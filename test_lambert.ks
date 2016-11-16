// Implementation of Gooding Lamber solver
// http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1990CeMDA..48..145G&amp;data_type=PDF_HIGH&amp;whole_paper=YES&amp;type=PRINTER&amp;filetype=.pdf
@lazyglobal off.
clearScreen.
clearVecDraws().

runOncePath("lib_dd_lambert").

local src is kerbin.
//local src is minmus.
//local src is ship.

local dst is moho.
//local dst is minmus.
//local dst is mun.

local window is Lambert["window"](src, dst).
