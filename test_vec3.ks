@lazyglobal off.
clearScreen.
clearVecDraws().

local v0 is V(0, 0, 0).
local proVec is vecDraw(v0, v0, green, "Prograde", 1, true, 0.2).
local radVec is vecDraw(v0, v0, cyan, "Radial", 1, true, 0.2).
local norVec is vecDraw(v0, v0, magenta, "Normal", 1, true, 0.2).

until false {
    local r1 is (body:position - sun:position):normalized.
    local r2 is (positionAt(kerbin, time + kerbin:obt:period * 0.25) - sun:position):normalized.
    local normal is vCrs(r2, r1).
    local prograde is vCrs(r1, normal):normalized.

    set radVec:vec to r1 * 10.
    set norVec:vec to normal * 10.    
    set ProVec:vec to prograde * 10.

    wait 1.
}
