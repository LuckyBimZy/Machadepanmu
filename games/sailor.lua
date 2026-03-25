-- ==================================================
-- SAILOR PIECE ULTIMATE - CATRAZ HUB PREMIUM
-- REWRITTEN FROM SCRATCH - ZERO PYMPLE UI DEPENDENCIES
-- ==================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- Global Configuration State
getgenv().Config = {
    Running = true,
    IsFarm = false,
    IsAutoDungeon = false,

    AutoFarm = {
        Enabled = false, AutoEquip = true,
        SkillCooldown = 1.0, SelectedWeapon = "None"
    },
    Farm = {
        SelectedIsland = "Auto", FarmMode = "Behind",
        FollowStyle = "Dodge", HeightOffset = 15, OffsetDist = 15,
        TweenSpeed = 100, AutoQuest = true, AutoSpawn = false
    },
    AutoSkills = { Z = false, X = false, C = false, V = false, F = false },
    Misc = { AntiAFK = true, NoShake = false, NoCutscene = false, DisablePvP = false },
    Items = { AutoChest = false, FruitSniper = false, AutoBuy = false },
    Dungeon = { Enabled = false, Diff = "Normal" },
    Boss = { Enabled = false, NameTarget = nil },
    Quests = { Hogyoku = false, DungeonPieces = false },
    
    ItemToggles = {}, MerchantToggles = {},
    BossWorldToggles = {}, BossSummonToggles = {},
    DiffToggles = {}
}

local State = {
    TweenOn = false, ATween = nil, ATweenConn = nil, CurTarget = nil, LockTarget = nil, HoverPos = nil,
    FarmOrigin = nil, SpawnDone = false, IslandTPd = false, CurIsland = nil,
    TPCount = 0, LastTP = 0, LastEnemy = 0, TPReset = tick(),
    HumCache = setmetatable({}, {__mode = "k"}),
    CollectedItems = {}, BossPosCache = {}, LastMerchant = 0,
    SummonBossCurrentIsland = nil, SummonBossFight = false, BossFight = false,
    HogyokuStep = 0, DungeonStep = 0, BossDeathTimes = {}
}

-- Remotes Maps
local Constants = {
    ICON = "rbxassetid://105921924721005",
    NPC_FOLDER = "NPCs",

    Islands = {
        {Portal="Starter",FarmUntil=250,Enemies={"Thief"},QuestNPC="QuestNPC1"},
        {Portal="Jungle",FarmUntil=750,Enemies={"Monkey"},QuestNPC="QuestNPC3"},
        {Portal="Desert",FarmUntil=1500,Enemies={"DesertBandit"},QuestNPC="QuestNPC5"},
        {Portal="Snow",FarmUntil=3000,Enemies={"Swordsman","FrostRogue"},QuestNPC="QuestNPC7"},
        {Portal="Shibuya",FarmUntil=5000,Enemies={"Sorcerer","Curse"},QuestNPC="QuestNPC9"},
        {Portal="HuecoMundo",FarmUntil=6250,Enemies={"Hollow","Quincy"},QuestNPC="QuestNPC11"},
        {Portal="Shinjuku",FarmUntil=8000,Enemies={"StrongSorcerer"},QuestNPC="QuestNPC12"},
        {Portal="Slime",FarmUntil=9000,Enemies={"Slime"},QuestNPC="QuestNPC14"},
        {Portal="Academy",FarmUntil=10000,Enemies={"AcademyTeacher"},QuestNPC="QuestNPC15"},
        {Portal="Judgement",FarmUntil=10750,Enemies={"Swordsman"},QuestNPC="QuestNPC16"},
        {Portal="SoulSociety",FarmUntil=999999,Enemies={"Quincy1","Quincy2","Quincy3","Quincy4","Quincy5"},QuestNPC="QuestNPC17"}
    },
    TpIslands = {"Starter","Jungle","Desert","Snow","Sailor","Shibuya","HuecoMundo","Boss","Dungeon","Shinjuku","Slime","Academy","Judgement","SoulSociety"},
    
    IslandsInOrder = { "Auto Level", "Starter", "Jungle", "Desert", "Snow", "Sailor", "Shibuya Station", "Hollow Ilha", "Shinjuku", "Slime", "Academy", "Judgement", "Soul Dominion" },
    TeleportMap = {
        ["Auto Level"] = "Auto", ["Starter"] = "Starter", ["Jungle"] = "Jungle", ["Desert"] = "Desert",
        ["Snow"] = "Snow", ["Sailor"] = "Sailor", ["Shibuya Station"] = "Shibuya",
        ["Hollow Ilha"] = "HuecoMundo", ["Shinjuku"] = "Shinjuku", ["Slime"] = "Slime",
        ["Academy"] = "Academy", ["Judgement"] = "Judgement", ["Soul Dominion"] = "SoulSociety"
    },
    QuestDataMap = {
        ["Auto Level"] = {"Auto"},
        ["Starter"] = {"Thief", "ThiefBoss"},
        ["Jungle"] = {"Monkey", "MonkeyBoss"},
        ["Desert"] = {"DesertBandit", "DesertBoss"},
        ["Snow"] = {"FrostRogue", "SnowBoss"},
        ["Sailor"] = {"JinwooMovesetNPC"},
        ["Shibuya Station"] = {"Sorcerer", "PandaMiniBoss"},
        ["Hollow Ilha"] = {"Hollow"},
        ["Shinjuku"] = {"StrongSorcerer", "Curse"},
        ["Slime"] = {"Slime"},
        ["Academy"] = {"AcademyTeacher"},
        ["Judgement"] = {"Swordsman"},
        ["Soul Dominion"] = {"Quincy"}
    },

    WorldBosses = {
        {Name="AizenBoss",Display="Aizen",Island="HuecoMundo"},
        {Name="AlucardBoss",Display="Alucard",Island="Sailor"},
        {Name="GojoBoss",Display="Gojo",Island="Shibuya"},
        {Name="JinwooBoss",Display="Jinwoo",Island="Sailor"},
        {Name="SukunaBoss",Display="Sukuna",Island="Shibuya"},
        {Name="YamatoBoss",Display="Yamato",Island="Judgement"},
        {Name="YujiBoss",Display="Yuji",Island="Shibuya"}
    },
    SummonBosses = {
        {Name="AnosBoss",Display="Anos",Island="Academy",Diffs={"Normal","Medium","Hard","Extreme"}},
        {Name="BlessedMaidenBoss",Display="Blessed Maiden",Diffs={"Normal","Medium","Hard","Extreme"}},
        {Name="GilgameshBoss",Display="Gilgamesh",Diffs={"Normal","Medium","Hard","Extreme"}},
        {Name="RimuruBoss",Display="Rimuru",Island="Slime",Diffs={"Normal","Medium","Hard","Extreme"}},
        {Name="SaberAlterBoss",Display="Saber Alter",Diffs={"Normal","Medium","Hard","Extreme"}},
        {Name="StrongestHistoryBoss",Display="Strongest in History",Island="Shinjuku",Diffs={"Normal","Medium","Hard","Extreme"}},
        {Name="StrongestTodayBoss",Display="Strongest Today",Island="Shinjuku",Diffs={"Normal","Medium","Hard","Extreme"}},
        {Name="TrueAizenBoss",Display="True Aizen",Island="SoulSociety",Diffs={"Normal","Medium","Hard","Extreme"}},
        {Name="IchigoBoss",Display="Ichigo"},
        {Name="QinShiBoss",Display="Qin Shi"}
    },

    DungeonTypes = {"Double", "Rune", "Cid"},
    ChestNames = {"Common Chest", "Rare Chest", "Epic Chest", "Legendary Chest", "Mythical Chest"},
    MerchantItems = {"Boss Key", "Clan Reroll", "Dungeon Key", "Haki Color Reroll", "Race Reroll", "Rush Key", "Trait Reroll"}
}

