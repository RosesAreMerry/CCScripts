---@class Direction
---@field value -3 | -2 | -1 | 1 | 2 | 3
---@field forward Direction
---@field backward Direction
---@field left Direction
---@field right Direction
---@field up Direction
---@field down Direction
Direction = {__index = Direction}

--- Instantiate a new Direction.
---@param directionVector -3 | -2 | -1 | 1 | 2 | 3
---@return Direction new direction
function Direction:create(directionVector)
	local dir = {}                  -- our new object
	setmetatable(dir, Direction)    -- make Direction handle lookup
	dir.value = directionVector     -- initialize our object
	return --[[---@type Direction]] dir
end

function Direction:applyTurn()
	if (self == Direction.up or self == Direction.down) then
		return
	end

	local result = facingDirection.value * self.value
	if result > 3 then
		result = -(result % 3)
	end
	self.value = result
end

Direction.forward = Direction:create(1)
Direction.backward = Direction:create(-1)
Direction.left = Direction:create(2)
Direction.right = Direction:create(-2)
Direction.up = Direction:create(3)
Direction.down = Direction:create(-3)


