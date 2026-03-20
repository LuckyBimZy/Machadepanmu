-- ==================== SAILOR PIECE - ULTIMATE AUTO FARM ====================
-- Menggunakan NovaLib UI Library
-- Version: 4.0 - Complete All Features

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
-- LOAD NOVALIB UI LIBRARY
--==================================================
local NovaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jachvn112-droid/sailor-piece-script/refs/heads/main/NovaLib.luau"))()

--==================================================
-- VARIABLES & SERVICES
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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Remote References
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
local autoSpawnBossRemote = Remotes:WaitForChild("RequestAutoSpawn")
local autoSpawnAnosRemote = Remotes:WaitForChild("RequestAutoSpawnAnos")
local autoSpawnStrongestRemote = Remotes:WaitForChild("RequestAutoSpawnStrongest")
local autoSpawnRimuruRemote = RemoteEvents:WaitForChild("RequestAutoSpawnRimuru")
local autoSpawnTrueAizenRemote = RemoteEvents:WaitForChild("RequestAutoSpawnTrueAizen")
local dungeonVoteRemote = Remotes:WaitForChild("DungeonWaveVote")
local dungeonPortalRemote = Remotes:WaitForChild("RequestDungeonPortal")
local slimeCraftRemote = Remotes:WaitForChild("RequestSlimeCraft")
local grailCraftRemote = Remotes:WaitForChild("RequestGrailCraft")

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

--==================================================
-- CONSTANTS & CONFIGURATION
--==================================================
local Constants = {
    ICON = "rbxassetid://105921924721005",
    DISCORD = "https://discord.gg/B3PurfCy",
    NPC_FOLDER = "NPCs",
    BOSS_ISLAND_PORTAL = "Boss",
    ANOS_ISLAND = "Academy",
    LOOK_DOWN = Vector3.new(0, -1, 0),
    
    -- Islands with quest NPCs
    Islands = {
        {Portal = "Starter", FarmUntil = 250, Enemies = {"Thief"}, QuestNPC = "QuestNPC1"},
        {Portal = "Jungle", FarmUntil = 750, Enemies = {"Monkey"}, QuestNPC = "QuestNPC3"},
        {Portal = "Desert", FarmUntil = 1500, Enemies = {"DesertBandit"}, QuestNPC = "QuestNPC5"},
        {Portal = "Snow", FarmUntil = 3000, Enemies = {"Swordsman", "FrostRogue"}, QuestNPC = "QuestNPC7"},
        {Portal = "Shibuya", FarmUntil = 5000, Enemies = {"Sorcerer", "Curse"}, QuestNPC = "QuestNPC9"},
        {Portal = "HuecoMundo", FarmUntil = 6250, Enemies = {"Hollow", "Quincy"}, QuestNPC = "QuestNPC11"},
        {Portal = "Shinjuku", FarmUntil = 8000, Enemies = {"StrongSorcerer"}, QuestNPC = "QuestNPC12"},
        {Portal = "Slime", FarmUntil = 9000, Enemies = {"SlimeWarrior"}, QuestNPC = "QuestNPC14"},
        {Portal = "Academy", FarmUntil = 10000, Enemies = {"AcademyTeacher"}, QuestNPC = "QuestNPC15"},
        {Portal = "Judgement", FarmUntil = 10750, Enemies = {"Swordsman"}, QuestNPC = "QuestNPC16"},
        {Portal = "SoulSociety", FarmUntil = 999999, Enemies = {"Quincy1", "Quincy2", "Quincy3", "Quincy4", "Quincy5"}, QuestNPC = "QuestNPC17"},
    },
    
    TpIslands = {"Starter","Jungle","Desert","Snow","Sailor","Shibuya","HuecoMundo","Boss","Dungeon","Shinjuku","Slime","Academy","Judgement","SoulSociety"},
    
    -- World Bosses
    Bosses = {
        {Name = "AizenBoss", Display = "Aizen", Island = "HuecoMundo"},
        {Name = "AlucardBoss", Display = "Alucard", Island = "Sailor"},
        {Name = "GojoBoss", Display = "Gojo", Island = "Shibuya", RenderNear = "YujiBoss"},
        {Name = "JinwooBoss", Display = "Jinwoo", Island = "Sailor"},
        {Name = "SukunaBoss", Display = "Sukuna", Island = "Shibuya"},
        {Name = "YamatoBoss", Display = "Yamato", Island = "Judgement"},
        {Name = "YujiBoss", Display = "Yuji", Island = "Shibuya"},
    },
    
    -- Summon Bosses
    SummonBosses = {
        {Name = "IchigoBoss", Display = "Ichigo"},
        {Name = "QinShiBoss", Display = "Qin Shi"},
        {Name = "SaberBoss", Display = "Saber"},
        {Name = "AnosBoss", Display = "Anos", Island = "Academy", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "BlessedMaidenBoss", Display = "Blessed Maiden", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "GilgameshBoss", Display = "Gilgamesh", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "RimuruBoss", Display = "Rimuru", Island = "Slime", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "SaberAlterBoss", Display = "Saber Alter", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "StrongestHistoryBoss", Display = "Strongest in History", Island = "Shinjuku", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "StrongestTodayBoss", Display = "Strongest Today", Island = "Shinjuku", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "TrueAizenBoss", Display = "True Aizen", Island = "SoulSociety", Difficulties = {"Normal","Medium","Hard","Extreme"}},
    },
    
    -- Mob mapping untuk quest
    MobQuestMap = {
        ["Thief"] = "QuestNPC1",
        ["Monkey"] = "QuestNPC3",
        ["DesertBandit"] = "QuestNPC5",
        ["FrostRogue"] = "QuestNPC7",
        ["Swordsman"] = "QuestNPC16",
        ["Sorcerer"] = "QuestNPC9",
        ["Curse"] = "QuestNPC9",
        ["Hollow"] = "QuestNPC11",
        ["Quincy"] = "QuestNPC11",
        ["StrongSorcerer"] = "QuestNPC12",
        ["SlimeWarrior"] = "QuestNPC14",
        ["AcademyTeacher"] = "QuestNPC15",
    },
    
    -- Display name mapping untuk dropdown
    MobDisplayToInternal = {
        ["Thief (Lv.10)"] = "Thief",
        ["Thief Boss (Lv.25)"] = "ThiefBoss",
        ["Monkey (Lv.250)"] = "Monkey",
        ["Monkey Boss (Lv.500)"] = "MonkeyBoss",
        ["Desert Bandit (Lv.750)"] = "DesertBandit",
        ["Desert Boss (Lv.1000)"] = "DesertBoss",
        ["Frost Rogue (Lv.1500)"] = "FrostRogue",
        ["Snow Boss (Lv.2000)"] = "SnowBoss",
        ["Sorcerer (Lv.3000)"] = "Sorcerer",
        ["Curse (Lv.3500)"] = "Curse",
        ["Hollow (Lv.4000)"] = "Hollow",
        ["Quincy (Lv.4500)"] = "Quincy",
        ["Strong Sorcerer (Lv.5000)"] = "StrongSorcerer",
        ["Slime (Lv.6000)"] = "SlimeWarrior",
        ["Academy Teacher (Lv.7000)"] = "AcademyTeacher",
        ["Swordsman (Lv.8000)"] = "Swordsman",
    },
    
    MobDisplayList = {
        "Thief (Lv.10)",
        "Thief Boss (Lv.25)",
        "Monkey (Lv.250)",
        "Monkey Boss (Lv.500)",
        "Desert Bandit (Lv.750)",
        "Desert Boss (Lv.1000)",
        "Frost Rogue (Lv.1500)",
        "Snow Boss (Lv.2000)",
        "Sorcerer (Lv.3000)",
        "Curse (Lv.3500)",
        "Hollow (Lv.4000)",
        "Quincy (Lv.4500)",
        "Strong Sorcerer (Lv.5000)",
        "Slime (Lv.6000)",
        "Academy Teacher (Lv.7000)",
        "Swordsman (Lv.8000)",
    },
    
    -- Dungeon Pieces Islands
    DungeonPieceIslands = {"Starter","Jungle","Desert","Snow","Shibuya","HuecoMundo"},
    
    -- Hogyoku Fragment Islands
    HogyokuFragmentIslands = {"Snow","Shibuya","HuecoMundo","Shinjuku","Slime","Judgement"},
    
    -- Chest Names
    ChestNames = {"Common Chest","Rare Chest","Epic Chest","Legendary Chest","Mythical Chest","Divine Chest","Godly Chest"},
    
    -- Merchant Items
    MerchantItems = {"Boss Key","Clan Reroll","Dungeon Key","Haki Color Reroll","Race Reroll","Rush Key","Trait Reroll"},
    
    IgnoreList = {"groupreward","katana","buyer","madoka","training","dummy","merchant","shop","vendor","shadow questline","shadowmonarch","obshakilsinhead","buff","questnpc"},
}

--==================================================
-- CONFIGURATION
--==================================================
getgenv().Config = {
    -- Auto Farm
    AutoFarm = {
        Enabled = false,
        AutoHit = true,
        AutoStats = true,
        AutoHaki = false,
        AutoObsHaki = false,
        AutoEquip = true,
        SelectedWeapon = "None",
        SelectedMob = "Thief",
        SkillCooldown = 0.3
    },
    
    -- Auto Skills
    AutoSkills = {
        Z = false,
        X = false,
        C = false,
        V = false,
        F = false
    },
    
    -- State untuk skill system
    LastSkillTime = 0,
    LastAbilityFire = 0,
    
    -- Mode flags
    IsFarm = false,
    IsBossFight = false,
    IsSummonBossFight = false,
    
    -- Farm Settings
    Farm = {
        HeightOffset = 10,
        TweenSpeed = 100,
        OffsetDist = 5,
        FarmMode = "Plank", -- Plank / Behind
        MoveMode = "Tween",
        SelectedIsland = "Auto",
        AntiAFK = true,
        AutoQuest = true,
        AutoSpawn = false,
        AutoChest = false
    },
    
    -- Boss Systems
    Bosses = {
        Enabled = false,
        Notify = true,
        Selected = {},
        SummonSelected = {}
    },
    
    -- Merchant
    Merchant = {
        Enabled = false,
        Notify = true,
        Selected = {}
    },
    
    -- Quest Systems
    Quests = {
        DungeonEnabled = false,
        HogyokuEnabled = false
    },
    
    -- Misc
    Misc = {
        AntiAFK = true,
        FpsBoost = false,
        WhiteScreen = false,
        AutoRejoin = false,
        TimedRejoin = false,
        RejoinDelay = 10
    },
    
    -- Difficulty Settings
    Difficulty = {
        Gilgamesh = "Normal",
        BlessedMaiden = "Normal",
        SaberAlter = "Normal",
        Rimuru = "Normal",
        Anos = "Normal",
        StrongestToday = "Normal",
        StrongestHistory = "Normal",
        TrueAizen = "Normal"
    }
}