-- Setup UI Base
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()
local S_Notify = function(title, content, duration)
    OrionLib:MakeNotification({Name = title, Content = content, Image = "info", Time = duration or 3})
end

local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece Ultimate",
    Subtext = "PREMIUM Edition v4.0",
    Version = "v4.0", VersionIcon = "shield-check",
    HidePremium = false, SaveConfig = true, ConfigFolder = "CatrazHubSP_V4",
    IntroEnabled = true, IntroText = "Sailor Piece CatrazHub",
    IntroIcon = Constants.ICON, Icon = Constants.ICON, ShowIcon = true,
    ImageBackground = "", ImageTransparency = 0.8, WindowTransparency = 0.05,
    ToggleIcon = Constants.ICON, ToggleSize = 50
})
OrionLib.SelectedTheme = "Ocean"
        {Name="TrueAizenBoss",Display="True Aizen",Difficulties={"Normal","Hard"}},
        {Name="StrongestHistoryBoss",Display="Strongest History (Sukuna)",Difficulties={"Normal","Hard"}},
        {Name="StrongestTodayBoss",Display="Strongest Today (Gojo)",Difficulties={"Normal","Hard"}}
    }
}

-- ==================================================
-- UTILITIES
-- ==================================================

local Util = {}
local R = {
    TP={"Remotes","TeleportToPortal"}, QuestAccept={"RemoteEvents","QuestAccept"}, QuestAbandon={"RemoteEvents","QuestAbandon"},
    QuestRepeat={"RemoteEvents","QuestRepeat"}, Hit={"CombatSystem","Remotes","RequestHit"}, Ability={"AbilitySystem","Remotes","RequestAbility"},
    Awaken={"AbilitySystem","Remotes","Awakening"}, Merchant={"Remotes","MerchantRemotes","PurchaseMerchantItem"}, Chest={"Remotes","OpenChest"},
    SummonBoss={"Remotes","RequestSummonBoss"}, AnosBoss={"Remotes","RequestSpawnAnosBoss"}, StrongestBoss={"Remotes","RequestSpawnStrongestBoss"},
    RimuruSpawn={"RemoteEvents","RequestSpawnRimuru"}, TrueAizenSpawn={"RemoteEvents","RequestSpawnTrueAizen"},
    DungeonVote={"Remotes","DungeonWaveVote"}, DungeonPortal={"Remotes","RequestDungeonPortal"}
}

function Util.WalkPathWait(parent, to, ...)
    local cur = parent
    for _, n in ipairs({...}) do
        cur = cur:WaitForChild(n, to)
        if not cur then return nil end
    end
    return cur
end

function Util.IsAlive()
    if not Player.Character then return false end
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    return hrp ~= nil and hum ~= nil and hum.Health > 0
end

function Util.WaitChar()
    if Util.IsAlive() then return true end
    local t = tick()
    while tick() - t < 15 do
        if Util.IsAlive() then task.wait(0.5) return true end
        task.wait(0.25)
    end
    return false
end

function Util.GetLevel()
    local lv = 0
    pcall(function() 
        local ls = Player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Level") then lv = tonumber(ls.Level.Value) or 0 end
    end)
    return lv
end

function Util.ModelPos(model)
    if not model then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then return hrp.Position end
    if model:IsA("Model") and model.PrimaryPart then return model.PrimaryPart.Position end
    for _, part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart") then return part.Position end
    end
    return nil
end

function Util.GetHum(model)
    if not model then return nil end
    local cached = State.HumCache[model]
    if cached and cached.Parent ~= nil then return cached end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then State.HumCache[model] = hum return hum end
    return nil
end

function Util.StopTween()
    if State.ATweenConn then pcall(function() State.ATweenConn:Disconnect() end); State.ATweenConn = nil end
    if State.ATween then pcall(function() State.ATween:Cancel() end); State.ATween = nil end
    State.TweenOn = false
end

function Util.TweenTo(targetCFrame, speedParam, safeDist)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    if safeDist and dist <= safeDist then return end
    
    local speed = speedParam or getgenv().Config.Farm.TweenSpeed
    local stepDist = math.min(dist, 80)
    local dir = (targetCFrame.Position - hrp.Position).Unit
    if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, 1) end
    
    local stepGoal = hrp.Position + (dir * stepDist)
    local cf = CFrame.new(stepGoal, targetCFrame.Position)
    local timeToReach = math.clamp(stepDist / math.max(speed, 1), 0.06, 3.0)
    
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
    Util.StopTween()
    
    State.TweenOn = true
    State.ATween = TweenService:Create(hrp, tweenInfo, {CFrame = cf})
    State.ATween:Play()
    
    State.ATweenConn = State.ATween.Completed:Connect(function()
        State.TweenOn = false
    end)
end

function Util.ForceTP(portalName)
    Util.StopTween()
    pcall(function() 
        local r = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.TP))
        if r then r:FireServer(portalName) end 
    end)
end

function Util.Stabilize(hrp, goalCF)
    local bv = hrp:FindFirstChild("FarmBVelocity")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FarmBVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = hrp
    end
    bv.Velocity = Vector3.new(0, 0, 0)
    
    local bg = hrp:FindFirstChild("FarmBGyro")
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = "FarmBGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 3000
        bg.D = 500
        bg.Parent = hrp
    end
    bg.CFrame = goalCF
