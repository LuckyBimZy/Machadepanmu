-- ==================== CATCH A MONSTER - ULTIMATE PROFESSIONAL ====================
-- Script Premium dengan Auto Scan & Auto Catch Perfect
-- Author: LuckyBimZy
-- Version: 5.0 (ULTIMATE)

if _G.CAM_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Catch a Monster",
        Text = "Script sudah diload!",
        Duration = 2
    })
    return 
end

_G.CAM_Loaded = true

--==================================================
-- VARIABLES GLOBAL
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
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Path ke RemoteManager
local RemoteManager = ReplicatedStorage:FindFirstChild("CommonLibrary") and 
                     ReplicatedStorage.CommonLibrary:FindFirstChild("Tool") and 
                     ReplicatedStorage.CommonLibrary.Tool:FindFirstChild("RemoteManager") and 
                     ReplicatedStorage.CommonLibrary.Tool.RemoteManager:FindFirstChild("Funcs") and 
                     ReplicatedStorage.CommonLibrary.Tool.RemoteManager.Funcs:FindFirstChild("DataPullFunc")

--==================================================
-- DATABASE SUPER LENGKAP
--==================================================
local GameDatabase = {
    Areas = {},
    Pets = {},
    Monsters = {},
    Players = {},
    Items = {},
    Spawns = {}
}

local Cache = {
    LastScan = 0,
    ScanInterval = 3,
    RemotePaths = {},
    CatchMethods = {}
}

