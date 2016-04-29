// lib_dd - Shared routines.
// Copyright © 2015 jacob berkman
// Portions (c) the KSLib team
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

global ddCfg is lexicon().

function clamp {
  parameter x, l, h.
  if x < l { return l. }
  if x > h { return h. }
  return x.
}

function compassForVec {
  parameter ves.
  parameter vec.

  local east is east_for(ves).

  local trig_x is vdot(ves:north:vector, vec).
  local trig_y is vdot(east, vec).

  local result is arctan2(trig_y, trig_x).

  if result < 0 {
    return 360 + result.
  } else {
    return result.
  }
}

function deltaVBurnTime {
  parameter dV.
  if ship:availableThrust = 0 {
    return 0.
  }
  return abs(dV * ship:mass / ship:availableThrust).
}

function east_for {
  parameter ves.
  return vcrs(ves:up:vector, ves:north:vector).
}

local loggedEvent is false.
function logLaunchEvent {
  parameter events.
  local fileName is ship:name + "-" + body:name + "-launch.csv".
  local fp is false.
  if archive:exists(fileName) {
    set fp to archive:open(fileName).
    if loggedEvent {
      fp:write(",").
    } else {
      fp:writeln("").
      set loggedEvent to true.
    }
  } else {
    set fp to archive:create(fileName).
  }
  fp:write(events:join(",")).
}

local tMET is time:seconds.

function mprint {
  parameter args.
  local t is round(time:seconds - tMET).
  if t > 0 {
    set t to "+" + t.
  } else if t = 0 {
    set t to "-" + t.
  }
  print "[T" + t + " " + round(ship:altitude / 1000, 1) + "km] " + args.
}

function pitchForVec {
  parameter ves.
  parameter vec.
  return 90 - vang(ves:up:vector, vec).
}

function setMET {
  parameter newValue.
  set tMET to newValue.
}

function stageDeltaV {
  local ispNum is 0.
  local ispDenum is 0.
  local engList is 0.
  list engines in engList.
  for eng in engList {
    if eng:ignition and not eng:flameout {
      set ispNum to ispNum + eng:availableThrust.
      set ispDenum to ispDenum + eng:availableThrust / eng:isp.
    }
  }
  if ispDenum = 0 {
    return 0.
  }
  local fuelMass is 0.
  local resources is stage:resourcesLex.
  for fuel in list("LiquidFuel", "Oxidizer") {
    if resources:hasKey(fuel) {
      local resource is resources[fuel].
      set fuelMass to fuelMass + resource:amount * resource:density.
    }
  }
  return 9.81 * ispNum * ln(mass / (mass - fuelMass)) / ispDenum.
}

function steerToDir {
  wait until vAng(steering:vector, ship:facing:vector) < 5.
}

function steerToVec {
  wait until vAng(steering, ship:facing:vector) < 5.
}

function unionLex {
  parameter lhs, rhs.
  for key in rhs:keys {
    set lhs[key] to rhs[key].
  }
}

for file in list("dd.cfg", shipName + ".cfg", shipName + "-" + body:name + ".cfg") {
  if exists(file) {
    unionLex(ddCfg, readJSON(file)).
  }
}
