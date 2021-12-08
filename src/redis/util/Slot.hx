package redis.util;

class Slot
{
    public static inline function make(key:String):Int
        return Crc16.make(haxe.io.Bytes.ofString(key, haxe.io.Encoding.RawNative)) % 16384;
}