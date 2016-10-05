// test_orbit - Orbital unit tests.
// Copyright © 2015 jacob berkman
// This file is distributed under the terms of the MIT license.

runOncePath("KSLib/unit_tests/lib_exec/lib_testing").
runOncePath("lib_dd_orbit").

{
    local vComp is DDOrbit["trueAnomaly"](211.137002, 0.0933833).
    local vExp is 206.114239.
    print "vComp: " + vComp + " vExp: " + vExp + " (" + abs(vComp - vExp) + ")".
    assert(abs(vComp - vExp) < 0.0001).
}

{
    local orbit is DDOrbit["withOrbit"](Mun:orbit).
    set orbit["trueAnomaly"] to 0.
    local period is orbit["period"](orbit).
    local orbit1 is orbit["after"](orbit, period / 2).
    print "t0: " + orbit["trueAnomaly"] + " t1: " + orbit1["trueAnomaly"].
    assert(abs(orbit1["trueAnomaly"] - 180) < 0.0001).
}

test_success().
