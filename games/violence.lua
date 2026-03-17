-- ==================== VIOLENCE DISTRICT - ULTIMATE COMPLETE EDITION ====================
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
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")
local Network = Stats.Network

--==================================================
-- COLORS
--==================================================
local TeamColor = Color3.fromRGB(0, 255, 0)      -- Hijau untuk teammate
local EnemyColor = Color3.fromRGB(255, 0, 0)      -- Merah untuk enemy

--==================================================
-- CONFIG
--==================================================
local Config = {
    -- Player Info
    PlayerInfo = {},
    
    -- Server Info
    ServerInfo = {},
    
    -- ESP Settings
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Tracers = false,
        TeamCheck = true,
        ShowTeammates = false,
        MaxDistance = 2000,
        NameSize = 22,
        NameOutline = true
    },
    
    -- Highlight Settings
    Highlight = {
        Enabled = false,
        TeamCheck = true,
        ShowTeam = false
    },
    
    -- Generator Settings
    Generator = {
        ESPEnabled = false,
        AntiFailEnabled = false
    },
    
    -- Healing Settings
    Healing = {
        AntiFailEnabled = false
    },
    
    -- UI Settings
    UI = {
        HideSkillCheck = false
    },
    
    -- Visual Settings
    Visual = {
        Wallhack = false,
        Fullbright = false,
        NoFog = false,
        SuperZoom = false,
        ZoomDistance = 70,
        AntiAliasing = false,
        GraphicsQuality = 1,
        Performance = false
    },
    
    -- Movement Settings
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 50,
        JumpEnabled = false,
        JumpValue = 100,
        InfiniteJump = false,
        Noclip = false,
        OriginalSpeed = 16,
        OriginalJump = 50
    },
    
    -- Teleport Settings
    Teleport = {
        SavedPosition = nil,
        LastTarget = nil
    },
    
    -- Misc Settings
    Misc = {
        AntiAFK = false,
        ActiveFeatures = {}
    }
}

--==================================================
-- ORIGINAL VISUAL SETTINGS
--==================================================
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top
}

local originalCamera = {
    FieldOfView = Camera.FieldOfView
}

local originalQuality = {
    AntiAliasing = UserInputService.Antialiasing,
    GraphicsQuality = UserInputService.GetGraphicsQuality and UserInputService:GetGraphicsQuality() or 1
}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Violence District",
        Content = msg,
        Image = "info",
        Time = duration or 2.5
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

Notify("Violence District COMPLETE Edition Loaded!", 3)

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
-- ACTIVE FEATURES TRACKER
--==================================================
local ActiveFeaturesLabel = nil
local ActiveFeaturesParagraph = nil