end

function Util.Destabilize(hrp)
    local bv = hrp:FindFirstChild("FarmBVelocity")
    if bv then bv:Destroy() end
    local bg = hrp:FindFirstChild("FarmBGyro")
    if bg then bg:Destroy() end
end

local function SetupAntiAFK()
    local vu = game:GetService("VirtualUser")
    Players.LocalPlayer.Idled:Connect(function()
        if getgenv().Config.Misc.AntiAFK then
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
end
task.spawn(SetupAntiAFK)


-- ==================================================
-- AUTO FARMING & SKILL LOGICS
-- ==================================================

local function GetIslandForLevel()
    local lv = Util.GetLevel()
    for _, isl in ipairs(Constants.Islands) do
        if lv < isl.FarmUntil then return isl end
    end
    return Constants.Islands[#Constants.Islands]
end

local function GetFarmIsland()
    local selected = getgenv().Config.Farm.SelectedIsland
    if selected == "Auto" then return GetIslandForLevel() end
    for _, isl in ipairs(Constants.Islands) do
        if isl.Portal == selected then return isl end
    end
    return GetIslandForLevel()
end

local function MatchEnemy(name, island)
    if not island then return false end
    
    -- Specific Mob Targeting Support
    local selectedIsland = getgenv().Config.Farm.SelectedIsland
    local selectedMob = getgenv().Config.Farm.SelectedMob
    if selectedIsland ~= "Auto Level" and selectedMob and selectedMob ~= "Auto" and selectedMob ~= "Nenhum" then
        local lowerName = string.lower(name:gsub("%d+",""):gsub("%s+",""))
        local targetName = string.lower(selectedMob:gsub("%s+",""))
        return string.find(lowerName, targetName) ~= nil
    end
    
    local lowerName = string.lower(name)
    for _, e in ipairs(island.Enemies) do
        if string.find(lowerName, string.lower(e)) then return true end
    end
    return false
}

local function FindEnemies(island)
    if not island then return {} end
    local npcs = workspace:FindFirstChild(Constants.NPC_FOLDER)
    if not npcs then return {} end
    
    local found = {}
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    
    local function check(m)
        if m:IsA("Model") then
            local hum = Util.GetHum(m)
            if hum and hum.Health > 0 and MatchEnemy(m.Name, island) then
                local p = Util.ModelPos(m)
                if p and hrp then
                    table.insert(found, m)
                end
            end
        end
    end
    
    for _, child in ipairs(npcs:GetChildren()) do
        check(child)
        if child:IsA("Folder") then
            for _, m in ipairs(child:GetChildren()) do check(m) end
        end
    end
    return found
}

local function BestEnemy(list)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or #list == 0 then return nil end
    local mypos = hrp.Position
    local bestE, bestD = nil, math.huge
    for _, e in ipairs(list) do
        local p = Util.ModelPos(e)
        if p then
            local dist = (mypos - p).Magnitude
            if dist < bestD then
                bestD = dist
                bestE = e
            end
        end
    end
    return bestE
}

local lastArmamentToggle, lastObsToggle = 0, 0

local function CheckHaki()
    local char = Player.Character
    if not char then return end
    
    if getgenv().Config.AutoFarm.AutoArmament and tick() - lastArmamentToggle > 3 then
        local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        if rightArm and rightArm.BrickColor ~= BrickColor.new("Really black") then
            lastArmamentToggle = tick()
            pcall(function() 
                local r = Util.WalkPathWait(ReplicatedStorage, 2, "AbilitySystem", "Remotes", "Haki")
                if r then r:FireServer("Toggle") end
            end)
        end
    end
    
    if getgenv().Config.AutoFarm.AutoObservation and tick() - lastObsToggle > 3 then
        local pg = Player:FindFirstChild("PlayerGui")
        local dodgeUI = pg and pg:FindFirstChild("DodgeCounterUI")
        local isVis = dodgeUI and dodgeUI:FindFirstChild("MainFrame") and dodgeUI.MainFrame.Visible
        
        local cdUI = pg and pg:FindFirstChild("CooldownUI")
        local onCd = cdUI and cdUI:FindFirstChild("MainFrame") and cdUI.MainFrame:FindFirstChild("Cooldown_ObsHaki_Observation") ~= nil
        
        if not isVis and not onCd then
            lastObsToggle = tick()
            pcall(function() 
                local r = Util.WalkPathWait(ReplicatedStorage, 2, "AbilitySystem", "Remotes", "ObservationHaki")
                if r then r:FireServer("Toggle") end
            end)
        end
    end
end

local function EquipWeapon()
    if not getgenv().Config.AutoFarm.AutoEquip then return end
    
    local c = Player.Character
    local hm = c and c:FindFirstChildOfClass("Humanoid")
    if not hm then return end
    local bp = Player:FindFirstChild("Backpack")
    if not bp then return end
    
    local targetWep = getgenv().Config.AutoFarm.SelectedWeapon
    if targetWep and targetWep ~= "None" then
        if c:FindFirstChild(targetWep) then return end
        local tool = bp:FindFirstChild(targetWep)
        if tool then
            hm:UnequipTools()
            task.wait(0.1)
            pcall(function() hm:EquipTool(tool) end)
        end
        return
    end
    
    local melee, sword = nil, nil
    local function checkT(t)
        local n = t.Name:lower()
        if n:find("melee") or n:find("combat") or n:find("fist") then melee = t
        elseif n:find("sword") or n:find("katana") or n:find("blade") then sword = t end
    end
    
    for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then checkT(t) end end
    for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then checkT(t) end end
    
    if melee and sword then
        if not c:FindFirstChild(sword.Name) then
            pcall(function() hm:EquipTool(sword) end)
            task.wait(0.05)
            pcall(function() hm:EquipTool(melee) end)
        end
    elseif sword and not melee then
        if not c:FindFirstChild(sword.Name) then pcall(function() hm:EquipTool(sword) end) end
    elseif melee and not sword then
        if not c:FindFirstChild(melee.Name) then pcall(function() hm:EquipTool(melee) end) end
    else
        for _, obj in ipairs(c:GetChildren()) do if obj:IsA("Tool") then return end end
        local fb = bp:FindFirstChildOfClass("Tool")
        if fb then pcall(function() hm:EquipTool(fb) end) end
    end
end

