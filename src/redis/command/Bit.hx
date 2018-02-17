package redis.command;

class Bit extends RedisCommand
{
    public function set(key:String, offset:Int, value:Int):String
        return writeData('SETBIT', [key, ""+offset, ""+value], key);

    public function get(key:String, offset:Int):Int
        return writeData('GETBIT', [key, ""+offset], key);

    public function count(key:String, ?start:Null<Int> = null, ?end:Null<Int>=null):Int
        return writeData('BITCOUNT', [key].concat((start != null && end != null) ? [""+start, ""+end] : []), key);

    public function pos(key:String, start:Int, ?end:Null<Int>=null):Int
        return writeData('BITPOS', [key, ""+start].concat((end != null) ? [""+end] : []), key);
}