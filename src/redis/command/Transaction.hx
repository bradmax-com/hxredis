package redis.command;

class Transaction extends RedisCommand
{   
    public function exec():Void
        throw "not implemented";

    public function multi():Void
        throw "not implemented";

    public function unwatch():Void
        throw "not implemented";

    public function watch():Void
        throw "not implemented";
}