local lastSkill = 0
local function AutoSkillCast()
    if tick() - lastSkill < getgenv().Config.AutoFarm.SkillCooldown then return end
    local c = getgenv().Config.AutoSkills
    if not (c.Z or c.X or c.C or c.V or c.F) then return end
    
    local rAbility, rAwaken = nil, nil
    pcall(function() rAbility = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.Ability)) end)
    pcall(function() rAwaken = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.Awaken)) end)
    
    lastSkill = tick()
    if c.Z and rAbility then pcall(function() rAbility:FireServer(1) end) end
    if c.X and rAbility then pcall(function() rAbility:FireServer(2) end) end
    if c.C and rAbility then pcall(function() rAbility:FireServer(3) end) end
    if c.V and rAbility then pcall(function() rAbility:FireServer(4) end) end
    if c.F and rAwaken then pcall(function() rAwaken:FireServer(5) end) end
end

local function AttackTarget(tgt)
    pcall(function() 
        local r = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.Hit))
        if r then r:FireServer(tgt) end 
    end)
    AutoSkillCast()
end

local function GetCombatPosition(targetPos, targetCF)
    local cfg = getgenv().Config.Farm
    local offsetDist = cfg.OffsetDist
    local h = cfg.HeightOffset
    
    local lookFlat = Vector3.new(targetCF.LookVector.X, 0, targetCF.LookVector.Z)
    if lookFlat.Magnitude > 0.01 then lookFlat = lookFlat.Unit else lookFlat = Vector3.new(0, 0, 1) end
    local rightFlat = Vector3.new(-lookFlat.Z, 0, lookFlat.X)
    
    local primary
    if cfg.FarmMode == "In Front" then primary = lookFlat
    elseif cfg.FarmMode == "Left Side" then primary = rightFlat
    elseif cfg.FarmMode == "Right Side" then primary = -rightFlat
    else primary = -lookFlat end
    
    local perp = Vector3.new(-primary.Z, 0, primary.X)
    local dirs = {primary, perp, -perp, -primary}
    
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    if Player.Character then rp.FilterDescendantsInstances = {Player.Character} end
    
    for _, dir in ipairs(dirs) do
        if dir.Magnitude > 0.1 then
            dir = Vector3.new(dir.X, 0, dir.Z).Unit
            local goal = targetPos + dir * offsetDist
            local ray = workspace:Raycast(targetPos, dir * offsetDist, rp)
            if not ray then return CFrame.new(Vector3.new(goal.X, targetPos.Y + h, goal.Z), targetPos) end
        end
    end
    return CFrame.new(Vector3.new(targetPos.X, targetPos.Y + h, targetPos.Z + offsetDist), targetPos)
end

local function FarmTick()
    if not getgenv().Config.AutoFarm.Enabled then return end
    
    local isl = GetFarmIsland()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if tick() - State.LastTP > 15 then State.IslandTPd = false end
    
    -- Questing logic
    if getgenv().Config.Farm.AutoQuest and isl.QuestNPC then
        if not State.LastQuestAccept then State.LastQuestAccept = 0 end
        if tick() - State.LastQuestAccept > 5 then
            State.LastQuestAccept = tick()
            pcall(function() 
                local qr = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.QuestRepeat))
                if qr then qr:FireServer(isl.Portal) end
                local qa = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.QuestAccept))
                if qa then qa:FireServer(isl.QuestNPC) end
            end)
        end
    end
    
    local target = BestEnemy(FindEnemies(isl))
    if not target then
        -- Teleport to island if no enemies nearby
        if not State.IslandTPd then
            State.IslandTPd = true
            State.LastTP = tick()
            Util.ForceTP(isl.Portal)
            task.wait(1.5)
        end
        return
    end
    
    local ePos = Util.ModelPos(target)
    local eCF = target.PrimaryPart and target.PrimaryPart.CFrame or CFrame.new(ePos)
    if not ePos then return end
    
    local combatPos = GetCombatPosition(ePos, eCF)
    
    hrp.Velocity = Vector3.new(0, 0, 0)
    
    -- Anti-Jitter BodyGyro stabilizer mechanism
    if (hrp.Position - ePos).Magnitude > 150 and getgenv().Config.Farm.MoveMode == "Tween" then
        Util.Destabilize(hrp)
        Util.TweenTo(combatPos)
    else
        Util.StopTween()
        Util.Stabilize(hrp, combatPos)
        hrp.CFrame = combatPos
    end
    
    CheckHaki()
    EquipWeapon()
    AttackTarget(target)
end


-- ==================================================
-- AUTO DUNGEON & BOSS RUSH
-- ==================================================

local function IsInDungeon()
    return workspace:FindFirstChild("DungeonSpawn") ~= nil
end

local function IsInDungeonLobby()
    return workspace:FindFirstChild("DungeonPart") ~= nil
end

local DungeonBossMap = {
    Rune = {}, Cid = {["shadowboss"]=true}, Double = {["shadowmonarchboss"]=true}
}
local DungeonEnemyNames = {"DungeonNPC1","DungeonNPC2","DungeonNPC3","DungeonNPC4","DungeonNPC5"}

local function IsDungeonEnemy(model)
    if not model or not model:IsA("Model") then return false end
    local lo = (model.Name or ""):lower()
    
    for _, base in ipairs(DungeonEnemyNames) do
        local bl = string.lower(base)
        if string.sub(lo, 1, #bl) == bl then return true end
    end
    
    local dtype = getgenv().Config.Dungeon.Diff or "Double"
    local bossMap = DungeonBossMap[dtype]
    if bossMap then
        if bossMap[lo] then return true end
        for name in pairs(bossMap) do
            if string.sub(lo, 1, #name) == name then return true end
        end
    end
    return false
end

local function FindDungeonEnemies()
    local found = {}
    local npcs = workspace:FindFirstChild(Constants.NPC_FOLDER)
    if not npcs then return found end
    
    local function check(m)
        if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) and IsDungeonEnemy(m) then
            local hum = Util.GetHum(m)
            if hum and hum.Health > 0 then table.insert(found, m) end
        end
    end
    
    for _, child in ipairs(npcs:GetChildren()) do
        check(child)
        if child:IsA("Folder") then for _, m in ipairs(child:GetChildren()) do check(m) end end
    end
    return found
end

local function DungeonTick()
    if not getgenv().Config.Dungeon.Enabled then return end
    
    local inDung = IsInDungeon()
    local inLobby = IsInDungeonLobby()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not inDung and not inLobby then
        Util.ForceTP("Dungeon")
        return
    end
    
    if inLobby then
        local lobbyPart = workspace:FindFirstChild("DungeonPart")
        if lobbyPart then
            Util.TweenTo(lobbyPart.CFrame * CFrame.new(0, 3, 0), 150)
            -- Auto vote
            pcall(function() 
                local vote = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.DungeonVote))
                if vote then vote:FireServer(getgenv().Config.Dungeon.Diff or "Normal") end
            end)
        end
        return
    end
    
    if inDung then
        State.TweenOn = false
        local target = BestEnemy(FindDungeonEnemies())
        if not target then return end
        
        local pos = Util.ModelPos(target)
        if not pos then return end
        local cf = target.PrimaryPart and target.PrimaryPart.CFrame or CFrame.new(pos)
        
        local combatPos = GetCombatPosition(pos, cf)
        
        if (hrp.Position - pos).Magnitude > 150 and getgenv().Config.Farm.MoveMode == "Tween" then
            Util.Destabilize(hrp)
            Util.TweenTo(combatPos)
        else
            Util.StopTween()
            Util.Stabilize(hrp, combatPos)
            hrp.CFrame = combatPos
        end
        
        CheckHaki()
        EquipWeapon()
        AttackTarget(target)
    end
