// lib_dd_gauss - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// Based on Robert A. Braeunig's site http://www.braeunig.us/space/basics.htm

@lazyglobal off.

runOncePath("lib_dd_kepler").
runOncePath("lib_dd_orbit").

{
    global Gauss is lex(
        "estimatedDuration", estimatedDuration@,
        "withOrbits", withOrbits@,
        "withGauss", withGauss@
    ).

    function estimatedDuration {
        parameter origin, destination.
        local rA is origin:semiMajorAxis.
        local rB is destination:semiMajorAxis.
        local aTX is (rA + rB) / 2.
        return constant:pi * sqrt(aTX ^ 3 / origin:body:mu).
    }

    function withOrbits {
        parameter origin, dest, tTX, goalPhase is 175.

        if origin:body <> dest:body { print 1 / 0. }

        local lower is 300.
        local upper is lower + 1 / (1 / origin:period - 1 / dest:period).
        local t is lower.

        local origin0 is DDOrbit["withOrbit"](origin).
        local originT is false.

        local dest0 is DDOrbit["withOrbit"](dest).
        local destTTX is false.

        function phase {
            set originT to origin0["after"](origin0, t).
            set destTTX to dest0["after"](dest0, t + tTX).
            return norDeg(destTTX["longitude"](destTTX) - originT["longitude"](originT)).
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

        if origin:semiMajorAxis > dest:semiMajorAxis {
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

        local originPos is originT["position"](originT).
        local destPos is destTTX["position"](destTTX).

        local self is withGauss(origin:body, originPos, destPos, tTX).
        set self["departureTime"] to time:seconds + t.
        return self.
    }

    function withGauss {
        parameter body, origin, destination, duration.

        local r1 is origin:mag.
        local r2 is destination:mag.
        local v is vang(origin, destination).
        local cosv is cos(v).
        local sinv is sin(v).

        // Evaluate the constants l k, and m from r1, r2 and v using equations
        // (5.9) through (5.11)
        // (5.9)
        local k is r1 * r2 * (1 - cosv).
        // (5.10)
        local l is r1 + r2.
        // (5.11)
        local m is r1 * r2 * (1 + cosv).
        
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
            local f is Kepler["f"](r2, p, v).
            // (5.6)
            local g is Kepler["g"](r1, r2, body:mu, p, v).

            local t is 0.
            // Solve for E or F, as appropriate, using equations (5.13) and
            // (5.14) or equation (5.15)
            // Solve for t from equation (5.16) or (5.17)
            if a > 0 {
                // (5.13)
                local dE is norDeg(arccos(1 - r1 * (1 - f) / a)).
                // (5.16)
                set t to g + sqrt(a ^ 3 / body:mu) * (dE * constant:degToRad - sin(dE)).
            } else {
                // (5.15)
                local dF is norDeg(arccosh(1 - r1 / a * (1 - f))).
                // (5.17)
                set t to g + sqrt(-a ^ 3 / body:mu) * (sinh(dF) - dF * constant:degToRad).
            }

            return lex("p", p, "a", a, "t", t).
        }

        print "p0: " + p0 + " p1: " + p1.
        local pat is eval(p1).
        local pat0 is eval(p0).
        // compare t with the desired time-of-flight.
        until abs(duration - pat["t"]) < 60 * 60 {
            print "duration: " + duration + " t: " + pat["t"].
            // Adjust the trial value of p using one of the iteration methods
            // discussed above until the desired time-of-flight is obtained.
            print "pat: " + pat.
            print "pat0: " + pat0.
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

        self:add("addNode", addNode@).
        self:add("captureVelocity", getCaptureVelocity@).
        self:add("departureVelocity", getDepartureVelocity@).
        self:add("orbit", getOrbit@).

        return self.
    }

    // (5.3)
    function getDepartureVelocity {
        parameter self.
        return Kepler["v1"](self["origin"], self["destination"], self["body"]:mu, self["parameter"], self["trueAnomaly"]).
    }

    // (5.4)
    function getCaptureVelocity {
        parameter self.
        return Kepler["v2"](self["origin"], self["destination"], self["body"]:mu, self["parameter"], self["trueAnomaly"]).
    }

    // (5.7)
    function getOrbit {
        parameter self.
        return DDOrbit["withVectors"](self["body"], self["origin"], departureVelocity(self)).
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
