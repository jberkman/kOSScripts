// lib_dd_transfer - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// Based on Robert A. Braeunig's site http://www.braeunig.us/space/basics.htm

runOncePath("lib_dd_orbit").

{
    function xfer {
        parameter body, origin, destination, duration.

        local r1 is origin:mag.
        local r2 is destination:mag.
        local v is vang(origin, destination).
        print "r1: " + r1 + " r2: " + r2 + " v: " + v.

        // Evaluate the constants l k, and m from r1, r2 and v using equations
        // (5.9) through (5.11)
        // (5.9)
        local k is r1 * r2 * (1 - cos(v)).
        // (5.10)
        local l is r1 + r2.
        // (5.11)
        local m is r1 * r2 * (1 + cos(v)).

        // Determine the limits on the possible values of p by evaluating pi and
        // pii from equations (5.18) and (5.19).
        // Pick a trial value of p within the appropriate limits.
        local p0 is 0.
        local p1 is 0.
        if v < 180 {
            // (5.18)
            local pi is k / (l + sqrt(2 * m)).
            set p0 to (r1 + r2) / 2.
            set p1 to p0 * 1.05.
        } else {
            // (5.19)
            print "k: " + k + " l: " + l + " m: " + m.
            local pii is k / (l - sqrt(2 * m)).
            set p0 to pii * 0.95.
            set p1 to p0 * 0.95.
        }

        // Using the trial value of p, solve for a from equation (5.12). The
        // type conic orbit will be known from the value of a.
        function eval {
            parameter p.
            // (5.12)
            local a is m * k * p / ((2 * m - l ^ 2) * p ^ 2 + 2 * k * l * p - k ^ 2).

            // Solve for f and g from equations (5.5), (5.6) and (5.7)
            // (5.5)
            local f_ is 1 - r2 / p * (1 - cos(v)).
            // (5.6)
            print "p: " + p.
            local g_ is r1 * r2 * sin(v) / sqrt(body:mu * p).

            local t is 0.
            // Solve for E or F, as appropriate, using equations (5.13) and
            // (5.14) or equation (5.15)
            // Solve for t from equation (5.16) or (5.17)
            if a > 0 {
                // (5.13)
                local dE is arccos(1 - r1 * (1 - f_) / a).
                // (5.16)
                set t to g_ + sqrt(a ^ 3 / body:mu) * (dE - sin(dE)).
            } else {
                // (5.15)
                local dF is arccosh(1 - r1 / a * (1 - f_)).
                // (5.17)
                set t to g_ + sqrt(-a ^ 3 / body:mu) * (sinh(dF) - dF).
            }

            return lex("p", p, "a", a, "t", t).
        }

        print "p0: " + p0 + " p1: " + p1.
        local pat is eval(p1).
        local pat0 is eval(p0).
        // compare t with the desired time-of-flight.
        until abs(duration - pat["t"]) < duration / (60 * 60) {
            print "duration: " + duration + " t: " + pat["t"].
            // Adjust the trial value of p using one of the iteration methods
            // discussed above until the desired time-of-flight is obtained.
            print "pat: " + pat + " pat0: " + pat0.
            local p is pat["p"] + (duration - pat["t"]) * (pat["p"] - pat0["p"]) / (pat["t"] - pat0["t"]).
            set pat0 to pat.
            set pat to eval(p).
            wait 0.
        }

        local self is lex(
            "body", body,
            "origin", origin:vec,
            "destination", destination:vec,
            "trueAnomaly", v,
            "parameter", pat["p"],
            "semiMajorAxis", pat["a"],
            "time", pat["t"]
        ).

        self:add("captureVelocity", captureVelocity@).
        self:add("departureVelocity", departureVelocity@).
        self:add("orbit", orbit@).

        return self.
    }

    // (5.3)
    function departureVelocity {
        parameter self.
        return (self["destination"] - f(self) * self["origin"]) / g(self).
    }

    // (5.4)
    function captureVelocity {
        parameter self.
        local r1 is self["origin"]:mag.
        local r2 is self["destination"]:mag.
        local p is self["parameter"].
        local v is self["trueAnomaly"].

        local a is sqrt(self["body"]:mu / p) * tan(v / 2).
        local b is (1 - cos(v)) / p - 1 / r1 - 1 / r2.

        local f_ is a * b.
        local g_ is 1 - r1 * (1 - cos(v)) / p.

        return f_ * self["origin"] + g_ * departureVelocity(self).
    }

    // (5.5)
    function f {
        parameter self.
        return 1 - self["destination"]:mag / self["parameter"] * (1 - cos(self["trueAnomaly"])).
    }

    // (5.6)
    function g {
        parameter self.
        return self["origin"]:mag * self["destination"]:mag * sin(self["trueAnomaly"]) / sqrt(self["body"]:mu * self["parameter"]).
    }

    // (5.7)
    function orbit {
        parameter self.
        return DDOrbit["withVectors"](self["body"], self["origin"], departureVelocity(self)).
    }

    global TransferOrbit is xfer@.

}