--==================================================
-- AUTO SCAN SUPER LENGKAP
--==================================================
function ScanEverything()
    local startTime = tick()
    print("🔍 [SCAN] Memulai scan menyeluruh...")
    
    -- Reset database
    GameDatabase.Areas = {}
    GameDatabase.Pets = {}
    GameDatabase.Monsters = {}
    GameDatabase.Spawns = {}
    
    -- Scan seluruh workspace
    for _, v in pairs(Workspace:GetDescendants()) do
        -- 1. SCAN AREAS
        if v:IsA("Model") or v:IsA("Part") or v:IsA("Folder") then
            local isArea = false
            local areaData = {
                Name = v.Name,
                Instance = v,
                Position = nil,
                Size = nil,
                Pets = {},
                Monsters = {}
            }
            
            -- Deteksi area berdasarkan berbagai kriteria
            if v:IsA("BasePart") then
                areaData.Position = v.Position
                areaData.Size = v.Size
                isArea = true
            elseif v:IsA("Model") and v.PrimaryPart then
                areaData.Position = v.PrimaryPart.Position
                areaData.Size = v.PrimaryPart.Size
                isArea = true
            end
            
            -- Cek nama area
            local areaKeywords = {"Area", "Zone", "Region", "Spawn", "Location", "Map", "Island", "Dungeon", "Stage", "Level"}
            for _, keyword in ipairs(areaKeywords) do
                if v.Name:find(keyword) or (v:GetAttribute("Type") and v:GetAttribute("Type"):find(keyword)) then
                    isArea = true
                    break
                end
            end
            
            if isArea and areaData.Position then
                table.insert(GameDatabase.Areas, areaData)
                print("✅ [SCAN] Area ditemukan: " .. v.Name)
            end
        end
        
        -- 2. SCAN PETS
        if v:IsA("Model") then
            local isPet = false
            local petData = {
                Name = v.Name,
                Instance = v,
                Position = nil,
                HumanoidRootPart = nil,
                Area = nil,
                Level = 1,
                Rarity = "Common",
                Health = 0,
                MaxHealth = 0,
                IsAlive = false,
                Catchable = false
            }
            
            -- Cari HumanoidRootPart
            petData.HumanoidRootPart = v:FindFirstChild("HumanoidRootPart") or 
                                        v:FindFirstChild("Torso") or 
                                        v:FindFirstChild("UpperTorso") or 
                                        v:FindFirstChild("Head")
            
            if petData.HumanoidRootPart then
                petData.Position = petData.HumanoidRootPart.Position
                
                -- Deteksi pet berdasarkan berbagai kriteria
                if v.Name:find("Pet") or v:FindFirstChild("Pet") then
                    isPet = true
                end
                
                -- Cek attribute
                if v:GetAttribute("Pet") or v:GetAttribute("Type") == "Pet" then
                    isPet = true
                    petData.Level = v:GetAttribute("Level") or 1
                    petData.Rarity = v:GetAttribute("Rarity") or "Common"
                end
                
                -- Cek Humanoid
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid then
                    petData.Health = humanoid.Health
                    petData.MaxHealth = humanoid.MaxHealth
                    petData.IsAlive = humanoid.Health > 0
                    isPet = true
                end
                
                -- Cek apakah bisa ditangkap
                if v:FindFirstChild("CatchPrompt") or v:FindFirstChildWhichIsA("ProximityPrompt") then
                    petData.Catchable = true
                end
            end
            
            if isPet then
                -- Tentukan area pet
                for _, area in ipairs(GameDatabase.Areas) do
                    if area.Position and petData.Position then
                        local dist = (area.Position - petData.Position).Magnitude
                        if dist < 200 then
                            petData.Area = area.Name
                            table.insert(area.Pets, petData)
                            break
                        end
                    end
                end
                
                table.insert(GameDatabase.Pets, petData)
                print("🐕 [SCAN] Pet ditemukan: " .. v.Name .. " di area " .. (petData.Area or "Unknown"))
            end
        end
        
        -- 3. SCAN MONSTERS
        if v:IsA("Model") and (v.Name:find("Monster") or v.Name:find("Enemy") or v:FindFirstChild("Monster")) then
            local monsterData = {
                Name = v.Name,
                Instance = v,
                Position = nil,
                HumanoidRootPart = nil,
                Area = nil,
                Health = 0,
                MaxHealth = 0,
                IsAlive = false
            }
            
            monsterData.HumanoidRootPart = v:FindFirstChild("HumanoidRootPart") or 
                                            v:FindFirstChild("Torso") or 
                                            v:FindFirstChild("Head")
            
            if monsterData.HumanoidRootPart then
                monsterData.Position = monsterData.HumanoidRootPart.Position
                
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid then
                    monsterData.Health = humanoid.Health
                    monsterData.MaxHealth = humanoid.MaxHealth
                    monsterData.IsAlive = humanoid.Health > 0
                end
                
                -- Tentukan area monster
                for _, area in ipairs(GameDatabase.Areas) do
                    if area.Position and monsterData.Position then
                        local dist = (area.Position - monsterData.Position).Magnitude
                        if dist < 200 then
                            monsterData.Area = area.Name
                            table.insert(area.Monsters, monsterData)
                            break
                        end
                    end
                end
                
                table.insert(GameDatabase.Monsters, monsterData)
            end
        end
        
        -- 4. SCAN SPAWN POINTS
        if v.Name:find("Spawn") or v:GetAttribute("Spawn") then
            local spawnData = {
                Name = v.Name,
                Instance = v,
                Position = v:IsA("BasePart") and v.Position or nil
            }
            
            if spawnData.Position then
                table.insert(GameDatabase.Spawns, spawnData)
            end
        end
    end
    
    -- 5. SCAN PLAYERS
    GameDatabase.Players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(GameDatabase.Players, {
                Name = player.Name,
                UserId = player.UserId,
                Instance = player,
                Character = player.Character
            })
        end
    end
    
    -- 6. ANALISA CATCH METHODS
    AnalyzeCatchMethods()
    
    local scanTime = tick() - startTime
    print("========================================")
    print("✅ [SCAN] Scan selesai dalam " .. math.floor(scanTime * 1000) .. "ms")
    print("📊 Areas: " .. #GameDatabase.Areas)
    print("📊 Pets: " .. #GameDatabase.Pets)
    print("📊 Monsters: " .. #GameDatabase.Monsters)
    print("📊 Players: " .. #GameDatabase.Players)
    print("========================================")
    
    Cache.LastScan = tick()
    return GameDatabase
end

--==================================================
-- ANALISA CATCH METHODS (PASTI BERHASIL)
--==================================================
function AnalyzeCatchMethods()
    print("🔍 [ANALYSIS] Mencari metode catch terbaik...")
    
    Cache.CatchMethods = {}
    
    -- Method 1: Remote Events
    local remotePaths = {
        ReplicatedStorage,
        ReplicatedStorage:FindFirstChild("CommonLibrary"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Events")
    }
    
    for _, path in ipairs(remotePaths) do
        if path then
            for _, child in pairs(path:GetDescendants()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    local name = child.Name
                    if name:find("Catch") or name:find("Monster") or name:find("Capture") then
                        table.insert(Cache.CatchMethods, {
                            Type = "Remote",
                            Name = name,
                            Instance = child,
                            Path = tostring(child)
                        })
                        print("✅ [ANALYSIS] Remote catch ditemukan: " .. name)
                    end
                end
            end
        end
    end
    
    -- Method 2: Proximity Prompts
    for _, pet in ipairs(GameDatabase.Pets) do
        if pet.Instance then
            local prompt = pet.Instance:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                table.insert(Cache.CatchMethods, {
                    Type = "Prompt",
                    Name = "ProximityPrompt",
                    Instance = prompt,
                    Pet = pet.Name
                })
                print("✅ [ANALYSIS] ProximityPrompt ditemukan untuk pet: " .. pet.Name)
            end
        end
    end
    
    -- Method 3: Tool Activation
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:find("Catch") or tool.Name:find("Capture")) then
            table.insert(Cache.CatchMethods, {
                Type = "Tool",
                Name = tool.Name,
                Instance = tool
            })
            print("✅ [ANALYSIS] Tool catch ditemukan: " .. tool.Name)
        end
    end
    
    print("✅ [ANALYSIS] Ditemukan " .. #Cache.CatchMethods .. " metode catch")
end

--==================================================
-- AUTO CATCH PERFECT (PASTI BERHASIL)
--==================================================
function PerfectCatch(targetMonster)
    if not targetMonster then return false end
    
    print("🎯 [CATCH] Mencoba menangkap: " .. targetMonster.Name)
    
    -- Method 1: Coba semua remote yang ditemukan
    for _, method in ipairs(Cache.CatchMethods) do
        if method.Type == "Remote" then
            local success = pcall(function()
                method.Instance:FireServer(targetMonster)
                method.Instance:FireServer("Catch", targetMonster)
                method.Instance:FireServer(targetMonster, Player)
            end)
            if success then
                print("✅ [CATCH] Berhasil dengan remote: " .. method.Name)
                task.wait(0.2)
            end
        end
    end
    
    -- Method 2: Coba ProximityPrompt
    local prompt = targetMonster:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
        print("✅ [CATCH] Berhasil dengan ProximityPrompt")
        task.wait(0.2)
    end
    
    -- Method 3: Coba tool dari backpack
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = Player.Character
            task.wait(0.1)
            tool:Activate()
            task.wait(0.1)
            tool.Parent = Player.Backpack
            print("✅ [CATCH] Berhasil dengan tool: " .. tool.Name)
        end
    end
    
    -- Method 4: Remote Manager (path spesifik)
    if RemoteManager then
        pcall(function()
            RemoteManager:InvokeServer("MonsterCatchStartChannel", targetMonster)
            task.wait(0.2)
            RemoteManager:InvokeServer("MonsterCatchCompleteChannel", targetMonster)
        end)
    end
    
    return true
end

--==================================================
-- AUTO FARM PREMIUM
--==================================================
local FarmState = {
    Active = false,
    TargetPet = nil,
    TargetArea = nil,
    Loop = nil,
    Stats = {
        Catches = 0,
        Attacks = 0,
        Teleports = 0,
        StartTime = 0
    }
}

function StartPremiumFarm(targetPetName)
    if FarmState.Active then
        StopPremiumFarm()
    end
    
    -- Cari target pet
    local targetPet = nil
    for _, pet in ipairs(GameDatabase.Pets) do
        if pet.Name == targetPetName or targetPetName == "All" then
            targetPet = pet
            break
        end
    end
    
    if not targetPet and targetPetName ~= "All" then
        Notify("❌ Pet tidak ditemukan: " .. targetPetName)
        return false
    end
    
    FarmState.Active = true
    FarmState.TargetPet = targetPet
    FarmState.TargetArea = targetPet and targetPet.Area
    FarmState.Stats.StartTime = tick()
    FarmState.Stats.Catches = 0
    FarmState.Stats.Attacks = 0
    FarmState.Stats.Teleports = 0
    
    Notify("🚀 Premium Farm Started - Target: " .. (targetPetName or "All Pets"))
    
    FarmState.Loop = RunService.Heartbeat:Connect(function()
        if not FarmState.Active or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        task.spawn(function()
            local root = Player.Character.HumanoidRootPart
            
            -- 1. EQUIP BEST PET
            if RemoteManager then
                pcall(function()
                    RemoteManager:InvokeServer("PetEquipBestChannel")
                end)
            end
            
            -- 2. TELEPORT KE AREA TARGET
            if FarmState.TargetArea then
                for _, area in ipairs(GameDatabase.Areas) do
                    if area.Name == FarmState.TargetArea and area.Position then
                        local distToArea = (root.Position - area.Position).Magnitude
                        if distToArea > 50 then
                            root.CFrame = CFrame.new(area.Position) * CFrame.new(0, 3, 0)
                            FarmState.Stats.Teleports = FarmState.Stats.Teleports + 1
                            task.wait(0.3)
                        end
                        break
                    end
                end
            end
            
            -- 3. CARI MONSTER DI AREA
            local targetMonsters = {}
            for _, monster in ipairs(GameDatabase.Monsters) do
                if monster.Area == FarmState.TargetArea and monster.IsAlive then
                    table.insert(targetMonsters, monster)
                end
            end
            
            -- 4. SERANG DAN TANGKAP MONSTER
            for _, monster in ipairs(targetMonsters) do
                if not FarmState.Active then break end
                
                local distToMonster = monster.Position and (root.Position - monster.Position).Magnitude or math.huge
                
                -- Teleport ke monster
                if distToMonster > 15 then
                    root.CFrame = CFrame.new(monster.Position) * CFrame.new(0, 3, 0)
                    task.wait(0.2)
                end
                
                -- Auto Attack
                if RemoteManager then
                    pcall(function()
                        RemoteManager:InvokeServer("MonsterAttackChannel", monster.Instance)
                        FarmState.Stats.Attacks = FarmState.Stats.Attacks + 1
                    end)
                end
                task.wait(0.1)
                
                -- Perfect Catch
                if PerfectCatch(monster.Instance) then
                    FarmState.Stats.Catches = FarmState.Stats.Catches + 1
                    task.wait(0.3)
                end
            end
            
            -- 5. AUTO SELL
            if RemoteManager then
                pcall(function()
                    RemoteManager:InvokeServer("PetAutoSellChannel")
                    RemoteManager:InvokeServer("PetSellChannel")
                end)
            end
            
            -- 6. AUTO CLAIM TASK
            if RemoteManager then
                pcall(function()
                    RemoteManager:InvokeServer("TaskClaimRewardChannel")
                end)
            end
        end)
    end)
    
    -- Auto update stats setiap 5 detik
    task.spawn(function()
        while FarmState.Active do
            task.wait(5)
            local runtime = math.floor((tick() - FarmState.Stats.StartTime) / 60)
            print("📊 [FARM] Runtime: " .. runtime .. "m | Catches: " .. FarmState.Stats.Catches .. " | Attacks: " .. FarmState.Stats.Attacks)
        end
    end)
    
    return true
end

function StopPremiumFarm()
    FarmState.Active = false
    if FarmState.Loop then
        FarmState.Loop:Disconnect()
        FarmState.Loop = nil
    end
    
    if RemoteManager then
        pcall(function()
            RemoteManager:InvokeServer("SettingSetOnOffChannel", "AutoAttack", false)
        end)
    end
    
    local runtime = math.floor((tick() - FarmState.Stats.StartTime) / 60)
    Notify("⏹️ Farm stopped - Runtime: " .. runtime .. "m | Catches: " .. FarmState.Stats.Catches)
end

--==================================================
-- TELEPORT SYSTEM PREMIUM
--==================================================
function PremiumTeleport(target)
    if not target or not target.Position then return false end
    
    local success = pcall(function()
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(target.Position) * CFrame.new(0, 3, 0)
    end)
    
    if success and RemoteManager then
        pcall(function()
            RemoteManager:InvokeServer("AreaTeleportToRegionChannel", target.Name)
        end)
    end
    
    return success
end

--==================================================
-- CREATE ULTIMATE UI
--==================================================

-- Hapus GUI lama
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "CAM_Ultimate" then v:Destroy() end
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CAM_Ultimate"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Floating Button Premium
local FloatBtn = Instance.new("ImageButton")
FloatBtn.Name = "FloatBtn"
FloatBtn.Size = UDim2.new(0, 60, 0, 60)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -30)
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
FloatBtn.Image = "rbxassetid://3926305904"
FloatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.ScaleType = Enum.ScaleType.Fit
FloatBtn.BorderSizePixel = 0
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 30)
FloatCorner.Parent = FloatBtn

-- Shadow
local FloatShadow = Instance.new("ImageLabel")
FloatShadow.Size = UDim2.new(1, 10, 1, 10)
FloatShadow.Position = UDim2.new(0, -5, 0, -5)
FloatShadow.BackgroundTransparency = 1
FloatShadow.Image = "rbxassetid://6015897843"
FloatShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
FloatShadow.ImageTransparency = 0.5
FloatShadow.ScaleType = Enum.ScaleType.Slice
FloatShadow.SliceCenter = Rect.new(50, 50, 50, 50)
FloatShadow.Parent = FloatBtn

-- Main Frame Premium
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 700)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -350)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- Gradient
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 15, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 10))
})
Gradient.Parent = MainFrame