--==================================================
-- STATE VARIABLES
--==================================================
local State = {
    Running = true,
    Kills = 0,
    BossKills = 0,
    KillCount = 0,
    CurIsland = nil,
    CurTarget = nil,
    LockTarget = nil,
    HoverPos = nil,
    TweenOn = false,
    TweenTarget = nil,
    ATween = nil,
    ATweenConn = nil,
    LastEquip = 0,
    LastTP = 0,
    LastEnemy = 0,
    TPCount = 0,
    TPRest = tick(),
    IslandTPd = false,
    SpawnDone = false,
    FarmOrigin = nil,
    QState = "NONE",
    BossTargetName = nil,
    BossDeathTimes = {},
    BossTimerCache = {},
    BossTPDone = false,
    LastBossTP = 0,
    BossTPRetries = 0,
    BossCurrentIsland = nil,
    BossPosCache = {},
    SummonBossFight = false,
    SummonBossTarget = nil,
    SummonBossTPDone = false,
    LastSummonBossTP = 0,
    SummonBossCommitted = {},
    SummonBossCurrentIsland = nil,
    SummonBossOrder = 0,
    SummonBossFailCount = {},
    SummonBossFireTime = {},
    SummonBossLockedDiff = {},
    AutoSpawnActive = {},
    DungeonStep = 0,
    DungeonCollected = {},
    HogyokuStep = 0,
    HogyokuCollected = {},
    Conns = {},
    RayParams = RaycastParams.new(),
    LastSkillUse = 0,
    CachedAbilityRemote = nil,
    CurrentTween = nil,
    NoclipActive = false,
    LastCanCollide = 0
}

-- Inisialisasi RayParams
State.RayParams.FilterType = Enum.RaycastFilterType.Exclude

--==================================================
-- UTILITY FUNCTIONS
--==================================================

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function DistTo(pos)
    if not pos then return 99999 end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 99999 end
    return (hrp.Position - pos).Magnitude
end

local function GetNPCFolder()
    local direct = Workspace:FindFirstChild(Constants.NPC_FOLDER)
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

local function ModelCF(e)
    if not e then return nil end
    local r = RootPos(e)
    if r then return CFrame.new(r) end
    local ok, cf = pcall(function() return e:GetPivot() end)
    if ok and cf then return cf end
    return nil
end

local function PortalDisplayName(portal)
    local names = {HuecoMundo = "Hueco Mundo", SoulSociety = "Soul Society"}
    return names[portal] or portal
end

local function GetIslandNames()
    local n = {"Auto"}
    for _, i in ipairs(Constants.Islands) do
        table.insert(n, PortalDisplayName(i.Portal))
    end
    return n
end

local function DisplayToPortal(display)
    for _, i in ipairs(Constants.Islands) do
        if PortalDisplayName(i.Portal) == display then
            return i.Portal
        end
    end
    return display
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

local function IslandForLevel(lvl)
    for _, i in ipairs(Constants.Islands) do
        if lvl < i.FarmUntil then return i end
    end
    return Constants.Islands[#Constants.Islands]
end

local function IslandByName(n)
    for _, i in ipairs(Constants.Islands) do
        if i.Portal == n then return i end
    end
    return nil
end

local function GetFarmIsland()
    local lvl = GetLevel()
    if getgenv().Config.Farm.SelectedIsland == "Auto" then
        return IslandForLevel(lvl)
    end
    return IslandByName(getgenv().Config.Farm.SelectedIsland) or IslandForLevel(lvl)
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
    for _, ig in ipairs(Constants.IgnoreList) do
        if lo:find(ig, 1, true) then return true end
    end
    if lo:match("boss$") then return true end
    return false
end

local function isMobMatch(npcName, targetMob)
    if not npcName or not targetMob then return false end
    if npcName == targetMob then return true end
    local pattern = "^" .. targetMob .. "%d+$"
    return string.match(npcName, pattern) ~= nil
end

local function MatchEnemy(name, island)
    if not island then return false end
    local lo = (name or ""):lower()
    for _, e in ipairs(island.Enemies) do
        local el = (e or ""):lower()
        if lo:sub(1, #el) == el then return true end
    end
    return false
end

local function IsAnosModel(name)
    return name and name:find("AnosBoss") ~= nil
end

local function IsStrongestTodayModel(name)
    return name and name:find("StrongestofTodayBoss") ~= nil
end

local function IsStrongestHistoryModel(name)
    return name and name:find("StrongestinHistoryBoss") ~= nil
end

local function IsStrongestModel(name)
    return IsStrongestTodayModel(name) or IsStrongestHistoryModel(name)
end

local function IsBoss(n)
    for _, b in ipairs(Constants.Bosses) do
        if b.Name == n then return true end
    end
    return IsAnosModel(n) or IsStrongestModel(n)
end

local function GetBossIsland(name)
    for _, b in ipairs(Constants.Bosses) do
        if b.Name == name then return b.Island end
    end
    if IsAnosModel(name) then return Constants.ANOS_ISLAND end
    return nil
end

local function GetBossDisplay(name)
    for _, b in ipairs(Constants.Bosses) do
        if b.Name == name then return b.Display end
    end
    if IsAnosModel(name) then
        local diff = name:match("AnosBoss_(.+)")
        if diff then return "Anos (" .. diff .. ")" end
        return "Anos"
    end
    return name
end

local function AbandonAllQuests()
    State.QState = "NONE"
    pcall(function() abandonRemote:FireServer("repeatable") end)
    for _, n in ipairs({"HogyokuUnlock","HogyokuQuestNPC","Hogyoku","HogyokuFragment","HogyokuQuest","SoulSocietyUnlock","SoulSociety"}) do
        pcall(function() abandonRemote:FireServer(n) end)
    end
    for _, isl in ipairs(Constants.Islands) do
        pcall(function() abandonRemote:FireServer(isl.QuestNPC) end)
    end
end

local function FullReset()
    AbandonAllQuests()
    State.CurIsland = nil
    State.IslandTPd = false
    State.SpawnDone = false
    State.FarmOrigin = nil
    State.LastEnemy = 0
    State.LastTP = 0
    State.TPCount = 0
    State.TPRest = tick()
    State.CurTarget = nil
    State.LockTarget = nil
    State.HoverPos = nil
    State.QState = "NONE"
    State.BossTargetName = nil
    State.BossFight = false
    State.BossTPDone = false
    State.LastBossTP = 0
    State.BossTPRetries = 0
    State.BossCurrentIsland = nil
    State.SummonBossFight = false
    State.SummonBossTarget = nil
    State.SummonBossTPDone = false
    State.LastSummonBossTP = 0
    State.SummonBossCommitted = {}
    State.SummonBossCurrentIsland = nil
    State.SummonBossOrder = 0
    State.HogyokuStep = 0
    State.HogyokuCollected = {}
    State.DungeonStep = 0
    State.DungeonCollected = {}
    
    -- Reset mode flags
    getgenv().Config.IsFarm = false
    getgenv().Config.IsBossFight = false
    getgenv().Config.IsSummonBossFight = false
end

local function ForceTP(portal)
    State.LastTP = 0
    State.TPCount = 0
    State.TPRest = tick()
    local ok = false
    pcall(function() tpRemote:FireServer(portal) ok = true end)
    if not ok then
        task.wait(1)
        pcall(function() tpRemote:FireServer(portal) ok = true end)
    end
    State.LastTP = tick()
    State.TPCount = 1
    return ok
end

local function StopTween()
    if State.ATweenConn then
        pcall(function() State.ATweenConn:Disconnect() end)
        State.ATweenConn = nil
    end
    if State.ATween then
        pcall(function() State.ATween:Cancel() end)
        State.ATween = nil
    end
    if State.CurrentTween then
        pcall(function() State.CurrentTween:Cancel() end)
        State.CurrentTween = nil
    end
    State.TweenOn = false
    State.TweenTarget = nil
end

local function ClearTarget()
    State.CurTarget = nil
    State.LockTarget = nil
    StopTween()
end

local function FindEnemies(island, selectedMob)
    local nf = GetNPCFolder()
    if not island then return {} end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local origin = State.FarmOrigin
    local out = {}
    
    local function checkModel(m)
        if m:IsA("Model") and not m:IsDescendantOf(Player.Character) then
            local hm = GetHum(m)
            if hm and hm.Health > 0 and not ShouldIgnore(m.Name) then
                local isMatch = false
                if selectedMob and selectedMob ~= "All" then
                    isMatch = isMobMatch(m.Name, selectedMob)
                else
                    isMatch = MatchEnemy(m.Name, island)
                end
                if isMatch then
                    local p = RootPos(m)
                    if p then
                        if hrp and (p - hrp.Position).Magnitude > 900 then return end
                        if origin and (p - origin).Magnitude > 1200 then return end
                    end
                    table.insert(out, m)
                end
            end
        end
    end
    
    if nf then
        for _, desc in ipairs(nf:GetChildren()) do
            if desc:IsA("Model") then
                checkModel(desc)
            elseif desc:IsA("Folder") then
                for _, m in ipairs(desc:GetChildren()) do
                    if m:IsA("Model") then checkModel(m) end
                end
            end
        end
    end
    return out
end

local function NearestFrom(list)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local myY = hrp.Position.Y
    local best, bd = nil, math.huge
    for _, e in ipairs(list) do
        local p = RootPos(e)
        if p and math.abs(p.Y - myY) < 150 then
            local d = (p - hrp.Position).Magnitude
            if d < bd then
                bd = d
                best = e
            end
        end
    end
    return best
end

-- Get farm position based on mode
local function GetGoalForEnemy(enemy)
    local pos = RootPos(enemy)
    if not pos then return nil, nil end
    
    local farmMode = getgenv().Config.Farm.FarmMode
    
    if farmMode == "Behind" then
        local cf = ModelCF(enemy)
        if cf then
            local behind = cf.Position - cf.LookVector * getgenv().Config.Farm.OffsetDist
            return Vector3.new(behind.X, behind.Y + 1, behind.Z), cf.Position
        end
        return Vector3.new(pos.X, pos.Y + 1, pos.Z), pos
    else -- Plank mode (above)
        local heightOffset = getgenv().Config.Farm.HeightOffset
        return Vector3.new(pos.X, pos.Y + heightOffset, pos.Z), pos
    end
end

local function TweenTo(enemy)
    if not enemy then return end
    
    local goal, look = GetGoalForEnemy(enemy)
    if not goal then return end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local d = (hrp.Position - goal).Magnitude
    if d > 600 then return end
    
    if getgenv().Config.Farm.MoveMode == "Teleport" then
        StopTween()
        hrp.CFrame = CFrame.new(goal, look or goal)
        State.LockTarget = enemy
        return
    end
    
    if State.TweenOn and State.TweenTarget == enemy then return end
    
    StopTween()
    State.TweenOn = true
    State.TweenTarget = enemy
    State.LockTarget = nil
    
    local stepDist = math.min(d, 80)
    local dir = (goal - hrp.Position).Unit
    local stepGoal = hrp.Position + (dir * stepDist)
    local cf = CFrame.new(stepGoal, look or goal)
    local dur = math.clamp(stepDist / math.max(getgenv().Config.Farm.TweenSpeed, 1), 0.06, 3.0)
    
    State.ATween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = cf})
    State.ATweenConn = State.ATween.Completed:Connect(function()
        State.ATween = nil
        State.ATweenConn = nil
        State.TweenOn = false
        State.TweenTarget = nil
        State.LockTarget = enemy
        State.HoverPos = goal
    end)
    State.ATween:Play()
