// lib_dd_orbit - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// Based on Robert A. Braeunig's site http://www.braeunig.us/space/basics.htm

@lazyglobal off.

runOncePath("lib_dd").
runOncePath("lib_dd_roots").

{
    global DDOrbit is lex(
        "escapeBurn", orbitEscapeBurn@,
        "trueAnomaly", orbitTrueAnomaly@,
        "meanMotion", orbitMeanMotion@,
        "meanAnomaly", orbitMeanAnomaly@,
        "interceptLongitude", orbitInterceptLongitude@,
        "phi", orbitPhi@,
        "synodicPeriod", orbitSynodicPeriod@,
        "withOrbit", orbitWithOrbit@,
        "withMeanAnomaly", orbitWithMeanAnomaly@,
        "withTrueAnomaly", orbitWithTrueAnomaly@,
        "withAltitude", orbitWithAltitude@,
        "withVectors", orbitWithVectors@
    ).

    function orbitInterceptLongitude {
        parameter src, dst.

        local l1 is src["longitudeOfAscendingNode"].
        local l2 is dst["longitudeOfAscendingNode"].

        local cosi1 is cos(src["inclination"]).
        local sini1 is sin(src["inclination"]).
        local cosi2 is cos(dst["inclination"]).
        local sini2 is sin(dst["inclination"]).

        return Roots["goldenSection"](0, 180, Roots["epsilon"], {
            parameter i.
            local x is sin(arctan(tan(i - l1) / cosi1)) * sini1.
            return abs(x - sin(arctan(tan(i - l2) / cosi2)) * sini2).
        }).
    }

    function orbitSynodicPeriod {
        parameter obt1, obt2.
        return abs(1 / (1 / obt1["period"](obt1) - 1 / obt2["period"](obt2))).
    }

    function orbitTrueAnomaly {
        parameter M, e.

        // "It is also important that the angles M and E be expressed in radians."
        set M to M * constant:degToRad.
        local E_ is 0.
        local x is 0.
        local epsilon is Roots["epsilon"].

        until false {
            local fx is e * sin(x * constant:radToDeg) - x + M.
            local f_x is e * cos(x * constant:radToDeg) - 1.
            local x_ is x - fx / f_x.
            if abs(x - x_) < epsilon { set E_ to x_. break. }
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
        return n * mod(t, 360 / n).
    }

    function orbitPhi {
        parameter r, v.
        return arccos((vcrs(r, v) / r:mag / v:mag):mag).
    }

    function orbitEscapeBurn {
        parameter obt, vInf.

        local longInf is vecLong(vInf).
        local sObt is DDOrbit["withOrbit"](obt).
        local taInj is norDeg(sObt["trueAnomalyAtLongitude"](sObt, longInf)).

        local prevDiff is 180.
        local delta is 1.
        if obt:inclination > 90 { set delta to -delta. }

        local injObt is false.
        local rInj is false.
        local vInj is false.

        vecDraw(V(0, 0, 0), universalToRaw(vInf):normalized * 10, yellow, "vInf", 1, true, 0.2).
        local rInjVec is vecDraw(V(0, 0, 0), V(0, 0, 0), red, "rInj", 1, true, 0.2).
        local epsilon is Roots["epsilon"].
        set taInj to Roots["goldenSection"](taInj - 160, taInj + 160, 0.2, {
            parameter taInj.
            set injObt to sObt["at"](sObt, norDeg(taInj)).
            set rInj to injObt["position"](injObt).
            set rInjVec:vec to universalToRaw(rInj):normalized * 10.
            local rInj_ is rInj:mag.

            set vInj to sqrt(vInf:mag^2 + 2 * kerbin:mu / rInj_).
            local EE is vInj^2 / 2 - kerbin:mu / rInj_.
            local h is rInj_ * vInj.
            local e is sqrt(1 + 2 * EE * h^2 / kerbin:mu^2).
            local etaCalc is arccos(-1 / e).
            local etaAng is vAng(vInf, rInj).
            local diff is abs(etaCalc - etaAng).
            print "    " + round(taInj, 1) + "    " + round(etaCalc, 1) + "    " + round(etaAng, 1) + "    " + round(diff, 4) + "    " + injObt["longitude"](injObt).
            return diff.
        }).

        local h is vCrs(vInf, rInj):normalized.
        set vInj to vInj * (vCrs(rInj, h):normalized).

        local vInj0 is injObt["velocity"](injObt).
        local deltaV is vInj - vInj0.
        return list(deltaV, taInj).
    }

    function createOrbit {
        return lex(
            "periapsis", getPeriapsis@,
            "apoapsis", getApoapsis@,
            "meanMotion", getMeanMotion@,
            "eccentricAnomaly", getEccentricAnomaly@,
            "hyperbolicEccentricity", getHyperbolicEccentricity@,
            "meanAnomaly", getMeanAnomaly@,
            "radius", getRadius@,
            "azimuth", getAzimuth@,
            "velocityMagnitude", getVelocityMagnitude@,
            "velocity", getVelocity@,
            "position", getPosition@,
            "period", getPeriod@,
            "at", getAt@,
            "after", getAfter@,
            "inclined", getInclined@,
            "secondsToMeanAnomaly", getSecondsToMeanAnomaly@,
        //    "trueAnomalyAtRadius", getTrueAnomalyAtRadius@,
            "secondsToTrueAnomaly", getSecondsToTrueAnomaly@,
            "longitude", getLongitude@,
            "latitude", getLatitude@,
            "latitudeAtLongitude", getLatitudeAtLongitude@,
            "trueAnomalyAtLongitude", getTrueAnomalyAtLongitude@
        ).
    }

    function orbitWithOrbit {
        parameter obt.
        return orbitWithTrueAnomaly(obt:body, obt:eccentricity, obt:semiMajorAxis, obt:inclination, obt:longitudeOfAscendingNode, obt:argumentOfPeriapsis, obt:trueAnomaly).
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
        local h is vcrs(v, r).
        local n is vcrs(h, V(0, 1, 0)).

        local x is r * (v:mag ^ 2 - body:mu / r:mag).
        local y is (r * v) * v.
        local e is (x - y) / body:mu.

        local a is 1 / (2 / r:mag - v:mag ^ 2 / body:mu).
        local i is arccos(h:y / h:mag).
        if i = 180 { set i to 360 - i. }

        local loan is arccos(n:x / n:mag).
        if n:z < 0 { set loan to 360 - loan. }

        local aop is arccos(clamp(n * e / n:mag / e:mag, -1, 1)).
        if e:y < 0 { set aop to 360 - aop. }

        local v is arccos((e * r) / e:mag / r:mag).

        return orbitWithTrueAnomaly(body, e:mag, a, i, loan, aop, v).
    }

    function getAt {
        parameter self, v.
        return orbitWithTrueAnomaly(self["body"], self["eccentricity"], self["semiMajorAxis"], self["inclination"], self["longitudeOfAscendingNode"], self["argumentOfPeriapsis"], v).
    }

    function getAfter {
        parameter self, t.
        local e is self["eccentricity"].
        local a is self["semiMajorAxis"].
        local body is self["body"].

        local M is getMeanAnomaly(self).
        local dM is orbitMeanAnomaly(a, body:mu, t).
        local v is orbitTrueAnomaly(norDeg(M + dM), e).

        if false {
            print " M: " + round(M, 1).
            print "dM: " + round(dM, 1).
            print " v: " + round(v, 1).
        }

        return orbitWithTrueAnomaly(body, e, a, self["inclination"], self["longitudeOfAscendingNode"], self["argumentOfPeriapsis"], v).
     }

     function getInclined {
        parameter self, i.
        return orbitWithTrueAnomaly(self["body"], self["eccentricity"], self["semiMajorAxis"], i, self["longitudeOfAscendingNode"], self["argumentOfPeriapsis"], self["trueAnomaly"]).
     }

    // (4.21)
    function getPeriapsis {
        parameter self.
        return self["semiMajorAxis"] * (1 - self["eccentricity"]).
    }

    // (4.22)
    function getApoapsis {
        parameter self.
        return self["semiMajorAxis"] * (1 + self["eccentricity"]).
    }

    // (4.39)
    function getMeanMotion {
        parameter self.
        return orbitMeanMotion(self["semiMajorAxis"], self["body"]:mu).
    }

    // (4.40)
    function getEccentricAnomaly {
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
    function getHyperbolicEccentricity {
        parameter self.
        local v is self["trueAnomaly"].
        local e is self["eccentricity"].

        local cosv is cos(v).
        local a is e + cosv.
        local b is 1 + e * cosv.
        local F is arccosh(abs(a / b)).
        if v >= 0 { return F. }
        return -F.
    }

    // (4.41)
    function getMeanAnomaly {
        parameter self.
        local E is getEccentricAnomaly(self).
        if false { print "E: " + E. }
        return E - self["eccentricity"] * sin(E) * constant:radToDeg.
    }

    // (4.43)
    function getRadius {
        parameter self.
        local e is self["eccentricity"].
        local a is self["semiMajorAxis"] * (1 - e ^ 2).
        local b is 1 + e * cos(self["trueAnomaly"]).
        return a / b.
    }

    // (4.44)
    function getAzimuth {
        parameter self.
        local v is self["trueAnomaly"].
        local e is self["eccentricity"].
        local a is e * sin(v).
        local b is 1 + e * cos(v).
        return arctan(a / b).
    }

    // (4.45)
    function getVelocityMagnitude {
        parameter self.
        return sqrt(self["body"]:mu * (2 / getRadius(self) - 1 / self["semiMajorAxis"])).
    }

    // Easy, but probably inaccurate and slow.
    // See http://www.orbiter-forum.com/showthread.php?t=24457 for another idea
    // but we'd need to determine h vector.
    function getVelocity {
        parameter self.
        if self["eccentricity"] < 1 {
            return (getPosition(getAfter(self, 1)) - getPosition(getAfter(self, -1))) / 2.
        }
        local v is self["trueAnomaly"].
        local dv is 0.1.
        until false {
            local s is abs(getSecondsToTrueAnomaly(self, v + dv)).
            if s <= 1 {
                local orbit1 is getAt(self, v - dv).
                local orbit2 is getAt(self, v + dv).
                return (getPosition(orbit2) - getPosition(orbit1)) / getSecondsToTrueAnomaly(orbit1, orbit2["trueAnomaly"]).
            }
            set dv to dv / s / 2.
        }
    }

    // http://www.braeunig.us/space/plntpos.htm#coordinates
    function getLatitude {
        parameter self.
        local u is self["argumentOfPeriapsis"] + self["trueAnomaly"].
        local i is self["inclination"].
        return arcsin(sin(u) * sin(i)).
    }

    function getLongitude {
        parameter self.
        local i is self["inclination"].

        local u is norDeg(self["trueAnomaly"] + self["argumentOfPeriapsis"]).
        local l_W is norDeg(arctan(cos(i) * sin(u) / cos(u))).
        // "If i < 90º, as for the major planets, (l – W) and u must lie in the
        // same quadrant."
        local l is l_W + self["longitudeOfAscendingNode"].
        //print "l_W: " + l_W + " u: " + u.
        if (l_W > 180) <> (u > 180) {
            //print "beep.".
            set l to l + 180.
        }
        return norDeg(l).
    }

    function getLatitudeAtLongitude {
        parameter self, longitude.
        local u is arctan(tan(longitude - self["longitudeOfAscendingNode"]) / cos(self["inclination"])).
        return arcsin(sin(u) * sin(self["inclination"])). 
    }

    function getTrueAnomalyAtLongitude {
        parameter self, longitude.
        local l_w is norDeg(longitude - self["longitudeOfAscendingNode"]).
        local u is norDeg(arctan2(tan(l_w), cos(self["inclination"]))).
        local v is u - self["argumentOfPeriapsis"].
        if (l_w > 180) <> (u > 180) { set v to v + 180. }
        //print "    l_w: " + longitude + "    u: " + norDeg(u) + "    v: " + norDeg(v).
        return norDeg(v).
    }

    function getPosition {
        parameter self.

        local b is getLatitude(self).
        local l is getLongitude(self).
        local r is getRadius(self).

        local x is r * cos(b) * cos(l).
        local y is r * sin(b).
        local z is r * cos(b) * sin(l).

        return V(x, y, z).
    }

    // (4.38)
    function getSecondsToMeanAnomaly {
        parameter self, M.
        set M to M - getMeanAnomaly(self).
        if M < 0 { set M to M + 360. }
        return M / getMeanMotion(self).
    }

    // (4.86)
    function getSecondsToTrueAnomaly {
        parameter self, v.
        local e is self["eccentricity"].
        local orbit is getAt(self, v).
        if e < 1 {
            return norDeg(getMeanAnomaly(orbit) - getMeanAnomaly(self)) / getMeanMotion(self).
        }
        local F is getHyperbolicEccentricity(orbit).
        local F0 is getHyperbolicEccentricity(self).
        local a is e * sinh(F) - F.
        local b is e * sinh(F0) - F0.
        local c is sqrt(((-self["semiMajorAxis"]) ^ 3) / self["body"]:mu).
        return (a - b) * c.
    }

    function getPeriod {
        parameter self.
        return 2 * constant:pi * sqrt(self["semiMajorAxis"] ^ 3 / self["body"]:mu).
    }

}
