// dd_hoverslam.ks - Perform descent burn.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run lib_dd.

clearScreen.
clearVecDraws().

print "DunaDirect HoverSlam! v0.1".
print "  grav:". // 1
print "thrust:". // 2
print " ".
print "goal a:". // 4
print "throtl:". // 5

local printRow is 0.
local printCol is 8.

local drawVecs is false.
local o is v(0, 0, 0).
local vecGrav is vecDrawArgs(o, o, yellow, "Gravity", 1, drawVecs).
local vecDrag is vecDrawArgs(o, o, red,    "Goal",    1, drawVecs).
local vecThrust is vecDrawArgs(o, o, cyan, "Thrust",  1, drawVecs).
local vecAccel is vecDrawArgs(o, o, green, "NonThrust",   1, drawVecs).

function steeringDir {
  local burnHeading is compassForVec(ship, ship:srfRetrograde:vector).
  local burnPitch is 90 - 2 * vang(up:vector, ship:srfRetrograde:vector).
  local upHeading is 0.
  local upPitch is 0.

  if burnPitch > 0 {
    set upHeading to 90.
    if burnHeading < 180 {
      set upPitch to burnPitch - 90.
    } else {
      set upPitch to 90 - burnPitch.
    }
  } else {
    set upHeading to 270.
    if burnHeading < 180 {
      set upPitch to -90 - burnPitch.
    } else {
      set upPitch to 90 + burnPitch.
    }
  }

  return lookDirUp(heading(burnHeading, burnPitch):vector, heading(upHeading, upPitch):vector).  
}

lock steering to steeringDir().

local gModifier is 1.
local tBuffer is 1.
local hOffset is 14.5.
local timestep is 0.001.

local burnStart is false.
local altStart is false.

global throttleValue is 0.
lock throttle to throttleValue.

until status = "LANDED" or status = "SPLASHED" {
  local grav is ship:body:mu / ((gModifier * ship:altitude + ship:body:radius) ^ 2).
  local thrust is ship:availableThrust / ship:mass.

  // v = at
  // t = v / a
  // d = at^2 / 2
  // d = a/2 * (v^2 / a^2)
  // d = v^2 / 2a
  // a = v^2 / 2d
  local goal is (2 + ship:airspeed) ^ 2 / (alt:radar - hOffset) / 2.
  local throttleDot is (goal + grav) / thrust.

  print round(grav, 3)   + " m/s^2      " at (printCol, printRow + 1).
  print round(thrust, 3) + " m/s^2      " at (printCol, printRow + 2).

  print round(goal, 3) + " m/s^2     " at (printCol, printRow + 4).
  print round(throttleDot * 100, 3) + " %         " at (printCol, printRow + 5).

  set vecGrav:vec to -grav * up:vector.
  set vecThrust:vec to thrust * ship:facing:vector.

  if burnStart = false and throttleDot > 0.95 {
    set burnStart to time:seconds.
    set altStart to alt:radar.
  }

  if burnStart <> false {
    if throttleDot > 2 / 3 {
      set throttleValue to throttleDot.
    } else {
      set throttleValue to 2 * throttleDot / 3.
    }
  }

  wait timestep.
}

lock throttle to 0.

print "burn time: " + round(time:seconds - burnStart, 3) + " s".
print "burn dist: " + round(alt:radar - altStart, 3) + " m".

unlock steering.
unlock throttle.
sas on.
print "Landing complete.".
