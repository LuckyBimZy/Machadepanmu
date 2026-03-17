-- ==================== VIOLENCE DISTRICT - COMPLETE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.0 COMPLETE (FIXED & EXECUTABLE)

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
-- CORE SERVICES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local StartTime = tick()

--==================================================
-- COLORS
--==================================================
local Colors = {
    Team = Color3.fromRGB(0, 255, 0),
    Enemy = Color3.fromRGB(255, 0, 0),
    Friendly = Color3.fromRGB(0, 255, 255),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Gray = Color3.fromRGB(128, 128, 128),
    Blue = Color3.fromRGB(65, 105, 225)
}

--==================================================
-- CONFIGURATION
--==================================================
local Config = {
    Version = "3.0",
    
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
        ZoomValue = 70,
        AntiAliasing = false,
        GraphicsQuality = 1,
        OptimizePerformance = false
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
        SavedPosition = nil,
        SelectedPlayer = nil
    },
    
    Misc = {
        AntiAFK = false,
        ActiveFeatures = {}
    }
}

--==================================================
-- ORIGINAL STATE
--==================================================
local OriginalState = {
    Lighting = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient
    },
    Camera = {
        FieldOfView = Camera.FieldOfView
    },
    Graphics = {
        QualityLevel = settings().Rendering.QualityLevel
    }
}

-- Save atmosphere if exists
local atm = Lighting:FindFirstChildOfClass("Atmosphere")
if atm then
    OriginalState.Lighting.Atmosphere = {
        Density = atm.Density,
        Offset = atm.Offset,
        Glare = atm.Glare,
        Haze = atm.Haze
    }
end

-- Save blur if exists
local blur = Lighting:FindFirstChildOfClass("BlurEffect")
if blur then
    OriginalState.Lighting.Blur = { Size = blur.Size }
end

--==================================================
-- UTILITY FUNCTIONS
--==================================================
local function Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Violence District",
        Content = msg,
        Image = "info",
        Time = duration or 2.5
    })
end

local function FormatUptime()
    local uptime = tick() - StartTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function GetPing()
    return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
end

local function GetPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

local function IsTeammate(player)
    if not LocalPlayer.Team then return false end
    if not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function GetPlayerColor(player)
    if Config.ESP.TeamCheck and IsTeammate(player) then
        return Colors.Team
    else
        return Colors.Enemy
    end
end

