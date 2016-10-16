// lib_dd_gooding - Kerbal Mechanics.
// Copyright © 2016 jacob berkman
// This file is distributed under the terms of the MIT license.
// Based on R. H. Gooding's paper: http://www.dtic.mil/get-tr-doc/pdf?AD=ADA200383

@lazyglobal off.

{
    global Gooding is lex(
        "tLamb", tLamb@,
        "xLamb", xLamb@,
        "vLamb", vLamb@
    ).

    function tLamb {
        parameter q, qSqFM1, x, n.

        local lM1 is n = -1.
        local l1 is n >= 1.
        local l2 is n >= 2.
        local l3 is n = 3.

        local qSq is q ^ 2.
        local xSq is x ^ 2.

        local u is (1 - x) * (1 + x).

        local t is false.
        local dT is false.
        local d2T is false.
        local d3T is false.

        function directComputation {
            local a is false.
            local b is false.
            local aa is false.
            local bb is false.

            local y is sqrt(abs(u)).
            local z is sqrt(qSqFm1 + qSq * xSq).
            local qx is q * x.
            if qx <= 0 {
                set a to z - qx.
                set b to q * z - x.
                if qx <> 0 and lM1 {
                    set aa to qSqFm1 / a.
                    set bb to qSqFm1 * (qSq * u - xSq) / b.
                }
            }
            if (qx = 0 and lM1) or qx > 0 {
                set aa to z + qx.
                set bb to q * z + x.
            }
            if qx > 0 {
                set a to qSqFm1 / aa.
                set b to qSqFm1 * (qSq * u - xSq) / bb.
            }

            if lM1 { return list(t, b, bb, aa). }

            local g is false.
            if qx * u >= 0 {
                set g to x * z + q * u.
            } else {
                set g to (xSq - qSq * u) / (x * z - q * u).
            }
            local f is a * y.
            if x <= 1 {
                set t to arctan2(f, g).
            } else if f > 0.4 {
                set t to ln(f + g).
            } else {
                local fg1 is f / (g + 1).
                local term is 2 * fg1.
                local fG1Sq is fg1 ^ 2.
                set t to term.
                local twoI1 to 1.
                until false {
                    set twoI1 to twoI1 + 2.
                    set term to term * fG1Sq.
                    local tOld is t.
                    set t to t + term / twoI1.
                    if t = tOld { break. }
                }
            }
            set t to 2 * (t / y + b) / u.
            if l1 and z <> 0 {
                local qz is q / z.
                local qz2 is qz * qz.
                set qz to qz * qz2.
                set dt to (3 * x * t - 4 * (a + qx * qSqFm1) / z) / u.
                if l2 { set d2t to (3 * t + 5 * x * dt + 4 * qz * qSqFm1) / u. }
                if l3 { set d3t to (8 * dt + 7 * x * d2t - 12 * qz * qz2 * x * qSqFm1) / u. }
            }
            return list(t, dT, d2T, d3T).
        }

        function seriesComputation {
            local u0I is 1.
            local u1I is 1.
            local u2I is 1.
            local u3I is 1.

            local term is 4.
            local tq is q * qSqFm1.
            local i is 0.
            local tqSum is false.
            if q < 0.5 { set tqSum to 1 - q * qSq. }
            else { set tqSum to (1 / (1 + q) + q) * qSqFm1. }
            set tTmOld to term / 3.
            set t to tTmOld * tSqSum.
            until {
                set i to i + 1.
                local p is i.
                set u0I to u0I * u.
                if l1 and i > 1 { set u1I to u1I * u. }
                if l2 and i > 2 { set u2I to u2I * u. }
                if l3 and i > 3 { set u3I to u3I * u. }
                set term to term * (p - 0.5) / p.
                set tq to tq * qSq.
                set tqSum to tqSum + tq.
                local tOld is t.
                local tTerm is term / (2 * p + 3).
                local tqTerm is tTerm * tqSum.
                set t to t - u01 * ((1.5 * p + 0.25) * tqTerm / (p ^ 2 - 0.25) - tTmOld * tq).
                set tTmOld to tTerm.
                set tqTerm to tqTerm * p.
                if l1 { set dT to dT + tqTerm * u1I. }
                if l2 { set d2T to d2T + tqTerm * u2I * (p - 1). }
                if l3 { set d3T to d3T + tqTerm * u3I * (p - 1) * (p - 2). }
                if i >= n and t = tOld { break. }
            }
            if l3 { set d3T to 8 * x * (1.5 * d2T - xSq * d3T). }
            if l2 { set d2t to 2 * (2 * xSq * d2T - dT). }
            if l1 { set dT to -2 * x * dT. }
            set t to t / xSq.
            return list(t, dT, d2T, d3T).
        }

        if lM1 or x < 0 or abs(u) > 0.4 { return directComputation(). }
        return seriesComputation().
    }

    function xLamb {
        parameter q, qSqFm1, tIn, thetaR.

        local x is false.

        local t0 is tLamb(q, qSqFm1, 0, 0)[0].
        local tDiff is tIn - t0.
        if tDiff < 0 {
            // (11)
            // -4 is the value of DT, for x = 0
            set x to t0 * tDiff / (-4 * tIn). 
        } else {
            // (13)
            set x to -tDiff / (tDiff + 4).
            // (16)
            local w is x + 1.7 * sqrt(2 - thetaR / 180).
            // (17), (15)
            if w < 0 { set x to x - w ^ 0.0625 * (x + sqrt(tDiff / (tDiff + 1.5 * t0))). }
            set w to 4 / (4 + tDiff).
            // (18), (19)
            set x to x * (1 + x * (w / 2 - 0.03 * x * sqrt(w))).
        }

        // Iterate 3 times.
        local i is 1.
        until i > 3 {
            set i to i + 1.
            local tList is tLamb(q, qSqFm1, x, 2).
            local t is tIn - tList[0].
            local dT is tList[1].
            local d2T is tList[2].
            if dt = 0 { break. }
            set x to x + t * dT / (dT ^ 2 + t * d2T / 2).
        }

        return x.
    }

    function vLamb {
        parameter mu, r1, r2, tDelta.

        local thetaR is vAng(r1, r2).
        local normal is vCrs(r1, r2).
        if  V(0, 0, 1) * normal < 0 { set thetaR to 360 - thetaR. }
        print "thetaR: " + thetaR.

        local r1_ is r1:mag.
        local r2_ is r2:mag.
        local r1r2 is r1_ * r2_.
        local c is (r2 - r1):mag.
        local s is (r1_ + r2_ + c) / 2.
        local r1r2Th is 4 * r1r2 * sin(thetaR / 2) ^ 2.
        local q is sqrt(r1r2) * cos(thetaR / 2) / s.
        local muS is sqrt(mu * s / 2).
        local qSqFm1 is c / s.
        local rho is 0.
        local sig is 1.
        if c <> 0 {
            set rho to (r1_ - r2_) / c.
            set sig to r1r2Th / c ^ 2.
        }
        local t is 4 * muS * tDelta / s ^ 2.

        local x is xLamb(q, qSqFm1, t, thetaR).
        print "x: " + x.

        local tList is tLamb(q, qSqFm1, x, -1).
        local qzMinX is tList[1].
        local qzPlX is tList[2].
        local zPlQX is tList[3].

        local vT2 is muS * zPlQX * sqrt(sig).
        local vR1 is muS * (qzMinX - qzPlX * rho) / r1_.
        local vT1 is vT2 / r1_.
        local vR2 is -muS * (qzMinX + qzPlX * rho) / r2_.

        local prograde is vCrs(normal, r1).
        local v1 is vR1 * r1:normalized + vT1 * prograde:normalized.

        set prograde to vCrs(normal, r2).
        local v2 is vR2 * r2:normalized + vT2 * prograde:normalized.

        return list(v1, v2).
    }

}
