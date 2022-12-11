local t = {}

facingDirection = Direction.forward

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
	for i = 1, amount do
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

local function moveWithNumber(a, b)
	t.turn(a)
	t.planarMove(a, b)
end

local function moveOnlyDirection(a)
	moveWithNumber(a, 1)
end

--- Move the turtle while not preserving facing direction. (The turtle will end up in the input orientation)
---@param direction Direction
---@vararg number
function t.moveTurn(direction, ...)
	local number = select(2, ...)
	if number == nil then
		moveOnlyDirection(direction)
	else
		moveWithNumber(direction, number)
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

--- Move while respecting facing direction
--- @param direction Direction
--- @vararg number
function t.move(direction, ...)
	t.moveTurn(direction, select(1, ...))
	t.unTurn(direction)
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

--- @return blockData
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
		return {
			name = nil,
			state = {axis = nil},
			tags = {nil = nil}
		}
	end
end

function t.look()
	---@shape surroundings
	---@field [Direction] table|string
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
	turtle.detect()
	return success
end

--- returns whether or not the block below the turtle is a torch
function checkTorch()
	local success, data = turtle.inspectDown()
	if success then
		if not(data.name == "minecraft:torch") then
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
		print("inside loop " .. j)
		while not(t.blockAhead()) do
			print("inside while " .. i)

			if i % 5 == 0 then
				if checkTorch() then
					return true
				end
			end

			if t.checkFuel(i) then
				print("inside checkFuel")
				t.move(Direction.forward)
			end

			i = i + 1
		end

		if checkTorch() then
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

--- Digs in a direction, checking to see if the dig was successful (there is no more block in the way),
--- then moves in that direction.
--- @overload fun()
function t.digMove(a)
	if (a == nil) then
		a = Direction.forward
	end
	t.turn(a)
	local success, data = turtle.inspect()
	while success do
		t.dig(a)
		success, data = turtle.inspect()
	end
	t.planarMove(a, 1)
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

function t.digColumn(a)
	t.dig(Direction.forward)
	t.moveTurn(Direction.forward)
	t.findItemByTag("forge:cobblestone")
	t.place()
	t.dig(Direction.down)
	t.dig(Direction.up)
end

function t.mainHallway(a)
	for i = 0, a do
		t.findItem("cobblestone")
		t.dig(Direction.forward)
		t.move(Direction.forward)
		t.dig(Direction.down)
		t.move(Direction.down)
		turtle.placeDown()
		t.dig(Direction.right)
		t.move(Direction.forward)
		turtle.placeDown()
		turtle.place()
		t.dig(Direction.up)
		t.move(Direction.up)
		turtle.place()
		t.dig(Direction.up)
		t.move(Direction.up)
		turtle.place()
		turtle.placeUp()
		t.dig(Direction.backward)
		t.move(Direction.forward)
		turtle.placeUp()
		t.dig(Direction.forward)
		t.move(Direction.forward)
		turtle.placeUp()
		turtle.place()
		t.dig(Direction.down)
		t.move(Direction.down)
		turtle.place()
		t.dig(Direction.down)
		t.move(Direction.down)
		turtle.place()
		turtle.placeDown()
		t.moveTurn(Direction.backward)
		t.dig(Direction.up)
		t.move(Direction.up)
		t.turn(Direction.right)
	end
end

t.dir = Direction

return t
