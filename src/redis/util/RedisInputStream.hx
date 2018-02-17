package redis.util;

import haxe.io.Input;

class RedisInputStream
{
    public static function readFloatCrLf(i:Input):Float
    {
        var val = "";
        while(true){
            var b = String.fromCharCode(i.readByte());
            if(b == "\r"){
                i.readByte();
                break;
            }else{
                val += b;
            }
        }
        return Std.parseFloat(val);
    }

    public static function readIntCrLf(i:Input):Int
    {
        return Std.int(readFloatCrLf(i));
    }
}