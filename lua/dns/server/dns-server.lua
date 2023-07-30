---@diagnostic disable: lowercase-global
local event = require("event");
local component = require("component");
local kfs = require("libk.fs");
local serialization = require("serialization");
local modem = component.modem;

local CONFIG = "/etc/dns-server.cfg";
local commands = {};
local registed = {
    domains = {},
    addresses = {}
}

local function loadEntries()
    local ok, value = kfs.readAll(CONFIG);

    if ok then
        local data = serialization.unserialize(value);

        if data and data.domains and data.addresses then
            registed = data;
        end
    end
end

local function saveEntries()
    kfs.writeAll(CONFIG, serialization.serialize(registed));
end

function commands.scan()
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

local function onMessage(_, localAddr, remoteAddr, port, distance, command, domain)
    if port == 53 then
        --print("DNS packet from '" .. remoteAddr .. "' -> " .. tostring(command) .. " -> " .. tostring(domain));

        event.push("dns_log", remoteAddr, command, domain);

        local func = commands[command];

        if func then
            modem.send(remoteAddr, 53, func(remoteAddr, domain));
        else
            modem.send(remoteAddr, 53, false, "Invalid command.");
        end
    end
end

function help()
    print("rc dns-server help");
    print("rc dns-server resolve [domain]");
    print("rc dns-server reverse [addr]");
    print("rc dns-server relinquish [domain|addr]");
    print("rc dns-server search [domain|addr]");
end

function resolve(domain)
    print(commands.resolve(nil, domain));
end

function reverse(addr)
    print(commands.reverse(nil, addr));
end

function relinquish(target)
    if registed.domains[target] then
        target = registed.domains[target];
    end

    print(commands.relinquish(target));
end

function search(query)
    local results = {};

    for k,v in pairs(registed.domains) do
        if string.find(k, query) then
            results[k] = v;
        end
    end

    for k,v in pairs(registed.addresses) do
        if string.find(k, query) then
            results[k] = v;
        end
    end

    for k,v in pairs(results) do
        print(k, v);
    end
end

function start()
    print("Serving DNS on port 53: " .. modem.address);

    loadEntries();
    modem.open(53);

    event.listen("modem_message", onMessage);
end

function stop()
    print("No longer serving DNS on port 53: " .. modem.address);

    event.ignore("modem_message", onMessage);

    modem.close(53);
    saveEntries();
end