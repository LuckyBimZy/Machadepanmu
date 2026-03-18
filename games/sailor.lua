-- ==================== SAILOR PIECE - CATRAZ ULTIMATE v4.0 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Gabungan ArcX + NovaLib methods
-- Version: 4.0 ULTIMATE

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
-- SERVICES & GLOBALS
--==================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local questcheck = require(ReplicatedStorage.Modules.QuestConfig)
local checkmap = require(ReplicatedStorage.TravelConfig)

--==================================================
-- REMOTE REFERENCES
--==================================================
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local CombatRemotes = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes")
local AbilityRemote = ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")

local hitRemote = CombatRemotes:WaitForChild("RequestHit")
local questRemote = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")
local hakiRemote = RemoteEvents:WaitForChild("HakiRemote")
local obsHakiRemote = RemoteEvents:WaitForChild("ObservationHakiRemote")
local summonBossRemote = Remotes:WaitForChild("RequestSummonBoss")
local spawnStrongestRemote = Remotes:WaitForChild("RequestSpawnStrongestBoss")
local anosRemote = Remotes:WaitForChild("RequestSpawnAnosBoss")
local trueAizenRemote = RemoteEvents:WaitForChild("RequestSpawnTrueAizen")
local rimuruRemote = RemoteEvents:WaitForChild("RequestSpawnRimuru")
local dungeonVoteRemote = Remotes:WaitForChild("DungeonWaveVote")
local dungeonPortalRemote = Remotes:WaitForChild("RequestDungeonPortal")

--==================================================
-- ANTI-KICK + ANTI-TP-BACK HOOK
--==================================================
local BLOCKED_REMOTES = {
    sanity = true, checksanity = true, positioncheck = true,
    antiteleport = true, validateposition = true, checkpos = true,
    anticheat = true, positionvalidate = true, sanitycheck = true,
    movementcheck = true, speedcheck = true, teleportback = true,
}

local OldNameKick
OldNameKick = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if (method == "Kick" or method == "kick") and (self == Player or self == Players) then
        warn("[AntiKick] Blocked kick:", args[1])
        return nil
    end

    if getgenv().IsFarm and (method == "FireServer" or method == "InvokeServer") then
        if self and self:IsA("RemoteEvent") or (self and pcall(function() return self:IsA("RemoteFunction") end)) then
            local remoteName = self.Name:lower():gsub("_", ""):gsub("-", "")
            if BLOCKED_REMOTES[remoteName] then
                warn("[AntiTP] Blocked remote:", self.Name)
                return nil
            end
        end
    end

    return OldNameKick(self, ...)
end)

--==================================================
-- BYPASS TELEPORT (ANTI-CHEAT HOOK)
--==================================================
if getgc and hookfunction then
    local hookedCount = 0
    for _, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local ok, info = pcall(getinfo, v)
            if ok and info and info.source then
                if info.source:find("AntiCheat") or info.source:find("ControlClient") or info.source:find("Idle") or info.source:find("Sanity") or info.source:find("Movement") then
                    if info.name and (info.name:lower():find("kick") or info.name:lower():find("ban") or info.name:lower():find("teleport") or info.name:lower():find("position") or info.name:lower():find("sanity") or info.name:lower():find("speed") or info.name:lower():find("check")) then
                        hookfunction(v, function(...) return nil end)
                        hookedCount = hookedCount + 1
                    end
                end
            end
            pcall(function()
                local upvalues = getupvalues(v)
                for key, val in pairs(upvalues) do
                    if type(key) == "string" then
                        if key:lower() == "isteleporting" then
                            setupvalue(v, key, false)
                        elseif key:lower() == "maxspeed" or key:lower() == "speedlimit" then
                            setupvalue(v, key, 99999)
                        end
                    end
                end
            end)
        end
    end
    warn("[BYPASS] Hooked " .. tostring(hookedCount) .. " AC functions")
end

