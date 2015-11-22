// bootLaunchAndRendezvous.ks - Prepare for direct ascent rendezvous.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "Initializing direct ascent CPU.".
for file in list("launchAndRendezvous", "gravityTurn", "launch", "lib_navball", "navball", "rendezvous", "manoeuvreNode") {
  copy file from archive.
}
