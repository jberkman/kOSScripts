// navball.ks - Navball utility functions.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run lib_navball.

function compassForVec {
  parameter ves.
  parameter vec.

  local east is east_for(ves).

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

function pitchForVec {
  parameter ves.
  parameter vec.
  return 90 - vang(ves:up:vector, vec).
}
