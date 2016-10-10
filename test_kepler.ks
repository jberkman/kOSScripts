// test_kepler - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// Based on Robert A. Braeunig's site http://www.braeunig.us/space/basics.htm

runOncePath("KSLib/unit_tests/lib_exec/lib_testing").
runOncePath("lib_dd_kepler").

// Problem 5.4
{
    local AU is 149597870000.
    local r1 is V(0.473265, -0.899215, 0).
    local r2 is V(0.066842, 1.561256, 0.030948).

    local r1Mag is r1:mag.
    print "r1Mag: " + r1Mag.
    print r1Mag - 1.01653.
    assert(abs(r1Mag - 1.016153) < 0.00001).

    local r2Mag is r2:mag.
    print "r2Mag: " + r2Mag.
    assert(abs(r2Mag - 1.562993) < 0.00001).

    local p is 1.250633.
    local a is 1.320971.
    local dv is 149.770967.

    local mu is 3.964016e-14.

    local f is Kepler["f"](r2Mag, p, dv).
    print "f: " + f.
    assert(abs(f + 1.329580) < 0.000001).

    local g is Kepler["g"](r1Mag, r2Mag, mu, p, dv).
    print "g: " + g.
    assert(abs(g - 3591258) < 1).

    local fDot is Kepler["fDot"](r1Mag, r2Mag, mu, p, dv).
    print "fDot: " + fDot.
    assert(abs(fDot + 8.795872e-8) < 1e-12).

    local gDot is Kepler["gDot"](r1Mag, p, dv).
    print "gDot: " + gDot.
    assert(abs(gDot + 0.514536) < 0.000001).

    local v1 is Kepler["v1"](r1, r2, mu, p, dv).
    print "v1: (AU) " + v1.
    set v1 to v1 * AU.
    print "v1: " + v1.
    assert(abs(v1:x - 28996.2) < 0.1).
    assert(abs(v1:y - 15232.7) < 0.1).
    assert(abs(v1:z - 1289.2) < 0.1).

    local v2 is Kepler["v2"](r1, r2, mu, p, dv).
    print "v2: (AU) " + v2.
    set v2 to v2 * AU.
    print "v2: " + v2.
    assert(abs(v2:x + 21147) < 0.1).
    assert(abs(v2:y - 3994.5) < 0.1).
    assert(abs(v2:z + 663.3) < 0.1).
}

test_success().
