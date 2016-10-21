// test_orbit - Orbital unit tests.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.
clearScreen.

runOncePath("KSLib/unit_tests/lib_exec/lib_testing").
runOncePath("lib_dd_orbit").

if false {
    local orbit is DDOrbit["withOrbit"](Moho:obt).
    local t is 0.
    //print "v0: " + orbit["trueAnomaly"].
    local last is orbit.
    print "    " + moho:latitude.
    until t > moho:obt:period * 3 {
        local computed is orbit["after"](orbit, t).
        local expected is shipRawToSOIUniversal(positionAt(moho, time + t), sun).
        set computed to computed["latitude"](computed).
        set expected to arcsin(expected:y / expected:mag).
        print "t=" + t + "    " +  round(expected, 1) + "   =>   " + round(computed, 1).
        set t to t + moho:obt:period / 10.
    }
}

{
    local t is 8735256.
    local orbit is DDOrbit["withOrbit"](Moho:obt).
    set orbit to orbit["after"](orbit, t - time:seconds).
    local computed is orbit["position"](orbit).
    local expected is shipRawToSOIUniversal(positionAt(moho, t), sun).
    print "computed: " + computed + "    " + computed:mag.
    print "expected: " + expected + "    " + expected:mag.
    print "    " + (expected - computed):mag.
    assert((expected - computed):mag < 1000).
}

{
    local vComp is DDOrbit["trueAnomaly"](211.137002, 0.0933833).
    local vExp is 206.114239.
    print "vComp: " + vComp + " vExp: " + vExp + " (" + abs(vComp - vExp) + ")".
    assert(abs(vComp - vExp) < 0.0001).
}

{
    local orbit is DDOrbit["withOrbit"](Mun:obt).
    set orbit["trueAnomaly"] to 0.
    local period is orbit["period"](orbit).
    local orbit1 is orbit["after"](orbit, period / 2).
    print "t0: " + orbit["trueAnomaly"] + " t1: " + orbit1["trueAnomaly"].
    assert(abs(orbit1["trueAnomaly"] - 180) < 0.0001).
}

{
    local orbit is DDOrbit["withOrbit"](Mun:obt).
    set orbit["trueAnomaly"] to 90.
    local period is orbit["period"](orbit).
    local orbit1 is orbit["after"](orbit, period / 2).
    print "t0: " + orbit["trueAnomaly"] + " t1: " + orbit1["trueAnomaly"].
    assert(abs(orbit1["trueAnomaly"] - 270) < 0.0001).
}

test_success().
