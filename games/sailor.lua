-- ==================== SAILOR PIECE - CATRAZ HUB EDITION v6.0 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Auto Farm System - Fully Optimized
-- Version: 6.0 ULTIMATE COMPLETE

if _G.SP_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Sailor Piece",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.SP_Loaded = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- SERVICES & VARIABLES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Remote References
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RemoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local CombatSystem = ReplicatedStorage:WaitForChild("CombatSystem")
local AbilitySystem = ReplicatedStorage:WaitForChild("AbilitySystem")

local CombatRemotes = CombatSystem:WaitForChild("Remotes")
local AbilityRemotes = AbilitySystem:WaitForChild("Remotes")

local hitRemote = CombatRemotes:WaitForChild("RequestHit")
local abilityRemote = AbilityRemotes:WaitForChild("RequestAbility")
local questRemote = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")
local hakiRemote = RemoteEvents:WaitForChild("HakiRemote")
local obsHakiRemote = RemoteEvents:WaitForChild("ObservationHakiRemote")
local summonBossRemote = Remotes:WaitForChild("RequestSummonBoss")
local spawnStrongestRemote = Remotes:WaitForChild("RequestSpawnStrongestBoss")
local spawnAnosRemote = Remotes:WaitForChild("RequestSpawnAnosBoss")
local spawnTrueAizenRemote = RemoteEvents:WaitForChild("RequestSpawnTrueAizen")
local spawnRimuruRemote = RemoteEvents:WaitForChild("RequestSpawnRimuru")
local merchantRemotes = Remotes:WaitForChild("MerchantRemotes")
local requestInventory = Remotes:WaitForChild("RequestInventory")
local updateInventory = Remotes:WaitForChild("UpdateInventory")
local craftSlimeRemote = Remotes:WaitForChild("RequestSlimeCraft")
local craftGrailRemote = Remotes:WaitForChild("RequestGrailCraft")
local exchangeItemRemote = Remotes:WaitForChild("ExchangeItem")
local getArtifactData = RemoteFunctions:WaitForChild("GetArtifactData")
local artifactEquip = RemoteEvents:WaitForChild("ArtifactEquip")
local artifactCloseUI = RemoteEvents:WaitForChild("ArtifactCloseUI")
local artifactUnlockSystem = RemoteEvents:WaitForChild("ArtifactUnlockSystem")

--==================================================
-- SAVE ORIGINAL SETTINGS
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

local originalQuality = settings().Rendering.QualityLevel

--==================================================
-- CONFIGURATION
--==================================================
local Config = {
    -- Farm Settings
    LoopFarm = false,
    AutoHit = true,
    AutoStats = true,
    AutoHeal = true,
    AutoReQuest = true,
    AutoTeleport = true,
    
    -- Movement
    MoveMode = "Tween",
    FarmSpeed = 50,
    FarmHeight = 25,
    PlankMode = false,
    TpTime = 0.1,
    
    -- Combat
    AttackCooldown = 0.3,
    SkillCooldown = 0.5,
    NPCAttackThreshold = 5,
    AutoSkills = { Z = false, X = false, C = false, V = false, F = false },
    SkillIds = { Z = 1, X = 2, C = 3, V = 4, F = 5 },
    
    -- Weapon
    AutoEquip = false,
    WeaponMode = "Melee",
    SelectedWeapon_NPC = "None",
    SelectedWeapon_Boss = "None",
    
    -- Target & Entities
    SelectedMob = nil,
    SelectedBoss = nil,
    SelectedSummonBoss = nil,
    SummonDifficulty = "Normal",
    IgnoredEntities = {},
    
    -- Safe Spot
    SafeSpot = false,
    SafeSpotPosition = nil,
    AutoReturn = false,
    AutoLeave = false,
    LowHealthThreshold = 30,
    
    -- Boss Settings
    AutoBossSpawn = false,
    AutoBossFight = false,
    AutoSummonBoss = false,
    BossSelected = {},
    SpecialBosses = {
        TrueAizen = { Auto = false, Diff = "Normal" },
        Sukuna = { Auto = false, Diff = "Normal" },
        Gojo = { Auto = false, Diff = "Normal" },
        Rimuru = { Auto = false, Diff = "Normal" },
        Anos = { Auto = false, Diff = "Normal" },
    },
    
    -- Game Modes
    AutoDungeon = false,
    DungeonType = "Shadow",
    AutoBossRush = false,
    AutoDungeonQuest = false,
    AutoHogyokuQuest = false,
    
    -- Haki & Dark Blade
    AutoHaki = false,
    AutoObsHaki = false,
    AutoBuyDarkBlade = false,
    
    -- Fruit Farm
    FruitFarm = false,
    FruitMinLevel = 11500,
    TargetFruit = "Quake",
    FruitFarmIsland = "Shinjuku",
    FruitFarmPos = CFrame.new(321.706757, -1.539090, -1756.500977),
    
    -- Boss Key & Exchange
    AutoBuyBossKey = false,
    BossKeyBuyInterval = 1800,
    ExchangeIchigo = false,
    IchigoMinLevel = 11500,
    FarmSaberBoss = false,
    
    -- Auto Quest
    AutoQuest = false,
    SelectedQuestNPC = "None",
    
    -- Auto Craft
    AutoCraft = {
        SlimeKey = false,
        DivineGrail = false,
    },
    CraftAmount = 1,
    
    -- Misc
    AntiAFK = true,
    Noclip = false,
    AntiVoid = true,
    WhiteScreen = false,
    FpsBoost = false,
    AutoRejoin = false,
    TimedRejoin = false,
    RejoinDelay = 10,
    FriendOnly = false,
    
    -- Stats Distribution
    StatSword = 50,
    StatDefense = 30,
    StatPower = 20,
}

--==================================================
-- GLOBAL STATE
--==================================================
getgenv().IsFarm = false
getgenv().IsBossFight = false
getgenv().IsSummonBoss = false
getgenv().IsAutoDungeon = false
getgenv().IsBossRush = false
getgenv().IsDungeonQuest = false
getgenv().IsHogyokuQuest = false
getgenv().IsTeleporting = false
getgenv().IsFruitFarming = false
getgenv().IsBuyingDarkBlade = false
getgenv().IslandMobCache = getgenv().IslandMobCache or {}
getgenv().IslandScanDone = false
getgenv().BypassLoaded = true
getgenv().NoclipEnabled = false
getgenv().AntiVoidEnabled = true
getgenv().AntiIdleEnabled = true

-- Entity Tracker
local EntityTracker = {}
local ActiveNPCs = {}
local NPCConnections = {}

-- Inventory
local inventoryByRarity = {
    Secret = {}, Mythical = {}, Legendary = {},
    Epic = {}, Rare = {}, Uncommon = {}, Common = {}
}
local cratesAndBoxes = {}

--==================================================
-- AUTO FARM SYSTEM - VARIABLES
--==================================================
local farmStatus = {
    isRunning = false,
    currentTarget = nil,
    currentQuest = nil,
    lastAttackTime = 0,
    lastSkillTime = 0,
    lastEquipTime = 0,
    lastTeleportTime = 0,
    farmStartTime = 0,
    totalKills = 0,
    totalXP = 0,
}

-- Quest Configuration
local questConfig = nil
pcall(function() 
    questConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("QuestConfig"))
end)

-- Mob Database
local mobDatabase = {}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Sailor Piece",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece",
    Subtext = "Catraz Hub Edition v6.0",
    Version = "v6.0",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece Catraz Hub",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    
    -- Custom Theme & Appearance
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    -- Floating Toggle 
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded successfully!")

--==================================================
-- CREATE TABS
--==================================================
local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local BossTab = Window:MakeTab({
    Name = "Boss",
    Icon = "skull",
    Glass = true,
    Outline = true
})

local SpecialBossTab = Window:MakeTab({
    Name = "Special Boss",
    Icon = "star",
    Glass = true,
    Outline = true
})

local ModeTab = Window:MakeTab({
    Name = "Modes",
    Icon = "gamepad-2",
    Glass = true,
    Outline = true
})

local SkillTab = Window:MakeTab({
    Name = "Skills",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local FruitTab = Window:MakeTab({
    Name = "Fruit",
    Icon = "apple",
    Glass = true,
    Outline = true
})

local CraftTab = Window:MakeTab({
    Name = "Crafting",
    Icon = "hammer",
    Glass = true,
    Outline = true
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    Glass = true,
    Outline = true
})

local InfoTab = Window:MakeTab({
    Name = "Info",
    Icon = "info",
    Glass = true,
    Outline = true
})

--==================================================
-- BYPASS SYSTEM
--==================================================
local function setupBypass()
    local BLOCKED_NAMES = {
        "sanity", "checksanity", "positioncheck", "antiteleport",
        "validateposition", "checkpos", "anticheat", "positionvalidate",
        "sanitycheck", "movementcheck", "speedcheck", "teleportback",
        "checkposition", "poscheck", "verifyposition", "servercheck",
        "validate", "verification", "exploit",
    }

    local blockedLookup = {}
    for _, name in ipairs(BLOCKED_NAMES) do
        blockedLookup[name] = true
    end

    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if (method == "Kick" or method == "kick") then
            if self == Player or self == Players then
                return nil
            end
        end

        if method == "FireServer" or method == "InvokeServer" then
            local ok, isRemote = pcall(function()
                return self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
            end)
            if ok and isRemote then
                local remoteName = self.Name:lower():gsub("_", ""):gsub("-", "")
                if blockedLookup[remoteName] then
                    return nil
                end
            end
        end

        return OldNamecall(self, ...)
    end)

    if getgc and hookfunction then
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" then
                local ok, info = pcall(getinfo, v)
                if ok and info and info.source then
                    local src = info.source:lower()
                    if src:find("anticheat") or src:find("controlclient") or src:find("sanity")
                        or src:find("idle") or src:find("movement") or src:find("speed") then
                        pcall(function()
                            hookfunction(v, function(...) return nil end)
                        end)
                    end
                end
            end
        end
    end

    print("[BYPASS] ✅ Anti-teleport & Anti-kick active")
end

--==================================================
-- NOCLIP SYSTEM
--==================================================
local noclipConnection = nil

local function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not Config.Noclip then return end
        
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
end

--==================================================
-- ANTI-VOID SYSTEM
--==================================================
local lastSafePos = CFrame.new(0, 100, 0)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not Config.AntiVoid then continue end
        
        local char = Player.Character
        if not char then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        if hrp.Position.Y > -50 then
            lastSafePos = hrp.CFrame
        elseif hrp.Position.Y < -50 then
            hrp.CFrame = lastSafePos
        end
    end
end)

