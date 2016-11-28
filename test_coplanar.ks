@lazyglobal off.
clearScreen.
clearVecDraws().
runOncePath("lib_dd").

local src is mun.
set src to kerbin.
local dst is minmus.
set dst to moho.
set dst to eeloo.

local origin is V(0, 0, 0).
local munVec is vecDraw(origin, origin, red, "SRC", 1, true, 0.2).
local minmusVec is vecDraw(origin, origin, yellow, "DST", 1, true, 0.2).
local normalVec is vecDraw(origin, origin, green, "Normal", 1, true, 0.2).
local planarVec is vecDraw(origin, origin, blue, "Planar", 1, true, 0.2).
local tangentVec is vecDraw(origin, origin, cyan, "Tangent", 1, true, 0.2).

set munVec:vec to 10 * (src:position - src:body:position):normalized.
set minmusVec:vec to 10 * (dst:position - dst:body:position):normalized.
set normalVec:vec to 10 * obtNormalVec(src).
set planarVec:vec to 10 * obtPlanarVec(src, dst:position - dst:body:position):normalized.
set tangentVec:vec to 10 * vCrs(normalVec:vec, planarVec:vec):normalized.

print vAng(planarVec:vec, minmusVec:vec).

