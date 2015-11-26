// gravityTurn.ks - Perform a gravity turn.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter checkpoints.
global gravityTurnCheckpoints to checkpoints.

print "Waiting for launch...".
lock throttle to 1.

wait until verticalSpeed > 10.

hudText("Initiating roll program.", 5, 2, 15, yellow, true).
global sourcePitch to 90.
global targetPitch to 90.
global sourceAltitude to 0.
global targetAltitude to 0.

lock pitch to targetPitch.
lock steering to lookdirup(heading(90, pitch):vector, heading(90, -45):vector).

when abs(facing:roll - 90) < 1 then {
  hudText("Roll program complete.", 5, 2, 15, yellow, true).
}

wait until verticalSpeed > 50.

when altitude > targetAltitude then {
  set sourcePitch to targetPitch.
  set targetPitch to gravityTurnCheckpoints[0][1].

  set sourceAltitude to targetAltitude.
  set targetAltitude to body:atm:height / gravityTurnCheckpoints[0][0].

  hudText("Pitching down => " + targetPitch + " @ " + targetAltitude, 5, 2, 15, yellow, true).
  lock pitch to targetPitch + (sourcePitch - targetPitch) * (targetAltitude - altitude) / (targetAltitude - sourceAltitude).

  if gravityTurnCheckpoints:length > 1 {
    gravityTurnCheckpoints:remove(0).
    preserve.
  } else {
    when altitude > targetAltitude then {
      hudText("Gravity turn complete.", 5, 2, 15, yellow, true).
      lock pitch to targetPitch. 
    }
  }
}
