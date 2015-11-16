// circularize.ks - Perform orbit circularization at apoapsis.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run manoeuvre.

print "Waiting to circularize until altitude: " + body:atm:height.
wait until altitude > body:atm:height.
burnAtApoapsisToAltitude(apoapsis).
