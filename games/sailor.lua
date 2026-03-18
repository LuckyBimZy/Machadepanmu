-- ==========================================
-- || CATRAZ HUB - SAILOR PIECE AUTO FARM
-- ==========================================
repeat task.wait() until game:IsLoaded()

local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

repeat task.wait()
until LocalPlayer
  and LocalPlayer.Character
  and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

-- ==========================================
-- || CONFIGURATION
-- ==========================================
local Config = {
    -- Auto Farm Settings
    AutoFarm = {
        Enabled = false,
        SelectedTarget = "None",
        TargetType = "None", -- "NPC" or "Boss"
    },
    
    -- Farm Settings
    FarmSettings = {
        TpTime = 0.1,
        NPCAttackThreshold = 5,
        AutoEquip = false,
        SelectedWeapon_NPC = "None",
        SelectedWeapon_Boss = "None",
        AutoHaki = false,
        AutoObservationHaki = false,
    },
    
    -- Fly Mode
    FlyHeight = {
        Enabled = true,
        Offset = 5,
    },
    
    -- Auto Skills
    AutoSkill = {
        Bosses = false,
        NPCs = false,
        BossSkills = {},
        NPCSkills = {},
        SkillIds = { Z = 1, X = 2, C = 3, V = 4, F = 5 },
    },
    
    -- Boss Spawner
    Boss = {
        AutoSpawn = false,
        Selected = {},
        Difficulty = "Normal",
    },
    
    -- Special Bosses
    Specials = {
        TrueAizen = { Auto = false, Diff = "Normal" },
        Sukuna    = { Auto = false, Diff = "Normal" },
        Gojo      = { Auto = false, Diff = "Normal" },
        Rimuru    = { Auto = false, Diff = "Normal" },
        Anos      = { Auto = false, Diff = "Normal" },
    },
    
    -- Dungeon Farm
    DungeonFarm = {
        Enabled = false,
        TweenSpeed = 0.1,
        FarmPosition = "Top",
        Distance = 5,
        AutoReplay = false,
        AutoVote = false,
        VoteDiff = "Easy",
    },
    
    -- Auto Quest
    AutoQuest = {
        SelectedNPC = "None",
    },
    
    -- Auto Craft
    AutoCraft = {
        SlimeKey = false,
        DivineGrail = false,
    },
    
    -- Utility
    Utility = {
        AutoRejoin = false,
        TimedRejoin = false,
        RejoinDelay = 10,
        FriendOnly = false,
        WhiteScreen = false,
    },
}

_G.CatrazConfig = Config

-- ==========================================
-- || TARGET LISTS
-- ==========================================
local TargetLists = {
    NPCs = {
        "Hollow",
        "Quincy", 
        "Swordsman",
        "AcademyTeacher",
        "Slime",
        "StrongSorcerer",
        "Curse",
    },
    Bosses = {
        "Gojo",
        "Yuji",
        "Sukuna",
        "Jinwoo",
        "Alucard",
        "Aizen",
        "Yamato",
        "Saber",
        "Ichigo",
        "QinShi",
        "Gilgamesh",
        "BlessedMaiden",
        "SaberAlter",
        "StrongestinHistory",
        "StrongestofToday",
        "Rimuru",
        "Anos",
        "TrueAizen",
    },
    AllTargets = {} -- Akan diisi otomatis
}

-- Gabungkan semua target
for _, v in ipairs(TargetLists.NPCs) do table.insert(TargetLists.AllTargets, v) end
for _, v in ipairs(TargetLists.Bosses) do table.insert(TargetLists.AllTargets, v) end
table.sort(TargetLists.AllTargets)

-- ==========================================
-- || CONSTANTS
-- ==========================================
local CONSTANTS = {
    HakiBlack = BrickColor.new("Really black"),

    Locations = {
        Hollow             = CFrame.new(-365,    0,    1094),
        Quincy             = CFrame.new(-1350, 1604,   1595),
        Swordsman          = CFrame.new(-1271,   1,   -1193),
        AcademyTeacher     = CFrame.new( 1081,   2,    1279),
        Slime              = CFrame.new(-1123,  14,     366),
        StrongSorcerer     = CFrame.new(  664,   2,   -1697),
        Curse              = CFrame.new(  -16,   2,   -1845),
        Gojo               = CFrame.new( 1858.32, 12.98,  338.14),
        Yuji               = CFrame.new( 1537.92,  9.98,  226.10),
        Sukuna             = CFrame.new( 1571.26, 77.22,  -34.11),
        Jinwoo             = CFrame.new(  248.74, 12.09,  927.54),
        Alucard            = CFrame.new(  248.74, 12.09,  927.54),
        Aizen              = CFrame.new( -567.22, -0.42, 1228.49),
        Yamato             = CFrame.new(-1422.68, 24.42,-1383.46),
        Saber              = CFrame.new(  770,   -1,   -1086),
        Ichigo             = CFrame.new(  770,   -1,   -1086),
        QinShi             = CFrame.new(  770,   -1,   -1086),
        Gilgamesh          = CFrame.new(  770,   -1,   -1086),
        BlessedMaiden      = CFrame.new(  770,   -1,   -1086),
        SaberAlter         = CFrame.new(  770,   -1,   -1086),
        StrongestinHistory = CFrame.new(  604,    3,   -2314),
        StrongestofToday   = CFrame.new(  139,    3,   -2432),
        Rimuru             = CFrame.new(-1358,   19,     219),
        Anos               = CFrame.new(  949,    1,    1370),
        TrueAizen          = CFrame.new(-1205, 1604,    1774),
    },

    FarmOrder = {
        { Name = "Hollow",             Remote = "HuecoMundo",  IsBossType = false },
        { Name = "Quincy",             Remote = "SoulSociety", IsBossType = false },
        { Name = "Swordsman",          Remote = "Judgement",   IsBossType = false },
        { Name = "AcademyTeacher",     Remote = "Academy",     IsBossType = false },
        { Name = "Slime",              Remote = "Slime",       IsBossType = false },
        { Name = "StrongSorcerer",     Remote = "Shinjuku",    IsBossType = false },
        { Name = "Curse",              Remote = "Shinjuku",    IsBossType = false },
        { Name = "Gojo",               Remote = "Shibuya",     IsBossType = true  },
        { Name = "Yuji",               Remote = "Shibuya",     IsBossType = true  },
        { Name = "Sukuna",             Remote = "Shibuya",     IsBossType = true  },
        { Name = "Jinwoo",             Remote = "Sailor",      IsBossType = true  },
        { Name = "Alucard",            Remote = "Sailor",      IsBossType = true  },
        { Name = "Aizen",              Remote = "HuecoMundo",  IsBossType = true  },
        { Name = "Yamato",             Remote = "Judgement",   IsBossType = true  },
        { Name = "Saber",              Remote = "Boss",        IsBossType = true  },
        { Name = "Ichigo",             Remote = "Boss",        IsBossType = true  },
        { Name = "QinShi",             Remote = "Boss",        IsBossType = true  },
        { Name = "Gilgamesh",          Remote = "Boss",        IsBossType = true  },
        { Name = "BlessedMaiden",      Remote = "Boss",        IsBossType = true  },
        { Name = "SaberAlter",         Remote = "Boss",        IsBossType = true  },
        { Name = "StrongestinHistory", Remote = "Shinjuku",    IsBossType = true  },
        { Name = "StrongestofToday",   Remote = "Shinjuku",    IsBossType = true  },
        { Name = "Rimuru",             Remote = "Slime",       IsBossType = true  },
        { Name = "Anos",               Remote = "Academy",     IsBossType = true  },
        { Name = "TrueAizen",          Remote = "SoulSociety", IsBossType = true  },
    },

    -- Buat mapping cepat untuk lookup
    TargetInfo = {},
}