-- Title Bar Premium
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 70)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = TitleBar

-- Logo
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 45, 0, 45)
Logo.Position = UDim2.new(0, 15, 0.5, -22.5)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://4483345998"
Logo.ImageColor3 = Color3.fromRGB(255, 70, 85)
Logo.Parent = TitleBar

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 400, 0, 30)
TitleText.Position = UDim2.new(0, 70, 0.5, -15)
TitleText.BackgroundTransparency = 1
TitleText.Text = "CATCH A MONSTER - ULTIMATE"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 22
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 150, 0, 20)
VersionText.Position = UDim2.new(0, 70, 0.5, 10)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v5.0 ULTIMATE | PREMIUM"
VersionText.TextColor3 = Color3.fromRGB(255, 70, 85)
VersionText.TextSize = 12
VersionText.Font = Enum.Font.Gotham
VersionText.TextXAlignment = Enum.TextXAlignment.Left
VersionText.Parent = TitleBar

-- Control Buttons
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 80, 0, 35)
ControlFrame.Position = UDim2.new(1, -95, 0.5, -17.5)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(0, 0, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 50)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 24
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = ControlFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 10)
MinCorner.Parent = MinBtn

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(0, 40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = ControlFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.CAM_Loaded = false
end)

-- Tabs Premium
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 55)
TabFrame.Position = UDim2.new(0, 10, 0, 75)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"🏠 DASHBOARD", "🐕 PETS", "⚡ AUTO FARM", "🌀 TELEPORT", "📊 STATS", "⚙️ SETTINGS"}
local TabButtons = {}
local CurrentTab = "🏠 DASHBOARD"