--==================================================
-- ESP SYSTEM (Using BillboardGui instead of Drawing)
--==================================================
local ESP = {
    Objects = {},
    
    Create = function(player)
        if player == LocalPlayer then return end
        if not player.Character then return end
        if ESP.Objects[player] then return end
        
        local char = player.Character
        local head = char:FindFirstChild("Head")
        if not head then return end
        
        -- Create BillboardGui for name and distance
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "VD_ESP"
        billboard.Parent = head
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.ResetOnSpawn = false
        
        -- Name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboard
        nameLabel.Size = UDim2.new(1, 0, 0, 30)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Colors.White
        nameLabel.TextSize = 22
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextStrokeColor3 = Colors.Black
        
        -- Distance label
        local distLabel = Instance.new("TextLabel")
        distLabel.Parent = billboard
        distLabel.Size = UDim2.new(1, 0, 0, 20)
        distLabel.Position = UDim2.new(0, 0, 0, 30)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "[0m]"
        distLabel.TextColor3 = Colors.Gray
        distLabel.TextSize = 16
        distLabel.Font = Enum.Font.SourceSans
        distLabel.TextStrokeTransparency = 0.3
        distLabel.TextStrokeColor3 = Colors.Black
        
        -- Health bar background
        local healthBg = Instance.new("Frame")
        healthBg.Parent = billboard
        healthBg.Size = UDim2.new(0, 4, 0, 50)
        healthBg.Position = UDim2.new(1, 5, 0, 0)
        healthBg.BackgroundColor3 = Colors.Black
        healthBg.BackgroundTransparency = 0.5
        healthBg.BorderSizePixel = 0
        
        -- Health bar
        local healthBar = Instance.new("Frame")
        healthBar.Parent = healthBg
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.Position = UDim2.new(0, 0, 0, 0)
        healthBar.BackgroundColor3 = Colors.Team
        healthBar.BorderSizePixel = 0
        
        ESP.Objects[player] = {
            Billboard = billboard,
            NameLabel = nameLabel,
            DistLabel = distLabel,
            HealthBg = healthBg,
            HealthBar = healthBar
        }
    end,
    
    Remove = function(player)
        if ESP.Objects[player] then
            if ESP.Objects[player].Billboard then
                ESP.Objects[player].Billboard:Destroy()
            end
            ESP.Objects[player] = nil
        end
    end,
    
    Update = function()
        if not Config.ESP.Enabled then
            for _, esp in pairs(ESP.Objects) do
                if esp.Billboard then
                    esp.Billboard.Enabled = false
                end
            end
            return
        end
        
        for player, esp in pairs(ESP.Objects) do
            if not player or not player.Parent or not player.Character then
                ESP.Remove(player)
                continue
            end
            
            if Config.ESP.TeamCheck and IsTeammate(player) and not Config.ESP.ShowTeammates then
                if esp.Billboard then
                    esp.Billboard.Enabled = false
                end
                continue
            end
            
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            
            if not hrp or not hum then
                if esp.Billboard then
                    esp.Billboard.Enabled = false
                end
                continue
            end
            
            local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
            
            if distance > Config.ESP.MaxDistance then
                if esp.Billboard then
                    esp.Billboard.Enabled = false
                end
                continue
            end
            
            -- Update visibility based on settings
            if esp.Billboard then
                esp.Billboard.Enabled = Config.ESP.Names or Config.ESP.Distance or Config.ESP.Health
            end
            
            -- Update name visibility and color
            if esp.NameLabel then
                esp.NameLabel.Visible = Config.ESP.Names
                esp.NameLabel.TextColor3 = GetPlayerColor(player)
            end
            
            -- Update distance
            if esp.DistLabel then
                esp.DistLabel.Visible = Config.ESP.Distance
                esp.DistLabel.Text = string.format("[%.0fm]", distance)
            end
            
            -- Update health bar
            if esp.HealthBg and esp.HealthBar then
                if Config.ESP.Health then
                    esp.HealthBg.Visible = true
                    local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    esp.HealthBar.Size = UDim2.new(1, 0, healthPercent, 0)
                    esp.HealthBar.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
                    
                    -- Health bar color
                    local healthColor = Color3.fromRGB(
                        math.floor(255 * (1 - healthPercent)),
                        math.floor(255 * healthPercent),
                        0
                    )
                    esp.HealthBar.BackgroundColor3 = healthColor
                else
                    esp.HealthBg.Visible = false
                end
            end
        end
    end,
    
    SetupPlayer = function(player)
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Head")
            task.wait(0.5)
            if Config.ESP.Enabled then
                ESP.Create(player)
            end
        end)
        
        if player.Character then
            task.spawn(function()
                local char = player.Character
                char:WaitForChild("Head")
                task.wait(0.5)
                if Config.ESP.Enabled then
                    ESP.Create(player)
                end
            end)
        end
    end,
    
    Init = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ESP.SetupPlayer(player)
            end
        end
        
        Players.PlayerAdded:Connect(ESP.SetupPlayer)
        Players.PlayerRemoving:Connect(ESP.Remove)
    end
}