end

local function TweenToPoint(goal)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local d = (hrp.Position - goal).Magnitude
    if d > 1500 then return end
    
    if d < 5 then
        State.HoverPos = goal
        return
    end
    
    StopTween()
    State.TweenOn = true
    State.LockTarget = nil
    
    local cf = CFrame.new(goal, goal + Constants.LOOK_DOWN)
    local dur = math.clamp(d / math.max(getgenv().Config.Farm.TweenSpeed, 20), 0.05, 30)
    
    State.ATween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = cf})
    State.ATweenConn = State.ATween.Completed:Connect(function()
        State.ATween = nil
        State.ATweenConn = nil
        State.TweenOn = false
        State.HoverPos = goal
    end)
    State.ATween:Play()
end

--==================================================
-- ENHANCED AUTO SKILLS SYSTEM
--==================================================
local function GetAbilityRemote()
    if State.CachedAbilityRemote and State.CachedAbilityRemote.Parent then
        return State.CachedAbilityRemote
    end
    
    State.CachedAbilityRemote = nil
    pcall(function()
        State.CachedAbilityRemote = ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility", 2)
    end)
    
    return State.CachedAbilityRemote
end

local function useSkills()
    local now = tick()
    local cooldown = getgenv().Config.AutoFarm.SkillCooldown or 0.3
    
    if now - getgenv().Config.LastSkillTime < cooldown then return end
    
    local remote = GetAbilityRemote()
    if not remote then return end
    
    local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
    local anySkillUsed = false
    
    for key, slot in pairs(skillMap) do
        if getgenv().Config.AutoSkills[key] then
            local success = pcall(function() 
                remote:FireServer(slot)
                return true
            end)
            if success then
                anySkillUsed = true
            end
        end
    end
    
    if anySkillUsed then
        getgenv().Config.LastSkillTime = now
        getgenv().Config.LastAbilityFire = now
    end
end

-- Skill spam loop
task.spawn(function()
    while State.Running do
        task.wait(0.05)
        
        if (getgenv().Config.IsFarm or getgenv().Config.IsBossFight or getgenv().Config.IsSummonBossFight) and getgenv().Config.AutoFarm.AutoHit then
            useSkills()
        end
    end
end)

--==================================================
-- EQUIP WEAPON FUNCTIONS
--==================================================
local function GetAllTools()
    local tools = {}
    local char = Player.Character
    local backpack = Player:FindFirstChild("Backpack")
    
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool)
            end
        end
    end
    
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(tools, tool)
            end
        end
    end
    
    return tools
end

local function GetCurrentWeapon()
    local char = Player.Character
    if not char then return nil end
    
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

local function EquipWeapon(weaponName)
    if not weaponName or weaponName == "None" then return false end
    
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    
    if char:FindFirstChild(weaponName) then
        return true
    end
    
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local tool = backpack:FindFirstChild(weaponName)
    if not tool or not tool:IsA("Tool") then return false end
    
    hum:UnequipTools()
    task.wait(0.1)
    hum:EquipTool(tool)
    task.wait(0.2)
    
    return char:FindFirstChild(weaponName) ~= nil
end

local function EquipBothWeapons()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return end
    
    local equipped = GetAllTools()
    local hasMelee, hasSword = false, false
    
    for _, t in ipairs(equipped) do
        if t.Name:lower() == "combat" then
            hasMelee = true
        else
            hasSword = true
        end
    end
    
    if hasMelee and hasSword then return end
    
    local allTools = {}
    for _, ch in ipairs(backpack:GetChildren()) do
        if ch:IsA("Tool") then table.insert(allTools, ch) end
    end
    for _, t in ipairs(equipped) do table.insert(allTools, t) end
    
    local melee, sword = nil, nil
    for _, t in ipairs(allTools) do
        if t.Name:lower() == "combat" then
            melee = t
        elseif not sword then
            sword = t
        end
    end
    
    if melee and sword then
        hum:UnequipTools()
        task.wait(0.1)
        pcall(function() sword.Parent = char end)
        task.wait(0.05)
        pcall(function() melee.Parent = char end)
    elseif sword and not melee then
        pcall(function() sword.Parent = char end)
    elseif melee and not sword then
        pcall(function() melee.Parent = char end)
    end
end

local function AutoEquipLogic()
    if not getgenv().Config.AutoFarm.AutoEquip or not IsAlive() then return end
    
    local currentWeapon = GetCurrentWeapon()
    local targetWeapon = getgenv().Config.AutoFarm.SelectedWeapon
    
    if targetWeapon == "None" then
        EquipBothWeapons()
        return
    end
    
    if currentWeapon and currentWeapon.Name == targetWeapon then return end
    
    if targetWeapon ~= "None" then
        EquipWeapon(targetWeapon)
    end
end

local function RefreshWeaponList()
    local weapons = {"None"}
    local backpack = Player:FindFirstChild("Backpack")
    local char = Player.Character
    
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(weapons, tool.Name)
            end
        end
    end
    
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and not table.find(weapons, tool.Name) then
                table.insert(weapons, tool.Name)
            end
        end
    end
    
    table.sort(weapons)
    return weapons
end

local function GetWeaponList()
    return RefreshWeaponList()
end

--==================================================
-- ATTACK FUNCTION
--==================================================
local function Attack(tgt)
    pcall(function() hitRemote:FireServer(tgt) end)
    
    local tools = GetAllTools()
    for _, tool in ipairs(tools) do
        pcall(function() tool:Activate() end)
    end
end

--==================================================
-- AUTO QUEST FUNCTIONS
--==================================================
local function QuestAccept(island)
    if not island or not island.QuestNPC then return end
    pcall(function() questRemote:FireServer(island.QuestNPC) end)
    State.LastQuestAccept = tick()
    State.QState = "ACTIVE"
end

local function QuestRepeatFire(island)
    if not island or not island.QuestNPC then return end
    pcall(function() questRemote:FireServer(island.QuestNPC) end)
    State.LastQuestAccept = tick()
    State.QState = "ACTIVE"
end

local function QuestCompletionScan()
    if State.QState ~= "ACTIVE" then return end
    if tick() - State.LastQuestAccept > 60 then
        State.QState = "NONE"
        return
    end
    if tick() - State.LastQuestAccept < 8 then return end
    
    local pg = Player:FindFirstChild("PlayerGui")
    if not pg then return end
    
    local hasQuestUI = false
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local t = (d.Text or ""):lower()
            if t:find("quest complet") or t:find("abandon") then
                State.QState = "NONE"
                return
            end
            if t:find("%d+%s*/%s*%d+") or t:find("kill") or t:find("collect") or t:find("objective") or t:find("quest") then
                hasQuestUI = true
            end
        end
    end
    if not hasQuestUI and tick() - State.LastQuestAccept > 20 then
        State.QState = "NONE"
    end
end

--==================================================
-- DUNGEON QUEST SYSTEM
--==================================================
local function FindDungeonPiece(island)
    local islandLow = island:lower()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "DungeonPuzzlePiece" and desc:IsA("BasePart") then
            local anc = desc.Parent
            while anc and anc ~= Workspace do
                if anc.Name:lower():find(islandLow, 1, true) then
                    return desc
                end
                anc = anc.Parent
            end
        end
    end
    return nil
end