end

local function BossRushTick()
    if not getgenv().Config.AutoBossRush then return end
    
    local inDung = IsInDungeon()
    local inLobby = IsInDungeonLobby()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not inDung and not inLobby then
        Util.ForceTP("Dungeon")
        return
    end
    
    if inLobby then
        local lobbyPart = workspace:FindFirstChild("DungeonPart")
        if lobbyPart then Util.TweenTo(lobbyPart.CFrame * CFrame.new(0, 3, 0), 150) end
        
        pcall(function() 
            local portal = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.DungeonPortal))
            if portal then portal:FireServer("BossRush") end
        end)
        return
    end
    
    if inDung then
        -- Boss Rush treats all bosses as enemies in NPC folder
        local found = {}
        local npcs = workspace:FindFirstChild(Constants.NPC_FOLDER)
        if npcs then
            for _, ch in ipairs(npcs:GetDescendants()) do
                if ch:IsA("Model") and not Players:GetPlayerFromCharacter(ch) and ch.Name:lower():find("boss") then
                    local hum = Util.GetHum(ch)
                    if hum and hum.Health > 0 then table.insert(found, ch) end
                end
            end
        end
        
        local target = BestEnemy(found)
        if not target then return end
        
        local pos = Util.ModelPos(target)
        if not pos then return end
        local cf = target.PrimaryPart and target.PrimaryPart.CFrame or CFrame.new(pos)
        
        local combatPos = GetCombatPosition(pos, cf)
        
        if (hrp.Position - pos).Magnitude > 150 and getgenv().Config.Farm.MoveMode == "Tween" then
            Util.Destabilize(hrp)
            Util.TweenTo(combatPos)
        else
            Util.StopTween()
            Util.Stabilize(hrp, combatPos)
            hrp.CFrame = combatPos
        end
        
        CheckHaki()
        EquipWeapon()
        AttackTarget(target)
    end
end


-- ==================================================
-- RAID & WORLD BOSSES
-- ==================================================

local function GetWorldBossIsland(targetName)
    for _, b in ipairs(Constants.WorldBosses) do
        if b.Name == targetName then return b.Island end
    end
    return nil
end

local function AnyBossSelected()
    for _, tgl in pairs(getgenv().Config.BossWorldToggles) do
        if tgl then return true end
    end
    return false
end

local function PickNextWorldBoss()
    for name, enabled in pairs(getgenv().Config.BossWorldToggles) do
        if enabled then
            local nextSpawn = State.BossDeathTimes[name]
            if not nextSpawn or (tick() - nextSpawn) > 300 then
                return name
            end
        end
    end
    return nil
end

local function BossTick()
    if not getgenv().Config.Boss.Enabled then return end
    if not AnyBossSelected() then return end
    
    local targetName = getgenv().Config.Boss.NameTarget
    if not targetName then
        local nextName = PickNextWorldBoss()
        if nextName then
            getgenv().Config.Boss.NameTarget = nextName
            State.LastBossTP = 0
            State.CurIsland = nil
            State.IslandTPd = false
            return
        end
        return
    end
    
    local island = GetWorldBossIsland(targetName)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local npcs = workspace:FindFirstChild(Constants.NPC_FOLDER)
    if not npcs then return end
    
    local bossModel = nil
    for _, m in ipairs(npcs:GetDescendants()) do
        if m:IsA("Model") and m.Name == targetName then
            local hum = Util.GetHum(m)
            if hum and hum.Health > 0 then
                bossModel = m
                break
            end
        end
    end
    
    if not bossModel then
        if island and not State.IslandTPd then
            if tick() - State.LastBossTP > 3 then
                State.LastBossTP = tick()
                Util.ForceTP(island)
                task.wait(2)
                State.IslandTPd = true
            end
            return
        end
        -- If no boss found on island after TP, record death time and switch target
        State.BossDeathTimes[targetName] = tick()
        getgenv().Config.Boss.NameTarget = nil
        return
    end
    
    -- Engage
    local pos = Util.ModelPos(bossModel)
    local cf = bossModel.PrimaryPart and bossModel.PrimaryPart.CFrame or CFrame.new(pos)
    
    local combatPos = GetCombatPosition(pos, cf)
    
    if (hrp.Position - pos).Magnitude > 150 and getgenv().Config.Farm.MoveMode == "Tween" then
        Util.Destabilize(hrp)
        Util.TweenTo(combatPos)
    else
        Util.StopTween()
        Util.Stabilize(hrp, combatPos)
        hrp.CFrame = combatPos
    end
    
    CheckHaki()
    EquipWeapon()
    AttackTarget(bossModel)
end

