@lazyglobal off.
clearScreen.
clearVecDraws().

runOncePath("lib_dd_gooding").
runOncePath("lib_dd_orbit").

local minToSec is 60.
local hourToSec is 60 * minToSec.
local dayToSec is 6 * hourToSec.

local secToMin is 1 / minToSec.
local secToHour is 1 / hourToSec.
local secToDay is 1 / dayToSec.

function toTimestamp {
    parameter years, days, hours, minutes, seconds.
    return (years * 426 + days) * dayToSec + hours * hourToSec + minutes * minToSec + seconds.
}

local departureTime is toTimestamp(0, 269, 0, 37, 12).
local interceptTime is toTimestamp(0, 405, 1, 52, 48).
local timeOfFlight is interceptTime - departureTime.

local kObt is DDOrbit["withOrbit"](kerbin:obt).
local mObt is DDOrbit["withOrbit"](moho:obt).

local depOrbit is kObt["after"](kObt, departureTime - time:seconds).
local r1 is depOrbit["position"](depOrbit).
local v0 is depOrbit["velocity"](depOrbit).

local arrOrbit is mObt["after"](mObt, interceptTime - time:seconds).
local r2 is arrOrbit["position"](arrOrbit).

local v1 is Gooding["vLamb"](sun:mu, r1, r2, timeOfFlight)[0].

print "    " + r1.
print "    " + r2.
print "    " + sun:mu.
print "    " + timeOfFlight.

print "    " + (360 - vang(r1, r2)).

print "    " + v0.
print "    " + v1.
print "    " + (v1 - v0).
print "    " + (v1 - v0):mag.

local origin is V(0, 0, 0).
local proVec is vecDraw(origin, v0:normalized * 10, green, "v0", 1, true, 0.2).
local radVec is vecDraw(origin, v1:normalized * 10, cyan, "v1", 1, true, 0.2).
