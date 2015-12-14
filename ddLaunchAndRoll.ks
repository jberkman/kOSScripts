// ddLaunchAndRoll.ks - Perform a gravity turn.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter turnHeading.

print "Waiting for launch...".
lock throttle to 1.

wait until verticalSpeed > 10.

hudText("Initiating roll program.", 5, 2, 15, yellow, true).
lock steering to lookdirup(heading(turnHeading, 90):vector, heading(turnHeading, -45):vector).

when abs(facing:roll - 90) < 1 then {
  hudText("Roll program complete.", 5, 2, 15, yellow, true).
}
