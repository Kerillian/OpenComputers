local component = require("component");
local fs = require("filesystem");
local shell = require("shell");
local eeprom = component.eeprom;
local args = {...};

local path = args[1] and shell.resolve(args[1]) or shell.resolve("bios.lua");
local label = args[2] or "EEPROM (QFlash)";

if string.match(eeprom.getLabel(), "EEPROM %(Lua BIOS%)") then
    print("Try flashing an EEPROM thats not preflashed with Lua, K?");
    return;
end

if fs.exists(path) then
    local size = fs.size(path);

    if size > 0 then
        local handle = fs.open(path, "r");
        local data = handle:read(size);
        handle:close();

        print("Flashing EEPROM...");
        local ok, err = pcall(function()
            eeprom.set(data);
        end);

        if ok then
            eeprom.setLabel(label);
            print("Wrote " .. tostring(size) .. " bytes to EEPROM.");
        else
            print("Failed to write to EEPROM. (" .. tostring(err) .. ")");
        end
    else
        print("File has zero bytes.");
    end
else
    print("File not found.");
end