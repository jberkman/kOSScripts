// lib_dd_launch - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter launchAltitude, launchAzimuth, pitchRate.

runOncePath("lib_dd").

clearScreen.
print " ".
print "   Startup".           // 1
print "   Ignition".          // 2
print "   Liftoff".           // 3
print "   Roll Program".      // 4
print "   Gravity Turn".      // 5
print "   Max-Q".             // 6
print "   MECO".              // 7
print "   Horizontal Flight". // 8
print "   SECO".              // 9

if status = "prelaunch" {
  print "T -" at (0, 0).
  from { local count is 10. } until count = 0 step {
    set count to count - 1.
    wait 1.
  } do {
    print count + " " at(4, 0).
    if count < 15 and warp <> 0 {
      set warp to 0.
    }
    if count <= 10 {
      print "*" at(1, 1).
      print char(7).
    }
  }
  print 0 at(4, 0).
  lock throttle to 1.
  stage.
  print "*" at(1, 2).
}

wait until verticalSpeed > 1.
print "*" at(1, 3).

// Wait to clear tower.
local rollAlt is alt:radar + 60.
wait until alt:radar > rollAlt.
sas off.

// Pitch program.
local tPitch is time:seconds.
local gravTurnPitch is 0.

local launchPhase is 0.
local prevQ is ship:q.

lock lookAt to heading(launchAzimuth, 90 - pitchRate * (time:seconds - tPitch)):vector.
lock lookUp to heading(launchAzimuth, -45):vector.

print "*" at(1, 4).
lock steering to lookDirUp(lookAt, lookUp).

global maxQValue is 0.
function maxQ {
  set maxQValue to max(maxQValue, ship:q).
  return maxQValue.
}

global maxQReached is false.
when ship:q < maxQ() then {
  print "*" at(1, 6).
  set maxQReached to true.
}

when ship:availableThrust = 0 then { print "*" at(1, 7). }

when maxQReached or ship:q > 0.2 then {
  print "*" at(1, 5).
  lock lookAt to ship:velocity:surface.
  lock lookUp to heading(compassForVec(ship, ship:velocity:surface), -45):vector.
  when ship:q < 0.02 then {
    global horizTime is time:seconds.
    global horizPitch is pitchForVec(ship, ship:facing:vector).
    print "*" at(1, 8).
    lock lookAt to heading(compassForVec(ship, ship:velocity:orbit), max(0, horizPitch * (1 - (time:seconds - horizTime) / 4))):vector.
  }
}
