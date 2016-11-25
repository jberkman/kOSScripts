@lazyglobal off.

runOncePath("lib_dd_roots").

local x is Roots["brents"](-4, 4/3, 0.00001, {
    parameter x.
    return (x + 3) * (x - 1) ^ 2.    
}).
print "x: " + x.
if x <> -3 { print 1/0. }
