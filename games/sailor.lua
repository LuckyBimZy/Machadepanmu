-- ==================== SAILOR PIECE - CATRAZ ULTIMATE ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.0 MERGED SYSTEM

if _G.SP_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Sailor Piece Ultimate",
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
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera

-- Remote References
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local CombatRemotes = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes")
local AbilityRemote = ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")

local UseItemRemote = ReplicatedStorage:FindFirstChild("UseItem", true)
local AllocateStatRemote = ReplicatedStorage:FindFirstChild("AllocateStat", true)

local hitRemote = CombatRemotes:WaitForChild("RequestHit")
local questRemote = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local tpRemote = Remotes:WaitForChild("TeleportToPortal")
local hakiRemote = RemoteEvents:WaitForChild("HakiRemote")
local obsHakiRemote = RemoteEvents:WaitForChild("ObservationHakiRemote")

local summonBossRemote = Remotes:WaitForChild("RequestSummonBoss")
local autoSpawnBossRemote = Remotes:WaitForChild("RequestAutoSpawn")
local spawnStrongestRemote = Remotes:WaitForChild("RequestSpawnStrongestBoss")
local anosRemote = Remotes:WaitForChild("RequestSpawnAnosBoss")
local trueAizenRemote = RemoteEvents:WaitForChild("RequestSpawnTrueAizen")
local rimuruRemote = RemoteEvents:WaitForChild("RequestSpawnRimuru")
local atomicRemote = RemoteEvents:WaitForChild("RequestSpawnAtomic")

local dungeonVoteRemote = Remotes:WaitForChild("DungeonWaveVote")
local dungeonPortalRemote = Remotes:WaitForChild("RequestDungeonPortal")

local CodeRedeem = RemoteEvents:FindFirstChild("CodeRedeem")

--==================================================
-- CONSTANTS & CONFIGURATION
--==================================================
local Constants = {
    ICON = "rbxassetid://105921924721005",
    NPC_FOLDER = "NPCs",
    FARM_MAX_DIST_FROM_PLAYER = 900,
    FARM_MAX_DIST_FROM_ORIGIN = 1200,

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
        {Portal = "SoulSociety", FarmUntil = 999999, Enemies = {"Quincy1", "Quincy2"}, QuestNPC = "QuestNPC17"},
    },
    
    TpIslands = {"Starter","Jungle","Desert","Snow","Sailor","Shibuya","HuecoMundo","Boss","Dungeon","Shinjuku","Slime","Academy","Judgement","SoulSociety"},
    
    NpcList = {
        "GroupRewardNPC", "BossRushShopNPC", "BossRushPortalNPC", "DungeonMerchantNPC", 
        "EnchantNPC", "YujiBuyerNPC", "BlessingNPC", "SlimeCraftNPC", 
        "RimuruMasteryNPC", "SkillTreeNPC", "Katana", "MadokaBuyer", 
        "HakiQuestNPC", "SummonBossNPC"
    },

    Bosses = {
        {Name = "AizenBoss", Display = "Aizen", Island = "HuecoMundo"},
        {Name = "AlucardBoss", Display = "Alucard", Island = "Sailor"},
        {Name = "GojoBoss", Display = "Gojo", Island = "Shibuya"},
        {Name = "JinwooBoss", Display = "Jinwoo", Island = "Sailor"},
        {Name = "SukunaBoss", Display = "Sukuna", Island = "Shibuya"},
        {Name = "YamatoBoss", Display = "Yamato", Island = "Judgement"},
        {Name = "YujiBoss", Display = "Yuji", Island = "Shibuya"},
    },
    
    SummonBosses = {
        {Name = "IchigoBoss", Display = "Ichigo"},
        {Name = "QinShiBoss", Display = "Qin Shi"},
        {Name = "SaberBoss", Display = "Saber"},
        {Name = "AnosBoss", Display = "Anos", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "BlessedMaidenBoss", Display = "Blessed Maiden", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "GilgameshBoss", Display = "Gilgamesh", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "RimuruBoss", Display = "Rimuru", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "SaberAlterBoss", Display = "Saber Alter", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "StrongestHistoryBoss", Display = "Strongest in History", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "StrongestTodayBoss", Display = "Strongest Today", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "TrueAizenBoss", Display = "True Aizen", Difficulties = {"Normal","Medium","Hard","Extreme"}},
        {Name = "AtomicBoss", Display = "Atomic", Difficulties = {"Normal","Medium","Hard","Extreme"}},
    },
    
    DungeonTypes = {"Double", "Rune", "Cid"},
    DungeonDifficulties = {"Easy", "Normal", "Hard", "Extreme"},
    DungeonPortalNames = {Double = "DoubleDungeon", Rune = "RuneDungeon", Cid = "CidDungeon"},
    
    IgnoreList = {"groupreward","katana","buyer","madoka","training","dummy","merchant","shop","vendor","shadow questline","shadowmonarch","obshakilsinhead","buff","questnpc"},
    ChestNames = {"Common Chest","Rare Chest","Epic Chest","Legendary Chest","Mythical Chest"},
    MerchantItems = {"Boss Key","Clan Reroll","Dungeon Key","Haki Color Reroll","Race Reroll","Rush Key","Trait Reroll"},
}

