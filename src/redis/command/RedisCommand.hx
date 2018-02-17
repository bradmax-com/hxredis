package redis.command;

class RedisCommand
{
    private var writeRedisData:String -> Array<String> -> String -> Dynamic = null;

    public function new(writeData:String -> Array<String> -> String -> Dynamic)
        this.writeRedisData = writeData;

    function writeData(command:String, ?args:Array<String> = null, ?key:String=null):Dynamic
        return writeRedisData(command, args == null ? [] : args, key);
}