// lib_dd_lambert - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.

@lazyglobal off.

runOncePath("lib_dd_gooding").
runOncePath("lib_dd_orbit").

{
    global Lambert is lex(
        "window", getWindow@
    ).

    function days {
        parameter seconds.
        return round(seconds * DDConstant["secToDay"], 1).
    }

    function getWindow {
        parameter src, dst.

        local body is src:obt:body.
        local srcObt is DDOrbit["withOrbit"](src:obt).
        local dstObt is DDOrbit["withOrbit"](dst:obt).

        local synodicPeriod is DDOrbit["synodicPeriod"](srcObt, dstObt).
        local hohmannPeriod is false.
        {
            local a is body:radius + (src:obt:apoapsis + dst:obt:apoapsis) / 2.
            set hohmannPeriod to 2 * constant:pi * sqrt(a ^ 3 / body:mu).
        }

        clearScreen.
        //     012345678901234567890123456
        print "DunaDirect Lambert! v0.1".
        print "(solution may take a few minutes)".
        print "Evaluating departure:". // 2
        print "Solution:".  // 3
        print "Departure:". // 4
        print "   deltaV:". // 5
        print " Duration:". // 6
        print "   deltaV:". // 7
        print "    total:". // 8

        local depRow is 2.
        local depCol is 22.
        local solRow is depRow + 2.
        local solCol is 11.

        local t0 is time.

        local v0 is false.
        local v1 is false.
        local v2 is false.
        local v3 is false.

        local r1 is false.
        local r2 is false.

        local depMin is 0.
        local depMax is synodicPeriod.
        local depStep is src:obt:period / 72.

        local durMin is hohmannPeriod / 4.
        local durMax is durMin * 3.
        local durStep is dst:obt:period / 72.

        local dvInf is false.
        local dvInfDep is -1.
        local dvInfDur is false.

        local i is 0.
        local n is max(0, round(log10(depStep * DDConstant["secToMin"]))).
        until depStep <= 5 {
            local departure is depMin.
            until departure > depMax {
                local departureTime is t0 + departure.
                {
                    local d is days(departureTime:seconds).
                    local p is i + (departure - depMin) / (depMax - depMin).
                    print d + " (" + round(100 * p / (n + 1)) + "%)      " at (depCol, depRow).
                }
                local r1 is shipRawToSOIUniversal(positionAt(src, departureTime), body).
                local v0 is rawToUniversal(velocityAt(src, departureTime):orbit).
                local duration is durMin.
                until duration > durMax {
                    if dvInfDep < 0 or departure <> depMin or duration <> durMin {
                        local r2 is shipRawToSOIUniversal(positionAt(dst, departureTime + duration), body).
                        if vAng(r1, r2) > 120 {
                            local vLamb is false.
                            if vAng(r1, r2) > 177 {
                                local a is (r1:mag + r2:mag) / 2.
                                local v1 is v0:normalized * sqrt(body:mu * (2 / r1:mag - 1 / a)).
                                local v2 is v1:normalized * sqrt(body:mu * (2 / r2:mag - 1 / a)).
                                set vLamb to list(v1, v2).
                            } else {
                                set vLamb to Gooding["vLamb"](body:mu, r1, r2, duration).
                            }
                            local dV is vLamb[0] - v0.
                            if dvInfDep < 0 or dV:mag < dvInf:mag {
                                set dvInf to dV.
                                set dvInfDep to departure.
                                set dvInfDur to duration.
                                set v1 to vLamb[0].
                                set v2 to vLamb[1].
                                set v3 to rawToUniversal(velocityAt(dst, departureTime + duration):orbit).
                                local dV2 is v3 - v2.
                                print days(departureTime:seconds) + "      " at (solCol, solRow + 0).
                                print round(dV:mag, 1)            + "      " at (solCol, solRow + 1).
                                print days(duration)              + "      " at (solCol, solRow + 2).
                                print round(dV2:mag, 1)           + "      " at (solCol, solRow + 3).
                                print round(dV:mag + dV2:mag, 1)  + "      " at (solCol, solRow + 4).
                                if dvInfDep < 0 { print 1/0. }
                           }
                           if vAng(r1, r2) > 175 { print 1/0. }
                        }
                    }
                    set duration to duration + durStep.
                }
                set departure to departure + depStep.
            }
            set depStep to depStep / 10.
            set depMin to max(0, dvInfDep - 9 * depStep).
            set depMax to dvInfDep + 9 * depStep.

            set durStep to durStep / 10.
            set durMin to max(0, dvInfDur - 9 * durStep).
            set durMax to dvInfDur + 9 * durStep.

            set i to i + 1.
        }
        return lex(
            "departure", t0 + depMin,
            "duration", durMin,
            "r1", r1,
            "r2", r2,
            "v0", v0,
            "v1", v1,
            "v2", v2,
            "v3", v3
        ).
    }

}