--==================================================
-- PHYSICS FIXER
--==================================================
task.spawn(function()
    while task.wait(0.1) do
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and root and getgenv().IsTeleporting then
            hum.PlatformStand = true
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            root.Velocity = Vector3.new(0, 0, 0)
        elseif hum and not getgenv().IsTeleporting then
            if hum.PlatformStand then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
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

local originalCamera = {
    FieldOfView = Camera.FieldOfView
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
getgenv().Config = {
    -- Farm Settings
    IsFarm = false,
    SelectedMob = nil,
    WeaponMode = "Melee",
    AttackCooldown = 0.3,
    IsTeleporting = false,
    PlankMode = false,
    FarmHeight = 25,
    FarmSpeed = 50,
    MoveMode = "Tween",
    
    -- Skill Settings
    SelectedSkill = 0,
    AutoSkills = { Z = false, X = false, C = false, V = false, F = false },
    SkillCooldown = 0.5,
    
    -- Boss Settings
    IsBossFight = false,
    SelectedBoss = nil,
    IsSummonBoss = false,
    SummonDifficulty = "Normal",
    
    -- Dungeon Settings
    IsAutoDungeon = false,
    DungeonType = "Shadow",
    IsBossRush = false,
    
    -- Quest Settings
    IsDungeonQuest = false,
    IsHogyokuQuest = false,
    
    -- Item Settings
    IsAutoChest = false,
    IsAutoMerchant = false,
    MerchantItem = nil,
    
    -- Misc Settings
    IsNoclip = false,
    AntiAFK = true,
    FpsBoost = false,
    WhiteScreen = false,
    AutoRejoin = false,
    TimedRejoin = false,
    RejoinDelay = 10,
    FriendOnly = false,
    
    -- Farm Order (dari ArcX)
    FarmOrder = {
        { Name = "Swordsman", Remote = "Judgement", IsBossType = false },
        { Name = "Quincy", Remote = "HuecoMundo", IsBossType = false },
        { Name = "AcademyTeacher", Remote = "Academy", IsBossType = false },
        { Name = "Slime", Remote = "Slime", IsBossType = false },
        { Name = "StrongSorcerer", Remote = "Shinjuku", IsBossType = false },
        { Name = "Hollow", Remote = "HuecoMundo", IsBossType = false },
        { Name = "Curse", Remote = "Shinjuku", IsBossType = false },
        { Name = "Gojo", Remote = "Shibuya", IsBossType = true },
        { Name = "Yuji", Remote = "Shibuya", IsBossType = true },
        { Name = "Sukuna", Remote = "Shibuya", IsBossType = true },
        { Name = "Jinwoo", Remote = "Sailor", IsBossType = true },
        { Name = "Alucard", Remote = "Sailor", IsBossType = true },
        { Name = "Aizen", Remote = "HuecoMundo", IsBossType = true },
        { Name = "Yamato", Remote = "Judgement", IsBossType = true },
        { Name = "Saber", Remote = "Boss", IsBossType = true },
        { Name = "Ichigo", Remote = "Boss", IsBossType = true },
        { Name = "QinShi", Remote = "Boss", IsBossType = true },
        { Name = "Gilgamesh", Remote = "Boss", IsBossType = true },
        { Name = "BlessedMaiden", Remote = "Boss", IsBossType = true },
        { Name = "SaberAlter", Remote = "Boss", IsBossType = true },
        { Name = "StrongestinHistory", Remote = "Shinjuku", IsBossType = true },
        { Name = "StrongestofToday", Remote = "Shinjuku", IsBossType = true },
        { Name = "Rimuru", Remote = "Slime", IsBossType = true },
        { Name = "Anos", Remote = "Academy", IsBossType = true },
        { Name = "TrueAizen", Remote = "HuecoMundo", IsBossType = true },
    },
    
    -- Constants
    ICON = "rbxassetid://105921924721005",
    NPC_FOLDER = "NPCs",
    BOSS_ISLAND_PORTAL = "Boss",
    ANOS_ISLAND = "Academy",
    
    -- Islands (dari ArcX)
    Islands = {
        {Portal = "Starter", FarmUntil = 250, Enemies = {"Thief"}, QuestNPC = "QuestNPC1"},
        {Portal = "Jungle", FarmUntil = 750, Enemies = {"Monkey"}, QuestNPC = "QuestNPC3"},
        {Portal = "Desert", FarmUntil = 1500, Enemies = {"DesertBandit"}, QuestNPC = "QuestNPC5"},
        {Portal = "Snow", FarmUntil = 3000, Enemies = {"Swordsman", "FrostRogue"}, QuestNPC = "QuestNPC7"},
        {Portal = "Shibuya", FarmUntil = 5000, Enemies = {"Sorcerer", "Curse"}, QuestNPC = "QuestNPC9"},
        {Portal = "HuecoMundo", FarmUntil = 6250, Enemies = {"Hollow", "Quincy"}, QuestNPC = "QuestNPC11"},
        {Portal = "Shinjuku", FarmUntil = 8000, Enemies = {"StrongSorcerer"}, QuestNPC = "QuestNPC12"},
        {Portal = "Slime", FarmUntil = 9000, Enemies = {"Slime"}, QuestNPC = "QuestNPC14"},
        {Portal = "Academy", FarmUntil = 10000, Enemies = {"AcademyTeacher"}, QuestNPC = "QuestNPC15"},
        {Portal = "Judgement", FarmUntil = 10750, Enemies = {"Swordsman"}, QuestNPC = "QuestNPC16"},
        {Portal = "SoulSociety", FarmUntil = 999999, Enemies = {"Quincy1", "Quincy2", "Quincy3", "Quincy4", "Quincy5"}, QuestNPC = "QuestNPC17"},
    },
    
    -- Dungeon Types
    DungeonTypes = {"Double", "Rune", "Cid"},
    DungeonDifficulties = {"Easy", "Normal", "Hard", "Extreme"},
    DungeonPortalNames = {Double = "DoubleDungeon", Rune = "RuneDungeon", Cid = "CidDungeon"},
    
    -- Ignore List
    IgnoreList = {"groupreward","katana","buyer","madoka","training","dummy","merchant","shop","vendor","shadow questline","shadowmonarch","obshakilsinhead","buff","questnpc"},
    
    -- Chest & Merchant Items
    ChestNames = {"Common Chest","Rare Chest","Epic Chest","Legendary Chest","Mythical Chest"},
    ChestTypes = {"Wood", "Iron", "Gold", "Diamond", "Legendary"},
    MerchantItems = {"Boss Key","Clan Reroll","Dungeon Key","Haki Color Reroll","Race Reroll","Rush Key","Trait Reroll"},
}

--==================================================
-- MOB DATABASE (Dari NovaLib)
--==================================================
local MobDatabase = {}

local function buildMobDatabase()
    table.clear(MobDatabase)

    local npcLevelMap = {}
    for _, questData in pairs(questcheck.RepeatableQuests) do
        local reqLevel = tonumber(questData.recommendedLevel) or 0
        if questData.requirements then
            for _, req in ipairs(questData.requirements) do
                if req.npcType then
                    if not npcLevelMap[req.npcType] or reqLevel > npcLevelMap[req.npcType] then
                        npcLevelMap[req.npcType] = reqLevel
                    end
                end
            end
        end
    end

    local seenTypes = {}
    local npcFolder = Workspace:FindFirstChild(getgenv().Config.NPC_FOLDER)
    if npcFolder then
        for _, npc in ipairs(npcFolder:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                local npcName = npc.Name
                if not seenTypes[npcName] then
                    seenTypes[npcName] = true
                    local level = 0
                    for npcType, lvl in pairs(npcLevelMap) do
                        if string.find(npcName, npcType) then
                            level = lvl
                            break
                        end
                    end

                    local island = "Unknown"
                    pcall(function()
                        local zoneId, _ = checkmap.GetZoneAt(npc.HumanoidRootPart.Position)
                        if zoneId then island = zoneId end
                    end)

                    table.insert(MobDatabase, {
                        name   = npcName,
                        level  = level,
                        island = island,
                    })
                end
            end
        end
    end

    table.sort(MobDatabase, function(a, b)
        if a.level == b.level then return a.name < b.name end
        return a.level < b.level
    end)
end

--==================================================
-- BOSS LIST
--==================================================
local BossList = {}

local function buildBossList()
    table.clear(BossList)
    for _, folder in ipairs({"Bosses", "Boss", "WorldBoss", getgenv().Config.NPC_FOLDER}) do
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

--==================================================
-- ISLAND LEARNING (Dari NovaLib)
--==================================================
local autoLevelRanges = {}
local hasLearned = false

local function autoLearnIslandLevels()
    if hasLearned then return end
    for _, questData in pairs(questcheck.RepeatableQuests) do
        local reqLevel = tonumber(questData.recommendedLevel) or 0
        if questData.requirements then
            for _, req in ipairs(questData.requirements) do
                if req.npcType then
                    local npcFolder = Workspace:FindFirstChild(getgenv().Config.NPC_FOLDER)
                    if npcFolder then
                        for _, obj in ipairs(npcFolder:GetChildren()) do
                            if string.find(obj.Name, req.npcType) and obj:FindFirstChild("HumanoidRootPart") then
                                local zoneId, _ = checkmap.GetZoneAt(obj.HumanoidRootPart.Position)
                                if zoneId then
                                    if not autoLevelRanges[zoneId] then
                                        autoLevelRanges[zoneId] = { MinLevel = reqLevel, MaxLevel = reqLevel, PortalKey = zoneId }
                                    else
                                        autoLevelRanges[zoneId].MinLevel = math.min(autoLevelRanges[zoneId].MinLevel, reqLevel)
                                        autoLevelRanges[zoneId].MaxLevel = math.max(autoLevelRanges[zoneId].MaxLevel, reqLevel)
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    hasLearned = true
end

--==================================================
-- QUEST SYSTEM (Dari NovaLib)
--==================================================
local function getTargetQuest()
    local level = Player.Data.Level.Value
    local bestNPC = nil
    local maxLevelFound = -1
    local choosenpc = nil

    for npcName, data in pairs(questcheck.RepeatableQuests) do
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
-- UTILITY FUNCTIONS
--==================================================

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function GetNPCFolder()
    local direct = Workspace:FindFirstChild(getgenv().Config.NPC_FOLDER)
    if direct then return direct end
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("Folder") then
            local n = (desc.Name or ""):lower()
            if n == "npcs" or n == "npc" or n:find("npc", 1, true) then
                return desc
            end
        end
    end
    return nil
end

local function GetHum(e)
    if not e then return nil end
    local h = e:FindFirstChildOfClass("Humanoid")
    if not h then
        for _, d in ipairs(e:GetDescendants()) do
            if d:IsA("Humanoid") then
                h = d
                break
            end
        end
    end
    return h
end

local function RootPos(e)
    if not e then return nil end
    local rp = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso") or e:FindFirstChild("UpperTorso")
    if rp and rp:IsA("BasePart") then return rp.Position end
    if e:IsA("Model") and e.PrimaryPart then return e.PrimaryPart.Position end
    for _, d in ipairs(e:GetDescendants()) do
        if d:IsA("BasePart") then return d.Position end
    end
    return nil
end

local function PortalDisplayName(portal)
    local names = {HuecoMundo = "Hueco Mundo", SoulSociety = "Soul Society"}
    return names[portal] or portal
end

local function GetLevel()
    local lv = 0
    pcall(function()
        local ls = Player:FindFirstChild("leaderstats")
        if ls then
            local v = ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl") or ls:FindFirstChild("LVL")
            if v then lv = tonumber(v.Value) or 0 end
        end
    end)
    return lv
end

local function IsAlive()
    local c = Player.Character
    if not c then return false end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return hrp ~= nil and hum ~= nil and hum.Health > 0
end

local function ShouldIgnore(name)
    local lo = name:lower()
    for _, ig in ipairs(getgenv().Config.IgnoreList) do
        if lo:find(ig, 1, true) then return true end
    end
    return false
end

--==================================================
-- FIND MOB FUNCTIONS (Dari NovaLib)
--==================================================
local function findMob(targetName)
    local npcFolder = GetNPCFolder()
    if not npcFolder then return nil end

    local closest = nil
    local closestDist = math.huge
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local playerPos = char.HumanoidRootPart.Position

    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and not ShouldIgnore(npc.Name) then
                local match = false
                if targetName then
                    match = (npc.Name == targetName) or string.find(npc.Name, targetName)
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
-- TELEPORT FUNCTIONS
--==================================================
local function getPortalForLevel(lvl)
    for zoneId, rangeData in pairs(autoLevelRanges) do
        if lvl >= rangeData.MinLevel and lvl <= rangeData.MaxLevel then
            return rangeData.PortalKey
        end
    end
    return "Starter"
end

local function teleportToIsland(currentLevel, targetMobName)
    local targetPortal = getPortalForLevel(currentLevel)
    local portalArg = targetPortal:gsub("Island", ""):gsub(" ", "")

    local success, _ = pcall(function()
        tpRemote:FireServer(portalArg)
    end)

    if success then
        task.wait(2)
        hasLearned = false
        autoLearnIslandLevels()
        buildMobDatabase()
    end
end

local function ForceTP(portal)
    pcall(function() tpRemote:FireServer(portal) end)
    task.wait(0.5)
end

--==================================================
-- TWEEN / MOVEMENT FUNCTIONS (Dari NovaLib)
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

local function tweenToMob(mob)
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end

    local root = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")

    local offset = Vector3.new(0, 0, 5)
    if getgenv().Config.PlankMode then
        offset = Vector3.new(0, getgenv().Config.FarmHeight, 0)
    end
    local targetPos = mob.HumanoidRootPart.Position + offset

    if getgenv().Config.MoveMode == "Teleport" then
        root.CFrame = CFrame.new(targetPos)
        return
    end

    local totalDist = (targetPos - root.Position).Magnitude
    getgenv().Config.IsTeleporting = true

    if totalDist <= CLOSE_RANGE then
        microTween(root, CFrame.new(targetPos))
        getgenv().Config.IsTeleporting = false
        return
    end

    local steps = math.ceil(totalDist / STEP_SIZE)
    local startPos = root.Position

    for i = 1, steps do
        if not getgenv().Config.IsFarm and not getgenv().Config.IsBossFight and not getgenv().Config.IsAutoDungeon then break end
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

        local moveDir = (nextPos - root.Position)
        if moveDir.Magnitude > 0 then
            root.Velocity = moveDir.Unit * getgenv().Config.FarmSpeed
        end

        microTween(root, CFrame.new(nextPos))
        task.wait(STEP_DELAY)
    end

    root.Velocity = Vector3.new(0, 0, 0)
    getgenv().Config.IsTeleporting = false
end

--==================================================
-- WEAPON / ATTACK SYSTEM (Dari NovaLib + ArcX)
--==================================================
local function equipWeapon()
    local char = Player.Character
    if not char then return nil end
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return nil end

    local mode = getgenv().Config.WeaponMode

    local function findTool(searchIn)
        for _, item in ipairs(searchIn:GetChildren()) do
            if item:IsA("Tool") then
                if mode == "Melee" then
                    local n = item.Name:lower()
                    if n:find("sword") or n:find("blade") or n:find("katana") or n:find("cutlass") or n:find("melee") then
                        return item
                    end
                elseif mode == "Fruit" then
                    local n = item.Name:lower()
                    if n:find("fruit") or n:find("devil") or n:find("power") or n:find("ability") then
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
        tool.Parent = char
        return tool
    end

    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            item.Parent = char
            return item
        end
    end

    return nil
end

local function autoAttack(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end

    local tool = equipWeapon()
    if tool then
        pcall(function() tool:Activate() end)
    end

    pcall(function() hitRemote:FireServer() end)

    local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
    for key, slot in pairs(skillMap) do
        if getgenv().Config.AutoSkills[key] then
            pcall(function() AbilityRemote:FireServer(slot) end)
        end
    end

    local skillId = getgenv().Config.SelectedSkill
    if skillId and skillId > 0 and not next(getgenv().Config.AutoSkills) then
        pcall(function() AbilityRemote:FireServer(skillId) end)
    end
end

--==================================================
-- BOSS FIGHT SYSTEM (Dari NovaLib)
--==================================================
local function doBossFight()
    local bossName = getgenv().Config.SelectedBoss
    local boss = findBoss(bossName)

    if not boss then
        return false
    end

    local h = boss:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end

    tweenToMob(boss)
    autoAttack(boss)
    return true
end

--==================================================
-- SUMMON BOSS SYSTEM (Dari NovaLib)
--==================================================
local function doSummonBoss()
    pcall(function()
        local summonRemote = summonBossRemote or RemoteEvents:FindFirstChild("SummonBoss") or RemoteEvents:FindFirstChild("BossSummon") or RemoteEvents:FindFirstChild("SpawnBoss")
        if summonRemote then
            summonRemote:FireServer(getgenv().Config.SelectedBoss or "Boss1", getgenv().Config.SummonDifficulty)
        end
    end)

    task.wait(2)

    local boss = findBoss(getgenv().Config.SelectedBoss)
    if boss then
        local h = boss:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then
            tweenToMob(boss)
            autoAttack(boss)
            return true
        end
    end
    return false
end

--==================================================
-- DUNGEON SYSTEM (Dari NovaLib)
--==================================================
local function doAutoDungeon()
    local dtype = getgenv().Config.DungeonType

    pcall(function()
        local dungeonRemote = dungeonPortalRemote or RemoteEvents:FindFirstChild("Dungeon") or RemoteEvents:FindFirstChild("DungeonEnter") or RemoteEvents:FindFirstChild("EnterDungeon")
        if dungeonRemote then
            dungeonRemote:FireServer("Enter", dtype)
        end
    end)

    task.wait(3)

    local mob = findMob(nil)
    if mob then
        tweenToMob(mob)
        autoAttack(mob)
        return true
    end
    return false
end

--==================================================
-- BOSS RUSH SYSTEM (Dari NovaLib)
--==================================================
local function doBossRush()
    pcall(function()
        local rushRemote = RemoteEvents:FindFirstChild("BossRush") or RemoteEvents:FindFirstChild("EnterBossRush")
        if rushRemote then
            rushRemote:FireServer("Enter")
        end
    end)

    task.wait(2)
    local boss = findBoss(nil)
    if boss then
        tweenToMob(boss)
        autoAttack(boss)
        return true
    end
    return false
end

--==================================================
-- DUNGEON QUEST (Dari NovaLib)
--==================================================
local function getDungeonQuestProgress()
    local count = 0
    pcall(function()
        local data = Player:FindFirstChild("Data")
        if data then
            local dq = data:FindFirstChild("DungeonPieces") or data:FindFirstChild("DungeonQuest")
            if dq then count = dq.Value end
        end
    end)
    return count
end

local DungeonQuestOrder = {"Double", "Rune", "Cid", "Double", "Rune", "Cid"}

local function doDungeonQuest()
    local progress = getDungeonQuestProgress()
    if progress >= 6 then
        return false
    end

    local nextDungeon = DungeonQuestOrder[progress + 1] or "Double"
    getgenv().Config.DungeonType = nextDungeon
    return doAutoDungeon()
end

--==================================================
-- HOGYOKU QUEST (Dari NovaLib)
--==================================================
local function getHogyokuProgress()
    local count = 0
    pcall(function()
        local data = Player:FindFirstChild("Data")
        if data then
            local hq = data:FindFirstChild("HogyokuFragments") or data:FindFirstChild("Hogyoku")
            if hq then count = hq.Value end
        end
    end)
    return count
end

local HogyokuBosses = {"AizenBoss", "IchigoBoss", "SaberBoss", "RimuruBoss", "TrueAizenBoss"}

local function doHogyokuQuest()
    local progress = getHogyokuProgress()
    if progress >= 5 then
        pcall(function()
            local questR = RemoteEvents:FindFirstChild("Quest") or RemoteEvents:FindFirstChild("QuestAccept")
            if questR then
                questR:FireServer("HogyokuComplete")
            end
        end)
        return false
    end

    local targetBoss = HogyokuBosses[progress + 1] or "AizenBoss"
    getgenv().Config.SelectedBoss = targetBoss
    return doBossFight()
end

--==================================================
-- SKILL SPAM LOOP (Dari NovaLib)
--==================================================
task.spawn(function()
    while true do
        task.wait(getgenv().Config.SkillCooldown)
        if getgenv().Config.IsFarm or getgenv().Config.IsBossFight or getgenv().Config.IsAutoDungeon or getgenv().Config.IsBossRush then
            local char = Player.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
                for key, slot in pairs(skillMap) do
                    if getgenv().Config.AutoSkills[key] then
                        pcall(function() AbilityRemote:FireServer(slot) end)
                    end
                end
            end
        end
    end
end)

--==================================================
-- NOCLIP (Dari NovaLib)
--==================================================
task.spawn(function()
    RunService.Stepped:Connect(function()
        if getgenv().Config.IsNoclip then
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
end)

--==================================================
-- AUTO CHEST (Dari NovaLib)
--==================================================
task.spawn(function()
    while true do
        task.wait(5)
        if getgenv().Config.IsAutoChest then
            for _, chestType in ipairs(getgenv().Config.ChestTypes) do
                pcall(function()
                    local chestR = RemoteEvents:FindFirstChild("Chest") or RemoteEvents:FindFirstChild("OpenChest")
                    if chestR then
                        chestR:FireServer("Open", chestType)
                    end
                end)
            end
        end
    end
end)

--==================================================
-- AUTO MERCHANT (Dari NovaLib)
--==================================================
task.spawn(function()
    while true do
        task.wait(30)
        if getgenv().Config.IsAutoMerchant and getgenv().Config.MerchantItem then
            pcall(function()
                local merchantR = RemoteEvents:FindFirstChild("Merchant") or RemoteEvents:FindFirstChild("Shop") or RemoteEvents:FindFirstChild("Buy")
                if merchantR then
                    merchantR:FireServer("Buy", getgenv().Config.MerchantItem)
                end
            end)
        end
    end
end)

--==================================================
-- ANTI AFK (Dari NovaLib)
--==================================================
task.spawn(function()
    while getgenv().Config.AntiAFK do
        task.wait(60)
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end)
    end
end)

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
-- CREATE MAIN WINDOW (Catraz Hub)
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece",
    Subtext = "Catraz Ultimate v4.0",
    Version = "v4.0",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece Ultimate",
    IntroIcon = getgenv().Config.ICON,
    Icon = getgenv().Config.ICON,
    ShowIcon = true,
    
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = getgenv().Config.ICON,
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
    Name = "⚔️ Farm",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local BossTab = Window:MakeTab({
    Name = "🐉 Boss",
    Icon = "skull",
    Glass = true,
    Outline = true
})

local ModeTab = Window:MakeTab({
    Name = "🎮 Modes",
    Icon = "gamepad",
    Glass = true,
    Outline = true
})

local SkillTab = Window:MakeTab({
    Name = "🔮 Skills",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local ItemTab = Window:MakeTab({
    Name = "📦 Items",
    Icon = "package",
    Glass = true,
    Outline = true
})

local SettingTab = Window:MakeTab({
    Name = "⚙️ Settings",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- MAIN TAB - PLAYER INFO
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local playerInfoPara = PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName,
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
        
        local level = 0
        local money = 0
        local gems = 0
        pcall(function() 
            level = Player.Data.Level.Value or 0
            money = Player.Data.Money.Value or 0
            gems = Player.Data.Gems.Value or 0
        end)
        
        playerInfoPara:SetDesc("Display Name: " .. Player.DisplayName .. "\n" ..
                               "Level: " .. level .. "\n" ..
                               "Money: " .. formatNumber(money) .. "\n" ..
                               "Gems: " .. formatNumber(gems) .. "\n" ..
                               "Account Age: " .. Player.AccountAge .. " days")
    end
end)

--==================================================
-- FARM TAB
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
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsFarm = Value
        if Value then
            autoLearnIslandLevels()
            buildMobDatabase()
            Notify("Auto Farm Enabled")
        else
            Notify("Auto Farm Disabled")
        end
    end
})

FarmMainSection:AddToggle({
    Name = "🛹 PLANK MODE (HOVER)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.PlankMode = Value
    end
})

FarmMainSection:AddDropdown({
    Name = "🚀 MOVE MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Outline = true,
    Flag = "MoveMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.MoveMode = Value
    end
})

FarmMainSection:AddSlider({
    Name = "📏 FARM HEIGHT",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "FarmHeight",
    Save = true,
    Callback = function(Value)
        getgenv().Config.FarmHeight = Value
    end
})

FarmMainSection:AddSlider({
    Name = "💨 FARM SPEED",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Flag = "FarmSpeed",
    Save = true,
    Callback = function(Value)
        getgenv().Config.FarmSpeed = Value
    end
})

FarmMainSection:AddSlider({
    Name = "⏱️ ATTACK COOLDOWN (ms)",
    Min = 100,
    Max = 1000,
    Default = 300,
    Increment = 10,
    ValueName = "ms",
    Outline = true,
    Flag = "AttackCooldown",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AttackCooldown = Value / 1000
    end
})

FarmMainSection:AddDropdown({
    Name = "⚔️ WEAPON MODE",
    Default = "Melee",
    Options = {"Melee", "Fruit"},
    Multi = false,
    Outline = true,
    Flag = "WeaponMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.WeaponMode = Value
    end
})

-- Target Selection
buildMobDatabase()
local mobNames = {"Auto (theo Level)"}
for _, mob in ipairs(MobDatabase) do
    table.insert(mobNames, string.format("[Lv.%d] %s", mob.level, mob.name))
end

FarmMainSection:AddDropdown({
    Name = "🎯 SELECT ENEMY",
    Default = "Auto (theo Level)",
    Options = mobNames,
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedMob",
    Save = true,
    Callback = function(Value)
        if Value == "Auto (theo Level)" then
            getgenv().Config.SelectedMob = nil
        else
            getgenv().Config.SelectedMob = Value:match("%] (.+)$")
        end
    end
})

FarmMainSection:AddButton({
    Name = "🔄 REFRESH MOB LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildMobDatabase()
        local newNames = {"Auto (theo Level)"}
        for _, mob in ipairs(MobDatabase) do
            table.insert(newNames, string.format("[Lv.%d] %s", mob.level, mob.name))
        end
        OrionLib.Flags["SelectedMob"]:SetOptions(newNames)
        Notify("Mob list refreshed")
    end
})

--==================================================
-- BOSS TAB
--==================================================
local BossMainSection = BossTab:AddSection({
    Name = "🐉 BOSS FIGHT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "ENABLE BOSS FIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossFight",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsBossFight = Value
        if Value then
            buildBossList()
            Notify("Boss Fight Enabled")
        else
            Notify("Boss Fight Disabled")
        end
    end
})

-- Boss List
buildBossList()
BossMainSection:AddDropdown({
    Name = "🎯 SELECT BOSS",
    Default = BossList[1] or "Boss1",
    Options = BossList,
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedBoss",
    Save = true,
    Callback = function(Value)
        getgenv().Config.SelectedBoss = Value
    end
})

BossMainSection:AddButton({
    Name = "🔄 REFRESH BOSS LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildBossList()
        OrionLib.Flags["SelectedBoss"]:SetOptions(BossList)
        Notify("Boss list refreshed")
    end
})

local SummonSection = BossTab:AddSection({
    Name = "🔮 SUMMON BOSS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SummonSection:AddToggle({
    Name = "ENABLE SUMMON BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SummonBoss",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsSummonBoss = Value
        Notify(Value and "Summon Boss Enabled" or "Summon Boss Disabled")
    end
})

SummonSection:AddDropdown({
    Name = "💀 DIFFICULTY",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Nightmare"},
    Multi = false,
    Outline = true,
    Flag = "SummonDifficulty",
    Save = true,
    Callback = function(Value)
        getgenv().Config.SummonDifficulty = Value
    end
})

--==================================================
-- MODES TAB
--==================================================
local ModeMainSection = ModeTab:AddSection({
    Name = "🏰 DUNGEON",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "ENABLE AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsAutoDungeon = Value
        Notify(Value and "Auto Dungeon Enabled" or "Auto Dungeon Disabled")
    end
})

ModeMainSection:AddDropdown({
    Name = "DUNGEON TYPE",
    Default = "Double",
    Options = {"Double", "Rune", "Cid"},
    Multi = false,
    Outline = true,
    Flag = "DungeonType",
    Save = true,
    Callback = function(Value)
        getgenv().Config.DungeonType = Value
    end
})

ModeMainSection:AddButton({
    Name = "🚪 ENTER DUNGEON",
    Icon = "door",
    Outline = true,
    Callback = function()
        pcall(function()
            dungeonPortalRemote:FireServer(getgenv().Config.DungeonPortalNames[getgenv().Config.DungeonType])
            Notify("Attempting to enter " .. getgenv().Config.DungeonType .. " Dungeon")
        end)
    end
})

ModeMainSection:AddButton({
    Name = "🗳️ VOTE DIFFICULTY",
    Icon = "vote",
    Outline = true,
    Callback = function()
        pcall(function()
            dungeonVoteRemote:FireServer("Normal")
            Notify("Voted for Normal difficulty")
        end)
    end
})

local RushSection = ModeTab:AddSection({
    Name = "⚡ BOSS RUSH",
    TextSize = 18,
    Glass = true,
    Outline = true
})

RushSection:AddToggle({
    Name = "ENABLE BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossRush",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsBossRush = Value
        Notify(Value and "Boss Rush Enabled" or "Boss Rush Disabled")
    end
})

local QuestSection = ModeTab:AddSection({
    Name = "🔮 QUEST CHAINS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

QuestSection:AddToggle({
    Name = "DUNGEON QUEST (6 PIECES)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsDungeonQuest = Value
        if Value then
            getgenv().Config.IsHogyokuQuest = false
            if OrionLib.Flags["HogyokuQuest"] then OrionLib.Flags["HogyokuQuest"]:SetValue(false) end
        end
        Notify(Value and "Dungeon Quest Enabled" or "Dungeon Quest Disabled")
    end
})

QuestSection:AddParagraph({
    Title = "Dungeon Info",
    Desc = "Collect 6 pieces:\nDouble → Rune → Cid → Double → Rune → Cid",
    Image = "info",
    ImageSize = 32
})

QuestSection:AddToggle({
    Name = "HOGYOKU QUEST (5 FRAGMENTS)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsHogyokuQuest = Value
        if Value then
            getgenv().Config.IsDungeonQuest = false
            if OrionLib.Flags["DungeonQuest"] then OrionLib.Flags["DungeonQuest"]:SetValue(false) end
        end
        Notify(Value and "Hogyoku Quest Enabled" or "Hogyoku Quest Disabled")
    end
})

QuestSection:AddParagraph({
    Title = "Hogyoku Info",
    Desc = "Collect 5 fragments:\nAizen → Ichigo → Saber → Rimuru → True Aizen",
    Image = "info",
    ImageSize = 32
})

--==================================================
-- SKILL TAB
--==================================================
local SkillMainSection = SkillTab:AddSection({
    Name = "🎯 AUTO SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SkillMainSection:AddToggle({
    Name = "USE SKILL Z",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillZ",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.Z = Value
    end
})

SkillMainSection:AddToggle({
    Name = "USE SKILL X",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillX",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.X = Value
    end
})

SkillMainSection:AddToggle({
    Name = "USE SKILL C",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillC",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.C = Value
    end
})

SkillMainSection:AddToggle({
    Name = "USE SKILL V",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillV",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.V = Value
    end
})

SkillMainSection:AddToggle({
    Name = "USE SKILL F (NUKE)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillF",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.F = Value
    end
})

SkillMainSection:AddToggle({
    Name = "🔥 ALL SKILLS ON/OFF",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AllSkills",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.Z = Value
        getgenv().Config.AutoSkills.X = Value
        getgenv().Config.AutoSkills.C = Value
        getgenv().Config.AutoSkills.V = Value
        getgenv().Config.AutoSkills.F = Value
        
        if OrionLib.Flags["SkillZ"] then OrionLib.Flags["SkillZ"]:SetValue(Value) end
        if OrionLib.Flags["SkillX"] then OrionLib.Flags["SkillX"]:SetValue(Value) end
        if OrionLib.Flags["SkillC"] then OrionLib.Flags["SkillC"]:SetValue(Value) end
        if OrionLib.Flags["SkillV"] then OrionLib.Flags["SkillV"]:SetValue(Value) end
        if OrionLib.Flags["SkillF"] then OrionLib.Flags["SkillF"]:SetValue(Value) end
    end
})

SkillMainSection:AddSlider({
    Name = "⏱️ SKILL COOLDOWN (ms)",
    Min = 100,
    Max = 3000,
    Default = 500,
    Increment = 10,
    ValueName = "ms",
    Outline = true,
    Flag = "SkillCooldown",
    Save = true,
    Callback = function(Value)
        getgenv().Config.SkillCooldown = Value / 1000
    end
})

local HakiSection = SkillTab:AddSection({
    Name = "⬛ HAKI",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HakiSection:AddToggle({
    Name = "AUTO ARMAMENT HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(Value)
        pcall(function() hakiRemote:FireServer("Toggle") end)
    end
})

HakiSection:AddToggle({
    Name = "AUTO OBSERVATION HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoObsHaki",
    Save = true,
    Callback = function(Value)
        pcall(function() obsHakiRemote:FireServer("Toggle") end)
    end
})

--==================================================
-- ITEMS TAB
--==================================================
local ItemMainSection = ItemTab:AddSection({
    Name = "📦 AUTO CHEST",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ItemMainSection:AddToggle({
    Name = "AUTO OPEN CHESTS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsAutoChest = Value
    end
})

local MerchantSection = ItemTab:AddSection({
    Name = "🛒 AUTO MERCHANT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MerchantSection:AddToggle({
    Name = "AUTO BUY FROM MERCHANT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoMerchant",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsAutoMerchant = Value
    end
})

MerchantSection:AddDropdown({
    Name = "🛒 ITEM TO BUY",
    Default = "Boss Key",
    Options = {"Boss Key", "Clan Reroll", "Dungeon Key", "Haki Color Reroll", "Race Reroll", "Rush Key", "Trait Reroll"},
    Multi = false,
    Outline = true,
    Flag = "MerchantItem",
    Save = true,
    Callback = function(Value)
        getgenv().Config.MerchantItem = Value
    end
})

--==================================================
-- SETTINGS TAB
--==================================================
local SettingsSection = SettingTab:AddSection({
    Name = "🔧 UTILITY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SettingsSection:AddToggle({
    Name = "👻 NOCLIP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsNoclip = Value
        Notify(Value and "Noclip ON" or "Noclip OFF")
    end
})

SettingsSection:AddToggle({
    Name = "ANTI-AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AntiAFK = Value
    end
})

SettingsSection:AddToggle({
    Name = "FPS BOOST (BLACK SCREEN)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        getgenv().Config.FpsBoost = Value
        if Value then
            Lighting.Brightness = 0
            Lighting.GlobalShadows = false
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
        else
            restoreOriginalSettings()
        end
    end
})

SettingsSection:AddToggle({
    Name = "WHITE SCREEN MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "WhiteScreen",
    Save = true,
    Callback = function(Value)
        getgenv().Config.WhiteScreen = Value
        RunService:Set3dRenderingEnabled(not Value)
    end
})

SettingsSection:AddToggle({
    Name = "AUTO REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoRejoin = Value
    end
})

SettingsSection:AddToggle({
    Name = "TIMED REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "TimedRejoin",
    Save = true,
    Callback = function(Value)
        getgenv().Config.TimedRejoin = Value
    end
})

SettingsSection:AddSlider({
    Name = "REJOIN DELAY (MINUTES)",
    Min = 1,
    Max = 120,
    Default = 10,
    Increment = 1,
    ValueName = "min",
    Outline = true,
    Flag = "RejoinDelay",
    Save = true,
    Callback = function(Value)
        getgenv().Config.RejoinDelay = Value
    end
})

SettingsSection:AddToggle({
    Name = "FRIEND-ONLY MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FriendOnly",
    Save = true,
    Callback = function(Value)
        getgenv().Config.FriendOnly = Value
    end
})

-- Teleport Section
local TeleportSection = SettingTab:AddSection({
    Name = "📍 TELEPORT TO ISLAND",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local islandNames = {"Starter","Jungle","Desert","Snow","Sailor","Shibuya","HuecoMundo","Boss","Dungeon","Shinjuku","Slime","Academy","Judgement","SoulSociety"}
for _, name in ipairs(islandNames) do
    TeleportSection:AddButton({
        Name = PortalDisplayName(name),
        Icon = "map-pin",
        Outline = true,
        Callback = function()
            if getgenv().Config.IsFarm then
                Notify("Disable Auto Farm first!", 2)
                return
            end
            ForceTP(name)
            Notify("Teleporting to " .. PortalDisplayName(name))
        end
    })
end

-- Debug Section
local DebugSection = SettingTab:AddSection({
    Name = "📝 DEBUG",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DebugSection:AddButton({
    Name = "🗺️ PRINT QUEST DATA",
    Icon = "bug",
    Outline = true,
    Callback = function()
        print("\n═══ QUEST CONFIG DUMP ═══")
        for npcName, data in pairs(questcheck.RepeatableQuests) do
            local req = data.requirements and data.requirements[1]
            local mobType = req and req.npcType or "???"
            local amount = req and req.amount or "?"
            print(string.format("  [%s] Lv.%s → Kill %s x%s", npcName, tostring(data.recommendedLevel), mobType, tostring(amount)))
        end
        print("═══ END ═══\n")
        Notify("Quest data printed to console")
    end
})

DebugSection:AddButton({
    Name = "👾 PRINT MOBS IN MAP",
    Icon = "bug",
    Outline = true,
    Callback = function()
        local npcFolder = GetNPCFolder()
        if not npcFolder then 
            Notify("❌ NPCs not found!")
            return 
        end
        print("\n═══ MOBS ═══")
        local seen = {}
        for _, npc in ipairs(npcFolder:GetChildren()) do
            if npc:IsA("Model") and not seen[npc.Name] then
                seen[npc.Name] = true
                local hum = npc:FindFirstChildOfClass("Humanoid")
                local hp = hum and string.format("HP: %d/%d", hum.Health, hum.MaxHealth) or "no Humanoid"
                print(string.format("  %s — %s", npc.Name, hp))
            end
        end
        print("═══ END ═══\n")
        Notify("Mob data printed to console")
    end
})

DebugSection:AddButton({
    Name = "🔄 REFRESH ALL LISTS",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildMobDatabase()
        buildBossList()
        Notify(string.format("✅ Found %d mobs, %d bosses", #MobDatabase, #BossList))
    end
})

-- Destroy Button
local DestroySection = SettingTab:AddSection({
    Name = "⚠️ DANGER ZONE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DestroySection:AddButton({
    Name = "💀 DESTROY GUI",
    Icon = "skull",
    Outline = true,
    Callback = function()
        getgenv().Config.IsFarm = false
        getgenv().Config.IsBossFight = false
        getgenv().Config.IsAutoDungeon = false
        getgenv().Config.IsBossRush = false
        getgenv().Config.IsSummonBoss = false
        getgenv().Config.IsDungeonQuest = false
        getgenv().Config.IsHogyokuQuest = false
        task.delay(0.1, function()
            OrionLib:Destroy()
            _G.SP_Loaded = false
        end)
    end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Configs",
    Icon = "settings"
})

--==================================================
-- FRIEND ONLY MODE
--==================================================
local function checkAndKick(player)
    if not getgenv().Config.FriendOnly or player == Player then return end
    local isFriend = false
    pcall(function() isFriend = Player:IsFriendsWith(player.UserId) end)
    if not isFriend then
        Player:Kick("\n[Security]\nStranger Detected: " .. player.Name)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    checkAndKick(player)
end

Players.PlayerAdded:Connect(checkAndKick)

--==================================================
-- TIMED REJOIN
--==================================================
task.spawn(function()
    local elapsed = 0
    while getgenv().Config.AntiAFK do
        task.wait(1)
        if getgenv().Config.TimedRejoin then
            elapsed = elapsed + 1
            if elapsed >= getgenv().Config.RejoinDelay * 60 then
                elapsed = 0
                task.wait(2)
                pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
            end
        else
            elapsed = 0
        end
    end
end)

--==================================================
-- AUTO REJOIN HANDLER
--==================================================
task.spawn(function()
    local GuiService = game:GetService("GuiService")
    local lastError = ""
    GuiService.ErrorMessageChanged:Connect(function()
        if not getgenv().Config.AutoRejoin then return end
        local err = GuiService:GetErrorMessage()
        if err ~= lastError and err ~= "" then
            lastError = err
            task.wait(5)
            pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
        end
    end)
end)

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if getgenv().Config.AutoHaki then
        pcall(function() hakiRemote:FireServer("Toggle") end)
    end
    if getgenv().Config.AutoObsHaki then
        pcall(function() obsHakiRemote:FireServer("Toggle") end)
    end
end)

--==================================================
-- KEYBINDS (Dari NovaLib)
--==================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- F2 Toggle Farm
    if input.KeyCode == Enum.KeyCode.F2 then
        getgenv().Config.IsFarm = not getgenv().Config.IsFarm
        if OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(getgenv().Config.IsFarm) end
        Notify(getgenv().Config.IsFarm and "Farm ON (F2)" or "Farm OFF (F2)")
    end
    
    -- V Toggle Farm
    if input.KeyCode == Enum.KeyCode.V then
        getgenv().Config.IsFarm = not getgenv().Config.IsFarm
        if OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(getgenv().Config.IsFarm) end
        Notify(getgenv().Config.IsFarm and "Farm ON (V)" or "Farm OFF (V)")
    end
    
    -- B Toggle Boss Fight
    if input.KeyCode == Enum.KeyCode.B then
        getgenv().Config.IsBossFight = not getgenv().Config.IsBossFight
        if OrionLib.Flags["BossFight"] then OrionLib.Flags["BossFight"]:SetValue(getgenv().Config.IsBossFight) end
        Notify(getgenv().Config.IsBossFight and "Boss ON (B)" or "Boss OFF (B)")
    end
    
    -- N Toggle Summon Boss
    if input.KeyCode == Enum.KeyCode.N then
        getgenv().Config.IsSummonBoss = not getgenv().Config.IsSummonBoss
        if OrionLib.Flags["SummonBoss"] then OrionLib.Flags["SummonBoss"]:SetValue(getgenv().Config.IsSummonBoss) end
        Notify(getgenv().Config.IsSummonBoss and "Summon ON (N)" or "Summon OFF (N)")
    end
    
    -- M Toggle All Skills
    if input.KeyCode == Enum.KeyCode.M then
        local anyOn = false
        for _, v in pairs(getgenv().Config.AutoSkills) do
            if v then anyOn = true break end
        end
        local newState = not anyOn
        getgenv().Config.AutoSkills.Z = newState
        getgenv().Config.AutoSkills.X = newState
        getgenv().Config.AutoSkills.C = newState
        getgenv().Config.AutoSkills.V = newState
        getgenv().Config.AutoSkills.F = newState
        
        if OrionLib.Flags["SkillZ"] then OrionLib.Flags["SkillZ"]:SetValue(newState) end
        if OrionLib.Flags["SkillX"] then OrionLib.Flags["SkillX"]:SetValue(newState) end
        if OrionLib.Flags["SkillC"] then OrionLib.Flags["SkillC"]:SetValue(newState) end
        if OrionLib.Flags["SkillV"] then OrionLib.Flags["SkillV"]:SetValue(newState) end
        if OrionLib.Flags["SkillF"] then OrionLib.Flags["SkillF"]:SetValue(newState) end
        if OrionLib.Flags["AllSkills"] then OrionLib.Flags["AllSkills"]:SetValue(newState) end
        
        Notify(newState and "All Skills ON (M)" or "All Skills OFF (M)")
    end
end)

--==================================================
-- PRIORITY MAIN LOOP (Dari NovaLib)
--==================================================
task.spawn(function()
    autoLearnIslandLevels()

    while true do
        task.wait(0.1)

        local char = Player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(1)
            continue
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            task.wait(2)
            continue
        end

        -- Priority 1: Dungeon Quest
        if getgenv().Config.IsDungeonQuest then
            if doDungeonQuest() then
                task.wait(getgenv().Config.AttackCooldown)
                continue
            end
        end

        -- Priority 2: Hogyoku Quest
        if getgenv().Config.IsHogyokuQuest then
            if doHogyokuQuest() then
                task.wait(getgenv().Config.AttackCooldown)
                continue
            end
        end

        -- Priority 3: Auto Dungeon
        if getgenv().Config.IsAutoDungeon then
            if doAutoDungeon() then
                task.wait(getgenv().Config.AttackCooldown)
                continue
            end
        end

        -- Priority 4: Boss Rush
        if getgenv().Config.IsBossRush then
            if doBossRush() then
                task.wait(getgenv().Config.AttackCooldown)
                continue
            end
        end

        -- Priority 5: Summon Boss
        if getgenv().Config.IsSummonBoss then
            if doSummonBoss() then
                task.wait(getgenv().Config.AttackCooldown)
                continue
            end
        end

        -- Priority 6: Boss Fight
        if getgenv().Config.IsBossFight then
            if doBossFight() then
                task.wait(getgenv().Config.AttackCooldown)
                continue
            end
        end

        -- Priority 7: Auto Farm
        if getgenv().Config.IsFarm then
            local targetMobName = getgenv().Config.SelectedMob
            local targetNPC, _, choosenpc

            if not targetMobName then
                targetNPC, _, choosenpc = getTargetQuest()
                targetMobName = choosenpc
            end

            if not targetMobName then
                task.wait(1)
                continue
            end

            -- Accept quest
            if targetNPC then
                pcall(function() questRemote:FireServer(targetNPC) end)
            end

            local mob, dist = findMob(targetMobName)

            if mob then
                local mobH = mob:FindFirstChildOfClass("Humanoid")
                if mobH and mobH.Health > 0 then
                    tweenToMob(mob)
                    task.wait(0.2)

                    while getgenv().Config.IsFarm and mob and mob.Parent and mob:FindFirstChild("HumanoidRootPart") do
                        local h = mob:FindFirstChildOfClass("Humanoid")
                        if not h or h.Health <= 0 then break end
                        tweenToMob(mob)
                        autoAttack(mob)
                        task.wait(getgenv().Config.AttackCooldown)
                    end

                    task.wait(0.3)
                end
            else
                local currentLevel = Player.Data.Level.Value
                teleportToIsland(currentLevel, targetMobName)
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 to toggle UI")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE v4.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Anti-Kick + Anti-TP-Back Hook")
print("✅ Auto Farm with Mob Database")
print("✅ Boss Fight + Summon Boss")
print("✅ Dungeon + Boss Rush Modes")
print("✅ Quest Chains (Dungeon + Hogyoku)")
print("✅ Auto Skills (Z,X,C,V,F)")
print("✅ Auto Chest + Auto Merchant")
print("✅ Noclip + Anti-AFK")
print("✅ Keybinds: F2/V=Farm | B=Boss | N=Summon | M=Skills")
print("═══════════════════════════════════════════════════════")