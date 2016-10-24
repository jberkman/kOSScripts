@lazyglobal off.
clearScreen.
runOncePath("lib_dd_gauss").

local src is kerbin.
local dst is moho.

local srcObt is DDOrbit["withOrbit"](src:obt).
local dstObt is DDOrbit["withOrbit"](dst:obt).

local interceptLongitude is DDOrbit["interceptLongitude"](src, dst) + 180.
print "intercept longitude: " + interceptLongitude.

local interceptTrueAnomaly is dstObt["trueAnomalyAtLongitude"](dstObt, interceptLongitude).
local interceptTime is dstObt["secondsToTrueAnomaly"](dstObt, interceptTrueAnomaly) + dst:obt:period.
print "intercept: " + (time:seconds + interceptTime) / 6 / 60 / 60.

local longTrueAnomaly is srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude - 240).
print "long true anomaly: " + longTrueAnomaly.
print "current true anomaly: " + src:obt:trueAnomaly.

local srcInterceptTrueAnomaly is srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude).
local trueAnomaly is max(longTrueAnomaly, src:obt:trueAnomaly).
local tgtObt is dstObt["at"](dstObt, trueAnomaly).
local r2 is tgtObt["position"](tgtObt).

local injObt is srcObt["at"](srcObt, trueAnomaly).
local r1 is injObt["position"](injObt).
local tTX is interceptTime - srcObt["secondsToTrueAnomaly"](srcObt, trueAnomaly).

function findxy {
    parameter lambda, T.
    if abs(lambda) >= 1 { print 1/0. }
    if T >= 0 { print 1/0. }

    local T0 is arccos(lambda) + lambda * sqrt(1 - lambda ^ 2).
    local T1 is 2 / 3 * (1 - lambda ^ 3).
    local x0 is false.
    if T >= T0 {
        print "T >= T0".
        set x0 to (T0 / T) ^ (2/3) - 1.
    } else if T < T1 {
        print "T < T1".
        set x0 to 5 / 2 * T1 / T * (T1 - T) / (1 - lambda ^ 5) + 1.
    } else {
        print "T1 < T < T0".
        set x0 to (T0 / T) ^ (ln(T1 / T0) / ln(2)) - 1.
    }
}

local c is r2 - r1.
local c_ is c:mag.
local r1_ is r1:mag.
local r2_ is r2:mag.

local s is (r1 + r2 + c) / 2.

local ir1 is r1:normalized.
local ir2 is r2:normalized.
local ih is vcrs(ir1, ir2).

local lamba is sqrt(1 - c / s).
local it1 is false.
local it2 is false.
if r1:x * r2:z - r1:z * r2:x < 0 {
    set lamba to -lambda.
    set it1 to vcrs(ir1, ih).
    set it2 to vcrs(ir2, ir2).
} else {
    set it1 to vcrs(ih, ir1).
    set it2 to vcrs(ih, ih).
}
local tau is tTX * sqrt(2 * src:obt:body:mu / s ^ 3).

local xylist is findxy(lambda, tau).

local gamma is sqrt(src:obt:body:mu * s / 2).
local rho is (r1_ - r2_) / c.
local sigma is sqrt(1 - rho ^ 2).
for xy in xylist {
    local x is xy[0].
    local y is xy[1].

    local vr1 is gamma * ((lambda * y - x) - rho * (lambda * y + x)) / r1_.
    local vr2 is -gamma * ((lambda * y - x) + rho * (lambda * y + x)) / r2_.
    local vt1 is gamma * sigma * (y + lambda * x) / r1_.
    local vt2 is gamma * sigma * (y + lambda * x) / r1_.
    local v1 is vr1 * ir1 + vt1 * it1.
    local v2 is vr2 * ir2 + vt2 * it2.
}
