local event = require("event");
local component = require("component");
local fs = require("filesystem");
local serialization = require("serialization");
local modem = component.modem;

local CONFIG = "/etc/dns-server.cfg";
local commands = {};
local registed = {
    domains = {},
    addresses = {}
}

modem.open(53);

local function loadEntries()
    if fs.exists(CONFIG) then
        local size = fs.size(CONFIG);
        local handle = fs.open(CONFIG, "r");

        local data = serialization.unserialize(handle:read(size));

        if data and data.domains and data.addresses then
            registed = data;
        end

        handle:close();
    end
end

local function saveEntries()
    local handle = fs.open(CONFIG, "w");
    handle:write(serialization.serialize(registed));
    handle:close();
end

function commands.ping()
    return true;
end

function commands.resolve(_, domain)
    local addr = registed.domains[domain];

    if addr then
        return true, addr;
    end

    return false, "No address assigned to domain.";
end

function commands.reverse(_, addr)
    local domain = registed.addresses[addr];

    if domain then
        return true, domain;
    end

    return false, "No domain associated with address.";
end

function commands.register(remoteAddr, domain)
    if registed.domains[domain] then
        return false, "Domain already registered.";
    end

    if registed.addresses[remoteAddr] then
        return false, "IP address already assigned.";
    end

    registed.addresses[remoteAddr] = domain;
    registed.domains[domain] = remoteAddr;

    saveEntries();

    return true, "Domain registered.";
end

function commands.relinquish(remoteAddr)
    local domain = registed.addresses[remoteAddr];

    if not domain then
        return false, "No domain found for address.";
    end

    registed.domains[domain] = nil;
    registed.addresses[remoteAddr] = nil;

    saveEntries();

    return true, "Relinquished domain.";
end

local function Listen()
    while true do
        local event, _, remoteAddr, port, _, command, domain = event.pullMultiple("modem_message", "interrupted");

        if event == "interrupted" then
            break;
        end

        if port == 53 then
            print("DNS packet from '" .. remoteAddr .. "' -> " .. tostring(command) .. " -> " .. tostring(domain));

            local func = commands[command];

            if func then
                modem.send(remoteAddr, 53, func(remoteAddr, domain));
            else
                modem.send(remoteAddr, 53, false, "Invalid command.");
            end
        end
    end
end

print("Hosting DNS on port 53: " .. modem.address);

loadEntries();
Listen();