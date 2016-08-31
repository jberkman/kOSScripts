// lib_dd_launch - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter launchAltitude, launchAzimuth, pitchRate.

run once lib_dd.

if status = "prelaunch" {
  print "T -" at (0, 9).
  from { local count is 30. } until count = 0 step {
    setMET(time:seconds + count).
    set count to count - 1.
    wait 1.
  } do {
    print count + " " at(4, 9).
    if count < 15 and warp <> 0 {
      set warp to 0.
    }
    if count <= 10 {
      print char(7).
    }
  }
  print 0 at(4, 9).
  lock throttle to 1.
  stage.
  mprint("Ignition!").
}

// Wait to clear tower.
local rollAlt is alt:radar + 60.
logLaunchEvent(list(availableThrust * (body:radius + altitude) ^ 2 / mass / body:mu)).
wait until alt:radar > rollAlt.
sas off.

// Pitch program.
local tPitch is time:seconds.
local gravTurnPitch is 0.

local launchPhase is 0.
local prevQ is ship:q.

lock lookAt to heading(launchAzimuth, 90 - pitchRate * (time:seconds - tPitch)):vector.
lock lookUp to heading(launchAzimuth, -45):vector.

mprint("Beginning roll program and pitch manoeuvre.").
lock steering to lookDirUp(lookAt, lookUp).

global maxQValue is 0.
function maxQ {
  set maxQValue to max(maxQValue, ship:q).
  return maxQValue.
}

global maxQReached is false.
when ship:q < maxQ() then {
  mprint("Reaching max Q: " + round(maxQ(), 2) + ".").
  set maxQReached to true.
}

when maxQReached or ship:q > 0.2 then {
  mprint("Transitioning to gravity turn.").
  lock lookAt to ship:velocity:surface.
  lock lookUp to heading(compassForVec(ship, ship:velocity:surface), -45):vector.
  when ship:q < 0.02 then {
    global horizTime is time:seconds.
    global horizPitch is pitchForVec(ship, ship:facing:vector).
    mprint("Transitioning to horizontal flight.").
    lock lookAt to heading(compassForVec(ship, ship:velocity:orbit), max(0, horizPitch * (1 - (time:seconds - horizTime) / 4))):vector.
  }
}

local burnPID to pidLoop(0.1, 0, 0, 0, 1).
lock throttle to burnPID:update(time:seconds, ship:apoapsis - launchAltitude).
wait until apoapsis > launchAltitude.
lock throttle to 0.
mprint("Beginning coast phase. peri: " + round(ship:periapsis / 1000, 2) + "km.").
logLaunchEvent(list(altitude, periapsis)).
wait until altitude > body:atm:height.
set warp to 0.
wait until warp = 0.
