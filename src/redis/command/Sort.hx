package redis.command;

class Sort extends RedisCommand
{
    public function sort(key:String, ?byPattern:String = "", ?start:Int = 0, ?end:Int = 0, ?getPattern:String = "", ?isAscending:Bool = true, ?isAlpha:Bool = false, ?distKey:String = ""):Array<Dynamic>
    {
        var arr:Array<String> = [key];
        
        if (byPattern != "")
            arr.concat(['BY', byPattern]);
        
        if (end > 0)
            arr.concat(['LIMIT', ""+start, ""+end]);
        
        if (getPattern != "")
            arr.concat(['GET', getPattern]);
        
        if (!isAscending)
            arr.push('DESC');
        
        if (isAlpha)
            arr.push('ALPHA');
        
        if (distKey != "")
            arr.concat(['STORE', distKey]);
        
        return writeData('SORT', arr, key);
    }
}