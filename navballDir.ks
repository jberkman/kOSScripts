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

run lib_navball.

function compassForDir {
  parameter ves.
  parameter dir.

  local east is east_for(ves).
  local vec is dir:forevector.

  local trig_x is vdot(ves:north:vector, vec).
  local trig_y is vdot(east, vec).

  local result is arctan2(trig_y, trig_x).

  //if result < 0 {
  //  print "result => " + result.
  //  return 360 + result.
  //} else {
    return result.
  //}
}

function pitchForDir {
  parameter ves.
  parameter dir.

  return 90 - vang(ves:up:vector, dir:forevector).
}
