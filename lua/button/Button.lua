local Libs = require("component");
local Term = require("term");
local Event = require("event");
local Screen = Libs.screen;
local GPU = Libs.gpu;
local w, h = GPU.getResolution();
local Handling = true;

local Button = {Data = {}};
local Color_Text = 0xFFFFFF;
local Color_Enabled = 0x00FF00;
local Color_Disabled = 0xFF0000;
local Color_Back = 0x000000;

local function Slice(tbl, first, last)
    local sliced = {};

    for i = first or 1, last or #tbl do
        sliced[#sliced + 1] = tbl[i];
    end

    return sliced;
end

local function EventFilter(name, ...)
    local args = {...};

    if name == "touch" then
        return {
            x = args[1],
            y = args[2]
        };
    elseif name == "screen_resized" then
        return {
            width = args[1],
            height = args[2]
        };
    elseif name == "modem_message" then
        return {
            receiver = args[1],
            sender = args[2],
            port = args[3],
            distance = args[4],
            args = Slice(args, 5)
        };
    end
end

function Button.Clear(buttons)
    if buttons then
        Button.Data = {};
    end

    GPU.setBackground(Color_Back);
    GPU.fill(1, 1, w, h, " ");
end

function Button.SetData(data)
    Button.Clear();
    Button.Data = data;
    Button.Draw();
end

function Button.Add(name, px, py, w, h, callback)
    Button.Data[name] = {Active = false, x = px, y = py, Width = w, Height = h, Callback = callback};
end

function Button.Fill(text, color, v);
    local yspot = math.floor((v.y + (v.y + v.Height)) / 2);
    local xspot = math.floor((v.x + (v.x + v.Width) - string.len(text)) / 2) + 1;
    local BackOld = GPU.setBackground(color);
    local ForOld = GPU.setForeground(Color_Text);

    GPU.fill(v.x, v.y, v.Width, v.Height, " ");
    GPU.set(xspot, yspot, text);
    GPU.setBackground(BackOld);
    GPU.setForeground(ForOld);
end

function Button.Draw()
    for k,v in pairs(Button.Data) do
        local color = v.Active and Color_Enabled or Color_Disabled;
        Button.Fill(k, color, v);
    end
end

function Button.Toggle(name)
    Button.Data[name].Active = not Button.Data[name].Active;
    Button.Draw();

    return Button.Data[name].Active;
end

function Button.Flash(name, length)
    Button.Toggle(name);
    Button.Draw();
    os.sleep(length);
    Button.Toggle(name);
    Button.Draw();
end

function Button.FindInPos(x, y)
    for k,v in pairs(Button.Data) do
        if x >= v.x and x <= (v.x + v.Width) - 1 then
            if y >= v.y and y <= (v.y + v.Height) - 1 then
                return true, k, v;
            end
        end
    end
    return false;
end

function Button.Handle(Custom)
    Handling = true;

    while Handling do
        --local _, _, x, y = Event.pull("touch");
        local name, data = event.pullFiltered(EventFilter);

        if name == "touch" then
            if data.x == nil or data.y == nil then
                w, h = GPU.getResolution();
                Button.Clear();
                Button.Draw();
            else
                local Found, Key, Struct = Button.FindInPos(data.x, data.y);

                if Found then
                    if Custom then
                        Custom(Key, Struct);
                    else
                        Struct.Callback(Key, not Struct.Active);
                    end
                end
            end
        elseif name == "screen_resized" then
            w, h = GPU.getResolution();
            Button.Clear();
            Button.Draw();
        elseif name == "modem_message" then

        end
    end
end

function Button.Exit()
    Handling = false;
end

function Button.Setup(width, height)
    Term.setCursorBlink(false);
    GPU.setResolution(width and width or 80, height and height or 25);
    Screen.setTouchModeInverted(true);
    Button.Clear();
    Button.Draw();
end

function Button.Label(x, y, text)
    Term.setCursor(x, y);
    Term.write(text);
end

function Button.SetEnabledColor(color)
    local old = Color_Enabled;
    Color_Enabled = color;

    return old;
end

function Button.SetDisabledColor(color)
    local old = Color_Disabled;
    Color_Disabled = color;

    return old;
end

function Button.SetTextColor(color)
    local old = Color_Text;
    Color_Text = color;

    return old;
end

function Button.SetBackColor(color)
    local old = Color_Back;
    Color_Back = color;

    return old;
end

return Button;