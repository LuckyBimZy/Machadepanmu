-- ==================== VIOLENCE DISTRICT - ULTIMATE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.1 FINAL

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
        InfiniteZoom = false
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
        AntiAFK = false
    }
}

--==================================================
-- ACTIVE FEATURES COUNTER
--==================================================
local function GetActiveFeatures()
    local active = {}
    
    if Config.ESP.Enabled then table.insert(active, "ESP") end
    if Config.Highlight.Enabled then table.insert(active, "Highlight") end
    if Config.Generator.ESPEnabled then table.insert(active, "GenESP") end
    if Config.Generator.AntiFailEnabled then table.insert(active, "Anti-Gen") end
    if Config.Healing.AntiFailEnabled then table.insert(active, "Anti-Heal") end
    if Config.UI.HideSkillCheck then table.insert(active, "HideSC") end
    if Config.Visual.FullbrightEnabled then table.insert(active, "Fullbright") end
    if Config.Visual.NoFogEnabled then table.insert(active, "NoFog") end
    if Config.Visual.WallhackEnabled then table.insert(active, "Wallhack") end
    if Config.Visual.InfiniteZoom then table.insert(active, "InfZoom") end
    if Config.Movement.SpeedEnabled then table.insert(active, "Speed") end
    if Config.Movement.JumpEnabled then table.insert(active, "Jump") end
    if Config.Movement.InfiniteJump then table.insert(active, "InfJump") end
    if Config.Movement.Noclip then table.insert(active, "Noclip") end
    if Config.Misc.AntiAFK then table.insert(active, "AntiAFK") end
    
    return active
end

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
-- CREATE MAIN WINDOW - TANPA BACKGROUND PUTIH
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Violence District",
    Subtext = "ULTIMATE Edition",
    Version = "v3.1",
    VersionIcon = "shield",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VD_ULTIMATE",
    IntroEnabled = false, -- Matikan intro biar ga ada efek putih
    IntroText = "",
    IntroIcon = "",
    Icon = "",
    ShowIcon = false,
    
    -- Custom Theme & Appearance - Buat lebih transparan
    ImageBackground = "",
    ImageTransparency = 1,
    WindowTransparency = 0.15,
    
    -- Floating Toggle Customization
    ToggleIcon = "",
    ToggleSize = 40
})

-- Set Theme ke Void biar gelap
OrionLib.SelectedTheme = "Void"

Notify("Script loaded successfully!")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = false -- Hilangkan outline
})

local ESPTab = Window:MakeTab({
    Name = "Player ESP",
    Icon = "eye",
    Glass = true,
    Outline = false
})

local HighlightTab = Window:MakeTab({
    Name = "Highlight",
    Icon = "sparkles",
    Glass = true,
    Outline = false
})

local GeneratorTab = Window:MakeTab({
    Name = "Generator",
    Icon = "zap",
    Glass = true,
    Outline = false
})

local HealingTab = Window:MakeTab({
    Name = "Healing",
    Icon = "heart",
    Glass = true,
    Outline = false
})

local VisualTab = Window:MakeTab({
    Name = "Visual",
    Icon = "sun",
    Glass = true,
    Outline = false
})

local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "footprints",
    Glass = true,
    Outline = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "map-pin",
    Glass = true,
    Outline = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    Glass = true,
    Outline = false
})

--==================================================
-- MAIN TAB - PLAYER INFO
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "PLAYER INFORMATION",
    TextSize = 16,
    Glass = true,
    Outline = false
})

-- Player info dengan tampilan lebih besar dan jelas
PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display: " .. Player.DisplayName .. "\n" ..
           "ID: " .. Player.UserId .. "\n" ..
           "Age: " .. Player.AccountAge .. " days\n" ..
           "Team: " .. (Player.Team and Player.Team.Name or "None"),
    Image = "user",
    ImageSize = 40
})

local ServerInfoSection = MainTab:AddSection({
    Name = "SERVER INFORMATION",
    TextSize = 16,
    Glass = true,
    Outline = false
})

local function UpdateServerInfo()
    local players = Players:GetPlayers()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
    
    return "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
           "Ping: " .. ping .. "ms\n" ..
           "Time: " .. os.date("%H:%M:%S")
end

local ServerInfoPara = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = UpdateServerInfo(),
    Image = "server",
    ImageSize = 40,
    Buttons = {
        {
            Title = "⟳ Refresh",
            Callback = function()
                ServerInfoPara:SetDesc(UpdateServerInfo())
            end
        }
    }
})

-- Auto refresh server info
task.spawn(function()
    while true do
        task.wait(5)
        ServerInfoPara:SetDesc(UpdateServerInfo())
    end
end)

