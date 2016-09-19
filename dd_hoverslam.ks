// dd_hoverslam.ks - Perform descent burn.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run lib_dd.

clearScreen.
clearVecDraws().

print "DunaDirect HoverSlam! v0.1".
print "  grav:". // 1
print "   acc:". // 2
print "  drag:". // 3
print "thrust:". // 4
print " ".
print " accel:". // 6
print " ".
print "   vel:". // 8
print "burn t:". // 9
print " ".
print "height:". // 11
print " to go:". // 12

local printRow is 0.
local printCol is 8.

local drawVecs is false.
local o is v(0, 0, 0).
local vecGrav is vecDrawArgs(o, o, yellow, "Gravity", 1, drawVecs).
local vecDrag is vecDrawArgs(o, o, red,    "Drag",    1, drawVecs).
local vecThrust is vecDrawArgs(o, o, cyan, "Thrust",  1, drawVecs).
local vecAccel is vecDrawArgs(o, o, green, "Accel",   1, drawVecs).

function upPitch {
  parameter burnHeading.
  if burnHeading < 180 {
    return -45.
  }
  return 45.
}

function steeringDir {
  local burnHeading is compassForVec(ship, ship:srfRetrograde:vector).
  local burnPitch is 90 - 2 * vang(up:vector, ship:srfRetrograde:vector).
  local burnUp is heading(90, upPitch(burnHeading)).
  return lookDirUp(heading(burnHeading, burnPitch):vector, burnUp:vector).  
}

lock steering to steeringDir().

local lock landed to status = "LANDED" or status = "SPLASHED".
local togo is alt:radar.

local gModifier is 1.
local tBuffer is 1.
local vFinal is 0.
local hOffset is 0.

until togo < -ship:verticalSpeed / 100 {
  local grav is ship:body:mu / ((gModifier * ship:altitude + ship:body:radius) ^ 2).
  local a is ship:sensors:acc.
  local a_up is vdot(up:vector, a).
  local drag is grav + a_up.
  local thrust is ship:availableThrust / ship:mass.

  local accel_vec is a + thrust * ship:facing:vector.
  //local accel_vec is thrust * ship:facing:vector - grav * up:vector.
  local accel is accel_vec:mag.

  local burnT is airspeed / accel + tBuffer.

  local height is vFinal * burnT + accel * (burnT ^ 2) / 2 - hOffset.
  set togo to alt:radar - height.

  print round(grav, 3)   + " m/s^2      " at (printCol, printRow + 1).
  print round(a_up, 3)   + " m/s^2      " at (printCol, printRow + 2).
  print round(drag, 3)   + " m/s^2      " at (printCol, printRow + 3).
  print round(thrust, 3) + " m/s^2      " at (printCol, printRow + 4).

  print round(accel, 3)  + " m/s^2      " at (printCol, printRow + 6).

  print round(airspeed, 3) + " m/s      " at (printCol, printRow + 8).
  print round(burnT, 3)  + " s          " at (printCol, printRow + 9).

  print round(height, 3) + " m          " at (printCol, printRow + 11).
  print round(togo, 3) +   " m          " at (printCol, printRow + 12).

  set vecGrav:vec to -grav * up:vector.
  set vecDrag:vec to drag * up:vector.
  set vecThrust:vec to thrust * ship:facing:vector.
  set vecAccel:vec to accel_vec.

  wait 0.001.
  set togo to alt:radar - height.
}

print "vspeed: " + -ship:verticalSpeed / 100.

local burnStart is time:seconds.
local altStart is alt:radar.

lock throttle to 1.

wait until verticalSpeed > -vFinal.

local burnEnd is time:seconds.
local altEnd is alt:radar.

print "burn time: " + round(burnEnd - burnStart, 3) + " s".
print "burn dist: " + round(altEnd - altStart, 3) + " m".
print "   height: " + round(alt:radar, 3) + " m".

local burnPID to pidLoop(0.02, 0.05, 0.05, 0, 1).
set burnPID:setPoint to -4.

lock throttle to burnPID:update(time:seconds, verticalSpeed).
wait until status = "LANDED" or status = "SPLASHED".

lock throttle to 0.

unlock steering.
unlock throttle.
sas on.
print "Landing complete.".
