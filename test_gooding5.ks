// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
clearVecDraws().
runOncePath("lib_dd_orbit").
runOncePath("lib_dd_gooding").

//local src is kerbin.
//local dst is moho.
//local src is ship.
//local dst is minmus.

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

    local departure is 0.
    local departureDelta is src:obt:period / 72.

    local duration is false.
    local durationDelta is dst:obt:period / 72.

    local bestDV is 99999.

    until departure > synodicPeriod {
        local departureTime is time + departure.
        local r1 is shipRawToSOIUniversal(positionAt(src, departureTime), body).
        local v0 is rawToUniversal(velocityAt(src, departureTime):orbit).
        set duration to departureDelta.
        until duration > hohmannPeriod {
            local r2 is shipRawToSOIUniversal(positionAt(dst, departureTime + duration), body).
            if vAng(r1, r2) > 120 {
                local vLamb is Gooding["vLamb"](body:mu, r1, r2, duration).
                local v1 is vLamb[0].
                local dV is v1 - v0.
                if dV:mag < bestDV {
                    set bestDV to dV:mag.
                    print "    dep: " + days(departure) + "    dur: " + days(duration) + "    dV: " + round(dV:mag, 1).
                }
            }
            set duration to duration + durationDelta.
        }
        set departure to departure + departureDelta.
    }

    print 1/0.
    local mu is srcObt["body"]:mu.
    local interceptLongitude is DDOrbit["interceptLongitude"](srcObt, dstObt).

    local tInt is time.
    local r2 is false.
    {
        local dstInterceptTrueAnomaly is dstObt["trueAnomalyAtLongitude"](dstObt, interceptLongitude).
        set tInt to tInt + dstObt["secondsToTrueAnomaly"](dstObt, dstInterceptTrueAnomaly).

        local tgtObt is dstObt["at"](dstObt, dstInterceptTrueAnomaly).
        set r2 to tgtObt["position"](tgtObt).
    }

    local interceptTrueAnomaly is srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude).
    local sweepAngle is 240.
    {
        local trueAnomaly is srcObt["trueAnomaly"].
        local windowStart is norDeg(interceptTrueAnomaly - sweepAngle).
        local windowEnd is norDeg(windowStart + 120).
        if windowStart < windowEnd {
            if trueAnomaly > windowStart and trueAnomaly < windowEnd {
                print "Transfer window already in progress.".
                set sweepAngle to norDeg(interceptTrueAnomaly - trueAnomaly).
            }
        } else if trueAnomaly > windowStart or trueAnomaly < windowEnd {
            print "Transfer window already in progress.".
            set sweepAngle to norDeg(interceptTrueAnomaly - trueAnomaly).
        }
        print "    windowStart: " + windowStart.
        print "      windowEnd: " + norDeg(windowStart + 120).
        print "    trueAnomaly: " + trueAnomaly.
        print "     sweepAngle: " + sweepAngle.    
    }

    local retDV is V(0, 0, 0).
    local retT is 0.

    until sweepAngle < 120 {
        local trueAnomaly is norDeg(interceptTrueAnomaly - sweepAngle).
        local tDelta is tInt - srcObt["secondsToTrueAnomaly"](srcObt, trueAnomaly).

        local depObt is srcObt["at"](srcObt, trueAnomaly).
        local v0 is depObt["velocity"](depObt).
        local r1 is depObt["position"](depObt).

        local vLamb is Gooding["vLamb"](mu, r1, r2, tDelta:seconds).
        local v1 is vLamb[0].
        local dV is v1 - v0.

        if retT = 0 or dV:mag < retDV:mag {
            set retT to tInt - tDelta.
            set retDV to dV.
            print " ".
            print "    v: " + round(sweepAngle, 1).
            print "    T: " + round(retT:seconds * DDConstant["secToDay"], 1).
            print "   dV: " + round(retDV:mag, 1).
        }

        set sweepAngle to sweepAngle - 5.
    }

//        local vInf is v1 - v0.

//    local tDelta is  + dstObt["period"](dstObt).
//    if norDeg(interceptTrueAnomaly - srcObt["trueAnomaly"]) < 90 {
//        set interceptLongitude to norDeg(interceptLongitude + 180).
//        set interceptTrueAnomaly to srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude).
//    }
//    local hohmannObt is srcObt["at"](srcObt, norDeg(interceptTrueAnomaly - 180)).
//    local hohmannR1 is hohmannObt["radius"](hohmannObt).
//    local hohmannSemiMajorAxis is (hohmannR1 + r2:mag) / 2.
//    local hohmannDuration is constant:pi * sqrt(hohmannSemiMajorAxis ^ 3 / src:obt:body:mu).
//    local hohmannDeparture is t2 - hohmannDuration.
//    set tInt to tInt + dstObt["period"](dstObt).



    //if norDeg(interceptTrueAnomaly - srcObt["trueAnomaly"]) < 90 {
    //    set interceptLongitude to norDeg(interceptLongitude + 180).
    //    set interceptTrueAnomaly to srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude).
    //}
}

getWindow(kerbin, moho).
print 1/0.

local r1 is srcObt["position"](srcObt).
local v0 is srcObt["velocity"](srcObt).

local dstInterceptTrueAnomaly is dstObt["trueAnomalyAtLongitude"](dstObt, interceptLongitude).
local tgtObt is dstObt["at"](dstObt, dstInterceptTrueAnomaly).
local tDelta is dstObt["secondsToTrueAnomaly"](dstObt, dstInterceptTrueAnomaly) + dstObt["period"](dstObt).
local r2 is tgtObt["position"](tgtObt).

//print "intercept longitude: " + round(interceptLongitude, 1).
//print "interceptTrueAnomaly: " + round(interceptTrueAnomaly, 1).
//print "dstInterceptTrueAnomaly: " + round(dstInterceptTrueAnomaly, 1).

//print " ".
//print "intercept ETA: " + round(tDelta * secToDay, 2).
local vLamb is Gooding["vLamb"](src:obt:body:mu, r1, r2, tDelta).
local v1 is vLamb[0].
local v2 is vLamb[1].
local vInf is v1 - v0.

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
