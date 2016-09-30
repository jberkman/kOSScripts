// manoeuvreNode.ks - Perform manouevres with or without nodes.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").

clearscreen.
print "DunaDirect Manoeuvre! v1.1".

local node is nextNode.
print "Waiting for node...".
wait until node:eta < 60 + deltaVBurnTime(node:deltaV:mag) / 2.

set warp to 0.
lock steering to lookdirup(node:deltaV, -up:vector).
local originalVector is node:deltaV.
wait until node:eta < deltaVBurnTime(node:deltaV:mag) / 2.

lock throttle to 1.
wait until node:deltaV:mag < ship:availableThrust / mass / 2 or vdot(originalVector, node:deltaV) <= 0.

lock throttle to 0.2.
wait until vdot(originalVector, node:deltaV) <= 0.

lock throttle to 0.

unlock steering.
unlock throttle.
sas on.
print "Burn complete.".
