// periapsisBurn.ks - Perform a burn at periapsis.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run libDunaDirect.

parameter burnAltitude.
run ddBurnFromAltitudeToAltitudeAtTime(periapsis, burnAltitude, time:seconds + timeToPeriapsisOfOrbit(obt)).
