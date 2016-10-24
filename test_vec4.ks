@lazyglobal off.
clearScreen.
clearVecDraws().

runOncePath("lib_dd").

local v0 is V(0, 0, 0).
local rVec is vecDraw(v0, v0, green, "Position", 1, true, 0.2).
local vVec is vecDraw(v0, v0, cyan, "Velocity", 1, true, 0.2).
local xVec is vecDraw(v0, v0, magenta, "Eccentricity", 1, true, 0.2).
local hVec is vecDraw(v0, v0, red, "H", 1, true, 0.2).
local nVec is vecDraw(v0, v0, blue, "N", 1, true, 0.2).

until false {
    local r is shipRawToSOIUniversal(moho:position, sun).
    local v is rawToUniversal(moho:obt:velocity:orbit).

    local h is vcrs(v, r).
    local n is vcrs(h, V(0, 1, 0)).

    local x is r * (v:mag ^ 2 - sun:mu / r:mag).
    local y is (r * v) * v.
    local e is (x - y) / sun:mu.

    set rVec:vec to r:normalized * 10.
    set vVec:start to rVec:vec.
    set vVec:vec to v:normalized * 10.    
    set xVec:vec to e:normalized * 10.
    set hVec:vec to h:normalized * 10.
    set nVec:vec to n:normalized * 10.

    local i is arccos(h:y / h:mag).

    local loan is arccos(n:x / n:mag).
    if n:y < 0 { set loan to 360 - loan. }

    local aop is arccos((n * e) / n:mag / e:mag).
    if e:z < 0 { set aop to 360 - aop. }

    print "i: " + round(i, 1) + " loan: " + round(loan, 1) + " aop: " + round(aop, 1).

    wait 1.
}