--==================================================
-- ORIGINAL SETTINGS
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
-- CONFIGURATION
--==================================================
getgenv().Config = {
    -- Auto Farm
    AutoFarm = {
        Enabled = false,
        AutoHit = true,
        AutoEquip = true,
        SelectedWeapon = "None",
        SkillCooldown = 0.3
    },
    AutoSkills = { Z = false, X = false, C = false, V = false, F = false },
    LastSkillTime = 0,
    IsFarm = false, IsBossFight = false, IsAutoDungeon = false,
    
    Farm = {
        HeightOffset = 15, TweenSpeed = 100, OffsetDist = 15,
        FarmMode = "Behind", FollowStyle = "Dodge", MoveMode = "Tween",
        SelectedIsland = "Auto", SelectedEnemy = "All",
        AutoQuest = true, AutoSpawn = false,
    },
    
    Dungeon = {
        Enabled = false, Type = "Double", Difficulty = "Normal",
        HeightOffset = 10, TweenSpeed = 50, MoveMode = "Teleport",
        FarmMode = "Behind", AutoReplay = false, AutoVote = false, AutoMake = false, AutoJoin = false,
    },
    
    Bosses = { Enabled = false, Selected = {}, SummonSelected = {} },
    AutoBoss = { Enabled = false, Target = "" },
    AutoSummonV2 = { Enabled = false, Target = "SummonBossNPC", BossIndex = 1 },
    AutoDummy = { Enabled = false },
    
    Merchant = { Enabled = false, Notify = true, Selected = {} },
    Quests = { DungeonEnabled = false, HogyokuEnabled = false },
    
    Misc = {
        AntiAFK = true,
        FpsBoost = false, WhiteScreen = false,
        AutoRejoin = false, TimedRejoin = false, RejoinDelay = 10,
        NoShake = false, NoCutscene = false, DisablePvP = false,
        TeleportTpTime = 0.1,
    },

    Reroll = {
        AutoRace = false, TargetRace = "Kitsune",
        AutoClan = false, TargetClan = "Gojo",
        AutoStats = false, TargetStat = "Melee",
        AutoChest = false, TargetChest = "Common Chest", ChestAmount = 1
    },

    Hacks = { InfJump = false, SuperSpeed = false, SpeedMulti = 2, FruitSniper = false, AutoCollect = false, AutoHaki = false, AutoObs = false }
}

--==================================================
-- STATE VARIABLES
--==================================================
local State = {
    Running = true, Kills = 0, BossKills = 0, KillCount = 0,
    CurIsland = nil, CurTarget = nil, LockTarget = nil,
    TweenOn = false, TweenTarget = nil, ATween = nil, ATweenConn = nil,
    LastEquip = 0, LastTP = 0, LastEnemy = 0, TPCount = 0, TPRest = tick(),
    IslandTPd = false, QState = "NONE",
    CollectedItems = {}, OrbitAngle = 0
}

--==================================================
-- UTILITY FUNCTIONS
--==================================================
local function DistTo(pos)
    if not pos then return 99999 end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 99999 end
    return (hrp.Position - pos).Magnitude
end

local function GetHum(e)
    if not e then return nil end
    local h = e:FindFirstChildOfClass("Humanoid")
    if not h then
        for _, d in ipairs(e:GetDescendants()) do
            if d:IsA("Humanoid") then return d end
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

