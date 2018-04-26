package ;

// import haxe.Timer;

class Test
{
    public static function main()
    {
        trace("start");


        var r = new redis.Redis();
        // r.connect("192.168.1.100", 6379);
        // r.connect("127.0.0.1", 6379);

        r.connect("bradmax-redis.kelmfo.clustercfg.euc1.cache.amazonaws.com", 6379);

        // trace(r.cluster.nodes());

        // var b = "0";
        // var kb = [for(i in 0...1024) b].join("");
        // var mb = [for(i in 0...1024) kb].join("");
        // var mb_10 = [for(i in 0...10) mb].join("");

        // tic("key_1kb");
        // r.redirect().key.set('key_1kb', kb);
        // toc("key_1kb");
        // r.redirect().key.get('key_1kb');
        // toc("key_1kb");

        // tic("key_1mb");
        // r.redirect().key.set('key_1mb', mb);
        // toc("key_1mb");
        // r.redirect().key.get('key_1mb');
        // toc("key_1mb");

        // tic("key_10mb");
        // r.redirect().key.set('key_10mb', mb_10);
        // toc("key_10mb");
        // r.redirect().key.get('key_10mb');
        // toc("key_10mb");

        // trace("end");

        // for(i in 0...100){
        //     r.list.leftPush("mylist", i);
        //     trace('leftPush $i');
        // }

        // for(i in 0...10)
        //     r.redirect().key.set('key_$i', i);


        // for(i in 0...10)
        //     trace(r.redirect().key.get('key_$i'));

        // trace(r.key.set('a', 100));
        // trace(r.key.set('b', 200));
        // trace(r.key.set('c', 300));
        // trace(r.key.get('a'));
        // trace(r.key.get('b'));
        // trace(r.key.get('c'));

        // var f = haxe.io.Bytes.ofString(sys.io.File.getContent("lua/Main_fix.lua"));
        // var sha = r.script.load(f);
        // trace(sha);
        // trace(r.script.evalsha(sha, [], []));


        for(i in 0...100){
            trace('------------------------------------------ $i');
             r.redirect().list.rightPush("my_list_hc", i);
            //  r.redirect().list.rightPush("my_list_hc", haxe.crypto.Md5.encode(i+""));
        }
    }




    // static private var tictoc = new Map<String, Float>();

    // public static function tic(?name:String = ""):Void {
    //     tictoc.set(name, Timer.stamp());
    // }

    // public static function toc(?name:String = ""):Void {
    //     if (!tictoc.exists(name))
    //         return;

    //     var val = tictoc.get(name);

    //     #if cpp
    //     trace("_______ TICTOC: " + name + " " + ((Timer.stamp() - val)));
    //     tictoc.set(name, Timer.stamp());
    //     #else
    //     Console.log(name + " " + ((Timer.stamp() - val)));
    //     tictoc.set(name, Date.now().getTime());
    //     #end
    // }



}

