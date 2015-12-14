// launchAndRendezvous.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

set ship:control:pilotmainthrottle to 0.

local launchHeading is 90.

run ddLaunchAndRoll(launchHeading).

if body:atm:exists {
	run ddGravityTurn(launchHeading, list(
	  list(14, 67.5),
	  list(6, 45),
	  list(2.8, 22.5),
	  list(2, 0)
	)).

	run ddCoastToAltitude(target:orbit:semiMajorAxis - body:radius).
} else {
	wait until apoapsis > altitude + 1000 - alt:radar.
	lock steering to lookdirup(heading(launchHeading, 22.5):vector, heading(launchHeading, -45):vector).
	wait until apoapsis > target:orbit:semiMajorAxis - body:radius.
}

run ddRendezvous.
