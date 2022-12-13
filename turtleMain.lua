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
	-- Move from starting position to mining tunnel
	if (t.checkFuel(100)) then
		if not(turtle.detect()) then
			t.move(Direction.forward)
			t.move(Direction.left)
		else
			t.mainHallway(30)
			t.moveTurn(Direction.backward, 30)
			t.move(Direction.left)
		end

		local onTheWayBack = false
		while running do
			if t.checkTunnels() then
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
end
