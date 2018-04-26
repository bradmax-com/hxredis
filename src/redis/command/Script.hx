package redis.command;

class Script extends RedisCommand
{
    public function eval(script:String, keys:Array<Dynamic>, args:Array<Dynamic>):Dynamic
    {
        var a:Array<Dynamic> = ['$script', ""+keys.length];
        return writeData('EVAL', a.concat(keys).concat(args));
    }

    public function evalsha(sha1:String, keys:Array<Dynamic>, args:Array<Dynamic>):Dynamic
    {
        var a:Array<Dynamic> = [sha1, ""+keys.length];
        return writeData('EVALSHA', a.concat(keys).concat(args));
    }

    public function exists(sha1:Array<String>):Array<Int>
        return writeData('SCRIPT', ['EXISTS'].concat(sha1));

    public function flush():String
        return writeData('SCRIPT', ['FLUSH']);

    public function kill():String
        return writeData('SCRIPT', ['KILL']);

    public function load(script:Dynamic):String{
        if(Std.is(script, String)){
            return writeData('SCRIPT', ['LOAD', '"$script"']);
        }

        if(Std.is(script, haxe.io.Bytes)){
            return writeData('SCRIPT', ['LOAD', script]);
        }

        return null;
    }

        
}