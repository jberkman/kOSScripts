// launch.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").

// Parse options 
local launchAzimuth is 90.
local rendezvous is false.
local launchAltitude is body:atm:height + 10000.
if rendezvous {
	set launchAltitude to target:orbit:semiMajorAxis - body:radius.
}
local pitchRate is 0.6.

clearscreen.
print "DunaDirect Launch! v2.9".

function getNumber {
  parameter setFunc.
  local line is getLine().
  if line = false {
    return.
  }
  local scalar is parseScalar(line).
  if scalar = false {
    return.
  }
  setFunc(scalar).
}

function setAltitude {
  print "Enter altitude in km:".
  getNumber({
    parameter value.
    set launchAltitude to value * 1000.
  }).
}

function setAzimuth {
  print "Enter inclination in degrees:".
  getNumber({
    parameter value.
    set launchAzimuth to arcsin(clamp(cos(value) / cos(ship:latitude), -1, 1)).
  }).
}

function setPitchRate {
  print "Enter pitch rate in degrees / s:".
  getNumber({
    parameter value.
    set pitchRate to value.
  }).
}

local scrub is false.
local launch is false.
until scrub or launch {
  menu("Ready to Launch", lex(
    "Altitude: " + round(launchAltitude / 1000, 3) + " km", { setAltitude(). },
    "Azimuth: " + round(launchAzimuth, 3) + " deg", { setAzimuth(). },
    "Pitch Rate: " + round(pitchRate, 3) + " deg/s", { setPitchRate(). },
    "Rendezvous: " + rendezvous, { set rendezvous to not rendezvous. },
    "Proceed with final countdown", { set launch to true. },
    "Scrub", { set scrub to true. }
  )).
}

if launch {
  logLaunchEvent(list(launchAzimuth, pitchRate)).

  // Initialize and begin countdown.
  set ship:control:pilotMainThrottle to 0.
  sas on.
  setMET(time:seconds).

  if body:atm:exists {
    run lib_dd_launch(launchAltitude, launchAzimuth, pitchRate).
  } else {
    // Wait to clear tower.
    local rollAlt is alt:radar + 60.
    lock throttle to 1.
    wait until alt:radar > rollAlt.
    sas off.
    // Pitch program.
    local tPitch is time:seconds.

    function launchPitch {
      if apoapsis < altitude + 1000 - alt:radar {
        return 67.5.
      }
      return 22.5.    
    }

    local lock lookAt to heading(launchAzimuth, launchPitch()).
    local lock lookUp to heading(launchAzimuth, -45).
    lock steering to lookDirUp(lookAt:vector, lookUp:vector).
    wait until apoapsis > launchAltitude.
  }

  lock throttle to 0.
  logLaunchEvent(list(obt:inclination)).
  local deltaV is stageDeltaV().
  logLaunchEvent(list(deltaV)).
  print "Launch complete. Remaining dV: " + deltaV.
}
