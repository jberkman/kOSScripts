@lazyglobal off.
clearScreen.
clearVecDraws().

runOncePath("lib_dd_orbit").

local vec is V(1, 0, 0).
local ang is 0.

local draw is vecDraw(V(0, 0, 0), vec * 10, green, "vec1", 1, true, 0.2).
vecDraw(V(0, 0, 0), vec * 10, yellow, "vec0", 1, true, 0.2).
local sObt is DDOrbit["withOrbit"](obt).

until ang > 360 {
  set draw:vec to vec * 10.
  local long is vecLong(vec).
  local v is sObt["trueAnomalyAtLongitude"](sObt, long).
	print "    ang: " + ang + "    long: " + long + "    v: " + v.
	set vec to R(0, -5, 0) * vec.
	set ang to ang + 5.
}
