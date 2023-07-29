local event = require("event");

while true do
    local event, remoteAddr, command, domain = event.pullMultiple("dns_log", "interrupted");

    if event == "interrupted" then
        break;
    end

    print(remoteAddr .. "' -> " .. tostring(command) .. " -> " .. tostring(domain))
end