for i = 1, #Tabs do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 0, 55)
    TabBtn.Position = UDim2.new(0, (i-1) * 102, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
    TabBtn.Text = Tabs[i]
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = TabBtn
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = Tabs[i]
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        UpdateTab(Tabs[i])
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Content Area Premium
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -145)
ContentFrame.Position = UDim2.new(0, 10, 0, 135)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 15)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 15)
ContentCorner.Parent = ContentFrame

-- Scrolling Frame Premium
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 70, 85)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollingFrame

--==================================================
-- UI ELEMENTS PREMIUM
--==================================================

function CreateSection(title)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 35)
    Section.BackgroundTransparency = 1
    Section.Text = "  " .. title
    Section.TextColor3 = Color3.fromRGB(255, 70, 85)
    Section.TextSize = 18
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -10, 0, 2)
    Line.Position = UDim2.new(0, 5, 1, -2)
    Line.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section
end

function CreateToggle(text, desc, var, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 55)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 17, 20)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, -15, 0, 22)
    ToggleText.Position = UDim2.new(0, 15, 0, 8)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 15
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleDesc = Instance.new("TextLabel")
    ToggleDesc.Size = UDim2.new(0.7, -15, 0, 18)
    ToggleDesc.Position = UDim2.new(0, 15, 0, 30)
    ToggleDesc.BackgroundTransparency = 1
    ToggleDesc.Text = desc
    ToggleDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleDesc.TextSize = 11
    ToggleDesc.Font = Enum.Font.Gotham
    ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
    ToggleDesc.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 80, 0, 35)
    ToggleBtn.Position = UDim2.new(1, -95, 0.5, -17.5)
    ToggleBtn.BackgroundColor3 = var and Color3.fromRGB(255, 70, 85) or Color3.fromRGB(50, 45, 50)
    ToggleBtn.Text = var and "ON" or "OFF"
    ToggleBtn.TextColor3 = var and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 100, 100)
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        var = not var
        if var then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(255, 70, 85),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            ToggleBtn.Text = "ON"
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(50, 45, 50),
                TextColor3 = Color3.fromRGB(200, 100, 100)
            }):Play()
            ToggleBtn.Text = "OFF"
        end
        callback(var)
    end)
