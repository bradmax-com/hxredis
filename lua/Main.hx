package;

import processing.structures.HyperLogLogPlusPlus;

typedef HllModel = {
    var bytes:haxe.io.Bytes;
}

class Main{

    public static function main(){
        #if lua
        return Main.calc(untyped __lua__("KEYS"), untyped __lua__("ARGV"));
        #else
        trace(Main.calc([], []));
        #end
        
    }
 
    public static function calc(?keys:Array<Dynamic> = null, ?args:Array<Dynamic> = null){
        #if lua
        var numKeys:Int = Std.parseInt(untyped __lua__("#keys")+"")+1;
        #else
        var numKeys:Int = 0;
        #end
        for(i in 0...86400){
            untyped __lua__("redis.call")('LPUSH', '1', haxe.crypto.Md5.encode(i+""));
        }


        return "ok";
        
        var a:Array<Dynamic> = [];
        var k:Array<Dynamic> = [];

        

        for(i in 1...numKeys)
            a.push(args[i]);

        for(i in 1...numKeys)
            k.push(keys[i]);

        var hll = new HyperLogLogPlusPlus(14, null);

        for(i in 0...10)
            hll.add('$i');


        for(i in 0...100){
            untyped __lua__("redis.call")('set', 'key_$i', i);
        }


        // var size:Int = 1024*1024;
        // var b = haxe.io.Bytes.alloc(size);
        
        // for(i in 0...100000)
        //     b.set(Std.int(i%size), Std.int(i%10));
        

        // return b.toString().length + "";
        // var n = 0;
        // for(i in 0...100000){
        //     n += i;
        // }

        // return n+"";

        return hll.count()+"_done";
    }
}

