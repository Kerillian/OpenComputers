local fs = require("filesystem");
local kfs = {};

function kfs.readAll(path)
    if not fs.exists(path) then
        return false, "File does not exist.";
    end

    if fs.isDirectory(path) then
        return false, "Cannot open folder for reading.";
    end

    local size = fs.size(path);

    if size == 0 then
        return false, "File is empty.";
    end

    local handle = fs.open(path, "r");

    if not handle then
        return false, "Failed to open file.";
    end

    local data = handle:read(size);
    handle:close();

    return true, data;
end

function kfs.writeAll(path, value)
    if type(value) ~= "string" then
        value = tostring(value);
    end

    local handle = fs.open(path, "w");

    if not handle then
        return false, "Failed to open file.";
    end

    handle:write(value);
    handle:close();

    return true;
end

return kfs;