-- Inisialisasi TargetInfo untuk lookup cepat
for _, target in ipairs(CONSTANTS.FarmOrder) do
    CONSTANTS.TargetInfo[target.Name] = {
        Remote = target.Remote,
        IsBossType = target.IsBossType
    }
end

-- ==========================================
-- || FLY HEIGHT HELPER
-- ==========================================
local function GetFlyPosition(targetCF, targetPos)
    local cfg = _G.CatrazConfig
    if not cfg.FlyHeight.Enabled then
        return targetCF
    end
    
    local offset = cfg.FlyHeight.Offset or 5
    local pos = targetPos or (targetCF and targetCF.Position)
    
    if not pos then
        return targetCF
    end
    
    local flyPos = Vector3.new(pos.X, pos.Y + offset, pos.Z)
    return CFrame.new(flyPos, pos)
end

-- ==========================================
-- || ENTITY TRACKER
-- ==========================================
local EntityTracker = {}
EntityTracker.__index = EntityTracker

function EntityTracker.new(npcsFolder)
    local self = setmetatable({
        Folder      = npcsFolder,
        Active      = {},
        Connections = {},
        NPCConns    = {},
    }, EntityTracker)
    self:Init()
    return self
end

function EntityTracker:Register(npc)
    task.spawn(function()
        local humanoid = npc:WaitForChild("Humanoid", 3)
        if not humanoid or humanoid.Health <= 0 then return end

        self.Active[npc] = true

        local deathConn, removeConn

        deathConn = humanoid.Died:Connect(function()
            self.Active[npc]   = nil
            self.NPCConns[npc] = nil
            deathConn:Disconnect()
            removeConn:Disconnect()
        end)

        removeConn = npc.AncestryChanged:Connect(function(_, parent)
            if not parent then
                self.Active[npc]   = nil
                self.NPCConns[npc] = nil
                removeConn:Disconnect()
                deathConn:Disconnect()
            end
        end)

        self.NPCConns[npc] = { deathConn, removeConn }
    end)
end

function EntityTracker:Init()
    for _, child in ipairs(self.Folder:GetChildren()) do
        self:Register(child)
    end
    local conn = self.Folder.ChildAdded:Connect(function(child)
        self:Register(child)
    end)
    table.insert(self.Connections, conn)
end

function EntityTracker:Destroy()
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
    self.Connections = {}

    for _, conns in pairs(self.NPCConns) do
        for _, c in ipairs(conns) do
            c:Disconnect()
        end
    end
    self.NPCConns = {}
    self.Active   = {}
end

function EntityTracker:IsAlive(targetName, isBossType)
    for npc in next, self.Active do
        if not (npc and npc.Parent) then
            self.Active[npc]   = nil
            self.NPCConns[npc] = nil
        end
    end

    for npc in next, self.Active do
        if npc.Name:find(targetName) then
            return true
        end
    end

    return false
end

function EntityTracker:GetFirstAlive(targetName)
    for npc in next, self.Active do
        if not (npc and npc.Parent) then
            self.Active[npc]   = nil
            self.NPCConns[npc] = nil
        end
    end

    for npc in next, self.Active do
        if npc.Name:find(targetName) and npc:FindFirstChild("HumanoidRootPart") then
            return npc
        end
    end

    return nil
end

-- ==========================================
-- || FARMER CLASS
-- ==========================================
local Farmer = {}
Farmer.__index = Farmer

function Farmer.new(tracker, tpRemote, abilityRemote, obsHakiRemote, hakiRemote)
    return setmetatable({
        Tracker            = tracker,
        TpRemote           = tpRemote,
        AbilityRemote      = abilityRemote,
        ObsHakiRemote      = obsHakiRemote,
        HakiRemote         = hakiRemote,
        LastSkillTime      = 0,
        LastEquipTime_NPC  = 0,
        LastEquipTime_Boss = 0,
        LastArmamentToggle = 0,
        LastObsToggle      = 0,
        CurrentTarget      = nil,
        _running           = false,
    }, Farmer)
end

function Farmer:Stop()
    self._running = false
    self.CurrentTarget = nil
end

