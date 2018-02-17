package redis.command;

class Hash extends RedisCommand
{
    
    public function hdel(key :String, field :String):Bool
        return writeData('HDEL', [key, field], key) > 0;

    public function hexists(key :String, field :String):Bool
        return writeData('HEXISTS', [key, field], key) > 0;

    public function hget(key :String, field :String):String
        return writeData('HGET', [key, field], key);

    public function hgetall(key :String):Map<String,String>
    {
        var arr:Array<String> = writeData('HGETALL', [key], key);
        var ret = new Map<String,String>();
        while( arr.length > 0 )
            ret.set(arr.shift(), arr.shift());
        return ret;
    }

    public function hincrby(key :String, field :String, increment :Int):Int
        return writeData('HINCRBY', [key, field, ""+increment], key);

    public function hincrbyfloat(key :String, field :String, increment :Float) :Float
        return writeData('HINCRBYFLOAT', [key, field, ""+increment], key);

    public function hkeys(key :String) :Array<String>
        return writeData('HKEYS', [key], key);

    public function hlen(key :String) :Int
        return writeData('HLEN', [key], key);

    public function hmget(key :String, fields :Array<String>) :Array<String>
        return writeData('HMGET', [key].concat(fields), key);

    public function hmset(key :String, fields :Map<String,String>) :Bool
    {
        var params:Array<String> = [key];
        for( kk in fields.keys() )
        {
            params.push(kk);
            params.push(fields.get(kk));
        }
        return writeData('HMSET', params, key) == 'OK';
    }

    public function hset(key :String, field :String, value :String) :Bool
        return writeData('HSET', [key, field, value], key) > 0;

    public function hsetnx(key :String, field :String, value :String) :Bool
        return writeData('HSETNX', [key, field, value], key) > 0;

    public function hvals(key :String) :Array<String>
        return writeData('HVALS', [key], key);
}