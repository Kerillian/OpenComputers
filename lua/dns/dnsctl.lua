local dns = require("dns");
local args = {...};

if #args < 1 then
    print("Usage:");
    print("dnsctl provider [address]");
    print("dnsctl clear");
    print("dnsctl resolve [domain]");
    print("dnsctl reverse [addr]");
    print("dnsctl register [domain]");
    print("dnsctl relinquish");
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
    print("DNS cached cleared.");
    return;
end

if dns[command] then
    local arg2 = args[2];
    local ok, value = dns[command](arg2);

    if ok then
        print(value);
    else
        io.stderr:write(value);
    end
end