-- ==================== SAILOR PIECE - CATRAZ EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 1.0 COMPLETE (11k+ lines)

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
-- S = ALL STATE, DATA, CONSTANTS
--==================================================
local S = {
    ICON = "rbxthumb://type=AvatarHeadShot&id=583572860&w=420&h=420",
    DISCORD = "https://discord.gg/B3PurfCy",
    NPC_FOLDER = "NPCs",
    BOSS_ISLAND_PORTAL = "Boss",
    ANOS_ISLAND = "Academy",
    LOOK_DOWN = Vector3.new(0,-1,0),
    FARM_MAX_DIST_FROM_PLAYER = 900,
    FARM_MAX_DIST_FROM_ORIGIN = 1200,
    GENERIC_HOSTILE_MAX_DIST = 900,
    TP = {"Remotes","TeleportToPortal"},
    QuestAccept = {"RemoteEvents","QuestAccept"},
    QuestAbandon = {"RemoteEvents","QuestAbandon"},
    UseItem = {"Remotes","UseItem"},
    Hit = {"CombatSystem","Remotes","RequestHit"},
    Ability = {"AbilitySystem","Remotes","RequestAbility"},
    Merchant = {"Remotes","MerchantRemotes","PurchaseMerchantItem"},
    Settings = {"RemoteEvents","SettingsToggle"},
    QuestRepeat = {"RemoteEvents","QuestRepeat"},
    SummonBoss = {"Remotes","RequestSummonBoss"},
    AnosBoss = {"Remotes","RequestSpawnAnosBoss"},
    StrongestBoss = {"Remotes","RequestSpawnStrongestBoss"},
    AutoSpawnBoss = {"Remotes","RequestAutoSpawn"},
    AutoSpawnAnos = {"Remotes","RequestAutoSpawnAnos"},
    AutoSpawnStrongest = {"Remotes","RequestAutoSpawnStrongest"},
    SlimeCraft = {"Remotes","RequestSlimeCraft"},
    RimuruSpawn = {"RemoteEvents","RequestSpawnRimuru"},
    AutoSpawnRimuru = {"RemoteEvents","RequestAutoSpawnRimuru"},
    TrueAizenSpawn = {"RemoteEvents","RequestSpawnTrueAizen"},
    AutoSpawnTrueAizen = {"RemoteEvents","RequestAutoSpawnTrueAizen"},
    DungeonVote = {"Remotes","DungeonWaveVote"},
    DungeonPortal = {"Remotes","RequestDungeonPortal"},
}

--==================================================
-- F = USER CONFIGURATION
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
    TrueAizenDiff = "Normal",
    StrongestHistoryDiff = "Normal",
    AutoChest = false,
    FarmMode = "Behind",
    BossRushFarmMode = "Behind",
    BossRushMoveMode = "Teleport",
    MoveMode = "Tween",
    OffsetDist = 15,
    AutoMerchant = false,
    MerchNotify = true,
    DungeonQuest = false,
    HogyokuQuest = false,
    DungeonType = "Rune",
    BossNotify = true,
    DodgeMode = true,
    FollowStyle = "Dodge"
}

--==================================================
-- S TABLE EXTENSION
--==================================================
S.Islands = {
    {Portal="Starter", FarmUntil=250, Enemies={"Thief"}, QuestNPC="QuestNPC1"},
    {Portal="Jungle", FarmUntil=750, Enemies={"Monkey"}, QuestNPC="QuestNPC3"},
    {Portal="Desert", FarmUntil=1500, Enemies={"DesertBandit"}, QuestNPC="QuestNPC5"},
    {Portal="Snow", FarmUntil=3000, Enemies={"Swordsman","FrostRogue"}, QuestNPC="QuestNPC7"},
    {Portal="Shibuya", FarmUntil=5000, Enemies={"Sorcerer","Curse"}, QuestNPC="QuestNPC9"},
    {Portal="HuecoMundo", FarmUntil=6250, Enemies={"Hollow","Quincy"}, QuestNPC="QuestNPC11"},
    {Portal="Shinjuku", FarmUntil=8000, Enemies={"StrongSorcerer"}, QuestNPC="QuestNPC12"},
    {Portal="Slime", FarmUntil=9000, Enemies={"Slime"}, QuestNPC="QuestNPC14"},
    {Portal="Academy", FarmUntil=10000, Enemies={"AcademyTeacher"}, QuestNPC="QuestNPC15"},
    {Portal="Judgement", FarmUntil=10750, Enemies={"Swordsman"}, QuestNPC="QuestNPC16"},
    {Portal="SoulSociety", FarmUntil=999999, Enemies={"Quincy1","Quincy2","Quincy3","Quincy4","Quincy5"}, QuestNPC="QuestNPC17"},
}

S.TpIslands = {"Starter","Jungle","Desert","Snow","Sailor","Shibuya","HuecoMundo","Boss","Dungeon","Shinjuku","Slime","Academy","Judgement","SoulSociety"}

S.PortalDisplayNames = {
    HuecoMundo = "Hueco Mundo",
    SoulSociety = "Soul Society"
}

S.Bosses = {
    {Name="AizenBoss", Display="Aizen", Island="HuecoMundo"},
    {Name="AlucardBoss", Display="Alucard", Island="Sailor"},
    {Name="GojoBoss", Display="Gojo", Island="Shibuya", RenderNear="YujiBoss"},
    {Name="JinwooBoss", Display="Jinwoo", Island="Sailor"},
    {Name="SukunaBoss", Display="Sukuna", Island="Shibuya"},
    {Name="YamatoBoss", Display="Yamato", Island="Judgement"},
    {Name="YujiBoss", Display="Yuji", Island="Shibuya"},
}

S.SummonBosses = {
    {Name="IchigoBoss", Display="Ichigo"},
    {Name="QinShiBoss", Display="Qin Shi"},
    {Name="SaberBoss", Display="Saber"},
    {Name="AnosBoss", Display="Anos", Island="Academy", Difficulties={"Normal","Medium","Hard","Extreme"}},
    {Name="BlessedMaidenBoss", Display="Blessed Maiden", Difficulties={"Normal","Medium","Hard","Extreme"}},
    {Name="GilgameshBoss", Display="Gilgamesh", Difficulties={"Normal","Medium","Hard","Extreme"}},
    {Name="RimuruBoss", Display="Rimuru", Island="Slime", Difficulties={"Normal","Medium","Hard","Extreme"}},
    {Name="SaberAlterBoss", Display="Saber Alter", Difficulties={"Normal","Medium","Hard","Extreme"}},
    {Name="StrongestHistoryBoss", Display="Strongest in History", Island="Shinjuku", Difficulties={"Normal","Medium","Hard","Extreme"}},
    {Name="StrongestTodayBoss", Display="Strongest Today", Island="Shinjuku", Difficulties={"Normal","Medium","Hard","Extreme"}},
    {Name="TrueAizenBoss", Display="True Aizen", Island="SoulSociety", Difficulties={"Normal","Medium","Hard","Extreme"}},
}

S.DungeonEnemyNames = {"DungeonNPC1","DungeonNPC2","DungeonNPC3","DungeonNPC4","DungeonNPC5"}
S.DungeonEnemySet = {}
for _,n in ipairs(S.DungeonEnemyNames) do S.DungeonEnemySet[(n or ""):lower()] = true end

S.DungeonTypes = {"Double","Rune","Cid"}
S.DungeonBossMap = {Rune={}, Cid={["shadowboss"]=true}, Double={["shadowmonarchboss"]=true}}
S.DungeonDifficulties = {"Easy","Normal","Hard","Extreme"}
S.DungeonPortalNames = {Double="DoubleDungeon", Rune="RuneDungeon", Cid="CidDungeon"}

S.AutoJoinDungeon = {}
S.AutoJoinFired = {}
S.AutoJoinBossRush = false
S.AutoJoinBossRushFired = false

S.IgnoreList = {"groupreward","katana","buyer","madoka","training","dummy","merchant","shop","vendor","shadow questline","shadowmonarch","obshakilsinhead","buff","questnpc"}
S.ChestNames = {"Common Chest","Rare Chest","Epic Chest","Legendary Chest","Mythical Chest"}
S.MerchantItems = {"Boss Key","Clan Reroll","Dungeon Key","Haki Color Reroll","Race Reroll","Rush Key","Trait Reroll"}

S.BossIsland = {}
S.AllBossNames = {}
S.BossDisplay = {}
S.BossRenderNear = {}

for _,b in ipairs(S.Bosses) do 
    S.BossIsland[b.Name] = b.Island 
    S.AllBossNames[b.Name] = true 
    S.BossDisplay[b.Name] = b.Display 
    if b.RenderNear then 
        S.BossRenderNear[b.Name] = b.RenderNear 
    end 
end

S.BossSharedSpawn = {AlucardBoss="Sailor_Shared", JinwooBoss="Sailor_Shared"}
S.BF = {}
for _,b in ipairs(S.Bosses) do S.BF[b.Name] = false end

S.BSF = {}
S.BSFToggle = {}
for _,b in ipairs(S.SummonBosses) do S.BSF[b.Name] = false end

S.SummonBossDisplay = {}
for _,b in ipairs(S.SummonBosses) do S.SummonBossDisplay[b.Name] = b.Display end

S.FM = {}
for _,item in ipairs(S.MerchantItems) do S.FM[item] = false end

S.FC = {}
for _,chest in ipairs(S.ChestNames) do S.FC[chest] = true end

-- Boss Rush Enemy Set
do
    local allBR = {}
    for _,b in ipairs(S.Bosses) do allBR[b.Name:lower()] = true end
    for _,b in ipairs(S.SummonBosses) do allBR[b.Name:lower()] = true end
    allBR["ragnaboss"] = true
    allBR["trueaizenboss"] = true
    allBR["madokaboss"] = true
    allBR["escanorboss"] = true
    allBR["strongestoftoday"] = true
    allBR["strongestinhistory"] = true
    allBR["strongesttoday"] = true
    allBR["strongesthistory"] = true
    S.BossRushEnemySet = allBR
end

S.Kills = 0
S.BossKills = 0
S.FarmToggle = nil
S.BossToggle = nil
S.FarmKeybind = nil
S.BossKeybind = nil
S.SummonBossKeybind = nil
S.AllSkillsKeybind = nil
S.SkillToggles = {}
S.SkillKeys = {"SkillZ","SkillX","SkillC","SkillV","SkillF"}
S.AllSkillsToggle = nil
S.Running = true
S.CurIsland = nil
S.CurTarget = nil
S.Conns = {}
S.LastEquip = 0
S.LastTP = 0
S.LastEnemy = 0
S.LastSkill = 0
S.LastChest = 0
S.LastQuestAccept = 0
S.LastMerchant = 0
S.LastCanCollide = 0
S.CachedAbilityRemote = nil
S.TPCount = 0
S.TPReset = tick()
S.KillCount = 0
S.ConfLevel = 0
S.LastLevelScanTick = 0
S.ATween = nil
S.ATweenConn = nil
S.TweenOn = false
S.TweenTarget = nil
S.HumCache = setmetatable({},{__mode="k"})
S.CharHum = nil
S.CachedQuestAbandon = nil
S.CachedUseItem = nil
S.IslandTPd = false
S.SpawnDone = false
S.FarmOrigin = nil
S.FarmGenericMode = false
S.LockTarget = nil
S.HoverPos = nil
S.QState = "NONE"
S.BossFight = false
S.BossTargetName = nil
S.BossDeathTimes = {}
S.BossInfoP = nil
S.BossTimerCache = {}
S.BossTPDone = false
S.LastBossTP = 0
S.BossTPRetries = 0
S.BossCurrentIsland = nil
S.BossPosCache = {}
S.SummonBossFight = false
S.SummonBossTarget = nil
S.SummonBossTPDone = false
S.LastSummonBossTP = 0
S.SummonBossCommitted = {}
S.SummonBossCurrentIsland = nil
S.SummonBossOrder = 0
S.SummonBossFailCount = {}
S.SummonBossFireTime = {}
S.SummonBossLockedDiff = {}
S.AutoSpawnActive = {}
S.DungeonStep = 0
S.DungeonCollected = {}
S.NoclipActive = false
S.LastDungeonSwitch = 0
S.BossRushAutoToggle = nil
S.LastBossRushSwitch = 0
S.LastDungeonVote = 0
S.LastPlankDamp = 0
S.DungeonPieceIslands = {"Starter","Jungle","Desert","Snow","Shibuya","HuecoMundo"}
S.HogyokuStep = 0
S.HogyokuCollected = {}
S.HogyokuFragmentIslands = {"Snow","Shibuya","HuecoMundo","Shinjuku","Slime","Judgement"}
S.LastSmoothMove = 0
S.RayParams = RaycastParams.new()
S.RayParams.FilterType = Enum.RaycastFilterType.Exclude
S.OverlapParams = OverlapParams.new()
S.OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
S.RayFilterChar = nil
S.NoclipParts = {}
S.NoclipChar = nil
S.DungeonWSCache = false
S.DungeonWSCacheTick = 0
S.SmoothY = nil
S.LastAbilityFire = 0
S.LastDodge = 0
S.DodgeDir = 1
S.SummonBossIslandMap = {}
for _,b in ipairs(S.SummonBosses) do S.SummonBossIslandMap[b.Name] = b.Island or S.BOSS_ISLAND_PORTAL end

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
    Subtext = "Premium Edition v1.0",
    Version = "v1.0",
    VersionIcon = "anchor",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Config",
    IntroEnabled = true,
    IntroText = "Sailor Piece",
    IntroIcon = S.ICON,
    Icon = S.ICON,
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
-- FN = FUNCTIONS
--==================================================
local fn = {}

fn.PortalDisplayName = function(p) return S.PortalDisplayNames[p] or p end

fn.Conn = function(c) table.insert(S.Conns,c) return c end

fn.Typing = function() return UserInputService:GetFocusedTextBox() ~= nil end

fn.Jit = function(b,v) return b+(math.random()*v*2-v) end

fn.StopTw = function() 
    if S.ATweenConn then 
        pcall(function() S.ATweenConn:Disconnect() end) 
        S.ATweenConn = nil 
    end 
    if S.ATween then 
        pcall(function() S.ATween:Cancel() end) 
        S.ATween = nil 
    end 
    S.TweenOn = false 
    S.TweenTarget = nil 
end

fn.DarkenColor = function(c,f) f = f or 0.55 return Color3.new(math.max(0,c.R*f),math.max(0,c.G*f),math.max(0,c.B*f)) end

fn.BrightenColor = function(c,f) f = f or 1.5 return Color3.new(math.min(1,c.R*f),math.min(1,c.G*f),math.min(1,c.B*f)) end

fn.ClearTgt = function() 
    S.CurTarget = nil 
    S.LockTarget = nil 
    S.SmoothY = nil 
    fn.StopTw() 
end

fn.GetHum = function(e)
    if not e then return nil end
    local cached = S.HumCache[e]
    if cached then
        local ok,alive = pcall(function() return cached.Parent~=nil end)
        if ok and alive then return cached end
        S.HumCache[e] = nil
    end
    local h = e:FindFirstChildOfClass("Humanoid")
    if not h then 
        for _,d in ipairs(e:GetDescendants()) do 
            if d:IsA("Humanoid") then h = d break end 
        end 
    end
    if h then S.HumCache[e] = h end
    return h
end

fn.Root = function(e)
    if not e then return nil end
    local h = fn.GetHum(e)
    if h then 
        local rp 
        pcall(function() rp = h.RootPart end) 
        if rp and rp:IsA("BasePart") then return rp end 
    end
    for _,n in ipairs({"HumanoidRootPart","Torso","UpperTorso"}) do 
        local r = e:FindFirstChild(n) 
        if r and r:IsA("BasePart") then return r end 
    end
    for _,d in ipairs(e:GetDescendants()) do 
        if(d.Name=="HumanoidRootPart" or d.Name=="Torso" or d.Name=="UpperTorso") and d:IsA("BasePart") then return d end 
    end
    if e:IsA("Model") and e.PrimaryPart then return e.PrimaryPart end
    for _,d in ipairs(e:GetDescendants()) do 
        if d:IsA("BasePart") then return d end 
    end
    return nil
end

fn.ModelPos = function(e)
    if not e then return nil end
    local r = fn.Root(e) if r then return r.Position end
    local ok,cf = pcall(function() return e:GetPivot() end) if ok and cf then return cf.Position end
    if e:IsA("Model") then 
        local ok2,bb = pcall(function() return e:GetBoundingBox() end) 
        if ok2 and bb then return bb.Position end 
    end
    return nil
end

fn.ModelCF = function(e)
    if not e then return nil end
    local r = fn.Root(e) if r then return r.CFrame end
    local ok,cf = pcall(function() return e:GetPivot() end) if ok and cf then return cf end
    return nil
end

fn.PlayerHRP = function() 
    local c = Player.Character 
    return c and c:FindFirstChild("HumanoidRootPart") 
end

fn.DistTo = function(pos) 
    if not pos then return 99999 end 
    local hrp = fn.PlayerHRP() 
    if not hrp then return 99999 end 
    return (hrp.Position-pos).Magnitude 
end

fn.IsAnosModel = function(name) return name and name:find("AnosBoss") ~= nil end

fn.IsRimuruModel = function(name) return name and (name:find("RimuruBoss")~=nil or name:find("Rimuru")~=nil) end

fn.IsStrongestTodayModel = function(name) return name and name:find("StrongestofTodayBoss")~=nil end

fn.IsStrongestHistoryModel = function(name) return name and name:find("StrongestinHistoryBoss")~=nil end

fn.IsTrueAizenModel = function(name) return name and name:find("TrueAizenBoss")~=nil end

fn.IsStrongestModel = function(name) return fn.IsStrongestTodayModel(name) or fn.IsStrongestHistoryModel(name) end

fn.IsBoss = function(n) return S.AllBossNames[n]==true or fn.IsAnosModel(n) or fn.IsRimuruModel(n) or fn.IsStrongestModel(n) end

fn.GetBossIsland = function(name) 
    if S.BossIsland[name] then return S.BossIsland[name] end 
    if fn.IsAnosModel(name) then return S.ANOS_ISLAND end 
    return nil 
end

fn.GetBossDisplay = function(name) 
    if S.BossDisplay[name] then return S.BossDisplay[name] end 
    if fn.IsAnosModel(name) then 
        local diff = name:match("AnosBoss_(.+)") 
        if diff then return "Anos ("..diff..")" end 
        return "Anos" 
    end 
    return name 
end

fn.WalkPathWait = function(base,t,...)
    local cur = base
    for _,seg in ipairs({...}) do
        if not cur then return nil end
        cur = cur:WaitForChild(seg,t)
    end
    return cur
end

fn.GetLevel = function()
    local lv = 0
    pcall(function() 
        local ls = Player:FindFirstChild("leaderstats") 
        if ls then 
            local v = ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl") or ls:FindFirstChild("LVL") 
            if v then lv = tonumber(v.Value) or 0 end 
        end 
    end)
    if lv>0 then 
        S.ConfLevel = lv 
        S.LastLevelScanTick = tick() 
        return lv 
    end
    if S.ConfLevel>0 and tick()-S.LastLevelScanTick<3 then return S.ConfLevel end
    S.LastLevelScanTick = tick()
    pcall(function() 
        for _,c in ipairs(Player:GetDescendants()) do 
            if(c:IsA("IntValue") or c:IsA("NumberValue") or c:IsA("StringValue")) then
                local n = c.Name:lower() 
                if n=="level" or n=="lvl" or n:find("level",1,true) or n:find("lvl",1,true) then 
                    local val = tonumber(c.Value) 
                    if val and val>lv then lv = val end 
                end 
            end 
        end 
    end)
    if lv>0 then S.ConfLevel = lv return lv end
    pcall(function() 
        local pg = Player:FindFirstChild("PlayerGui") 
        if pg then 
            for _,d in ipairs(pg:GetDescendants()) do 
                if d:IsA("TextLabel") or d:IsA("TextButton") then 
                    local m = (d.Text or ""):match("Lv%.%s*(%d[%d,%.]*)" ) 
                    if m then 
                        m = m:gsub(",","") 
                        local val = tonumber(m) 
                        if val and val>lv then lv = val end 
                    end 
                end 
            end 
        end 
    end)
    if lv>0 then S.ConfLevel = lv return lv end
    return S.ConfLevel
end

