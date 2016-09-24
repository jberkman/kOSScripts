// launch.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").

// Parse options 
local launchAzimuth is 90.
local circularize is true.
local rendezvous is false.
local launchAltitude is body:atm:height + 10000.
local pitchRate is 0.6.

local scrub is false.
local launch is false.
until scrub or launch {
  clearscreen.
  print "DunaDirect Launch! v2.9".
  print " ".
  menu(lex(
    "Altitude: " + round(launchAltitude / 1000, 3) + " km", {
      print "Enter altitude in km:".
      getScalar({
        parameter value.
        set launchAltitude to value * 1000.
      }).
    },
    "Azimuth: " + round(launchAzimuth, 3) + " deg", {
      print "Enter inclination in degrees:".
      getScalar({
        parameter value.
        set launchAzimuth to arcsin(clamp(cos(value) / cos(ship:latitude), -1, 1)).
      }).
    },
    "Pitch Rate: " + round(pitchRate, 3) + " deg/s", {
      print "Enter pitch rate in degrees / s:".
      getScalar({
        parameter value.
        set pitchRate to value.
      }).
    },
    "Circularize: " + circularize, {
      set circularize to not circularize.
      set rendezvous to false.
    },
    "Rendezvous: " + rendezvous, {
      set rendezvous to not rendezvous.
      set circularize to false.
    },
    "Proceed with final countdown", { set launch to true. },
    "Scrub", { set scrub to true. }
  )).
}

if launch {
  if circularize {
    install("dd_circularize").
  } else if rendezvous {
    install("dd_rendezvous").
  }
  logLaunchEvent(list(launchAzimuth, pitchRate)).

  // Initialize and begin countdown.
  set ship:control:pilotMainThrottle to 0.
  sas on.
  setMET(time:seconds).

  if body:atm:exists {
    install("lib_dd_launch").
    runPath("lib_dd_launch", launchAltitude, launchAzimuth, pitchRate).
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

  if circularize {
    runPath("dd_circularize").
  } else if rendezvous {
    runPath("dd_rendezvous").
  }
  print "Launch complete. Remaining dV: " + deltaV.
}