local function SummonBossTick()
    -- Handling Anos, Rimuru, etc. (Requires specific spawning mechanism)
    local activeSummon = nil
    for name, enabled in pairs(getgenv().Config.BossSummonToggles) do
        if enabled then activeSummon = name break end
    end
    if not activeSummon then return end
    
    local bDef
    for _, d in ipairs(Constants.SummonBosses) do
        if d.Name == activeSummon then bDef = d break end
    end
    if not bDef then return end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local npcs = workspace:FindFirstChild(Constants.NPC_FOLDER)
    local bossModel = nil
    if npcs then
        for _, m in ipairs(npcs:GetDescendants()) do
            if m:IsA("Model") and m.Name == bDef.Name then
                local hum = Util.GetHum(m)
                if hum and hum.Health > 0 then bossModel = m break end
            end
        end
    end
    
    if bossModel then
        -- Engage Raid Boss
        local pos = Util.ModelPos(bossModel)
        local cf = bossModel.PrimaryPart and bossModel.PrimaryPart.CFrame or CFrame.new(pos)
        
        local combatPos = GetCombatPosition(pos, cf)
        
        if (hrp.Position - pos).Magnitude > 150 and getgenv().Config.Farm.MoveMode == "Tween" then
            Util.Destabilize(hrp)
            Util.TweenTo(combatPos)
        else
            Util.StopTween()
            Util.Stabilize(hrp, combatPos)
            hrp.CFrame = combatPos
        end
        
        CheckHaki()
        EquipWeapon()
        AttackTarget(bossModel)
    else
        -- Need to spawn
        if bDef.Island and not State.IslandTPd then
            if tick() - State.LastBossTP > 5 then
                State.LastBossTP = tick()
                Util.ForceTP(bDef.Island)
                task.wait(2)
                State.IslandTPd = true
            end
            return
        end
        
        -- Spawn the boss!
        local diffObj = getgenv().Config.DiffToggles[bDef.Name]
        local diffArg = diffObj and diffObj or "Normal"
        
        local function FireSpawn(path, ...)
            local args = {...}
            pcall(function()
                local rem = Util.WalkPathWait(ReplicatedStorage, 2, unpack(path))
                if rem then rem:InvokeServer(unpack(args)) end
            end)
        end
        
        if bDef.Name == "AnosBoss" then FireSpawn(R.AnosBoss, diffArg)
        elseif bDef.Name == "StrongestHistoryBoss" then FireSpawn(R.StrongestBoss, diffArg, "History")
        elseif bDef.Name == "StrongestTodayBoss" then FireSpawn(R.StrongestBoss, diffArg, "Today")
        elseif bDef.Name == "RimuruBoss" then FireSpawn(R.RimuruSpawn, diffArg)
        elseif bDef.Name == "TrueAizenBoss" then FireSpawn(R.TrueAizenSpawn, diffArg)
        else
            local nForArgs = bDef.Name:gsub("Boss","")
            FireSpawn(R.SummonBoss, nForArgs, diffArg)
        end
        task.wait(2)
    end
end


-- ==================================================
-- SPECIAL QUESTS & COLLECTIBLES
-- ==================================================

local function AutoChestTick()
    if not getgenv().Config.Items.AutoChest then return end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local chestsFolder = workspace:FindFirstChild("Chests")
    if not chestsFolder then return end
    
    local o = {}
    for _, ch in ipairs(chestsFolder:GetChildren()) do
        if ch:IsA("Model") and getgenv().Config.ItemToggles[ch.Name] then
            local pp = ch.PrimaryPart
            if pp and (hrp.Position - pp.Position).Magnitude < 150 then table.insert(o, ch.Name) end
        end
    end
    
    if #o > 0 then
        pcall(function() 
            local r = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.Chest))
            if r then r:FireServer(o) end
        end)
    end
end

local function AutoMerchantTick()
    if not getgenv().Config.Items.AutoBuy then return end
    if tick() - State.LastMerchant < 5 then return end
    State.LastMerchant = tick()
    
    local npcs = workspace:FindFirstChild(Constants.NPC_FOLDER)
    if not npcs then return end
    
    local merchFolder = npcs:FindFirstChild("Merchant")
    if merchFolder then
        local remote = Util.WalkPathWait(ReplicatedStorage, 2, unpack(R.Merchant))
        if remote then
            for item, enabled in pairs(getgenv().Config.MerchantToggles) do
                if enabled then pcall(function() remote:InvokeServer(item) end) end
            end
        end
    end
end

local function AutoCraftTick()
    if getgenv().Config.Items.CraftSlime then
        pcall(function() 
            local r = Util.WalkPathWait(ReplicatedStorage, 2, "Remotes", "RequestSlimeCraft")
            if r then r:InvokeServer("SlimeKey", 1) end
        end)
    end
    if getgenv().Config.Items.CraftGrail then
        pcall(function() 
            local r = Util.WalkPathWait(ReplicatedStorage, 2, "Remotes", "RequestGrailCraft")
            if r then r:InvokeServer("DivineGrail", 1) end
        end)
    end
end

local HogyokuIslands = {"Snow","Shibuya","HuecoMundo","Shinjuku","Slime","Judgement"}
local function HogyokuTick()
    if not getgenv().Config.Quests.Hogyoku then return end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if State.HogyokuStep == 0 then
        -- Accept quest remotely
        local rem = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("QuestAccept")
        if rem then pcall(function() rem:FireServer("QuestNPC20") end) end
        State.HogyokuStep = 1
        State.CurIsland = nil
        State.IslandTPd = false
        task.wait(1)
        return
    end
    
    if State.HogyokuStep >= 1 and State.HogyokuStep <= 6 then
        local targetIsl = HogyokuIslands[State.HogyokuStep]
        if not State.IslandTPd then
            if tick() - State.LastTP > 4 then
                State.LastTP = tick()
                Util.ForceTP(targetIsl)
                State.IslandTPd = true
                task.wait(2)
            end
            return
        end
        
        -- Find fragment
        local frag = workspace:FindFirstChild("HogyokuFragment")
        if frag and frag:IsA("BasePart") then
            Util.TweenTo(frag.CFrame, 150)
            if (hrp.Position - frag.Position).Magnitude < 10 then
                if fireproximityprompt then
                    local px = frag:FindFirstChildOfClass("ProximityPrompt")
                    if px then fireproximityprompt(px) end
                end
                task.wait(1)
                State.HogyokuStep = State.HogyokuStep + 1
                State.IslandTPd = false
            end
        else
            -- Check if it got collected
            local backpack = Player:FindFirstChild("Backpack")
            if backpack and backpack:FindFirstChild("HogyokuFragment") then
                State.HogyokuStep = State.HogyokuStep + 1
                State.IslandTPd = false
            end
        end
    end
    
    if State.HogyokuStep > 6 then
        -- Turn in at Hueco Mundo
        if not State.IslandTPd then
            if tick() - State.LastTP > 4 then
                State.LastTP = tick()
                Util.ForceTP("HuecoMundo")
                State.IslandTPd = true
                task.wait(2)
            end
            return
        end
        -- Move to Gin to complete
        local npcs = workspace:FindFirstChild(Constants.NPC_FOLDER)
        local gin = npcs and npcs:FindFirstChild("Gin")
        if gin then
            local pos = Util.ModelPos(gin)
            if pos then
                Util.TweenTo(CFrame.new(pos))
                if (hrp.Position - pos).Magnitude < 15 and fireproximityprompt then
                    local px = gin:FindFirstChildOfClass("ProximityPrompt", true)
                    if px then fireproximityprompt(px) end
                    task.wait(1)
                    State.HogyokuStep = 0
                    State.IslandTPd = false
                    getgenv().Config.Quests.Hogyoku = false
                    S_Notify("Hogyoku Quest", "Quest Completed!")
                end
            end
        end
    end
