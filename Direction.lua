---@class Direction
---@field private value -3 | -2 | -1 | 1 | 2 | 3
---@field forward Direction
---@field backward Direction
---@field left Direction
---@field right Direction
---@field up Direction
---@field down Direction
---@field __index Direction
Direction = {}
Direction.__index = Direction

--- Instantiate a new Direction.
---@param directionVector -3 | -2 | -1 | 1 | 2 | 3
---@return Direction new direction
---@private
function Direction.create(directionVector)
	local dir = {}                  -- our new object
	setmetatable(dir, Direction)    -- make Direction handle lookup
	dir.value = directionVector     -- initialize our object
	return --[[---@type Direction]] dir
end

Direction.forward = Direction.create(1)
Direction.backward = Direction.create(-1)
Direction.left = Direction.create(2)
Direction.right = Direction.create(-2)
Direction.up = Direction.create(3)
Direction.down = Direction.create(-3)

--- Get a direction of the specified Vector
function Direction.valueOf(directionVector)
	if     directionVector == -3 then return Direction.down
	elseif directionVector == -2 then return Direction.right
	elseif directionVector == -1 then return Direction.backward
	elseif directionVector == 1 then return Direction.forward
	elseif directionVector == 2 then return Direction.left
	elseif directionVector == 3 then return Direction.up
	end
end

--- Apply a turn to a direction. If direction is right, and you turn right, you will be backward etc.
--- @param turn Direction the Direction to apply
--- @return Direction The modified Direction.
function Direction:applyTurn(turn)
	if (turn == Direction.up or turn == Direction.down) then
		return self
	end

	--- -2 ^ -2 = -1
	--- 2 ^ 2 = -1
	--- 2 ^ -2 = 1
	--- 1 ^ 2 = 2
	--- 1 ^ -2 = -2
	--- -1 ^ 2 = -2
	--- -1 ^ -2 = 2
	local result = self.value * turn.value
	if result == 4 then
		result = -1
	elseif result == -4 then
		result = 1
	end

	return Direction.valueOf(result)
end

--- Returns the opposite of the direction.
---@return Direction The modified direction.
function Direction:opposite()
	return Direction.valueOf(-self.value)
end

--- Returns forward or the input direction if the direction is left right or backward.
--- Returns input if up or down
--- @overload fun(): Direction
--- @param default Direction Default return if not up or down
--- @return Direction the modified direction.
function Direction:forwardOrVertical(default)
	if (self == Direction.up or self == Direction.down) then
		return self
	elseif default ~= nil then
		return default
	end
	return Direction.forward
end


