// dd_circularize.ks - Circularize into an orbit.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").

clearscreen.
print "DunaDirect Circularize! v0.2".

local goalAltitude is body:radius.
local burnEta is 0.
if eta:apoapsis < eta:periapsis {
	// Raise peri to apo
	set goalAltitude to goalAltitude + ship:obt:apoapsis.
	lock burnTime to time:seconds + eta:apoapsis.
} else {
	// drop apo to peri
	set goalAltitude to goalAltitude + ship:obt:periapsis.
	lock burnTime to time:seconds + eta:periapsis.
}
print "goal alt: " + goalAltitude.
print "time: " + burnTime.
local goalVelocity is sqrt(ship:body:mu / goalAltitude).
print "goalVelocity: " + goalVelocity.
local deltaV is goalVelocity - velocityAt(ship, burnTime):orbit:mag.
print "deltaV: " + deltaV.

local burnDuration is deltaVBurnTime(abs(deltaV)).
lock burnStartTime to burnTime - burnDuration / 2.

mprint("Circularization burn time: " + round(burnDuration) + " dV:" + round(deltaV)).
logLaunchEvent(list(deltaV)).

wait until time:seconds >= burnStartTime - 60.
set warp to 0.
local lock burnVector to ship:prograde:foreVector.
if deltaV < 0 {
	lock burnVector to ship:retrograde:foreVector.
}
lock burnPitch to -pitchForVec(ship, burnVector).
lock burnHeading to compassForVec(ship, burnVector).
lock steering to lookdirup(heading(burnHeading, burnPitch):vector, heading(burnHeading, -45):vector).

wait until time:seconds >= burnStartTime.
steerToDir().
lock throttle to 1.

if deltaV > 0 {
	wait until ship:obt:semiMajorAxis >= goalAltitude.
} else {
	wait until ship:obt:semiMajorAxis <= goalAltitude.
}

lock throttle to 0.
unlock steering.
unlock throttle.
set ship:control:pilotMainThrottle to 0.