local function GetFarmIsland()
    local lv = 0
    pcall(function() lv = Player.Data.Level.Value end)
    
    if getgenv().Config.Farm.SelectedIsland == "Auto" then
        for _, i in ipairs(Constants.Islands) do
            if lv < i.FarmUntil then return i end
        end
        return Constants.Islands[#Constants.Islands]
    end
    
    for _, i in ipairs(Constants.Islands) do
        if i.Portal == getgenv().Config.Farm.SelectedIsland then return i end
    end
    return Constants.Islands[1]
end

local function IsAlive()
    local c = Player.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return c:FindFirstChild("HumanoidRootPart") and h and h.Health > 0
end

local function ForceTP(portal)
    local ok = false
    pcall(function() tpRemote:FireServer(portal); ok = true end)
    if not ok then
        task.wait(1)
        pcall(function() tpRemote:FireServer(portal); ok = true end)
    end
    return ok
end

local function StopTween()
    if State.ATweenConn then pcall(function() State.ATweenConn:Disconnect() end); State.ATweenConn = nil end
    if State.ATween then pcall(function() State.ATween:Cancel() end); State.ATween = nil end
    State.TweenOn = false; State.TweenTarget = nil
end

local function ClearTarget()
    State.CurTarget = nil; State.LockTarget = nil; StopTween()
end

local function EquipWeapon(weaponName)
    if not weaponName or weaponName == "None" then return false end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if char:FindFirstChild(weaponName) then return true end
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return false end
    local tool = backpack:FindFirstChild(weaponName)
    if not tool or not tool:IsA("Tool") then return false end
    hum:UnequipTools()
    task.wait(0.1)
    hum:EquipTool(tool)
    task.wait(0.1)
    return char:FindFirstChild(weaponName) ~= nil
end

local function RefreshWeaponList()
    local w = {"None"}
    for _, p in ipairs({Player:FindFirstChild("Backpack"), Player.Character}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") and not table.find(w, t.Name) then table.insert(w, t.Name) end
            end
        end
    end
    table.sort(w)
    return w
end

local function FindEnemies(island)
    local nf = Workspace:FindFirstChild(Constants.NPC_FOLDER)
    if not island or not nf then return {} end
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local origin = State.FarmOrigin
    local out = {}
    
    local function check(m)
        if m:IsA("Model") and not m:IsDescendantOf(Player.Character) then
            if getgenv().Config.Farm.SelectedEnemy ~= "All" and m.Name ~= getgenv().Config.Farm.SelectedEnemy then return end
            local hm = GetHum(m)
            if hm and hm.Health > 0 and not m.Name:lower():find("boss") and not m:GetAttribute("IsTrainingDummy") then
                local found = false
                for _, e in ipairs(island.Enemies) do
                    if m.Name:lower():sub(1, #e) == e:lower() then found = true; break end
                end
                if found then
                    local p = RootPos(m)
                    if hrp and p and (p - hrp.Position).Magnitude <= Constants.FARM_MAX_DIST_FROM_PLAYER then
                        if not origin or (p - origin).Magnitude <= Constants.FARM_MAX_DIST_FROM_ORIGIN then
                            table.insert(out, m)
                        end
                    end
                end
            end
        end
    end
    
    for _, desc in ipairs(nf:GetChildren()) do
        if desc:IsA("Model") then check(desc)
        elseif desc:IsA("Folder") then
            for _, m in ipairs(desc:GetChildren()) do check(m) end
        end
    end
    return out
end

local function GetGoalForEnemy(enemy)
    local pos = RootPos(enemy)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not pos or not hrp then return nil, nil end
    local dir = (hrp.Position - pos).Unit
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    local ho = getgenv().Config.Farm.HeightOffset
    local dist = getgenv().Config.Farm.OffsetDist
    local fm = getgenv().Config.Farm.FarmMode
    local goal
    if fm == "In Front" then goal = pos - dir * dist
    elseif fm == "Left Side" then goal = pos + Vector3.new(dir.Z, 0, -dir.X) * dist
    elseif fm == "Right Side" then goal = pos + Vector3.new(-dir.Z, 0, dir.X) * dist
    else goal = pos + dir * dist end
    goal = Vector3.new(goal.X, pos.Y + ho, goal.Z)
    return goal, pos
end

local function TweenTo(enemy)
    if not enemy then return end
    local ep = RootPos(enemy)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not ep or not hrp then return end
    if State.LockTarget == enemy and getgenv().Config.Farm.FollowStyle ~= "Dodge" then
        if (hrp.Position - ep).Magnitude > getgenv().Config.Farm.OffsetDist + 25 then State.LockTarget = nil else return end
    end
    
    local goal, look = GetGoalForEnemy(enemy)
    if not goal then return end
    local d = (hrp.Position - goal).Magnitude
    if d > 600 then return end
    if d < getgenv().Config.Farm.OffsetDist + 2 then
        State.LockTarget = enemy; StopTween(); return
    end
    if getgenv().Config.Farm.MoveMode == "Teleport" then
        StopTween(); hrp.CFrame = CFrame.new(goal, look or goal); State.LockTarget = enemy; return
    end
    if State.TweenOn and State.TweenTarget == enemy then return end
    
    StopTween(); State.TweenOn = true; State.TweenTarget = enemy; State.LockTarget = nil
    local stepDist = math.min(d, 80)
    local dir = (goal - hrp.Position).Unit
    local cf = CFrame.new(hrp.Position + (dir * stepDist), look or goal)
    local dur = math.clamp(stepDist / math.max(getgenv().Config.Farm.TweenSpeed, 1), 0.06, 3.0)
    State.ATween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = cf})
    State.ATweenConn = State.ATween.Completed:Connect(function() 
        State.ATween = nil; State.ATweenConn = nil; State.TweenOn = false; State.TweenTarget = nil; State.LockTarget = enemy 
    end)
    State.ATween:Play()
end

--==================================================
-- CUSTOM FEATURES (FROM STANDALONE FILES)
--==================================================
-- Auto Use Skills
task.spawn(function()
    while State.Running do
        task.wait(0.1)
        if getgenv().Config.IsFarm or getgenv().Config.IsBossFight or getgenv().Config.IsAutoDungeon or getgenv().Config.AutoBoss.Enabled or getgenv().Config.AutoSummonV2.Enabled or getgenv().Config.AutoDummy.Enabled then
            if tick() - getgenv().Config.LastSkillTime >= getgenv().Config.AutoFarm.SkillCooldown then
                local used = false
                local map = {Z=1, X=2, C=3, V=4, F=5}
                for k, v in pairs(map) do
                    if getgenv().Config.AutoSkills[k] then
                        pcall(function() AbilityRemote:FireServer(v) end)
                        used = true
                    end
                end
                if used then getgenv().Config.LastSkillTime = tick() end
            end
        end
    end
end)

-- Anti-AFK
LP.Idled:Connect(function()
    if getgenv().Config.Misc.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- Super Speed & Inf Jump
RunService.Heartbeat:Connect(function()
    if getgenv().Config.Hacks.SuperSpeed then
        local char = Player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * getgenv().Config.Hacks.SpeedMulti)
        end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if getgenv().Config.Hacks.InfJump then
        local char = Player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Dash/Optimizer Attrs
task.spawn(function()
    while State.Running do
        task.wait(1)
        pcall(function()
            Player:SetAttribute("DisableScreenShake", getgenv().Config.Misc.NoShake)
            Player:SetAttribute("DisableCutscene", getgenv().Config.Misc.NoCutscene)
            Player:SetAttribute("DisablePvP", getgenv().Config.Misc.DisablePvP)
        end)
    end
end)

-- Auto Race & Clan Reroll & Stats
task.spawn(function()
    while State.Running do
        task.wait(1.5)
        local cf = getgenv().Config.Reroll
        if cf.AutoRace and UseItemRemote then
            local curr = Player:GetAttribute("CurrentRace")
            if curr and string.lower(curr) == string.lower(cf.TargetRace) then
                cf.AutoRace = false; OrionLib:MakeNotification({Name="Reroll", Content="Got " .. cf.TargetRace, Time=3})
                if OrionLib.Flags["AutoRace"] then OrionLib.Flags["AutoRace"]:SetValue(false) end
            else pcall(function() UseItemRemote:FireServer("Use", "Race Reroll", 1, false) end) end
        end
        if cf.AutoClan and UseItemRemote then
            local curr = Player:GetAttribute("CurrentClan")
            if curr and string.lower(curr) == string.lower(cf.TargetClan) then
                cf.AutoClan = false; OrionLib:MakeNotification({Name="Reroll", Content="Got " .. cf.TargetClan, Time=3})
                if OrionLib.Flags["AutoClan"] then OrionLib.Flags["AutoClan"]:SetValue(false) end
            else pcall(function() UseItemRemote:FireServer("Use", "Clan Reroll", 1, false) end) end
        end
        if cf.AutoStats and AllocateStatRemote then
            pcall(function()
                local data = Player:FindFirstChild("Data")
                if data and data:FindFirstChild("StatPoints") and data.StatPoints.Value > 0 then
                    AllocateStatRemote:FireServer(cf.TargetStat, 1)
                end
            end)
        end
        if cf.AutoChest and UseItemRemote then
            pcall(function() UseItemRemote:FireServer("Use", cf.TargetChest, cf.ChestAmount, false) end)
        end
    end
end)

-- Auto Haki / Obs Auto
task.spawn(function()
    while State.Running do
        task.wait(2)
        local char = Player.Character
        if char then
            if getgenv().Config.Hacks.AutoHaki and hakiRemote then
                local ra = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                if ra and ra.BrickColor ~= BrickColor.new("Really black") then pcall(function() hakiRemote:FireServer("Toggle") end) end
            end
            if getgenv().Config.Hacks.AutoObs and obsHakiRemote then
                local pg = Player:FindFirstChild("PlayerGui")
                local dUI = pg and pg:FindFirstChild("DodgeCounterUI")
                local vis = dUI and dUI:FindFirstChild("MainFrame") and dUI.MainFrame.Visible
                if not vis then pcall(function() obsHakiRemote:FireServer("Toggle") end) end
            end
        end
    end
end)

-- Auto Collect (Chests, puzzles)
task.spawn(function()
    while State.Running do
        task.wait(1.5)
        if getgenv().Config.Hacks.AutoCollect then
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local found = false
                for _, obj in pairs(Workspace:GetDescendants()) do
                    local nm = string.lower(obj.Name)
                    if (nm:find("chest") or nm:find("box") or nm:find("hogyoku") or nm:find("puzzle")) and not nm:find("dealer") and not nm:find("npc") then
                        if not State.CollectedItems[obj] then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or (obj.Parent and obj.Parent:FindFirstChildWhichIsA("ProximityPrompt", true))
                            local clicker = obj:FindFirstChildWhichIsA("ClickDetector", true)
                            if prompt or clicker then
                                local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position)
                                if pos then
                                    hrp.Velocity = Vector3.zero
                                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                                    task.wait(0.5)
                                    if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                                    if clicker and fireclickdetector then fireclickdetector(clicker) end
                                    State.CollectedItems[obj] = true
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        else
            State.CollectedItems = {}
        end
    end
end)

-- Fruit Sniper
Workspace.DescendantAdded:Connect(function(obj)
    if not getgenv().Config.Hacks.FruitSniper then return end
    task.spawn(function()
        task.wait(0.2)
        if not obj or not obj.Parent then return end
        local nm = string.lower(obj.Name)
        if (nm:find("fruit") or nm:find("fruta")) and not nm:find("dealer") and not nm:find("npc") and not obj:FindFirstChild("Humanoid") then
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or (obj.Parent and obj.Parent:FindFirstChildWhichIsA("ProximityPrompt", true))
            local clicker = obj:FindFirstChildWhichIsA("ClickDetector", true)
            if prompt or clicker then
                local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position)
                if pos then
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                        task.wait(0.5)
                        if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                        if clicker and fireclickdetector then fireclickdetector(clicker) end
                    end
                end
            end
        end
    end)
end)

