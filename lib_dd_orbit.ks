// lib_dd_orbit - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// Based on Robert A. Braeunig's site http://www.braeunig.us/space/basics.htm

runOncePath("lib_dd").

{
    global DDOrbit is lex(
        "trueAnomaly", orbitTrueAnomaly@,
        "meanMotion", orbitMeanMotion@,
        "meanAnomaly", orbitMeanAnomaly@,
        "phi", orbitPhi@,
        "withOrbit", orbitWithOrbit@,
        "withMeanAnomaly", orbitWithMeanAnomaly@,
        "withTrueAnomaly", orbitWithTrueAnomaly@,
        "withAltitude", orbitWithAltitude@,
        "withVectors", orbitWithVectors@
    ).

    function orbitTrueAnomaly {
        parameter M, e.

        // "It is also important that the angles M and E be expressed in radians."
        set M to M * constant:degToRad.
        local E_ is 0.
        local x is 0.

        until false {
            local fx is e * sin(x * constant:radToDeg) - x + M.
            local f_x is e * cos(x * constant:radToDeg) - 1.
            local x_ is x - fx / f_x.
            if abs(x - x_) < 0.001 { set E_ to x_. break. }
            set x to x_.
        }

        // http://www.braeunig.us/space/plntpos.htm#coordinates
        local a is sqrt((1 + e) / (1 - e)).
        local b is tan(E_ * constant:radToDeg / 2).
        local c is 2 * arctan(a * b).
        return norDeg(c).
    }

    function orbitMeanMotion {
        parameter a, mu.
        return sqrt(mu / a ^ 3) * constant:radToDeg.
    }

    function orbitMeanAnomaly {
        parameter a, mu, t.
        local n is orbitMeanMotion(a, mu).
        local p is 360 / n.
        local t2 is mod(t, p).
        return norDeg(t2 * n).
    }

    function orbitPhi {
        parameter r, v.
        return arccos((vcrs(r, v) / r:mag / v:mag):mag).
    }

    function createOrbit {
        local self is lex().
        self:add("periapsis", periapsis@).
        self:add("apoapsis", apoapsis@).
        self:add("meanMotion", meanMotion@).
        self:add("eccentricAnomaly", eccentricAnomaly@).
        self:add("hyperbolicEccentricity", hyperbolicEccentricity@).
        self:add("meanAnomaly", meanAnomaly@).
        self:add("radius", radius@).
        self:add("azimuth", azimuth@).
        self:add("velocityMagnitude", velocityMagnitude@).
        self:add("velocity", velocity@).
        self:add("position", position@).
        self:add("period", period@).
        self:add("at", at@).
        self:add("after", after@).
        self:add("inclined", inclined@).
        self:add("secondsToMeanAnomaly", secondsToMeanAnomaly@).
        //self:add("trueAnomalyAtRadius", trueAnomalyAtRadius@).
        self:add("secondsToTrueAnomaly", secondsToTrueAnomaly@).
        return self.
    }

    function orbitWithOrbit {
        parameter obt.
        return orbitWithTrueAnomaly(obt:body, obt:eccentricity, obt:semiMajorAxis, obt:inclination, obt:argumentOfPeriapsis, obt:longitudeOfAscendingNode, obt:trueAnomaly).
    }

    function orbitWithMeanAnomaly {
        parameter body, e, a, i, loan, aop, M.
        local v is orbitTrueAnomaly(M, e).
        return orbitWithTrueAnomaly(body, e, a, i , loan, aop, v).
    }

    function orbitWithTrueAnomaly {
        parameter body, e, a, i, loan, aop, v.
        local self is createOrbit().
        self:add("body", body).
        self:add("eccentricity", e).
        self:add("semiMajorAxis", a).
        self:add("inclination", i).
        self:add("longitudeOfAscendingNode", loan).
        self:add("argumentOfPeriapsis", aop).
        self:add("trueAnomaly", v).
        return self.
    }

    function orbitWithAltitude {
        parameter body, altitude.
        return orbitWithTrueAnomaly(body, 0, body:radius + altitude, 0, 0, 0, 0).
    }

    function orbitWithVectors {
        parameter body, r, v.
        local h is vcrs(r, v).
        local n is vcrs(V(0, 0, 1), h).

        local x is r * (v:mag ^ 2 - body:mu / r:mag).
        local y is (r * v) * v.
        local e is (x - y) / body:mu.

        local a is 1 / (2 / r:mag - v:mag ^ 2 / body:mu).
        local i is arccos(h:z / h:mag).

        local loan is arccos(n:x / n:mag).
        if n:y < 0 { set loan to 360 - loan. }

        local aop is arccos((n * e) / n:mag / e:mag).
        if e:z < 0 { set aop to 360 - aop. }

        local v is arccos((e * r) / e:mag / r:mag).

        return orbitWithTrueAnomaly(body, e:mag, a, i, loan, aop, v).
    }

    function at {
        parameter self, v.
        return orbitWithTrueAnomaly(self["body"], self["eccentricity"], self["semiMajorAxis"], self["inclination"], self["longitudeOfAscendingNode"], self["argumentOfPeriapsis"], v).
    }

    function after {
        parameter self, t.
        local e is self["eccentricity"].
        local a is self["semiMajorAxis"].
        local body is self["body"].

        local dM is orbitMeanAnomaly(a, body:mu, t).
        local M is meanAnomaly(self) + dM.
        local v is orbitTrueAnomaly(M, e).
        return orbitWithTrueAnomaly(body, e, a, self["inclination"], self["longitudeOfAscendingNode"], self["argumentOfPeriapsis"], v).
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
        local E_ is arccos(a / b).
        if v < 180 { return E_. }
        return 360 - E_.
    }

    // (4.87)
    function hyperbolicEccentricity {
        parameter self.
        local v is self["trueAnomaly"].
        local cosv is cos(v).
        local a is self["eccentricity"] + cosv.
        local F is arccosh(abs(a / b)).
        if v >= 0 { return F. }
        return -F.
    }

    // (4.41)
    function meanAnomaly {
        parameter self.
        local E is eccentricAnomaly(self).
        return (E * constant:degToRad - self["eccentricity"] * sin(E)) * constant:radToDeg.
    }

    // (4.43)
    function radius {
        parameter self.
        local e is self["eccentricity"].
        local a is self["semiMajorAxis"] * (1 - e ^ 2).
        local b is 1 + e * cos(self["trueAnomaly"]).
        return a / b.
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
        local i is self["inclination"].

        local u is norDeg(self["trueAnomaly"] + self["argumentOfPeriapsis"]).
        local l_W is norDeg(arctan(cos(i) * sin(u) / cos(u))).
        // "If i < 90º, as for the major planets, (l – W) and u must lie in the
        // same quadrant."
        local l is l_W + self["longitudeOfAscendingNode"] + self["body"]:rotationAngle.
        //print "l_W: " + l_W + " u: " + u.
        if (l_W > 180) <> (u > 180) {
            //print "beep.".
            set l to l + 180.
        }
        local b is arcsin(sin(u) * sin(i)).
        local r is radius(self).

        //print "u: " + round(u) + " l_W: " + round(l_W) + " + loan: " + round(self["longitudeOfAscendingNode"]) + " long: " + round(l) + " lat: " + round(b) + " r: " + r.
        //print "longitude: " + longitude + " rotation: " + body:rotationAngle.
        local x is r * cos(b) * cos(l).
        local y is r * sin(b).
        local z is r * cos(b) * sin(l).

        return V(x, y, z).
    }

    // (4.38)
    function secondsToMeanAnomaly {
        parameter self, M.
        set M to M - meanAnomaly(self).
        if M < 0 { set M to M + 360. }
        return M / meanMotion(self).
    }

    // (4.86)
    function secondsToTrueAnomaly {
        parameter self, v.
        local e is self["eccentricity"].
        local orbit is at(self, v).
        if e < 1 {
            return norDeg(meanAnomaly(orbit) - meanAnomaly(self)) / meanMotion(self).
        }
        local F is hyperbolicEccentricity(orbit).
        local F0 is hyperbolicEccentricity(self).
        local a is e * sinh(F) - F.
        local b is e * sinh(F0) - F0.
        local c is sqrt(((-self["semiMajorAxis"]) ^ 3) / self["body"]:mu).
        return (a - b) * c.
    }

    function period {
        parameter self.
        return 2 * constant:pi * sqrt(self["semiMajorAxis"] ^ 3 / self["body"]:mu).
    }

}