local function updateActiveFeatures()
    local activeList = {}
    
    if Config.ESP.Enabled then table.insert(activeList, "ESP") end
    if Config.Highlight.Enabled then table.insert(activeList, "Highlight") end
    if Config.Generator.ESPEnabled then table.insert(activeList, "Gen ESP") end
    if Config.Generator.AntiFailEnabled then table.insert(activeList, "Anti-Fail Gen") end
    if Config.Healing.AntiFailEnabled then table.insert(activeList, "Anti-Fail Heal") end
    if Config.Movement.SpeedEnabled then table.insert(activeList, "Speed") end
    if Config.Movement.JumpEnabled then table.insert(activeList, "Jump") end
    if Config.Movement.InfiniteJump then table.insert(activeList, "Inf Jump") end
    if Config.Movement.Noclip then table.insert(activeList, "Noclip") end
    if Config.Visual.Wallhack then table.insert(activeList, "Wallhack") end
    if Config.Visual.Fullbright then table.insert(activeList, "Fullbright") end
    if Config.Visual.NoFog then table.insert(activeList, "No Fog") end
    if Config.Visual.SuperZoom then table.insert(activeList, "Super Zoom") end
    if Config.Visual.AntiAliasing then table.insert(activeList, "AA") end
    if Config.Visual.Performance then table.insert(activeList, "Perf Mode") end
    if Config.UI.HideSkillCheck then table.insert(activeList, "Hide UI") end
    if Config.Misc.AntiAFK then table.insert(activeList, "Anti AFK") end
    
    local activeCount = #activeList
    local activeText = activeCount > 0 and table.concat(activeList, ", ") or "None"
    
    if ActiveFeaturesParagraph then
        -- Update paragraph
        ActiveFeaturesParagraph:SetDesc(activeCount .. " Active: " .. activeText)
    end
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
-- PLAYER ESP SYSTEM (FONT BESAR DAN TEBAL)
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
    
    -- Name settings (BESAR DAN TEBAL)
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = Config.ESP.NameSize  -- Size 22
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 3  -- Font bold
    
    -- Distance settings
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 15
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
    
    -- Tracer
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
        
        -- Box
        if Config.ESP.Boxes then
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            esp.Box.Color = playerColor
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        -- Name (BESAR)
        if Config.ESP.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 45)  -- Naikkan posisi karena font besar
            esp.Name.Color = playerColor
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- Distance
        if Config.ESP.Distance then
            esp.Distance.Text = string.format("[%.0fm]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxSize.Y / 2 + 20)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        -- Health Bar
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
        
        -- Tracer
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

-- Initialize ESP
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
function UpdateWallhack()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if Config.Visual.Wallhack then
                if v.Transparency < 0.5 then
                    v.Material = Enum.Material.ForceField
                    v.Transparency = 0.5
                end
            else
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
            end
        end
    end
end

--==================================================
-- VISUAL FUNCTIONS
--==================================================
local function applyFullbright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
    Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
    
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
        
        if v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
        end
    end
end

local function resetFullbright()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Ambient = originalLighting.Ambient
    Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
    Lighting.ColorShift_Top = originalLighting.ColorShift_Top
end

local function applyNoFog()
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
end

local function resetNoFog()
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart or 0
end

local function applySuperZoom()
    Camera.FieldOfView = Config.Visual.ZoomDistance
end

local function resetSuperZoom()
    Camera.FieldOfView = originalCamera.FieldOfView
end

local function applyAntiAliasing()
    UserInputService.Antialiasing = Config.Visual.AntiAliasing and 2 or originalQuality.AntiAliasing
end

local function applyGraphicsQuality()
    if Config.Visual.Performance then
        -- Optimasi performa
        settings().Rendering.QualityLevel = 1
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    else
        settings().Rendering.QualityLevel = Config.Visual.GraphicsQuality
    end
end

local function resetAllVisual()
    Config.Visual.Wallhack = false
    Config.Visual.Fullbright = false
    Config.Visual.NoFog = false
    Config.Visual.SuperZoom = false
    Config.Visual.AntiAliasing = false
    Config.Visual.Performance = false
    
    UpdateWallhack()
    resetFullbright()
    resetNoFog()
    resetSuperZoom()
    
    UserInputService.Antialiasing = originalQuality.AntiAliasing
    settings().Rendering.QualityLevel = 1
    
    Notify("All visual settings reset to normal", 2)
end

--==================================================
-- MOVEMENT FUNCTIONS
--==================================================
local noclipConnection = nil
local infiniteJumpConnection = nil

local function updateMovement()
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    -- Speed
    if Config.Movement.SpeedEnabled then
        hum.WalkSpeed = Config.Movement.SpeedValue
    else
        hum.WalkSpeed = 16
    end
    
    -- Jump
    if Config.Movement.JumpEnabled then
        hum.JumpPower = Config.Movement.JumpValue
    else
        hum.JumpPower = 50
    end
end

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
-- UTILITY FUNCTIONS
--==================================================
local function getUptime()
    local days = math.floor(Workspace.DistributedGameTime / 86400)
    local hours = math.floor((Workspace.DistributedGameTime % 86400) / 3600)
    local minutes = math.floor((Workspace.DistributedGameTime % 3600) / 60)
    local seconds = math.floor(Workspace.DistributedGameTime % 60)
    
    if days > 0 then
        return string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
    elseif hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, seconds)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, seconds)
    else
        return string.format("%ds", seconds)
    end
end

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
-- MAIN TAB
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "Player Information",
    TextSize = 17,
    Glass = true,
    Outline = true
})

-- Player Info Paragraph (akan diupdate setiap 5 detik)
local PlayerInfoPara = PlayerInfoSection:AddParagraph({
    Title = Player.Name,
    Desc = string.format(
        "Display Name: %s\nUser ID: %d\nAccount Age: %d days\nTeam: %s",
        Player.DisplayName,
        Player.UserId,
        Player.AccountAge,
        Player.Team and Player.Team.Name or "No Team"
    ),
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                PlayerInfoPara:SetDesc(string.format(
                    "Display Name: %s\nUser ID: %d\nAccount Age: %d days\nTeam: %s",
                    Player.DisplayName,
                    Player.UserId,
                    Player.AccountAge,
                    Player.Team and Player.Team.Name or "No Team"
                ))
                Notify("Player info refreshed", 1)
            end
        }
    }
})

local ServerInfoSection = MainTab:AddSection({
    Name = "Server Information",
    TextSize = 17,
    Glass = true,
    Outline = true
})

