// dd_navigate - DunaDirect Orbit and Navigation.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").

function transfer {
	local menus is lex().
	local transferBody is false.
	function addBody {
		parameter include.
		for body in bodies {
			if include(body) { menus:add(body:name, { set transferBody to body. }). }
		}
	}
	addBody({
		parameter i.
		return i <> Sun and i:obt:body = body.
	}).
	if body <> Sun {
		addBody({
			parameter i.
			return i <> body and i <> Sun and i:obt:body = body:obt:body.
		}).
		addBody({
			parameter i.
			return i = body:obt:body.
		}).
	}
	local cancel is false.
	menus:add("Cancel", { set cancel to true. }).
	until cancel or transferBody <> false { menu("Select Destination", menus). }
	if cancel { return. }

	if transferBody:obt:body = body {
		// 1. Calculate change in true anomaly + time of flight
		local rA is obt:semiMajorAxis.
		local rB is transferBody:obt:semiMajorAxis.
		local aTX is (obt:semiMajoraxis + transferBody:obt:semiMajorAxis) / 2.

		local e is 1 - rA / aTX.
		local v is arccos((aTX * (1 - e ^ 2) / rB - 1) / e).
	}
}

function setSemiMajorAxis {
	parameter label, otherHeight, getETA.
	local height is getAltitude(label, otherHeight).
	if height <> "NaN" { semiMajorAxisBurn(height, otherHeight, getETA). }
}

local exit is false.
until exit {
    local menus is lex().
    if career():canMakeNodes {
        menus:add("Transfer", transfer@).
    }
    menus:add("Apoapsis: " + round(apoapsis / 1000, 3) + " km", {
        setSemiMajorAxis("Apoapsis", periapsis, { return eta:periapsis. }).
    }).
    menus:add("Periapsis: " + round(periapsis / 1000, 3) + " km", {
        setSemiMajorAxis("Periapsis", apoapsis, { return eta:apoapsis. }).
    }).
    //menus:add("Inclination: " + round(ship:obt:inclination, 2) + " deg", setInclination@).
    if hasNode { menus:add("Perform Manouevre Burn", { runSubcommand("dd_node_burn"). }). }
    menus:add("Done", { set exit to true. }).
 	menu("DunaDirect Orbit and Navigation! v0.1", menus).
}