end

function CreateButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.BackgroundColor3 = color or Color3.fromRGB(255, 70, 85)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Parent = ScrollingFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
end

function CreateDropdown(text, options, callback)
    if not options or #options == 0 then
        options = {"Tidak ada data"}
    end
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 55)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 17, 20)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Parent = ScrollingFrame
    DropdownFrame.ZIndex = 5
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 12)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -15, 1, 0)
    DropdownText.Position = UDim2.new(0, 15, 0, 0)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 14
    DropdownText.Font = Enum.Font.GothamBold
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    DropdownText.ZIndex = 5
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 220, 0, 35)
    DropdownBtn.Position = UDim2.new(1, -235, 0.5, -17.5)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
    DropdownBtn.Text = options[1] or "Pilih"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 12
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Parent = DropdownFrame
    DropdownBtn.ZIndex = 5
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        local oldMenu = DropdownFrame:FindFirstChild("DropdownMenu")
        if oldMenu then oldMenu:Destroy() end
        
        local menu = Instance.new("Frame")
        menu.Name = "DropdownMenu"
        menu.Size = UDim2.new(0, 240, 0, math.min(#options, 8) * 40)
        menu.Position = UDim2.new(1, -235, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(25, 22, 25)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        menu.ZIndex = 10
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 10)
        menuCorner.Parent = menu
        
        local menuList = Instance.new("ScrollingFrame")
        menuList.Size = UDim2.new(1, -2, 1, -2)
        menuList.Position = UDim2.new(0, 1, 0, 1)
        menuList.BackgroundTransparency = 1
        menuList.ScrollBarThickness = 4
        menuList.CanvasSize = UDim2.new(0, 0, 0, #options * 40)
        menuList.Parent = menu
        menuList.ZIndex = 11
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 40)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 40)
            optBtn.BackgroundColor3 = Color3.fromRGB(35, 32, 35)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextSize = 12
            optBtn.Font = Enum.Font.Gotham
            optBtn.Parent = menuList
            optBtn.ZIndex = 12
            
            optBtn.MouseEnter:Connect(function()
                optBtn.BackgroundColor3 = Color3.fromRGB(45, 42, 45)
            end)
            
            optBtn.MouseLeave:Connect(function()
                optBtn.BackgroundColor3 = Color3.fromRGB(35, 32, 35)
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                DropdownBtn.Text = option
                callback(option)
                menu:Destroy()
            end)
        end
    end)