fn.IslandForLevel = function(lvl) 
    for _,i in ipairs(S.Islands) do 
        if lvl < i.FarmUntil then return i end 
    end 
    return S.Islands[#S.Islands] 
end

fn.IslandByName = function(n) 
    for _,i in ipairs(S.Islands) do 
        if i.Portal == n then return i end 
    end 
    return nil 
end

fn.GetFarmIsland = function()
    local lvl = fn.GetLevel()
    if lvl==0 then
        task.wait(0.5) lvl = fn.GetLevel()
        if lvl==0 then task.wait(1) lvl = fn.GetLevel() end
        if lvl==0 then return nil end
    end
    if F.SelectedIsland == "Auto" then return fn.IslandForLevel(lvl) end
    return fn.IslandByName(F.SelectedIsland) or fn.IslandForLevel(lvl)
end

fn.IsAlive = function() 
    local c = Player.Character 
    if not c then return false end 
    local h = c:FindFirstChild("HumanoidRootPart") 
    local hm = c:FindFirstChildOfClass("Humanoid") 
    return h ~= nil and hm ~= nil and hm.Health>0 
end

fn.WaitChar = function() 
    if fn.IsAlive() then return true end 
    local t = tick() 
    while tick()-t<20 do 
        if fn.IsAlive() then 
            task.wait(0.5) 
            return true 
        end 
        task.wait(0.15) 
    end 
    return false 
end

fn.IsPlayer = function(m) 
    for _,p in ipairs(Players:GetPlayers()) do 
        if p.Character == m then return true end 
    end 
    return false 
end

fn.ShouldIgnore = function(n) 
    local lo = n:lower() 
    for _,ig in ipairs(S.IgnoreList) do 
        if lo:find(ig,1,true) then return true end 
    end 
    if lo:match("boss$") then return true end 
    return false 
end

fn.MatchEnemy = function(name,island)
    if not island then return false end
    local lo = (name or ""):lower()
    local loNorm = lo:gsub("[%s%p_]","")
    for _,e in ipairs(island.Enemies) do
        local el = (e or ""):lower()
        local elNorm = el:gsub("[%s%p_]","")
        if lo:sub(1,#el)==el then return true end
        if elNorm~="" and loNorm:sub(1,#elNorm)==elNorm then return true end
    end
    return false
end

fn.AbandonAllQuests = function()
    S.QState = "NONE"
    if not S.CachedQuestAbandon then
        pcall(function()
            local f = ReplicatedStorage:FindFirstChild(S.QuestAbandon[1])
            if f then S.CachedQuestAbandon = f:FindFirstChild(S.QuestAbandon[2]) end
        end)
        if not S.CachedQuestAbandon then 
            pcall(function() S.CachedQuestAbandon = fn.WalkPathWait(ReplicatedStorage,1,unpack(S.QuestAbandon)) end) 
        end
    end
    local ab = S.CachedQuestAbandon
    if ab then
        pcall(function() ab:FireServer("repeatable") end)
        pcall(function() ab:FireServer() end)
        for _,n in ipairs({"HogyokuUnlock","HogyokuQuestNPC","Hogyoku","HogyokuFragment","HogyokuQuest","SoulSocietyUnlock","SoulSociety"}) do 
            pcall(function() ab:FireServer(n) end) 
        end
        for _,isl in ipairs(S.Islands) do 
            pcall(function() ab:FireServer(isl.QuestNPC) end) 
        end
    end
end

fn.FullReset = function()
    fn.RestoreWalkSpeed()
    fn.StopTw() 
    fn.ClearTgt() 
    S.HoverPos = nil 
    S.LockTarget = nil 
    S.CurIsland = nil 
    S.IslandTPd = false 
    S.SpawnDone = false 
    S.FarmOrigin = nil 
    S.LastEnemy = 0 
    S.LastTP = 0 
    S.TPCount = 0
    S.FarmGenericMode = false
    fn.AbandonAllQuests()
    S.LastQuestAccept = 0 
    S.BossTargetName = nil 
    S.BossFight = false 
    S.BossTPDone = false 
    S.LastBossTP = 0 
    S.BossTPRetries = 0 
    S.BossCurrentIsland = nil
    S.SummonBossFight = false 
    S.SummonBossTarget = nil 
    S.SummonBossTPDone = false 
    S.LastSummonBossTP = 0 
    S.SummonBossCommitted = {} 
    S.SummonBossCurrentIsland = nil 
    S.SummonBossOrder = 0 
    S.SummonBossFailCount = {} 
    S.SummonBossLockedDiff = {}
    S.HogyokuStep = 0 
    S.HogyokuCollected = {}
    pcall(function() 
        local c = Player.Character 
        if c then 
            local hm = c:FindFirstChildOfClass("Humanoid") 
            if hm then hm.PlatformStand = false end 
        end 
    end)
end

fn.DoTP = function(portal)
    if tick()-S.LastTP<3 then return false end
    if tick()-S.TPReset>120 then S.TPCount = 0 S.TPReset = tick() end
    if S.TPCount>=10 then return false end
    S.LastTP = tick() 
    S.TPCount = S.TPCount+1
    local ok = false
    pcall(function() 
        fn.WalkPathWait(ReplicatedStorage,3,unpack(S.TP)):FireServer(portal) 
        ok = true 
    end)
    return ok
end

fn.ForceTP = function(portal)
    S.LastTP = 0 
    S.TPCount = 0 
    S.TPReset = tick()
    S.HoverPos = nil 
    S.LockTarget = nil
    fn.StopTw()
    local ok = false
    pcall(function() 
        fn.WalkPathWait(ReplicatedStorage,5,unpack(S.TP)):FireServer(portal) 
        ok = true 
    end)
    if not ok then
        task.wait(1)
        pcall(function() 
            fn.WalkPathWait(ReplicatedStorage,5,unpack(S.TP)):FireServer(portal) 
            ok = true 
        end)
    end
    S.LastTP = tick() 
    S.TPCount = 1
    return ok
end

fn.EnableGameQuestRepeat = function()
    pcall(function()
        local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.Settings))
        if not r then return end
        r:FireServer("EnableQuestRepeat",true)
        task.wait(0.05)
        r:FireServer("AutoQuestRepeat",true)
    end)
end

fn.QuestAccept = function(island) 
    if not island or not island.QuestNPC then return end 
    pcall(function() 
        fn.WalkPathWait(ReplicatedStorage,3,unpack(S.QuestAccept)):FireServer(island.QuestNPC) 
    end) 
    S.LastQuestAccept = tick() 
    S.QState = "ACTIVE" 
    task.spawn(fn.EnableGameQuestRepeat) 
end

fn.QuestRepeatFire = function(island) 
    if not island or not island.QuestNPC then return end 
    pcall(function() 
        fn.WalkPathWait(ReplicatedStorage,3,unpack(S.QuestRepeat)):FireServer(island.QuestNPC) 
    end) 
    S.LastQuestAccept = tick() 
    S.QState = "ACTIVE" 
end

fn.QuestAbandon = function() fn.AbandonAllQuests() end

fn.QuestCompletionScan = function()
    if S.QState~="ACTIVE" then return end
    if tick()-S.LastQuestAccept>60 then S.QState = "NONE" return end
    if tick()-S.LastQuestAccept<8 then return end
    local pg = Player:FindFirstChild("PlayerGui") if not pg then return end
    local hasQuestUI = false
    for _,d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local t = (d.Text or ""):lower()
            if t:find("quest complet") or t:find("abandon") then S.QState = "NONE" return end
            if t:find("%d+%s*/%s*%d+") or t:find("kill") or t:find("collect") or t:find("objective") or t:find("quest") then hasQuestUI = true end
        end
    end
    if not hasQuestUI and tick()-S.LastQuestAccept>20 then S.QState = "NONE" end
end

fn.ClickYes = function()
    local pg = Player:FindFirstChild("PlayerGui") if not pg then return end
    for _,desc in ipairs(pg:GetDescendants()) do
        if desc:IsA("TextButton") or desc:IsA("ImageButton") then
            local txt = "" pcall(function() txt = (desc.Text or ""):lower() end)
            local nm = (desc.Name or ""):lower()
            if txt=="yes" or nm=="yes" or nm=="confirm" or txt=="confirm" then
                pcall(function() 
                    for _,conn in ipairs(getconnections(desc.Activated)) do conn:Fire() end 
                end)
                pcall(function() 
                    for _,conn in ipairs(getconnections(desc.MouseButton1Click)) do conn:Fire() end 
                end)
            end
        end
    end
end

fn.PlayerHasChest = function(name)
    local found = Player:FindFirstChild(name,true)
    if not found then return false end
    if found:IsA("IntValue") or found:IsA("NumberValue") then return (tonumber(found.Value) or 0)>0 end
    return true
end

fn.SafeInvoke = function(remote,timeout,...)
    local args = {...}
    local done,ok,result = false,false,nil
    task.spawn(function()
        local s,r = pcall(function() return remote:InvokeServer(table.unpack(args)) end)
        ok,result,done = s,r,true
    end)
    local t = tick()
    while not done and tick()-t<(timeout or 3) do task.wait(0.05) end
    return ok,result
end

fn.SuppressHasItemError = function()
    pcall(function()
        local pg = Player:FindFirstChild("PlayerGui") if not pg then return end
        for _,d in ipairs(pg:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local txt = (d.Text or ""):lower()
                if (txt:find("don") or txt:find("doesn")) and txt:find("have") then
                    local p = d while p and not p:IsA("ScreenGui") do p = p.Parent end
                    if p then pcall(function() p.Enabled = false end) end
                    pcall(function() d.Visible = false end)
                end
            end
        end
    end)
end

fn.OpenAllChests = function()
    if not F.AutoChest then return end
    if not S.CachedUseItem then
        pcall(function()
            local f = ReplicatedStorage:FindFirstChild(S.UseItem[1])
            if f then S.CachedUseItem = f:FindFirstChild(S.UseItem[2]) end
        end)
        if not S.CachedUseItem then 
            pcall(function() S.CachedUseItem = fn.WalkPathWait(ReplicatedStorage,1,unpack(S.UseItem)) end) 
        end
    end
    local useItem = S.CachedUseItem
    if not useItem then return end
    local isEvent = false 
    pcall(function() isEvent = useItem:IsA("RemoteEvent") end)
    local startIdx = S.ChestIndex or 0
    local found = false
    for i=1,#S.ChestNames do
        local idx = (startIdx+i-1)%#S.ChestNames+1
        if S.FC[S.ChestNames[idx]] then
            S.ChestIndex = idx
            found = true
            break
        end
    end
    if not found then return end
    local name = S.ChestNames[S.ChestIndex]
    if isEvent then
        pcall(function() useItem:FireServer("Use",name,999,false) end)
    else
        fn.SafeInvoke(useItem,0.5,"Use",name,999,false)
    end
    task.wait(0.2)
    fn.ClickYes()
    fn.SuppressHasItemError()
end

fn.BuyMerchantItems = function()
    if not F.AutoMerchant then return end
    if tick()-S.LastMerchant<1800 then return end
    S.LastMerchant = tick()
    local remote
    pcall(function() remote = fn.WalkPathWait(ReplicatedStorage,2,unpack(S.Merchant)) end)
    if not remote then return end
    for _,item in ipairs(S.MerchantItems) do
        if S.FM[item] then
            for _=1,15 do
                local ok,result = fn.SafeInvoke(remote,0.75,item,1)
                if not ok or result==false then break end
                if type(result)=="table" and result.success==false then break end
                if F.MerchNotify then
                    Notify("Purchased "..item)
                end
                task.wait(0.05)
            end
        end
    end
end

fn.SpawnCrystal = function(island)
    if not island or not F.AutoSpawn then return end
    local cn = "SpawnPointCrystal_"..island.Portal
    for _,desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name==cn then
            local pr
            if desc:IsA("Model") then 
                for _,ch in ipairs(desc:GetDescendants()) do 
                    if ch:IsA("ProximityPrompt") then pr = ch break end 
                end
            elseif desc:IsA("BasePart") then 
                pr = desc:FindFirstChildOfClass("ProximityPrompt") 
                if not pr and desc.Parent then 
                    for _,ch in ipairs(desc.Parent:GetDescendants()) do 
                        if ch:IsA("ProximityPrompt") then pr = ch break end 
                    end 
                end 
            end
            if pr then
                local hrp = fn.PlayerHRP()
                local cp
                if desc:IsA("BasePart") then cp = desc.Position 
                elseif desc:IsA("Model") then 
                    local pm = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart") 
                    if pm then cp = pm.Position end 
                end
                if hrp and cp then 
                    if (hrp.Position-cp).Magnitude>15 then 
                        hrp.CFrame = CFrame.new(cp+Vector3.new(0,3,3)) 
                        task.wait(0.2) 
                    end 
                    pcall(function() fireproximityprompt(pr) end) 
                    task.wait(0.2) 
                    pcall(function() fireproximityprompt(pr) end) 
                end
                return
            end
        end
    end
end

fn.GetNPCFolder = function()
    local direct = Workspace:FindFirstChild(S.NPC_FOLDER)
    if direct then return direct end
    for _,desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("Folder") then
            local n = (desc.Name or ""):lower()
            if n=="npcs" or n=="npc" or n:find("npc",1,true) then
                return desc
            end
        end
    end
    return nil
end

fn.FindEnemies = function(island)
    local nf = fn.GetNPCFolder()
    if not island then return {} end
    local hrp = fn.PlayerHRP()
    local origin = S.FarmOrigin
    local out = {}
    local function checkModel(m)
        if m:IsA("Model") and not fn.IsPlayer(m) and not fn.IsBoss(m.Name) then
            local hm = fn.GetHum(m)
            if hm and hm.Health>0 and not fn.ShouldIgnore(m.Name) then
                if fn.MatchEnemy(m.Name,island) then
                    local p = fn.ModelPos(m)
                    if p then
                        if hrp and (p-hrp.Position).Magnitude>S.FARM_MAX_DIST_FROM_PLAYER then return end
                        if origin and (p-origin).Magnitude>S.FARM_MAX_DIST_FROM_ORIGIN then return end
                    end
                    table.insert(out,m)
                end
            end
        end
    end
    if nf then
        for _,desc in ipairs(nf:GetChildren()) do
            if desc:IsA("Model") then checkModel(desc)
            elseif desc:IsA("Folder") then 
                for _,m in ipairs(desc:GetChildren()) do 
                    if m:IsA("Model") then checkModel(m) end 
                end 
            end
        end
    else
        for _,desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") then checkModel(desc) end
        end
    end
    return out
end

fn.FindGenericHostiles = function(maxDist)
    local hrp = fn.PlayerHRP()
    if not hrp then return {} end
    local origin = S.FarmOrigin
    local maxD = maxDist or S.GENERIC_HOSTILE_MAX_DIST
    local out = {}
    local function isIgnoredName(n)
        local lo = (n or ""):lower()
        if S.DungeonEnemySet[lo] then return false end
        return lo:find("quest",1,true) or lo:find("npc",1,true) or lo:find("merchant",1,true) or lo:find("shop",1,true) or lo:find("vendor",1,true) or lo:find("dummy",1,true) or lo:find("training",1,true)
    end
    local function addIfHostile(m)
        if not m:IsA("Model") then return end
        if fn.IsPlayer(m) then return end
        if isIgnoredName(m.Name) then return end
        local hm = fn.GetHum(m)
        if not hm or hm.Health<=0 then return end
        local p = fn.ModelPos(m)
        if not p then return end
        if (p-hrp.Position).Magnitude>maxD then return end
        if origin and (p-origin).Magnitude>S.FARM_MAX_DIST_FROM_ORIGIN then return end
        table.insert(out,m)
    end
    local nf = fn.GetNPCFolder()
    if nf then
        for _,desc in ipairs(nf:GetChildren()) do
            if desc:IsA("Model") then addIfHostile(desc)
            elseif desc:IsA("Folder") then 
                for _,m in ipairs(desc:GetChildren()) do 
                    if m:IsA("Model") then addIfHostile(m) end 
                end 
            end
        end
    end
    if #out==0 then
        for _,desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") then addIfHostile(desc) end
        end
    end
    return out
end

fn.FindDungeonEnemiesKnown = function(maxDist)
    local hrp = fn.PlayerHRP()
    if not hrp then return {} end
    local maxD = maxDist or S.GENERIC_HOSTILE_MAX_DIST
    local myY = hrp.Position.Y
    local out = {}
    local function isDungeonBossLike(m)
        local name = (m and m.Name) or ""
        local lo = name:lower()
        if not lo:find("boss",1,true) then return false end
        if fn.IsBoss(name) then return false end
        if fn.IsBossRushEnemy(m) then return false end
        if lo:find("quest",1,true) or lo:find("merchant",1,true) or lo:find("shop",1,true) or lo:find("vendor",1,true) or lo:find("dummy",1,true) or lo:find("training",1,true) then return false end
        local hm = fn.GetHum(m)
        if not hm or hm.Health<=0 then return false end
        local rp = fn.Root(m)
        if not rp then return false end
        local moving = (rp.AssemblyLinearVelocity.Magnitude>0.5)
        local md
        pcall(function() md = hm.MoveDirection end)
        if md and md.Magnitude>0.05 then moving = true end
        local ws = 0
        pcall(function() ws = hm.WalkSpeed or 0 end)
        if ws>0 then moving = true end
        return moving
    end
    local function isKnownDungeonName(n)
        local lo = (n or ""):lower()
        if S.DungeonEnemySet[lo] then return true end
        for _,base in ipairs(S.DungeonEnemyNames) do
            local bl = (base or ""):lower()
            if lo:sub(1,#bl)==bl then return true end
        end
        return false
    end
    local function addIfMatch(m)
        if not m:IsA("Model") then return end
        if fn.IsPlayer(m) then return end
        if not isKnownDungeonName(m.Name) and not isDungeonBossLike(m) then return end
        local hm = fn.GetHum(m)
        if not hm or hm.Health<=0 then return end
        local p = fn.ModelPos(m)
        if not p then return end
        if math.abs(p.Y-myY)>150 then return end
        if (p-hrp.Position).Magnitude>maxD then return end
        table.insert(out,m)
    end
    local nf = fn.GetNPCFolder()
    if nf then
        for _,desc in ipairs(nf:GetChildren()) do
            if desc:IsA("Model") then addIfMatch(desc)
            elseif desc:IsA("Folder") then 
                for _,m in ipairs(desc:GetChildren()) do 
                    if m:IsA("Model") then addIfMatch(m) end 
                end 
            end
        end
    end
    if #out==0 then
        for _,desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") then addIfMatch(desc) end
        end
    end
    return out
end

fn.IsKnownDungeonEnemy = function(model)
    if not model or not model:IsA("Model") then return false end
    local lo = ((model.Name or ""):lower())
    if S.DungeonEnemySet[lo] then return true end
    for _,base in ipairs(S.DungeonEnemyNames) do
        local bl = (base or ""):lower()
        if lo:sub(1,#bl)==bl then return true end
    end
    local bossMap = S.DungeonBossMap[F.DungeonType]
    if bossMap then
        if bossMap[lo] then return true end
        for name in pairs(bossMap) do 
            if lo:sub(1,#name)==name then return true end 
        end
    end
    return false
end

fn.HasDungeonEnemiesInWorkspace = function()
    if tick()-S.DungeonWSCacheTick<0.5 then return S.DungeonWSCache end
    S.DungeonWSCacheTick = tick()
    local nf = fn.GetNPCFolder()
    if nf then
        for _,m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and fn.IsKnownDungeonEnemy(m) and not fn.IsPlayer(m) then
                local hm = fn.GetHum(m) if hm and hm.Health>0 then S.DungeonWSCache = true return true end
            end
        end
    end
    S.DungeonWSCache = false
    return false
end

fn.FindEnemiesFallback = function(maxDist)
    local nf = fn.GetNPCFolder()
    if not nf then return {} end
    local hrp = fn.PlayerHRP()
    local maxD = maxDist or 1400
    local out = {}
    for _,desc in ipairs(nf:GetChildren()) do
        if desc:IsA("Model") and not fn.IsPlayer(desc) and not fn.IsBoss(desc.Name) then
            local lo = (desc.Name or ""):lower()
            if not fn.ShouldIgnore(desc.Name) and not lo:find("npc",1,true) and not lo:find("quest",1,true) and not lo:find("merchant",1,true) and not lo:find("shop",1,true) and not lo:find("vendor",1,true) then
                local hm = fn.GetHum(desc)
                if hm and hm.Health>0 then
                    local p = fn.ModelPos(desc)
                    if p and (not hrp or (p-hrp.Position).Magnitude<=maxD) then
                        table.insert(out,desc)
                    end
                end
            end
        end
    end
    return out
end

fn.NearestFrom = function(list)
    local hrp = fn.PlayerHRP() if not hrp then return nil end
    local myY = hrp.Position.Y
    local best,bd = nil,math.huge
    for _,e in ipairs(list) do 
        local p = fn.ModelPos(e) 
        if p and math.abs(p.Y-myY)<150 then 
            local d = (p-hrp.Position).Magnitude 
            if d<bd then bd = d best = e end 
        end 
    end
    return best
end

fn.FreshBoss = function(name)
    local nf = fn.GetNPCFolder() if not nf then return nil end
    for _,ch in ipairs(nf:GetChildren()) do
        if ch:IsA("Model") and ch.Name==name then 
            local hm = fn.GetHum(ch) 
            if hm and hm.Health>0 then return ch end 
        end
        if ch:IsA("Folder") then 
            for _,m in ipairs(ch:GetChildren()) do 
                if m:IsA("Model") and m.Name==name then 
                    local hm = fn.GetHum(m) 
                    if hm and hm.Health>0 then return m end 
                end 
            end 
        end
    end
    return nil
end

fn.FindAnyAnosAlive = function()
    local nf = fn.GetNPCFolder() if not nf then return nil end
    for _,ch in ipairs(nf:GetChildren()) do
        if ch:IsA("Model") and fn.IsAnosModel(ch.Name) then 
            local hm = fn.GetHum(ch) 
            if hm and hm.Health>0 then return ch end 
        end
        if ch:IsA("Folder") then 
            for _,m in ipairs(ch:GetChildren()) do 
                if m:IsA("Model") and fn.IsAnosModel(m.Name) then 
                    local hm = fn.GetHum(m) 
                    if hm and hm.Health>0 then return m end 
                end 
            end 
        end
    end
    return nil
end

fn.CheckBoss = function(name)
    local m = fn.FreshBoss(name) 
    if m then 
        local p = fn.ModelPos(m) 
        if p then S.BossPosCache[name] = p end 
        return m 
    end
    if fn.IsAnosModel(name) then 
        local a = fn.FindAnyAnosAlive() 
        if a then 
            local p = fn.ModelPos(a) 
            if p then S.BossPosCache[name] = p end 
            return a 
        end 
    end
    return nil
end

fn.CacheBossPositions = function()
    local nf = fn.GetNPCFolder() if not nf then return end
    local function cache(m)
        if m:IsA("Model") and fn.IsBoss(m.Name) then
            local p = fn.ModelPos(m)
            if p then S.BossPosCache[m.Name] = p end
        end
    end
    for _,ch in ipairs(nf:GetChildren()) do
        cache(ch)
        if ch:IsA("Folder") then 
            for _,m in ipairs(ch:GetChildren()) do cache(m) end 
        end
    end
end

fn.GetRenderPos = function(name)
    if S.BossPosCache[name] then return S.BossPosCache[name] end
    local ref = S.BossRenderNear[name]
    if ref then
        if S.BossPosCache[ref] then return S.BossPosCache[ref] end
        local nf = fn.GetNPCFolder() 
        if nf then 
            for _,m in ipairs(nf:GetChildren()) do 
                if m:IsA("Model") and m.Name==ref then 
                    local p = fn.ModelPos(m) 
                    if p then return p end 
                end 
            end 
        end
    end
    return nil
end

fn.AllBossesOnIsland = function(island)
    local nf = fn.GetNPCFolder() if not nf then return {} end
    local out = {}
    local function check(m)
        if m:IsA("Model") then
            local hm = fn.GetHum(m)
            if hm and hm.Health>0 then
                if S.AllBossNames[m.Name] and S.BF[m.Name] and S.BossIsland[m.Name]==island and not fn.IsBossOnCooldown(m.Name) then 
                    table.insert(out,m.Name) 
                end
            end
        end
    end
    for _,ch in ipairs(nf:GetChildren()) do
        check(ch)
        if ch:IsA("Folder") then 
            for _,m in ipairs(ch:GetChildren()) do check(m) end 
        end
    end
    return out
end

fn.PickNextBossName = function()
    local nf = fn.GetNPCFolder() if not nf then return nil end
    if S.BossCurrentIsland then
        local sameIsland = fn.AllBossesOnIsland(S.BossCurrentIsland)
        if #sameIsland>0 then
            local hrp = fn.PlayerHRP()
            if hrp and #sameIsland>1 then
                local cl,cd = nil,math.huge
                for _,bn in ipairs(sameIsland) do 
                    local bp = fn.ModelPos(fn.CheckBoss(bn)) 
                    if bp then 
                        local d = (hrp.Position-bp).Magnitude 
                        if d<cd then cd = d cl = bn end 
                    elseif not cl then cl = bn end 
                end
                if cl then return cl end
            end
            return sameIsland[1]
        end
    end
    local alive = {}
    local function addAlive(m)
        if m:IsA("Model") then
            local hm = fn.GetHum(m)
            if hm and hm.Health>0 then
                if S.AllBossNames[m.Name] and S.BF[m.Name] and not fn.IsBossOnCooldown(m.Name) then 
                    table.insert(alive,m.Name) 
                end
            end
        end
    end
    for _,ch in ipairs(nf:GetChildren()) do
        addAlive(ch)
        if ch:IsA("Folder") then 
            for _,m in ipairs(ch:GetChildren()) do addAlive(m) end 
        end
    end
    if #alive==0 then return nil end
    if #alive==1 then return alive[1] end
    local byIsland = {}
    for _,bn in ipairs(alive) do
        local bi = fn.GetBossIsland(bn) or "?"
        if not byIsland[bi] then byIsland[bi] = {} end
        table.insert(byIsland[bi],bn)
    end
    local bestIsland,bestCount = nil,0
    for isl,list in pairs(byIsland) do 
        if #list>bestCount then 
            bestCount = #list 
            bestIsland = isl 
        end 
    end
    if bestIsland and byIsland[bestIsland] then
        local pick = byIsland[bestIsland]
        local hrp = fn.PlayerHRP()
        if hrp and #pick>1 then
            local cl,cd = nil,math.huge
            for _,bn in ipairs(pick) do 
                local bp = fn.ModelPos(fn.CheckBoss(bn)) 
                if bp then 
                    local d = (hrp.Position-bp).Magnitude 
                    if d<cd then cd = d cl = bn end 
                elseif not cl then cl = bn end 
            end
            if cl then return cl end
        end
        return pick[1]
    end
    return alive[1]
end

fn.RecordBossDeath = function(name)
    S.BossDeathTimes[name] = tick()
    local group = S.BossSharedSpawn[name]
    if group then
        for _,b in ipairs(S.Bosses) do
            if S.BossSharedSpawn[b.Name]==group and b.Name~=name then 
                S.BossDeathTimes[b.Name] = tick() 
            end
        end
    end
end

fn.IsBossOnCooldown = function(name)
    local dt = S.BossDeathTimes[name]
    if dt and tick()-dt<30 then return true end
    local tc = S.BossTimerCache[name]
    if tc and (tick()-(tc.t or 0))<5 and not tc.alive then return true end
    return false
end

fn.ScanAllBossTimers = function()
    fn.CacheBossPositions()
    local results = {}
    local nf = fn.GetNPCFolder()
    if nf then
        for _,m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and S.AllBossNames[m.Name] and not results[m.Name] then
                local hm = fn.GetHum(m)
                if hm and hm.Health>0 then 
                    results[m.Name] = {alive=true}
                else
                    for _,d in ipairs(m:GetDescendants()) do 
                        if d:IsA("TextLabel") then 
                            local mn,sc = (d.Text or ""):match("(%d+):(%d+)") 
                            if mn and sc then 
                                results[m.Name] = {m=tonumber(mn),s=tonumber(sc)} 
                                break 
                            end 
                        end 
                    end
                    if not results[m.Name] then 
                        for _,d in ipairs(m:GetDescendants()) do 
                            if d:IsA("BillboardGui") then 
                                for _,child in ipairs(d:GetDescendants()) do 
                                    if child:IsA("TextLabel") then 
                                        local mn,sc = (child.Text or ""):match("(%d+):(%d+)") 
                                        if mn and sc then 
                                            results[m.Name] = {m=tonumber(mn),s=tonumber(sc)} 
                                            break 
                                        end 
                                    end 
                                end 
                                if results[m.Name] then break end 
                            end 
                        end 
                    end
                end
            end
        end
    end
    local pg = Player:FindFirstChild("PlayerGui")
    if pg then 
        for _,desc in ipairs(pg:GetDescendants()) do 
            if desc:IsA("TextLabel") then 
                local txt = desc.Text or "" 
                for _,bDef in ipairs(S.Bosses) do 
                    if not results[bDef.Name] then 
                        if txt:find(bDef.Display) then 
                            local mn,sc = txt:match("(%d+):(%d+)") 
                            if mn and sc then 
                                results[bDef.Name] = {m=tonumber(mn),s=tonumber(sc)} 
                            end 
                        end 
                    end 
                end 
            end 
        end 
    end
    for k,v in pairs(results) do 
        S.BossTimerCache[k] = v 
        S.BossTimerCache[k].t = tick() 
    end
    return results
end

fn.GetBossTimerText = function()
    local lines = {}
    for _,bDef in ipairs(S.Bosses) do
        local info = S.BossTimerCache[bDef.Name]
        local status = ""
        if info and(tick()-(info.t or 0))<5 then
            if info.alive then 
                status = "ALIVE"
            elseif info.m and info.s then 
                local total = info.m*60+info.s 
                if total==0 then 
                    status = "ALIVE" 
                elseif total<=15 then 
                    status = info.m..":"..string.format("%02d",info.s).." SPAWNING!" 
                else 
                    status = info.m..":"..string.format("%02d",info.s) 
                end
            else 
                status = "Loading..." 
            end
        else 
            local dt = S.BossDeathTimes[bDef.Name] 
            if dt then 
                local remain = math.max(0,300-(tick()-dt)) 
                if remain>0 then 
                    local mn = math.floor(remain/60) 
                    local sc = math.floor(remain%60) 
                    status = mn..":"..string.format("%02d",sc) 
                else 
                    status = "Ready!" 
                end 
            else 
                status = "Loading..." 
            end 
        end
        table.insert(lines,bDef.Display.." ("..bDef.Island..") - "..status)
    end
    return table.concat(lines,"\n")
end

fn.GetTool = function() 
    local c = Player.Character 
    if not c then return nil end 
    for _,ch in ipairs(c:GetChildren()) do 
        if ch:IsA("Tool") then return ch end 
    end 
    return nil 
end

fn.GetAllTools = function() 
    local c = Player.Character 
    if not c then return {} end 
    local t = {} 
    for _,ch in ipairs(c:GetChildren()) do 
        if ch:IsA("Tool") then table.insert(t,ch) end 
    end 
    return t 
end

fn.GetToolFromBackpack = function(toolType)
    local bp = Player:FindFirstChild("Backpack") if not bp then return nil end
    for _,c in ipairs(bp:GetChildren()) do
        if c:IsA("Tool") then
            local ttObj = c:FindFirstChild("ToolType")
            local tt = (ttObj and ttObj.Value) or c:GetAttribute("ToolType") or nil
            if tt and tt:lower()==toolType:lower() then return c end
            local nm = c.Name:lower()
            if toolType:lower()=="melee" and nm=="combat" then return c end
            if toolType:lower()=="sword" and nm~="combat" then return c end
        end
    end
    return nil
end

fn.EquipSword = function()
    local c = Player.Character if not c then return end
    local hm = c:FindFirstChildOfClass("Humanoid") if not hm then return end
    local bp = Player:FindFirstChild("Backpack") if not bp then return end
    local equipped = fn.GetAllTools()
    local hasSword = false
    for _,t in ipairs(equipped) do 
        if t.Name:lower()~="combat" then hasSword = true end 
    end
    if hasSword then return end
    for _,t in ipairs(equipped) do 
        if t.Name:lower()=="combat" then 
            hm:UnequipTools() 
            task.wait(0.15) 
            break 
        end 
    end
    for _,ch in ipairs(bp:GetChildren()) do 
        if ch:IsA("Tool") and ch.Name:lower()~="combat" then 
            hm:EquipTool(ch) 
            return 
        end 
    end
end

fn.EquipBothWeapons = function()
    local c = Player.Character if not c then return end
    local hm = c:FindFirstChildOfClass("Humanoid") if not hm then return end
    local bp = Player:FindFirstChild("Backpack") if not bp then return end
    local equipped = fn.GetAllTools()
    local hasMelee,hasSword = false,false
    for _,t in ipairs(equipped) do
        if t.Name:lower()=="combat" then hasMelee = true else hasSword = true end
    end
    if hasMelee and hasSword then return end
    local allTools = {}
    for _,ch in ipairs(bp:GetChildren()) do 
        if ch:IsA("Tool") then table.insert(allTools,ch) end 
    end
    for _,t in ipairs(equipped) do table.insert(allTools,t) end
    local melee,sword = nil,nil
    for _,t in ipairs(allTools) do
        if t.Name:lower()=="combat" then melee = t
        elseif not sword then sword = t end
    end
    if melee and sword then
        hm:UnequipTools() task.wait(0.1)
        local ok1 = pcall(function() melee.Parent = c end)
        local ok2 = pcall(function() sword.Parent = c end)
        if not ok1 or not ok2 then
            pcall(function() hm:EquipTool(sword) end)
            task.wait(0.05)
            pcall(function() hm:EquipTool(melee) end)
        end
    elseif sword and not melee then
        if not pcall(function() sword.Parent = c end) then 
            pcall(function() hm:EquipTool(sword) end) 
        end
    elseif melee and not sword then
        if not pcall(function() melee.Parent = c end) then 
            pcall(function() hm:EquipTool(melee) end) 
        end
    end
end

fn.GetGoalForEnemy = function(enemy)
    local pos = fn.ModelPos(enemy) if not pos then return nil,nil end
    local cf = fn.ModelCF(enemy)
    if not cf then return Vector3.new(pos.X,pos.Y,pos.Z+F.OffsetDist),pos end
    local lookFlat = Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
    if lookFlat.Magnitude>0.01 then lookFlat = lookFlat.Unit else lookFlat = Vector3.new(0,0,1) end
    local rightFlat = Vector3.new(-lookFlat.Z,0,lookFlat.X)
    local fm = F.FarmMode or "Behind"
    local primary
    if fm=="In Front" then primary = lookFlat
    elseif fm=="Left Side" then primary = rightFlat
    elseif fm=="Right Side" then primary = -rightFlat
    else primary = -lookFlat end
    local perp = Vector3.new(-primary.Z,0,primary.X)
    local dirs = {primary,perp,-perp,-primary}
    for _,dir in ipairs(dirs) do
        if dir.Magnitude>0.1 then
            dir = Vector3.new(dir.X,0,dir.Z).Unit
            local goal = pos+dir*F.OffsetDist
            local ray = Workspace:Raycast(pos,dir*F.OffsetDist,S.RayParams)
            if not ray then return Vector3.new(goal.X,pos.Y,goal.Z),pos end
        end
    end
    return Vector3.new(pos.X,pos.Y,pos.Z+2),pos
end

fn.DungeonHeight = function() return F[F.DungeonType.."Height"] or 10 end
fn.DungeonSpeed = function() return F[F.DungeonType.."Speed"] or 70 end
fn.DungeonMove = function() return F[F.DungeonType.."Move"] or "Teleport" end
fn.DungeonDiff = function() return F[F.DungeonType.."Diff"] or "Normal" end

fn.FireDungeonVote = function()
    pcall(function()
        local r = fn.WalkPathWait(ReplicatedStorage,2,unpack(S.DungeonVote))
        if r then r:FireServer(fn.DungeonDiff()) end
    end)
end

fn.FireDungeonPortal = function(dtype)
    local portalName = S.DungeonPortalNames[dtype]
    if not portalName then return false end
    local ok = false
    pcall(function()
        local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.DungeonPortal))
        if r then r:FireServer(portalName) ok = true end
    end)
    return ok
end

fn.IsInDungeon = function()
    local nf = fn.GetNPCFolder()
    if not nf then return false end
    for _,m in ipairs(nf:GetChildren()) do
        if m:IsA("Model") and fn.IsKnownDungeonEnemy(m) and not fn.IsPlayer(m) then
            local hm = fn.GetHum(m) if hm and hm.Health>0 then return true end
        end
    end
    return false
end

fn.IsInDungeonLobby = function()
    local pg = Player:FindFirstChild("PlayerGui") if not pg then return false end
    for _,d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextButton") then
            local txt = (d.Text or ""):lower()
            if txt=="leave portal" then return true end
        end
    end
    return false
end

fn.GetGoalForDungeonEnemy = function(enemy)
    local pos = fn.ModelPos(enemy) if not pos then return nil,nil end
    local targetY = pos.Y+fn.DungeonHeight()
    return Vector3.new(pos.X,targetY,pos.Z),pos
end

fn.SyncDungeonHeightNow = function() end
fn.SyncBossRushHeightNow = function() end
fn.HoldDungeonIdleHover = function() end
fn.GetGoalForBossRushEnemy = function(enemy) return fn.GetGoalForEnemy(enemy) end
fn.GetGoalForDungeonEnemy = function(enemy) return fn.GetGoalForEnemy(enemy) end

S.OrigWalkSpeed = nil

fn.SetFarmWalkSpeed = function()
    local c = Player.Character if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid") if not hum then return end
    if not S.OrigWalkSpeed then S.OrigWalkSpeed = hum.WalkSpeed end
    if F.MoveMode=="Walk" then hum.WalkSpeed = F.TweenSpeed end
end

fn.RestoreWalkSpeed = function()
    if S.OrigWalkSpeed then
        pcall(function()
            local c = Player.Character if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid") if not hum then return end
            hum.WalkSpeed = S.OrigWalkSpeed
        end)
        S.OrigWalkSpeed = nil
    end
end

fn.TweenTo = function(enemy)
    if not enemy then return end
    local effectiveStyle = (F.FarmMode=="Behind") and (F.FollowStyle or "Dodge") or "Static"
    if S.LockTarget==enemy and effectiveStyle~="Dodge" then
        local ep = fn.ModelPos(enemy)
        local hrp2 = fn.PlayerHRP()
        if ep and hrp2 then
            local dEnemy = (hrp2.Position-ep).Magnitude
            if dEnemy<=F.OffsetDist+25 then return end
            S.LockTarget = nil
        else
            return
        end
    end
    local goal,look = fn.GetGoalForEnemy(enemy) if not goal then return end
    local hrp = fn.PlayerHRP() if not hrp then return end
    local d = (hrp.Position-goal).Magnitude
    if d>600 then return end
    if d<F.OffsetDist+2 then
        S.LockTarget = enemy S.TweenOn = false S.TweenTarget = nil
        return
    end
    if F.MoveMode=="Teleport" then
        fn.StopTw()
        local hrpRef = fn.PlayerHRP()
        if hrpRef then hrpRef.CFrame = CFrame.new(goal,look or goal) end
        S.LockTarget = enemy S.TweenOn = false S.TweenTarget = nil
        return
    end
    if S.TweenOn and S.TweenTarget==enemy then return end
    fn.StopTw() S.TweenOn = true S.TweenTarget = enemy S.LockTarget = nil
    local stepDist = math.min(d,80)
    local dir = (goal-hrp.Position).Unit
    local stepGoal = hrp.Position+(dir*stepDist)
    local cf = CFrame.new(stepGoal,look or goal)
    local dur = math.clamp(stepDist/math.max(F.TweenSpeed,1),0.06,3.0)
    S.ATween = TweenService:Create(hrp,TweenInfo.new(dur,Enum.EasingStyle.Linear),{CFrame=cf})
    S.ATweenConn = S.ATween.Completed:Connect(function()
        S.ATween = nil S.ATweenConn = nil S.TweenOn = false S.TweenTarget = nil
        S.LockTarget = enemy
    end)
    S.ATween:Play()
end

fn.TweenToDungeon = function(enemy) fn.TweenTo(enemy) end
fn.TweenToBossRush = function(enemy) fn.TweenTo(enemy) end

fn.TweenToPoint = function(goal)
    local hrp = fn.PlayerHRP() if not hrp then return end
    local d = (hrp.Position-goal).Magnitude
    if d>1500 or d<5 then return end
    fn.StopTw() S.TweenOn = true S.LockTarget = nil
    local stepDist = math.min(d,120)
    local dir = (goal-hrp.Position).Unit
    local stepGoal = hrp.Position+(dir*stepDist)
    local cf = CFrame.new(stepGoal,stepGoal+Vector3.new(0,-1,0))
    local dur = math.clamp(stepDist/math.max(F.TweenSpeed,1),0.06,3.0)
    S.ATween = TweenService:Create(hrp,TweenInfo.new(dur,Enum.EasingStyle.Linear),{CFrame=cf})
    S.ATweenConn = S.ATween.Completed:Connect(function() S.ATween = nil S.ATweenConn = nil S.TweenOn = false end)
    S.ATween:Play()
end

fn.FireAbilities = function()
    if tick()-S.LastSkill<F.SkillCooldown then return end
    if not(F.SkillZ or F.SkillX or F.SkillC or F.SkillV or F.SkillF) then return end
    if not S.CachedAbilityRemote or not S.CachedAbilityRemote.Parent then
        S.CachedAbilityRemote = nil
        pcall(function() S.CachedAbilityRemote = fn.WalkPathWait(ReplicatedStorage,2,unpack(S.Ability)) end)
    end
    local r = S.CachedAbilityRemote
    if not r then return end
    S.LastSkill = tick()
    S.LastAbilityFire = tick()
    if F.SkillZ then pcall(function() r:FireServer(1) end) end
    if F.SkillX then pcall(function() r:FireServer(2) end) end
    if F.SkillC then pcall(function() r:FireServer(3) end) end
    if F.SkillV then pcall(function() r:FireServer(4) end) end
    if F.SkillF then pcall(function() r:FireServer(5) end) end
end

fn.Attack = function(tgt)
    pcall(function() fn.WalkPathWait(ReplicatedStorage,2,unpack(S.Hit)):FireServer(tgt) end)
    fn.FireAbilities()
end

fn.ToggleFarm = function() 
    if S.FarmToggle then 
        pcall(function() S.FarmToggle:SetValue(not S.FarmToggle:GetValue()) end) 
    else 
        F.AutoFarmLevel = not F.AutoFarmLevel 
        if not F.AutoFarmLevel then fn.FullReset() end 
    end 
end

fn.ToggleBoss = function() 
    if S.BossToggle then 
        pcall(function() S.BossToggle:SetValue(not S.BossToggle:GetValue()) end) 
    else 
        F.BossEnabled = not F.BossEnabled 
        if not F.BossEnabled and S.BossFight then fn.ExitBossMode(S.BossTargetName) end 
    end 
end

fn.ToggleSummonBoss = function()
    if fn.HasAnySummonBossEnabled() then
        for _,b in ipairs(S.SummonBosses) do
            S.BSF[b.Name] = false
            if S.BSFToggle[b.Name] then pcall(function() S.BSFToggle[b.Name]:SetValue(false) end) end
        end
        fn.ExitSummonBossMode()
    end
end

fn.ToggleAllSkills = function()
    local anyOn = false
    for _,k in ipairs(S.SkillKeys) do 
        if F[k] then anyOn = true break end 
    end
    local newVal = not anyOn
    for _,k in ipairs(S.SkillKeys) do
        local tgl = S.SkillToggles[k]
        if tgl then pcall(function() tgl:SetValue(newVal) end) else F[k] = newVal end
    end
    if S.AllSkillsToggle then pcall(function() S.AllSkillsToggle:SetValue(newVal) end) end
end

fn.SetupAntiAFK = function()
    local function disableIdled() 
        pcall(function() 
            for _,c in ipairs(getconnections(Player.Idled)) do c:Disable() end 
        end) 
    end
    local function pulse()
        pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
        pcall(function() VirtualUser:Button2Down(Vector2.new()) task.defer(function() pcall(function() VirtualUser:Button2Up(Vector2.new()) end) end) end)
    end
    disableIdled()
    pcall(function() fn.Conn(Player.Idled:Connect(function() if F.AntiAFK then disableIdled() pulse() end end)) end)
    task.spawn(function() while S.Running do task.wait(fn.Jit(30,10)) if F.AntiAFK then disableIdled() pulse() pcall(function() keypress(0x20) task.wait(0.05) keyrelease(0x20) end) end end end)
    task.spawn(function() while S.Running do task.wait(fn.Jit(60,15)) if F.AntiAFK then pulse() pcall(function() mousemoverel(1,0) task.wait(0.05) mousemoverel(-1,0) end) pcall(function() keypress(0x57) task.wait(0.08) keyrelease(0x57) end) end end end)
    task.spawn(function() while S.Running do task.wait(fn.Jit(120,20)) if F.AntiAFK then disableIdled() pulse() pcall(function() keypress(0x41) task.wait(0.08) keyrelease(0x41) end) end end end)
    local r 
    pcall(function() r = ReplicatedStorage:WaitForChild("Remotes",10):WaitForChild("AntiAFKHeartbeat",10) end)
    task.spawn(function()
        while S.Running do
            task.wait(fn.Jit(25,5))
            if F.AntiAFK and r then pcall(function() r:FireServer() end) end
        end
    end)
end

fn.OnCharAdded = function(char)
    S.CharHum = nil S.NoclipChar = nil S.RayFilterChar = nil
    char:WaitForChild("Humanoid",10) S.CharHum = char:FindFirstChildOfClass("Humanoid")
    S.LockTarget = nil S.TweenOn = false S.TweenTarget = nil S.HoverPos = nil
    if F.AutoEquip then 
        task.spawn(function() 
            task.wait(0.5) 
            for _=1,10 do 
                task.wait(0.3) 
                fn.EquipBothWeapons() 
                local tools = fn.GetAllTools() 
                if #tools>=2 then break end 
                if #tools>=1 then 
                    local hasSword = false 
                    for _,t in ipairs(tools) do 
                        if t.Name:lower()~="combat" then hasSword = true end 
                    end 
                    if hasSword then break end 
                end 
            end 
        end) 
    end
end

if Player.Character then task.spawn(function() fn.OnCharAdded(Player.Character) end) end
fn.Conn(Player.CharacterAdded:Connect(fn.OnCharAdded))

fn.GetIslandNames = function() 
    local n = {"Auto"} 
    for _,i in ipairs(S.Islands) do 
        table.insert(n,fn.PortalDisplayName(i.Portal)) 
    end 
    return n 
end

fn.DisplayToPortal = function(display) 
    for _,i in ipairs(S.Islands) do 
        if fn.PortalDisplayName(i.Portal)==display then return i.Portal end 
    end 
    return display 
end

fn.WaitForMapLoad = function(island,timeout)
    local start = tick()
    local deadline = start+(timeout or 15)
    while tick()<deadline do
        if not fn.IsAlive() then task.wait(0.2) if not fn.IsAlive() then return false end end
        local hrp = fn.PlayerHRP()
        if hrp then
            if island then
                local nf = fn.GetNPCFolder()
                if nf then
                    local function chkMatch(m) 
                        if m:IsA("Model") and not fn.IsPlayer(m) and fn.MatchEnemy(m.Name,island) then 
                            local hm = fn.GetHum(m) 
                            if hm and hm.Health>0 then return true end 
                        end 
                        return false 
                    end
                    for _,ch in ipairs(nf:GetChildren()) do 
                        if chkMatch(ch) then return true 
                        elseif ch:IsA("Folder") then 
                            for _,m in ipairs(ch:GetChildren()) do 
                                if chkMatch(m) then return true end 
                            end 
                        end 
                    end
                end
            end
            if tick()-start>3 then
                local hit = Workspace:Raycast(hrp.Position+Vector3.new(0,10,0),Vector3.new(0,-200,0),S.RayParams)
                if hit then
                    local nf = fn.GetNPCFolder()
                    if nf then 
                        for _,m in ipairs(nf:GetChildren()) do 
                            if m:IsA("Model") and not fn.IsPlayer(m) and not fn.IsBoss(m.Name) then 
                                local hm = fn.GetHum(m) 
                                if hm and hm.Health>0 then 
                                    local p = fn.ModelPos(m) 
                                    if p and (p-hrp.Position).Magnitude<400 then return true end 
                                end 
                            end 
                        end 
                    end
                end
            end
        end
        task.wait(0.3)
    end
    return false
end

fn.Conn(RunService.Heartbeat:Connect(function()
    local anyActive = F.AutoFarmLevel or F.AutoDungeon or F.AutoBossRush or S.SummonBossFight or S.BossFight or F.DungeonQuest or F.HogyokuQuest
    if not anyActive or S.TweenOn then return end
    local c = Player.Character if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local hum = S.CharHum or c:FindFirstChildOfClass("Humanoid") if not hum then return end
    if S.LockTarget then
        local valid = true
        local hm = fn.GetHum(S.LockTarget)
        if not hm or hm.Health<=0 or not S.LockTarget.Parent then valid = false end
        if valid then
            local tp = fn.ModelPos(S.LockTarget)
            if not tp or tp.Y<-30 or (hrp.Position-tp).Magnitude>600 then valid = false end
        end
        if not valid then S.LockTarget = nil end
    end
    if S.LockTarget then
        local enemyPos = fn.ModelPos(S.LockTarget)
        if enemyPos then
            local now = tick()
            local enemyCF = fn.ModelCF(S.LockTarget)
            local enemyLook = enemyCF and Vector3.new(enemyCF.LookVector.X,0,enemyCF.LookVector.Z) or nil
            if enemyLook and enemyLook.Magnitude>0.01 then
                enemyLook = enemyLook.Unit
            else
                local fallback = (hrp.Position-enemyPos) fallback = Vector3.new(fallback.X,0,fallback.Z)
                enemyLook = fallback.Magnitude>0.1 and -fallback.Unit or Vector3.new(0,0,1)
            end
            local enemyRight = Vector3.new(-enemyLook.Z,0,enemyLook.X)
            local farmMode = F.FarmMode or "Behind"
            local baseDir
            if farmMode=="In Front" then
                baseDir = enemyLook
            elseif farmMode=="Left Side" then
                baseDir = enemyRight
            elseif farmMode=="Right Side" then
                baseDir = -enemyRight
            else
                baseDir = -enemyLook
            end
            local style = (farmMode=="Behind") and (F.FollowStyle or "Dodge") or "Static"
            local rightDir = Vector3.new(-baseDir.Z,0,baseDir.X)
            local goal
            if style=="Orbit" then
                local angle = now*0.8
                local orbitDir = Vector3.new(math.cos(angle),0,math.sin(angle))
                goal = enemyPos+(orbitDir*F.OffsetDist)
            elseif style=="Strafe" then
                if now-S.LastDodge>0.55 then
                    S.LastDodge = now
                    S.DodgeDir = -S.DodgeDir
                end
                goal = enemyPos+(baseDir*F.OffsetDist)+(rightDir*S.DodgeDir*6)
            elseif style=="Dodge" then
                local threatDetected = false
                local myPos = hrp.Position
                local scanCF = CFrame.new(myPos)
                local scanSize = Vector3.new(120,120,120)
                local nearby = Workspace:GetPartBoundsInBox(scanCF,scanSize,S.OverlapParams)
                for _,obj in ipairs(nearby) do
                    if obj~=hrp then
                        local vel = obj.AssemblyLinearVelocity
                        if vel.Magnitude>40 then
                            local toMe = myPos-obj.Position
                            if toMe.Magnitude<60 and vel.Unit:Dot(toMe.Unit)>0.7 then
                                threatDetected = true
                                break
                            end
                        end
                    end
                end
                if threatDetected and now-S.LastDodge>0.4 then
                    S.LastDodge = now
                    S.DodgeDir = -S.DodgeDir
                end
                local dodgeOffset = threatDetected and (rightDir*S.DodgeDir*4) or Vector3.new(0,0,0)
                goal = enemyPos+(baseDir*F.OffsetDist)+dodgeOffset
            else
                goal = enemyPos+(baseDir*F.OffsetDist)
            end
            goal = Vector3.new(goal.X,enemyPos.Y,goal.Z)
            local toGoal = (goal-enemyPos)
            local rayDir = toGoal.Magnitude>0.1 and toGoal.Unit or baseDir
            local ray = Workspace:Raycast(enemyPos,rayDir*F.OffsetDist,S.RayParams)
            if ray then 
                goal = enemyPos+baseDir*math.max(1,F.OffsetDist*0.5) 
                goal = Vector3.new(goal.X,enemyPos.Y,goal.Z) 
            end
            local lookAt = Vector3.new(enemyPos.X,hrp.Position.Y,enemyPos.Z)
            if style=="Dodge" then
                local dist = (Vector3.new(hrp.Position.X,0,hrp.Position.Z)-Vector3.new(goal.X,0,goal.Z)).Magnitude
                if dist>1 then hum:MoveTo(goal) end
                hrp.CFrame = CFrame.new(hrp.Position,lookAt)
            else
                local dGoal = (hrp.Position-goal).Magnitude
                if dGoal>0.3 then
                    local spd = math.max(F.TweenSpeed or 100,20)/60
                    local newPos = hrp.Position+(goal-hrp.Position).Unit*math.min(dGoal,spd)
                    hrp.CFrame = CFrame.new(newPos,Vector3.new(lookAt.X,newPos.Y,lookAt.Z))
                else
                    hrp.CFrame = CFrame.new(goal,lookAt)
                end
            end
        end
    end
end))

fn.ExitBossMode = function(lastBossName)
    local bi = lastBossName and fn.GetBossIsland(lastBossName)
    local savedHover = S.HoverPos
    S.BossFight = false S.BossTargetName = nil S.BossTPDone = false S.BossCurrentIsland = nil fn.ClearTgt() S.HoverPos = nil S.LastBossTP = 0 S.BossTPRetries = 0
    S.LastEnemy = 0 S.LastTP = 0
    local farmIsland = fn.GetFarmIsland()
    if bi and farmIsland and farmIsland.Portal==bi then
        S.CurIsland = farmIsland S.IslandTPd = true S.SpawnDone = true S.LastEnemy = tick()
        if savedHover then
            S.HoverPos = savedHover
        end
        if F.AutoQuest and S.QState~="ACTIVE" then task.delay(0.15,function() fn.QuestAccept(S.CurIsland) end) end
        Notify("Bosses Clear! Already on "..bi..", resuming farm")
    else
        S.CurIsland = nil S.IslandTPd = false S.SpawnDone = false
        local msg = F.AutoFarmLevel and "Returning to farming..." or "All bosses cleared!"
        Notify(msg)
    end
end

fn.DoFarmTick = function()
    local tgtIsland = fn.GetFarmIsland()
    if not tgtIsland then
        if S.ConfLevel==0 then
            Notify("Waiting for Level — retrying")
        end
        task.wait(1)
        return
    end
    if not S.CurIsland or S.CurIsland.Portal~=tgtIsland.Portal then
        fn.StopTw()
        S.CurIsland = tgtIsland S.IslandTPd = false S.SpawnDone = false S.FarmOrigin = nil S.QState = "NONE" S.CurTarget = nil S.LockTarget = nil S.HoverPos = nil S.LastEnemy = 0 S.LastQuestAccept = tick()
        fn.AbandonAllQuests()
        Notify("Teleporting to "..fn.PortalDisplayName(tgtIsland.Portal))
    end
    if not S.IslandTPd then
        local hrpBefore = fn.PlayerHRP()
        local posBefore = hrpBefore and hrpBefore.Position
        if fn.ForceTP(S.CurIsland.Portal) then
            task.wait(0.5)
            local hrpAfter = fn.PlayerHRP()
            if posBefore and hrpAfter and (posBefore-hrpAfter.Position).Magnitude<30 then
                fn.ForceTP(S.CurIsland.Portal)
                task.wait(0.8)
                hrpAfter = fn.PlayerHRP()
            end
            S.IslandTPd = true S.FarmOrigin = nil
            local snapIsland = S.CurIsland
            fn.WaitForMapLoad(snapIsland, 12)
            if S.CurIsland~=snapIsland then return end
            local hrpNow = fn.PlayerHRP()
            do
                local nf = fn.GetNPCFolder()
                local bestPos = nil local bestDist = math.huge
                if nf and hrpNow then
                    local function tryAnchor(m)
                        if m:IsA("Model") and not fn.IsPlayer(m) and fn.MatchEnemy(m.Name,snapIsland) then
                            local hm = fn.GetHum(m) if hm and hm.Health>0 then
                                local p = fn.ModelPos(m) if p then local d = (p-hrpNow.Position).Magnitude if d<bestDist then bestDist = d bestPos = p end end
                            end
                        end
                    end
                    for _,ch in ipairs(nf:GetChildren()) do 
                        if ch:IsA("Model") then tryAnchor(ch) 
                        elseif ch:IsA("Folder") then 
                            for _,m in ipairs(ch:GetChildren()) do tryAnchor(m) end 
                        end 
                    end
                end
                if bestPos then S.FarmOrigin = bestPos elseif hrpNow then S.FarmOrigin = hrpNow.Position end
            end
            S.LastEnemy = tick()
            if F.AutoSpawn and not S.SpawnDone then fn.SpawnCrystal(S.CurIsland) S.SpawnDone = true task.wait(0.2) end
            if S.CurIsland~=snapIsland then return end
            if F.AutoQuest and S.QState=="NONE" then task.wait(0.1) fn.QuestAccept(S.CurIsland) end
        else task.wait(1) end
        return
    end
    if F.AutoQuest and S.QState=="NONE" then
        if tick()-S.LastQuestAccept>5 then fn.QuestRepeatFire(S.CurIsland) end
    end
    local enemies = fn.FindEnemies(S.CurIsland)
    S.FarmGenericMode = false
    if #enemies>0 then
        S.LastEnemy = tick()
        if S.CurTarget then
            local hm = fn.GetHum(S.CurTarget)
            if not hm or hm.Health<=0 or not S.CurTarget.Parent then 
                if hm and hm.Health<=0 then 
                    S.Kills = S.Kills+1 
                    S.KillCount = S.KillCount+1 
                end 
                S.CurTarget = nil 
                S.LockTarget = nil
            elseif not fn.MatchEnemy(S.CurTarget.Name,S.CurIsland) then 
                S.CurTarget = nil 
                S.LockTarget = nil
            else 
                local cp = fn.ModelPos(S.CurTarget) 
                if cp and fn.DistTo(cp)>400 then 
                    S.CurTarget = nil 
                    S.LockTarget = nil 
                end 
            end
        end
        if not S.CurTarget then S.CurTarget = fn.NearestFrom(enemies) end
        if S.CurTarget then fn.TweenTo(S.CurTarget) fn.Attack(S.CurTarget) end
    else
        S.FarmGenericMode = false
        S.CurTarget = nil S.LockTarget = nil
        if tick()-S.LastEnemy>20 then S.IslandTPd = false S.SpawnDone = false S.FarmOrigin = nil S.LastEnemy = 0 S.HoverPos = nil end
        task.wait(0.15)
    end
    if F.AutoEquip and tick()-S.LastEquip>3 then S.LastEquip = tick() fn.EquipBothWeapons() end
end

fn.DoBossTick = function()
    if not S.BossTargetName then
        local nextName = fn.PickNextBossName()
        if nextName then
            S.BossTargetName = nextName S.BossTPDone = false S.LastBossTP = 0 fn.ClearTgt() S.HoverPos = nil
            local nextBossIsland = fn.GetBossIsland(nextName)
            if S.BossCurrentIsland~=nextBossIsland then S.BossCurrentIsland = nil end
            if F.BossNotify then Notify("Next: "..fn.GetBossDisplay(nextName).." at "..fn.PortalDisplayName(nextBossIsland or "?")) end
        else fn.ExitBossMode(nil) end
        return
    end
    if not S.BossTPDone then
        local bi = fn.GetBossIsland(S.BossTargetName)
        if not bi then S.BossTargetName = nil return end
        local model = fn.CheckBoss(S.BossTargetName)
        if model then
            local bp = fn.ModelPos(model)
            if bp and fn.DistTo(bp)<300 then S.BossTPDone = true S.BossCurrentIsland = bi S.BossTPRetries = 0 return end
        end
        if tick()-S.LastBossTP<4 then task.wait(0.2) return end
        fn.ClearTgt() S.HoverPos = nil S.LastBossTP = tick()
        local alreadyHere = S.BossCurrentIsland and S.BossCurrentIsland==bi
        if not alreadyHere then
            Notify("Teleporting to "..fn.PortalDisplayName(bi).." for "..fn.GetBossDisplay(S.BossTargetName))
            fn.ForceTP(bi)
            task.wait(1.5)
        else
            Notify("Searching for "..fn.GetBossDisplay(S.BossTargetName).." on "..fn.PortalDisplayName(bi))
        end
        S.BossCurrentIsland = bi
        local m2 = fn.CheckBoss(S.BossTargetName)
        if m2 then
            local bp2 = fn.ModelPos(m2)
            if bp2 then
                local goal = Vector3.new(bp2.X,bp2.Y+F.HeightOffset,bp2.Z)
                if fn.DistTo(bp2)<500 then
                    fn.TweenToPoint(goal)
                    S.BossTPDone = true S.BossTPRetries = 0
                    return
                else
                    local hrp = fn.PlayerHRP()
                    if hrp then hrp.CFrame = CFrame.new(goal) end
                    task.wait(0.3)
                end
            end
        end
        local renderPos = fn.GetRenderPos(S.BossTargetName)
        if renderPos then
            local hrp = fn.PlayerHRP()
            if hrp then hrp.CFrame = CFrame.new(Vector3.new(renderPos.X,renderPos.Y+F.HeightOffset,renderPos.Z)) end
        end
        for _=1,10 do
            local m = fn.CheckBoss(S.BossTargetName)
            if m then 
                local mp = fn.ModelPos(m) 
                if mp and fn.DistTo(mp)<500 then 
                    S.BossTPDone = true 
                    S.BossTPRetries = 0 
                    return 
                end 
            end
            task.wait(0.3)
        end
        local m3 = fn.CheckBoss(S.BossTargetName)
        local m3Close = m3 and fn.ModelPos(m3) and fn.DistTo(fn.ModelPos(m3))<500
        if m3 and not m3Close then
            S.BossCurrentIsland = nil S.LastBossTP = 0 S.BossTPRetries = 0
            return
        end
        if not m3 then
            S.BossTPRetries = (S.BossTPRetries or 0)+1
            if S.BossTPRetries<3 then
                Notify("Retrying TP for "..fn.GetBossDisplay(S.BossTargetName).." ("..S.BossTPRetries.."/3)")
                S.BossCurrentIsland = nil S.LastBossTP = 0
                return
            end
            S.BossTPRetries = 0
            fn.RecordBossDeath(S.BossTargetName)
            Notify("Skipping "..fn.GetBossDisplay(S.BossTargetName).." — not found after 3 TP attempts")
            local skippedName = S.BossTargetName
            S.BossTargetName = nil S.BossTPDone = false fn.ClearTgt() S.HoverPos = nil task.wait(0.15)
            local nextName = fn.PickNextBossName()
            if nextName then
                S.BossTargetName = nextName
                local nextIsland = fn.GetBossIsland(nextName)
                if nextIsland==S.BossCurrentIsland then S.BossTPDone = true
                else S.BossTPDone = false S.LastBossTP = 0 S.HoverPos = nil end
                if F.BossNotify then Notify("Next: "..fn.GetBossDisplay(nextName).." at "..fn.PortalDisplayName(nextIsland or "?")) end
            else fn.ExitBossMode(skippedName) end
        else S.BossTPDone = true S.BossTPRetries = 0 end
        return
    end
    local model = fn.CheckBoss(S.BossTargetName)
    if model and fn.IsAnosModel(S.BossTargetName) and model.Name~=S.BossTargetName then S.BossTargetName = model.Name end
    if not model then
        local deadName = S.BossTargetName
        local deadIsland = fn.GetBossIsland(deadName)
        S.BossKills = S.BossKills+1 S.Kills = S.Kills+1 S.KillCount = S.KillCount+1 fn.RecordBossDeath(deadName)
        if F.BossNotify then Notify("Defeated "..fn.GetBossDisplay(deadName)) end
        local savedHover = S.HoverPos
        if not savedHover then
            local hrp = fn.PlayerHRP()
            if hrp then savedHover = Vector3.new(hrp.Position.X,hrp.Position.Y+F.HeightOffset,hrp.Position.Z) end
        end
        S.BossTargetName = nil S.BossTPDone = false fn.ClearTgt() task.wait(0.15)
        S.HoverPos = savedHover
        local nextName = fn.PickNextBossName()
        if nextName then
            S.BossTargetName = nextName
            local nextIsland = fn.GetBossIsland(nextName)
            if nextIsland==S.BossCurrentIsland then
                S.BossTPDone = true
                S.HoverPos = savedHover
            else S.BossTPDone = false S.LastBossTP = 0 S.HoverPos = nil end
            if F.BossNotify then Notify("Next: "..fn.GetBossDisplay(nextName).." at "..fn.PortalDisplayName(nextIsland or "?")) end
        else fn.ExitBossMode(deadName) end
        return
    end
    local bossP = fn.ModelPos(model)
    if not bossP then task.wait(0.3) return end
    local bDist = fn.DistTo(bossP)
    if bDist>1500 then S.BossTPDone = false return end
    if bDist>500 then
        local goal = Vector3.new(bossP.X,bossP.Y+F.HeightOffset,bossP.Z)
        fn.TweenToPoint(goal)
        return
    end
    S.CurTarget = model
    fn.TweenTo(model)
    fn.Attack(model)
    if F.AutoEquip and tick()-S.LastEquip>3 then S.LastEquip = tick() fn.EquipBothWeapons() end
end

fn.GetSummonBossDiff = function(name)
    if name=="GilgameshBoss" then return F.GilgameshDiff end
    if name=="BlessedMaidenBoss" then return F.BlessedMaidenDiff end
    if name=="SaberAlterBoss" then return F.SaberAlterDiff end
    if name=="RimuruBoss" then return F.RimuruDiff end
    if name=="AnosBoss" then return F.AnosDiff end
    if name=="StrongestTodayBoss" then return F.StrongestTodayDiff end
    if name=="StrongestHistoryBoss" then return F.StrongestHistoryDiff end
    if name=="TrueAizenBoss" then return F.TrueAizenDiff end
    return nil
end

fn.GetItemCount = function(itemName)
    local best = 0
    local target = (itemName or ""):lower()
    local targetNorm = target:gsub("[%s_%-]","")
    pcall(function()
        local direct = Player:FindFirstChild(itemName,true)
        if direct and (direct:IsA("IntValue") or direct:IsA("NumberValue") or direct:IsA("StringValue")) then
            best = tonumber(direct.Value) or best
        end
    end)
    pcall(function()
        for _,d in ipairs(Player:GetDescendants()) do
            if d:IsA("IntValue") or d:IsA("NumberValue") or d:IsA("StringValue") then
                local n = (d.Name or ""):lower()
                local nNorm = n:gsub("[%s_%-]","")
                if n==target or nNorm==targetNorm or n:find(target,1,true) then
                    local v = tonumber(d.Value)
                    if v and v>best then best = v end
                end
            end
        end
    end)
    return best
end

fn.TryCraftSlimeKey = function(craftMax)
    local ok,remote = pcall(function() return fn.WalkPathWait(ReplicatedStorage,2,unpack(S.SlimeCraft)) end)
    if not ok or not remote then return false end
    local keyNames = {"Slime Key","SlimeKey"}
    local function keyCount()
        local best = 0
        for _,nm in ipairs(keyNames) do
            best = math.max(best,fn.GetItemCount(nm))
        end
        return best
    end
    local qty = 999
    if craftMax and craftMax>0 then qty = math.max(1,math.floor(craftMax)) end
    local startKeys = keyCount()
    local argSets = {
        {"SlimeKey",qty},
        {"Slime Key",qty},
        {"SlimeKey"},
        {"Slime Key"},
        {qty},
        {},
    }
    local did = false
    for _,args in ipairs(argSets) do
        local fired = false
        pcall(function()
            if remote:IsA("RemoteFunction") then
                remote:InvokeServer(table.unpack(args))
                fired = true
            elseif remote:IsA("RemoteEvent") then
                remote:FireServer(table.unpack(args))
                fired = true
            end
        end)
        if fired then did = true end
        task.wait(0.08)
        if keyCount()>startKeys then return true end
    end
    return did
end

fn.TrySpawnRimuru = function(diff)
    pcall(function()
        local r = fn.WalkPathWait(ReplicatedStorage,2,unpack(S.RimuruSpawn))
        if r then r:FireServer(diff or "Normal") end
    end)
end

fn.DetectSummonError = function()
    local found = false
    pcall(function()
        local pg = Player:FindFirstChild("PlayerGui") if not pg then return end
        for _,d in ipairs(pg:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local txt = (d.Text or ""):lower()
                if ((txt:find("don't have") or txt:find("doesn't have") or txt:find("don%'t have") or txt:find("not enough")) and (txt:find("material") or txt:find("item") or txt:find("summon") or txt:find("spawn"))) or txt:find("cannot summon") or txt:find("can't summon") or txt:find("can%'t summon") then
                    found = true
                    local p = d while p and not p:IsA("ScreenGui") do p = p.Parent end
                    if p then pcall(function() p.Enabled = false end) end
                    pcall(function() d.Visible = false end)
                end
            end
        end
    end)
    return found
end

fn.FireAutoSpawn = function(name)
    if not S.BSF[name] then return end
    if S.AutoSpawnActive[name] then return end
    local existing = fn.CheckSummonBoss(name)
    if existing and fn.SummonBossPosValid(existing) then
        S.AutoSpawnActive[name] = "passive"
        return
    end
    if not S.SummonBossLockedDiff[name] then
        S.SummonBossLockedDiff[name] = fn.GetSummonBossDiff(name) or "Normal"
    end
    local diff = S.SummonBossLockedDiff[name]
    pcall(function()
        if name=="AnosBoss" then
            local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnAnos))
            if r then r:FireServer("Anos",diff) S.AutoSpawnActive[name] = "fired" end
        elseif name=="RimuruBoss" then
            fn.TryCraftSlimeKey()
            fn.TrySpawnRimuru(diff)
            local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnRimuru))
            if r then r:FireServer(diff) S.AutoSpawnActive[name] = "fired" end
        elseif name=="StrongestTodayBoss" then
            local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnStrongest))
            if r then r:FireServer("StrongestToday",diff) S.AutoSpawnActive[name] = "fired" end
        elseif name=="StrongestHistoryBoss" then
            local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnStrongest))
            if r then r:FireServer("StrongestHistory",diff) S.AutoSpawnActive[name] = "fired" end
        elseif name=="TrueAizenBoss" then
            local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnTrueAizen))
            if r then r:FireServer(diff) S.AutoSpawnActive[name] = "fired" end
        else
            local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnBoss))
            if r then r:FireServer(name,diff) S.AutoSpawnActive[name] = "fired" end
        end
    end)
