local t = require( "myTurtle" )

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
if t.checkTorches() then
	t.turn(t.dir.left)
	t.playerTunnel(30)
else
	t.move(t.dir.right)
	while not(t.blockAhead()) do
		t.move(t.dir.forward)
	end
	t.mainHallway(30)
end
