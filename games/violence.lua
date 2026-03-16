-- ==================== VIOLENCE DISTRICT - ULTIMATE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Features: Enhanced Player ESP, Speed, Jump, Noclip
-- Adapted from RanZx999 & LuckyBimZy

if _G.VD_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Violence District",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.VD_Loaded = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- VARIABLES
--==================================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

--==================================================
-- CONFIGURATION (Menggunakan format dari RanZx999)
--==================================================
getgenv().VDConfig = {
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Tracers = false,
        TeamCheck = true,
        MaxDistance = 2000
    },
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 16,
        JumpEnabled = false,
        JumpValue = 50,
        Noclip = false
    }
}

--// COLORS untuk ESP
local TeamColor = Color3.fromRGB(0, 255, 0)    -- Hijau untuk teammate
local EnemyColor = Color3.fromRGB(255, 0, 0)    -- Merah untuk enemy

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Violence District",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

--==================================================
-- TEAM CHECK FUNCTION (dari RanZx999)
--==================================================
local function isTeammate(player)
    if not Player.Team then return false end
    if not player.Team then return false end
    return player.Team == Player.Team
end

local function getPlayerColor(player)
    if VDConfig.ESP.TeamCheck and isTeammate(player) then
        return TeamColor
    else
        return EnemyColor
    end
end

--==================================================
-- ENHANCED PLAYER ESP (dari RanZx999)
--==================================================
local ESPObjects = {}

local function createPlayerESP(player)
    if player == Player then return end
    if ESPObjects[player] then return end
    
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }
    
    local esp = ESPObjects[player]
    
    -- Box setup
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    -- Name setup
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 15
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 2
    
    -- Distance setup
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 13
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 2
    
    -- Health bar background
    esp.HealthBarBG.Visible = false
    esp.HealthBarBG.Color = Color3.fromRGB(20, 20, 20)
    esp.HealthBarBG.Thickness = 1
    esp.HealthBarBG.Transparency = 0.8
    esp.HealthBarBG.Filled = true
    
    -- Health bar
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Filled = true
    
    -- Tracer setup
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 1
end

local function removePlayerESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function updatePlayerESP()
    if not VDConfig.ESP.Enabled then
        for _, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do 
                pcall(function() obj.Visible = false end)
            end
        end
        return
    end
    
    for player, esp in pairs(ESPObjects) do
        if not player or not player.Parent or not player.Character then
            removePlayerESP(player)
            continue
        end
        
        if VDConfig.ESP.TeamCheck and isTeammate(player) then
            for _, obj in pairs(esp) do 
                pcall(function() obj.Visible = false end)
            end
            continue
        end
        
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        local head = char:FindFirstChild("Head")
        
        if not hrp or not hum or not head then
            for _, obj in pairs(esp) do 
                pcall(function() obj.Visible = false end)
            end
            continue
        end
        
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        
        if distance > VDConfig.ESP.MaxDistance then
            for _, obj in pairs(esp) do 
                pcall(function() obj.Visible = false end)
            end
            continue
        end
        
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        local rootPos = Camera:WorldToViewportPoint(hrp.Position)
        
        if not onScreen then
            for _, obj in pairs(esp) do 
                pcall(function() obj.Visible = false end)
            end
            continue
        end
        
        local boxSize = Vector2.new(2000 / distance, 2500 / distance)
        local playerColor = getPlayerColor(player)
        
        -- Box ESP
        if VDConfig.ESP.Boxes then
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            esp.Box.Color = playerColor
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        -- Name ESP
        if VDConfig.ESP.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 35)
            esp.Name.Color = playerColor
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- Distance ESP
        if VDConfig.ESP.Distance then
            esp.Distance.Text = string.format("[%.0fm]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxSize.Y / 2 + 20)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        -- Health Bar
        if VDConfig.ESP.Health and hum then
            local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barWidth = 3
            local barHeight = boxSize.Y
            
            esp.HealthBarBG.Size = Vector2.new(barWidth, barHeight)
            esp.HealthBarBG.Position = Vector2.new(rootPos.X - boxSize.X / 2 - 5, rootPos.Y - boxSize.Y / 2)
            esp.HealthBarBG.Visible = true
            
            local healthColor = Color3.fromRGB(
                math.floor(255 * (1 - healthPercent)),
                math.floor(255 * healthPercent),
                0
            )
            esp.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
            esp.HealthBar.Position = Vector2.new(
                rootPos.X - boxSize.X / 2 - 5,
                rootPos.Y - boxSize.Y / 2 + barHeight * (1 - healthPercent)
            )
            esp.HealthBar.Color = healthColor
            esp.HealthBar.Visible = true
        else
            esp.HealthBarBG.Visible = false
            esp.HealthBar.Visible = false
        end
        
        -- Tracers
        if VDConfig.ESP.Tracers then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.From = screenCenter
            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            esp.Tracer.Color = playerColor
            esp.Tracer.Visible = true
        else
            esp.Tracer.Visible = false
        end
    end
end

local function setupPlayerESP(player)
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        task.wait(0.5)
        if VDConfig.ESP.Enabled then
            createPlayerESP(player)
        end
    end)
    
    if player.Character then
        task.spawn(function()
            player.Character:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
            if VDConfig.ESP.Enabled then
                createPlayerESP(player)
            end
        end)
    end
