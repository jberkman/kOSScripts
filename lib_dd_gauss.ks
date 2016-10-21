// lib_dd_gauss - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// Based on Robert A. Braeunig's site http://www.braeunig.us/space/basics.htm

@lazyglobal off.

runOncePath("lib_dd_kepler").
runOncePath("lib_dd_orbit").

{
    global Gauss is lex(
        "addNode", addNode@,
        "captureVelocity", getCaptureVelocity@,
        "departureVelocity", getDepartureVelocity@,
        "estimatedDuration", estimatedDuration@,
        "findEncounter", findEncounter@,
        "init", gaussInit@,
        "orbit", getOrbit@,
        "solve", solve@
    ).

    function estimatedDuration {
        parameter r1, r2.
        local rA is r1:semiMajorAxis.
        local rB is r2:semiMajorAxis.
        local aTX is (rA + rB) / 2.
        return constant:pi * sqrt(aTX ^ 3 / r1:body:mu).
    }

    function gaussInit {
        parameter body, r1, r2, dt, dv is 0.
        if dv = 0 { set dv to vang(r1, r2). }
        return lex(
            "body", body,
            "r1", r1,
            "r2", r2,
            "transferTime", dt,
            "trueAnomaly", dv
        ).
    }

    function findEncounter {
        parameter orbit1, orbit2, tTX, goalPhase is 175.

        if orbit1:body <> orbit2:body { print 1 / 0. }

        local lower is 300.
        local upper is lower + 1 / (1 / orbit1:period - 1 / orbit2:period).
        local t is lower.

        local orbit10 is DDOrbit["withOrbit"](orbit1).
        local orbit1T is false.

        local orbit20 is DDOrbit["withOrbit"](orbit2).
        local orbit2TTX is false.

        function phase {
            set orbit1T to orbit10["after"](orbit10, t).
            set orbit2TTX to orbit20["after"](orbit20, t + tTX).
            return norDeg(orbit2TTX["longitude"](orbit2TTX) - orbit1T["longitude"](orbit1T)).
        }

        function testIncreasing {
            parameter curPhase.
            return prevPhase >= goalPhase and curPhase <= goalPhase.
        }

        function testDecreasing {
            parameter curPhase.
            return prevPhase <= goalPhase and curPhase >= goalPhase.
        }

        local lowerTest is testIncreasing@.
        local upperTest is testDecreasing@.

        if orbit1:semiMajorAxis > orbit2:semiMajorAxis {
            set lowerTest to testDecreasing@.
            set upperTest to testIncreasing@.
        }

        local prevPhase is phase().
        local inc is (upper - lower) / 2.
        until abs(upper - lower) < 60 {
            until false {
                wait 0.
                set t to t + inc.
                local curPhase is phase().
                print round(lower) + " < " + round(t) + " < " + round(upper) + " prev: " + round(prevPhase) + " cur: " + round(curPhase).
                if inc > 0 {
                    if lowerTest(curPhase) {
                        set prevPhase to curPhase.
                        break.
                    }
                    set lower to t.
                }
                else {
                    if upperTest(curPhase) {
                        set prevPhase to curPhase.
                        break.
                    }
                    set upper to t.
                }
                set prevPhase to curPhase.
            }
            if inc > 0 { set upper to t. }
            else { set lower to t. }
            set inc to -inc / 2.
        }

        local self is gaussInit(orbit1:body, orbit1T["position"](orbit1T), orbit2TTX["position"](orbit2TTX), tTX, prevPhase).
        self:add("departureTime", time:seconds + t).
        return self.
    }

    function solve {
        parameter self.

        local mu is self["body"]:mu.
        local dt is self["transferTime"].
        local dv is self["trueAnomaly"].

        local r1_ is self["r1"]:mag.
        local r2_ is self["r2"]:mag.
        local cosv is cos(dv).
        local sinv is sin(dv).

        // Evaluate the constants l k, and m from r1_, r2_ and v using equations
        // (5.9) through (5.11)
        // (5.9)
        local k is r1_ * r2_ * (1 - cosv).
        // (5.10)
        local l is r1_ + r2_.
        // (5.11)
        local m is r1_ * r2_ * (1 + cosv).
        
        // Determine the limits on the possible values of p by evaluating pi and
        // pii from equations (5.18) and (5.19).
        // (5.18)
        local pi is k / (l + sqrt(2 * m)).
        // (5.19)
        local pii is k / (l - sqrt(2 * m)).

        // Pick a trial value of p within the appropriate limits.
        local p1 is (pi + pii) / 2.
        local p0 is p1 * 1.05.

        // Using the trial value of p, solve for a from equation (5.12). The
        // type conic orbit will be known from the value of a.
        function eval {
            parameter p.
            // (5.12)
            local a1 is m * k * p.
            local a2 is (2 * m - l^2) * p^2 + 2 * k * l * p - k^2.
            local a is a1 / a2.

            // Solve for f and g from equations (5.5), (5.6) and (5.7)
            // (5.5)
            local f is Kepler["f"](r2_, p, dv).
            // (5.6)
            local g is Kepler["g"](r1_, r2_, mu, p, dv).

            local t is 0.
            // Solve for E or F, as appropriate, using equations (5.13) and
            // (5.14) or equation (5.15)
            // Solve for t from equation (5.16) or (5.17)
            if a > 0 {
                // (5.13)
                local cosDE is 1 - r1_ * (1 - f) / a.

                local fDot is Kepler["fDot"](r1_, r2_, mu, p, dv).

                // (5.14)
                local sinDE is -r1_ * r2_ * fDot / sqrt(mu * a).
                local dE is norDeg(arctan2(sinDE, cosDE)).
                print "dE: " + dE.
                // (5.16)
                set t to g + sqrt(a ^ 3 / mu) * (dE * constant:degToRad - sin(dE)).
            } else {
                // (5.15)
                local dF is arccosh(1 - r1_ / a * (1 - f)).
                // (5.17)
                set t to g + sqrt(-a ^ 3 / mu) * (sinh(dF) - dF * constant:degToRad).
            }

            return lex("p", p, "a", a, "t", t).
        }

        print "p0: " + p0 + " p1: " + p1.
        local pat is eval(p1).
        local pat0 is eval(p0).
        // compare t with the desired time-of-flight.
        until abs(dt - pat["t"]) < 60 * 60 {
            print "dt: " + dt + " t: " + pat["t"].
            // Adjust the trial value of p using one of the iteration methods
            // discussed above until the desired time-of-flight is obtained.
            print "pat: " + pat.
            print "pat0: " + pat0.
            local p is pat["p"] + (dt - pat["t"]) * (pat["p"] - pat0["p"]) / (pat["t"] - pat0["t"]).
            set pat0 to pat.
            set pat to eval(p).
            wait 0.
        }

        self:add("parameter", pat["p"]).
        self:add("semiMajorAxis", pat["a"]).
        self:add("time", pat["t"]).

        return self.
    }

    // (5.3)
    function getDepartureVelocity {
        parameter self.
        return Kepler["v1"](self["r1"], self["r2"], self["body"]:mu, self["parameter"], self["trueAnomaly"]).
    }

    // (5.4)
    function getCaptureVelocity {
        parameter self.
        return Kepler["v2"](self["r1"], self["r2"], self["body"]:mu, self["parameter"], self["trueAnomaly"]).
    }

    // (5.7)
    function getOrbit {
        parameter self.
        return DDOrbit["withVectors"](self["body"], self["r1"], getDepartureVelocity(self)).
    }

    function addNode {
        parameter self, orbit.
        local departureTime is self["departureTime"].
        set orbit to DDOrbit["withOrbit"](orbit).
        set orbit to orbit["after"](orbit, departureTime - time:seconds).

        local v is orbit["velocity"](orbit).
        local position is orbit["position"](orbit):normalized.
        local cx is vCrs(v:normalized, position).

        local dv is getDepartureVelocity(self) - v.
        local prograde is v:normalized * dv.
        local radial is position * dv.
        local normal is cx * dv.

        print "radial: " + round(radial) + " normal: " + round(normal) + " prograde: " + round(prograde).

        add Node(departureTime, radial, normal, prograde).
    }

}
