package redis.util;

import haxe.io.Input;

class RedisInputStream
{
    public static function readFloatCrLf(i:Input):Float
    {
        var val = new StringBuf();
        while(true){
            var b = i.readByte();
            // trace(b);
            if(b == 13){
                i.readByte();
                break;
            }else{
                val.addChar(b);
            }
        }
        // trace(val, val.toString(), Std.parseFloat(val.toString()));
        return Std.parseFloat(val.toString());
    }

    public static function readIntCrLf(i:Input):Int
    {
        return Std.int(readFloatCrLf(i));
    }
}