local Libs = require("component");
local Sides = require("sides");
local Event = require("event");
local Robot = require("robot");
local Computer = require("computer");
local Redstone = Libs.redstone;

while true do
    local EName, _, Side, Old, New = Event.pull(60, "redstone_changed");

    if math.floor((Computer.energy() / Computer.maxEnergy()) * 100) < 15 then
        Redstone.setOutput(Sides.right, 15);
        os.sleep(5);
        Redstone.setOutput(Sides.right, 0);
    end

    if EName then
        if Side == Sides.back and Old == 0 and New == 15 then
            Robot.select(1);
            Robot.down();
            Robot.down();
            Robot.down();
            Robot.down();
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.up();
            Robot.placeDown();
            Robot.back();
            Robot.placeDown();
            Robot.back();
            Robot.placeDown();
            Robot.turnRight();
            Robot.forward();
            Robot.turnLeft();
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.turnLeft();
            Robot.forward();
            Robot.forward();
            Robot.turnLeft();
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.up();
            Robot.turnAround();
            Robot.select(2);
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.turnRight();
            Robot.forward();
            Robot.forward();
            Robot.turnRight();
            Robot.placeDown();
            Robot.forward();
            Robot.placeDown();
            Robot.forward()
            Robot.placeDown();
            Robot.turnRight();
            Robot.forward();
            Robot.turnRight();
            Robot.forward();
            Robot.forward();
            Robot.placeDown();
            Robot.back();
            Robot.placeDown();
            Robot.back();
            Robot.placeDown();
            Robot.up();
            Robot.up();
        end
    end
end