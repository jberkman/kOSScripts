//
// mechanics.ks
// kOSScripts
//
// Created by jacob berkman on 2015-11-11.
// Copyright © 2015 jacob berkman
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@lazyglobal off.

run lib_navball.


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
//  print "E: " + E.
//  print "sin(E): " + sin(E).
//  print "ecc: " + orbit:eccentricity.
//  print "ecc * sinE: " + (orbit:eccentricity * sin(E)).
//  print "rad(E): " + rad(E).
//  print "bleh: " + (rad(E) - orbit:eccentricity * sin(E)).
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

function compassForDir {
  parameter ves.
  parameter dir.

  local east is east_for(ves).
  local vec is dir:forevector.

  local trig_x is vdot(ves:north:vector, vec).
  local trig_y is vdot(east, vec).

  local result is arctan2(trig_y, trig_x).

  //if result < 0 {
  //  print "result => " + result.
  //  return 360 + result.
  //} else {
    return result.
  //}
}

function pitchForDir {
  parameter ves.
  parameter dir.
  return 90 - vang(ves:up:vector, dir:forevector).
}

// Manouvres

function burnWithDeltaVAtTime {
  parameter deltaV.
  parameter t.
  parameter completion.

  global burnWithDeltaVAtTimeCompletion is completion.

  local burnRoll is roll_for(ship).
  local burnHeading is compass_for(ship).  
  lock burnPitch to -pitchForDir(ship, ship:prograde).
  print "pitch: " + burnPitch.

  lock throttle to 0.
  lock steering to r(0, 0, burnRoll) + heading(burnHeading, burnPitch).

  global circularizationPID is PIDLoop(5, 1, 5, 0, 1).
  set circularizationPID:setPoint to velocity:orbit:mag + deltaV.

  local maxAcceleration is ship:availableThrust / ship:mass.
  local burnDuration is deltaV / maxAcceleration.
  global burnStartTime is t - burnDuration / 2.
  global burnEndTime is t + burnDuration / 2.

  print "deltaV required for circularization: " + deltaV.
  print "estimated burn time: " + burnDuration.

  when time:seconds >= burnStartTime then {
    //circularizationPID:update(time:seconds, velocity:orbit:mag).
    lock throttle to 1.
    //circularizationPID:output.
    when time:seconds >= burnEndTime then {
      // - circularizationPID:lastSampleTime > 0.01 then {
      //circularizationPID:update(time:seconds, velocity:orbit:mag).
      //print circularizationPID:setPoint - velocity:orbit:mag.
      //if time:seconds < burnEndTime {
      //  preserve.
      //} else {
        lock throttle to 0.
        set burnWithDeltaVAtTimeCompletion[0] to true.
      //}
    }
  }
}

function burnAtPeriapsisToAltitude {
  parameter altitude.
  parameter completion.

  local initialVelocity is velocityOfOrbitalAtAltitude(ship, periapsis).
  local goalVelocity is velocityOfOrbitalAtAltitudeWithSemiMajorAxis(ship, periapsis, body:radius + (periapsis + altitude) / 2).

  burnWithDeltaVAtTime(goalVelocity - initialVelocity, time:seconds + timeToPeriapsisOfOrbit(obt), completion).
}

function burnAtApoapsisToAltitude {
  parameter altitude.
  parameter completion.

  local initialVelocity is velocityOfOrbitalAtAltitude(ship, apoapsis).
  local goalVelocity is velocityOfOrbitalAtAltitudeWithSemiMajorAxis(ship, apoapsis, body:radius + (apoapsis + altitude) / 2).

  print "goal velocity: " + goalVelocity.

  burnWithDeltaVAtTime(goalVelocity - initialVelocity, time:seconds + timeToApoapsisOfOrbit(obt), completion).
}