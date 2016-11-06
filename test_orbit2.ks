clearScreen.
clearVecDraws().
runOncePath("lib_dd_orbit").

local sObt is DDOrbit["withOrbit"](obt).
local v is 0.
until v = 360 {
    local sObt2 is sObt["at"](sObt, v).
    local r is sObt2["position"](sObt2).
    vecDraw(V(0, 0, 0), r:normalized * 10, yellow, "r: " + v, 1, true, 0.2).
    set v to v + 5.
}
