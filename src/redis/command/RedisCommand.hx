package redis.command;

class RedisCommand
{
    private var writeRedisData:String -> Array<Dynamic> -> String -> Dynamic = null;

    public function new(writeData:String -> Array<Dynamic> -> String -> Dynamic)
        this.writeRedisData = writeData;

    function writeData(command:String, ?args:Array<Dynamic> = null, ?key:String=null):Dynamic
        return writeRedisData(command, args == null ? [] : args, key);
}