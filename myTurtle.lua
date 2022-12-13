---@class MyTurtle
local t = {}

require("Direction")
require("Location")

relativeLocation = Location.create()
facingDirection = Direction.forward
--- @shape itemTable
--- @field [number] string
requiredItems = {"torch", "cobblestone"}

--- Wrapper for turtle.turn functions using Direction class. It will only work for directions
--- that can be turned to; left, right, and backward.
---@param a Direction the direction to turn.
function t.turn(a)
	if a == Direction.left then
		if turtle.turnLeft() then
			facingDirection = facingDirection:applyTurn(Direction.left)
		end
	elseif a == Direction.right then
		if turtle.turnRight() then
			facingDirection = facingDirection:applyTurn(Direction.right)
		end
	elseif a == Direction.backward then
		if turtle.turnRight() then
			facingDirection = facingDirection:applyTurn(Direction.right)
		end
		if turtle.turnRight() then
			facingDirection = facingDirection:applyTurn(Direction.right)
		end
	end
end

--- Wrapper for turtle.turn functions using Direction class. Will turn to face the direction relative to facingDirection.
---@param direction Direction the direction to turn.
function t.face(direction)
	if (direction == facingDirection) then
		return
	elseif (direction == facingDirection:applyTurn(Direction.left)) then
		t.turn(Direction.left)
	elseif (direction == facingDirection:applyTurn(Direction.right)) then
		t.turn(Direction.right)
	elseif (direction == facingDirection:applyTurn(Direction.backward)) then
		t.turn(Direction.right)
		t.turn(Direction.right)
	end
end

--- Move without turning at all. Used by higher level move functions.
---@overload fun(direction:Direction, amount:number)
---@overload fun(direction:Direction)
---@param direction Direction The direction to move.
---@param amount number The number of blocks to move.
---@param strict boolean Whether to still move if the direction is left or right
function t.planarMove(direction, amount, strict)
	if amount == nil then amount = 1 end
	if strict == nil then strict = false end
	for _ = 1, amount do
		if direction == Direction.up then
			if turtle.up() then
				relativeLocation = relativeLocation:applyMove(direction)
			end
		elseif direction == Direction.down then
			if turtle.down() then
				relativeLocation = relativeLocation:applyMove(direction)
			end
		elseif direction == Direction.backward then
			if turtle.back() then
				relativeLocation = relativeLocation:applyMove(direction)
			end
		elseif direction == Direction.forward or not strict then
			if turtle.forward() then
				relativeLocation = relativeLocation:applyMove(Direction.forward)
			end
		end
	end
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
--- @overload fun(number: number)
--- @param direction Direction
--- @param number number
function t.move(direction, number)
	if type(direction) == "number" then
		number = --[[---@type number]] direction
		direction = Direction.forward
	end
	t.moveTurn(direction, number)
	if (direction:isTurn()) then
		t.unTurn(direction)
	end
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

--- @overload fun(test: string): boolean, number
--- @param test fun(data: table): boolean
function t.findItem(test)
	if type(test) == "string" then
		local name = test
		test = function() return item.name == ("minecraft:" .. name) end
	end
	for i = 1, 16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if item ~= nil and test(item) then
			return true, turtle.getItemCount()
		end
	end
	return false, 0
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
	if a >= level then
		if t.fuel() then
			return t.checkFuel(a)
		else
			return true
		end
	end
	return false
end

function t.awaitItem(name)
	local hasItem = false
	while not hasItem do
		hasItem = t.findItem(name)
	end
end

function t.requestItem(name)
	print("Out of " .. name .. " Please insert more to continue.")
	t.awaitItem(name)
end

function t.checkItems()
	for _, item in pairs(requiredItems) do
		if t.findItem(item) == false then
			t.requestItem(item)
		end
	end
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

function abs(number)
	if number < 0 then
		return -number
	else
		return number
	end
end

--- returns whether or not the block below the turtle is a torch
function checkTunnel()
	local success, data = inspect(Direction.down)
	if success then
		if data.name == "minecraft:torch" or data.tags["forge:cobblestone"] == true then
			return true
		end
	end
	return false
end

local function oneBlockOfTunnel(i, last)
	if i % 5 == 0 then
		if not checkTunnel() then
			return true
		end
	end
	if not last then
		t.move(Direction.forward)
	end
end

--- A function to run down a mainHallway to find a good place to place a playerTunnel
---@overload fun(): (boolean, number)
---@param hallwayLength number
---@return (boolean, number)
function t.checkTunnels(hallwayLength)
	if (hallwayLength == nil) then
		local last = false
		local i = 0
		while not t.detect(Direction.forward) or last do
			if oneBlockOfTunnel(i, last) then
				return true, i
			end
			i = i + 1
			if last then
				last = false
			elseif t.detect(Direction.forward) then
				last = true
			end
		end
		return false, i
	else
		for i = 0, hallwayLength do
			if oneBlockOfTunnel(i, (i ~= hallwayLength)) then
				return true, i
			end
		end
	end

	return false, hallwayLength
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
--- @overload fun(direction: Direction)
--- @overload fun(number: number)
--- @param direction Direction
--- @param number number
function t.digMove(direction, number)
	if (type(direction) == "number") then number = --[[---@type number]] direction; direction = Direction.forward end
	if (direction == nil) then direction = Direction.forward end
	if (number == nil) then number = 1 end
	if number == 0 then return end
	t.turn(direction)
	for i = 1, number do
		while t.detect(direction) do
			t.dig(direction:forwardOrVertical())
		end
		t.planarMove(direction:forwardOrVertical(), 1)
	end
