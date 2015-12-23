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
  "ddDock.ks",
  "ddGravityTurn.ks",
  "ddLand.ks",
  "ddLaunch.ks",
  "ddLaunchAndRendezvous.ks",
  "ddLaunchAndRoll.ks",
  "ddLaunchInclined.ks",
  "ddLaunchMunShot.ks",
  "ddManoeuvreNode.ks",
  "ddPeriapsisBurn.ks",
  "ddPolarLaunch.ks",
  "ddRendezvous.ks",
  "ddStabilize.ks",
  "ddSuicideBurn.ks") {
    copy file from archive.
}
