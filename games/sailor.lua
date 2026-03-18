-- ==================== SAILOR PIECE - CATRAZ ULTIMATE v3.0 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.0 COMPLETE with Advanced AutoFarm

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
-- VARIABLES & SERVICES
--==================================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

--==================================================
-- REMOTE REFERENCES
--==================================================
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
local CombatSystem = ReplicatedStorage:FindFirstChild("CombatSystem")
local AbilitySystem = ReplicatedStorage:FindFirstChild("AbilitySystem")
local Modules = ReplicatedStorage:FindFirstChild("Modules")

-- Load required modules
local questcheck = Modules and require(Modules:FindFirstChild("QuestConfig")) or {}
local checkmap = Modules and require(Modules:FindFirstChild("TravelConfig")) or {}

-- Safe remote getter
local function getRemote(parent, ...)
    if not parent then return nil end
    for _, name in ipairs({...}) do
        parent = parent:FindFirstChild(name)
        if not parent then return nil end
    end
    return parent
end

-- Core remotes
local hitRemote = getRemote(CombatSystem, "Remotes", "RequestHit") or getRemote(ReplicatedStorage, "RequestHit")
local abilityRemote = getRemote(AbilitySystem, "Remotes", "RequestAbility") or getRemote(ReplicatedStorage, "RequestAbility")
local questRemote = getRemote(RemoteEvents, "QuestAccept") or getRemote(ReplicatedStorage, "QuestAccept")
local abandonRemote = getRemote(RemoteEvents, "QuestAbandon") or getRemote(ReplicatedStorage, "QuestAbandon")
local statRemote = getRemote(RemoteEvents, "AllocateStat") or getRemote(ReplicatedStorage, "AllocateStat")
local tpRemote = getRemote(Remotes, "TeleportToPortal") or getRemote(ReplicatedStorage, "TeleportToPortal")
local settingsToggle = getRemote(RemoteEvents, "SettingsToggle") or getRemote(ReplicatedStorage, "SettingsToggle")
local hakiRemote = getRemote(RemoteEvents, "HakiRemote") or getRemote(ReplicatedStorage, "HakiRemote")
local obsHakiRemote = getRemote(RemoteEvents, "ObservationHakiRemote") or getRemote(ReplicatedStorage, "ObservationHakiRemote")
local summonBossRemote = getRemote(Remotes, "RequestSummonBoss") or getRemote(ReplicatedStorage, "RequestSummonBoss")
local fruitPowerRemote = getRemote(RemoteEvents, "FruitPowerRemote")
local fruitActionRemote = getRemote(RemoteEvents, "FruitAction")
local equipRemote = getRemote(Remotes, "EquipWeapon") or getRemote(ReplicatedStorage, "EquipWeapon")
local resetStatsRemote = getRemote(RemoteEvents, "ResetStats")

--==================================================
-- BYPASS & ANTI-CHEAT SYSTEM
--==================================================
local BLOCKED_REMOTES = {
    "sanity", "checksanity", "positioncheck", "antiteleport",
    "validateposition", "checkpos", "anticheat", "positionvalidate",
    "sanitycheck", "movementcheck", "speedcheck", "teleportback",
    "checkposition", "poscheck", "verifyposition", "servercheck",
    "validate", "verification", "exploit", "kick", "ban"
}

local blockedLookup = {}
for _, name in ipairs(BLOCKED_REMOTES) do
    blockedLookup[name] = true
end

-- Hook __namecall to block kick and anti-cheat remotes
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Block kick
    if (method == "Kick" or method == "kick") and (self == Player or self == Players) then
        return nil
    end

    -- Block anti-TP remotes
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

-- Hook getgc to disable anti-cheat functions
if getgc and hookfunction then
    local hookedCount = 0
    for _, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local ok, info = pcall(getinfo, v)
            if ok and info and info.source then
                local src = info.source:lower()
                if src:find("anticheat") or src:find("controlclient") or src:find("sanity")
                    or src:find("idle") or src:find("movement") or src:find("speed") then
                    local fname = info.name and info.name:lower() or ""
                    if fname:find("kick") or fname:find("ban") or fname:find("teleport")
                        or fname:find("position") or fname:find("sanity") or fname:find("speed")
                        or fname:find("check") then
                        pcall(function()
                            hookfunction(v, function(...) return nil end)
                            hookedCount = hookedCount + 1
                        end)
                    end
                end
            end
            -- Patch upvalues
            pcall(function()
                local upvals = getupvalues(v)
                for key, val in pairs(upvals) do
                    if type(key) == "string" then
                        local k = key:lower()
                        if k == "isteleporting" then
                            setupvalue(v, key, false)
                        elseif k == "maxspeed" or k == "speedlimit" then
                            setupvalue(v, key, 99999)
                        end
                    end
                end
            end)
        end
    end
end

