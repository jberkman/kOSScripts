// bootDunaDirect.ks - Initialize CPU.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "Initializing CPU.".

for file in list("apoapsisBurn.ks",
  "descentBurn.ks",
  "gravityTurn.ks",
  "launch.ks",
  "launchAndRendezvous.ks",
  "launchMunShot.ks",
  "lib_navball.ks",
  "manoeuvre.ks",
  "manoeuvreNode.ks",
  "mechanics.ks",
  "periapsisBurn.ks",
  "rendezvous.ks") {
    copy file from archive.
}