local function DungeonCollectPiece(piece)
    StopTween()
    ClearTarget()
    State.HoverPos = nil
    State.LockTarget = nil
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(piece.Position + Vector3.new(0, 2, 0))
    end
    task.wait(0.15)
    
    local pp = piece:FindFirstChild("PuzzlePrompt") or piece:FindFirstChildOfClass("ProximityPrompt")
    if not pp then
        for _, ch in ipairs(piece:GetDescendants()) do
            if ch:IsA("ProximityPrompt") then
                pp = ch
                break
            end
        end
    end
    if pp then
        pcall(function() fireproximityprompt(pp) end)
        task.wait(0.2)
        pcall(function() fireproximityprompt(pp) end)
    end
end

local function AcceptDungeonQuest()
    pcall(function() 
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DungeonQuestAccept", 2)
        if remote then remote:FireServer() end
    end)
    task.wait(0.3)
    -- Click Yes button
    local pg = Player:FindFirstChild("PlayerGui")
    if pg then
        for _, desc in ipairs(pg:GetDescendants()) do
            if desc:IsA("TextButton") and (desc.Text:lower() == "yes" or desc.Name:lower() == "yes") then
                pcall(function()
                    for _, conn in ipairs(getconnections(desc.Activated)) do
                        conn:Fire()
                    end
                end)
                break
            end
        end
    end
    task.wait(0.3)
    pcall(function() questRemote:FireServer("DungeonUnlock") end)
end

local function DoDungeonQuestTick()
    if not getgenv().Config.Quests.DungeonEnabled then return end
    
    local step = State.DungeonStep
    
    if step < 1 then
        -- Check if all pieces already collected
        local anyUncollected = false
        for _, isl in ipairs(Constants.DungeonPieceIslands) do
            local p = FindDungeonPiece(isl)
            if p then
                anyUncollected = true
                break
            end
        end
        if not anyUncollected then
            -- TP to first island to verify
            ForceTP(Constants.DungeonPieceIslands[1])
            task.wait(1)
            local p = FindDungeonPiece(Constants.DungeonPieceIslands[1])
            if not p then
                getgenv().Config.Quests.DungeonEnabled = false
                State.DungeonStep = 0
                State.DungeonCollected = {}
                print("All dungeon pieces already collected!")
                return
            end
        end
        AcceptDungeonQuest()
        State.DungeonStep = 1
        State.DungeonCollected = {}
        return
    end
    
    if step > 6 then
        ForceTP("Dungeon")
        task.wait(1)
        AcceptDungeonQuest()
        getgenv().Config.Quests.DungeonEnabled = false
        State.DungeonStep = 0
        State.DungeonCollected = {}
        print("Dungeon quest completed!")
        return
    end
    
    local island = Constants.DungeonPieceIslands[step]
    if not island then
        State.DungeonStep = step + 1
        return
    end
    if State.DungeonCollected[step] then
        State.DungeonStep = step + 1
        return
    end
    
    ForceTP(island)
    task.wait(0.5)
    task.wait(0.5)
    
    local piece = FindDungeonPiece(island)
    if not piece then
        task.wait(1)
        piece = FindDungeonPiece(island)
    end
    if not piece then
        task.wait(1)
        piece = FindDungeonPiece(island)
    end
    
    if piece then
        DungeonCollectPiece(piece)
    end
    
    State.DungeonCollected[step] = true
    State.DungeonStep = step + 1
end

--==================================================
-- HOGYOKU QUEST SYSTEM
--==================================================
local function FindHogyokuFragment(stepNum)
    local target = "hogyoku fragment #" .. stepNum
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and (desc.ObjectText or ""):lower() == target then
            return desc
        end
    end
    return nil
end

local function DoHogyokuQuestTick()
    if not getgenv().Config.Quests.HogyokuEnabled then return end
    
    local step = State.HogyokuStep
    
    if step == 0 then
        ForceTP("HuecoMundo")
        State.HogyokuStep = 0.5
        return
    end
    
    if step == 0.5 then
        task.wait(1)
        task.wait(0.5)
        
        local npc = Workspace:FindFirstChild("HogyokuQuestNPC", true)
        if not npc then
            task.wait(2)
            npc = Workspace:FindFirstChild("HogyokuQuestNPC", true)
        end
        if not npc then
            State.HogyokuStep = 0
            return
        end
        
        local npcPos
        local p = npc:FindFirstChild("HumanoidRootPart", true) or npc:FindFirstChild("Head", true)
        if p and p:IsA("BasePart") then
            npcPos = p.Position
        end
        if not npcPos then
            for _, d in ipairs(npc:GetDescendants()) do
                if d:IsA("BasePart") then
                    npcPos = d.Position
                    break
                end
            end
        end
        
        if npcPos then
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(npcPos + Vector3.new(0, 0, 3))
            end
        end
        task.wait(0.3)
        
        for _, desc in ipairs(npc:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                pcall(function() fireproximityprompt(desc) end)
            end
        end
        task.wait(0.5)
        
        State.HogyokuStep = 1
        State.HogyokuCollected = {}
        task.wait(1)
        return
    end
    
    if step > 6 then
        ForceTP("HuecoMundo")
        task.wait(1)
        task.wait(0.5)
        
        local npc = Workspace:FindFirstChild("HogyokuQuestNPC", true)
        if npc then
            for _, desc in ipairs(npc:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(desc) end)
                end
            end
        end
        
        getgenv().Config.Quests.HogyokuEnabled = false
        State.HogyokuStep = 0
        State.HogyokuCollected = {}
        print("Hogyoku quest completed!")
        return
    end
    
    local island = Constants.HogyokuFragmentIslands[step]
    if not island then
        State.HogyokuStep = step + 1
        return
    end
    if State.HogyokuCollected[step] then
        State.HogyokuStep = step + 1
        return
    end
    
    ForceTP(island)
    task.wait(0.5)
    task.wait(0.5)
    
    local prompt = FindHogyokuFragment(step)
    if not prompt then
        task.wait(1)
        prompt = FindHogyokuFragment(step)
    end
    if not prompt then
        task.wait(1)
        prompt = FindHogyokuFragment(step)
    end
    
    if prompt then
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local par = prompt.Parent
        if par and hrp then
            local pos = par:IsA("BasePart") and par.Position or (par:IsA("Model") and RootPos(par)) or nil
            if pos then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
            end
        end
        task.wait(0.1)
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.15)
        pcall(function() fireproximityprompt(prompt) end)
        State.HogyokuCollected[step] = true
        State.HogyokuStep = step + 1
    end
end

--==================================================
-- WORLD BOSS SYSTEM
--==================================================
local function CheckBoss(name)
    local nf = GetNPCFolder()
    if not nf then return nil end
    
    for _, m in ipairs(nf:GetChildren()) do
        if m:IsA("Model") and m.Name == name then
            local hm = GetHum(m)
            if hm and hm.Health > 0 then
                local p = RootPos(m)
                if p then State.BossPosCache[name] = p end
                return m
            end
        end
    end
    
    if IsAnosModel(name) then
        for _, m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and IsAnosModel(m.Name) then
                local hm = GetHum(m)
                if hm and hm.Health > 0 then
                    local p = RootPos(m)
                    if p then State.BossPosCache[name] = p end
                    return m
                end
            end
        end
    end
    return nil
end

local function RecordBossDeath(name)
    State.BossDeathTimes[name] = tick()
end

local function IsBossOnCooldown(name)
    local dt = State.BossDeathTimes[name]
    if dt and tick() - dt < 30 then return true end
    return false
end

local function PickNextBossName()
    local nf = GetNPCFolder()
    if not nf then return nil end
    
    local alive = {}
    for _, m in ipairs(nf:GetChildren()) do
        if m:IsA("Model") then
            local hm = GetHum(m)
            if hm and hm.Health > 0 then
                for _, b in ipairs(Constants.Bosses) do
                    if m.Name == b.Name and getgenv().Config.Bosses.Selected[b.Name] and not IsBossOnCooldown(b.Name) then
                        table.insert(alive, b.Name)
                    end
                end
            end
        end
    end
    
    if #alive == 0 then return nil end
    return alive[1]
end

local function ExitBossMode(lastBossName)
    local bi = lastBossName and GetBossIsland(lastBossName)
    local savedHover = State.HoverPos
    
    State.BossFight = false
    State.BossTargetName = nil
    State.BossTPDone = false
    State.BossCurrentIsland = nil
    ClearTarget()
    State.HoverPos = nil
    State.LastBossTP = 0
    State.BossTPRetries = 0
    
    local farmIsland = GetFarmIsland()
    if bi and farmIsland and farmIsland.Portal == bi then
        State.CurIsland = farmIsland
        State.IslandTPd = true
        State.SpawnDone = true
        State.LastEnemy = tick()
        if savedHover then State.HoverPos = savedHover end
    else
        State.CurIsland = nil
        State.IslandTPd = false
        State.SpawnDone = false
    end
end

