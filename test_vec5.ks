@lazyglobal off.
clearScreen.
clearVecDraws().

local v0 is V(0, 0, 0).
local r1 is vecDraw(v0, V(1, 0, 0), green, "r1", 10, true, 0.2).
local r2 is vecDraw(v0, r1:vec, cyan, "r2", 10, true, 0.2).
local h  is vecDraw(v0, v0, magenta, "Normal", 10, true, 0.2).

until false {
    set r2:vec to R(0, -5, 0) * r2:vec.
    set h:vec to vCrs(r1:vec, r2:vec).
    print "    " + V(0, 1, 0) * h:vec.
    wait 0.1.
}