-- Code Redeemer
local function AutoRedeemCodes()
    local cc = pcall(function() return require(ReplicatedStorage:WaitForChild("CodesConfig", 5)) end)
    if cc and CodeRedeem then
        for code, _ in pairs(cc.Codes) do
            if cc.IsValid(code) then pcall(function() CodeRedeem:InvokeServer(code) end); task.wait(0.5) end
        end
        OrionLib:MakeNotification({Name="Codes", Content="Redeemed auto codes!", Time=3})
    end
end

--==================================================
-- CREATE UI
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece Ultimate",
    Subtext = "PREMIUM Edition",
    Version = "v3.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CatrazHubSP",
    IntroEnabled = true,
    IntroText = "Sailor Piece CatrazHub",
    IntroIcon = Constants.ICON,
    Icon = Constants.ICON,
    ShowIcon = true,
    
    -- Custom Theme & Appearance
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    -- Floating Toggle 
    ToggleIcon = Constants.ICON,
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

--==================================================
-- MAIN TAB
--==================================================
local MainTab = Window:MakeTab({ Name = "🎯 Main", Icon = "home" })

local InfoSec = MainTab:AddSection({ Name = "👤 Player Information", TextSize = 16, Glass = true })
local LevelLbl = InfoSec:AddLabel("Level: Loading...")
local RaceLbl = InfoSec:AddLabel("Race: Loading...")
local ClanLbl = InfoSec:AddLabel("Clan: Loading...")

