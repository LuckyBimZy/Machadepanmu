-- ==================== VIOLENCE DISTRICT - ULTIMATE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.1 (Fixed ESP - Highlight Only)

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
local TeamColor = Color3.fromRGB(255, 255, 255) -- PUTIH untuk teammate
local EnemyColor = Color3.fromRGB(255, 0, 0)    -- MERAH untuk killer/enemy
local LobbyColor = Color3.fromRGB(255, 255, 255) -- PUTIH untuk lobby

--==================================================
-- CONFIG
--==================================================
local Config = {
    ESP = {
        Enabled = false,
        -- Box dimatikan secara default (tidak digunakan)
        Boxes = false,
        Names = true,
        Distance = true,
        Health = false,
        Tracers = false,
        TeamCheck = true,
        MaxDistance = 2000,
        ShowTeammates = true -- Ubah jadi true agar teammate muncul
    },
    Highlight = {
        Enabled = false,
        TeamCheck = true,
        ShowTeam = true
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
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Violence District",
    Subtext = "ULTIMATE Edition",
    Version = "v3.1",
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
    Name = "Player ESP",
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
-- MAIN TAB - PLAYER INFO
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Player info dengan tampilan lebih besar dan jelas
PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName .. "\n" ..
           "User ID: " .. Player.UserId .. "\n" ..
           "Account Age: " .. Player.AccountAge .. " days\n" ..
           "Team: " .. (Player.Team and Player.Team.Name or "No Team"),
    Image = "user",
    ImageSize = 48
})

