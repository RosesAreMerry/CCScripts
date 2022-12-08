local t = require( "myTurtle" )

running = true

-- Move from starting position to mining tunnel
t.checkFuel(100)
if not(t.blockAhead()) then
	t.move(t.dir.forward)
	t.move(t.dir.left)
else
	t.mainHallway(30)
	t.moveTurn(t.dir.left)
	t.turn(t.dir.left)
end

print("outside checkTorches")
while running do
	if t.checkTorches() then
		t.turn(Direction.left)
		t.playerTunnel(30)
		t.moveTurn(t.dir.backward, 30)
		t.turn(t.dir.left)
	else
		t.move(t.dir.right)
		while not(t.blockAhead()) do
			t.move(t.dir.forward)
		end
		t.mainHallway(30)
	end
end