--==================================================
-- ANTI-AFK SYSTEM
--==================================================
local antiAFKConnection = nil

local function setupAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    
    if Config.AntiAFK then
        antiAFKConnection = Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

--==================================================
-- AUTO REJOIN SYSTEM
--==================================================
local function setupAutoRejoin()
    local conn = GuiService.ErrorMessageChanged:Connect(function()
        if not Config.AutoRejoin then return end
        
        local lastError = GuiService:GetErrorMessage()
        if lastError:find("ArcX Security") then return end

        task.spawn(function()
            while task.wait(5) do
                if pcall(function() TeleportService:Teleport(game.PlaceId, Player) end) then
                    break
                end
                task.wait(10)
            end
        end)
    end)
end

--==================================================
-- TIMED REJOIN SYSTEM
--==================================================
local timedRejoinRunning = false

local function setupTimedRejoin()
    timedRejoinRunning = false
    task.wait()
    timedRejoinRunning = true

    task.spawn(function()
        local elapsed = 0
        while timedRejoinRunning and task.wait(1) do
            if not Config.TimedRejoin then
                elapsed = 0
                continue
            end

            elapsed += 1
            local target = (Config.RejoinDelay or 10) * 60
            if elapsed > target then elapsed = target end

            if elapsed >= target then
                elapsed = 0
                Notify("Timed rejoin: Rejoining now...")
                task.wait(5)

                for _ = 1, 10 do
                    if pcall(function() TeleportService:Teleport(game.PlaceId, Player) end) then
                        break
                    end
                    task.wait(10)
                end
            end
        end
    end)
end

--==================================================
-- FRIEND ONLY SYSTEM
--==================================================
local function setupFriendOnly()
    local function checkAndKick(pla)
        if not Config.FriendOnly or pla == Player then return end

        local isFriend = false
        local ok, result = pcall(function() return Player:IsFriendsWith(pla.UserId) end)
        if ok then isFriend = result end

        if not isFriend then
            Player:Kick("[Security] Friend-Only Mode: Stranger detected")
        end
    end

    for _, pla in ipairs(Players:GetPlayers()) do
        checkAndKick(pla)
    end

    Players.PlayerAdded:Connect(checkAndKick)
end

--==================================================
-- UTILITY FUNCTIONS
--==================================================
local function getChar()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    return char, hrp, hum
end

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function getWeapons()
    local weapons = {}
    local char = Player.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then table.insert(weapons, v.Name) end
        end
    end
    for _, v in ipairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") then table.insert(weapons, v.Name) end
    end
    return #weapons > 0 and weapons or { "None" }
end

local function getPlayerList()
    local list = {}
    for _, pla in pairs(Players:GetPlayers()) do
        if pla ~= Player then
            table.insert(list, pla.Name)
        end
    end
    return list
end

--==================================================
-- ENTITY TRACKER SYSTEM
--==================================================
local function registerNPC(npc)
    task.spawn(function()
        local humanoid = npc:WaitForChild("Humanoid", 3)
        if not humanoid or humanoid.Health <= 0 then return end

        ActiveNPCs[npc] = true

        local deathConn, removeConn

        deathConn = humanoid.Died:Connect(function()
            ActiveNPCs[npc] = nil
            NPCConnections[npc] = nil
            deathConn:Disconnect()
            removeConn:Disconnect()
        end)

        removeConn = npc.AncestryChanged:Connect(function(_, parent)
            if not parent then
                ActiveNPCs[npc] = nil
                NPCConnections[npc] = nil
                removeConn:Disconnect()
                deathConn:Disconnect()
            end
        end)

        NPCConnections[npc] = { deathConn, removeConn }
    end)
end

local function initEntityTracker()
    local npcFolder = Workspace:WaitForChild("NPCs")
    
    for _, child in ipairs(npcFolder:GetChildren()) do
        registerNPC(child)
    end
    
    npcFolder.ChildAdded:Connect(function(child)
        registerNPC(child)
    end)
end

local function isNPCActive(queryName, isBossType, requiredCount)
    requiredCount = requiredCount or 5
    local currentCount = 0

    for npc in next, ActiveNPCs do
        if not (npc and npc.Parent) then
            ActiveNPCs[npc] = nil
            NPCConnections[npc] = nil
        end
    end

    for npc in next, ActiveNPCs do
        if isBossType then
            if npc.Name:find("^" .. queryName) then
                return true
            end
        else
            if npc.Name:find(queryName) then
                currentCount += 1
                if currentCount >= requiredCount then
                    return true
                end
            end
        end
    end

    return false
end

--==================================================
-- AUTO FARM SYSTEM - CORE FUNCTIONS
--==================================================

-- Build mob database
local function buildMobDatabase()
    table.clear(mobDatabase)
    
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return end
    
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum then
                local level = 0
                local name = npc.Name
                
                local levelMatch = name:match("Lv%.?(%d+)") or name:match("Level (%d+)")
                if levelMatch then
                    level = tonumber(levelMatch) or 0
                end
                
                if questConfig and questConfig.RepeatableQuests then
                    for questName, questData in pairs(questConfig.RepeatableQuests) do
                        if questData.requirements then
                            for _, req in ipairs(questData.requirements) do
                                if req.npcType and name:find(req.npcType) then
                                    level = tonumber(questData.recommendedLevel) or level
                                    break
                                end
                            end
                        end
                    end
                end
                
                mobDatabase[name] = {
                    name = name,
                    level = level,
                    health = hum.MaxHealth,
                    position = npc.HumanoidRootPart.Position,
                }
            end
        end
    end
end

-- Get best quest based on level
local function getBestQuest()
    local playerLevel = 0
    pcall(function() playerLevel = Player.Data.Level.Value or 0 end)
    
    local bestQuest = nil
    local bestNPC = nil
    local bestMob = nil
    local highestLevel = -1
    
    if not questConfig or not questConfig.RepeatableQuests then
        return nil, nil, nil
    end
    
    for npcName, questData in pairs(questConfig.RepeatableQuests) do
        local reqLevel = tonumber(questData.recommendedLevel) or 0
        
        if playerLevel >= reqLevel and reqLevel > highestLevel then
            if questData.requirements and #questData.requirements > 0 then
                local req = questData.requirements[1]
                if req and req.npcType then
                    highestLevel = reqLevel
                    bestQuest = npcName
                    bestNPC = npcName
                    bestMob = req.npcType
                end
            end
        end
    end
    
    return bestQuest, bestNPC, bestMob
end

-- Check quest status
local function checkQuestStatus()
    local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
    if not questUI then return "none" end
    
    local questFrame = questUI:FindFirstChild("Quest")
    if not questFrame or not questFrame.Visible then
        return "none"
    end
    
    local completed = false
    local progress = "0/0"
    
    pcall(function()
        local content = questFrame.Quest.Holder.Content.QuestInfo
        if content then
            local title = content.QuestTitle and content.QuestTitle.QuestTitle and content.QuestTitle.QuestTitle.Text
            if title and title:find("Completed") then
                completed = true
            end
            
            for _, child in pairs(content:GetDescendants()) do
                if child:IsA("TextLabel") then
                    local text = child.Text
                    local cur, tot = text:match("(%d+)/(%d+)")
                    if cur and tot then
                        progress = text
                        if tonumber(cur) >= tonumber(tot) then
                            completed = true
                        end
                        break
                    end
                end
            end
        end
    end)
    
    if completed then
        return "completed"
    else
        return "active"
    end
end

-- Accept quest
local function acceptQuest(questNPC)
    if not questNPC or questNPC == "" then return false end
    
    local success = pcall(function()
        questRemote:FireServer(questNPC)
    end)
    
    if success then
        farmStatus.currentQuest = questNPC
        return true
    end
    return false
end

-- Complete quest
local function completeQuest()
    local questNPC = farmStatus.currentQuest
    if not questNPC then return false end
    
    local npcPos = nil
    pcall(function()
        if questConfig and questConfig.RepeatableQuests and questConfig.RepeatableQuests[questNPC] then
            npcPos = questConfig.RepeatableQuests[questNPC].position
        end
    end)
    
    if npcPos then
        tweenToPosition(CFrame.new(npcPos).Position)
        task.wait(2)
    end
    
    for i = 1, 3 do
        pcall(function()
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(npcPos) * CFrame.new(0, 0, 3)
            end
        end)
        task.wait(0.5)
        VirtualUser:Button1Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(0.1)
        VirtualUser:Button1Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
    end
    
    farmStatus.currentQuest = nil
    return true
