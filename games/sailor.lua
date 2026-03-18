-- ==================== SAILOR PIECE - CATRAZ EDITION ====================
-- Adapted from PIMPLE v7.5 untuk UI Catraz Hub
-- Version: 1.0

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
-- REMOTE PATHS
--==================================================
local R = {
    TP = {"Remotes", "TeleportToPortal"},
    QuestAccept = {"RemoteEvents", "QuestAccept"},
    QuestAbandon = {"RemoteEvents", "QuestAbandon"},
    UseItem = {"Remotes", "UseItem"},
    Hit = {"CombatSystem", "Remotes", "RequestHit"},
    Ability = {"AbilitySystem", "Remotes", "RequestAbility"},
    Merchant = {"Remotes", "MerchantRemotes", "PurchaseMerchantItem"},
    Settings = {"RemoteEvents", "SettingsToggle"},
    QuestRepeat = {"RemoteEvents", "QuestRepeat"},
    SummonBoss = {"Remotes", "RequestSummonBoss"},
    AnosBoss = {"Remotes", "RequestSpawnAnosBoss"},
    StrongestBoss = {"Remotes", "RequestSpawnStrongestBoss"},
    AutoSpawnBoss = {"Remotes", "RequestAutoSpawn"},
    AutoSpawnAnos = {"Remotes", "RequestAutoSpawnAnos"},
    AutoSpawnStrongest = {"Remotes", "RequestAutoSpawnStrongest"},
    SlimeCraft = {"Remotes", "RequestSlimeCraft"},
    RimuruSpawn = {"RemoteEvents", "RequestSpawnRimuru"},
    AutoSpawnRimuru = {"RemoteEvents", "RequestAutoSpawnRimuru"},
    DungeonVote = {"Remotes", "DungeonWaveVote"},
    DungeonPortal = {"Remotes", "RequestDungeonPortal"},
}

--==================================================
-- CONFIG
--==================================================
local F = {
    AutoFarmLevel = false,
    AutoDungeon = false,
    AutoBossRush = false,
    HeightOffset = 15,
    TweenSpeed = 100,
    RuneHeight = 10,
    RuneSpeed = 50,
    RuneMove = "Teleport",
    RuneDiff = "Normal",
    CidHeight = 10,
    CidSpeed = 50,
    CidMove = "Teleport",
    CidDiff = "Normal",
    DoubleHeight = 10,
    DoubleSpeed = 50,
    DoubleMove = "Teleport",
    DoubleDiff = "Normal",
    BossRushHeightOffset = 10,
    BossRushTweenSpeed = 50,
    AntiAFK = true,
    AutoEquip = true,
    AutoQuest = true,
    AutoSpawn = false,
    SelectedIsland = "Auto",
    SkillZ = false,
    SkillX = false,
    SkillC = false,
    SkillV = false,
    SkillF = false,
    SkillCooldown = 1.0,
    BossEnabled = false,
    SummonBossEnabled = false,
    GilgameshDiff = "Normal",
    BlessedMaidenDiff = "Normal",
    SaberAlterDiff = "Normal",
    RimuruDiff = "Normal",
    AnosDiff = "Normal",
    StrongestTodayDiff = "Normal",
    StrongestHistoryDiff = "Normal",
    AutoChest = false,
    FarmMode = "Plank",
    BossRushFarmMode = "Plank",
    BossRushMoveMode = "Teleport",
    MoveMode = "Tween",
    OffsetDist = 5,
    AutoMerchant = false,
    MerchNotify = true,
    DungeonQuest = false,
    HogyokuQuest = false,
    DungeonType = "Rune",
}

--==================================================
-- CONSTANTS & DATA
--==================================================
local S = {
    ICON = "rbxthumb://type=AvatarHeadShot&id=583572860&w=420&h=420",
    DISCORD = "https://discord.gg/B3PurfCy",
    NPC_FOLDER = "NPCs",
    BOSS_ISLAND_PORTAL = "Boss",
    ANOS_ISLAND = "Academy",
    LOOK_DOWN = Vector3.new(0, -1, 0),
    FARM_MAX_DIST_FROM_PLAYER = 900,
    FARM_MAX_DIST_FROM_ORIGIN = 1200,
    GENERIC_HOSTILE_MAX_DIST = 900,
}

S.Islands = {
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
}

S.TpIslands = {"Starter", "Jungle", "Desert", "Snow", "Sailor", "Shibuya", "HuecoMundo", "Boss", "Dungeon", "Shinjuku", "Slime", "Academy", "Judgement", "SoulSociety"}

S.Bosses = {
    {Name = "AizenBoss", Display = "Aizen", Island = "HuecoMundo"},
    {Name = "AlucardBoss", Display = "Alucard", Island = "Sailor"},
    {Name = "GojoBoss", Display = "Gojo", Island = "Shibuya", RenderNear = "YujiBoss"},
    {Name = "JinwooBoss", Display = "Jinwoo", Island = "Sailor"},
    {Name = "SukunaBoss", Display = "Sukuna", Island = "Shibuya"},
    {Name = "YamatoBoss", Display = "Yamato", Island = "Judgement"},
    {Name = "YujiBoss", Display = "Yuji", Island = "Shibuya"},
}

S.SummonBosses = {
    {Name = "IchigoBoss", Display = "Ichigo"},
    {Name = "QinShiBoss", Display = "Qin Shi"},
    {Name = "SaberBoss", Display = "Saber"},
    {Name = "AnosBoss", Display = "Anos", Island = "Academy", Difficulties = {"Normal", "Medium", "Hard", "Extreme"}},
    {Name = "BlessedMaidenBoss", Display = "Blessed Maiden", Difficulties = {"Normal", "Medium", "Hard", "Extreme"}},
    {Name = "GilgameshBoss", Display = "Gilgamesh", Difficulties = {"Normal", "Medium", "Hard", "Extreme"}},
    {Name = "RimuruBoss", Display = "Rimuru", Island = "Slime", Difficulties = {"Normal", "Medium", "Hard", "Extreme"}},
    {Name = "SaberAlterBoss", Display = "Saber Alter", Difficulties = {"Normal", "Medium", "Hard", "Extreme"}},
    {Name = "StrongestHistoryBoss", Display = "Strongest in History", Island = "Shinjuku", Difficulties = {"Normal", "Medium", "Hard", "Extreme"}},
    {Name = "StrongestTodayBoss", Display = "Strongest Today", Island = "Shinjuku", Difficulties = {"Normal", "Medium", "Hard", "Extreme"}},
}

S.DungeonEnemyNames = {"DungeonNPC1", "DungeonNPC2", "DungeonNPC3", "DungeonNPC4", "DungeonNPC5"}
S.DungeonEnemySet = {}
for _, n in ipairs(S.DungeonEnemyNames) do S.DungeonEnemySet[(n or ""):lower()] = true end

