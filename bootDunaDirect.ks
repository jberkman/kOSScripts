// bootDunaDirect.ks - Initialize CPU.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "Initializing CPU.".

for file in list(
  "libDunaDirect.ks",
  "ddBurnFromAltitudeToAltitudeAtTime.ks",
  "ddDescentBurn.ks",
  "ddDock.ks",
  "ddLand.ks",
  "ddLaunch.ks",
  "ddManoeuvreNode.ks",
  "ddRendezvous.ks",
  "ddStabilize.ks",
  "ddSuicideBurn.ks") {
    copy file from archive.
}