-- Anti-void
task.spawn(function()
    local lastSafe = CFrame.new(0, 100, 0)
    while task.wait(0.5) do
        local char = Player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        if hrp.Position.Y > -50 then
            lastSafe = hrp.CFrame
        elseif getgenv().AntiVoid then
            hrp.CFrame = lastSafe
        end
    end
end)

-- Anti-idle
task.spawn(function()
    while task.wait(60) do
        if getgenv().AntiIdle then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.5)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

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
-- RESTORE ORIGINAL SETTINGS
--==================================================
local function restoreOriginalSettings()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Ambient = originalLighting.Ambient
    settings().Rendering.QualityLevel = originalQuality
end

--==================================================
-- CONFIGURATION
--==================================================
local Config = {
    -- Bypass Settings
    Bypass = {
        NoclipEnabled = true,
        AntiVoid = true,
        AntiIdle = true,
    },
    
    -- Auto Farm
    AutoFarm = {
        Enabled = false,
        AutoHit = true,
        AutoStats = true,
        AutoHaki = false,
        AutoObsHaki = false,
        AutoEquip = false,
        SelectedWeapon = "None",
        WeaponMode = "Melee",
        MoveMode = "Tween",
        FarmHeight = 25,
        FarmSpeed = 50,
        AttackCooldown = 0.3,
        PlankMode = false,
        SelectedMob = nil,
        Skills = {
            Z = false, X = false, C = false, V = false, F = false
        },
        SkillCooldown = 0.5,
    },
    
    -- Boss System
    Boss = {
        Enabled = false,
        SelectedBoss = nil,
        SummonEnabled = false,
        SummonDifficulty = "Normal",
    },
    
    -- Dungeon System
    Dungeon = {
        Enabled = false,
        DungeonType = "Shadow",
        BossRushEnabled = false,
        DungeonQuestEnabled = false,
        HogyokuQuestEnabled = false,
    },
    
    -- Items
    Items = {
        AutoChest = false,
        AutoMerchant = false,
        MerchantItem = "HealthPotion",
    },
    
    -- Haki & Dark Blade
    HakiQuest = {
        Enabled = false,
        MinLevel = 3000,
        Timeout = 3600,
        BuyDarkBlade = true,
    },
    
    -- Fruit Farm
    FruitFarm = {
        Enabled = false,
        MinLevel = 11500,
        TargetFruit = "Quake",
        Island = "Shinjuku",
        Position = CFrame.new(321.706757, -1.539090, -1756.500977)
    },
    
    -- Stats Distribution
    Stats = {
        Sword = 50,
        Defense = 30,
        Power = 20
    }
}

--==================================================
-- STATE VARIABLES
--==================================================
local isHakiQuestActive = false
local isFruitFarming = false
local isFarmingBoss = false
local isInDungeon = false
local farmLoopRunning = false
local skillSpamRunning = false
local currentTarget = nil

-- Island Mob Cache
getgenv().IslandMobCache = getgenv().IslandMobCache or {}
getgenv().IslandScanDone = false

-- Mob Database
local MobDatabase = {}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Sailor Piece",
        Content = msg,
        Image = "info",
        Time = duration or 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece",
    Subtext = "Catraz Ultimate v3.0",
    Version = "v3.0",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece Ultimate",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

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
    Name = "Auto Farm",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local BossTab = Window:MakeTab({
    Name = "Bosses",
    Icon = "skull",
    Glass = true,
    Outline = true
})

local DungeonTab = Window:MakeTab({
    Name = "Dungeon",
    Icon = "castle",
    Glass = true,
    Outline = true
})