local ActiveFeaturesSection = MainTab:AddSection({
    Name = "ACTIVE FEATURES",
    TextSize = 16,
    Glass = true,
    Outline = false
})

local ActiveFeaturesPara = ActiveFeaturesSection:AddParagraph({
    Title = "Currently Active",
    Desc = "None",
    Image = "activity",
    ImageSize = 32
})

-- Update active features setiap detik
task.spawn(function()
    while true do
        local active = GetActiveFeatures()
        if #active > 0 then
            ActiveFeaturesPara:SetDesc(table.concat(active, " • "))
        else
            ActiveFeaturesPara:SetDesc("None")
        end
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
-- PLAYER ESP SYSTEM - DENGAN FONT TEBAL DAN POSISI PRESISI
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
    
    -- Box settings - posisi presisi
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255, 255, 255)
    
    -- Name settings - FONT SANGAT TEBAL DAN BESAR
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255) -- Putih
    esp.Name.Size = 22 -- Ukuran font lebih besar
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.OutlineTransparency = 0.5
    esp.Name.Font = 3 -- Font paling tebal (Enum.Font.SourceSansBold)
    
    -- Distance settings
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(255, 255, 255)
    esp.Distance.Size = 18
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 3
    
    -- Health bar settings
    esp.HealthBarBG.Visible = false
    esp.HealthBarBG.Color = Color3.fromRGB(30, 30, 30)
    esp.HealthBarBG.Thickness = 1
    esp.HealthBarBG.Transparency = 0.5
    esp.HealthBarBG.Filled = true
    
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 1
    esp.HealthBar.Filled = true
    
    -- Tracer settings
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 1.5
    esp.Tracer.Transparency = 1
    esp.Tracer.Color = Color3.fromRGB(255, 255, 255)
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
        
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos = Camera:WorldToViewportPoint(hrp.Position)
        local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        if not onScreen then
            for _, obj in pairs(esp) do obj.Visible = false end
            continue
        end
        
        -- Hitung ukuran box berdasarkan tinggi karakter
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height * 0.6
        local boxSize = Vector2.new(width, height)
        local playerColor = getPlayerColor(player)
        
        -- BOX - posisi presisi mengelilingi karakter
        if Config.ESP.Boxes then
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            esp.Box.Color = playerColor
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        -- NAMA - di atas kepala dengan font tebal
        if Config.ESP.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 50)
            esp.Name.Color = Color3.fromRGB(255, 255, 255) -- Putih
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- JARAK - di bawah kaki
        if Config.ESP.Distance then
            esp.Distance.Text = string.format("[%.0fm]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, footPos.Y + 20)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        -- HEALTH BAR - di samping kiri box
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
        
        -- TRACER - dari kaki ke tengah layar bawah
        if Config.ESP.Tracers then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.From = screenCenter
            esp.Tracer.To = Vector2.new(rootPos.X, footPos.Y)
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
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Player then
        setupPlayerESP(player)
    end
end

Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

--==================================================
-- WALLHACK FUNCTION
--==================================================
local WallhackConnection = nil

local function updateWallhack()
    if WallhackConnection then
        WallhackConnection:Disconnect()
        WallhackConnection = nil
    end
    
    if Config.Visual.WallhackEnabled then
        WallhackConnection = RunService.RenderStepped:Connect(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
                    if v.Transparency < 0.5 then
                        v.Material = Enum.Material.ForceField
                        v.Transparency = 0.5
                    end
                end
            end
        end)
    else
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
            end
        end
    end
end

--==================================================
-- NO FOG FUNCTION
--==================================================
local function updateNoFog()
    if Config.Visual.NoFogEnabled then
        Lighting.FogEnd = 1e9
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end

--==================================================
-- INFINITE ZOOM FUNCTION
--==================================================
local function updateInfiniteZoom()
    if Config.Visual.InfiniteZoom and Camera then
        Camera.FieldOfView = 120
    elseif Camera then
        Camera.FieldOfView = 70
    end
end

--==================================================
-- FULLBRIGHT FUNCTION
--==================================================
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

--==================================================
-- MOVEMENT SYSTEM
--==================================================
local noclipConnection = nil
local infiniteJumpConnection = nil

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

-- Infinite Jump
if infiniteJumpConnection then
    infiniteJumpConnection:Disconnect()
end

infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
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
-- ANTI AFK SYSTEM
--==================================================
local antiAFKConnection = nil

local function setupAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    
    if Config.Misc.AntiAFK then
        antiAFKConnection = Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

--==================================================
-- TELEPORT FUNCTIONS
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

local function teleportToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        Notify("Teleported to " .. playerName)
        return true
    end
    Notify("Player not found or invalid")
    return false
end

--==================================================
-- UPDATE LOOP
--==================================================
RunService.Heartbeat:Connect(function()
    updateMovement()
    updatePlayerESP()
    updateNoFog()
    updateFullbright()
    updateInfiniteZoom()
    updateWallhack()
end)

--==================================================
-- ESP TAB
--==================================================
local ESPSection = ESPTab:AddSection({
    Name = "PLAYER ESP SETTINGS",
    TextSize = 16,
    Glass = true,
    Outline = false
})

ESPSection:AddToggle({
    Name = "ENABLE ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
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
    Name = "SHOW BOXES",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "ESPBoxes",
    Save = true,
    Callback = function(Value) Config.ESP.Boxes = Value end
})

ESPSection:AddToggle({
    Name = "SHOW NAMES (WHITE - BOLD)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "ESPNames",
    Save = true,
    Callback = function(Value) Config.ESP.Names = Value end
})

ESPSection:AddToggle({
    Name = "SHOW DISTANCE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "ESPDistance",
    Save = true,
    Callback = function(Value) Config.ESP.Distance = Value end
})

ESPSection:AddToggle({
    Name = "SHOW HEALTH BAR",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "ESPHealth",
    Save = true,
    Callback = function(Value) Config.ESP.Health = Value end
})

ESPSection:AddToggle({
    Name = "SHOW TRACERS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "ESPTracers",
    Save = true,
    Callback = function(Value) Config.ESP.Tracers = Value end
})

ESPSection:AddToggle({
    Name = "TEAM CHECK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "ESPTeamCheck",
    Save = true,
    Callback = function(Value) Config.ESP.TeamCheck = Value end
})

ESPSection:AddToggle({
    Name = "SHOW TEAMMATES",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "ESPShowTeam",
    Save = true,
    Callback = function(Value) Config.ESP.ShowTeammates = Value end
})

ESPSection:AddSlider({
    Name = "MAX ESP DISTANCE",
    Min = 500,
    Max = 5000,
    Default = 2000,
    Increment = 100,
    ValueName = "m",
    Outline = false,
    Callback = function(Value) Config.ESP.MaxDistance = Value end
})

ESPSection:AddParagraph({
    Title = "COLOR GUIDE",
    Desc = "🟢 Teammate\n🔴 Enemy\n⬜ White names",
    Image = "info",
    ImageSize = 32
})

--==================================================
-- MOVEMENT TAB
--==================================================
local SpeedSection = MovementTab:AddSection({
    Name = "SPEED HACK",
    TextSize = 16,
    Glass = true,
    Outline = false
})

SpeedSection:AddToggle({
    Name = "ENABLE SPEED",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "SpeedEnable",
    Save = true,
    Callback = function(Value)
        Config.Movement.SpeedEnabled = Value
    end
})

SpeedSection:AddSlider({
    Name = "SPEED VALUE",
    Min = 16,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "WS",
    Outline = false,
    Callback = function(Value)
        Config.Movement.SpeedValue = Value
    end
})

local JumpSection = MovementTab:AddSection({
    Name = "JUMP HACK",
    TextSize = 16,
    Glass = true,
    Outline = false
})

JumpSection:AddToggle({
    Name = "ENABLE JUMP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "JumpEnable",
    Save = true,
    Callback = function(Value)
        Config.Movement.JumpEnabled = Value
    end
})

JumpSection:AddSlider({
    Name = "JUMP POWER",
    Min = 50,
    Max = 300,
    Default = 100,
    Increment = 5,
    ValueName = "JP",
    Outline = false,
    Callback = function(Value)
        Config.Movement.JumpValue = Value
    end
})

local ExtraSection = MovementTab:AddSection({
    Name = "EXTRA MOVEMENT",
    TextSize = 16,
    Glass = true,
    Outline = false
})

ExtraSection:AddToggle({
    Name = "INFINITE JUMP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "InfiniteJump",
    Save = true,
    Callback = function(Value)
        Config.Movement.InfiniteJump = Value
    end
})

ExtraSection:AddToggle({
    Name = "NOCLIP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Movement.Noclip = Value
        if Value then
            enableNoclip()
        else
            disableNoclip()
        end
    end
})

--==================================================
-- VISUAL TAB
--==================================================
local VisualMainSection = VisualTab:AddSection({
    Name = "VISUAL ENHANCEMENTS",
    TextSize = 16,
    Glass = true,
    Outline = false
})

VisualMainSection:AddToggle({
    Name = "WALLHACK",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "Wallhack",
    Save = true,
    Callback = function(Value)
        Config.Visual.WallhackEnabled = Value
        updateWallhack()
    end
})

VisualMainSection:AddToggle({
    Name = "FULLBRIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "Fullbright",
    Save = true,
    Callback = function(Value)
        Config.Visual.FullbrightEnabled = Value
        updateFullbright()
    end
})

VisualMainSection:AddToggle({
    Name = "NO FOG",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "NoFog",
    Save = true,
    Callback = function(Value)
        Config.Visual.NoFogEnabled = Value
        updateNoFog()
    end
})

VisualMainSection:AddToggle({
    Name = "INFINITE ZOOM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "InfiniteZoom",
    Save = true,
    Callback = function(Value)
        Config.Visual.InfiniteZoom = Value
        updateInfiniteZoom()
    end
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportMainSection = TeleportTab:AddSection({
    Name = "TELEPORT TO PLAYER",
    TextSize = 16,
    Glass = true,
    Outline = false
})

local SelectedPlayer = ""

TeleportMainSection:AddDropdown({
    Name = "SELECT PLAYER",
    Default = "Select...",
    Options = getPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = false,
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

TeleportMainSection:AddButton({
    Name = "TELEPORT",
    Icon = "map-pin",
    Outline = false,
    Callback = function()
        if SelectedPlayer and SelectedPlayer ~= "" and SelectedPlayer ~= "Select..." then
            teleportToPlayer(SelectedPlayer)
        else
            Notify("Select a player first!")
        end
    end
})

TeleportMainSection:AddButton({
    Name = "REFRESH LIST",
    Icon = "refresh-cw",
    Outline = false,
    Callback = function()
        Notify("Player list refreshed")
    end
})

local WaypointSection = TeleportTab:AddSection({
    Name = "WAYPOINTS",
    TextSize = 16,
    Glass = true,
    Outline = false
})

WaypointSection:AddButton({
    Name = "SAVE POSITION",
    Icon = "save",
    Outline = false,
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Config.Teleport.SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Position saved!")
        end
    end
})

WaypointSection:AddButton({
    Name = "LOAD POSITION",
    Icon = "upload",
    Outline = false,
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
local MiscMainSection = MiscTab:AddSection({
    Name = "UTILITY",
    TextSize = 16,
    Glass = true,
    Outline = false
})

MiscMainSection:AddToggle({
    Name = "ANTI AFK",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.Misc.AntiAFK = Value
        setupAntiAFK()
    end
})

--==================================================
-- HIGHLIGHT TAB
--==================================================
local HighlightSection = HighlightTab:AddSection({
    Name = "HIGHLIGHT",
    TextSize = 16,
    Glass = true,
    Outline = false
})

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
    end
    
    Highlights[player] = highlight
end

local function removeHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

HighlightSection:AddToggle({
    Name = "ENABLE HIGHLIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
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
        else
            for player, _ in pairs(Highlights) do
                removeHighlight(player)
            end
        end
    end
})

--==================================================
-- GENERATOR TAB
--==================================================
local GenSection = GeneratorTab:AddSection({
    Name = "GENERATOR",
    TextSize = 16,
    Glass = true,
    Outline = false
})

GenSection:AddToggle({
    Name = "ENABLE GENERATOR ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "GenESP",
    Save = true,
    Callback = function(Value)
        Config.Generator.ESPEnabled = Value
    end
})

GenSection:AddToggle({
    Name = "ANTI-FAIL GENERATOR",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "GenAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Generator.AntiFailEnabled = Value
    end
})

--==================================================
-- HEALING TAB
--==================================================
local HealSection = HealingTab:AddSection({
    Name = "HEALING",
    TextSize = 16,
    Glass = true,
    Outline = false
})

HealSection:AddToggle({
    Name = "ANTI-FAIL HEALING",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "HealAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Healing.AntiFailEnabled = Value
    end
})

--==================================================
-- HIDE SKILL CHECK UI
--==================================================
local UISection = VisualTab:AddSection({
    Name = "UI SETTINGS",
    TextSize = 16,
    Glass = true,
    Outline = false
})

UISection:AddToggle({
    Name = "HIDE SKILL CHECK",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = false,
    Flag = "HideSkillCheck",
    Save = true,
    Callback = function(Value)
        Config.UI.HideSkillCheck = Value
    end
})

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
-- GENERATOR ESP SYSTEM
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
    textLabel.TextSize = 16
    
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
-- ANTI-FAIL SYSTEM
--==================================================
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
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    
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

Notify("Press F4 to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 VIOLENCE DISTRICT - ULTIMATE Edition v3.1 🔥")
print("═══════════════════════════════════════════════════════")