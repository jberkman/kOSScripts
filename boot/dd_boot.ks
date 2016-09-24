// dd_boot - Install and launch DunaDirect shell.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.
if core:currentVolume <> archive and not exists("ddsh") {
	copyPath("0:/ddsh", "").
}
runPath("ddsh").
