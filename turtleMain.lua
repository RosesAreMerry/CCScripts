local t = require( "myTurtle" )
require("Direction")

running = true

-- Move from starting position to mining tunnel
if (t.checkFuel(100)) then
	if not(turtle.detect()) then
		t.move(Direction.forward)
		t.move(Direction.left)
	else
		t.mainHallway(30)
		t.moveTurn(Direction.left)
		t.turn(Direction.left)
	end

	print("outside checkTorches")
	while running do
		if t.checkTorches() then
			print("making player tunnel")
			t.turn(Direction.left)
			t.playerTunnel(30)
			t.moveTurn(Direction.backward, 30)
			t.turn(Direction.left)
		else
			print("making hallway")
			t.move(Direction.right)
			while not(turtle.detect()) do
				t.move(Direction.forward)
			end
			t.mainHallway(30)
		end
	end
end
