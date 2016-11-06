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
local vInf is v1 - v0.

print "  R1    " + r1.
//print "  **    " + shipRawToSOIUniversal(positionAt(kerbin, departureTime), sun).
print "  R2    " + r2.
//print "  **    " + shipRawToSOIUniversal(positionAt(moho, interceptTime), sun).
print "  MU    " + sun:mu.
print "  TF    " + timeOfFlight.

print "  VA    " + (360 - vang(r1, r2)).
print " ".
print "  V0    " + v0.
print "  V1    " + v1.
print "  vInf  " + vInf.
print "  vInf  " + vInf:mag.

vecDraw(origin, r1:normalized * 10, blue, "r1", 1, true, 0.2).
vecDraw(origin, r2:normalized * 10, green, "r2", 1, true, 0.2).

vecDraw(r1:normalized * 10, v0:normalized * 10, green, "v0", 1, true, 0.2).
vecDraw(r1:normalized * 10, v1:normalized * 10, cyan, "v1", 1, true, 0.2).
vecDraw(r1:normalized * 10, vCrs(r1, r2):normalized * 10, magenta, "h", 1, true, 0.2).
vecDraw(r1:normalized * 10, vInf:normalized * 10, yellow, "vInf", 1, true, 0.2).

local longInf is vecLong(vInf).
local sObt is DDOrbit["withOrbit"](obt).
local taInj is sObt["trueAnomalyAtLongitude"](sObt, norDeg(longInf + 180)).
set sObt to sObt["at"](sObt, taInj).

print "  lInf  " + round(longInf, 1).
print "  taInj " + round(taInj, 1).

local prevDiff is 180.
local delta is 5.

local injObt is false.
local rInj is false.
local vInj is false.

until false {
    set injObt to sObt["at"](sObt, taInj).
    set rInj to injObt["position"](injObt).
    local rInj_ is rInj:mag.

    set vInj to sqrt(vInf:mag^2 + 2 * kerbin:mu / rInj_).
    local EE is vInj^2 / 2 - kerbin:mu / rInj_.
    local h is rInj_ * vInj.
    local e is sqrt(1 + 2 * EE * h^2 / kerbin:mu^2).
    local etaCalc is arccos(-1 / e).
    local etaAng is vAng(vInf, rInj).
    local diff is abs(etaCalc - etaAng).

    print "    " + round(eta, 1) + "    " + round(etaCalc, 1) + "    " + round(etaAng, 1) + "    " + round(diff, 4) + "    " + injObt["longitude"](injObt).

    if diff < 0.01 { break. }
    else if diff > prevDiff { set delta to -delta / 10. }
    set prevDiff to diff.
    set taInj to norDeg(taInj + delta).
}

local h is vCrs(vInf, rInj):normalized.
set vInj to vInj * (vCrs(rInj, h):normalized).

local vInj0 is injObt["velocity"](injObt).
local deltaV is vInj - vInj0.

print "    dV    " + deltaV.
print "    dV    " + round(deltaV:mag, 1).

local origin is V(0, 0, 0).

vecDraw(r1:normalized * 10, rInj:normalized * 10, red, "rInj", 1, true, 0.2).

vecDraw(r1:normalized * 10 + rInj:normalized * 10, h * 10, magenta, "h", 1, true, 0.2).
vecDraw(r1:normalized * 10 + rInj:normalized * 10, vInj:normalized * 10, cyan, "vInj", 1, true, 0.2).
vecDraw(r1:normalized * 10 + rInj:normalized * 10, deltaV:normalized * 10, yellow, "deltaV", 1, true, 0.2).