end

-- Abandon quest
local function abandonQuest()
    pcall(function() abandonRemote:FireServer("repeatable") end)
    farmStatus.currentQuest = nil
    task.wait(1)
end

-- Find nearest mob
local function findNearestMob(targetMobType)
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end
    
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local playerPos = char.HumanoidRootPart.Position
    local nearestMob = nil
    local nearestDist = math.huge
    
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                -- Check if mob is ignored
                if Config.IgnoredEntities and Config.IgnoredEntities[npc.Name] then
                    continue
                end
                
                local match = false
                if targetMobType then
                    match = (npc.Name == targetMobType) or 
                            string.find(npc.Name, targetMobType) or
                            (hum.DisplayName and string.find(hum.DisplayName, targetMobType))
                else
                    match = true
                end
                
                if match then
                    local dist = (npc.HumanoidRootPart.Position - playerPos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestMob = npc
                    end
                end
            end
        end
    end
    
    return nearestMob, nearestDist
end

-- Check if mobs are nearby
local function hasMobsNearby(range)
    range = range or 50
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return false end
    
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    
    local playerPos = char.HumanoidRootPart.Position
    
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (npc.HumanoidRootPart.Position - playerPos).Magnitude
                if dist <= range then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Auto heal
local function autoHeal()
    if not Config.AutoHeal then return end
    
    local char = Player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if hum.Health < hum.MaxHealth * 0.3 then
        local backpack = Player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:find("Potion") or tool.Name:find("Heal") or tool.Name:find("Medkit")) then
                    local char = Player.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:EquipTool(tool)
                        task.wait(0.3)
                        pcall(function() tool:Activate() end)
                    end
                    break
                end
            end
        end
    end
end

--==================================================
-- TWEEN MOVEMENT SYSTEM
--==================================================
local STEP_SIZE = 50
local STEP_TIME = 0.08
local STEP_DELAY = 0.03
local CLOSE_RANGE = 15

local function microTween(root, targetCF)
    local tw = TweenService:Create(
        root,
        TweenInfo.new(STEP_TIME, Enum.EasingStyle.Linear),
        { CFrame = targetCF }
    )
    tw:Play()
    tw.Completed:Wait()
end

local function tweenToPosition(targetPos, callback)
    local char = Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    local distance = (targetPos - root.Position).Magnitude

    if Config.MoveMode == "Teleport" or distance <= CLOSE_RANGE then
        root.CFrame = CFrame.new(targetPos)
        if callback then callback() end
        return
    end

    getgenv().IsTeleporting = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    local steps = math.ceil(distance / STEP_SIZE)
    local startPos = root.Position

    for i = 1, steps do
        if not Config.LoopFarm and not Config.AutoBossFight and not Config.AutoDungeon then break end
        
        local nextPos
        if i == steps then
            nextPos = targetPos
        else
            local progress = i / steps
            nextPos = startPos:Lerp(targetPos, progress)
        end

        root.Velocity = (nextPos - root.Position).Unit * Config.FarmSpeed
        microTween(root, CFrame.new(nextPos))
        task.wait(STEP_DELAY)
    end

    root.Velocity = Vector3.zero
    getgenv().IsTeleporting = false
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    
    if callback then callback() end
end

local function tweenToMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    
    local offset = Config.PlankMode and Vector3.new(0, Config.FarmHeight, 0) or Vector3.new(0, 0, 5)
    local targetPos = mob.HumanoidRootPart.Position + offset
    tweenToPosition(targetPos)
end

--==================================================
-- WEAPON SYSTEM
--==================================================
local function equipWeapon(isBoss)
    if not Config.AutoEquip then return end

    local weaponName = isBoss and Config.SelectedWeapon_Boss or Config.SelectedWeapon_NPC

    local char = Player.Character
    if not char then return end

    local hum = char:FindFirstChild("Humanoid")
    local backpack = Player:FindFirstChild("Backpack")
    if not hum or hum.Health <= 0 or not backpack then return end

    if weaponName == "None" or weaponName == "" then
        local equippedTool = char:FindFirstChildOfClass("Tool")
        if equippedTool then
            if isBoss then Config.SelectedWeapon_Boss = equippedTool.Name
            else Config.SelectedWeapon_NPC = equippedTool.Name end
            return
        end

        local firstTool = backpack:FindFirstChildOfClass("Tool")
        if not firstTool then return end
        hum:EquipTool(firstTool)

        if isBoss then Config.SelectedWeapon_Boss = firstTool.Name
        else Config.SelectedWeapon_NPC = firstTool.Name end
        return
    end

    if char:FindFirstChild(weaponName) then return end
    local tool = backpack:FindFirstChild(weaponName)
    if tool then hum:EquipTool(tool) end
end

--==================================================
-- COMBAT SYSTEM
--==================================================
local function performAutoAttack(mob, isBoss)
    local now = tick()
    
    if now - farmStatus.lastAttackTime < Config.AttackCooldown then
        return
    end
    
    if Config.AutoEquip and now - farmStatus.lastEquipTime > 1 then
        equipWeapon(isBoss)
        farmStatus.lastEquipTime = now
    end
    
    pcall(function() hitRemote:FireServer() end)
    
    local char = Player.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
    end
    
    farmStatus.lastAttackTime = now
    
    if mob and mob:FindFirstChild("Humanoid") then
        local mobHum = mob.Humanoid
        if mobHum and mobHum.Health <= 0 then
            farmStatus.totalKills = farmStatus.totalKills + 1
            farmStatus.totalXP = farmStatus.totalXP + (mobHum.MaxHealth * 0.1)
        end
    end
end

local function performAutoSkills()
    local now = tick()
    
    if now - farmStatus.lastSkillTime < Config.SkillCooldown then
        return
    end
    
    local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
    for key, slot in pairs(skillMap) do
        if Config.AutoSkills[key] then
            pcall(function() abilityRemote:FireServer(slot) end)
        end
    end
    
    farmStatus.lastSkillTime = now
end

--==================================================
-- AUTO FARM MAIN LOOP
--==================================================
local function autoFarmLoop()
    farmStatus.isRunning = true
    farmStatus.farmStartTime = tick()
    farmStatus.totalKills = 0
    farmStatus.totalXP = 0
    
    Notify("✅ Auto Farm started!")
    
    while farmStatus.isRunning and Config.LoopFarm do
        task.wait(0.2)
        
        local char = Player.Character
        if not char then 
            task.wait(1)
            continue 
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then 
            task.wait(3)
            continue 
        end
        
        -- Auto heal
        autoHeal()
        
        -- Auto Haki
        if Config.AutoHaki then
            pcall(toggleHaki)
        end
        if Config.AutoObsHaki then
            pcall(toggleObsHaki)
        end
        
        -- Auto stats
        if Config.AutoStats then
            pcall(allocateStats)
        end
        
        -- Check quest status
        local questStatus = checkQuestStatus()
        
        -- Get best quest based on level
        local bestQuest, bestQuestNPC, bestMob = getBestQuest()
        
        -- Handle quest system
        if Config.AutoReQuest then
            if questStatus == "none" or questStatus == "completed" then
                if questStatus == "completed" then
                    completeQuest()
                    task.wait(1)
                end
                
                if bestQuest and bestQuestNPC then
                    if farmStatus.currentQuest then
                        abandonQuest()
                        task.wait(1)
                    end
                    
                    local npcPos = nil
                    pcall(function()
                        if questConfig and questConfig.RepeatableQuests and questConfig.RepeatableQuests[bestQuestNPC] then
                            npcPos = questConfig.RepeatableQuests[bestQuestNPC].position
                        end
                    end)
                    
                    if npcPos then
                        tweenToPosition(CFrame.new(npcPos).Position)
                        task.wait(2)
                        
                        if acceptQuest(bestQuestNPC) then
                            farmStatus.currentTarget = bestMob
                            Notify("📋 Quest accepted: " .. bestMob)
                        end
                    end
                end
                task.wait(1)
                continue
            end
        end
        
        -- Auto teleport to island if no mobs
        if Config.AutoTeleport and not hasMobsNearby(100) then
            local targetMob = Config.SelectedMob or bestMob or farmStatus.currentTarget
            if targetMob and getgenv().TeleportToMobIsland then
                getgenv().TeleportToMobIsland(targetMob)
                task.wait(3)
                continue
            end
        end
        
        -- Find mob to kill
        local targetMob = Config.SelectedMob or bestMob or farmStatus.currentTarget
        if not targetMob then
            task.wait(1)
            continue
        end
        
        local mob, dist = findNearestMob(targetMob)
        
        if mob then
            if dist > 7 then
                tweenToMob(mob)
            end
            
            performAutoAttack(mob, false)
            performAutoSkills()
            
            -- Auto return to safe spot if too far
            if Config.AutoReturn and Config.SafeSpotPosition then
                local distFromSafe = (hrp.Position - Config.SafeSpotPosition).Magnitude
                if distFromSafe > 100 then
                    tweenToPosition(Config.SafeSpotPosition)
                    Notify("📍 Returning to safe spot...")
                end
            end
        else
            task.wait(1)
        end
    end
    
    farmStatus.isRunning = false
    Notify("⏸️ Auto Farm stopped!")
