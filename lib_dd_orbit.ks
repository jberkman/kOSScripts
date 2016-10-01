// lib_dd_orbital_elements - Shared routines.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

runOncePath("lib_dd").

{
    global DDOrbit is lex(
        "trueAnomaly", orbitTrueAnomaly@,
        "meanMotion", orbitMeanMotion@,
        "meanAnomaly", orbitMeanAnomaly@,
        //"phi", orbitPhi@,
        "orbitAtTime", orbitAtTime@,
        //"orbitWithMeanAnomaly", orbitWithMeanAnomaly@,
        //"orbitWithTrueAnomaly", orbitWithTrueAnomaly@,
        //"orbitWithAltitude", orbitWithAltitude@,
        //"orbitWithPosition", orbitWithPosition@,
    ).

    local twoPi is 2 * constant():pi.

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

    function createOrbit {
        return lex(
            //"periapsis", periapsis@,
            //"apoapsis", apoapsis@,
            //"meanMotion", meanMotion@,
            //"eccentricAnomaly", eccentricAnomaly@,
            //"hyperbolicEccentricAnomaly", hyperbolicEccentricAnomaly@,
            //"meanAnomaly", meanAnomaly@,
            //"radius", radius@,
            //"azimuth", azimuth@,
            //"velocityMagnitude", velocityMagnitude@,
            //"velocity", velocity@,
            //"position", position@,
            //"at", at@,
            //"after", after@,
            //"inclined", inclined@,
            //"secondsToMeanAnomaly", secondsToMeanAnomaly@,
            //"trueAnomalyAtRadius", trueAnomalyAtRadius@,
            //"secondsToTrueAnomaly", secondsToTrueAnomaly@
        ).
    }

    function orbitAtTime {
        parameter obt, time.

        local orbit is createOrbit().
        orbit:add("body", obt:body).
        orbit:add("eccentricity", obt:eccentricity).
        orbit:add("semiMajorAxis", obt:semiMajorAxis).
        orbit:add("inclination", degToRad(obt:inclination)).
        orbit:add("argumentOfPeriapsis", degToRad(obt:argumentOfPeriapsis)).
        orbit:add("longitudeOfAscendingNode", degToRad(obt:longitudeOfAscendingNode)).

        local dM is orbitMeanAnomaly(obt:semiMajorAxis, obt:body:mu, time).
        local M is norRad(degToRad(obt:meanAnomaly) + dM).
        orbit:add("trueAnomaly", orbitTrueAnomaly(M, obt:eccentricity)).
        return orbit.
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
        local cosv is cos(self["trueAnomaly"]).
        local a is self["eccentricity"] + cosv.
        local b is 1 + self["eccentricity"] * cosv.
        local E is arccos(a / b).
        if self["trueAnomaly"] < constant():pi { return E. }
        return twoPi - E.
    }

    // (4.87)
    function hyperbolicEccentricity {
        parameter self.
        local cosv is cos(self["trueAnomaly"]).
        local a is self["eccentricity"] + cosv.
        local x is abs(a / b).
        // acosh()
        local F is ln(x + sqrt(x ^ 2 - 1)).
        if self["trueAnomaly"] >= 0 { return F. }
        return -F.
    }

    // (4.41)
    function meanAnomaly {
        parameter self.
        local E is eccentricAnomaly(self).
        return E - self["eccentricity"] * sin(E).
    }
}
