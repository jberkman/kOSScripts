// launch.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

run once lib_dd.

clearscreen.
print "DunaDirect Launch! v2.9".

// Parse options 
local undefined is "$UNDEFINED$".
parameter options is undefined.
if options <> undefined {
  unionLex(ddCfg, options).
}

local targetInclination is 0.
if ddCfg:hasKey("launch.inclination") {
  set targetInclination to ddCfg["launch.inclination"].
}

local launchAzimuth is arcsin(clamp(cos(targetInclination) / cos(ship:latitude), -1, 1)).
if targetInclination < 0 {
  set launchAzimuth to 180 - launchAzimuth.
}
if ddCfg:hasKey("launch.azimuth") {
  set launchAzimuth to ddCfg["launch.azimuth"].
}

local rendezvous is false.
if ddCfg:hasKey("launch.rendezvous") {
  set rendezvous to ddCfg["launch.rendezvous"].
}

local launchAltitude is body:atm:height + 10000.
if rendezvous {
	set launchAltitude to target:orbit:semiMajorAxis - body:radius.
}
if ddCfg:hasKey("launch.altitude") {
  set launchAltitude to ddCfg["launch.altitude"] * 1000.  
}

local pitchRate is 0.6.
if ddCfg:hasKey("launch.pitchRate") {
  set pitchRate to ddCfg["launch.pitchRate"].
}

print " ".
print "Launch Configuration:".
print "launch.rendezvous: " + rendezvous.
print "launch.altitude: " + round(launchAltitude / 1000, 3) + " km".
if body:atm:exists {
  print "launch.pitchRate: " + round(pitchRate, 3) + " deg/s".
}
if not ddCfg:hasKey("launch.azimuth") {
  print "launch.inclination: " + round(targetInclination, 3) + " deg".
}
print "launch.azimuth: " + round(launchAzimuth, 3) + " deg".
if not body:atm:exists {
  print " ".
}
if ddCfg:hasKey("launch.azimuth") {
  print " ".
}
print " ".
print " ".
logLaunchEvent(list(launchAzimuth, pitchRate)).

// Initialize and begin countdown.
set ship:control:pilotMainThrottle to 0.
sas on.
setMET(time:seconds).

if body:atm:exists {
  run lib_dd_launch(launchAltitude, launchAzimuth, pitchRate).
} else {
  // Wait to clear tower.
  local rollAlt is alt:radar + 60.
  lock throttle to 1.
  wait until alt:radar > rollAlt.
  sas off.
  // Pitch program.
  local tPitch is time:seconds.

  function launchPitch {
    if apoapsis < altitude + 1000 - alt:radar {
      return 67.5.
    }
    return 22.5.    
  }

  local lock lookAt to heading(launchAzimuth, launchPitch()).
  local lock lookUp to heading(launchAzimuth, -45).
  lock steering to lookDirUp(lookAt:vector, lookUp:vector).
  wait until apoapsis > launchAltitude.
}

lock throttle to 0.
logLaunchEvent(list(obt:inclination)).
local deltaV is stageDeltaV().
logLaunchEvent(list(deltaV)).
print "Launch complete. Remaining dV: " + deltaV.