end

-- Start auto farm
local function startAutoFarm()
    if farmStatus.isRunning then
        Notify("Auto Farm already running!")
        return
    end
    
    task.spawn(autoFarmLoop)
end

-- Stop auto farm
local function stopAutoFarm()
    farmStatus.isRunning = false
end

--==================================================
-- HAKI SYSTEM
--==================================================
local function checkHakiStatus()
    local hasHaki = false
    local hakiInfo = ""
    pcall(function()
        local statsUI = Player.PlayerGui:FindFirstChild("StatsPanelUI")
        if not statsUI then return end
        for _, desc in pairs(statsUI:GetDescendants()) do
            if desc.Name == "HakiProgressionFrame" and desc.Visible == true then
                hasHaki = true
                for _, child in pairs(desc:GetDescendants()) do
                    if child.Name == "HakiLevel" and child:IsA("TextLabel") then
                        hakiInfo = child.Text
                        break
                    end
                end
                break
            end
        end
    end)
    return hasHaki, hakiInfo
end

local function checkObservationHaki()
    local hasObs = false
    pcall(function()
        local statsUI = Player.PlayerGui:FindFirstChild("StatsPanelUI")
        if statsUI then
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name:find("Observation") and desc:IsA("Frame") and desc.Visible == true then
                    hasObs = true
                    break
                end
            end
        end
    end)
    return hasObs
end

local function toggleHaki()
    pcall(function() hakiRemote:FireServer("Toggle") end)
end

local function toggleObsHaki()
    pcall(function() obsHakiRemote:FireServer("Toggle") end)
end

--==================================================
-- STATS SYSTEM
--==================================================
local function allocateStats()
    local points = 0
    pcall(function() points = Player.Data.StatPoints.Value or 0 end)
    if points <= 0 then return end

    local level = 0
    pcall(function() level = Player.Data.Level.Value or 0 end)

    if level < 3000 then
        local melee, defense = 0, 0
        while points > 0 do
            local m = math.min(2, points)
            if m > 0 then statRemote:FireServer("Melee", m); points = points - m; melee = melee + m end
            task.wait(0.1)
            if points <= 0 then break end
            local d = math.min(1, points)
            if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d end
            task.wait(0.1)
        end
    else
        local sword, defense, power = 0, 0, 0
        while points > 0 do
            local s = math.min(3, points)
            if s > 0 then statRemote:FireServer("Sword", s); points = points - s; sword = sword + s end
            task.wait(0.1)
            if points <= 0 then break end
            local d = math.min(2, points)
            if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d end
            task.wait(0.1)
            if points <= 0 then break end
            local p = math.min(1, points)
            if p > 0 then statRemote:FireServer("Power", p); points = points - p; power = power + p end
            task.wait(0.1)
        end
    end
end

--==================================================
-- SUMMON BOSS SYSTEM
--==================================================
local function summonBoss()
    if Config.AutoSummonBoss and Config.SelectedSummonBoss then
        pcall(function() summonBossRemote:FireServer(Config.SelectedSummonBoss .. "Boss", Config.SummonDifficulty) end)
    end
    task.wait(2)
end

local function summonSpecialBoss(bossName, diff)
    if bossName == "TrueAizen" then
        pcall(function() spawnTrueAizenRemote:FireServer(diff) end)
    elseif bossName == "Sukuna" then
        pcall(function() spawnStrongestRemote:FireServer("StrongestHistory", diff) end)
    elseif bossName == "Gojo" then
        pcall(function() spawnStrongestRemote:FireServer("StrongestToday", diff) end)
    elseif bossName == "Rimuru" then
        pcall(function() spawnRimuruRemote:FireServer(diff) end)
    elseif bossName == "Anos" then
        pcall(function() spawnAnosRemote:FireServer("Anos", diff) end)
    end
end

--==================================================
-- DUNGEON SYSTEM
--==================================================
local function enterDungeon()
    pcall(function()
        local dungeonRemote = RemoteEvents:FindFirstChild("Dungeon") or RemoteEvents:FindFirstChild("DungeonEnter")
        if dungeonRemote then
            dungeonRemote:FireServer("Enter", Config.DungeonType)
        end
    end)
    task.wait(3)
end

local function enterBossRush()
    pcall(function()
        local rushRemote = RemoteEvents:FindFirstChild("BossRush") or RemoteEvents:FindFirstChild("EnterBossRush")
        if rushRemote then
            rushRemote:FireServer("Enter")
        end
    end)
    task.wait(2)
end

--==================================================
-- DARK BLADE SYSTEM
--==================================================
local function findDarkBlade()
    for _, container in pairs({Player.Character, Player.Backpack}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:find("Dark Blade") or tool.Name:find("ดาบสีเข้ม")) then
                    return tool
                end
            end
        end
    end
    return nil
end

local function checkDarkBlade()
    local result = false
    pcall(function()
        updateInventory.OnClientEvent:Connect(function(tab, data)
            for _, item in pairs(data) do
                if item.name and (item.name:find("Dark Blade") or item.name:find("ดาบสีเข้ม")) then
                    result = true
                end
            end
        end)
        requestInventory:FireServer()
    end)
    task.wait(0.5)
    return result
end

local function equipDarkBlade()
    pcall(function() Remotes:WaitForChild("EquipWeapon"):FireServer("Equip", "Dark Blade") end)
    task.wait(1)
    pcall(function() Remotes:WaitForChild("EquipWeapon"):FireServer("Equip", "ดาบสีเข้ม") end)
    task.wait(1)
    return findDarkBlade() ~= nil
end

local function buyDarkBlade()
    if findDarkBlade() then
        Notify("Already have Dark Blade!")
        return true
    end
    if checkDarkBlade() then
        equipDarkBlade()
        return true
    end

    local gem = Player.Data.Gems.Value
    local money = Player.Data.Money.Value

    if gem < 150 or money < 250000 then
        Notify("Not enough resources!")
        return false
    end

    local npcCF = CFrame.new(-132.516449, 13.2661686, -1091.2699)
    local maxAttempts = 20

    while not (checkDarkBlade() or findDarkBlade()) and maxAttempts > 0 do
        maxAttempts = maxAttempts - 1

        pcall(function() RemoteEvents:WaitForChild("ResetStats"):FireServer() end)

        tweenToPosition(npcCF.Position)
        task.wait(2)

        local npc = Workspace.ServiceNPCs and Workspace.ServiceNPCs.DarkBladeNPC
        if npc and npc:FindFirstChild("HumanoidRootPart") then
            local prompt = npc.HumanoidRootPart:FindFirstChild("DarkBladeShopPrompt")
            if prompt then
                fireproximityprompt(prompt)
                task.wait(3)
                equipDarkBlade()
            end
        end
    end

    return findDarkBlade() ~= nil
end

--==================================================
-- FRUIT SYSTEM
--==================================================
local function checkHasFruit(fruitName)
    local char = Player.Character
    local backpack = Player:FindFirstChild("Backpack")
    
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                return true
            end
        end
    end
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                return true
            end
        end
    end
    
    return false
end

local function equipFruit(fruitName)
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:EquipTool(tool)
                    return true
                end
            end
        end
    end
    return false
end

