// ddDock.ks - Dock with target.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter shipPortTag, targetPortTag.

run ddStabilize.

local shipPort is ship:partsTagged(shipPortTag)[0].
local targetPort is target:partsTagged(targetPortTag)[0].

local debug is false.

if debug {
  clearscreen.
  clearvecdraws().
  //     0         1         2         3         4         5         6
  //     0123456789012345678901234567890123456789012345678901234567890123456789
  print "          yaw       pitch     roll".
  print "  offset:".
  print "velocity:".
  print " control:".
  print " ".
  print "          star(x)   top(y)    fore(z)".
  print "  offset:".
  print "    goal:".
  print "velocity:".
  print " control:".
}

local control is ship:control.
set control:rotation to v(0, 0, 0).

local lock yawVel to vdot(angularVel, shipPort:portFacing:topVector).
local lock pitchVel to -vdot(angularVel, shipPort:portFacing:starVector).
local lock rollVel to -vdot(angularVel, shipPort:portFacing:foreVector).

// These are the directions we want to face in order to line up
// with the target docking port.
local lock yawOff to 90 * vdot(targetPort:portFacing:foreVector, shipPort:portFacing:starVector).
local lock pitchOff to 90 * vdot(targetPort:portFacing:foreVector, shipPort:portFacing:topVector).
//local lock rollOff to 90 * vdot(targetPort:portFacing:topVector, shipPort:portFacing:foreVector).

local yawPID is PIDLoop(0.25, 0.01, 0.1, -1, 1).
local pitchPID is PIDLoop(0.25, 0.01, 0.1, -1, 1).
local rollPID is PIDLoop(0.25, 0.01, 0.1, -1, 1).

// Waypoints are used to avoid crashing into the target.
// Currently, we just use one in front of the docking port.
// TODO: add waypoint in an "arc" halfway between current
// location and current waypoint.
local waypoint is 0.
local waypointDistance is 50.
local lock tgtWaypoint to targetPort:portFacing:vector * waypointDistance + targetPort:nodePosition - shipPort:nodePosition.

// Distance we need to travel, in ship-facing (*not* port-facing!) coords.
local lock tgtRelWaypoint to ship:facing:inverse * tgtWaypoint.

// We want to limit our velocity (so that we don't use fuel the whole time).
// However, if we use just a scaled-normalized vector, directions that require
// a small delta will have the value be less than the RCS "flame-out".
// For small values, we allow a larger absolute value.

local maxVel is 10.
local function normalizeWaypoint {
  local pos is tgtRelWaypoint.
  local ret is tgtRelWaypoint:normalized * min(tgtWaypoint:mag / 10, maxVel).
  if pos:x < 0.5 {
    set ret:x to pos:x / 2.
  }
  if pos:y < 0.5 {
    set ret:y to pos:y / 2.
  }
  if pos:z < 0.5 {
    set ret:z to pos:z / 2.
  }
  return ret.
}
local lock tgtSetPoints to normalizeWaypoint().


local lock tgtVel to ship:velocity:orbit - target:velocity:orbit.
local lock tgtRelVel to ship:facing:inverse * tgtVel.

if debug {
  set velDraw to vecDraw(V(0, 0, 0), tgtVel, yellow, "Target Velocity", 1, true).
  set posDraw to vecDraw(V(0, 0, 0), tgtWaypoint, magenta, "Target Position", 1, true).

  set starDraw to vecDraw(v(0, 0, 0), shipPort:portFacing:upVector, green, "STAR", 1, true).
  set topDraw to vecDraw(v(0, 0, 0), shipPort:portFacing:topVector, blue, "UP", 1, true).
  set foreDraw to vecDraw(v(0, 0, 0), shipPort:portFacing:foreVector, red, "FORE", 1, true).
}

local starPID is PIDLoop(1, 0, 0.1, -1, 1).
local topPID is PIDLoop(1, 0, 0.1, -1, 1).
local forePID is PIDLoop(1, 0, 0.1, -1, 1).

print "Proceeding to waypoint #1.".
until waypoint = 1 and tgtWaypoint:mag < targetPort:acquireRange {
  set control:rotation to V(yawPID:update(time:seconds, yawOff), pitchPID:update(time:seconds, pitchOff), rollPID:update(time:seconds, rollVel)).

  if abs(pitchOff) < 5 and abs(yawOff) < 5 {
    local tgt is tgtSetPoints.
    rcs on.
    set starPID:setPoint to tgt:x.
    set topPID:setPoint to tgt:y.
    set forePID:setPoint to tgt:z.

    set control:translation to v(starPID:update(time:seconds, tgtRelVel:x), topPID:update(time:seconds, tgtRelVel:y), forePID:update(time:seconds, tgtRelVel:z)).

    if tgtWaypoint:mag < 0.25 and tgtVel:mag < 0.25 {
      if waypoint = 0 {
        set maxVel to 0.25.
        print "Performing docking approach.".
        lock tgtWaypoint to targetPort:nodePosition - shipPort:nodePosition.
      }
      set waypoint to waypoint + 1.
    }
  } else {
    rcs off.
    set control:translation to v(0, 0, 0).
  }

  if debug {
    print round(yawOff, 3) at(10, 1).
    print round(pitchOff, 3) at(20, 1).
    //print round(rollOff, 3) at (30, 1).

    print round(yawVel, 3) at(10, 2).
    print round(pitchVel, 3) at(20, 2).
    print round(rollVel, 3) at(30, 2).

    print round(control:yaw, 3) at(10, 3).
    print round(control:pitch, 3) at(20, 3).
    print round(control:roll, 3) at(30, 3).

    print round(tgtRelWaypoint:x, 2) at(10, 6).
    print round(tgtRelWaypoint:y, 2) at(20, 6).
    print round(tgtRelWaypoint:z, 2) at(30, 6).

    print round(tgtSetPoints:x, 2) at(10, 7).
    print round(tgtSetPoints:y, 2) at(20, 7).
    print round(tgtSetPoints:z, 2) at(30, 7).

    print round(tgtRelVel:x, 2) at(10, 8).
    print round(tgtRelVel:y, 2) at(20, 8).
    print round(tgtRelVel:z, 2) at(30, 8).

    print round(control:starboard, 2) at(10, 9).
    print round(control:top, 2) at(20, 9).
    print round(control:fore, 2) at(30, 9).

    set velDraw:start to shipPort:nodePosition.
    set posDraw:start to shipPort:nodePosition.
    set topDraw:start to shipPort:nodePosition.
    set starDraw:start to shipPort:nodePosition.
    set foreDraw:start to shipPort:nodePosition.

    set velDraw:vec to tgtVel * 10.
    set posDraw:vec to tgtWaypoint.

    set topDraw:vec to shipPort:portFacing:topVector * 5.
    set starDraw:vec to shipPort:portFacing:starVector * 5.
    set foreDraw:vec to shipPort:portFacing:foreVector * 5.
  }

  wait 0.01.
}

set control:neutralize to true.
rcs off.
if debug {
  clearvecdraws().
}
print "Docking complete.".
