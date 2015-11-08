// The MIT License (MIT)
//
// Copyright (c) 2015 jacob berkman
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

function countdown {
  lock throttle to 1.0.

  print "Initiating countdown.".
  from {
    local tMinus is 10.
  } until tMinus = 0 step {
    set tMinus to tMinus - 1.
  } do {
    print "..." + tMinus.
    wait 1.
  }
}

function mainEngineStart {
  when maxthrust = 0 then {
    print "Stage activated.".
    stage.
    preserve.
  }
}

function rollProgram {
  print "Initiating roll program.".
  lock steering to r(0, 0, 180) + heading(90, 90).
  when abs(facing:roll - 90) < 1 then {
    print "Roll program complete.".
  }
}

function initiateGravityTurn {
  global gravityTurnOldPitch to 90.
  global gravityTurnPitch to 90.
  global gravityTurnOldAltitude to 0.
  global gravityTurnAltitude to 0.

  global gravityTurnCheckpoints to list(
    list(5000, 67.5),
    list(15000, 45),
    list(30000, 5),
    list(50000, 0)
  ).

  lock pitch to gravityTurnPitch.
  lock steering to r(0, 0, 180) + heading(90, pitch).

  when altitude > gravityTurnAltitude then {
    set gravityTurnOldPitch to gravityTurnPitch.
    set gravityTurnPitch to gravityTurnCheckpoints[0][1].

    set gravityTurnOldAltitude to gravityTurnAltitude.
    set gravityTurnAltitude to gravityTurnCheckpoints[0][0].

    print "Pitching down => " + gravityTurnPitch + " @ " + gravityTurnAltitude.

    lock pitch to gravityTurnPitch + (gravityTurnOldPitch - gravityTurnPitch) * (gravityTurnAltitude - altitude) / (gravityTurnAltitude - gravityTurnOldAltitude).

    if gravityTurnCheckpoints:length > 1 {
      gravityTurnCheckpoints:remove(0).
      preserve.
    }
  }
}

function launch {
  countdown().
  mainEngineStart().

  when velocity:surface:mag > 10 then {
    rollProgram().
    when velocity:surface:mag > 50 then {
      initiateGravityTurn().
    }
  }

  wait until apoapsis > 80000.

  print "80km apoapsis reached, cutting throttle".

  lock throttle to 0.

  set ship:control:pilotmainthrottle to 0.
}