local function buyRandomFruit()
    local npcCF = CFrame.new(400.641937, 2.79983521, 752.175842)
    tweenToPosition(npcCF.Position)
    task.wait(3)

    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = npcCF * CFrame.new(0, 0, -3)
    end
    task.wait(1)

    pcall(function()
        local npc = workspace.ServiceNPCs.GemFruitDealer
        if npc then
            for _, desc in pairs(npc:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    fireproximityprompt(desc)
                    break
                end
            end
        end
    end)
    task.wait(3)
    
    return true
end

local function getAnyFruit()
    local backpack = Player:FindFirstChild("Backpack")
    local char = Player.Character
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                return tool
            end
        end
    end
    
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                return tool
            end
        end
    end
    
    return nil
end

local function eatFruit(fruitTool)
    if not fruitTool then return end
    
    local fruitName = fruitTool.Name
    local char = Player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    local backpack = Player:FindFirstChild("Backpack")

    if humanoid and fruitTool.Parent == backpack then
        humanoid:EquipTool(fruitTool)
        task.wait(0.5)
    end

    pcall(function() fruitTool:Activate() end)
    task.wait(1)

    local confirmUI = Player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then yesButton = yesButton:FindFirstChild("ButtonsHolder") end
        if yesButton then yesButton = yesButton:FindFirstChild("Yes") end
        
        if yesButton then
            for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                connection:Fire()
            end
        end
    else
        pcall(function() RemoteEvents:WaitForChild("FruitAction"):FireServer("eat", fruitName) end)
    end
    
    task.wait(3)
end

--==================================================
-- CRAFTING SYSTEM
--==================================================
local function craftSlimeKey(amount)
    pcall(function()
        local args = { "SlimeKey", amount }
        craftSlimeRemote:InvokeServer(unpack(args))
    end)
end

local function craftDivineGrail(amount)
    pcall(function()
        local args = { "DivineGrail", amount }
        craftGrailRemote:InvokeServer(unpack(args))
    end)
end

--==================================================
-- ICHIGO EXCHANGE SYSTEM
--==================================================
local function checkIchigoRequirements()
    local bossTicketCount = inventoryByRarity["Epic"] and inventoryByRarity["Epic"]["Boss Ticket"] or 0
    
    if bossTicketCount == 0 then
        pcall(function() requestInventory:FireServer() end)
        task.wait(1)
        bossTicketCount = inventoryByRarity["Epic"] and inventoryByRarity["Epic"]["Boss Ticket"] or 0
    end
    
    return bossTicketCount >= 500, bossTicketCount
end

local function exchangeIchigo()
    if checkDarkBlade("Ichigo") then
        Notify("Already have Ichigo!")
        return true
    end

    local hasAll, count = checkIchigoRequirements()
    if not hasAll then
        Notify("Need 500 Boss Tickets! Current: " .. count)
        return false
    end

    pcall(function() exchangeItemRemote:InvokeServer("Ichigo") end)
    task.wait(3)
    
    return true
end

--==================================================
-- BOSS KEY SYSTEM
--==================================================
local function checkBossKeyCount()
    pcall(function() requestInventory:FireServer() end)
    task.wait(1)
    return inventoryByRarity["Epic"] and inventoryByRarity["Epic"]["Boss Key"] or 0
end

local function buyBossKeys(amount)
    local merchantCF = CFrame.new(368.817719, 2.79983521, 783.589844)
    tweenToPosition(merchantCF.Position)
    task.wait(2)

    for i = 1, amount do
        pcall(function() merchantRemotes.PurchaseMerchantItem:InvokeServer("Boss Key", 1) end)
        task.wait(0.5)
    end
end

--==================================================
-- SABER BOSS FARM SYSTEM
--==================================================
local function farmSaberBoss()
    local summonNPCCFrame = CFrame.new(651.810181, -3.67419362, -1021.13123)
    
    while Config.FarmSaberBoss do
        local bossKeyCount = checkBossKeyCount()
        if bossKeyCount < 1 then
            Notify("Not enough Boss Keys!")
            break
        end

        tweenToPosition(summonNPCCFrame.Position)
        task.wait(3)

        pcall(function() summonBossRemote:FireServer("SaberBoss") end)
        task.wait(5)

        local boss = Workspace:FindFirstChild("NPCs") and Workspace.NPCs:FindFirstChild("SaberBoss")
        
        if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") then
            local bossRoot = boss.HumanoidRootPart
            local bossHumanoid = boss.Humanoid
            
            local box = Instance.new("SelectionBox")
            box.Adornee = boss
            box.Color3 = Color3.fromRGB(255, 0, 0)
            box.LineThickness = 0.1
            box.SurfaceTransparency = 0.6
            box.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
            box.Parent = Workspace

            repeat task.wait()
                if not boss or not boss.Parent or not boss:FindFirstChild("HumanoidRootPart") or bossHumanoid.Health <= 0 then
                    break
                end
                
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then break end
                if char.Humanoid.Health <= 0 then break end

                equipWeapon(true)
                tweenToMob(boss)
                performAutoAttack(boss, true)
                performAutoSkills()

            until not boss.Parent or bossHumanoid.Health <= 0 or char.Humanoid.Health <= 0

            box:Destroy()
        end

        task.wait(5)
    end
end

--==================================================
-- ARTIFACTS SYSTEM
--==================================================
local function checkArtifactsUnlocked()
    local unlocked = false
    pcall(function()
        local data = getArtifactData:InvokeServer()
        if data and type(data) == "table" and data.Unlocked == true then
            unlocked = true
        end
    end)
    return unlocked
end

local function unlockArtifacts()
    if checkArtifactsUnlocked() then
        Notify("Artifacts already unlocked!")
        return true
    end

    local npcCFrame = CFrame.new(-440.516388, 1.77979147, -1095.86072)
    tweenToPosition(npcCFrame.Position)
    task.wait(3)

    local npc = Workspace:FindFirstChild("ServiceNPCs") and Workspace.ServiceNPCs:FindFirstChild("ArtifactsUnlocker")
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        local prompt = npc.HumanoidRootPart:FindFirstChild("ArtifactPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(2)
        end
    end

    local confirmUI = Player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then yesButton = yesButton:FindFirstChild("ButtonsHolder") end
        if yesButton then yesButton = yesButton:FindFirstChild("Yes") end
        
        if yesButton then
            for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                connection:Fire()
            end
        end
    else
        pcall(function() artifactUnlockSystem:FireServer() end)
    end

    task.wait(3)
    return checkArtifactsUnlocked()
end

local function equipArtifacts()
    pcall(function() RemoteEvents:WaitForChild("ArtifactUIOpened"):FireServer() end)
    task.wait(2)

    local data = nil
    pcall(function() data = getArtifactData:InvokeServer() end)

    if data and type(data) == "table" then
        local allIds = {}
        local function deepScan(tbl)
            for k, v in pairs(tbl) do
                if type(v) == "table" then
                    deepScan(v)
                elseif type(v) == "string" and v:match("%x%x%x%x%x%x%x%x%-%x%x%x%x") then
                    table.insert(allIds, v)
                end
            end
        end
        deepScan(data)

        for _, uuid in ipairs(allIds) do
            pcall(function() artifactEquip:FireServer(uuid) end)
            task.wait(0.5)
        end
    end

    task.wait(1)
    pcall(function() artifactCloseUI:FireServer() end)
    
    local artifactsUI = Player.PlayerGui:FindFirstChild("ArtifactsUI")
    if artifactsUI then
        artifactsUI.Enabled = false
    end
end

--==================================================
-- OBSERVATION HAKI BUY SYSTEM
--==================================================
local function buyObservationHaki()
    if checkObservationHaki() then
        Notify("Already have Observation Haki!")
        return true
    end

    local npcCFrame = CFrame.new(-713.182922, 12.1339779, -527.289795)
    tweenToPosition(npcCFrame.Position)
    task.wait(3)

    local npc = Workspace:FindFirstChild("ServiceNPCs") and Workspace.ServiceNPCs:FindFirstChild("ObservationBuyer")
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        local prompt = npc.HumanoidRootPart:FindFirstChild("ObservationHakiPrompt")
        if prompt then
            fireproximityprompt(prompt)
            task.wait(2)
        end
    end

    local confirmUI = Player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then yesButton = yesButton:FindFirstChild("ButtonsHolder") end
        if yesButton then yesButton = yesButton:FindFirstChild("Yes") end
        
        if yesButton then
            for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                connection:Fire()
            end
        end
    end

    task.wait(3)
    return true
end

--==================================================
-- ISLAND SCANNER SYSTEM
--==================================================
local function getAllIslands()
    local islands = {}
    
    local ok, travelConfig = pcall(function()
        return require(ReplicatedStorage:WaitForChild("TravelConfig", 5))
    end)
    
    if ok and travelConfig then
        local data = travelConfig.Islands or travelConfig.Zones
        if data then
            for name, _ in pairs(data) do
                local portalArg = name:gsub("Island", ""):gsub(" ", "")
                table.insert(islands, { name = name, portal = portalArg })
            end
        end
    end
    
    if #islands == 0 then
        local hardcoded = {
            "Starter", "Jungle", "Desert", "Snow", "Boss",
            "ShibuyaStation", "Sailor", "HuecoMundo", "Dungeon",
            "Shinjuku", "Slime", "Academy", "SoulSociety", "Judgement"
        }
        for _, name in ipairs(hardcoded) do
            table.insert(islands, { name = name .. "Island", portal = name })
        end
    end
    
    return islands
end

local function scanCurrentIslandNPCs(islandName)
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return 0 end
    
    local found = 0
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") then
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hrp and hum and not getgenv().IslandMobCache[npc.Name] then
                getgenv().IslandMobCache[npc.Name] = {
                    island = islandName,
                    position = hrp.Position,
                    maxHealth = hum.MaxHealth,
                }
                found = found + 1
            end
        end
    end
    
    return found
end

getgenv().TeleportToMobIsland = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    if not cached then return false end
    
    local portalArg = cached.island:gsub("Island", ""):gsub(" ", "")
    pcall(function() tpRemote:FireServer(portalArg) end)
    task.wait(3)
    return true
end

getgenv().GetIslandForMob = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    return cached and cached.island or nil
end

getgenv().ScanAllIslands = function()
    local islands = getAllIslands()
    
    for i, island in ipairs(islands) do
        pcall(function() tpRemote:FireServer(island.portal) end)
        task.wait(4)
        scanCurrentIslandNPCs(island.name)
        task.wait(1)
    end
    
    getgenv().IslandScanDone = true
    Notify("Island scan completed!")
end

--==================================================
-- INVENTORY TRACKER
--==================================================
task.spawn(function()
    local ItemRarityConfig = require(ReplicatedStorage.Modules.ItemRarityConfig)

    updateInventory.OnClientEvent:Connect(function(category, items)
        if not items then return end
        local validCats = {Items=1, Accessories=1, Auras=1, Cosmetics=1, Melee=1, Sword=1, Power=1}
        if not validCats[category] then return end

        for _, item in pairs(items) do
            local name = item.name
            local qty = item.quantity or 1
            if not name then continue end

            if name:lower():find("crate") or name:lower():find("box") or name:lower():find("chest") then
                cratesAndBoxes[name] = qty
            end

            local ok, rarity = pcall(function() return ItemRarityConfig:GetRarity(name) end)
            if ok and rarity and inventoryByRarity[rarity] then
                inventoryByRarity[rarity][name] = qty
            end
        end
    end)

    task.wait(3)
    pcall(function() requestInventory:FireServer() end)
end)

--==================================================
-- FPS BOOST
--==================================================
local function setFpsBoost(state)
    if state then
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 1
            end
        end
    else
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

--==================================================
-- WHITE SCREEN
--==================================================
local function setWhiteScreen(state)
    RunService:Set3dRenderingEnabled(not state)
end

--==================================================
-- SKILL SPAM LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(Config.SkillCooldown)
        if Config.LoopFarm or Config.AutoBossFight or Config.AutoDungeon or Config.AutoBossRush then
            local char = Player.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
                for key, slot in pairs(skillMap) do
                    if Config.AutoSkills[key] then
                        pcall(function() abilityRemote:FireServer(slot) end)
                    end
                end
            end
        end
    end
end)

--==================================================
-- AUTO STATS LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(5)
        if Config.AutoStats then
            pcall(allocateStats)
        end
    end
end)

