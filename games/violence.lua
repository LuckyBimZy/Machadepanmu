-- ==================== VIOLENCE DISTRICT - ULTIMATE EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Features from RanZx999 + Original Features
-- Version: 2.0 ULTIMATE

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
-- CONFIG - MENGGABUNGKAN DARI KEDUA SCRIPT
--==================================================
local Toggles = {
    -- Player ESP (dari RanZx999)
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
    
    -- Highlight (dari RanZx999)
    Highlight = {
        Enabled = false,
        TeamCheck = true,
        ShowTeam = false
    },
    
    -- Generator (dari RanZx999 + original)
    Generator = {
        ESPEnabled = false,
        AntiFailEnabled = false,
        AutoFarm = false,
        AutoComplete = false
    },
    
    -- Healing (dari RanZx999)
    Healing = {
        AntiFailEnabled = false,
        AutoHeal = false
    },
    
    -- Visual (dari RanZx999 + original)
    Visual = {
        FullbrightEnabled = false,
        NoFog = false,
        Wallhack = false,
        HideSkillCheck = false
    },
    
    -- Movement (dari RanZx999 + original)
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 50,
        JumpEnabled = false,
        JumpValue = 100,
        InfiniteJump = false,
        Noclip = false,
        TeleportToMouse = false
    },
    
    -- Combat (dari original)
    Combat = {
        Aimbot = false,
        KillAura = false,
        KillAuraRange = 20
    },
    
    -- Auto Farm (dari original)
    AutoFarm = {
        AutoPresent = false,
        AutoGift = false,
        AutoCoins = false
    },
    
    -- Misc (dari original + RanZx999)
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

--==================================================
-- TEAM CHECK FUNCTION
--==================================================
local function isTeammate(player)
    if not Player.Team then return false end
    if not player.Team then return false end
    return player.Team == Player.Team
end

local function getPlayerColor(player)
    if Toggles.ESP.TeamCheck and isTeammate(player) then
        return TeamColor
    else
        return EnemyColor
    end
end

--==================================================
-- HIDE SKILLCHECK UI
--==================================================
RunService.RenderStepped:Connect(function()
    if Toggles.Visual.HideSkillCheck then
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
-- ANTI-FAIL SYSTEM (UNIFIED)
--==================================================
local AntiFailHooked = false

local function setupUnifiedAntiFail()
    if AntiFailHooked then return end
    
    task.spawn(function()
        local success = pcall(function()
            -- Wait for remotes
            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not Remotes then return end
            
            -- Wait for Events folder
            local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
            
            -- Generator remotes
            local GenRemotes = Remotes:FindFirstChild("Generator")
            local GenResultEvent = GenRemotes and GenRemotes:FindFirstChild("SkillCheckResultEvent")
            local GenFailEvent = GenRemotes and GenRemotes:FindFirstChild("SkillCheckFailEvent")
            
            -- Healing remotes
            local Healing = EventsFolder and EventsFolder:FindFirstChild("Healing")
            local HealResultEvent = Healing and Healing:FindFirstChild("SkillCheckResultEvent")
            local HealFailEvent = Healing and Healing:FindFirstChild("SkillCheckFailEvent")
            
            -- Hook metamethod
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                -- GENERATOR ANTI-FAIL
                if GenResultEvent and Toggles.Generator.AntiFailEnabled then
                    -- Block fail event
                    if GenFailEvent and self == GenFailEvent and method == "FireServer" then
                        return nil
                    end
                    
                    -- Force success on generator
                    if self == GenResultEvent and method == "FireServer" then
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            args[1] = true
                            return oldNamecall(self, unpack(args))
                        else
                            return nil
                        end
                    end
                end
                
                -- HEALING ANTI-FAIL
                if HealResultEvent and Toggles.Healing.AntiFailEnabled then
                    -- Block fail event
                    if HealFailEvent and self == HealFailEvent and method == "FireServer" then
                        return nil
                    end
                    
                    -- Force success on healing
                    if self == HealResultEvent and method == "FireServer" then
                        args[1] = true
                        return oldNamecall(self, unpack(args))
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            AntiFailHooked = true
            print("✅ Unified Anti-Fail System hooked successfully!")
        end)
        
        if not success then
            warn("⚠️ Anti-Fail System hook failed")
        end
    end)
end

-- Initialize anti-fail system
setupUnifiedAntiFail()

--==================================================
-- PLAYER ESP (DARI RANZX999)
--==================================================
local ESPObjects = {}
local ESPConnections = {}

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
    
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 15
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Font = 2
    
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 13
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Font = 2
    
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
    if not Toggles.ESP.Enabled then
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
        
        if Toggles.ESP.TeamCheck and isTeammate(player) then
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
        
        if distance > Toggles.ESP.MaxDistance then
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
        
        if Toggles.ESP.Boxes then
            esp.Box.Size = boxSize
            esp.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            esp.Box.Color = playerColor
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        if Toggles.ESP.Names then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 35)
            esp.Name.Color = playerColor
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        if Toggles.ESP.Distance then
            esp.Distance.Text = string.format("[%.0fm]", distance)
            esp.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxSize.Y / 2 + 20)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        if Toggles.ESP.Health and hum then
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
        
        if Toggles.ESP.Tracers then
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
        if Toggles.ESP.Enabled then
            createPlayerESP(player)
        end
    end)
    
    if player.Character then
        task.spawn(function()
            player.Character:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
            if Toggles.ESP.Enabled then
                createPlayerESP(player)
            end
        end)
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Player then
        setupPlayerESP(player)
    end
