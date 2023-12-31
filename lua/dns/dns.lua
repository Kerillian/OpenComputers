local event = require("event");
local fs = require("filesystem");
local component = require("component");
local modem = component.modem;

local dns = {
    cache = {},
    provider = nil
};

local function saveConfig()
    local handle = fs.open("/etc/dns.cfg", "w");
    handle:write(dns.provider or "");
    handle:close();
end

local function loadConfig()
    if fs.exists("/etc/dns.cfg") then
        local size = fs.size("/etc/dns.cfg");

        if size > 0 then
            local handle = fs.open("/etc/dns.cfg", "r");
            local data = handle:read(size);
            handle:close();

            if type(data) == "string" and #data > 0 then
                dns.provider = data;
            end
        end
    end
end

function dns.clearCache()
    dns.cache = {};
end

function dns.setProvider(addr)
    dns.provider = addr;
    saveConfig();
end

function dns.sendCommand(...)
    modem.open(53);

    if dns.provider then
        modem.send(dns.data.provider, 53, ...);
    else
        modem.broadcast(53, ...);
    end

    for _ = 1, 3 do
        local event, _, _, _, _, status, value = event.pull(2, "modem_message", nil, dns.provider, 53);

        if event then
            modem.close(53);
            return status, value;
        end
    end

    modem.close(53);
    return false, "No repsonse from DNS server after 3 retries.";
end

function dns.scan()
    local pongs = {};
    local found = 0;

    modem.open(53);
    modem.broadcast(53, "scan");

    for _ = 1, 100 do
        local event, _, remoteAddr, _, distance = event.pull(2, "modem_message", nil, nil, 53);

        -- If 2 seconds have passed and we got no messages we don't need to continue checking.
        if not event then
            break;
        end

        pongs[remoteAddr] = distance;
        found = found + 1;
    end

    modem.close(53);
    return found, pongs;
end

function dns.resolve(domain)
    if dns.cache[domain] then
        return true, dns.cache[domain];
    end

    local ok, addr = dns.sendCommand("resolve", domain);

    if ok then
        dns.cache[domain] = addr;
    end

    return ok, addr;
end

function dns.reverse(addr)
    if dns.cache[addr] then
        return true, dns.cache[addr];
    end

    local ok, domain = dns.sendCommand("reverse", addr);

    if ok then
        dns.cache[addr] = domain;
    end

    return ok, domain;
end

function dns.register(domain)
    return dns.sendCommand("register", domain);
end

function dns.relinquish()
    return dns.sendCommand("relinquish");
end

loadConfig();
return dns;