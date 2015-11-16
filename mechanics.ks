// mechanics.ks - Orbital mechanics routines.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

function deg {
  parameter radians.
  return radians * constant:radToDeg.
}

function rad {
  parameter degrees.
  return degrees * constant:degToRad.
}

function velocityOfOrbitalAtAltitudeWithSemiMajorAxis {
  parameter orbitable.
  parameter altitude.
  parameter a.

  local r is altitude + orbitable:body:radius.

  return sqrt(orbitable:body:mu * ((2 / r) - (1 / a))).  
}

function velocityOfOrbitalAtAltitude {
  parameter orbitable.
  parameter altitude.
  return velocityOfOrbitalAtAltitudeWithSemiMajorAxis(orbitable, altitude, orbitable:obt:semiMajorAxis).
}

function velocityOfOrbital {
  parameter orbitable.
  return velocityOfOrbitalAtAltitudeWithSemiMajorAxis(orbitable, orbitable:altitude, orbitable:obt:semiMajorAxis).
}

function eccentricAnomalyOfOrbit {
  parameter orbit.

  local cosv is cos(orbit:trueAnomaly).
  local num is orbit:eccentricity + cosv.
  local denom is 1 + (orbit:eccentricity * cosv).
  local tmp is arccos(num / denom).
  if orbit:trueAnomaly < 180 {
    return tmp.
  }
  return 360 - tmp.
}

function meanAnomalyOfOrbit {
  parameter orbit.

  local E is eccentricAnomalyOfOrbit(orbit).
  return deg(rad(E) - orbit:eccentricity * sin(E)).
}

function meanMotionOfOrbit {
  parameter orbit.
  return sqrt(orbit:body:mu / (orbit:semiMajorAxis ^ 3)).
}

function timeOfOrbitToMeanAnomaly {
  parameter orbit.
  parameter meanAnomaly.

  local M is meanAnomalyOfOrbit(orbit).
  local dM is mod(meanAnomaly - M + 360, 360).

  return rad(dM) / meanMotionOfOrbit(orbit).
}

function timeToPeriapsisOfOrbit {
  parameter orbit.
  return timeOfOrbitToMeanAnomaly(orbit, 0).
}

function timeToApoapsisOfOrbit {
  parameter orbit.
  return timeOfOrbitToMeanAnomaly(orbit, 180).
}
