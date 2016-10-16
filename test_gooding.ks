// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
runOncePath("lib_dd_orbit").
runOncePath("lib_dd_gooding").

//local src is kerbin.
//local dst is moho.
local src is ship.
local dst is minmus.

local minToSec is 60.
local hourToSec is 60 * minToSec.
local dayToSec is 6 * hourToSec.

local secToMin is 1 / minToSec.
local secToHour is 1 / hourToSec.
local secToDay is 1 / dayToSec.

local srcObt is DDOrbit["withOrbit"](src:obt).
local dstObt is DDOrbit["withOrbit"](dst:obt).

local interceptLongitude is DDOrbit["interceptLongitude"](src, dst).
if norDeg(interceptLongitude - dstObt["longitude"](dstObt)) > 180 {
    set interceptLongitude to norDeg(interceptLongitude - 180).
}
print "intercept longitude: " + round(interceptLongitude, 1).

local interceptTrueAnomaly is dstObt["trueAnomalyAtLongitude"](dstObt, interceptLongitude).
print "interceptTrueAnomaly: " + round(interceptTrueAnomaly, 1).

local tgtObt is dstObt["at"](dstObt, interceptTrueAnomaly).
local r2 is tgtObt["position"](tgtObt).

local interceptTime is dstObt["secondsToTrueAnomaly"](dstObt, interceptTrueAnomaly).
print "intercept ETA: " + round(interceptTime * secToDay, 2).

local srcInterceptTrueAnomaly is srcObt["trueAnomalyAtLongitude"](srcObt, interceptLongitude).
local hohmannDepartureTrueAnomaly is norDeg(srcInterceptTrueAnomaly + 180).
local hohmannObt is srcObt["at"](srcObt, hohmannDepartureTrueAnomaly).
local hohmannR1 is hohmannObt["radius"](hohmannObt).
local hohmannSemiMajorAxis is (hohmannR1 + r2:mag) / 2.
local hohmannDuration is constant:pi * sqrt(hohmannSemiMajorAxis ^ 3 / src:obt:body:mu).
local hohmannDeparture is interceptTime - hohmannDuration.

print "departure true anomaly: " + round(hohmannDepartureTrueAnomaly, 1).
print "estimated travel time: " + round(hohmannDuration * secToDay, 2).
print "departure ETA: " + round((interceptTime - hohmannDuration) * secToDay, 2).

// Transfer window:
// opens: T < hohmannDeparture where trueAnomaly = hohmannTrueAnomaly - 60
// closes: T > hohmannDeparture where trueAnomaly = hohmannTrueAnomaly + 60

local hohmannDepartureObt is srcObt["after"](srcObt, hohmannDeparture).
local hohmannTrueAnomalyCheck is hohmannDepartureObt["trueAnomaly"].
print "true anomaly at hohmann time: " + round(hohmannTrueAnomalyCheck, 1).

local windowOpen is hohmannDeparture - srcObt["period"](srcObt) + hohmannDepartureObt["secondsToTrueAnomaly"](hohmannDepartureObt, norDeg(hohmannDepartureTrueAnomaly - 60)).
set windowOpen to hohmannDeparture - srcObt["period"](srcObt) + hohmannDepartureObt["secondsToTrueAnomaly"](hohmannDepartureObt, norDeg(hohmannDepartureTrueAnomaly)).
print "ETA window open: " + round(windowOpen * secToHour, 2).
local windowClose is hohmannDeparture + hohmannDepartureObt["secondsToTrueAnomaly"](hohmannDepartureObt, norDeg(hohmannDepartureTrueAnomaly + 60)).
print "Duration: " + round((windowClose - windowOpen) * secToHour, 2).

local tDepart is max(0, windowOpen).
local tInc is (windowClose - windowOpen) / 10.
until tDepart > windowOpen {
    local r1Obt is srcObt["after"](srcObt, tDepart).
    local r1TrueAnomaly is r1Obt["trueAnomaly"].
    print " ".
    print "departure time: " + round(tDepart * secToDay, 2).
    print "departure true anomaly: " + round(r1TrueAnomaly, 1).
    //if r1TrueAnomaly >= longTrueAnomaly and r1TrueAnomaly <= shortTrueAnomaly {
        local r1 is r1Obt["position"](r1Obt).
        local v0 is r1Obt["velocity"](r1Obt).
        print "v0: " + v0.
        print "v0: " + round(v0:mag, 1).
        local vLamb is Gooding["vLamb"](src:obt:body:mu, r1, r2, interceptTime - tDepart).
        print vLamb.

        local v1 is vLamb[0].
        local v2 is vLamb[1].
        local dv is v1 - v0.
        print "v1: " + round(v1:mag, 1).
        print "dv: " + dV.
        print "dv: " + round(dV:mag, 1).
        print "dv: " + round(v1:mag - v0:mag, 1).
        local xferObt is DDOrbit["withVectors"](src:obt:body, r1, v1).
        print "xfer peri: " + xferObt["periapsis"](xferObt).
        print "xfer apo: " + xferObt["apoapsis"](xferObt).
        print "xfer inc: " + xferObt["inclination"].
    //} else {
    //    print " (skipping)".
    //}
    print 1/0.
    set tDepart to tDepart + tinc.
}

local hohmannDepartureObt is srcObt["after"](srcObt, hohmannDeparture).

// Transfer window starts at time of longest sweep angle (240 deg) before hohmannDeparture.
// Transfer window ends at time of shorest sweep angle (120 deg) after hohmannDeparture.
// (Sweep angles near 180 may need to use mid-course inclination burn)


print 1/0.


local r1 is srcObt["position"](srcObt).

local vList is vLamb(src:obt:body:mu, r1, r2, interceptTime).
local v1 is vList[0].
local v2 is vList[1].

local xfer is DDOrbit["withVectors"](src:obt:body, r1, v1).
print "xfer peri: " + xfer["periapsis"](xfer).
print "xfer apo: " + xfer["apoapsis"](xfer).
print "xfer inc: " + xfer["inclination"].