local function DoBossTick()
    if not State.BossTargetName then
        local nextName = PickNextBossName()
        if nextName then
            State.BossTargetName = nextName
            State.BossTPDone = false
            State.LastBossTP = 0
            ClearTarget()
            State.HoverPos = nil
            local nextBossIsland = GetBossIsland(nextName)
            if State.BossCurrentIsland ~= nextBossIsland then State.BossCurrentIsland = nil end
            print("Next boss: " .. GetBossDisplay(nextName) .. " on " .. PortalDisplayName(nextBossIsland or "?"))
        else
            ExitBossMode(nil)
        end
        return
    end
    
    if not State.BossTPDone then
        local bi = GetBossIsland(State.BossTargetName)
        if not bi then
            State.BossTargetName = nil
            return
        end
        
        local model = CheckBoss(State.BossTargetName)
        if model then
            local bp = RootPos(model)
            if bp and DistTo(bp) < 300 then
                State.BossTPDone = true
                State.BossCurrentIsland = bi
                State.BossTPRetries = 0
                return
            end
        end
        
        if tick() - State.LastBossTP < 4 then
            task.wait(0.2)
            return
        end
        
        ClearTarget()
        State.HoverPos = nil
        State.LastBossTP = tick()
        
        local alreadyHere = State.BossCurrentIsland and State.BossCurrentIsland == bi
        if not alreadyHere then
            ForceTP(bi)
            task.wait(1.5)
        end
        
        State.BossCurrentIsland = bi
        local m2 = CheckBoss(State.BossTargetName)
        if m2 then
            local bp2 = RootPos(m2)
            if bp2 and DistTo(bp2) < 500 then
                local goal = Vector3.new(bp2.X, bp2.Y + getgenv().Config.Farm.HeightOffset, bp2.Z)
                TweenToPoint(goal)
                State.BossTPDone = true
                State.BossTPRetries = 0
                return
            end
        end
        
        for _ = 1, 10 do
            local m = CheckBoss(State.BossTargetName)
            if m then
                local mp = RootPos(m)
                if mp and DistTo(mp) < 500 then
                    State.BossTPDone = true
                    State.BossTPRetries = 0
                    return
                end
            end
            task.wait(0.3)
        end
        
        if not m2 then
            State.BossTPRetries = (State.BossTPRetries or 0) + 1
            if State.BossTPRetries < 3 then
                State.BossCurrentIsland = nil
                State.LastBossTP = 0
                return
            end
            State.BossTPRetries = 0
            RecordBossDeath(State.BossTargetName)
            local skippedName = State.BossTargetName
            State.BossTargetName = nil
            State.BossTPDone = false
            ClearTarget()
            task.wait(0.15)
            
            local nextName = PickNextBossName()
            if nextName then
                State.BossTargetName = nextName
                local nextIsland = GetBossIsland(nextName)
                if nextIsland == State.BossCurrentIsland then
                    State.BossTPDone = true
                else
                    State.BossTPDone = false
                    State.LastBossTP = 0
                end
            else
                ExitBossMode(skippedName)
            end
        else
            State.BossTPDone = true
            State.BossTPRetries = 0
        end
        return
    end
    
    local model = CheckBoss(State.BossTargetName)
    if not model then
        local deadName = State.BossTargetName
        State.BossKills = State.BossKills + 1
        State.Kills = State.Kills + 1
        State.KillCount = State.KillCount + 1
        RecordBossDeath(deadName)
        
        local savedHover = State.HoverPos
        if not savedHover then
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                savedHover = Vector3.new(hrp.Position.X, hrp.Position.Y + getgenv().Config.Farm.HeightOffset, hrp.Position.Z)
            end
        end
        
        State.BossTargetName = nil
        State.BossTPDone = false
        ClearTarget()
        task.wait(0.15)
        State.HoverPos = savedHover
        
        local nextName = PickNextBossName()
        if nextName then
            State.BossTargetName = nextName
            local nextIsland = GetBossIsland(nextName)
            if nextIsland == State.BossCurrentIsland then
                State.BossTPDone = true
                State.HoverPos = savedHover
            else
                State.BossTPDone = false
                State.LastBossTP = 0
                State.HoverPos = nil
            end
        else
            ExitBossMode(deadName)
        end
        return
    end
    
    local bossP = RootPos(model)
    if not bossP then
        task.wait(0.3)
        return
    end
    
    if DistTo(bossP) > 500 then
        State.BossTPDone = false
        return
    end
    
    State.CurTarget = model
    TweenTo(model)
    Attack(model)
    
    if getgenv().Config.AutoFarm.AutoEquip and tick() - State.LastEquip > 3 then
        State.LastEquip = tick()
        AutoEquipLogic()
    end
end

--==================================================
-- SUMMON BOSS SYSTEM
--==================================================
local function GetSummonBossDiff(name)
    if name == "GilgameshBoss" then return getgenv().Config.Difficulty.Gilgamesh end
    if name == "BlessedMaidenBoss" then return getgenv().Config.Difficulty.BlessedMaiden end
    if name == "SaberAlterBoss" then return getgenv().Config.Difficulty.SaberAlter end
    if name == "RimuruBoss" then return getgenv().Config.Difficulty.Rimuru end
    if name == "AnosBoss" then return getgenv().Config.Difficulty.Anos end
    if name == "StrongestTodayBoss" then return getgenv().Config.Difficulty.StrongestToday end
    if name == "StrongestHistoryBoss" then return getgenv().Config.Difficulty.StrongestHistory end
    if name == "TrueAizenBoss" then return getgenv().Config.Difficulty.TrueAizen end
    return "Normal"
end

local function FireAutoSpawn(name)
    if not getgenv().Config.Bosses.SummonSelected[name] then return end
    if State.AutoSpawnActive[name] then return end
    
    if not State.SummonBossLockedDiff[name] then
        State.SummonBossLockedDiff[name] = GetSummonBossDiff(name) or "Normal"
    end
    local diff = State.SummonBossLockedDiff[name]
    
    pcall(function()
        if name == "AnosBoss" then
            if autoSpawnAnosRemote then
                autoSpawnAnosRemote:FireServer("Anos", diff)
                State.AutoSpawnActive[name] = true
            end
        elseif name == "RimuruBoss" then
            if autoSpawnRimuruRemote then
                autoSpawnRimuruRemote:FireServer(diff)
                State.AutoSpawnActive[name] = true
            end
        elseif name == "StrongestTodayBoss" then
            if autoSpawnStrongestRemote then
                autoSpawnStrongestRemote:FireServer("StrongestToday", diff)
                State.AutoSpawnActive[name] = true
            end
        elseif name == "StrongestHistoryBoss" then
            if autoSpawnStrongestRemote then
                autoSpawnStrongestRemote:FireServer("StrongestHistory", diff)
                State.AutoSpawnActive[name] = true
            end
        elseif name == "TrueAizenBoss" then
            if autoSpawnTrueAizenRemote then
                autoSpawnTrueAizenRemote:FireServer(diff)
                State.AutoSpawnActive[name] = true
            end
        else
            if autoSpawnBossRemote then
                autoSpawnBossRemote:FireServer(name, diff)
                State.AutoSpawnActive[name] = true
            end
        end
    end)
end

local function DisableAutoSpawn(name)
    if State.AutoSpawnActive[name] then
        local diff = State.SummonBossLockedDiff[name] or GetSummonBossDiff(name) or "Normal"
        pcall(function()
            if name == "AnosBoss" then
                if autoSpawnAnosRemote then autoSpawnAnosRemote:FireServer("Anos", diff) end
            elseif name == "RimuruBoss" then
                if autoSpawnRimuruRemote then autoSpawnRimuruRemote:FireServer(diff) end
            elseif name == "StrongestTodayBoss" then
                if autoSpawnStrongestRemote then autoSpawnStrongestRemote:FireServer("StrongestToday", diff) end
            elseif name == "StrongestHistoryBoss" then
                if autoSpawnStrongestRemote then autoSpawnStrongestRemote:FireServer("StrongestHistory", diff) end
            elseif name == "TrueAizenBoss" then
                if autoSpawnTrueAizenRemote then autoSpawnTrueAizenRemote:FireServer(diff) end
            else
                if autoSpawnBossRemote then autoSpawnBossRemote:FireServer(name, diff) end
            end
        end)
    end
    State.AutoSpawnActive[name] = nil
end

local function DisableAllAutoSpawn()
    for _, b in ipairs(Constants.SummonBosses) do
        if State.AutoSpawnActive[b.Name] then
            DisableAutoSpawn(b.Name)
        end
    end
    State.AutoSpawnActive = {}
end

local function CheckSummonBoss(name)
    local nf = GetNPCFolder()
    if not nf then return nil end
    
    for _, m in ipairs(nf:GetChildren()) do
        if m:IsA("Model") and m.Name == name then
            local hm = GetHum(m)
            if hm and hm.Health > 0 then return m end
        end
    end
    return nil
end

local function HasAnySummonBossEnabled()
    for _, b in ipairs(Constants.SummonBosses) do
        if getgenv().Config.Bosses.SummonSelected[b.Name] then return true end
    end
    return false
end

local function ExitSummonBossMode()
    DisableAllAutoSpawn()
    getgenv().Config.IsSummonBossFight = false
    State.SummonBossFight = false
    State.SummonBossTarget = nil
    State.SummonBossTPDone = false
    State.LastSummonBossTP = 0
    State.SummonBossCommitted = {}
    State.SummonBossCurrentIsland = nil
    State.SummonBossOrder = 0
    State.SummonBossFailCount = {}
    State.SummonBossFireTime = {}
    State.SummonBossLockedDiff = {}
    ClearTarget()
    State.HoverPos = nil
    State.CurIsland = nil
    State.IslandTPd = false
    State.SpawnDone = false
end

local function SummonBossPosValid(model)
    local p = RootPos(model)
    if not p then return false end
    if p.Y < -30 then return false end
    return true
end

