-- ==========================================
-- || INITIALIZATION
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
-- || CONFIGURATION (Linked to _G)
-- ==========================================
local Config = {
	LoopFarm              = false,
	AutoRejoin            = false,
	TimedRejoin           = false,
	RejoinDelay           = 10,
	FriendOnly            = false,
	WhiteScreen           = false,
	TpTime                = 0.1,
	NPCAttackThreshold    = 5,
	AutoEquip             = false,
	SelectedWeapon_NPC    = "None",
	SelectedWeapon_Boss   = "None",
	AutoHaki              = false,
	AutoObservationHaki   = false,
	IgnoredEntities = {
		Hollow             = true,
		Quincy             = true,
		Swordsman          = true,
		AcademyTeacher     = true,
		Slime              = true,
		StrongSorcerer     = true,
		Curse              = true,
		Gojo               = true,
		Yuji               = true,
		Sukuna             = true,
		Jinwoo             = true,
		Alucard            = true,
		Aizen              = true,
		Yamato             = true,
		Saber              = true,
		Ichigo             = true,
		QinShi             = true,
		Gilgamesh          = true,
		BlessedMaiden      = true,
		SaberAlter         = true,
		StrongestinHistory = true,
		StrongestofToday   = true,
		Rimuru             = true,
		Anos               = true,
		TrueAizen          = true,
	},
	Boss = {
		AutoSpawn  = false,
		Selected   = {}, -- Multi-select sebagai table
		Difficulty = "Normal",
	},
	Specials = {
		TrueAizen = { Auto = false, Diff = "Normal" },
		Sukuna    = { Auto = false, Diff = "Normal" },
		Gojo      = { Auto = false, Diff = "Normal" },
		Rimuru    = { Auto = false, Diff = "Normal" },
		Anos      = { Auto = false, Diff = "Normal" },
	},
	AutoSkill = {
		Bosses     = false,
		NPCs       = false,
		BossSkills = {},
		NPCSkills  = {},
		SkillIds   = { Z = 1, X = 2, C = 3, V = 4, F = 5 },
	},
	AutoQuest = {
		SelectedNPC = "None",
	},
	AutoCraft = {
		SlimeKey = false,
		DivineGrail = false,
	},
	DungeonFarm = {
		Enabled      = false,
		TweenSpeed   = 0.1,
		FarmPosition = "Top",
		Distance     = 5,
		AutoReplay   = false,
		AutoVote     = false,
		VoteDiff     = "Easy",
	},
}

_G.FarmConfig = Config

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
		{ Name = "Swordsman",          Remote = "Judgement",   IsBossType = false },
		{ Name = "Quincy",             Remote = "SoulSociety", IsBossType = false },
		{ Name = "AcademyTeacher",     Remote = "Academy",     IsBossType = false },
		{ Name = "Slime",              Remote = "Slime",       IsBossType = false },
		{ Name = "StrongSorcerer",     Remote = "Shinjuku",    IsBossType = false },
		{ Name = "Hollow",             Remote = "HuecoMundo",  IsBossType = false },
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

	CraftingSets = {
		StrongestinHistory = {
			Items = {
				{"Malevolent Soul", 3},
				{"Awakened Cursed Finger", 20},
				{"Cursed Flesh", 1},
				{"Vessel Ring", 7}
			},
			SkillUnlock = {
				{"Shrine Domain Shard", 1},
				{"Malevolent Soul", 3}
			}
		},

		TrueAizen = {
			Items = {
				{"Evolution Fragment", 1},
				{"Transcendent Core", 3},
				{"Divinity Essence", 8},
				{"Fusion Ring", 15},
				{"Chrysalis Sigil", 75}
			},
			SkillUnlock = {
				{"Transmutation Shard", 5}
			}
		},

		StrongestofToday = {
			Items = {
				{"Reversal Pulse", 9},
				{"Blue Singularity", 3},
				{"Infinity Essence", 1},
				{"Six Eye", 6}
			},
			SkillUnlock = {
				{"Blue Singularity", 3},
				{"Infinity Domain Shard", 1}
			}
		},

		BlessedMaiden = {
			Items = {
				{"Celestial Mark", 1},
				{"Aero Core", 3},
				{"Gale Essence", 8},
				{"Tide Remnant", 14},
				{"Tempest Relic", 25}
			},
			SkillUnlock = {
				{"Celestial Mark", 2},
				{"Aero Core", 8},
				{"Tempest Relic", 75}
			}
		},

		Aizen = {
			Items = {
				{"Hōgyoku Fragment", 1},
				{"Reiatsu Core", 3},
				{"Illusion Prism", 6},
				{"Mirage Pendant", 10}
			}
		},

		SaberAlter = {
			Items = {
				{"Corrupt Crown", 1},
				{"Corruption Core", 3},
				{"Alter Essence", 8},
				{"Morgan Remnant", 15},
				{"Dark Grail", 25}
			},
			SkillUnlock = {
				{"Corrupt Crown", 2},
				{"Corruption Core", 9},
				{"Dark Grail", 85}
			}
		},

		Anos = {
			Items = {
				{"Calamity Seal", 65},
				{"Demonic Fragment", 12},
				{"Demonic Shard", 6},
				{"Destruction Eye", 2},
				{"Imperial Mark", 1}
			}
		},

		Yamato = {
			Items = {
				{"Azure Heart", 1},
				{"Silent Storm", 3},
				{"Yamato Essence", 7},
				{"Frozen Will", 14}
			}
		},

		Gilgamesh = {
			Items = {
				{"Throne Remnant", 12},
				{"Ancient Shard", 6},
				{"Golden Essence", 3},
				{"Phantasm Core", 1}
			}
		},

		ShadowMonarch = {
			Items = {
				{"Monarch Core", 10},
				{"Monarch Essence", 5},
				{"Kamish Dagger", 2},
				{"Shadow Crystal", 1}
			}
		},

		Gryphon = {
			Items = {}
		}
	}
}

