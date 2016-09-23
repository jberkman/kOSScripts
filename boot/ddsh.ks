// ddsh - DunaDirect Shell.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

set terminal:charwidth to 24.
set terminal:charheight to 24.
set terminal:width to 80.
set terminal:height to 24.

function install {
	parameter script, runOnce is false.
	copyPath("0:/" + script, "").
	if runOnce {
		runOncePath(script).
	}
}
install("lib_dd", true).

function installPrograms {
	local installMenu is lex(
		"Launch", { install("dd_launch"). install("lib_dd_launch"). },
		"Circularize", { install("dd_circularize"). },
		"Execute manouvre node burn", { install("dd_node_burn"). },
		"Deorbit", { install("dd_deorbit"). },
		"Hoverslam", { install("dd_hoverslam"). },
		"Rendezvous", { install("dd_rendezvous"). },
		"Dock", { install("dd_rendezvous"). install("dd_dock"). },
		"Done", { }
	).
	wait until menu("Select Programs to Install", installMenu) = installMenu:length - 1.
}

function uninstallPrograms {
	print "Resetting " + core:name + "." + core:currentVolume:name.
	local fileList is false.
	list files in fileList.
	for file in fileList {
		if file <> "ddsh.ks" {
			deletePath(file).
		}
	}	
}

clearScreen.
print "DunaDirect Shell! v0.1".

local mainMenu is lex(
	"Launch", { runPath("dd_launch"). },
	"Circularize", { runPath("dd_circularize"). },
	"Execute manouvre node burn", { runPath("dd_node_burn"). },
	"Deorbit", { runPath("dd_deorbit"). },
	"Hoverslam", { runPath("dd_hoverslam"). },
	"Rendezvous", { runPath("dd_rendezvous"). },
	"Dock", { runPath("dd_dock"). },
	"Install programs", { installPrograms(). },
	"Uninstall all programs", { uninstallPrograms(). },
	"Exit", { }
).
wait until menu("Main Menu", mainMenu) = mainMenu:length - 1.