end

-- Setup ESP untuk semua player
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Player then
        setupPlayerESP(player)
    end
end

Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

--==================================================
-- NOCLIP FUNCTION (dari RanZx999)
--==================================================
local noclipConnection = nil

local function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not VDConfig.Movement.Noclip then return end
        
        local char = Player.Character
        if not char then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    task.wait(0.1)
    
    local char = Player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

--==================================================
-- MOVEMENT UPDATE
--==================================================
local function updateMovement()
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if VDConfig.Movement.SpeedEnabled then
        hum.WalkSpeed = VDConfig.Movement.SpeedValue
    end
    
    if VDConfig.Movement.JumpEnabled then
        hum.JumpPower = VDConfig.Movement.JumpValue
    end
end

-- Character update
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    if VDConfig.Movement.Noclip then
        enableNoclip()
    end
end)

--==================================================
-- CREATE MAIN WINDOW (Catraz Hub)
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Violence District",
    Subtext = "Ultimate Edition",
    Version = "v2.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VD_Ultimate",
    IntroEnabled = true,
    IntroText = "Violence District",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded successfully!")

--==================================================
-- CREATE TABS
--==================================================
local ESPTab = Window:MakeTab({
    Name = "Player ESP",
    Icon = "eye",
    Glass = true,
    Outline = true
})

local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- PLAYER ESP TAB
--==================================================
local ESPMainSection = ESPTab:AddSection({
    Name = "Player ESP (Enhanced)",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ESPMainSection:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPEnabled",
    Save = true,
    Callback = function(Value)
        VDConfig.ESP.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    createPlayerESP(player)
                end
            end
            Notify("Player ESP Enabled")
        else
            for player, _ in pairs(ESPObjects) do
                removePlayerESP(player)
            end
        end
    end
})

