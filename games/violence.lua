-- ==================== VIOLENCE DISTRICT - COMPLETE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.0 COMPLETE (STRUCTURED)

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
-- [SECTION 1] CORE SERVICES & VARIABLES
--==================================================
local Core = {}
Core.Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    VirtualUser = game:GetService("VirtualUser"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Stats = game:GetService("Stats")
}

Core.Player = Core.Services.Players.LocalPlayer
Core.Mouse = Core.Player:GetMouse()
Core.Camera = Core.Services.Workspace.CurrentCamera
Core.StartTime = tick()

--==================================================
-- [SECTION 2] COLOR CONSTANTS
--==================================================
local Colors = {
    Team = Color3.fromRGB(0, 255, 0),
    Enemy = Color3.fromRGB(255, 0, 0),
    Friendly = Color3.fromRGB(0, 255, 255),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Gray = Color3.fromRGB(128, 128, 128)
}

--==================================================
-- [SECTION 3] CONFIGURATION SYSTEM
--==================================================
local Config = {
    -- Version Control
    Version = "3.0",
    
    -- Main Tab
    Main = {
        PlayerInfo = true,
        ServerInfo = true
    },
    
    -- ESP Settings
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Tracers = false,
        TeamCheck = true,
        MaxDistance = 2000,
        ShowTeammates = false,
        FontSize = 22  -- Fixed at 22 as requested
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
        FullbrightEnabled = false,
        NoFogEnabled = false,
        WallhackEnabled = false,
        SuperZoomEnabled = false,
        ZoomValue = 70,
        AntiAliasing = false,
        GraphicsQuality = 1,
        OptimizePerformance = false
    },
    
    -- Movement Settings
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 50,
        JumpEnabled = false,
        JumpValue = 100,
        InfiniteJump = false,
        Noclip = false
    },
    
    -- Teleport Settings
    Teleport = {
        SavedPosition = nil,
        SelectedPlayer = nil
    },
    
    -- Misc Settings
    Misc = {
        AntiAFK = false,
        ActiveFeatures = {}
    }
}

--==================================================
-- [SECTION 4] ORIGINAL STATE SAVER
--==================================================
local OriginalState = {
    Lighting = {
        Brightness = Core.Services.Lighting.Brightness,
        ClockTime = Core.Services.Lighting.ClockTime,
        FogEnd = Core.Services.Lighting.FogEnd,
        FogStart = Core.Services.Lighting.FogStart,
        GlobalShadows = Core.Services.Lighting.GlobalShadows,
        OutdoorAmbient = Core.Services.Lighting.OutdoorAmbient,
        Atmosphere = nil,
        Blur = nil
    },
    Camera = {
        FieldOfView = Core.Camera.FieldOfView
    },
    Graphics = {
        QualityLevel = settings().Rendering.QualityLevel
    }
}

-- Save atmosphere and blur effects
local atm = Core.Services.Lighting:FindFirstChildOfClass("Atmosphere")
if atm then
    OriginalState.Lighting.Atmosphere = {
        Density = atm.Density,
        Offset = atm.Offset,
        Glare = atm.Glare,
        Haze = atm.Haze
    }
end

local blur = Core.Services.Lighting:FindFirstChildOfClass("BlurEffect")
if blur then
    OriginalState.Lighting.Blur = { Size = blur.Size }
end

--==================================================
-- [SECTION 5] UTILITY FUNCTIONS
--==================================================
local Utilities = {}

function Utilities.Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Violence District",
        Content = msg,
        Image = "info",
        Time = duration or 2.5
    })
end

