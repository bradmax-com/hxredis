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
        // trace('CONNECT: $host:$port');
        var s = new Socket();
        #if cpp
        s.setTimeout(timeout);
        // s.setFastSend(true);
        #end
        s.connect(new Host(host), port);
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
        // #if debug trace(command, args); #end
        var str = "";
        var soc = socket;
        if(key != null && useRedirect)
            soc = findSlotSocket(key);


        // str += '*${args.length + 1}$EOL';
        // str += "$"+'${command.length}$EOL';
        // str += '${command}$EOL';
        // for(i in args){
        //     str += "$"+'${(i+"").length}$EOL';
        //     str += '${i}$EOL';
        // }
        // trace("1.COMMAND ------------- " + str);

        // Profiler.tic("writeSocketData");
        // trace(soc);
        // trace(soc.output);
        // trace(args);
        // soc.setFastSend(true);
        soc.output.writeString('*${args.length + 1}$EOL');
        soc.output.writeString("$"+'${command.length}$EOL');
        soc.output.writeString('${command}$EOL');

        for(i in args){
            soc.output.writeString("$"+'${(i+"").length}$EOL');
            soc.output.writeString('${i}$EOL');
        }
        // Profiler.toc("writeSocketData");

        // Profiler.tic("process");
        // var data = process(soc.input);
        var data = process(soc);
        // Profiler.toc("process");
        // trace(data);

        // #if debug trace('DATA', data); #end

        // return "OK";

        var movedString = false; 
        if(Std.is(data, String)){
            movedString = (data+"").indexOf("MOVED") == 0;

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

    private function process2(si:Input):Dynamic
    {
        bufferLength = 0;
        str = new StringBuf();
        // bytes = Bytes.alloc(2 << 9);
        
        // Profiler.tic("process - while");
        while(true){
            try{
                bufferLength = si.readBytes(bytes, 0, chunkSize);
                input = new haxe.io.BytesInput(bytes, 0, bufferLength);

                if(input.length == 0)
                    break;

                // var s = input.readString(input.length);
                var s = bytes.getString(0, bufferLength);
                str.addSub(s, 0, s.length);

                if(bufferLength < chunkSize)
                    break;

                // var tmpBuff = bufferLength;
                // bufferLength = si.readBytes(bytes, bufferLength, chunkSize);
                // tmpBuff = bufferLength - tmpBuff;
                // str.addSub()
                // // bytes.get(bytes.length-1)
                // trace('bufferLength $bufferLength');


                // if(tmpBuff < chunkSize){
                //     break;
                // }


            }catch(err:Dynamic){
                // trace("eof", err, bytes.length);
                // trace(bytes.toString());
                // Sys.sleep(1);
                break;
            }
        }

        // Profiler.toc("process - while");
        // trace(str.toString(), str.length);
        // trace(bytes.sub(bytes.length - 2, 2).toString(), bytes.length);
        // return bytes.toString();
        return str.toString();
    }

    var poll = new cpp.net.Poll(100);
    private function process(soc:Socket):Dynamic
    {
        Profiler.tic("poll");
        var i = 0;
        while(true){
            if(poll.poll([soc], 0.00000000001).length == 0)
            // if(Socket.select([soc], [], []).read.length == 0)
                Sys.sleep(0.00000000001);
            else
                break;

            i++;
        }

        
        Profiler.toc("poll");
        trace('__________________ $i');

        Profiler.tic("byte");
        var si = soc.input;
        var b = String.fromCharCode(si.readByte());
        Profiler.toc("byte");

        // #if debug trace('REPLY T/YPE: $b'); #end

        var ret:Dynamic = null;
        switch(b){
            case '+':
                Profiler.tic("processStatusCodeReply");
                ret = processStatusCodeReply(soc);
                Profiler.toc("processStatusCodeReply");
            case '$':
                Profiler.tic("processBulkReply");
                ret = processBulkReply(soc);
                Profiler.toc("processBulkReply");
            case '*':
                Profiler.tic("processMultiBulkReply");
                ret = processMultiBulkReply(soc);
                Profiler.toc("processMultiBulkReply");
            case ':':
                Profiler.tic("processInteger");
                ret = processInteger(soc);
                Profiler.toc("processInteger");
            case '-':
                Profiler.tic("processError");
                ret = processError(soc);
                Profiler.toc("processError");
            case _:
                Profiler.tic("b");
                ret = b;
                Profiler.toc("b");
        }

        // trace(ret);
        return ret;
    }

    private function processStatusCodeReply(soc:Socket):String
    {
        // #if debug trace('--------------- processStatusCodeReply'); #end

        var si = soc.input;
        var res = si.readLine();
        return res;
    }

    private function processBulkReply(soc:Socket):String
    {
        var si = soc.input;
        // #if debug trace('--------------- processBulkReply'); #end
        var len = RedisInputStream.readIntCrLf(si);
        // trace('LEN: $len');
        if(len == -1)
            return null;

        var buff = Bytes.alloc(len);
        var offset = 0;

        while (offset < len) {
            var size = si.readBytes(buff, offset, len - offset);
            // trace('SIZE: $size');
            if (size == -1) 
                return null; //exception
            offset += size;
        }

        si.readByte();
        si.readByte();
        // trace(buff.toString());

        return buff.toString();
    }

    private function processMultiBulkReply(soc:Socket):Array<Dynamic>
    {
        var si = soc.input;
        // #if debug trace('--------------- processMultiBulkReply'); #end
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
        // #if debug trace('--------------- processInteger'); #end
        var si = soc.input;
        return RedisInputStream.readFloatCrLf(si);
    }

    private function processError(soc:Socket):String
    {

        var si = soc.input;
        // #if debug trace('--------------- processError'); #end
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