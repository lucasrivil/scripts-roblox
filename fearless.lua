local repo = "https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "Fearless Hub",
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Aimbots"), 
    Setting = Window:AddTab("UI Settings"),
}

local camlockgroup = Tabs.Main:AddLeftGroupbox("Cam Lock")
local espgroup = Tabs.Main:AddRightGroupbox("ESP")

local esp_ = false
local health_ = false

-- settings
local settings = {
    defaultcolor = Color3.fromRGB(255,0,0),
    healthbarcolor = Color3.fromRGB(0,255,0),
    teamcheck = false,
    teamcolor = true
 };
 
 -- services
 local runService = game:GetService("RunService");
 local players = game:GetService("Players");
 
 -- variables
 local localPlayer = players.LocalPlayer;
 local camera = workspace.CurrentCamera;
 
 -- functions
 local newVector2, newColor3, newDrawing = Vector2.new, Color3.new, Drawing.new;
 local tan, rad = math.tan, math.rad;
 local round = function(...) local a = {}; for i,v in next, table.pack(...) do a[i] = math.round(v); end return unpack(a); end;
 local wtvp = function(...) local a, b = camera.WorldToViewportPoint(camera, ...) return newVector2(a.X, a.Y), b, a.Z end;
 
 local espCache = {};
 local function createEsp(player)
    local drawings = {};
    
    drawings.box = newDrawing("Square");
    drawings.box.Thickness = 1;
    drawings.box.Filled = false;
    drawings.box.Color = settings.defaultcolor;
    drawings.box.Visible = false;
    drawings.box.ZIndex = 2;
 
    drawings.boxoutline = newDrawing("Square");
    drawings.boxoutline.Thickness = 3;
    drawings.boxoutline.Filled = false;
    drawings.boxoutline.Color = settings.defaultcolor;
    drawings.boxoutline.Visible = false;
    drawings.boxoutline.ZIndex = 1;

    drawings.name = newDrawing("Text");
    drawings.name.Text = player.Name;
    drawings.name.Size = 20;
    drawings.name.Center = true;
    drawings.name.Outline = true;
    drawings.name.Visible = false;
    drawings.name.Color = settings.defaultcolor;
    drawings.name.ZIndex = 3;

    drawings.healthbar = newDrawing("Square");
    drawings.healthbar.Thickness = 1;
    drawings.healthbar.Filled = false;
    drawings.healthbar.Color = settings.healthbarcolor;
    drawings.healthbar.Visible = false;
    drawings.healthbar.ZIndex = 2;
    drawings.healthbar.Size = newVector2(100, 3);
 
    espCache[player] = drawings;
 end
 
 local function removeEsp(player)
    if rawget(espCache, player) then
        for _, drawing in next, espCache[player] do
            drawing:Remove();
        end
        espCache[player] = nil;
    end
 end
 
 local function updateEsp(player, esp)
    local character = player and player.Character;
    if character then
        local cframe = character:GetModelCFrame();
        local position, visible, depth = wtvp(cframe.Position);
        esp.box.Visible = visible;
        esp.boxoutline.Visible = visible;
        if Toggles.name.Value then
            esp.name.Visible = visible;
        else
            esp.name.Visible = false;
        end
        if Toggles.health.Value then
            esp.healthbar.Visible = visible;
        else
            esp.healthbar.Visible = false;
        end
 
        if cframe and visible then
            local scaleFactor = 1 / (depth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000;
            local width, height = round(4 * scaleFactor, 5 * scaleFactor);
            local x, y = round(position.X, position.Y);
 
            esp.box.Size = newVector2(width, height);
            esp.box.Position = newVector2(round(x - width / 2, y - height / 2));
            esp.box.Color = settings.defaultcolor;
 
            esp.boxoutline.Size = esp.box.Size;
            esp.boxoutline.Position = esp.box.Position;
            
            if Toggles.name.Value then
                esp.name.Text = player.Name;
            else
                esp.name.Text = "";
            end

            esp.name.Size = 20;
            esp.name.Position = newVector2(x, y - height / 2 - 20);
            esp.name.Color = settings.defaultcolor;

            humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            health = humanoid.Health
            if Toggles.health.Value then
                esp.healthbar.Size = newVector2(health, 3);
            else
                esp.healthbar.Size = newVector2(0, 0);
            end
            esp.healthbar.Size = newVector2(health, 3);
            esp.healthbar.Position = newVector2(x - width / 2, y + height / 2 + 3);
            esp.healthbar.Color = settings.healthbarcolor;
        end
    else
        esp.box.Visible = false;
        esp.boxoutline.Visible = false;
        esp.name.Visible = false;
        esp.healthbar.Visible = false;
    end
end

espgroup:AddLabel('Color'):AddColorPicker('ColorPicker', {
    Default = Color3.new(0, 1, 0), -- Bright green
    Title = 'ESP color', -- Optional. Allows you to have a custom color picker title (when you open it)
    Callback = function(Value)
        r = Value.r * 255
        g = Value.g * 255
        b = Value.b * 255
        settings.defaultcolor = Color3.fromRGB(r,g,b)
        if esp_ then
            for _, player in next, players:GetPlayers() do
                if player ~= localPlayer then
                    removeEsp(player);
                    createEsp(player);
                end
            end
        end
    end
})

espgroup:AddToggle("esp", {
    Text = "ESP",
    Default = false,
    Tooltip = "Activate ESP",
})

espgroup:AddToggle("name", {
    Text = "ESP name",
    Default = false,
    Tooltip = "Activate ESP name",
})

espgroup:AddToggle("health", {
    Text = "Health bar",
    Default = false,
    Tooltip = "Activate health bar",
})

Toggles.health:OnChanged(function()
    if Toggles.health.Value then
        health_ = true
    else
        health_ = false
    end
end)

espgroup:AddLabel('Keybind'):AddKeyPicker('KeyESP', {
    Default = 'E',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Keybind',
    NoUI = false,
    Callback = function(Value)
        Toggles.esp:SetValue(Value)
    end,
    ChangedCallback = function(New)
        return
    end
})

Toggles.esp:SetValue(false)

Toggles.esp:OnChanged(function()
    if Toggles.esp.Value then
        esp_ = true
        for _, player in next, players:GetPlayers() do
            if player ~= localPlayer then
                createEsp(player);
            end
        end
    else
        esp_ = false
        for _, player in next, players:GetPlayers() do
            if player ~= localPlayer then
                removeEsp(player);
            end
        end
    end
end)

runService.RenderStepped:Connect(function()
    if esp_ then
        for _, player in next, players:GetPlayers() do
            if player ~= localPlayer then
                updateEsp(player, espCache[player]);
            end
        end
    end
end)

camlockgroup:AddLabel('Keybind'):AddKeyPicker('KeyPicker', {
    Default = 'C',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Keybind',
    NoUI = false,
    Callback = function(Value)
        Toggles.camlock:SetValue(Value)
    end,
    ChangedCallback = function(New)
        return
    end
})

camlockgroup:AddToggle("camlock", {
    Text = "Cam Lock",
    Default = false,
    Tooltip = "Activates Cam Lock",
})

Toggles.camlock:SetValue(false)

Prediction = "0.1"

camlockgroup:AddSlider("prediction", {
    Text = "Prediction",
    Default = 1,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        Prediction = tostring(Value/100)
    end
})

AimPart = "Head"

camlockgroup:AddDropdown("part", {
    Values = { "Head", "LeftFoot", "LeftHand", "LeftLowerArm", "LeftLowerLeg", "LeftUpperArm", "LeftUpperLeg", "LowerTorso", "RightFoot", "RightHand", "RightLowerArm", "RightLowerLeg", "RightUpperArm", "RightUpperLeg", "UpperTorso", "HumanoidRootPart" },
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = "Aim Part",
    Tooltip = "Select part for aim !", -- Information shown when you hover over the textbox

    Callback = function(Value)
        AimPart = Value
    end
})

local MenuGroup = Tabs.Setting:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('Fearless')
SaveManager:SetFolder('Fearless/specific-game')
SaveManager:BuildConfigSection(Tabs.Setting)
ThemeManager:ApplyToTab(Tabs.Setting)

-------------------------------------------------------------------

--// Variables (Service)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local GS = game:GetService("GuiService")
local SG = game:GetService("StarterGui")

--// Variables (regular)

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = WS.CurrentCamera
local GetGuiInset = GS.GetGuiInset

local AimlockState = false
local Locked
local Victim

--// Notification function

function Notify(tx)
    SG:SetCore("SendNotification", {
        Title = "Cam Lock Enabled | .gg/thusky",
        Text = tx,
        Duration = 5
    })
end

--// Check if aimlock is loaded

if Loaded == true then
    Notify("Aimlock is already loaded!")
    return
end

Loaded = true

--// FOV Circle

local fov = Drawing.new("Circle")
fov.Filled = false
fov.Transparency = 1
fov.Thickness = 1
fov.Color = Color3.fromRGB(255, 255, 0)
fov.NumSides = 1000

--// Functions

function update()
    if FOV == true then
        if fov then
            fov.Radius = FOVSize * 2
            fov.Visible = ShowFOV
            fov.Position = Vector2.new(Mouse.X, Mouse.Y + GetGuiInset(GS).Y)

            return fov
        end
    end
end

function WTVP(arg)
    return Camera:WorldToViewportPoint(arg)
end

function WTSP(arg)
    return Camera.WorldToScreenPoint(Camera, arg)
end

function getClosest()
    local closestPlayer
    local shortestDistance = math.huge

    for i, v in pairs(game.Players:GetPlayers()) do
        local notKO = v.Character:WaitForChild("BodyEffects")["K.O"].Value ~= true
        local notGrabbed = v.Character:FindFirstChild("GRABBING_COINSTRAINT") == nil
        
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild(AimPart) and notKO and notGrabbed then
            local pos = Camera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
            
            if (FOV) then
                if (fov.Radius > magnitude and magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            else
                if (magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end
    return closestPlayer
end
 
--// Checks if key is down

Toggles.camlock:OnChanged(function()
    if Toggles.camlock.Value == true then
        AimlockState = true
    else
        AimlockState = false
    end
    if AimlockState == true then
        Locked = not Locked
        if Locked then
            Victim = getClosest()
        else
            if Victim ~= nil then
                Victim = nil
            end
        end
    end
end)

--// Loop update FOV and loop camera lock onto target

RS.RenderStepped:Connect(function()
    update()
    if AimlockState == true then
        if Victim ~= nil then
            Camera.CFrame = CFrame.new(Camera.CFrame.p, Victim.Character[AimPart].Position + Victim.Character[AimPart].Velocity*Prediction)
        end
    end
end)
while wait() do
    if AutoPrediction == true then
        local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local split = string.split(pingvalue,"(")
        local ping = tonumber(split[1])
            if ping < 225 then
            Prediction = 1.4
        elseif ping < 215 then
            Prediction = 1.2
	    elseif ping < 205 then
            Prediction = 1.0
	    elseif ping < 190 then
            Prediction = 0.10
        elseif ping < 180 then
            Prediction = 0.12
	    elseif ping < 170 then
            Prediction = 0.15
	    elseif ping < 160 then
            Prediction = 0.18
	    elseif ping < 150 then
            Prediction = 0.110
        elseif ping < 140 then
            Prediction = 0.113
        elseif ping < 130 then
            Prediction = 0.116
        elseif ping < 120 then
            Prediction = 0.120
        elseif ping < 110 then
            Prediction = 0.124
        elseif ping < 105 then
            Prediction = 0.127
        elseif ping < 90 then
            Prediction = 0.130
        elseif ping < 80 then
            Prediction = 0.133
        elseif ping < 70 then
            Prediction = 0.136
        elseif ping < 60 then
            Prediction = 0.15038
        elseif ping < 50 then
            Prediction = 0.15038
        elseif ping < 40 then
            Prediction = 0.145
        elseif ping < 30 then
            Prediction = 0.155
        elseif ping < 20 then
            Prediction = 0.157
        end
    end
end
