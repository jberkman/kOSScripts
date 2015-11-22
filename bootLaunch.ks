// bootLaunch.ks - Prepare CPU for performing launch.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "Initializing launch CPU.".
for file in list("launch", "gravityTurn", "manoeuvreNode") {
  copy file from archive.
}