local function DoSummonBossTick()
    if not HasAnySummonBossEnabled() then
        if State.SummonBossFight then ExitSummonBossMode() end
        return
    end
    
    if not State.SummonBossFight then
        State.SummonBossFight = true
        getgenv().Config.IsSummonBossFight = true
        ClearTarget()
        State.HoverPos = nil
        State.CurIsland = nil
        State.IslandTPd = false
        State.SummonBossTPDone = false
        State.LastSummonBossTP = 0
        State.SummonBossCurrentIsland = nil
    end
    
    if not State.SummonBossTPDone then
        if tick() - State.LastSummonBossTP < 4 then
            task.wait(0.2)
            return
        end
        
        local targetIsland = Constants.BOSS_ISLAND_PORTAL
        for _, b in ipairs(Constants.SummonBosses) do
            if getgenv().Config.Bosses.SummonSelected[b.Name] then
                targetIsland = b.Island or Constants.BOSS_ISLAND_PORTAL
                break
            end
        end
        
        State.LastSummonBossTP = tick()
        ForceTP(targetIsland)
        task.wait(1)
        
        State.SummonBossCurrentIsland = targetIsland
        
        -- Fire auto spawn for all selected bosses
        for _, b in ipairs(Constants.SummonBosses) do
            if getgenv().Config.Bosses.SummonSelected[b.Name] then
                FireAutoSpawn(b.Name)
                if not State.SummonBossCommitted[b.Name] then
                    State.SummonBossFireTime[b.Name] = tick()
                    State.SummonBossOrder = State.SummonBossOrder + 1
                    State.SummonBossCommitted[b.Name] = State.SummonBossOrder
                end
                task.wait(0.15)
            end
        end
        
        State.SummonBossTPDone = true
        return
    end
    
    -- Find active summon boss
    local activeBoss = nil
    for _, b in ipairs(Constants.SummonBosses) do
        if getgenv().Config.Bosses.SummonSelected[b.Name] then
            local m = CheckSummonBoss(b.Name)
            if m and SummonBossPosValid(m) then
                activeBoss = m
                State.SummonBossTarget = b.Name
                break
            end
        end
    end
    
    if not activeBoss then
        -- Check if any boss died
        for _, b in ipairs(Constants.SummonBosses) do
            if State.SummonBossCommitted[b.Name] and not CheckSummonBoss(b.Name) then
                local fireT = State.SummonBossFireTime[b.Name] or 0
                if tick() - fireT > 10 then
                    -- Boss likely died
                    State.SummonBossCommitted[b.Name] = nil
                    State.BossKills = State.BossKills + 1
                    State.Kills = State.Kills + 1
                    State.KillCount = State.KillCount + 1
                    
                    -- Auto respawn if still selected
                    if getgenv().Config.Bosses.SummonSelected[b.Name] then
                        FireAutoSpawn(b.Name)
                        State.SummonBossFireTime[b.Name] = tick()
                        State.SummonBossOrder = State.SummonBossOrder + 1
                        State.SummonBossCommitted[b.Name] = State.SummonBossOrder
                    end
                end
            end
        end
        task.wait(0.3)
        return
    end
    
    local bossPos = RootPos(activeBoss)
    if not bossPos then
        task.wait(0.15)
        return
    end
    
    local dist = DistTo(bossPos)
    if dist > 1500 then
        State.SummonBossTPDone = false
        ClearTarget()
        return
    end
    
    State.CurTarget = activeBoss
    local goal = Vector3.new(bossPos.X, bossPos.Y + getgenv().Config.Farm.HeightOffset, bossPos.Z)
    
    if dist > 80 then
        TweenToPoint(goal)
    elseif dist > 15 then
        TweenTo(activeBoss)
    end
    
    State.HoverPos = goal
    State.LockTarget = activeBoss
    Attack(activeBoss)
    
    if getgenv().Config.AutoFarm.AutoEquip and tick() - State.LastEquip > 3 then
        State.LastEquip = tick()
        AutoEquipLogic()
    end
end

--==================================================
-- AUTO MERCHANT SYSTEM
--==================================================
local function BuyMerchantItems()
    if not getgenv().Config.Merchant.Enabled then return end
    if tick() - State.LastMerchant < 1800 then return end
    State.LastMerchant = tick()
    
    local remote = Remotes:FindFirstChild("MerchantRemotes") and Remotes.MerchantRemotes:FindFirstChild("PurchaseMerchantItem")
    if not remote then return end
    
    for _, item in ipairs(Constants.MerchantItems) do
        if getgenv().Config.Merchant.Selected[item] then
            for _ = 1, 15 do
                local success = pcall(function() return remote:InvokeServer(item, 1) end)
                if not success then break end
                if getgenv().Config.Merchant.Notify then
                    print("Purchased: " .. item)
                end
                task.wait(0.05)
            end
        end
    end
end

--==================================================
-- AUTO CHEST SYSTEM
--==================================================
local function OpenAllChests()
    if not getgenv().Config.Farm.AutoChest then return end
    if tick() - State.LastChest < 5 then return end
    State.LastChest = tick()
    
    local useItemRemote = Remotes:FindFirstChild("UseItem")
    if not useItemRemote then return end
    
    for _, name in ipairs(Constants.ChestNames) do
        pcall(function() useItemRemote:FireServer("Use", name, 999, false) end)
        task.wait(0.3)
    end
end

--==================================================
-- AUTO STATS SYSTEM
--==================================================
local function AutoStatsUpgrade()
    local points = Player.Data.StatPoints.Value or 0
    if points <= 0 then return end
    
    local level = GetLevel()
    if level < 1000 then
        local meleePoints = math.floor(points * 0.7)
        local defensePoints = points - meleePoints
        for i = 1, meleePoints do
            statRemote:FireServer("Melee", 1)
            task.wait(0.05)
        end
        for i = 1, defensePoints do
            statRemote:FireServer("Defense", 1)
            task.wait(0.05)
        end
    else
        local swordPoints = math.floor(points * 0.5)
        local defensePoints = math.floor(points * 0.3)
        local powerPoints = points - swordPoints - defensePoints
        for i = 1, swordPoints do
            statRemote:FireServer("Sword", 1)
            task.wait(0.05)
        end
        for i = 1, defensePoints do
            statRemote:FireServer("Defense", 1)
            task.wait(0.05)
        end
        for i = 1, powerPoints do
            statRemote:FireServer("Power", 1)
            task.wait(0.05)
        end
    end
end

--==================================================
-- AUTO HAKI SYSTEM
--==================================================
local function ToggleHaki()
    if getgenv().Config.AutoFarm.AutoHaki then
        pcall(function() hakiRemote:FireServer("Toggle") end)
    end
    if getgenv().Config.AutoFarm.AutoObsHaki then
        pcall(function() obsHakiRemote:FireServer("Toggle") end)
    end
end

--==================================================
-- MAIN FARM LOOP
--==================================================
local function DoFarmTick()
    local tgtIsland = GetFarmIsland()
    if not tgtIsland then
        task.wait(1)
        return
    end
    
    if not State.CurIsland or State.CurIsland.Portal ~= tgtIsland.Portal then
        StopTween()
        State.CurIsland = tgtIsland
        State.IslandTPd = false
        State.SpawnDone = false
        State.FarmOrigin = nil
        State.QState = "NONE"
        ClearTarget()
        AbandonAllQuests()
        print("Teleporting to " .. PortalDisplayName(tgtIsland.Portal))
    end
    
    if not State.IslandTPd then
        if ForceTP(State.CurIsland.Portal) then
            task.wait(0.5)
            State.IslandTPd = true
            State.FarmOrigin = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position or nil
            State.LastEnemy = tick()
        else
            task.wait(1)
        end
        return
    end
    
    -- Auto quest
    if getgenv().Config.Farm.AutoQuest then
        if State.QState == "NONE" then
            if tick() - State.LastQuestAccept > 5 then
                QuestRepeatFire(State.CurIsland)
            end
        end
        QuestCompletionScan()
    end
    
    local enemies = FindEnemies(State.CurIsland, getgenv().Config.AutoFarm.SelectedMob)
    
    if #enemies > 0 then
        State.LastEnemy = tick()
        if State.CurTarget then
            local hm = GetHum(State.CurTarget)
            if not hm or hm.Health <= 0 or not State.CurTarget.Parent then
                if hm and hm.Health <= 0 then
                    State.KillCount = State.KillCount + 1
                end
                State.CurTarget = nil
                State.LockTarget = nil
            end
        end
        if not State.CurTarget then
            State.CurTarget = NearestFrom(enemies)
        end
        if State.CurTarget then
            TweenTo(State.CurTarget)
            Attack(State.CurTarget)
            
            if getgenv().Config.AutoFarm.AutoEquip and tick() - State.LastEquip > 2 then
                State.LastEquip = tick()
                AutoEquipLogic()
            end
        end
    else
        State.CurTarget = nil
        State.LockTarget = nil
        if tick() - State.LastEnemy > 20 then
            State.IslandTPd = false
            State.SpawnDone = false
            State.FarmOrigin = nil
            State.LastEnemy = 0
        end
        task.wait(0.1)
    end
end

--==================================================
-- CREATE WINDOW WITH NOVALIB
--==================================================
local Window = NovaLib:Create({
    Name = "Sailor Piece Ultimate",
    Theme = NovaLib.Themes.Midnight
})

-- Create Tabs
local FarmTab = Window:Tab({ Name = "Auto Farm" })
local BossTab = Window:Tab({ Name = "Bosses" })
local SkillTab = Window:Tab({ Name = "Auto Skills" })
local QuestTab = Window:Tab({ Name = "Quests" })
local MerchantTab = Window:Tab({ Name = "Merchant" })
local SettingsTab = Window:Tab({ Name = "Settings" })

--==================================================
-- FARM TAB
--==================================================

-- Mob Selection Section
FarmTab:Section("Mob Settings")

local selectedMob = "Thief"
FarmTab:Dropdown({
    Name = "Select Mob",
    Items = Constants.MobDisplayList,
    Callback = function(selected)
        selectedMob = Constants.MobDisplayToInternal[selected] or selected
        getgenv().Config.AutoFarm.SelectedMob = selectedMob
        print("Selected mob: " .. selectedMob)
    end
})

local autoFarmToggle = FarmTab:Toggle({
    Name = "Enable Auto Farm",
    Default = false,
    Callback = function(state)
        getgenv().Config.AutoFarm.Enabled = state
        getgenv().Config.IsFarm = state
        if state then
            FullReset()
            print("Auto Farm Enabled")
        else
            print("Auto Farm Disabled")
        end
    end
})

-- Farm Settings Section
FarmTab:Section("Farm Settings")

FarmTab:Dropdown({
    Name = "Farm Style",
    Items = { "Plank", "Behind" },
    Callback = function(selected)
        getgenv().Config.Farm.FarmMode = selected
        print("Farm mode: " .. selected)
    end
})

FarmTab:Slider({
    Name = "Height Offset (Plank Mode)",
    Min = 5,
    Max = 40,
    Default = 10,
    Callback = function(value)
        getgenv().Config.Farm.HeightOffset = value
    end
})

FarmTab:Slider({
    Name = "Offset Distance (Behind Mode)",
    Min = 2,
    Max = 15,
    Default = 5,
    Callback = function(value)
        getgenv().Config.Farm.OffsetDist = value
    end
})