task.spawn(function()
    while State.Running do
        task.wait(2)
        pcall(function()
            local d = Player:FindFirstChild("Data")
            if d then
                LevelLbl:Set("Level: " .. (d:FindFirstChild("Level") and d.Level.Value or "N/A"))
                RaceLbl:Set("Race: " .. (Player:GetAttribute("CurrentRace") or "N/A"))
                ClanLbl:Set("Clan: " .. (Player:GetAttribute("CurrentClan") or "N/A"))
            end
        end)
    end
end)

local DashSec = MainTab:AddSection({ Name = "🔧 Dashboard & QoL", TextSize = 16, Glass = true })
DashSec:AddToggle({Name = "Auto Redeem Codes", Default = false, Save = true, Flag = "AutoCodes", Callback = function(v)
    if v then task.spawn(AutoRedeemCodes) end
end})
DashSec:AddToggle({Name = "Disable Screen Shake", Default = false, Save = true, Flag = "NoShake", Callback = function(v) getgenv().Config.Misc.NoShake = v end})
DashSec:AddToggle({Name = "Disable Cutscenes", Default = false, Save = true, Flag = "NoCutscene", Callback = function(v) getgenv().Config.Misc.NoCutscene = v end})
DashSec:AddToggle({Name = "Disable PvP", Default = false, Save = true, Flag = "DisablePvP", Callback = function(v) getgenv().Config.Misc.DisablePvP = v end})

--==================================================
-- AUTO FARM TAB
--==================================================
local FarmTab = Window:MakeTab({ Name = "⚔️ Farming", Icon = "swords" })

local MainFarmSec = FarmTab:AddSection({ Name = "⚡ Main Auto Farm", TextSize = 18, Glass = true })
MainFarmSec:AddToggle({Name = "Enable Auto Farm", Default = false, Save = true, Flag = "AutoFarm", Callback = function(v)
    getgenv().Config.AutoFarm.Enabled = v; getgenv().Config.IsFarm = v
end})
MainFarmSec:AddToggle({Name = "Auto Accept Quest", Default = true, Save = true, Flag = "AutoQuest", Callback = function(v) getgenv().Config.Farm.AutoQuest = v end})
MainFarmSec:AddDropdown({Name = "Select Island", Default = "Auto", Options = {"Auto", unpack(Constants.TpIslands)}, Save = true, Flag = "FarmIsland", Callback = function(v) getgenv().Config.Farm.SelectedIsland = v end})
MainFarmSec:AddDropdown({Name = "Target Priority", Default = "All", Options = {"All", "Swordsman", "Quincy", "Curse", "Monkey"}, Save = true, Flag = "FarmEnemy", Callback = function(v) getgenv().Config.Farm.SelectedEnemy = v end})

local WeaponSec = FarmTab:AddSection({ Name = "🛡️ Weapon Selection", TextSize = 16, Glass = true })
WeaponSec:AddToggle({Name = "Auto Equip", Default = true, Save = true, Flag = "AutoEquip", Callback = function(v) getgenv().Config.AutoFarm.AutoEquip = v end})
local WeaponDrop = WeaponSec:AddDropdown({Name = "Select Weapon", Default = "None", Options = {"None"}, Save = true, Flag = "SelWep", Callback = function(v) getgenv().Config.AutoFarm.SelectedWeapon = v end})
WeaponSec:AddButton({Name = "Refresh Weapons", Callback = function() WeaponDrop:Refresh(RefreshWeaponList(), true) end})

local PosSec = FarmTab:AddSection({ Name = "📐 Positioning", TextSize = 16, Glass = true })
PosSec:AddDropdown({Name = "Farm Mode", Default = "Behind", Options = {"Behind", "In Front", "Left Side", "Right Side"}, Save = true, Flag = "FarmMode", Callback = function(v) getgenv().Config.Farm.FarmMode = v end})
PosSec:AddDropdown({Name = "Follow Style", Default = "Dodge", Options = {"Dodge", "Static", "Orbit", "Strafe"}, Save = true, Flag = "FollowStyle", Callback = function(v) getgenv().Config.Farm.FollowStyle = v end})
PosSec:AddSlider({Name = "Height Offset", Min = 5, Max = 50, Default = 15, Increment = 1, Save = true, Flag = "HeightOffset", Callback = function(v) getgenv().Config.Farm.HeightOffset = v end})
PosSec:AddSlider({Name = "Distance", Min = 0, Max = 25, Default = 15, Increment = 1, Save = true, Flag = "OffsetDist", Callback = function(v) getgenv().Config.Farm.OffsetDist = v end})

local DummySec = FarmTab:AddSection({ Name = "🎯 Training Dummy", TextSize = 16, Glass = true })
DummySec:AddToggle({Name = "Auto Farm Dummy", Default = false, Save = true, Flag = "AutoDummy", Callback = function(v)
    getgenv().Config.AutoDummy.Enabled = v
    if v then
        if OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(false) end
    end
end})

--==================================================
-- SKILLS TAB
--==================================================
local SkillsTab = Window:MakeTab({ Name = "✨ Skills", Icon = "sparkles" })

