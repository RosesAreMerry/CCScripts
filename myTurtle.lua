local t = {}

Direction = {
	forward = 1,
	backward = -1,
	left = 2,
	right = -2,
	up = 3,
	down = -3,
}

relativeLocation = {x = 0, y = 0, z = 0}

facingDirection = Direction.forward

function Direction.applyTurn(a)
  if (a == Direction.up or a == Direction.down) then
    return
  end
  
  result = facingDirection * a
  if result > 3 then
    result = -(result % 3)
  end
end

function t.turn(a)
	if a == Direction.left then
		turtle.turnLeft()
	elseif a == Direction.right then
		turtle.turnRight()
	elseif a == Direction.backward then
		turtle.turnRight()
		turtle.turnRight()
	end
end

function t.planarMove(a, b)
  moves = 0
	for i = 1, b do
		if a == Direction.up then
			if turtle.up() then
			  moves = moves + 1
			end
		elseif a == Direction.down then
			if turtle.down() then
			  moves = moves + 1
			end
		else
			if turtle.forward() then
		    moves = moves + 1
			end
		end
	end
  return moves
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

function t.unTurn(a)
	if (a == Direction.backward) then
		t.turn(a)
	elseif (a == Direction.forward) then
		return
	else
		t.turn(-a)
	end
end

function t.move(...)
  t.moveTurn(arg[1], arg[2])
  t.unTurn(arg[1])
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
	print("outside loop")
	for j = 1, 2 do
		print("inside loop " .. j)
		while not(t.blockAhead()) do
			print("inside while " .. i)
			if not(t.checkFuel(i)) then
				print("inside checkFuel")
				t.move(Direction.forward)
			end

			if i % 5 == 0 then
				success, data = turtle.inspectDown()
				if not(data.name == "minecraft:torch") then
					return true
				end
			end
			i = i + 1
		end
		t.moveTurn(Direction.right, 3)
		t.turn(Direction.right)
	end
	t.moveTurn(Direction.right)
	t.turn(Direction.right)
	return false
end
	

function t.oreCheck()
	local sur = t.look()
	for k, v in pairs( sur ) do
		if not(v.tags == nil) and v.tags["forge:ores"] == true then
			t.dig(k)
			t.planarMove(k, 1)
			t.oreCheck()
			t.turn(-k)
			t.moveTurn(-k)
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
		if i % 8 == 1 then
			if t.findItem("torch") then
				turtle.placeDown()
			end
		end
		t.digMove()
		t.oreCheck()
		t.dig(Direction.down)
		t.moveTurn(Direction.down)
		t.oreCheck()
		t.moveTurn(Direction.up)
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
		t.moveTurn(Direction.forward, 2)
		t.digColumn()
		t.moveTurn(Direction.backward)
		t.turn(Direction.right)
	end
end

t.dir = Direction

return t