FarmTab:Slider({
    Name = "Movement Speed",
    Min = 20,
    Max = 250,
    Default = 100,
    Callback = function(value)
        getgenv().Config.Farm.TweenSpeed = value
    end
})

FarmTab:Dropdown({
    Name = "Travel Mode",
    Items = { "Tween", "Teleport" },
    Callback = function(selected)
        getgenv().Config.Farm.MoveMode = selected
        ClearTarget()
    end
})

FarmTab:Dropdown({
    Name = "Farm Island",
    Items = GetIslandNames(),
    Callback = function(selected)
        getgenv().Config.Farm.SelectedIsland = DisplayToPortal(selected)
        ClearTarget()
        State.CurIsland = nil
        State.IslandTPd = false
        State.SpawnDone = false
        State.FarmOrigin = nil
        AbandonAllQuests()
        print("Island changed to: " .. selected)
    end
})

-- Weapon Settings Section
FarmTab:Section("Weapon Settings")

local function updateWeaponList()
    local weapons = GetWeaponList()
    if weaponDropdown and weaponDropdown.Refresh then
        weaponDropdown:Refresh(weapons)
    end
    return weapons
end

local weaponDropdown = FarmTab:Dropdown({
    Name = "Select Weapon",
    Items = GetWeaponList(),
    Callback = function(weapon)
        getgenv().Config.AutoFarm.SelectedWeapon = weapon
        print("Selected weapon: " .. weapon)
        if getgenv().Config.AutoFarm.AutoEquip then
            EquipWeapon(weapon)
        end
    end
})

FarmTab:Toggle({
    Name = "Auto Equip Weapon",
    Default = true,
    Callback = function(state)
        getgenv().Config.AutoFarm.AutoEquip = state
        if state and getgenv().Config.AutoFarm.SelectedWeapon ~= "None" then
            EquipWeapon(getgenv().Config.AutoFarm.SelectedWeapon)
        end
    end
})