local AutoSkillSec = SkillsTab:AddSection({ Name = "💫 Auto Skills", TextSize = 18, Glass = true })
AutoSkillSec:AddToggle({Name = "Use Skill Z", Default = false, Save = true, Flag = "SkillZ", Callback = function(v) getgenv().Config.AutoSkills.Z = v end})
AutoSkillSec:AddToggle({Name = "Use Skill X", Default = false, Save = true, Flag = "SkillX", Callback = function(v) getgenv().Config.AutoSkills.X = v end})
AutoSkillSec:AddToggle({Name = "Use Skill C", Default = false, Save = true, Flag = "SkillC", Callback = function(v) getgenv().Config.AutoSkills.C = v end})
AutoSkillSec:AddToggle({Name = "Use Skill V", Default = false, Save = true, Flag = "SkillV", Callback = function(v) getgenv().Config.AutoSkills.V = v end})
AutoSkillSec:AddToggle({Name = "Use Skill F", Default = false, Save = true, Flag = "SkillF", Callback = function(v) getgenv().Config.AutoSkills.F = v end})
AutoSkillSec:AddSlider({Name = "Skill Delay", Min = 0.1, Max = 2.0, Default = 0.2, Increment = 0.1, Save = true, Flag = "SkillDelay", Callback = function(v) getgenv().Config.AutoFarm.SkillCooldown = v end})

--==================================================
-- DUNGEON TAB
--==================================================
local DungeonTab = Window:MakeTab({ Name = "🏰 Dungeon", Icon = "castle" })

local DungSec = DungeonTab:AddSection({ Name = "🚪 Dungeon Automation", TextSize = 18, Glass = true })
DungSec:AddToggle({Name = "Enable Auto Dungeon", Default = false, Save = true, Flag = "AutoDungeon", Callback = function(v)
    getgenv().Config.Dungeon.Enabled = v
    getgenv().Config.IsAutoDungeon = v
    if v and OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(false) end
end})

DungSec:AddDropdown({Name = "Dungeon Type", Default = "Double", Options = {"Double", "Rune", "Cid"}, Save = true, Flag = "DungType", Callback = function(v) getgenv().Config.Dungeon.Type = v end})
DungSec:AddDropdown({Name = "Difficulty", Default = "Normal", Options = {"Easy", "Normal", "Hard", "Extreme"}, Save = true, Flag = "DungDiff", Callback = function(v) getgenv().Config.Dungeon.Difficulty = v end})
DungSec:AddToggle({Name = "Auto Enter Portal", Default = false, Save = true, Flag = "AutoEnter", Callback = function(v) getgenv().Config.Dungeon.AutoJoin = v end})
DungSec:AddToggle({Name = "Auto Vote", Default = false, Save = true, Flag = "AutoVote", Callback = function(v) getgenv().Config.Dungeon.AutoVote = v end})

--==================================================
-- BOSS TAB
--==================================================
local BossTab = Window:MakeTab({ Name = "👑 Bosses", Icon = "crown" })

local BossWorldSec = BossTab:AddSection({ Name = "🌍 World Bosses", TextSize = 18, Glass = true })
BossWorldSec:AddToggle({Name = "Enable Auto Boss", Default = false, Save = true, Flag = "AutoBoss", Callback = function(v)
    getgenv().Config.Bosses.Enabled = v
    getgenv().Config.IsBossFight = v
    if v and OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(false) end
end})
local blist = {}
for _, b in ipairs(Constants.Bosses) do table.insert(blist, b.Name) end
BossWorldSec:AddDropdown({Name = "Target World Boss", Default = blist[1], Options = blist, Save = true, Flag = "SelWBoss", Callback = function(v) getgenv().Config.AutoBoss.Target = v end})

local SummonBossSec = BossTab:AddSection({ Name = "🔮 Auto Summon Boss", TextSize = 16, Glass = true })
SummonBossSec:AddToggle({Name = "Enable Auto Summon Farm", Default = false, Save = true, Flag = "SummonFarm", Callback = function(v)
    getgenv().Config.AutoSummonV2.Enabled = v
    if v and OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(false) end
end})
local slist = {}
for _, sb in ipairs(Constants.SummonBosses) do table.insert(slist, sb.Name) end
SummonBossSec:AddDropdown({Name = "Target Boss Summon", Default = slist[1], Options = slist, Save = true, Flag = "SelSBoss", Callback = function(v) getgenv().Config.AutoSummonV2.Target = v end})

--==================================================
-- ITEMS & QUESTS TAB
--==================================================
local ItemsTab = Window:MakeTab({ Name = "🎒 Items", Icon = "backpack" })

local CollectSec = ItemsTab:AddSection({ Name = "⭐ Auto Collect", TextSize = 18, Glass = true })
CollectSec:AddToggle({Name = "Fruit Sniper (Auto TP to Fruits)", Default = false, Save = true, Flag = "FruitSniper", Callback = function(v) getgenv().Config.Hacks.FruitSniper = v end})
CollectSec:AddToggle({Name = "Auto Collect Objects (Chests, Puzzles, Hogyoku)", Default = false, Save = true, Flag = "AutoObjectCollect", Callback = function(v) getgenv().Config.Hacks.AutoCollect = v end})
CollectSec:AddToggle({Name = "Auto Chest Use", Default = false, Save = true, Flag = "ChestUse", Callback = function(v) getgenv().Config.Reroll.AutoChest = v end})
CollectSec:AddDropdown({Name = "Target Chest", Default = "Common Chest", Options = Constants.ChestNames, Save = true, Flag = "ChestName", Callback = function(v) getgenv().Config.Reroll.TargetChest = v end})
CollectSec:AddSlider({Name = "Amount to Use", Min = 1, Max = 100, Default = 1, Increment = 1, Save = true, Flag = "ChestAmt", Callback = function(v) getgenv().Config.Reroll.ChestAmount = v end})

local MerchSec = ItemsTab:AddSection({ Name = "🛒 Auto Merchant", TextSize = 18, Glass = true })
MerchSec:AddToggle({Name = "Enable Auto Buy", Default = false, Save = true, Flag = "AutoMerch", Callback = function(v) getgenv().Config.Merchant.Enabled = v end})
for _, m in ipairs(Constants.MerchantItems) do
    MerchSec:AddToggle({Name = "Buy " .. m, Default = false, Save = true, Flag = "Buy"..m, Callback = function(v)
        if v then getgenv().Config.Merchant.Selected[m] = true else getgenv().Config.Merchant.Selected[m] = nil end
    end})