function Utilities.FormatUptime()
    local uptime = tick() - Core.StartTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function Utilities.GetPing()
    return math.floor(Core.Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
end

function Utilities.GetPlayerList()
    local list = {}
    for _, player in pairs(Core.Services.Players:GetPlayers()) do
        if player ~= Core.Player then
            table.insert(list, player.Name)
        end
    end
    return list
end

function Utilities.IsTeammate(player)
    if not Core.Player.Team then return false end
    if not player.Team then return false end
    return player.Team == Core.Player.Team
end

function Utilities.GetPlayerColor(player)
    if Config.ESP.TeamCheck and Utilities.IsTeammate(player) then
        return Colors.Team
    else
        return Colors.Enemy
    end
end

--==================================================
-- [SECTION 6] ACTIVE FEATURES TRACKER
--==================================================
local FeatureTracker = {
    ActiveFeaturesLabel = nil,
    
    Update = function()
        local activeList = {}
        
        if Config.ESP.Enabled then table.insert(activeList, "ESP") end
        if Config.Highlight.Enabled then table.insert(activeList, "Highlight") end
        if Config.Movement.SpeedEnabled then table.insert(activeList, "Speed") end
        if Config.Movement.JumpEnabled then table.insert(activeList, "Jump") end
        if Config.Movement.InfiniteJump then table.insert(activeList, "Infinite Jump") end
        if Config.Movement.Noclip then table.insert(activeList, "Noclip") end
        if Config.Visual.FullbrightEnabled then table.insert(activeList, "Fullbright") end
        if Config.Visual.NoFogEnabled then table.insert(activeList, "No Fog") end
        if Config.Visual.WallhackEnabled then table.insert(activeList, "Wallhack") end
        if Config.Visual.SuperZoomEnabled then table.insert(activeList, "Super Zoom") end
        if Config.Generator.ESPEnabled then table.insert(activeList, "Gen ESP") end
        if Config.Generator.AntiFailEnabled then table.insert(activeList, "Anti-Fail Gen") end
        if Config.Healing.AntiFailEnabled then table.insert(activeList, "Anti-Fail Heal") end
        if Config.UI.HideSkillCheck then table.insert(activeList, "Hide UI") end
        if Config.Misc.AntiAFK then table.insert(activeList, "Anti AFK") end
        
        local text = "No active features"
        if #activeList > 0 then
            text = "✅ " .. table.concat(activeList, " • ")
        end
        
        if FeatureTracker.ActiveFeaturesLabel then
            pcall(function()
                FeatureTracker.ActiveFeaturesLabel:Set(text)
            end)
        end
    end
}

--==================================================
-- [SECTION 7] ESP SYSTEM
--==================================================
local ESP = {
    Objects = {},
    Connections = {},
    
    Create = function(player)
        if player == Core.Player then return end
        if ESP.Objects[player] then return end
        
        ESP.Objects[player] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            HealthBarBG = Drawing.new("Square"),
            HealthBar = Drawing.new("Square"),
            Tracer = Drawing.new("Line")
        }
        
        local esp = ESP.Objects[player]
        
        -- Box settings
        esp.Box.Visible = false
        esp.Box.Thickness = 2
        esp.Box.Transparency = 1
        esp.Box.Filled = false
        
        -- Name settings (Size 22 - Bold)
        esp.Name.Visible = false
        esp.Name.Color = Colors.White
        esp.Name.Size = 22
        esp.Name.Center = true
        esp.Name.Outline = true
        esp.Name.OutlineColor = Colors.Black
        esp.Name.Font = 3  -- Bold font
        
        -- Distance settings
        esp.Distance.Visible = false
        esp.Distance.Color = Colors.Gray
        esp.Distance.Size = 16
        esp.Distance.Center = true
        esp.Distance.Outline = true
        esp.Distance.OutlineColor = Colors.Black
        esp.Distance.Font = 2
        
        -- Health bar settings
        esp.HealthBarBG.Visible = false
        esp.HealthBarBG.Color = Color3.fromRGB(20, 20, 20)
        esp.HealthBarBG.Thickness = 1
        esp.HealthBarBG.Transparency = 0.8
        esp.HealthBarBG.Filled = true
        
        esp.HealthBar.Visible = false
        esp.HealthBar.Color = Colors.Team
        esp.HealthBar.Thickness = 1
        esp.HealthBar.Transparency = 1
        esp.HealthBar.Filled = true
        
        -- Tracer settings
        esp.Tracer.Visible = false
        esp.Tracer.Thickness = 1
        esp.Tracer.Transparency = 1
    end,
    
    Remove = function(player)
        if ESP.Objects[player] then
            for _, obj in pairs(ESP.Objects[player]) do
                pcall(function() obj:Remove() end)
            end
            ESP.Objects[player] = nil
        end
    end,
    
    Update = function()
        if not Config.ESP.Enabled then
            for _, esp in pairs(ESP.Objects) do
                for _, obj in pairs(esp) do obj.Visible = false end
            end
            return
        end
        
        for player, esp in pairs(ESP.Objects) do
            if not player or not player.Parent or not player.Character then
                ESP.Remove(player)
                continue
            end
            
            if Config.ESP.TeamCheck and Utilities.IsTeammate(player) and not Config.ESP.ShowTeammates then
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
            
            local distance = (hrp.Position - Core.Camera.CFrame.Position).Magnitude
            
            if distance > Config.ESP.MaxDistance then
                for _, obj in pairs(esp) do obj.Visible = false end
                continue
            end
            
            local headPos, onScreen = Core.Camera:WorldToViewportPoint(head.Position)
            local rootPos = Core.Camera:WorldToViewportPoint(hrp.Position)
            
            if not onScreen then
                for _, obj in pairs(esp) do obj.Visible = false end
                continue
            end
            
            local boxSize = Vector2.new(2000 / distance, 2500 / distance)
            local playerColor = Utilities.GetPlayerColor(player)
            
            -- Update box
            if Config.ESP.Boxes then
                esp.Box.Size = boxSize
                esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                esp.Box.Color = playerColor
                esp.Box.Visible = true
            else
                esp.Box.Visible = false
            end
            
            -- Update name (Size 22)
            if Config.ESP.Names then
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 45)
                esp.Name.Color = playerColor
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
            
            -- Update distance
            if Config.ESP.Distance then
                esp.Distance.Text = string.format("[%.0fm]", distance)
                esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxSize.Y / 2 + 25)
                esp.Distance.Visible = true
            else
                esp.Distance.Visible = false
            end
            
            -- Update health bar
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
            
            -- Update tracer
            if Config.ESP.Tracers then
                local screenCenter = Vector2.new(Core.Camera.ViewportSize.X / 2, Core.Camera.ViewportSize.Y)
                esp.Tracer.From = screenCenter
                esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.Tracer.Color = playerColor
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end
        end
    end,
    
    SetupPlayer = function(player)
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
            if Config.ESP.Enabled then
                ESP.Create(player)
            end
        end)
        
        if player.Character then
            task.spawn(function()
                player.Character:WaitForChild("HumanoidRootPart")
                task.wait(0.5)
                if Config.ESP.Enabled then
                    ESP.Create(player)
                end
            end)
        end
    end,
    
    Init = function()
        for _, player in pairs(Core.Services.Players:GetPlayers()) do
            if player ~= Core.Player then
                ESP.SetupPlayer(player)
            end
        end
        
        Core.Services.Players.PlayerAdded:Connect(ESP.SetupPlayer)
        Core.Services.Players.PlayerRemoving:Connect(ESP.Remove)
    end
}

