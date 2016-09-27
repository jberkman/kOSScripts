// dd_navigate - DunaDirect Orbit and Navigation.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").
install("KSLib/library/lib_enum", "KSLib/library").
runOncePath("KSLib/library/lib_enum").

function setSignificantOrbit {
	parameter label, otherHeight, getETA.

	local parkingAlt is 10000 + body:atm:height.
	local semiAlt is altitudeForPeriod(body, body:rotationPeriod / 2).
	local syncAlt is altitudeForPeriod(body, body:rotationPeriod).

	local doneSemi is false.
	local doneSync is false.

	local exit is false.

	function burn {
		parameter alt.
		semiMajorAxisBurn(alt, otherHeight, getETA).
		set exit to true.
	}

	function addSemi {
		menus:add("Semi-Synchronous: " + round(semiAlt / 1000) + " km", { burn(semiAlt). }).
		set doneSemi to true.
	}

	function addSync {
		menus:add("Synchronous: " + round(syncAlt / 1000) + " km", { burn(syncAlt). }).
		set doneSync to true.				
	}

	local menus is lex("Parking: " + round(parkingAlt / 1000) + " km", { burn(parkingAlt). }).
	for sib in allBodies {
		if sib <> Sun and sib:body = body {
			local sibAlt is sib:obt:semiMajorAxis - sib:body:radius.
			if not doneSemi and sibAlt > semiAlt { addSemi(). }
			if not doneSync and sibAlt > syncAlt { addSync(). }
			menus:add(sib:name + ": " + round(sibAlt / 1000) + " km", { burn(sibAlt). }).
		}
	}

	local SOIAlt is body:SOIRadius - body:radius.
	if not doneSemi and semiAlt < SOIAlt { addSemi(). }
	if not doneSync and syncAlt < SOIAlt { addSync(). }

	menus:add("Done", { set exit to true. }).

	until exit {
		clearScreen.
		print "Set " + label.
		print " ".
		menu(menus).
	}
}

function setSemiMajorAxis {
	parameter label, otherHeight, getETA.
	local exit is false.
	until exit {
		clearScreen.
		print "Set " + label.
		print " ".
		menu(lex(
			"Circular: " + round(otherHeight / 1000, 3) + " km", {
				semiMajorAxisBurn(otherHeight, otherHeight, getETA).
				set exit to true.
			},
			"Significant", {
				setSignificantOrbit(label, otherHeight, getETA).
				set exit to true.
			},
			// "Resonant", { },
			"Custom", {
				clearScreen.
				print label + " height in km:".
				local height is getScalar().
				if height <> "NaN" {
					semiMajorAxisBurn(1000 * height, otherHeight, getETA).
					set exit to true.
				}
			},
			"Done", { set exit to true. }
		)).
	}
}

local exit is false.
until exit {
	clearScreen.
 	print "DunaDirect Orbit and Navigation! v0.1".
 	print " ".
 	menu(lex(
 		"Body: " + body:name, { transfer(). },
 		"Apoapsis: " + round(apoapsis / 1000, 3) + " km", {
 			setSemiMajorAxis("Apoapsis", periapsis, { return eta:periapsis. }).
 		},
 		"Periapsis: " + round(periapsis / 1000, 3) + " km", {
 			setSemiMajorAxis("Periapsis", apoapsis, { return eta:apoapsis. }).
 		},
 		// "Inclination: " + round(ship:obt:inclination, 2) + " deg", { setInclination(). },
 		"Done", { set exit to true. }
 	)).
}
