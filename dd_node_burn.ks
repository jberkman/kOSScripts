// manoeuvreNode.ks - Perform manouevres with or without nodes.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

clearscreen.
print "DunaDirect Manoeuvre! v1.0".

run once lib_dd.

local node is nextNode.
local originalVector to node:deltaV.
wait until node:eta < 60 + deltaVBurnTime(node:deltaV:mag) / 2.

set warp to 0.
local topVector is facing:topVector.
lock steering to lookdirup(node:deltaV, topVector).
wait until node:eta < deltaVBurnTime(node:deltaV:mag) / 2.

global burnPID to pidLoop(0.1, 0, 0, 0, 1).
lock throttle to burnPID:update(time:seconds, -node:deltaV:mag).
wait until node:deltaV:mag < 0.1 or vdot(originalVector, node:deltaV) < 0.

unlock steering.
unlock throttle.
print "Burn complete.".