end

fn.DisableAutoSpawn = function(name)
    if S.AutoSpawnActive[name]=="fired" then
        local diff = S.SummonBossLockedDiff[name] or fn.GetSummonBossDiff(name) or "Normal"
        pcall(function()
            if name=="AnosBoss" then
                local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnAnos))
                if r then r:FireServer("Anos",diff) end
            elseif name=="RimuruBoss" then
                local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnRimuru))
                if r then r:FireServer(diff) end
            elseif name=="StrongestTodayBoss" then
                local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnStrongest))
                if r then r:FireServer("StrongestToday",diff) end
            elseif name=="StrongestHistoryBoss" then
                local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnStrongest))
                if r then r:FireServer("StrongestHistory",diff) end
            elseif name=="TrueAizenBoss" then
                local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnTrueAizen))
                if r then r:FireServer(diff) end
            else
                local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.AutoSpawnBoss))
                if r then r:FireServer(name,diff) end
            end
        end)
    end
    S.AutoSpawnActive[name] = nil
end

fn.DisableAllAutoSpawn = function()
    for _,b in ipairs(S.SummonBosses) do
        if S.AutoSpawnActive[b.Name] then
            fn.DisableAutoSpawn(b.Name)
        end
    end
    S.AutoSpawnActive = {}
end

