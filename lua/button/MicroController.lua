local RS = component.proxy(component.list("redstone")());
local Modem = component.proxy(component.list("modem")());
local Me = "Lights"; --Remember to set this.

Modem.open(420);

while true do
    local _, _, _, _, _, Name, Toggle = computer.pullSignal("modem_message");

    if type(Name) == "string" and type(Toggle) == "boolean" then
        if Name == Me then
            local Power = Toggle and 15 or 0;
            RS.setOutput(3, Power);
        end
    end
end