//
// launch.ks
// kOSScripts
//
// Created by jacob berkman on 2015-11-11.
// Copyright © 2015 jacob berkman
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@lazyglobal off.

run mechanics.

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

function rollProgram {
  hudText("Initiating roll program.", 5, 2, 15, yellow, true).
  lock steering to r(0, 0, 180) + heading(90, 90).
  when abs(facing:roll - 90) < 1 then {
    hudText("Roll program complete.", 5, 2, 15, yellow, true).
  }
}

function initiateGravityTurn {
  global gravityTurnOldPitch to 90.
  global gravityTurnPitch to 90.
  global gravityTurnOldAltitude to 0.
  global gravityTurnAltitude to 0.

  global gravityTurnCheckpoints to list(
    list(14, 67.5),
    list(5, 45),
    list(2.8, 22.5),
    list(2, 0)
  ).

  lock pitch to gravityTurnPitch.
  lock steering to r(0, 0, 180) + heading(90, pitch).

  when altitude > gravityTurnAltitude then {
    set gravityTurnOldPitch to gravityTurnPitch.
    set gravityTurnPitch to gravityTurnCheckpoints[0][1].

    set gravityTurnOldAltitude to gravityTurnAltitude.
    set gravityTurnAltitude to body:atm:height / gravityTurnCheckpoints[0][0].

    hudText("Pitching down => " + gravityTurnPitch + " @ " + gravityTurnAltitude, 5, 2, 15, yellow, true).
    lock pitch to gravityTurnPitch + (gravityTurnOldPitch - gravityTurnPitch) * (gravityTurnAltitude - altitude) / (gravityTurnAltitude - gravityTurnOldAltitude).

    if gravityTurnCheckpoints:length > 1 {
      gravityTurnCheckpoints:remove(0).
      preserve.
    } else {
      when altitude > gravityTurnAltitude then {
        hudText("Gravity turn complete.", 5, 2, 15, yellow, true).
        lock pitch to 0. 
      }
    }
  }
}

function coastThrottle {
  if apoapsis > coastPID:setPoint + 50 {
    return 0.
  }
  return coastPID:update(time:seconds, apoapsis).
}

function initiateCoast {
  hudText("Initiating coast.", 5, 2, 15, yellow, true).
  global coastPID to PIDLoop(0.05, 0.01, 0.05, 0, 1).
  set coastPID:setPoint to body:atm:height + 10000.
  lock throttle to coastThrottle().
}

countdown().
mainEngineStart().

wait until velocity:surface:mag > 10.
rollProgram().

wait until velocity:surface:mag > 50.
initiateGravityTurn().

wait until apoapsis > body:atm:height + 1000.
initiateCoast().

wait until altitude > body:atm:height.
set throttle to 0.
local completion is list(false).
burnAtApoapsisToAltitude(apoapsis, completion).

wait until completion[0].

hudText("Launch complete.", 5, 2, 15, yellow, true).
