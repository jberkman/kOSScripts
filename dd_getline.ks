// dd_getline - DunaDirect Get Line.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

function getLine {
	local path is ".getLine.txt".
	deletePath(path).
	edit path.
	if not exists(path) {
		return false.
	}
	local line is open(path):readAll.
	deletePath(path).
	return line.
}
