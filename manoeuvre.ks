// manoeuvre.ks - Perform manouevres without nodes.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run navball.
run mechanics.

function burnFromAtAltitudeToAltitudeAtTime {
  parameter sourceAltitude.
  parameter targetAltitude.
  parameter t.

  local goalOrbit to sourceAltitude + targetAltitude.
  local initialVelocity is velocityOfOrbitalAtAltitude(ship, sourceAltitude).
  local goalVelocity is velocityOfOrbitalAtAltitudeWithSemiMajorAxis(ship, sourceAltitude, body:radius + goalOrbit / 2).
  local deltaV to goalVelocity - initialVelocity.

  local burnRoll is roll_for(ship).
  local burnHeading is 0.

  if deltaV > 0 {
    lock burnComplete to apoapsis + periapsis >= goalOrbit.
    set burnHeading to compassForDir(ship, ship:prograde).
    lock burnPitch to -pitchForDir(ship, ship:prograde).
  } else {
    lock burnComplete to apoapsis + periapsis <= goalOrbit.
    set burnHeading to compassForDir(ship, ship:retrograde).
    lock burnPitch to -pitchForDir(ship, ship:retrograde).
  }

  lock steering to r(0, 0, burnRoll) + heading(burnHeading, burnPitch).
  lock burnStartTime to t - abs(deltaV * ship:mass / ship:availableThrust / 2).

  print "deltaV required for circularization: " + round(abs(deltaV)).
  print "estimated burn time: " + round(2 * (t - burnStartTime)).

  lock throttle to 0.

  wait until time:seconds >= burnStartTime.
  lock throttle to 1.

  wait until burnComplete.
  lock throttle to 0.
  set ship:control:pilotmainthrottle to 0.
  unlock steering.

  print "Burn complete.".
}

function burnAtPeriapsisToAltitude {
  parameter altitude.
  burnFromAtAltitudeToAltitudeAtTime(periapsis, altitude, time:seconds + timeToPeriapsisOfOrbit(obt)).
}

function burnAtApoapsisToAltitude {
  parameter altitude.
  burnFromAtAltitudeToAltitudeAtTime(apoapsis, altitude, time:seconds + timeToApoapsisOfOrbit(obt)).
}
