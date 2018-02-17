package redis.command;

@:enum
abstract Failover(String) {
    var FORCE = 'FORCE';
    var TAKEOVER = 'TAKEOVER';
}

@:enum
abstract Reset(String) {
    var HARD = 'HARD';
    var SOFT = 'SOFT';
}

@:enum
abstract SetSlot(String) {
    var IMPORTING = 'IMPORTING';
    var MIGRATING = 'MIGRATING';
    var STABLE = 'STABLE';
    var NODE = 'NODE';
}

class Cluster extends RedisCommand
{
    public function addSlots(slots:Array<String>):Bool
        return writeData('CLUSTER', ['ADDSLOTS']) == 'OK';

    public function countFailureReports(nodeId:String):Int
        return writeData('CLUSTER', ['COUNT-FAILURE-REPORTS', nodeId]);

    public function countKeysInSlot(slot:String):Int
        return writeData('CLUSTER', ['COUNTKEYSINSLOT', slot]);

    public function delSlots(slots:Array<String>):Bool
        return writeData('CLUSTER', ['DELSLOTS'].concat(slots)) == 'OK';

    public function failover(type:Failover):Bool
        return writeData('CLUSTER', ['FAILOVER', ""+type]) == 'OK';

    public function forget(nodeId:String):Bool
        return writeData('CLUSTER', ['FORGET', nodeId]) == 'OK';

    //TODO parse
    public function getKeysInSlot(slot:Int, count:Int):Dynamic
        return writeData('CLUSTER', ['GETKEYSINSLOT', ""+slot, ""+count]);

    //TODO parse
    public function info():Dynamic
        return writeData('CLUSTER', ['INFO']);

    public function keySlot(key:String):Int
        return writeData('CLUSTER', ['KEYSLOT', key]);

    public function meet(host:String, port:Int):Bool
        return writeData('CLUSTER', ['MEET', host, ""+port]) == 'OK';

    public function nodes():Dynamic
        return parseNodes(writeData('CLUSTER', ['NODES']));

    public function replicate(nodeId:String): Bool
        return writeData('CLUSTER', ['REPLICATE', nodeId]) == 'OK';

    public function reset(type:Reset):Bool
        return writeData('CLUSTER', ['RESET', ""+type]) == 'OK';

    public function saveConfig():Bool
        return writeData('CLUSTER', ['SAVECONFIG']) == 'OK';

    public function setConfigEpoch(config:String):Bool
        return writeData('CLUSTER', ['SET-CONFIG-EPOCH', config]);

    public function setSlot(slot:Int, type:SetSlot, ?nodeId:String=null):String
        return writeData('CLUSTER', ['SETSLOT', ""+slot, ""+type].concat((nodeId == null) ? [] : [nodeId]));
    
    public function slaves():Dynamic
        return parseNodes(writeData('CLUSTER', ['SLAVES']));

    //TODO parse
    public function slots():Dynamic
        return writeData('CLUSTER', ['SLOTS']);
    
    public function readOnly():String
        return writeData('READONLY');

    public function readWrite():String
        return writeData('READWRITE');

    private function parseNodes(input:String):Array<{hash:String, host:String, port:Int, from:Int, to:Int}>
    {
        var value = input.split('\n');
        var arr:Array<{hash:String, host:String, port:Int, from:Int, to:Int}> = [];
        
        for(i in value){
            try{
                var data:Array<String> = i.split(' ');
                var c = data[1].split('@')[0].split(':');
                var ft = data[8].split('-');
                arr.push({
                    hash: data[0],
                    host: c[0],
                    port: Std.parseInt(c[1]),
                    from: Std.parseInt(ft[0]),
                    to: Std.parseInt(ft[1])
                });
            }catch(err:Dynamic){
                continue;
            }
        }

        return arr;
    }
}