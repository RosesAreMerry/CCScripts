---@class MyTurtle
local t = {}

require("Direction")

--- Wrapper for turtle.turn functions using Direction class. It will only work for directions
--- that can be turned to; left, right, and backward.
---@param a Direction the direction to turn.
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

--- Move without turning at all. Used by higher level move functions.
---@overload fun(direction:Direction, amount:number)
---@overload fun(direction:Direction)
---@param direction Direction The direction to move.
---@param amount number The number of blocks to move.
---@param strict boolean Whether to still move if the direction is left or right
---@return number The number of completed moves
function t.planarMove(direction, amount, strict)
	if amount == nil then amount = 1 end
	if strict == nil then strict = false end
	local moves = 0
	for _ = 1, amount do
		if direction == Direction.up then
			if turtle.up() then
				moves = moves + 1
			end
		elseif direction == Direction.down then
			if turtle.down() then
				moves = moves + 1
			end
		elseif direction == Direction.backward then
			if turtle.back() then
				moves = moves + 1
			end
		elseif direction == Direction.forward or not strict then
			if turtle.forward() then
				moves = moves + 1
			end
		end
	end
	return moves
end

--- Move the turtle while not preserving facing direction. (The turtle will end up in the input orientation)
--- @overload fun(direction: Direction)
--- @param direction Direction
--- @param number number
--- @vararg number
function t.moveTurn(direction, number)
	if number == nil then number = 1 end
	if (direction == Direction.left or direction == Direction.right) then
		t.turn(direction)
	end
	t.planarMove(direction, number)
end

--- Undo a Turn.
--- @param direction Direction
function t.unTurn(direction)
	if (direction == Direction.backward) then
		t.turn(direction)
	elseif (direction == Direction.forward) then
		return
	else
		print(textutils.serialize(direction))
		t.turn(direction:opposite())
	end
end

--- Move while respecting facing direction
--- @overload fun(direction: Direction)
--- @param direction Direction
--- @param number number
function t.move(direction, number)
	t.moveTurn(direction, number)
	t.unTurn(direction)
end

--- Dig in a direction, turning if needed.
--- @param direction Direction
function t.dig(direction)
	if direction == Direction.up then
		turtle.digUp()
	elseif direction == Direction.down then
		turtle.digDown()
	else
		t.turn(direction)
		turtle.dig()
	end
end

function t.findItem(a)
	for i = 1, 16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if item ~= nil and item.name == ("minecraft:" .. a) then
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
			print("Out of Fuel!!!")
			return false
		end
	end
	return true
end

--- @return boolean, blockData
local function inspect(direction)
	local success, data
	if direction == Direction.up then
		success, data = turtle.inspectUp()
	elseif direction == Direction.down then
		success, data = turtle.inspectDown()
	else
		success, data = turtle.inspect()
	end
	if not success then
		return false, {name = nil,
		               state = nil,
		               tags = nil}
	else
		return success, data
	end
end

function t.look()
	---@shape surroundings
	---@field [Direction] blockData
	local surroundings = {}

	success, surroundings[Direction.forward] = inspect(Direction.forward)
	t.turn(Direction.right)
	success, surroundings[Direction.right] = inspect(Direction.forward)
	t.turn(Direction.backward)
	success, surroundings[Direction.left] = inspect(Direction.forward)
	t.turn(Direction.right)
	success, surroundings[Direction.down] = inspect(Direction.down)
	success, surroundings[Direction.up] = inspect(Direction.up)
	return surroundings
end

--- returns whether or not the block below the turtle is a torch
function checkTorch()
	local success, data = inspect(Direction.down)
	if success then
		if data.name == "minecraft:torch" then
			return true
		end
	end
	return false
end


--- A function to run down a mainHallway to find a good place to place a playerTunnel
function t.checkTorches()
	local i = 0
	print("outside loop")
	for j = 1, 2 do
		print("inside loop " .. j .. "  " .. tostring(turtle.inspect()))
		while not(turtle.detect()) do
			print("inside while " .. i)

			if i % 5 == 0 then
				if not checkTorch() then
					return true
				end
			end

			t.move(Direction.forward)

			i = i + 1
		end

		if not checkTorch() then
			return true
		end

		t.moveTurn(Direction.right, 2)
		t.turn(Direction.right)
		i = 0
	end
	t.moveTurn(Direction.right)
	t.turn(Direction.right)
	return false
end

function dig(a)
	if (a == Direction.up) then
		turtle.digUp()
	elseif (a == Direction.down) then
		turtle.digUp()
	else
		turtle.dig()
	end
end

--- Detects in a specific direction. Does not turn.
--- @param direction Direction
function t.detect(direction)
	if direction == Direction.up then
		return turtle.detectUp()
	elseif direction == Direction.down then
		return turtle.detectDown()
	else
		return turtle.detect()
	end
end

--- Digs in a direction, checking to see if the dig was successful (there is no more block in the way),
--- then moves in that direction. Does not preserve facing direction.
--- @overload fun()
--- @param direction Direction
function t.digMove(direction)
	if (direction == nil) then direction = Direction.forward end
	t.turn(direction)
	while t.detect(direction) do
		t.dig(direction:forwardOrVertical())
	end
	t.planarMove(direction:forwardOrVertical(), 1)
end

function t.oreCheck()
	local sur = t.look()
	for k, v in pairs( sur ) do
		if not(v.tags == nil) and v.tags["forge:ores"] == true then
			t.turn(k)
			t.digMove()
			t.oreCheck()
			t.move(Direction.backward)
			t.unTurn(k)
		end
	end
end

--- Tries to find and place a torch downwards.
function t.placeTorch()
	if t.findItem("torch") then
		turtle.placeDown()
	end
end

--- Makes a player traversable tunnel, including torches.
--- @param a number Tunnel length
function t.playerTunnel(a)
	for i = 0, a do
		if not(t.checkFuel(a)) then
			return
		end
		if i % 8 == 0 then
			t.placeTorch()
		end
		t.digMove()
		t.oreCheck()
		t.dig(Direction.down)
		t.moveTurn(Direction.down)
		t.oreCheck()
		t.moveTurn(Direction.up)
	end
end

function t.mainHallway(a)
	for i = 0, a do
		if i % 8 == 0 then
			t.placeTorch()
		end
		t.findItem("cobblestone")
		t.digMove(Direction.forward)
		t.digMove(Direction.down)
		turtle.placeDown()
		t.digMove(Direction.right)
		turtle.placeDown()
		turtle.place()
		t.digMove(Direction.up)
		turtle.place()
		t.digMove(Direction.up)
		turtle.place()
		turtle.placeUp()
		t.digMove(Direction.backward)
		turtle.placeUp()
		t.digMove(Direction.forward)
		turtle.placeUp()
		turtle.place()
		t.digMove(Direction.down)
		turtle.place()
		t.digMove(Direction.down)
		turtle.place()
		turtle.placeDown()
		t.moveTurn(Direction.backward)
		t.digMove(Direction.up)
		t.turn(Direction.right)
	end
end

return t