function Farmer:EquipWeapon(isBoss)
    local cfg = _G.CatrazConfig.FarmSettings
    if not cfg.AutoEquip then return end

    local now = tick()
    if isBoss then
        if now - self.LastEquipTime_Boss < 1 then return end
        self.LastEquipTime_Boss = now
    else
        if now - self.LastEquipTime_NPC < 1 then return end
        self.LastEquipTime_NPC = now
    end

    local weaponName = isBoss and cfg.SelectedWeapon_Boss or cfg.SelectedWeapon_NPC

    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChild("Humanoid")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not hum or hum.Health <= 0 or not backpack then return end

    if weaponName == "None" or weaponName == "" then
        local equippedTool = char:FindFirstChildOfClass("Tool")
        if equippedTool then
            if isBoss then cfg.SelectedWeapon_Boss = equippedTool.Name
            else cfg.SelectedWeapon_NPC = equippedTool.Name end
            return
        end

        local firstTool = backpack:FindFirstChildOfClass("Tool")
        if not firstTool then return end
        hum:EquipTool(firstTool)

        if isBoss then cfg.SelectedWeapon_Boss = firstTool.Name
        else cfg.SelectedWeapon_NPC = firstTool.Name end
        return
    end

    if char:FindFirstChild(weaponName) then return end
    local tool = backpack:FindFirstChild(weaponName)
    if tool then hum:EquipTool(tool) end
end

function Farmer:CheckArmamentHaki()
    local cfg = _G.CatrazConfig.FarmSettings
    if not cfg.AutoHaki then return end

    local now = tick()
    if now - self.LastArmamentToggle < 3 then return end

    local char = LocalPlayer.Character
    if not char then return end

    local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    local isHakiActive = rightArm and rightArm.BrickColor == CONSTANTS.HakiBlack

    if not isHakiActive then
        self.LastArmamentToggle = now
        pcall(function() self.HakiRemote:FireServer("Toggle") end)
    end
end

function Farmer:CheckObservationHaki()
    local cfg = _G.CatrazConfig.FarmSettings
    if not cfg.AutoObservationHaki then return end
    if tick() - self.LastObsToggle < 3 then return end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local dodgeUI = playerGui and playerGui:FindFirstChild("DodgeCounterUI")
    local isVisible = dodgeUI
        and dodgeUI:FindFirstChild("MainFrame")
        and dodgeUI.MainFrame.Visible

    local cdUI = playerGui and playerGui:FindFirstChild("CooldownUI")
    local onCooldown = cdUI
        and cdUI:FindFirstChild("MainFrame")
        and cdUI.MainFrame:FindFirstChild("Cooldown_ObsHaki_Observation") ~= nil

    if not isVisible and not onCooldown then
        self.LastObsToggle = tick()
        pcall(function() self.ObsHakiRemote:FireServer("Toggle") end)
    end
end

function Farmer:CastSkills(isBoss)
    local cfg = _G.CatrazConfig.AutoSkill
    local shouldCast = isBoss and cfg.Bosses or (not isBoss and cfg.NPCs)
    if not shouldCast then return end

    if tick() - self.LastSkillTime <= 0.1 then return end
    self.LastSkillTime = tick()

    local activeSkills = isBoss and cfg.BossSkills or cfg.NPCSkills
    for skillName, isEnabled in pairs(activeSkills) do
        if isEnabled then
            local skillId = cfg.SkillIds[skillName]
            if skillId then
                pcall(function() self.AbilityRemote:FireServer(skillId) end)
                task.wait(0.05)
            end
        end
    end
end

function Farmer:FarmTarget(targetName)
    local cfg = _G.CatrazConfig
    local farmCfg = cfg.FarmSettings
    local targetInfo = CONSTANTS.TargetInfo[targetName]
    
    if not targetInfo then
        warn("[CatrazHub] Target not found:", targetName)
        return false
    end
    
    local spawnCF = CONSTANTS.Locations[targetName]
    if not spawnCF then
        warn("[CatrazHub] Location not found for:", targetName)
        return false
    end
    
    local isBoss = targetInfo.IsBossType
    
    -- Teleport ke area target
    if targetInfo.Remote then
        self.TpRemote:FireServer(targetInfo.Remote)
        task.wait(0.2)
    end
    
    -- Loop farming target ini
    local farmStartTime = tick()
    while self._running and cfg.AutoFarm.Enabled and cfg.AutoFarm.SelectedTarget == targetName do
        cfg = _G.CatrazConfig
        farmCfg = cfg.FarmSettings
        
        self:CheckObservationHaki()
        self:CheckArmamentHaki()
        self:EquipWeapon(isBoss)
        self:CastSkills(isBoss)
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then task.wait(1) break end
        
        -- Cari target hidup
        local liveTarget = self.Tracker:GetFirstAlive(targetName)
        local targetPos = liveTarget and liveTarget.HumanoidRootPart.Position or spawnCF.Position
        local targetCF = liveTarget and liveTarget.HumanoidRootPart.CFrame or spawnCF
        
        -- Hitung jarak
        local distance = (hrp.Position - targetPos).Magnitude
        
        -- Terbang mode
        if distance > 20 then
            if distance > 150 and targetInfo.Remote then
                self.TpRemote:FireServer(targetInfo.Remote)
                task.wait(0.5)
            end
            local flyPos = GetFlyPosition(targetCF, targetPos)
            hrp.CFrame = flyPos
        else
            local flyPos = GetFlyPosition(targetCF, targetPos)
            hrp.CFrame = CFrame.lookAt(flyPos.Position, targetPos)
        end
        
        task.wait(farmCfg.TpTime)
        
        -- Cek timeout (5 menit) untuk mencegah loop tak terbatas
        if tick() - farmStartTime > 300 then
            warn("[CatrazHub] Farming timeout for:", targetName)
            break
        end
    end
    
    return true
end

