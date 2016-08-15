// boot_ddlch2 - Initialize CPU for launching w/ navigation.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.
copy dd_install from archive.
run dd_install(list("launch", "node")).
