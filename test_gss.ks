@lazyglobal off.

runOncePath("lib_dd_roots").

local epsilon is Roots["epsilon"].

local x is Roots["goldenSection"](1, 5, epsilon, {
    parameter x.
    return (x - 2) ^ 2.
}).

print "x: " + x.
if abs(x - 2) / 2 > epsilon { print 1/0. }

local x2 is Roots["goldenSection"](2, 5, epsilon, {
    parameter x.
    return (x - 2) ^ 2.
}).

print "x: " + x2.
if abs(x2 - 2) / 2 > epsilon { print 1/0. }