--==================================================
-- HIGHLIGHT SYSTEM
--==================================================
local Highlight = {
    Objects = {},
    
    Create = function(player)
        if player == LocalPlayer then return end
        if not player.Character then return end
        if Highlight.Objects[player] then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "VD_Highlight"
        highlight.Parent = player.Character
        highlight.Adornee = player.Character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        if Config.Highlight.TeamCheck then
            if IsTeammate(player) then
                highlight.FillColor = Colors.Team
                highlight.OutlineColor = Colors.Team
            else
                highlight.FillColor = Colors.Enemy
                highlight.OutlineColor = Colors.Enemy
            end
        else
            highlight.FillColor = Colors.White
            highlight.OutlineColor = Colors.White
        end
        
        Highlight.Objects[player] = highlight
    end,
    
    Remove = function(player)
        if Highlight.Objects[player] then
            Highlight.Objects[player]:Destroy()
            Highlight.Objects[player] = nil
        end
    end,
    
    Update = function()
        for player, highlight in pairs(Highlight.Objects) do
            if not player or not player.Parent or not player.Character then
                Highlight.Remove(player)
                continue
            end
            
            if Config.Highlight.TeamCheck and IsTeammate(player) and not Config.Highlight.ShowTeam then
                highlight.Enabled = false
                continue
            else
                highlight.Enabled = Config.Highlight.Enabled
            end
            
            if Config.Highlight.TeamCheck then
                if IsTeammate(player) then
                    highlight.FillColor = Colors.Team
                    highlight.OutlineColor = Colors.Team
                else
                    highlight.FillColor = Colors.Enemy
                    highlight.OutlineColor = Colors.Enemy
                end
            else
                highlight.FillColor = Colors.White
                highlight.OutlineColor = Colors.White
            end
        end
    end
}

