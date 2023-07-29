local event = require("event");

if #{...} < 1 then
    print("Commands:");
    print("dns-manage resolve [domain]");
    print("dns-manage reverse [address]");
    print("dns-manage relinquish [domain|address]");
    return;
end

event.push("dns_manage_request", ...);

local event, ok, value = event.pull(2, "dns_manage_response");

if not event then
    io.stderr:write("DNS Service did not respond, is it running?");
    return;
end

if ok then
    print(value);
    return;
end

io.stderr:write(value);