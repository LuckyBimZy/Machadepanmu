-- ==================== VIOLENCE DISTRICT - COMPLETE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.0 COMPLETE

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
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StartTime = tick()

--==================================================
-- COLORS
--==================================================
local TeamColor = Color3.fromRGB(0, 255, 0)
local EnemyColor = Color3.fromRGB(255, 0, 0)

--==================================================
-- CONFIG
--==================================================
local Config = {
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Tracers = false,
        TeamCheck = true,
        MaxDistance = 2000,
        ShowTeammates = false
    },
    Highlight = {
        Enabled = false,
        TeamCheck = true,
        ShowTeam = false
    },
    Generator = {
        ESPEnabled = false,
        AntiFailEnabled = false
    },
    Healing = {
        AntiFailEnabled = false
    },
    UI = {
        HideSkillCheck = false
    },
    Visual = {
        FullbrightEnabled = false,
        NoFogEnabled = false,
        WallhackEnabled = false,
        SuperZoomEnabled = false,
        AntiAliasing = false,
        PerformanceMode = false,
        ZoomDistance = 70
    },
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 16,
        JumpEnabled = false,
        JumpValue = 50,
        InfiniteJump = false,
        Noclip = false
    },
    Misc = {
        AntiAFK = false,
        ActiveFeatures = {}
    },
    Teleport = {
        SavedPosition = nil
    }
}

--==================================================
-- SAVE ORIGINAL LIGHTING
--==================================================
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

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
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Violence District",
    Subtext = "COMPLETE Edition",
    Version = "v3.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VD_COMPLETE",
    IntroEnabled = true,
    IntroText = "Violence District COMPLETE",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    
    -- Custom Theme & Appearance
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    -- Floating Toggle Customization
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded successfully!")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

local ESPTab = Window:MakeTab({
    Name = "Player ESP",
    Icon = "eye",
    Glass = true,
    Outline = true
})

local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "footprints",
    Glass = true,
    Outline = true
})

local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "sun",
    Glass = true,
    Outline = true
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "map-pin",
    Glass = true,
    Outline = true
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- MAIN TAB - PLAYER INFO
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "Player Information",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Function to update player info
local PlayerInfoParagraph = PlayerInfoSection:AddParagraph({
    Title = Player.Name,
    Desc = string.format(
        "Display Name: %s\nUser ID: %d\nAccount Age: %d days\nTeam: %s",
        Player.DisplayName,
        Player.UserId,
        Player.AccountAge,
        Player.Team and Player.Team.Name or "No Team"
    ),
    Image = "user",
    ImageSize = 48
})

local ServerInfoSection = MainTab:AddSection({
    Name = "Server Information",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Live updating server info
local ServerInfoParagraph = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = "Players: 0\nPing: 0ms\nUptime: 0m",
    Image = "server",
    ImageSize = 48,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                -- Refresh will be handled by the loop
            end
        }
    }
})

-- Live update for server info
task.spawn(function()
    while true do
        local players = #Players:GetPlayers()
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        local uptime = math.floor((tick() - StartTime) / 60)
        
        ServerInfoParagraph:SetDesc(string.format(
            "Players: %d\nPing: %dms\nUptime: %dm",
            players,
            ping,
            uptime
        ))
        
        -- Update player info in case team changes
        PlayerInfoParagraph:SetDesc(string.format(
            "Display Name: %s\nUser ID: %d\nAccount Age: %d days\nTeam: %s",
            Player.DisplayName,
            Player.UserId,
            Player.AccountAge,
            Player.Team and Player.Team.Name or "No Team"
        ))
        
        task.wait(1)
    end
end)

--==================================================
-- TEAM CHECK FUNCTION
--==================================================
local function isTeammate(player)
    if not Player.Team then return false end
    if not player.Team then return false end
    return player.Team == Player.Team
end

local function getPlayerColor(player)
    if Config.ESP.TeamCheck and isTeammate(player) then
        return TeamColor
    else
        return EnemyColor
    end
end