local ServerInfoSection = MainTab:AddSection({
    Name = "🌐 SERVER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local function UpdateServerInfo()
    local players = Players:GetPlayers()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
    
    return "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
           "Ping: " .. ping .. "ms\n" ..
           "Server Time: " .. os.date("%H:%M:%S")
end

local ServerInfoPara = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = UpdateServerInfo(),
    Image = "server",
    ImageSize = 48,
    Buttons = {
        {
            Title = "🔄 Refresh",
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
    Name = "⚡ ACTIVE FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local ActiveFeaturesPara = ActiveFeaturesSection:AddParagraph({
    Title = "Currently Active",
    Desc = "No active features",
    Image = "activity",
    ImageSize = 38
})

-- Update active features setiap detik
task.spawn(function()
    while true do
        local active = GetActiveFeatures()
        if #active > 0 then
            ActiveFeaturesPara:SetDesc(table.concat(active, " • "))
        else
            ActiveFeaturesPara:SetDesc("No active features")
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
    -- Di lobby atau tidak ada team, semua putih
    if not Player.Team or not player.Team then
        return LobbyColor
    end
    
    -- Di dalam game
    if isTeammate(player) then
        return TeamColor -- PUTIH untuk teammate
    else
        return EnemyColor -- MERAH untuk enemy/killer
    end
end

--==================================================
-- PLAYER ESP SYSTEM - HIGHLIGHT ONLY (TANPA BOX)
--==================================================
local ESPObjects = {}

local function createPlayerESP(player)
    if player == Player then return end
    if ESPObjects[player] then return end
    
    ESPObjects[player] = {
        -- HAPUS BOX - hanya pakai Name, Distance, dan Tracer (opsional)
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    local esp = ESPObjects[player]
    
    -- Name settings - FONT BESAR DAN JELAS
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255) -- Putih
    esp.Name.Size = 20 -- Font lebih besar
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 3 -- Font bold
    
    -- Distance settings
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 16 -- Ukuran lebih besar
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 3
    
    -- Tracer settings (opsional)
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 1.5
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
        
        -- Team check - jika ShowTeammates false dan dia teammate, sembunyikan
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
        
        local playerColor = getPlayerColor(player)
        
        -- NAME (selalu putih, warna hanya untuk tracer)
        if Config.ESP.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 50) -- Naikkan posisi
            esp.Name.Color = Color3.fromRGB(255, 255, 255) -- Tetap putih
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- DISTANCE
        if Config.ESP.Distance then
            esp.Distance.Text = string.format("[%.0fm]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + 40)
            esp.Distance.Color = Color3.fromRGB(255, 255, 255) -- Putih
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        -- TRACER (warna sesuai team/enemy)
        if Config.ESP.Tracers then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.From = screenCenter
            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            esp.Tracer.Color = playerColor -- Warna sesuai role (putih/merah)
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
-- HIGHLIGHT SYSTEM (SEPERTI GENERATOR)
--==================================================
local Highlights = {}

local function createHighlight(player)
    if player == Player then return end
    if not player.Character then return end
    
    -- Hapus highlight lama jika ada
    if Highlights[player] then
        Highlights[player]:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = player.Character
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.3 -- Sedikit transparan seperti generator
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Selalu di atas
    
    -- Di lobby atau tidak ada team, semua putih
    if not Player.Team or not player.Team then
        highlight.FillColor = LobbyColor -- PUTIH
        highlight.OutlineColor = LobbyColor
    else
        -- Di dalam game
        if isTeammate(player) then
            highlight.FillColor = TeamColor -- PUTIH untuk teammate
            highlight.OutlineColor = TeamColor
        else
            highlight.FillColor = EnemyColor -- MERAH untuk enemy/killer
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

local function updateHighlights()
    for player, highlight in pairs(Highlights) do
        if not player or not player.Parent or not player.Character then
            removeHighlight(player)
            continue
        end
        
        -- Jika highlight dimatikan, sembunyikan
        if not Config.Highlight.Enabled then
            highlight.Enabled = false
            continue
        else
            highlight.Enabled = true
        end
        
        -- Update warna berdasarkan kondisi
        if not Player.Team or not player.Team then
            highlight.FillColor = LobbyColor
            highlight.OutlineColor = LobbyColor
        else
            if isTeammate(player) then
                highlight.FillColor = TeamColor
                highlight.OutlineColor = TeamColor
            else
                highlight.FillColor = EnemyColor
                highlight.OutlineColor = EnemyColor
            end
        end
    end
end

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
        -- Restore normal materials
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
    updateHighlights()
    updateNoFog()
    updateFullbright()
    updateInfiniteZoom()
    updateWallhack()
end)

--==================================================
-- ESP TAB (TANPA BOX)
--==================================================
local ESPSection = ESPTab:AddSection({
    Name = "🎯 PLAYER ESP SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ESPSection:AddToggle({
    Name = "ENABLE ESP (HIGHLIGHT STYLE)",
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
            Notify("Player ESP Enabled - White for teammates, Red for enemies")
        else
            for player, _ in pairs(ESPObjects) do
                removePlayerESP(player)
            end
        end
    end
})

ESPSection:AddToggle({
    Name = "SHOW NAMES (WHITE - LARGE FONT)",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPNames",
    Save = true,
    Callback = function(Value) Config.ESP.Names = Value end
})

ESPSection:AddToggle({
    Name = "SHOW DISTANCE",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPDistance",
    Save = true,
    Callback = function(Value) Config.ESP.Distance = Value end
})

ESPSection:AddToggle({
    Name = "SHOW TRACERS (COLOR CODED)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPTracers",
    Save = true,
    Callback = function(Value) Config.ESP.Tracers = Value end
})

ESPSection:AddToggle({
    Name = "TEAM CHECK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPTeamCheck",
    Save = true,
    Callback = function(Value) Config.ESP.TeamCheck = Value end
})

ESPSection:AddToggle({
    Name = "SHOW TEAMMATES",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
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
    ValueName = "meters",
    Outline = true,
    Callback = function(Value) Config.ESP.MaxDistance = Value end
})

ESPSection:AddParagraph({
    Title = "COLOR GUIDE",
    Desc = "⚪ WHITE = Teammate/Lobby\n🔴 RED = Enemy/Killer\n📝 Names always WHITE",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- HIGHLIGHT TAB
--==================================================
local HighlightSection = HighlightTab:AddSection({
    Name = "✨ CHARACTER HIGHLIGHT (LIKE GENERATOR)",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HighlightSection:AddToggle({
    Name = "ENABLE HIGHLIGHT",
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
            
            Players.PlayerAdded:Connect(function(player)
                if Config.Highlight.Enabled then
                    repeat task.wait() until player.Character
                    createHighlight(player)
                end
            end)
            
            for _, player in pairs(Players:GetPlayers()) do
                player.CharacterAdded:Connect(function()
                    if Config.Highlight.Enabled then
                        task.wait(0.5)
                        createHighlight(player)
                    end
                end)
            end
            
            Notify("Highlight Enabled - White for teammates, Red for enemies")
        else
            for player, _ in pairs(Highlights) do
                removeHighlight(player)
            end
        end
    end
})

HighlightSection:AddToggle({
    Name = "AUTO TEAM COLORS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightTeam",
    Save = true,
    Callback = function(Value) Config.Highlight.TeamCheck = Value end
})

HighlightSection:AddParagraph({
    Title = "COLOR GUIDE",
    Desc = "⚪ WHITE = Teammate/Lobby\n🔴 RED = Enemy/Killer",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- MOVEMENT TAB
--==================================================
local SpeedSection = MovementTab:AddSection({
    Name = "⚡ SPEED HACK",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SpeedSection:AddToggle({
    Name = "ENABLE SPEED BOOST",
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

SpeedSection:AddSlider({
    Name = "SPEED VALUE",
    Min = 16,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Callback = function(Value)
        Config.Movement.SpeedValue = Value
    end
})

local JumpSection = MovementTab:AddSection({
    Name = "🦘 JUMP HACK",
    TextSize = 18,
    Glass = true,
    Outline = true
})

JumpSection:AddToggle({
    Name = "ENABLE JUMP BOOST",
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

JumpSection:AddSlider({
    Name = "JUMP POWER",
    Min = 50,
    Max = 300,
    Default = 100,
    Increment = 5,
    ValueName = "JP",
    Outline = true,
    Callback = function(Value)
        Config.Movement.JumpValue = Value
    end
})

local ExtraSection = MovementTab:AddSection({
    Name = "🚀 EXTRA MOVEMENT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ExtraSection:AddToggle({
    Name = "INFINITE JUMP",
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
    Name = "NOCLIP (WALK THROUGH WALLS)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Movement.Noclip = Value
        
        if Value then
            enableNoclip()
            Notify("Noclip Enabled - You can walk through walls!")
        else
            disableNoclip()
            Notify("Noclip Disabled - Collision restored")
        end
    end
})

--==================================================
-- VISUAL TAB
--==================================================
local VisualMainSection = VisualTab:AddSection({
    Name = "☀️ VISUAL ENHANCEMENTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

VisualMainSection:AddToggle({
    Name = "WALLHACK (SEE THROUGH WALLS)",
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
    Name = "FULLBRIGHT (BRIGHT MAP)",
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
    Name = "NO FOG",
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
    Name = "INFINITE ZOOM OUT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "InfiniteZoom",
    Save = true,
    Callback = function(Value)
        Config.Visual.InfiniteZoom = Value
        updateInfiniteZoom()
        Notify(Value and "Infinite Zoom Enabled" or "Infinite Zoom Disabled")
    end
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportMainSection = TeleportTab:AddSection({
    Name = "📍 TELEPORT TO PLAYER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local SelectedPlayer = ""

TeleportMainSection:AddDropdown({
    Name = "SELECT PLAYER",
    Default = "Select a player",
    Options = getPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

TeleportMainSection:AddButton({
    Name = "🚀 TELEPORT TO SELECTED PLAYER",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        if SelectedPlayer and SelectedPlayer ~= "" then
            teleportToPlayer(SelectedPlayer)
        else
            Notify("Please select a player first!")
        end
    end
})

TeleportMainSection:AddButton({
    Name = "🔄 REFRESH PLAYER LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
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
    Name = "💾 SAVE CURRENT POSITION",
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
    Name = "📂 LOAD SAVED POSITION",
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
-- MISC TAB
--==================================================
local MiscMainSection = MiscTab:AddSection({
    Name = "⚙️ UTILITY FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddToggle({
    Name = "ANTI AFK (PREVENT IDLE KICK)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.Misc.AntiAFK = Value
        setupAntiAFK()
        Notify(Value and "Anti AFK Enabled" or "Anti AFK Disabled")
    end
})

--==================================================
-- GENERATOR TAB
--==================================================
local GenSection = GeneratorTab:AddSection({
    Name = "⚡ GENERATOR FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

GenSection:AddToggle({
    Name = "ENABLE GENERATOR ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "GenESP",
    Save = true,
    Callback = function(Value)
        Config.Generator.ESPEnabled = Value
    end
})

GenSection:AddToggle({
    Name = "ENABLE ANTI-FAIL GENERATOR",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
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
    Name = "❤️ HEALING FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HealSection:AddToggle({
    Name = "ENABLE ANTI-FAIL HEALING",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
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
    Name = "🎮 UI SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

UISection:AddToggle({
    Name = "HIDE SKILL CHECK UI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
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
    highlight.FillTransparency = 0.3
    
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
                
                -- GENERATOR ANTI-FAIL
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
                
                -- HEALING ANTI-FAIL
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
    
    -- Re-apply noclip if enabled
    if Config.Movement.Noclip then
        enableNoclip()
    end
    
    -- Reset speed/jump if enabled
    if Config.Movement.SpeedEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Config.Movement.SpeedValue end
    end
    
    if Config.Movement.JumpEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Config.Movement.JumpValue end
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
print("🔥 VIOLENCE DISTRICT - ULTIMATE Edition v3.1 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Player ESP - HIGHLIGHT ONLY (No Boxes)")
print("   ⚪ White = Teammate/Lobby")
print("   🔴 Red = Enemy/Killer")
print("✅ Movement - Speed, Jump, Infinite Jump, Noclip")
print("✅ Visual - Wallhack, Fullbright, No Fog, Infinite Zoom")
print("✅ Teleport - Player TP, Waypoints, Refresh List")
print("✅ Misc - Anti AFK, Active Features Counter")
print("═══════════════════════════════════════════════════════")