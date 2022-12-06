local myTurtle = {}

Direction = {
	LEFT = 0,
	FORWARD = 1,
	RIGHT = 2,
	BACKWARD = 3,
	UP = 4,
	DOWN = 5,
}


function myTurtle.turn(a)
	if a == Direction.LEFT then
		turtle.turnLeft()
	elseif a == Direction.RIGHT then
		turtle.turnRight()
	elseif a == Direction.BACKWARD then
		turtle.turnRight()
		turtle.turnRight()
	end
end

function moveWithNumber(a, b)
	myTurtle.turn(a)
	for i = 1, b do
		if a == Direction.UP then
			turtle.up()
		elseif a == Direction.DOWN then
			turtle.down()
		else
			turtle.forward()
		end
	end
end

function moveOnlyDirection(a)
	moveWithNumber(a, 1)
end

function myTurtle.move(...)
	if arg[2] == nil then
		moveOnlyDirection(arg[1])
	else
		moveWithNumber(arg[1], arg[2])
	end
end

myTurtle.Direction = Direction

return myTurtle