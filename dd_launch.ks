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
  menu("DunaDirect Launch! v2.9", lex(
    "Altitude: " + round(launchAltitude / 1000, 3) + " km", {
      local value is getAltitude("Altitude").
      if value <> "NaN" { set launchAltitude to value. }
    },
    "Azimuth: " + round(launchAzimuth, 3) + " deg", {
      print "Enter inclination in degrees:".
      local value is getScalar().
      if value <> "NaN" { set launchAzimuth to arcsin(clamp(cos(value) / cos(ship:latitude), -1, 1)). }
    },
    "Pitch Rate: " + round(pitchRate, 3) + " deg/s", {
      print "Enter pitch rate in degrees / s:".
      local value is getScalar().
      if value <> "NaN" { set pitchRate to value. }
    },
    "Circularize: " + circularize, {
      set circularize to not circularize.
      set rendezvous to false.
    },
    "Rendezvous: " + rendezvous, {
      set rendezvous to not rendezvous.
      set circularize to false.
    },
    "GO For Launch", { set launch to true. },
    "Scrub", { set scrub to true. }
  )).
}

if launch {
  if rendezvous { install("dd_rendezvous"). }

  // Initialize and begin countdown.
  set ship:control:pilotMainThrottle to 0.
  sas on.

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
  }

  local SMAOffset is launchAltitude / 2 + body:radius.
  wait until apoapsis > 70000.
  local lock deltaV to orbitalVelocity(ship, altitude, SMAOffset + periapsis / 2) - velocity:orbit:mag.
  local lock thrust to ship:availableThrust / mass.

  wait until deltaV <= thrust / 2.
  lock throttle to 0.2.
  wait until apoapsis >= launchAltitude * 0.99.
  lock throttle to 0.

  if body:atm:exists { print "*" at(1, 9). }

  if circularize {
    semiMajorAxisBurn(apoapsis, apoapsis, { return eta:apoapsis. }).
  } else if rendezvous {
    runPath("dd_rendezvous").
  }
}
