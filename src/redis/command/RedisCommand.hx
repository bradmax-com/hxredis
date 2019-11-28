package redis.command;

class RedisCommand
{
    private var writeRedisData:String -> Array<Dynamic> -> String -> Bool -> Dynamic = null;

    public function new(writeData:String -> Array<Dynamic> -> String -> Bool -> Dynamic)
        this.writeRedisData = writeData;

    function writeData(command:String, ?args:Array<Dynamic> = null, ?key:String=null, ?runOnAllNodes:Bool = false):Dynamic
        return writeRedisData(command, args == null ? [] : args, key, runOnAllNodes);
}