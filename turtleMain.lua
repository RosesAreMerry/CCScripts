local t = require( "myTurtle" )
require("Direction")

running = true
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
			local success, message = pcall(loaded)
			if not success then print(message)
		else
			print(error)
		end
	end
end
	-- TODO: Make a system to automatically dump resources. DONE
	-- TODO: Make a system to automatically craft and/or get necessary items. DONE
	-- TODO: Make a system to refuel automatically. DONE
	-- TODO: Reorganize turtleMain
	-- TODO: make a isFuel function.
	-- TODO: Rework getFuel Function to go until a certain fuel level is reached
	-- TODO: Make sure digMove Doesn't break chests or turtles.
	-- TODO: Make a system to automatically expand the tunnels. 3 4 6 7 9

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


		if t.checkFuel(300) then
			print("Getting Fuel")
			t.getFuel()
		end
		if t.checkIfFullOrClose() then
			print("Dumping Items")
			t.dumpItems()
		end
		if t.checkItem("torch") then
			print("Getting Torches")
			t.getTorches()
		end
		if t.checkItem(function(n) return n:isBlock() end) then
			print("Getting Blocks")
			t.getBlocks()
		end

		if onTheWayBack then
			foundTunnel, wentDistance = t.checkTunnels(tunnelLength)
			print("foundTunnel="..foundTunnel)
			print("wentDistance="..wentDistance)
		else
			foundTunnel, wentDistance = t.checkTunnels()
		end

		print(tunnelLength)
		print(wentDistance)

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
			tunnelLength = tunnelLength + wentDistance
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
