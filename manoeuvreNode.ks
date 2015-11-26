// manoeuvreNode.ks - Perform manouevres with or without nodes.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run mechanics.

local node is nextNode.
local topVector is ship:facing:topVector.

lock steering to lookdirup(node:deltaV, topVector).
print "Waiting until burn.".
wait until node:eta < estimatedBurnTimeWithDeltaV(node:deltaV:mag) / 2.

global burnPID to pidLoop(0.1, 0, 0, 0, 1).
lock throttle to burnPID:update(time:seconds, -node:deltaV:mag).

wait until node:deltaV:mag < 0.05.

unlock steering.
unlock throttle.

print "Burn complete.".
