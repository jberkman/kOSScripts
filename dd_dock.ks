// ddDock.ks - Dock with target.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

parameter shipPortTag, targetPortTag.

rcs off.
run dd_rendezvous(targetPortTag).

clearvecdraws().
print "DunaDirect Dock! v2.0".

local shipPort is ship:partsTagged(shipPortTag)[0].
shipPort:controlFrom().
global targetPort is target:partsTagged(targetPortTag)[0].

// Distance we need to travel, in ship-facing (*not* port-facing!) coords.
local lock tgtWaypoint to targetPort:nodePosition - shipPort:nodePosition.
local lock tgtRelWaypoint to facing:inverse * tgtWaypoint.

local lock tgtVel to velocity:orbit - target:velocity:orbit.
local lock tgtRelVel to facing:inverse * tgtVel.

local lock dockFacing to angleAxis(180, targetPort:portFacing:topVector) * targetPort:portFacing.

print "Aligning with docking port.".
lock steering to dockFacing.
steerToDir().

function translateControl {
  parameter d.
  parameter v.
  local targetV is 1.
  if abs(d) < 5 {
    set targetV to 0.1.
  } else if abs(d) < 20 {
    set targetV to 0.2.
  }
  if d > 0.1 {
    if v < 0.9 * targetV {
      return 1.
    } else if v > 1.1 * targetV {
      return -1.
    }
  } else if d < -0.1 {
    if v > -0.9 * targetV {
      return -1.
    } else if v < -1.1 * targetV {
      return 1.
    }
  } else if v > 0.025 {
    return -0.5.
  } else if v < -0.025 {
    return 0.5.
  }
  return 0.
}

print "Performing docking approach.".
until tgtWaypoint:mag < targetPort:acquireRange {
  local starControl is translateControl(tgtRelWaypoint:x, tgtRelVel:x).
  local topControl is translateControl(tgtRelWaypoint:y, tgtRelVel:y).
  local foreDistance is 0.
  if vAng(tgtWaypoint, dockFacing:vector) < 15 {
    set foreDistance to tgtRelWaypoint:z.
  }
  local foreControl is translateControl(foreDistance, tgtRelVel:z).
  if starControl <> 0 or topControl <> 0 or foreControl <> 0 {
//    if starControl <> 0 {
//      print "star: d: " + tgtRelWaypoint:x + " v: " + tgtRelVel:x + " -> ctrl: " + starControl.
//    }
//    if topControl <> 0 {
//      print "top: d: " + tgtRelWaypoint:y + " v: " + tgtRelVel:y + " -> ctrl: " + topControl.
//    }
//    if foreControl <> 0 {
//      print "fore: d: " + foreDistance + " v: " + tgtRelVel:z + " -> ctrl: " + foreControl.
//    }
    unlock steering.
    rcs on.
    set ship:control:translation to V(starControl, topControl, foreControl).
    wait 0.
    rcs off.
    lock steering to dockFacing.
    wait 0.15.
  } else {
    wait 0.
  }
}

//  local velDraw is vecDraw(V(0, 0, 0), tgtVel, yellow, "Target Velocity", 1, true).
//  local posDraw is vecDraw(V(0, 0, 0), tgtWaypoint, magenta, "Target Position", 1, true).

//  local starDraw is vecDraw(v(0, 0, 0), shipPort:portFacing:upVector, green, "STAR", 1, true).
//  local topDraw is vecDraw(v(0, 0, 0), shipPort:portFacing:topVector, blue, "UP", 1, true).
//  local foreDraw is vecDraw(v(0, 0, 0), shipPort:portFacing:foreVector, red, "FORE", 1, true).

clearvecdraws().

unlock steering.
unlock throttle.
set ship:control:neutralize to true.

print "Docking complete.".
