// manoeuvre.ks - Perform manouevres with or without nodes.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run mechanics.

function estimatedBurnTimeWithDeltaV {
  parameter deltaV.
  return abs(deltaV * ship:mass / ship:availableThrust).
}

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
    set burnHeading to compassForVec(ship, ship:prograde:forevector).
    lock burnPitch to -pitchForVec(ship, ship:prograde:forevector).
  } else {
    lock burnComplete to apoapsis + periapsis <= goalOrbit.
    set burnHeading to compassForVec(ship, ship:retrograde:forevector).
    lock burnPitch to -pitchForVec(ship, ship:retrograde:forevector).
  }

  lock steering to r(0, 0, burnRoll) + heading(burnHeading, burnPitch).
  lock burnStartTime to t - estimatedBurnTimeWithDeltaV(deltaV) / 2.

  print "deltaV required for circularization: " + round(abs(deltaV)).
  print "estimated burn time: " + round(2 * (t - burnStartTime)).

  lock throttle to 0.

  wait until time:seconds >= burnStartTime.
  lock throttle to 1.

  wait until burnComplete.

  unlock steering.
  unlock throttle.

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

function executeNextManoeuvreNode {
  local node is nextNode.
  local topVector is ship:facing:topVector.

  lock steering to lookdirup(node:deltaV, topVector).
  print "Waiting until burn.".
  wait until node:eta < estimatedBurnTimeWithDeltaV(node:deltaV:mag) / 2.

  global burnPID to pidLoop(0.1, 0, 0, 0, 1).
  lock throttle to burnPID:update(time:seconds, -node:deltaV:mag).

  wait until node:deltaV:mag < 0.05.

  unlock steering.
  unlock throttle.

  print "Burn complete.".
}

// ship:facing:inverted * mun:position.

function descentPitch {

}

function burnForDescent {
  local burnRoll is roll_for(ship).

  lock burnHeading to compassForVec(ship, ship:srfretrograde:forevector).
  lock burnPitch to 2 * pitchForVec(ship, ship:srfretrograde:forevector).

  lock steering to r(0, 0, burnRoll) + heading(burnHeading, burnPitch).
  lock throttle to 0.

  print "Wating for rotation.".
  wait until abs(compass_for(ship) - burnHeading) < 5 and abs(pitch_for(ship) - burnPitch) < 5.

  global burnPID to pidLoop(0.1, 0, 0, 0, 1).
  lock throttle to burnPID:update(time:seconds, -groundspeed).

  print "Waiting for surface velocity to reach 0.".
  wait until groundspeed < 0.25.

  lock burnPitch to 90 - 2 * vang(up:vector, ship:srfretrograde:vector).

  lock impactTime to timeToImpact().
  lock deltaV to suicideVelocityWithTime(impactTime).
  lock landed to status = "LANDED" or status = "SPLASHED".

  until landed {
    print "Waiting for burn...".
    lock throttle to 0.
    wait until landed or impactTime < ceiling(estimatedBurnTimeWithDeltaV(deltaV)).

    if landed {
      break.
    }

    print "Burning!".
    lock throttle to burnPID:update(time:seconds, verticalSpeed).
    wait until landed or abs(verticalSpeed) < 1.
  }

  unlock steering.
  unlock throttle.

  print "Burn complete.".
}
