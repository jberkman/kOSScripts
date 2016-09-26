// ddsh - DunaDirect Shell.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

set terminal:charwidth to 18.
set terminal:charheight to 18.
set terminal:width to 80.
set terminal:height to 24.

if core:currentVolume <> archive and not exists("lib_dd") {
	copyPath("0:/lib_dd", "").
}
runOncePath("lib_dd").

function uninstallPrograms {
	if path():volume = archive {
		return.
	}
	print "Resetting " + core:name + "." + core:currentVolume:name.
	local fileList is false.
	list files in fileList.
	for file in fileList {
		if file <> "ddsh.ks" {
			deletePath(file).
		}
	}	
}

until false {
	clearScreen.
	print "DunaDirect Shell! v0.1".
	print " ".
	menu(lex(
		"Launch",  { runSubcommand("dd_launch"). },
		"Orbit and Navigation", { runSubcommand("dd_navigate"). },
		"Rendezvous and Docking", { runSubcommand("dd_rendezvous"). },
		"Landing", { runSubcommand("dd_land"). },
		"Uninstall all programs", { uninstallPrograms(). },
		"Shut Down", { core:deactivate. }
	)).
}