fn.FireSummonBoss = function(name)
    fn.FireAutoSpawn(name)
end

fn.CheckSummonResult = function(name,timeout)
    local deadline = tick()+(timeout or 3)
    while tick()<deadline do
        local m = fn.CheckSummonBoss(name)
        if m and fn.SummonBossPosValid(m) then return true end
        if fn.DetectSummonError() then return false end
        task.wait(0.15)
    end
    return nil
end

fn.GetSummonBossIsland = function(name) return S.SummonBossIslandMap[name] or S.BOSS_ISLAND_PORTAL end

fn.CheckSummonBoss = function(name)
    local nf = fn.GetNPCFolder() if not nf then return nil end
    if name=="AnosBoss" then
        for _,m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and fn.IsAnosModel(m.Name) then 
                local hm = fn.GetHum(m) 
                if hm and hm.Health>0 then return m end 
            end
        end
        return nil
    end
    if name=="RimuruBoss" then
        for _,m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and fn.IsRimuruModel(m.Name) then 
                local hm = fn.GetHum(m) 
                if hm and hm.Health>0 then return m end 
            end
        end
        return nil
    end
    if name=="StrongestTodayBoss" then
        for _,m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and fn.IsStrongestTodayModel(m.Name) then 
                local hm = fn.GetHum(m) 
                if hm and hm.Health>0 then return m end 
            end
        end
        return nil
    end
    if name=="StrongestHistoryBoss" then
        for _,m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and fn.IsStrongestHistoryModel(m.Name) then 
                local hm = fn.GetHum(m) 
                if hm and hm.Health>0 then return m end 
            end
        end
        return nil
    end
    if name=="TrueAizenBoss" then
        for _,m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and fn.IsTrueAizenModel(m.Name) then 
                local hm = fn.GetHum(m) 
                if hm and hm.Health>0 then return m end 
            end
        end
        return nil
    end
    local nameLo = name:lower()
    for _,m in ipairs(nf:GetChildren()) do
        if m:IsA("Model") then
            local mLo = (m.Name or ""):lower()
            if mLo==nameLo or mLo:sub(1,#nameLo)==nameLo then
                local hm = fn.GetHum(m) if hm and hm.Health>0 then return m end
            end
        end
    end
    return nil
end

fn.HasAnySummonBossEnabled = function()
    for _,b in ipairs(S.SummonBosses) do if S.BSF[b.Name] then return true end end
    return false
end

fn.ExitSummonBossMode = function()
    fn.DisableAllAutoSpawn()
    S.SummonBossFight = false S.SummonBossTarget = nil S.SummonBossTPDone = false S.LastSummonBossTP = 0 S.SummonBossCommitted = {} S.SummonBossCurrentIsland = nil S.SummonBossOrder = 0 S.SummonBossFailCount = {} S.SummonBossFireTime = {} S.SummonBossLockedDiff = {}
    fn.ClearTgt() S.HoverPos = nil
    S.CurIsland = nil S.IslandTPd = false S.SpawnDone = false S.LastEnemy = 0 S.LastTP = 0
end

fn.SummonBossPosValid = function(model)
    local p = fn.ModelPos(model)
    if not p then return false end
    if p.Y<-30 then return false end
    return true
end

fn.AcquireSummonBossFast = function(preferredName,timeout)
    local deadline = tick()+(timeout or 1.2)
    while tick()<deadline do
        if preferredName then
            local preferred = fn.CheckSummonBoss(preferredName)
            if preferred and fn.SummonBossPosValid(preferred) then return preferredName,preferred end
        end
        for _,b in ipairs(S.SummonBosses) do
            if S.BSF[b.Name] or S.SummonBossCommitted[b.Name] then
                local m = fn.CheckSummonBoss(b.Name)
                if m and fn.SummonBossPosValid(m) then return b.Name,m end
            end
        end
        task.wait(0.05)
    end
    return nil,nil
end

fn.DoSummonBossTick = function()
    local function PickBestTarget()
        local bestName,bestOrder = nil,math.huge
        local hrp = fn.PlayerHRP()
        for _,b in ipairs(S.SummonBosses) do
            if S.SummonBossCommitted[b.Name] then
                local m = fn.CheckSummonBoss(b.Name)
                if m and fn.SummonBossPosValid(m) then
                    local ord = S.SummonBossCommitted[b.Name]
                    if type(ord)=="number" and ord<bestOrder then bestOrder = ord bestName = b.Name end
                end
            end
        end
        if bestName then return bestName end
        local bestDist = math.huge
        for _,b in ipairs(S.SummonBosses) do
            if S.BSF[b.Name] or S.SummonBossCommitted[b.Name] then
                local m = fn.CheckSummonBoss(b.Name)
                if m and fn.SummonBossPosValid(m) then
                    if not hrp then return b.Name end
                    local p = fn.ModelPos(m)
                    local d = p and (hrp.Position-p).Magnitude or math.huge
                    if d<bestDist then bestDist = d bestName = b.Name end
                end
            end
        end
        return bestName
    end
    local function SummonAllEnabled()
        for _,b in ipairs(S.SummonBosses) do
            if S.BSF[b.Name] and fn.GetSummonBossIsland(b.Name)==S.SummonBossCurrentIsland then
                fn.FireAutoSpawn(b.Name)
                if not S.SummonBossCommitted[b.Name] then
                    S.SummonBossFireTime[b.Name] = tick()
                    S.SummonBossOrder = S.SummonBossOrder+1
                    S.SummonBossCommitted[b.Name] = S.SummonBossOrder
                end
                task.wait(0.15)
            end
        end
    end
    if not S.SummonBossTPDone then
        if tick()-S.LastSummonBossTP<4 then task.wait(0.2) return end
        local targetIsland = S.BOSS_ISLAND_PORTAL
        local bestOrd = math.huge
        for _,b in ipairs(S.SummonBosses) do
            if S.BSF[b.Name] then
                local isl = fn.GetSummonBossIsland(b.Name)
                local ord = S.SummonBossCommitted[b.Name]
                if type(ord)=="number" and ord<bestOrd then bestOrd = ord targetIsland = isl end
            end
        end
        if bestOrd==math.huge then
            local hasBossIsland,hasOther = false,false
            for _,b in ipairs(S.SummonBosses) do
                if S.BSF[b.Name] then
                    if fn.GetSummonBossIsland(b.Name)==S.BOSS_ISLAND_PORTAL then hasBossIsland = true
                    else hasOther = true end
                end
            end
            if hasBossIsland then targetIsland = S.BOSS_ISLAND_PORTAL
            elseif hasOther then
                for _,b in ipairs(S.SummonBosses) do
                    if S.BSF[b.Name] then targetIsland = fn.GetSummonBossIsland(b.Name) break end
                end
            end
        end
        S.LastSummonBossTP = tick()
        local displayIsland = fn.PortalDisplayName(targetIsland)
        local bossDisp = ""
        for _,b in ipairs(S.SummonBosses) do if S.BSF[b.Name] then bossDisp = b.Display break end end
        Notify("Attempting to summon "..bossDisp.."!")
        fn.StopTw() S.HoverPos = nil fn.ClearTgt()
        local _hrpBefore = fn.PlayerHRP()
        local posBefore = _hrpBefore and _hrpBefore.Position
        fn.ForceTP(targetIsland)
        task.wait(0.9)
        local _hrpAfter = fn.PlayerHRP()
        if posBefore and _hrpAfter and (posBefore-_hrpAfter.Position).Magnitude<30 then
            fn.ForceTP(targetIsland)
            task.wait(1.0)
        end
        S.SummonBossCurrentIsland = targetIsland
        local _hrp = fn.PlayerHRP() if _hrp then S.HoverPos = _hrp.Position end
        SummonAllEnabled()
        local nextName,nextModel = fn.AcquireSummonBossFast(nil,3.0)
        if not nextName then task.wait(0.5) nextName,nextModel = fn.AcquireSummonBossFast(nil,3.0) end
        if nextModel then
            local bp = fn.ModelPos(nextModel)
            if bp then
                local goal = Vector3.new(bp.X,bp.Y+F.HeightOffset,bp.Z)
                local hrp = fn.PlayerHRP()
                local d = hrp and (hrp.Position-goal).Magnitude or math.huge
                if d<=1500 then
                    fn.TweenToPoint(goal)
                    S.HoverPos = goal
                end
            end
        end
        S.SummonBossTPDone = true S.SummonBossTarget = nextName
        if nextModel then S.CurTarget = nextModel end
        return
    end
    if not S.SummonBossTarget then
        S.SummonBossTarget = PickBestTarget()
        if not S.SummonBossTarget then
            local anyGrace = false
            for _,b in ipairs(S.SummonBosses) do
                if S.SummonBossCommitted[b.Name] and fn.GetSummonBossIsland(b.Name)==S.SummonBossCurrentIsland and not fn.CheckSummonBoss(b.Name) then
                    local fireT = S.SummonBossFireTime[b.Name] or 0
                    if tick()-fireT<8 then
                        anyGrace = true
                    else
                        S.SummonBossFailCount[b.Name] = (S.SummonBossFailCount[b.Name] or 0)+1
                        if (S.SummonBossFailCount[b.Name] or 0)>=5 then
                            fn.DisableAutoSpawn(b.Name)
                            S.SummonBossCommitted[b.Name] = nil
                            S.BSF[b.Name] = false
                            local tgl = S.BSFToggle[b.Name]
                            if tgl then
                                pcall(function() tgl:SetValue(false) end)
                            end
                            local dsp = S.SummonBossDisplay[b.Name] or b.Name
                            Notify("Summon Failed: "..dsp.." disabled — no materials?")
                        else
                            fn.FireSummonBoss(b.Name)
                            S.SummonBossFireTime[b.Name] = tick()
                            anyGrace = true
                        end
                    end
                end
            end
            if anyGrace then task.wait(0.2) return end
            if not fn.HasAnySummonBossEnabled() then
                task.wait(0.3) return
            end
            SummonAllEnabled()
            local nextName,_ = fn.AcquireSummonBossFast(nil,3.0)
            S.SummonBossTarget = nextName
            if not S.SummonBossTarget then
                for _,b in ipairs(S.SummonBosses) do
                    if S.BSF[b.Name] and fn.GetSummonBossIsland(b.Name)~=S.SummonBossCurrentIsland then
                        S.SummonBossTPDone = false S.LastSummonBossTP = 0
                        fn.ClearTgt()
                        return
                    end
                end
                task.wait(0.3)
            end
            return
        end
        Notify("Summon Boss: "..(S.SummonBossDisplay[S.SummonBossTarget] or S.SummonBossTarget).." — Attacking!")
    end
    local targetIsland = fn.GetSummonBossIsland(S.SummonBossTarget)
    if targetIsland~=S.SummonBossCurrentIsland then
        S.SummonBossTPDone = false S.LastSummonBossTP = 0
        fn.ClearTgt()
        return
    end
    local model = fn.CheckSummonBoss(S.SummonBossTarget)
    if not model then
        task.wait(0.25)
        model = fn.CheckSummonBoss(S.SummonBossTarget)
        if model then S.CurTarget = model return end
        local deadName = S.SummonBossTarget
        local deadDisplay = S.SummonBossDisplay[deadName] or deadName
        S.BossKills = S.BossKills+1 S.Kills = S.Kills+1 S.KillCount = S.KillCount+1
        Notify("Successfully defeated "..deadDisplay.."!")
        S.SummonBossCommitted[deadName] = nil
        S.SummonBossFailCount[deadName] = 0
        S.SummonBossTarget = nil fn.ClearTgt()
        if S.BSF[deadName] and fn.GetSummonBossIsland(deadName)==S.SummonBossCurrentIsland then
            S.SummonBossFireTime[deadName] = tick()
            S.SummonBossOrder = S.SummonBossOrder+1
            S.SummonBossCommitted[deadName] = S.SummonBossOrder
        end
        local nextName,nextModel = fn.AcquireSummonBossFast(deadName,4)
        S.SummonBossTarget = nextName
        if nextModel then S.CurTarget = nextModel end
        return
    end
    local bossPos = fn.ModelPos(model)
    if not bossPos or bossPos.Y<-30 then task.wait(0.15) return end
    local dist = fn.DistTo(bossPos)
    if dist>1500 then
        S.SummonBossTPDone = false S.LastSummonBossTP = 0
        fn.ClearTgt()
        return
    end
    S.CurTarget = model
    local goal = Vector3.new(bossPos.X,bossPos.Y+F.HeightOffset,bossPos.Z)
    local hrpNow = fn.PlayerHRP()
    local hDist = hrpNow and Vector3.new(hrpNow.Position.X-bossPos.X,0,hrpNow.Position.Z-bossPos.Z).Magnitude or dist
    if hDist>80 then
        fn.TweenToPoint(goal)
    elseif hDist>15 then
        fn.TweenTo(model)
    end
    S.HoverPos = goal S.LockTarget = model
    fn.Attack(model)
    if F.AutoEquip and tick()-S.LastEquip>3 then S.LastEquip = tick() fn.EquipBothWeapons() end
end

fn.DoAutoDungeonTick = function()
    if tick()-S.LastDungeonVote>10 then S.LastDungeonVote = tick() fn.FireDungeonVote() end
    local prevTarget = S.CurTarget
    local enemies = fn.FindDungeonEnemiesKnown(S.GENERIC_HOSTILE_MAX_DIST)
    if #enemies==0 then
        S.CurTarget = nil S.LockTarget = nil
        fn.HoldDungeonIdleHover()
        task.wait(0.12)
        return
    end
    local best,bestDist = nil,math.huge
    for _,e in ipairs(enemies) do
        local p = fn.ModelPos(e)
        if p then
            local d = fn.DistTo(p)
            if d<bestDist then best = e bestDist = d end
        end
    end
    if S.CurTarget then
        local hm = fn.GetHum(S.CurTarget)
        if not fn.IsKnownDungeonEnemy(S.CurTarget) or not hm or hm.Health<=0 or not S.CurTarget.Parent or fn.IsPlayer(S.CurTarget) then
            S.CurTarget = nil S.LockTarget = nil S.HoverPos = nil
        else
            local cp = fn.ModelPos(S.CurTarget)
            if cp and fn.DistTo(cp)>900 then S.CurTarget = nil S.LockTarget = nil S.HoverPos = nil end
        end
    end
    if not S.CurTarget then
        S.CurTarget = best
        if S.CurTarget then S.LastDungeonSwitch = tick() end
    end
    if S.CurTarget and prevTarget and S.CurTarget~=prevTarget then
        fn.StopTw()
        S.LockTarget = nil
        S.HoverPos = nil
    end
    if not S.CurTarget then
        S.LockTarget = nil
        if not S.HoverPos then
            fn.HoldDungeonIdleHover()
        end
        task.wait(0.12)
        return
    end
    if S.CurTarget then fn.TweenToDungeon(S.CurTarget) fn.Attack(S.CurTarget) end
    if F.AutoEquip and tick()-S.LastEquip>3 then S.LastEquip = tick() fn.EquipBothWeapons() end
end

fn.IsBossRushEnemy = function(model)
    if not model or not model:IsA("Model") then return false end
    local lo = (model.Name or ""):lower()
    if S.BossRushEnemySet[lo] then return true end
    for name in pairs(S.BossRushEnemySet) do
        if lo:sub(1,#name)==name then return true end
    end
    return false
end

fn.HasBossRushEnemiesInWorkspace = function()
    local nf = fn.GetNPCFolder()
    if nf then
        for _,m in ipairs(nf:GetChildren()) do
            if m:IsA("Model") and fn.IsBossRushEnemy(m) and not fn.IsPlayer(m) then
                local hm = fn.GetHum(m) if hm and hm.Health>0 then return true end
            end
        end
    end
    return false
end

fn.FindBossRushEnemies = function(maxDist)
    local hrp = fn.PlayerHRP() if not hrp then return {} end
    local maxD = maxDist or S.GENERIC_HOSTILE_MAX_DIST
    local myY = hrp.Position.Y
    local out = {}
    local function addIfMatch(m)
        if not m:IsA("Model") then return end
        if fn.IsPlayer(m) then return end
        if not fn.IsBossRushEnemy(m) then return end
        local hm = fn.GetHum(m) if not hm or hm.Health<=0 then return end
        local p = fn.ModelPos(m) if not p then return end
        if (p-hrp.Position).Magnitude>maxD then return end
        table.insert(out,m)
    end
    local nf = fn.GetNPCFolder()
    if nf then 
        for _,desc in ipairs(nf:GetChildren()) do 
            if desc:IsA("Model") then addIfMatch(desc) end 
        end 
    end
    if #out==0 then 
        for _,desc in ipairs(Workspace:GetDescendants()) do 
            if desc:IsA("Model") then addIfMatch(desc) end 
        end 
    end
    return out
end

fn.DoBossRushTick = function()
    local prevTarget = S.CurTarget
    local enemies = fn.FindBossRushEnemies(S.GENERIC_HOSTILE_MAX_DIST)
    if #enemies==0 then
        S.CurTarget = nil S.LockTarget = nil
        fn.HoldDungeonIdleHover()
        task.wait(0.12)
        return
    end
    local best,bestDist = nil,math.huge
    for _,e in ipairs(enemies) do
        local p = fn.ModelPos(e)
        if p then
            local d = fn.DistTo(p)
            if d<bestDist then best = e bestDist = d end
        end
    end
    if S.CurTarget then
        local hm = fn.GetHum(S.CurTarget)
        if not fn.IsBossRushEnemy(S.CurTarget) or not hm or hm.Health<=0 or not S.CurTarget.Parent or fn.IsPlayer(S.CurTarget) then
            S.CurTarget = nil S.LockTarget = nil S.HoverPos = nil
        else
            local cp = fn.ModelPos(S.CurTarget)
            if cp and fn.DistTo(cp)>900 then S.CurTarget = nil S.LockTarget = nil S.HoverPos = nil end
        end
    end
    if not S.CurTarget then
        S.CurTarget = best
        if S.CurTarget then S.LastBossRushSwitch = tick() end
    end
    if S.CurTarget and prevTarget and S.CurTarget~=prevTarget then
        fn.StopTw() S.LockTarget = nil S.HoverPos = nil
    end
    if not S.CurTarget then
        S.LockTarget = nil
        if not S.HoverPos then fn.HoldDungeonIdleHover() end
        task.wait(0.12)
        return
    end
    fn.TweenToBossRush(S.CurTarget)
    fn.Attack(S.CurTarget)
    if F.AutoEquip and tick()-S.LastEquip>3 then S.LastEquip = tick() fn.EquipBothWeapons() end
end

fn.DisableGameAutoSkills = function()
    pcall(function()
        local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.Settings))
        if not r then return end
        for _,skill in ipairs({"AutoSkillZ","AutoSkillX","AutoSkillC","AutoSkillV","AutoSkillF"}) do
            pcall(function() r:FireServer(skill,false) end) task.wait(0.05)
        end
    end)