-- ==========================================
-- || CLASS: Entity Tracker
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

function EntityTracker:IsAlive(queryName, isBossType, requiredCount)
	requiredCount = requiredCount or 5
	local currentCount = 0

	for npc in next, self.Active do
		if not (npc and npc.Parent) then
			self.Active[npc]   = nil
			self.NPCConns[npc] = nil
		end
	end

	for npc in next, self.Active do
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

-- ==========================================
-- || CLASS: Boss Spawner
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
			local cfg = _G.FarmConfig

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
-- || CLASS: Farmer
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
		_running           = false,
	}, Farmer)
end

function Farmer:Stop()
	self._running = false
end

function Farmer:EquipWeapon(isBoss)
	local cfg = _G.FarmConfig
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

	local hum     = char:FindFirstChild("Humanoid")
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not hum or hum.Health <= 0 or not backpack then return end

	if weaponName == "None" or weaponName == "" then
		local equippedTool = char:FindFirstChildOfClass("Tool")
		if equippedTool then
			if isBoss then cfg.SelectedWeapon_Boss = equippedTool.Name
			else            cfg.SelectedWeapon_NPC  = equippedTool.Name end
			return
		end

		local firstTool = backpack:FindFirstChildOfClass("Tool")
		if not firstTool then return end
		hum:EquipTool(firstTool)

		if isBoss then cfg.SelectedWeapon_Boss = firstTool.Name
		else            cfg.SelectedWeapon_NPC  = firstTool.Name end
		return
	end

	if char:FindFirstChild(weaponName) then return end
	local tool = backpack:FindFirstChild(weaponName)
	if tool then hum:EquipTool(tool) end
end

function Farmer:CheckArmamentHaki()
	local cfg = _G.FarmConfig
	if not cfg.AutoHaki then return end

	local now = tick()
	if now - self.LastArmamentToggle < 3 then return end

	local char = LocalPlayer.Character
	if not char then return end

	local rightArm     = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
	local isHakiActive = rightArm and rightArm.BrickColor == CONSTANTS.HakiBlack

	if not isHakiActive then
		self.LastArmamentToggle = now
		pcall(function() self.HakiRemote:FireServer("Toggle") end)
	end
end

function Farmer:CheckObservationHaki()
	local cfg = _G.FarmConfig
	if not cfg.AutoObservationHaki then return end
	if tick() - self.LastObsToggle < 3 then return end

	local playerGui  = LocalPlayer:FindFirstChild("PlayerGui")
	local dodgeUI    = playerGui and playerGui:FindFirstChild("DodgeCounterUI")
	local isVisible  = dodgeUI
		and dodgeUI:FindFirstChild("MainFrame")
		and dodgeUI.MainFrame.Visible

	local cdUI       = playerGui and playerGui:FindFirstChild("CooldownUI")
	local onCooldown = cdUI
		and cdUI:FindFirstChild("MainFrame")
		and cdUI.MainFrame:FindFirstChild("Cooldown_ObsHaki_Observation") ~= nil

	if not isVisible and not onCooldown then
		self.LastObsToggle = tick()
		pcall(function() self.ObsHakiRemote:FireServer("Toggle") end)
	end
end

function Farmer:CastSkills(isBoss)
	local cfg = _G.FarmConfig
	local shouldCast = isBoss and cfg.AutoSkill.Bosses or (not isBoss and cfg.AutoSkill.NPCs)
	if not shouldCast then return end

	if tick() - self.LastSkillTime <= 0.3 then return end
	self.LastSkillTime = tick()

	local activeSkills = isBoss and cfg.AutoSkill.BossSkills or cfg.AutoSkill.NPCSkills
	for skillName, isEnabled in pairs(activeSkills) do
		if isEnabled then
			local skillId = cfg.AutoSkill.SkillIds[skillName]
			if skillId then
				pcall(function() self.AbilityRemote:FireServer(skillId) end)
			end
		end
	end
end

function Farmer:Start()
	if self._running then return end
	self._running = true

	task.spawn(function()
		while self._running and task.wait(0.1) do
			local cfg = _G.FarmConfig
			if not cfg.LoopFarm then continue end
			if game.PlaceId ~= 77747658251236 then continue end

			self:CheckObservationHaki()
			self:CheckArmamentHaki()
			self:EquipWeapon(false)

			local char = LocalPlayer.Character
			local hrp  = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end

			for _, target in ipairs(CONSTANTS.FarmOrder) do
				if not self._running or not cfg.LoopFarm then break end
				if cfg.IgnoredEntities[target.Name] then continue end

				local requiredToStart = target.IsBossType and 1 or cfg.NPCAttackThreshold
				if not self.Tracker:IsAlive(target.Name, target.IsBossType, requiredToStart) then
					continue
				end

				local spawnCF = CONSTANTS.Locations[target.Name]
				if not spawnCF then continue end

				if target.IsBossType then
					if target.Remote then
						self.TpRemote:FireServer(target.Remote)
						task.wait(0.2)
					end

					while
						self._running
						and cfg.LoopFarm
						and not cfg.IgnoredEntities[target.Name]
						and self.Tracker:IsAlive(target.Name, true)
					do
						cfg = _G.FarmConfig

						self:CheckObservationHaki()
						self:CheckArmamentHaki()
						self:EquipWeapon(true)
						self:CastSkills(true)

						local curChar = LocalPlayer.Character
						local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
						if not curHrp then task.wait(1) continue end

						local liveBoss = nil
						for npc in next, self.Tracker.Active do
							if npc.Name:find("^" .. target.Name) and npc:FindFirstChild("HumanoidRootPart") then
								liveBoss = npc.HumanoidRootPart
								break
							end
						end

						local targetGoal = liveBoss and liveBoss.CFrame or spawnCF
						local lookAtPos  = targetGoal.Position
						local distance   = (curHrp.Position - lookAtPos).Magnitude

						if distance > 20 then
							if distance > 150 and target.Remote then
								self.TpRemote:FireServer(target.Remote)
								task.wait(0.5)
							end
							curHrp.CFrame = CFrame.lookAt(
								targetGoal.Position + Vector3.new(0, 0, 3),
								lookAtPos
							)
						else
							curHrp.CFrame = CFrame.lookAt(curHrp.Position, lookAtPos)
						end

						task.wait(cfg.TpTime)
					end

				else
					if target.Remote then
						self.TpRemote:FireServer(target.Remote)
						task.wait(0.2)
					end

					while
						self._running
						and cfg.LoopFarm
						and not cfg.IgnoredEntities[target.Name]
						and self.Tracker:IsAlive(target.Name, false, 1)
					do
						cfg = _G.FarmConfig

						local curChar = LocalPlayer.Character
						local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
						if not curHrp then task.wait(1) continue end

						self:CheckObservationHaki()
						self:CheckArmamentHaki()
						self:EquipWeapon(false)
						self:CastSkills(false)

						local distance = (curHrp.Position - spawnCF.Position).Magnitude
						if distance > 10 then
							curHrp.CFrame = spawnCF
						end

						task.wait(cfg.TpTime)
					end
				end
			end
		end
	end)
