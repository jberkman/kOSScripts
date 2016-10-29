@lazyglobal off.
//clearScreen.
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
} else if true {
    set r1 to shipRawToSOIUniversal(positionAt(kerbin, departureTime), sun).
    set v0 to rawToUniversal(velocityAt(kerbin, departureTime):orbit).
    set r2 to shipRawToSOIUniversal(positionAt(moho, interceptTime), sun).
} else {
    set r2 to V(4609596511.74102, -36848806.2899858, -4264926486.31324).
    set r1 to V(-5032504995.39272, 0, 12634458771.9485).
    set v2 to V(0, 0, 0).    
}

local v1 is Gooding["vLamb"](sun:mu, r1, r2, timeOfFlight)[0].

print "  R1  " + r1.
print "  **  " + shipRawToSOIUniversal(positionAt(kerbin, departureTime), sun).
print "  R2  " + r2.
print "  **  " + shipRawToSOIUniversal(positionAt(moho, interceptTime), sun).
print "  MU  " + sun:mu.
print "  TF  " + timeOfFlight.

print "  VA  " + (360 - vang(r1, r2)).

print "  V0  " + v0.
print "  V1  " + v1.
print "  dV  " + (v1 - v0).
print "  dV  " + (v1 - v0):mag.

local origin is V(0, 0, 0).
vecDraw(origin, v0:normalized * 10, green, "v0", 1, true, 0.2).
vecDraw(origin, v1:normalized * 10, cyan, "v1", 1, true, 0.2).
vecDraw(origin, r1:normalized * 10, magenta, "r1", 1, true, 0.2).
vecDraw(origin, r2:normalized * 10, yellow, "r2", 1, true, 0.2).
vecDraw(origin, vCrs(r1, r2):normalized * 10, red, "h", 1, true, 0.2).
