// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
clearVecDraws().

runOncePath("lib_dd").
runOncePath("lib_dd_gooding").
runOncePath("lib_dd_orbit").
runOncePath("lib_dd_roots").
//runOncePath("lib_dd_lambert").

    function days {
        parameter seconds.
        return round(seconds * DDConstant["secToDay"], 1).
    }

    function getWindow {
        parameter src, dst.

        local body is src:body.
        local srcObt is DDOrbit["withOrbit"](src:obt).
        local dstObt is DDOrbit["withOrbit"](dst:obt).

        //local synodicPeriod is DDOrbit["synodicPeriod"](srcObt, dstObt).
        //local hohmannPeriod is false.
        //{
        local a is (src:obt:semiMajorAxis + dst:obt:semiMajorAxis) / 2.
        local hohmannPeriod is 2 * constant:pi * sqrt(a ^ 3 / body:mu).
        //}

        clearScreen.
        //     012345678901234567890123456
        print "DunaDirect Lambert! v0.1".
        print "(solution may take a few minutes)".
        print "Evaluating duration:". // 2
        print "Solution:".  // 1
        print "Departure:". // 2
        print "   deltaV:". // 1
        print " Duration:". // 2
        print "   deltaV:". // 3
        print "    total:". // 4

        local depRow is 2.
        local depCol is 22.
        local solRow is depRow + 2.
        local solCol is 11.

        local departure is time:seconds.

        local minDuration is hohmannPeriod / 4.
        local maxDuration is minDuration * 3.

        local tStep is false.
        if min(src:obt:period, dst:obt:period) < 60 * DDConstant["dayToSec"] {
            set tStep to DDConstant["hourToSec"].
        } else {
            set tStep to DDConstant["dayToSec"].
        }
        local minDV is 99999.

        local iterations is 0.
        local ret is false.
        local r1 is shipRawToSOIUniversal(positionAt(src, departure), body).
        local v0 is rawToUniversal(velocityAt(src, departure):orbit).

        local duration is minDuration.
        until duration > maxDuration {
            print days(duration) + " " + round(200 * (duration - minDuration) / hohmannPeriod) + "%     " at (depCol, depRow).
            local r2 is shipRawToSOIUniversal(positionAt(dst, departure + duration), body).
            if vAng(r1, r2) > 120 {
                set iterations to iterations + 1.
                local v1 is false.
                local v2 is false.
                //if false and vAng(r1, r2) > 177 {
                //    local a is (r1:mag + r2:mag) / 2.
                //    set v1 to v0:normalized * sqrt(body:mu * (2 / r1:mag - 1 / a)).
                //    set v2 to v1:normalized * sqrt(body:mu * (2 / r2:mag - 1 / a)).
                //} else {
                    local vLamb is Gooding["vLamb"](body:mu, r1, r2, duration).
                    set v1 to vLamb[0].
                    set v2 to vLamb[1].
                //}
                local dV is (v1 - v0):mag.
                if dV < minDV {
                    set minDV to dV.
                    local v3 to rawToUniversal(velocityAt(dst, departure + duration):orbit).
                    set ret to lex(
                        "departure", departure,
                        "duration", duration,
                        "r1", r1,
                        "r2", r2,
                        "v0", v0,
                        "v1", v1,
                        "v2", v2,
                        "v3", v3
                    ).

                    local dV2 is (v3 - v2):mag.
                    print days(departure)    + "      " at (solCol, solRow + 0).
                    print round(dV, 1)       + "      " at (solCol, solRow + 1).
                    print days(duration)     + "      " at (solCol, solRow + 2).
                    print round(dV2, 1)      + "      " at (solCol, solRow + 3).
                    print round(dV + dV2, 1) + "      " at (solCol, solRow + 4).
                }
            }
            set duration to duration + tStep.
        }
        print "iterations: " + iterations.
        return ret.
    }

local src is body.
//local src is minmus.
//local src is ship.

//local dst is moho.
//local dst is minmus.
//local dst is mun.
local dst is target.

local window is getWindow(src, dst).
local departure is window["departure"].
local duration is window["duration"].

print "departure: " + round((departure  - time:seconds) * DDConstant["secToDay"], 1).
print "duration: " + round(duration * DDConstant["secToDay"], 1).

local r1 is window["r1"].
local r2 is window["r2"].
local v0 is window["v0"].
local v1 is window["v1"].
local vInf is v1 - v0.

local escape is DDOrbit["escapeBurn"](obt, vInf).
local deltaV is escape[0].
local taInj is escape[1].

local xferObt is DDOrbit["withVectors"](src:body, r1, vInf).
//print xferObt.

local sObt is DDOrbit["withOrbit"](obt).

//print "    dV    " + deltaV.
//print "    dV    " + round(deltaV:mag, 1).

local origin is V(0, 0, 0).

print "   ta: " + obt:trueAnomaly.
local secToMin is DDConstant["secToMin"].
print "    t: " + sObt["secondsToTrueAnomaly"](sObt, taInj) * secToMin.
print "   dV: " + deltaV.

set departure to time:seconds + sObt["secondsToTrueAnomaly"](sObt, taInj).
set sObt to sObt["at"](sObt, taInj).
local rInj is sObt["position"](sObt).

function addNode {
    parameter t, dV.

    local o is DDOrbit["withOrbit"](obt).
    set o to o["after"](o, t - time:seconds).
    local v is o["velocity"](o):normalized.
    local r is o["position"](o):normalized.
    local cx is vCrs(v, r):normalized.

    //set dV to universalToRaw(dV).
    //local r is (positionAt(ship, t) - body:position):normalized.
    //local v is (velocityAt(ship, t):orbit - body:obt:velocity:orbit):normalized.
    //local cx is vCrs(v, r):normalized.

    vecDraw(V(0, 0, 0), v * 10, yellow, "v", 1, true, 0.2).
    vecDraw(V(0, 0, 0), r * 10, green, "r", 1, true, 0.2).
    vecDraw(V(0, 0, 0), cx * 10, magenta, "cx", 1, true, 0.2).

    local prograde is v * dV.
    local radial is r * dV.
    local normal is cx * dV.

    print "radial: " + round(radial) + " normal: " + round(normal) + " prograde: " + round(prograde).
    print vang(r, rInj).
    print t - time:seconds.

    add Node(t, radial, normal, prograde).
}

addNode(departure, deltaV).

local secToDay is DDConstant["secToDay"].
print "v0: " + round(v0:mag, 1) + "    " + v0.
print "v1: " + round(v1:mag, 1) + "    " + v1.
print "vInf: " + round(vInf:mag, 1) + "    " + vInf.
print "xfer inc: " + DDOrbit["withVectors"](src:body, r1, vInf)["inclination"].
//print "  lInf  " + round(longInf, 1).
print "  taInj " + round(taInj, 1).
print "               Departure: " + round(departure * secToDay, 2).
print "                 Arrival: " + round((departure + duration) * secToDay, 2).
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

if true {
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
