package redis.command;

class Cluster extends RedisCommand
{

    //TODO
    public function slots():Dynamic
    {
        var value:Array<String> = writeData('CLUSTER', ['SLOTS']);
        return value;
    }

    public function nodes():Array<{hash:String, host:String, port:Int, from:Int, to:Int}>
    {
        var value:Array<String> = writeData('CLUSTER', ['NODES']).split('\n');
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