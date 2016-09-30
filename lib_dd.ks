// lib_dd - Shared routines.
// Copyright © 2015 jacob berkman
// Portions (c) the KSLib team
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

global bodies is list(Sun, Moho, Eve, Gilly, Kerbin, Mun, Minmus, Duna, Ike, Jool, Laythe, Vall, Tylo, Bop, Pol, Eeloo).

function altitudeForPeriod {
  parameter body, t.
  return (body:mu / 4 * (t / constant:pi) ^ 2) ^ (1 / 3) - body:radius.
}

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
  if ship:availableThrust = 0 { return 0. }
  return abs(dV * mass / ship:availableThrust).
}

function east_for {
  parameter ves.
  return vcrs(ves:up:vector, ves:north:vector).
}

function getAltitude {
  parameter label, otherHeight is -1.

  local parkingAlt is 10000 + body:atm:height.
  local semiAlt is altitudeForPeriod(body, body:rotationPeriod / 2).
  local syncAlt is altitudeForPeriod(body, body:rotationPeriod).

  local doneSemi is false.
  local doneSync is false.

  local ret is false.

  function addSemi {
    menus:add("Semi-Synchronous: " + round(semiAlt / 1000) + " km", { set ret to semiAlt. }).
    set doneSemi to true.
  }

  function addSync {
    menus:add("Synchronous: " + round(syncAlt / 1000) + " km", { set ret to syncAlt. }).
    set doneSync to true.
  }

  local menus is lex().
  if otherHeight > 0 {
    menus:add("Circular: " + round(otherHeight / 1000) + " km", { set ret to otherHeight. }).
  }
  menus:add("Parking: " + round(parkingAlt / 1000) + " km", { set ret to parkingAlt. }).
  for sib in bodies {
    if sib <> Sun and sib:body = body {
      local sibAlt is sib:obt:semiMajorAxis - sib:body:radius.
      if not doneSemi and sibAlt > semiAlt { addSemi(). }
      if not doneSync and sibAlt > syncAlt { addSync(). }
      menus:add(sib:name + ": " + round(sibAlt / 1000) + " km", { set ret to sibAlt. }).
    }
  }

  local SOIAlt is body:SOIRadius - body:radius.
  if not doneSemi and semiAlt < SOIAlt { addSemi(). }
  if not doneSync and syncAlt < SOIAlt { addSync(). }

  //menus:add("Resonant", { }).
  menus:add("Custom", {
    clearScreen.
    print "Enter Altitude in km:".
    print " ".
    local value is getScalar().
    if value <> "NaN" { set ret to value * 1000. }
  }).
  menus:add("Cancel", { set ret to "NaN". }).

  until ret <> false { menu("Set " + label, menus). }
  return ret.
}

function getLine {
  local path is ".getLine.txt".
  deletePath(path).
  edit path.
  until exists(path) { wait 0.1. }
  local line is open(path):readAll.
  deletePath(path).
  if line:empty { return false. }
  return line:string.
}

function getScalar {
  local line is getLine().
  if line = false { return "NaN". }
  return parseScalar(line).
}

function install {
  parameter source.
  if core:currentVolume = archive or exists(source) { return. }
  local target is path(source):parent:segments:join("/").
  if not exists(target) { createDir(target). }
  copyPath("0:/" + source, target).
}

function menu {
  parameter title, menuItems.
  //runLibGUIBox().

  local path is ".getLine.txt".
  deletePath(path).
  edit path.

  clearScreen.
  local maxLine is title:length.
  print title at(2, 1).

  local i is 1.
  for item in menuItems:keys {
    local line is i + ". " + item.
    print line at(2, i + 2).
    set maxLine to max(maxLine, line:length).
    set i to i + 1.  
  }

  //draw_gui_box(0, 0, maxLine + 4, menuItems:length + 4).
  //draw_gui_box(0, 2, maxLine + 4, 1).

  until exists(path) { wait 0.1. }
  local choice is open(path):readAll.
  deletePath(path).
  if choice:empty { return false. }
  set choice to parseScalar(choice:string).
  if choice = "NaN" or choice < 1 or choice > menuItems:length { return false. }
  return menuItems:values[choice - 1]().
}

function norRad {
    parameter n.
    local twoPi is 2 * constant():pi.
    if n < 0 { return mod(n, twoPi) + twoPi. }
    if n >= twoPi { return mod(n, twoPi). }
    return n.
}

function orbitalVelocity {
  parameter orbitable.
  parameter altitude.
  parameter a is orbitable:obt:semiMajorAxis.
  local r is altitude + orbitable:body:radius.
  return sqrt(orbitable:body:mu * (2 / r - 1 / a)).  
}

local digits is lex("0", 0, "1", 1, "2", 2, "3", 3, "4", 4, "5", 5, "6", 6, "7", 7, "8", 8, "9", 9).
function parseScalar {
  parameter s.
  if s:length = 0 { return "NaN". }

  local negative is s[0] = "-".
  if negative {
    set s to s:sublist(1, length).
  }

  local value is 0.
  local decimal is false.
  local decimalDigits is 0.

  for c in s:split(""):sublist(1, s:length) {
    if digits:hasKey(c) {
      if decimal { set decimalDigits to decimalDigits + 1. }
      set value to value * 10 + digits[c].
    } else if c = "." and not decimal {
      set decimal to true.
    } else {
      break.
    }
  }
  return value / (10 ^ decimalDigits).
}

function pitchForVec {
  parameter ves.
  parameter vec.
  return 90 - vang(ves:up:vector, vec).
}

function runLibGUIBox {
  install("KSLib/library/lib_gui_box").
  install("KSLib/library_ksm/spec_char").
  cd("KSLib/library_ksm").
  runOncePath("../library/lib_gui_box").
  cd().
}

function runSubcommand {
  parameter subcommand.
  install(subcommand).
  runPath(subcommand).
}

function semiMajorAxisBurn {
  parameter goalAltitude, burnAltitude, getETA.
  local lock burnTime to time:seconds + getETA().

  local goalSMA is body:radius + (goalAltitude + burnAltitude) / 2.
  local deltaV is orbitalVelocity(ship, burnAltitude, goalSMA).
  set deltaV to deltaV - orbitalVelocity(ship, burnAltitude).

  local burnDuration is deltaVBurnTime(abs(deltaV)).
  lock burnStartTime to burnTime - burnDuration / 2.

  wait until time:seconds >= burnStartTime - 60.
  set warp to 0.
  lock burnVector to prograde:foreVector.
  if deltaV < 0 { lock burnVector to retrograde:foreVector. }
  lock burnPitch to -pitchForVec(ship, burnVector).
  lock burnHeading to compassForVec(ship, burnVector).
  lock steering to lookdirup(heading(burnHeading, burnPitch):vector, heading(burnHeading, -45):vector).

  wait until time:seconds >= burnStartTime.
  steerToDir().
  lock throttle to 1.

  if deltaV > 0 { wait until obt:semiMajorAxis >= goalSMA. }
  else { wait until obt:eccentricity < 1 and obt:semiMajorAxis <= goalSMA. }

  lock throttle to 0.
  unlock steering.
  unlock throttle.
  set ship:control:pilotMainThrottle to 0.
}

function steerToDir {
  wait until vAng(steering:vector, facing:vector) < 5.
}

function steerToVec {
  wait until vAng(steering, facing:vector) < 5.
}