S.DungeonTypes = {"Double", "Rune", "Cid"}
S.DungeonDifficulties = {"Easy", "Normal", "Hard", "Extreme"}
S.DungeonPortalNames = {Double = "DoubleDungeon", Rune = "RuneDungeon", Cid = "CidDungeon"}

S.IgnoreList = {"groupreward", "katana", "buyer", "madoka", "training", "dummy", "merchant", "shop", "vendor", "shadow questline", "shadowmonarch", "obshakilsinhead", "buff", "questnpc"}
S.ChestNames = {"Common Chest", "Rare Chest", "Epic Chest", "Legendary Chest", "Mythical Chest"}
S.MerchantItems = {"Boss Key", "Clan Reroll", "Dungeon Key", "Haki Color Reroll", "Race Reroll", "Rush Key", "Trait Reroll"}

S.SkillKeys = {"SkillZ", "SkillX", "SkillC", "SkillV", "SkillF"}

--==================================================
-- STATE VARIABLES
--==================================================
local state = {
    Kills = 0,
    BossKills = 0,
    Running = true,
    CurIsland = nil,
    CurTarget = nil,
    LockTarget = nil,
    HoverPos = nil,
    TweenOn = false,
    TweenTarget = nil,
    ATween = nil,
    ATweenConn = nil,
    HumCache = setmetatable({}, {__mode = "k"}),
    CharHum = nil,
    LastSkill = 0,
    LastEquip = 0,
    LastTP = 0,
    LastEnemy = 0,
    LastQuestAccept = 0,
    LastMerchant = 0,
    TPCount = 0,
    TPReset = tick(),
    ConfLevel = 0,
    LastLevelScanTick = 0,
    IslandTPd = false,
    SpawnDone = false,
    FarmOrigin = nil,
    FarmGenericMode = false,
    QState = "NONE",
    BossFight = false,
    BossTargetName = nil,
    BossTPDone = false,
    LastBossTP = 0,
    BossCurrentIsland = nil,
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
    BF = {},
    BSF = {},
    FC = {},
    FM = {},
    SkillToggles = {},
    RayParams = RaycastParams.new(),
    NoclipParts = {},
    NoclipActive = false,
    LastCanCollide = 0,
    LastSmoothMove = 0,
    SmoothY = nil,
    CachedAbilityRemote = nil,
    CachedUseItem = nil,
    CachedQuestAbandon = nil,
}

-- Initialize boss flags
for _, b in ipairs(S.Bosses) do state.BF[b.Name] = false end
for _, b in ipairs(S.SummonBosses) do state.BSF[b.Name] = false end
for _, item in ipairs(S.MerchantItems) do state.FM[item] = false end
for _, chest in ipairs(S.ChestNames) do state.FC[chest] = true end

state.RayParams.FilterType = Enum.RaycastFilterType.Exclude

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
    Subtext = "Catraz Edition v1.0",
    Version = "v1.0",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece",
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
    Icon = "sword",
    Glass = true,
    Outline = true
})

local GameModesTab = Window:MakeTab({
    Name = "Gamemodes",
    Icon = "shield",
    Glass = true,
    Outline = true
})

local SkillsTab = Window:MakeTab({
    Name = "Skills",
    Icon = "flame",
    Glass = true,
    Outline = true
})

local QuestsTab = Window:MakeTab({
    Name = "Quests",
    Icon = "bookmark",
    Glass = true,
    Outline = true
})

