// dd_circularize.ks - Circularize into an orbit.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run once lib_dd.

clearscreen.
print "DunaDirect Circularize! v0.1".

// Circularize etc.
function orbitalVelocity {
  parameter orbitable.
  parameter altitude.
  parameter a is orbitable:obt:semiMajorAxis.
  local r is altitude + orbitable:body:radius.
  return sqrt(orbitable:body:mu * ((2 / r) - (1 / a))).  
}

parameter stageParam is false.
wait until altitude > body:atm:height.
set warp to 0.
wait until warp = 0.
if stageParam = true {
  stage.
  wait 1.
}

local goalSemiMajorAxis is body:radius + apoapsis.
local initialVelocity is orbitalVelocity(ship, apoapsis).
local goalVelocity is orbitalVelocity(ship, apoapsis, goalSemiMajorAxis).
local deltaV is goalVelocity - initialVelocity.

local burnTime is deltaVBurnTime(deltaV).
lock burnStartTime to time:seconds + eta:apoapsis - burnTime / 2.

mprint("Circularization burn time: " + round(burnTime) + " dV:" + round(deltaV)).
logLaunchEvent(list(deltaV)).

wait until time:seconds >= burnStartTime - 30.
set warp to 0.
lock burnPitch to -pitchForVec(ship, ship:prograde:forevector).
lock burnHeading to compassForVec(ship, ship:prograde:forevector).
lock steering to lookdirup(heading(burnHeading, burnPitch):vector, heading(burnHeading, -45):vector).

wait until time:seconds >= burnStartTime.
steerToDir().
lock throttle to 1.

wait until obt:semiMajorAxis >= goalSemiMajorAxis.

lock throttle to 0.
unlock steering.
unlock throttle.
set ship:control:pilotMainThrottle to 0.
