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
		shell.run("label set ", a)
	if a == Direction.LEFT then
		turtle.turnRight()
	elseif a == Direction.RIGHT then
		turtle.turnLeft()
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

function myTurtle.findItem(a)
	for i = 1, 16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if not(item == nil) and item.name == ("minecraft:" .. a) then
			return true
		end
	end
	return true
end

function myTurtle.findEmpty()
	for i = 1, 16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if item == nil then
			return true
		end
	end
	return false
end

function myTurtle.fuel()
	myTurtle.findItem("coal")
	return turtle.refuel()
end

function myTurtle.checkFuel(a)
	level = turtle.getFuelLevel()
	if ((a / 2) - 50) >= level then
		if myTurtle.fuel() then
			myTurtle.checkFuel()
		else
			return false
		end
	end
	return true
end

function myTurtle.digMove()
	while not(turtle.inspect() == nil) do
		turtle.dig()
	end
	turtle.forward()
end

--- Makes a player traversable tunnel, including torches.
-- @param a Tunnel length 
function myTurtle.playerTunnel(a)
	for i = 1, a do
		if not myTurtle.checkFuel(a) then
			return
		end
		myTurtle.digMove()
		turtle.digDown()
		if i % 8 == 0 then
			if myTurtle.findItem("torch") then
				turtle.placeDown()
			end
		end
	end
end

myTurtle.dir = Direction

return myTurtle