function Farmer:Start()
    if self._running then return end
    self._running = true
    
    task.spawn(function()
        while self._running and task.wait(0.1) do
            local cfg = _G.CatrazConfig
            
            if not cfg.AutoFarm.Enabled then
                task.wait(1)
                continue
            end
            
            if game.PlaceId ~= 77747658251236 then
                task.wait(5)
                continue
            end
            
            local targetName = cfg.AutoFarm.SelectedTarget
            if targetName == "None" or targetName == "" then
                task.wait(1)
                continue
            end
            
            -- Farm target yang dipilih
            self:FarmTarget(targetName)
            
            -- Jeda sebelum mulai lagi
            task.wait(1)
        end
    end)
end

-- ==========================================
-- || BOSS SPAWNER
-- ==========================================
local BossSpawner = {}
BossSpawner.__index = BossSpawner

function BossSpawner.new(tracker, remotes)
    return setmetatable({
        Tracker  = tracker,
        Remotes  = remotes,
        _running = false,
    }, BossSpawner)
end

function BossSpawner:Stop()
    self._running = false
end

function BossSpawner:Start()
    if self._running then return end
    self._running = true

    task.spawn(function()
        while self._running and task.wait(0.5) do
            local cfg = _G.CatrazConfig

            if cfg.Boss.AutoSpawn then
                local selected = cfg.Boss.Selected
                if type(selected) == "table" then
                    for bName, enabled in pairs(selected) do
                        if enabled == true and not self.Tracker:IsAlive(bName, true) then
                            self.Remotes.SummonBoss:FireServer(bName .. "Boss", cfg.Boss.Difficulty)
                            task.wait(0.3)
                        end
                    end
                end
            end

            local specs = cfg.Specials
            if specs.TrueAizen.Auto and not self.Tracker:IsAlive("TrueAizen", true) then
                self.Remotes.TrueAizen:FireServer(specs.TrueAizen.Diff)
            end
            if specs.Sukuna.Auto and not self.Tracker:IsAlive("StrongestinHistory", true) then
                self.Remotes.SpawnStrongest:FireServer("StrongestHistory", specs.Sukuna.Diff)
            end
            if specs.Gojo.Auto and not self.Tracker:IsAlive("StrongestofToday", true) then
                self.Remotes.SpawnStrongest:FireServer("StrongestToday", specs.Gojo.Diff)
            end
            if specs.Rimuru.Auto and not self.Tracker:IsAlive("Rimuru", true) then
                self.Remotes.Rimuru:FireServer(specs.Rimuru.Diff)
            end
            if specs.Anos.Auto and not self.Tracker:IsAlive("Anos", true) then
                self.Remotes.Anos:FireServer("Anos", specs.Anos.Diff)
            end
        end
    end)
end

-- ==========================================
-- || DUNGEON FARMER
-- ==========================================
local DungeonFarmer = {}
DungeonFarmer.__index = DungeonFarmer

function DungeonFarmer.new()
    return setmetatable({ _running = false }, DungeonFarmer)
end

function DungeonFarmer:Stop()
    self._running = false
end

function DungeonFarmer:_stabilize(hrp, goalCF)
    local bv = hrp:FindFirstChild("DungeonStabilizer_BV")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "DungeonStabilizer_BV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = hrp
    end
    bv.Velocity = Vector3.new(0, 0, 0)
    
    local bg = hrp:FindFirstChild("DungeonStabilizer_BG")
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = "DungeonStabilizer_BG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 3000
        bg.D = 500
        bg.Parent = hrp
    end
    bg.CFrame = goalCF
end

function DungeonFarmer:_destabilize(hrp)
    local bv = hrp:FindFirstChild("DungeonStabilizer_BV")
    if bv then bv:Destroy() end
    local bg = hrp:FindFirstChild("DungeonStabilizer_BG")
    if bg then bg:Destroy() end
end

function DungeonFarmer:_getGoal(npcHRP)
    local cfg = _G.CatrazConfig
    local pos = npcHRP.Position
    
    if cfg.FlyHeight.Enabled then
        local offset = cfg.FlyHeight.Offset or 5
        return CFrame.new(pos + Vector3.new(0, offset, 0), pos)
    else
        local dist = cfg.DungeonFarm.Distance or 5
        if cfg.DungeonFarm.FarmPosition == "Top" then
            return CFrame.new(pos + Vector3.new(0, dist, 0), pos)
        else
            return npcHRP.CFrame * CFrame.new(0, 2, dist)
        end
    end
end

