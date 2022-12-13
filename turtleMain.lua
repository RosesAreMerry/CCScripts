local t = require( "myTurtle" )
require("Direction")

running = true

t.checkFuel(100)
t.checkItems()
print("Dev mode?")
local answer = read()
if answer == "y" then
	local localEnv = {}
	localEnv.t = t
	localEnv.Direction = Direction
	localEnv.Location = Location
	while running do
		loaded, error = load(read(), nil, "t", localEnv)
		if loaded then
			loaded()
		else
			print(error)
		end
	end
else

	-- TODO: Make a system to automatically dump resources
	-- TODO: Make a system to automatically craft and/or get necessary items.
	-- TODO: Make a system to refuel automatically.

	-- Move from starting position to mining tunnel
	if not(turtle.detect()) then
		t.move(Direction.forward)
		t.move(Direction.left)
	else
		t.mainHallway(30)
		t.moveTurn(Direction.backward, 30)
		t.move(Direction.left)
	end

	local onTheWayBack = false
	local foundTunnel, wentDistance
	local tunnelLength = 0
	while running do

		if t.checkIfFullOrClose() then
			t.dumpItems()
			t.moveTo(Location.create(1, 1, 0))
			t.face(Direction.forward)
		end

		if onTheWayBack then
			foundTunnel, wentDistance = t.checkTunnels(tunnelLength)
		else
			foundTunnel, wentDistance = t.checkTunnels()
		end

		if foundTunnel and not wentDistance == 0 then
			if onTheWayBack then
				tunnelLength = tunnelLength - wentDistance
			else
				tunnelLength = tunnelLength + wentDistance
			end
			print("making player tunnel")
			t.turn(Direction.left)
			t.playerTunnel(30)
			t.moveTurn(Direction.backward, 31)
			t.turn(Direction.right)
		elseif onTheWayBack == false then
			print("turning around")
			t.moveTurn(Direction.right, 2)
			t.turn(Direction.right)
			onTheWayBack = true
		else
			print("making hallway")
			t.move(Direction.right)
			while not(turtle.detect()) do
				t.move(Direction.forward)
			end
			t.mainHallway(30)
			t.moveTurn(Direction.backward, 30)
			t.move(Direction.left)
			onTheWayBack = false
		end
	end
end
