// lib_dd - Shared routines.
// Copyright © 2015 jacob berkman
// Portions (c) the KSLib team
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

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

function getLine {
  local path is ".getLine.txt".
  deletePath(path).
  edit path.
  until exists(path) {
    wait 0.25.
  }
  local line is open(path):readAll.
  deletePath(path).
  if line:empty {
    return false.
  }
  return line:string.
}

function getScalar {
  parameter setFunc.
  local line is getLine().
  if line = false {
    return.
  }
  local scalar is parseScalar(line).
  if scalar = false {
    return.
  }
  setFunc(scalar).
}

function install {
  parameter script.
  if core:currentVolume <> archive and not exists(script) {
    copyPath("0:/" + script, "").
  }
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

function menu {
  parameter menuItems.
  from { local i is 0. } until i = menuItems:length step { set i to i + 1. } do {
    print " " + (i + 1) + ". " + menuItems:keys[i].
  }
  local line is getLine().
  if line = false {
    return false.
  }
  local choice is parseScalar(line) - 1.
  if choice < 0 or choice >= menuItems:length {
    return false.
  }
  return menuItems:values[choice]().
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

function parseScalar {
  parameter s.
  local value is 0.
  local negative is false.
  local decimal is false.
  local decimalDigits is 0.

  local parser is lex(
    "-", { set negative to true. parser:remove("-"). },
    ".", { set decimal to true.  parser:remove("."). },
    "0", { set value to value * 10. },
    "1", { set value to value * 10 + 1. },
    "2", { set value to value * 10 + 2. },
    "3", { set value to value * 10 + 3. },
    "4", { set value to value * 10 + 4. },
    "5", { set value to value * 10 + 5. },
    "6", { set value to value * 10 + 6. },
    "7", { set value to value * 10 + 7. },
    "8", { set value to value * 10 + 8. },
    "9", { set value to value * 10 + 9. }
  ).

  from { local i is 0. } until i = s:length step { set i to i + 1. } do {
    if not parser:hasKey(s[i]) {
      return value.
    }
    if decimalDigits > 0 {
      set decimalDigits to decimalDigits + 1.
    }
    parser[s[i]]().
  }
  return value / (10 ^ decimalDigits).
}

function pitchForVec {
  parameter ves.
  parameter vec.
  return 90 - vang(ves:up:vector, vec).
}

function runSubcommand {
  parameter subcommand.
  install(subcommand).
  runPath(subcommand).
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
