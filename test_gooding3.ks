@lazyglobal off.
clearScreen.
clearVecDraws().

runOncePath("lib_dd_gooding").
runOncePath("lib_dd_orbit").

local departureTime is toTimestamp(0, 268, 0, 37, 12).
local interceptTime is toTimestamp(0, 404, 1, 52, 48).
local timeOfFlight is interceptTime - departureTime.

local v0 is false.
local r1 is false.
local v2 is false.
local r2 is false.

print "depart: " + ((departureTime - time:seconds) + time):calendar.
print "arrive: " + ((interceptTime - time:seconds) + time):calendar.

if true {
    local kObt is DDOrbit["withOrbit"](kerbin:obt).
    local mObt is DDOrbit["withOrbit"](moho:obt).
    print "current: " + mObt["latitude"](mObt).
    print "true anom: " + mObt["trueAnomaly"].

    local depOrbit is kObt["after"](kObt, departureTime - time:seconds).
    set r1 to depOrbit["position"](depOrbit).
    set v0 to depOrbit["velocity"](depOrbit).

    local arrOrbit is mObt["after"](mObt, interceptTime - time:seconds).
    set r2 to arrOrbit["position"](arrOrbit).
    print "lat: " + arrOrbit["latitude"](arrOrbit).
} else if false {
    set r1 to positionAt(kerbin, departureTime) - sun:position.
    set v0 to velocityAt(kerbin, departureTime):orbit.
    set r2 to positionAt(moho, interceptTime) - sun:position.
} else {
    set r2 to V(4609596511.74102, -36848806.2899858, -4264926486.31324).
    set r1 to V(-5032504995.39272, 0, 12634458771.9485).
    set v2 to V(0, 0, 0).    
}

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
