f = loadfile('scripts/turtleMain')
setfenv( f, getfenv() )
f(...)