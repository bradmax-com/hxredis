package redis.command;

class Script extends RedisCommand
{
    public function eval(script:String, keys:Array<String>, args:Array<String>):Dynamic
        return writeData('EVAL', ['"$script"', ""+keys.length].concat(keys).concat(args));

    public function evalsha(sha1:String, keys:Array<String>, args:Array<String>):Dynamic
        return writeData('EVAL', [sha1, ""+keys.length].concat(keys).concat(args));

    public function exists(sha1:Array<String>):Array<Int>
        return writeData('SCRIPT', ['EXISTS'].concat(sha1));

    public function flush():String
        return writeData('SCRIPT', ['FLUSH']);

    public function kill():String
        return writeData('SCRIPT', ['KILL']);

    public function load(script:String):String
        return writeData('SCRIPT', ['LOAD', '"$script"']);
}