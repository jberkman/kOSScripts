// descentBurn.ks - Perform descent burn.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run libDunaDirect.

local lock burnHeading to compassForVec(ship, ship:srfretrograde:forevector).
local lock burnPitch to 2 * pitchForVec(ship, ship:srfretrograde:forevector).
local lock burnUp to up.

lock steering to lookdirup(heading(burnHeading, burnPitch):vector, burnUp:vector).
lock throttle to 0.

print "Wating for rotation.".
wait until abs(compassForVec(ship, ship:facing:vector) - burnHeading) < 5 and abs(pitchForVec(ship, ship:facing:vector) - burnPitch) < 5.

global burnPID to pidLoop(0.1, 0, 0, 0, 1).
lock throttle to burnPID:update(time:seconds, -groundspeed).

print "Waiting for surface velocity to reach 0.".
wait until groundspeed < 0.25.

local lock burnUp to heading(90, -45).
local lock burnPitch to 90 - 2 * vang(up:vector, ship:srfretrograde:vector).

local lock impactTime to timeToImpact().
local lock suicideDeltaV to suicideVelocityWithTime(impactTime).
local lock landed to status = "LANDED" or status = "SPLASHED".

//set burnPID:kP to 0.1.
//et burnPID:kI to 0.1.
//set burnPID:kD to 0.5.
set burnPID:setPoint to -1.
lock throttle to 0.

print "Descending to " + suicideBurnDistance() + "...".
wait until landed or alt:radar - suicideBurnDistance() < 10. // impactTime < ceiling(estimatedBurnTimeWithDeltaV(suicideDeltaV)).

until landed {
  print "Burning!".
  lock throttle to burnPID:update(time:seconds, verticalSpeed).
  wait until landed or abs(verticalSpeed) < 1.

  lock throttle to 0.
  print "Waiting for burn...".
  wait until landed or impactTime < ceiling(estimatedBurnTimeWithDeltaV(suicideDeltaV)).
}

unlock steering.
unlock throttle.

print "Landing complete.".
