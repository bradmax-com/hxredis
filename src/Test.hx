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
        var r = new redis.Redis(false);
        var i = 0;

        while(true){
            r.connect("127.0.0.1", 6379);
            trace(r.key.set("a", i++));
            trace(r.key.get("a"));
            r.close();
        }

        // r.accumulate();
        // r.key.set("a", 1);
        // r.key.set("b", 1);
        // r.key.set("c", 1);
        // r.key.set("d", 1);
        // r.key.set("e", 1);
        // r.key.set("f", 1);
        // r.key.set("g", 1);
        // r.flush();
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