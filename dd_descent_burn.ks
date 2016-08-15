// ddDescentBurn.ks - Perform descent burn.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

clearscreen.
print "DunaDirect Descend! v1.0".

run once lib_dd.

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

unlock throttle.
unlock steering.
