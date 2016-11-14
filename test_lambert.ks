// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
clearVecDraws().
runOncePath("lib_dd_lambert").

//local src is kerbin.
//local dst is moho.
//local src is ship.
//local dst is minmus.

local window is Lambert["window"](kerbin, moho).
print 1/0.
//local window is getWindow(mun, minmus).
//local window is getWindow(ship, mun).

function days {
    parameter seconds.
    return round(seconds * DDConstant["secToDay"], 1).
}

function getWindow {
    parameter src, dst.

    local body is src:obt:body.
    local srcObt is DDOrbit["withOrbit"](src:obt).
    local dstObt is DDOrbit["withOrbit"](dst:obt).

    local synodicPeriod is DDOrbit["synodicPeriod"](srcObt, dstObt).
    local hohmannPeriod is false.
    {
        local a is body:radius + (src:obt:apoapsis + dst:obt:apoapsis) / 2.
        set hohmannPeriod to 2 * constant:pi * sqrt(a ^ 3 / body:mu).
    }

    print "    syn: " + days(synodicPeriod) + "    hmn: " + days(hohmannPeriod).

    local t0 is time.

    local v0 is false.
    local v1 is false.
    local v2 is false.
    local v3 is false.

    local r1 is false.
    local r2 is false.

    local depMin is -1.
    local depMax is synodicPeriod.
    local depStep is src:obt:period / 72.

    local durMin is hohmannPeriod / 3.
    local durMax is durMin * 2.
    local durStep is dst:obt:period / 72.

    local dvInf is false.
    local dvInfDep is -1.
    local dvInfDur is false.

    until depStep <= 5 {
        local departure is depMin.
        until departure > depMax {
            print "    " + round(100 * (departure - depMin) / (depMax - depMin)) + "%".
            local departureTime is t0 + departure.
            local r1 is shipRawToSOIUniversal(positionAt(src, departureTime), body).
            local v0 is rawToUniversal(velocityAt(src, departureTime):orbit).
            local duration is durMin.
            until duration > durMax {
                if dvInfDep < 0 or departure <> depMin or duration <> durMin {
                    local r2 is shipRawToSOIUniversal(positionAt(dst, departureTime + duration), body).
                    if vAng(r1, r2) > 120 {
                        local vLamb is Gooding["vLamb"](body:mu, r1, r2, duration).
                        local dV is vLamb[0] - v0.
                        if dvInfDep < 0 or dV:mag < dvInf:mag {
                            set dvInf to dV.
                            set dvInfDep to departure.
                            set dvInfDur to duration.
                            set v1 to vLamb[0].
                            set v2 to vLamb[1].
                            set v3 to rawToUniversal(velocityAt(dst, departureTime + duration):orbit).
                            local dV2 is v3 - v2.
                            print "    dep: " + days(departure) + "    dur: " + days(duration) + "    dV: " + round(dV:mag, 1) + "    dV2: " + round(dV2:mag, 1) + "    dV3: " + round(dV:mag + dV2:mag, 1).
                        }
                    }
                }
                set duration to duration + durStep.
            }
            set departure to departure + depStep.
        }
        set depStep to depStep / 10.
        set depMin to max(0, dvInfDep - 9 * depStep).
        set depMax to dvInfDep + 9 * depStep.

        set durStep to durStep / 10.
        set durMin to max(0, dvInfDur - 9 * durStep).
        set durMax to dvInfDur + 9 * durStep.
    }
    return lex(
        "departure", t0 + depMin,
        "duration", durMin,
        "r1", r1,
        "r2", r2,
        "v0", v0,
        "v1", v1,
        "v2", v2,
        "v3", v3
    ).
}


local vInf is window["v1"] - window["v0"].
local longInf is vecLong(vInf).
local sObt is DDOrbit["withOrbit"](obt).
local taInj is sObt["trueAnomalyAtLongitude"](sObt, norDeg(longInf)).
local xferObt is DDOrbit["withVectors"](src:obt:body, r1, vInf).

//print "v0: " + round(v0:mag, 1) + "    " + v0.
//print "v1: " + round(v1:mag, 1) + "    " + v1.
//print "vInf: " + round(vInf:mag, 1) + "    " + vInf.
//print "xfer inc: " + DDOrbit["withVectors"](src:obt:body, r1, vInf)["inclination"].
//print "  lInf  " + round(longInf, 1).
//print "  taInj " + round(taInj, 1).

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

    //print "    " + round(taInj, 1) + "    " + round(etaCalc, 1) + "    " + round(etaAng, 1) + "    " + round(diff, 4) + "    " + injObt["longitude"](injObt).

    if diff < 0.01 { break. }
    else if diff > prevDiff { set delta to -delta / 10. }
    set prevDiff to diff.
    set taInj to norDeg(taInj + delta).
}

local h is vCrs(vInf, rInj):normalized.
set vInj to vInj * (vCrs(rInj, h):normalized).

local vInj0 is injObt["velocity"](injObt).
local deltaV is vInj - vInj0.

//print "    dV    " + deltaV.
//print "    dV    " + round(deltaV:mag, 1).

local origin is V(0, 0, 0).

vecDraw(r1:normalized * 10 + rInj:normalized * 10, h * 10, magenta, "h", 1, true, 0.2).
vecDraw(r1:normalized * 10 + rInj:normalized * 10, vInj:normalized * 10, cyan, "vInj", 1, true, 0.2).
vecDraw(r1:normalized * 10 + rInj:normalized * 10, deltaV:normalized * 10, yellow, "deltaV", 1, true, 0.2).

//print "    t: " + sObt["secondsToTrueAnomaly"](sObt, taInj) * secToMin.
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

    //print "radial: " + round(radial) + " normal: " + round(normal) + " prograde: " + round(prograde).

    add Node(t, radial, normal, prograde).
}

addNode(departureTime, deltaV).

print "               Departure: " + round(departureTime * secToDay, 2).
print "                 Arrival: " + round((time:seconds + tDelta) * secToDay, 2).
print "          Time of flight: " + round(tDelta * secToDay, 2).
print "             Phase angle: " + round(vAng(srcObt["position"](srcObt), dstObt["position"](dstObt)) - 360, 2).
print "          Ejection angle: " + round(norDeg(180 - vAng(rInj, kerbin:obt:velocity:orbit)), 1).
print "             Ejection dV: " + round(nextNode:deltaV:mag, 1).
print "             Prograde dV: " + round(nextNode:prograde, 1).
print "               Normal dV: " + round(nextNode:normal, 2).
print "      Transfer periapsis: " + round(xferObt["periapsis"](xferObt) / 1000000).
print "       Transfer apoapsis: " + round(xferObt["apoapsis"](xferObt) / 1000000).
print "    Transfer Inclination: " + round(xferObt["inclination"], 2).
print "          Transfer angle: " + round(vAng(r1, r2), 2).
