local Libs = require("component");
local Computer = require("computer");
local Event = require("event");
local Sides = require("sides");
local Robot = require("robot");
local Gen = Libs.generator;

local Wait = 10 * 60;
local Runway = 14;
local Height = 7;
local Chestside = Sides.left;
local StartSong = {{200, 0.1}, {300, 0.1}, {400, 0.1}, {500, 0.1}, {600, 0.2}, {500, 0.2}, {600, 0.3}};
local EndSong = {{400, 0.1}, {300, 0.1}, {200, 0.1}};

local GoingForward = true;
local InvInfo = {};

local function PlaySong(song)
	for k,v in pairs(song) do
		if #v == 2 and type(v[1]) == "number" and type(v[2]) == "number" then
			Computer.beep(v[1], v[2]);
		end
	end
end

local function ValidateMove()
	while Robot.detect() do
		Computer.beep(700, 0.3);
		Computer.beep(700, 0.3);
		os.sleep(3);
	end
end

local function Pick()
	Robot.use(Sides.left);
	os.sleep(0.01);
	Robot.use(Sides.right);
end

while true do
	PlaySong(StartSong);

	for u = 1, Height do
		ValidateMove();
		
		for f = 1, Runway do
			ValidateMove();
			Pick();
			Robot.forward();
		end

		Robot.turnAround()
		GoingForward = not GoingForward;
		Pick();
		Robot.up();
	end

	for u = 1, Height-1 do
		ValidateMove();
		Robot.down();
	end

	if not GoingForward then
		for f = 1, Runway do
			ValidateMove();
			Robot.forward();
		end

		Robot.turnAround();
		GoingForward = true;
	end

	if math.floor((Computer.energy() / Computer.maxEnergy()) * 100) < 5 then
		local Ok, Msg = Gen.insert(5);

		if not Ok then
			print(Msg);
		end
	end

	for i = 2, 16 do
		Robot.select(i);
		Robot.dropUp();
	end

	Robot.select(1);
	PlaySong(EndSong);
	os.sleep(Wait);
end