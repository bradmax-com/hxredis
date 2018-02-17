package redis.util;

class Slot
{
    public static inline function make(key:String):Int
        return Crc16.make(haxe.io.Bytes.ofString(key)) % 16384;
}