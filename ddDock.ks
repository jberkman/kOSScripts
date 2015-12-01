// ddDock.ks - Dock with target.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

local lock targetRetrograde to r(0, 180, 0) * target:facing.

local lock goal to lookDirUp(targetRetrograde:vector, ship:facing:topVector).

unlock steering.
unlock throttle.

local pitchPID is PIDLoop(0.1, 0, 1, -1, 1).
local yawPID is PIDLoop(0.1, 0, 5, -1, 1).
local rollPID is PIDLoop(0.1, 0, 1, -1, 1).

local control to ship:control.

function relativeAngle {
  parameter angle.
  if angle > 180 {
    return angle - 360.
  }
  return angle.
}
local lock deltaPitch to relativeAngle(goal:pitch - ship:facing:pitch).
local lock deltaYaw to relativeAngle(goal:yaw - ship:facing:yaw).

local lock pitch to pitchPID:update(time:seconds, deltaPitch).
local lock yaw to yawPID:update(time:seconds, deltaYaw).

set control:pitch to pitch.
until abs(pitchPID:input) < 1 and ship:angularMomentum:mag < 0.01 {
  set control:pitch to pitch.
  print "pitch: " + round(deltaPitch) + ": " + control:pitch.
  wait 0.1.
}

set control:pitch to 0.
set control:yaw to yaw.
until abs(yawPID:input) < 1 {
  set control:yaw to yaw.
  print "yaw: " + round(yawPID:input) + " (" + control:yaw + ")".
  wait 0.2.
}

set control:yaw to 0.
print "Docking complete.".
