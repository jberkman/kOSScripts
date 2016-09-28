// dd_navigate - DunaDirect Orbit and Navigation.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd").

function setSemiMajorAxis {
	parameter label, otherHeight, getETA.
	local height is getAltitude(label, otherHeight).
	if height <> "NaN" { semiMajorAxisBurn(height, otherHeight, getETA). }
}

local exit is false.
until exit {
 	menu("DunaDirect Orbit and Navigation! v0.1", lex(
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