end


-- ==================================================
-- UI CONSTRUCTION & BINDINGS
-- ==================================================

-- MAIN
local MainTab = Window:MakeTab({Name = "🎯 Main", Icon = "home"})
local InfoSec = MainTab:AddSection({Name = "👤 Player Info", TextSize = 16, Glass = true})
local LvlLbl = InfoSec:AddLabel("Level: Loading...")
task.spawn(function()
    while getgenv().Config.Running do task.wait(2)
        local d = Player:FindFirstChild("Data")
        if d and d:FindFirstChild("Level") then LvlLbl:Set("Level: "..d.Level.Value) end
    end
end)

local DashSec = MainTab:AddSection({Name = "🔧 Dashboard", TextSize = 16, Glass = true})
DashSec:AddToggle({Name = "Anti-AFK", Default = true, Flag = "AntiAFK", Save=true, Callback = function(v) getgenv().Config.Misc.AntiAFK = v end})

-- FARMING
local FarmTab = Window:MakeTab({Name = "⚔️ Farming", Icon = "swords"})
local FarmSec = FarmTab:AddSection({Name = "⚙️ Auto Level", TextSize = 18, Glass = true})

local fTgl
fTgl = FarmSec:AddToggle({Name = "Enable Auto Farm", Default = false, Flag = "AFarm", Save=true, Callback=function(v)
    if v and (getgenv().Config.Dungeon.Enabled or getgenv().Config.AutoBossRush or getgenv().Config.Boss.Enabled) then
        task.defer(function() pcall(function() fTgl:Set(false) end) end); return
    end
    getgenv().Config.AutoFarm.Enabled = v
    if not v then
        Util.StopTween()
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("FarmBVelocity") then hrp.FarmBVelocity:Destroy() end
    end
end})

FarmSec:AddToggle({Name = "Auto Equip", Default = true, Flag="AEquip", Save=true, Callback=function(v) getgenv().Config.AutoFarm.AutoEquip = v end})
FarmSec:AddToggle({Name = "Auto Quest", Default = true, Flag="AQuest", Save=true, Callback=function(v) getgenv().Config.Farm.AutoQuest = v end})

local mobDrop
FarmSec:AddDropdown({Name = "Select Island", Default = "Auto Level", Options = Constants.IslandsInOrder, Flag="SelIsl2", Save=true, Callback=function(v) 
    getgenv().Config.Farm.SelectedIsland = v
    if mobDrop then
        local mobs = Constants.QuestDataMap[v] or {"Auto"}
        mobDrop:Refresh(mobs, true)
        getgenv().Config.Farm.SelectedMob = mobs[1]
    end
end})

mobDrop = FarmSec:AddDropdown({Name = "Select Mob", Default = "Auto", Options = {"Auto"}, Flag="SelMob", Save=true, Callback=function(v)
    getgenv().Config.Farm.SelectedMob = v
end})

local PosiSec = FarmTab:AddSection({Name = "📐 Positioning", TextSize = 16, Glass = true})
PosiSec:AddDropdown({Name = "Farm Mode", Default = "Behind", Options = {"Behind", "In Front", "Left Side", "Right Side"}, Flag="FMode", Save=true, Callback=function(v) getgenv().Config.Farm.FarmMode = v end})
PosiSec:AddDropdown({Name = "Travel Mode", Default = "Tween", Options = {"Tween", "Teleport"}, Flag="TMode", Save=true, Callback=function(v) getgenv().Config.Farm.MoveMode = v end})
PosiSec:AddSlider({Name = "Offset Distance", Min = 5, Max = 50, Default = 15, Increment=1, Flag="OffDist", Save=true, Callback=function(v) getgenv().Config.Farm.OffsetDist = v end})

-- GAMEMODES
local GameTab = Window:MakeTab({Name = "🏰 Gamemodes", Icon = "castle"})
local DungSec = GameTab:AddSection({Name = "🚪 Dungeons", TextSize = 18, Glass = true})
DungSec:AddDropdown({Name = "Dungeon Type", Default = "Double", Options = {"Double", "Rune", "Cid"}, Flag="DType", Save=true, Callback=function(v) getgenv().Config.Dungeon.Diff = v end})

local dTgl
dTgl = DungSec:AddToggle({Name = "Enable Auto Dungeon", Default = false, Flag="ADung", Save=true, Callback=function(v)
    if v and (getgenv().Config.AutoFarm.Enabled or getgenv().Config.AutoBossRush) then task.defer(function() pcall(function() dTgl:Set(false) end) end); return end
    getgenv().Config.Dungeon.Enabled = v
    if not v then Util.StopTween() end
end})

local BRSec = GameTab:AddSection({Name = "💀 Boss Rush", TextSize = 18, Glass = true})
local brTgl
brTgl = BRSec:AddToggle({Name = "Enable Boss Rush", Default = false, Flag="ABR", Save=true, Callback=function(v)
    if v and (getgenv().Config.AutoFarm.Enabled or getgenv().Config.Dungeon.Enabled) then task.defer(function() pcall(function() brTgl:Set(false) end) end); return end
    getgenv().Config.AutoBossRush = v
    if not v then Util.StopTween() end
end})

-- BOSSES
local BossTab = Window:MakeTab({Name = "👹 Bosses", Icon = "skull"})
local WBSec = BossTab:AddSection({Name = "🌍 World Bosses", TextSize = 18, Glass = true})
local wbTgl
wbTgl = WBSec:AddToggle({Name = "Enable World Bosses", Default = false, Flag="EWB", Save=true, Callback=function(v)
    if v and (getgenv().Config.AutoFarm.Enabled or getgenv().Config.Dungeon.Enabled) then task.defer(function() pcall(function() wbTgl:Set(false) end) end); return end
    getgenv().Config.Boss.Enabled = v
    if not v then Util.StopTween(); getgenv().Config.Boss.NameTarget=nil end
end})

for _, b in ipairs(Constants.WorldBosses) do
    WBSec:AddToggle({Name = b.Display.." ("..b.Island..")", Default=false, Flag="WB_"..b.Name, Save=true, Callback=function(v) getgenv().Config.BossWorldToggles[b.Name] = v end})
end

