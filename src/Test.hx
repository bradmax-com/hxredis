class Test
{
    public static function main()
    {
        trace("start");


        var r = new redis.Redis();
        r.connect("192.168.1.100", 6379);
        // r.connect("onet.pl", 80);

            trace(r.cluster.nodes());

        trace("##############################");


        // var stra = "";
        // for(i in 0...1024){
        //     stra+="a";
        // }

        // var str = "";
        // for(i in 0...1){
        //     str+=stra;
        // }

        // var tmp = "";

        // for(i in 0...100){
        //     tmp+=str;
        // }
        // str=tmp;


        // trace('write');
        // var s = haxe.Timer.stamp();
        // for(i  in 0...5){
        //     trace(r.key.set('test_$i', '$i$str'));
        // }
        // var e = haxe.Timer.stamp();
        // trace(e-s);
        // trace("TEST");
        // trace(r.key.exists('test_1'));
        // trace(r.key.exists('test_2'));
        // trace(r.key.exists('test_3'));
        // trace(r.key.type('test_1'));
        // trace(r.key.delete('test_1'));
        // trace(r.key.delete('test_2'));
        // trace(r.key.keys('*'));
        // trace(r.key.set("dup1", "10"));
        // // trace(r.key.rename("dup1", "dup1"));
        // for(i in 2...100){
        //     trace(i, r.key.rename("dup1", "dup"+i));
        // // }
        // trace(r.key.expire('test_4', 3));
        trace(r.key.set('incr', "10"));
        trace(r.key.get('incr'));
        trace(r.key.increment('incr'));
        trace(r.key.get('incr'));
        trace(r.key.incrementBy('incr', 10));
        trace(r.key.get('incr'));



        

        trace(r.redirect().key.set("DUAPAAA", "100"));


        // Sys.sleep(4);
        // trace(r.key.expire('test_5',100));
        // trace(r.key.ttl('test_5'));
        // var keys = [""];
        // for(i in 0...10){
        //     keys.push('key_$i');
        //     r.key.set('key_$i', '$i');
        // }
        // trace(r.key.multiGet(keys));
        
        // trace('read');
        // var s = haxe.Timer.stamp();
        // for(i  in 0...5){
        //     trace(r.key.get('test_$i'));
        // }
        // var e = haxe.Timer.stamp();
        // trace(e-s);
    }
}