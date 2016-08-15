// boot_ddall - Initialize CPU for everything.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.
copyPath("0:/dd_install", "").
run dd_install(list("launch", "dock", "land", "node")).
