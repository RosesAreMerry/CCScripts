local t = require( "myTurtle" )

-- Move from starting position to mining tunnel
t.move(t.dir.BACKWARD)
t.move(t.dir.RIGHT, 9)
t.move(t.dir.UP)