// dd_navigate - DunaDirect Orbit and Navigation.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd_transfer").

function transferToSibling {
    parameter dest.
    clearScreen.

    local rA is obt:semiMajorAxis.
    local rB is dest:obt:semiMajorAxis.
    local aTX is (rA + rB) / 2.
    local tTX is constant:pi * sqrt(aTX ^ 3 / body:mu).

    local lower is 0.
    local upper is 1 / abs(1 / obt:period - 1 / dest:obt:period).
    local t is 0.
    local epsilon is 0.1 * constant:degToRad.
    local obtA is false.
    local obtB is false.
    local posA is false.
    local posB is false.
    until false {
        print "lower: " + lower + " upper: " + upper.
        set t to (lower + upper) / 2.

        set obtA to DDOrbit["at"](obt, t).
        set posA to obtA["position"](obtA).
        local xyA is posA:vec.
        set xyA:z to 0.

        set obtB to DDOrbit["at"](dest:obt, t + tTX).
        set posB to obtB["position"](obtB).
        local xyB is posB:vec.
        set xyB:z to 0.

        local curPhase is vang(xyA, xyB).
        print "t: " + round(t) + " phase: " + round(curPhase).
        if curPhase > 180.1 { set upper to t. }
        else if curPhase < 179.9 { set lower to t. }
        else { break. }
        wait 0.001.
    }

    local posA is obtA["position"](obtA).
    local posB is obtB["position"](obtB).
    print " ".
    print "obtA: " + obtA["trueAnomaly"].
    print "obtB: " + obtB["trueAnomaly"].
    print " ".
    print "posA: " + posA.
    print "posB: " + posB.
    print " ".

    local xfer is TransferOrbit(body, posA, posB, tTX).

    print 1 / 0.
}

function doTransfer {
	local menus is lex().
    local exit is false.
	local dest is false.
    function addBody {
        parameter body.
        menus:add(body:name, {
            set dest to body.
            set exit to true.
        }).        
    }
	function addBodies {
		parameter include.
		for body in bodies { if include(body) { addBody(body). } }
	}
	addBodies({
		parameter i.
		return i <> Sun and i:obt:body = body.
	}).
	if body <> Sun {
		addBodies({
			parameter i.
			return i <> body and i <> Sun and i:obt:body = body:obt:body.
		}).
		addBodies({
			parameter i.
			return i = body:obt:body.
		}).
	}
	local cancel is false.
	menus:add("Cancel", { set cancel to true. }).
	until cancel or exit { menu("Select dest", menus). }
	if cancel { return. }

	if dest:obt:body = body {
        transferToSibling(dest).
    }
    else { print 1/0. }
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
        menus:add("Transfer", doTransfer@).
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