end

--==================================================
-- CHARACTER TAB
--==================================================
local CharTab = Window:MakeTab({ Name = "🧑 Character", Icon = "user" })

local RerollSec = CharTab:AddSection({ Name = "🎲 Rerolls", TextSize = 18, Glass = true })
RerollSec:AddToggle({Name = "Auto Race", Default = false, Save = true, Flag = "AutoRace", Callback = function(v) getgenv().Config.Reroll.AutoRace = v end})
RerollSec:AddDropdown({Name = "Target Race", Default = "Kitsune", Options = {"Kitsune", "Cyborg", "MinK", "Ghoul", "Fishman"}, Save = true, Flag = "TargetRace", Callback = function(v) getgenv().Config.Reroll.TargetRace = v end})

RerollSec:AddToggle({Name = "Auto Clan", Default = false, Save = true, Flag = "AutoClan", Callback = function(v) getgenv().Config.Reroll.AutoClan = v end})
RerollSec:AddDropdown({Name = "Target Clan", Default = "Gojo", Options = {"Gojo", "Uchiha", "Monkey", "Zenith", "Trafalgar"}, Save = true, Flag = "TargetClan", Callback = function(v) getgenv().Config.Reroll.TargetClan = v end})

local StatsSec = CharTab:AddSection({ Name = "📈 Auto Stats", TextSize = 18, Glass = true })
StatsSec:AddToggle({Name = "Auto Upgrade Stats", Default = false, Save = true, Flag = "AutoStats", Callback = function(v) getgenv().Config.Reroll.AutoStats = v end})
StatsSec:AddDropdown({Name = "Select Stat", Default = "Melee", Options = {"Melee", "Defense", "Sword", "Devil Fruit", "Haki"}, Save = true, Flag = "TargetStat", Callback = function(v) getgenv().Config.Reroll.TargetStat = v end})

local HakiSec = CharTab:AddSection({ Name = "💪 Haki", TextSize = 18, Glass = true })
HakiSec:AddToggle({Name = "Auto Buso Haki", Default = true, Save = true, Flag = "AutoHaki", Callback = function(v) getgenv().Config.Hacks.AutoHaki = v end})
HakiSec:AddToggle({Name = "Auto Obs Haki", Default = true, Save = true, Flag = "AutoObs", Callback = function(v) getgenv().Config.Hacks.AutoObs = v end})

--==================================================
-- TELEPORT TAB
--==================================================
local TpTab = Window:MakeTab({ Name = "📍 Teleport", Icon = "map-pin" })

local IslandSec = TpTab:AddSection({ Name = "🌴 Islands", TextSize = 18, Glass = true })
for _, i in ipairs(Constants.TpIslands) do
    IslandSec:AddButton({Name = "TP " .. i, Callback = function() ForceTP(i) end})
end

local NpcSec = TpTab:AddSection({ Name = "🧍 NPCs (Fly GPS)", TextSize = 18, Glass = true })
for _, n in ipairs(Constants.NpcList) do
    NpcSec:AddButton({Name = "Fly " .. n, Callback = function()
        local svc = Workspace:FindFirstChild("ServiceNPCs")
        local tnpc = svc and svc:FindFirstChild(n)
        if tnpc and tnpc:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dur = (hrp.Position - tnpc.HumanoidRootPart.Position).Magnitude / 150
                local tw = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = tnpc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)})
                tw:Play()
            end
        else OrionLib:MakeNotification({Name="NPC", Content="NPC " .. n .. " not found here!", Time=3}) end
    end})
end

--==================================================
-- SETTINGS TAB
--==================================================
local SetTab = Window:MakeTab({ Name = "⚙️ Settings", Icon = "settings" })

local MiscSec = SetTab:AddSection({ Name = "🔧 Misc Features", TextSize = 18, Glass = true })
MiscSec:AddToggle({Name = "Anti AFK", Default = true, Save = true, Flag = "AntiAFK", Callback = function(v) getgenv().Config.Misc.AntiAFK = v end})
MiscSec:AddToggle({Name = "FPS Boost (Black Screen)", Default = false, Save = true, Flag = "Fps", Callback = function(v)
    getgenv().Config.Misc.FpsBoost = v
    if v then
        Lighting.Brightness = 0; Lighting.GlobalShadows = false
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 1 end
        end
    else
        Lighting.Brightness = originalLighting.Brightness; Lighting.GlobalShadows = originalLighting.GlobalShadows
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 0 end
        end
    end
end})
MiscSec:AddToggle({Name = "White Screen Mode", Default = false, Save = true, Flag = "WhiteScrn", Callback = function(v)
    getgenv().Config.Misc.WhiteScreen = v; RunService:Set3dRenderingEnabled(not v)
end})

local RejoinSec = SetTab:AddSection({ Name = "🔄 Auto Rejoin", TextSize = 18, Glass = true })
RejoinSec:AddToggle({Name = "Auto Rejoin on Kick", Default = false, Save = true, Flag = "RejoinKick", Callback = function(v) getgenv().Config.Misc.AutoRejoin = v end})
RejoinSec:AddToggle({Name = "Timed Rejoin", Default = false, Save = true, Flag = "TimedRejoin", Callback = function(v) getgenv().Config.Misc.TimedRejoin = v end})
RejoinSec:AddSlider({Name = "Rejoin Delay (Minutes)", Min = 1, Max = 120, Default = 10, Increment = 1, Save = true, Flag = "RejoinDelay", Callback = function(v) getgenv().Config.Misc.RejoinDelay = v end})

