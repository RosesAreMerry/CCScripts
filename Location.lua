--- @class Location
--- @field x number
--- @field y number
--- @field z number
--- @field __index Location
Location = {}
Location.__index = Location


--- Instantiate a new Location.
--- @overload fun(): Location
--- @param x number X coordinate
--- @param y number Y coordinate
--- @param z number Z coordinate
--- @return Location new location
function Location.create(x, y, z)
	if x == nil then x = 0 end
	if y == nil then y = 0 end
	if z == nil then z = 0 end
	local loc = {}                  -- our new object
	setmetatable(loc, Location)    -- make Direction handle lookup
	loc.x = x                       -- initialize our object
	loc.y = y
	loc.z = z
	return --[[---@type Location]] loc
end

function Location:copy()
	return Location.create(self.x, self.y, self.z)
end

--- Apply a move to a location. Does not take any facing direction into account.
--- @param direction Direction The Direction of the move.
--- @return Location The altered location.
function Location:simpleMove(direction)
	local newLocation = self:copy()
	if     direction == Direction.left then newLocation.y = self.y + 1
	elseif direction == Direction.right then newLocation.y = self.y - 1
	elseif direction == Direction.backward then newLocation.x = self.x - 1
	elseif direction == Direction.forward then newLocation.x = self.x + 1
	elseif direction == Direction.down then newLocation.z = self.z - 1
	elseif direction == Direction.up then newLocation.z = self.z + 1 end
	return newLocation
end

--- Apply a move to the input direction. Uses global FacingDirection.
--- CANNOT MOVE LEFT OR RIGHT RELATIVE TO FACING DIRECTION.
--- @param moveDirection Direction The direction to move
--- @return Location The new location
function Location:applyMove(moveDirection)
	local newLocation = self:copy()
	if     moveDirection == Direction.down then newLocation.z = newLocation.z - 1
	elseif moveDirection == Direction.up then newLocation.z = newLocation.z + 1
	elseif moveDirection == Direction.backward then newLocation = newLocation:simpleMove(facingDirection:opposite())
	elseif moveDirection == Direction.forward then newLocation = newLocation:simpleMove(facingDirection:copy()) end
	return newLocation
end
