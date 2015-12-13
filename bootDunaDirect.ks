// bootDunaDirect.ks - Initialize CPU.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

print "Initializing CPU.".

for file in list(
  "libDunaDirect.ks",
  "ddApoapsisBurn.ks",
  "ddBurnFromAltitudeToAltitudeAtTime.ks",
  "ddCoastToAltitude.ks",
  "ddDescentBurn.ks",
  "ddGravityTurn.ks",
  "ddLand.ks",
  "ddLaunch.ks",
  "ddLaunchAndRendezvous.ks",
  "ddLaunchInclined.ks",
  "ddLaunchMunShot.ks",
  "ddManoeuvreNode.ks",
  "ddPeriapsisBurn.ks",
  "ddPolarLaunch.ks",
  "ddRendezvous.ks",
  "ddSuicideBurn.ks") {
    copy file from archive.
}
