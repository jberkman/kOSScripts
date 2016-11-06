// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
clearVecDraws().
runOncePath("lib_dd_orbit").
runOncePath("lib_dd_gooding").

local src is kerbin.
local dst is moho.
//local src is ship.
//local dst is minmus.

local minToSec is 60.
local hourToSec is 60 * minToSec.
local dayToSec is 6 * hourToSec.

local secToMin is 1 / minToSec.
local secToHour is 1 / hourToSec.
local secToDay is 1 / dayToSec.

local srcObt is DDOrbit["withOrbit"](src:obt).
local dstObt is DDOrbit["withOrbit"](dst:obt).

local interceptLongitude is DDOrbit["interceptLongitude"](src, dst).
local interceptTrueAnomaly is srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude).
if abs(interceptTrueAnomaly - srcObt["trueAnomaly"]) < 90 {
    set interceptLongitude to norDeg(interceptLongitude + 180).
    set interceptTrueAnomaly to srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude).
}
local r1 is srcObt["position"](srcObt).
local v0 is srcObt["velocity"](srcObt).

local dstInterceptTrueAnomaly is dstObt["trueAnomalyAtLongitude"](dstObt, interceptLongitude).
local tgtObt is dstObt["at"](dstObt, dstInterceptTrueAnomaly).
local tDelta is dstObt["secondsToTrueAnomaly"](dstObt, dstInterceptTrueAnomaly) + dstObt["period"](dstObt).
local r2 is tgtObt["position"](tgtObt).

print "intercept longitude: " + round(interceptLongitude, 1).
print "interceptTrueAnomaly: " + round(interceptTrueAnomaly, 1).
print "dstInterceptTrueAnomaly: " + round(dstInterceptTrueAnomaly, 1).

print " ".
print "intercept ETA: " + round(tDelta * secToDay, 2).
local vLamb is Gooding["vLamb"](src:obt:body:mu, r1, r2, tDelta).
local v1 is vLamb[0].
local v2 is vLamb[1].
local vInf is v1 - v0.

local longInf is vecLong(vInf).
local sObt is DDOrbit["withOrbit"](obt).
local taInj is sObt["trueAnomalyAtLongitude"](sObt, norDeg(longInf)).

print "v0: " + round(v0:mag, 1) + "    " + v0.
print "v1: " + round(v1:mag, 1) + "    " + v1.
print "vInf: " + round(vInf:mag, 1) + "    " + vInf.
print "xfer inc: " + DDOrbit["withVectors"](src:obt:body, r1, vInf)["inclination"].
print "  lInf  " + round(longInf, 1).
print "  taInj " + round(taInj, 1).

vecDraw(V(0, 0, 0), r1:normalized * 10, blue, "r1", 1, true, 0.2).
vecDraw(V(0, 0, 0), r2:normalized * 10, green, "r2", 1, true, 0.2).

vecDraw(r1:normalized * 10, v0:normalized * 10, green, "v0", 1, true, 0.2).
vecDraw(r1:normalized * 10, v1:normalized * 10, cyan, "v1", 1, true, 0.2).
vecDraw(r1:normalized * 10, vCrs(r1, r2):normalized * 10, magenta, "h", 1, true, 0.2).
vecDraw(r1:normalized * 10, vInf:normalized * 10, yellow, "vInf", 1, true, 0.2).
local rInjVec is vecDraw(r1:normalized * 10, V(0, 0, 0), red, "rInj", 1, true, 0.2).

local prevDiff is 180.
local delta is 5.

local injObt is false.
local rInj is false.
local vInj is false.

until false {
    set injObt to sObt["at"](sObt, taInj).
    set rInj to injObt["position"](injObt).
    set rInjVec:vec to rInj:normalized * 10.
    local rInj_ is rInj:mag.

    set vInj to sqrt(vInf:mag^2 + 2 * kerbin:mu / rInj_).
    local EE is vInj^2 / 2 - kerbin:mu / rInj_.
    local h is rInj_ * vInj.
    local e is sqrt(1 + 2 * EE * h^2 / kerbin:mu^2).
    local etaCalc is arccos(-1 / e).
    local etaAng is vAng(vInf, rInj).
    local diff is abs(etaCalc - etaAng).

    print "    " + round(taInj, 1) + "    " + round(etaCalc, 1) + "    " + round(etaAng, 1) + "    " + round(diff, 4) + "    " + injObt["longitude"](injObt).

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

vecDraw(r1:normalized * 10 + rInj:normalized * 10, h * 10, magenta, "h", 1, true, 0.2).
vecDraw(r1:normalized * 10 + rInj:normalized * 10, vInj:normalized * 10, cyan, "vInj", 1, true, 0.2).
vecDraw(r1:normalized * 10 + rInj:normalized * 10, deltaV:normalized * 10, yellow, "deltaV", 1, true, 0.2).

print "    t: " + sObt["secondsToTrueAnomaly"](sObt, taInj) * secToMin.
local departureTime is time:seconds + sObt["secondsToTrueAnomaly"](sObt, taInj).

function addNode {
    parameter t, dV.

    local orbit to DDOrbit["withOrbit"](obt).
    set orbit to orbit["after"](orbit, t - time:seconds).

    local v is orbit["velocity"](orbit):normalized.
    local position is orbit["position"](orbit):normalized.
    local cx is vCrs(v:normalized, position).

    local prograde is v:normalized * dV.
    local radial is position * dV.
    local normal is cx * dV.

    print "radial: " + round(radial) + " normal: " + round(normal) + " prograde: " + round(prograde).

    add Node(t, radial, normal, prograde).
}

addNode(departureTime, deltaV).
