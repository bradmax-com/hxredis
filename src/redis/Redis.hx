package redis;

import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;
import redis.command.Bit;
import redis.command.Cluster;
import redis.command.Connection;
import redis.command.Hash;
import redis.command.Key;
import redis.command.List;
import redis.command.PubSub;
import redis.command.Script;
import redis.command.Server;
import redis.command.Set;
import redis.command.Sort;
import redis.command.Transaction;
import redis.util.RedisInputStream;
import redis.util.Slot;
import sys.net.Host;
import sys.net.Socket;

class Redis
{    
    private static inline var EOL:String = "\r\n";

    private var socket:Socket;
    private var connections = new Map<String, Socket>();
    private var currentNodes = new Array<{hash:String, host:String, port:Int, from:Int, to:Int}>();
    private var redir = false;

    public var bit:Bit = null;
    public var cluster:Cluster = null;
    public var connection:Connection = null;
    public var hash:Hash = null;
    public var key:Key = null;
    public var list:List = null;
    public var pubSub:PubSub = null;
    public var script:Script = null;
    public var server:Server = null;
    public var set:Set = null;
    public var sort:Sort = null;
    public var transaction:Transaction = null;

    public function new(){
        bit = new Bit(writeData);
        cluster = new Cluster(writeData);
        connection = new Connection(writeData);	
        hash = new Hash(writeData);
        key = new Key(writeData);	
        list = new List(writeData);	
        pubSub = new PubSub(writeData);
        script = new Script(writeData);
        server = new Server(writeData);
        set = new Set(writeData);	
        sort = new Sort(writeData);
        transaction = new Transaction(writeData);
    }

    public function redirect():Redis
    {
        redir = true;
        return this;
    }

    public function connect(?host:String = "localhost", ?port:Int = 6379, ?timeout:Float = 5)
    {
        var s = new Socket();
        #if cpp
        s.setTimeout(timeout);
        s.setFastSend(true);
        #end
        s.connect(new Host(host), port);
        // s.setBlocking(false);
        connections.set('$host:$port', s);

        if(socket == null)
            socket = s;

        return s;
    }

    private function writeData(command:String, ?args:Array<Dynamic> = null, ?key:String = null):Dynamic
    {
        args = (args == null) ? [] : args;
        var useRedirect = redir;
        redir = false;
        return writeSocketData(command, args, key, false, useRedirect);
    }

    private function writeSocketData(command:String, args:Array<Dynamic>, ?key:String, ?moved:Bool = false, ?useRedirect:Bool = false):Dynamic
    {
        var str = "";
        var soc = socket;
        if(key != null && useRedirect)
            soc = findSlotSocket(key);
            
        soc.output.writeString('*${args.length + 1}$EOL');
        soc.output.writeString("$"+'${command.length}$EOL');
        soc.output.writeString('${command}$EOL');

        for(i in args){
            soc.output.writeString("$"+'${(i+"").length}$EOL');
            soc.output.writeString('${i}$EOL');
        }
        
        var data = process(soc);

        var movedString = false; 
        if(Std.is(data, String)){
            movedString = data.indexOf("MOVED") == 0;

            if(movedString && moved == false){
                currentNodes = [];
                return writeSocketData(command, args, key, true);
            }
        }

        return movedString ? null : data;
    }

    private function findSlotSocket(key:String):Socket
    {
        var slot = Slot.make(key);

        if(currentNodes.length == 0){
            currentNodes = cluster.nodes();
        }

        for(i in currentNodes){
            if(slot >= i.from && slot <= i.to){
                if(connections.exists('${i.host}:${i.port}')){
                    return connections.get('${i.host}:${i.port}');
                }else{
                    return connect(i.host, i.port);
                }
                break;
            }
        }

        return null;
    }

        var bufferLength = 0;
        var input:haxe.io.BytesInput = null;
        var chunkSize = 2 << 9;
        var bytes = Bytes.alloc(2 << 9);
        var str = new StringBuf();



    var poll = new cpp.net.Poll(100);
    private function process(soc:Socket):Dynamic
    {
        var i = 0;
        while(true){
            if(poll.poll([soc]).length == 0)
                Sys.sleep(0.00000000001);
            else
                break;

            i++;
        }

        var si = soc.input;
        var b:Int = si.readByte();

        var ret:Dynamic = null;
        switch(String.fromCharCode(b)){
            case '+':
                ret = processStatusCodeReply(soc);
            case '$':
                ret = processBulkReply(soc);
            case '*':
                ret = processMultiBulkReply(soc);
            case ':':
                ret = processInteger(soc);
            case '-':
                ret = processError(soc);
            case _:
                ret = b;
        }

        return ret;
    }

    private function processStatusCodeReply(soc:Socket):String
    {
        var si = soc.input;
        var res = si.readLine();
        return res;
    }

    private function processBulkReply(soc:Socket):String
    {
        var si = soc.input;
        var len = RedisInputStream.readIntCrLf(si);

        if(len == -1)
            return null;

        var buff = Bytes.alloc(len);
        var offset = 0;

        while (offset < len) {
            var size = si.readBytes(buff, offset, len - offset);
            if (size == -1) 
                return null;
            offset += size;
        }

        si.readByte();
        si.readByte();

        return buff.toString();
    }

    private function processMultiBulkReply(soc:Socket):Array<Dynamic>
    {
        var si = soc.input;
        var len = RedisInputStream.readIntCrLf(si);
        if(len == -1)
            return null;

        var res:Array<Dynamic> = [];

        for (i in 0...len) {
            try {
                res.push(process(soc));
            } catch (err:Dynamic) {
                res.push(err);
            }
        }

        return res;
    }

    private function processInteger(soc:Socket):Float
    {
        var si = soc.input;
        return RedisInputStream.readFloatCrLf(si);
    }

    private function processError(soc:Socket):String
    {
        var si = soc.input;
        var res:String = si.readLine();
        trace('ERROR: $res');
        switch(res.split(" ")[0]){
            case 'CROSSSLOT':
                return null;
            case _:
                return null;
        }
        return res;
    }
}