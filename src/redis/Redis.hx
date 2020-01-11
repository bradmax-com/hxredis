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


typedef Request = {
    var command:String;
    @:optional var args:Array<Dynamic>;
    @:optional var key:String;
}
class Redis
{    
    private static inline var EOL:String = "\r\n";

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
    public var useAcumulate = false;
    public var accumulator:Array<Request> = [];

    private var socket:Socket;
    private var connections:Map<String, Socket> = new Map();
    private var currentNodes:Array<redis.command.Cluster.Node> = [];
    private var useCluster = false;
    private var bufferLength = 0;
    private var input:haxe.io.BytesInput = null;
    private var chunkSize = 2 << 9;
    private var bytes = Bytes.alloc(2 << 9);
    private var str = new StringBuf();

    public function new(?useCluster = false)
    {
        this.useCluster = useCluster;
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

    public function connect(?host:String = "localhost", ?port:Int = 6379, ?timeout:Float = 5, ?maxRetry:Int = 10)
    {
        var s:Socket = null;
        while(maxRetry-- > 0){
            try{
                s = new Socket();

                #if cpp
                s.setTimeout(timeout);
                s.setFastSend(true);
                #end
                
                s.connect(new Host(host), port);
                connections.set('$host:$port', s);

                socket = s;

                return s;
            }catch(err:Dynamic){
                cleanClose(s);
                Sys.sleep(1);
                trace(err);
            }
        }
        throw 'Unable to connect to host@$host:$port';
        return null;
    }

    function cleanClose(s:Socket){
        s.setTimeout(0.01);
        try{
            while(true){
                s.input.readByte();
            }
        }catch(err:Dynamic){}
        s.shutdown(true, true);
        s.close();
    }

    public function close(){
        for(i in connections){
            try{
                cleanClose(i);
            }catch(err:Dynamic){}
        }
        connections = new Map();
        currentNodes = [];
        socket = null;
    }

    public function accumulate()
    {
        useAcumulate = true;
    }

    public function flush()
    {
        useAcumulate = false;
        var resp:Array<Dynamic> = flushAccumulator();
        return resp;
    }

    private function flushAccumulator()
    {
        var amap:Map<Socket, Array<Request>> = new Map();

        //split requests to differenet sockets
        var orginalIndexes:Array<Socket> = [];
        var idx = 0;
        for(i in accumulator){
            var key = i.key;
            var soc = socket;

            if(key != null){
                soc = findSlotSocket(key);
                if(!amap.exists(soc)){
                    amap.set(soc, new Array<Request>());
                }
                amap.get(soc).push(i);
            }

            if(soc == null){
                soc = socket;
                if(!amap.exists(soc)){
                    amap.set(soc, new Array<Request>());
                }
                amap.get(soc).push(i);
            }

            orginalIndexes[idx++] = soc;
        }

        var data:Array<Dynamic> = [];
        
        for(soc in amap.keys()){
            var cmd = amap.get(soc);
            var buffer = new haxe.io.BytesBuffer();
            
            for(c in cmd){
                writeSocketDataMulti(buffer, c.command, c.args, c.key);
            }
            var bytes = buffer.getBytes();
            soc.output.write(bytes);
            var rsp = process(soc, cmd.length);
            var outArr:Array<Dynamic> = [];

            if(Std.is(rsp, Array) == true){
                outArr = [].concat(cast rsp);
            }else{
                outArr = [rsp];
            }

            var idx = 0;
            for(i in 0...orginalIndexes.length){
                if(soc == orginalIndexes[i]){
                    data[i] = outArr[idx++];
                }
            }
        }

        accumulator = [];
        return data;
    }

    private function writeSocketDataMulti(buffer: haxe.io.BytesBuffer, command:String, args:Array<Dynamic>, ?key:String)
    {
        buffer.addString('*${args.length + 1}$EOL');
        buffer.addString("$"+'${command.length}$EOL');
        buffer.addString('${command}$EOL');

        for(i in args){
            buffer.addString("$"+'${(i+"").length}$EOL');
            buffer.addString('${i}$EOL');
        }
    }

    private function writeData(command:String, ?args:Array<Dynamic> = null, ?key:String = null, ?runOnAllNodes:Bool = false):Dynamic
    {
        trace("writeData", command, args, key);
        if(useAcumulate){
            accumulator.push({
                command: command, 
                args: args,
                key: key
            });
            return null;
        }else{
            args = (args == null) ? [] : args;
            var useRedirect = useCluster;
            return writeSocketData(command, args, key, false, useRedirect, runOnAllNodes);
        }
    }

    private function writeSocketData(command:String, args:Array<Dynamic>, ?key:String, ?moved:Bool = false, ?useRedirect:Bool = false, ?runOnAllNodes:Bool = false):Dynamic
    {
        var soc = socket;
        if(key != null && useRedirect){
            soc = findSlotSocket(key);
        }
        if(soc == null){
            soc = socket;
        }
        if(soc == null){
            return null;
        }

        soc.output.writeString('*${args.length + 1}$EOL');
        soc.output.writeString("$"+'${command.length}$EOL');
        soc.output.writeString('${command}$EOL');

        for(i in args){
            soc.output.writeString("$"+'${(i+"").length}$EOL');
            soc.output.writeString('${i}$EOL');
        }
        
        var data:Dynamic = process(soc);
        trace(data, command);

        var movedString = false;
        if(Std.is(data, String)){
            var dataStr:String = cast(data, String);
            movedString = dataStr.indexOf("MOVED") == 0;
            if(movedString && (moved == false)){
                currentNodes = [];
                return writeSocketData(command, args, key, true);
            }
        }
        return movedString ? null : data;
    }

    private function findSlotSocket(key:String):Socket
    {
        if(!useCluster){
            return socket;
        }

        var slot = Slot.make(key);
        
        if(currentNodes.length == 0){
            currentNodes = cluster.nodes();
        }

        for(i in currentNodes){
            if(isSlotInNode(slot, i)){
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

    private function allClusterNodes():Array<{host:String, port:Int}> {
        return null;
    }

    private function isSlotInNode(slot:Int, node:redis.command.Cluster.Node):Bool{
        for(range in node.slots){
            if(range.to == null){
                if(range.from == slot){
                    return true;
                }
            }else{
                if(slot >= range.from && slot <=range.to){
                    return true;
                }
            }
        }
        return false;
    }

    private function process(soc:Socket, ?count:Int=1):Dynamic
    {
        var i = 0;
        while(true){
            if(Socket.select([soc], [], [], null).read.length == 0){
                Sys.sleep(0.0001);
            }else{
                break;
            }
            trace("process", i);
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
        
        if(count > 1){
            var retArr = [ret];
            while(count-- > 1){
                ret = process(soc);
                retArr.push(ret);
            }
            return(retArr);
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
        
        switch(res.split(" ")[0]){
            case 'CROSSSLOT':
                return null;
            case _:
                return null;
        }
        return res;
    }
}