local SBSec = BossTab:AddSection({Name = "🔮 Summon / Raid Bosses", TextSize = 18, Glass = true})
local sbToggleMap = {}
for _, b in ipairs(Constants.SummonBosses) do
    local lbl = b.Display .. (b.Island and " ("..b.Island..")" or "")
    local tgl = SBSec:AddToggle({Name = lbl, Default=false, Flag="SB_"..b.Name, Save=true, Callback=function(v)
        if v and getgenv().Config.AutoFarm.Enabled then task.defer(function() pcall(function() sbToggleMap[b.Name]:Set(false) end) end); return end
        if v then
            for k, otgl in pairs(sbToggleMap) do if k~=b.Name then pcall(function() otgl:Set(false) end); getgenv().Config.BossSummonToggles[k] = false end end
            getgenv().Config.BossSummonToggles[b.Name] = true
        else
            getgenv().Config.BossSummonToggles[b.Name] = false
        end
    end})
    sbToggleMap[b.Name] = tgl
    if b.Diffs then SBSec:AddDropdown({Name = b.Display.." Difficulty", Default="Normal", Options=b.Diffs, Flag="SBD_"..b.Name, Save=true, Callback=function(v) getgenv().Config.DiffToggles[b.Name] = v end}) end
end

-- SKILLS
local SkTab = Window:MakeTab({Name = "✨ Skills", Icon = "sparkles"})
local ASkSec = SkTab:AddSection({Name = "💫 Auto Skills", TextSize = 18, Glass = true})
ASkSec:AddToggle({Name="Auto Armament Haki", Default=false, Flag="SkHakiA", Save=true, Callback=function(v) getgenv().Config.AutoFarm.AutoArmament=v end})
ASkSec:AddToggle({Name="Auto Observation Haki", Default=false, Flag="SkHakiO", Save=true, Callback=function(v) getgenv().Config.AutoFarm.AutoObservation=v end})
ASkSec:AddToggle({Name="Use Z", Default=false, Flag="SkZ", Save=true, Callback=function(v) getgenv().Config.AutoSkills.Z=v end})
ASkSec:AddToggle({Name="Use X", Default=false, Flag="SkX", Save=true, Callback=function(v) getgenv().Config.AutoSkills.X=v end})
ASkSec:AddToggle({Name="Use C", Default=false, Flag="SkC", Save=true, Callback=function(v) getgenv().Config.AutoSkills.C=v end})
ASkSec:AddToggle({Name="Use V", Default=false, Flag="SkV", Save=true, Callback=function(v) getgenv().Config.AutoSkills.V=v end})
ASkSec:AddToggle({Name="Use F (Awakening)", Default=false, Flag="SkF", Save=true, Callback=function(v) getgenv().Config.AutoSkills.F=v end})
ASkSec:AddSlider({Name="Skill Delay", Min=0.3, Max=5.0, Default=1.0, Increment=0.1, Flag="SkD", Save=true, Callback=function(v) getgenv().Config.AutoFarm.SkillCooldown=v end})

-- COLLECTIBLES & QUESTS
local ITab = Window:MakeTab({Name = "📦 Items & Quests", Icon = "box"})
local CQSec = ITab:AddSection({Name = "📜 Special Quests", TextSize = 18, Glass = true})
local cqTgl1, cqTgl2
cqTgl1 = CQSec:AddToggle({Name="Auto Hogyoku Fragments (Overrides everything)", Default=false, Flag="Q_Hog", Save=true, Callback=function(v) 
    getgenv().Config.Quests.Hogyoku = v
    if v then if cqTgl2 then pcall(function() cqTgl2:Set(false) end) end; State.HogyokuStep = 0; Util.StopTween() end
end})
-- Auto Dungeon Pieces logic can be added similarly

local ChSec = ITab:AddSection({Name = "🎁 Auto Chests & Merchant", TextSize = 18, Glass = true})
ChSec:AddToggle({Name="Auto Open Chests", Default=false, Flag="OCh", Save=true, Callback=function(v) getgenv().Config.Items.AutoChest=v end})
for _, c in ipairs(Constants.ChestNames) do ChSec:AddToggle({Name=c, Default=true, Flag="Ch_"..c, Save=true, Callback=function(v) getgenv().Config.ItemToggles[c]=v end}) end
ChSec:AddToggle({Name="Auto Merchant", Default=false, Flag="AMerch", Save=true, Callback=function(v) getgenv().Config.Items.AutoBuy=v end})
for _, m in ipairs(Constants.MerchantItems) do ChSec:AddToggle({Name=m, Default=false, Flag="Mer_"..m, Save=true, Callback=function(v) getgenv().Config.MerchantToggles[m]=v end}) end

local CrSec = ITab:AddSection({Name = "⚒️ Auto Craft", TextSize = 18, Glass = true})
CrSec:AddToggle({Name="Auto Craft Slime Key", Default=false, Flag="CrSlime", Save=true, Callback=function(v) getgenv().Config.Items.CraftSlime = v end})
CrSec:AddToggle({Name="Auto Craft Divine Grail", Default=false, Flag="CrGrail", Save=true, Callback=function(v) getgenv().Config.Items.CraftGrail = v end})

-- TELEPORTS
local TPTab = Window:MakeTab({Name = "🗺️ Teleports", Icon = "map-pin"})
local TPSec = TPTab:AddSection({Name = "🏝️ Islands", TextSize = 18, Glass = true})
for _, n in ipairs(Constants.TpIslands) do TPSec:AddButton({Name=n, Callback=function() Util.ForceTP(n); S_Notify("Teleport","Sent to "..n) end}) end

-- ==================================================
-- BACKGROUND EVENT LOOPS
-- ==================================================

task.spawn(function()
    while getgenv().Config.Running do
        task.wait(0.1)
        if Util.WaitChar() then
            local isRaidSelected = false
            for _, enabled in pairs(getgenv().Config.BossSummonToggles) do if enabled then isRaidSelected = true break end end
            
            if getgenv().Config.Quests.Hogyoku then
                pcall(HogyokuTick)
            elseif getgenv().Config.Dungeon.Enabled then
                pcall(DungeonTick)
            elseif getgenv().Config.AutoBossRush then
                pcall(BossRushTick)
            elseif isRaidSelected then
                pcall(SummonBossTick)
            elseif getgenv().Config.Boss.Enabled then
                pcall(BossTick)
            elseif getgenv().Config.AutoFarm.Enabled then
                pcall(FarmTick)
            end
        end
    end
end)

task.spawn(function()
    while getgenv().Config.Running do
        task.wait(1.5)
        pcall(AutoChestTick)
        pcall(AutoMerchantTick)
        pcall(AutoCraftTick)
    end
end)

OrionLib:Init()


