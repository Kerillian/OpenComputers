local Libs = require("component");
local Computer = require("computer");
local Button = require("button");
local Modem = Libs.modem;

Button.SetEnabledColor(0x1EACFF);
Button.SetDisabledColor(0x000000);

local function Sound(Active)
    Computer.beep(Active and 200 or 400, 0.05);
    Computer.beep(Active and 400 or 200, 0.05);
end

Button.Add("Hostiles", 2, 0, 26, 13, function(Key, Active)
    Modem.broadcast(420, "Light", Active);
    Button.Toggle(Key);
    Sound(Active);
end);

Button.Add("Withers", 28, 0, 26, 13, function(Key, Active)
    Modem.broadcast(420, "Wither", Active);
    Button.Toggle(Key);
    Sound(Active);
end);

Button.Add("Blaze",  54, 0, 26, 13, function(Key, Active)
    Modem.broadcast(420, "Blaze", Active);
    Button.Toggle(Key);
    Sound(Active);
end);

Button.Add("Snowmen", 2, 13, 26, 13, function(Key, Active)
    Modem.broadcast(420, "Snowman", Active);
    Button.Toggle(Key);
    Sound(Active);
end);

Button.Add("Blizz", 28, 13, 26, 13, function(Key, Active)
    Modem.broadcast(420, "Cow", Active);
    Button.Toggle(Key);
    Sound(Active);
end);

Button.Add("Slimes", 54, 13, 26, 13, function(Key, Active)
    Modem.broadcast(420, "Slime", Active);
    Button.Toggle(Key);
    Sound(Active);
end);

Button.Setup();
Button.Handle();