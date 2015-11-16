// launch.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

function rollProgram {
  hudText("Initiating roll program.", 5, 2, 15, yellow, true).
  lock steering to r(0, 0, 180) + heading(90, 90).
  when abs(facing:roll - 90) < 1 then {
    hudText("Roll program complete.", 5, 2, 15, yellow, true).
  }
}

function initiateGravityTurn {
  global gravityTurnOldPitch to 90.
  global gravityTurnPitch to 90.
  global gravityTurnOldAltitude to 0.
  global gravityTurnAltitude to 0.

  global gravityTurnCheckpoints to list(
    list(14, 67.5),
    list(6, 45),
    list(2.8, 22.5),
    list(2, 0)
  ).

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
        lock pitch to 0. 
      }
    }
  }
}

function coastThrottle {
  if apoapsis > coastPID:setPoint {
    return 0.
  }
  return coastPID:update(time:seconds, apoapsis).
}

function initiateCoast {
  hudText("Initiating coast.", 5, 2, 15, yellow, true).
  global coastPID to PIDLoop(0.05, 0.01, 0.05, 0, 1).
  set coastPID:setPoint to body:atm:height + 10000.
  lock throttle to coastThrottle().
}

print "Waiting for launch...".
lock throttle to 1.
wait until velocity:surface:mag > 10.
rollProgram().

wait until velocity:surface:mag > 50.
initiateGravityTurn().

wait until apoapsis > body:atm:height + 1000.
initiateCoast().

wait until altitude > body:atm:height.

hudText("Launch complete.", 5, 2, 15, yellow, true).