function DungeonFarmer:Start()
    if self._running then return end
    self._running = true

    task.spawn(function()
        while self._running do
            task.wait(0.05)
            local cfg = _G.CatrazConfig
            if not cfg.DungeonFarm.Enabled then task.wait(0.5) continue end

            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui and playerGui:FindFirstChild("DungeonUI") then
                local dungeonUI = playerGui.DungeonUI
                
                if cfg.DungeonFarm.AutoReplay then
                    local replayFrame = dungeonUI:FindFirstChild("ReplayDungeonFrameVisibleOnlyWhenClearingDungeon")
                    if replayFrame and replayFrame.Visible then
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveReplayVote"):FireServer("sponsor")
                        end)
                        task.wait(1)
                    end
                end
                
                if cfg.DungeonFarm.AutoVote then
                    local contentFrame = dungeonUI:FindFirstChild("ContentFrame")
                    if contentFrame then
                        local actions = contentFrame:FindFirstChild("Actions")
                        if actions then
                            local diffFrame = actions:FindFirstChild(cfg.DungeonFarm.VoteDiff .. "DifficultyFrame")
                            if diffFrame and diffFrame.Visible then
                                pcall(function()
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonWaveVote"):FireServer(cfg.DungeonFarm.VoteDiff)
                                end)
                                task.wait(1)
                            end
                        end
                    end
                end
            end

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(1) continue end

            local npcsFolder = workspace:FindFirstChild("NPCs")
            if not npcsFolder then task.wait(1) continue end

            local targets = npcsFolder:GetChildren()
            if #targets == 0 then task.wait(0.5) continue end

            for _, model in ipairs(targets) do
                if not self._running or not cfg.DungeonFarm.Enabled then break end

                local hum = model:FindFirstChildOfClass("Humanoid")
                local npcHRP = model:FindFirstChild("HumanoidRootPart")
                if not hum or not npcHRP then continue end
                if hum.Health <= 0 then continue end

                local isBoss = model.Name:find("Boss") ~= nil
                local speed = cfg.DungeonFarm.TweenSpeed

                if isBoss then
                    while self._running and cfg.DungeonFarm.Enabled do
                        cfg = _G.CatrazConfig
                        speed = cfg.DungeonFarm.TweenSpeed

                        if _G.CatrazHub_Farmer then
                            _G.CatrazHub_Farmer:CheckObservationHaki()
                            _G.CatrazHub_Farmer:CheckArmamentHaki()
                            _G.CatrazHub_Farmer:EquipWeapon(true)
                            _G.CatrazHub_Farmer:CastSkills(true)
                        end

                        local curChar = LocalPlayer.Character
                        local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                        if not curHrp then task.wait(1) break end

                        local liveHum = model:FindFirstChildOfClass("Humanoid")
                        if not model.Parent or not liveHum or liveHum.Health <= 0 then break end

                        local liveHRP = model:FindFirstChild("HumanoidRootPart")
                        if not liveHRP then break end

                        local goal = self:_getGoal(liveHRP)
                        self:_stabilize(curHrp, goal)
                        curHrp.CFrame = goal
                        task.wait(speed)
                    end
                else
                    local curChar = LocalPlayer.Character
                    local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                    if not curHrp then continue end
                    
                    if _G.CatrazHub_Farmer then
                        _G.CatrazHub_Farmer:CheckObservationHaki()
                        _G.CatrazHub_Farmer:CheckArmamentHaki()
                        _G.CatrazHub_Farmer:EquipWeapon(false)
                        _G.CatrazHub_Farmer:CastSkills(false)
                    end
                    
                    local goal = self:_getGoal(npcHRP)
                    self:_stabilize(curHrp, goal)
                    curHrp.CFrame = goal
                    task.wait(speed)
                end
                
                local curChar = LocalPlayer.Character
                local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                if curHrp then self:_destabilize(curHrp) end
            end
        end
    end)
end

-- ==========================================
-- || UTILITY FUNCTIONS
-- ==========================================
local Utility = {}
local _utilityConnections = {}

function Utility.EnableAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    local conn = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    table.insert(_utilityConnections, conn)
end

function Utility.EnableAutoRejoin()
    local TeleportService = game:GetService("TeleportService")
    local GuiService = game:GetService("GuiService")

    local conn = GuiService.ErrorMessageChanged:Connect(function()
        local cfg = _G.CatrazConfig.Utility
        if not cfg.AutoRejoin then return end

        local lastError = GuiService:GetErrorMessage()
        if lastError:find("CatrazHub Security") then
            warn("Auto-Rejoin blocked: Security Kick.")
            return
        end

        task.spawn(function()
            while task.wait(5) do
                if pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) then
                    break
                end
                task.wait(10)
            end
        end)
    end)

    table.insert(_utilityConnections, conn)
end

local _timedRejoinRunning = false

function Utility.EnableTimedRejoin()
    _timedRejoinRunning = false
    task.wait()
    _timedRejoinRunning = true

    local TeleportService = game:GetService("TeleportService")

    task.spawn(function()
        local elapsed = 0
        while _timedRejoinRunning and task.wait(1) do
            local cfg = _G.CatrazConfig.Utility

            if not cfg.TimedRejoin then
                elapsed = 0
                continue
            end

            elapsed += 1
            local target = (cfg.RejoinDelay or 10) * 60
            if elapsed > target then elapsed = target end

            if elapsed >= target then
                elapsed = 0
                Notify("Rejoining now (" .. (cfg.RejoinDelay or 10) .. " min timer)...")
                task.wait(5)

                for _ = 1, 10 do
                    if pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) then
                        break
                    end
                    task.wait(10)
                end
            end
        end
    end)
end

function Utility.EnableFriendCheck()
    local function checkAndKick(player)
        local cfg = _G.CatrazConfig.Utility
        if not cfg.FriendOnly or player == LocalPlayer then return end

        local isFriend = false
        local ok, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
        if ok then isFriend = result end

        if not isFriend then
            LocalPlayer:Kick(
                "\n[CatrazHub Security]\nStranger Detected: " .. player.Name
                .. "\nAuto-Rejoin disabled to prevent looping."
            )
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        checkAndKick(player)
    end

    local conn = Players.PlayerAdded:Connect(checkAndKick)
    table.insert(_utilityConnections, conn)
end

function Utility.SetupCharacterEvents(hakiRemote, obsHakiRemote)
    local function onCharacterAdded(char)
        char:WaitForChild("HumanoidRootPart", 5)
        task.wait(1)
        local cfg = _G.CatrazConfig.FarmSettings

        if cfg.AutoHaki then
            pcall(function() hakiRemote:FireServer("Toggle") end)
        end

        if cfg.AutoObservationHaki then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local cdUI = playerGui:FindFirstChild("CooldownUI")
                local hasCD = cdUI
                    and cdUI:FindFirstChild("MainFrame")
                    and cdUI.MainFrame:FindFirstChild("Cooldown_ObsHaki_Observation") ~= nil

                local dodgeUI = playerGui:FindFirstChild("DodgeCounterUI")
                local isVisible = dodgeUI
                    and dodgeUI:FindFirstChild("MainFrame")
                    and dodgeUI.MainFrame.Visible

                if not hasCD and not isVisible then
                    pcall(function() obsHakiRemote:FireServer("Toggle") end)
                end
            end
        end
    end

    local conn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(_utilityConnections, conn)

    if LocalPlayer.Character then
        task.spawn(onCharacterAdded, LocalPlayer.Character)
    end
end

function Utility.Cleanup()
    _timedRejoinRunning = false

    for _, conn in ipairs(_utilityConnections) do
        conn:Disconnect()
    end
    _utilityConnections = {}
end

