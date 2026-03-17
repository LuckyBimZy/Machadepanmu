--[[
═══════════════════════════════════════════════════════════════
  VIOLENCE DISTRICT - ULTIMATE EDITION (ENHANCED)
  Created by RanZx999 (Modified)
  UI: Rayfield Premium
═══════════════════════════════════════════════════════════════

Features:
✅ Player Name ESP (White Large Font) - NO BOXES!
✅ Highlight System (Lobby: White | Game: Green/Red)
✅ Generator ESP dengan progress %
✅ Anti-Fail Generator & Healing
✅ Hide Skill Check UI
✅ Fullbright, No Fog, Wallhack, Infinite Zoom
✅ Speed Hack (16-200) with slider
✅ Jump Hack (50-300) with slider
✅ Infinite Jump
✅ Noclip
✅ Teleport to Player with dropdown
✅ Waypoints (Save/Load Position)
✅ Anti AFK
✅ Active Features Counter
✅ Player Info di Main Tab

Created by RanZx999
═══════════════════════════════════════════════════════════════
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// SAVE ORIGINAL LIGHTING
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

--// COLORS
local TeamColor = Color3.fromRGB(0, 255, 0)      -- Hijau untuk teammate
local EnemyColor = Color3.fromRGB(255, 0, 0)      -- Merah untuk enemy
local LobbyColor = Color3.fromRGB(255, 255, 255)  -- Putih untuk lobby

--// CONFIG
getgenv().VDConfig = {
    Main = {
        PlayerInfo = true
    },
    ESP = {
        Enabled = false,
        Names = true,        -- Always true when ESP enabled
        Distance = false,
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
-- TEAM CHECK FUNCTION
--==================================================
local function isTeammate(player)
    if not LocalPlayer.Team then return false end
    if not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

--==================================================
-- ACTIVE FEATURES COUNTER
--==================================================
local function GetActiveFeatures()
    local active = {}
    
    if VDConfig.ESP.Enabled then table.insert(active, "ESP") end
    if VDConfig.Highlight.Enabled then table.insert(active, "Highlight") end
    if VDConfig.Generator.ESPEnabled then table.insert(active, "GenESP") end
    if VDConfig.Generator.AntiFailEnabled then table.insert(active, "AntiGen") end
    if VDConfig.Healing.AntiFailEnabled then table.insert(active, "AntiHeal") end
    if VDConfig.UI.HideSkillCheck then table.insert(active, "HideSC") end
    if VDConfig.Visual.FullbrightEnabled then table.insert(active, "Fullbright") end
    if VDConfig.Visual.NoFogEnabled then table.insert(active, "NoFog") end
    if VDConfig.Visual.WallhackEnabled then table.insert(active, "Wallhack") end
    if VDConfig.Visual.InfiniteZoom then table.insert(active, "InfZoom") end
    if VDConfig.Movement.SpeedEnabled then table.insert(active, "Speed") end
    if VDConfig.Movement.JumpEnabled then table.insert(active, "Jump") end
    if VDConfig.Movement.InfiniteJump then table.insert(active, "InfJump") end
    if VDConfig.Movement.Noclip then table.insert(active, "Noclip") end
    if VDConfig.Misc.AntiAFK then table.insert(active, "AntiAFK") end
    
    return active
end

--==================================================
-- PLAYER NAME ESP ONLY (NO BOXES, NO DRAWINGS)
--==================================================
local ESPObjects = {}

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    
    -- Hanya menggunakan BillboardGui untuk nama (lebih stabil, tidak ada kotak)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VD_NameESP"
    billboard.Parent = player.Character
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.ResetOnSpawn = false
    billboard.Enabled = false  -- Akan di-update
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)  -- Putih
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Parent = billboard
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 1, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = ""
    distanceLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    distanceLabel.TextStrokeTransparency = 0.3
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextScaled = true
    
    ESPObjects[player] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        DistanceLabel = distanceLabel
    }
end

local function removePlayerESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Billboard then
            pcall(function() ESPObjects[player].Billboard:Destroy() end)
        end
        ESPObjects[player] = nil
    end
end

local function updatePlayerESP()
    if not VDConfig.ESP.Enabled then
        for _, esp in pairs(ESPObjects) do
            if esp.Billboard then
                esp.Billboard.Enabled = false
            end
        end
        return
    end
    
    for player, esp in pairs(ESPObjects) do
        if not player or not player.Parent or not player.Character then
            removePlayerESP(player)
            continue
        end
        
        -- Team check
        if VDConfig.ESP.TeamCheck and isTeammate(player) and not VDConfig.ESP.ShowTeammates then
            esp.Billboard.Enabled = false
            continue
        end
        
        -- Distance check
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            esp.Billboard.Enabled = false
            continue
        end
        
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > VDConfig.ESP.MaxDistance then
            esp.Billboard.Enabled = false
            continue
        end
        
        -- Update nama (selalu putih)
        esp.NameLabel.Text = player.Name
        esp.NameLabel.TextColor3 = Color3.new(1, 1, 1)  -- Putih
        
        -- Update jarak jika diaktifkan
        if VDConfig.ESP.Distance then
            esp.DistanceLabel.Text = string.format("[%.0fm]", distance)
        else
            esp.DistanceLabel.Text = ""
        end
        
        esp.Billboard.Enabled = true
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

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
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
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    -- Hapus highlight lama jika ada
    if Highlights[player] then
        pcall(function() Highlights[player]:Destroy() end)
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = player.Character
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Set warna berdasarkan kondisi
    if not LocalPlayer.Team or not player.Team then
        -- Lobby: semua putih
        highlight.FillColor = LobbyColor
        highlight.OutlineColor = LobbyColor
    elseif isTeammate(player) then
        -- Teammate: hijau
        highlight.FillColor = TeamColor
        highlight.OutlineColor = TeamColor
    else
        -- Enemy: merah
        highlight.FillColor = EnemyColor
        highlight.OutlineColor = EnemyColor
    end
    
    Highlights[player] = highlight
end

local function removeHighlight(player)
    if Highlights[player] then
        pcall(function() Highlights[player]:Destroy() end)
        Highlights[player] = nil
    end
end

local function updateHighlights()
    for player, highlight in pairs(Highlights) do
        if not player or not player.Parent or not player.Character then
            removeHighlight(player)
            continue
        end
        
        -- Update warna berdasarkan kondisi terbaru
        if not LocalPlayer.Team or not player.Team then
            -- Lobby: semua putih
            highlight.FillColor = LobbyColor
            highlight.OutlineColor = LobbyColor
            highlight.Enabled = VDConfig.Highlight.Enabled
        elseif isTeammate(player) then
            -- Teammate: hijau (atau hide jika ShowTeam = false)
            if VDConfig.Highlight.ShowTeam then
                highlight.FillColor = TeamColor
                highlight.OutlineColor = TeamColor
                highlight.Enabled = VDConfig.Highlight.Enabled
            else
                highlight.Enabled = false
            end
        else
            -- Enemy: merah
            highlight.FillColor = EnemyColor
            highlight.OutlineColor = EnemyColor
            highlight.Enabled = VDConfig.Highlight.Enabled
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
    
    if VDConfig.Visual.WallhackEnabled then
        WallhackConnection = RunService.RenderStepped:Connect(function()
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
            if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
            end
        end
    end
end

--==================================================
-- VISUAL FUNCTIONS
--==================================================
local function updateNoFog()
    if VDConfig.Visual.NoFogEnabled then
        Lighting.FogEnd = 1e9
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end

local function updateInfiniteZoom()
    if VDConfig.Visual.InfiniteZoom and Camera then
        Camera.FieldOfView = 120
    elseif Camera then
        Camera.FieldOfView = 70
    end
end

local function updateFullbright()
    if VDConfig.Visual.FullbrightEnabled then
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

local function updateMovement()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if VDConfig.Movement.SpeedEnabled then
        hum.WalkSpeed = VDConfig.Movement.SpeedValue
    else
        hum.WalkSpeed = 16
    end
    
    if VDConfig.Movement.JumpEnabled then
        hum.JumpPower = VDConfig.Movement.JumpValue
    else
        hum.JumpPower = 50
    end
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if VDConfig.Movement.InfiniteJump then
        local char = LocalPlayer.Character
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
        if not VDConfig.Movement.Noclip then return end
        
        local char = LocalPlayer.Character
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
    
    local char = LocalPlayer.Character
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
local VirtualUser = game:GetService("VirtualUser")
local antiAFKConnection = nil

local function setupAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    
    if VDConfig.Misc.AntiAFK then
        antiAFKConnection = LocalPlayer.Idled:Connect(function()
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
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

local function teleportToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        Rayfield:Notify({
            Title = "Teleport",
            Content = "Teleported to " .. playerName,
            Duration = 2
        })
        return true
    end
    return false
end

--==================================================
-- HIDE SKILLCHECK UI
--==================================================
RunService.RenderStepped:Connect(function()
    if VDConfig.UI.HideSkillCheck then
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        
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
-- ANTI-FAIL SYSTEM (DARI CODE ASLI)
--==================================================
local AntiFailHooked = false

local function setupUnifiedAntiFail()
    if AntiFailHooked then return end
    
    task.spawn(function()
        local success = pcall(function()
            -- Wait for remotes
            local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
            if not Remotes then 
                warn("⚠️ Remotes not found")
                return 
            end
            
            -- Wait for Events folder
            local EventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
            if not EventsFolder then
                warn("⚠️ Events folder not found")
            end
            
            -- Generator remotes
            local GenRemotes = Remotes:WaitForChild("Generator", 5)
            local GenResultEvent = GenRemotes and GenRemotes:WaitForChild("SkillCheckResultEvent", 5)
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
                if GenResultEvent and VDConfig.Generator.AntiFailEnabled then
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
                if HealResultEvent and VDConfig.Healing.AntiFailEnabled then
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
    end)
end

setupUnifiedAntiFail()

--==================================================
-- GENERATOR ESP (DARI CODE ASLI)
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
            highlight.Enabled = VDConfig.Generator.ESPEnabled
            textLabel.Visible = VDConfig.Generator.ESPEnabled
            
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
        if VDConfig.Generator.ESPEnabled then
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
-- RAYFIELD UI WINDOW
--==================================================
local Window = Rayfield:CreateWindow({
   Name = "VIOLENCE DISTRICT - ULTIMATE EDITION",
   LoadingTitle = "Loading VIOLENCE DISTRICT...",
   LoadingSubtitle = "by RanZx999 (Enhanced)",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ViolenceDistrict",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

--==================================================
-- MAIN TAB (PLAYER INFO)
--==================================================
local MainTab = Window:CreateTab("🏠 Main", 4483362458)

MainTab:CreateSection("📊 PLAYER INFORMATION")

MainTab:CreateLabel("👤 Name: " .. LocalPlayer.Name)
MainTab:CreateLabel("📝 Display: " .. LocalPlayer.DisplayName)
MainTab:CreateLabel("🆔 User ID: " .. LocalPlayer.UserId)
MainTab:CreateLabel("📅 Account Age: " .. LocalPlayer.AccountAge .. " days")
MainTab:CreateLabel("🎯 Team: " .. (LocalPlayer.Team and LocalPlayer.Team.Name or "No Team"))

MainTab:CreateSection("🌐 SERVER INFORMATION")

local function updateServerInfo()
    local players = #Players:GetPlayers()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
    return "Players: " .. players .. "/" .. (Players.MaxPlayers or "??") .. "\nPing: " .. ping .. "ms"
end

MainTab:CreateLabel(updateServerInfo())

MainTab:CreateSection("⚡ ACTIVE FEATURES")

local ActiveLabel = MainTab:CreateLabel("No active features")

-- Update active features setiap detik
task.spawn(function()
    while true do
        local active = GetActiveFeatures()
        if #active > 0 then
            ActiveLabel:Set(table.concat(active, " • "))
        else
            ActiveLabel:Set("No active features")
        end
        task.wait(1)
    end
end)

--==================================================
-- ESP TAB (NAMES ONLY - NO BOXES)
--==================================================
local ESPTab = Window:CreateTab("👤 Player ESP", 4483362458)

ESPTab:CreateSection("PLAYER NAME ESP (NO BOXES)")

ESPTab:CreateToggle({
   Name = "Enable Name ESP",
   CurrentValue = false,
   Flag = "EnableESP",
   Callback = function(Value)
       VDConfig.ESP.Enabled = Value
       
       if Value then
           for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer then
                   createPlayerESP(player)
               end
           end
           Rayfield:Notify({
               Title = "Name ESP Enabled",
               Content = "White names above heads",
               Duration = 2
           })
       else
           for player, _ in pairs(ESPObjects) do
               removePlayerESP(player)
           end
       end
   end,
})

ESPTab:CreateToggle({
   Name = "Show Distance",
   CurrentValue = false,
   Callback = function(Value) VDConfig.ESP.Distance = Value end,
})

ESPTab:CreateToggle({
   Name = "Team Check (Hide Teammates)",
   CurrentValue = true,
   Callback = function(Value) VDConfig.ESP.TeamCheck = Value end,
})

ESPTab:CreateToggle({
   Name = "Show Teammates (Override)",
   CurrentValue = false,
   Callback = function(Value) VDConfig.ESP.ShowTeammates = Value end,
})

ESPTab:CreateSlider({
   Name = "Max ESP Distance",
   Range = {500, 5000},
   Increment = 100,
   Suffix = "m",
   CurrentValue = 2000,
   Callback = function(Value) VDConfig.ESP.MaxDistance = Value end,
})

ESPTab:CreateLabel("⚪ Names are always WHITE")

--==================================================
-- HIGHLIGHT TAB
--==================================================
local HighlightTab = Window:CreateTab("✨ Highlight", 4483362458)

HighlightTab:CreateSection("CHARACTER HIGHLIGHT")

HighlightTab:CreateToggle({
   Name = "Enable Highlight",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Highlight.Enabled = Value
       
       if Value then
           for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer then
                   createHighlight(player)
               end
           end
           
           Players.PlayerAdded:Connect(function(player)
               if VDConfig.Highlight.Enabled then
                   repeat task.wait() until player.Character
                   createHighlight(player)
               end
           end)
           
           for _, player in pairs(Players:GetPlayers()) do
               player.CharacterAdded:Connect(function()
                   if VDConfig.Highlight.Enabled then
                       task.wait(0.5)
                       createHighlight(player)
                   end
               end)
           end
           
           Rayfield:Notify({
               Title = "Highlight Enabled",
               Content = "Players are now highlighted!",
               Duration = 2
           })
       else
           for player, _ in pairs(Highlights) do
               removeHighlight(player)
           end
       end
   end,
})

HighlightTab:CreateToggle({
   Name = "Show Team Highlight",
   CurrentValue = false,
   Callback = function(Value) VDConfig.Highlight.ShowTeam = Value end,
})

HighlightTab:CreateLabel("⚪ Lobby: All White")
HighlightTab:CreateLabel("🟢 Game: Teammate Green")
HighlightTab:CreateLabel("🔴 Game: Enemy Red")

--==================================================
-- VISUAL TAB (WALLHACK, FULLBRIGHT, NO FOG, INFINITE ZOOM)
--==================================================
local VisualTab = Window:CreateTab("☀️ Visual", 4483362458)

VisualTab:CreateSection("VISUAL ENHANCEMENTS")

VisualTab:CreateToggle({
   Name = "Wallhack (See Through Walls)",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Visual.WallhackEnabled = Value
       updateWallhack()
   end,
})

VisualTab:CreateToggle({
   Name = "Fullbright (Bright Map)",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Visual.FullbrightEnabled = Value
   end,
})

VisualTab:CreateToggle({
   Name = "No Fog",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Visual.NoFogEnabled = Value
   end,
})

VisualTab:CreateToggle({
   Name = "Infinite Zoom Out",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Visual.InfiniteZoom = Value
   end,
})

--==================================================
-- MOVEMENT TAB (SPEED, JUMP, INFINITE JUMP, NOCLIP)
--==================================================
local MovementTab = Window:CreateTab("🏃 Movement", 4483362458)

MovementTab:CreateSection("⚡ SPEED HACK")

MovementTab:CreateToggle({
   Name = "Enable Speed Boost",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Movement.SpeedEnabled = Value
       if not Value then
           local char = LocalPlayer.Character
           if char then
               local hum = char:FindFirstChildOfClass("Humanoid")
               if hum then hum.WalkSpeed = 16 end
           end
       end
   end,
})

MovementTab:CreateSlider({
   Name = "Speed Value",
   Range = {16, 200},
   Increment = 1,
   Suffix = "WS",
   CurrentValue = 16,
   Callback = function(Value) VDConfig.Movement.SpeedValue = Value end,
})

MovementTab:CreateSection("🦘 JUMP HACK")

MovementTab:CreateToggle({
   Name = "Enable Jump Boost",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Movement.JumpEnabled = Value
       if not Value then
           local char = LocalPlayer.Character
           if char then
               local hum = char:FindFirstChildOfClass("Humanoid")
               if hum then hum.JumpPower = 50 end
           end
       end
   end,
})

MovementTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 300},
   Increment = 5,
   Suffix = "JP",
   CurrentValue = 50,
   Callback = function(Value) VDConfig.Movement.JumpValue = Value end,
})

MovementTab:CreateSection("🚀 EXTRA MOVEMENT")

MovementTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(Value) VDConfig.Movement.InfiniteJump = Value end,
})

MovementTab:CreateToggle({
   Name = "Noclip (Walk Through Walls)",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Movement.Noclip = Value
       
       if Value then
           enableNoclip()
           Rayfield:Notify({
               Title = "Noclip Enabled",
               Content = "Walk through walls!",
               Duration = 2
           })
       else
           disableNoclip()
           Rayfield:Notify({
               Title = "Noclip Disabled",
               Content = "Collision restored",
               Duration = 2
           })
       end
   end,
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)

TeleportTab:CreateSection("TELEPORT TO PLAYER")

local SelectedPlayer = ""
local PlayerDropdown

-- Function to refresh dropdown
local function refreshPlayerDropdown()
    local players = getPlayerList()
    if #players > 0 then
        if PlayerDropdown then
            PlayerDropdown:Set(players[1])
        end
        SelectedPlayer = players[1] or ""
    end
end

PlayerDropdown = TeleportTab:CreateDropdown({
   Name = "Select Player",
   Options = getPlayerList(),
   CurrentOption = "Select a player",
   Callback = function(Value)
       SelectedPlayer = Value
   end,
})

TeleportTab:CreateButton({
   Name = "🚀 Teleport to Selected Player",
   Callback = function()
       if SelectedPlayer and SelectedPlayer ~= "" and SelectedPlayer ~= "Select a player" then
           if teleportToPlayer(SelectedPlayer) then
               -- Success
           else
               Rayfield:Notify({
                   Title = "Error",
                   Content = "Failed to teleport",
                   Duration = 2
               })
           end
       else
           Rayfield:Notify({
               Title = "Error",
               Content = "Please select a player first",
               Duration = 2
           })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "🔄 Refresh Player List",
   Callback = function()
       refreshPlayerDropdown()
       Rayfield:Notify({
           Title = "Refreshed",
           Content = "Player list updated",
           Duration = 2
       })
   end,
})

TeleportTab:CreateSection("📍 WAYPOINTS")

TeleportTab:CreateButton({
   Name = "💾 Save Current Position",
   Callback = function()
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           VDConfig.Teleport.SavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
           Rayfield:Notify({
               Title = "Saved",
               Content = "Position saved!",
               Duration = 2
           })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "📂 Load Saved Position",
   Callback = function()
       if VDConfig.Teleport.SavedPosition then
           LocalPlayer.Character.HumanoidRootPart.CFrame = VDConfig.Teleport.SavedPosition
           Rayfield:Notify({
               Title = "Teleported",
               Content = "Returned to saved position",
               Duration = 2
           })
       else
           Rayfield:Notify({
               Title = "Error",
               Content = "No saved position found",
               Duration = 2
           })
       end
   end,
})

--==================================================
-- GENERATOR TAB (DARI CODE ASLI)
--==================================================
local GeneratorTab = Window:CreateTab("⚡ Generator", 4483362458)

GeneratorTab:CreateSection("GENERATOR ESP")

GeneratorTab:CreateToggle({
   Name = "Enable Generator ESP",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Generator.ESPEnabled = Value
       
       if Value then
           Rayfield:Notify({
               Title = "Generator ESP Enabled",
               Content = "Scanning for generators...",
               Duration = 2
           })
       else
           for gen, folder in pairs(GeneratorESP) do
               if folder then pcall(function() folder:Destroy() end) end
           end
           GeneratorESP = {}
       end
   end,
})

GeneratorTab:CreateLabel("🔵 Cyan = In Progress")
GeneratorTab:CreateLabel("🟢 Green = Complete (100%)")

GeneratorTab:CreateSection("ANTI-FAIL GENERATOR")

GeneratorTab:CreateToggle({
   Name = "Enable Anti-Fail Generator",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Generator.AntiFailEnabled = Value
   end,
})

GeneratorTab:CreateLabel("✅ Auto-pass generator skill checks")

--==================================================
-- HEALING TAB
--==================================================
local HealingTab = Window:CreateTab("❤️ Healing", 4483362458)

HealingTab:CreateSection("ANTI-FAIL HEALING")

HealingTab:CreateToggle({
   Name = "Enable Anti-Fail Heal",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Healing.AntiFailEnabled = Value
   end,
})

HealingTab:CreateToggle({
   Name = "Hide Skill Check UI",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.UI.HideSkillCheck = Value
   end,
})

HealingTab:CreateLabel("✅ Auto-pass healing skill checks")
HealingTab:CreateLabel("✅ Clean screen while healing")

--==================================================
-- MISC TAB (ANTI AFK)
--==================================================
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateSection("UTILITY")

MiscTab:CreateToggle({
   Name = "Anti AFK (Prevent Idle Kick)",
   CurrentValue = false,
   Callback = function(Value)
       VDConfig.Misc.AntiAFK = Value
       setupAntiAFK()
   end,
})

MiscTab:CreateSection("SCRIPT INFO")

MiscTab:CreateLabel("Violence District - ULTIMATE Edition")
MiscTab:CreateLabel("Version: 3.0")
MiscTab:CreateLabel("Created by: RanZx999 (Enhanced)")
MiscTab:CreateLabel("Toggle UI: Right CTRL")

MiscTab:CreateButton({
   Name = "Destroy Script",
   Callback = function()
       -- Cleanup ESP
       for player, _ in pairs(ESPObjects) do
           removePlayerESP(player)
       end
       
       -- Cleanup Highlights
       for player, _ in pairs(Highlights) do
           removeHighlight(player)
       end
       
       -- Cleanup Generator ESP
       for gen, folder in pairs(GeneratorESP) do
           if folder then pcall(function() folder:Destroy() end) end
       end
       
       -- Cleanup connections
       if noclipConnection then noclipConnection:Disconnect() end
       if WallhackConnection then WallhackConnection:Disconnect() end
       if antiAFKConnection then antiAFKConnection:Disconnect() end
       
       -- Restore lighting
       Lighting.Brightness = originalLighting.Brightness
       Lighting.ClockTime = originalLighting.ClockTime
       Lighting.FogEnd = originalLighting.FogEnd
       Lighting.FogStart = originalLighting.FogStart
       Lighting.GlobalShadows = originalLighting.GlobalShadows
       Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
       
       Rayfield:Notify({
           Title = "Script Destroyed",
           Content = "VIOLENCE DISTRICT unloaded!",
           Duration = 2
       })
       
       task.wait(1)
       Rayfield:Destroy()
   end,
})

--==================================================
-- SETTINGS TAB (CONFIG)
--==================================================
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateSection("CONFIGURATION")

-- Load configuration
Rayfield:LoadConfiguration()

--==================================================
-- INITIALIZE
--==================================================
print("═══════════════════════════════════════════════════════")
print("🔥 VIOLENCE DISTRICT - ULTIMATE EDITION 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Player Name ESP - White large font (NO BOXES!)")
print("✅ Highlight - Lobby: White | Game: Green/Red")
print("✅ Visual - Wallhack, Fullbright, No Fog, Infinite Zoom")
print("✅ Movement - Speed, Jump, Infinite Jump, Noclip")
print("✅ Teleport - Player TP, Waypoints, Refresh List")
print("✅ Misc - Anti AFK, Active Features Counter")
print("✅ Player Info - Complete stats on Main Tab")
print("═══════════════════════════════════════════════════════")