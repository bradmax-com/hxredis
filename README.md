<center>
<img src="assets/logo.svg" width="300" height="300" />

Best haxe redis client ;)
</center>

INSTALLATION
============
```
haxelib install hxredis
```

HOW TO USE
==========
```
class Main
{
    public static function main()
    {
        var r = new redis.Redis(false); // true if you want to use clusters
        r.connect("127.0.0.1", 6379);
        r.key.set("dupa", "dupa"));
        trace(r.key.get("dupa")); // prints dupa
        r.close();
    }
}
```

COMMANDS
========
        r.key.set()

        bit
        cluster
        connection
        hash
        list
        pubSub
        script
        server
        set
        sort
        transaction

TODO
====
- tests
- lua cluster support