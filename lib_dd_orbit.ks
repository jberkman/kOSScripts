// lib_dd_orbital_elements - Shared routines.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

runOncePath("lib_dd").

{
    global DDOrbit is lex(
        "trueAnomaly", orbitTrueAnomaly@,
        "meanMotion", orbitMeanMotion@,
        "meanAnomaly", orbitMeanAnomaly@,
        "phi", orbitPhi@,
        "at", orbitAt@,
        "withMeanAnomaly", orbitWithMeanAnomaly@,
        "withTrueAnomaly", orbitWithTrueAnomaly@,
        "withAltitude", orbitWithAltitude@,
        "withVectors", orbitWithVectors@
    ).

    local pi is constant:pi.
    local twoPi is 2 * pi.

    function orbitTrueAnomaly {
        parameter M, e.

        local E is 0.
        local x is 0.
        until false {
            local fx is e * sin(x) - x + M.
            local f_x is e * cos(x) - 1.
            local x_ is x - fx / f_x.
            if abs(x - x_) < 0.0001 { set E to x_. break. }
            set x to x_.
        }

        // http://www.braeunig.us/space/plntpos.htm#coordinates
        local a is sqrt((1 + e) / (1 - e)).
        local b is tan(E / 2).
        local c is 2 * arctan(a * b).
        return norRad(c).
    }

    function orbitMeanMotion {
        parameter a, mu.
        return sqrt(mu / (a ^ 3)).
    }

    function orbitMeanAnomaly {
        parameter a, mu, t.
        local n is orbitMeanMotion(a, mu).
        local p is twoPi / n.
        local t2 is mod(t, p).
        return norRad(t2 * n).
    }

    function orbitPhi {
        parameter r, v.
        return arccos((vcrs(r, v) / r:mag / v:mag):mag).
    }

    function createOrbit {
        local orbit is lex().
        lex:add("periapsis", periapsis@:bind(orbit)).
        lex:add("apoapsis", apoapsis@:bind(orbit)).
        lex:add("meanMotion", meanMotion@:bind(orbit)).
        lex:add("eccentricAnomaly", eccentricAnomaly@:bind(orbit)).
        lex:add("hyperbolicEccentricAnomaly", hyperbolicEccentricAnomaly@:bind(orbit)).
        lex:add("meanAnomaly", meanAnomaly@:bind(orbit)).
        lex:add("radius", radius@:bind(orbit)).
        lex:add("azimuth", azimuth@:bind(orbit)).
        lex:add("velocityMagnitude", velocityMagnitude@:bind(orbit)).
        lex:add("velocity", velocity@:bind(orbit)).
        lex:add("position", position@:bind(orbit)).
        lex:add("at", at@:bind(orbit)).
        lex:add("after", after@:bind(orbit)).
        lex:add("inclined", inclined@:bind(orbit)).
        lex:add("secondsToMeanAnomaly", secondsToMeanAnomaly@:bind(orbit)).
        lex:add("trueAnomalyAtRadius", trueAnomalyAtRadius@:bind(orbit)).
        lex:add("secondsToTrueAnomaly", secondsToTrueAnomaly@:bind(orbit)).
        return orbit.
    }

    function orbitAt {
        parameter obt, time.
        local dM is orbitMeanAnomaly(obt:semiMajorAxis, obt:body:mu, time).
        local M is norRad(degToRad(obt:meanAnomaly) + dM).
        return orbitWithMeanAnomaly(obt:body, obt:eccentricity, obt:semiMajorAxis, degToRad(obt:inclination), degToRad(obt:argumentOfPeriapsis), degToRad(obt:longitudeOfAscendingNode), M).
    }

    function orbitWithMeanAnomaly {
        parameter body, e, a, i, loan, aop, M.
        local v is orbitTrueAnomaly(M, e).
        return orbitWithTrueAnomaly(body, e, a, i , laon, aop, v).
    }

    function orbitWithTrueAnomaly {
        parameter body, e, a, i, loan, aop, v.
        local orbit is createOrbit().
        orbit:add("body", body).
        orbit:add("eccentricity", e).
        orbit:add("semiMajorAxis", a).
        orbit:add("inclination", i).
        orbit:add("longitudeOfAscendingNode", loan).
        orbit:add("argumentOfPeriapsis", aop).
        orbit:add("trueAnomaly", v).
        return orbit.
    }

    function orbitWithAltitude {
        parameter body, altitude.
        return orbitWithTrueAnomaly(body, 0, body:radius + altitude, 0, 0, 0, 0).
    }

    function orbitWithVectors {
        parameter body, r, v.
        local h is vcrs(r, v).
        local n is vcrs(Vector(0, 0, 1), h).

        local x is r * ((v:mag ^ 2) - body:mu / r:mag).
        local y is (r * v) * v.
        local e is (x - y) / body:mu.

        local a is 1 / (2 / r:mag - (v:mag ^ 2) / body:mu).
        local i is arccos(h:z / h:mag).

        local loan is arccos(n:x / n:mag).
        if n:y < 0 { set loan to twoPi - loan. }

        local aop is arccos((n * e) / n:mag / e:mag).
        if e:z < 0 { set aop to twoPi - aop. }

        local v is arccos((e * r) / e:mag / r:mag).

        return orbitWithTrueAnomaly(body, e:mag, a, i, loan, aop, v).
    }

    function at {
        parameter self, v.
        return orbitWithTrueAnomaly(self["body"], self["eccentricity"], self["semiMajorAxis"], self["inclination"], self["longitudeOfAscendingNode"], self["argumentOfPeriapsis"], v).
    }

    function after {
        parameter self, t.
        local dM is orbitMeanAnomaly(self["semiMajorAxis"], self["body"]:mu, t).
        local M is self["meanAnomaly"]() + dM.
        return orbitWithTrueAnomaly(self["body"], self["eccentricity"], self["semiMajorAxis"], self["inclination"], self["longitudeOfAscendingNode"], self["argumentOfPeriapsis"], M).
     }

     function inclined {
        parameter self, i.
        return orbitWithTrueAnomaly(self["body"], self["eccentricity"], self["semiMajorAxis"], i, self["longitudeOfAscendingNode"], self["argumentOfPeriapsis"], self["trueAnomaly"]).
     }

    // (4.21)
    function periapsis {
        parameter self.
        return self["semiMajorAxis"] * (1 - self["eccentricity"]).
    }

    // (4.22)
    function apoapsis {
        parameter self.
        return self["semiMajorAxis"] * (1 + self["eccentricity"]).
    }

    // (4.39)
    function meanMotion {
        parameter self.
        return orbitMeanMotion(self["semiMajorAxis"], self["body"]:mu).
    }

    // (4.40)
    function eccentricAnomaly {
        parameter self.
        local v is self["trueAnomaly"].
        local e is self["eccentricity"].

        local cosv is cos(v).
        local a is e + cosv.
        local b is 1 + e * cosv.
        local E is arccos(a / b).
        if v < pi { return E. }
        return twoPi - E.
    }

    // (4.87)
    function hyperbolicEccentricity {
        parameter self.
        local v is self["trueAnomaly"].
        local cosv is cos(v).
        local a is self["eccentricity"] + cosv.
        local x is abs(a / b).
        // acosh()
        local F is ln(x + sqrt(x ^ 2 - 1)).
        if v >= 0 { return F. }
        return -F.
    }

    // (4.41)
    function meanAnomaly {
        parameter self.
        local E is eccentricAnomaly(self).
        return E - self["eccentricity"] * sin(E).
    }

    // (4.43)
    function radius {
        parameter self.
        local e is self["eccentricity"].
        local a is self["semiMajorAxis"] * (1 - e ^ 2).
        local b is 1 + e * cos(self["trueAnomaly"]).
    }

    // (4.44)
    function azimuth {
        parameter self.
        local v is self["trueAnomaly"].
        local e is self["eccentricity"].
        local a is e * sin(v).
        local b is 1 + e * cos(v).
        return arctan(a / b).
    }

    // (4.45)
    function velocityMagnitude {
        parameter self.
        return sqrt(self["body"]:mu * (2 / radius(self) - 1 / self["semiMajorAxis"])).
    }

    // Easy, but probably inaccurate and slow.
    // See http://www.orbiter-forum.com/showthread.php?t=24457 for another idea
    // but we'd need to determine h vector.
    function velocity {
        parameter self.
        if self["eccentricity"] < 1 {
            return position(after(self, 0.5)) - position(after(self, -0.5)).
        }
        local v is self["trueAnomaly"].
        local dv is 0.1.
        until false {
            local s is abs(secondsToTrueAnomaly(self, v + dv)).
            if s <= 1 {
                local orbit1 is at(self, v - dv).
                local orbit2 is at(self, v + dv).
                return (position(orbit2) - position(orbit1)) / secondsToTrueAnomaly(orbit1, orbit2["trueAnomaly"]).
            }
            set dv to dv / s / 2.
        }
    }

    // http://www.braeunig.us/space/plntpos.htm#coordinates
    function position {
        parameter self.
        local i is inclination.

        local u is norRad(self["trueAnomaly"] + self["argumentOfPeriapsis"]).
        local l_W is norRad(arctan(cos(i) * sin(u) / cos(u))).
        // "If i < 90º, as for the major planets, (l – W) and u must lie in the
        // same quadrant."
        local l is l_W + self["longitudeOfAscendingNode"].
        if (l_W > pi) <> (u > pi) {
            set l_W to l_W + pi.
        }
        local b is arcsin(sin(u) * sin(i)).
        // FIXME: this is vector in polar coords; translate to cartesian!
        return Vector(norRad(l), norRad(b), radius(self)).
    }

    // (4.38)
    function secondsToMeanAnomaly {
        parameter self, M.
        set M to M - meanAnomaly(self).
        if M < 0 { set M to M + twoPi. }
        return M / meanMotion(self).
    }

    // (4.86)
    function secondsToTrueAnomaly {
        parameter self, v.
        local e is self["eccentricity"].
        local orbit is at(self, v).
        if e < 1 {
            return norRad(meanAnomaly(orbit) - meanAnomaly(self)) / meanMotion(self).
        }
        local F is hyperbolicEccentricAnomaly(orbit).
        local F0 is hyperbolicEccentricAnomaly(self).
        local sinhF is ((constant:e ^ F) - (constant:e ^ (-F))) / 2.
        local a is e * sinhF - F.
        local sinhF0 is ((constant:e ^ F0) - (constant:e ^ (-f0))) / 2.
        local b is e * sinhF0 - F0.
        local c is sqrt(((-self["semiMajorAxis"]) ^ 3) / self["body"]:mu).
        return (a - b) * c.
    }

}
