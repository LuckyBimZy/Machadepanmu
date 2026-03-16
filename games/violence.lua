-- ==================== VIOLENCE DISTRICT - ULTIMATE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Adapted from LuckyBimZy & RanZx999
-- Version: 3.0 FINAL - All Fixed

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

--==================================================
-- COLORS
--==================================================
local TeamColor = Color3.fromRGB(0, 255, 0)
local EnemyColor = Color3.fromRGB(255, 0, 0)

--==================================================
-- CONFIG - SEMUA DALAM KEADAAN OFF
--==================================================
local Config = {
    -- ESP Settings
    ESP = {
        Enabled = false,
        Mode = "None", -- None, Modern, Classic
        Modern = {
            Names = false,
            Distance = false,
            Boxes = false,
            Highlight = false,
            Health = false,
            Tracers = false,
            TeamCheck = true,
            MaxDistance = 2000,
            ShowTeammates = false
        },
        Classic = {
            Names = false,
            Distance = false,
            Boxes = false,
            Health = false,
            Tracers = false,
            TeamCheck = true,
            MaxDistance = 2000,
            ShowTeammates = false
        }
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
        InfiniteZoomEnabled = false
    },
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 16,
        JumpEnabled = false,
        JumpValue = 50,
        InfiniteJump = false,
        Noclip = false
    },
    Teleport = {
        SavedPosition = nil
    },
    Misc = {
        AntiAFK = false,
        AutoClick = false
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

local atm = Lighting:FindFirstChildOfClass("Atmosphere")
if atm then
    originalLighting.Atmosphere = {
        Density = atm.Density,
        Offset = atm.Offset,
        Glare = atm.Glare,
        Haze = atm.Haze
    }
end

local blur = Lighting:FindFirstChildOfClass("BlurEffect")
if blur then
    originalLighting.Blur = { Size = blur.Size }
end

--==================================================
-- ACTIVE FEATURES COUNTER
--==================================================
local ActiveFeatures = {}

local function updateActiveFeatures()
    ActiveFeatures = {}
    
    if Config.ESP.Enabled and Config.ESP.Mode ~= "None" then 
        table.insert(ActiveFeatures, Config.ESP.Mode .. " ESP") 
    end
    if Config.Highlight.Enabled then table.insert(ActiveFeatures, "Highlight") end
    if Config.Generator.ESPEnabled then table.insert(ActiveFeatures, "Gen ESP") end
    if Config.Generator.AntiFailEnabled then table.insert(ActiveFeatures, "Anti-Fail Gen") end
    if Config.Healing.AntiFailEnabled then table.insert(ActiveFeatures, "Anti-Fail Heal") end
    if Config.Visual.FullbrightEnabled then table.insert(ActiveFeatures, "Fullbright") end
    if Config.Visual.NoFogEnabled then table.insert(ActiveFeatures, "No Fog") end
    if Config.Visual.WallhackEnabled then table.insert(ActiveFeatures, "Wallhack") end
    if Config.Visual.InfiniteZoomEnabled then table.insert(ActiveFeatures, "Infinite Zoom") end
    if Config.UI.HideSkillCheck then table.insert(ActiveFeatures, "Hide UI") end
    if Config.Movement.SpeedEnabled then table.insert(ActiveFeatures, "Speed") end
    if Config.Movement.JumpEnabled then table.insert(ActiveFeatures, "Jump") end
    if Config.Movement.InfiniteJump then table.insert(ActiveFeatures, "Inf Jump") end
    if Config.Movement.Noclip then table.insert(ActiveFeatures, "Noclip") end
    if Config.Misc.AntiAFK then table.insert(ActiveFeatures, "Anti AFK") end
    if Config.Misc.AutoClick then table.insert(ActiveFeatures, "Auto Click") end
    
    return ActiveFeatures
end

--==================================================
-- TEAM CHECK FUNCTION
--==================================================
local function isTeammate(player)
    if not Player.Team then return false end
    if not player.Team then return false end
    return player.Team == Player.Team
end

local function getPlayerColor(player)
    if Config.ESP.Mode == "Modern" then
        if Config.ESP.Modern.TeamCheck and isTeammate(player) then
            return TeamColor
        else
            return EnemyColor
        end
    elseif Config.ESP.Mode == "Classic" then
        if Config.ESP.Classic.TeamCheck and isTeammate(player) then
            return TeamColor
        else
            return EnemyColor
        end
    end
    return EnemyColor
end

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
    Subtext = "ULTIMATE Edition",
    Version = "v3.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VD_ULTIMATE",
    IntroEnabled = true,
    IntroText = "Violence District ULTIMATE",
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
    Name = "ESP",
    Icon = "eye",
    Glass = true,
    Outline = true
})

