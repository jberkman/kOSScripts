// launch.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").

// Parse options 
local launchInclination is latitude.
local circularize is true.
local rendezvous is false.
local launchAltitude is body:atm:height + 10000.
local pitchRate is 0.6.

local scrub is false.
local launch is false.

until scrub or launch {
  menu("DunaDirect Launch! v3.0", lex(
    "Altitude: " + round(launchAltitude / 1000, 3) + " km", {
      local value is getAltitude("Altitude").
      if value <> "NaN" { set launchAltitude to value. }
    },
    "Inclination: " + round(launchInclination) + " deg", {
      print "Enter inclination in degrees:".
      local value is getScalar().
      if value <> "NaN" { set launchInclination to value. }
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

global maxQValue is 0.
global maxQReached is false.
function maxQ {
  set maxQValue to max(maxQValue, ship:q).
  return maxQValue.
}

if launch {
  if rendezvous { install("dd_rendezvous"). }

  // Initialize and begin countdown.
  set ship:control:pilotMainThrottle to 0.
  sas on.

  clearScreen.
  print "T -".
  print " * Startup".           // 1
  print "   Ignition".          // 2
  print "   Liftoff".           // 3
  print "   Roll Program".      // 4
  print "   Gravity Turn".      // 5
  print "   Max-Q".             // 6
  print "   MECO".              // 7
  print "   Horizontal Flight". // 8
  print "   SECO".              // 9

  local count is 10.
  until count = 0 {
    print count + " " at(4, 0).
    print char(7).
    wait 1.
    set count to count - 1.
  }
  print 0 at(4, 0).

  lock throttle to 1.
  if status = "prelaunch" { stage. }
  print "*" at(1, 2).
 
  wait until verticalSpeed > 1.
  print "*" at(1, 3).

  // Wait to clear tower.
  local rollAlt is alt:radar + 60.
  wait until alt:radar > rollAlt.
  sas off.

  local tPitch is time:seconds.
  function launchPitch {
    if body:atm:exists { return 90 - pitchRate * (time:seconds - tPitch). }
    if apoapsis < altitude + 1000 - alt:radar { return 67.5. }
    return 22.5.    
  }
  local launchAzimuth is arcsin(clamp(cos(launchInclination) / cos(latitude), -1, 1)).
  lock lookAt to heading(launchAzimuth, launchPitch()):vector.
  lock lookUp to heading(launchAzimuth, -45):vector.
  lock steering to lookDirUp(lookAt, lookUp).
  print "*" at(1, 4).

  if body:atm:exists {
    when ship:q < maxQ() then {
      print "*" at(1, 6).
      set maxQReached to true.
    }

    when ship:availableThrust = 0 then { print "*" at(1, 7). }

    when maxQReached or ship:q > 0.2 then {
      print "*" at(1, 5).
      lock lookAt to ship:velocity:surface.
      lock lookUp to -up:vector.
      when ship:q < 0.02 then {
        print "*" at(1, 8).
        lock lookAt to heading(compassForVec(ship, ship:velocity:orbit), 0):vector.
      }
    }
  }

  local SMAOffset is launchAltitude / 2 + body:radius.
  wait until orbitalVelocity(ship, altitude, SMAOffset + periapsis / 2) - velocity:orbit:mag < ship:availableThrust / mass / 2.
  lock throttle to 0.2.
  wait until apoapsis >= launchAltitude * 0.9995.
  lock throttle to 0.

  if body:atm:exists { print "*" at(1, 9). }

  if circularize {
    semiMajorAxisBurn(apoapsis, apoapsis, { return eta:apoapsis. }).
    if hasNode { runSubcommand("dd_node_burn"). }
  } else if rendezvous {
    runPath("dd_rendezvous").
  }
}