--==================================================
-- AUTO HAKI LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(3)
        if Config.AutoHaki then
            pcall(toggleHaki)
        end
        if Config.AutoObsHaki then
            pcall(toggleObsHaki)
        end
    end
end)

--==================================================
-- AUTO CRAFT LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(5)
        if Config.AutoCraft.SlimeKey then
            craftSlimeKey(Config.CraftAmount)
        end
        if Config.AutoCraft.DivineGrail then
            craftDivineGrail(Config.CraftAmount)
        end
    end
end)

--==================================================
-- AUTO BOSS KEY BUY LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(Config.BossKeyBuyInterval)
        if Config.AutoBuyBossKey then
            local count = checkBossKeyCount()
            if count < 10 then
                buyBossKeys(5)
            end
        end
    end
end)

--==================================================
-- SPECIAL BOSS SPAWN LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        
        local specs = Config.SpecialBosses
        if specs.TrueAizen.Auto and not isNPCActive("TrueAizen", true) then
            summonSpecialBoss("TrueAizen", specs.TrueAizen.Diff)
        end
        if specs.Sukuna.Auto and not isNPCActive("StrongestinHistory", true) then
            summonSpecialBoss("Sukuna", specs.Sukuna.Diff)
        end
        if specs.Gojo.Auto and not isNPCActive("StrongestofToday", true) then
            summonSpecialBoss("Gojo", specs.Gojo.Diff)
        end
        if specs.Rimuru.Auto and not isNPCActive("Rimuru", true) then
            summonSpecialBoss("Rimuru", specs.Rimuru.Diff)
        end
        if specs.Anos.Auto and not isNPCActive("Anos", true) then
            summonSpecialBoss("Anos", specs.Anos.Diff)
        end
    end
end)

--==================================================
-- AUTO LEAVE WHEN LOW HEALTH
--==================================================
task.spawn(function()
    while true do
        task.wait(1)
        if Config.AutoLeave and farmStatus.isRunning then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local healthPercent = (hum.Health / hum.MaxHealth) * 100
                    if healthPercent <= (Config.LowHealthThreshold or 30) then
                        Notify("Low health! Returning to safe spot...")
                        farmStatus.isRunning = false
                        if Config.SafeSpotPosition then
                            tweenToPosition(Config.SafeSpotPosition)
                        end
                        task.wait(5)
                        farmStatus.isRunning = true
                    end
                end
            end
        end
    end
end)

--==================================================
-- AUTO RETURN TO SAFE SPOT
--==================================================
task.spawn(function()
    while true do
        task.wait(5)
        if Config.AutoReturn and Config.SafeSpotPosition and farmStatus.isRunning then
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - Config.SafeSpotPosition).Magnitude
                if dist > 100 then
                    tweenToPosition(Config.SafeSpotPosition)
                    Notify("Returning to safe spot...")
                end
            end
        end
    end
end)

--==================================================
-- FARM TAB UI
--==================================================
local FarmMainSection = FarmTab:AddSection({
    Name = "⚔️ AUTO FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmMainSection:AddToggle({
    Name = "ENABLE AUTO FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "LoopFarm",
    Save = true,
    Callback = function(Value)
        Config.LoopFarm = Value
        getgenv().IsFarm = Value
        
        if Value then
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end
})

FarmMainSection:AddToggle({
    Name = "AUTO HIT",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHit",
    Save = true,
    Callback = function(Value) Config.AutoHit = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO STATS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoStats",
    Save = true,
    Callback = function(Value) Config.AutoStats = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO HEAL",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHeal",
    Save = true,
    Callback = function(Value) Config.AutoHeal = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO RE-QUEST",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoReQuest",
    Save = true,
    Callback = function(Value) Config.AutoReQuest = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO TELEPORT TO ISLAND",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoTeleport",
    Save = true,
    Callback = function(Value) Config.AutoTeleport = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO EQUIP WEAPON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoEquip",
    Save = true,
    Callback = function(Value) Config.AutoEquip = Value end
})

FarmMainSection:AddToggle({
    Name = "PLANK MODE (HOVER)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(Value) Config.PlankMode = Value end
})

FarmMainSection:AddDropdown({
    Name = "MOVE MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value) Config.MoveMode = Value end
})

FarmMainSection:AddSlider({
    Name = "FARM HEIGHT",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Callback = function(Value) Config.FarmHeight = Value end
})

FarmMainSection:AddSlider({
    Name = "FARM SPEED",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    ValueName = "speed",
    Outline = true,
    Callback = function(Value) Config.FarmSpeed = Value end
})

FarmMainSection:AddSlider({
    Name = "ATTACK COOLDOWN",
    Min = 0.1,
    Max = 1.0,
    Default = 0.3,
    Increment = 0.05,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value) Config.AttackCooldown = Value end
})

FarmMainSection:AddSlider({
    Name = "NPC ATTACK THRESHOLD",
    Min = 1,
    Max = 10,
    Default = 5,
    Increment = 1,
    ValueName = "npcs",
    Outline = true,
    Callback = function(Value) Config.NPCAttackThreshold = Value end
})

FarmMainSection:AddSlider({
    Name = "TELEPORT DELAY",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Increment = 0.05,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value) Config.TpTime = Value end
})

-- Farm Stats
local FarmStatsPara = FarmTab:AddSection({
    Name = "📊 FARM STATS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local FarmStatsText = FarmStatsPara:AddParagraph({
    Title = "Current Session",
    Desc = "Kills: 0\nXP: 0\nRuntime: 00:00:00",
    Image = "bar-chart-2",
    ImageSize = 38
})

-- Update farm stats
task.spawn(function()
    while true do
        task.wait(1)
        if farmStatus.isRunning then
            local runtime = tick() - farmStatus.farmStartTime
            local hours = math.floor(runtime / 3600)
            local minutes = math.floor((runtime % 3600) / 60)
            local seconds = math.floor(runtime % 60)
            local runtimeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            
            FarmStatsText:SetDesc(string.format(
                "Kills: %d\nXP: %s\nRuntime: %s",
                farmStatus.totalKills,
                formatNumber(farmStatus.totalXP),
                runtimeStr
            ))
        end
    end
end)

-- Weapon Selection
FarmMainSection:AddSection({
    Name = "🎯 WEAPON SELECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmMainSection:AddDropdown({
    Name = "WEAPON FOR NPCS",
    Default = "None",
    Options = getWeapons(),
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.SelectedWeapon_NPC = Value end
})

FarmMainSection:AddDropdown({
    Name = "WEAPON FOR BOSSES",
    Default = "None",
    Options = getWeapons(),
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.SelectedWeapon_Boss = Value end
})

FarmMainSection:AddButton({
    Name = "REFRESH WEAPON LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local weapons = getWeapons()
        Notify("Weapon list refreshed!")
    end
})

