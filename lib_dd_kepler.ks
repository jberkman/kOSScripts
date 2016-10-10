// lib_dd_kepler - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// Based on Robert A. Braeunig's site http://www.braeunig.us/space/basics.htm

@lazyglobal off.

{
    global Kepler is lex(
        "f", keplerF@,
        "fDot", keplerFDot@,
        "g", keplerG@,
        "gDot", keplerGDot@,
        "v1", keplerV1@,
        "v2", keplerV2@
    ).

    function keplerF {
        parameter r2, p, dv.
        return 1 - r2 / p * (1 - cos(dv)).
    }

    function keplerFDot {
        parameter r1, r2, mu, p, dv.
        local x is sqrt(mu / p) * tan(dv / 2).
        local y is (1 - cos(dv)) / p - 1 / r1 - 1 / r2.
        return x * y.
    }

    function keplerG {
        parameter r1, r2, mu, p, dv.
        return r1 * r2 * sin(dv) / sqrt(mu * p).
    }

    function keplerGDot {
        parameter r1, p, dv.
        return 1 - r1 / p * (1 - cos(dv)).
    }

    function keplerV1 {
        parameter r1, r2, mu, p, dv.
        local f is keplerF(r2:mag, p, dv).
        local g is keplerG(r1:mag, r2:mag, mu, p, dv).
        return (r2 - f * r1) / g.
    }

    function keplerV2 {
        parameter r1, r2, mu, p, dv.
        local fDot is keplerFDot(r1:mag, r2:mag, mu, p, dv).
        local gDot is keplerGDot(r1:mag, p, dv).
        local v1 is keplerV1(r1, r2, mu, p, dv).
        return fDot * r1 + gDot * v1.
    }

}
