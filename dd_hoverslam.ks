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
print " ".
print "goal a:". // 14
print "throtl:". // 15

local printRow is 0.
local printCol is 8.

local drawVecs is true.
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

local lock landed to status = "LANDED" or status = "SPLASHED".
local togo is alt:radar.

local gModifier is 1.
local tBuffer is 1.
local vFinal is 0.
local hOffset is 0.
local timestep is 0.01.

local burnStart is false.
local altStart is false.

local burnPID to pidLoop(0.01, 0.01, 0.5).
global midThrottle is 0.
global pidThrottle is 0.
//lock throttle to midThrottle + pidThrottle.
global throttleValue is 0.
lock throttle to throttleValue.

until status = "LANDED" or status = "SPLASHED" {
  local grav is ship:body:mu / ((gModifier * ship:altitude + ship:body:radius) ^ 2).
  local a is ship:sensors:acc.
  local a_up is vdot(up:vector, a).
  local drag is grav + a_up.
  local thrust is ship:availableThrust / ship:mass.

  local nonThrust is -grav * up:vector. //a - throttle * ship:availableThrust / ship:mass * ship:facing:vector.

  local accel_vec is a.
//  if burnStart = false {
//    set accel_vec to a + thrust * ship:facing:vector.
//  } else {
//    set accel_vec to a.
//  }
  local accel is vdot(ship:facing:vector, accel_vec).

  local burnT is airspeed / accel + tBuffer.

  local height is vFinal * burnT + accel * (burnT ^ 2) / 2 - hOffset.
  set togo to alt:radar - height.

//  local goalAcc is (2 + ship:airspeed) ^ 2 / 2 / (alt:radar - hOffset) * ship:srfRetrograde:vector.
//  local goal is vdot(ship:facing:vector, goalAcc).
//  local throttleVec is goalAcc - nonThrust.
//  local throttleDot is vdot(ship:facing:vector, throttleVec) / thrust.

  local goal is (2 + ship:airspeed) ^ 2 / (alt:radar - hOffset) / 2.

  print round(grav, 3)   + " m/s^2      " at (printCol, printRow + 1).
  print round(a_up, 3)   + " m/s^2      " at (printCol, printRow + 2).
  print round(drag, 3)   + " m/s^2      " at (printCol, printRow + 3).
  print round(thrust, 3) + " m/s^2      " at (printCol, printRow + 4).

//  print round(accel, 3)  + " m/s^2      " at (printCol, printRow + 6).

//  print round(airspeed, 3) + " m/s      " at (printCol, printRow + 8).
//  print round(burnT, 3)  + " s          " at (printCol, printRow + 9).

//  print round(height, 3) + " m          " at (printCol, printRow + 11).
//  print round(togo, 3) +   " m          " at (printCol, printRow + 12).

  print round(goal, 3) + " m/s^2     " at (printCol, printRow + 14).

  local throttleDot is (goal + grav) / thrust.
  print round(throttleDot * 100, 3) + " %         " at (printCol, printRow + 15).

  set vecGrav:vec to -grav * up:vector.
  //set vecDrag:vec to goalAcc.
  set vecThrust:vec to thrust * ship:facing:vector.
  //set vecAccel:vec to nonThrust.

  if burnStart = false and throttleDot > 0.95 {
    set burnStart to time:seconds.
    set altStart to alt:radar.
  }

  if burnStart <> false {
    if throttleDot > 0.75 {
      set throttleValue to throttleDot.
    } else {
      set throttleValue to throttleDot / 2.
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
