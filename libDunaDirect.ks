// mechanics.ks - Orbital mechanics routines.
// Copyright © 2015 jacob berkman
// Portions (c) the KSLib team
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

function east_for {
  parameter ves.
  return vcrs(ves:up:vector, ves:north:vector).
}

function compassForVec {
  parameter ves.
  parameter vec.

  local east is east_for(ves).

  local trig_x is vdot(ves:north:vector, vec).
  local trig_y is vdot(east, vec).

  local result is arctan2(trig_y, trig_x).

  if result < 0 {
    return 360 + result.
  } else {
    return result.
  }
}

function pitchForVec {
  parameter ves.
  parameter vec.
  return 90 - vang(ves:up:vector, vec).
}

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

function timeToImpact {
  // s = ut + 1/2 * at^2
  // s = a / 2 * t ^ 2 + u * t
  // a/2 * t^2 + u*t - s = 0

  // a = g/2
  local a is body:mu / (2 * body:radius ^ 2).

  // b = u
  local b is -verticalSpeed.

  // c = -s
  local c is -alt:radar.

  return (-b + sqrt(b ^ 2 - 4 * a * c)) / (2 * a).
}

function suicideVelocityWithTime {
  parameter t.
  local a is body:mu / body:radius ^ 2.
  local ret is -verticalSpeed + a * t.
  return ret.
}

function suicideBurnDistance {
  local v is suicideVelocityWithTime(timeToImpact()).
  local t is estimatedBurnTimeWithDeltaV(v).
  local g is ship:availableThrust / ship:mass. // - body:mu / body:radius ^ 2.
  local d is g * t ^ 2 / 2.
  return d.
}

function estimatedBurnTimeWithDeltaV {
  parameter deltaV.
  return abs(deltaV * ship:mass / ship:availableThrust).
}