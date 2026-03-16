-- ==================== VIOLENCE DISTRICT - ULTIMATE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Adapted from LuckyBimZy & RanZx999
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
        InfiniteZoomEnabled = false
    },
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 50,
        JumpEnabled = false,
        JumpValue = 100,
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

-- Untuk tracking active features
local ActiveFeatures = {
    ESP = false,
    Highlight = false,
    GenESP = false,
    GenAntiFail = false,
    HealAntiFail = false,
    HideSkillCheck = false,
    Fullbright = false,
    NoFog = false,
    Wallhack = false,
    InfiniteZoom = false,
    Speed = false,
    Jump = false,
    InfiniteJump = false,
    Noclip = false,
    AntiAFK = false
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
-- UPDATE ACTIVE FEATURES COUNTER
--==================================================
local function updateActiveFeaturesCount()
    local count = 0
    for _, v in pairs(ActiveFeatures) do
        if v then count = count + 1 end
    end
    return count
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
    Name = "Player Information",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Player info dengan tampilan yang lebih jelas
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
    Name = "Server Information",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Fungsi untuk update server info
local function updateServerInfo()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    local players = #Players:GetPlayers()
    local serverTime = math.floor(workspace.DistributedGameTime)
    local hours = math.floor(serverTime / 3600)
    local minutes = math.floor((serverTime % 3600) / 60)
    local seconds = serverTime % 60
    
    return "Players: " .. players .. "/" .. Players.MaxPlayers .. "\n" ..
           "Ping: " .. ping .. " ms\n" ..
           "Server Time: " .. string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local serverInfoParagraph = ServerInfoSection:AddParagraph({
    Title = "🌐 Server Status",
    Desc = updateServerInfo(),
    Image = "server",
    ImageSize = 48,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                serverInfoParagraph:SetDesc(updateServerInfo())
            end
        }
    }
})

