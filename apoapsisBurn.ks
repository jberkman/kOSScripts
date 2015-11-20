// apoapsisBurn.ks - Perform a burn at apoapsis.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run manoeuvre.

parameter burnAltitude.
burnAtApoapsisToAltitude(burnAltitude).
