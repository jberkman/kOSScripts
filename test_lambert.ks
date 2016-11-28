// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
clearVecDraws().

runOncePath("lib_dd").
runOncePath("lib_dd_lambert").

local src is body.
//local src is minmus.
//local src is ship.

//local dst is moho.
//local dst is minmus.
//local dst is mun.
local dst is target.

local window is Lambert["window"](src, dst).
local departure is window["departure"] - time:seconds.
local duration is window["duration"].

print "departure: " + round(departure * DDConstant["secToDay"], 1).
print "duration: " + round(duration * DDConstant["secToDay"], 1).