FarmTab:Button({
    Name = "Refresh Weapon List",
    Callback = function()
        local weapons = updateWeaponList()
        print("Weapon list refreshed: " .. #weapons .. " weapons found")
    end
})

FarmTab:Button({
    Name = "Equip Selected Weapon Now",
    Callback = function()
        if getgenv().Config.AutoFarm.SelectedWeapon ~= "None" then
            if EquipWeapon(getgenv().Config.AutoFarm.SelectedWeapon) then
                print("Equipped: " .. getgenv().Config.AutoFarm.SelectedWeapon)
            else
                print("Failed to equip: " .. getgenv().Config.AutoFarm.SelectedWeapon)
            end
        else
            print("Select a weapon first!")
        end
    end
})

-- Additional Settings Section
FarmTab:Section("Additional Settings")

FarmTab:Toggle({
    Name = "Auto Hit",
    Default = true,
    Callback = function(state)
        getgenv().Config.AutoFarm.AutoHit = state
        if not state then
            print("Auto Hit disabled - skills will not activate")
        end
    end
})

FarmTab:Toggle({
    Name = "Auto Stats",
    Default = true,
    Callback = function(state)
        getgenv().Config.AutoFarm.AutoStats = state
    end
})

FarmTab:Toggle({
    Name = "Auto Quest",
    Default = true,
    Callback = function(state)
        getgenv().Config.Farm.AutoQuest = state
    end
})

FarmTab:Toggle({
    Name = "Set Spawn Crystal",
    Default = false,
    Callback = function(state)
        getgenv().Config.Farm.AutoSpawn = state
        State.SpawnDone = false
    end
})

FarmTab:Toggle({
    Name = "Auto Open Chests",
    Default = false,
    Callback = function(state)
        getgenv().Config.Farm.AutoChest = state
    end
})

FarmTab:Toggle({
    Name = "Auto Armament Haki",
    Default = false,
    Callback = function(state)
        getgenv().Config.AutoFarm.AutoHaki = state
    end
})

FarmTab:Toggle({
    Name = "Auto Observation Haki",
    Default = false,
    Callback = function(state)
        getgenv().Config.AutoFarm.AutoObsHaki = state
    end
})

--==================================================
-- BOSS TAB
--==================================================
BossTab:Section("World Bosses")

BossTab:Toggle({
    Name = "Enable World Boss Killing",
    Default = false,
    Callback = function(state)
        getgenv().Config.Bosses.Enabled = state
        getgenv().Config.IsBossFight = state
        if state then
            print("World Boss Hunting Enabled")
        else
            print("World Boss Hunting Disabled")
        end
    end
})

for _, boss in ipairs(Constants.Bosses) do
    BossTab:Toggle({
        Name = boss.Display .. " (" .. boss.Island .. ")",
        Default = false,
        Callback = function(state)
            if state then
                getgenv().Config.Bosses.Selected[boss.Name] = true
            else
                getgenv().Config.Bosses.Selected[boss.Name] = nil
            end
        end
    })
end

BossTab:Section("Summon Bosses")

for _, boss in ipairs(Constants.SummonBosses) do
    BossTab:Toggle({
        Name = boss.Display .. (boss.Island and " (" .. boss.Island .. ")" or ""),
        Default = false,
        Callback = function(state)
            if state then
                getgenv().Config.Bosses.SummonSelected[boss.Name] = true
                FireAutoSpawn(boss.Name)
            else
                getgenv().Config.Bosses.SummonSelected[boss.Name] = nil
                DisableAutoSpawn(boss.Name)
                State.SummonBossCommitted[boss.Name] = nil
            end
        end
    })
    
    if boss.Difficulties then
        BossTab:Dropdown({
            Name = boss.Display .. " Difficulty",
            Default = "Normal",
            Items = boss.Difficulties,
            Callback = function(selected)
                if boss.Name == "GilgameshBoss" then
                    getgenv().Config.Difficulty.Gilgamesh = selected
                elseif boss.Name == "BlessedMaidenBoss" then
                    getgenv().Config.Difficulty.BlessedMaiden = selected
                elseif boss.Name == "SaberAlterBoss" then
                    getgenv().Config.Difficulty.SaberAlter = selected
                elseif boss.Name == "RimuruBoss" then
                    getgenv().Config.Difficulty.Rimuru = selected
                elseif boss.Name == "AnosBoss" then
                    getgenv().Config.Difficulty.Anos = selected
                elseif boss.Name == "StrongestTodayBoss" then
                    getgenv().Config.Difficulty.StrongestToday = selected
                elseif boss.Name == "StrongestHistoryBoss" then
                    getgenv().Config.Difficulty.StrongestHistory = selected
                elseif boss.Name == "TrueAizenBoss" then
                    getgenv().Config.Difficulty.TrueAizen = selected
                end
            end
        })
    end
end

--==================================================
-- SKILL TAB
--==================================================
SkillTab:Section("Auto Skills Settings")

SkillTab:Toggle({
    Name = "USE SKILL Z",
    Default = false,
    Callback = function(state)
        getgenv().Config.AutoSkills.Z = state
        print(state and "Skill Z ON" or "Skill Z OFF")
    end
})

SkillTab:Toggle({
    Name = "USE SKILL X",
    Default = false,
    Callback = function(state)
        getgenv().Config.AutoSkills.X = state
        print(state and "Skill X ON" or "Skill X OFF")
    end
})

SkillTab:Toggle({
    Name = "USE SKILL C",
    Default = false,
    Callback = function(state)
        getgenv().Config.AutoSkills.C = state
        print(state and "Skill C ON" or "Skill C OFF")
    end
})

SkillTab:Toggle({
    Name = "USE SKILL V",
    Default = false,
    Callback = function(state)
        getgenv().Config.AutoSkills.V = state
        print(state and "Skill V ON" or "Skill V OFF")
    end
})

SkillTab:Toggle({
    Name = "USE SKILL F (NUKE)",
    Default = false,
    Callback = function(state)
        getgenv().Config.AutoSkills.F = state
        print(state and "Skill F ON" or "Skill F OFF")
    end
})

SkillTab:Slider({
    Name = "Skill Cooldown",
    Min = 0.05,
    Max = 2.0,
    Default = 0.3,
    Callback = function(value)
        getgenv().Config.AutoFarm.SkillCooldown = value
        print("Skill cooldown set to: " .. value .. "s")
    end
})

SkillTab:Paragraph({
    Title = "⚡ Auto Skills Info",
    Content = "Skills will automatically activate when any farming mode is active\n\n" ..
               "Skill Check Interval: 0.05 seconds\n" ..
               "Skill Cooldown: " .. getgenv().Config.AutoFarm.SkillCooldown .. "s\n\n" ..
               "Skill Order: Z → X → C → V → F\n" ..
               "Skills only activate when AUTO HIT is ON"
})

--==================================================
-- QUEST TAB
--==================================================
QuestTab:Section("Unlock Quests")

QuestTab:Toggle({
    Name = "Dungeon Pieces Quest",
    Default = false,
    Callback = function(state)
        getgenv().Config.Quests.DungeonEnabled = state
        if state then
            if getgenv().Config.Quests.HogyokuEnabled then
                getgenv().Config.Quests.HogyokuEnabled = false
            end
            State.DungeonStep = 0
            State.DungeonCollected = {}
            print("Dungeon Quest Enabled")
        else
            print("Dungeon Quest Disabled")
        end
    end
})

QuestTab:Paragraph({
    Title = "Dungeon Info",
    Content = "Collect 6 puzzle pieces:\nStarter → Jungle → Desert → Snow → Shibuya → Hueco Mundo"
})

QuestTab:Toggle({
    Name = "Hogyoku Fragments Quest",
    Default = false,
    Callback = function(state)
        getgenv().Config.Quests.HogyokuEnabled = state
        if state then
            if getgenv().Config.Quests.DungeonEnabled then
                getgenv().Config.Quests.DungeonEnabled = false
            end
            State.HogyokuStep = 0
            State.HogyokuCollected = {}
            print("Hogyoku Quest Enabled")
        else
            print("Hogyoku Quest Disabled")
        end
    end
})

QuestTab:Paragraph({
    Title = "Hogyoku Info",
    Content = "Collect 6 fragments:\nSnow → Shibuya → Hueco Mundo → Shinjuku → Slime → Judgement"
})

--==================================================
-- MERCHANT TAB
--==================================================
MerchantTab:Section("Auto Merchant")

MerchantTab:Toggle({
    Name = "Enable Auto Merchant",
    Default = false,
    Callback = function(state)
        getgenv().Config.Merchant.Enabled = state
    end
})

MerchantTab:Toggle({
    Name = "Merchant Notifications",
    Default = true,
    Callback = function(state)
        getgenv().Config.Merchant.Notify = state
    end
})

MerchantTab:Section("Items to Buy")

for _, item in ipairs(Constants.MerchantItems) do
    MerchantTab:Toggle({
        Name = item,
        Default = false,
        Callback = function(state)
            if state then
                getgenv().Config.Merchant.Selected[item] = true
            else
                getgenv().Config.Merchant.Selected[item] = nil
            end
        end
    })
end

--==================================================
-- SETTINGS TAB
--==================================================
SettingsTab:Section("General Settings")

SettingsTab:Toggle({
    Name = "Anti AFK",
    Default = true,
    Callback = function(state)
        getgenv().Config.Misc.AntiAFK = state
    end
})

SettingsTab:Toggle({
    Name = "FPS Boost (Black Screen)",
    Default = false,
    Callback = function(state)
        getgenv().Config.Misc.FpsBoost = state
        if state then
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

SettingsTab:Toggle({
    Name = "White Screen Mode",
    Default = false,
    Callback = function(state)
        getgenv().Config.Misc.WhiteScreen = state
        RunService:Set3dRenderingEnabled(not state)
    end
})

SettingsTab:Toggle({
    Name = "Auto Rejoin",
    Default = false,
    Callback = function(state)
        getgenv().Config.Misc.AutoRejoin = state
    end
})

SettingsTab:Toggle({
    Name = "Timed Rejoin",
    Default = false,
    Callback = function(state)
        getgenv().Config.Misc.TimedRejoin = state
    end
})

SettingsTab:Slider({
    Name = "Rejoin Delay (Minutes)",
    Min = 1,
    Max = 120,
    Default = 10,
    Callback = function(value)
        getgenv().Config.Misc.RejoinDelay = value
    end
})

-- Teleport Section
SettingsTab:Section("Teleport to Island")

for _, name in ipairs(Constants.TpIslands) do
    SettingsTab:Button({
        Name = PortalDisplayName(name),
        Callback = function()
            if getgenv().Config.AutoFarm.Enabled then
                print("Disable Auto Farm first!")
                return
            end
            ForceTP(name)
            print("Teleporting to " .. PortalDisplayName(name))
        end
    })
end

-- Destroy Button
SettingsTab:Section("Danger Zone")

SettingsTab:Button({
    Name = "Destroy GUI",
    Callback = function()
        State.Running = false
        task.delay(0.1, function()
            NovaLib:Destroy()
            _G.SP_Loaded = false
        end)
    end
})

--==================================================
-- BACKGROUND LOOPS
--==================================================

-- Anti AFK Loop
task.spawn(function()
    while State.Running do
        task.wait(60)
        if getgenv().Config.Misc.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- Auto Rejoin Handler
task.spawn(function()
    local GuiService = game:GetService("GuiService")
    local lastError = ""
    GuiService.ErrorMessageChanged:Connect(function()
        if not getgenv().Config.Misc.AutoRejoin then return end
        local err = GuiService:GetErrorMessage()
        if err ~= lastError and err ~= "" then
            lastError = err
            task.wait(5)
            pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
        end
    end)
end)

-- Timed Rejoin
task.spawn(function()
    local elapsed = 0
    while State.Running do
        task.wait(1)
        if getgenv().Config.Misc.TimedRejoin then
            elapsed = elapsed + 1
            if elapsed >= getgenv().Config.Misc.RejoinDelay * 60 then
                elapsed = 0
                task.wait(2)
                pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
            end
        else
            elapsed = 0
        end
    end
end)

-- Auto Stats Loop
task.spawn(function()
    while State.Running do
        task.wait(5)
        if getgenv().Config.AutoFarm.AutoStats then
            pcall(AutoStatsUpgrade)
        end
    end
end)

-- Auto Haki Loop
task.spawn(function()
    while State.Running do
        task.wait(3)
        pcall(ToggleHaki)
    end
end)

-- Auto Merchant Loop
task.spawn(function()
    while State.Running do
        task.wait(30)
        pcall(BuyMerchantItems)
    end
end)

-- Auto Chest Loop
task.spawn(function()
    while State.Running do
        task.wait(2)
        pcall(OpenAllChests)
    end
end)

--==================================================
-- MAIN LOOP
--==================================================
task.spawn(function()
    while State.Running do
        task.wait(0.1)
        
        -- Priority: Quests first
        if getgenv().Config.Quests.DungeonEnabled then
            pcall(DoDungeonQuestTick)
        elseif getgenv().Config.Quests.HogyokuEnabled then
            pcall(DoHogyokuQuestTick)
        elseif HasAnySummonBossEnabled() then
            pcall(DoSummonBossTick)
        elseif getgenv().Config.Bosses.Enabled then
            pcall(DoBossTick)
        elseif getgenv().Config.AutoFarm.Enabled then
            if IsAlive() then
                pcall(DoFarmTick)
            else
                task.wait(0.5)
            end
        end
    end
end)

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    ClearTarget()
    if getgenv().Config.AutoFarm.AutoEquip and getgenv().Config.AutoFarm.SelectedWeapon ~= "None" then
        task.spawn(function()
            task.wait(1.5)
            EquipWeapon(getgenv().Config.AutoFarm.SelectedWeapon)
        end)
    end
end)

-- Update weapon list when backpack changes
Player.Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        task.wait(0.1)
        updateWeaponList()
        if getgenv().Config.AutoFarm.AutoEquip and getgenv().Config.AutoFarm.SelectedWeapon == child.Name then
            local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(child)
            end
        end
    end
end)

--==================================================
-- NOCLIP AND MOVEMENT SYSTEM
--==================================================
RunService.RenderStepped:Connect(function()
    local inBossFight = State.SummonBossFight or State.BossFight
    local anyActive = getgenv().Config.AutoFarm.Enabled or inBossFight or 
                       getgenv().Config.Quests.DungeonEnabled or getgenv().Config.Quests.HogyokuEnabled or
                       HasAnySummonBossEnabled()
    
    if not anyActive then
        if State.NoclipActive then
            State.NoclipActive = false
            pcall(function()
                local c = Player.Character
                if not c then return end
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
                local hm = c:FindFirstChildOfClass("Humanoid")
                if hm then hm.PlatformStand = false end
            end)
        end
        return
    end
    
    State.NoclipActive = true
    local c = Player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Noclip
    if tick() - State.LastCanCollide > 0.2 then
        State.LastCanCollide = tick()
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    
    -- Ground detection
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {c}
    local hit = Workspace:Raycast(hrp.Position + Vector3.new(0, 3, 0), Vector3.new(0, -50, 0), rp)
    if hit and hrp.Position.Y < hit.Position.Y + 1 then
        hrp.CFrame = CFrame.new(hrp.Position.X, hit.Position.Y + 3, hrp.Position.Z) * (hrp.CFrame - hrp.CFrame.Position)
    end
    
    -- Plank mode platform stand
    if getgenv().Config.Farm.FarmMode == "Plank" then
        local hm = c:FindFirstChildOfClass("Humanoid")
        if hm then hm.PlatformStand = true end
    end
    
    if State.TweenOn then return end
    
    if State.LockTarget then
        local hm = GetHum(State.LockTarget)
        if not hm or hm.Health <= 0 or not State.LockTarget.Parent then
            State.LockTarget = nil
        elseif not State.BossFight and State.CurIsland then
            if not MatchEnemy(State.LockTarget.Name, State.CurIsland) and not IsBoss(State.LockTarget.Name) then
                State.LockTarget = nil
            end
        end
        
        if State.LockTarget then
            local tp = RootPos(State.LockTarget)
            if tp then
                if tp.Y < -30 then State.LockTarget = nil end
                if State.LockTarget and hrp and (tp - hrp.Position).Magnitude > 600 then State.LockTarget = nil end
            end
        end
    end
    
    if State.LockTarget then
        local goal, look = GetGoalForEnemy(State.LockTarget)
        if goal then
            if goal.Y < -30 then
                State.LockTarget = nil
            else
                if getgenv().Config.Farm.FarmMode == "Plank" and State.HoverPos and not inBossFight then
                    goal = Vector3.new(goal.X, math.max(goal.Y, State.HoverPos.Y), goal.Z)
                end
                hrp.CFrame = CFrame.new(goal, look or goal)
                State.HoverPos = goal
            end
        end
    elseif State.HoverPos then
        hrp.CFrame = CFrame.new(State.HoverPos, State.HoverPos + Constants.LOOK_DOWN)
    end
    
    -- Stabilize in plank mode
    if getgenv().Config.Farm.FarmMode == "Plank" then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end)

--==================================================
-- INITIALIZE
--==================================================
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - ULTIMATE AUTO FARM v4.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ COMPLETE FEATURES:")
print("   • Auto Farm (Plank/Behind modes)")
print("   • Auto Skills (Z, X, C, V, F)")
print("   • World Boss Killing")
print("   • Summon Boss System with Difficulties")
print("   • Dungeon Pieces Quest (6 islands)")
print("   • Hogyoku Fragments Quest (6 islands)")
print("   • Auto Merchant & Auto Chest")
print("   • Auto Stats & Auto Haki")
print("   • Anti AFK & Auto Rejoin")
print("   • FPS Boost & White Screen Mode")
print("═══════════════════════════════════════════════════════")
print("⚠️ ALL FEATURES ARE OFF BY DEFAULT")
print("⚠️ Enable them from the UI")
print("⚠️ Skills will only activate when AUTO HIT is ON")
print("═══════════════════════════════════════════════════════")