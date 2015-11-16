// countdown.ks - Launch into a parking suborbital trajectory.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

function countdown {
  hudText("Throttle up.", 5, 2, 15, yellow, true).
  lock throttle to 1.0.

  hudText("Initiating countdown.", 1, 2, 15, yellow, true).
  from {
    local tMinus is 3.
  } until tMinus = 0 step {
    set tMinus to tMinus - 1.
  } do {
    hudText("..." + tMinus, 1, 2, 15, yellow, true).
    wait 1.
  }
}

function mainEngineStart {
  hudText("Main engine start.", 5, 2, 15, yellow, true).
  stage.
}

countdown().
mainEngineStart().
