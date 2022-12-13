local t = require( "myTurtle" )
require("Direction")

running = true

t.checkFuel(100)
t.checkItems()
--local localEnv = {}
--localEnv.t = t
--localEnv.Direction = Direction
--localEnv.Location = Location
--while running do
--	loaded, error = load(read(), nil, "t", localEnv)
--	if loaded then
--		loaded()
--	else
--		print(error)
--	end
--	end


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

	print("outside checkTorches")
	while running do
		if t.checkTunnels() then
			print("making player tunnel")
			t.turn(Direction.left)
			t.playerTunnel(30)
			t.moveTurn(Direction.backward, 31)
			t.turn(Direction.right)
		else
			print("making hallway")
			t.move(Direction.right)
			while not(turtle.detect()) do
				t.move(Direction.forward)
			end
			t.mainHallway(30)
			t.moveTurn(Direction.backward, 30)
			t.move(Direction.left)
		end
	end
end