end

-- ==========================================
-- || CLASS: Dungeon Farmer
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

function DungeonFarmer:_getGoal(npcHRP, position)
	local pos = npcHRP.Position
	local cf  = npcHRP.CFrame
	local dist = _G.FarmConfig.DungeonFarm.Distance or 5
	
	if position == "Top" then
		return CFrame.new(pos + Vector3.new(0, dist, 0), pos)
	else -- Behind
		return cf * CFrame.new(0, 2, dist)
	end
end

function DungeonFarmer:Start()
	if self._running then return end
	self._running = true

	task.spawn(function()
		while self._running do
			task.wait(0.05)
			local cfg = _G.FarmConfig
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
			local hrp  = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then task.wait(1) continue end

			local npcsFolder = workspace:FindFirstChild("NPCs")
			if not npcsFolder then task.wait(1) continue end

			local targets = npcsFolder:GetChildren()
			if #targets == 0 then task.wait(0.5) continue end

			for _, model in ipairs(targets) do
				if not self._running or not cfg.DungeonFarm.Enabled then break end

				local hum    = model:FindFirstChildOfClass("Humanoid")
				local npcHRP = model:FindFirstChild("HumanoidRootPart")
				if not hum or not npcHRP then continue end
				if hum.Health <= 0 then continue end

				local isBoss = model.Name:find("Boss") ~= nil
				local speed  = cfg.DungeonFarm.TweenSpeed
				local pos    = cfg.DungeonFarm.FarmPosition

				if isBoss then
					while self._running and cfg.DungeonFarm.Enabled do
						cfg = _G.FarmConfig
						speed = cfg.DungeonFarm.TweenSpeed
						pos   = cfg.DungeonFarm.FarmPosition

						if _G.ArcX_Farmer then
							_G.ArcX_Farmer:CheckObservationHaki()
							_G.ArcX_Farmer:CheckArmamentHaki()
							_G.ArcX_Farmer:EquipWeapon(true)
							_G.ArcX_Farmer:CastSkills(true)
						end

						local curChar = LocalPlayer.Character
						local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
						if not curHrp then task.wait(1) break end

						local liveHum = model:FindFirstChildOfClass("Humanoid")
						if not model.Parent or not liveHum or liveHum.Health <= 0 then break end

						local liveHRP = model:FindFirstChild("HumanoidRootPart")
						if not liveHRP then break end

						local goal = self:_getGoal(liveHRP, pos)
						self:_stabilize(curHrp, goal)
						curHrp.CFrame = goal
						task.wait(speed)
					end
				else
					local curChar = LocalPlayer.Character
					local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
					if not curHrp then continue end
					
					if _G.ArcX_Farmer then
						_G.ArcX_Farmer:CheckObservationHaki()
						_G.ArcX_Farmer:CheckArmamentHaki()
						_G.ArcX_Farmer:EquipWeapon(false)
						_G.ArcX_Farmer:CastSkills(false)
					end
					
					local goal = self:_getGoal(npcHRP, pos)
					
					self:_stabilize(curHrp, goal)
					curHrp.CFrame = goal
					task.wait(speed)
				end
				
				local curChar = LocalPlayer.Character
				local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
				if curHrp then self:_destabilize(curHrp) end
			end
		end
	end)
end