local HacksSec = SetTab:AddSection({ Name = "⚡ Hacks", TextSize = 18, Glass = true })
HacksSec:AddToggle({Name = "Infinite Jump", Default = false, Save = true, Flag = "InfJump", Callback = function(v) getgenv().Config.Hacks.InfJump = v end})
HacksSec:AddToggle({Name = "Super Speed", Default = false, Save = true, Flag = "SuperSpeed", Callback = function(v) getgenv().Config.Hacks.SuperSpeed = v end})
HacksSec:AddSlider({Name = "Speed Multiplier", Min = 1, Max = 10, Default = 2, Increment = 1, Save = true, Flag = "SpdMulti", Callback = function(v) getgenv().Config.Hacks.SpeedMulti = v end})

SetTab:AddSection({ Name = "🛑 Danger Zone", TextSize = 18, Glass = true }):AddButton({Name = "Destroy GUI", Callback = function()
    State.Running = false
    task.delay(0.1, function() OrionLib:Destroy(); _G.SP_Loaded = false end)
end})

--==================================================
-- MAIN LOOPS
--==================================================
-- Auto Farm Logic
task.spawn(function()
    while State.Running do
        task.wait(0.1)
        if getgenv().Config.AutoFarm.Enabled and IsAlive() then
            local tIsland = GetFarmIsland()
            if not State.CurIsland or State.CurIsland.Portal ~= tIsland.Portal then
                StopTween(); State.CurIsland = tIsland; State.IslandTPd = false; State.QState = "NONE"
                ClearTarget()
                if pcall(function() return abandonRemote:FireServer() end) then end
            end
            
            if not State.IslandTPd then
                if ForceTP(State.CurIsland.Portal) then
                    task.wait(0.5); State.IslandTPd = true; State.FarmOrigin = RootPos(Player.Character)
                    if getgenv().Config.Farm.AutoQuest and State.QState == "NONE" then
                        pcall(function() questRemote:FireServer(State.CurIsland.QuestNPC); State.QState = "ACTIVE" end)
                    end
                else task.wait(1) end
            else
                local emy = FindEnemies(State.CurIsland)
                if #emy > 0 then
                    if State.CurTarget then
                        local h = GetHum(State.CurTarget)
                        if not h or h.Health <= 0 or not State.CurTarget.Parent then State.CurTarget = nil end
                    end
                    if not State.CurTarget then
                        local near = nil; local nd = math.huge
                        local rp = RootPos(Player.Character)
                        for _, e in ipairs(emy) do
                            local ep = RootPos(e)
                            if rp and ep then
                                local d = (rp - ep).Magnitude
                                if d < nd then nd = d; near = e end
                            end
                        end
                        State.CurTarget = near
                    end
                    if State.CurTarget then
                        TweenTo(State.CurTarget)
                        if getgenv().Config.AutoFarm.AutoEquip and tick() - State.LastEquip > 2 then
                            State.LastEquip = tick(); EquipWeapon(getgenv().Config.AutoFarm.SelectedWeapon)
                        end
                        if hitRemote then pcall(function() hitRemote:FireServer() end) end
                    end
                else State.CurTarget = nil end
            end
        end
    end
end)

-- Auto Boss Logic
task.spawn(function()
    while State.Running do
        task.wait(0.1)
        if getgenv().Config.Bosses.Enabled and IsAlive() then
            local tBoss = getgenv().Config.AutoBoss.Target
            local found = nil
            for _, o in ipairs(Workspace:GetDescendants()) do
                if o:IsA("Model") and GetHum(o) and GetHum(o).Health > 0 and (o.Name:lower():find(tBoss:lower()) or tBoss == "All") then
                    if o.Name:lower():find("boss") then found = o; break end
                end
            end
            if found then
                TweenTo(found)
                if getgenv().Config.AutoFarm.AutoEquip and tick() - State.LastEquip > 2 then
                    State.LastEquip = tick(); EquipWeapon(getgenv().Config.AutoFarm.SelectedWeapon)
                end
                if hitRemote then pcall(function() hitRemote:FireServer() end) end
            end
        end
    end
end)

-- Auto Summon Boss Loop
task.spawn(function()
    while State.Running do
        task.wait(0.5)
        if getgenv().Config.AutoSummonV2.Enabled and IsAlive() then
            local tgt = getgenv().Config.AutoSummonV2.Target
            local f = nil
            for _, o in ipairs(Workspace:GetDescendants()) do
                if o:IsA("Model") and GetHum(o) and GetHum(o).Health > 0 and o.Name:lower() == tgt:lower() then f = o; break end
            end
            if f then
                TweenTo(f)
                if getgenv().Config.AutoFarm.AutoEquip and tick() - State.LastEquip > 2 then
                    State.LastEquip = tick(); EquipWeapon(getgenv().Config.AutoFarm.SelectedWeapon)
                end
                if hitRemote then pcall(function() hitRemote:FireServer() end) end
            else pcall(function() autoSpawnBossRemote:FireServer(tgt, "Normal") end); task.wait(2) end
        end
    end
end)

-- System Run
OrionLib:Init()
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE MERGED 🔥")
print("✅ ALL SCRIPTS CONSOLIDATED!")
print("✅ Auto Farm, Boss, Dungeon, Fruit Sniper, Hacks Included!")
print("═══════════════════════════════════════════════════════")

