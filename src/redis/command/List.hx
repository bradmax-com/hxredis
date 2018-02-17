package redis.command;

class List extends RedisCommand
{
    public function rightPush(key:String, value:String):Bool
        return writeData('RPUSH', [key, value], key) == 'OK';

    public function leftPush(key:String, value:String):Bool
        return writeData('LPUSH', [key, value], key) == 'OK';

    public function length(key:String):Int
        return writeData('LLEN', [key], key);

    public function range(key:String, start:Int, end:Int):Array<Dynamic>
        return writeData('LRANGE', [key, ""+start, ""+end], key);

    public function trim(key:String, start:Int, end:Int):Bool
        return writeData('LTRIM', [key, ""+start, ""+end], key) == 'OK';

    public function index(key:String, index:Int):String
        return writeData('LINDEX', [key, ""+index], key);

    public function set(key:String, index:Int, value:String):Bool
        return writeData('LSET', [key, ""+index, value], key) == 'OK';

    public function remove(key:String, count:Int, value:String):Int
        return writeData('LREM', [key, ""+count, value], key);

    public function leftPop(key:String):String
        return writeData('LPOP', [key], key);

    public function rightPop(key:String):String
        return writeData('RPOP', [key], key);

    public function rightPopLeftPush(srcList:String, distList:String):String
        return writeData('RPOPLPUSH', [srcList, distList]);
}