package;

import haxe.Timer;

class Profiler
{
    static private var tictoc = new Map<String, Float>();

    public static function tic(?name:String = ""):Void {
        tictoc.set(name, Timer.stamp());
    }

    public static function toc(?name:String = ""):Void {
        if (!tictoc.exists(name))
            return;

        var val = tictoc.get(name);

        #if cpp
        trace("_______ TICTOC: " + name + " " + ((Timer.stamp() - val)));
        tictoc.set(name, Timer.stamp());
        #else
        Console.log(name + " " + ((Timer.stamp() - val)));
        tictoc.set(name, Date.now().getTime());
        #end
    }
}