end

Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

--==================================================
-- HIGHLIGHT SYSTEM (DARI RANZX999)
--==================================================
local Highlights = {}

local function createHighlight(player)
    if player == Player then return end
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "VD_Highlight"
    highlight.Parent = player.Character
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    if Toggles.Highlight.TeamCheck then
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
        
        if Toggles.Highlight.TeamCheck and isTeammate(player) and not Toggles.Highlight.ShowTeam then
            highlight.Enabled = false
            continue
        else
            highlight.Enabled = true
        end
        
        if Toggles.Highlight.TeamCheck then
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

RunService.Heartbeat:Connect(function()
    if Toggles.Highlight.Enabled then
        updateHighlights()
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
            highlight.Enabled = Toggles.Generator.ESPEnabled
            textLabel.Visible = Toggles.Generator.ESPEnabled
            
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
        if Toggles.Generator.ESPEnabled then
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
-- WALLHACK FUNCTION
--==================================================
function UpdateWallhack()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if Toggles.Visual.Wallhack then
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
-- FULLBRIGHT (FOG REMOVAL!)
--==================================================
task.spawn(function()
    while true do
        if Toggles.Visual.FullbrightEnabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            
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
                
                if v:IsA("ColorCorrectionEffect") then
                    v.Enabled = false
                end
                
                if v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.FogStart = originalLighting.FogStart or 0
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") and originalLighting.Atmosphere then
                    v.Density = originalLighting.Atmosphere.Density or 0.3
                    v.Offset = originalLighting.Atmosphere.Offset or 0.25
                    v.Glare = originalLighting.Atmosphere.Glare or 0
                    v.Haze = originalLighting.Atmosphere.Haze or 0
                end
            end
        end
        task.wait(0.5)
    end
end)

--==================================================
-- MOVEMENT & NOCLIP
--==================================================
local noclipConnection = nil
local infiniteJumpConnection = nil

local function updateMovement()
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if Toggles.Movement.SpeedEnabled then
        hum.WalkSpeed = Toggles.Movement.SpeedValue
    else
        hum.WalkSpeed = 16
    end
    
    if Toggles.Movement.JumpEnabled then
        hum.JumpPower = Toggles.Movement.JumpValue
    else
        hum.JumpPower = 50
    end
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.Movement.InfiniteJump then
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
        if not Toggles.Movement.Noclip then return end
        
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

-- Teleport to mouse
UserInputService.InputBegan:Connect(function(input)
    if Toggles.Movement.TeleportToMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = Mouse.Hit.p
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(target.X, target.Y + 3, target.Z)
    end
end)

-- Character update
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    if Toggles.Movement.Noclip then
        enableNoclip()
    end
end)