-- ==========================================
-- || CLASS: Utility / Character Manager
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
	local GuiService      = game:GetService("GuiService")

	local conn = GuiService.ErrorMessageChanged:Connect(function()
		local cfg = _G.FarmConfig
		if not cfg.AutoRejoin then return end

		local lastError = GuiService:GetErrorMessage()
		if lastError:find("ArcX Security") then
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
			local cfg = _G.FarmConfig

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
		if not _G.FarmConfig.FriendOnly or player == LocalPlayer then return end

		local isFriend = false
		local ok, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
		if ok then isFriend = result end

		if not isFriend then
			LocalPlayer:Kick(
				"\n[ArcX Security]\nStranger Detected: " .. player.Name
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
		local cfg = _G.FarmConfig

		if cfg.AutoHaki then
			pcall(function() hakiRemote:FireServer("Toggle") end)
		end

		if cfg.AutoObservationHaki then
			local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
			if playerGui then
				local cdUI    = playerGui:FindFirstChild("CooldownUI")
				local hasCD   = cdUI
					and cdUI:FindFirstChild("MainFrame")
					and cdUI.MainFrame:FindFirstChild("Cooldown_ObsHaki_Observation") ~= nil

				local dodgeUI   = playerGui:FindFirstChild("DodgeCounterUI")
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
	local weapons = {}
	local char = LocalPlayer.Character
	if char then
		for _, v in ipairs(char:GetChildren()) do
			if v:IsA("Tool") then table.insert(weapons, v.Name) end
		end
	end
	for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then table.insert(weapons, v.Name) end
	end
	return #weapons > 0 and weapons or { "None" }
end

-- ==========================================
-- || CODE REDEEMER
-- ==========================================
local _codeRedeemDone = false

local function RedeemCodes()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local ok, CodesConfig = pcall(function()
		return require(ReplicatedStorage:WaitForChild("CodesConfig", 5))
	end)

	if not ok or not CodesConfig then
		warn("[ArcX] Code Redeemer: CodesConfig module not found.")
		return
	end

	local CodeRedeem = ReplicatedStorage
		:WaitForChild("RemoteEvents", 5)
		:FindFirstChild("CodeRedeem")

	if not CodeRedeem then
		warn("[ArcX] Code Redeemer: CodeRedeem remote not found.")
		return
	end

	print("[ArcX] Starting code auto-redeem...")

	for codeName, _ in pairs(CodesConfig.Codes) do
		if CodesConfig.IsValid(codeName) then
			print("[ArcX] Redeeming: " .. codeName)

			local success, serverResponse = pcall(function()
				return CodeRedeem:InvokeServer(codeName)
			end)

			if success then
				print("[ArcX] Response for " .. codeName .. ":", serverResponse)
			else
				warn("[ArcX] Error redeeming " .. codeName .. ":", serverResponse)
			end

			task.wait(0.5)
		end
	end

	print("[ArcX] Code auto-redeem finished.")
end

-- ==========================================
-- || QUEST MANAGER
-- ==========================================
local QuestManager = {}
QuestManager.__index = QuestManager

function QuestManager.new()
	return setmetatable({ _remote = nil }, QuestManager)
end

function QuestManager.GetQuestNPCs()
	local found = {}
	local serviceNPCs = workspace:FindFirstChild("ServiceNPCs")
	if not serviceNPCs then return { "None" } end

	for _, child in ipairs(serviceNPCs:GetChildren()) do
		if child.Name:match("^QuestNPC") then
			table.insert(found, child.Name)
		end
	end

	table.sort(found, function(a, b)
		local na = tonumber(a:match("%d+$")) or 0
		local nb = tonumber(b:match("%d+$")) or 0
		return na < nb
	end)

	return #found > 0 and found or { "None" }
end

function QuestManager:AcceptOnce(npcName)
	if not npcName or npcName == "None" or npcName == "" then
		warn("[ArcX] AcceptOnce: No Quest NPC selected.")
		return false
	end

	if not self._remote then
		local re = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
		self._remote = re and re:FindFirstChild("QuestAccept")
	end

	if not self._remote then
		warn("[ArcX] QuestAccept remote not found.")
		return false
	end

	local ok, err = pcall(function()
		self._remote:FireServer(npcName)
	end)

	if ok then
		print("[ArcX] Quest accepted from " .. npcName)
		return true
	else
		warn("[ArcX] Quest accept failed:", err)
		return false
	end
end

-- ==========================================
-- || NOTIFICATION FUNCTION
-- ==========================================
local function Notify(msg)
	OrionLib:MakeNotification({
		Name = "ArcX",
		Content = msg,
		Image = "info",
		Time = 2.5
	})
end

-- ==========================================
-- || CLEANUP PREVIOUS INSTANCES
-- ==========================================
if _G.ArcX_Spawner       then _G.ArcX_Spawner:Stop()             end
if _G.ArcX_Farmer        then _G.ArcX_Farmer:Stop()              end
if _G.ArcX_DungeonFarmer then _G.ArcX_DungeonFarmer:Stop()       end
if _G.ArcX_Tracker       then _G.ArcX_Tracker:Destroy()          end
Utility.Cleanup()

if _G.ArcX_Window then
	pcall(function() _G.ArcX_Window:Destroy() end)
	_G.ArcX_Window = nil
end

-- ==========================================
-- || REMOTE SETUP
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents      = ReplicatedStorage:WaitForChild("RemoteEvents")
local AbilityRemote     = ReplicatedStorage
	:WaitForChild("AbilitySystem")
	:WaitForChild("Remotes")
	:WaitForChild("RequestAbility")

local GameRemotes = {
	Teleport        = Remotes:WaitForChild("TeleportToPortal"),
	SummonBoss      = Remotes:WaitForChild("RequestSummonBoss"),
	SpawnStrongest  = Remotes:WaitForChild("RequestSpawnStrongestBoss"),
	Anos            = Remotes:WaitForChild("RequestSpawnAnosBoss"),
	TrueAizen       = RemoteEvents:WaitForChild("RequestSpawnTrueAizen"),
	Rimuru          = RemoteEvents:WaitForChild("RequestSpawnRimuru"),
	Haki            = RemoteEvents:WaitForChild("HakiRemote"),
	ObservationHaki = RemoteEvents:WaitForChild("ObservationHakiRemote"),
}

local Tracker   = EntityTracker.new(workspace:WaitForChild("NPCs"))
local Spawner   = BossSpawner.new(Tracker, GameRemotes)
local AutoFarm  = Farmer.new(
	Tracker,
	GameRemotes.Teleport,
	AbilityRemote,
	GameRemotes.ObservationHaki,
	GameRemotes.Haki
)
local AutoQuest     = QuestManager.new()
local DungeonFarm   = DungeonFarmer.new()

_G.ArcX_Tracker       = Tracker
_G.ArcX_Spawner       = Spawner
_G.ArcX_Farmer        = AutoFarm
_G.ArcX_DungeonFarmer = DungeonFarm

Utility.EnableAntiAFK()
Utility.EnableAutoRejoin()
Utility.EnableTimedRejoin()
Utility.EnableFriendCheck()
Utility.SetupCharacterEvents(GameRemotes.Haki, GameRemotes.ObservationHaki)

print("ArcX AutoFarm Initialized Successfully.")

-- ==========================================
-- || CREATE MAIN WINDOW (CATRAZ HUB)
-- ==========================================
local Window = OrionLib:MakeWindow({
    Name = "ArcX",
    Subtext = "| Developer",
    Version = "v1.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ArcX",
    IntroEnabled = true,
    IntroText = "ArcX AutoFarm",
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

_G.ArcX_Window = Window

Notify("ArcX AutoFarm Loaded Successfully!")

-- ==========================================
-- || CREATE TABS
-- ==========================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

local MobsTab = Window:MakeTab({
    Name = "Entities",
    Icon = "ghost",
    Glass = true,
    Outline = true
})

local BossesTab = Window:MakeTab({
    Name = "Standard Bosses",
    Icon = "skull",
    Glass = true,
    Outline = true
})

local SpecialsTab = Window:MakeTab({
    Name = "Special Bosses",
    Icon = "star",
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
-- || MAIN TAB
-- ==========================================
local MainSection1 = MainTab:AddSection({
    Name = "Auto Farm Settings",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MainSection1:AddToggle({
    Name = "Enable Auto Farm",
    Default = Config.LoopFarm,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_LoopFarm",
    Save = true,
    Callback = function(Value)
        if Value and game.PlaceId ~= 77747658251236 then
            Notify("Main Auto Farm is only available in Sailor Piece Main Game!")
            Config.LoopFarm = false
            return false
        end
        Config.LoopFarm = Value
    end
})

MainSection1:AddSlider({
    Name = "Teleport Delay",
    Min = 0,
    Max = 1,
    Default = Config.TpTime,
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Flag = "Slider_TpTime",
    Save = true,
    Callback = function(Value) Config.TpTime = Value end
})

MainSection1:AddToggle({
    Name = "Auto Armament Haki",
    Default = Config.AutoHaki,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoHaki",
    Save = true,
    Callback = function(Value) Config.AutoHaki = Value end
})

MainSection1:AddToggle({
    Name = "Auto Observation Haki",
    Default = Config.AutoObservationHaki,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoObsHaki",
    Save = true,
    Callback = function(Value) Config.AutoObservationHaki = Value end
})

local MainSection2 = MainTab:AddSection({
    Name = "Inventory Management",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MainSection2:AddToggle({
    Name = "Auto Equip Weapon",
    Default = Config.AutoEquip,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoEquip",
    Save = true,
    Callback = function(Value) Config.AutoEquip = Value end
})

-- Weapon dropdowns
local weaponsList = Utility.GetWeapons()

MainSection2:AddDropdown({
    Name = "Weapon for NPCs",
    Default = Config.SelectedWeapon_NPC,
    Options = weaponsList,
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_WeaponNPC",
    Save = true,
    Callback = function(Value) Config.SelectedWeapon_NPC = Value end
})

MainSection2:AddDropdown({
    Name = "Weapon for Bosses",
    Default = Config.SelectedWeapon_Boss,
    Options = weaponsList,
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_WeaponBoss",
    Save = true,
    Callback = function(Value) Config.SelectedWeapon_Boss = Value end
})

MainSection2:AddButton({
    Name = "Refresh Weapon Lists",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local weapons = Utility.GetWeapons()
        -- Note: In Catraz Hub, you'd need to properly refresh dropdowns
        Notify("Weapon list refreshed")
    end
})

local MainSection3 = MainTab:AddSection({
    Name = "Auto Skills",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MainSection3:AddToggle({
    Name = "Use Skills on Bosses",
    Default = Config.AutoSkill.Bosses,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoSkillBoss",
    Save = true,
    Callback = function(Value) Config.AutoSkill.Bosses = Value end
})

MainSection3:AddDropdown({
    Name = "Boss Skills Selection",
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

MainSection3:AddToggle({
    Name = "Use Skills on NPCs",
    Default = Config.AutoSkill.NPCs,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoSkillNPC",
    Save = true,
    Callback = function(Value) Config.AutoSkill.NPCs = Value end
})

MainSection3:AddDropdown({
    Name = "NPC Skills Selection",
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
-- || MOBS / ENTITIES TAB
-- ==========================================
local MobsSection1 = MobsTab:AddSection({
    Name = "NPC Settings",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MobsSection1:AddSlider({
    Name = "Wait for NPCs",
    Min = 1,
    Max = 5,
    Default = Config.NPCAttackThreshold,
    Increment = 1,
    ValueName = "count",
    Outline = true,
    Flag = "Slider_NPCThreshold",
    Save = true,
    Callback = function(Value) Config.NPCAttackThreshold = Value end
})

MobsSection1:AddParagraph({
    Title = "Info",
    Desc = "Script will only attack when this many NPCs are gathered.",
    Image = "info",
    ImageSize = 38
})

local MobsSection2 = MobsTab:AddSection({
    Name = "Entity Targeting",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- NPCs
MobsSection2:AddParagraph({
    Title = "NPCs",
    Desc = "Enable entities to farm",
    Image = "users",
    ImageSize = 38
})

local npcList = { "Hollow", "Quincy", "Swordsman", "AcademyTeacher", "Slime", "StrongSorcerer", "Curse" }
for _, entityName in ipairs(npcList) do
    MobsSection2:AddToggle({
        Name = "Farm " .. entityName,
        Default = not Config.IgnoredEntities[entityName],
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Mob_" .. entityName,
        Save = true,
        Callback = function(Value) Config.IgnoredEntities[entityName] = not Value end
    })
end

local MobsSection3 = MobsTab:AddSection({
    Name = "Timed Bosses",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local timedBossList = { "Gojo", "Yuji", "Sukuna", "Jinwoo", "Alucard", "Aizen", "Yamato" }
for _, entityName in ipairs(timedBossList) do
    MobsSection3:AddToggle({
        Name = "Farm " .. entityName,
        Default = not Config.IgnoredEntities[entityName],
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Mob_" .. entityName,
        Save = true,
        Callback = function(Value) Config.IgnoredEntities[entityName] = not Value end
    })
end

local MobsSection4 = MobsTab:AddSection({
    Name = "Summon Bosses",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local summonBossList = { "Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden", "SaberAlter", "StrongestinHistory", "StrongestofToday", "Rimuru", "Anos", "TrueAizen" }
for _, entityName in ipairs(summonBossList) do
    MobsSection4:AddToggle({
        Name = "Farm " .. entityName,
        Default = not Config.IgnoredEntities[entityName],
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Mob_" .. entityName,
        Save = true,
        Callback = function(Value) Config.IgnoredEntities[entityName] = not Value end
    })
end

-- ==========================================
-- || BOSSES TAB
-- ==========================================
local BossesSection1 = BossesTab:AddSection({
    Name = "Standard Boss Spawner",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossesSection1:AddParagraph({
    Title = "Info",
    Desc = "Select one or more bosses. Each selected boss will be spawned independently when not alive.",
    Image = "info",
    ImageSize = 38
})

BossesSection1:AddToggle({
    Name = "Auto-Spawn Bosses",
    Default = Config.Boss.AutoSpawn,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoSpawn",
    Save = true,
    Callback = function(Value) Config.Boss.AutoSpawn = Value end
})

BossesSection1:AddDropdown({
    Name = "Select Bosses (Multi)",
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

BossesSection1:AddDropdown({
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

-- ==========================================
-- || SPECIALS TAB
-- ==========================================
local SpecialsSection = SpecialsTab:AddSection({
    Name = "Special Boss Spawners",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SpecialsSection:AddParagraph({
    Title = "Info",
    Desc = "Configure auto-spawning for special bosses.",
    Image = "info",
    ImageSize = 38
})

local difficultyLevels = { "Normal", "Medium", "Hard", "Extreme" }

for bossName, bossData in pairs(Config.Specials) do
    SpecialsSection:AddToggle({
        Name = "Auto Spawn " .. bossName,
        Default = bossData.Auto,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Special_" .. bossName,
        Save = true,
        Callback = function(Value) Config.Specials[bossName].Auto = Value end
    })

    SpecialsSection:AddDropdown({
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
    Name = "Dungeon Auto Farm",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonSection1:AddParagraph({
    Title = "Info",
    Desc = "Loops through workspace.NPCs. Bosses are attacked until dead; regular NPCs are hit once and skipped.",
    Image = "info",
    ImageSize = 38
})

DungeonSection1:AddToggle({
    Name = "Enable Dungeon Auto Farm",
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
    Name = "Auto Run",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonSection2:AddToggle({
    Name = "Auto Replay Dungeon",
    Default = Config.DungeonFarm.AutoReplay,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_DungeonAutoReplay",
    Save = true,
    Callback = function(Value) Config.DungeonFarm.AutoReplay = Value end
})

DungeonSection2:AddToggle({
    Name = "Auto Vote Dungeon",
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
-- || CRAFTING TAB FUNCTIONS
-- ==========================================
local function GetItemQuantity(itemName)
	local player = game:GetService("Players").LocalPlayer
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return 0 end
	
	local inventoryUI = playerGui:FindFirstChild("InventoryPanelUI")
	if not inventoryUI then return 0 end
	
	local storage = inventoryUI:FindFirstChild("MainFrame")
		and inventoryUI.MainFrame:FindFirstChild("Frame")
		and inventoryUI.MainFrame.Frame:FindFirstChild("Content")
		and inventoryUI.MainFrame.Frame.Content:FindFirstChild("Holder")
		and inventoryUI.MainFrame.Frame.Content.Holder:FindFirstChild("StorageHolder")
		and inventoryUI.MainFrame.Frame.Content.Holder.StorageHolder:FindFirstChild("Storage")
		
	if not storage then return 0 end

	local itemFrame = storage:FindFirstChild("Item_" .. itemName)
	if not itemFrame then return 0 end

	local quantityText = itemFrame:FindFirstChild("Slot")
		and itemFrame.Slot:FindFirstChild("Holder")
		and itemFrame.Slot.Holder:FindFirstChild("Quantity")
		
	if quantityText and (quantityText:IsA("TextLabel") or quantityText:IsA("TextBox")) then
		local text = quantityText.Text
		local num = text:match("x(%d+)") or text:match("%d+")
		return tonumber(num) or 0
	end
	return 0
end

local function CheckSetAmount(setName)
	local setInfo = CONSTANTS.CraftingSets[setName]
	if not setInfo then return 0, 0, 0 end

	local normalReqs = {}
	local skillReqs = {}
	local combinedReqs = {}
	
	if setInfo.Items then
		for _, req in ipairs(setInfo.Items) do
			local itemName = req[1]
			local requiredAmt = req[2]
			normalReqs[itemName] = (normalReqs[itemName] or 0) + requiredAmt
			combinedReqs[itemName] = (combinedReqs[itemName] or 0) + requiredAmt
		end
	end
	
	if setInfo.SkillUnlock then
		if type(setInfo.SkillUnlock[1]) == "table" then
			for _, req in ipairs(setInfo.SkillUnlock) do
				local itemName = req[1]
				local requiredAmt = req[2]
				skillReqs[itemName] = (skillReqs[itemName] or 0) + requiredAmt
				combinedReqs[itemName] = (combinedReqs[itemName] or 0) + requiredAmt
			end
		else
			local itemName = setInfo.SkillUnlock[1]
			local requiredAmt = setInfo.SkillUnlock[2]
			skillReqs[itemName] = (skillReqs[itemName] or 0) + requiredAmt
			combinedReqs[itemName] = (combinedReqs[itemName] or 0) + requiredAmt
		end
	end

	local function calcMaxSets(reqsDict)
		local maxSets = math.huge
		local hasReqs = false
		for itemName, requiredAmt in pairs(reqsDict) do
			hasReqs = true
			local hasAmt = GetItemQuantity(itemName)
			local canMake = math.floor(hasAmt / requiredAmt)
			if canMake < maxSets then
				maxSets = canMake
			end
		end
		return hasReqs and (maxSets == math.huge and 0 or maxSets) or 0
	end

	local normalSets = calcMaxSets(normalReqs)
	local skillSets = calcMaxSets(skillReqs)
	local combinedSets = calcMaxSets(combinedReqs)

	return normalSets, skillSets, combinedSets
end

-- ==========================================
-- || CRAFTING TAB
-- ==========================================
local CraftingSection1 = CraftingTab:AddSection({
    Name = "Crafting Calculator",
    TextSize = 18,
    Glass = true,
    Outline = true
})

CraftingSection1:AddParagraph({
    Title = "Warning",
    Desc = "⚠️ You must open inventory in items tabs only. And make every materials visible.",
    Image = "alert-triangle",
    ImageSize = 38
})

local craftingSetKeys = {}
for k, _ in pairs(CONSTANTS.CraftingSets) do table.insert(craftingSetKeys, k) end

local selectedSet = "StrongestinHistory"

CraftingSection1:AddDropdown({
    Name = "Select Set",
    Default = selectedSet,
    Options = craftingSetKeys,
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Flag = "Dropdown_CraftingSet",
    Save = true,
    Callback = function(Value) selectedSet = Value end
})

local setAmountParagraph = CraftingSection1:AddParagraph({
    Title = "Craftable Amount",
    Desc = "Can create: 0 sets\n(Select a set and check amount)",
    Image = "package",
    ImageSize = 38
})

CraftingSection1:AddButton({
    Name = "Check Amount",
    Icon = "search",
    Outline = true,
    Callback = function()
		local setInfo = CONSTANTS.CraftingSets[selectedSet]
		if not setInfo then return end

		local normalSets, skillSets, combinedSets = CheckSetAmount(selectedSet)
		local details = ""
		
		if setInfo.SkillUnlock then
			details = "Can create:\n- Normal Sets: " .. normalSets .. "\n- SkillUnlock Sets: " .. skillSets .. "\n- Combined Sets: " .. combinedSets .. "\n"
		else
			details = "Can create:\n- Normal Sets: " .. normalSets .. "\n"
		end
		
		if setInfo.Items then
			details = details .. "\nNormal Items:"
			for _, req in ipairs(setInfo.Items) do
				local itemName = req[1]
				local requiredAmt = req[2]
				local hasAmt = GetItemQuantity(itemName)
				details = details .. "\n- " .. itemName .. ": " .. hasAmt .. " / " .. requiredAmt
			end
		end

		if setInfo.SkillUnlock then
			details = details .. "\n\nSkill Unlock:"
			
			if type(setInfo.SkillUnlock[1]) == "table" then
				for _, unlockReq in ipairs(setInfo.SkillUnlock) do
					local unlockItem = unlockReq[1]
					local unlockReqAmt = unlockReq[2]
					local unlockHasAmt = GetItemQuantity(unlockItem)
					local status = unlockHasAmt >= unlockReqAmt and "✅" or "❌"
					details = details .. "\n- " .. unlockItem .. ": " .. unlockHasAmt .. " / " .. unlockReqAmt .. " " .. status
				end
			else
				local unlockItem = setInfo.SkillUnlock[1]
				local unlockReqAmt = setInfo.SkillUnlock[2]
				local unlockHasAmt = GetItemQuantity(unlockItem)
				local status = unlockHasAmt >= unlockReqAmt and "✅ (Unlocked)" or "❌ (Locked)"
				details = details .. "\n- " .. unlockItem .. ": " .. unlockHasAmt .. " / " .. unlockReqAmt .. " " .. status
			end
		end
		
		if setAmountParagraph.SetDesc then
			setAmountParagraph:SetDesc(details)
		end
		
		local notifyText = "Normal: " .. normalSets
		if setInfo.SkillUnlock then
			notifyText = notifyText .. " | Combined: " .. combinedSets
		end

		Notify(notifyText)
	end
})

local CraftingSection2 = CraftingTab:AddSection({
    Name = "Craft Items",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local craftAmount = 1

CraftingSection2:AddTextbox({
    Name = "Amount to Craft",
    Default = "1",
    Numeric = true,
    Outline = true,
    Flag = "Input_CraftAmount",
    Save = true,
    Callback = function(Value)
		local num = tonumber(Value)
		if num and num > 0 then
			craftAmount = num
		else
			craftAmount = 1
		end
	end
})

CraftingSection2:AddButton({
    Name = "Craft SlimeKey",
    Icon = "hammer",
    Outline = true,
    Callback = function()
		task.spawn(function()
			local args = { "SlimeKey", craftAmount }
			local ok, err = pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSlimeCraft"):InvokeServer(unpack(args))
			end)
			if ok then
				Notify("Requested " .. craftAmount .. "x SlimeKey.")
			else
				warn("[ArcX] SlimeKey Craft Error:", err)
			end
		end)
	end
})

CraftingSection2:AddButton({
    Name = "Craft Divine Grail",
    Icon = "hammer",
    Outline = true,
    Callback = function()
		task.spawn(function()
			local args = { "DivineGrail", craftAmount }
			local ok, err = pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestGrailCraft"):InvokeServer(unpack(args))
			end)
			if ok then
				Notify("Requested " .. craftAmount .. "x Divine Grail.")
			else
				warn("[ArcX] Divine Grail Craft Error:", err)
			end
		end)
	end
})

local CraftingSection3 = CraftingTab:AddSection({
    Name = "Auto Crafting",
    TextSize = 18,
    Glass = true,
    Outline = true
})

CraftingSection3:AddToggle({
    Name = "Auto Craft SlimeKey",
    Default = Config.AutoCraft.SlimeKey,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoCraftSlimeKey",
    Save = true,
    Callback = function(Value) Config.AutoCraft.SlimeKey = Value end
})

CraftingSection3:AddToggle({
    Name = "Auto Craft Divine Grail",
    Default = Config.AutoCraft.DivineGrail,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoCraftDivineGrail",
    Save = true,
    Callback = function(Value) Config.AutoCraft.DivineGrail = Value end
})

-- Auto Craft loop
task.spawn(function()
	while task.wait(5) do
		if Config.AutoCraft.SlimeKey then
			pcall(function()
				local args = { "SlimeKey", 1 }
				game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestSlimeCraft"):InvokeServer(unpack(args))
			end)
		end
		if Config.AutoCraft.DivineGrail then
			pcall(function()
				local args = { "DivineGrail", 1 }
				game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestGrailCraft"):InvokeServer(unpack(args))
			end)
		end
	end
end)

-- ==========================================
-- || MISC TAB
-- ==========================================
local MiscSection1 = MiscTab:AddSection({
    Name = "Code Redeemer",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscSection1:AddButton({
    Name = "Redeem Active Codes",
    Icon = "gift",
    Outline = true,
    Callback = function()
		task.spawn(RedeemCodes)
	end
})

local MiscSection2 = MiscTab:AddSection({
    Name = "Get Quest",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local questNPCList = QuestManager.GetQuestNPCs()

MiscSection2:AddDropdown({
    Name = "Quest NPC",
    Default = questNPCList[1],
    Options = questNPCList,
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Flag = "Dropdown_QuestNPC",
    Save = true,
    Callback = function(Value) Config.AutoQuest.SelectedNPC = Value end
})

MiscSection2:AddButton({
    Name = "Refresh Quest NPC List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
		local fresh = QuestManager.GetQuestNPCs()
		Notify("Found " .. #fresh .. " Quest NPC(s).")
	end
})

MiscSection2:AddButton({
    Name = "Get Quest",
    Icon = "check-circle",
    Outline = true,
    Callback = function()
		task.spawn(function()
			AutoQuest:AcceptOnce(Config.AutoQuest.SelectedNPC)
		end)
	end
})

-- ==========================================
-- || SETTINGS TAB
-- ==========================================
local SettingsSection1 = SettingsTab:AddSection({
    Name = "Script Utilities",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SettingsSection1:AddToggle({
    Name = "WhiteScreen Mode",
    Default = Config.WhiteScreen,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_WhiteScreen",
    Save = true,
    Callback = function(Value)
		Config.WhiteScreen = Value
		game:GetService("RunService"):Set3dRenderingEnabled(not Value)
		if Value then
			Notify("WhiteScreen Mode Active.")
		end
	end
})

SettingsSection1:AddToggle({
    Name = "Auto Rejoin on Disconnect",
    Default = Config.AutoRejoin,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_AutoRejoin",
    Save = true,
    Callback = function(Value) Config.AutoRejoin = Value end
})

SettingsSection1:AddToggle({
    Name = "Friend-Only Mode (Anti-Stranger)",
    Default = Config.FriendOnly,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_FriendOnly",
    Save = true,
    Callback = function(Value)
		Config.FriendOnly = Value
		if Value then
			for _, player in ipairs(game.Players:GetPlayers()) do
				if player ~= LocalPlayer then
					local isFriend = false
					pcall(function() isFriend = LocalPlayer:IsFriendsWith(player.UserId) end)
					if not isFriend then
						LocalPlayer:Kick("[ArcX Security] Friend-Only Mode Enabled: Stranger found.")
					end
				end
			end
		end
	end
})

local SettingsSection2 = SettingsTab:AddSection({
    Name = "Timed Auto Rejoin",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SettingsSection2:AddToggle({
    Name = "Timed Auto Rejoin",
    Default = Config.TimedRejoin,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Toggle_TimedRejoin",
    Save = true,
    Callback = function(Value) Config.TimedRejoin = Value end
})

SettingsSection2:AddSlider({
    Name = "Rejoin Interval (minutes)",
    Min = 1,
    Max = 120,
    Default = Config.RejoinDelay,
    Increment = 1,
    ValueName = "min",
    Outline = true,
    Flag = "Slider_RejoinDelay",
    Save = true,
    Callback = function(Value) Config.RejoinDelay = Value end
})

-- ==========================================
-- || ADD CONFIG TAB
-- ==========================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

-- ==========================================
-- || INITIALIZE
-- ==========================================
OrionLib:Init()

-- Start loops
Spawner:Start()
AutoFarm:Start()
DungeonFarm:Start()

-- Auto-redeem on load (once per session)
if not _codeRedeemDone then
	_codeRedeemDone = true
	task.spawn(function()
		task.wait(2)
		RedeemCodes()
	end)
end

Notify("ArcX AutoFarm Loaded. Don't forget to refresh and select your weapon!")