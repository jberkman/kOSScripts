// lib_dd_launch - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter launchAltitude, launchAzimuth, pitchRate.

run once lib_dd.

local triggersEnabled is false.
function triggerEvent {
    parameter name.
    if not triggersEnabled or not ddCfg:hasKey(name) {
      return.
    }
    local t is ddCfg[name].
    if t = "" {
      return.
    }
    print "Running trigger " + t + " for event " + name.
    if t = "ag1" { AG1 on. }
    else if t = "ag2" { AG2 on. }
    else if t = "ag3" { AG3 on. }
    else if t = "ag4" { AG4 on. }
    else if t = "ag5" { AG5 on. }
    else if t = "ag6" { AG6 on. }
    else if t = "ag7" { AG7 on. }
    else if t = "ag8" { AG8 on. }
    else if t = "ag9" { AG9 on. }
    else if t = "ag10" { AG10 on. }
}

if status = "prelaunch" {
  set triggersEnabled to true.
  local preIgnite is false.
  for module in ship:modulesNamed("LaunchClamp") {
    if module:part:stage < stage:number - 1 {
      set preIgnite to true.
      break.
    }
  }
  print "T -" at (0, 9).
  from { local count is 30. } until count = 0 step {
    setMET(time:seconds + count).
    set count to count - 1.
    wait 1.
  } do {
    print count + " " at(4, 9).
    if count = 15 {
      set warp to 0.
    }
    if count <= 10 {
      print char(7).
    }
    if preIgnite and count = 3 {
      mprint("Ignition.").
      global tIgnition is time:seconds.
      lock throttle to (time:seconds - tIgnition) / 4 + 0.5.
      stage.
      triggerEvent("launch.ignition").
    }
  }
  print 0 at(4, 9).
  stage.
  mprint("Liftoff!").
  if not preIgnite {
    triggerEvent("launch.ignition").
  }
}

// Wait to clear tower.
local rollAlt is alt:radar + 60.
lock throttle to 1.
triggerEvent("launch.liftoff").
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
triggerEvent("launch.rollProgram").

global maxQValue is 0.
function maxQ {
  set maxQValue to max(maxQValue, ship:q).
  return maxQValue.
}

global maxQReached is false.
when ship:q < maxQ() then {
  mprint("Reaching max Q: " + round(maxQ(), 2) + ".").
  set maxQReached to true.
  triggerEvent("launch.maxQ").
}

when maxQReached or ship:q > 0.2 then {
  mprint("Transitioning to gravity turn.").
  lock lookAt to ship:velocity:surface.
  lock lookUp to heading(compassForVec(ship, ship:velocity:surface), -45):vector.
  global maxQTime is time:seconds.
  global maxQPitch is pitchForVec(ship, ship:velocity:surface).
  triggerEvent("launch.gravityTurn").
  when ship:q < 0.02 then {
    mprint("Transitioning to horizontal flight.").
    lock lookAt to heading(compassForVec(ship, ship:velocity:orbit), max(0, maxQPitch - 4 * (time:seconds - maxQTime))):vector.
    triggerEvent("launch.horizontalFlight").
  }
}

// Staging control
function hasFlameout {
  local hasEngine is false.
  local hasUllage is false.
  local engs is 0.
  list engines in engs.
  for eng in engs {
    if eng:title:contains("ullage") or eng:title:contains("sepratron") or eng:tag:contains("ullage") {
      set hasUllage to hasUllage or eng:ignition.
    } else if eng:ignition and eng:flameout and not eng:multiMode {
      return true.
    } else if eng:ignition {
      set hasEngine to true.
    }
  }
  return maxThrust = 0 or (hasUllage and not hasEngine).
}

local burnPID to pidLoop(0.1, 0, 0, 0, 1).
until altitude > body:atm:height {
  lock throttle to burnPID:update(time:seconds, ship:apoapsis - launchAltitude).
  until apoapsis > launchAltitude {
    wait until apoapsis > launchAltitude or hasFlameout().
    if apoapsis < launchAltitude {
      mprint("Enginge cutout. apo: " + round(ship:apoapsis / 1000, 2) + "km.").
      logLaunchEvent(list(altitude, apoapsis)).
      if maxQReached {
        triggerEvent("launch.MECO").
      }
      wait 1.
    }
    until not hasFlameout() {
      wait 1.
      stage.
      wait 1. // give KW rockets time to spool up
    }
  }
  lock throttle to 0.
  mprint("Beginning coast phase. peri: " + round(ship:periapsis / 1000, 2) + "km.").
  logLaunchEvent(list(altitude, periapsis)).
  triggerEvent("launch.SECO").
  wait until altitude > body:atm:height or apoapsis < body:atm:height + 5000.
  set warp to 0.
  wait until warp = 0.
}

lock throttle to 0.
triggerEvent("launch.space").