--==================================================
-- UTILITY FUNCTIONS (DARI ORIGINAL)
--==================================================
local Loops = {}
local SavedPosition = nil

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            
            if name == "Present" and Toggles.AutoFarm.AutoPresent then
                local present = FindNearestPresent()
                if present then
                    Player.Character.HumanoidRootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
                
            elseif name == "Gift" and Toggles.AutoFarm.AutoGift then
                local gift = FindNearestGift()
                if gift then
                    Player.Character.HumanoidRootPart.CFrame = gift.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
                
            elseif name == "Coins" and Toggles.AutoFarm.AutoCoins then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Coin" and v:IsA("BasePart") then
                        local dist = (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude
                        if dist < 30 then
                            Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.1)
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then fireproximityprompt(prompt) end
                            break
                        end
                    end
                end
                
            elseif name == "Heal" and Toggles.Healing.AutoHeal then
                if Player.Character.Humanoid.Health < 50 then
                    local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                    if remote then pcall(function() remote:FireServer("Heal") end) end
                end
                
            elseif name == "Aimbot" and Toggles.Combat.Aimbot then
                local target = FindNearestPlayer()
                if target and target.Character then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    Player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(Player.Character.HumanoidRootPart.Position, targetPos)
                end
                
            elseif name == "KillAura" and Toggles.Combat.KillAura then
                local range = Toggles.Combat.KillAuraRange
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
                        local dist = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= range then
                            player.Character.Humanoid.Health = 0
                        end
                    end
                end
                
            elseif name == "GeneratorFarm" and Toggles.Generator.AutoFarm then
                local gen = FindNearestGenerator()
                if gen and gen.PrimaryPart then
                    Player.Character.HumanoidRootPart.CFrame = gen.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = gen:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
                
            elseif name == "GeneratorComplete" and Toggles.Generator.AutoComplete then
                local gen = FindNearestGenerator()
                if gen then
                    local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                    if remote then pcall(function() remote:FireServer("CompleteGenerator", gen) end) end
                end
                
            elseif name == "Click" and Toggles.Misc.AutoClick then
                mouse1click()
            end
            
            task.wait(0.1)
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

-- Find functions
function FindNearestGenerator()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") and v.PrimaryPart then
            local d = (root.Position - v.PrimaryPart.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function FindNearestPresent()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Present" and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function FindNearestGift()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Gift" and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function FindNearestPlayer()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist, nearest = d, player
            end
        end
    end
    return nearest
end

function GetPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(list, player.Name)
        end
    end
    return list
end

--==================================================
-- CREATE MAIN WINDOW (CATRAZ HUB)
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "VIOLENCE DISTRICT ULTIMATE",
    Subtext = "by RanZx999 + Original",
    Version = "v2.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VD_Ultimate_Config",
    IntroEnabled = true,
    IntroText = "Violence District Ultimate",
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

--==================================================
-- CREATE TABS
--==================================================
local PlayerESPTab = Window:MakeTab({
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
    Icon = "activity",
    Glass = true,
    Outline = true
})

local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "sword",
    Glass = true,
    Outline = true
})

local AutoFarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "zap",
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
-- PLAYER ESP TAB
--==================================================
local ESPMainSection = PlayerESPTab:AddSection({
    Name = "Player ESP (Auto-Detect!)",
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
        Toggles.ESP.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    createPlayerESP(player)
                end
            end
            OrionLib:MakeNotification({
                Name = "Player ESP Enabled",
                Content = "Auto-detecting players!",
                Time = 3
            })
        else
            for player, _ in pairs(ESPObjects) do
                removePlayerESP(player)
            end
        end
    end
})

