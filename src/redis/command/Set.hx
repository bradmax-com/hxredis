package redis.command;

class Set extends RedisCommand
{
    public function add(key:String, member:String):Bool
        return writeData('SADD', [key, member], key) > 0;

    public function addM(key:String, members:Array<String>):Bool
        return writeData('SADD', [key].concat(members), key) > 0;

    public function remove(key:String, member:String):Bool
        return writeData('SREM', [key, member], key) > 0;

    public function removeM(key:String, members:Array<String>):Bool
        return writeData('SREM', [key].concat(members), key) > 0;

    public function pop(key:String):String
        return writeData('SPOP', [key], key);

    public function move(srcKey:String, distKey:String, member:String):Int
        return writeData('SMOVE', [srcKey, distKey, member]);

    public function count(key:String):Int
        return writeData('SCARD', [key], key);

    public function hasMember(key:String, member:String):Bool
        return writeData('SISMEMBER', [key, member], key) > 0;

    public function intersect(keys:Array<String>):Array<Dynamic>
        return writeData('SINTER', keys);

    public function intersectStore(distKey:String, keys:Array<String>):Bool
        return writeData('SINTERSTORE', [distKey].concat(keys)) == 'OK';

    public function union(keys:Array<String>):Array<Dynamic>
        return writeData('SUNION', keys);

    public function unionStore(distKey:String, keys:Array<String>):Bool
        return writeData('SUNIONSTORE', [distKey].concat(keys)) == 'OK';

    public function difference(keys:Array<String>):Array<Dynamic>
        return writeData('SDIFF', keys);

    public function differenceStore(distKey:String, keys:Array<String>):Bool
        return writeData('SDIFFSTORE', [distKey].concat(keys)) == 'OK';

    public function members(key:String):Array<Dynamic>
        return writeData('SMEMBERS', [key], key);

    public function randomMember(key:String):String 
        return writeData('SRANDMEMBER', [key], key);

    public function sortedAdd(key:String, score:Float, member:String):Bool
        return writeData('ZADD', [key, ""+score, member], key) > 0;
        
    public function sortedAddM(key:String, members:Array<{score:Float, member:String}>):Bool{
        var arr:Array<String> = [key];
        for(i in members){
            arr.push(""+i.score);
            arr.push(i.member);
        }
        return writeData('ZADD', arr, key) > 0;
    }

    public function sortedRemove(key:String, member:String):Bool
        return writeData('ZREM', [key, member], key) > 0;

    public function sortedRemoveM(key:String, members:Array<String>):Bool
        return writeData('ZREM', [key].concat(members), key) > 0;

    public function sortedIncrementBy(key:String, increment:Float, member:String):Int
        return writeData('ZINCRBY', [key, ""+increment, member], key);
        
    public function sortedRange(key:String, start:Float, end:Float, ?withScores:Bool = false):Array<Dynamic>
        return writeData('ZRANGE', [key, ""+start, ""+end].concat(withScores ? ['WITHSCORES'] : []), key);

    public function sortedReverseRange(key:String, start:Float, end:Float, ?withScores:Bool = false):Array<Dynamic>
        return writeData('ZREVRANGE', [key, ""+start, ""+end].concat(withScores ? ['WITHSCORES'] : []), key);

    public function sortedRangeByScore(key:String, min:Float, max:Float, ?offset:Int = 0, ?count:Int = 0):Array<Dynamic>
        return writeData('ZRANGEBYSCORE', [key, ""+min, ""+max].concat((count > 0) ? ['LIMIT'] : []).concat([""+offset, ""+count]), key);

    public function sortedCount(key:String):Int
        return writeData('ZCARD', [key], key);

    public function sortedScore(key:String, member:String):Int
        return writeData('ZSCORE', [key, member], key);

    public function sortedRemoveRangeByScore(key:String, min:Float, max:Float):Int
        return writeData('ZREMRANGEBYSCORE', [key, ""+min, ""+max], key);
}