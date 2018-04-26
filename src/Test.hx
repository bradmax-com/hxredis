package ;

// import haxe.Timer;

class Test
{
    public static function main()
    {
        var r = new redis.Redis();

        r.connect("bradmax-redis.kelmfo.clustercfg.euc1.cache.amazonaws.com", 6379);

        var kb = [for(i in 0...1024)"x"].join("");
        var mb = [for(i in 0...1024)kb].join("");
        var mb_10 = [for(i in 0...10)mb].join("");

        Profiler.tic("random keys - 10000 x kb");
        for(i in 0...10000){
             r.redirect().key.set(i+"kb", kb);
        }
        Profiler.toc("random keys - 10000 x kb");

        Profiler.tic("random keys - 100 x mb");
        for(i in 0...100){
            // trace(i);
             r.redirect().key.set(i+"mb", mb);
        }
        Profiler.toc("random keys - 100 x mb");

        Profiler.tic("random keys - 20 x 10mb");
        for(i in 0...20){
             r.redirect().key.set(i+"10mb", mb_10);
        }
        Profiler.toc("random keys - 20 x 10mb");
    }

}

