// descentBurn.ks - Perform descent burn.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run mechanics.

local burnRoll is roll_for(ship).

lock burnHeading to compassForVec(ship, ship:srfretrograde:forevector).
lock burnPitch to 2 * pitchForVec(ship, ship:srfretrograde:forevector).

lock steering to r(0, 0, burnRoll) + heading(burnHeading, burnPitch).
lock throttle to 0.

print "Wating for rotation.".
wait until abs(compass_for(ship) - burnHeading) < 5 and abs(pitch_for(ship) - burnPitch) < 5.

global burnPID to pidLoop(0.1, 0, 0, 0, 1).
lock throttle to burnPID:update(time:seconds, -groundspeed).

print "Waiting for surface velocity to reach 0.".
wait until groundspeed < 0.25.

lock burnPitch to 90 - 2 * vang(up:vector, ship:srfretrograde:vector).

local lock impactTime to timeToImpact().
local lock suicideDeltaV to suicideVelocityWithTime(impactTime).
local lock landed to status = "LANDED" or status = "SPLASHED".

until landed {
  print "Waiting for burn...".
  lock throttle to 0.
  wait until landed or impactTime < ceiling(estimatedBurnTimeWithDeltaV(suicideDeltaV)).

  if landed {
    break.
  }

  print "Burning!".
  lock throttle to burnPID:update(time:seconds, verticalSpeed).
  wait until landed or abs(verticalSpeed) < 1.
}

unlock steering.
unlock throttle.

print "Burn complete.".
