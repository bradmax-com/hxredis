package ;

// import haxe.Timer;






typedef Range = {
    var from:Null<Int>;
    @:optional var to:Null<Int>;
}

typedef Node = {
    var hash:String;
    var host:String;
    var port:Int;
    var slots:Array<Range>;
}


class Test
{
    public static function main()
    {
        trace("RUN");
        var r = new redis.Redis(false);
        trace("RUN1");
        var i = 0;
        trace("RUN2");
        r.connect("127.0.0.1", 6379);
        trace("RUN3");
        
        var key = 'rt_client_material_cookie:a:b';
        var count = r.set.count(key);
        trace("c", count);
        r.accumulate();    
        r.set.count(key);
        var all:Dynamic = r.flush();
        trace("flush", all);

        // while(true){
        //     r.connect("127.0.0.1", 6379);
        //     trace(r.key.set("a", i++));
        //     trace(r.key.get("a"));
        //     r.close();
        // }

        // r.set.add("sss", "aaa");
        // r.set.add("sss", "bbb");
        // r.set.add("sss", "ccc");
        var i = 10;
        // while(i-- > 0){
            r.accumulate();
            trace("RUN4");
            r.set.count("sss");
            r.set.count("sss");
            r.set.count("sss");
            r.set.count("sss");
            r.set.count("sss");
            trace("RUN5");
            var resp = r.flush();
            trace("RUN6");
            trace(resp);
        // }hc_dev


        // r.key.set("aaa", 1);
        // r.key.set("bbb", 2);
        // r.key.set("ccc", 3);
        // r.key.set("d", 4);
        // r.key.set("e", 5);
        // r.key.set("f", 6);
        // r.key.set("g", 7);
        // r.key.get("a");
        // r.key.get("b");
        // r.key.get("c");
        // r.key.get("d");
        // r.key.get("e");
        // r.key.get("f");
        // r.key.get("g");
        // trace("-------");
        // trace(r.key.get("a"));
        // trace("-------");




        // var kb = [for(i in 0...1024)"x"].join("");
        // var mb = [for(i in 0...1024)kb].join("");
        // var mb_10 = [for(i in 0...10)mb].join("");

        // // Profiler.tic("random keys - 10000 x kb");
        // // for(i in 0...10000){
        // //      r.redirect().key.set(i+"kb", kb);
        // // }
        // // Profiler.toc("random keys - 10000 x kb");

        // // Profiler.tic("random keys - 100 x mb");
        // // for(i in 0...100){
        // //      r.redirect().key.set(i+"mb", mb);
        // // }
        // // Profiler.toc("random keys - 100 x mb");

        // Profiler.tic("random keys - 20 x 10mb");
        // for(i in 0...20){
        //      r.key.set(i+"10mb", mb_10);
        // }
        // Profiler.toc("random keys - 20 x 10mb");
    }

}