local myTurtle = {}

Direction = {
	left = "left",
	forward = "forward",
	right = "right",
	backward = "backward",
	up = "up",
	down = "down",
}

function dirOpposite(a)
	if Direction.left then
		return Direction.right
	elseif Direction.right then
		return Direction.left
	elseif Direction.down then
		return Direction.up
	elseif Direction.up then
		return Direction.down
	elseif Direction.backward then
		return Direction.forward
	elseif Direction.forward then
		return Direction.backward
	end
end

function myTurtle.turn(a)
	if a == Direction.left then
		turtle.turnRight()
	elseif a == Direction.right then
		turtle.turnLeft()
	elseif a == Direction.backward then
		turtle.turnRight()
		turtle.turnRight()
	end
end

function myTurtle.unTurn(a)
	if a == Direction.left then
		turtle.turnLeft()
	elseif a == Direction.right then
		turtle.turnRight()
	end
end

function moveWithoutTurning(a, b)
	for i = 1, b do
		if a == Direction.up then
			turtle.up()
		elseif a == Direction.down then
			turtle.down()
		else
			turtle.forward()
		end
	end
end

function moveWithNumber(a, b)
	myTurtle.turn(a)
	moveWithoutTurning(a, b)
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

function myTurtle.dig(a)
	if a == Direction.up then
		turtle.digUp()
	elseif a == Direction.down then
		turtle.digDown()
	else
		myTurtle.turn(a)
		turtle.dig()
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
	if (a + 50) >= level then
		if myTurtle.fuel() then
			return myTurtle.checkFuel(a)
		else
			return false
		end
	end
	return true
end

function myTurtle.look()
	local surroundings = {}

	success, surroundings[Direction.forward] = turtle.inspect()
	myTurtle.turn(Direction.right)
	success, surroundings[Direction.right] = turtle.inspect()
	myTurtle.turn(Direction.backward)
	success, surroundings[Direction.left] = turtle.inspect()
	myTurtle.turn(Direction.right)
	success, surroundings[Direction.down] = turtle.inspectDown()
	success, surroundings[Direction.up] = turtle.inspectUp()
	return surroundings
end

function myTurtle.oreCheck()
	local sur = myTurtle.look()
	for k, v in pairs( sur ) do
		if v.tags["forge:ores"] == true then
			myTurtle.dig(k)
			myTurtle.moveWithoutTurning(k)
			myTurtle.oreCheck()
			myTurtle.unTurn(k)
			myTurtle.move(dirOpposite(k))
		end
	end
end


function myTurtle.digMove()
	local success, data = turtle.inspect()
	while success do
		turtle.dig()
		success, data = turtle.inspect()
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
		myTurtle.oreCheck()
		myTurtle.dig(Direction.down)
		myTurtle.move(Direction.down)
		myTurtle.oreCheck()
		myTurtle.move(Direction.up)
		if i % 8 == 0 then
			if myTurtle.findItem("torch") then
				turtle.placeDown()
			end
		end
	end
end

myTurtle.dir = Direction

return myTurtle