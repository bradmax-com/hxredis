package redis.command;

class Key extends RedisCommand
{
    public function set(key:String, value:String):Bool
        return writeData('SET', [key, value], key) == "OK";

    public function get(key:String):String
        return writeData('GET', [key], key);
        
    public function exists(key:String):Bool
        return writeData('EXISTS', [key], key) == 1;

    public function delete(key:String):Bool
        return writeData('DEL', [key], key) == 1;

    public function type(key:String):String
        return writeData('TYPE', [key], key);

    public function keys(pattern:String):Array<Dynamic>
        return writeData('KEYS', [pattern]);

    public function randomKey():String
        return writeData('RANDOMKEY');

    public function rename(oldKey:String, newKey:String):Bool
        return oldKey == newKey
            ? throw "Please re-enter keys: oldKey has to be different than newKey"
            : writeData('RENAME', [oldKey, newKey]) == 'OK'; //TODO: crosslot error

    public function renameSafely(oldKey:String, newKey:String):Bool
        return oldKey == newKey
            ? throw "Please re-enter keys: oldKey has to be different than newKey"
            : writeData('RENAMENX', [oldKey, newKey]) == 'OK'; //TODO: crosslot error

    public function expire(key:String, seconds:Int):Bool
        return writeData('EXPIRE', [key, ""+seconds], key) == 1;

    public function expireAt(key:String, unixTime:Int):Bool
        return writeData('EXPIREAT', [key, ""+unixTime], key) == 1;

    public function ttl(key:String):Int
        return writeData('TTL', [key], key);

    public function move(key:String, dbIndex:Int):Bool
        return writeData('MOVE', [key, ""+dbIndex], key) == 1;

    public function getSet(key:String, value:String):String
        return writeData('GETSET', [key, value], key);

    public function multiGet(keys:Array<String>):Array<Dynamic>
        return writeData('MGET', keys);

    public function setSafely(key:String, value:String):Bool
        return writeData('SETNX', [key, ""+value], key) == 1;

    public function multiSet(keys:Array<String>):Bool
        return writeData('MSET', keys) == 'OK';

    public function multiSetSafely(keys:Array<String>):Bool
        return writeData('MSETNX', keys) == 'OK';

    public function increment(key:String):Int
        return writeData('INCR', [key], key);

    public function incrementBy(key:String, value:Int):Int
        return writeData('INCRBY', [key, ""+value], key);

    public function decrement(key:String):Int
        return  writeData('DECR', [key], key);

    public function decrementBy(key:String, value:Int):Int
        return writeData('DECRBY', [key, ""+value], key);
}