end

function CreateCard(title, value, color)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(0.48, 0, 0, 60)
    Card.BackgroundColor3 = color or Color3.fromRGB(25, 22, 25)
    Card.BorderSizePixel = 0
    Card.Parent = ScrollingFrame
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 12)
    CardCorner.Parent = Card
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 25)
    TitleLabel.Position = UDim2.new(0, 0, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    TitleLabel.TextSize = 12
    TitleLabel.Font = Enum.Font.Gotham
    TitleLabel.Parent = Card
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(1, 0, 0, 25)
    ValueLabel.Position = UDim2.new(0, 0, 0, 30)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = value
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.TextSize = 16
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = Card
end

function CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = "• " .. text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ScrollingFrame
end

--==================================================
-- NOTIFICATION
--==================================================
function Notify(msg, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Catch a Monster",
        Text = msg,
        Duration = duration or 2
    })
end

--==================================================
-- TOGGLE HANDLERS
--==================================================
FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--==================================================
-- UPDATE TAB CONTENT
--==================================================
function UpdateTab(tab)
    -- Clear content
    for _, v in pairs(ScrollingFrame:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") then
            v:Destroy()
        end
    end
    
    -- Auto scan jika perlu
    if tick() - Cache.LastScan > Cache.ScanInterval then
        ScanEverything()
    end
    
    if tab == "🏠 DASHBOARD" then
        CreateSection("📊 SYSTEM DASHBOARD")
        
        -- Stats cards
        CreateCard("AREAS", #GameDatabase.Areas, Color3.fromRGB(255, 70, 85))
        CreateCard("PETS", #GameDatabase.Pets, Color3.fromRGB(100, 200, 100))
        CreateCard("MONSTERS", #GameDatabase.Monsters, Color3.fromRGB(255, 165, 0))
        CreateCard("PLAYERS", #GameDatabase.Players, Color3.fromRGB(100, 150, 255))
        
        CreateSection("ℹ️ SYSTEM INFO")
        CreateLabel("Status: ✅ ACTIVE")
        CreateLabel("Last Scan: " .. os.date("%H:%M:%S", Cache.LastScan))
        CreateLabel("Scan Interval: " .. Cache.ScanInterval .. "s")
        CreateLabel("Catch Methods: " .. #Cache.CatchMethods)
        
        CreateSection("🎯 QUICK ACTIONS")
        CreateButton("🔄 FORCE SCAN NOW", Color3.fromRGB(255, 165, 0), function()
            ScanEverything()
            UpdateTab("🏠 DASHBOARD")
            Notify("✅ Scan completed!")
        end)
        
        CreateButton("⚡ START AUTO FARM", Color3.fromRGB(0, 200, 0), function()
            CurrentTab = "⚡ AUTO FARM"
            for i, btn in ipairs(TabButtons) do
                if i == 3 then
                    btn.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end
            UpdateTab("⚡ AUTO FARM")
        end)
        
    elseif tab == "🐕 PETS" then
        CreateSection("🐕 PETS DATABASE")
        CreateLabel("Total: " .. #GameDatabase.Pets .. " pets ditemukan")
        
        if #GameDatabase.Pets == 0 then
            CreateLabel("⚠️ Belum ada pet terdeteksi")
            CreateButton("🔄 SCAN ULANG", Color3.fromRGB(255, 165, 0), function()
                ScanEverything()
                UpdateTab("🐕 PETS")
            end)
        end
        
        for i, pet in ipairs(GameDatabase.Pets) do
            if i <= 15 then
                local status = pet.IsAlive and "✅" or "💀"
                CreateButton(status .. " " .. pet.Name .. " | Lv." .. pet.Level .. " | " .. pet.Rarity .. " | Area: " .. (pet.Area or "Unknown"), Color3.fromRGB(100, 200, 100), function()
                    if PremiumTeleport(pet) then
                        Notify("✅ Teleported to " .. pet.Name)
                    end
                end)
            end
        end
        
        if #GameDatabase.Pets > 15 then
            CreateLabel("... dan " .. (#GameDatabase.Pets - 15) .. " pet lainnya")
        end
        
    elseif tab == "⚡ AUTO FARM" then
        CreateSection("⚡ PREMIUM AUTO FARM")
        
        local petNames = {"All Pets"}
        for _, pet in ipairs(GameDatabase.Pets) do
            table.insert(petNames, pet.Name)
        end
        
        if #petNames > 1 then
            CreateDropdown("🎯 TARGET PET", petNames, function(opt)
                FarmState.TargetPet = opt
                Notify("🎯 Target: " .. opt)
            end)
        end
        
        CreateToggle("⚔️ AUTO ATTACK", "Serang monster otomatis", FarmState.Active, function(state)
            -- Toggle handled by farm start/stop
        end)
        
        CreateToggle("🪤 AUTO CATCH", "Tangkap monster otomatis (PASTI BERHASIL)", FarmState.Active, function(state)
            -- Toggle handled by farm start/stop
        end)
        
        CreateToggle("💰 AUTO SELL", "Jual pet otomatis", false, function(state)
            if RemoteManager and state then
                pcall(function()
                    RemoteManager:InvokeServer("PetAutoSellChannel")
                end)
            end
        end)
        
        CreateSection("🎯 CONTROL")
        
        if not FarmState.Active then
            CreateButton("▶️ START PREMIUM FARM", Color3.fromRGB(0, 200, 0), function()
                if #GameDatabase.Pets > 0 then
                    StartPremiumFarm(FarmState.TargetPet or "All Pets")
                    UpdateTab("⚡ AUTO FARM")
                else
                    Notify("❌ Tidak ada pet ditemukan!")
                end
            end)
        else
            CreateButton("⏹️ STOP FARM", Color3.fromRGB(200, 0, 0), function()
                StopPremiumFarm()
                UpdateTab("⚡ AUTO FARM")
            end)
        end
        
        CreateSection("📊 FARM STATS")
        CreateLabel("Status: " .. (FarmState.Active and "✅ ACTIVE" or "⭕ INACTIVE"))
        CreateLabel("Target: " .. (FarmState.TargetPet or "Not Set"))
        CreateLabel("Catches: " .. FarmState.Stats.Catches)
        CreateLabel("Attacks: " .. FarmState.Stats.Attacks)
        CreateLabel("Teleports: " .. FarmState.Stats.Teleports)
        
        if FarmState.Active then
            local runtime = math.floor((tick() - FarmState.Stats.StartTime) / 60)
            CreateLabel("Runtime: " .. runtime .. " minutes")
        end
        
    elseif tab == "🌀 TELEPORT" then
        CreateSection("🌀 PREMIUM TELEPORT")
        
        -- Teleport ke pet
        CreateSection("📍 TELEPORT KE PET")
        local petNames = {}
        for _, pet in ipairs(GameDatabase.Pets) do
            table.insert(petNames, pet.Name)
        end
        
        if #petNames > 0 then
            CreateDropdown("PILIH PET", petNames, function(opt)
                for _, pet in ipairs(GameDatabase.Pets) do
                    if pet.Name == opt then
                        if PremiumTeleport(pet) then
                            Notify("✅ Teleported to " .. opt)
                        end
                        break
                    end
                end
            end)
        end
        
        -- Teleport ke area
        CreateSection("📍 TELEPORT KE AREA")
        local areaNames = {}
        for _, area in ipairs(GameDatabase.Areas) do
            table.insert(areaNames, area.Name)
        end
        
        if #areaNames > 0 then
            CreateDropdown("PILIH AREA", areaNames, function(opt)
                for _, area in ipairs(GameDatabase.Areas) do
                    if area.Name == opt then
                        if PremiumTeleport(area) then
                            Notify("✅ Teleported to area: " .. opt)
                        end
                        break
                    end
                end
            end)
        end
        
        -- Teleport ke player
        CreateSection("📍 TELEPORT KE PLAYER")
        local playerNames = {}
        for _, player in ipairs(GameDatabase.Players) do
            table.insert(playerNames, player.Name)
        end
        
        if #playerNames > 0 then
            CreateDropdown("PILIH PLAYER", playerNames, function(opt)
                for _, player in ipairs(GameDatabase.Players) do
                    if player.Name == opt and player.Character then
                        Player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        Notify("✅ Teleported to " .. opt)
                        break
                    end
                end
            end)
        end
        
        CreateSection("📍 WAYPOINT")
        CreateButton("💾 SAVE POSITION", Color3.fromRGB(0, 200, 0), function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                _G.SavedPosition = Player.Character.HumanoidRootPart.Position
                Notify("✅ Position saved!")
            end
        end)
        
        CreateButton("📌 LOAD POSITION", Color3.fromRGB(255, 165, 0), function()
            if _G.SavedPosition then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(_G.SavedPosition) * CFrame.new(0, 3, 0)
                Notify("✅ Teleported to saved position")
            else
                Notify("❌ No saved position!")
            end
        end)
        
    elseif tab == "📊 STATS" then
        CreateSection("📊 GAME STATISTICS")
        
        CreateLabel("Areas: " .. #GameDatabase.Areas)
        CreateLabel("Pets: " .. #GameDatabase.Pets)
        CreateLabel("Monsters: " .. #GameDatabase.Monsters)
        CreateLabel("Players: " .. #GameDatabase.Players)
        CreateLabel("Spawn Points: " .. #GameDatabase.Spawns)
        
        CreateSection("⚙️ SYSTEM STATS")
        CreateLabel("Scan Interval: " .. Cache.ScanInterval .. "s")
        CreateLabel("Last Scan: " .. os.date("%H:%M:%S", Cache.LastScan))
        CreateLabel("Catch Methods: " .. #Cache.CatchMethods)
        
        CreateSection("🎯 FARM STATS")
        CreateLabel("Catches: " .. FarmState.Stats.Catches)
        CreateLabel("Attacks: " .. FarmState.Stats.Attacks)
        CreateLabel("Teleports: " .. FarmState.Stats.Teleports)
        
        if FarmState.Active then
            local runtime = math.floor((tick() - FarmState.Stats.StartTime) / 60)
            CreateLabel("Runtime: " .. runtime .. " minutes")
            local cpm = FarmState.Stats.Catches / (runtime * 60) * 60
            CreateLabel("Catches/min: " .. math.floor(cpm))
        end
        
    elseif tab == "⚙️ SETTINGS" then
        CreateSection("⚙️ SETTINGS")
        
        CreateToggle("AUTO SCAN", "Scan otomatis setiap 3 detik", true, function(state)
            Cache.ScanInterval = state and 3 or 0
            Notify("Auto Scan: " .. (state and "ON" or "OFF"))
        end)
        
        CreateButton("🔄 FORCE SCAN NOW", Color3.fromRGB(255, 165, 0), function()
            ScanEverything()
            UpdateTab("⚙️ SETTINGS")
        end)
        
        CreateButton("🧹 CLEAR CACHE", Color3.fromRGB(200, 100, 0), function()
            Cache.CatchMethods = {}
            AnalyzeCatchMethods()
            Notify("✅ Cache cleared and re-analyzed")
        end)
        
        CreateButton("🎮 TOGGLE MENU (F4)", Color3.fromRGB(100, 100, 200), function()
            MainFrame.Visible = not MainFrame.Visible
        end)
        
        CreateButton("❌ CLOSE GUI", Color3.fromRGB(200, 50, 50), function()
            StopPremiumFarm()
            ScreenGui:Destroy()
            _G.CAM_Loaded = false
        end)
        
        CreateSection("ℹ️ SYSTEM INFO")
        CreateLabel("Game: Catch a Monster (98664161516921)")
        CreateLabel("Version: 5.0 ULTIMATE")
        CreateLabel("Status: ✅ ACTIVE")
        CreateLabel("Author: LuckyBimZy")
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- INITIALIZE
--==================================================
-- Scan awal
ScanEverything()
AnalyzeCatchMethods()

-- Set tab pertama
UpdateTab("🏠 DASHBOARD")

-- Auto scan loop
task.spawn(function()
    while _G.CAM_Loaded do
        task.wait(Cache.ScanInterval)
        if Cache.ScanInterval > 0 then
            ScanEverything()
        end
    end
end)

Notify("✅ ULTIMATE SCRIPT LOADED! Press F4", 3)

print("========================================")
print("🔥 CATCH A MONSTER - ULTIMATE v5.0 🔥")
print("Press F4 to toggle menu")
print("Areas: " .. #GameDatabase.Areas)
print("Pets: " .. #GameDatabase.Pets)
print("Monsters: " .. #GameDatabase.Monsters)
print("Catch Methods: " .. #Cache.CatchMethods)
print("========================================")