--==================================================
-- PLAYER ESP SYSTEM (AUTO-DETECT)
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
    
    -- Box settings
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    -- Name settings (BESAR DAN TEBAL - sesuai permintaan)
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 22  -- Ukuran 22 seperti diminta
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 2  -- Bold
    
    -- Distance settings
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 16
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 2
    
    -- Health bar settings
    esp.HealthBarBG.Visible = false
    esp.HealthBarBG.Color = Color3.fromRGB(20, 20, 20)
    esp.HealthBarBG.Thickness = 1
    esp.HealthBarBG.Transparency = 0.8
    esp.HealthBarBG.Filled = true
    
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Filled = true
    
    -- Tracer settings
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
    if not Config.ESP.Enabled then
        for _, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do obj.Visible = false end
        end
        return
    end
    
    for player, esp in pairs(ESPObjects) do
        if not player or not player.Parent or not player.Character then
            removePlayerESP(player)
            continue
        end
        
        if Config.ESP.TeamCheck and isTeammate(player) and not Config.ESP.ShowTeammates then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        local head = char:FindFirstChild("Head")
        
        if not hrp or not hum or not head then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        
        if distance > Config.ESP.MaxDistance then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        local rootPos = Camera:WorldToViewportPoint(hrp.Position)
        
        if not onScreen then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        local boxSize = Vector2.new(2000 / distance, 2500 / distance)
        local playerColor = getPlayerColor(player)
        
        if Config.ESP.Boxes then
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            esp.Box.Color = playerColor
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        if Config.ESP.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 40)
            esp.Name.Color = playerColor
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        if Config.ESP.Distance then
            esp.Distance.Text = string.format("[%.0fm]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxSize.Y / 2 + 25)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        if Config.ESP.Health and hum then
            local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barWidth = 4
            local barHeight = boxSize.Y
            
            esp.HealthBarBG.Size = Vector2.new(barWidth, barHeight)
            esp.HealthBarBG.Position = Vector2.new(rootPos.X - boxSize.X / 2 - 8, rootPos.Y - boxSize.Y / 2)
            esp.HealthBarBG.Visible = true
            
            local healthColor = Color3.fromRGB(
                math.floor(255 * (1 - healthPercent)),
                math.floor(255 * healthPercent),
                0
            )
            esp.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
            esp.HealthBar.Position = Vector2.new(
                rootPos.X - boxSize.X / 2 - 8,
                rootPos.Y - boxSize.Y / 2 + barHeight * (1 - healthPercent)
            )
            esp.HealthBar.Color = healthColor
            esp.HealthBar.Visible = true
        else
            esp.HealthBarBG.Visible = false
            esp.HealthBar.Visible = false
        end
        
        if Config.ESP.Tracers then
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

--==================================================
-- WALLHACK FUNCTION
--==================================================
local wallhackConnection = nil

local function updateWallhack()
    if Config.Visual.WallhackEnabled then
        if not wallhackConnection then
            wallhackConnection = RunService.RenderStepped:Connect(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
                        if v.Transparency < 0.5 then
                            v.Material = Enum.Material.ForceField
                            v.Transparency = 0.5
                        end
                    end
                end
            end)
        end
    else
        if wallhackConnection then
            wallhackConnection:Disconnect()
            wallhackConnection = nil
        end
        
        -- Restore normal materials
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
            end
        end
    end
end

--==================================================
-- MOVEMENT SYSTEM (LENGKAP)
--==================================================
local noclipConnection = nil
local infiniteJumpConnection = nil

local function updateMovement()
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    -- Speed Hack dengan return to normal
    if Config.Movement.SpeedEnabled then
        hum.WalkSpeed = Config.Movement.SpeedValue
    else
        hum.WalkSpeed = 16
    end
    
    -- Jump Hack dengan return to normal
    if Config.Movement.JumpEnabled then
        hum.JumpPower = Config.Movement.JumpValue
    else
        hum.JumpPower = 50
    end
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfiniteJump then
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Noclip
local function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not Config.Movement.Noclip then return end
        
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
-- VISUAL FEATURES (LENGKAP)
--==================================================
-- Fullbright
local function updateFullbright()
    if Config.Visual.FullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
end

-- No Fog
local function updateNoFog()
    if Config.Visual.NoFogEnabled then
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then
                v.Density = 0
                v.Offset = 0
                v.Glare = 0
                v.Haze = 0
            end
        end
    else
        Lighting.FogStart = originalLighting.FogStart or 0
        Lighting.FogEnd = originalLighting.FogEnd
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") and originalLighting.Atmosphere then
                v.Density = originalLighting.Atmosphere.Density or 0.3
                v.Offset = originalLighting.Atmosphere.Offset or 0.25
                v.Glare = originalLighting.Atmosphere.Glare or 0
                v.Haze = originalLighting.Atmosphere.Haze or 0
            end
        end
    end
end

-- Super Zoom Out
local function updateSuperZoom()
    if Config.Visual.SuperZoomEnabled then
        Camera.FieldOfView = 120
    else
        Camera.FieldOfView = 70
    end
end

-- Anti-Aliasing & Graphics Quality
local function updateGraphicsQuality()
    if Config.Visual.AntiAliasing then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
    end
    
    if Config.Visual.PerformanceMode then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.Brightness = 1
    end
end

-- Reset Visual
local function resetVisual()
    Config.Visual.FullbrightEnabled = false
    Config.Visual.NoFogEnabled = false
    Config.Visual.WallhackEnabled = false
    Config.Visual.SuperZoomEnabled = false
    Config.Visual.AntiAliasing = false
    Config.Visual.PerformanceMode = false
    
    updateFullbright()
    updateNoFog()
    updateWallhack()
    updateSuperZoom()
    Camera.FieldOfView = 70
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level10
    
    Notify("Visual settings restored to normal")
end

--==================================================
-- TELEPORT FEATURES (LENGKAP)
--==================================================
local function getPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(list, player.Name)
        end
    end
    return list
end

--==================================================
-- ACTIVE FEATURES COUNTER
--==================================================
local function updateActiveFeatures()
    local active = {}
    
    if Config.ESP.Enabled then table.insert(active, "ESP") end
    if Config.Highlight.Enabled then table.insert(active, "Highlight") end
    if Config.Generator.ESPEnabled then table.insert(active, "GenESP") end
    if Config.Generator.AntiFailEnabled then table.insert(active, "AntiFailGen") end
    if Config.Healing.AntiFailEnabled then table.insert(active, "AntiFailHeal") end
    if Config.Movement.SpeedEnabled then table.insert(active, "Speed") end
    if Config.Movement.JumpEnabled then table.insert(active, "Jump") end
    if Config.Movement.InfiniteJump then table.insert(active, "InfJump") end
    if Config.Movement.Noclip then table.insert(active, "Noclip") end
    if Config.Visual.FullbrightEnabled then table.insert(active, "Fullbright") end
    if Config.Visual.NoFogEnabled then table.insert(active, "NoFog") end
    if Config.Visual.WallhackEnabled then table.insert(active, "Wallhack") end
    if Config.Visual.SuperZoomEnabled then table.insert(active, "SuperZoom") end
    if Config.UI.HideSkillCheck then table.insert(active, "HideUI") end
    if Config.Misc.AntiAFK then table.insert(active, "AntiAFK") end
    
    return active
end

--==================================================
-- ESP TAB
--==================================================
local ESPSection = ESPTab:AddSection({
    Name = "Player ESP Settings",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ESPSection:AddToggle({
    Name = "ENABLE ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPEnable",
    Save = true,
    Callback = function(Value)
        Config.ESP.Enabled = Value
        
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

ESPSection:AddToggle({
    Name = "Show Boxes",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPBoxes",
    Save = true,
    Callback = function(Value) Config.ESP.Boxes = Value end
})

ESPSection:AddToggle({
    Name = "Show Names (Size 22 Bold)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPNames",
    Save = true,
    Callback = function(Value) Config.ESP.Names = Value end
})

ESPSection:AddToggle({
    Name = "Show Distance",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPDistance",
    Save = true,
    Callback = function(Value) Config.ESP.Distance = Value end
})

ESPSection:AddToggle({
    Name = "Show Health Bar",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPHealth",
    Save = true,
    Callback = function(Value) Config.ESP.Health = Value end
})

ESPSection:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPTracers",
    Save = true,
    Callback = function(Value) Config.ESP.Tracers = Value end
})

ESPSection:AddToggle({
    Name = "Team Check (Hide Teammates)",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPTeamCheck",
    Save = true,
    Callback = function(Value) Config.ESP.TeamCheck = Value end
})

ESPSection:AddToggle({
    Name = "Show Teammates (Override)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPShowTeam",
    Save = true,
    Callback = function(Value) Config.ESP.ShowTeammates = Value end
})

ESPSection:AddSlider({
    Name = "Max ESP Distance",
    Min = 500,
    Max = 5000,
    Default = 2000,
    Increment = 100,
    ValueName = "m",
    Outline = true,
    Callback = function(Value) Config.ESP.MaxDistance = Value end
})

ESPSection:AddParagraph({
    Title = "Color Guide",
    Desc = "🟢 Green = Teammate\n🔴 Red = Enemy\n📏 Distance shows in meters",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- MOVEMENT TAB (LENGKAP)
--==================================================
local SpeedSection = MovementTab:AddSection({
    Name = "🚀 SPEED HACK",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SpeedSection:AddToggle({
    Name = "Enable Speed Hack",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SpeedEnable",
    Save = true,
    Callback = function(Value)
        Config.Movement.SpeedEnabled = Value
        if not Value then
            local char = Player.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
        end
    end
})

SpeedSection:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Callback = function(Value)
        Config.Movement.SpeedValue = Value
        if Config.Movement.SpeedEnabled then
            local char = Player.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
            end
        end
    end
})

local JumpSection = MovementTab:AddSection({
    Name = "🦘 JUMP HACK",
    TextSize = 18,
    Glass = true,
    Outline = true
})

JumpSection:AddToggle({
    Name = "Enable Jump Hack",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "JumpEnable",
    Save = true,
    Callback = function(Value)
        Config.Movement.JumpEnabled = Value
        if not Value then
            local char = Player.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").JumpPower = 50
            end
        end
    end
})

JumpSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Increment = 5,
    ValueName = "JP",
    Outline = true,
    Callback = function(Value)
        Config.Movement.JumpValue = Value
        if Config.Movement.JumpEnabled then
            local char = Player.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").JumpPower = Value
            end
        end
    end
})

local ExtraSection = MovementTab:AddSection({
    Name = "⚡ EXTRA MOVEMENT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ExtraSection:AddToggle({
    Name = "🚀 Infinite Jump",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "InfiniteJump",
    Save = true,
    Callback = function(Value)
        Config.Movement.InfiniteJump = Value
        Notify(Value and "Infinite Jump Enabled" or "Infinite Jump Disabled")
    end
})

ExtraSection:AddToggle({
    Name = "👻 Noclip",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Movement.Noclip = Value
        
        if Value then
            enableNoclip()
            Notify("Noclip Enabled - Walk through walls!")
        else
            disableNoclip()
            Notify("Noclip Disabled - Collision restored")
        end
    end
})

--==================================================
-- VISUAL TAB (LENGKAP)
--==================================================
local VisualMainSection = VisualTab:AddSection({
    Name = "🎨 VISUAL FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

VisualMainSection:AddToggle({
    Name = "Wallhack (See through walls)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Wallhack",
    Save = true,
    Callback = function(Value)
        Config.Visual.WallhackEnabled = Value
        updateWallhack()
        Notify(Value and "Wallhack Enabled" or "Wallhack Disabled")
    end
})

VisualMainSection:AddToggle({
    Name = "Fullbright (Bright map)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Fullbright",
    Save = true,
    Callback = function(Value)
        Config.Visual.FullbrightEnabled = Value
        updateFullbright()
        Notify(Value and "Fullbright Enabled" or "Fullbright Disabled")
    end
})

VisualMainSection:AddToggle({
    Name = "No Fog (Clear view)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "NoFog",
    Save = true,
    Callback = function(Value)
        Config.Visual.NoFogEnabled = Value
        updateNoFog()
        Notify(Value and "No Fog Enabled" or "No Fog Disabled")
    end
})

VisualMainSection:AddToggle({
    Name = "Super Zoom Out",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SuperZoom",
    Save = true,
    Callback = function(Value)
        Config.Visual.SuperZoomEnabled = Value
        updateSuperZoom()
        Notify(Value and "Super Zoom Enabled" or "Super Zoom Disabled")
    end
})

local GraphicsSection = VisualTab:AddSection({
    Name = "🎮 GRAPHICS QUALITY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

GraphicsSection:AddToggle({
    Name = "Anti-Aliasing (Smooth edges)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAlias",
    Save = true,
    Callback = function(Value)
        Config.Visual.AntiAliasing = Value
        if Value then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
        end
        Notify(Value and "Anti-Aliasing Enabled" or "Anti-Aliasing Disabled")
    end
})

GraphicsSection:AddToggle({
    Name = "Performance Mode (Low graphics)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Performance",
    Save = true,
    Callback = function(Value)
        Config.Visual.PerformanceMode = Value
        if Value then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.Brightness = 1
        end
        Notify(Value and "Performance Mode Enabled" or "Performance Mode Disabled")
    end
})

GraphicsSection:AddButton({
    Name = "🔄 Reset All Visual Settings",
    Icon = "refresh-cw",
    Outline = true,
    Callback = resetVisual
})

--==================================================
-- TELEPORT TAB (LENGKAP)
--==================================================
local TeleportMainSection = TeleportTab:AddSection({
    Name = "📡 PLAYER TELEPORT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Dropdown untuk pilih player
local playerDropdown
playerDropdown = TeleportMainSection:AddDropdown({
    Name = "Select Player",
    Default = getPlayerList()[1] or "None",
    Options = getPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Callback = function(Value)
        -- Just selection, no action yet
    end
})

TeleportMainSection:AddButton({
    Name = "📌 Teleport to Selected Player",
    Icon = "send",
    Outline = true,
    Callback = function()
        local selected = playerDropdown.CurrentOption
        if selected and selected ~= "None" then
            local target = Players:FindFirstChild(selected)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                Notify("Teleported to " .. selected)
            else
                Notify("Target not found or invalid")
            end
        else
            Notify("Please select a player first")
        end
    end
})

TeleportMainSection:AddButton({
    Name = "🔄 Refresh Player List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        playerDropdown:Refresh(getPlayerList(), true)
        Notify("Player list refreshed")
    end
})

local WaypointSection = TeleportTab:AddSection({
    Name = "📍 WAYPOINTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

WaypointSection:AddButton({
    Name = "💾 Save Current Position",
    Icon = "save",
    Outline = true,
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Config.Teleport.SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Position saved!")
        end
    end
})

WaypointSection:AddButton({
    Name = "📂 Load Saved Position",
    Icon = "upload",
    Outline = true,
    Callback = function()
        if Config.Teleport.SavedPosition then
            Player.Character.HumanoidRootPart.CFrame = Config.Teleport.SavedPosition
            Notify("Teleported to saved position")
        else
            Notify("No saved position found!")
        end
    end
})

--==================================================
-- MISC TAB (LENGKAP)
--==================================================
local MiscMainSection = MiscTab:AddSection({
    Name = "⚙️ MISC FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddToggle({
    Name = "Anti AFK (Prevent disconnect)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.Misc.AntiAFK = Value
        if Value then
            Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            Notify("Anti AFK Enabled")
        else
            Notify("Anti AFK Disabled")
        end
    end
})

MiscMainSection:AddToggle({
    Name = "Hide Skill Check UI (Clean screen)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HideSkillCheck",
    Save = true,
    Callback = function(Value)
        Config.UI.HideSkillCheck = Value
        Notify(Value and "Skill Check UI Hidden" or "Skill Check UI Visible")
    end
})

-- Active Features Counter (Live Update)
local ActiveSection = MiscTab:AddSection({
    Name = "📊 ACTIVE FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local ActiveParagraph = ActiveSection:AddParagraph({
    Title = "Currently Active:",
    Desc = "No active features",
    Image = "activity",
    ImageSize = 38
})

-- Live update for active features
task.spawn(function()
    while true do
        local active = updateActiveFeatures()
        if #active > 0 then
            ActiveParagraph:SetDesc("• " .. table.concat(active, "\n• "))
        else
            ActiveParagraph:SetDesc("No active features")
        end
        task.wait(1)
    end
end)

--==================================================
-- ADDITIONAL FEATURES (Dari script sebelumnya)
--==================================================
local HighlightTab2 = Window:MakeTab({
    Name = "Highlight",
    Icon = "sparkles",
    Glass = true,
    Outline = true
})

local GenTab = Window:MakeTab({
    Name = "Generator",
    Icon = "zap",
    Glass = true,
    Outline = true
})

-- HIGHLIGHT SYSTEM
local Highlights = {}

local function createHighlight(player)
    if player == Player then return end
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = player.Character
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    if Config.Highlight.TeamCheck then
        if isTeammate(player) then
            highlight.FillColor = TeamColor
            highlight.OutlineColor = TeamColor
        else
            highlight.FillColor = EnemyColor
            highlight.OutlineColor = EnemyColor
        end
    else
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    end
    
    Highlights[player] = highlight
end

local function removeHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

-- HIGHLIGHT TAB
local HighlightSection = HighlightTab2:AddSection({
    Name = "Character Highlight",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HighlightSection:AddToggle({
    Name = "Enable Highlight",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightEnable",
    Save = true,
    Callback = function(Value)
        Config.Highlight.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    createHighlight(player)
                end
            end
            Notify("Highlight Enabled")
        else
            for player, _ in pairs(Highlights) do
                removeHighlight(player)
            end
        end
    end
})

HighlightSection:AddToggle({
    Name = "Auto Team Colors",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightTeam",
    Save = true,
    Callback = function(Value) Config.Highlight.TeamCheck = Value end
})

-- GENERATOR ESP
local GeneratorESP = {}

local function createGeneratorESP(gen)
    if not gen:IsA("Model") or gen:FindFirstChild("GenESP") then return end
    
    local folder = Instance.new("Folder", gen)
    folder.Name = "GenESP"
    
    local highlight = Instance.new("Highlight", folder)
    highlight.Adornee = gen
    highlight.FillColor = Color3.new(0, 1, 1)
    highlight.DepthMode = "AlwaysOnTop"
    
    local billboard = Instance.new("BillboardGui", folder)
    billboard.Size = UDim2.new(0, 80, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.Adornee = gen:FindFirstChild("HitBox") or gen.PrimaryPart
    billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    
    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    
    task.spawn(function()
        while gen.Parent and folder.Parent do
            local progress = gen:GetAttribute("RepairProgress") or 0
            textLabel.Text = math.floor(progress) .. "%"
            highlight.Enabled = Config.Generator.ESPEnabled
            textLabel.Visible = Config.Generator.ESPEnabled
            
            if progress >= 100 then
                highlight.FillColor = Color3.new(0, 1, 0)
            else
                highlight.FillColor = Color3.new(0, 1, 1)
            end
            
            task.wait(1)
        end
    end)
    
    GeneratorESP[gen] = folder
end

-- GENERATOR TAB
local GenESPSection = GenTab:AddSection({
    Name = "Generator ESP",
    TextSize = 18,
    Glass = true,
    Outline = true
})

GenESPSection:AddToggle({
    Name = "Enable Generator ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "GenESP",
    Save = true,
    Callback = function(Value)
        Config.Generator.ESPEnabled = Value
        
        if Value then
            Notify("Generator ESP Enabled")
        else
            for gen, folder in pairs(GeneratorESP) do
                if folder then folder:Destroy() end
            end
            GeneratorESP = {}
        end
    end
})

GenESPSection:AddParagraph({
    Title = "Color Guide",
    Desc = "🔵 Cyan = In Progress\n🟢 Green = Complete (100%)",
    Image = "info",
    ImageSize = 38
})

GenESPSection:AddSection({
    Name = "Anti-Fail Generator",
    TextSize = 18,
    Glass = true,
    Outline = true
})

GenESPSection:AddToggle({
    Name = "Enable Anti-Fail",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "GenAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Generator.AntiFailEnabled = Value
        Notify(Value and "Anti-Fail Generator Enabled" or "Anti-Fail Generator Disabled")
    end
})

-- ANTI-FAIL SYSTEM
local AntiFailHooked = false

local function setupAntiFail()
    if AntiFailHooked then return end
    
    task.spawn(function()
        local success = pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if Config.Generator.AntiFailEnabled then
                    if tostring(self):find("SkillCheckFailEvent") and method == "FireServer" then
                        return nil
                    end
                    
                    if tostring(self):find("SkillCheckResultEvent") and method == "FireServer" then
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            args[1] = true
                            return oldNamecall(self, unpack(args))
                        else
                            return nil
                        end
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            AntiFailHooked = true
        end)
    end)
end

setupAntiFail()

--==================================================
-- HIDE SKILLCHECK UI
--==================================================
RunService.RenderStepped:Connect(function()
    if Config.UI.HideSkillCheck then
        local PlayerGui = Player:WaitForChild("PlayerGui")
        
        local targetUI = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        local targetUICon = PlayerGui:FindFirstChild("SkillCheckPromptGui-con")
        
        if targetUI and targetUI.Enabled then
            targetUI.Enabled = false
        end
        
        if targetUICon and targetUICon.Enabled then
            targetUICon.Enabled = false
        end
    end
end)

--==================================================
-- INITIALIZE PLAYERS FOR ESP
--==================================================
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Player then
        -- Setup ESP
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
            if Config.ESP.Enabled then
                createPlayerESP(player)
            end
        end)
        
        if player.Character then
            task.spawn(function()
                player.Character:WaitForChild("HumanoidRootPart")
                task.wait(0.5)
                if Config.ESP.Enabled then
                    createPlayerESP(player)
                end
            end)
        end
        
        -- Setup Highlight
        player.CharacterAdded:Connect(function()
            if Config.Highlight.Enabled then
                task.wait(0.5)
                createHighlight(player)
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= Player then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Config.ESP.Enabled then
                createPlayerESP(player)
            end
            if Config.Highlight.Enabled then
                createHighlight(player)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerESP(player)
    removeHighlight(player)
end)

--==================================================
-- GENERATOR ESP SCANNER
--==================================================
task.spawn(function()
    while true do
        if Config.Generator.ESPEnabled then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "Generator" and obj:IsA("Model") then
                    createGeneratorESP(obj)
                end
            end
        end
        task.wait(3)
    end
end)

--==================================================
-- MAIN UPDATE LOOP
--==================================================
RunService.Heartbeat:Connect(function()
    updateMovement()
    updatePlayerESP()
    
    if Config.Highlight.Enabled then
        for player, highlight in pairs(Highlights) do
            if not player or not player.Parent or not player.Character then
                removeHighlight(player)
            end
        end
    end
end)

-- Character added handler
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    
    -- Re-apply movement settings
    if Config.Movement.SpeedEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Config.Movement.SpeedValue end
    end
    
    if Config.Movement.JumpEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Config.Movement.JumpValue end
    end
    
    if Config.Movement.Noclip then
        enableNoclip()
    end
end)

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 VIOLENCE DISTRICT - COMPLETE Edition 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Player ESP - Size 22 Bold with Team Colors")
print("✅ Movement Hacks - Speed, Jump, Infinite Jump, Noclip")
print("✅ Visual Features - Wallhack, Fullbright, No Fog, Super Zoom")
print("✅ Teleport System - Player TP, Waypoints")
print("✅ Misc Features - Anti AFK, Active Counter")
print("✅ Highlight System & Generator ESP")
print("═══════════════════════════════════════════════════════")