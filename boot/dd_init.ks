// dd_init - Install DunaDirect features.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "DunaDirect Install! v1.0".
parameter features is "$UNDEFINED$".

switch to core:volume.
if features = "reset" {
	print "Resetting " + core:name + "." + core:currentVolume:name.
	local fileList is false.
	list files in fileList.
	for file in fileList {
		if file <> "dd_init.ks" {
			deletePath(file).
		}
	}
	set core:bootFileName to "".
}

if features = "$UNDEFINED$" and status = "prelaunch" {
	local i is core:tag:find("[dd:").
	if i <> -1 {
		local j is core:tag:findAt("]", i + 5).
		if j <> -1 {
			set features to core:tag:substring(i + 4, j - i - 4).
		}
	}	
}

function install {
	parameter feature, files, label.
	if features = "$UNDEFINED$" {
		if feature <> true {
			print(feature + ": " + label).
		}
		return.
	}
	if feature <> true and not features:contains(feature) {
		return.
	}
	print "[" + label + "]".
	for file in files {
		if feature <> true or archive:exists(file) {
			copyPath("0:/" + file, "").
		}
	}
}

print("features:" + features).

install(true, list("lib_dd", "dd.cfg", shipName + ".cfg", shipName + "-" + body:name + ".cfg"), "common files").
install("launch", list("dd_launch.ks", "lib_dd_launch.ks"), "launch").
install("reorbit", list("lib_dd_launch"), "vacuum launch").
install("circularize", list("dd_circularize.ks"), "circularize").
install("dock", list("dd_rendezvous", "dd_dock"), "rendezvous and docking").
install("land", list("dd_land", "dd_descent_burn", "dd_suicide_burn"), "landing").
install("node", list("dd_node_burn.ks"), "manoeuvre nodes").
install("rendezvous", list("dd_rendezvous"), "rendezvous").
