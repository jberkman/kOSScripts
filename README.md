# kOSScripts
Scripts for [kOS](https://github.com/KSP-KOS/KOS) - as seen on [DunaQuest](http://dunadirect.com)!

## About

These scripts are my attempt to automate repetitive tasks in KSP as real space programs do. See below for supported commands.

## Installation

1. Copy the scripts into your `$KSP/Ships/Script` folder.
2. Configure your kOS processer with the appropriate boot script, depending on storage availability and mission requirements.

### boot_dd_05k

Required storage: 5000

Supported commands:

1. `dd_launch(<inclination>)`
  
  Launches the vessel into a parking orbit - 10km for non-atmospheric bodies, and about 10km above the atmosphere for atomspheric bodies.
  
  An optional (approximate) inclination can be specified in degrees. 90 launches to the north, -90 (or 270) launches to the south.
  
  Most staging is performed automatically, although boosters may not be automatically staged.
  
  See the [Duna Launch System](http://www.dunadirect.com/vab.html) for staging parameters and reference designs.

2. `dd_manual_burn([sourceAltitude], [targetAltitude], [timeForBurn])`
  
  Mainly a helper for circularization, but if you really need to do manual burns, this may be helpful.

### boot_dd_10k

Required storage: 10000

Additional commands:

1. `dd_descent_burn`
  
  Kill horizontal velocity in preparation for landing.

2. `dd_launch(<inclination>, <rendezvous>)`
  
  Same as above, but can now accept an optional rendezvous flag. If set to true, the vessel will attempt a direct-ascent rendezvous with the target vessel. Some experimentation may be necessary to determine the appropriate launch window.

3. `dd_land`
  
  Shortcut for performing a descent burn followed by a suicide burn.

4. `dd_node_burn`
  
  Executes the next manouevre node. Kills warp ~30 seconds before burning, for low values of warp.

5. `dd_suicide_burn`
  
  Attempt to land by performing a suicide burn. Not for the faint of heart, but it works.

### boot_dd_20k

Required storage: 20000

Additional commands:

1. `dd_dock([shipPortNameTag], [targetPortNameTag])`
  
  Attempts to dock with the target vessel, using the provided ports. The vessels do not need to have already performed a rendezvous, but they should be on an intercept trajectory.

2. `dd_rendezvous`

  Performs a rendezvous with the target vessel. The vessels should be on an intercept trajectory.
