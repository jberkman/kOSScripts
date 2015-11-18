// bootMunShot.ks - Prepare CPU for performing Mun shot.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "Initializing launch CPU.".
for file in list("munShot", "gravityTurn") {
  copy file from archive.
}