function Utility.GetWeapons()
    local weapons = { "None" }
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then
                table.insert(weapons, v.Name)
            end
        end
    end
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            table.insert(weapons, v.Name)
        end
    end
    -- Hapus duplikat
    local seen = {}
    local unique = {}
    for _, item in ipairs(weapons) do
        if not seen[item] then
            seen[item] = true
            table.insert(unique, item)
        end
    end
    return unique
end

-- ==========================================
-- || NOTIFICATION
-- ==========================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "CatrazHub",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

-- ==========================================
-- || CLEANUP PREVIOUS INSTANCES
-- ==========================================
if _G.CatrazHub_Spawner then _G.CatrazHub_Spawner:Stop() end
if _G.CatrazHub_Farmer then _G.CatrazHub_Farmer:Stop() end
if _G.CatrazHub_DungeonFarmer then _G.CatrazHub_DungeonFarmer:Stop() end
if _G.CatrazHub_Tracker then _G.CatrazHub_Tracker:Destroy() end
Utility.Cleanup()

if _G.CatrazHub_Window then
    pcall(function() _G.CatrazHub_Window:Destroy() end)
    _G.CatrazHub_Window = nil
end

-- ==========================================
-- || REMOTE SETUP
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AbilityRemote = ReplicatedStorage
    :WaitForChild("AbilitySystem")
    :WaitForChild("Remotes")
    :WaitForChild("RequestAbility")

local GameRemotes = {
    Teleport = Remotes:WaitForChild("TeleportToPortal"),
    SummonBoss = Remotes:WaitForChild("RequestSummonBoss"),
    SpawnStrongest = Remotes:WaitForChild("RequestSpawnStrongestBoss"),
    Anos = Remotes:WaitForChild("RequestSpawnAnosBoss"),
    TrueAizen = RemoteEvents:WaitForChild("RequestSpawnTrueAizen"),
    Rimuru = RemoteEvents:WaitForChild("RequestSpawnRimuru"),
    Haki = RemoteEvents:WaitForChild("HakiRemote"),
    ObservationHaki = RemoteEvents:WaitForChild("ObservationHakiRemote"),
}

local Tracker = EntityTracker.new(workspace:WaitForChild("NPCs"))
local Spawner = BossSpawner.new(Tracker, GameRemotes)
local AutoFarm = Farmer.new(
    Tracker,
    GameRemotes.Teleport,
    AbilityRemote,
    GameRemotes.ObservationHaki,
    GameRemotes.Haki
)
local DungeonFarm = DungeonFarmer.new()

_G.CatrazHub_Tracker = Tracker
_G.CatrazHub_Spawner = Spawner
_G.CatrazHub_Farmer = AutoFarm
_G.CatrazHub_DungeonFarmer = DungeonFarm

Utility.EnableAntiAFK()
Utility.EnableAutoRejoin()
Utility.EnableTimedRejoin()
Utility.EnableFriendCheck()
Utility.SetupCharacterEvents(GameRemotes.Haki, GameRemotes.ObservationHaki)

print("CatrazHub AutoFarm Initialized Successfully.")

