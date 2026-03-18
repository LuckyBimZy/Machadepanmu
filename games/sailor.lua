-- ==================== SAILOR PIECE - ULTIMATE HUB v2.1 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 2.1 STABLE (Tanpa hookmetamethod & getgc)

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
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

-- Wait for character
repeat task.wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

--==================================================
-- SAFE REMOTE ACCESS (Dengan error handling)
--==================================================
local function getRemote(...)
    local args = {...}
    local obj = ReplicatedStorage
    for i = 1, #args do
        obj = obj:FindFirstChild(args[i])
        if not obj then return nil end
    end
    return obj
end

-- Combat Remotes
local hitRemote = getRemote("CombatSystem", "Remotes", "RequestHit")
local combatRemote = getRemote("CombatSystem", "Remotes", "RequestCombat")

-- Ability Remotes
local abilityRemote = getRemote("AbilitySystem", "Remotes", "RequestAbility")

-- Teleport Remote
local tpRemote = getRemote("Remotes", "TeleportToPortal")

-- Quest Remotes
local questRemote = getRemote("RemoteEvents", "QuestAccept")
local abandonRemote = getRemote("RemoteEvents", "QuestAbandon")

-- Stats Remote
local statRemote = getRemote("RemoteEvents", "AllocateStat")
local resetStatsRemote = getRemote("RemoteEvents", "ResetStats")

-- Settings Remote
local settingsRemote = getRemote("RemoteEvents", "SettingsToggle")

-- Haki Remotes
local hakiRemote = getRemote("RemoteEvents", "HakiRemote")
local obsHakiRemote = getRemote("RemoteEvents", "ObservationHakiRemote")

-- Boss Remotes
local summonBossRemote = getRemote("Remotes", "RequestSummonBoss")
local spawnStrongestRemote = getRemote("Remotes", "RequestSpawnStrongestBoss")
local spawnAnosRemote = getRemote("Remotes", "RequestSpawnAnosBoss")
local trueAizenRemote = getRemote("RemoteEvents", "RequestSpawnTrueAizen")
local rimuruRemote = getRemote("RemoteEvents", "RequestSpawnRimuru")

-- Merchant Remotes
local merchantRemotes = getRemote("Remotes", "MerchantRemotes")
local purchaseRemote = merchantRemotes and merchantRemotes:FindFirstChild("PurchaseMerchantItem")
local stockRemote = merchantRemotes and merchantRemotes:FindFirstChild("GetMerchantStock")
local stockUpdateRemote = merchantRemotes and merchantRemotes:FindFirstChild("MerchantStockUpdate")

-- Crafting Remotes
local slimeCraftRemote = getRemote("Remotes", "RequestSlimeCraft")
local grailCraftRemote = getRemote("Remotes", "RequestGrailCraft")

-- Inventory Remotes
local updateInventoryRemote = getRemote("Remotes", "UpdateInventory")
local requestInventoryRemote = getRemote("Remotes", "RequestInventory")

-- Artifact Remotes
local artifactDataRemote = getRemote("RemoteFunctions", "GetArtifactData")
local artifactEquipRemote = getRemote("RemoteEvents", "ArtifactEquip")
local artifactUnlockRemote = getRemote("RemoteEvents", "ArtifactUnlockSystem")
local artifactCloseRemote = getRemote("RemoteEvents", "ArtifactCloseUI")
local artifactUIOpenedRemote = getRemote("RemoteEvents", "ArtifactUIOpened")

-- Dungeon Remote
local dungeonRemote = getRemote("RemoteEvents", "Dungeon")
local bossRushRemote = getRemote("RemoteEvents", "BossRush")

-- Fruit Remote
local fruitPowerRemote = getRemote("RemoteEvents", "FruitPowerRemote")
local fruitActionRemote = getRemote("RemoteEvents", "FruitAction")

-- Exchange Remote
local exchangeRemote = getRemote("Remotes", "ExchangeItem")

-- Code Redeem Remote
local codeRedeemRemote = getRemote("RemoteEvents", "CodeRedeem")

-- Equip Weapon Remote
local equipWeaponRemote = getRemote("Remotes", "EquipWeapon")

-- Chest Remote
local chestRemote = getRemote("RemoteEvents", "Chest")

--==================================================
-- LOAD CONFIG MODULES (Aman dengan pcall)
--==================================================
local TravelConfig = nil
local QuestConfig = nil
local ItemRarityConfig = nil
local CodesConfig = nil

pcall(function()
    TravelConfig = require(ReplicatedStorage:WaitForChild("TravelConfig"))
end)

pcall(function()
    QuestConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("QuestConfig"))
end)

pcall(function()
    ItemRarityConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ItemRarityConfig"))
end)

pcall(function()
    CodesConfig = require(ReplicatedStorage:WaitForChild("CodesConfig"))
end)

--==================================================
-- CONFIGURATION (LENGKAP)
--==================================================
local Config = {
    -- Farm Settings
    AutoFarm = false,
    SelectedMob = "Auto",
    WeaponMode = "Melee",
    FarmHeight = 25,
    FarmSpeed = 50,
    MoveMode = "Tween",
    AttackCooldown = 0.3,
    PlankMode = false,
    NPCAttackThreshold = 5,
    
    -- Mob Database
    MobDatabase = {},
    IslandCache = {},
    EntityTracker = {},
    
    -- Quest Settings
    AutoQuest = false,
    AutoAcceptQuest = true,
    SelectedQuestNPC = "None",
    
    -- Skill Settings
    AutoSkills = {
        Z = false,
        X = false,
        C = false,
        V = false,
        F = false
    },
    SkillCooldown = 0.5,
    LastSkillTime = 0,
    
    -- Boss Settings
    AutoBossFight = false,
    SelectedBoss = "None",
    AutoSummonBoss = false,
    SummonDifficulty = "Normal",
    SelectedSummonBoss = "None",
    SelectedBosses = {},
    
    -- Special Bosses
    SpecialBosses = {
        TrueAizen = { Auto = false, Diff = "Normal" },
        Sukuna = { Auto = false, Diff = "Normal" },
        Gojo = { Auto = false, Diff = "Normal" },
        Rimuru = { Auto = false, Diff = "Normal" },
        Anos = { Auto = false, Diff = "Normal" }
    },
    
    -- Gamemodes
    AutoDungeon = false,
    DungeonType = "Shadow",
    AutoBossRush = false,
    
    -- Quest Chains
    DungeonQuest = false,
    HogyokuQuest = false,
    
    -- Items
    AutoChest = false,
    AutoMerchant = false,
    MerchantItem = "HealthPotion",
    AutoCraft = {
        SlimeKey = false,
        DivineGrail = false
    },
    CraftAmount = 1,
    
    -- Haki Settings
    AutoHaki = false,
    AutoObsHaki = false,
    HakiQuest = false,
    HakiMinLevel = 3000,
    HakiTimeout = 3600,
    LastHakiCheck = 0,
    
    -- Dark Blade
    AutoBuyDarkBlade = false,
    DarkBladeGems = 150,
    DarkBladeMoney = 250000,
    DarkBladeOwned = false,
    
    -- Fruit Farm
    FruitFarm = false,
    TargetFruit = "Quake",
    FruitFarmIsland = "Shinjuku",
    FruitFarmPos = CFrame.new(321.706757, -1.539090, -1756.500977),
    FruitFarming = false,
    
    -- Boss Key
    AutoBuyBossKey = false,
    BossKeyBuyInterval = 1800,
    LastBossKeyBuy = 0,
    
    -- Ichigo Exchange
    ExchangeIchigo = false,
    IchigoMinLevel = 11500,
    
    -- Saber Boss Farm
    FarmSaberBoss = false,
    FarmingIchigoBoss = false,
    
    -- Stats Distribution
    AutoStats = false,
    StatSword = 50,
    StatDefense = 30,
    StatPower = 20,
    
    -- Utility
    Noclip = false,
    AntiAFK = true,
    FpsBoost = false,
    WhiteScreen = false,
    AntiVoid = true,
    AntiIdle = true,
    
    -- Auto Rejoin
    AutoRejoin = false,
    TimedRejoin = false,
    RejoinDelay = 10,
    TimedRejoinRunning = false,
    
    -- Friend Only
    FriendOnly = false,
    
    -- Ignored Entities
    IgnoredEntities = {},
    
    -- Inventory
    InventoryByRarity = {
        Secret = {}, Mythical = {}, Legendary = {},
        Epic = {}, Rare = {}, Uncommon = {}, Common = {}
    },
    CratesAndBoxes = {},
    
    -- Artifacts
    ArtifactsUnlocked = false,
    
    -- Player Data Cache
    PlayerData = {
        Level = 0,
        Money = 0,
        Gems = 0,
        StatPoints = 0,
        Power = 0,
        Sword = 0,
        Defense = 0,
        Melee = 0
    }
}

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
    Ambient = Lighting.Ambient
}

