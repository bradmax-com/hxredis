package redis;

import sys.net.Host;
import sys.net.Socket;
import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Output;

import redis.command.Cluster;
import redis.command.Connection;
import redis.command.Server;
import redis.command.Key;
import redis.command.List;
import redis.command.Set;
import redis.command.Sort;

import redis.util.Slot;
import redis.util.RedisInputStream;


class Redis
{    
    private static inline var EOL:String = "\r\n";
    private var socket:Socket;
    private var connections = new Map<String, Socket>();
    private var currentNodes = new Array<{hash:String, host:String, port:Int, from:Int, to:Int}>();
    private var redir = false;

    public var cluster:Cluster = null;
    public var key:Key = null;
    public var list:List = null;
    public var set:Set = null;
    public var connection:Connection = null;
    public var server:Server = null;


    public function new(){
        cluster = new Cluster(writeData);
        key = new Key(writeData);	
        list = new List(writeData);	
        set = new Set(writeData);	
        connection = new Connection(writeData);	
        server = new Server(writeData);
    }

    public function redirect():Redis
    {
        redir = true;
        return this;
    }

    public function connect(?host:String = "localhost", ?port:Int = 6379, ?timeout:Float = 100)
    {
        var s = new Socket();
        s.setTimeout(timeout);
        s.connect(new Host(host), port);        
        connections.set('$host:$port', s);

        if(socket == null)
            socket = s;

        return s;
    }

    private function writeData(command:String, ?args:Array<String> = null, ?key:String = null):Dynamic
    {
        args = (args == null) ? [] : args;
        var useRedirect = redir;
        redir = false;
        return writeSocketData(command, args, key, false, useRedirect);
    }

    private function writeSocketData(command:String, args:Array<String>, ?key:String, ?moved:Bool = false, ?useRedirect:Bool = false):Dynamic
    {
        // trace(command, args);

        var soc = socket;
        if(key != null && useRedirect)
            soc = findSlotSocket(key);

        soc.output.writeString('*${args.length + 1}$EOL');
        soc.output.writeString("$"+'${command.length}$EOL');
        soc.output.writeString('${command}$EOL');
        for(i in args){
            soc.output.writeString("$"+'${i.length}$EOL');
            soc.output.writeString('${i}$EOL');
        }
        
        var data = process(soc.input);
        // trace('DATA', data);

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

    private function findSlotSocket(key:String){
        var slot = Slot.make(key);
        // trace('SLOT', slot);
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

    private function process(si:Input):Dynamic
    {
        var b = String.fromCharCode(si.readByte());
        // trace('REPLY TYPE: $b');

        return switch(b){
            case '+':
                processStatusCodeReply(si);
            case '$':
                processBulkReply(si);
            case '*':
                processMultiBulkReply(si);
            case ':':
                processInteger(si);
            case '-':
                processError(si);
            case _:
                b;
        }
    }

    private function processStatusCodeReply(si:Input):String
    {
        // trace('--------------- processStatusCodeReply');
        var res = si.readLine();
        return res;
    }

    private function processBulkReply(si:Input):String
    {
        // trace('--------------- processBulkReply');
        var len = RedisInputStream.readIntCrLf(si);
        if(len == -1)
            return null;

        var buff = Bytes.alloc(len);
        var offset = 0;

        while (offset < len) {
            var size = si.readBytes(buff, offset, len - offset);
            if (size == -1) 
                return null; //exception
            offset += size;
        }

        si.readByte();
        si.readByte();

        return buff.toString();
    }

    private function processMultiBulkReply(si:Input):Array<Dynamic>
    {
        // trace('--------------- processMultiBulkReply');
        var len = RedisInputStream.readIntCrLf(si);
        if(len == -1)
            return null;

        var res:Array<Dynamic> = [];

        for (i in 0...len) {
            try {
                res.push(process(si));
            } catch (err:Dynamic) {
                res.push(err);
            }
        }

        return res;
    }

    private function processInteger(si:Input):Float
    {
        // trace('--------------- processInteger');
        return RedisInputStream.readFloatCrLf(si);
    }

    private function processError(si:Input):String
    {
        trace('--------------- processError');
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