local ESPFeaturesSection = ESPTab:AddSection({
    Name = "ESP Features",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ESPFeaturesSection:AddToggle({
    Name = "📦 Show Boxes",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPBoxes",
    Save = true,
    Callback = function(Value) VDConfig.ESP.Boxes = Value end
})

ESPFeaturesSection:AddToggle({
    Name = "👤 Show Names",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPNames",
    Save = true,
    Callback = function(Value) VDConfig.ESP.Names = Value end
})

ESPFeaturesSection:AddToggle({
    Name = "📏 Show Distance",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPDistance",
    Save = true,
    Callback = function(Value) VDConfig.ESP.Distance = Value end
})

ESPFeaturesSection:AddToggle({
    Name = "❤️ Show Health",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPHealth",
    Save = true,
    Callback = function(Value) VDConfig.ESP.Health = Value end
})

ESPFeaturesSection:AddToggle({
    Name = "📍 Show Tracers",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPTracers",
    Save = true,
    Callback = function(Value) VDConfig.ESP.Tracers = Value end
})

local ESPSettingsSection = ESPTab:AddSection({
    Name = "ESP Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ESPSettingsSection:AddToggle({
    Name = "Team Check (Hide Teammates)",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPTeamCheck",
    Save = true,
    Callback = function(Value) VDConfig.ESP.TeamCheck = Value end
})

ESPSettingsSection:AddSlider({
    Name = "Max ESP Distance",
    Min = 500,
    Max = 5000,
    Default = 2000,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 100,
    ValueName = "m",
    Outline = true,
    Callback = function(Value) VDConfig.ESP.MaxDistance = Value end
})

ESPSettingsSection:AddParagraph({
    Title = "Color Guide",
    Desc = "🟢 Green = Teammate\n🔴 Red = Enemy",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- MOVEMENT TAB
--==================================================
local SpeedSection = MovementTab:AddSection({
    Name = "Speed Hack",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

SpeedSection:AddToggle({
    Name = "Enable Speed",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SpeedEnabled",
    Save = true,
    Callback = function(Value)
        VDConfig.Movement.SpeedEnabled = Value
        if not Value then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end
})

SpeedSection:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Callback = function(Value) VDConfig.Movement.SpeedValue = Value end
})

local JumpSection = MovementTab:AddSection({
    Name = "Jump Hack",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

JumpSection:AddToggle({
    Name = "Enable Jump",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "JumpEnabled",
    Save = true,
    Callback = function(Value)
        VDConfig.Movement.JumpEnabled = Value
        if not Value then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = 50 end
            end
        end
    end
})

JumpSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    ValueName = "JP",
    Outline = true,
    Callback = function(Value) VDConfig.Movement.JumpValue = Value end
})

local ExtraSection = MovementTab:AddSection({
    Name = "Extra Movement",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ExtraSection:AddToggle({
    Name = "👻 Noclip",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        VDConfig.Movement.Noclip = Value
        
        if Value then
            enableNoclip()
            Notify("Noclip Enabled - Walk through walls!")
        else
            disableNoclip()
            Notify("Noclip Disabled")
        end
    end
})

--==================================================
-- SETTINGS TAB
--==================================================
local InfoSection = SettingsTab:AddSection({
    Name = "Script Information",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

InfoSection:AddParagraph({
    Title = "Violence District",
    Desc = "Ultimate Edition v2.0\nFeatures: Enhanced ESP, Speed, Jump, Noclip\nAdapted for Catraz Hub",
    Image = "award",
    ImageSize = 38
})

local ControlSection = SettingsTab:AddSection({
    Name = "Controls",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ControlSection:AddButton({
    Name = "Destroy Script",
    Icon = "x",
    Outline = true,
    Callback = function()
        -- Clean up ESP
        for player, _ in pairs(ESPObjects) do
            removePlayerESP(player)
        end
        
        -- Disable noclip
        if VDConfig.Movement.Noclip then
            disableNoclip()
        end
        
        -- Reset movement
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
        end
        
        Notify("Script destroyed!")
        wait(1)
        OrionLib:Destroy()
        _G.VD_Loaded = false
    end
})

ControlSection:CreateLabel("• Toggle UI: Click floating button")
ControlSection:CreateLabel("• All features auto-save")

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

--==================================================
-- MAIN LOOP
--==================================================
RunService.Heartbeat:Connect(function()
    updateMovement()
    updatePlayerESP()
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 VIOLENCE DISTRICT - ULTIMATE EDITION 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Enhanced Player ESP - With Team Check")
print("✅ Speed Hack - Adjustable up to 200 WS")
print("✅ Jump Hack - Adjustable up to 300 JP")
print("✅ Noclip - Walk through walls")
print("═══════════════════════════════════════════════════════")
print("Adapted for Catraz Hub UI")
print("═══════════════════════════════════════════════════════")