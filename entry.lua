f = loadfile('scripts/turtleMain.lua')
setfenv( f, getfenv() )
f(...)