local t = {}

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

function t.turn(a)
	if a == Direction.left then
		turtle.turnRight()
	elseif a == Direction.right then
		turtle.turnLeft()
	elseif a == Direction.backward then
		turtle.turnRight()
		turtle.turnRight()
	end
end

function t.move(a)
	if Direction.left then
		return turtle.left()
	elseif Direction.right then
		return turtle.right()
	elseif Direction.down then
		return turtle.down()
	elseif Direction.up then
		return turtle.up()
	elseif Direction.backward then
		return turtle.backward()
	elseif Direction.forward then
		return turtle.forward()
	end
end

function t.planarMove(a, b)
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
	t.turn(a)
	t.planarMove(a, b)
end

function moveOnlyDirection(a)
	moveWithNumber(a, 1)
end

function t.moveTurn(...)
	if arg[2] == nil then
		moveOnlyDirection(arg[1])
	else
		moveWithNumber(arg[1], arg[2])
	end
end

function t.dig(a)
	if a == Direction.up then
		turtle.digUp()
	elseif a == Direction.down then
		turtle.digDown()
	else
		t.turn(a)
		turtle.dig()
	end
end

function t.findItem(a)
	for i = 1, 16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if not(item == nil) and item.name == ("minecraft:" .. a) then
			return true
		end
	end
	return true
end

function t.findItemByTag(a)
	for i = 1, 16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if not(item == nil) and item.tags[a] == true then
			return true
		end
	end
	return true
end

function t.findEmpty()
	for i = 1, 16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if item == nil then
			return true
		end
	end
	return false
end

function t.fuel()
	t.findItem("coal")
	return turtle.refuel()
end

function t.checkFuel(a)
	level = turtle.getFuelLevel()
	if (a + 50) >= level then
		if t.fuel() then
			return t.checkFuel(a)
		else
			return false
		end
	end
	return true
end

function t.look()
	local surroundings = {}

	success, surroundings[Direction.forward] = turtle.inspect()
	t.turn(Direction.right)
	success, surroundings[Direction.right] = turtle.inspect()
	t.turn(Direction.backward)
	success, surroundings[Direction.left] = turtle.inspect()
	t.turn(Direction.right)
	success, surroundings[Direction.down] = turtle.inspectDown()
	success, surroundings[Direction.up] = turtle.inspectUp()
	return surroundings
end

function t.blockAhead()
	success, data = turtle.inspect()
	return success
end

function t.checkTorches()
	local i = 0
	for j = 1, 2 do
		while not(t.blockAhead()) do
			if not(t.checkFuel(i)) then
				if j == 1 then
					t.moveTurn(Direction.backward, i)
					t.turn(Direction.backward)
				else
					t.moveTurn(Direction.forward, i)
					t.turn(Direction.backward)
				end
			end

			if i % 5 == 0 then
				success, data = turtle.inspectDown()
				if not(data.name == "minecraft:torch") then
					return true
				end
			end
			t.moveTurn(Direction.forward)
			i = i + 1
		end
		t.moveTurn(Direction.right, 3)
		t.turn(Direction.right)
	end
	return false
end
	

function t.oreCheck()
	local sur = t.look()
	for k, v in pairs( sur ) do
		if not(v.tags == nil) and v.tags["forge:ores"] == true then
			t.dig(k)
			t.planarMove(k, 1)
			t.oreCheck()
			t.turn(dirOpposite(k))
			t.moveTurn(dirOpposite(k))
			t.turn(k)
		end
	end
end


function t.digMove()
	local success, data = turtle.inspect()
	while success do
		turtle.dig()
		success, data = turtle.inspect()
	end
	turtle.forward()
end

--- Makes a player traversable tunnel, including torches.
-- @param a Tunnel length 
function t.playerTunnel(a)
	for i = 1, a do
		if not(t.checkFuel(a)) then
			return
		end
		t.digMove()
		t.oreCheck()
		t.dig(Direction.down)
		t.moveTurn(Direction.down)
		t.oreCheck()
		t.moveTurn(Direction.up)
		if i % 8 == 1 then
			if t.findItem("torch") then
				turtle.placeDown()
			end
		end
	end
end  

function t.digColumn()
	t.dig(Direction.forward)
	t.moveTurn(Direction.forward)
	t.dig(Direction.down)
	t.dig(Direction.up)
end

function t.mainHallway(a)
	for i = 1, a do
		t.digColumn()
		t.turn(Direction.left)
		t.digColumn()
		t.turn(Direction.backward)
		t.moveTurn(Direction.forward)
		t.digColumn()
		t.moveTurn(Direction.backward)
		t.turn(Direction.left)
	end
end

t.dir = Direction

return t