-- Target Selection
FarmMainSection:AddSection({
    Name = "🎯 TARGET SELECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmMainSection:AddDropdown({
    Name = "SELECT SPECIFIC MOB",
    Default = "Auto (Quest Based)",
    Options = {"Auto (Quest Based)", "Thief", "Bandit", "Pirate", "Marine", "Swordsman", "Shinigami", "Hollow"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        if Value == "Auto (Quest Based)" then
            Config.SelectedMob = nil
        else
            Config.SelectedMob = Value
        end
    end
})

FarmMainSection:AddButton({
    Name = "REFRESH MOB LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildMobDatabase()
        Notify("Mob database refreshed!")
    end
})

-- Safe Spot
FarmMainSection:AddSection({
    Name = "🛡️ SAFE SPOT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmMainSection:AddToggle({
    Name = "ENABLE SAFE SPOT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SafeSpot",
    Save = true,
    Callback = function(Value) Config.SafeSpot = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO RETURN TO SAFE SPOT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoReturn",
    Save = true,
    Callback = function(Value) Config.AutoReturn = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO LEAVE WHEN LOW HEALTH",
    Default = false,
    Color = Color3.fromRGB(255, 0, 0),
    Outline = true,
    Flag = "AutoLeave",
    Save = true,
    Callback = function(Value) Config.AutoLeave = Value end
})

FarmMainSection:AddSlider({
    Name = "LOW HEALTH THRESHOLD",
    Min = 10,
    Max = 50,
    Default = 30,
    Increment = 5,
    ValueName = "%",
    Outline = true,
    Callback = function(Value) Config.LowHealthThreshold = Value end
})

FarmMainSection:AddButton({
    Name = "SET CURRENT AS SAFE SPOT",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            Config.SafeSpotPosition = char.HumanoidRootPart.Position
            Notify("Safe spot set!")
        end
    end
})

FarmMainSection:AddButton({
    Name = "TELEPORT TO SAFE SPOT",
    Icon = "navigation",
    Outline = true,
    Callback = function()
        if Config.SafeSpotPosition then
            tweenToPosition(Config.SafeSpotPosition)
        else
            Notify("No safe spot set!")
        end
    end
})

-- Ignore Mobs
FarmMainSection:AddSection({
    Name = "🚫 IGNORE MOBS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local ignoreMobsList = {"Slime", "Bat", "Spider", "Zombie", "Skeleton", "Ghost"}

for _, mobName in ipairs(ignoreMobsList) do
    FarmMainSection:AddToggle({
        Name = "IGNORE " .. mobName,
        Default = false,
        Color = Color3.fromRGB(255, 0, 0),
        Outline = true,
        Flag = "Ignore_" .. mobName,
        Save = true,
        Callback = function(Value)
            if not Config.IgnoredEntities then Config.IgnoredEntities = {} end
            Config.IgnoredEntities[mobName] = Value
        end
    })
end

--==================================================
-- BOSS TAB UI
--==================================================
local BossMainSection = BossTab:AddSection({
    Name = "🐉 BOSS FIGHT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "AUTO BOSS FIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBoss",
    Save = true,
    Callback = function(Value)
        Config.AutoBossFight = Value
        getgenv().IsBossFight = Value
        Notify(Value and "Auto Boss Enabled" or "Auto Boss Disabled")
    end
})

BossMainSection:AddDropdown({
    Name = "SELECT BOSS",
    Default = "Boss1",
    Options = {"Boss1", "Boss2", "Boss3", "WorldBoss", "SaberBoss", "Ichigo"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.SelectedBoss = Value end
})

BossMainSection:AddSection({
    Name = "🔮 SUMMON BOSS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "AUTO SUMMON BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoSummon",
    Save = true,
    Callback = function(Value)
        Config.AutoSummonBoss = Value
        getgenv().IsSummonBoss = Value
    end
})

BossMainSection:AddToggle({
    Name = "AUTO BOSS SPAWN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBossSpawn",
    Save = true,
    Callback = function(Value) Config.AutoBossSpawn = Value end
})

BossMainSection:AddDropdown({
    Name = "SUMMON BOSS",
    Default = "Boss1",
    Options = {"Boss1", "Boss2", "Boss3", "SaberBoss"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.SelectedSummonBoss = Value end
})

BossMainSection:AddDropdown({
    Name = "DIFFICULTY",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Nightmare"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value) Config.SummonDifficulty = Value end
})

BossMainSection:AddDropdown({
    Name = "SELECT BOSSES (MULTI)",
    Default = {},
    Options = {"Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden", "SaberAlter"},
    Multi = true,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.BossSelected = Value end
})

--==================================================
-- SPECIAL BOSS TAB UI
--==================================================
local SpecialBossSection = SpecialBossTab:AddSection({
    Name = "🌟 SPECIAL BOSSES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local difficultyLevels = { "Normal", "Medium", "Hard", "Extreme" }

for bossName, bossData in pairs(Config.SpecialBosses) do
    SpecialBossSection:AddToggle({
        Name = "AUTO SPAWN " .. bossName,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Special_" .. bossName,
        Save = true,
        Callback = function(Value) Config.SpecialBosses[bossName].Auto = Value end
    })

    SpecialBossSection:AddDropdown({
        Name = bossName .. " DIFFICULTY",
        Default = "Normal",
        Options = difficultyLevels,
        Multi = false,
        Search = false,
        Outline = true,
        Callback = function(Value) Config.SpecialBosses[bossName].Diff = Value end
    })
end

--==================================================
-- MODES TAB UI
--==================================================
local ModeMainSection = ModeTab:AddSection({
    Name = "🏰 DUNGEONS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        Config.AutoDungeon = Value
        getgenv().IsAutoDungeon = Value
    end
})

ModeMainSection:AddDropdown({
    Name = "DUNGEON TYPE",
    Default = "Shadow",
    Options = {"Shadow", "Rune", "Cid"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value) Config.DungeonType = Value end
})

ModeMainSection:AddToggle({
    Name = "AUTO BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBossRush",
    Save = true,
    Callback = function(Value)
        Config.AutoBossRush = Value
        getgenv().IsBossRush = Value
    end
})

ModeMainSection:AddSection({
    Name = "🔮 QUEST CHAINS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "DUNGEON QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(Value)
        Config.AutoDungeonQuest = Value
        getgenv().IsDungeonQuest = Value
    end
})

ModeMainSection:AddToggle({
    Name = "HOGYOKU QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(Value)
        Config.AutoHogyokuQuest = Value
        getgenv().IsHogyokuQuest = Value
    end
})

ModeMainSection:AddToggle({
    Name = "AUTO QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoQuest",
    Save = true,
    Callback = function(Value) Config.AutoQuest = Value end
})

--==================================================
-- SKILLS TAB UI
--==================================================
local SkillMainSection = SkillTab:AddSection({
    Name = "🔮 AUTO SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

for _, key in ipairs({"Z", "X", "C", "V", "F"}) do
    SkillMainSection:AddToggle({
        Name = "SKILL " .. key,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Skill" .. key,
        Save = true,
        Callback = function(Value) Config.AutoSkills[key] = Value end
    })
end

SkillMainSection:AddSlider({
    Name = "SKILL COOLDOWN",
    Min = 0.1,
    Max = 3.0,
    Default = 0.5,
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value) Config.SkillCooldown = Value end
})

SkillMainSection:AddSection({
    Name = "⬛ HAKI",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SkillMainSection:AddToggle({
    Name = "AUTO ARMAMENT HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(Value) Config.AutoHaki = Value end
})

SkillMainSection:AddToggle({
    Name = "AUTO OBSERVATION HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoObsHaki",
    Save = true,
    Callback = function(Value) Config.AutoObsHaki = Value end
})

--==================================================
-- FRUIT TAB UI
--==================================================
local FruitMainSection = FruitTab:AddSection({
    Name = "🍎 FRUIT FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FruitMainSection:AddToggle({
    Name = "ENABLE FRUIT FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FruitFarm",
    Save = true,
    Callback = function(Value)
        Config.FruitFarm = Value
        getgenv().IsFruitFarming = Value
    end
})

FruitMainSection:AddSlider({
    Name = "MIN LEVEL",
    Min = 1000,
    Max = 15000,
    Default = 11500,
    Increment = 100,
    ValueName = "lvl",
    Outline = true,
    Callback = function(Value) Config.FruitMinLevel = Value end
})

FruitMainSection:AddDropdown({
    Name = "TARGET FRUIT",
    Default = "Quake",
    Options = {"Quake", "Flame", "Ice", "Gravity", "Light", "Dark", "String", "Rumble"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.TargetFruit = Value end
})

FruitMainSection:AddDropdown({
    Name = "FARM ISLAND",
    Default = "Shinjuku",
    Options = {"Starter", "Jungle", "Desert", "Snow", "Boss", "Shinjuku", "Slime", "Academy"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.FruitFarmIsland = Value end
})

FruitMainSection:AddButton({
    Name = "BUY DARK BLADE",
    Icon = "sword",
    Outline = true,
    Callback = function()
        getgenv().IsBuyingDarkBlade = true
        buyDarkBlade()
        getgenv().IsBuyingDarkBlade = false
    end
})

FruitMainSection:AddButton({
    Name = "CHECK DARK BLADE",
    Icon = "search",
    Outline = true,
    Callback = function()
        if findDarkBlade() then
            Notify("Dark Blade found in equipment!")
        elseif checkDarkBlade() then
            Notify("Dark Blade found in inventory!")
        else
            Notify("Dark Blade not found!")
        end
    end
})

--==================================================
-- CRAFTING TAB UI
--==================================================
local CraftMainSection = CraftTab:AddSection({
    Name = "🔨 CRAFTING",
    TextSize = 18,
    Glass = true,
    Outline = true
})

CraftMainSection:AddInput({
    Name = "CRAFT AMOUNT",
    Default = "1",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            Config.CraftAmount = num
        end
    end
})

CraftMainSection:AddToggle({
    Name = "AUTO CRAFT SLIME KEY",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoSlimeKey",
    Save = true,
    Callback = function(Value) Config.AutoCraft.SlimeKey = Value end
})

CraftMainSection:AddToggle({
    Name = "AUTO CRAFT DIVINE GRAIL",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoGrail",
    Save = true,
    Callback = function(Value) Config.AutoCraft.DivineGrail = Value end
})

CraftMainSection:AddButton({
    Name = "CRAFT SLIME KEY NOW",
    Icon = "hammer",
    Outline = true,
    Callback = function()
        craftSlimeKey(Config.CraftAmount)
        Notify("Crafting " .. Config.CraftAmount .. " Slime Key(s)")
    end
})

CraftMainSection:AddButton({
    Name = "CRAFT DIVINE GRAIL NOW",
    Icon = "hammer",
    Outline = true,
    Callback = function()
        craftDivineGrail(Config.CraftAmount)
        Notify("Crafting " .. Config.CraftAmount .. " Divine Grail(s)")
    end
})

--==================================================
-- MISC TAB UI
--==================================================
local MiscMainSection = MiscTab:AddSection({
    Name = "⚙️ UTILITY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddToggle({
    Name = "ANTI AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.AntiAFK = Value
        setupAntiAFK()
    end
})

MiscMainSection:AddToggle({
    Name = "NOCLIP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Noclip = Value
        getgenv().NoclipEnabled = Value
        if Value then
            enableNoclip()
        else
            disableNoclip()
        end
    end
})

MiscMainSection:AddToggle({
    Name = "ANTI VOID",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiVoid",
    Save = true,
    Callback = function(Value)
        Config.AntiVoid = Value
        getgenv().AntiVoidEnabled = Value
    end
})

MiscMainSection:AddToggle({
    Name = "FPS BOOST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        Config.FpsBoost = Value
        setFpsBoost(Value)
    end
})

MiscMainSection:AddToggle({
    Name = "WHITE SCREEN MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "WhiteScreen",
    Save = true,
    Callback = function(Value)
        Config.WhiteScreen = Value
        setWhiteScreen(Value)
    end
})

MiscMainSection:AddToggle({
    Name = "AUTO REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value) Config.AutoRejoin = Value end
})

MiscMainSection:AddToggle({
    Name = "TIMED REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "TimedRejoin",
    Save = true,
    Callback = function(Value) Config.TimedRejoin = Value end
})

MiscMainSection:AddSlider({
    Name = "REJOIN DELAY (minutes)",
    Min = 1,
    Max = 120,
    Default = 10,
    Increment = 1,
    ValueName = "min",
    Outline = true,
    Callback = function(Value) Config.RejoinDelay = Value end
})

MiscMainSection:AddToggle({
    Name = "FRIEND ONLY MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FriendOnly",
    Save = true,
    Callback = function(Value) Config.FriendOnly = Value end
})

MiscMainSection:AddSection({
    Name = "🗺️ ISLAND SCANNER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddButton({
    Name = "SCAN ALL ISLANDS",
    Icon = "map",
    Outline = true,
    Callback = function()
        task.spawn(function()
            Notify("Scanning islands...")
            getgenv().ScanAllIslands()
        end)
    end
})

MiscMainSection:AddButton({
    Name = "PRINT CACHED MOBS",
    Icon = "list",
    Outline = true,
    Callback = function()
        print("\n=== CACHED MOBS ===")
        for mobName, data in pairs(getgenv().IslandMobCache) do
            print(string.format("  %s → %s", mobName, data.island))
        end
        print("===================\n")
    end
})

MiscMainSection:AddSection({
    Name = "⚡ BOSS KEY & EXCHANGE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddToggle({
    Name = "AUTO BUY BOSS KEY",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBossKey",
    Save = true,
    Callback = function(Value) Config.AutoBuyBossKey = Value end
})

MiscMainSection:AddToggle({
    Name = "EXCHANGE ICHIGO",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ExchangeIchigo",
    Save = true,
    Callback = function(Value) Config.ExchangeIchigo = Value end
})

MiscMainSection:AddToggle({
    Name = "FARM SABER BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FarmSaber",
    Save = true,
    Callback = function(Value) Config.FarmSaberBoss = Value end
})

MiscMainSection:AddButton({
    Name = "CHECK ICHIGO REQUIREMENTS",
    Icon = "check",
    Outline = true,
    Callback = function()
        local hasAll, count = checkIchigoRequirements()
        if hasAll then
            Notify("You have enough Boss Tickets! (500/500)")
        else
            Notify("Need 500 Boss Tickets! Current: " .. count)
        end
    end
})

MiscMainSection:AddButton({
    Name = "EXCHANGE ICHIGO NOW",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        exchangeIchigo()
    end
})

MiscMainSection:AddSection({
    Name = "🔓 ARTIFACTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddButton({
    Name = "UNLOCK ARTIFACTS",
    Icon = "lock",
    Outline = true,
    Callback = function()
        task.spawn(unlockArtifacts)
    end
})

MiscMainSection:AddButton({
    Name = "EQUIP ARTIFACTS",
    Icon = "package",
    Outline = true,
    Callback = function()
        task.spawn(equipArtifacts)
    end
})

MiscMainSection:AddButton({
    Name = "BUY OBSERVATION HAKI",
    Icon = "eye",
    Outline = true,
    Callback = function()
        task.spawn(buyObservationHaki)
    end
})

--==================================================
-- INFO TAB UI
--==================================================
local InfoSection = InfoTab:AddSection({
    Name = "📊 PLAYER INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local function updatePlayerInfo()
    local level = 0
    local money = 0
    local gems = 0
    local statPoints = 0
    
    pcall(function()
        level = Player.Data.Level.Value or 0
        money = Player.Data.Money.Value or 0
        gems = Player.Data.Gems.Value or 0
        statPoints = Player.Data.StatPoints.Value or 0
    end)
    
    local hasHaki, hakiInfo = checkHakiStatus()
    local hasObs = checkObservationHaki()
    local hasBlade = findDarkBlade() ~= nil
    
    return string.format(
        "Level: %d\nMoney: %s\nGems: %s\nStat Points: %d\nArmament Haki: %s\nObservation Haki: %s\nDark Blade: %s",
        level, formatNumber(money), formatNumber(gems), statPoints,
        hasHaki and "✅" or "❌",
        hasObs and "✅" or "❌",
        hasBlade and "✅" or "❌"
    )
end

local PlayerInfoPara = InfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = updatePlayerInfo(),
    Image = "user",
    ImageSize = 48,
    Buttons = {
        {
            Title = "🔄 Refresh",
            Callback = function()
                PlayerInfoPara:SetDesc(updatePlayerInfo())
            end
        }
    }
})

task.spawn(function()
    while true do
        task.wait(2)
        PlayerInfoPara:SetDesc(updatePlayerInfo())
    end
end)

local ServerInfoSection = InfoTab:AddSection({
    Name = "🌐 SERVER INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local startTime = tick()
local function getUptime()
    local uptime = tick() - startTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function UpdateServerInfo()
    local players = Players:GetPlayers()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
    
    return "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
           "Ping: " .. ping .. "ms\n" ..
           "Uptime: " .. getUptime()
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

task.spawn(function()
    while true do
        task.wait(1)
        ServerInfoPara:SetDesc(UpdateServerInfo())
    end
end)

local ActiveFeaturesSection = InfoTab:AddSection({
    Name = "⚡ ACTIVE FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local function GetActiveFeatures()
    local active = {}
    
    if Config.LoopFarm then table.insert(active, "Farm") end
    if Config.AutoBossFight then table.insert(active, "Boss") end
    if Config.AutoSummonBoss then table.insert(active, "Summon") end
    if Config.AutoDungeon then table.insert(active, "Dungeon") end
    if Config.AutoBossRush then table.insert(active, "BossRush") end
    if Config.AutoDungeonQuest then table.insert(active, "DungeonQ") end
    if Config.AutoHogyokuQuest then table.insert(active, "HogyokuQ") end
    if Config.FruitFarm then table.insert(active, "Fruit") end
    if Config.AutoBuyBossKey then table.insert(active, "BossKey") end
    if Config.ExchangeIchigo then table.insert(active, "Ichigo") end
    if Config.FarmSaberBoss then table.insert(active, "Saber") end
    if Config.AutoCraft.SlimeKey then table.insert(active, "SlimeKey") end
    if Config.AutoCraft.DivineGrail then table.insert(active, "Grail") end
    if Config.AutoHaki then table.insert(active, "Haki") end
    if Config.AutoObsHaki then table.insert(active, "ObsHaki") end
    if Config.Noclip then table.insert(active, "Noclip") end
    
    return active
end

local ActiveFeaturesPara = ActiveFeaturesSection:AddParagraph({
    Title = "Currently Active",
    Desc = "No active features",
    Image = "activity",
    ImageSize = 38
})

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

InfoSection:AddSection({
    Name = "📝 CREDITS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

InfoSection:AddParagraph({
    Title = "Sailor Piece Catraz Hub",
    Desc = "Version: 6.0 ULTIMATE\nFeatures: 50+\nMerged from: ArcX, Sailor v4/v5, Bypass",
    Image = "star",
    ImageSize = 38
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

--==================================================
-- INITIALIZE ALL SYSTEMS
--==================================================
setupBypass()
setupAntiAFK()
setupAutoRejoin()
setupTimedRejoin()
setupFriendOnly()
initEntityTracker()
buildMobDatabase()

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    task.wait(3)
    if Config.Noclip then
        enableNoclip()
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

task.spawn(function()
    task.wait(5)
    task.spawn(function() getgenv().ScanAllIslands() end)
end)

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ HUB EDITION v6.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ AUTO FARM SYSTEM - FULLY OPTIMIZED")
print("  • Quest-based farming with auto accept/complete")
print("  • Auto heal when low health")
print("  • Auto skills with cooldown")
print("  • Auto equip weapons")
print("  • Farm stats tracking")
print("  • Safe spot with auto return")
print("  • Ignore mobs list")
print("✅ Auto Boss - Fight & Summon bosses")
print("✅ Special Bosses - TrueAizen, Sukuna, Gojo, Rimuru, Anos")
print("✅ Auto Dungeon - Shadow/Rune/Cid dungeons")
print("✅ Auto Skills - Z, X, C, V, F")
print("✅ Auto Haki - Armament & Observation")
print("✅ Fruit Farm - Target fruit farming")
print("✅ Crafting - Slime Key & Divine Grail")
print("✅ Bypass - Anti-TP, Anti-Kick, Anti-Void")
print("✅ Island Scanner - Cache all mob locations")
print("✅ Artifacts - Unlock & equip system")
print("✅ Boss Key - Auto buy & Saber boss farm")
print("✅ Ichigo - Exchange system")
print("═══════════════════════════════════════════════════════")