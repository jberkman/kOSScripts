// lib_dd_roots - Root solvers
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

{
    local gr is (sqrt(5) + 1) / 2.

    local epsilon is 1.
    until 1 + epsilon = 1 { set epsilon to epsilon / 10. }

    global Roots is lex(
        "brents", getBrents@,
        "brents2", getBrents2@,
        "epsilon", epsilon,
        "goldenSection", getGoldenSection@
    ).

    function getBrents {
        parameter a, b, delta, f.

        local fa is f(a).
        local fb is f(b).

        if fa * fb > 0 { print 1/0. }
        if delta < 0 { print 1/0. }

        if abs(fa) < abs(fb) {
            local tmp is a.
            set a to b.
            set b to tmp.
            set tmp to fa.
            set fa to fb.
            set fb to tmp.
        }

        local c is a.
        local d is false.
        local mflag is true.
        until abs(a - b) < delta {
            print "[ " + a + ", " + b + " ]".
            local fc is f(c).
            local s is false.
            if fa <> fc and fb <> fc {
                // "inverse quadratic interpolation"
                set s to (a * fb * fc) / (fa - fb) / (fa - fc).
                set s to (b * fa * fc) / (fb - fa) / (fb - fc) + s.
                set s to (c * fa * fb) / (fc - fa) / (fc - fb) + s.
            } else {
                // "secant method"
                set s to b - fb * (b - a) / (fb - fa).
            }
            if (s < (3 * a + b) / 4 or s > b) or
                (mflag and abs(s - b) >= abs(b - c) / 2) or
                (not mflag and abs(s - b) >= abs(c - d) / 2) or
                (mflag and abs(b - c) < delta) or
                (not mflag and abs(c - d) < delta) {
                    // "bisection method"
                    set s to (a + b) / 2.
                    set mflag to true.
            } else {
                set mflag to false.
            }
            local fs is f(s).
            if fs = 0 { return s. }
            set d to c.
            set c to b.
            if fa * fs < 0 {
                set b to s.
                set fb to fs.
            } else {
                set a to s.
                set fa to fs.
            }
            if abs(fa) < abs(fb) {
                local tmp is a.
                set a to b.
                set b to tmp.
                set tmp to fa.
                set fa to fb.
                set fb to tmp.
            }
            if fA = 0 { return a. }
            if fB = 0 { return b. }
        }
        return (a + b) / 2.
    }

    function getBrents2 {
        parameter a, b, delta, f.
        local n is 40.
        local d is (b - a) / n.
        local x is a.
        local fx is f(a).
        local ret is list().
        local i is 0.
        until i = n {
            local y is x + d.
            local fy is f(y).
            //print fx * fy.
            if fx * fy < 0 { ret:add(getBrents(x, y, delta, f)). }
            set x to y.
            set fx to fy.
            set i to i + 1.
        }
        return ret.
    }

    function getGoldenSection {
        parameter a, b, delta, f.
        until false {
            //print "[ " + a + ", " + b + " ]".
            local c is b - (b - a) / gr.
            local d is a + (b - a) / gr.
            if abs(c - d) < delta { break. }
            if f(c) < f(d) { set b to d. }
            else { set a to c. }
        }
        return (a + b) / 2.
    }

}