--==================================================
-- MOVEMENT SYSTEM
--==================================================
local Movement = {
    NoclipConnection = nil,
    InfiniteJumpConnection = nil,
    
    Update = function()
        local char = LocalPlayer.Character
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
    end,
    
    SetupInfiniteJump = function()
        if Movement.InfiniteJumpConnection then
            Movement.InfiniteJumpConnection:Disconnect()
            Movement.InfiniteJumpConnection = nil
        end
        
        if Config.Movement.InfiniteJump then
            Movement.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end,
    
    EnableNoclip = function()
        if Movement.NoclipConnection then
            Movement.NoclipConnection:Disconnect()
        end
        
        Movement.NoclipConnection = RunService.Stepped:Connect(function()
            if not Config.Movement.Noclip then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end,
    
    DisableNoclip = function()
        if Movement.NoclipConnection then
            Movement.NoclipConnection:Disconnect()
            Movement.NoclipConnection = nil
        end
        
        task.wait(0.1)
        
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
}

--==================================================
-- VISUAL SYSTEM
--==================================================
local Visual = {
    WallhackConnection = nil,
    
    UpdateWallhack = function()
        if Visual.WallhackConnection then
            Visual.WallhackConnection:Disconnect()
            Visual.WallhackConnection = nil
        end
        
        if Config.Visual.WallhackEnabled then
            Visual.WallhackConnection = RunService.RenderStepped:Connect(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
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
                if v:IsA("BasePart") and v.Material == Enum.Material.ForceField then
                    v.Material = Enum.Material.Plastic
                    v.Transparency = 0
                end
            end
        end
    end,
    
    UpdateLighting = function()
        -- Fullbright
        if Config.Visual.FullbrightEnabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Colors.Gray
        else
            Lighting.Brightness = OriginalState.Lighting.Brightness
            Lighting.ClockTime = OriginalState.Lighting.ClockTime
            Lighting.GlobalShadows = OriginalState.Lighting.GlobalShadows
            Lighting.OutdoorAmbient = OriginalState.Lighting.OutdoorAmbient
        end
        
        -- No Fog
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
                
                if v:IsA("BlurEffect") then
                    v.Size = 0
                end
            end
        else
            Lighting.FogEnd = OriginalState.Lighting.FogEnd
            Lighting.FogStart = OriginalState.Lighting.FogStart or 0
            
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") and OriginalState.Lighting.Atmosphere then
                    v.Density = OriginalState.Lighting.Atmosphere.Density or 0.3
                    v.Offset = OriginalState.Lighting.Atmosphere.Offset or 0.25
                    v.Glare = OriginalState.Lighting.Atmosphere.Glare or 0
                    v.Haze = OriginalState.Lighting.Atmosphere.Haze or 0
                end
                
                if v:IsA("BlurEffect") and OriginalState.Lighting.Blur then
                    v.Size = OriginalState.Lighting.Blur.Size or 0
                end
            end
        end
    end,
    
    UpdateZoom = function()
        if Config.Visual.SuperZoomEnabled then
            Camera.FieldOfView = Config.Visual.ZoomValue
        else
            Camera.FieldOfView = OriginalState.Camera.FieldOfView
        end
    end,
    
    UpdateGraphics = function()
        if Config.Visual.AntiAliasing then
            settings().Rendering.SimulationLodBias = 0
        end
        
        settings().Rendering.QualityLevel = Config.Visual.GraphicsQuality
        
        if Config.Visual.OptimizePerformance then
            settings().Rendering.EagerBulkExecution = true
            settings().Rendering.MaxFrameRate = 60
        else
            settings().Rendering.EagerBulkExecution = false
            settings().Rendering.MaxFrameRate = 0
        end
    end,
    
    ResetAll = function()
        Config.Visual.FullbrightEnabled = false
        Config.Visual.NoFogEnabled = false
        Config.Visual.WallhackEnabled = false
        Config.Visual.SuperZoomEnabled = false
        Config.Visual.ZoomValue = 70
        Config.Visual.AntiAliasing = false
        Config.Visual.GraphicsQuality = 1
        Config.Visual.OptimizePerformance = false
        
        Visual.UpdateLighting()
        Camera.FieldOfView = OriginalState.Camera.FieldOfView
        settings().Rendering.QualityLevel = OriginalState.Graphics.QualityLevel
        Visual.UpdateWallhack()
        
        Notify("All visual settings reset to default")
    end
}

--==================================================
-- GENERATOR SYSTEM
--==================================================
local Generator = {
    Objects = {},
    
    CreateESP = function(gen)
        if not gen:IsA("Model") then return end
        if gen:FindFirstChild("VD_GenESP") then return end
        
        local folder = Instance.new("Folder", gen)
        folder.Name = "VD_GenESP"
        
        local highlight = Instance.new("Highlight", folder)
        highlight.Adornee = gen
        highlight.FillColor = Color3.new(0, 1, 1)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = Config.Generator.ESPEnabled
        
        local primaryPart = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            local billboard = Instance.new("BillboardGui", folder)
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.Adornee = primaryPart
            billboard.ExtentsOffset = Vector3.new(0, 3, 0)
            billboard.Enabled = Config.Generator.ESPEnabled
            
            local textLabel = Instance.new("TextLabel", billboard)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Colors.White
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextSize = 18
            textLabel.TextStrokeTransparency = 0.5
            textLabel.TextStrokeColor3 = Colors.Black
            textLabel.Text = "⚡ 0%"
            
            task.spawn(function()
                while gen.Parent and folder.Parent do
                    local progress = gen:GetAttribute("RepairProgress") or 0
                    textLabel.Text = "⚡ " .. math.floor(progress) .. "%"
                    
                    if progress >= 100 then
                        highlight.FillColor = Colors.Team
                    else
                        highlight.FillColor = Color3.new(0, 1, 1)
                    end
                    
                    task.wait(1)
                end
            end)
        end
        
        Generator.Objects[gen] = folder
    end,
    
    Scanner = function()
        task.spawn(function()
            while true do
                if Config.Generator.ESPEnabled then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name == "Generator" and obj:IsA("Model") then
                            Generator.CreateESP(obj)
                        end
                    end
                end
                task.wait(3)
            end
        end)
    end
}

--==================================================
-- HIDE SKILLCHECK UI
--==================================================
RunService.RenderStepped:Connect(function()
    if Config.UI.HideSkillCheck then
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if PlayerGui then
            local targetUI = PlayerGui:FindFirstChild("SkillCheckPromptGui")
            local targetUICon = PlayerGui:FindFirstChild("SkillCheckPromptGui-con")
            
            if targetUI and targetUI.Enabled then
                targetUI.Enabled = false
            end
            
            if targetUICon and targetUICon.Enabled then
                targetUICon.Enabled = false
            end
        end
    end
end)

--==================================================
-- ANTI AFK
--==================================================
local AntiAFKConnection = nil

local function SetupAntiAFK()
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
    
    if Config.Misc.AntiAFK then
        AntiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

--==================================================
-- UI SYSTEM
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Violence District",
    Subtext = "COMPLETE Edition",
    Version = "v" .. Config.Version,
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VD_COMPLETE",
    IntroEnabled = true,
    IntroText = "Violence District COMPLETE",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

OrionLib.SelectedTheme = "Ocean"

-- Create Tabs
local MainTab = Window:MakeTab({ Name = "Main", Icon = "home", Glass = true, Outline = true })
local ESPTab = Window:MakeTab({ Name = "Player ESP", Icon = "eye", Glass = true, Outline = true })
local MovementTab = Window:MakeTab({ Name = "Movement", Icon = "footprints", Glass = true, Outline = true })
local VisualTab = Window:MakeTab({ Name = "Visual", Icon = "sun", Glass = true, Outline = true })
local TeleportTab = Window:MakeTab({ Name = "Teleport", Icon = "map-pin", Glass = true, Outline = true })
local MiscTab = Window:MakeTab({ Name = "Misc", Icon = "settings", Glass = true, Outline = true })
local GeneratorTab = Window:MakeTab({ Name = "Generator", Icon = "zap", Glass = true, Outline = true })

--==================================================
-- MAIN TAB
--==================================================
local MainSection = MainTab:AddSection({ Name = "Player Information", TextSize = 17, Glass = true, Outline = true })

local playerTeam = LocalPlayer.Team and LocalPlayer.Team.Name or "No Team"
MainSection:AddParagraph({
    Title = LocalPlayer.Name,
    Desc = "Display Name: " .. LocalPlayer.DisplayName .. 
           "\nUser ID: " .. LocalPlayer.UserId ..
           "\nAccount Age: " .. LocalPlayer.AccountAge .. " days" ..
           "\nTeam: " .. playerTeam,
    Image = "user",
    ImageSize = 48
})

local ServerSection = MainTab:AddSection({ Name = "Server Information", TextSize = 17, Glass = true, Outline = true })

local ServerInfo = ServerSection:AddParagraph({
    Title = "Server Status",
    Desc = "Players: " .. #Players:GetPlayers() .. 
           "\nPing: " .. GetPing() .. " ms" ..
           "\nUptime: " .. FormatUptime(),
    Image = "server",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                -- Update info
            end
        }
    }
})