-- ==========================================
-- || CREATE MAIN WINDOW
-- ==========================================
local Window = OrionLib:MakeWindow({
    Name = "CatrazHub",
    Subtext = "| Sailor Piece",
    Version = "v3.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CatrazHub",
    IntroEnabled = true,
    IntroText = "CatrazHub AutoFarm",
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
_G.CatrazHub_Window = Window
Notify("CatrazHub AutoFarm Loaded Successfully!")

-- ==========================================
-- || CREATE TABS
-- ==========================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

local BossTab = Window:MakeTab({
    Name = "Boss Spawner",
    Icon = "skull",
    Glass = true,
    Outline = true
})

local DungeonTab = Window:MakeTab({
    Name = "Dungeon",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local CraftingTab = Window:MakeTab({
    Name = "Crafting",
    Icon = "hammer",
    Glass = true,
    Outline = true
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "gift",
    Glass = true,
    Outline = true
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    Glass = true,
    Outline = true
})

-- ==========================================
-- || MAIN TAB - AUTO FARM DENGAN DROPDOWN
-- ==========================================
local FarmSection = MainTab:AddSection({
    Name = "🎯 AUTO FARM TARGET",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Dropdown untuk memilih target
FarmSection:AddDropdown({
    Name = "Pilih Target",
    Default = Config.AutoFarm.SelectedTarget,
    Options = TargetLists.AllTargets,
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_TargetSelect",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm.SelectedTarget = Value
        -- Deteksi tipe target
        for _, npc in ipairs(TargetLists.NPCs) do
            if npc == Value then
                Config.AutoFarm.TargetType = "NPC"
                break
            end
        end
        for _, boss in ipairs(TargetLists.Bosses) do
            if boss == Value then
                Config.AutoFarm.TargetType = "Boss"
                break
            end
        end
    end
})

-- Toggle Auto Farm
FarmSection:AddToggle({
    Name = "Auto Farm ON/OFF",
    Default = Config.AutoFarm.Enabled,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoFarm",
    Save = true,
    Callback = function(Value)
        if Value and Config.AutoFarm.SelectedTarget == "None" then
            Notify("Pilih target terlebih dahulu!")
            Config.AutoFarm.Enabled = false
            return false
        end
        Config.AutoFarm.Enabled = Value
        if Value then
            Notify("Auto Farm Started - Target: " .. Config.AutoFarm.SelectedTarget)
        else
            Notify("Auto Farm Stopped")
        end
    end
})

-- Info target
FarmSection:AddParagraph({
    Title = "Target Info",
    Desc = "Target: " .. Config.AutoFarm.SelectedTarget .. "\nType: " .. Config.AutoFarm.TargetType,
    Image = "info",
    ImageSize = 38
})

-- Separator
FarmSection:AddParagraph({
    Title = "",
    Desc = "══════════════════════════",
    Image = "",
    ImageSize = 0
})

-- ==========================================
-- || MAIN TAB - FARM SETTINGS
-- ==========================================
local FarmSettingsSection = MainTab:AddSection({
    Name = "⚙️ FARM SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmSettingsSection:AddSlider({
    Name = "Teleport Delay",
    Min = 0,
    Max = 1,
    Default = Config.FarmSettings.TpTime,
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Flag = "Slider_TpTime",
    Save = true,
    Callback = function(Value) Config.FarmSettings.TpTime = Value end
})

FarmSettingsSection:AddSlider({
    Name = "NPC Threshold",
    Min = 1,
    Max = 10,
    Default = Config.FarmSettings.NPCAttackThreshold,
    Increment = 1,
    ValueName = "count",
    Outline = true,
    Flag = "Slider_NPCThreshold",
    Save = true,
    Callback = function(Value) Config.FarmSettings.NPCAttackThreshold = Value end
})

-- ==========================================
-- || MAIN TAB - WEAPON SELECTION
-- ==========================================
local WeaponSection = MainTab:AddSection({
    Name = "🔧 WEAPON SELECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local weaponsList = Utility.GetWeapons()

WeaponSection:AddToggle({
    Name = "Auto Equip Weapon",
    Default = Config.FarmSettings.AutoEquip,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoEquip",
    Save = true,
    Callback = function(Value) Config.FarmSettings.AutoEquip = Value end
})

WeaponSection:AddDropdown({
    Name = "Weapon untuk NPC",
    Default = Config.FarmSettings.SelectedWeapon_NPC,
    Options = weaponsList,
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_WeaponNPC",
    Save = true,
    Callback = function(Value) Config.FarmSettings.SelectedWeapon_NPC = Value end
})

WeaponSection:AddDropdown({
    Name = "Weapon untuk Boss",
    Default = Config.FarmSettings.SelectedWeapon_Boss,
    Options = weaponsList,
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_WeaponBoss",
    Save = true,
    Callback = function(Value) Config.FarmSettings.SelectedWeapon_Boss = Value end
})

WeaponSection:AddButton({
    Name = "Refresh Weapon List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local weapons = Utility.GetWeapons()
        Notify("Weapon list refreshed")
    end
})

-- ==========================================
-- || MAIN TAB - HAKI SETTINGS
-- ==========================================
local HakiSection = MainTab:AddSection({
    Name = "👊 HAKI SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HakiSection:AddToggle({
    Name = "Auto Armament Haki",
    Default = Config.FarmSettings.AutoHaki,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoHaki",
    Save = true,
    Callback = function(Value) Config.FarmSettings.AutoHaki = Value end
})

HakiSection:AddToggle({
    Name = "Auto Observation Haki",
    Default = Config.FarmSettings.AutoObservationHaki,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoObsHaki",
    Save = true,
    Callback = function(Value) Config.FarmSettings.AutoObservationHaki = Value end
})

-- ==========================================
-- || MAIN TAB - SKILL SETTINGS
-- ==========================================
local SkillSection = MainTab:AddSection({
    Name = "⚡ SKILL SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SkillSection:AddToggle({
    Name = "Use Skills on Bosses",
    Default = Config.AutoSkill.Bosses,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoSkillBoss",
    Save = true,
    Callback = function(Value) Config.AutoSkill.Bosses = Value end
})

SkillSection:AddDropdown({
    Name = "Boss Skills",
    Default = Config.AutoSkill.BossSkills,
    Options = { "Z", "X", "C", "V", "F" },
    Multi = true,
    Search = false,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_BossSkills",
    Save = true,
    Callback = function(Value) Config.AutoSkill.BossSkills = Value end
})

SkillSection:AddToggle({
    Name = "Use Skills on NPCs",
    Default = Config.AutoSkill.NPCs,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoSkillNPC",
    Save = true,
    Callback = function(Value) Config.AutoSkill.NPCs = Value end
})

SkillSection:AddDropdown({
    Name = "NPC Skills",
    Default = Config.AutoSkill.NPCSkills,
    Options = { "Z", "X", "C", "V", "F" },
    Multi = true,
    Search = false,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_NPCSkills",
    Save = true,
    Callback = function(Value) Config.AutoSkill.NPCSkills = Value end
})

-- ==========================================
-- || BOSS TAB
-- ==========================================
local BossSection1 = BossTab:AddSection({
    Name = "🤖 STANDARD BOSS SPAWNER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossSection1:AddToggle({
    Name = "Auto-Spawn Bosses",
    Default = Config.Boss.AutoSpawn,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoSpawn",
    Save = true,
    Callback = function(Value) Config.Boss.AutoSpawn = Value end
})

BossSection1:AddDropdown({
    Name = "Pilih Boss (Multi)",
    Default = Config.Boss.Selected,
    Options = { "Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden", "SaberAlter" },
    Multi = true,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_SelectedBoss",
    Save = true,
    Callback = function(Value) Config.Boss.Selected = Value end
})

BossSection1:AddDropdown({
    Name = "Difficulty",
    Default = Config.Boss.Difficulty,
    Options = { "Normal", "Medium", "Hard", "Extreme" },
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Flag = "Dropdown_BossDifficulty",
    Save = true,
    Callback = function(Value) Config.Boss.Difficulty = Value end
})

local BossSection2 = BossTab:AddSection({
    Name = "⭐ SPECIAL BOSS SPAWNERS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local difficultyLevels = { "Normal", "Medium", "Hard", "Extreme" }

for bossName, bossData in pairs(Config.Specials) do
    BossSection2:AddToggle({
        Name = "Auto Spawn " .. bossName,
        Default = bossData.Auto,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Special_" .. bossName,
        Save = true,
        Callback = function(Value) Config.Specials[bossName].Auto = Value end
    })

    BossSection2:AddDropdown({
        Name = bossName .. " Difficulty",
        Default = bossData.Diff,
        Options = difficultyLevels,
        Multi = false,
        Search = false,
        AllowNone = false,
        Outline = true,
        Flag = "SpecialDiff_" .. bossName,
        Save = true,
        Callback = function(Value) Config.Specials[bossName].Diff = Value end
    })
end

-- ==========================================
-- || DUNGEON TAB
-- ==========================================
local DungeonSection1 = DungeonTab:AddSection({
    Name = "🏰 DUNGEON AUTO FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonSection1:AddToggle({
    Name = "Enable Dungeon Farm",
    Default = Config.DungeonFarm.Enabled,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_DungeonFarm",
    Save = true,
    Callback = function(Value) Config.DungeonFarm.Enabled = Value end
})

DungeonSection1:AddSlider({
    Name = "TP Delay",
    Min = 0.05,
    Max = 2,
    Default = Config.DungeonFarm.TweenSpeed,
    Increment = 0.05,
    ValueName = "sec",
    Outline = true,
    Flag = "Slider_DungeonTweenSpeed",
    Save = true,
    Callback = function(Value) Config.DungeonFarm.TweenSpeed = Value end
})

DungeonSection1:AddDropdown({
    Name = "Farm Position",
    Default = Config.DungeonFarm.FarmPosition,
    Options = { "Top", "Behind" },
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Flag = "Dropdown_DungeonPosition",
    Save = true,
    Callback = function(Value) Config.DungeonFarm.FarmPosition = Value end
})

DungeonSection1:AddSlider({
    Name = "Farm Distance",
    Min = 0,
    Max = 20,
    Default = Config.DungeonFarm.Distance,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "Slider_DungeonDistance",
    Save = true,
    Callback = function(Value) Config.DungeonFarm.Distance = Value end
})

local DungeonSection2 = DungeonTab:AddSection({
    Name = "🔄 AUTO RUN",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonSection2:AddToggle({
    Name = "Auto Replay",
    Default = Config.DungeonFarm.AutoReplay,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_DungeonAutoReplay",
    Save = true,
    Callback = function(Value) Config.DungeonFarm.AutoReplay = Value end
})

DungeonSection2:AddToggle({
    Name = "Auto Vote",
    Default = Config.DungeonFarm.AutoVote,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_DungeonAutoVote",
    Save = true,
    Callback = function(Value) Config.DungeonFarm.AutoVote = Value end
})

DungeonSection2:AddDropdown({
    Name = "Vote Difficulty",
    Default = Config.DungeonFarm.VoteDiff,
    Options = { "Easy", "Medium", "Hard", "Extreme" },
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Flag = "Dropdown_DungeonVoteDiff",
    Save = true,
    Callback = function(Value) Config.DungeonFarm.VoteDiff = Value end
})

-- ==========================================
-- || CRAFTING TAB (SEDERHANA)
-- ==========================================
local CraftSection = CraftingTab:AddSection({
    Name = "🔨 AUTO CRAFT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

CraftSection:AddToggle({
    Name = "Auto Craft SlimeKey",
    Default = Config.AutoCraft.SlimeKey,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoCraftSlimeKey",
    Save = true,
    Callback = function(Value) Config.AutoCraft.SlimeKey = Value end
})

CraftSection:AddToggle({
    Name = "Auto Craft Divine Grail",
    Default = Config.AutoCraft.DivineGrail,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoCraftDivineGrail",
    Save = true,
    Callback = function(Value) Config.AutoCraft.DivineGrail = Value end
})

-- ==========================================
-- || MISC TAB
-- ==========================================
local MiscSection1 = MiscTab:AddSection({
    Name = "🎁 CODE REDEEMER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscSection1:AddButton({
    Name = "Redeem Active Codes",
    Icon = "gift",
    Outline = true,
    Callback = RedeemCodes
})

-- ==========================================
-- || SETTINGS TAB
-- ==========================================
local UtilSection = SettingsTab:AddSection({
    Name = "🛠️ UTILITY SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

UtilSection:AddToggle({
    Name = "WhiteScreen Mode",
    Default = Config.Utility.WhiteScreen,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_WhiteScreen",
    Save = true,
    Callback = function(Value)
        Config.Utility.WhiteScreen = Value
        game:GetService("RunService"):Set3dRenderingEnabled(not Value)
        if Value then Notify("WhiteScreen Mode Active.") end
    end
})

UtilSection:AddToggle({
    Name = "Auto Rejoin",
    Default = Config.Utility.AutoRejoin,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoRejoin",
    Save = true,
    Callback = function(Value) Config.Utility.AutoRejoin = Value end
})

UtilSection:AddToggle({
    Name = "Friend-Only Mode",
    Default = Config.Utility.FriendOnly,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_FriendOnly",
    Save = true,
    Callback = function(Value) Config.Utility.FriendOnly = Value end
})

UtilSection:AddToggle({
    Name = "Timed Rejoin",
    Default = Config.Utility.TimedRejoin,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_TimedRejoin",
    Save = true,
    Callback = function(Value) Config.Utility.TimedRejoin = Value end
})

UtilSection:AddSlider({
    Name = "Rejoin Interval (minutes)",
    Min = 1,
    Max = 120,
    Default = Config.Utility.RejoinDelay,
    Increment = 1,
    ValueName = "min",
    Outline = true,
    Flag = "Slider_RejoinDelay",
    Save = true,
    Callback = function(Value) Config.Utility.RejoinDelay = Value end
})

-- ==========================================
-- || FLY MODE SETTINGS
-- ==========================================
local FlySection = SettingsTab:AddSection({
    Name = "🚀 FLY MODE SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FlySection:AddToggle({
    Name = "Enable Fly Mode",
    Default = Config.FlyHeight.Enabled,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_FlyMode",
    Save = true,
    Callback = function(Value) Config.FlyHeight.Enabled = Value end
})

FlySection:AddSlider({
    Name = "Fly Height Offset",
    Min = 1,
    Max = 20,
    Default = Config.FlyHeight.Offset,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "Slider_FlyOffset",
    Save = true,
    Callback = function(Value) Config.FlyHeight.Offset = Value end
})

-- ==========================================
-- || CONFIG TAB
-- ==========================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

-- ==========================================
-- || INITIALIZE
-- ==========================================
OrionLib:Init()

-- Start services
Spawner:Start()
AutoFarm:Start()
DungeonFarm:Start()

Notify("CatrazHub Ready! Pilih target di Main Tab lalu nyalakan Auto Farm.")