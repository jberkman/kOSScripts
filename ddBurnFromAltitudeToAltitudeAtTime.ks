// burnFromAltitudeToAltitudeAtTime.ks - Perform manouevres with or without nodes.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run libDunaDirect.

parameter sourceAltitude.
parameter targetAltitude.
parameter t.

local goalOrbit to sourceAltitude + targetAltitude.
local initialVelocity is velocityOfOrbitalAtAltitude(ship, sourceAltitude).
local goalVelocity is velocityOfOrbitalAtAltitudeWithSemiMajorAxis(ship, sourceAltitude, body:radius + goalOrbit / 2).
local deltaV is goalVelocity - initialVelocity.

local burnHeading is 0.

if deltaV > 0 {
  lock burnComplete to apoapsis + periapsis >= goalOrbit.
  set burnHeading to compassForVec(ship, ship:prograde:forevector).
  lock burnPitch to -pitchForVec(ship, ship:prograde:forevector).
} else {
  lock burnComplete to apoapsis + periapsis <= goalOrbit.
  set burnHeading to compassForVec(ship, ship:retrograde:forevector).
  lock burnPitch to -pitchForVec(ship, ship:retrograde:forevector).
}

lock steering to lookdirup(heading(burnHeading, burnPitch):vector, heading(burnHeading, -45):vector).
lock burnStartTime to t - estimatedBurnTimeWithDeltaV(deltaV) / 2.

print "deltaV required for circularization: " + round(abs(deltaV)).
print "estimated burn time: " + round(2 * (t - burnStartTime)).

lock throttle to 0.

wait until time:seconds >= burnStartTime.
lock throttle to 1.

wait until burnComplete.

unlock steering.
unlock throttle.

print "Burn complete.".