end

function t.moveTo(location)
	if (relativeLocation.z > location.z) then
		t.digMove(Direction.down, abs(relativeLocation.z - location.z))
	else
		t.digMove(Direction.up, abs(relativeLocation.z - location.z))
	end
	if (relativeLocation.x > location.x) then
		t.face(Direction.backward)
	else
		t.face(Direction.forward)
	end
	t.digMove(abs(relativeLocation.x - location.x))
	if (relativeLocation.y > location.y) then
		t.face(Direction.right)
	else
		t.face(Direction.left)
	end
	t.digMove(abs(relativeLocation.y - location.y))
end

function isBlock(string)
	return string == "minecraft:cobblestone" or string == "minecraft:cobbled_deepslate"
end

function t.checkIfFullOrClose()
	local j = 0
	for i = 1, 16 do
		local count = turtle.getItemCount(i)
		if count == 0 then
			j = j + 1
		end
	end
	return j < 4
end

function t.checkItem(predicate)
	local _, number = t.findItem(predicate)
	return number > 30
end

---@overload fun()
function t.dumpItems(recursion)
	if recursion == nil then recursion = 0 end
	t.moveTo(Location.create(3, 1 + recursion, 0))
	chest = peripheral.wrap("bottom")
	if chest ~= nil and peripheral.hasType(chest, "inventory") then
		local hasKeptOneStackOfBlocks = false
		for i = 1, 16 do
			turtle.select(i)
			if (turtle.getItemDetail() ~= nil and turtle.getItemDetail().name == "minecraft:torch") then
			elseif (turtle.getItemDetail() ~= nil and isBlock(turtle.getItemDetail().name) and not hasKeptOneStackOfBlocks) then
				hasKeptOneStackOfBlocks = true
			else
				local success, message = turtle.dropDown()
				if message == "No space for items" then
					t.dumpItems(recursion + 1)
				end
			end
		end
	else
		error("Dump chest full or missing")
	end
	t.moveTo(Location.create(1, 1, 0))
	t.face(Direction.forward)
end

function t.getTorches(recursion)
	if recursion == nil then recursion = 0 end
	t.moveTo(Location.create(8, 1 + recursion, 0))
	chest = peripheral.wrap("bottom")
	if chest ~= nil and peripheral.hasType(chest, "inventory") then
		if not turtle.suckDown() then
			t.getTorches(recursion + 1)
		end
	else
		error("Torch chest empty or missing")
	end
	if not t.checkItem("torch") then
		error("Incorrect Input or empty chest")
	end
	t.moveTo(Location.create(1, 1, 0))
	t.face(Direction.forward)
end

function t.getFuel(recursion)
	if recursion == nil then recursion = 0 end
	t.moveTo(Location.create(18, 1 + recursion, 0))
	chest = peripheral.wrap("bottom")
	if chest ~= nil and peripheral.hasType(chest, "inventory") then
		if not turtle.suckDown(10) then
			t.getFuel(recursion + 1)
		end
	else
		error("Fuel chest empty or missing")
	end
	if not t.checkItem("coal") then
		error("Incorrect Input or empty chest")
	end
	t.fuel()
	t.moveTo(Location.create(1, 1, 0))
	t.face(Direction.forward)
end

function t.getBlocks(recursion, recursion2)
	if recursion == nil then recursion = 0 end
	if recursion2 == nil then recursion2 = 0 end
	t.moveTo(Location.create(13, 1 + recursion, 0))
	chest = peripheral.wrap("bottom")
	if chest ~= nil and peripheral.hasType(chest, "inventory") then
		if not turtle.suckDown() then
			t.getBlocks(recursion + 1)
		end
	else
		error("Block chest empty or missing")
	end
	if not t.checkItem(isBlock) then
		error("Incorrect Input or empty chest")
	end
	t.moveTo(Location.create(1, 1, 0))
	t.face(Direction.forward)
end

--- Returns whether or not this block should be mined as ore.
--- @param ore blockData
--- @return boolean
local function isWantedOre(ore)
	return not(ore.tags == nil)
			and ore.tags["forge:ores"] == true
			and ore.name ~= "minecraft:copper_ore"
			and ore.name ~= "minecraft:deepslate_copper_ore"
end

--- Checks to see if there are ores around and mines them if there are.
--- @overload fun()
--- @param recursionNumber number
function t.oreCheck(recursionNumber)
	local sur = t.look()
	for direction, block in pairs( sur ) do
		if isWantedOre(block) then
			t.turn(direction)
			local success, data = inspect(direction:forwardOrVertical())
			if success then
				t.digMove(direction:forwardOrVertical())
				t.oreCheck()
				t.move(direction:forwardOrVertical():opposite())
			end
			t.unTurn(direction)
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
	t.findItem("cobblestone")
	turtle.placeDown()

	for i = 0, a do
		if not(t.checkFuel(a)) then
			return
		end
		if i == 1 then
			t.dig(Direction.up)
		end
		if i % 8 == 1 then
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
