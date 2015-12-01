// ddCoastToAltitude.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter coastAltitude.

wait until apoapsis > coastAltitude.

hudText("Initiating coast.", 5, 2, 15, yellow, true).
local coastPID to PIDLoop(0.05, 0, 0.05, 0, 1).
lock throttle to coastPID:update(time:seconds, apoapsis - coastAltitude).

wait until altitude > body:atm:height.
lock throttle to 0.