local originalQuality = settings().Rendering.QualityLevel

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
    Subtext = "ULTIMATE Hub v2.1",
    Version = "v2.1",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Config",
    IntroEnabled = true,
    IntroText = "Sailor Piece Ultimate",
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
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

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

local SkillsTab = Window:MakeTab({
    Name = "Skills",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local GamemodesTab = Window:MakeTab({
    Name = "Gamemodes",
    Icon = "gamepad-2",
    Glass = true,
    Outline = true
})

local ItemsTab = Window:MakeTab({
    Name = "Items",
    Icon = "package",
    Glass = true,
    Outline = true
})

local HakiTab = Window:MakeTab({
    Name = "Haki",
    Icon = "eye",
    Glass = true,
    Outline = true
})

local StatsTab = Window:MakeTab({
    Name = "Stats",
    Icon = "bar-chart-2",
    Glass = true,
    Outline = true
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- PLAYER DATA UPDATE
--==================================================
local function updatePlayerData()
    pcall(function()
        if Player.Data then
            Config.PlayerData.Level = Player.Data:FindFirstChild("Level") and Player.Data.Level.Value or 0
            Config.PlayerData.Money = Player.Data:FindFirstChild("Money") and Player.Data.Money.Value or 0
            Config.PlayerData.Gems = Player.Data:FindFirstChild("Gems") and Player.Data.Gems.Value or 0
            Config.PlayerData.StatPoints = Player.Data:FindFirstChild("StatPoints") and Player.Data.StatPoints.Value or 0
            Config.PlayerData.Power = Player.Data:FindFirstChild("Power") and Player.Data.Power.Value or 0
            Config.PlayerData.Sword = Player.Data:FindFirstChild("Sword") and Player.Data.Sword.Value or 0
            Config.PlayerData.Defense = Player.Data:FindFirstChild("Defense") and Player.Data.Defense.Value or 0
            Config.PlayerData.Melee = Player.Data:FindFirstChild("Melee") and Player.Data.Melee.Value or 0
        end
    end)
end

task.spawn(function()
    while true do
        updatePlayerData()
        task.wait(1)
    end
end)

--==================================================
-- ACTIVE FEATURES COUNTER
--==================================================
local function GetActiveFeatures()
    local active = {}
    
    if Config.AutoFarm then table.insert(active, "Farm") end
    if Config.AutoBossFight then table.insert(active, "Boss") end
    if Config.AutoSummonBoss then table.insert(active, "Summon") end
    for _, data in pairs(Config.SpecialBosses) do
        if data.Auto then table.insert(active, "Special") break end
    end
    if Config.AutoDungeon then table.insert(active, "Dungeon") end
    if Config.AutoBossRush then table.insert(active, "Rush") end
    if Config.AutoHaki then table.insert(active, "Haki") end
    if Config.AutoObsHaki then table.insert(active, "Obs") end
    if Config.HakiQuest then table.insert(active, "HakiQ") end
    if Config.AutoBuyDarkBlade then table.insert(active, "Blade") end
    if Config.FruitFarm then table.insert(active, "Fruit") end
    if Config.AutoBuyBossKey then table.insert(active, "BossKey") end
    if Config.ExchangeIchigo then table.insert(active, "Ichigo") end
    if Config.FarmSaberBoss then table.insert(active, "Saber") end
    if Config.AutoStats then table.insert(active, "Stats") end
    if Config.Noclip then table.insert(active, "Noclip") end
    if Config.AntiAFK then table.insert(active, "AntiAFK") end
    if Config.FpsBoost then table.insert(active, "FPS") end
    if Config.AutoRejoin then table.insert(active, "Rejoin") end
    
    return active
end

--==================================================
-- ANTI-VOID (Safe version)
--==================================================
task.spawn(function()
    local lastSafe = CFrame.new(0, 100, 0)
    while task.wait(0.5) do
        if not Config.AntiVoid then continue end
        local char = Player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        if hrp.Position.Y > -50 then
            lastSafe = hrp.CFrame
        else
            hrp.CFrame = lastSafe
        end
    end
end)

--==================================================
-- ANTI-IDLE (Safe version)
--==================================================
task.spawn(function()
    while task.wait(120) do
        if not Config.AntiIdle then continue end
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

--==================================================
-- ISLAND SCANNER SYSTEM
--==================================================

-- Get all islands
local function getAllIslands()
    local islands = {}
    
    -- Dari TravelConfig
    if TravelConfig and TravelConfig.Islands then
        for name, _ in pairs(TravelConfig.Islands) do
            local portalArg = name:gsub("Island", ""):gsub(" ", "")
            table.insert(islands, { name = name, portal = portalArg })
        end
    end
    
    -- Fallback hardcoded
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

-- Scan NPCs at current island
local function scanCurrentIsland(islandName)
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return 0 end
    
    local found = 0
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") then
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                if not Config.IslandCache[npc.Name] then
                    Config.IslandCache[npc.Name] = {
                        island = islandName,
                        position = hrp.Position,
                        maxHealth = hum.MaxHealth
                    }
                    found = found + 1
                end
            end
        end
    end
    return found
end

-- Scan all islands
local function scanAllIslands()
    local islands = getAllIslands()
    local totalMobs = 0
    
    Notify("Scanning " .. #islands .. " islands...")
    
    for i, island in ipairs(islands) do
        if tpRemote then
            pcall(function()
                tpRemote:FireServer(island.portal)
            end)
        end
        task.wait(3)
        
        local found = scanCurrentIsland(island.name)
        totalMobs = totalMobs + found
    end
    
    Notify("✅ Found " .. totalMobs .. " mob types")
    return totalMobs
end

-- Teleport to mob's island
local function teleportToMobIsland(mobName)
    local cached = Config.IslandCache[mobName]
    if not cached then
        scanAllIslands()
        cached = Config.IslandCache[mobName]
    end
    
    if cached and tpRemote then
        local portalArg = cached.island:gsub("Island", ""):gsub(" ", "")
        pcall(function()
            tpRemote:FireServer(portalArg)
        end)
        task.wait(3)
        return true
    end
    return false
end

--==================================================
-- ENTITY TRACKER SYSTEM (Safe version)
--==================================================
local EntityTracker = {}
EntityTracker.Active = {}
EntityTracker.Connections = {}

function EntityTracker:Register(npc)
    task.spawn(function()
        local humanoid = npc:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        self.Active[npc] = true
        
        local deathConn = humanoid.Died:Connect(function()
            self.Active[npc] = nil
        end)
        
        local removeConn = npc.AncestryChanged:Connect(function(_, parent)
            if not parent then
                self.Active[npc] = nil
            end
        end)
        
        table.insert(self.Connections, deathConn)
        table.insert(self.Connections, removeConn)
    end)
end

function EntityTracker:Init()
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, child in ipairs(npcFolder:GetChildren()) do
            self:Register(child)
        end
        
        local conn = npcFolder.ChildAdded:Connect(function(child)
            self:Register(child)
        end)
        table.insert(self.Connections, conn)
    end
end

function EntityTracker:IsAlive(name, isBoss, required)
    required = required or 1
    local count = 0
    
    for npc in pairs(self.Active) do
        if npc and npc.Parent then
            if isBoss then
                if npc.Name:find("^" .. name) then
                    return true
                end
            else
                if npc.Name:find(name) then
                    count = count + 1
                    if count >= required then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

EntityTracker:Init()

--==================================================
-- MOB DATABASE
--==================================================
local function buildMobDatabase()
    table.clear(Config.MobDatabase)
    
    if QuestConfig and QuestConfig.RepeatableQuests then
        for npcName, data in pairs(QuestConfig.RepeatableQuests) do
            local reqLevel = tonumber(data.recommendedLevel) or 0
            if data.requirements and data.requirements[1] then
                local mobType = data.requirements[1].npcType
                table.insert(Config.MobDatabase, {
                    name = mobType,
                    level = reqLevel,
                    npcName = npcName,
                    island = "Unknown"
                })
            end
        end
    end
    
    table.sort(Config.MobDatabase, function(a, b)
        return a.level < b.level
    end)
end

--==================================================
-- INVENTORY SYSTEM
--==================================================
if updateInventoryRemote then
    updateInventoryRemote.OnClientEvent:Connect(function(category, items)
        if not items then return end
        
        for _, item in pairs(items) do
            local name = item.name
            local qty = item.quantity or 1
            if not name then continue end
            
            -- Crates/Boxes
            if name:lower():find("crate") or name:lower():find("box") or name:lower():find("chest") then
                Config.CratesAndBoxes[name] = qty
            end
            
            -- Rarity
            if ItemRarityConfig then
                local ok, rarity = pcall(function()
                    return ItemRarityConfig:GetRarity(name)
                end)
                if ok and rarity and Config.InventoryByRarity[rarity] then
                    Config.InventoryByRarity[rarity][name] = qty
                end
            end
        end
    end)
end

if requestInventoryRemote then
    task.spawn(function()
        task.wait(3)
        pcall(function() requestInventoryRemote:FireServer() end)
    end)
end

--==================================================
-- GET QUEST INFO
--==================================================
local function getQuestInfo()
    local ok, result = pcall(function()
        return RemoteEvents and RemoteEvents:FindFirstChild("GetQuestArrowTarget"):InvokeServer()
    end)
    return ok and result or nil
end

local function getNpcType(npcName)
    if not QuestConfig or not QuestConfig.RepeatableQuests then return nil end
    
    for questNPC, questData in pairs(QuestConfig.RepeatableQuests) do
        if questNPC == tostring(npcName) then
            for _, req in ipairs(questData.requirements) do
                return req.npcType
            end
        end
    end
    return nil
end

local function getTargetQuest()
    local level = Config.PlayerData.Level
    local bestNPC = nil
    local maxLevel = -1
    local targetMob = nil
    
    if QuestConfig and QuestConfig.RepeatableQuests then
        for npcName, data in pairs(QuestConfig.RepeatableQuests) do
            local req = tonumber(data.recommendedLevel) or 0
            if level >= req and req > maxLevel then
                maxLevel = req
                bestNPC = npcName
                if data.requirements and data.requirements[1] then
                    targetMob = data.requirements[1].npcType
                end
            end
        end
    end
    
    return bestNPC, targetMob
end

--==================================================
-- FARM SYSTEM
--==================================================
local BodyVelocity = Instance.new("BodyVelocity")
local STEP_SIZE = 50
local STEP_TIME = 0.08
local STEP_DELAY = 0.03
local CLOSE_RANGE = 15

local function getChar()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    return char, hrp, hum
end

-- Find mob
local function findMob(targetName)
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil, math.huge end
    
    local char, hrp = getChar()
    local closest = nil
    local closestDist = math.huge
    local playerPos = hrp.Position
    
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local match = false
                if targetName and targetName ~= "Auto" then
                    match = npc.Name:find(targetName)
                else
                    match = true
                end
                
                if match then
                    local dist = (npc.HumanoidRootPart.Position - playerPos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = npc
                    end
                end
            end
        end
    end
    
    return closest, closestDist
end

-- Find boss
local function findBoss(bossName)
    for _, folder in ipairs({"NPCs", "Bosses", "WorldBoss"}) do
        local f = workspace:FindFirstChild(folder)
        if f then
            for _, npc in ipairs(f:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if bossName == "None" or npc.Name:find(bossName) then
                            return npc
                        end
                    end
                end
            end
        end
    end
    return nil
}

-- Tween to mob
local function tweenToMob(mob)
    local char, hrp, hum = getChar()
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    
    local offset = Config.PlankMode and Vector3.new(0, Config.FarmHeight, 0) or Vector3.new(0, 0, 5)
    local targetPos = mob.HumanoidRootPart.Position + offset
    
    if Config.MoveMode == "Teleport" then
        hrp.CFrame = CFrame.new(targetPos)
        return
    end
    
    local totalDist = (targetPos - hrp.Position).Magnitude
    
    if totalDist <= CLOSE_RANGE then
        hrp.CFrame = CFrame.new(targetPos)
        return
    end
    
    local steps = math.ceil(totalDist / STEP_SIZE)
    local startPos = hrp.Position
    
    for i = 1, steps do
        if not Config.AutoFarm then break end
        if not mob or not mob.Parent then break end
        
        if mob:FindFirstChild("HumanoidRootPart") then
            targetPos = mob.HumanoidRootPart.Position + offset
        end
        
        local nextPos
        if i == steps then
            nextPos = targetPos
        else
            local progress = i / steps
            nextPos = startPos:Lerp(targetPos, progress)
        end
        
        hrp.CFrame = CFrame.new(nextPos)
        task.wait(STEP_DELAY)
    end
end

-- Equip weapon
local function equipWeapon()
    local char, _, hum = getChar()
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    local function findTool(container)
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                if Config.WeaponMode == "Melee" then
                    local n = item.Name:lower()
                    if n:find("sword") or n:find("blade") or n:find("katana") or n:find("cutlass") then
                        return item
                    end
                elseif Config.WeaponMode == "Fruit" then
                    local n = item.Name:lower()
                    if n:find("fruit") or n:find("devil") then
                        return item
                    end
                end
            end
        end
        return nil
    end
    
    local equipped = findTool(char)
    if equipped then return equipped end
    
    local tool = findTool(backpack)
    if tool then
        hum:EquipTool(tool)
        return tool
    end
    
    -- Fallback: equip first tool
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            hum:EquipTool(item)
            return item
        end
    end
    
    return nil
}

-- Auto attack
local function autoAttack(mob)
    if not mob then return end
    
    local tool = equipWeapon()
    if tool then
        pcall(function() tool:Activate() end)
    end
    
    if hitRemote then
        pcall(function() hitRemote:FireServer() end)
    end
    
    -- Skills
    local now = tick()
    if now - Config.LastSkillTime >= Config.SkillCooldown then
        Config.LastSkillTime = now
        local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
        for key, slot in pairs(skillMap) do
            if Config.AutoSkills[key] and abilityRemote then
                pcall(function() abilityRemote:FireServer(slot) end)
            end
        end
    end
end

--==================================================
-- STATS SYSTEM
--==================================================
local function allocateStats()
    if not statRemote then return end
    
    local points = Config.PlayerData.StatPoints
    if points <= 0 then return end
    
    local level = Config.PlayerData.Level
    
    if level < Config.HakiMinLevel then
        -- Level 1-2999: Melee + Defense
        local melee = math.floor(points * 0.67)
        local defense = points - melee
        
        if melee > 0 then
            pcall(function() statRemote:FireServer("Melee", melee) end)
        end
        if defense > 0 then
            pcall(function() statRemote:FireServer("Defense", defense) end)
        end
    else
        -- Level 3000+: Sword, Defense, Power
        local sword = math.floor(points * Config.StatSword / 100)
        local defense = math.floor(points * Config.StatDefense / 100)
        local power = points - sword - defense
        
        if sword > 0 then
            pcall(function() statRemote:FireServer("Sword", sword) end)
        end
        if defense > 0 then
            pcall(function() statRemote:FireServer("Defense", defense) end)
        end
        if power > 0 then
            pcall(function() statRemote:FireServer("Power", power) end)
        end
    end
end

local function resetStats()
    if resetStatsRemote then
        pcall(function() resetStatsRemote:FireServer() end)
    end
end

--==================================================
-- HAKI SYSTEM
--==================================================
local function checkHakiStatus()
    local hasHaki = false
    pcall(function()
        local statsUI = Player.PlayerGui:FindFirstChild("StatsPanelUI")
        if statsUI then
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name == "HakiProgressionFrame" and desc.Visible then
                    hasHaki = true
                    break
                end
            end
        end
    end)
    return hasHaki
end

local function checkObservationHaki()
    local hasObs = false
    pcall(function()
        local statsUI = Player.PlayerGui:FindFirstChild("StatsPanelUI")
        if statsUI then
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name:find("Observation") and desc:IsA("Frame") and desc.Visible then
                    hasObs = true
                    break
                end
            end
        end
    end)
    return hasObs
end

local function acceptHakiQuest()
    if not questRemote then return end
    
    local hakiPos = Vector3.new(-497.94, 23.66, -1252.64)
    
    -- Abandon old quest
    pcall(function()
        local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
        if questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible then
            local title = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
            if not title:find("Path to Haki") and abandonRemote then
                abandonRemote:FireServer("repeatable")
                task.wait(2)
            end
        end
    end)
    
    -- Teleport to Haki NPC
    local char, hrp = getChar()
    hrp.CFrame = CFrame.new(hakiPos)
    task.wait(2)
    
    -- Accept quest
    pcall(function() questRemote:FireServer("HakiQuestNPC") end)
end

local function farmThiefForHaki()
    if not hitRemote then return end
    
    local targetNPC = "Thief"
    local farmStart = tick()
    
    -- Teleport to starter island
    if tpRemote then
        pcall(function() tpRemote:FireServer("Starter") end)
        task.wait(3)
    end
    
    while Config.HakiQuest and (tick() - farmStart) < Config.HakiTimeout do
        local char, hrp = getChar()
        
        -- Check quest progress
        local shouldGoToNPC = false
        local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
        
        if questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible then
            pcall(function()
                for _, child in pairs(questUI.Quest.Quest.Holder.Content.QuestInfo:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        if child.Text:find("Completed!") then
                            shouldGoToNPC = true
                            break
                        end
                        local cur, tot = child.Text:match("(%d+)/(%d+)")
                        if cur and tot and tonumber(cur) >= tonumber(tot) then
                            shouldGoToNPC = true
                        end
                    end
                end
            end)
        end
        
        -- Go to NPC if quest complete
        if shouldGoToNPC then
            local hakiPos = Vector3.new(-497.94, 23.66, -1252.64)
            hrp.CFrame = CFrame.new(hakiPos)
            task.wait(3)
            
            -- Press E key
            for i = 1, 3 do
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(0.4)
            end
            
            if checkHakiStatus() then
                Notify("✅ Haki obtained!")
                return true
            end
        end
        
        -- Farm mobs
        for i = 1, 5 do
            local npc = workspace.NPCs and workspace.NPCs:FindFirstChild(targetNPC .. i)
            if npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local target = npc:FindFirstChild("HumanoidRootPart")
                if target then
                    while npc.Parent and npc.Humanoid.Health > 0 do
                        hrp.CFrame = target.CFrame * CFrame.new(0, 0, 5)
                        hitRemote:FireServer()
                        task.wait(0.3)
                    end
                end
            end
        end
        
        task.wait(1)
    end
    
    return false
end

local function startHakiQuest()
    if not Config.HakiQuest then return end
    acceptHakiQuest()
    farmThiefForHaki()
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

local function checkDarkBladeInventory()
    local result = false
    if updateInventoryRemote then
        local conn
        conn = updateInventoryRemote.OnClientEvent:Connect(function(_, data)
            for _, item in pairs(data) do
                if item.name and (item.name:find("Dark Blade") or item.name:find("ดาบสีเข้ม")) then
                    result = true
                    if conn then conn:Disconnect() end
                end
            end
        end)
    end
    if requestInventoryRemote then
        pcall(function() requestInventoryRemote:FireServer() end)
    end
    task.wait(0.5)
    return result
end

local function equipDarkBlade()
    if equipWeaponRemote then
        pcall(function() equipWeaponRemote:FireServer("Equip", "Dark Blade") end)
        task.wait(1)
    end
    return findDarkBlade() ~= nil
end

local function buyDarkBlade()
    if findDarkBlade() then 
        Config.DarkBladeOwned = true
        Notify("✅ Dark Blade already owned")
        return true 
    end
    
    local gems = Config.PlayerData.Gems
    local money = Config.PlayerData.Money
    
    if gems < Config.DarkBladeGems or money < Config.DarkBladeMoney then
        Notify("❌ Not enough resources for Dark Blade")
        return false
    end
    
    local npcCF = CFrame.new(-132.516449, 13.2661686, -1091.2699)
    
    -- Reset stats first
    resetStats()
    task.wait(2)
    
    -- Teleport to NPC
    local char, hrp = getChar()
    hrp.CFrame = npcCF * CFrame.new(0, 0, -3)
    task.wait(3)
    
    -- Find and fire prompt
    pcall(function()
        local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("DarkBladeNPC")
        if npc then
            local prompt = npc:FindFirstChild("DarkBladeShopPrompt", true)
            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end)
    
    task.wait(5)
    
    -- Equip if purchased
    if findDarkBlade() or checkDarkBladeInventory() then
        equipDarkBlade()
        Config.DarkBladeOwned = true
        Notify("✅ Dark Blade purchased and equipped!")
        return true
    end
    
    return false
end

--==================================================
-- FRUIT FARM SYSTEM
--==================================================
local function checkHasFruit(fruitName)
    for _, container in pairs({Player.Character, Player.Backpack}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:find(fruitName) then
                    return true, tool
                end
            end
        end
    end
    return false, nil
end

local function getAnyFruitFromBackpack()
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                return tool
            end
        end
    end
    return nil
end

local function eatFruit(fruitTool)
    if not fruitTool then return end
    
    local char, _, hum = getChar()
    
    -- Equip fruit
    if fruitTool.Parent == Player.Backpack then
        hum:EquipTool(fruitTool)
        task.wait(0.5)
    end
    
    -- Activate fruit
    pcall(function() fruitTool:Activate() end)
    task.wait(1)
    
    -- Click Yes in ConfirmUI
    local confirmUI = Player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame") and
                         confirmUI.MainFrame:FindFirstChild("ButtonsHolder") and
                         confirmUI.MainFrame.ButtonsHolder:FindFirstChild("Yes")
        if yesButton then
            pcall(function()
                for _, conn in pairs(getconnections(yesButton.MouseButton1Click)) do
                    conn:Fire()
                end
            end)
        end
    elseif fruitActionRemote then
        pcall(function() fruitActionRemote:FireServer("eat", fruitTool.Name) end)
    end
    
    task.wait(3)
end

local function buyRandomFruit()
    local npcCF = CFrame.new(400.641937, 2.79983521, 752.175842)
    
    local char, hrp = getChar()
    hrp.CFrame = npcCF * CFrame.new(0, 0, -3)
    task.wait(3)
    
    pcall(function()
        local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("GemFruitDealer")
        if npc then
            local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end)
    
    task.wait(3)
    return true
end

local function fruitFarmLoop()
    Config.FruitFarming = true
    
    local keyCodes = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
    local targetFruit = Config.TargetFruit
    
    while Config.FruitFarm and Config.FruitFarming do
        task.wait(0.5)
        
        local char, hrp = getChar()
        
        -- Lock position
        if (hrp.Position - Config.FruitFarmPos.Position).Magnitude > 5 then
            hrp.CFrame = Config.FruitFarmPos
        end
        
        -- Equip fruit
        equipWeapon()
        
        -- Use fruit skills
        for i, keyCode in ipairs(keyCodes) do
            if fruitPowerRemote then
                pcall(function()
                    fruitPowerRemote:FireServer("UseAbility", {
                        TargetPosition = hrp.Position,
                        FruitPower = targetFruit,
                        KeyCode = keyCode
                    })
                end)
            end
            task.wait(0.3)
        end
        
        task.wait(1.5)
    end
    
    Config.FruitFarming = false
end

local function startFruitFarm()
    local targetFruit = Config.TargetFruit
    
    -- Check if already have fruit
    local hasFruit, fruitTool = checkHasFruit(targetFruit)
    
    if hasFruit then
        Notify("✅ Already have " .. targetFruit)
        if fruitTool then
            eatFruit(fruitTool)
            task.wait(2)
        end
        equipWeapon()
        
        -- Teleport to farm position
        if tpRemote then
            pcall(function() tpRemote:FireServer(Config.FruitFarmIsland) end)
            task.wait(3)
        end
        
        local char, hrp = getChar()
        for i = 1, 5 do
            hrp.CFrame = Config.FruitFarmPos
            task.wait(0.1)
        end
        
        task.spawn(fruitFarmLoop)
        return true
    end
    
    -- Buy until get target fruit
    Notify("🎲 Buying fruits until get " .. targetFruit)
    
    local maxAttempts = 50
    local gotTarget = false
    
    while maxAttempts > 0 and not gotTarget do
        maxAttempts = maxAttempts - 1
        
        buyRandomFruit()
        task.wait(3)
        
        local fruit = getAnyFruitFromBackpack()
        if fruit then
            if fruit.Name:find(targetFruit) then
                Notify("🎉 Got " .. targetFruit .. "!")
                eatFruit(fruit)
                task.wait(2)
                gotTarget = true
            else
                eatFruit(fruit)
                task.wait(2)
            end
        end
    end
    
    if gotTarget then
        equipWeapon()
        
        if tpRemote then
            pcall(function() tpRemote:FireServer(Config.FruitFarmIsland) end)
            task.wait(3)
        end
        
        local char, hrp = getChar()
        for i = 1, 5 do
            hrp.CFrame = Config.FruitFarmPos
            task.wait(0.1)
        end
        
        task.spawn(fruitFarmLoop)
        return true
    end
    
    Notify("❌ Failed to get " .. targetFruit)
    return false
end

--==================================================
-- ARTIFACTS SYSTEM
--==================================================
local function checkArtifactsUnlocked()
    if not artifactDataRemote then return false end
    
    local unlocked = false
    pcall(function()
        local data = artifactDataRemote:InvokeServer()
        if data and data.Unlocked == true then
            unlocked = true
        end
    end)
    return unlocked
end

local function unlockArtifacts()
    if checkArtifactsUnlocked() then
        Config.ArtifactsUnlocked = true
        return true
    end
    
    local npcCF = CFrame.new(-440.516388, 1.77979147, -1095.86072)
    
    local char, hrp = getChar()
    hrp.CFrame = npcCF * CFrame.new(0, 0, -3)
    task.wait(3)
    
    -- Find and fire prompt
    pcall(function()
        local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("ArtifactsUnlocker")
        if npc then
            local prompt = npc:FindFirstChild("ArtifactPrompt", true)
            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end)
    
    task.wait(2)
    
    -- Click Yes in ConfirmUI
    local confirmUI = Player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame") and
                         confirmUI.MainFrame:FindFirstChild("ButtonsHolder") and
                         confirmUI.MainFrame.ButtonsHolder:FindFirstChild("Yes")
        if yesButton then
            pcall(function()
                for _, conn in pairs(getconnections(yesButton.MouseButton1Click)) do
                    conn:Fire()
                end
            end)
        end
    elseif artifactUnlockRemote then
        pcall(function() artifactUnlockRemote:FireServer() end)
    end
    
    task.wait(3)
    
    Config.ArtifactsUnlocked = checkArtifactsUnlocked()
    return Config.ArtifactsUnlocked
end

local function equipArtifacts()
    if not artifactDataRemote or not artifactEquipRemote then return end
    
    -- Open UI
    if artifactUIOpenedRemote then
        pcall(function() artifactUIOpenedRemote:FireServer() end)
    end
    task.wait(2)
    
    -- Get artifact data
    local data = nil
    pcall(function() data = artifactDataRemote:InvokeServer() end)
    
    if data and type(data) == "table" then
        -- Find all UUIDs
        local uuids = {}
        local function scanForUUIDs(tbl)
            for k, v in pairs(tbl) do
                if type(v) == "table" then
                    scanForUUIDs(v)
                elseif type(v) == "string" and v:match("%x%x%x%x%x%x%x%x%-%x%x%x%x") then
                    table.insert(uuids, v)
                end
            end
        end
        scanForUUIDs(data)
        
        -- Equip all artifacts
        for _, uuid in ipairs(uuids) do
            pcall(function() artifactEquipRemote:FireServer(uuid) end)
            task.wait(0.5)
        end
    end
    
    task.wait(1)
    
    -- Close UI
    if artifactCloseRemote then
        pcall(function() artifactCloseRemote:FireServer() end)
    end
end

--==================================================
-- OBSERVATION HAKI SYSTEM
--==================================================
local function buyObservationHaki()
    if checkObservationHaki() then return true end
    
    local npcCF = CFrame.new(-713.182922, 12.1339779, -527.289795)
    
    local char, hrp = getChar()
    hrp.CFrame = npcCF * CFrame.new(0, 0, -3)
    task.wait(3)
    
    pcall(function()
        local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("ObservationBuyer")
        if npc then
            local prompt = npc:FindFirstChild("ObservationHakiPrompt", true)
            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end)
    
    task.wait(2)
    
    -- Click Yes in ConfirmUI
    local confirmUI = Player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame") and
                         confirmUI.MainFrame:FindFirstChild("ButtonsHolder") and
                         confirmUI.MainFrame.ButtonsHolder:FindFirstChild("Yes")
        if yesButton then
            pcall(function()
                for _, conn in pairs(getconnections(yesButton.MouseButton1Click)) do
                    conn:Fire()
                end
            end)
        end
    end
    
    task.wait(3)
    return checkObservationHaki()
end

--==================================================
-- BOSS KEY SYSTEM
--==================================================
local function checkBossKeyCount()
    -- Refresh inventory
    if requestInventoryRemote then
        pcall(function() requestInventoryRemote:FireServer() end)
        task.wait(1)
    end
    
    return Config.InventoryByRarity["Epic"]["Boss Key"] or 0
end

local function buyBossKeys(amount)
    if not purchaseRemote then return end
    
    local merchantCF = CFrame.new(368.817719, 2.79983521, 783.589844)
    
    local char, hrp = getChar()
    hrp.CFrame = merchantCF * CFrame.new(0, 0, -3)
    task.wait(3)
    
    for i = 1, amount do
        pcall(function()
            purchaseRemote:InvokeServer("Boss Key", 1)
        end)
        task.wait(0.5)
    end
    
    Notify("✅ Bought " .. amount .. " Boss Keys")
end

local function setupBossKeyListener()
    if not merchantRemotes then return end
    
    -- Check initial stock
    task.spawn(function()
        task.wait(2)
        if stockRemote then
            local success, stock = pcall(function()
                return stockRemote:InvokeServer()
            end)
            
            if success and stock and stock.stock then
                for _, item in pairs(stock.stock) do
                    if item.name == "Boss Key" and item.stock > 0 then
                        buyBossKeys(item.stock)
                        break
                    end
                end
            end
        end
    end)
    
    -- Listen for updates
    if stockUpdateRemote then
        stockUpdateRemote.OnClientEvent:Connect(function(...)
            if not Config.AutoBuyBossKey then return end
            
            local args = {...}
            for _, arg in ipairs(args) do
                if type(arg) == "table" then
                    for _, item in pairs(arg) do
                        if type(item) == "table" and item.name == "Boss Key" then
                            local stock = item.stock or item.quantity or 0
                            if stock > 0 then
                                buyBossKeys(stock)
                            end
                            return
                        end
                    end
                end
            end
        end)
    end
end

--==================================================
-- ICHIGO EXCHANGE SYSTEM
--==================================================
local function checkIchigoRequirements()
    local bossTicketCount = Config.InventoryByRarity["Epic"]["Boss Ticket"] or 0
    
    if bossTicketCount == 0 and requestInventoryRemote then
        pcall(function() requestInventoryRemote:FireServer() end)
        task.wait(1)
        bossTicketCount = Config.InventoryByRarity["Epic"]["Boss Ticket"] or 0
    end
    
    return bossTicketCount >= 500, bossTicketCount
end

local function exchangeIchigo()
    local hasAll, count = checkIchigoRequirements()
    
    if not hasAll then
        Notify("❌ Need 500 Boss Tickets (have " .. count .. ")")
        return false
    end
    
    if exchangeRemote then
        pcall(function()
            exchangeRemote:InvokeServer("Ichigo")
        end)
        task.wait(3)
        Notify("✅ Ichigo exchanged!")
        return true
    end
    
    return false
end

--==================================================
-- SABER BOSS FARM SYSTEM
--==================================================
local function farmSaberBoss()
    Config.FarmingIchigoBoss = true
    
    while Config.FarmingIchigoBoss do
        local bossKeyCount = checkBossKeyCount()
        
        if bossKeyCount < 1 then
            Notify("❌ Not enough Boss Keys")
            break
        end
        
        -- Summon boss
        if summonBossRemote then
            pcall(function() summonBossRemote:FireServer("SaberBoss") end)
        end
        task.wait(5)
        
        -- Find boss
        local boss = nil
        for i = 1, 10 do
            boss = workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("SaberBoss")
            if boss then break end
            task.wait(2)
        end
        
        if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") then
            local bossRoot = boss.HumanoidRootPart
            local bossHum = boss.Humanoid
            
            -- Fight boss
            while boss.Parent and bossHum.Health > 0 do
                local char, hrp = getChar()
                
                hrp.CFrame = bossRoot.CFrame * CFrame.new(0, 15, 5)
                autoAttack(boss)
                
                task.wait(Config.AttackCooldown)
            end
            
            Notify("✅ Saber Boss defeated!")
            task.wait(3)
        else
            task.wait(5)
        end
    end
    
    Config.FarmingIchigoBoss = false
end

--==================================================
-- CODE REDEEMER
--==================================================
local function redeemCodes()
    if not CodesConfig or not codeRedeemRemote then
        Notify("❌ Codes not available")
        return
    end
    
    Notify("🔄 Redeeming codes...")
    
    for codeName, _ in pairs(CodesConfig.Codes) do
        if CodesConfig.IsValid and CodesConfig.IsValid(codeName) then
            pcall(function()
                codeRedeemRemote:InvokeServer(codeName)
            end)
            task.wait(0.5)
        end
    end
    
    Notify("✅ Code redemption complete!")
end

--==================================================
-- QUEST MANAGER
--==================================================
local QuestManager = {}

function QuestManager.GetQuestNPCs()
    local found = {}
    local serviceNPCs = workspace:FindFirstChild("ServiceNPCs")
    if serviceNPCs then
        for _, child in ipairs(serviceNPCs:GetChildren()) do
            if child.Name:match("^QuestNPC") then
                table.insert(found, child.Name)
            end
        end
    end
    table.sort(found)
    return #found > 0 and found or { "None" }
end

function QuestManager.Accept(npcName)
    if not npcName or npcName == "None" or not questRemote then return false end
    
    local success = pcall(function()
        questRemote:FireServer(npcName)
    end)
    
    if success then
        Notify("✅ Quest accepted from " .. npcName)
        return true
    end
    return false
end

--==================================================
-- AUTO REJOIN
--==================================================
local function setupAutoRejoin()
    if Config.AutoRejoin then
        GuiService.ErrorMessageChanged:Connect(function()
            local lastError = GuiService:GetErrorMessage()
            if lastError:find("Security") then return end
            
            task.spawn(function()
                task.wait(5)
                pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
            end)
        end)
    end
end

-- Timed rejoin
local function setupTimedRejoin()
    Config.TimedRejoinRunning = true
    
    task.spawn(function()
        local elapsed = 0
        while Config.TimedRejoinRunning and task.wait(1) do
            if not Config.TimedRejoin then
                elapsed = 0
                continue
            end
            
            elapsed = elapsed + 1
            local target = Config.RejoinDelay * 60
            
            if elapsed >= target then
                elapsed = 0
                Notify("🔄 Timed rejoin...")
                task.wait(5)
                pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
            end
        end
    end)
end

--==================================================
-- FRIEND CHECK
--==================================================
local function setupFriendCheck()
    local function checkAndKick(p)
        if not Config.FriendOnly or p == Player then return end
        
        local isFriend = false
        pcall(function() isFriend = Player:IsFriendsWith(p.UserId) end)
        
        if not isFriend then
            Player:Kick("\n[Security] Stranger detected: " .. p.Name)
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        checkAndKick(p)
    end
    
    Players.PlayerAdded:Connect(checkAndKick)
end

--==================================================
-- FPS BOOST / WHITE SCREEN
--==================================================
local function setFpsBoost(state)
    if state then
        Lighting.Brightness = 0
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0.8
            end
        end
        
        settings().Rendering.QualityLevel = 1
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
        
        settings().Rendering.QualityLevel = originalQuality
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.Ambient = originalLighting.Ambient
    end
end

local function setWhiteScreen(state)
    if state then
        RunService:Set3dRenderingEnabled(false)
    else
        RunService:Set3dRenderingEnabled(true)
    end
end

--==================================================
-- NOCLIP
--==================================================
task.spawn(function()
    RunService.Stepped:Connect(function()
        if not Config.Noclip then return end
        local char = Player.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end)

--==================================================
-- ANTI AFK
--==================================================
if Config.AntiAFK then
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

--==================================================
-- CHARACTER EVENT HANDLERS
--==================================================
Player.CharacterAdded:Connect(function(char)
    task.wait(3)
    
    -- Reapply noclip
    if Config.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Reapply FPS boost
    if Config.FpsBoost then
        setFpsBoost(true)
    end
    
    -- Reapply haki
    if Config.AutoHaki and hakiRemote then
        pcall(function() hakiRemote:FireServer("Toggle") end)
    end
    
    if Config.AutoObsHaki and obsHakiRemote then
        pcall(function() obsHakiRemote:FireServer("Toggle") end)
    end
    
    -- Scan current island
    local island = "Unknown"
    pcall(function()
        if TravelConfig and TravelConfig.GetZoneAt then
            island = TravelConfig.GetZoneAt(char.HumanoidRootPart.Position) or "Unknown"
        end
    end)
    scanCurrentIsland(island)
end)

--==================================================
-- GET MOB LIST FOR DROPDOWN
--==================================================
local function getMobList()
    local mobs = {"Auto"}
    for _, mob in ipairs(Config.MobDatabase) do
        table.insert(mobs, string.format("[Lv.%d] %s", mob.level, mob.name))
    end
    return mobs
end

--==================================================
-- GET BOSS LIST
--==================================================
local function getBossList()
    local bosses = {"None"}
    local seen = {}
    
    for _, folder in ipairs({"NPCs", "Bosses", "WorldBoss"}) do
        local f = workspace:FindFirstChild(folder)
        if f then
            for _, npc in ipairs(f:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MaxHealth >= 5000 and not seen[npc.Name] then
                        seen[npc.Name] = true
                        table.insert(bosses, npc.Name)
                    end
                end
            end
        end
    end
    
    return bosses
end

--==================================================
-- GET SUMMON BOSS LIST
--==================================================
local function getSummonBossList()
    return {"None", "Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden", "SaberAlter"}
end

--==================================================
-- GET QUEST NPC LIST
--==================================================
local function getQuestNPCList()
    return QuestManager.GetQuestNPCs()
end

--==================================================
-- BUILD MOB DATABASE ON START
--==================================================
task.spawn(function()
    task.wait(2)
    buildMobDatabase()
    scanAllIslands()
    setupBossKeyListener()
    
    if Config.AutoRejoin then setupAutoRejoin() end
    if Config.TimedRejoin then setupTimedRejoin() end
    if Config.FriendOnly then setupFriendCheck() end
end)

--==================================================
-- MAIN FARM LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        
        local char, hrp, hum = pcall(getChar) and getChar() or nil
        if not char or hum.Health <= 0 then
            task.wait(2)
            continue
        end
        
        local level = Config.PlayerData.Level
        
        -- Auto Stats
        if Config.AutoStats and statRemote then
            pcall(allocateStats)
        end
        
        -- Auto Haki
        if Config.AutoHaki and hakiRemote and not checkHakiStatus() then
            pcall(function() hakiRemote:FireServer("Toggle") end)
        end
        
        -- Auto Observation Haki
        if Config.AutoObsHaki and obsHakiRemote and not checkObservationHaki() then
            pcall(function() obsHakiRemote:FireServer("Toggle") end)
        end
        
        -- Auto Haki Quest
        if Config.HakiQuest and level >= Config.HakiMinLevel and not checkHakiStatus() then
            if tick() - Config.LastHakiCheck > 60 then
                Config.LastHakiCheck = tick()
                task.spawn(startHakiQuest)
            end
        end
        
        -- Auto Dark Blade
        if Config.AutoBuyDarkBlade and not Config.DarkBladeOwned and level >= Config.HakiMinLevel then
            task.spawn(buyDarkBlade)
        end
        
        -- Artifacts (level 4000+)
        if level >= 4000 and not Config.ArtifactsUnlocked then
            if unlockArtifacts() then
                task.spawn(equipArtifacts)
            end
        end
        
        -- Observation Haki (level 6000+)
        if level >= 6000 and not checkObservationHaki() then
            task.spawn(buyObservationHaki)
        end
        
        -- Saber Boss Farm
        if Config.FarmSaberBoss and not Config.FarmingIchigoBoss then
            task.spawn(farmSaberBoss)
        end
        
        -- Ichigo Exchange
        if Config.ExchangeIchigo and level >= Config.IchigoMinLevel then
            local hasAll, count = checkIchigoRequirements()
            if hasAll then
                task.spawn(exchangeIchigo)
            end
        end
        
        -- Auto Buy Boss Key (periodic)
        if Config.AutoBuyBossKey and purchaseRemote then
            if tick() - Config.LastBossKeyBuy > Config.BossKeyBuyInterval then
                Config.LastBossKeyBuy = tick()
                task.spawn(function()
                    if stockRemote then
                        local success, stock = pcall(function()
                            return stockRemote:InvokeServer()
                        end)
                        if success and stock and stock.stock then
                            for _, item in pairs(stock.stock) do
                                if item.name == "Boss Key" and item.stock > 0 then
                                    buyBossKeys(item.stock)
                                    break
                                end
                            end
                        end
                    end
                end)
            end
        end
        
        -- Fruit Farm
        if Config.FruitFarm and not Config.FruitFarming and level >= Config.HakiMinLevel then
            task.spawn(startFruitFarm)
        end
        
        -- Auto Farm
        if Config.AutoFarm then
            local targetMob = Config.SelectedMob
            if targetMob == "Auto" then
                _, targetMob = getTargetQuest()
            end
            
            if not targetMob then
                task.wait(1)
                continue
            end
            
            -- Accept quest
            if Config.AutoAcceptQuest and questRemote then
                local questNPC, _ = getTargetQuest()
                if questNPC then
                    pcall(function() questRemote:FireServer(questNPC) end)
                end
            end
            
            -- Check if enough mobs
            if not EntityTracker:IsAlive(targetMob, false, Config.NPCAttackThreshold) then
                task.wait(2)
                continue
            end
            
            local mob = findMob(targetMob)
            
            if mob then
                tweenToMob(mob)
                task.wait(0.2)
                
                while Config.AutoFarm and mob and mob.Parent do
                    local mobHum = mob:FindFirstChildOfClass("Humanoid")
                    if not mobHum or mobHum.Health <= 0 then break end
                    
                    tweenToMob(mob)
                    autoAttack(mob)
                    task.wait(Config.AttackCooldown)
                end
            else
                -- Teleport to island
                teleportToMobIsland(targetMob)
                task.wait(3)
            end
        end
        
        -- Auto Boss Fight
        if Config.AutoBossFight and Config.SelectedBoss ~= "None" then
            local boss = findBoss(Config.SelectedBoss)
            if boss then
                tweenToMob(boss)
                task.wait(0.2)
                
                while Config.AutoBossFight and boss and boss.Parent do
                    local bossHum = boss:FindFirstChildOfClass("Humanoid")
                    if not bossHum or bossHum.Health <= 0 then break end
                    
                    tweenToMob(boss)
                    autoAttack(boss)
                    task.wait(Config.AttackCooldown)
                end
            end
        end
        
        -- Auto Summon Boss
        if Config.AutoSummonBoss and Config.SelectedSummonBoss ~= "None" and summonBossRemote then
            pcall(function()
                summonBossRemote:FireServer(Config.SelectedSummonBoss .. "Boss", Config.SummonDifficulty)
            end)
            task.wait(3)
        end
        
        -- Special Bosses
        for bossName, data in pairs(Config.SpecialBosses) do
            if data.Auto then
                if bossName == "TrueAizen" and trueAizenRemote then
                    pcall(function() trueAizenRemote:FireServer(data.Diff) end)
                elseif bossName == "Sukuna" and spawnStrongestRemote then
                    pcall(function() spawnStrongestRemote:FireServer("StrongestHistory", data.Diff) end)
                elseif bossName == "Gojo" and spawnStrongestRemote then
                    pcall(function() spawnStrongestRemote:FireServer("StrongestToday", data.Diff) end)
                elseif bossName == "Rimuru" and rimuruRemote then
                    pcall(function() rimuruRemote:FireServer(data.Diff) end)
                elseif bossName == "Anos" and spawnAnosRemote then
                    pcall(function() spawnAnosRemote:FireServer("Anos", data.Diff) end)
                end
                task.wait(2)
            end
        end
        
        -- Auto Dungeon
        if Config.AutoDungeon and dungeonRemote then
            pcall(function() dungeonRemote:FireServer("Enter", Config.DungeonType) end)
            task.wait(3)
        end
        
        -- Auto Boss Rush
        if Config.AutoBossRush and bossRushRemote then
            pcall(function() bossRushRemote:FireServer("Enter") end)
            task.wait(3)
        end
        
        -- Auto Chest
        if Config.AutoChest and chestRemote then
            local chestTypes = {"Wood", "Iron", "Gold", "Diamond", "Legendary"}
            for _, chestType in ipairs(chestTypes) do
                pcall(function() chestRemote:FireServer("Open", chestType) end)
            end
        end
        
        -- Auto Craft
        if Config.AutoCraft.SlimeKey and slimeCraftRemote then
            pcall(function() slimeCraftRemote:InvokeServer("SlimeKey", Config.CraftAmount) end)
        end
        if Config.AutoCraft.DivineGrail and grailCraftRemote then
            pcall(function() grailCraftRemote:InvokeServer("DivineGrail", Config.CraftAmount) end)
        end
    end
end)

--==================================================
-- UI SECTIONS
--==================================================

-- MAIN TAB
local MainInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MainInfoSection:AddParagraph({
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

local startTime = tick()
local function getUptime()
    local uptime = tick() - startTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function getServerInfo()
    local players = Players:GetPlayers()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
    return "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
           "Ping: " .. ping .. "ms\n" ..
           "Uptime: " .. getUptime() .. "\n" ..
           "Level: " .. Config.PlayerData.Level .. " | 💰 " .. Config.PlayerData.Money .. " | 💎 " .. Config.PlayerData.Gems
end

local ServerInfoPara = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = getServerInfo(),
    Image = "server",
    ImageSize = 48,
    Buttons = {
        {
            Title = "🔄 Refresh",
            Callback = function()
                ServerInfoPara:SetDesc(getServerInfo())
            end
        }
    }
})

-- Auto refresh server info
task.spawn(function()
    while true do
        task.wait(5)
        ServerInfoPara:SetDesc(getServerInfo())
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

-- Update active features
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

-- FARM TAB
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
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm = Value
        Notify(Value and "Auto Farm Enabled" or "Auto Farm Disabled")
    end
})

FarmMainSection:AddDropdown({
    Name = "SELECT MOB",
    Default = "Auto",
    Options = getMobList(),
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        if Value == "Auto" then
            Config.SelectedMob = "Auto"
        else
            Config.SelectedMob = Value:match("%] (.+)$") or Value
        end
    end
})

FarmMainSection:AddButton({
    Name = "🔄 REFRESH MOB LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildMobDatabase()
        local mobs = getMobList()
        Notify("✅ Found " .. #Config.MobDatabase .. " mobs")
    end
})

FarmMainSection:AddButton({
    Name = "🗺️ SCAN ALL ISLANDS",
    Icon = "map",
    Outline = true,
    Callback = function()
        task.spawn(function()
            local count = scanAllIslands()
            Notify("✅ Scanned " .. count .. " mobs")
        end)
    end
})

FarmMainSection:AddToggle({
    Name = "AUTO ACCEPT QUEST",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoQuest",
    Save = true,
    Callback = function(Value)
        Config.AutoAcceptQuest = Value
    end
})

FarmMainSection:AddSlider({
    Name = "NPC ATTACK THRESHOLD",
    Min = 1,
    Max = 10,
    Default = 5,
    Increment = 1,
    ValueName = "mobs",
    Outline = true,
    Callback = function(Value)
        Config.NPCAttackThreshold = Value
    end
})

local MovementSection = FarmTab:AddSection({
    Name = "🚀 MOVEMENT SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MovementSection:AddDropdown({
    Name = "MOVE MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Outline = true,
    Callback = function(Value)
        Config.MoveMode = Value
    end
})

MovementSection:AddToggle({
    Name = "PLANK MODE (HOVER)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(Value)
        Config.PlankMode = Value
    end
})

MovementSection:AddSlider({
    Name = "FARM HEIGHT",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 5,
    ValueName = "studs",
    Outline = true,
    Callback = function(Value)
        Config.FarmHeight = Value
    end
})

MovementSection:AddSlider({
    Name = "FARM SPEED",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    ValueName = "studs/s",
    Outline = true,
    Callback = function(Value)
        Config.FarmSpeed = Value
    end
})

MovementSection:AddSlider({
    Name = "ATTACK COOLDOWN",
    Min = 0.1,
    Max = 1,
    Default = 0.3,
    Increment = 0.05,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Config.AttackCooldown = Value
    end
})

-- BOSS TAB
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
    end
})

BossMainSection:AddDropdown({
    Name = "SELECT BOSS",
    Default = "None",
    Options = getBossList(),
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        Config.SelectedBoss = Value
    end
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
    end
})

BossMainSection:AddDropdown({
    Name = "SUMMON BOSS",
    Default = "None",
    Options = getSummonBossList(),
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        Config.SelectedSummonBoss = Value
    end
})

BossMainSection:AddDropdown({
    Name = "DIFFICULTY",
    Default = "Normal",
    Options = {"Normal", "Medium", "Hard", "Extreme"},
    Multi = false,
    Outline = true,
    Callback = function(Value)
        Config.SummonDifficulty = Value
    end
})

BossMainSection:AddButton({
    Name = "🔄 REFRESH BOSS LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local bosses = getBossList()
        Notify("✅ Found " .. (#bosses - 1) .. " bosses")
    end
})

local SpecialSection = BossTab:AddSection({
    Name = "✨ SPECIAL BOSSES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

for bossName, _ in pairs(Config.SpecialBosses) do
    SpecialSection:AddToggle({
        Name = "AUTO " .. bossName:upper(),
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Special_" .. bossName,
        Save = true,
        Callback = function(Value)
            Config.SpecialBosses[bossName].Auto = Value
        end
    })
    
    SpecialSection:AddDropdown({
        Name = bossName .. " DIFFICULTY",
        Default = "Normal",
        Options = {"Normal", "Medium", "Hard", "Extreme"},
        Multi = false,
        Outline = true,
        Callback = function(Value)
            Config.SpecialBosses[bossName].Diff = Value
        end
    })
end

-- SKILLS TAB
local SkillMainSection = SkillsTab:AddSection({
    Name = "🔮 AUTO SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local skillKeys = {"Z", "X", "C", "V", "F"}
local skillSlots = {Z=1, X=2, C=3, V=4, F=5}

for _, key in ipairs(skillKeys) do
    SkillMainSection:AddToggle({
        Name = "AUTO SKILL " .. key .. " (Slot " .. skillSlots[key] .. ")",
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Skill_" .. key,
        Save = true,
        Callback = function(Value)
            Config.AutoSkills[key] = Value
        end
    })
end

SkillMainSection:AddButton({
    Name = "🔥 ALL SKILLS ON",
    Icon = "toggle-right",
    Outline = true,
    Callback = function()
        for key, _ in pairs(Config.AutoSkills) do
            Config.AutoSkills[key] = true
        end
        Notify("✅ All skills enabled")
    end
})

SkillMainSection:AddButton({
    Name = "❌ ALL SKILLS OFF",
    Icon = "toggle-left",
    Outline = true,
    Callback = function()
        for key, _ in pairs(Config.AutoSkills) do
            Config.AutoSkills[key] = false
        end
        Notify("❌ All skills disabled")
    end
})

SkillMainSection:AddSlider({
    Name = "SKILL COOLDOWN",
    Min = 0.1,
    Max = 3,
    Default = 0.5,
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Config.SkillCooldown = Value
    end
})

-- GAMEMODES TAB
local DungeonSection = GamemodesTab:AddSection({
    Name = "🏰 DUNGEON",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonSection:AddToggle({
    Name = "AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        Config.AutoDungeon = Value
    end
})

DungeonSection:AddDropdown({
    Name = "DUNGEON TYPE",
    Default = "Shadow",
    Options = {"Shadow", "Rune", "Cid"},
    Multi = false,
    Outline = true,
    Callback = function(Value)
        Config.DungeonType = Value
    end
})

DungeonSection:AddToggle({
    Name = "AUTO BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossRush",
    Save = true,
    Callback = function(Value)
        Config.AutoBossRush = Value
    end
})

-- ITEMS TAB
local ItemsMainSection = ItemsTab:AddSection({
    Name = "📦 AUTO ITEMS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ItemsMainSection:AddToggle({
    Name = "AUTO OPEN CHESTS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(Value)
        Config.AutoChest = Value
    end
})

ItemsMainSection:AddToggle({
    Name = "AUTO BUY BOSS KEY",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBossKey",
    Save = true,
    Callback = function(Value)
        Config.AutoBuyBossKey = Value
    end
})

ItemsMainSection:AddSlider({
    Name = "BOSS KEY BUY INTERVAL",
    Min = 5,
    Max = 60,
    Default = 30,
    Increment = 5,
    ValueName = "minutes",
    Outline = true,
    Callback = function(Value)
        Config.BossKeyBuyInterval = Value * 60
    end
})

local CraftSection = ItemsTab:AddSection({
    Name = "⚒️ AUTO CRAFT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

CraftSection:AddToggle({
    Name = "AUTO CRAFT SLIME KEY",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "CraftSlime",
    Save = true,
    Callback = function(Value)
        Config.AutoCraft.SlimeKey = Value
    end
})

CraftSection:AddToggle({
    Name = "AUTO CRAFT DIVINE GRAIL",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "CraftGrail",
    Save = true,
    Callback = function(Value)
        Config.AutoCraft.DivineGrail = Value
    end
})

CraftSection:AddSlider({
    Name = "CRAFT AMOUNT",
    Min = 1,
    Max = 10,
    Default = 1,
    Increment = 1,
    ValueName = "items",
    Outline = true,
    Callback = function(Value)
        Config.CraftAmount = Value
    end
})

CraftSection:AddButton({
    Name = "📜 REDEEM CODES",
    Icon = "gift",
    Outline = true,
    Callback = function()
        task.spawn(redeemCodes)
    end
})

-- HAKI TAB
local HakiMainSection = HakiTab:AddSection({
    Name = "⬛ HAKI SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HakiMainSection:AddToggle({
    Name = "AUTO ARMAMENT HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(Value)
        Config.AutoHaki = Value
    end
})

HakiMainSection:AddToggle({
    Name = "AUTO OBSERVATION HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoObs",
    Save = true,
    Callback = function(Value)
        Config.AutoObsHaki = Value
    end
})

HakiMainSection:AddToggle({
    Name = "AUTO HAKI QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HakiQuest",
    Save = true,
    Callback = function(Value)
        Config.HakiQuest = Value
    end
})

HakiMainSection:AddSlider({
    Name = "HAKI MIN LEVEL",
    Min = 1000,
    Max = 10000,
    Default = 3000,
    Increment = 100,
    ValueName = "level",
    Outline = true,
    Callback = function(Value)
        Config.HakiMinLevel = Value
    end
})

HakiMainSection:AddButton({
    Name = "CHECK HAKI STATUS",
    Icon = "eye",
    Outline = true,
    Callback = function()
        local hasArm = checkHakiStatus()
        local hasObs = checkObservationHaki()
        Notify("Armament: " .. (hasArm and "✅" or "❌") .. " | Observation: " .. (hasObs and "✅" or "❌"))
    end
})

HakiMainSection:AddToggle({
    Name = "AUTO BUY DARK BLADE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDarkBlade",
    Save = true,
    Callback = function(Value)
        Config.AutoBuyDarkBlade = Value
    end
})

-- STATS TAB
local StatsMainSection = StatsTab:AddSection({
    Name = "📊 STATS SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

StatsMainSection:AddToggle({
    Name = "AUTO ALLOCATE STATS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoStats",
    Save = true,
    Callback = function(Value)
        Config.AutoStats = Value
    end
})

StatsMainSection:AddSlider({
    Name = "SWORD % (Level 3000+)",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 5,
    ValueName = "%",
    Outline = true,
    Callback = function(Value)
        Config.StatSword = Value
    end
})

StatsMainSection:AddSlider({
    Name = "DEFENSE % (Level 3000+)",
    Min = 0,
    Max = 100,
    Default = 30,
    Increment = 5,
    ValueName = "%",
    Outline = true,
    Callback = function(Value)
        Config.StatDefense = Value
    end
})

StatsMainSection:AddSlider({
    Name = "POWER % (Level 3000+)",
    Min = 0,
    Max = 100,
    Default = 20,
    Increment = 5,
    ValueName = "%",
    Outline = true,
    Callback = function(Value)
        Config.StatPower = Value
    end
})

StatsMainSection:AddButton({
    Name = "RESET STATS",
    Icon = "rotate-ccw",
    Outline = true,
    Callback = function()
        resetStats()
        Notify("✅ Stats reset!")
    end
})

-- SETTINGS TAB
local UtilitySection = SettingsTab:AddSection({
    Name = "🔧 UTILITY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

UtilitySection:AddToggle({
    Name = "NOCLIP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Noclip = Value
        Notify(Value and "Noclip Enabled" or "Noclip Disabled")
    end
})

UtilitySection:AddToggle({
    Name = "ANTI AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.AntiAFK = Value
    end
})

UtilitySection:AddToggle({
    Name = "ANTI VOID",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiVoid",
    Save = true,
    Callback = function(Value)
        Config.AntiVoid = Value
    end
})

UtilitySection:AddToggle({
    Name = "ANTI IDLE",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiIdle",
    Save = true,
    Callback = function(Value)
        Config.AntiIdle = Value
    end
})

UtilitySection:AddToggle({
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

UtilitySection:AddToggle({
    Name = "WHITE SCREEN",
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

local RejoinSection = SettingsTab:AddSection({
    Name = "🔄 REJOIN SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

RejoinSection:AddToggle({
    Name = "AUTO REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value)
        Config.AutoRejoin = Value
        if Value then setupAutoRejoin() end
    end
})

RejoinSection:AddToggle({
    Name = "TIMED REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "TimedRejoin",
    Save = true,
    Callback = function(Value)
        Config.TimedRejoin = Value
        if Value then setupTimedRejoin() end
    end
})

RejoinSection:AddSlider({
    Name = "REJOIN DELAY",
    Min = 1,
    Max = 120,
    Default = 10,
    Increment = 1,
    ValueName = "minutes",
    Outline = true,
    Callback = function(Value)
        Config.RejoinDelay = Value
    end
})

RejoinSection:AddToggle({
    Name = "FRIEND ONLY MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FriendOnly",
    Save = true,
    Callback = function(Value)
        Config.FriendOnly = Value
        if Value then setupFriendCheck() end
    end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

--==================================================
-- KEYBINDS
--==================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        Config.AutoFarm = not Config.AutoFarm
        Notify(Config.AutoFarm and "✅ Auto Farm ON" or "❌ Auto Farm OFF")
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.AutoBossFight = not Config.AutoBossFight
        Notify(Config.AutoBossFight and "✅ Boss Fight ON" or "❌ Boss Fight OFF")
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Window:Toggle()
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 to toggle menu | F2 Toggle Farm | F3 Toggle Boss")

print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - ULTIMATE HUB v2.1 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm - Mob database + Island scanner")
print("✅ Auto Boss - Fight, Summon, Special bosses")
print("✅ Auto Skills - Z,X,C,V,F with cooldown")
print("✅ Auto Gamemodes - Dungeon, Boss Rush")
print("✅ Auto Items - Chests, Boss Key, Crafting")
print("✅ Auto Haki - Armament, Observation, Quest")
print("✅ Auto Dark Blade - Buy and equip")
print("✅ Auto Fruit Farm - Target fruit farming")
print("✅ Auto Stats - Custom distribution")
print("✅ Utility - Noclip, Anti AFK, Anti Void, FPS Boost")
print("✅ COMPATIBLE with all executors - No hookmetamethod!")
print("═══════════════════════════════════════════════════════")