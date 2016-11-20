// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
clearVecDraws().

runOncePath("lib_dd_gooding").
runOncePath("lib_dd_orbit").

{
local src is kerbin.
//local src is minmus.
//local src is ship.

local dst is moho.
//local dst is minmus.
//local dst is mun.

local departureTime is time.
local duration is 134 * DDConstant["dayToSec"].
print "duration: " + duration.

local r1 is shipRawToSOIUniversal(positionAt(src, departureTime), src:body).
local r2 is shipRawToSOIUniversal(positionAt(dst, departureTIme + duration), src:body).
local v0 is rawToUniversal(velocityAt(src, departureTime):orbit).

local vLamb is Gooding["vLamb"](src:body:mu, r1, r2, duration).
local v1 is vLamb[0].
local v2 is vLamb[1].
local vInf is v1 - v0.

local escape is DDOrbit["escapeBurn"](obt, vInf).
local deltaV is escape[0].
local taInj is escape[1].

local xferObt is DDOrbit["withVectors"](src:body, r1, vInf).

local sObt is DDOrbit["withOrbit"](obt).
set sObt to sObt["at"](sObt, taInj).
local rInj is sObt["position"](sObt).

//print "    dV    " + deltaV.
//print "    dV    " + round(deltaV:mag, 1).

local origin is V(0, 0, 0).

//print "    t: " + sObt["secondsToTrueAnomaly"](sObt, taInj) * secToMin.
set departureTime to departureTime + sObt["secondsToTrueAnomaly"](sObt, taInj).

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

    //print "radial: " + round(radial) + " normal: " + round(normal) + " prograde: " + round(prograde).

    add Node(t, radial, normal, prograde).
}

addNode(departureTime:seconds, deltaV).

local secToDay is DDConstant["secToDay"].
print "v0: " + round(v0:mag, 1) + "    " + v0.
print "v1: " + round(v1:mag, 1) + "    " + v1.
print "vInf: " + round(vInf:mag, 1) + "    " + vInf.
print "xfer inc: " + DDOrbit["withVectors"](src:body, r1, vInf)["inclination"].
//print "  lInf  " + round(longInf, 1).
print "  taInj " + round(taInj, 1).
print "               Departure: " + round(departureTime:seconds * secToDay, 2).
print "                 Arrival: " + round((departureTime + duration):seconds * secToDay, 2).
print "          Time of flight: " + round(duration * secToDay, 2).
//print "             Phase angle: " + round(vAng(srcObt["position"](srcObt), dstObt["position"](dstObt)) - 360, 2).
print "          Ejection angle: " + round(norDeg(180 - vAng(rInj, src:obt:velocity:orbit)), 1).
print "             Ejection dV: " + round(nextNode:deltaV:mag, 1).
print "             Prograde dV: " + round(nextNode:prograde, 1).
print "               Normal dV: " + round(nextNode:normal, 2).
print "      Transfer periapsis: " + round(xferObt["periapsis"](xferObt) / 1000000).
print "       Transfer apoapsis: " + round(xferObt["apoapsis"](xferObt) / 1000000).
print "    Transfer Inclination: " + round(xferObt["inclination"], 2).
print "          Transfer angle: " + round(vAng(r1, r2), 2).

if false {
set r1 to universalToRaw(r1).
set r2 to universalToRaw(r2).
set v0 to universalToRaw(v0).
set v1 to universalToRaw(v1).
set vInf to universalToRaw(vInf).
set rInj to universalToRaw(rInj).
//set h to universalToRaw(h).
//set vInj to universalToRaw(vInj).
set deltaV to universalToRaw(deltaV).
}

vecDraw(V(0, 0, 0), r1:normalized * 10, blue, "r1", 1, true, 0.2).
vecDraw(V(0, 0, 0), r2:normalized * 10, green, "r2", 1, true, 0.2).

vecDraw(r1:normalized * 10, v0:normalized * 10, green, "v0", 1, true, 0.2).
vecDraw(r1:normalized * 10, v1:normalized * 10, cyan, "v1", 1, true, 0.2).
vecDraw(r1:normalized * 10, vCrs(r1, r2):normalized * 10, magenta, "h", 1, true, 0.2).
vecDraw(r1:normalized * 10, vInf:normalized * 10, yellow, "vInf", 1, true, 0.2).
//vecDraw(r1:normalized * 10 + rInj:normalized * 10, h * 10, magenta, "h", 1, true, 0.2).
//vecDraw(r1:normalized * 10 + rInj:normalized * 10, vInj:normalized * 10, cyan, "vInj", 1, true, 0.2).
vecDraw(r1:normalized * 10 + rInj:normalized * 10, deltaV:normalized * 10, yellow, "deltaV", 1, true, 0.2).
vecDraw(r1:normalized * 10, rInj:normalized * 10, red, "rInj", 1, true, 0.2).
}
