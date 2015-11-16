// bootCircularize.ks - Prepare CPU for performing launch.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "Initializing circularization CPU.".
for file in list("circularize", "lib_navball", "manoeuvre", "mechanics", "navball") {
  copy file from archive.
}
