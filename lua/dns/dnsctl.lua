local dns = require("dns");
local args = {...};

local function help()
    print("Usage:");
    print("dnsctl scan               - Scan for dns servers.");
    print("dnsctl clear              - Clear the dns cache.");
    print("dnsctl provider [address] - Set primary dns server.");
    print("dnsctl resolve [domain]   - Resolve a domain name.");
    print("dnsctl reverse [addr]     - Lookup an address.");
    print("dnsctl register [domain]  - Register domain name.");
    print("dnsctl relinquish         - Relinquish domain name.");
end

if #args < 1 then
    help();
    return;
end

local command = args[1];

if command == "provider" then
    if args[2] then
        dns.setProvider(args[2]);
        print("DNS Provider set.");
        return;
    end

    print("Current Provider: " .. tostring(dns.provider));
    return;
end

if command == "clear" then
    dns.clearCache();
    print("DNS cache cleared.");
    return;
end

if command == "scan" then
    local found, pongs = dns.scan();

    if found > 0 then
        for k, v in pairs(pongs) do
            print(k .. " (" .. v .. ")");
        end
    else
        io.stderr:write("No DNS servers found.");
    end

    return;
end

if command == "resolve" then
    if args[2] then
        local ok, value = dns.resolve(args[2]);

        if ok then
            print(args[2] .. " -> " .. value);
        else
            io.stderr:write(value);
        end
    end

    return;
end

if command == "reverse" then
    if args[2] then
        local ok, value = dns.reverse(args[2]);

        if ok then
            print(args[2] .. " -> " .. value);
        else
            io.stderr:write(value);
        end
    end

    return;
end

if command == "register" then
    if args[2] then
        local ok, message = dns.register(args[2]);

        if ok then
            print(message);
        else
            io.stderr:write(message);
        end
    end

    return;
end

if command == "relinquish" then
    local ok, message = dns.relinquish();

    if ok then
        print(message);
    else
        io.stderr:write(message);
    end

    return;
end

help();