local ServerInfoPara = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = string.format(
        "Players: %d/%d\nPing: %d ms\nUptime: %s",
        #Players:GetPlayers(),
        Players.MaxPlayers,
        math.floor(Network.ServerStatsItem["Data Ping"]:GetValue() * 1000),
        getUptime()
    ),
    Image = "server",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                ServerInfoPara:SetDesc(string.format(
                    "Players: %d/%d\nPing: %d ms\nUptime: %s",
                    #Players:GetPlayers(),
                    Players.MaxPlayers,
                    math.floor(Network.ServerStatsItem["Data Ping"]:GetValue() * 1000),
                    getUptime()
                ))
            end
        }
    }
})

-- Auto refresh server info setiap 5 detik
task.spawn(function()
    while true do
        task.wait(5)
        if ServerInfoPara then
            ServerInfoPara:SetDesc(string.format(
                "Players: %d/%d\nPing: %d ms\nUptime: %s",
                #Players:GetPlayers(),
                Players.MaxPlayers,
                math.floor(Network.ServerStatsItem["Data Ping"]:GetValue() * 1000),
                getUptime()
            ))
        end
    end
end)

--==================================================
-- ESP TAB
--==================================================
local ESPSection = ESPTab:AddSection({
    Name = "Player ESP Settings",
    TextSize = 17,
    Glass = true,
    Outline = true
})

ESPSection:AddToggle({
    Name = "Enable ESP",
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
        updateActiveFeatures()
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
        updateActiveFeatures()
    end
})

SpeedSection:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 200,
    Default = 50,
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
    Name = "Jump Hack",
    TextSize = 17,
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
        updateActiveFeatures()
    end
})

JumpSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 100,
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
    Name = "Extra Movement",
    TextSize = 17,
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
        updateActiveFeatures()
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
            Notify("Noclip Disabled - Normal collision restored")
        end
        updateActiveFeatures()
    end
})

--==================================================
-- VISUAL TAB
--==================================================
local VisualSection = VisualTab:AddSection({
    Name = "Visual Features",
    TextSize = 17,
    Glass = true,
    Outline = true
})

VisualSection:AddToggle({
    Name = "Wallhack (See through walls)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Wallhack",
    Save = true,
    Callback = function(Value)
        Config.Visual.Wallhack = Value
        UpdateWallhack()
        updateActiveFeatures()
    end
})

VisualSection:AddToggle({
    Name = "Fullbright",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Fullbright",
    Save = true,
    Callback = function(Value)
        Config.Visual.Fullbright = Value
        if Value then 
            applyFullbright()
        else 
            resetFullbright()
        end
        updateActiveFeatures()
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
        Config.Visual.NoFog = Value
        if Value then 
            applyNoFog()
        else 
            resetNoFog()
        end
        updateActiveFeatures()
    end
})

VisualSection:AddToggle({
    Name = "Super Zoom Out",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SuperZoom",
    Save = true,
    Callback = function(Value)
        Config.Visual.SuperZoom = Value
        if Value then 
            applySuperZoom()
        else 
            resetSuperZoom()
        end
        updateActiveFeatures()
    end
})

VisualSection:AddSlider({
    Name = "Zoom Distance",
    Min = 30,
    Max = 120,
    Default = 70,
    Increment = 1,
    ValueName = "FOV",
    Outline = true,
    Callback = function(Value)
        Config.Visual.ZoomDistance = Value
        if Config.Visual.SuperZoom then
            applySuperZoom()
        end
    end
})

VisualSection:AddToggle({
    Name = "Anti-Aliasing",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAlias",
    Save = true,
    Callback = function(Value)
        Config.Visual.AntiAliasing = Value
        applyAntiAliasing()
        updateActiveFeatures()
    end
})

VisualSection:AddToggle({
    Name = "Performance Mode (Low Graphics)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Performance",
    Save = true,
    Callback = function(Value)
        Config.Visual.Performance = Value
        applyGraphicsQuality()
        updateActiveFeatures()
    end
})