end

fn.AbandonDungeonQuest = function()
    pcall(function()
        local ab = fn.WalkPathWait(ReplicatedStorage,2,unpack(S.QuestAbandon))
        if ab then ab:FireServer("DungeonUnlock") end
    end)
end

fn.AcceptDungeonQuest = function()
    pcall(function() fn.WalkPathWait(ReplicatedStorage,2,"Remotes","DungeonQuestAccept"):FireServer() end)
    task.wait(0.3) fn.ClickYes() task.wait(0.3)
    pcall(function() fn.WalkPathWait(ReplicatedStorage,2,unpack(S.QuestAccept)):FireServer("DungeonUnlock") end)
    task.wait(0.3) fn.ClickYes()
end

fn.FindDungeonPiece = function(island)
    local islandLow = island:lower()
    for _,desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name=="DungeonPuzzlePiece" and desc:IsA("BasePart") then
            local anc = desc.Parent
            while anc and anc~=Workspace do
                if anc.Name:lower():find(islandLow,1,true) then return desc end
                anc = anc.Parent
            end
        end
    end
    return nil
end

fn.DungeonClear = function()
    fn.StopTw() fn.ClearTgt() S.HoverPos = nil S.LockTarget = nil
end

fn.DungeonCollectPiece = function(piece)
    fn.DungeonClear()
    local hrp = fn.PlayerHRP()
    if hrp then hrp.CFrame = CFrame.new(piece.Position+Vector3.new(0,2,0)) end
    task.wait(0.15)
    local pp = piece:FindFirstChild("PuzzlePrompt") or piece:FindFirstChildOfClass("ProximityPrompt")
    if not pp then 
        for _,ch in ipairs(piece:GetDescendants()) do 
            if ch:IsA("ProximityPrompt") then pp = ch break end 
        end 
    end
    if pp then 
        pcall(function() fireproximityprompt(pp) end) 
        task.wait(0.2) 
        pcall(function() fireproximityprompt(pp) end) 
    end