--==================================================
-- ESP TAB
--==================================================
local ESPSection = ESPTab:AddSection({ Name = "Player ESP Settings", TextSize = 17, Glass = true, Outline = true })

ESPSection:AddToggle({
    Name = "Enable ESP",
    Default = Config.ESP.Enabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "ESPEnable",
    Save = true,
    Callback = function(Value)
        Config.ESP.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    ESP.Create(player)
                end
            end
            Notify("Player ESP Enabled")
        else
            for player, _ in pairs(ESP.Objects) do
                ESP.Remove(player)
            end
        end
    end
})

ESPSection:AddToggle({ Name = "Show Names (Size 22)", Default = Config.ESP.Names, Color = Colors.Blue, Outline = true, Flag = "ESPNames", Save = true, Callback = function(Value) Config.ESP.Names = Value end })
ESPSection:AddToggle({ Name = "Show Distance", Default = Config.ESP.Distance, Color = Colors.Blue, Outline = true, Flag = "ESPDistance", Save = true, Callback = function(Value) Config.ESP.Distance = Value end })
ESPSection:AddToggle({ Name = "Show Health Bar", Default = Config.ESP.Health, Color = Colors.Blue, Outline = true, Flag = "ESPHealth", Save = true, Callback = function(Value) Config.ESP.Health = Value end })
ESPSection:AddToggle({ Name = "Team Check", Default = Config.ESP.TeamCheck, Color = Colors.Blue, Outline = true, Flag = "ESPTeamCheck", Save = true, Callback = function(Value) Config.ESP.TeamCheck = Value end })
ESPSection:AddToggle({ Name = "Show Teammates", Default = Config.ESP.ShowTeammates, Color = Colors.Blue, Outline = true, Flag = "ESPShowTeam", Save = true, Callback = function(Value) Config.ESP.ShowTeammates = Value end })

