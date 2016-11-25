runOncePath("lib_dd_orbit").
runOncePath("lib_dd_roots").

function orbitInterceptLongitude1 {
    parameter src, dst.

    local l1 is src["longitudeOfAscendingNode"].
    local l2 is dst["longitudeOfAscendingNode"].

    local cosi1 is cos(src["inclination"]).
    local sini1 is sin(src["inclination"]).
    local cosi2 is cos(dst["inclination"]).
    local sini2 is sin(dst["inclination"]).
    local iterations is 0.

    function iter {
        parameter min, max, inc.
        local bestX is 99999.
        local ret is -1.
        local i is min.
        until i >= max {
            set iterations to iterations + 1.
            local x is sin(arctan(tan(i - l1) / cosi1)) * sini1.
            set x to abs(x - sin(arctan(tan(i - l2) / cosi2)) * sini2).
            if x < bestX {
                set bestX to x.
                set ret to i.
            }
            set i to i + inc.
        }
        return ret.
    }

    local x is iter(0, 180, 2.5).
    local ret is iter(max(0, x - 2.5), min(x + 2.5, 180), 0.025).
    print "iterations: " + iterations + " ret: " + ret.
    return ret.
}

function orbitInterceptLongitude2 {
    parameter src, dst.

    local l1 is src["longitudeOfAscendingNode"].
    local l2 is dst["longitudeOfAscendingNode"].

    local cosi1 is cos(src["inclination"]).
    local sini1 is sin(src["inclination"]).
    local cosi2 is cos(dst["inclination"]).
    local sini2 is sin(dst["inclination"]).
    local iterations is 0.

    local ret is Roots["goldenSection"](0, 180, Roots["epsilon"], {
        parameter i.
        set iterations to iterations + 1.
        local x is sin(arctan(tan(i - l1) / cosi1)) * sini1.
        return abs(x - sin(arctan(tan(i - l2) / cosi2)) * sini2).
    }).
    print "iterations: " + iterations + " ret: " + ret.
    return ret.
}

local src is DDOrbit["withOrbit"](kerbin:obt).
local dst is DDOrbit["withOrbit"](moho:obt).

orbitInterceptLongitude1(src, dst).
orbitInterceptLongitude2(src, dst).