end

fn.DungeonPieceHasPrompt = function(piece)
    if not piece then return false end
    local pp = piece:FindFirstChild("PuzzlePrompt") or piece:FindFirstChildOfClass("ProximityPrompt")
    if pp then return true end
    for _,ch in ipairs(piece:GetDescendants()) do 
        if ch:IsA("ProximityPrompt") then return true end 
    end
    return false
end

fn.DoDungeonQuestTick = function()
    if not F.DungeonQuest then return end
    local step = S.DungeonStep
    if step<1 then
        fn.DungeonClear()
        local anyUncollected = false
        for _,isl in ipairs(S.DungeonPieceIslands) do
            local p = fn.FindDungeonPiece(isl)
            if p and fn.DungeonPieceHasPrompt(p) then anyUncollected = true break end
        end
        if not anyUncollected then
            fn.ForceTP(S.DungeonPieceIslands[1])
            task.wait(1) fn.WaitChar() task.wait(0.5)
            local p = fn.FindDungeonPiece(S.DungeonPieceIslands[1])
            if not p or not fn.DungeonPieceHasPrompt(p) then
                Notify("Dungeon Pieces: All pieces already collected!")
                F.DungeonQuest = false S.DungeonStep = 0 S.DungeonCollected = {}
                if S.DungeonToggle then pcall(function() S.DungeonToggle:SetValue(false) end) end
                return
            end
        end
        fn.AcceptDungeonQuest()
        S.DungeonStep = 1 S.DungeonCollected = {}
        return
    end
    if step>6 then
        fn.DungeonClear()
        fn.ForceTP("Dungeon")
        task.wait(1) fn.WaitChar() task.wait(1)
        fn.AcceptDungeonQuest()
        F.DungeonQuest = false S.DungeonStep = 0 S.DungeonCollected = {}
        if S.DungeonToggle then pcall(function() S.DungeonToggle:SetValue(false) end) end
        Notify("Dungeon Pieces: Complete! All pieces collected.")
        return
    end
    local island = S.DungeonPieceIslands[step]
    if not island then S.DungeonStep = step+1 return end
    if S.DungeonCollected and S.DungeonCollected[step] then S.DungeonStep = step+1 return end
    fn.DungeonClear()
    Notify("Dungeon Pieces: Piece #"..step.." at "..fn.PortalDisplayName(island))
    fn.ForceTP(island)
    task.wait(0.5)
    fn.WaitChar()
    task.wait(0.5)
    local piece = fn.FindDungeonPiece(island)
    if not piece then task.wait(1) piece = fn.FindDungeonPiece(island) end
    if not piece then task.wait(1) piece = fn.FindDungeonPiece(island) end
    if not piece or not fn.DungeonPieceHasPrompt(piece) then
        Notify("Dungeon: Piece #"..step.." already collected or not found")
    else
        fn.DungeonCollectPiece(piece)
    end
    if not S.DungeonCollected then S.DungeonCollected = {} end
    S.DungeonCollected[step] = true
    S.DungeonStep = step+1
end

fn.AbandonHogyokuQuest = function()
    pcall(function()
        local ab = fn.WalkPathWait(ReplicatedStorage,2,unpack(S.QuestAbandon))
        if ab then 
            for _,n in ipairs({"HogyokuUnlock","HogyokuQuestNPC","Hogyoku","HogyokuFragment","HogyokuQuest","SoulSociety"}) do 
                pcall(function() ab:FireServer(n) end) 
            end 
        end
    end)
end

fn.FindHogyokuFragment = function(stepNum)
    local target = "hogyoku fragment #"..stepNum
    for _,desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and (desc.ObjectText or ""):lower()==target then return desc end
    end
    return nil
end

fn.DoHogyokuQuestTick = function()
    if not F.HogyokuQuest then return end
    local step = S.HogyokuStep
    if step==0 then
        fn.StopTw() fn.ClearTgt()
        fn.ForceTP("HuecoMundo")
        S.HogyokuStep = 0.5
        return
    end
    if step==0.5 then
        task.wait(1) fn.WaitChar() task.wait(0.5)
        local npc = Workspace:FindFirstChild("HogyokuQuestNPC",true)
        if not npc then task.wait(2) npc = Workspace:FindFirstChild("HogyokuQuestNPC",true) end
        if not npc then
            Notify("Hogyoku: NPC not found, retrying...")
            S.HogyokuStep = 0
            return
        end
        local npcPos
        if npc:IsA("BasePart") then npcPos = npc.Position end
        if not npcPos then
            local p = npc:FindFirstChild("HumanoidRootPart",true) or npc:FindFirstChild("Head",true)
            if p and p:IsA("BasePart") then npcPos = p.Position end
        end
        if not npcPos then
            for _,d in ipairs(npc:GetDescendants()) do if d:IsA("BasePart") then npcPos = d.Position break end end
        end
        if not npcPos then
            pcall(function() npcPos = npc:GetPivot().Position end)
        end
        if not npcPos then S.HogyokuStep = 0 return end
        local hrp = fn.PlayerHRP()
        if hrp then hrp.CFrame = CFrame.new(npcPos+Vector3.new(0,0,3)) end
        task.wait(0.3)
        for _,desc in ipairs(npc:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(desc) end) end
            if desc:IsA("ClickDetector") then pcall(function() fireclickdetector(desc) end) end
        end
        task.wait(0.5) fn.ClickYes()
        task.wait(0.3) fn.ClickYes()
        for _,desc in ipairs(npc:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(desc) end) end
        end
        task.wait(0.3) fn.ClickYes()
        task.wait(0.3) fn.ClickYes()
        S.HogyokuStep = 1 S.HogyokuCollected = {}
        F.HogyokuQuest = true
        task.wait(1)
        Notify("Hogyoku: Quest accepted! Collecting fragments...")
        return
    end
    if step>6 then
        fn.StopTw() fn.ClearTgt()
        fn.ForceTP("HuecoMundo")
        task.wait(1) fn.WaitChar() task.wait(0.5)
        local npc = Workspace:FindFirstChild("HogyokuQuestNPC",true)
        if npc then
            local npcPos
            local p = npc:FindFirstChild("HumanoidRootPart",true) or npc:FindFirstChild("Head",true)
            if p and p:IsA("BasePart") then npcPos = p.Position end
            if not npcPos then 
                for _,d in ipairs(npc:GetDescendants()) do 
                    if d:IsA("BasePart") then npcPos = d.Position break end 
                end 
            end
            if npcPos then 
                local hrp = fn.PlayerHRP() 
                if hrp then hrp.CFrame = CFrame.new(npcPos+Vector3.new(0,0,3)) end 
            end
            task.wait(0.3)
            for _,desc in ipairs(npc:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(desc) end) end
            end
            task.wait(0.3) fn.ClickYes() task.wait(0.3) fn.ClickYes()
        end
        F.HogyokuQuest = false S.HogyokuStep = 0 S.HogyokuCollected = {}
        if S.HogyokuToggle then pcall(function() S.HogyokuToggle:SetValue(false) end) end
        Notify("Hogyoku: Complete! Soul Society unlocked!")
        return
    end
    local island = S.HogyokuFragmentIslands[step]
    if not island then S.HogyokuStep = step+1 return end
    if S.HogyokuCollected and S.HogyokuCollected[step] then S.HogyokuStep = step+1 return end
    fn.StopTw() fn.ClearTgt()
    fn.ForceTP(island)
    task.wait(0.5) fn.WaitChar() task.wait(0.5)
    local prompt = fn.FindHogyokuFragment(step)
    if not prompt then task.wait(1) prompt = fn.FindHogyokuFragment(step) end
    if not prompt then task.wait(1) prompt = fn.FindHogyokuFragment(step) end
    if prompt then
        local hrp = fn.PlayerHRP()
        local par = prompt.Parent
        if par and hrp then
            local pos = par:IsA("BasePart") and par.Position or par:IsA("Model") and fn.ModelPos(par) or nil
            if pos then hrp.CFrame = CFrame.new(pos+Vector3.new(0,2,0)) end
        end
        task.wait(0.1)
        pcall(function() fireproximityprompt(prompt) end)
        task.wait(0.15)
        pcall(function() fireproximityprompt(prompt) end)
        if not S.HogyokuCollected then S.HogyokuCollected = {} end
        S.HogyokuCollected[step] = true
        S.HogyokuStep = step+1
    else
        Notify("Hogyoku: Fragment #"..step.." not found — retrying")
    end
end

fn.ScanDungeonDebug = function()
    local lines = {}
    table.insert(lines,"== QUEST STATE ==")
    local collectedStr = "" for k in pairs(S.DungeonCollected or {}) do collectedStr = collectedStr..k.."," end
    table.insert(lines,"Step: "..S.DungeonStep.." | Collected: {"..collectedStr.."} | Flag: "..tostring(F.DungeonQuest))
    table.insert(lines,"== DUNGEON PIECES (detail) ==")
    local ct = 0
    for _,desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name=="DungeonPuzzlePiece" and ct<10 then
            ct = ct+1
            local info = desc.Name.." ["..desc.ClassName.."] in "..(desc.Parent and desc.Parent.Name or "?")
            pcall(function() info = info.." Trans="..desc.Transparency end)
            pcall(function() info = info.." CC="..tostring(desc.CanCollide) end)
            pcall(function() info = info.." Anch="..tostring(desc.Anchored) end)
            pcall(function() 
                if desc:IsA("BasePart") then 
                    info = info.." Pos="..math.floor(desc.Position.X)..","..math.floor(desc.Position.Y)..","..math.floor(desc.Position.Z) 
                end 
            end)
            local kids = {} 
            for _,ch in ipairs(desc:GetChildren()) do 
                table.insert(kids,ch.Name.."["..ch.ClassName.."]") 
            end
            info = info.." Children={"..table.concat(kids,",").."}"
            local touchConns = 0 
            pcall(function() touchConns = #getconnections(desc.Touched) end)
            info = info.." TouchConns="..touchConns
            table.insert(lines,info)
        end
    end
    if ct==0 then table.insert(lines,"(no DungeonPuzzlePiece found)") end
    table.insert(lines,"== ALL DUNGEON/PUZZLE OBJECTS ==")
    local ct2 = 0
    for _,desc in ipairs(Workspace:GetDescendants()) do
        local nm = (desc.Name or ""):lower()
        if (nm:find("dungeon") or nm:find("puzzle")) and not(desc.Name=="DungeonPuzzlePiece") and ct2<20 then
            ct2 = ct2+1
            local info = desc.Name.." ["..desc.ClassName.."]"
            if desc.Parent then info = info.." in "..desc.Parent.Name end
            if desc:IsA("ProximityPrompt") then info = info.." Action="..(desc.ActionText or "").." Obj="..(desc.ObjectText or "") end
            table.insert(lines,info)
        end
    end
    if ct2==0 then table.insert(lines,"(none)") end
    table.insert(lines,"== NEARBY PROMPTS (<200 studs) ==")
    local hrp = fn.PlayerHRP() local pc = 0
    if hrp then
        for _,desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and pc<20 then
                local par = desc.Parent local pos = nil
                if par and par:IsA("BasePart") then pos = par.Position 
                elseif par and par:IsA("Model") then pos = fn.ModelPos(par) end
                if pos and (hrp.Position-pos).Magnitude<200 then
                    pc = pc+1
                    table.insert(lines,(par and par.Name or "?").." Action="..(desc.ActionText or "").." Obj="..(desc.ObjectText or "").." d="..math.floor((hrp.Position-pos).Magnitude))
                end
            end
        end
    end
    if pc==0 then table.insert(lines,"(none)") end
    table.insert(lines,"== ALL REMOTES (dungeon/puzzle/quest) ==")
    local rc = 0
    pcall(function()
        for _,desc in ipairs(ReplicatedStorage:GetDescendants()) do
            local nm = (desc.Name or ""):lower()
            if (nm:find("quest") or nm:find("dungeon") or nm:find("puzzle") or nm:find("piece") or nm:find("collect")) and (desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction")) then
                rc = rc+1 table.insert(lines,desc.Name.." ["..desc.ClassName.."] in "..(desc.Parent and desc.Parent.Name or "?"))
            end
        end
    end)
    if rc==0 then table.insert(lines,"(none)") end
    table.insert(lines,"== QUEST UI (PlayerGui) ==")
    local uc = 0
    pcall(function()
        local pg = Player:FindFirstChild("PlayerGui") if not pg then return end
        for _,desc in ipairs(pg:GetDescendants()) do
            if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and uc<15 then
                local txt = (desc.Text or ""):lower()
                if txt:find("dungeon") or txt:find("quest") or txt:find("piece") or txt:find("collect") or txt:find("puzzle") then
                    uc = uc+1 table.insert(lines,desc.Name..": "..(desc.Text or ""):sub(1,80))
                end
            end
        end
    end)
    if uc==0 then table.insert(lines,"(none)") end
    return table.concat(lines,"\n")
end

fn.ScanHogyokuDebug = function()
    local lines = {}
    table.insert(lines,"========== HOGYOKU MEGA DEBUG ==========")
    table.insert(lines,"== QUEST STATE ==")
    local collectedStr = "" for k in pairs(S.HogyokuCollected or {}) do collectedStr = collectedStr..k.."," end
    table.insert(lines,"Step: "..S.HogyokuStep.." | Collected: {"..collectedStr.."} | Flag: "..tostring(F.HogyokuQuest))
    table.insert(lines,"Islands: "..table.concat(S.HogyokuFragmentIslands,", "))
    table.insert(lines,"")
    table.insert(lines,"== WORKSPACE TOP-LEVEL CHILDREN ==")
    pcall(function()
        for _,ch in ipairs(Workspace:GetChildren()) do
            table.insert(lines,ch.Name.." ["..ch.ClassName.."]")
        end
    end)
    table.insert(lines,"")
    table.insert(lines,"== KEYWORD SEARCH (hogyoku/fragment/orb/shard/piece/puzzle/soul/unlock) ==")
    local ct = 0
    for _,desc in ipairs(Workspace:GetDescendants()) do
        local nm = (desc.Name or ""):lower()
        if (nm:find("hogyoku") or nm:find("fragment") or nm:find("orb") or nm:find("shard") or nm:find("puzzle") and not nm:find("dungeonpuzzle")) and ct<60 then
            ct = ct+1
            local info = ct..") "..desc.Name.." ["..desc.ClassName.."]"
            if desc.Parent then info = info.." in "..desc.Parent.Name end
            if desc:IsA("BasePart") then
                pcall(function() info = info.." Pos="..math.floor(desc.Position.X)..","..math.floor(desc.Position.Y)..","..math.floor(desc.Position.Z) end)
                pcall(function() info = info.." Trans="..desc.Transparency end)
            elseif desc:IsA("Model") then
                pcall(function() local p = fn.ModelPos(desc) if p then info = info.." Pos="..math.floor(p.X)..","..math.floor(p.Y)..","..math.floor(p.Z) end end)
            end
            local kids = {} 
            for _,ch in ipairs(desc:GetChildren()) do 
                table.insert(kids,ch.Name.."["..ch.ClassName.."]") 
            end
            if #kids>0 then info = info.." Children={"..table.concat(kids,",").."}" end
            local hasPrompt = false
            pcall(function() 
                for _,ch in ipairs(desc:GetDescendants()) do 
                    if ch:IsA("ProximityPrompt") then hasPrompt = true break end 
                end 
            end)
            pcall(function() if desc:FindFirstChildOfClass("ProximityPrompt") then hasPrompt = true end end)
            info = info.." Prompt="..tostring(hasPrompt)
            local path = {} 
            local anc = desc.Parent
            while anc and anc~=Workspace do 
                table.insert(path,1,anc.Name) 
                anc = anc.Parent 
            end
            info = info.." Path="..table.concat(path,"/")
            table.insert(lines,info)
        end
    end
    if ct==0 then table.insert(lines,"(NOTHING found with these keywords)") end
    table.insert(lines,"")
    table.insert(lines,"== EVERY PROXIMITYPROMPT IN WORKSPACE ==")
    local pc = 0
    for _,desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and pc<80 then
            pc = pc+1
            local par = desc.Parent
            local info = pc..") Parent="..((par and par.Name) or "?").." ["..((par and par.ClassName) or "?").."]"
            info = info.." Action="..(desc.ActionText or "").." Obj="..(desc.ObjectText or "")
            local pos = nil
            if par and par:IsA("BasePart") then pos = par.Position 
            elseif par and par:IsA("Model") then pos = fn.ModelPos(par) end
            if pos then info = info.." Pos="..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z) end
            local path = {} 
            local anc = par
            while anc and anc~=Workspace do 
                table.insert(path,1,anc.Name) 
                anc = anc.Parent 
            end
            info = info.." Path="..table.concat(path,"/")
            table.insert(lines,info)
        end
    end
    if pc==0 then table.insert(lines,"(no ProximityPrompts in workspace)") end
    table.insert(lines,"")
    table.insert(lines,"== PLAYER DATA (leaderstats/QuestData/values) ==")
    pcall(function()
        for _,ch in ipairs(Player:GetChildren()) do
            if ch:IsA("Folder") or ch:IsA("StringValue") or ch:IsA("IntValue") or ch:IsA("NumberValue") or ch:IsA("BoolValue") or ch:IsA("ObjectValue") then
                local info = ch.Name.." ["..ch.ClassName.."]"
                pcall(function() info = info.." Val="..tostring(ch.Value) end)
                table.insert(lines,info)
                if ch:IsA("Folder") then
                    for _,sub in ipairs(ch:GetChildren()) do
                        local si = "  "..sub.Name.." ["..sub.ClassName.."]"
                        pcall(function() si = si.." Val="..tostring(sub.Value) end)
                        table.insert(lines,si)
                    end
                end
            end
        end
    end)
    table.insert(lines,"")
    table.insert(lines,"== ALL REMOTES IN REPLICATEDSTORAGE ==")
    local rc = 0
    pcall(function()
        for _,desc in ipairs(ReplicatedStorage:GetDescendants()) do
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                rc = rc+1 table.insert(lines,rc..") "..desc.Name.." ["..desc.ClassName.."] in "..(desc.Parent and desc.Parent.Name or "?"))
            end
        end
    end)
    if rc==0 then table.insert(lines,"(none)") end
    table.insert(lines,"")
    table.insert(lines,"== NPCs NEAR PLAYER (<500 studs) ==")
    local nc = 0
    pcall(function()
        local hrp = fn.PlayerHRP()
        if hrp then
            for _,desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and desc~=Player.Character and nc<30 then
                    local pos = fn.ModelPos(desc)
                    if pos and (hrp.Position-pos).Magnitude<500 then
                        nc = nc+1
                        local d = math.floor((hrp.Position-pos).Magnitude)
                        local hasPrompt = false
                        for _,ch in ipairs(desc:GetDescendants()) do 
                            if ch:IsA("ProximityPrompt") then hasPrompt = true break end 
                        end
                        table.insert(lines,nc..") "..desc.Name.." d="..d.." Prompt="..tostring(hasPrompt))
                    end
                end
            end
        end
    end)
    if nc==0 then table.insert(lines,"(none)") end
    table.insert(lines,"")
    table.insert(lines,"== QUEST UI (PlayerGui — hogyoku/fragment/quest/unlock/soul/collect) ==")
    local uc = 0
    pcall(function()
        local pg = Player:FindFirstChild("PlayerGui") if not pg then return end
        for _,desc in ipairs(pg:GetDescendants()) do
            if (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("Frame") or desc:IsA("ImageLabel")) and uc<30 then
                local txt = "" pcall(function() txt = (desc.Text or ""):lower() end)
                local nm = (desc.Name or ""):lower()
                if txt:find("hogyoku") or txt:find("fragment") or txt:find("quest") or txt:find("unlock") or txt:find("soul") or txt:find("collect") or txt:find("orb")
                    or nm:find("hogyoku") or nm:find("fragment") or nm:find("quest") or nm:find("unlock") or nm:find("soul") or nm:find("collect") or nm:find("orb") then
                    uc = uc+1
                    local info = desc.Name.." ["..desc.ClassName.."]"
                    pcall(function() if desc.Text and #desc.Text>0 then info = info.." Text=\""..(desc.Text):sub(1,120).."\"" end end)
                    pcall(function() if desc.Visible~=nil then info = info.." Vis="..tostring(desc.Visible) end end)
                    table.insert(lines,uc..") "..info)
                end
            end
        end
    end)
    if uc==0 then table.insert(lines,"(none)") end
    return table.concat(lines,"\n")
end

--==================================================
-- UI TABS & SECTIONS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "sword",
    Glass = true,
    Outline = true
})

