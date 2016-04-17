// burnFromAltitudeToAltitudeAtTime.ks - Perform manouevres with or without nodes.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

clearscreen.
print "DunaDirect Burn! v1.0".

run once lib_dd.

parameter sourceAltitude.
parameter targetAltitude.
parameter t.

function orbitalVelocity {
  parameter orbitable.
  parameter altitude.
  parameter a is orbitable:obt:semiMajorAxis.

  local r is altitude + orbitable:body:radius.

  return sqrt(orbitable:body:mu * ((2 / r) - (1 / a))).  
}

local goalOrbit to sourceAltitude + targetAltitude.
local initialVelocity is orbitalVelocity(ship, sourceAltitude).
local goalVelocity is orbitalVelocity(ship, sourceAltitude, body:radius + goalOrbit / 2).
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

lock burnStartTime to t - deltaVBurnTime(deltaV) / 2.

print "deltaV required for circularization: " + round(abs(deltaV)).
print "estimated burn time: " + round(2 * (t - burnStartTime)).

lock throttle to 0.

wait until time:seconds >= burnStartTime - 30.
set warp to 0.
lock steering to lookdirup(heading(burnHeading, burnPitch):vector, heading(burnHeading, -45):vector).

wait until time:seconds >= burnStartTime.
lock throttle to 1.

wait until burnComplete.

unlock steering.
unlock throttle.

print "Burn complete.".