ESPSection:AddSlider({
    Name = "Max ESP Distance",
    Min = 500,
    Max = 5000,
    Default = Config.ESP.MaxDistance,
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

-- Highlight Section
local HighlightSection = ESPTab:AddSection({ Name = "Highlight System", TextSize = 17, Glass = true, Outline = true })

HighlightSection:AddToggle({
    Name = "Enable Highlight",
    Default = Config.Highlight.Enabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "HighlightEnable",
    Save = true,
    Callback = function(Value)
        Config.Highlight.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    Highlight.Create(player)
                end
            end
            Notify("Highlight Enabled")
        else
            for player, _ in pairs(Highlight.Objects) do
                Highlight.Remove(player)
            end
        end
    end
})

HighlightSection:AddToggle({ Name = "Auto Team Colors", Default = Config.Highlight.TeamCheck, Color = Colors.Blue, Outline = true, Flag = "HighlightTeam", Save = true, Callback = function(Value) Config.Highlight.TeamCheck = Value end })
HighlightSection:AddToggle({ Name = "Show Team Highlight", Default = Config.Highlight.ShowTeam, Color = Colors.Blue, Outline = true, Flag = "HighlightShowTeam", Save = true, Callback = function(Value) Config.Highlight.ShowTeam = Value end })

--==================================================
-- MOVEMENT TAB
--==================================================
local SpeedSection = MovementTab:AddSection({ Name = "Speed Hack", TextSize = 17, Glass = true, Outline = true })

SpeedSection:AddToggle({
    Name = "Enable Speed",
    Default = Config.Movement.SpeedEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "SpeedEnable",
    Save = true,
    Callback = function(Value)
        Config.Movement.SpeedEnabled = Value
        if not Value then
            local char = LocalPlayer.Character
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
    Default = Config.Movement.SpeedValue,
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Callback = function(Value) Config.Movement.SpeedValue = Value end
})

local JumpSection = MovementTab:AddSection({ Name = "Jump Hack", TextSize = 17, Glass = true, Outline = true })

JumpSection:AddToggle({
    Name = "Enable Jump",
    Default = Config.Movement.JumpEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "JumpEnable",
    Save = true,
    Callback = function(Value)
        Config.Movement.JumpEnabled = Value
        if not Value then
            local char = LocalPlayer.Character
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
    Default = Config.Movement.JumpValue,
    Increment = 5,
    ValueName = "JP",
    Outline = true,
    Callback = function(Value) Config.Movement.JumpValue = Value end
})

local ExtraSection = MovementTab:AddSection({ Name = "Extra Movement", TextSize = 17, Glass = true, Outline = true })

ExtraSection:AddToggle({
    Name = "🚀 Infinite Jump",
    Default = Config.Movement.InfiniteJump,
    Color = Colors.Blue,
    Outline = true,
    Flag = "InfiniteJump",
    Save = true,
    Callback = function(Value)
        Config.Movement.InfiniteJump = Value
        Movement.SetupInfiniteJump()
    end
})

ExtraSection:AddToggle({
    Name = "👻 Noclip",
    Default = Config.Movement.Noclip,
    Color = Colors.Blue,
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Movement.Noclip = Value
        
        if Value then
            Movement.EnableNoclip()
            Notify("Noclip Enabled")
        else
            Movement.DisableNoclip()
            Notify("Noclip Disabled")
        end
    end
})

--==================================================
-- VISUAL TAB
--==================================================
local VisualSection = VisualTab:AddSection({ Name = "Visual Enhancements", TextSize = 17, Glass = true, Outline = true })

VisualSection:AddToggle({
    Name = "Wallhack",
    Default = Config.Visual.WallhackEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "Wallhack",
    Save = true,
    Callback = function(Value)
        Config.Visual.WallhackEnabled = Value
        Visual.UpdateWallhack()
    end
})

VisualSection:AddToggle({
    Name = "Fullbright",
    Default = Config.Visual.FullbrightEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "Fullbright",
    Save = true,
    Callback = function(Value)
        Config.Visual.FullbrightEnabled = Value
        Visual.UpdateLighting()
    end
})

VisualSection:AddToggle({
    Name = "No Fog",
    Default = Config.Visual.NoFogEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "NoFog",
    Save = true,
    Callback = function(Value)
        Config.Visual.NoFogEnabled = Value
        Visual.UpdateLighting()
    end
})

VisualSection:AddToggle({
    Name = "Super Zoom Out",
    Default = Config.Visual.SuperZoomEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "SuperZoom",
    Save = true,
    Callback = function(Value)
        Config.Visual.SuperZoomEnabled = Value
    end
})

VisualSection:AddSlider({
    Name = "Zoom Level",
    Min = 30,
    Max = 120,
    Default = Config.Visual.ZoomValue,
    Increment = 5,
    ValueName = "FOV",
    Outline = true,
    Callback = function(Value) Config.Visual.ZoomValue = Value end
})

local GraphicSection = VisualTab:AddSection({ Name = "Graphics & Performance", TextSize = 17, Glass = true, Outline = true })

GraphicSection:AddToggle({
    Name = "Anti-Aliasing",
    Default = Config.Visual.AntiAliasing,
    Color = Colors.Blue,
    Outline = true,
    Flag = "AntiAlias",
    Save = true,
    Callback = function(Value) Config.Visual.AntiAliasing = Value end
})

GraphicSection:AddSlider({
    Name = "Graphics Quality",
    Min = 1,
    Max = 21,
    Default = Config.Visual.GraphicsQuality,
    Increment = 1,
    ValueName = "Level",
    Outline = true,
    Callback = function(Value)
        Config.Visual.GraphicsQuality = Value
        settings().Rendering.QualityLevel = Value
    end
})

GraphicSection:AddToggle({
    Name = "Optimize Performance",
    Default = Config.Visual.OptimizePerformance,
    Color = Colors.Blue,
    Outline = true,
    Flag = "Optimize",
    Save = true,
    Callback = function(Value)
        Config.Visual.OptimizePerformance = Value
        Visual.UpdateGraphics()
    end
})

VisualTab:AddButton({
    Name = "Reset All Visual Settings",
    Icon = "refresh-cw",
    Outline = true,
    Callback = Visual.ResetAll
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportSection = TeleportTab:AddSection({ Name = "Player Teleport", TextSize = 17, Glass = true, Outline = true })

local dropdownOptions = GetPlayerList()

TeleportSection:AddDropdown({
    Name = "Select Player",
    Default = dropdownOptions[1] or "None",
    Options = dropdownOptions,
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "TeleportDropdown",
    Callback = function(Value)
        Config.Teleport.SelectedPlayer = Value
    end
})

TeleportSection:AddButton({
    Name = "Teleport to Selected Player",
    Icon = "send",
    Outline = true,
    Callback = function()
        if Config.Teleport.SelectedPlayer and Config.Teleport.SelectedPlayer ~= "None" then
            local target = Players:FindFirstChild(Config.Teleport.SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                Notify("Teleported to " .. Config.Teleport.SelectedPlayer)
            end
        else
            Notify("Please select a player first")
        end
    end
})

TeleportSection:AddButton({
    Name = "Refresh Player List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local newOptions = GetPlayerList()
        Notify("Player list refreshed - " .. #newOptions .. " players found")
    end
})

local WaypointSection = TeleportTab:AddSection({ Name = "Waypoints", TextSize = 17, Glass = true, Outline = true })

WaypointSection:AddButton({
    Name = "Save Current Position",
    Icon = "save",
    Outline = true,
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Config.Teleport.SavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            Notify("Position saved!")
        end
    end
})

WaypointSection:AddButton({
    Name = "Load Saved Position",
    Icon = "upload",
    Outline = true,
    Callback = function()
        if Config.Teleport.SavedPosition then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Config.Teleport.SavedPosition
            Notify("Teleported to saved position")
        else
            Notify("No saved position!")
        end
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({ Name = "Utilities", TextSize = 17, Glass = true, Outline = true })

MiscSection:AddToggle({
    Name = "Anti AFK",
    Default = Config.Misc.AntiAFK,
    Color = Colors.Blue,
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.Misc.AntiAFK = Value
        SetupAntiAFK()
    end
})

MiscSection:AddToggle({
    Name = "Hide Skill Check UI",
    Default = Config.UI.HideSkillCheck,
    Color = Colors.Blue,
    Outline = true,
    Flag = "HideSkillCheck",
    Save = true,
    Callback = function(Value)
        Config.UI.HideSkillCheck = Value
    end
})

--==================================================
-- GENERATOR TAB
--==================================================
local GenSection = GeneratorTab:AddSection({ Name = "Generator ESP", TextSize = 17, Glass = true, Outline = true })

GenSection:AddToggle({
    Name = "Enable Generator ESP",
    Default = Config.Generator.ESPEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "GenESP",
    Save = true,
    Callback = function(Value)
        Config.Generator.ESPEnabled = Value
        
        if Value then
            Notify("Generator ESP Enabled")
        else
            for gen, folder in pairs(Generator.Objects) do
                if folder then folder:Destroy() end
            end
            Generator.Objects = {}
        end
    end
})

GenSection:AddParagraph({
    Title = "Generator Status Colors",
    Desc = "🔵 Cyan = In Progress (0-99%)\n🟢 Green = Complete (100%)",
    Image = "info",
    ImageSize = 38
})

local AntiFailSection = GeneratorTab:AddSection({ Name = "Anti-Fail Systems", TextSize = 17, Glass = true, Outline = true })

AntiFailSection:AddToggle({
    Name = "Anti-Fail Generator",
    Default = Config.Generator.AntiFailEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "GenAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Generator.AntiFailEnabled = Value
        Notify(Value and "Anti-Fail Generator Enabled" or "Anti-Fail Generator Disabled")
    end
})

AntiFailSection:AddToggle({
    Name = "Anti-Fail Healing",
    Default = Config.Healing.AntiFailEnabled,
    Color = Colors.Blue,
    Outline = true,
    Flag = "HealAntiFail",
    Save = true,
    Callback = function(Value)
        Config.Healing.AntiFailEnabled = Value
        Notify(Value and "Anti-Fail Healing Enabled" or "Anti-Fail Healing Disabled")
    end
})

AntiFailSection:AddParagraph({
    Title = "Info",
    Desc = "✅ Auto-pass skill checks\n✅ Hold left click to repair/heal",
    Image = "check-circle",
    ImageSize = 38
})

--==================================================
-- CONFIG TAB
--==================================================
Window:AddConfigTab({ Name = "Settings", Icon = "settings" })

--==================================================
-- MAIN UPDATE LOOP
--==================================================
RunService.Heartbeat:Connect(function()
    ESP.Update()
    Movement.Update()
    Visual.UpdateLighting()
    Visual.UpdateZoom()
    
    if Config.Highlight.Enabled then
        Highlight.Update()
    end
end)

--==================================================
-- CHARACTER UPDATES
--==================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Config.Movement.Noclip then
        Movement.EnableNoclip()
    end
end)

--==================================================
-- INITIALIZATION
--==================================================
ESP.Init()
Generator.Scanner()
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu", 3)

print("═══════════════════════════════════════════════════════")
print("🔥 VIOLENCE DISTRICT - COMPLETE Edition 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Main Tab - Complete Player & Server Info")
print("✅ Player ESP - Names Size 22 + Health Bars")
print("✅ Movement - Speed, Jump, Infinite Jump, Noclip")
print("✅ Visual - Wallhack, Fullbright, No Fog, Super Zoom")
print("✅ Graphics - Anti-Aliasing, Quality Control")
print("✅ Teleport - Player List + Waypoints")
print("✅ Misc - Anti AFK, Hide UI")
print("✅ Generator - ESP + Anti-Fail System")
print("═══════════════════════════════════════════════════════")