local _ENV = require("castl.runtime");
(function (this)
local Std,Main,HxOverrides;
HxOverrides = (function (this)

end);
HxOverrides.cca = (function (this, s, index)
local x;
x = s:charCodeAt(index);
if (not _eq(x,x)) then
do return undefined; end
end

do return x; end
end);
Main = (function (this)

end);
Main.main = (function (this)
do return Main:calc(KEYS,ARGV); end
end);
Main.calc = (function (this, keys, args)
local i1,__g2,__g11,i,__g,__g1,k,a,numKeys;
numKeys = (_addNum2(Std:parseInt((_addStr2(____lua____(_ENV,"#keys"),""))),1));
a = _arr({},0);
k = _arr({},0);
__g1 = 1;
__g = numKeys;
while (_lt(__g1,__g)) do
i = (function () local _tmp = __g1; __g1 = _inc(_tmp); return _tmp; end)();
a:push(args[i]);
::_continue::
end

__g11 = 1;
__g2 = numKeys;
while (_lt(__g11,__g2)) do
i1 = (function () local _tmp = __g11; __g11 = _inc(_tmp); return _tmp; end)();
k:push(keys[i1]);
::_continue::
end

do return a:concat(k):join(","); end
end);
Std = (function (this)

end);
Std.parseInt = (function (this, x)
local v;
v = parseInt(_ENV,x,10);
if ((function() local _lev=(_eq(v,0)); if _bool(_lev) then return ((function() local _lev=(_eq(HxOverrides:cca(x,1),120)); return _bool(_lev) and _lev or (_eq(HxOverrides:cca(x,1),88)) end)()); else return _lev; end end)()) then
v = parseInt(_ENV,x);
end

if _bool(isNaN(_ENV,v)) then
do return null; end
end

do return v; end
end);
Main:main();
end)(_ENV);