local ESPFeaturesSection = PlayerESPTab:AddSection({
    Name = "ESP Features",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ESPFeaturesSection:AddToggle({
    Name = "Show Boxes",
    Default = false,
    Outline = true,
    Callback = function(Value) Toggles.ESP.Boxes = Value end
})

ESPFeaturesSection:AddToggle({
    Name = "Show Names",
    Default = false,
    Outline = true,
    Callback = function(Value) Toggles.ESP.Names = Value end
})

ESPFeaturesSection:AddToggle({
    Name = "Show Distance",
    Default = false,
    Outline = true,
    Callback = function(Value) Toggles.ESP.Distance = Value end
})

ESPFeaturesSection:AddToggle({
    Name = "Show Health",
    Default = false,
    Outline = true,
    Callback = function(Value) Toggles.ESP.Health = Value end
})

ESPFeaturesSection:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Outline = true,
    Callback = function(Value) Toggles.ESP.Tracers = Value end
})

local ESPSettingsSection = PlayerESPTab:AddSection({
    Name = "ESP Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ESPSettingsSection:AddToggle({
    Name = "Team Check (Hide Teammates)",
    Default = true,
    Outline = true,
    Callback = function(Value) Toggles.ESP.TeamCheck = Value end
})

ESPSettingsSection:AddSlider({
    Name = "Max ESP Distance",
    Min = 500,
    Max = 5000,
    Default = 2000,
    Increment = 100,
    ValueName = "m",
    Outline = true,
    Callback = function(Value) Toggles.ESP.MaxDistance = Value end
})