VisualSection:AddButton({
    Name = "Reset All Visual Settings",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        resetAllVisual()
        updateActiveFeatures()
    end
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportSection = TeleportTab:AddSection({
    Name = "Teleport to Player",
    TextSize = 17,
    Glass = true,
    Outline = true
})

-- Dropdown untuk pilih player
local PlayerDropdown = TeleportSection:AddDropdown({
    Name = "Select Player",
    Default = getPlayerList()[1] or "None",
    Options = getPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Callback = function(Value)
        Config.Teleport.LastTarget = Value
    end
})

TeleportSection:AddButton({
    Name = "Teleport to Selected Player",
    Icon = "send",
    Outline = true,
    Callback = function()
        local target = Players:FindFirstChild(Config.Teleport.LastTarget or getPlayerList()[1])
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                Notify("Teleported to " .. target.Name, 2)
            end
        else
            Notify("Target player not found or invalid", 3)
        end
    end
})

TeleportSection:AddButton({
    Name = "Refresh Player List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        PlayerDropdown:Refresh(getPlayerList(), true)
        Notify("Player list refreshed", 1)
    end
})

local WaypointSection = TeleportTab:AddSection({
    Name = "Waypoints",
    TextSize = 17,
    Glass = true,
    Outline = true
})

WaypointSection:AddButton({
    Name = "Save Current Position",
    Icon = "save",
    Outline = true,
    Callback = function()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            Config.Teleport.SavedPosition = char.HumanoidRootPart.CFrame
            Notify("Position saved!", 2)
        end
    end
})

WaypointSection:AddButton({
    Name = "Load Saved Position",
    Icon = "upload",
    Outline = true,
    Callback = function()
        if Config.Teleport.SavedPosition then
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = Config.Teleport.SavedPosition
                Notify("Teleported to saved position", 2)
            end
        else
            Notify("No saved position found!", 3)
        end
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({
    Name = "Utility Features",
    TextSize = 17,
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
        updateActiveFeatures()
    end
})

MiscSection:AddToggle({
    Name = "Hide Skill Check UI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HideSkillCheck",
    Save = true,
    Callback = function(Value)
        Config.UI.HideSkillCheck = Value
        Notify(Value and "Skill Check UI Hidden" or "Skill Check UI Visible")
        updateActiveFeatures()
    end
})

-- Highlight System
local HighlightSection = MiscTab:AddSection({
    Name = "Highlight System",
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
            
            Notify("Highlight Enabled")
        else
            for player, _ in pairs(Highlights) do
                removeHighlight(player)
            end
        end
        updateActiveFeatures()
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

-- Generator ESP
local GenSection = MiscTab:AddSection({
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
        
        if Value then
            Notify("Generator ESP Enabled")
        else
            for gen, folder in pairs(GeneratorESP) do
                if folder then folder:Destroy() end
            end
            GeneratorESP = {}
        end
        updateActiveFeatures()
    end
})

-- Anti-Fail Generator
GenSection:AddToggle({
    Name = "Anti-Fail Generator",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "GenAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Generator.AntiFailEnabled = Value
        Notify(Value and "Anti-Fail Generator Enabled" or "Anti-Fail Generator Disabled")
        updateActiveFeatures()
    end
})

-- Anti-Fail Healing
local HealSection = MiscTab:AddSection({
    Name = "Healing",
    TextSize = 17,
    Glass = true,
    Outline = true
})

HealSection:AddToggle({
    Name = "Anti-Fail Healing",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HealAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Healing.AntiFailEnabled = Value
        Notify(Value and "Anti-Fail Healing Enabled" or "Anti-Fail Healing Disabled")
        updateActiveFeatures()
    end
})

-- Active Features Counter
local ActiveSection = MiscTab:AddSection({
    Name = "Active Features",
    TextSize = 17,
    Glass = true,
    Outline = true
})

ActiveFeaturesParagraph = ActiveSection:AddParagraph({
    Title = "Currently Active",
    Desc = "0 Active: None",
    Image = "activity",
    ImageSize = 38
})

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
    -- Update ESP
    updatePlayerESP()
    
    -- Update Highlight
    if Config.Highlight.Enabled then
        updateHighlights()
    end
    
    -- Update Movement
    updateMovement()
    
    -- Update Wallhack jika diperlukan
    if Config.Visual.Wallhack then
        -- Wallhack update bisa ditambahkan di sini jika perlu
    end
end)

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
    
    -- Re-apply speed/jump if enabled
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

-- Initial active features update
updateActiveFeatures()

Notify("Press F4 or click floating button to toggle menu", 3)
print("═══════════════════════════════════════════════════════")
print("🔥 VIOLENCE DISTRICT - COMPLETE Edition 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Main Tab - Player & Server Info (Live Updates)")
print("✅ Player ESP - Font Besar (Size 22 Bold)")
print("✅ ESP Features - Box, Names, Distance, Health, Tracers")
print("✅ Team Colors - Hijau (Teammate), Merah (Enemy)")
print("✅ Movement - Speed, Jump, Infinite Jump, Noclip")
print("✅ Visual - Wallhack, Fullbright, No Fog, Super Zoom")
print("✅ Visual - Anti-Aliasing, Performance Mode")
print("✅ Teleport - Player Dropdown + Waypoints")
print("✅ Misc - Anti AFK, Hide Skill Check UI")
print("✅ Active Features Counter (Live Update)")
print("✅ Highlight System, Generator ESP, Anti-Fail")
print("═══════════════════════════════════════════════════════")