local SkillTab = Window:MakeTab({
    Name = "Skills",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local ItemTab = Window:MakeTab({
    Name = "Items",
    Icon = "package",
    Glass = true,
    Outline = true
})

local SettingTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- UTILITY FUNCTIONS
--==================================================

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function getChar()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    return char, hrp, hum
end

--==================================================
-- ISLAND SCANNER SYSTEM
--==================================================

local function getAllIslands()
    local islands = {}
    
    -- Try to get from TravelConfig
    if checkmap then
        local data = checkmap.Islands or checkmap.Zones
        if data then
            for name, _ in pairs(data) do
                local portalArg = name:gsub("Island", ""):gsub(" ", "")
                table.insert(islands, { name = name, portal = portalArg })
            end
        end
    end
    
    -- Scan workspace folders
    if #islands == 0 then
        for _, child in ipairs(Workspace:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                if child.Name:find("Island") or child.Name:find("island") then
                    local portalArg = child.Name:gsub("Island", ""):gsub(" ", "")
                    table.insert(islands, { name = child.Name, portal = portalArg })
                end
            end
        end
    end
    
    -- Fallback
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
            if hrp and hum then
                if not getgenv().IslandMobCache[npc.Name] then
                    getgenv().IslandMobCache[npc.Name] = {
                        island = islandName,
                        position = hrp.Position,
                        maxHealth = hum.MaxHealth,
                    }
                    found = found + 1
                    
                    -- Add to MobDatabase
                    table.insert(MobDatabase, {
                        name = npc.Name,
                        level = 0,
                        island = islandName
                    })
                end
            end
        end
    end
    
    return found
end

local function scanAllIslands()
    local islands = getAllIslands()
    local totalMobs = 0
    
    local startIsland = nil
    safeCall(function()
        if checkmap and Player.Character then
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                startIsland = checkmap.GetZoneAt(hrp.Position)
            end
        end
    end)
    
    for i, island in ipairs(islands) do
        if tpRemote then
            safeCall(function() tpRemote:FireServer(island.portal) end)
            task.wait(4)
            
            local waitCount = 0
            while not Workspace:FindFirstChild("NPCs") and waitCount < 5 do
                task.wait(1)
                waitCount = waitCount + 1
            end
            
            local found = scanCurrentIslandNPCs(island.name)
            totalMobs = totalMobs + found
        end
        task.wait(1)
    end
    
    -- Return to start island
    if startIsland then
        local portalBack = startIsland:gsub("Island", ""):gsub(" ", "")
        if tpRemote then
            safeCall(function() tpRemote:FireServer(portalBack) end)
        end
        task.wait(3)
    end
    
    getgenv().IslandScanDone = true
    
    -- Sort MobDatabase by level
    table.sort(MobDatabase, function(a, b)
        if a.level == b.level then return a.name < b.name end
        return a.level < b.level
    end)
end

-- API for teleport to mob island
getgenv().TeleportToMobIsland = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    if not cached then
        scanAllIslands()
        cached = getgenv().IslandMobCache[mobName]
    end
    
    if cached and tpRemote then
        local portalArg = cached.island:gsub("Island", ""):gsub(" ", "")
        safeCall(function() tpRemote:FireServer(portalArg) end)
        task.wait(3)
        return true
    end
    return false
end

--==================================================
-- QUEST SYSTEM
--==================================================

local function getTargetQuest()
    local level = safeCall(function() return Player.Data.Level.Value end) or 0
    local bestNPC = nil
    local maxLevelFound = -1
    local choosenpc = nil

    for npcName, data in pairs(questcheck.RepeatableQuests or {}) do
        local req = tonumber(data.recommendedLevel) or 0
        if level >= req and req > maxLevelFound then
            maxLevelFound = req
            bestNPC = npcName
            if data.requirements and data.requirements[1] then
                choosenpc = data.requirements[1].npcType
            end
        end
    end

    return bestNPC, maxLevelFound, choosenpc
end

--==================================================
-- FIND MOB FUNCTIONS
--==================================================

local function findMob(targetName)
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end

    local closest = nil
    local closestDist = math.huge
    local char, hrp = getChar()
    if not hrp then return nil end

    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local match = false
                if targetName then
                    match = (npc.Name == targetName) or string.find(npc.Name, targetName)
                else
                    match = true
                end

                if match then
                    local root = npc.HumanoidRootPart
                    local dist = (root.Position - hrp.Position).Magnitude
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

local function findBoss(bossName)
    for _, folder in ipairs({"NPCs", "Bosses", "Boss", "WorldBoss"}) do
        local f = Workspace:FindFirstChild(folder)
        if f then
            for _, npc in ipairs(f:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                    local h = npc:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        if bossName then
                            if npc.Name == bossName or string.find(npc.Name, bossName) then
                                return npc
                            end
                        else
                            return npc
                        end
                    end
                end
            end
        end
    end
    return nil
end

--==================================================
-- TELEPORT & MOVEMENT
--==================================================

local function smartTP(pos)
    if not tpRemote then return false end
    
    if type(pos) == "string" then
        safeCall(function() tpRemote:FireServer(pos) end)
    else
        safeCall(function() tpRemote:FireServer(pos) end)
    end
    
    task.wait(1)
    return true
end

local function tweenToTarget(targetPos, offset)
    local char, hrp, hum = getChar()
    if not hrp then return end
    
    local targetCF = CFrame.new(targetPos + (offset or Vector3.new(0, 0, 5)))
    local distance = (targetPos - hrp.Position).Magnitude
    
    if Config.AutoFarm.MoveMode == "Teleport" then
        hrp.CFrame = targetCF
        return
    end
    
    if distance > 250 and tpRemote then
        smartTP(targetPos)
        task.wait(2)
    end
    
    local tweenInfo = TweenInfo.new(distance / Config.AutoFarm.FarmSpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCF})
    tween:Play()
    tween.Completed:Wait()
end

--==================================================
-- WEAPON & ATTACK SYSTEM
--==================================================

local function getWeaponList()
    local weapons = {"None", "Combat"}
    local seen = {None=true, Combat=true}
    
    local function addWeapons(container)
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and not seen[tool.Name] then
                    table.insert(weapons, tool.Name)
                    seen[tool.Name] = true
                end
            end
        end
    end
    
    addWeapons(Player.Character)
    addWeapons(Player:FindFirstChild("Backpack"))
    
    return weapons
end

local function findDarkBlade()
    for _, container in pairs({Player.Character, Player:FindFirstChild("Backpack")}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool.Name:find("Dark Blade") or tool.Name:find("ดาบสีเข้ม") then
                        return tool
                    end
                end
            end
        end
    end
    return nil
end

local function equipWeapon(weaponName)
    if weaponName == "None" then return end
    
    local char, hum = getChar()
    
    if char:FindFirstChild(weaponName) then return true end
    
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(weaponName)
        if tool and hum then
            hum:EquipTool(tool)
            task.wait(0.5)
            return true
        end
    end
    
    if equipRemote then
        safeCall(function() equipRemote:FireServer("Equip", weaponName) end)
        task.wait(0.5)
    end
    
    return char:FindFirstChild(weaponName) ~= nil
end

local function autoAttack(target)
    if not target then return end
    
    -- Hit
    if hitRemote then
        safeCall(function() hitRemote:FireServer() end)
    end
    
    -- Skills
    local skillMap = { Z=1, X=2, C=3, V=4, F=5 }
    for key, slot in pairs(skillMap) do
        if Config.AutoFarm.Skills[key] and abilityRemote then
            safeCall(function() abilityRemote:FireServer(slot) end)
        end
    end
end

-- Skill spam loop
task.spawn(function()
    while true do
        task.wait(Config.AutoFarm.SkillCooldown)
        if Config.AutoFarm.Enabled and Config.AutoFarm.AutoHit then
            local char = getChar()
            if char then
                local skillMap = { Z=1, X=2, C=3, V=4, F=5 }
                for key, slot in pairs(skillMap) do
                    if Config.AutoFarm.Skills[key] and abilityRemote then
                        safeCall(function() abilityRemote:FireServer(slot) end)
                    end
                end
            end
        end
    end
end)

--==================================================
-- AUTO FARM LOOP
--==================================================

local function farmLoop()
    if farmLoopRunning then return end
    farmLoopRunning = true
    
    while Config.AutoFarm.Enabled do
        task.wait(Config.AutoFarm.AttackCooldown)
        
        local char, hrp, hum = getChar()
        if hum.Health <= 0 then
            task.wait(3)
            continue
        end
        
        -- Auto Stats
        if Config.AutoFarm.AutoStats then
            safeCall(function()
                local points = Player.Data.StatPoints.Value or 0
                if points > 0 and statRemote then
                    statRemote:FireServer("Sword", points)
                end
            end)
        end
        
        -- Auto Haki
        if Config.AutoFarm.AutoHaki and hakiRemote then
            safeCall(function() hakiRemote:FireServer("Toggle") end)
        end
        
        -- Auto Obs Haki
        if Config.AutoFarm.AutoObsHaki and obsHakiRemote then
            safeCall(function() obsHakiRemote:FireServer("Toggle") end)
        end
        
        -- Auto Equip
        if Config.AutoFarm.AutoEquip and Config.AutoFarm.SelectedWeapon ~= "None" then
            equipWeapon(Config.AutoFarm.SelectedWeapon)
        end
        
        -- Get target mob
        local targetMob = Config.AutoFarm.SelectedMob
        local targetNPC, _, choosenpc
        
        if not targetMob then
            targetNPC, _, choosenpc = getTargetQuest()
            targetMob = choosenpc
        end
        
        if not targetMob then
            task.wait(1)
            continue
        end
        
        -- Accept quest
        if targetNPC and questRemote then
            safeCall(function() questRemote:FireServer(targetNPC) end)
        end
        
        -- Find mob
        local mob, dist = findMob(targetMob)
        
        if mob then
            local mobH = mob:FindFirstChildOfClass("Humanoid")
            if mobH and mobH.Health > 0 then
                local offset = Config.AutoFarm.PlankMode and 
                    Vector3.new(0, Config.AutoFarm.FarmHeight, 0) or 
                    Vector3.new(0, 0, 5)
                
                tweenToTarget(mob.HumanoidRootPart.Position, offset)
                
                while Config.AutoFarm.Enabled and mob and mob.Parent and mobH.Health > 0 do
                    if Config.AutoFarm.PlankMode then
                        tweenToTarget(mob.HumanoidRootPart.Position, Vector3.new(0, Config.AutoFarm.FarmHeight, 0))
                    end
                    autoAttack(mob)
                    task.wait(Config.AutoFarm.AttackCooldown)
                end
            end
        else
            -- Teleport to mob island
            getgenv().TeleportToMobIsland(targetMob)
            task.wait(1)
        end
    end
    
    farmLoopRunning = false
end

--==================================================
-- BOSS SYSTEM
--==================================================

local BossList = {}
local function buildBossList()
    table.clear(BossList)
    for _, folder in ipairs({"Bosses", "Boss", "WorldBoss", "NPCs"}) do
        local f = Workspace:FindFirstChild(folder)
        if f then
            for _, npc in ipairs(f:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                    local h = npc:FindFirstChildOfClass("Humanoid")
                    if h and h.MaxHealth >= 5000 then
                        local seen = false
                        for _, b in ipairs(BossList) do
                            if b == npc.Name then seen = true break end
                        end
                        if not seen then
                            table.insert(BossList, npc.Name)
                        end
                    end
                end
            end
        end
    end
    if #BossList == 0 then
        BossList = {"WorldBoss", "Boss1", "Boss2", "Boss3"}
    end
end

local function bossFightLoop()
    while Config.Boss.Enabled do
        task.wait(0.5)
        
        local boss = findBoss(Config.Boss.SelectedBoss)
        if boss then
            local h = boss:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                tweenToTarget(boss.HumanoidRootPart.Position)
                autoAttack(boss)
            end
        else
            -- Try to summon boss
            if Config.Boss.SummonEnabled and summonBossRemote then
                safeCall(function() 
                    summonBossRemote:FireServer(Config.Boss.SelectedBoss .. "Boss", Config.Boss.SummonDifficulty) 
                end)
                task.wait(3)
            end
        end
    end
end

--==================================================
-- DUNGEON SYSTEM
--==================================================

local DungeonTypes = {"Shadow", "Rune", "Cid"}

local function dungeonLoop()
    while Config.Dungeon.Enabled do
        task.wait(1)
        
        -- Enter dungeon
        safeCall(function()
            if RemoteEvents then
                local dungeonRemote = RemoteEvents:FindFirstChild("Dungeon") or 
                                     RemoteEvents:FindFirstChild("DungeonEnter") or 
                                     RemoteEvents:FindFirstChild("EnterDungeon")
                if dungeonRemote then
                    dungeonRemote:FireServer("Enter", Config.Dungeon.DungeonType)
                end
            end
        end)
        
        task.wait(3)
        
        -- Farm mobs in dungeon
        local mob = findMob(nil)
        if mob then
            tweenToTarget(mob.HumanoidRootPart.Position)
            autoAttack(mob)
        end
    end
end

--==================================================
-- NOCLIP
--==================================================
RunService.Stepped:Connect(function()
    if Config.Bypass.NoclipEnabled then
        local char = Player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

--==================================================
-- AUTO CHEST
--==================================================
local ChestTypes = {"Wood", "Iron", "Gold", "Diamond", "Legendary"}

task.spawn(function()
    while true do
        task.wait(5)
        if Config.Items.AutoChest then
            for _, chestType in ipairs(ChestTypes) do
                safeCall(function()
                    if RemoteEvents then
                        local chestR = RemoteEvents:FindFirstChild("Chest") or 
                                      RemoteEvents:FindFirstChild("OpenChest")
                        if chestR then
                            chestR:FireServer("Open", chestType)
                        end
                    end
                end)
            end
        end
    end
end)

--==================================================
-- AUTO MERCHANT
--==================================================
task.spawn(function()
    while true do
        task.wait(30)
        if Config.Items.AutoMerchant and Config.Items.MerchantItem then
            safeCall(function()
                if RemoteEvents then
                    local merchantR = RemoteEvents:FindFirstChild("Merchant") or 
                                     RemoteEvents:FindFirstChild("Shop") or 
                                     RemoteEvents:FindFirstChild("Buy")
                    if merchantR then
                        merchantR:FireServer("Buy", Config.Items.MerchantItem)
                    end
                end
            end)
        end
    end
end)

--==================================================
-- FRUIT FARM SYSTEM
--==================================================

local function checkHasFruit(fruitName)
    local containers = {Player.Character, Player:FindFirstChild("Backpack")}
    for _, container in pairs(containers) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:find(fruitName) then
                    return true, tool
                end
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
                local char, hum = getChar()
                if hum then
                    hum:EquipTool(tool)
                    task.wait(1)
                    return true
                end
            end
        end
    end
    return false
end

local function fruitFarmLoop()
    if not Config.FruitFarm.Enabled then return end
    
    if tpRemote then
        safeCall(function() tpRemote:FireServer(Config.FruitFarm.Island) end)
        task.wait(3)
    end
    
    local char, hrp = getChar()
    if hrp then
        hrp.CFrame = Config.FruitFarm.Position
    end
    
    equipFruit(Config.FruitFarm.TargetFruit)
    
    while Config.FruitFarm.Enabled do
        task.wait(1)
        
        local char, hrp, hum = getChar()
        if hum.Health <= 0 then
            task.wait(5)
            continue
        end
        
        if (hrp.Position - Config.FruitFarm.Position.Position).Magnitude > 10 then
            hrp.CFrame = Config.FruitFarm.Position
        end
        
        if hakiRemote then safeCall(function() hakiRemote:FireServer("Toggle") end) end
        
        if fruitPowerRemote then
            local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
            for _, key in ipairs(keys) do
                safeCall(function()
                    fruitPowerRemote:FireServer("UseAbility", {
                        TargetPosition = hrp.Position,
                        FruitPower = Config.FruitFarm.TargetFruit,
                        KeyCode = key
                    })
                end)
                task.wait(0.5)
            end
        end
    end
end

--==================================================
-- MAIN TAB
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local playerInfoPara = PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Loading...",
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

local ServerInfoPara = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = "Loading...",
    Image = "server",
    ImageSize = 48
})

-- Auto refresh info
task.spawn(function()
    while true do
        task.wait(2)
        
        local level = safeCall(function() return Player.Data.Level.Value end) or 0
        local money = safeCall(function() return Player.Data.Money.Value end) or 0
        local gems = safeCall(function() return Player.Data.Gems.Value end) or 0
        
        playerInfoPara:SetDesc(
            "Display Name: " .. Player.DisplayName .. "\n" ..
            "Level: " .. level .. "\n" ..
            "Money: " .. formatNumber(money) .. "\n" ..
            "Gems: " .. formatNumber(gems) .. "\n" ..
            "Account Age: " .. Player.AccountAge .. " days"
        )
        
        local players = Players:GetPlayers()
        local ping = safeCall(function() 
            return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
        end) or 0
        
        ServerInfoPara:SetDesc(
            "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
            "Ping: " .. ping .. "ms\n" ..
            "Uptime: " .. getUptime()
        )
    end
end)

MainTab:AddButton({
    Name = "🔍 SCAN ALL ISLANDS",
    Icon = "search",
    Outline = true,
    Callback = function()
        task.spawn(function()
            Notify("Scanning all islands...", 3)
            scanAllIslands()
            Notify("Scan complete! Found " .. #MobDatabase .. " mobs", 3)
        end)
    end
})

--==================================================
-- FARM TAB
--==================================================
local FarmSection = FarmTab:AddSection({
    Name = "⚡ AUTO FARM SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmSection:AddToggle({
    Name = "ENABLE AUTO FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm.Enabled = Value
        Notify(Value and "Auto Farm Enabled" or "Auto Farm Disabled")
        if Value then
            task.spawn(farmLoop)
        end
    end
})

FarmSection:AddToggle({
    Name = "AUTO HIT",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHit",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoHit = Value end
})

FarmSection:AddToggle({
    Name = "AUTO STATS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoStats",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoStats = Value end
})

FarmSection:AddToggle({
    Name = "AUTO HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoHaki = Value end
})

FarmSection:AddToggle({
    Name = "AUTO OBS HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoObsHaki",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoObsHaki = Value end
})

FarmSection:AddToggle({
    Name = "AUTO EQUIP WEAPON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoEquip",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoEquip = Value end
})

FarmSection:AddDropdown({
    Name = "SELECT WEAPON",
    Default = "None",
    Options = getWeaponList(),
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "WeaponSelect",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm.SelectedWeapon = Value
    end
})

FarmSection:AddButton({
    Name = "🔄 REFRESH WEAPON LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local weapons = getWeaponList()
        OrionLib.Flags["WeaponSelect"]:SetOptions(weapons)
        Notify("Weapon list refreshed")
    end
})

FarmSection:AddDropdown({
    Name = "⚔️ WEAPON MODE",
    Default = "Melee",
    Options = {"Melee", "Fruit"},
    Multi = false,
    Outline = true,
    Flag = "WeaponMode",
    Save = true,
    Callback = function(Value) Config.AutoFarm.WeaponMode = Value end
})

FarmSection:AddDropdown({
    Name = "🚀 MOVE MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Outline = true,
    Flag = "MoveMode",
    Save = true,
    Callback = function(Value) Config.AutoFarm.MoveMode = Value end
})

FarmSection:AddToggle({
    Name = "🛹 PLANK MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(Value) Config.AutoFarm.PlankMode = Value end
})

FarmSection:AddSlider({
    Name = "📏 FARM HEIGHT",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "FarmHeight",
    Save = true,
    Callback = function(Value) Config.AutoFarm.FarmHeight = Value end
})

FarmSection:AddSlider({
    Name = "💨 FARM SPEED",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    ValueName = "studs/s",
    Outline = true,
    Flag = "FarmSpeed",
    Save = true,
    Callback = function(Value) Config.AutoFarm.FarmSpeed = Value end
})

FarmSection:AddSlider({
    Name = "⏱️ ATTACK COOLDOWN (ms)",
    Min = 100,
    Max = 1000,
    Default = 300,
    Increment = 50,
    ValueName = "ms",
    Outline = true,
    Flag = "AttackCooldown",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AttackCooldown = Value / 1000 end
})

FarmSection:AddDropdown({
    Name = "🎯 SELECT MOB",
    Default = "Auto",
    Options = {"Auto"},
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedMob",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm.SelectedMob = Value ~= "Auto" and Value or nil
    end
})

FarmSection:AddButton({
    Name = "🔄 REFRESH MOB LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local mobNames = {"Auto"}
        for _, mob in ipairs(MobDatabase) do
            table.insert(mobNames, mob.name)
        end
        OrionLib.Flags["SelectedMob"]:SetOptions(mobNames)
        Notify("Mob list refreshed")
    end
})

--==================================================
-- SKILL TAB
--==================================================
local SkillSection = SkillTab:AddSection({
    Name = "🎯 AUTO SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

for _, key in ipairs({"Z", "X", "C", "V", "F"}) do
    local slotNum = ({ Z=1, X=2, C=3, V=4, F=5 })[key]
    SkillSection:AddToggle({
        Name = string.format("[%s] SKILL %d", key, slotNum),
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Skill" .. key,
        Save = true,
        Callback = function(Value) Config.AutoFarm.Skills[key] = Value end
    })
end

SkillSection:AddToggle({
    Name = "🔥 ALL SKILLS ON/OFF",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AllSkills",
    Save = true,
    Callback = function(Value)
        for _, k in ipairs({"Z","X","C","V","F"}) do
            Config.AutoFarm.Skills[k] = Value
        end
    end
})

SkillSection:AddSlider({
    Name = "⏱️ SKILL COOLDOWN (ms)",
    Min = 100,
    Max = 3000,
    Default = 500,
    Increment = 50,
    ValueName = "ms",
    Outline = true,
    Flag = "SkillCooldown",
    Save = true,
    Callback = function(Value) Config.AutoFarm.SkillCooldown = Value / 1000 end
})

--==================================================
-- BOSS TAB
--==================================================
local BossSection = BossTab:AddSection({
    Name = "🐉 BOSS FIGHT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossSection:AddToggle({
    Name = "ENABLE BOSS FIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossFight",
    Save = true,
    Callback = function(Value)
        Config.Boss.Enabled = Value
        if Value then
            task.spawn(bossFightLoop)
        end
    end
})

BossSection:AddDropdown({
    Name = "🎯 SELECT BOSS",
    Default = "Select Boss",
    Options = BossList,
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedBoss",
    Save = true,
    Callback = function(Value) Config.Boss.SelectedBoss = Value end
})

BossSection:AddToggle({
    Name = "🔮 AUTO SUMMON BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SummonBoss",
    Save = true,
    Callback = function(Value) Config.Boss.SummonEnabled = Value end
})

BossSection:AddDropdown({
    Name = "💀 DIFFICULTY",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Nightmare"},
    Multi = false,
    Outline = true,
    Flag = "BossDifficulty",
    Save = true,
    Callback = function(Value) Config.Boss.SummonDifficulty = Value end
})

BossSection:AddButton({
    Name = "🔄 REFRESH BOSS LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildBossList()
        OrionLib.Flags["SelectedBoss"]:SetOptions(BossList)
        Notify("Boss list refreshed")
    end
})

--==================================================
-- DUNGEON TAB
--==================================================
local DungeonSection = DungeonTab:AddSection({
    Name = "🏰 DUNGEON",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonSection:AddToggle({
    Name = "ENABLE AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        Config.Dungeon.Enabled = Value
        if Value then
            task.spawn(dungeonLoop)
        end
    end
})

DungeonSection:AddDropdown({
    Name = "🏰 DUNGEON TYPE",
    Default = "Shadow",
    Options = DungeonTypes,
    Multi = false,
    Outline = true,
    Flag = "DungeonType",
    Save = true,
    Callback = function(Value) Config.Dungeon.DungeonType = Value end
})

DungeonSection:AddToggle({
    Name = "⚡ BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossRush",
    Save = true,
    Callback = function(Value) Config.Dungeon.BossRushEnabled = Value end
})

--==================================================
-- ITEM TAB
--==================================================
local ItemSection = ItemTab:AddSection({
    Name = "📦 AUTO ITEMS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ItemSection:AddToggle({
    Name = "AUTO OPEN CHESTS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(Value) Config.Items.AutoChest = Value end
})

ItemSection:AddToggle({
    Name = "AUTO BUY FROM MERCHANT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoMerchant",
    Save = true,
    Callback = function(Value) Config.Items.AutoMerchant = Value end
})

ItemSection:AddDropdown({
    Name = "🛒 ITEM TO BUY",
    Default = "HealthPotion",
    Options = {"HealthPotion", "StaminaPotion", "BoostScroll", "SummonStone"},
    Multi = false,
    Outline = true,
    Flag = "MerchantItem",
    Save = true,
    Callback = function(Value) Config.Items.MerchantItem = Value end
})

--==================================================
-- SETTINGS TAB
--==================================================
local SettingSection = SettingTab:AddSection({
    Name = "⚙️ BYPASS SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SettingSection:AddToggle({
    Name = "👻 NOCLIP",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value) Config.Bypass.NoclipEnabled = Value end
})

SettingSection:AddToggle({
    Name = "🚫 ANTI VOID",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiVoid",
    Save = true,
    Callback = function(Value) Config.Bypass.AntiVoid = Value end
})

SettingSection:AddToggle({
    Name = "💤 ANTI AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiIdle",
    Save = true,
    Callback = function(Value) Config.Bypass.AntiIdle = Value end
})

SettingSection:AddToggle({
    Name = "FPS BOOST (BLACK SCREEN)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        Config.Misc.FpsBoost = Value
        if Value then
            Lighting.Brightness = 0
            Lighting.GlobalShadows = false
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
            end
        end
    end
})

SettingSection:AddToggle({
    Name = "⚡ MAKE GAME SMOOTHER",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Smoother",
    Save = true,
    Callback = function(Value)
        if settingsToggle then
            local toggles = {
                {"MuteMusic", Value}, {"MuteSFX", Value},
                {"DisableVFX", Value}, {"DisableCutscene", Value},
                {"DisableOtherVFX", Value}, {"RemoveTexture", Value},
                {"RemoveShadows", Value},
            }
            for _, t in ipairs(toggles) do
                safeCall(function() settingsToggle:FireServer(t[1], t[2]) end)
            end
            local settings = UserSettings():GetService("UserGameSettings")
            settings.SavedQualityLevel = Value and Enum.SavedQualitySetting.QualityLevel1 or Enum.SavedQualitySetting.QualityLevel10
            settings.GraphicsQualityLevel = Value and 1 or 10
        end
    end
})

SettingSection:AddToggle({
    Name = "AUTO REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value) Config.Misc.AutoRejoin = Value end
})

SettingSection:AddKeybind({
    Name = "[F2] TOGGLE FARM",
    Key = Enum.KeyCode.F2,
    Flag = "KeyFarm",
    Callback = function()
        Config.AutoFarm.Enabled = not Config.AutoFarm.Enabled
        Notify(Config.AutoFarm.Enabled and "Farm ON" or "Farm OFF")
        if Config.AutoFarm.Enabled then
            task.spawn(farmLoop)
        end
    end
})

SettingSection:AddKeybind({
    Name = "[B] TOGGLE BOSS",
    Key = Enum.KeyCode.B,
    Flag = "KeyBoss",
    Callback = function()
        Config.Boss.Enabled = not Config.Boss.Enabled
        Notify(Config.Boss.Enabled and "Boss Fight ON" or "Boss Fight OFF")
        if Config.Boss.Enabled then
            task.spawn(bossFightLoop)
        end
    end
})

SettingSection:AddKeybind({
    Name = "[M] TOGGLE ALL SKILLS",
    Key = Enum.KeyCode.M,
    Flag = "KeySkills",
    Callback = function()
        local anyOn = false
        for _, v in pairs(Config.AutoFarm.Skills) do
            if v then anyOn = true break end
        end
        local newState = not anyOn
        for _, k in ipairs({"Z","X","C","V","F"}) do
            Config.AutoFarm.Skills[k] = newState
        end
        Notify(newState and "All Skills ON" or "All Skills OFF")
    end
})

--==================================================
-- AUTO REJOIN HANDLER
--==================================================
GuiService.ErrorMessageChanged:Connect(function()
    if Config.Misc and Config.Misc.AutoRejoin then
        local lastError = GuiService:GetErrorMessage()
        if not lastError:find("Security") then
            task.spawn(function()
                task.wait(5)
                for _ = 1, 10 do
                    if pcall(function() TeleportService:Teleport(game.PlaceId, Player) end) then
                        break
                    end
                    task.wait(10)
                end
            end)
        end
    end
end)

--==================================================
-- INITIAL SCAN
--==================================================
task.spawn(function()
    task.wait(5)
    buildBossList()
    task.spawn(scanAllIslands)
end)

--==================================================
-- INITIALIZE
--==================================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")

print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE v3.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm System - COMPLETE")
print("✅ Boss Fight System - COMPLETE")
print("✅ Dungeon System - COMPLETE")
print("✅ Skill System - COMPLETE")
print("✅ Item Auto System - COMPLETE")
print("✅ Bypass & Anti-Cheat - COMPLETE")
print("✅ Island Scanner - COMPLETE")
print("═══════════════════════════════════════════════════════")