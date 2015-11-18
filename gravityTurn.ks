// gravityTurn.ks - Perform a gravity turn.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

function launchWithGravityTurnCheckpoints {
  parameter checkpoints.

  print "Waiting for launch...".
  lock throttle to 1.
  wait until velocity:surface:mag > 10.

  hudText("Initiating roll program.", 5, 2, 15, yellow, true).
  lock steering to r(0, 0, 180) + heading(90, 90).
  when abs(facing:roll - 90) < 1 then {
    hudText("Roll program complete.", 5, 2, 15, yellow, true).
  }

  wait until velocity:surface:mag > 50.

  global gravityTurnOldPitch to 90.
  global gravityTurnPitch to 90.
  global gravityTurnOldAltitude to 0.
  global gravityTurnAltitude to 0.

  global gravityTurnCheckpoints to checkpoints.

  lock pitch to gravityTurnPitch.
  lock steering to r(0, 0, 180) + heading(90, pitch).

  when altitude > gravityTurnAltitude then {
    set gravityTurnOldPitch to gravityTurnPitch.
    set gravityTurnPitch to gravityTurnCheckpoints[0][1].

    set gravityTurnOldAltitude to gravityTurnAltitude.
    set gravityTurnAltitude to body:atm:height / gravityTurnCheckpoints[0][0].

    hudText("Pitching down => " + gravityTurnPitch + " @ " + gravityTurnAltitude, 5, 2, 15, yellow, true).
    lock pitch to gravityTurnPitch + (gravityTurnOldPitch - gravityTurnPitch) * (gravityTurnAltitude - altitude) / (gravityTurnAltitude - gravityTurnOldAltitude).

    if gravityTurnCheckpoints:length > 1 {
      gravityTurnCheckpoints:remove(0).
      preserve.
    } else {
      when altitude > gravityTurnAltitude then {
        hudText("Gravity turn complete.", 5, 2, 15, yellow, true).
        lock pitch to gravityTurnPitch. 
      }
    }
  }
}