local HighlightTab = Window:MakeTab({
    Name = "Highlight",
    Icon = "sparkles",
    Glass = true,
    Outline = true
})

local GeneratorTab = Window:MakeTab({
    Name = "Generator",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local HealingTab = Window:MakeTab({
    Name = "Healing",
    Icon = "heart",
    Glass = true,
    Outline = true
})

local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "sun",
    Glass = true,
    Outline = true
})

local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "footprints",
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
-- PLAYER INFO SECTION (MAIN TAB)
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "👤 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

PlayerInfoSection:AddParagraph({
    Title = "📊 Player Statistics",
    Desc = string.format(
        "Name: %s\nDisplay: %s\nAge: %d days\nTeam: %s",
        Player.Name,
        Player.DisplayName,
        Player.AccountAge,
        Player.Team and Player.Team.Name or "No Team"
    ),
    Image = "user",
    ImageSize = 42
})

local ServerInfoSection = MainTab:AddSection({
    Name = "🌐 SERVER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = string.format(
        "Players: %d\nPlace ID: %d\nGame ID: %s",
        #Players:GetPlayers(),
        game.PlaceId,
        game.GameId
    ),
    Image = "server",
    ImageSize = 42
})

local ActiveFeaturesSection = MainTab:AddSection({
    Name = "⚡ ACTIVE FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- This will be updated periodically
local activeFeaturesPara = ActiveFeaturesSection:AddParagraph({
    Title = "Currently Active:",
    Desc = "None",
    Image = "activity",
    ImageSize = 42
})

-- Update active features every 2 seconds
task.spawn(function()
    while true do
        local features = updateActiveFeatures()
        if #features > 0 then
            activeFeaturesPara:SetDesc("• " .. table.concat(features, "\n• "))
        else
            activeFeaturesPara:SetDesc("None")
        end
        task.wait(2)
    end
end)

--==================================================
-- ESP SYSTEM - MODERN (Seperti di gambar)
--==================================================
local ModernESPObjects = {}

local function createModernESP(player)
    if player == Player then return end
    if ModernESPObjects[player] then return end
    
    ModernESPObjects[player] = {
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Box = Drawing.new("Square"),
        Highlight = Drawing.new("Square"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }
    
    local esp = ModernESPObjects[player]
    
    -- Modern Name Settings
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 20
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 3
    
    -- Modern Distance Settings
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
    esp.Distance.Size = 18
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 3
    
    -- Box Settings
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255, 255, 255)
    
    -- Highlight Settings
    esp.Highlight.Visible = false
    esp.Highlight.Thickness = 1
    esp.Highlight.Transparency = 0.7
    esp.Highlight.Filled = true
    esp.Highlight.Color = Color3.fromRGB(255, 255, 255)
    
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

local function removeModernESP(player)
    if ModernESPObjects[player] then
        for _, obj in pairs(ModernESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ModernESPObjects[player] = nil
    end
end

local function updateModernESP()
    if not Config.ESP.Enabled or Config.ESP.Mode ~= "Modern" then
        for _, esp in pairs(ModernESPObjects) do
            for _, obj in pairs(esp) do 
                pcall(function() obj.Visible = false end)
            end
        end
        return
    end
    
    for player, esp in pairs(ModernESPObjects) do
        if not player or not player.Parent or not player.Character then
            removeModernESP(player)
            continue
        end
        
        if Config.ESP.Modern.TeamCheck and isTeammate(player) and not Config.ESP.Modern.ShowTeammates then
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
        
        if distance > Config.ESP.Modern.MaxDistance then
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
        
        -- Hide all elements first
        for _, obj in pairs(esp) do 
            pcall(function() obj.Visible = false end)
        end
        
        -- Modern Name
        if Config.ESP.Modern.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 45)
            esp.Name.Color = playerColor
            esp.Name.Visible = true
        end
        
        -- Modern Distance
        if Config.ESP.Modern.Distance then
            esp.Distance.Text = string.format("[%dm]", math.floor(distance))
            esp.Distance.Position = Vector2.new(headPos.X, headPos.Y - 20)
            esp.Distance.Color = playerColor
            esp.Distance.Visible = true
        end
        
        -- Box
        if Config.ESP.Modern.Boxes then
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            esp.Box.Color = playerColor
            esp.Box.Visible = true
        end
        
        -- Highlight
        if Config.ESP.Modern.Highlight then
            esp.Highlight.Size = boxSize + Vector2.new(8, 8)
            esp.Highlight.Position = Vector2.new(rootPos.X - (boxSize.X + 8) / 2, rootPos.Y - (boxSize.Y + 8) / 2)
            esp.Highlight.Color = playerColor
            esp.Highlight.Visible = true
        end
        
        -- Health bar
        if Config.ESP.Modern.Health and hum then
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
        end
        
        -- Tracers
        if Config.ESP.Modern.Tracers then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.From = screenCenter
            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            esp.Tracer.Color = playerColor
            esp.Tracer.Visible = true
        end
    end
end

--==================================================
-- ESP SYSTEM - CLASSIC
--==================================================
local ClassicESPObjects = {}

local function createClassicESP(player)
    if player == Player then return end
    if ClassicESPObjects[player] then return end
    
    ClassicESPObjects[player] = {
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Box = Drawing.new("Square"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }
    
    local esp = ClassicESPObjects[player]
    
    -- Classic Name Settings
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 15
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 2
    
    -- Classic Distance Settings
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 13
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 2
    
    -- Classic Box Settings
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255, 255, 255)
    
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

local function removeClassicESP(player)
    if ClassicESPObjects[player] then
        for _, obj in pairs(ClassicESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ClassicESPObjects[player] = nil
    end
end

local function updateClassicESP()
    if not Config.ESP.Enabled or Config.ESP.Mode ~= "Classic" then
        for _, esp in pairs(ClassicESPObjects) do
            for _, obj in pairs(esp) do 
                pcall(function() obj.Visible = false end)
            end
        end
        return
    end
    
    for player, esp in pairs(ClassicESPObjects) do
        if not player or not player.Parent or not player.Character then
            removeClassicESP(player)
            continue
        end
        
        if Config.ESP.Classic.TeamCheck and isTeammate(player) and not Config.ESP.Classic.ShowTeammates then
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
        
        if distance > Config.ESP.Classic.MaxDistance then
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
        
        -- Hide all elements first
        for _, obj in pairs(esp) do 
            pcall(function() obj.Visible = false end)
        end
        
        -- Classic Name
        if Config.ESP.Classic.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 35)
            esp.Name.Color = playerColor
            esp.Name.Visible = true
        end
        
        -- Classic Distance
        if Config.ESP.Classic.Distance then
            esp.Distance.Text = string.format("[%.0fm]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxSize.Y / 2 + 20)
            esp.Distance.Visible = true
        end
        
        -- Classic Box
        if Config.ESP.Classic.Boxes then
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            esp.Box.Color = playerColor
            esp.Box.Visible = true
        end
        
        -- Health bar
        if Config.ESP.Classic.Health and hum then
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
        end
        
        -- Tracers
        if Config.ESP.Classic.Tracers then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.From = screenCenter
            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            esp.Tracer.Color = playerColor
            esp.Tracer.Visible = true
        end
    end
end

-- Initialize ESP for existing players
local function setupAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            createModernESP(player)
            createClassicESP(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= Player then
        createModernESP(player)
        createClassicESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeModernESP(player)
    removeClassicESP(player)
end)

setupAllESP()

--==================================================
-- WALLHACK FUNCTION
--==================================================
local wallhackConnection = nil

local function enableWallhack()
    if wallhackConnection then wallhackConnection:Disconnect() end
    
    wallhackConnection = RunService.RenderStepped:Connect(function()
        if not Config.Visual.WallhackEnabled then return end
        
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

local function disableWallhack()
    if wallhackConnection then
        wallhackConnection:Disconnect()
        wallhackConnection = nil
    end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            v.Material = Enum.Material.Plastic
            v.Transparency = 0
        end
    end
end

--==================================================
-- INFINITE ZOOM
--==================================================
local function setInfiniteZoom(enabled)
    if enabled then
        Camera.MaxAxisFieldOfView = 120
        Camera.FieldOfView = 120
    else
        Camera.MaxAxisFieldOfView = 80
        Camera.FieldOfView = 70
    end
end

--==================================================
-- HIGHLIGHT SYSTEM
--==================================================
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

local function updateHighlights()
    for player, highlight in pairs(Highlights) do
        if not player or not player.Parent or not player.Character then
            removeHighlight(player)
            continue
        end
        
        if Config.Highlight.TeamCheck and isTeammate(player) and not Config.Highlight.ShowTeam then
            highlight.Enabled = false
            continue
        else
            highlight.Enabled = true
        end
        
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
    end
end

--==================================================
-- GENERATOR ESP
--==================================================
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
-- ANTI-FAIL SYSTEM
--==================================================
local AntiFailHooked = false

local function setupAntiFail()
    if AntiFailHooked then return end
    
    task.spawn(function()
        local success = pcall(function()
            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local Events = ReplicatedStorage:FindFirstChild("Events")
            
            if not Remotes and not Events then
                return
            end
            
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
                
                if Config.Healing.AntiFailEnabled then
                    if tostring(self):find("Heal") and tostring(self):find("Fail") and method == "FireServer" then
                        return nil
                    end
                    
                    if tostring(self):find("Heal") and tostring(self):find("Result") and method == "FireServer" then
                        args[1] = true
                        return oldNamecall(self, unpack(args))
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
-- FULLBRIGHT & NO FOG SYSTEM
--==================================================
task.spawn(function()
    while true do
        if Config.Visual.FullbrightEnabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") then
                    v.Density = 0
                    v.Offset = 0
                    v.Glare = 0
                    v.Haze = 0
                end
                
                if v:IsA("BlurEffect") then
                    v.Size = 0
                end
            end
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") and originalLighting.Atmosphere then
                    v.Density = originalLighting.Atmosphere.Density or 0.3
                    v.Offset = originalLighting.Atmosphere.Offset or 0.25
                    v.Glare = originalLighting.Atmosphere.Glare or 0
                    v.Haze = originalLighting.Atmosphere.Haze or 0
                end
                
                if v:IsA("BlurEffect") and originalLighting.Blur then
                    v.Size = originalLighting.Blur.Size or 0
                end
            end
        end
        
        if Config.Visual.NoFogEnabled then
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.FogStart = originalLighting.FogStart or 0
        end
        
        task.wait(0.5)
    end
end)

--==================================================
-- MOVEMENT SYSTEM
--==================================================
local noclipConnection = nil

local function updateMovement()
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if Config.Movement.SpeedEnabled then
        hum.WalkSpeed = Config.Movement.SpeedValue
    else
        hum.WalkSpeed = 16
    end
    
    if Config.Movement.JumpEnabled then
        hum.JumpPower = Config.Movement.JumpValue
    else
        hum.JumpPower = 50
    end
end

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
-- ANTI AFK
--==================================================
local function setupAntiAFK()
    Player.Idled:Connect(function()
        if Config.Misc.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

setupAntiAFK()

--==================================================
-- AUTO CLICK
--==================================================
local autoClickConnection = nil

local function enableAutoClick()
    if autoClickConnection then return end
    
    autoClickConnection = RunService.Heartbeat:Connect(function()
        if Config.Misc.AutoClick then
            mouse1click()
            task.wait(0.05)
        end
    end)
end

local function disableAutoClick()
    if autoClickConnection then
        autoClickConnection:Disconnect()
        autoClickConnection = nil
    end
end

--==================================================
-- RUN SERVICE CONNECTIONS
--==================================================
RunService.Heartbeat:Connect(function()
    updateMovement()
    updateModernESP()
    updateClassicESP()
    if Config.Highlight.Enabled then
        updateHighlights()
    end
end)

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
-- ESP TAB - SATU MENU DENGAN DROPDOWN
--==================================================
local ESPMainSection = ESPTab:AddSection({
    Name = "⚡ ESP CONFIGURATION ⚡",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ESPMainSection:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPEnable",
    Save = true,
    Callback = function(Value)
        Config.ESP.Enabled = Value
        if not Value then
            Config.ESP.Mode = "None"
        end
        Notify(Value and "ESP Enabled - Select Mode" or "ESP Disabled")
    end
})

ESPMainSection:AddDropdown({
    Name = "ESP Mode",
    Default = "None",
    Options = {"None", "Modern", "Classic"},
    Multi = false,
    Search = false,
    AllowNone = true,
    Outline = true,
    Flag = "ESPMode",
    Save = true,
    Callback = function(Value)
        if Config.ESP.Enabled then
            Config.ESP.Mode = Value
            Notify("ESP Mode: " .. Value)
        else
            Notify("Please enable ESP first!")
        end
    end
})

-- MODERN ESP SECTION (Muncul hanya jika mode Modern dipilih)
local ModernSection = ESPTab:AddSection({
    Name = "✨ MODERN ESP SETTINGS ✨",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Sembunyikan section ini awalnya
ModernSection:Set("Visible", false)

-- CLASSIC ESP SECTION (Muncul hanya jika mode Classic dipilih)
local ClassicSection = ESPTab:AddSection({
    Name = "📦 CLASSIC ESP SETTINGS 📦",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Sembunyikan section ini awalnya
ClassicSection:Set("Visible", false)

-- Function untuk update visibility section berdasarkan mode
local function updateESPVisibility()
    if Config.ESP.Enabled and Config.ESP.Mode == "Modern" then
        ModernSection:Set("Visible", true)
        ClassicSection:Set("Visible", false)
    elseif Config.ESP.Enabled and Config.ESP.Mode == "Classic" then
        ModernSection:Set("Visible", false)
        ClassicSection:Set("Visible", true)
    else
        ModernSection:Set("Visible", false)
        ClassicSection:Set("Visible", false)
    end
end

-- Modern ESP Toggles (Semua dalam keadaan off)
ModernSection:AddToggle({
    Name = "Show Names",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ModernNames",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.Names = Value end
})

ModernSection:AddToggle({
    Name = "Show Distance [80m]",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ModernDistance",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.Distance = Value end
})

ModernSection:AddToggle({
    Name = "Show Boxes",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ModernBoxes",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.Boxes = Value end
})

ModernSection:AddToggle({
    Name = "Show Highlight",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ModernHighlight",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.Highlight = Value end
})

ModernSection:AddToggle({
    Name = "Show Health Bar",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ModernHealth",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.Health = Value end
})

ModernSection:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ModernTracers",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.Tracers = Value end
})

ModernSection:AddToggle({
    Name = "Team Check (Hide Teammates)",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ModernTeamCheck",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.TeamCheck = Value end
})

ModernSection:AddToggle({
    Name = "Show Teammates (Override)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ModernShowTeam",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.ShowTeammates = Value end
})

ModernSection:AddSlider({
    Name = "Max ESP Distance",
    Min = 500,
    Max = 5000,
    Default = 2000,
    Increment = 100,
    ValueName = "m",
    Outline = true,
    Flag = "ModernMaxDist",
    Save = true,
    Callback = function(Value) Config.ESP.Modern.MaxDistance = Value end
})

ModernSection:AddParagraph({
    Title = "Modern ESP Preview",
    Desc = "• Nama besar putih (size 20)\n• Distance format [80m] putih\n• Bold font dengan outline hitam",
    Image = "eye",
    ImageSize = 38
})

-- Classic ESP Toggles (Semua dalam keadaan off)
ClassicSection:AddToggle({
    Name = "Show Names",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ClassicNames",
    Save = true,
    Callback = function(Value) Config.ESP.Classic.Names = Value end
})

ClassicSection:AddToggle({
    Name = "Show Distance",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ClassicDistance",
    Save = true,
    Callback = function(Value) Config.ESP.Classic.Distance = Value end
})

ClassicSection:AddToggle({
    Name = "Show Boxes",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ClassicBoxes",
    Save = true,
    Callback = function(Value) Config.ESP.Classic.Boxes = Value end
})

ClassicSection:AddToggle({
    Name = "Show Health Bar",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ClassicHealth",
    Save = true,
    Callback = function(Value) Config.ESP.Classic.Health = Value end
})

ClassicSection:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ClassicTracers",
    Save = true,
    Callback = function(Value) Config.ESP.Classic.Tracers = Value end
})

ClassicSection:AddToggle({
    Name = "Team Check (Hide Teammates)",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ClassicTeamCheck",
    Save = true,
    Callback = function(Value) Config.ESP.Classic.TeamCheck = Value end
})

ClassicSection:AddToggle({
    Name = "Show Teammates (Override)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ClassicShowTeam",
    Save = true,
    Callback = function(Value) Config.ESP.Classic.ShowTeammates = Value end
})

ClassicSection:AddSlider({
    Name = "Max ESP Distance",
    Min = 500,
    Max = 5000,
    Default = 2000,
    Increment = 100,
    ValueName = "m",
    Outline = true,
    Flag = "ClassicMaxDist",
    Save = true,
    Callback = function(Value) Config.ESP.Classic.MaxDistance = Value end
})

ClassicSection:AddParagraph({
    Title = "Classic ESP Preview",
    Desc = "• Nama ukuran normal (size 15)\n• Distance abu-abu (size 13)\n• Regular font",
    Image = "box",
    ImageSize = 38
})

-- Update visibility when mode changes
task.spawn(function()
    while true do
        updateESPVisibility()
        task.wait(0.5)
    end
end)

--==================================================
-- HIGHLIGHT TAB
--==================================================
local HighlightSection = HighlightTab:AddSection({
    Name = "✨ CHARACTER HIGHLIGHT ✨",
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

HighlightSection:AddToggle({
    Name = "Show Team Highlight",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightShowTeam",
    Save = true,
    Callback = function(Value) Config.Highlight.ShowTeam = Value end
})

--==================================================
-- GENERATOR TAB
--==================================================
local GenSection = GeneratorTab:AddSection({
    Name = "⚡ GENERATOR ESP ⚡",
    TextSize = 18,
    Glass = true,
    Outline = true
})

GenSection:AddToggle({
    Name = "Enable Generator ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "GenESP",
    Save = true,
    Callback = function(Value)
        Config.Generator.ESPEnabled = Value
        Notify(Value and "Generator ESP Enabled" or "Generator ESP Disabled")
    end
})

GenSection:AddSection({
    Name = "🛡️ ANTI-FAIL GENERATOR 🛡️",
    TextSize = 18,
    Glass = true,
    Outline = true
})

GenSection:AddToggle({
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

--==================================================
-- HEALING TAB
--==================================================
local HealSection = HealingTab:AddSection({
    Name = "❤️ ANTI-FAIL HEALING ❤️",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HealSection:AddToggle({
    Name = "Enable Anti-Fail Heal",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HealAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Healing.AntiFailEnabled = Value
        Notify(Value and "Anti-Fail Healing Enabled" or "Anti-Fail Healing Disabled")
    end
})

--==================================================
-- VISUAL TAB
--==================================================
local VisualSection = VisualTab:AddSection({
    Name = "☀️ VISUAL ENHANCEMENTS ☀️",
    TextSize = 18,
    Glass = true,
    Outline = true
})

VisualSection:AddToggle({
    Name = "Enable Fullbright",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Fullbright",
    Save = true,
    Callback = function(Value)
        Config.Visual.FullbrightEnabled = Value
        Notify(Value and "Fullbright Enabled" or "Fullbright Disabled")
    end
})

VisualSection:AddToggle({
    Name = "Enable No Fog",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "NoFog",
    Save = true,
    Callback = function(Value)
        Config.Visual.NoFogEnabled = Value
        Notify(Value and "No Fog Enabled" or "No Fog Disabled")
    end
})

VisualSection:AddToggle({
    Name = "Enable Wallhack",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Wallhack",
    Save = true,
    Callback = function(Value)
        Config.Visual.WallhackEnabled = Value
        if Value then
            enableWallhack()
            Notify("Wallhack Enabled")
        else
            disableWallhack()
            Notify("Wallhack Disabled")
        end
    end
})

VisualSection:AddToggle({
    Name = "Infinite Zoom Out",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "InfiniteZoom",
    Save = true,
    Callback = function(Value)
        Config.Visual.InfiniteZoomEnabled = Value
        setInfiniteZoom(Value)
        Notify(Value and "Infinite Zoom Enabled" or "Infinite Zoom Disabled")
    end
})

VisualSection:AddSection({
    Name = "🎮 UI SETTINGS 🎮",
    TextSize = 18,
    Glass = true,
    Outline = true
})

VisualSection:AddToggle({
    Name = "Hide Skill Check UI",
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

--==================================================
-- MOVEMENT TAB
--==================================================
local MoveSection = MovementTab:AddSection({
    Name = "🏃 SPEED HACK (16-200) 🏃",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MoveSection:AddToggle({
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
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end
})

MoveSection:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Flag = "SpeedValue",
    Save = true,
    Callback = function(Value)
        Config.Movement.SpeedValue = Value
    end
})

MoveSection:AddSection({
    Name = "🦘 JUMP HACK (50-300) 🦘",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MoveSection:AddToggle({
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
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = 50 end
            end
        end
    end
})

MoveSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Increment = 5,
    ValueName = "JP",
    Outline = true,
    Flag = "JumpValue",
    Save = true,
    Callback = function(Value)
        Config.Movement.JumpValue = Value
    end
})

MoveSection:AddSection({
    Name = "🚀 EXTRA MOVEMENT 🚀",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MoveSection:AddToggle({
    Name = "Infinite Jump",
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

MoveSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Movement.Noclip = Value
        
        if Value then
            enableNoclip()
            Notify("Noclip Enabled")
        else
            disableNoclip()
            Notify("Noclip Disabled")
        end
    end
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportSection = TeleportTab:AddSection({
    Name = "📍 TELEPORT TO PLAYER 📍",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local function getPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(list, player.Name)
        end
    end
    return list
end

local selectedPlayer = "None"

TeleportSection:AddDropdown({
    Name = "Select Player",
    Default = "None",
    Options = getPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "TeleportTarget",
    Save = false,
    Callback = function(Value)
        selectedPlayer = Value
    end
})

TeleportSection:AddButton({
    Name = "Teleport to Selected Player",
    Icon = "send",
    Outline = true,
    Callback = function()
        if selectedPlayer and selectedPlayer ~= "None" then
            local target = Players:FindFirstChild(selectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                Notify("Teleported to " .. selectedPlayer)
            else
                Notify("Player not found or invalid")
            end
        else
            Notify("No player selected")
        end
    end
})

TeleportSection:AddButton({
    Name = "Refresh Player List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        Notify("Player list refreshed")
    end
})

TeleportSection:AddSection({
    Name = "📍 WAYPOINTS 📍",
    TextSize = 18,
    Glass = true,
    Outline = true
})

TeleportSection:AddButton({
    Name = "Save Current Position",
    Icon = "save",
    Outline = true,
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Config.Teleport.SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Position saved!")
        end
    end
})

TeleportSection:AddButton({
    Name = "Load Saved Position",
    Icon = "upload",
    Outline = true,
    Callback = function()
        if Config.Teleport.SavedPosition then
            Player.Character.HumanoidRootPart.CFrame = Config.Teleport.SavedPosition
            Notify("Teleported to saved position")
        else
            Notify("No saved position!")
        end
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({
    Name = "⚙️ UTILITY FEATURES ⚙️",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscSection:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.Misc.AntiAFK = Value
        Notify(Value and "Anti AFK Enabled" or "Anti AFK Disabled")
    end
})

MiscSection:AddToggle({
    Name = "Auto Click",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoClick",
    Save = true,
    Callback = function(Value)
        Config.Misc.AutoClick = Value
        if Value then
            enableAutoClick()
            Notify("Auto Click Enabled")
        else
            disableAutoClick()
            Notify("Auto Click Disabled")
        end
    end
})

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    
    if Config.Movement.Noclip then
        enableNoclip()
    end
    
    updateMovement()
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
print("🔥 VIOLENCE DISTRICT - ULTIMATE Edition v3.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ ESP - 1 Menu dengan Dropdown Mode")
print("   • Modern ESP - Nama besar putih + [80m]")
print("   • Classic ESP - Dari script sebelumnya")
print("✅ Semua fitur dalam keadaan OFF default")
print("✅ Highlight - Team colors")
print("✅ Generator ESP + Anti-Fail")
print("✅ Healing Anti-Fail")
print("✅ Visual - Fullbright, No Fog, Wallhack, Infinite Zoom")
print("✅ Movement - Speed, Jump, Infinite Jump, Noclip")
print("✅ Teleport - To Player + Waypoints")
print("✅ Misc - Anti AFK, Auto Click")
print("═══════════════════════════════════════════════════════")