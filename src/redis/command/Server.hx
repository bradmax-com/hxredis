package redis.command;

enum SlaveConfig
{
    THostPort(host:String, port:Int);
    TNoOne;
}

class Server extends RedisCommand
{
    public function save():Bool
        return writeData('SAVE') == 'OK';

    public function backgroundSave():Bool
        return writeData('BGSAVE') == 'OK';

    public function lastSave():Int
        return writeData('LASTSAVE');

    public function shutdown():Void
        writeData('SHUTDOWN');

    public function backgroundRewriteAppendOnlyFile():Bool
        return writeData('BGREWRITEAOF') == 'OK';

    public function info():Array<Dynamic>
        return writeData('INFO');
    
    public function slaveOf(config:SlaveConfig):Bool
        return writeData('SLAVEOF',
        switch(config){
                case THostPort(host, port):
                    [host, ""+port];
                
                case TNoOne:
                    ['no', 'one'];
            }
        ) == 'OK';

    public function dbSize():Int
        return writeData('DBSIZE');

    public function flushDB():Bool
        return writeData('FLUSHDB') == 'OK';

    public function flushAll():Bool
        return writeData('FLUSHALL') == 'OK';

    public function clientkill():Void
        throw "not implemented";

    public function clientlist():Void
        throw "not implemented";

    public function clientgetname():Void
        throw "not implemented";

    public function clientsetname():Void
        throw "not implemented";

    public function configget():Void
        throw "not implemented";

    public function configset():Void
        throw "not implemented";

    public function configresetstat():Void
        throw "not implemented";
	
    public function debugobject():Void
        throw "not implemented";

    public function debugsetfault():Void
        throw "not implemented";
	
    public function echo():Void
        throw "not implemented";
	
    public function monitor():Void
        throw "not implemented";

    public function slowlog():Void
        throw "not implemented";

    public function sync():Void
        throw "not implemented";

    public function time():Void
        throw "not implemented";
}