local GamemodesTab = Window:MakeTab({
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

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- MAIN TAB
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName .. "\n" ..
           "User ID: " .. Player.UserId .. "\n" ..
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

--==================================================
-- FARM TAB
--==================================================
local FarmSection = FarmTab:AddSection({
    Name = "⚡ AUTO FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

S.FarmToggle = FarmSection:AddToggle({
    Name = "ENABLE AUTO FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoFarmLevel",
    Save = true,
    Callback = function(Value)
        if Value and (F.AutoDungeon or F.AutoBossRush) then
            task.defer(function() pcall(function() S.FarmToggle:SetValue(false) end) end)
            return
        end
        if Value and fn.HasDungeonEnemiesInWorkspace() then
            task.defer(function() pcall(function() S.FarmToggle:SetValue(false) end) end)
            return
        end
        F.AutoFarmLevel = Value
        if Value then
            if F.AutoDungeon then
                F.AutoDungeon = false
                for _,dt in ipairs(S.DungeonTypes) do 
                    if S.DungeonToggles and S.DungeonToggles[dt] then 
                        pcall(function() S.DungeonToggles[dt]:SetValue(false) end) 
                    end 
                end
            end
            S.LastDungeonSwitch = 0
            fn.StopTw()
            fn.ClearTgt()
            S.CurIsland = nil S.IslandTPd = false S.SpawnDone = false S.FarmOrigin = nil S.FarmGenericMode = false S.QState = "NONE" S.CurTarget = nil S.LockTarget = nil S.HoverPos = nil S.LastEnemy = 0
        else
            fn.FullReset()
        end
    end
})

S.FarmKeybind = FarmSection:AddKeybind({
    Name = "FARM KEYBIND",
    Default = "V",
    Outline = true,
    Flag = "FarmKeybind",
    Save = true,
    Callback = function(Value) end
})

FarmSection:AddToggle({
    Name = "AUTO EQUIP WEAPON",
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
    Callback = function(Value) 
        F.AutoQuest = Value 
        if Value and F.AutoFarmLevel then 
            task.spawn(fn.EnableGameQuestRepeat) 
        end 
    end
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
        S.SpawnDone = false 
    end
})

FarmSection:AddDropdown({
    Name = "FARM ZONE",
    Default = "Auto",
    Options = fn.GetIslandNames(),
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedIsland",
    Save = true,
    Callback = function(Value)
        local portal = fn.DisplayToPortal(Value)
        F.SelectedIsland = portal
        fn.StopTw() fn.ClearTgt() S.HoverPos = nil S.LockTarget = nil
        S.CurIsland = nil S.IslandTPd = false S.SpawnDone = false S.FarmOrigin = nil S.FarmGenericMode = false S.LastEnemy = 0
        S.CurTarget = nil S.LastTP = 0 S.TPCount = 0 S.TPReset = tick()
        S.QState = "NONE"
        fn.AbandonAllQuests()
        Notify("Island Changed: Now farming "..Value)
    end
})

FarmSection:AddDropdown({
    Name = "STAND POSITION",
    Default = "Behind",
    Options = {"Behind", "In Front", "Left Side", "Right Side"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "FarmMode",
    Save = true,
    Callback = function(Value) 
        F.FarmMode = Value 
        fn.ClearTgt() 
        S.HoverPos = nil 
    end
})

FarmSection:AddDropdown({
    Name = "COMBAT STYLE",
    Default = "Dodge",
    Options = {"Dodge", "Static", "Orbit", "Strafe"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "FollowStyle",
    Save = true,
    Callback = function(Value) 
        F.FollowStyle = Value 
        F.DodgeMode = (Value=="Dodge") 
    end
})

FarmSection:AddDropdown({
    Name = "TRAVEL MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "MoveMode",
    Save = true,
    Callback = function(Value) 
        F.MoveMode = Value 
        fn.ClearTgt() 
        S.HoverPos = nil 
        if Value~="Walk" then fn.RestoreWalkSpeed() end 
    end
})

FarmSection:AddSlider({
    Name = "OFFSET DISTANCE",
    Min = 5,
    Max = 50,
    Default = 25,
    Increment = 1,
    ValueName = "m",
    Outline = true,
    Flag = "OffsetDist",
    Save = true,
    Callback = function(Value) F.OffsetDist = Value end
})

FarmSection:AddSlider({
    Name = "MOVEMENT SPEED",
    Min = 15,
    Max = 200,
    Default = 100,
    Increment = 5,
    ValueName = "WS",
    Outline = true,
    Flag = "TweenSpeed",
    Save = true,
    Callback = function(Value) 
        F.TweenSpeed = Value 
        fn.StopTw() 
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

FarmSection:AddButton({
    Name = "SCAN ALL NPCS",
    Outline = true,
    Callback = function()
        local isl = S.CurIsland or fn.IslandForLevel(fn.GetLevel())
        local en = fn.FindEnemies(isl)
        local nf = fn.GetNPCFolder() 
        local all = {}
        if nf then 
            local ct = {} 
            local function addModel(m) 
                if m:IsA("Model") then 
                    ct[m.Name] = (ct[m.Name] or 0)+1 
                end 
            end 
            for _,child in ipairs(nf:GetChildren()) do 
                if child:IsA("Folder") then 
                    for _,m in ipairs(child:GetChildren()) do 
                        addModel(m) 
                    end 
                else 
                    addModel(child) 
                end 
            end 
            for n,c in pairs(ct) do 
                table.insert(all,n.." x"..c) 
            end 
            table.sort(all) 
        end
        Notify("Matched: "..#en.." ("..isl.Portal..")")
    end
})

-- Teleport Section
local TeleportSection = FarmTab:AddSection({
    Name = "📍 TELEPORT TO ISLAND",
    TextSize = 18,
    Glass = true,
    Outline = true
})

for _, islandName in ipairs(S.TpIslands) do
    local displayName = S.PortalDisplayNames[islandName] or islandName
    TeleportSection:AddButton({
        Name = "🚀 " .. displayName,
        Outline = true,
        Callback = function()
            if F.AutoFarmLevel then 
                Notify("Auto Farm is ON — disable before teleporting") 
                return 
            end
            fn.ForceTP(islandName)
            Notify("Teleporting to "..displayName)
        end
    })
end

-- Boss Farm Section
local BossSection = FarmTab:AddSection({
    Name = "👾 AUTO FARM BOSS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

S.BossToggle = BossSection:AddToggle({
    Name = "ENABLE BOSS KILLING",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossEnabled",
    Save = true,
    Callback = function(Value)
        if Value and (F.AutoDungeon or F.AutoBossRush) then
            task.defer(function() pcall(function() S.BossToggle:SetValue(false) end) end)
            return
        end
        if Value and fn.HasDungeonEnemiesInWorkspace() then
            task.defer(function() pcall(function() S.BossToggle:SetValue(false) end) end)
            return
        end
        F.BossEnabled = Value
        if not Value and S.BossFight then fn.ExitBossMode(S.BossTargetName) end
    end
})

S.BossKeybind = BossSection:AddKeybind({
    Name = "BOSS KEYBIND",
    Default = "B",
    Outline = true,
    Flag = "BossKeybind",
    Save = true,
    Callback = function(Value) end
})

BossSection:AddToggle({
    Name = "BOSS NOTIFICATIONS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossNotify",
    Save = true,
    Callback = function(Value) F.BossNotify = Value end
})

for _, bDef in ipairs(S.Bosses) do
    BossSection:AddToggle({
        Name = bDef.Display .. " (" .. bDef.Island .. ")",
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Boss_" .. bDef.Name,
        Save = true,
        Callback = function(Value) S.BF[bDef.Name] = Value end
    })
end

S.BossInfoP = BossSection:AddParagraph({
    Title = "BOSS TIMERS",
    Desc = "Scanning...",
    Image = "timer",
    ImageSize = 30
})

-- Summon Boss Section
local SummonSection = FarmTab:AddSection({
    Name = "✨ SUMMON BOSS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

S.SummonBossKeybind = SummonSection:AddKeybind({
    Name = "SUMMON KEYBIND",
    Default = "N",
    Outline = true,
    Flag = "SummonKeybind",
    Save = true,
    Callback = function(Value) end
})

for _, bDef in ipairs(S.SummonBosses) do
    local islandText = bDef.Island and " (" .. (S.PortalDisplayNames[bDef.Island] or bDef.Island) .. ")" or ""
    S.BSFToggle[bDef.Name] = SummonSection:AddToggle({
        Name = bDef.Display .. islandText,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "SummonBoss_" .. bDef.Name,
        Save = true,
        Callback = function(Value)
            if Value and (F.AutoDungeon or F.AutoBossRush or fn.HasDungeonEnemiesInWorkspace()) then
                task.defer(function() 
                    if S.BSFToggle[bDef.Name] then
                        pcall(function() S.BSFToggle[bDef.Name]:SetValue(false) end)
                    end
                end)
                return
            end
            if Value then
                for _,ob in ipairs(S.SummonBosses) do
                    if ob.Name~=bDef.Name then
                        S.BSF[ob.Name] = false
                        if S.BSFToggle[ob.Name] then pcall(function() S.BSFToggle[ob.Name]:SetValue(false) end) end
                    end
                end
                fn.ExitSummonBossMode()
                task.wait(0.3)
                S.BSF[bDef.Name] = true
                S.SummonBossFailCount[bDef.Name] = nil
            else
                S.BSF[bDef.Name] = false
                fn.DisableAutoSpawn(bDef.Name)
                S.SummonBossCommitted[bDef.Name] = nil
                S.SummonBossFireTime[bDef.Name] = nil
                if S.SummonBossTarget==bDef.Name then 
                    S.SummonBossTarget = nil 
                    fn.ClearTgt() 
                end
                if not fn.HasAnySummonBossEnabled() then
                    fn.ExitSummonBossMode()
                end
            end
        end
    })
    
    if bDef.Difficulties then
        SummonSection:AddDropdown({
            Name = bDef.Display .. " Difficulty",
            Default = "Normal",
            Options = bDef.Difficulties,
            Multi = false,
            Search = false,
            Outline = true,
            Flag = "SummonDiff_" .. bDef.Name,
            Save = true,
            Callback = function(Value)
                if bDef.Name=="GilgameshBoss" then F.GilgameshDiff = Value end
                if bDef.Name=="BlessedMaidenBoss" then F.BlessedMaidenDiff = Value end
                if bDef.Name=="SaberAlterBoss" then F.SaberAlterDiff = Value end
                if bDef.Name=="RimuruBoss" then F.RimuruDiff = Value end
                if bDef.Name=="AnosBoss" then F.AnosDiff = Value end
                if bDef.Name=="StrongestTodayBoss" then F.StrongestTodayDiff = Value end
                if bDef.Name=="StrongestHistoryBoss" then F.StrongestHistoryDiff = Value end
                if bDef.Name=="TrueAizenBoss" then F.TrueAizenDiff = Value end
            end
        })
    end
end

--==================================================
-- GAMEMODES TAB
--==================================================
local DungeonSection = GamemodesTab:AddSection({
    Name = "⚔️ AUTO DUNGEONS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local dungeonTypeMap = {
    ["Shadow Dungeon"] = "Double",
    ["Rune Dungeon"] = "Rune",
    ["Cid Dungeon"] = "Cid"
}

DungeonSection:AddDropdown({
    Name = "DUNGEON TYPE",
    Default = "Shadow Dungeon",
    Options = {"Shadow Dungeon", "Rune Dungeon", "Cid Dungeon"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "DungeonType",
    Save = true,
    Callback = function(Value)
        local dt = dungeonTypeMap[Value] or "Double"
        if F.AutoDungeon then 
            fn.EnableDungeonType(dt,true) 
        else 
            F.DungeonType = dt 
        end
    end
})

S.DungeonUnifiedToggle = DungeonSection:AddToggle({
    Name = "ENABLE AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value) 
        fn.EnableDungeonType(F.DungeonType or "Double",Value) 
    end
})

DungeonSection:AddDropdown({
    Name = "DIFFICULTY",
    Default = "Normal",
    Options = S.DungeonDifficulties,
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "DungeonDiff",
    Save = true,
    Callback = function(Value) 
        F.DungeonDiff = Value 
        task.spawn(fn.FireDungeonVote) 
    end
})

DungeonSection:AddDropdown({
    Name = "STAND POSITION",
    Default = "Behind",
    Options = {"Behind", "In Front", "Left Side", "Right Side"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "DungeonFarmMode",
    Save = true,
    Callback = function(Value) 
        F.FarmMode = Value 
        fn.ClearTgt() 
        S.HoverPos = nil 
    end
})

DungeonSection:AddDropdown({
    Name = "TRAVEL MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "DungeonMove",
    Save = true,
    Callback = function(Value) 
        F.MoveMode = Value 
        fn.ClearTgt() 
        S.HoverPos = nil 
        if Value~="Walk" then fn.RestoreWalkSpeed() end 
    end
})

DungeonSection:AddDropdown({
    Name = "COMBAT STYLE",
    Default = "Dodge",
    Options = {"Dodge", "Static", "Orbit", "Strafe"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "DungeonFollowStyle",
    Save = true,
    Callback = function(Value) 
        F.FollowStyle = Value 
        F.DodgeMode = (Value=="Dodge") 
    end
})

DungeonSection:AddSlider({
    Name = "OFFSET DISTANCE",
    Min = 5,
    Max = 50,
    Default = 25,
    Increment = 1,
    ValueName = "m",
    Outline = true,
    Flag = "DungeonOffsetDist",
    Save = true,
    Callback = function(Value) F.OffsetDist = Value end
})

DungeonSection:AddSlider({
    Name = "MOVEMENT SPEED",
    Min = 20,
    Max = 250,
    Default = 100,
    Increment = 5,
    ValueName = "WS",
    Outline = true,
    Flag = "DungeonSpeed",
    Save = true,
    Callback = function(Value) F.TweenSpeed = Value end
})

local AutoJoinSection = GamemodesTab:AddSection({
    Name = "🚪 AUTO-JOIN DUNGEON",
    TextSize = 18,
    Glass = true,
    Outline = true
})

AutoJoinSection:AddToggle({
    Name = "AUTO-JOIN SHADOW DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoJoinDouble",
    Save = true,
    Callback = function(Value) 
        S.AutoJoinDungeon["Double"] = Value 
        if Value then 
            S.AutoJoinFired["Double"] = true 
            task.spawn(function() fn.FireDungeonPortal("Double") end) 
        else 
            S.AutoJoinFired["Double"] = nil 
        end 
    end
})

AutoJoinSection:AddToggle({
    Name = "AUTO-JOIN RUNE DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoJoinRune",
    Save = true,
    Callback = function(Value) 
        S.AutoJoinDungeon["Rune"] = Value 
        if Value then 
            S.AutoJoinFired["Rune"] = true 
            task.spawn(function() fn.FireDungeonPortal("Rune") end) 
        else 
            S.AutoJoinFired["Rune"] = nil 
        end 
    end
})

AutoJoinSection:AddToggle({
    Name = "AUTO-JOIN CID DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoJoinCid",
    Save = true,
    Callback = function(Value) 
        S.AutoJoinDungeon["Cid"] = Value 
        if Value then 
            S.AutoJoinFired["Cid"] = true 
            task.spawn(function() fn.FireDungeonPortal("Cid") end) 
        else 
            S.AutoJoinFired["Cid"] = nil 
        end 
    end
})

local BossRushSection = GamemodesTab:AddSection({
    Name = "⚡ BOSS RUSH",
    TextSize = 18,
    Glass = true,
    Outline = true
})

S.BossRushAutoToggle = BossRushSection:AddToggle({
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
            if S.FarmToggle then pcall(function() S.FarmToggle:SetValue(false) end) end
            F.AutoDungeon = false
            S.LastDungeonSwitch = 0
            for _,dt in ipairs(S.DungeonTypes) do 
                if S.DungeonToggles and S.DungeonToggles[dt] then 
                    pcall(function() S.DungeonToggles[dt]:SetValue(false) end) 
                end 
            end
            F.BossEnabled = false
            if S.BossToggle then pcall(function() S.BossToggle:SetValue(false) end) end
            for _,ob in ipairs(S.SummonBosses) do
                if S.BSF[ob.Name] then
                    S.BSF[ob.Name] = false
                    fn.DisableAutoSpawn(ob.Name)
                    S.SummonBossCommitted[ob.Name] = nil
                    S.SummonBossFireTime[ob.Name] = nil
                    if S.BSFToggle[ob.Name] then
                        pcall(function() S.BSFToggle[ob.Name]:SetValue(false) end)
                    end
                end
            end
            if S.BossFight then
                S.BossFight = false
                S.BossTargetName = nil
                S.BossTPDone = false
            end
            if S.SummonBossFight then fn.ExitSummonBossMode() end
            S.CurTarget = nil
            S.LockTarget = nil
            S.HoverPos = nil
            S.LastBossRushSwitch = 0
            fn.StopTw()
        else
            S.CurTarget = nil S.LockTarget = nil S.HoverPos = nil S.LastBossRushSwitch = 0
            fn.StopTw()
        end
    end
})

BossRushSection:AddToggle({
    Name = "AUTO-JOIN BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoJoinBossRush",
    Save = true,
    Callback = function(Value) 
        S.AutoJoinBossRush = Value 
        if Value then 
            S.AutoJoinBossRushFired = true 
            task.spawn(function() 
                pcall(function() 
                    local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.DungeonPortal)) 
                    if r then r:FireServer("BossRush") end 
                end) 
            end) 
        else 
            S.AutoJoinBossRushFired = false 
        end 
    end
})

BossRushSection:AddDropdown({
    Name = "STAND POSITION",
    Default = "Behind",
    Options = {"Behind", "In Front", "Left Side", "Right Side"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "BossRushFarmMode",
    Save = true,
    Callback = function(Value) 
        F.BossRushFarmMode = Value 
        F.FarmMode = Value 
    end
})

BossRushSection:AddDropdown({
    Name = "TRAVEL MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "BossRushMoveMode",
    Save = true,
    Callback = function(Value) 
        F.BossRushMoveMode = Value 
        F.MoveMode = Value 
    end
})

BossRushSection:AddDropdown({
    Name = "COMBAT STYLE",
    Default = "Dodge",
    Options = {"Dodge", "Static", "Orbit", "Strafe"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "BossRushFollowStyle",
    Save = true,
    Callback = function(Value) 
        F.BossRushFollowStyle = Value 
        F.FollowStyle = Value 
        F.DodgeMode = (Value=="Dodge") 
    end
})

BossRushSection:AddSlider({
    Name = "OFFSET DISTANCE",
    Min = 5,
    Max = 50,
    Default = 25,
    Increment = 1,
    ValueName = "m",
    Outline = true,
    Flag = "BossRushOffsetDist",
    Save = true,
    Callback = function(Value) F.OffsetDist = Value end
})

BossRushSection:AddSlider({
    Name = "MOVEMENT SPEED",
    Min = 20,
    Max = 250,
    Default = 50,
    Increment = 5,
    ValueName = "WS",
    Outline = true,
    Flag = "BossRushTweenSpeed",
    Save = true,
    Callback = function(Value) F.BossRushTweenSpeed = Value end
})

--==================================================
-- SKILLS TAB
--==================================================
local SkillsMainSection = SkillsTab:AddSection({
    Name = "⚡ AUTO SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

S.AllSkillsToggle = SkillsMainSection:AddToggle({
    Name = "ALL SKILLS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AllSkills",
    Save = true,
    Callback = function(Value)
        for _,k in ipairs(S.SkillKeys) do
            local tgl = S.SkillToggles[k]
            if tgl then pcall(function() tgl:SetValue(Value) end) else F[k] = Value end
        end
    end
})

S.AllSkillsKeybind = SkillsMainSection:AddKeybind({
    Name = "ALL SKILLS KEYBIND",
    Default = "M",
    Outline = true,
    Flag = "AllSkillsKeybind",
    Save = true,
    Callback = function(Value) end
})

local function createSkillToggle(skillKey, displayName)
    S.SkillToggles[skillKey] = SkillsMainSection:AddToggle({
        Name = "SKILL " .. displayName,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = skillKey,
        Save = true,
        Callback = function(Value) F[skillKey] = Value end
    })
end

createSkillToggle("SkillZ", "Z")
createSkillToggle("SkillX", "X")
createSkillToggle("SkillC", "C")
createSkillToggle("SkillV", "V")
createSkillToggle("SkillF", "F (Nuke)")

SkillsMainSection:AddSlider({
    Name = "SKILL COOLDOWN",
    Min = 0.3,
    Max = 5,
    Default = 1.0,
    Increment = 0.1,
    ValueName = "s",
    Outline = true,
    Flag = "SkillCooldown",
    Save = true,
    Callback = function(Value) F.SkillCooldown = Value end
})

local ChestSection = SkillsTab:AddSection({
    Name = "📦 AUTO CHEST",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ChestSection:AddToggle({
    Name = "AUTO OPEN CHESTS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(Value) F.AutoChest = Value end
})

for _, chest in ipairs(S.ChestNames) do
    ChestSection:AddToggle({
        Name = chest,
        Default = true,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Chest_" .. chest:gsub(" ", "_"),
        Save = true,
        Callback = function(Value) S.FC[chest] = Value end
    })
end

--==================================================
-- QUESTS TAB
--==================================================
local QuestsSection = QuestsTab:AddSection({
    Name = "🔓 UNLOCK QUESTS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

S.DungeonToggle = QuestsSection:AddToggle({
    Name = "DUNGEON PIECES INFO",
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
                S.HogyokuStep = 0 
                S.HogyokuCollected = {}
                fn.AbandonHogyokuQuest()
                if S.HogyokuToggle then pcall(function() S.HogyokuToggle:SetValue(false) end) end
                Notify("Hogyoku Quest Disabled — only one quest at a time")
            end
            S.DungeonStep = 0 S.DungeonCollected = {}
            fn.StopTw() fn.ClearTgt() S.HoverPos = nil S.LockTarget = nil
            S.LastTP = 0 S.TPCount = 0 S.TPReset = tick()
            if S.SummonBossFight then fn.ExitSummonBossMode() end
            if S.BossFight then S.BossFight = false S.BossTargetName = nil S.BossTPDone = false end
            fn.ClearTgt() S.HoverPos = nil
            Notify("Dungeon Quest: Starting dungeon unlock quest")
        else
            S.DungeonStep = 0 S.DungeonCollected = {}
            fn.StopTw() fn.ClearTgt() S.HoverPos = nil S.LockTarget = nil
            S.LastTP = 0 S.TPCount = 0 S.TPReset = tick()
            fn.AbandonDungeonQuest()
            fn.ClearTgt() S.HoverPos = nil
            Notify("Dungeon Quest: Quest abandoned")
        end
    end
})

QuestsSection:AddHelper({
    Text = "Collect 6 puzzle pieces across islands: Starter → Jungle → Desert → Snow → Shibuya → Hueco Mundo"
})

S.HogyokuToggle = QuestsSection:AddToggle({
    Name = "HOGYOKU FRAGMENTS INFO",
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
                S.DungeonStep = 0 S.DungeonCollected = {}
                fn.AbandonDungeonQuest()
                if S.DungeonToggle then pcall(function() S.DungeonToggle:SetValue(false) end) end
                Notify("Dungeon Quest Disabled — only one quest at a time")
            end
            S.HogyokuStep = 0 S.HogyokuCollected = {}
            fn.StopTw() fn.ClearTgt() S.HoverPos = nil S.LockTarget = nil
            S.LastTP = 0 S.TPCount = 0 S.TPReset = tick()
            if S.SummonBossFight then fn.ExitSummonBossMode() end
            if S.BossFight then S.BossFight = false S.BossTargetName = nil S.BossTPDone = false end
            fn.ClearTgt() S.HoverPos = nil
            Notify("Hogyoku Quest: Starting Hogyoku fragment quest")
        else
            S.HogyokuStep = 0 S.HogyokuCollected = {}
            fn.StopTw() fn.ClearTgt() S.HoverPos = nil S.LockTarget = nil
            S.LastTP = 0 S.TPCount = 0 S.TPReset = tick()
            fn.AbandonHogyokuQuest()
            fn.ClearTgt() S.HoverPos = nil
            Notify("Hogyoku Quest: Quest abandoned")
        end
    end
})

QuestsSection:AddHelper({
    Text = "Collect 6 Hogyoku fragments to unlock Soul Society: Snow → Shibuya → Hueco Mundo → Shinjuku → Slime → Judgement"
})

QuestsSection:AddParagraph({
    Title = "QUEST INFO",
    Desc = "Dungeon Pieces: Accepts quest remotely\nCollects 6 pieces across islands\nReturns to Dungeon Master\n\nHogyoku Fragments: Accepts quest remotely\nCollects 6 fragments\nReturns to Gin (Hueco Mundo)",
    Image = "info",
    ImageSize = 30
})

local QDbgSec = QuestsTab:AddSection({
    Name = "🔍 QUEST DEBUG",
    TextSize = 18,
    Glass = true,
    Outline = true
})

QDbgSec:AddButton({
    Name = "SCAN DUNGEON DEBUG",
    Outline = true,
    Callback = function()
        local result = fn.ScanDungeonDebug()
        Notify("Dungeon Debug: "..result:sub(1,500))
    end
})

QDbgSec:AddButton({
    Name = "SCAN HOGYOKU DEBUG",
    Outline = true,
    Callback = function()
        local result = fn.ScanHogyokuDebug()
        Notify("Hogyoku Debug: "..result:sub(1,500))
    end
})

--==================================================
-- MERCHANT TAB
--==================================================
local MerchantMainSection = MerchantTab:AddSection({
    Name = "🏪 AUTO MERCHANT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MerchantMainSection:AddToggle({
    Name = "ENABLE AUTO MERCHANT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoMerchant",
    Save = true,
    Callback = function(Value) 
        F.AutoMerchant = Value 
        if Value then S.LastMerchant = 0 end 
    end
})

MerchantMainSection:AddToggle({
    Name = "MERCHANT NOTIFICATION",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "MerchNotify",
    Save = true,
    Callback = function(Value) F.MerchNotify = Value end
})

MerchantMainSection:AddHelper({
    Text = "Buys all selected items in one go; 30 min restock"
})

for _, item in ipairs(S.MerchantItems) do
    MerchantMainSection:AddToggle({
        Name = item,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Merchant_" .. item:gsub(" ", "_"),
        Save = true,
        Callback = function(Value) S.FM[item] = Value end
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

UISection:AddToggle({
    Name = "ALWAYS SHOW FRAME",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AlwaysShowFrame",
    Save = true,
    Callback = function(Value) end
})

UISection:AddColorPicker({
    Name = "HIGHLIGHT COLOR",
    Default = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightColor",
    Save = true,
    Callback = function(Value) end
})

UISection:AddButton({
    Name = "📋 COPY DISCORD LINK",
    Outline = true,
    Callback = function()
        setclipboard(S.DISCORD)
        Notify("Discord link copied!")
    end
})

UISection:AddButton({
    Name = "🗑️ DESTROY GUI",
    Outline = true,
    Callback = function()
        S.Running = false
        F.AutoFarmLevel = false 
        F.AutoDungeon = false 
        F.AutoBossRush = false 
        F.BossEnabled = false 
        F.AutoChest = false 
        F.AutoMerchant = false 
        F.DungeonQuest = false 
        F.HogyokuQuest = false
        for _,k in ipairs(S.SkillKeys) do F[k] = false end
        pcall(function() 
            local c = Player.Character 
            if c then 
                local hm = c:FindFirstChildOfClass("Humanoid") 
                if hm then hm.PlatformStand = false end 
                for _,p in ipairs(c:GetDescendants()) do 
                    if p:IsA("BasePart") then p.CanCollide = true end 
                end 
            end 
        end)
        fn.StopTw() fn.ClearTgt() S.HoverPos = nil S.NoclipActive = false
        fn.DisableAllAutoSpawn()
        for _,c in ipairs(S.Conns) do pcall(function() c:Disconnect() end) end
        S.Conns = {}
        OrionLib:Destroy()
        _G.SP_Loaded = false
    end
})

local InfoSection = SettingsTab:AddSection({
    Name = "ℹ️ INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

InfoSection:AddParagraph({
    Title = "SAILOR PIECE v1.0",
    Desc = "Left Alt = Toggle UI\nV = Farm | B = Boss\nN = Summon | M = All Skills\n\nStand Position: Behind/In Front/Left/Right\nMove Mode: Tween (smooth) or Teleport (instant)\nCombat Style: Dodge/Static/Orbit/Strafe\n\nBoss: Portal TP first, cached positions\nAnos: separate summon remote, detects any difficulty\nChest: batch open all at once",
    Image = "info",
    ImageSize = 30
})

local ThemeSection = SettingsTab:AddSection({
    Name = "🎭 THEMES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ThemeSection:AddDropdown({
    Name = "SELECT THEME",
    Default = "Ocean",
    Options = {"Default", "Ocean", "Void", "Hackerman", "Dark Green", "Dark Blue", "Purple Rose", "Skeet"},
    Multi = false,
    Search = false,
    Outline = true,
    Flag = "Theme",
    Save = true,
    Callback = function(Value) OrionLib.SelectedTheme = Value end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "folder"
})

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ EDITION v1.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm - Full farming system with quests")
print("✅ Auto Skills - All skills with cooldown control")
print("✅ Auto Boss - World bosses with timers")
print("✅ Summon Boss - All summonable bosses")
print("✅ Auto Dungeon - All dungeon types")
print("✅ Auto Chest - Open all chests automatically")
print("✅ Auto Merchant - Auto buy items")
print("✅ Teleport System - Quick island teleports")
print("═══════════════════════════════════════════════════════")

--==================================================
-- BACKGROUND THREADS
--==================================================
fn.SetupAntiAFK()
task.spawn(fn.DisableGameAutoSkills)

task.spawn(function() 
    while S.Running do 
        if F.AutoQuest then 
            fn.QuestCompletionScan() 
        end 
        task.wait(2) 
    end 
end)

task.spawn(function() 
    while S.Running do 
        if F.AutoChest then 
            fn.OpenAllChests() 
        end 
        task.wait(2) 
    end 
end)

task.spawn(function() 
    while S.Running do 
        if F.AutoMerchant then 
            fn.BuyMerchantItems() 
        end 
        task.wait(8) 
    end 
end)

task.spawn(function() 
    while S.Running do 
        task.wait(3) 
        for _,dt in ipairs(S.DungeonTypes) do 
            if S.AutoJoinDungeon[dt] and not S.AutoJoinFired[dt] and not fn.IsInDungeon() and not fn.IsInDungeonLobby() then 
                S.AutoJoinFired[dt] = true 
                fn.FireDungeonPortal(dt) 
            end 
        end 
        if S.AutoJoinBossRush and not S.AutoJoinBossRushFired and not fn.IsInDungeon() and not fn.IsInDungeonLobby() then 
            S.AutoJoinBossRushFired = true 
            pcall(function() 
                local r = fn.WalkPathWait(ReplicatedStorage,3,unpack(S.DungeonPortal)) 
                if r then r:FireServer("BossRush") end 
            end) 
        end 
    end 
end)

task.spawn(function() 
    task.wait(1.5) 
    fn.ScanAllBossTimers() 
    while S.Running do 
        fn.ScanAllBossTimers() 
        if S.BossInfoP then 
            pcall(function() 
                local txt = fn.GetBossTimerText() 
                if S.BossInfoP.SetContent then 
                    S.BossInfoP:SetContent(txt) 
                end 
            end) 
        end 
        task.wait(1) 
    end 
end)

task.spawn(function()
    if not fn.IsAlive() then fn.WaitChar() task.wait(0.5) end
    for _=1,10 do 
        if fn.GetLevel()>0 then break end 
        task.wait(0.5) 
    end
    while S.Running do
        repeat
            local isSummonActive = fn.HasAnySummonBossEnabled()
            if not F.AutoFarmLevel and not F.AutoDungeon and not F.AutoBossRush and not isSummonActive and not F.BossEnabled and not S.BossFight and not F.DungeonQuest and not F.HogyokuQuest then 
                task.wait(0.3) 
                break 
            end
            if not fn.IsAlive() then
                fn.ClearTgt() S.HoverPos = nil fn.WaitChar() task.wait(0.3)
                if F.AutoEquip then fn.EquipBothWeapons() task.wait(0.2) end
                if not S.BossFight and not S.SummonBossFight then 
                    S.IslandTPd = false 
                    S.SpawnDone = false 
                    S.FarmOrigin = nil 
                end
                S.LastBossTP = 0 
                S.BossTPDone = false 
                S.LastSummonBossTP = 0 
                S.SummonBossTPDone = false
            end
            if not fn.IsAlive() then 
                task.wait(0.3) 
                break 
            end
            if F.DungeonQuest then
                if S.SummonBossFight then fn.ExitSummonBossMode() end
                if S.BossFight then 
                    S.BossFight = false 
                    S.BossTargetName = nil 
                    fn.ClearTgt() 
                    S.HoverPos = nil 
                end
                local dok,derr = pcall(fn.DoDungeonQuestTick) 
                if not dok then 
                    Notify("Dungeon Error: "..tostring(derr):sub(1,80)) 
                end
                task.wait(0.2) 
                break
            end
            if F.HogyokuQuest then
                if S.SummonBossFight then fn.ExitSummonBossMode() end
                if S.BossFight then 
                    S.BossFight = false 
                    S.BossTargetName = nil 
                    fn.ClearTgt() 
                    S.HoverPos = nil 
                end
                local hok,herr = pcall(fn.DoHogyokuQuestTick) 
                if not hok then 
                    Notify("Hogyoku Error: "..tostring(herr):sub(1,80)) 
                end
                task.wait(0.2) 
                break
            end
            if F.AutoDungeon then
                if S.SummonBossFight then fn.ExitSummonBossMode() end
                if S.BossFight then 
                    S.BossFight = false 
                    S.BossTargetName = nil 
                    fn.ClearTgt() 
                    S.HoverPos = nil 
                end
                pcall(fn.DoAutoDungeonTick)
                task.wait(0.08)
                break
            end
            if F.AutoBossRush then
                if S.SummonBossFight then fn.ExitSummonBossMode() end
                if S.BossFight then 
                    S.BossFight = false 
                    S.BossTargetName = nil 
                    fn.ClearTgt() 
                    S.HoverPos = nil 
                end
                pcall(fn.DoBossRushTick)
                task.wait(0.08)
                break
            end
            if not isSummonActive and S.SummonBossFight then fn.ExitSummonBossMode() end
            if isSummonActive and not S.SummonBossFight then
                S.SummonBossFight = true 
                S.BossFight = false 
                S.BossTargetName = nil 
                S.BossTPDone = false 
                S.SummonBossTPDone = false 
                S.LastSummonBossTP = 0 
                S.SummonBossCurrentIsland = nil 
                S.SummonBossOrder = 0 
                S.SummonBossFailCount = {} 
                S.SummonBossFireTime = {} 
                S.SummonBossLockedDiff = {} 
                fn.ClearTgt() 
                S.HoverPos = nil 
                S.CurIsland = nil 
                S.IslandTPd = false
            end
            if S.SummonBossFight then 
                fn.DoSummonBossTick() 
                task.wait(0.1) 
                break 
            end
            if F.BossEnabled and not S.BossFight then
                local nextName = fn.PickNextBossName()
                if nextName then
                    local bossIsland = fn.GetBossIsland(nextName)
                    local alreadyOnIsland = S.CurIsland and bossIsland and S.CurIsland.Portal==bossIsland and S.IslandTPd
                    S.BossFight = true 
                    S.BossTargetName = nextName 
                    S.BossTPDone = alreadyOnIsland 
                    S.LastBossTP = 0 
                    fn.ClearTgt() 
                    S.HoverPos = nil
                    if alreadyOnIsland then 
                        S.BossCurrentIsland = bossIsland 
                    else 
                        S.BossCurrentIsland = nil 
                        S.CurIsland = nil 
                        S.IslandTPd = false 
                    end
                    if F.BossNotify then 
                        Notify("Locating "..fn.GetBossDisplay(nextName).." — Teleporting!") 
                    end
                end
            end
            if S.BossFight then 
                fn.DoBossTick() 
                task.wait(0.1) 
                break 
            end
            if not F.AutoFarmLevel then 
                task.wait(0.3) 
                break 
            end
            fn.DoFarmTick()
            task.wait(0.1)
        until true
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or fn.Typing() then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.Unknown then return end
    local kn = key.Name
    if S.FarmKeybind and kn == S.FarmKeybind:GetValue() then 
        fn.ToggleFarm() 
        return 
    end
    if S.BossKeybind and kn == S.BossKeybind:GetValue() then 
        fn.ToggleBoss() 
        return 
    end
    if kn == "N" then 
        fn.ToggleSummonBoss() 
        return 
    end
    if S.AllSkillsKeybind and kn == S.AllSkillsKeybind:GetValue() then 
        fn.ToggleAllSkills() 
        return 
    end
end)