local MerchantTab = Window:MakeTab({
    Name = "Merchant",
    Icon = "shopping-cart",
    Glass = true,
    Outline = true
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "map-pin",
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
-- UTILITY FUNCTIONS
--==================================================

local function GetHum(e)
    if not e then return nil end
    local cached = state.HumCache[e]
    if cached then
        local ok, alive = pcall(function() return cached.Parent ~= nil end)
        if ok and alive then return cached end
        state.HumCache[e] = nil
    end
    local h = e:FindFirstChildOfClass("Humanoid")
    if not h then
        for _, d in ipairs(e:GetDescendants()) do
            if d:IsA("Humanoid") then h = d break end
        end
    end
    if h then state.HumCache[e] = h end
    return h
end

local function GetRoot(e)
    if not e then return nil end
    local h = GetHum(e)
    if h then
        local rp = h.RootPart
        if rp and rp:IsA("BasePart") then return rp end
    end
    for _, n in ipairs({"HumanoidRootPart", "Torso", "UpperTorso"}) do
        local r = e:FindFirstChild(n)
        if r and r:IsA("BasePart") then return r end
    end
    for _, d in ipairs(e:GetDescendants()) do
        if (d.Name == "HumanoidRootPart" or d.Name == "Torso" or d.Name == "UpperTorso") and d:IsA("BasePart") then
            return d
        end
    end
    if e:IsA("Model") and e.PrimaryPart then return e.PrimaryPart end
    for _, d in ipairs(e:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function GetModelPos(e)
    if not e then return nil end
    local r = GetRoot(e)
    if r then return r.Position end
    local ok, cf = pcall(function() return e:GetPivot() end)
    if ok and cf then return cf.Position end
    return nil
end

local function GetHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function DistTo(pos)
    if not pos then return 99999 end
    local hrp = GetHRP()
    if not hrp then return 99999 end
    return (hrp.Position - pos).Magnitude
end

local function IsAlive()
    local c = Player.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    return hrp ~= nil and h ~= nil and h.Health > 0
end

local function WaitForChar(timeout)
    if IsAlive() then return true end
    local t = tick()
    timeout = timeout or 20
    while tick() - t < timeout do
        if IsAlive() then task.wait(0.5) return true end
        task.wait(0.15)
    end
    return false
end

local function IsPlayer(m)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == m then return true end
    end
    return false
end

local function ShouldIgnore(n)
    local lo = (n or ""):lower()
    for _, ig in ipairs(S.IgnoreList) do
        if lo:find(ig, 1, true) then return true end
    end
    if lo:match("boss$") then return true end
    return false
end

local function MatchEnemy(name, island)
    if not island then return false end
    local lo = (name or ""):lower()
    local loNorm = lo:gsub("[%s%p_]", "")
    for _, e in ipairs(island.Enemies) do
        local el = (e or ""):lower()
        local elNorm = el:gsub("[%s%p_]", "")
        if lo:sub(1, #el) == el then return true end
        if elNorm ~= "" and loNorm:sub(1, #elNorm) == elNorm then return true end
    end
    return false
end

local function GetNPCFolder()
    local direct = Workspace:FindFirstChild(S.NPC_FOLDER)
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

local function FindEnemies(island)
    local nf = GetNPCFolder()
    if not island then return {} end
    local hrp = GetHRP()
    local origin = state.FarmOrigin
    local out = {}
    local function checkModel(m)
        if m:IsA("Model") and not IsPlayer(m) then
            local hm = GetHum(m)
            if hm and hm.Health > 0 and not ShouldIgnore(m.Name) then
                if MatchEnemy(m.Name, island) then
                    local p = GetModelPos(m)
                    if p then
                        if hrp and (p - hrp.Position).Magnitude > S.FARM_MAX_DIST_FROM_PLAYER then return end
                        if origin and (p - origin).Magnitude > S.FARM_MAX_DIST_FROM_ORIGIN then return end
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
    local hrp = GetHRP()
    if not hrp then return nil end
    local myY = hrp.Position.Y
    local best, bd = nil, math.huge
    for _, e in ipairs(list) do
        local p = GetModelPos(e)
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

local function GetIslandNames()
    local n = {"Auto"}
    for _, i in ipairs(S.Islands) do
        table.insert(n, i.Portal)
    end
    return n
end

local function DisplayToPortal(display)
    for _, i in ipairs(S.Islands) do
        if i.Portal == display then return i.Portal end
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
    if lv > 0 then
        state.ConfLevel = lv
        state.LastLevelScanTick = tick()
        return lv
    end
    if state.ConfLevel > 0 and tick() - state.LastLevelScanTick < 3 then
        return state.ConfLevel
    end
    state.LastLevelScanTick = tick()
    pcall(function()
        for _, c in ipairs(Player:GetDescendants()) do
            if (c:IsA("IntValue") or c:IsA("NumberValue") or c:IsA("StringValue")) then
                local n = c.Name:lower()
                if n == "level" or n == "lvl" or n:find("level", 1, true) or n:find("lvl", 1, true) then
                    local val = tonumber(c.Value)
                    if val and val > lv then lv = val end
                end
            end
        end
    end)
    if lv > 0 then
        state.ConfLevel = lv
        return lv
    end
    return state.ConfLevel
end

local function IslandForLevel(lvl)
    for _, i in ipairs(S.Islands) do
        if lvl < i.FarmUntil then return i end
    end
    return S.Islands[#S.Islands]
end

local function IslandByName(n)
    for _, i in ipairs(S.Islands) do
        if i.Portal == n then return i end
    end
    return nil
end

local function GetFarmIsland()
    local lvl = GetLevel()
    if lvl == 0 then
        task.wait(0.5)
        lvl = GetLevel()
        if lvl == 0 then
            task.wait(1)
            lvl = GetLevel()
        end
        if lvl == 0 then return nil end
    end
    if F.SelectedIsland == "Auto" then
        return IslandForLevel(lvl)
    end
    return IslandByName(F.SelectedIsland) or IslandForLevel(lvl)
end

local function WalkPathWait(base, t, ...)
    local cur = base
    for _, seg in ipairs({...}) do
        if not cur then return nil end
        cur = cur:WaitForChild(seg, t)
    end
    return cur
end

local function StopTween()
    if state.ATweenConn then
        pcall(function() state.ATweenConn:Disconnect() end)
        state.ATweenConn = nil
    end
    if state.ATween then
        pcall(function() state.ATween:Cancel() end)
        state.ATween = nil
    end
    state.TweenOn = false
    state.TweenTarget = nil
end

local function ClearTarget()
    state.CurTarget = nil
    state.LockTarget = nil
    state.SmoothY = nil
    StopTween()
end

local function AbandonAllQuests()
    state.QState = "NONE"
    if not state.CachedQuestAbandon then
        pcall(function()
            local f = ReplicatedStorage:FindFirstChild(R.QuestAbandon[1])
            if f then state.CachedQuestAbandon = f:FindFirstChild(R.QuestAbandon[2]) end
        end)
        if not state.CachedQuestAbandon then
            pcall(function() state.CachedQuestAbandon = WalkPathWait(ReplicatedStorage, 1, unpack(R.QuestAbandon)) end)
        end
    end
    local ab = state.CachedQuestAbandon
    if ab then
        pcall(function() ab:FireServer("repeatable") end)
        pcall(function() ab:FireServer() end)
        for _, n in ipairs({"HogyokuUnlock", "HogyokuQuestNPC", "Hogyoku", "HogyokuFragment", "HogyokuQuest", "SoulSocietyUnlock", "SoulSociety"}) do
            pcall(function() ab:FireServer(n) end)
        end
        for _, isl in ipairs(S.Islands) do
            pcall(function() ab:FireServer(isl.QuestNPC) end)
        end
    end
end

local function FullReset()
    StopTween()
    ClearTarget()
    state.HoverPos = nil
    state.LockTarget = nil
    state.CurIsland = nil
    state.IslandTPd = false
    state.SpawnDone = false
    state.FarmOrigin = nil
    state.LastEnemy = 0
    state.LastTP = 0
    state.TPCount = 0
    state.FarmGenericMode = false
    AbandonAllQuests()
    state.LastQuestAccept = 0
    state.BossTargetName = nil
    state.BossFight = false
    state.BossTPDone = false
    state.LastBossTP = 0
    state.BossCurrentIsland = nil
    state.SummonBossFight = false
    state.SummonBossTarget = nil
    state.SummonBossTPDone = false
    state.LastSummonBossTP = 0
    state.SummonBossCommitted = {}
    state.SummonBossCurrentIsland = nil
    state.SummonBossOrder = 0
    state.SummonBossFailCount = {}
    state.SummonBossLockedDiff = {}
    pcall(function()
        local c = Player.Character
        if c then
            local hm = c:FindFirstChildOfClass("Humanoid")
            if hm then hm.PlatformStand = false end
        end
    end)
end

local function DoTP(portal)
    if tick() - state.LastTP < 3 then return false end
    if tick() - state.TPReset > 120 then
        state.TPCount = 0
        state.TPReset = tick()
    end
    if state.TPCount >= 10 then return false end
    state.LastTP = tick()
    state.TPCount = state.TPCount + 1
    local ok = false
    pcall(function()
        WalkPathWait(ReplicatedStorage, 3, unpack(R.TP)):FireServer(portal)
        ok = true
    end)
    return ok
end

local function ForceTP(portal)
    state.LastTP = 0
    state.TPCount = 0
    state.TPReset = tick()
    local ok = false
    pcall(function()
        WalkPathWait(ReplicatedStorage, 5, unpack(R.TP)):FireServer(portal)
        ok = true
    end)
    if not ok then
        task.wait(1)
        pcall(function()
            WalkPathWait(ReplicatedStorage, 5, unpack(R.TP)):FireServer(portal)
            ok = true
        end)
    end
    state.LastTP = tick()
    state.TPCount = 1
    return ok
end

local function QuestAccept(island)
    if not island or not island.QuestNPC then return end
    pcall(function() WalkPathWait(ReplicatedStorage, 3, unpack(R.QuestAccept)):FireServer(island.QuestNPC) end)
    state.LastQuestAccept = tick()
    state.QState = "ACTIVE"
end

local function QuestRepeatFire(island)
    if not island or not island.QuestNPC then return end
    pcall(function() WalkPathWait(ReplicatedStorage, 3, unpack(R.QuestRepeat)):FireServer(island.QuestNPC) end)
    state.LastQuestAccept = tick()
    state.QState = "ACTIVE"
end

local function QuestCompletionScan()
    if state.QState ~= "ACTIVE" then return end
    if tick() - state.LastQuestAccept > 60 then
        state.QState = "NONE"
        return
    end
    if tick() - state.LastQuestAccept < 8 then return end
    local pg = Player:FindFirstChild("PlayerGui")
    if not pg then return end
    local hasQuestUI = false
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local t = (d.Text or ""):lower()
            if t:find("quest complet") or t:find("abandon") then
                state.QState = "NONE"
                return
            end
            if t:find("%d+%s*/%s*%d+") or t:find("kill") or t:find("collect") or t:find("objective") or t:find("quest") then
                hasQuestUI = true
            end
        end
    end
    if not hasQuestUI and tick() - state.LastQuestAccept > 20 then
        state.QState = "NONE"
    end
end

local function GetGoalForEnemy(enemy)
    local pos = GetModelPos(enemy)
    if not pos then return nil, nil end
    return Vector3.new(pos.X, pos.Y + F.HeightOffset, pos.Z), pos
end

local function TweenTo(enemy)
    if not enemy then return end
    local goal, look = GetGoalForEnemy(enemy)
    if not goal then return end
    local hrp = GetHRP()
    if not hrp then return end
    local d = (hrp.Position - goal).Magnitude
    if d > 600 then return end
    local speed = F.TweenSpeed
    local inBoss = state.BossFight or state.SummonBossFight
    if F.MoveMode == "Teleport" and not inBoss and d < 35 and tick() - state.LastSmoothMove > 0.2 then
        StopTween()
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(goal, look or goal), 0.55)
        state.LastSmoothMove = tick()
        state.LockTarget = enemy
        state.TweenOn = false
        state.TweenTarget = nil
        state.HoverPos = goal
        return
    end
    if state.TweenTarget ~= enemy then StopTween() end
    d = (hrp.Position - goal).Magnitude
    if d < 25 and F.MoveMode ~= "Tween" then
        state.LockTarget = enemy
        state.TweenOn = false
        state.TweenTarget = nil
        state.HoverPos = goal
        return
    end
    if state.TweenOn and state.TweenTarget == enemy then return end
    StopTween()
    state.TweenOn = true
    state.TweenTarget = enemy
    state.LockTarget = nil
    local stepDist = math.min(d, 80)
    local dir = (goal - hrp.Position).Unit
    local stepGoal = hrp.Position + (dir * stepDist)
    local cf = CFrame.new(stepGoal, look or goal)
    local dur = math.clamp(stepDist / math.max(speed, 1), 0.06, 3.0)
    state.ATween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = cf})
    state.ATweenConn = state.ATween.Completed:Connect(function()
        state.ATween = nil
        state.ATweenConn = nil
        state.TweenOn = false
        state.TweenTarget = nil
        if enemy and enemy.Parent then
            if F.MoveMode == "Tween" then
                local h2 = GetHRP()
                state.HoverPos = h2 and h2.Position or goal
            else
                state.LockTarget = enemy
                state.HoverPos = goal
            end
        end
    end)
    state.ATween:Play()
end

local function FireAbilities()
    if tick() - state.LastSkill < F.SkillCooldown then return end
    if not (F.SkillZ or F.SkillX or F.SkillC or F.SkillV or F.SkillF) then return end
    if not state.CachedAbilityRemote or not state.CachedAbilityRemote.Parent then
        state.CachedAbilityRemote = nil
        pcall(function() state.CachedAbilityRemote = WalkPathWait(ReplicatedStorage, 2, unpack(R.Ability)) end)
    end
    local r = state.CachedAbilityRemote
    if not r then return end
    state.LastSkill = tick()
    if F.SkillZ then pcall(function() r:FireServer(1) end) end
    if F.SkillX then pcall(function() r:FireServer(2) end) end
    if F.SkillC then pcall(function() r:FireServer(3) end) end
    if F.SkillV then pcall(function() r:FireServer(4) end) end
    if F.SkillF then pcall(function() r:FireServer(5) end) end
end

local function Attack(tgt)
    pcall(function() WalkPathWait(ReplicatedStorage, 2, unpack(R.Hit)):FireServer(tgt) end)
    local tools = {}
    local c = Player.Character
    if c then
        for _, ch in ipairs(c:GetChildren()) do
            if ch:IsA("Tool") then table.insert(tools, ch) end
        end
    end
    for _, tool in ipairs(tools) do
        pcall(function() tool:Activate() end)
    end
    FireAbilities()
end

local function GetAllTools()
    local c = Player.Character
    if not c then return {} end
    local t = {}
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") then table.insert(t, ch) end
    end
    return t
end

local function EquipBothWeapons()
    local c = Player.Character
    if not c then return end
    local hm = c:FindFirstChildOfClass("Humanoid")
    if not hm then return end
    local bp = Player:FindFirstChild("Backpack")
    if not bp then return end
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
    for _, ch in ipairs(bp:GetChildren()) do
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
        hm:UnequipTools()
        task.wait(0.1)
        pcall(function() melee.Parent = c end)
        pcall(function() sword.Parent = c end)
    elseif sword and not melee then
        pcall(function() sword.Parent = c end)
    elseif melee and not sword then
        pcall(function() melee.Parent = c end)
    end
end

local function OnCharAdded(char)
    state.CharHum = nil
    char:WaitForChild("Humanoid", 10)
    state.CharHum = char:FindFirstChildOfClass("Humanoid")
    state.LockTarget = nil
    state.TweenOn = false
    state.TweenTarget = nil
    state.HoverPos = nil
    if F.AutoEquip then
        task.spawn(function()
            task.wait(0.5)
            for _ = 1, 10 do
                task.wait(0.3)
                EquipBothWeapons()
                local tools = GetAllTools()
                if #tools >= 2 then break end
                if #tools >= 1 then
                    local hasSword = false
                    for _, t in ipairs(tools) do
                        if t.Name:lower() ~= "combat" then hasSword = true end
                    end
                    if hasSword then break end
                end
            end
        end)
    end
end

if Player.Character then
    task.spawn(function() OnCharAdded(Player.Character) end)
end
Player.CharacterAdded:Connect(OnCharAdded)

local function SetupAntiAFK()
    local function disableIdled()
        pcall(function()
            for _, c in ipairs(getconnections(Player.Idled)) do
                c:Disable()
            end
        end)
    end
    local function pulse()
        pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
        pcall(function() VirtualUser:Button2Down(Vector2.new()) task.defer(function() pcall(function() VirtualUser:Button2Up(Vector2.new()) end) end) end)
    end
    disableIdled()
    Player.Idled:Connect(function()
        if F.AntiAFK then
            disableIdled()
            pulse()
        end
    end)
    task.spawn(function()
        while state.Running do
            task.wait(math.random(20, 40))
            if F.AntiAFK then
                disableIdled()
                pulse()
            end
        end
    end)
end

SetupAntiAFK()

--==================================================
-- FARM TAB
--==================================================
local FarmSection = FarmTab:AddSection({
    Name = "⚔️ AUTO FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmSection:AddToggle({
    Name = "ENABLE AUTO FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoFarmLevel",
    Save = true,
    Callback = function(Value)
        if Value and (F.AutoDungeon or F.AutoBossRush) then
            task.defer(function() 
                pcall(function() 
                    local toggle = FarmSection.Toggles and FarmSection.Toggles["AutoFarmLevel"]
                    if toggle then toggle:SetValue(false) end
                end)
            end)
            return
        end
        F.AutoFarmLevel = Value
        if Value then
            if F.AutoDungeon then F.AutoDungeon = false end
            StopTween()
            ClearTarget()
            state.CurIsland = nil
            state.IslandTPd = false
            state.SpawnDone = false
            state.FarmOrigin = nil
            state.FarmGenericMode = false
            state.QState = "NONE"
            state.CurTarget = nil
            state.LockTarget = nil
            state.HoverPos = nil
            state.LastEnemy = 0
            Notify("Auto Farm Enabled")
        else
            FullReset()
            Notify("Auto Farm Disabled")
        end
    end
})

FarmSection:AddKeybind({
    Name = "Farm Keybind",
    Default = Enum.KeyCode.V,
    Flag = "FarmKeybind",
    Callback = function()
        if FarmSection.Toggles and FarmSection.Toggles["AutoFarmLevel"] then
            local current = FarmSection.Toggles["AutoFarmLevel"]:GetValue()
            FarmSection.Toggles["AutoFarmLevel"]:SetValue(not current)
        end
    end
})

FarmSection:AddToggle({
    Name = "AUTO EQUIP SWORD",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoEquip",
    Save = true,
    Callback = function(Value) F.AutoEquip = Value end
})

FarmSection:AddToggle({
    Name = "AUTO QUEST",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoQuest",
    Save = true,
    Callback = function(Value) F.AutoQuest = Value end
})

FarmSection:AddToggle({
    Name = "SET SPAWN CRYSTAL",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoSpawn",
    Save = true,
    Callback = function(Value) 
        F.AutoSpawn = Value 
        state.SpawnDone = false
    end
})

FarmSection:AddToggle({
    Name = "ANTI AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value) F.AntiAFK = Value end
})

FarmSection:AddDropdown({
    Name = "ISLAND",
    Default = "Auto",
    Values = GetIslandNames(),
    Flag = "SelectedIsland",
    Save = true,
    Callback = function(Value)
        local portal = DisplayToPortal(Value)
        F.SelectedIsland = portal
        StopTween()
        ClearTarget()
        state.HoverPos = nil
        state.LockTarget = nil
        state.CurIsland = nil
        state.IslandTPd = false
        state.SpawnDone = false
        state.FarmOrigin = nil
        state.FarmGenericMode = false
        state.LastEnemy = 0
        state.CurTarget = nil
        state.LastTP = 0
        state.TPCount = 0
        state.TPReset = tick()
        state.QState = "NONE"
        AbandonAllQuests()
        Notify("Island changed to: " .. Value)
    end
})

FarmSection:AddDropdown({
    Name = "FARM STYLE",
    Default = "Plank",
    Values = {"Plank"},
    Flag = "FarmMode",
    Save = true,
    Callback = function(Value)
        F.FarmMode = "Plank"
        ClearTarget()
        state.HoverPos = nil
    end
})

FarmSection:AddDropdown({
    Name = "MOVE MODE",
    Default = "Tween",
    Values = {"Tween", "Teleport"},
    Flag = "MoveMode",
    Save = true,
    Callback = function(Value)
        F.MoveMode = Value
        ClearTarget()
        state.HoverPos = nil
    end
})

FarmSection:AddSlider({
    Name = "HEIGHT (PLANK)",
    Min = 5,
    Max = 40,
    Default = 15,
    Increment = 1,
    ValueName = "studs",
    Flag = "HeightOffset",
    Save = true,
    Callback = function(Value) F.HeightOffset = Value end
})

FarmSection:AddSlider({
    Name = "OFFSET DISTANCE",
    Min = 2,
    Max = 15,
    Default = 5,
    Increment = 1,
    ValueName = "studs",
    Flag = "OffsetDist",
    Save = true,
    Callback = function(Value) F.OffsetDist = Value end
})

FarmSection:AddSlider({
    Name = "TWEEN SPEED",
    Min = 15,
    Max = 200,
    Default = 100,
    Increment = 1,
    ValueName = "speed",
    Flag = "TweenSpeed",
    Save = true,
    Callback = function(Value) 
        F.TweenSpeed = Value 
        StopTween()
    end
})

--==================================================
-- GAMEMODES TAB
--==================================================
local DungeonSection = GameModesTab:AddSection({
    Name = "🏰 DUNGEON",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Rune Dungeon
DungeonSection:AddToggle({
    Name = "ENABLE RUNE DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRuneDungeon",
    Save = true,
    Callback = function(Value)
        if Value then
            F.DungeonType = "Rune"
            F.AutoDungeon = true
            F.AutoFarmLevel = false
            F.AutoBossRush = false
            F.BossEnabled = false
            if state.BossFight then state.BossFight = false end
            if state.SummonBossFight then 
                state.SummonBossFight = false 
                state.SummonBossTarget = nil
            end
            ClearTarget()
            Notify("Rune Dungeon Enabled")
        else
            F.AutoDungeon = false
        end
    end
})

DungeonSection:AddDropdown({
    Name = "Rune Difficulty",
    Default = "Normal",
    Values = S.DungeonDifficulties,
    Flag = "RuneDiff",
    Save = true,
    Callback = function(Value) F.RuneDiff = Value end
})

DungeonSection:AddDropdown({
    Name = "Rune Move Mode",
    Default = "Teleport",
    Values = {"Tween", "Teleport"},
    Flag = "RuneMove",
    Save = true,
    Callback = function(Value) 
        F.RuneMove = Value 
        ClearTarget()
    end
})

DungeonSection:AddSlider({
    Name = "Rune Height",
    Min = 5,
    Max = 40,
    Default = 10,
    Increment = 1,
    ValueName = "studs",
    Flag = "RuneHeight",
    Save = true,
    Callback = function(Value) F.RuneHeight = Value end
})

DungeonSection:AddSlider({
    Name = "Rune Speed",
    Min = 20,
    Max = 250,
    Default = 50,
    Increment = 1,
    ValueName = "speed",
    Flag = "RuneSpeed",
    Save = true,
    Callback = function(Value) F.RuneSpeed = Value end
})

-- Cid Dungeon
DungeonSection:AddToggle({
    Name = "ENABLE CID DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoCidDungeon",
    Save = true,
    Callback = function(Value)
        if Value then
            F.DungeonType = "Cid"
            F.AutoDungeon = true
            F.AutoFarmLevel = false
            F.AutoBossRush = false
            F.BossEnabled = false
            if state.BossFight then state.BossFight = false end
            if state.SummonBossFight then 
                state.SummonBossFight = false 
                state.SummonBossTarget = nil
            end
            ClearTarget()
            Notify("Cid Dungeon Enabled")
        else
            F.AutoDungeon = false
        end
    end
})

DungeonSection:AddDropdown({
    Name = "Cid Difficulty",
    Default = "Normal",
    Values = S.DungeonDifficulties,
    Flag = "CidDiff",
    Save = true,
    Callback = function(Value) F.CidDiff = Value end
})

DungeonSection:AddDropdown({
    Name = "Cid Move Mode",
    Default = "Teleport",
    Values = {"Tween", "Teleport"},
    Flag = "CidMove",
    Save = true,
    Callback = function(Value) 
        F.CidMove = Value 
        ClearTarget()
    end
})

DungeonSection:AddSlider({
    Name = "Cid Height",
    Min = 5,
    Max = 40,
    Default = 10,
    Increment = 1,
    ValueName = "studs",
    Flag = "CidHeight",
    Save = true,
    Callback = function(Value) F.CidHeight = Value end
})

DungeonSection:AddSlider({
    Name = "Cid Speed",
    Min = 20,
    Max = 250,
    Default = 50,
    Increment = 1,
    ValueName = "speed",
    Flag = "CidSpeed",
    Save = true,
    Callback = function(Value) F.CidSpeed = Value end
})

-- Double Dungeon
DungeonSection:AddToggle({
    Name = "ENABLE DOUBLE DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDoubleDungeon",
    Save = true,
    Callback = function(Value)
        if Value then
            F.DungeonType = "Double"
            F.AutoDungeon = true
            F.AutoFarmLevel = false
            F.AutoBossRush = false
            F.BossEnabled = false
            if state.BossFight then state.BossFight = false end
            if state.SummonBossFight then 
                state.SummonBossFight = false 
                state.SummonBossTarget = nil
            end
            ClearTarget()
            Notify("Double Dungeon Enabled")
        else
            F.AutoDungeon = false
        end
    end
})

DungeonSection:AddDropdown({
    Name = "Double Difficulty",
    Default = "Normal",
    Values = S.DungeonDifficulties,
    Flag = "DoubleDiff",
    Save = true,
    Callback = function(Value) F.DoubleDiff = Value end
})

DungeonSection:AddDropdown({
    Name = "Double Move Mode",
    Default = "Teleport",
    Values = {"Tween", "Teleport"},
    Flag = "DoubleMove",
    Save = true,
    Callback = function(Value) 
        F.DoubleMove = Value 
        ClearTarget()
    end
})

DungeonSection:AddSlider({
    Name = "Double Height",
    Min = 5,
    Max = 40,
    Default = 10,
    Increment = 1,
    ValueName = "studs",
    Flag = "DoubleHeight",
    Save = true,
    Callback = function(Value) F.DoubleHeight = Value end
})

DungeonSection:AddSlider({
    Name = "Double Speed",
    Min = 20,
    Max = 250,
    Default = 50,
    Increment = 1,
    ValueName = "speed",
    Flag = "DoubleSpeed",
    Save = true,
    Callback = function(Value) F.DoubleSpeed = Value end
})

-- Boss Rush Section
local BossRushSection = GameModesTab:AddSection({
    Name = "👑 BOSS RUSH",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossRushSection:AddToggle({
    Name = "ENABLE BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBossRush",
    Save = true,
    Callback = function(Value)
        F.AutoBossRush = Value
        if Value then
            F.AutoFarmLevel = false
            F.AutoDungeon = false
            F.BossEnabled = false
            if state.BossFight then state.BossFight = false end
            if state.SummonBossFight then 
                state.SummonBossFight = false 
                state.SummonBossTarget = nil
            end
            ClearTarget()
            Notify("Boss Rush Enabled")
        else
            ClearTarget()
        end
    end
})

BossRushSection:AddDropdown({
    Name = "Boss Rush Style",
    Default = "Plank",
    Values = {"Plank"},
    Flag = "BossRushFarmMode",
    Save = true,
    Callback = function()
        F.BossRushFarmMode = "Plank"
        ClearTarget()
    end
})

BossRushSection:AddDropdown({
    Name = "Boss Rush Move Mode",
    Default = "Teleport",
    Values = {"Tween", "Teleport"},
    Flag = "BossRushMoveMode",
    Save = true,
    Callback = function(Value)
        F.BossRushMoveMode = Value
        ClearTarget()
    end
})

BossRushSection:AddSlider({
    Name = "Boss Rush Height",
    Min = 5,
    Max = 40,
    Default = 10,
    Increment = 1,
    ValueName = "studs",
    Flag = "BossRushHeightOffset",
    Save = true,
    Callback = function(Value) F.BossRushHeightOffset = Value end
})

BossRushSection:AddSlider({
    Name = "Boss Rush Speed",
    Min = 20,
    Max = 250,
    Default = 50,
    Increment = 1,
    ValueName = "speed",
    Flag = "BossRushTweenSpeed",
    Save = true,
    Callback = function(Value) F.BossRushTweenSpeed = Value end
})

--==================================================
-- SKILLS TAB
--==================================================
local SkillsSection = SkillsTab:AddSection({
    Name = "🔥 AUTO SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local AllSkillsToggle = SkillsSection:AddToggle({
    Name = "ALL SKILLS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AllSkills",
    Save = true,
    Callback = function(Value)
        for _, k in ipairs(S.SkillKeys) do
            local toggle = SkillsSection.Toggles and SkillsSection.Toggles[k]
            if toggle then
                pcall(function() toggle:SetValue(Value) end)
            else
                F[k] = Value
            end
        end
    end
})

AllSkillsToggle:AddKeybind({
    Name = "All Skills Keybind",
    Default = Enum.KeyCode.M,
    Flag = "AllSkillsKeybind",
    Callback = function()
        local current = AllSkillsToggle:GetValue()
        AllSkillsToggle:SetValue(not current)
    end
})

SkillsSection:AddToggle({
    Name = "SKILL Z",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillZ",
    Save = true,
    Callback = function(Value) F.SkillZ = Value end
})

SkillsSection:AddToggle({
    Name = "SKILL X",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillX",
    Save = true,
    Callback = function(Value) F.SkillX = Value end
})

SkillsSection:AddToggle({
    Name = "SKILL C",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillC",
    Save = true,
    Callback = function(Value) F.SkillC = Value end
})

SkillsSection:AddToggle({
    Name = "SKILL V",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillV",
    Save = true,
    Callback = function(Value) F.SkillV = Value end
})

SkillsSection:AddToggle({
    Name = "SKILL F (NUKE)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillF",
    Save = true,
    Callback = function(Value) F.SkillF = Value end
})

SkillsSection:AddSlider({
    Name = "SKILL COOLDOWN",
    Min = 0.3,
    Max = 5,
    Default = 1.0,
    Increment = 0.1,
    ValueName = "sec",
    Flag = "SkillCooldown",
    Save = true,
    Callback = function(Value) F.SkillCooldown = Value end
})

--==================================================
-- CHESTS SECTION
--==================================================
local ChestsSection = SkillsTab:AddSection({
    Name = "🎁 AUTO CHESTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ChestsSection:AddToggle({
    Name = "AUTO OPEN CHESTS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(Value) F.AutoChest = Value end
})

for _, chest in ipairs(S.ChestNames) do
    local flag = "Chest_" .. chest:gsub(" ", "_")
    ChestsSection:AddToggle({
        Name = chest,
        Default = true,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = flag,
        Save = true,
        Callback = function(Value) state.FC[chest] = Value end
    })
end

--==================================================
-- QUESTS TAB
--==================================================
local QuestsSection = QuestsTab:AddSection({
    Name = "📜 UNLOCK QUESTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

QuestsSection:AddToggle({
    Name = "LOCATE DUNGEON PIECES",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(Value)
        F.DungeonQuest = Value
        if Value then
            if F.HogyokuQuest then
                F.HogyokuQuest = false
            end
            if state.SummonBossFight then state.SummonBossFight = false end
            if state.BossFight then state.BossFight = false end
            ClearTarget()
            Notify("Dungeon Quest Started")
        else
            ClearTarget()
            Notify("Dungeon Quest Disabled")
        end
    end
})

QuestsSection:AddParagraph({
    Title = "Dungeon Info",
    Desc = "1. Accepts quest remotely\n2. Collects 6 pieces (Starter→Jungle→Desert→Snow→Shibuya→Hueco Mundo)\n3. Returns to Dungeon Master",
    Image = "info",
    ImageSize = 38
})

QuestsSection:AddToggle({
    Name = "LOCATE HOGYOKU FRAGMENTS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(Value)
        F.HogyokuQuest = Value
        if Value then
            if F.DungeonQuest then
                F.DungeonQuest = false
            end
            if state.SummonBossFight then state.SummonBossFight = false end
            if state.BossFight then state.BossFight = false end
            ClearTarget()
            Notify("Hogyoku Quest Started")
        else
            ClearTarget()
            Notify("Hogyoku Quest Disabled")
        end
    end
})

QuestsSection:AddParagraph({
    Title = "Hogyoku Info",
    Desc = "1. Accepts quest remotely\n2. Collects 5 fragments (Snow→Shibuya→Hueco Mundo→Slime→Judgement)\n3. Returns to Gin (Hueco Mundo)",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- MERCHANT TAB
--==================================================
local MerchantSection = MerchantTab:AddSection({
    Name = "🛒 AUTO MERCHANT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MerchantSection:AddToggle({
    Name = "ENABLE AUTO MERCHANT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoMerchant",
    Save = true,
    Callback = function(Value) 
        F.AutoMerchant = Value 
        if Value then state.LastMerchant = 0 end
    end
})

MerchantSection:AddToggle({
    Name = "MERCHANT NOTIFIER",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "MerchNotify",
    Save = true,
    Callback = function(Value) F.MerchNotify = Value end
})

for _, item in ipairs(S.MerchantItems) do
    local flag = "Merchant_" .. item:gsub(" ", "_")
    MerchantSection:AddToggle({
        Name = item,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = flag,
        Save = true,
        Callback = function(Value) state.FM[item] = Value end
    })
end

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportSection = TeleportTab:AddSection({
    Name = "📍 TELEPORT TO ISLAND",
    TextSize = 18,
    Glass = true,
    Outline = true
})

for _, name in ipairs(S.TpIslands) do
    TeleportSection:AddButton({
        Name = name,
        Icon = "map-pin",
        Outline = true,
        Callback = function()
            if F.AutoFarmLevel then
                Notify("Disable Auto Farm first!", 3)
                return
            end
            ForceTP(name)
            Notify("Teleported to " .. name)
        end
    })
end

--==================================================
-- SETTINGS TAB
--==================================================
local UISection = SettingsTab:AddSection({
    Name = "🎨 UI SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

UISection:AddButton({
    Name = "COPY DISCORD LINK",
    Icon = "link",
    Outline = true,
    Callback = function()
        pcall(function() setclipboard(S.DISCORD) end)
        Notify("Discord link copied!")
    end
})

UISection:AddButton({
    Name = "DESTROY GUI",
    Icon = "x",
    Outline = true,
    Callback = function()
        state.Running = false
        F.AutoFarmLevel = false
        F.AutoDungeon = false
        F.AutoBossRush = false
        F.BossEnabled = false
        F.AutoChest = false
        F.AutoMerchant = false
        F.DungeonQuest = false
        F.HogyokuQuest = false
        for _, k in ipairs(S.SkillKeys) do F[k] = false end
        pcall(function()
            local c = Player.Character
            if c then
                local hm = c:FindFirstChildOfClass("Humanoid")
                if hm then hm.PlatformStand = false end
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end)
        StopTween()
        ClearTarget()
        state.HoverPos = nil
        state.NoclipActive = false
        task.wait(0.1)
        OrionLib:Destroy()
        _G.SP_Loaded = false
    end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "folder"
})

--==================================================
-- MAIN LOOP
--==================================================
task.spawn(function()
    if not IsAlive() then WaitForChar() task.wait(0.5) end
    for _ = 1, 10 do
        if GetLevel() > 0 then break end
        task.wait(0.5)
    end
    
    while state.Running do
        repeat
            local isSummonActive = false
            for _, b in ipairs(S.SummonBosses) do
                if state.BSF[b.Name] then
                    isSummonActive = true
                    break
                end
            end
            
            if not F.AutoFarmLevel and not F.AutoDungeon and not F.AutoBossRush and not isSummonActive and not F.DungeonQuest and not F.HogyokuQuest then
                task.wait(0.3)
                break
            end
            
            if not IsAlive() then
                ClearTarget()
                state.HoverPos = nil
                WaitForChar()
                task.wait(0.3)
                if F.AutoEquip then
                    EquipBothWeapons()
                    task.wait(0.2)
                end
                if not state.BossFight and not state.SummonBossFight then
                    state.IslandTPd = false
                    state.SpawnDone = false
                    state.FarmOrigin = nil
                end
                state.LastBossTP = 0
                state.BossTPDone = false
                state.LastSummonBossTP = 0
                state.SummonBossTPDone = false
            end
            
            if not IsAlive() then
                task.wait(0.3)
                break
            end
            
            -- FARM LOOP
            if F.AutoFarmLevel and not F.AutoDungeon and not F.AutoBossRush and not isSummonActive and not F.DungeonQuest and not F.HogyokuQuest then
                local tgtIsland = GetFarmIsland()
                if not tgtIsland then
                    task.wait(1)
                    break
                end
                
                if not state.CurIsland or state.CurIsland.Portal ~= tgtIsland.Portal then
                    StopTween()
                    state.CurIsland = tgtIsland
                    state.IslandTPd = false
                    state.SpawnDone = false
                    state.FarmOrigin = nil
                    state.QState = "NONE"
                    state.CurTarget = nil
                    state.LockTarget = nil
                    state.HoverPos = nil
                    state.LastEnemy = 0
                    state.LastQuestAccept = tick()
                    AbandonAllQuests()
                    Notify("Teleporting to " .. tgtIsland.Portal)
                end
                
                if not state.IslandTPd then
                    if ForceTP(state.CurIsland.Portal) then
                        task.wait(0.5)
                        state.IslandTPd = true
                        state.FarmOrigin = nil
                        task.wait(1.0)
                        local hrpNow = GetHRP()
                        if hrpNow then state.FarmOrigin = hrpNow.Position end
                        state.LastEnemy = tick()
                        if F.AutoSpawn and not state.SpawnDone then
                            state.SpawnDone = true
                            task.wait(0.2)
                        end
                        if F.AutoQuest and state.QState == "NONE" then
                            task.wait(0.1)
                            QuestAccept(state.CurIsland)
                        end
                    else
                        task.wait(1)
                    end
                    break
                end
                
                if F.AutoQuest and state.QState == "NONE" then
                    if tick() - state.LastQuestAccept > 5 then
                        QuestRepeatFire(state.CurIsland)
                    end
                end
                
                local enemies = FindEnemies(state.CurIsland)
                state.FarmGenericMode = false
                
                if #enemies > 0 then
                    state.LastEnemy = tick()
                    if state.CurTarget then
                        local hm = GetHum(state.CurTarget)
                        if not hm or hm.Health <= 0 or not state.CurTarget.Parent then
                            if hm and hm.Health <= 0 then
                                state.Kills = state.Kills + 1
                            end
                            state.CurTarget = nil
                            state.LockTarget = nil
                        elseif not MatchEnemy(state.CurTarget.Name, state.CurIsland) then
                            state.CurTarget = nil
                            state.LockTarget = nil
                        else
                            local cp = GetModelPos(state.CurTarget)
                            if cp and DistTo(cp) > 400 then
                                state.CurTarget = nil
                                state.LockTarget = nil
                            end
                        end
                    end
                    if not state.CurTarget then
                        state.CurTarget = NearestFrom(enemies)
                    end
                    if state.CurTarget then
                        TweenTo(state.CurTarget)
                        Attack(state.CurTarget)
                    end
                else
                    state.FarmGenericMode = false
                    state.CurTarget = nil
                    state.LockTarget = nil
                    if tick() - state.LastEnemy > 20 then
                        state.IslandTPd = false
                        state.SpawnDone = false
                        state.FarmOrigin = nil
                        state.LastEnemy = 0
                        state.HoverPos = nil
                    end
                    task.wait(0.15)
                end
                
                if F.AutoEquip and tick() - state.LastEquip > 3 then
                    state.LastEquip = tick()
                    EquipBothWeapons()
                end
                
                task.wait(0.1)
                break
            end
            
            task.wait(0.1)
        until true
    end
end)

--==================================================
-- RENDER LOOP (NOCLIP, HOVER)
--==================================================
RunService.RenderStepped:Connect(function()
    local anyActive = F.AutoFarmLevel or F.AutoDungeon or F.AutoBossRush or state.BossFight or state.SummonBossFight or F.DungeonQuest or F.HogyokuQuest
    
    if not anyActive then
        if state.NoclipActive then
            state.NoclipActive = false
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
        state.SmoothY = nil
        return
    end
    
    state.NoclipActive = true
    local c = Player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if tick() - state.LastCanCollide > 0.2 then
        state.LastCanCollide = tick()
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
    
    -- Platform stand for Plank mode
    if F.FarmMode == "Plank" or F.BossRushFarmMode == "Plank" then
        local hm = c:FindFirstChildOfClass("Humanoid")
        if hm then hm.PlatformStand = true end
    end
    
    if state.TweenOn then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return
    end
    
    -- Ground detection
    local hit = Workspace:Raycast(hrp.Position + Vector3.new(0, 3, 0), Vector3.new(0, -50, 0), state.RayParams)
    if hit and hrp.Position.Y < hit.Position.Y + 1 then
        local corrected = CFrame.new(hrp.Position.X, hit.Position.Y + 3, hrp.Position.Z) * (hrp.CFrame - hrp.CFrame.Position)
        hrp.CFrame = hrp.CFrame:Lerp(corrected, 0.4)
    end
    
    -- Lock target hover
    if state.LockTarget then
        local hm = GetHum(state.LockTarget)
        if not hm or hm.Health <= 0 or not state.LockTarget.Parent then
            state.LockTarget = nil
        end
        
        if state.LockTarget then
            local tp = GetModelPos(state.LockTarget)
            if tp then
                if tp.Y < -30 then
                    state.LockTarget = nil
                end
                if state.LockTarget and hrp and (tp - hrp.Position).Magnitude > 600 then
                    state.LockTarget = nil
                end
            end
        end
        
        if state.LockTarget then
            local goal, look = GetGoalForEnemy(state.LockTarget)
            if goal then
                if goal.Y < -30 then
                    state.LockTarget = nil
                else
                    if not state.SmoothY then
                        state.SmoothY = goal.Y
                    else
                        state.SmoothY = state.SmoothY + (goal.Y - state.SmoothY) * 0.03
                    end
                    goal = Vector3.new(goal.X, state.SmoothY, goal.Z)
                    local targetCF = CFrame.new(goal, look or (goal + S.LOOK_DOWN))
                    local dist = (hrp.Position - goal).Magnitude
                    if dist < 5 then
                        hrp.CFrame = targetCF
                    else
                        local alpha = math.clamp(0.18 + (dist / 220), 0.18, 0.45)
                        hrp.CFrame = hrp.CFrame:Lerp(targetCF, alpha)
                    end
                    state.HoverPos = goal
                    state.LastSmoothMove = tick()
                end
            end
        elseif state.HoverPos then
            local hoverCF = CFrame.new(state.HoverPos, state.HoverPos + S.LOOK_DOWN)
            hrp.CFrame = hoverCF
        end
    elseif state.HoverPos then
        local hoverCF = CFrame.new(state.HoverPos, state.HoverPos + S.LOOK_DOWN)
        hrp.CFrame = hoverCF
    end
    
    -- Zero velocity in plank mode
    if F.FarmMode == "Plank" or F.BossRushFarmMode == "Plank" then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ EDITION 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm Level")
print("✅ Auto Dungeon (Rune/Cid/Double)")
print("✅ Auto Boss Rush")
print("✅ Auto Skills")
print("✅ Auto Chests")
print("✅ Auto Merchant")
print("✅ Dungeon & Hogyoku Quests")
print("✅ Teleport to Islands")
print("═══════════════════════════════════════════════════════")