--==================================================
-- [SECTION 8] HIGHLIGHT SYSTEM
--==================================================
local Highlight = {
    Objects = {},
    
    Create = function(player)
        if player == Core.Player then return end
        if not player.Character then return end
        if Highlight.Objects[player] then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.Adornee = player.Character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        
        if Config.Highlight.TeamCheck then
            if Utilities.IsTeammate(player) then
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
            
            if Config.Highlight.TeamCheck and Utilities.IsTeammate(player) and not Config.Highlight.ShowTeam then
                highlight.Enabled = false
                continue
            else
                highlight.Enabled = Config.Highlight.Enabled
            end
            
            if Config.Highlight.TeamCheck then
                if Utilities.IsTeammate(player) then
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
-- [SECTION 9] MOVEMENT SYSTEM
--==================================================
local Movement = {
    NoclipConnection = nil,
    InfiniteJumpConnection = nil,
    
    Update = function()
        local char = Core.Player.Character
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
            Movement.InfiniteJumpConnection = Core.Services.UserInputService.JumpRequest:Connect(function()
                local char = Core.Player.Character
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
        if Movement.NoclipConnection then Movement.NoclipConnection:Disconnect() end
        
        Movement.NoclipConnection = Core.Services.RunService.Stepped:Connect(function()
            if not Config.Movement.Noclip then return end
            
            local char = Core.Player.Character
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
        
        local char = Core.Player.Character
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
-- [SECTION 10] VISUAL SYSTEM
--==================================================
local Visual = {
    WallhackConnection = nil,
    
    UpdateWallhack = function()
        if Visual.WallhackConnection then
            Visual.WallhackConnection:Disconnect()
            Visual.WallhackConnection = nil
        end
        
        if Config.Visual.WallhackEnabled then
            Visual.WallhackConnection = Core.Services.RunService.RenderStepped:Connect(function()
                for _, v in pairs(Core.Services.Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsDescendantOf(Core.Player.Character) then
                        if v.Transparency < 0.5 then
                            v.Material = Enum.Material.ForceField
                            v.Transparency = 0.5
                        end
                    end
                end
            end)
        else
            -- Restore normal materials
            for _, v in pairs(Core.Services.Workspace:GetDescendants()) do
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
            Core.Services.Lighting.Brightness = 2
            Core.Services.Lighting.ClockTime = 14
            Core.Services.Lighting.GlobalShadows = false
            Core.Services.Lighting.OutdoorAmbient = Colors.Gray
        else
            Core.Services.Lighting.Brightness = OriginalState.Lighting.Brightness
            Core.Services.Lighting.ClockTime = OriginalState.Lighting.ClockTime
            Core.Services.Lighting.GlobalShadows = OriginalState.Lighting.GlobalShadows
            Core.Services.Lighting.OutdoorAmbient = OriginalState.Lighting.OutdoorAmbient
        end
        
        -- No Fog
        if Config.Visual.NoFogEnabled then
            Core.Services.Lighting.FogStart = 0
            Core.Services.Lighting.FogEnd = 100000
            
            for _, v in pairs(Core.Services.Lighting:GetChildren()) do
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
            Core.Services.Lighting.FogEnd = OriginalState.Lighting.FogEnd
            Core.Services.Lighting.FogStart = OriginalState.Lighting.FogStart or 0
            
            for _, v in pairs(Core.Services.Lighting:GetChildren()) do
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
            Core.Camera.FieldOfView = Config.Visual.ZoomValue
        else
            Core.Camera.FieldOfView = OriginalState.Camera.FieldOfView
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
        
        -- Reset lighting
        Visual.UpdateLighting()
        
        -- Reset camera
        Core.Camera.FieldOfView = OriginalState.Camera.FieldOfView
        
        -- Reset graphics
        settings().Rendering.QualityLevel = OriginalState.Graphics.QualityLevel
        
        -- Disable wallhack
        Visual.UpdateWallhack()
        
        Utilities.Notify("All visual settings reset to default")
        FeatureTracker.Update()
    end
}

--==================================================
-- [SECTION 11] GENERATOR SYSTEM
--==================================================
local Generator = {
    Objects = {},
    
    CreateESP = function(gen)
        if not gen:IsA("Model") or gen:FindFirstChild("GenESP") then return end
        
        local folder = Instance.new("Folder", gen)
        folder.Name = "GenESP"
        
        local highlight = Instance.new("Highlight", folder)
        highlight.Adornee = gen
        highlight.FillColor = Color3.new(0, 1, 1)
        highlight.DepthMode = "AlwaysOnTop"
        
        local billboard = Instance.new("BillboardGui", folder)
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.Adornee = gen:FindFirstChild("HitBox") or gen.PrimaryPart
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        
        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Colors.White
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 18
        textLabel.TextStrokeTransparency = 0.5
        textLabel.TextStrokeColor3 = Colors.Black
        
        task.spawn(function()
            while gen.Parent and folder.Parent do
                local progress = gen:GetAttribute("RepairProgress") or 0
                textLabel.Text = "⚡ " .. math.floor(progress) .. "%"
                highlight.Enabled = Config.Generator.ESPEnabled
                textLabel.Visible = Config.Generator.ESPEnabled
                
                if progress >= 100 then
                    highlight.FillColor = Colors.Team
                else
                    highlight.FillColor = Color3.new(0, 1, 1)
                end
                
                task.wait(1)
            end
        end)
        
        Generator.Objects[gen] = folder
    end,
    
    Scanner = function()
        task.spawn(function()
            while true do
                if Config.Generator.ESPEnabled then
                    for _, obj in pairs(Core.Services.Workspace:GetDescendants()) do
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
-- [SECTION 12] ANTI-FAIL SYSTEM
--==================================================
local AntiFail = {
    Hooked = false,
    
    Setup = function()
        if AntiFail.Hooked then return end
        
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
                            if Core.Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
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
                
                AntiFail.Hooked = true
            end)
        end)
    end
}

--==================================================
-- [SECTION 13] UI SYSTEM
--==================================================
local UI = {
    Window = nil,
    Tabs = {},
    
    CreateWindow = function()
        UI.Window = OrionLib:MakeWindow({
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
    end,
    
    CreateTabs = function()
        UI.Tabs.Main = UI.Window:MakeTab({ Name = "Main", Icon = "home", Glass = true, Outline = true })
        UI.Tabs.ESP = UI.Window:MakeTab({ Name = "Player ESP", Icon = "eye", Glass = true, Outline = true })
        UI.Tabs.Movement = UI.Window:MakeTab({ Name = "Movement", Icon = "footprints", Glass = true, Outline = true })
        UI.Tabs.Visual = UI.Window:MakeTab({ Name = "Visual", Icon = "sun", Glass = true, Outline = true })
        UI.Tabs.Teleport = UI.Window:MakeTab({ Name = "Teleport", Icon = "map-pin", Glass = true, Outline = true })
        UI.Tabs.Misc = UI.Window:MakeTab({ Name = "Misc", Icon = "settings", Glass = true, Outline = true })
        UI.Tabs.Generator = UI.Window:MakeTab({ Name = "Generator", Icon = "zap", Glass = true, Outline = true })
    end,
    
    PopulateMainTab = function()
        -- Player Info Section
        local playerSection = UI.Tabs.Main:AddSection({ Name = "Player Information", TextSize = 17, Glass = true, Outline = true })
        local playerTeam = Core.Player.Team and Core.Player.Team.Name or "No Team"
        
        playerSection:AddParagraph({
            Title = Core.Player.Name,
            Desc = "Display Name: " .. Core.Player.DisplayName .. 
                   "\nUser ID: " .. Core.Player.UserId ..
                   "\nAccount Age: " .. Core.Player.AccountAge .. " days" ..
                   "\nTeam: " .. playerTeam,
            Image = "user",
            ImageSize = 48
        })
        
        -- Server Info Section
        local serverSection = UI.Tabs.Main:AddSection({ Name = "Server Information", TextSize = 17, Glass = true, Outline = true })
        
        serverSection:AddParagraph({
            Title = "Server Status",
            Desc = "Players: " .. #Core.Services.Players:GetPlayers() .. 
                   "\nPing: " .. Utilities.GetPing() .. " ms" ..
                   "\nUptime: " .. Utilities.FormatUptime(),
            Image = "server",
            ImageSize = 38,
            Buttons = {
                {
                    Title = "Refresh",
                    Callback = function()
                        -- Refresh would update the paragraph
                        Utilities.Notify("Info refreshed")
                    end
                }
            }
        })
        
        -- Active Features Section
        local activeSection = UI.Tabs.Main:AddSection({ Name = "Active Features", TextSize = 17, Glass = true, Outline = true })
        
        FeatureTracker.ActiveFeaturesLabel = activeSection:AddParagraph({
            Title = "Currently Active",
            Desc = "No active features",
            Image = "activity",
            ImageSize = 38
        })
    end,
    
    PopulateESPTab = function()
        local espSection = UI.Tabs.ESP:AddSection({ Name = "Player ESP Settings", TextSize = 17, Glass = true, Outline = true })
        
        espSection:AddToggle({
            Name = "Enable ESP",
            Default = Config.ESP.Enabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "ESPEnable",
            Save = true,
            Callback = function(Value)
                Config.ESP.Enabled = Value
                
                if Value then
                    for _, player in pairs(Core.Services.Players:GetPlayers()) do
                        if player ~= Core.Player then
                            ESP.Create(player)
                        end
                    end
                    Utilities.Notify("Player ESP Enabled")
                else
                    for player, _ in pairs(ESP.Objects) do
                        ESP.Remove(player)
                    end
                end
                FeatureTracker.Update()
            end
        })
        
        espSection:AddToggle({ Name = "Show Boxes", Default = Config.ESP.Boxes, Color = Colors.Team, Outline = true, Flag = "ESPBoxes", Save = true, Callback = function(Value) Config.ESP.Boxes = Value end })
        espSection:AddToggle({ Name = "Show Names (Size 22 - Bold)", Default = Config.ESP.Names, Color = Colors.Team, Outline = true, Flag = "ESPNames", Save = true, Callback = function(Value) Config.ESP.Names = Value end })
        espSection:AddToggle({ Name = "Show Distance", Default = Config.ESP.Distance, Color = Colors.Team, Outline = true, Flag = "ESPDistance", Save = true, Callback = function(Value) Config.ESP.Distance = Value end })
        espSection:AddToggle({ Name = "Show Health Bar", Default = Config.ESP.Health, Color = Colors.Team, Outline = true, Flag = "ESPHealth", Save = true, Callback = function(Value) Config.ESP.Health = Value end })
        espSection:AddToggle({ Name = "Show Tracers", Default = Config.ESP.Tracers, Color = Colors.Team, Outline = true, Flag = "ESPTracers", Save = true, Callback = function(Value) Config.ESP.Tracers = Value end })
        espSection:AddToggle({ Name = "Team Check", Default = Config.ESP.TeamCheck, Color = Colors.Team, Outline = true, Flag = "ESPTeamCheck", Save = true, Callback = function(Value) Config.ESP.TeamCheck = Value end })
        espSection:AddToggle({ Name = "Show Teammates (Override)", Default = Config.ESP.ShowTeammates, Color = Colors.Team, Outline = true, Flag = "ESPShowTeam", Save = true, Callback = function(Value) Config.ESP.ShowTeammates = Value end })
        
        espSection:AddSlider({
            Name = "Max ESP Distance",
            Min = 500,
            Max = 5000,
            Default = Config.ESP.MaxDistance,
            Increment = 100,
            ValueName = "m",
            Outline = true,
            Callback = function(Value) Config.ESP.MaxDistance = Value end
        })
        
        espSection:AddParagraph({
            Title = "Color Guide",
            Desc = "🟢 Green = Teammate\n🔴 Red = Enemy",
            Image = "info",
            ImageSize = 38
        })
        
        -- Highlight Section
        local highlightSection = UI.Tabs.ESP:AddSection({ Name = "Highlight System", TextSize = 17, Glass = true, Outline = true })
        
        highlightSection:AddToggle({
            Name = "Enable Highlight",
            Default = Config.Highlight.Enabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "HighlightEnable",
            Save = true,
            Callback = function(Value)
                Config.Highlight.Enabled = Value
                
                if Value then
                    for _, player in pairs(Core.Services.Players:GetPlayers()) do
                        if player ~= Core.Player then
                            Highlight.Create(player)
                        end
                    end
                    Utilities.Notify("Highlight Enabled")
                else
                    for player, _ in pairs(Highlight.Objects) do
                        Highlight.Remove(player)
                    end
                end
                FeatureTracker.Update()
            end
        })
        
        highlightSection:AddToggle({ Name = "Auto Team Colors", Default = Config.Highlight.TeamCheck, Color = Colors.Team, Outline = true, Flag = "HighlightTeam", Save = true, Callback = function(Value) Config.Highlight.TeamCheck = Value end })
        highlightSection:AddToggle({ Name = "Show Team Highlight", Default = Config.Highlight.ShowTeam, Color = Colors.Team, Outline = true, Flag = "HighlightShowTeam", Save = true, Callback = function(Value) Config.Highlight.ShowTeam = Value end })
    end,
    
    PopulateMovementTab = function()
        local speedSection = UI.Tabs.Movement:AddSection({ Name = "Speed Hack", TextSize = 17, Glass = true, Outline = true })
        
        speedSection:AddToggle({
            Name = "Enable Speed",
            Default = Config.Movement.SpeedEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "SpeedEnable",
            Save = true,
            Callback = function(Value)
                Config.Movement.SpeedEnabled = Value
                if not Value then
                    local char = Core.Player.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.WalkSpeed = 16 end
                    end
                end
                FeatureTracker.Update()
            end
        })
        
        speedSection:AddSlider({
            Name = "Speed Value",
            Min = 16,
            Max = 200,
            Default = Config.Movement.SpeedValue,
            Increment = 1,
            ValueName = "WS",
            Outline = true,
            Callback = function(Value) Config.Movement.SpeedValue = Value end
        })
        
        local jumpSection = UI.Tabs.Movement:AddSection({ Name = "Jump Hack", TextSize = 17, Glass = true, Outline = true })
        
        jumpSection:AddToggle({
            Name = "Enable Jump",
            Default = Config.Movement.JumpEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "JumpEnable",
            Save = true,
            Callback = function(Value)
                Config.Movement.JumpEnabled = Value
                if not Value then
                    local char = Core.Player.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.JumpPower = 50 end
                    end
                end
                FeatureTracker.Update()
            end
        })
        
        jumpSection:AddSlider({
            Name = "Jump Power",
            Min = 50,
            Max = 300,
            Default = Config.Movement.JumpValue,
            Increment = 5,
            ValueName = "JP",
            Outline = true,
            Callback = function(Value) Config.Movement.JumpValue = Value end
        })
        
        local extraSection = UI.Tabs.Movement:AddSection({ Name = "Extra Movement", TextSize = 17, Glass = true, Outline = true })
        
        extraSection:AddToggle({
            Name = "🚀 Infinite Jump",
            Default = Config.Movement.InfiniteJump,
            Color = Colors.Team,
            Outline = true,
            Flag = "InfiniteJump",
            Save = true,
            Callback = function(Value)
                Config.Movement.InfiniteJump = Value
                Movement.SetupInfiniteJump()
                FeatureTracker.Update()
            end
        })
        
        extraSection:AddToggle({
            Name = "👻 Noclip",
            Default = Config.Movement.Noclip,
            Color = Colors.Team,
            Outline = true,
            Flag = "Noclip",
            Save = true,
            Callback = function(Value)
                Config.Movement.Noclip = Value
                
                if Value then
                    Movement.EnableNoclip()
                    Utilities.Notify("Noclip Enabled")
                else
                    Movement.DisableNoclip()
                    Utilities.Notify("Noclip Disabled")
                end
                FeatureTracker.Update()
            end
        })
    end,
    
    PopulateVisualTab = function()
        local visualSection = UI.Tabs.Visual:AddSection({ Name = "Visual Enhancements", TextSize = 17, Glass = true, Outline = true })
        
        visualSection:AddToggle({
            Name = "Wallhack",
            Default = Config.Visual.WallhackEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "Wallhack",
            Save = true,
            Callback = function(Value)
                Config.Visual.WallhackEnabled = Value
                Visual.UpdateWallhack()
                FeatureTracker.Update()
            end
        })
        
        visualSection:AddToggle({
            Name = "Fullbright",
            Default = Config.Visual.FullbrightEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "Fullbright",
            Save = true,
            Callback = function(Value)
                Config.Visual.FullbrightEnabled = Value
                Visual.UpdateLighting()
                FeatureTracker.Update()
            end
        })
        
        visualSection:AddToggle({
            Name = "No Fog",
            Default = Config.Visual.NoFogEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "NoFog",
            Save = true,
            Callback = function(Value)
                Config.Visual.NoFogEnabled = Value
                Visual.UpdateLighting()
                FeatureTracker.Update()
            end
        })
        
        visualSection:AddToggle({
            Name = "Super Zoom Out",
            Default = Config.Visual.SuperZoomEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "SuperZoom",
            Save = true,
            Callback = function(Value)
                Config.Visual.SuperZoomEnabled = Value
                FeatureTracker.Update()
            end
        })
        
        visualSection:AddSlider({
            Name = "Zoom Level",
            Min = 30,
            Max = 120,
            Default = Config.Visual.ZoomValue,
            Increment = 5,
            ValueName = "FOV",
            Outline = true,
            Callback = function(Value) Config.Visual.ZoomValue = Value end
        })
        
        local graphicSection = UI.Tabs.Visual:AddSection({ Name = "Graphics & Performance", TextSize = 17, Glass = true, Outline = true })
        
        graphicSection:AddToggle({
            Name = "Anti-Aliasing",
            Default = Config.Visual.AntiAliasing,
            Color = Colors.Team,
            Outline = true,
            Flag = "AntiAlias",
            Save = true,
            Callback = function(Value) Config.Visual.AntiAliasing = Value end
        })
        
        graphicSection:AddSlider({
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
        
        graphicSection:AddToggle({
            Name = "Optimize Performance",
            Default = Config.Visual.OptimizePerformance,
            Color = Colors.Team,
            Outline = true,
            Flag = "Optimize",
            Save = true,
            Callback = function(Value)
                Config.Visual.OptimizePerformance = Value
                Visual.UpdateGraphics()
            end
        })
        
        UI.Tabs.Visual:AddButton({
            Name = "Reset All Visual Settings",
            Icon = "refresh-cw",
            Outline = true,
            Callback = Visual.ResetAll
        })
    end,
    
    PopulateTeleportTab = function()
        local teleportSection = UI.Tabs.Teleport:AddSection({ Name = "Player Teleport", TextSize = 17, Glass = true, Outline = true })
        
        local dropdownOptions = Utilities.GetPlayerList()
        
        teleportSection:AddDropdown({
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
        
        teleportSection:AddButton({
            Name = "Teleport to Selected Player",
            Icon = "send",
            Outline = true,
            Callback = function()
                if Config.Teleport.SelectedPlayer and Config.Teleport.SelectedPlayer ~= "None" then
                    local target = Core.Services.Players:FindFirstChild(Config.Teleport.SelectedPlayer)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        Core.Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        Utilities.Notify("Teleported to " .. Config.Teleport.SelectedPlayer)
                    end
                else
                    Utilities.Notify("Please select a player first")
                end
            end
        })
        
        teleportSection:AddButton({
            Name = "Refresh Player List",
            Icon = "refresh-cw",
            Outline = true,
            Callback = function()
                local newOptions = Utilities.GetPlayerList()
                Utilities.Notify("Player list refreshed - " .. #newOptions .. " players found")
            end
        })
        
        local waypointSection = UI.Tabs.Teleport:AddSection({ Name = "Waypoints", TextSize = 17, Glass = true, Outline = true })
        
        waypointSection:AddButton({
            Name = "Save Current Position",
            Icon = "save",
            Outline = true,
            Callback = function()
                if Core.Player.Character and Core.Player.Character:FindFirstChild("HumanoidRootPart") then
                    Config.Teleport.SavedPosition = Core.Player.Character.HumanoidRootPart.CFrame
                    Utilities.Notify("Position saved!")
                end
            end
        })
        
        waypointSection:AddButton({
            Name = "Load Saved Position",
            Icon = "upload",
            Outline = true,
            Callback = function()
                if Config.Teleport.SavedPosition then
                    Core.Player.Character.HumanoidRootPart.CFrame = Config.Teleport.SavedPosition
                    Utilities.Notify("Teleported to saved position")
                else
                    Utilities.Notify("No saved position!")
                end
            end
        })
    end,
    
    PopulateMiscTab = function()
        local miscSection = UI.Tabs.Misc:AddSection({ Name = "Utilities", TextSize = 17, Glass = true, Outline = true })
        
        miscSection:AddToggle({
            Name = "Anti AFK",
            Default = Config.Misc.AntiAFK,
            Color = Colors.Team,
            Outline = true,
            Flag = "AntiAFK",
            Save = true,
            Callback = function(Value)
                Config.Misc.AntiAFK = Value
                if Value then
                    Core.Player.Idled:Connect(function()
                        Core.Services.VirtualUser:CaptureController()
                        Core.Services.VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
                FeatureTracker.Update()
            end
        })
        
        miscSection:AddToggle({
            Name = "Hide Skill Check UI",
            Default = Config.UI.HideSkillCheck,
            Color = Colors.Team,
            Outline = true,
            Flag = "HideSkillCheck",
            Save = true,
            Callback = function(Value)
                Config.UI.HideSkillCheck = Value
                FeatureTracker.Update()
            end
        })
    end,
    
    PopulateGeneratorTab = function()
        local genSection = UI.Tabs.Generator:AddSection({ Name = "Generator ESP", TextSize = 17, Glass = true, Outline = true })
        
        genSection:AddToggle({
            Name = "Enable Generator ESP",
            Default = Config.Generator.ESPEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "GenESP",
            Save = true,
            Callback = function(Value)
                Config.Generator.ESPEnabled = Value
                
                if Value then
                    Utilities.Notify("Generator ESP Enabled")
                else
                    for gen, folder in pairs(Generator.Objects) do
                        if folder then folder:Destroy() end
                    end
                    Generator.Objects = {}
                end
                FeatureTracker.Update()
            end
        })
        
        genSection:AddParagraph({
            Title = "Generator Status Colors",
            Desc = "🔵 Cyan = In Progress (0-99%)\n🟢 Green = Complete (100%)",
            Image = "info",
            ImageSize = 38
        })
        
        local antiFailSection = UI.Tabs.Generator:AddSection({ Name = "Anti-Fail Systems", TextSize = 17, Glass = true, Outline = true })
        
        antiFailSection:AddToggle({
            Name = "Anti-Fail Generator",
            Default = Config.Generator.AntiFailEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "GenAntiFail",
            Save = true,
            Callback = function(Value)
                Config.Generator.AntiFailEnabled = Value
                Utilities.Notify(Value and "Anti-Fail Generator Enabled" or "Anti-Fail Generator Disabled")
                FeatureTracker.Update()
            end
        })
        
        antiFailSection:AddToggle({
            Name = "Anti-Fail Healing",
            Default = Config.Healing.AntiFailEnabled,
            Color = Colors.Team,
            Outline = true,
            Flag = "HealAntiFail",
            Save = true,
            Callback = function(Value)
                Config.Healing.AntiFailEnabled = Value
                Utilities.Notify(Value and "Anti-Fail Healing Enabled" or "Anti-Fail Healing Disabled")
                FeatureTracker.Update()
            end
        })
        
        antiFailSection:AddParagraph({
            Title = "Info",
            Desc = "✅ Auto-pass skill checks\n✅ Hold left click to repair/heal",
            Image = "check-circle",
            ImageSize = 38
        })
    end,
    
    Init = function()
        UI.CreateWindow()
        UI.CreateTabs()
        UI.PopulateMainTab()
        UI.PopulateESPTab()
        UI.PopulateMovementTab()
        UI.PopulateVisualTab()
        UI.PopulateTeleportTab()
        UI.PopulateMiscTab()
        UI.PopulateGeneratorTab()
        
        -- Add config tab
        UI.Window:AddConfigTab({ Name = "Settings", Icon = "settings" })
        
        -- Initialize UI
        OrionLib:Init()
    end
}

--==================================================
-- [SECTION 14] MAIN UPDATE LOOP
--==================================================
local function SetupUpdateLoop()
    Core.Services.RunService.Heartbeat:Connect(function()
        -- Update ESP
        ESP.Update()
        
        -- Update movement
        Movement.Update()
        
        -- Update visuals
        Visual.UpdateLighting()
        Visual.UpdateZoom()
        
        -- Update highlights
        if Config.Highlight.Enabled then
            Highlight.Update()
        end
        
        -- Update active features every 2 seconds
        if tick() % 2 < 0.1 then
            FeatureTracker.Update()
        end
    end)
    
    -- Hide skill check UI
    Core.Services.RunService.RenderStepped:Connect(function()
        if Config.UI.HideSkillCheck then
            local PlayerGui = Core.Player:FindFirstChild("PlayerGui")
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
end

--==================================================
-- [SECTION 15] CHARACTER UPDATES
--==================================================
local function SetupCharacterUpdates()
    Core.Player.CharacterAdded:Connect(function(char)
        Core.Player.Character = char
        task.wait(1)
        
        -- Re-apply noclip if enabled
        if Config.Movement.Noclip then
            Movement.EnableNoclip()
        end
    end)
end

--==================================================
-- [SECTION 16] INITIALIZATION
--==================================================
local function Initialize()
    -- Initialize systems
    ESP.Init()
    Generator.Scanner()
    AntiFail.Setup()
    
    -- Create UI
    UI.Init()
    
    -- Setup loops
    SetupUpdateLoop()
    SetupCharacterUpdates()
    
    -- Initial notification
    Utilities.Notify("Press F4 or click floating button to toggle menu", 3)
    
    -- Print info
    print("═══════════════════════════════════════════════════════")
    print("🔥 VIOLENCE DISTRICT - COMPLETE Edition 🔥")
    print("═══════════════════════════════════════════════════════")
    print("✅ Main Tab - Complete Player & Server Info")
    print("✅ Player ESP - Bold Names Size 22 + Full Features")
    print("✅ Movement - Speed, Jump, Infinite Jump, Noclip")
    print("✅ Visual - Wallhack, Fullbright, No Fog, Super Zoom")
    print("✅ Graphics - Anti-Aliasing, Quality Control")
    print("✅ Teleport - Player List + Waypoints")
    print("✅ Misc - Anti AFK, Hide UI, Active Features Counter")
    print("✅ Generator - ESP + Anti-Fail System")
    print("═══════════════════════════════════════════════════════")
end

-- Start the script
Initialize()