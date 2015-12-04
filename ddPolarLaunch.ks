// ddPolarLaunch.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

set ship:control:pilotmainthrottle to 0.

run ddGravityTurn(0, list(
  list(14, 67.5),
  list(6, 45),
  list(2.8, 22.5),
  list(2, 0)
)).

run ddCoastToAltitude(body:atm:height + 10000).

run ddApoapsisBurn(apoapsis).

hudText("Launch complete.", 5, 2, 15, yellow, true).
