// launch.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

set ship:control:pilotmainthrottle to 0.

run gravityTurn.

function coastThrottle {
  if apoapsis > coastPID:setPoint {
    return 0.
  }
  return coastPID:update(time:seconds, apoapsis).
}

launchWithGravityTurnCheckpoints(list(
  list(14, 67.5),
  list(6, 45),
  list(2.8, 22.5),
  list(2, 0)
)).

wait until apoapsis > body:atm:height + 1000.

hudText("Initiating coast.", 5, 2, 15, yellow, true).
global coastPID to PIDLoop(0.05, 0.01, 0.05, 0, 1).
set coastPID:setPoint to body:atm:height + 10000.
lock throttle to coastThrottle().

wait until altitude > body:atm:height.

run manoeuvre.
burnAtApoapsisToAltitude(apoapsis).

hudText("Launch complete.", 5, 2, 15, yellow, true).
