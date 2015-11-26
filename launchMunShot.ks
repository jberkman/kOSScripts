// lanchMunShot.ks - Launch directly to a Mun encounter.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run gravityTurn(list(
  list(14, 67.5),
  list(6, 45)
)).

local mun is Body("Mun").
wait until apoapsis >= mun:altitude.

lock throttle to 0.
set ship:control:pilotmainthrottle to 0.
unlock steering.

hudText("Launch complete.", 5, 2, 15, yellow, true).