ESPSettingsSection:AddParagraph({
    Title = "Color Guide",
    Desc = "🟢 Green = Teammate\n🔴 Red = Enemy",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- HIGHLIGHT TAB
--==================================================
local HighlightMainSection = HighlightTab:AddSection({
    Name = "Character Highlight",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

HighlightMainSection:AddToggle({
    Name = "Enable Highlight",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightEnabled",
    Save = true,
    Callback = function(Value)
        Toggles.Highlight.Enabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player then
                    createHighlight(player)
                end
            end
            
            Players.PlayerAdded:Connect(function(player)
                if Toggles.Highlight.Enabled then
                    repeat task.wait() until player.Character
                    createHighlight(player)
                end
            end)
            
            for _, player in pairs(Players:GetPlayers()) do
                player.CharacterAdded:Connect(function()
                    if Toggles.Highlight.Enabled then
                        task.wait(0.5)
                        createHighlight(player)
                    end
                end)
            end
            
            OrionLib:MakeNotification({
                Name = "Highlight Enabled",
                Content = "Players are now highlighted!",
                Time = 3
            })
        else
            for player, _ in pairs(Highlights) do
                removeHighlight(player)
            end
        end
    end
})

HighlightMainSection:AddToggle({
    Name = "Auto Team Colors",
    Default = true,
    Outline = true,
    Callback = function(Value) Toggles.Highlight.TeamCheck = Value end
})

HighlightMainSection:AddToggle({
    Name = "Show Team Highlight",
    Default = false,
    Outline = true,
    Callback = function(Value) Toggles.Highlight.ShowTeam = Value end
})

HighlightMainSection:AddParagraph({
    Title = "Color Guide",
    Desc = "🟢 Green = Teammate\n🔴 Red = Enemy",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- GENERATOR TAB
--==================================================
local GenESPSection = GeneratorTab:AddSection({
    Name = "Generator ESP",
    TextSize = 17,
    Folded = false,
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
        Toggles.Generator.ESPEnabled = Value
        
        if Value then
            OrionLib:MakeNotification({
                Name = "Generator ESP Enabled",
                Content = "Scanning for generators...",
                Time = 3
            })
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

local GenAntiFailSection = GeneratorTab:AddSection({
    Name = "Anti-Fail Generator",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

GenAntiFailSection:AddToggle({
    Name = "Enable Anti-Fail Generator",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "GenAntiFail",
    Save = true,
    Callback = function(Value)
        Toggles.Generator.AntiFailEnabled = Value
        
        OrionLib:MakeNotification({
            Name = Value and "Anti-Fail Generator Enabled" or "Anti-Fail Generator Disabled",
            Content = Value and "Skill checks will never fail!" or "Normal skill checks restored",
            Time = 3
        })
    end
})

GenAntiFailSection:AddLabel("✅ Auto-pass generator skill checks")
GenAntiFailSection:AddLabel("✅ Hold left click to repair")

local GenAutoFarmSection = GeneratorTab:AddSection({
    Name = "Auto Farm Generator",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

GenAutoFarmSection:AddToggle({
    Name = "Auto Farm Generator",
    Default = false,
    Outline = true,
    Callback = function(Value)
        Toggles.Generator.AutoFarm = Value
        if Value then StartLoop("GeneratorFarm") else StopLoop("GeneratorFarm") end
    end
})

GenAutoFarmSection:AddToggle({
    Name = "Auto Complete Generator",
    Default = false,
    Outline = true,
    Callback = function(Value)
        Toggles.Generator.AutoComplete = Value
        if Value then StartLoop("GeneratorComplete") else StopLoop("GeneratorComplete") end
    end
})

--==================================================
-- HEALING TAB
--==================================================
local HealAntiFailSection = HealingTab:AddSection({
    Name = "Anti-Fail Healing",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

HealAntiFailSection:AddToggle({
    Name = "Enable Anti-Fail Heal",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HealAntiFail",
    Save = true,
    Callback = function(Value)
        Toggles.Healing.AntiFailEnabled = Value
        
        OrionLib:MakeNotification({
            Name = Value and "Anti-Fail Heal Enabled" or "Anti-Fail Heal Disabled",
            Content = Value and "Healing skill checks will never fail!" or "Normal healing restored",
            Time = 3
        })
    end
})

HealAntiFailSection:AddLabel("✅ Auto-pass healing skill checks")
HealAntiFailSection:AddLabel("✅ Never fail healing")

local HealAutoSection = HealingTab:AddSection({
    Name = "Auto Heal",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

HealAutoSection:AddToggle({
    Name = "Auto Heal",
    Default = false,
    Outline = true,
    Callback = function(Value)
        Toggles.Healing.AutoHeal = Value
        if Value then StartLoop("Heal") else StopLoop("Heal") end
    end
})

--==================================================
-- VISUAL TAB
--==================================================
local VisualMainSection = VisualTab:AddSection({
    Name = "Visual Enhancements",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

VisualMainSection:AddToggle({
    Name = "Enable Fullbright",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Fullbright",
    Save = true,
    Callback = function(Value)
        Toggles.Visual.FullbrightEnabled = Value
        
        OrionLib:MakeNotification({
            Name = Value and "Fullbright Enabled" or "Fullbright Disabled",
            Content = Value and "Map is now bright! (Fog removed)" or "Normal lighting restored",
            Time = 3
        })
    end
})

VisualMainSection:AddLabel("✅ Removes fog completely")
VisualMainSection:AddLabel("✅ Removes atmosphere effects")

VisualMainSection:AddToggle({
    Name = "Wallhack",
    Default = false,
    Outline = true,
    Callback = function(Value)
        Toggles.Visual.Wallhack = Value
        UpdateWallhack()
    end
})

local HideUISection = VisualTab:AddSection({
    Name = "Hide UI Elements",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

HideUISection:AddToggle({
    Name = "Hide Skill Check UI",
    Default = false,
    Outline = true,
    Flag = "HideSkillCheck",
    Save = true,
    Callback = function(Value)
        Toggles.Visual.HideSkillCheck = Value
        
        OrionLib:MakeNotification({
            Name = Value and "Skill Check UI Hidden" or "Skill Check UI Visible",
            Content = Value and "Clean screen mode enabled!" or "Normal UI restored",
            Time = 3
        })
    end
})

HideUISection:AddLabel("✅ Hides SkillCheckPromptGui")
HideUISection:AddLabel("✅ Clean screen while repairing")

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
    Outline = true,
    Flag = "SpeedEnabled",
    Save = true,
    Callback = function(Value)
        Toggles.Movement.SpeedEnabled = Value
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
    Callback = function(Value) Toggles.Movement.SpeedValue = Value end
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
    Outline = true,
    Flag = "JumpEnabled",
    Save = true,
    Callback = function(Value)
        Toggles.Movement.JumpEnabled = Value
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
    Callback = function(Value) Toggles.Movement.JumpValue = Value end
})

local ExtraMoveSection = MovementTab:AddSection({
    Name = "Extra Movement",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ExtraMoveSection:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Outline = true,
    Flag = "InfiniteJump",
    Save = true,
    Callback = function(Value)
        Toggles.Movement.InfiniteJump = Value
    end
})

ExtraMoveSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Toggles.Movement.Noclip = Value
        
        if Value then
            enableNoclip()
            OrionLib:MakeNotification({
                Name = "Noclip Enabled",
                Content = "Walk through walls!",
                Time = 3
            })
        else
            disableNoclip()
            OrionLib:MakeNotification({
                Name = "Noclip Disabled",
                Content = "Normal collision restored",
                Time = 3
            })
        end
    end
})

--==================================================
-- COMBAT TAB
--==================================================
local CombatMainSection = CombatTab:AddSection({
    Name = "Combat Features",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

CombatMainSection:AddToggle({
    Name = "Aimbot",
    Default = false,
    Outline = true,
    Flag = "Aimbot",
    Save = true,
    Callback = function(Value)
        Toggles.Combat.Aimbot = Value
        if Value then StartLoop("Aimbot") else StopLoop("Aimbot") end
    end
})

CombatMainSection:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Outline = true,
    Flag = "KillAura",
    Save = true,
    Callback = function(Value)
        Toggles.Combat.KillAura = Value
        if Value then StartLoop("KillAura") else StopLoop("KillAura") end
    end
})

CombatMainSection:AddSlider({
    Name = "Kill Aura Range",
    Min = 5,
    Max = 50,
    Default = 20,
    Increment = 1,
    ValueName = "m",
    Outline = true,
    Callback = function(Value) Toggles.Combat.KillAuraRange = Value end
})

--==================================================
-- AUTO FARM TAB
--==================================================
local AutoFarmMainSection = AutoFarmTab:AddSection({
    Name = "Auto Collect",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

AutoFarmMainSection:AddToggle({
    Name = "Auto Present",
    Default = false,
    Outline = true,
    Flag = "AutoPresent",
    Save = true,
    Callback = function(Value)
        Toggles.AutoFarm.AutoPresent = Value
        if Value then StartLoop("Present") else StopLoop("Present") end
    end
})

AutoFarmMainSection:AddToggle({
    Name = "Auto Gift",
    Default = false,
    Outline = true,
    Flag = "AutoGift",
    Save = true,
    Callback = function(Value)
        Toggles.AutoFarm.AutoGift = Value
        if Value then StartLoop("Gift") else StopLoop("Gift") end
    end
})

AutoFarmMainSection:AddToggle({
    Name = "Auto Coins",
    Default = false,
    Outline = true,
    Flag = "AutoCoins",
    Save = true,
    Callback = function(Value)
        Toggles.AutoFarm.AutoCoins = Value
        if Value then StartLoop("Coins") else StopLoop("Coins") end
    end
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportMainSection = TeleportTab:AddSection({
    Name = "Teleport Options",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

TeleportMainSection:AddToggle({
    Name = "Teleport to Mouse (Right Click)",
    Default = false,
    Outline = true,
    Flag = "TPMouse",
    Save = true,
    Callback = function(Value)
        Toggles.Movement.TeleportToMouse = Value
    end
})

TeleportMainSection:AddDropdown({
    Name = "Teleport to Player",
    Default = GetPlayerList()[1] or "None",
    Options = GetPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Callback = function(Value)
        local target = Players:FindFirstChild(Value)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            OrionLib:MakeNotification({
                Name = "Teleported",
                Content = "To " .. Value,
                Time = 2
            })
        end
    end
})

local WaypointSection = TeleportTab:AddSection({
    Name = "Waypoints",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

WaypointSection:AddButton({
    Name = "Save Position",
    Icon = "save",
    Outline = true,
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SavedPosition = Player.Character.HumanoidRootPart.CFrame
            OrionLib:MakeNotification({
                Name = "Position Saved",
                Content = "Current position saved!",
                Time = 2
            })
        end
    end
})

WaypointSection:AddButton({
    Name = "Load Position",
    Icon = "upload",
    Outline = true,
    Callback = function()
        if SavedPosition then
            Player.Character.HumanoidRootPart.CFrame = SavedPosition
            OrionLib:MakeNotification({
                Name = "Position Loaded",
                Content = "Teleported to saved position",
                Time = 2
            })
        else
            OrionLib:MakeNotification({
                Name = "No Saved Position",
                Content = "Save a position first!",
                Time = 2
            })
        end
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscMainSection = MiscTab:AddSection({
    Name = "Utility",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

MiscMainSection:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Toggles.Misc.AntiAFK = Value
        if Value then
            Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

MiscMainSection:AddToggle({
    Name = "Auto Click",
    Default = false,
    Outline = true,
    Flag = "AutoClick",
    Save = true,
    Callback = function(Value)
        Toggles.Misc.AutoClick = Value
        if Value then StartLoop("Click") else StopLoop("Click") end
    end
})

local InfoSection = MiscTab:AddSection({
    Name = "Script Information",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

InfoSection:AddParagraph({
    Title = "VIOLENCE DISTRICT",
    Desc = "Version: 2.0 ULTIMATE\nCreated by: RanZx999 + Original\nUI: Catraz Hub",
    Image = "award",
    ImageSize = 38
})

InfoSection:AddButton({
    Name = "Destroy Script",
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
        
        OrionLib:MakeNotification({
            Name = "Script Destroyed",
            Content = "VIOLENCE DISTRICT unloaded!",
            Time = 3
        })
        
        task.wait(1)
        OrionLib:Destroy()
        _G.VD_Loaded = false
    end
})

InfoSection:AddLabel("• Toggle UI: F4")
InfoSection:AddLabel("• All features auto-save")

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

--==================================================
-- MAIN UPDATE LOOP
--==================================================
RunService.Heartbeat:Connect(function()
    updatePlayerESP()
    updateMovement()
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

-- Notifikasi startup
OrionLib:MakeNotification({
    Name = "VIOLENCE DISTRICT ULTIMATE",
    Content = "Loaded successfully! Press F4 to toggle",
    Time = 5
})

-- Print ke console
print("═══════════════════════════════════════════════════════")
print("🔥 VIOLENCE DISTRICT - ULTIMATE EDITION 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Player ESP - Auto-detect + Team Check")
print("✅ Highlight - Team colors (Green/Red)")
print("✅ Generator ESP - Auto-scan with progress")
print("✅ Anti-Fail System - UNIFIED (Generator + Healing)")
print("✅ Hide Skill Check UI - Clean screen")
print("✅ Fullbright - Complete fog removal")
print("✅ Wallhack - See through walls")
print("✅ Movement - Speed, Jump, Infinite Jump, Noclip")
print("✅ Combat - Aimbot, Kill Aura")
print("✅ Auto Farm - Presents, Gifts, Coins")
print("✅ Teleport - To mouse, players, waypoints")
print("═══════════════════════════════════════════════════════")
print("Created by RanZx999 + Original | UI: Catraz Hub")
print("═══════════════════════════════════════════════════════")