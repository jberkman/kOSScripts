// launch.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter inclination, rendezvous.

local launchHeading is 90 - inclination.
local launchAltitude is body:atm:height + 10000.
if rendezvous {
	set launchAltitude to target:orbit:semiMajorAxis - body:radius.
} else {
  run libDunaDirect.
}

print "Waiting for launch...".
set ship:control:pilotmainthrottle to 0.
lock throttle to 1.
wait until verticalSpeed > 10.

local lock lookAt to heading(launchHeading, 90).
local lock lookUp to heading(launchHeading, -45).
lock steering to lookdirup(lookAt:vector, lookUp:vector).

if body:atm:exists {
  wait until verticalSpeed > 50.

	global checkpoints is list(
	  list(14, 67.5),
	  list(6, 45),
	  list(2.8, 22.5),
	  list(2, 0)
	).

  global sourcePitch to 90.
  global targetPitch to 90.
  global sourceAltitude to 0.
  global targetAltitude to 0.

  lock lookAt to heading(launchHeading, targetPitch).

  when altitude > targetAltitude then {
    set sourcePitch to targetPitch.
    set targetPitch to checkpoints[0][1].

    set sourceAltitude to targetAltitude.
    set targetAltitude to body:atm:height / checkpoints[0][0].

    lock lookAt to heading(launchHeading, targetPitch + (sourcePitch - targetPitch) * (targetAltitude - altitude) / (targetAltitude - sourceAltitude)).

    if checkpoints:length > 1 {
      checkpoints:remove(0).
      preserve.
    } else {
      when altitude > targetAltitude then {
        lock lookAt to heading(launchHeading, targetPitch).
      }
    }
  }

	wait until apoapsis > launchAltitude.

	local coastPID to PIDLoop(0.05, 0, 0.05, 0, 1).
	lock throttle to coastPID:update(time:seconds, apoapsis - launchAltitude).

	wait until altitude > body:atm:height.
} else {
	wait until apoapsis > altitude + 1000 - alt:radar.
  lock lookAt to heading(launchHeading, 22.5).
	wait until apoapsis > launchAltitude.
}

lock throttle to 0.

if rendezvous {
	run ddRendezvous.
} else {
	run ddBurnFromAltitudeToAltitudeAtTime(apoapsis, apoapsis, time:seconds + timeToApoapsisOfOrbit(obt)).
}
