// dd_navigate - DunaDirect Orbit and Navigation.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").

function setSemiMajorAxis {
	parameter label, otherHeight, getETA.
	local exit is false.
	until exit {
		clearScreen.
		print "Set " + label.
		print " ".
		menu(lex(
			"Circular: " + round(otherHeight / 1000, 3) + " km", {
				semiMajorAxisBurn(ship:body:radius + otherHeight, otherHeight, getETA).
			},
			// "Significant", { },
			// "Resonant", { },
			"Custom", {
				clearScreen.
				print label + " height in km:".
				getScalar({
					parameter height.
					semiMajorAxisBurn(ship:body:radius + (1000 * height + otherHeight) / 2, otherHeight, getETA).
				}).
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
 		"Body: " + ship:body:name, { transfer(). },
 		"Apoapsis: " + round(ship:obt:apoapsis / 1000, 3) + " km", {
 			setSemiMajorAxis("Apoapsis", ship:obt:periapsis, { return eta:periapsis. }).
 		},
 		"Periapsis: " + round(ship:obt:periapsis / 1000, 3) + " km", {
 			setSemiMajorAxis("Periapsis", ship:obt:apoapsis, { return eta:apoapsis. }).
 		},
 		"Inclination: " + round(ship:obt:inclination, 2) + " deg", { setInclination(). },
 		"Done", { set exit to true. }
 	)).
}
