// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
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

local interceptLongitude is DDOrbit["interceptLongitude"](src, dst) + 180.
if norDeg(interceptLongitude - dstObt["longitude"](dstObt)) > 180 {
    set interceptLongitude to norDeg(interceptLongitude - 180).
}
print "intercept longitude: " + round(interceptLongitude, 1).

local interceptTrueAnomaly is dstObt["trueAnomalyAtLongitude"](dstObt, interceptLongitude).
//print "interceptTrueAnomaly: " + round(interceptTrueAnomaly, 1).

local tgtObt is dstObt["at"](dstObt, interceptTrueAnomaly).
local r2 is tgtObt["position"](tgtObt).

local t2 is dstObt["secondsToTrueAnomaly"](dstObt, interceptTrueAnomaly).
print "intercept ETA: " + round(t2 * secToDay, 2).

local srcInterceptTrueAnomaly is srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude).
local hohmannDepartureTrueAnomaly is norDeg(srcInterceptTrueAnomaly + 180).
local hohmannObt is srcObt["at"](srcObt, hohmannDepartureTrueAnomaly).
local hohmannR1 is hohmannObt["radius"](hohmannObt).
local hohmannSemiMajorAxis is (hohmannR1 + r2:mag) / 2.
local hohmannDuration is constant:pi * sqrt(hohmannSemiMajorAxis ^ 3 / src:obt:body:mu).
local hohmannDeparture is t2 - hohmannDuration.

print "interceptTrueAnomaly: " + round(srcInterceptTrueAnomaly, 1).
print "departure true anomaly: " + round(hohmannDepartureTrueAnomaly, 1).
print "estimated travel time: " + round(hohmannDuration * secToDay, 2).
print "departure ETA: " + round((t2 - hohmannDuration) * secToDay, 2).

// Transfer window:
// opens: T < hohmannDeparture where trueAnomaly = hohmannTrueAnomaly - 60
// closes: T > hohmannDeparture where trueAnomaly = hohmannTrueAnomaly + 60

local hohmannDepartureObt is srcObt["after"](srcObt, hohmannDeparture).
local hohmannTrueAnomalyCheck is hohmannDepartureObt["trueAnomaly"].
print "true anomaly at hohmann time: " + round(hohmannTrueAnomalyCheck, 1).

local windowOpen is hohmannDeparture - srcObt["period"](srcObt) + hohmannDepartureObt["secondsToTrueAnomaly"](hohmannDepartureObt, norDeg(hohmannDepartureTrueAnomaly - 60)).

local windowObt is srcObt["after"](srcObt, windowOpen).
local windowDuration is windowObt["secondsToTrueAnomaly"](windowObt, norDeg(hohmannDepartureTrueAnomaly + 60)).

local tInc is windowDuration / 10.

print "ETA window open: " + round(windowOpen * secToHour, 2).
print "Duration: " + round(windowDuration * secToHour, 2).

local t1 is windowOpen.
local count is 0.
until t1 > windowOpen + windowDuration {
    set count to count + 1.
    local r1Obt is srcObt["after"](srcObt, t1).
    local r1TrueAnomaly is r1Obt["trueAnomaly"].
    print " ".
    //print "departure time: " + round(t1 * secToDay, 2).
    print "departure true anomaly: " + round(r1TrueAnomaly, 1).
    local r1 is r1Obt["position"](r1Obt).
    local v0 is r1Obt["velocity"](r1Obt).
    print "time: " + round((t2 - t1) * secToDay, 3).
    print "sweep angle: " + round(vAng(r1, r2), 1).
    local vLamb is Gooding["vLamb"](src:obt:body:mu, r1, r2, t2 - t1).
    //print vLamb.

    local v1 is vLamb[0].
    local v2 is vLamb[1].
    local dv is v1 - v0.
    print "v0: " + round(v0:mag, 1) + "    " + v0.
    print "v1: " + round(v1:mag, 1) + "    " + v1.
    print "dv: " + round(dV:mag, 1) + "    " + dV.
    local xferObt is DDOrbit["withVectors"](src:obt:body, r1, v1).
    //print "xfer peri: " + xferObt["periapsis"](xferObt).
    //print "xfer apo: " + xferObt["apoapsis"](xferObt).
    print "xfer inc: " + xferObt["inclination"].
    set t1 to t1 + tInc.
}