local ActiveFeaturesSection = MainTab:AddSection({
    Name = "Active Features",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local activeFeaturesParagraph = ActiveFeaturesSection:AddParagraph({
    Title = "📊 Status",
    Desc = "Active Features: " .. updateActiveFeaturesCount() .. "\n" ..
           "Check each tab for details",
    Image = "activity",
    ImageSize = 48
})

-- Update active features setiap 2 detik
task.spawn(function()
    while true do
        activeFeaturesParagraph:SetDesc("Active Features: " .. updateActiveFeaturesCount() .. "\n" ..
                                       "Check each tab for details")
        task.wait(2)
    end
end)

--==================================================
-- PLAYER ESP SYSTEM (AUTO-DETECT) - DIPERJELAS
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
    
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    -- Name dengan font lebih besar dan putih
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255) -- Putih
    esp.Name.Size = 18 -- Lebih besar
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 3 -- Font lebih tebal
    
    -- Distance dengan font lebih besar
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 16
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 3
    
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
            esp.Name.Text = player.Name .. (isTeammate(player) and " (Team)" or " (Enemy)")
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 40)
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        if Config.ESP.Distance then
            esp.Distance.Text = string.format("[%.0f meters]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxSize.Y / 2 + 25)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        if Config.ESP.Health and hum then
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
-- WALLHACK FUNCTION
--==================================================
local wallhackConnection = nil

local function updateWallhack()
    if Config.Visual.WallhackEnabled then
        if wallhackConnection then wallhackConnection:Disconnect() end
        
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
    else
        if wallhackConnection then
            wallhackConnection:Disconnect()
            wallhackConnection = nil
        end
        
        -- Restore original materials
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
            end
        end
    end
end

--==================================================
-- INFINITE ZOOM
--==================================================
local function updateInfiniteZoom()
    if Config.Visual.InfiniteZoomEnabled and Camera then
        Camera.FieldOfView = 120
    elseif Camera then
        Camera.FieldOfView = 70
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
-- VISUAL SYSTEMS (FULLBRIGHT, NO FOG)
--==================================================
task.spawn(function()
    while true do
        -- Fullbright
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
        
        -- No Fog
        if Config.Visual.NoFogEnabled then
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.FogStart = originalLighting.FogStart or 0
        end
        
        -- Atmosphere removal for Fullbright
        if Config.Visual.FullbrightEnabled or Config.Visual.NoFogEnabled then
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
            -- Restore atmosphere
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
        
        -- Infinite Zoom
        updateInfiniteZoom()
        
        task.wait(0.5)
    end
end)

--==================================================
-- MOVEMENT SYSTEM (COMPLETE)
--==================================================
local noclipConnection = nil

local function updateMovement()
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    -- Speed Hack
    if Config.Movement.SpeedEnabled then
        hum.WalkSpeed = Config.Movement.SpeedValue
        ActiveFeatures.Speed = true
    else
        hum.WalkSpeed = 16
        ActiveFeatures.Speed = false
    end
    
    -- Jump Hack
    if Config.Movement.JumpEnabled then
        hum.JumpPower = Config.Movement.JumpValue
        ActiveFeatures.Jump = true
    else
        hum.JumpPower = 50
        ActiveFeatures.Jump = false
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
-- ANTI AFK SYSTEM
--==================================================
local antiAFKConnection = nil

local function enableAntiAFK()
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    
    antiAFKConnection = RunService.Heartbeat:Connect(function()
        if Config.Misc.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

local function disableAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
end

--==================================================
-- TELEPORT FUNCTIONS
--==================================================
local SavedPosition = nil

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
-- RUN SERVICE UPDATES
--==================================================
RunService.Heartbeat:Connect(function()
    updateMovement()
    updatePlayerESP()
    if Config.Highlight.Enabled then
        updateHighlights()
    end
end)

-- Generator ESP scanner
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
-- MAIN TAB CONTENT (sudah dibuat di atas)
--==================================================

--==================================================
-- ESP TAB
--==================================================
local ESPSection = ESPTab:AddSection({
    Name = "⚡ PLAYER ESP (AUTO-DETECT) ⚡",
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
        ActiveFeatures.ESP = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    createPlayerESP(player)
                end
            end
            Notify("✅ Player ESP Enabled")
        else
            for player, _ in pairs(ESPObjects) do
                removePlayerESP(player)
            end
            Notify("❌ Player ESP Disabled")
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
    Name = "Show Names (Large White Text)",
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
    ValueName = "meters",
    Outline = true,
    Callback = function(Value) Config.ESP.MaxDistance = Value end
})

ESPSection:AddParagraph({
    Title = "Color Guide",
    Desc = "🟢 Green = Teammate\n🔴 Red = Enemy\n⚪ White Names = All Players",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- HIGHLIGHT TAB
--==================================================
local HighlightSection = HighlightTab:AddSection({
    Name = "Character Highlight",
    TextSize = 17,
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
        ActiveFeatures.Highlight = Value
        
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
            
            Notify("✅ Highlight Enabled")
        else
            for player, _ in pairs(Highlights) do
                removeHighlight(player)
            end
            Notify("❌ Highlight Disabled")
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

HighlightSection:AddParagraph({
    Title = "Color Guide",
    Desc = "🟢 Green = Teammate\n🔴 Red = Enemy",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- GENERATOR TAB
--==================================================
local GenSection = GeneratorTab:AddSection({
    Name = "Generator ESP",
    TextSize = 17,
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
        ActiveFeatures.GenESP = Value
        
        if Value then
            Notify("✅ Generator ESP Enabled")
        else
            for gen, folder in pairs(GeneratorESP) do
                if folder then folder:Destroy() end
            end
            GeneratorESP = {}
            Notify("❌ Generator ESP Disabled")
        end
    end
})

GenSection:AddParagraph({
    Title = "Color Guide",
    Desc = "🔵 Cyan = In Progress\n🟢 Green = Complete (100%)",
    Image = "info",
    ImageSize = 38
})

GenSection:AddSection({
    Name = "Anti-Fail Generator",
    TextSize = 17,
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
        ActiveFeatures.GenAntiFail = Value
        Notify(Value and "✅ Anti-Fail Generator Enabled" or "❌ Anti-Fail Generator Disabled")
    end
})

GenSection:AddParagraph({
    Title = "Info",
    Desc = "✅ Auto-pass generator skill checks\n✅ Hold left click to repair",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- HEALING TAB
--==================================================
local HealSection = HealingTab:AddSection({
    Name = "Anti-Fail Healing",
    TextSize = 17,
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
        ActiveFeatures.HealAntiFail = Value
        Notify(Value and "✅ Anti-Fail Healing Enabled" or "❌ Anti-Fail Healing Disabled")
    end
})

HealSection:AddParagraph({
    Title = "Info",
    Desc = "✅ Auto-pass healing skill checks\n✅ Never fail healing",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- VISUAL TAB (LENGKAP)
--==================================================
local VisualSection = VisualTab:AddSection({
    Name = "Visual Enhancements",
    TextSize = 17,
    Glass = true,
    Outline = true
})

VisualSection:AddToggle({
    Name = "Fullbright",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Fullbright",
    Save = true,
    Callback = function(Value)
        Config.Visual.FullbrightEnabled = Value
        ActiveFeatures.Fullbright = Value
        Notify(Value and "✅ Fullbright Enabled" or "❌ Fullbright Disabled")
    end
})

VisualSection:AddToggle({
    Name = "No Fog",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "NoFog",
    Save = true,
    Callback = function(Value)
        Config.Visual.NoFogEnabled = Value
        ActiveFeatures.NoFog = Value
        Notify(Value and "✅ No Fog Enabled" or "❌ No Fog Disabled")
    end
})

VisualSection:AddToggle({
    Name = "Wallhack",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Wallhack",
    Save = true,
    Callback = function(Value)
        Config.Visual.WallhackEnabled = Value
        ActiveFeatures.Wallhack = Value
        updateWallhack()
        Notify(Value and "✅ Wallhack Enabled" or "❌ Wallhack Disabled")
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
        ActiveFeatures.InfiniteZoom = Value
        Notify(Value and "✅ Infinite Zoom Enabled" or "❌ Infinite Zoom Disabled")
    end
})

VisualSection:AddSection({
    Name = "Hide Skill Check UI",
    TextSize = 17,
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
        ActiveFeatures.HideSkillCheck = Value
        Notify(Value and "✅ Skill Check UI Hidden" or "❌ Skill Check UI Visible")
    end
})

VisualSection:AddParagraph({
    Title = "Info",
    Desc = "✅ Hides SkillCheckPromptGui\n✅ Clean screen while repairing",
    Image = "eye-off",
    ImageSize = 38
})

--==================================================
-- MOVEMENT TAB (LENGKAP)
--==================================================
local MoveSection = MovementTab:AddSection({
    Name = "⚡ SPEED HACK (16-200) ⚡",
    TextSize = 17,
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
        ActiveFeatures.Speed = Value
        Notify(Value and "✅ Speed Hack Enabled" or "❌ Speed Hack Disabled")
    end
})

MoveSection:AddSlider({
    Name = "Speed Value",
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

MoveSection:AddSection({
    Name = "⚡ JUMP HACK (50-300) ⚡",
    TextSize = 17,
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
        ActiveFeatures.Jump = Value
        Notify(Value and "✅ Jump Hack Enabled" or "❌ Jump Hack Disabled")
    end
})

MoveSection:AddSlider({
    Name = "Jump Power",
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

MoveSection:AddSection({
    Name = "🚀 EXTRA MOVEMENT 🚀",
    TextSize = 17,
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
        ActiveFeatures.InfiniteJump = Value
        Notify(Value and "✅ Infinite Jump Enabled" or "❌ Infinite Jump Disabled")
    end
})

MoveSection:AddToggle({
    Name = "Noclip (Walk Through Walls)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Movement.Noclip = Value
        ActiveFeatures.Noclip = Value
        
        if Value then
            enableNoclip()
            Notify("✅ Noclip Enabled")
        else
            disableNoclip()
            Notify("❌ Noclip Disabled")
        end
    end
})

MoveSection:AddParagraph({
    Title = "Movement Features",
    Desc = "✅ Speed Hack (16-200) - Returns to normal when disabled\n" ..
           "✅ Jump Hack (50-300) - Returns to normal when disabled\n" ..
           "✅ Infinite Jump - Jump unlimited times in air\n" ..
           "✅ Noclip - Walk through walls with stable implementation",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- TELEPORT TAB (LENGKAP)
--==================================================
local TeleportSection = TeleportTab:AddSection({
    Name = "📍 TELEPORT TO PLAYER 📍",
    TextSize = 17,
    Glass = true,
    Outline = true
})

local playerDropdown = nil
local function refreshPlayerDropdown()
    local players = getPlayerList()
    if #players == 0 then
        table.insert(players, "No players")
    end
    
    if playerDropdown then
        playerDropdown:Refresh(players, true)
    end
end

playerDropdown = TeleportSection:AddDropdown({
    Name = "Select Player",
    Default = getPlayerList()[1] or "No players",
    Options = getPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Flag = "TeleportDropdown",
    Save = true,
    Callback = function(Value) end
})

TeleportSection:AddButton({
    Name = "🚀 TELEPORT TO SELECTED PLAYER",
    Icon = "send",
    Outline = true,
    Callback = function()
        local selectedPlayer = playerDropdown.CurrentOption
        if selectedPlayer and selectedPlayer ~= "No players" then
            local target = Players:FindFirstChild(selectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                Notify("🚀 Teleported to " .. selectedPlayer)
            else
                Notify("❌ Player not found or invalid")
            end
        else
            Notify("❌ No player selected")
        end
    end
})

TeleportSection:AddButton({
    Name = "🔄 Refresh Player List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        refreshPlayerDropdown()
        Notify("✅ Player list refreshed")
    end
})

TeleportSection:AddSection({
    Name = "📍 WAYPOINTS 📍",
    TextSize = 17,
    Glass = true,
    Outline = true
})

TeleportSection:AddButton({
    Name = "💾 Save Current Position",
    Icon = "save",
    Outline = true,
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Config.Teleport.SavedPosition = SavedPosition
            Notify("✅ Position saved!")
        else
            Notify("❌ Cannot save position")
        end
    end
})

TeleportSection:AddButton({
    Name = "📤 Load Saved Position",
    Icon = "upload",
    Outline = true,
    Callback = function()
        if SavedPosition then
            Player.Character.HumanoidRootPart.CFrame = SavedPosition
            Notify("✅ Teleported to saved position")
        else
            Notify("❌ No saved position found")
        end
    end
})

--==================================================
-- MISC TAB (DENGAN ANTI AFK)
--==================================================
local MiscSection = MiscTab:AddSection({
    Name = "🛡️ ANTI AFK 🛡️",
    TextSize = 17,
    Glass = true,
    Outline = true
})

MiscSection:AddToggle({
    Name = "Enable Anti AFK",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.Misc.AntiAFK = Value
        ActiveFeatures.AntiAFK = Value
        
        if Value then
            enableAntiAFK()
            Notify("✅ Anti AFK Enabled")
        else
            disableAntiAFK()
            Notify("❌ Anti AFK Disabled")
        end
    end
})

MiscSection:AddParagraph({
    Title = "Info",
    Desc = "✅ Prevents auto-kick from server\n✅ Simulates player activity",
    Image = "info",
    ImageSize = 38
})

MiscSection:AddSection({
    Name = "📊 ACTIVE FEATURES 📊",
    TextSize = 17,
    Glass = true,
    Outline = true
})

-- Live updating active features
local activeFeaturesList = MiscSection:AddParagraph({
    Title = "Currently Active:",
    Desc = "Loading...",
    Image = "activity",
    ImageSize = 38
})

task.spawn(function()
    while true do
        local activeList = ""
        local count = 0
        
        if ActiveFeatures.ESP then activeList = activeList .. "✅ Player ESP\n"; count = count + 1 end
        if ActiveFeatures.Highlight then activeList = activeList .. "✅ Highlight\n"; count = count + 1 end
        if ActiveFeatures.GenESP then activeList = activeList .. "✅ Generator ESP\n"; count = count + 1 end
        if ActiveFeatures.GenAntiFail then activeList = activeList .. "✅ Anti-Fail Generator\n"; count = count + 1 end
        if ActiveFeatures.HealAntiFail then activeList = activeList .. "✅ Anti-Fail Healing\n"; count = count + 1 end
        if ActiveFeatures.HideSkillCheck then activeList = activeList .. "✅ Hide Skill Check\n"; count = count + 1 end
        if ActiveFeatures.Fullbright then activeList = activeList .. "✅ Fullbright\n"; count = count + 1 end
        if ActiveFeatures.NoFog then activeList = activeList .. "✅ No Fog\n"; count = count + 1 end
        if ActiveFeatures.Wallhack then activeList = activeList .. "✅ Wallhack\n"; count = count + 1 end
        if ActiveFeatures.InfiniteZoom then activeList = activeList .. "✅ Infinite Zoom\n"; count = count + 1 end
        if ActiveFeatures.Speed then activeList = activeList .. "✅ Speed Hack\n"; count = count + 1 end
        if ActiveFeatures.Jump then activeList = activeList .. "✅ Jump Hack\n"; count = count + 1 end
        if ActiveFeatures.InfiniteJump then activeList = activeList .. "✅ Infinite Jump\n"; count = count + 1 end
        if ActiveFeatures.Noclip then activeList = activeList .. "✅ Noclip\n"; count = count + 1 end
        if ActiveFeatures.AntiAFK then activeList = activeList .. "✅ Anti AFK\n"; count = count + 1 end
        
        if count == 0 then
            activeList = "No features active"
        else
            activeList = "Total: " .. count .. " features\n\n" .. activeList
        end
        
        activeFeaturesList:SetDesc(activeList)
        task.wait(1)
    end
end)

MiscSection:AddSection({
    Name = "⚙️ SCRIPT INFO ⚙️",
    TextSize = 17,
    Glass = true,
    Outline = true
})

MiscSection:AddParagraph({
    Title = "Violence District",
    Desc = "Version: 3.0 ULTIMATE\n" ..
           "UI: Catraz Hub Library\n" ..
           "Press F4 to toggle menu",
    Image = "info",
    ImageSize = 38
})

MiscSection:AddButton({
    Name = "❌ Destroy Script",
    Icon = "x",
    Outline = true,
    Callback = function()
        -- Cleanup
        for player, _ in pairs(ESPObjects) do
            removePlayerESP(player)
        end
        for player, _ in pairs(Highlights) do
            removeHighlight(player)
        end
        for gen, folder in pairs(GeneratorESP) do
            if folder then folder:Destroy() end
        end
        
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
        end
        
        if wallhackConnection then
            wallhackConnection:Disconnect()
        end
        
        Notify("Script Destroyed")
        task.wait(1)
        OrionLib:Destroy()
        _G.VD_Loaded = false
    end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

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
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 VIOLENCE DISTRICT - ULTIMATE Edition v3.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Player ESP - Large White Text")
print("✅ Movement Hacks - Speed, Jump, Infinite Jump, Noclip")
print("✅ Visual - Wallhack, Fullbright, No Fog, Infinite Zoom")
print("✅ Teleport - To Player, Save/Load Position")
print("✅ Misc - Anti AFK, Active Features Counter")
print("✅ Highlight - Team Colors")
print("✅ Generator ESP - With Progress %")
print("✅ Anti-Fail Systems - Generator & Healing")
print("═══════════════════════════════════════════════════════")