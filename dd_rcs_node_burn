// dd_rcs_node_burn - Perform manouevres with RCS thrusters.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

clearscreen.
print "DunaDirect RCS Manoeuvre! v0.9".

run once lib_dd.

local node is nextNode.
local originalVector to node:deltaV.
wait until node:eta < 60.

set warp to 0.
local topVector is ship:facing:topVector.
lock steering to lookdirup(node:deltaV, topVector).
wait until node:eta < 10.

until node:deltaV:mag < 0.1 or vdot(originalVector, node:deltaV) < 0 {
	unlock steering.
	rcs on.
	set ship:control:translation to V(0, 0, 1).
	wait 0.
	rcs off.
	lock steering to lookdirup(node:deltaV, topVector).
	wait 0.1.	
}

unlock steering.
unlock throttle.
print "Burn complete.".
