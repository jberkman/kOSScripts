// lib_dd_brent - Brent's method
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// https://en.wikipedia.org/wiki/Brent's_method

@lazyglobal off.

{
    global Brent is lex(
    )
function brentsRoot {
    parameter a, b, delta, f.

    local fa is f(a).
    local fb is f(b).

    if fa * fb >= 0 { print 1/0. }
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
    until a - b = 0 {
        print "[ " + a + ", " + b + " ]".
        if f(b) = 0 { return b. }
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
    }
    return a.
}

print brentsRoot(-4, 4/3, 0.00001, {
    parameter x.
    return (x + 3) * (x - 1) ^ 2.    
}).