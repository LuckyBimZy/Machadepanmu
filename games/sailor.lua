-- ==================== SAILOR PIECE - CATRAZ ULTIMATE v3.0 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.0 COMPLETE EDITION dengan Full AutoFarm System

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
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

--==================================================
-- GLOBAL STATE (Menggunakan getgenv untuk kompatibilitas)
--==================================================
getgenv().IsFarm = false
getgenv().SelectedMob = nil
getgenv().WeaponMode = "Melee"
getgenv().AttackCooldown = 0.3
getgenv().IsTeleporting = false
getgenv().PlankMode = false
getgenv().FarmHeight = 25
getgenv().FarmSpeed = 50
getgenv().MoveMode = "Tween"
getgenv().SelectedSkill = 0
getgenv().AutoSkills = { Z = false, X = false, C = false, V = false, F = false }
getgenv().SkillCooldown = 0.5
getgenv().IsBossFight = false
getgenv().SelectedBoss = nil
getgenv().IsSummonBoss = false
getgenv().SummonDifficulty = "Normal"
getgenv().IsAutoDungeon = false
getgenv().DungeonType = "Shadow"
getgenv().IsBossRush = false
getgenv().IsDungeonQuest = false
getgenv().IsHogyokuQuest = false
getgenv().IsAutoChest = false
getgenv().IsAutoMerchant = false
getgenv().MerchantItem = nil
getgenv().IsNoclip = false
getgenv()._antiAFK = true
getgenv().IslandScanDone = false
getgenv().IslandMobCache = getgenv().IslandMobCache or {}

-- Status text
local statusText = "Siap. Bật Auto Farm untuk memulai."
local function setStatus(text)
    statusText = text
end

--==================================================
-- ANTI-KICK + BYPASS TELEPORT
--==================================================
local BLOCKED_REMOTES = {
    sanity = true, checksanity = true, positioncheck = true,
    antiteleport = true, validateposition = true, checkpos = true,
    anticheat = true, positionvalidate = true, sanitycheck = true,
    movementcheck = true, speedcheck = true, teleportback = true,
    checkposition = true, poscheck = true, verifyposition = true,
}

local OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
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

    return OldNamecall(self, ...)
end)

-- Physics fixer
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
-- LOAD QUEST CONFIG
--==================================================
local questcheck = require(ReplicatedStorage.Modules.QuestConfig)
local checkmap = require(ReplicatedStorage.TravelConfig)

--==================================================
-- MOB DATABASE
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
    local npcFolder = Workspace:FindFirstChild("NPCs")
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
                        name = npcName,
                        level = level,
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
-- QUEST SYSTEM
--==================================================
local function getTargetQuest()
    local level = Player.Data.Level.Value
    local bestNPC = nil
    local maxLevelFound = -1
    local chosenpc = nil

    for npcName, data in pairs(questcheck.RepeatableQuests) do
        local req = tonumber(data.recommendedLevel) or 0
        if level >= req and req > maxLevelFound then
            maxLevelFound = req
            bestNPC = npcName
            if data.requirements and data.requirements[1] then
                chosenpc = data.requirements[1].npcType
            end
        end
    end

    return bestNPC, maxLevelFound, chosenpc
end

--==================================================
-- ISLAND SCANNER (Teleport Bypass)
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
                    local npcFolder = Workspace:FindFirstChild("NPCs")
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

-- Island Scanner v4
local function getAllIslands()
    local islands = {}
    
    local ok, travelConfig = pcall(function()
        return require(ReplicatedStorage:WaitForChild("TravelConfig", 5))
    end)
    
    if ok and travelConfig then
        local data = travelConfig.Islands or travelConfig.Zones
        if data then
            for name, _ in pairs(data) do
                local portalArg = name:gsub("Island", ""):gsub(" ", "")
                table.insert(islands, { name = name, portal = portalArg })
            end
        end
    end
    
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
                end
            end
        end
    end
    
    local extraFolders = {"ServiceNPCs", "StorageNPC", "Mobs", "Enemies"}
    for _, folderName in ipairs(extraFolders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, npc in ipairs(folder:GetChildren()) do
                if npc:IsA("Model") then
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and not getgenv().IslandMobCache[npc.Name] then
                        getgenv().IslandMobCache[npc.Name] = {
                            island = islandName,
                            position = hrp.Position,
                            maxHealth = hum.MaxHealth,
                        }
                        found = found + 1
                    end
                end
            end
        end
    end
    
    return found
end

-- API untuk autofarm
getgenv().TeleportToMobIsland = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    if not cached then
        getgenv().ScanAllIslands()
        cached = getgenv().IslandMobCache[mobName]
    end
    
    if cached then
        local portalArg = cached.island:gsub("Island", ""):gsub(" ", "")
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(portalArg)
        end)
        task.wait(3)
        return true
    end
    return false
end

getgenv().GetIslandForMob = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    return cached and cached.island or nil
end

getgenv().ScanAllIslands = function()
    local islands = getAllIslands()
    local totalMobs = 0
    
    local startIsland = nil
    pcall(function()
        local currentZone = checkmap.GetZoneAt(Player.Character.HumanoidRootPart.Position)
        startIsland = currentZone
    end)
    
    for i, island in ipairs(islands) do
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(island.portal)
        end)
        
        task.wait(4)
        
        local waitCount = 0
        while not Workspace:FindFirstChild("NPCs") and waitCount < 5 do
            task.wait(1)
            waitCount = waitCount + 1
        end
        
        local found = scanCurrentIslandNPCs(island.name)
        totalMobs = totalMobs + found
        task.wait(1)
    end
    
    if startIsland then
        local portalBack = startIsland:gsub("Island", ""):gsub(" ", "")
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(portalBack)
        end)
        task.wait(3)
    end
    
    getgenv().IslandScanDone = true
    buildMobDatabase()
end

--==================================================
-- TELEPORT & MOVEMENT FUNCTIONS
--==================================================
local STEP_SIZE = 50
local STEP_TIME = 0.08
local STEP_DELAY = 0.03
local CLOSE_RANGE = 15

local function findMob(targetName)
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end

    local closest = nil
    local closestDist = math.huge
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local playerPos = char.HumanoidRootPart.Position

    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
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
    if getgenv().PlankMode then
        offset = Vector3.new(0, getgenv().FarmHeight, 0)
    end
    local targetPos = mob.HumanoidRootPart.Position + offset

    if getgenv().MoveMode == "Teleport" then
        root.CFrame = CFrame.new(targetPos)
        return
    end

    local totalDist = (targetPos - root.Position).Magnitude
    getgenv().IsTeleporting = true

    if totalDist <= CLOSE_RANGE then
        microTween(root, CFrame.new(targetPos))
        getgenv().IsTeleporting = false
        return
    end

    local steps = math.ceil(totalDist / STEP_SIZE)
    local startPos = root.Position

    for i = 1, steps do
        if not getgenv().IsFarm and not getgenv().IsBossFight and not getgenv().IsAutoDungeon then break end
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
            root.Velocity = moveDir.Unit * getgenv().FarmSpeed
        end

        microTween(root, CFrame.new(nextPos))
        task.wait(STEP_DELAY)
    end

    root.Velocity = Vector3.new(0, 0, 0)
    getgenv().IsTeleporting = false
end

--==================================================
-- WEAPON / ATTACK SYSTEM
--==================================================
local function equipWeapon()
    local char = Player.Character
    if not char then return nil end
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return nil end

    local mode = getgenv().WeaponMode

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

    pcall(function()
        ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()
    end)

    local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
    for key, slot in pairs(skillMap) do
        if getgenv().AutoSkills[key] then
            pcall(function()
                ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility"):FireServer(slot)
            end)
        end
    end
end

-- Skill spam loop
task.spawn(function()
    while true do
        task.wait(getgenv().SkillCooldown)
        if getgenv().IsFarm or getgenv().IsBossFight or getgenv().IsAutoDungeon or getgenv().IsBossRush then
            local char = Player.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
                for key, slot in pairs(skillMap) do
                    if getgenv().AutoSkills[key] then
                        pcall(function()
                            ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility"):FireServer(slot)
                        end)
                    end
                end
            end
        end
    end
end)

--==================================================
-- NOCLIP
--==================================================
task.spawn(function()
    RunService.Stepped:Connect(function()
        if getgenv().IsNoclip then
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
-- ANTI-VOID
--==================================================
task.spawn(function()
    local lastSafe = CFrame.new(0, 100, 0)
    while task.wait(0.5) do
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
-- ANTI-IDLE
--==================================================
task.spawn(function()
    while task.wait(120) do
        if getgenv()._antiAFK then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                task.wait(0.5)
                VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

--==================================================
-- DUNGEON SYSTEM
--==================================================
local DungeonTypes = {"Shadow", "Rune", "Cid"}

local function doAutoDungeon()
    local dtype = getgenv().DungeonType

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if remotes then
            local dungeonRemote = remotes:FindFirstChild("Dungeon") or remotes:FindFirstChild("DungeonEnter") or remotes:FindFirstChild("EnterDungeon")
            if dungeonRemote then
                dungeonRemote:FireServer("Enter", dtype)
                setStatus("🏰 Entering dungeon: " .. dtype)
            end
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
-- BOSS RUSH
--==================================================
local function doBossRush()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if remotes then
            local rushRemote = remotes:FindFirstChild("BossRush") or remotes:FindFirstChild("EnterBossRush")
            if rushRemote then
                rushRemote:FireServer("Enter")
                setStatus("⚡ Boss Rush mode!")
            end
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
-- QUEST CHAINS
--==================================================
local DungeonQuestOrder = {"Shadow", "Rune", "Cid", "Shadow", "Rune", "Cid"}

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

local function doDungeonQuest()
    local progress = getDungeonQuestProgress()
    if progress >= 6 then
        setStatus("✅ Dungeon Quest complete! (6/6)")
        return false
    end

    local nextDungeon = DungeonQuestOrder[progress + 1] or "Shadow"
    setStatus(string.format("🔮 Dungeon Quest: %d/6 → %s", progress, nextDungeon))

    getgenv().DungeonType = nextDungeon
    return doAutoDungeon()
end

local HogyokuBosses = {"Boss1", "Boss2", "Boss3", "Boss4", "Boss5"}

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

local function doHogyokuQuest()
    local progress = getHogyokuProgress()
    if progress >= 5 then
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
            if remotes then
                local questR = remotes:FindFirstChild("Quest") or remotes:FindFirstChild("QuestAccept")
                if questR then
                    questR:FireServer("HogyokuComplete")
                end
            end
        end)
        setStatus("✅ Hogyoku Quest complete! (5/5)")
        return false
    end

    local targetBoss = HogyokuBosses[progress + 1] or "Boss1"
    setStatus(string.format("🔮 Hogyoku: %d/5 → %s", progress, targetBoss))

    local boss = findBoss(targetBoss)
    if boss then
        tweenToMob(boss)
        autoAttack(boss)
        return true
    end
    return false
end

--==================================================
-- AUTO CHEST
--==================================================
local ChestTypes = {"Wood", "Iron", "Gold", "Diamond", "Legendary"}

task.spawn(function()
    while true do
        task.wait(5)
        if getgenv().IsAutoChest then
            for _, chestType in ipairs(ChestTypes) do
                pcall(function()
                    local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
                    if remotes then
                        local chestR = remotes:FindFirstChild("Chest") or remotes:FindFirstChild("OpenChest")
                        if chestR then
                            chestR:FireServer("Open", chestType)
                        end
                    end
                end)
            end
            setStatus("📦 Auto Chest: Opened all chests")
        end
    end
end)

--==================================================
-- AUTO MERCHANT
--==================================================
task.spawn(function()
    while true do
        task.wait(30)
        if getgenv().IsAutoMerchant and getgenv().MerchantItem then
            pcall(function()
                local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
                if remotes then
                    local merchantR = remotes:FindFirstChild("Merchant") or remotes:FindFirstChild("Shop") or remotes:FindFirstChild("Buy")
                    if merchantR then
                        merchantR:FireServer("Buy", getgenv().MerchantItem)
                        setStatus("🛒 Bought: " .. getgenv().MerchantItem)
                    end
                end
            end)
        end
    end
end)

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

local SettingsTab = Window:MakeTab({
    Name = "⚙️ Settings",
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

local StatusSection = MainTab:AddSection({
    Name = "📝 STATUS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local StatusPara = StatusSection:AddParagraph({
    Title = "Current Status",
    Desc = statusText,
    Image = "info",
    ImageSize = 38
})

-- Auto refresh info
task.spawn(function()
    while true do
        task.wait(2)
        
        local level = pcall(function() return Player.Data.Level.Value end) and Player.Data.Level.Value or 0
        local money = pcall(function() return Player.Data.Money.Value end) and Player.Data.Money.Value or 0
        local gems = pcall(function() return Player.Data.Gems.Value end) and Player.Data.Gems.Value or 0
        
        playerInfoPara:SetDesc(
            "Display Name: " .. Player.DisplayName .. "\n" ..
            "Level: " .. level .. "\n" ..
            "Money: " .. (money >= 1000000 and string.format("%.1fM", money/1000000) or (money >= 1000 and string.format("%.0fK", money/1000) or money)) .. "\n" ..
            "Gems: " .. gems .. "\n" ..
            "Account Age: " .. Player.AccountAge .. " days"
        )
        
        local players = Players:GetPlayers()
        local ping = pcall(function() 
            return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
        end) or 0
        
        ServerInfoPara:SetDesc(
            "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
            "Ping: " .. ping .. "ms\n" ..
            "Uptime: " .. getUptime()
        )
        
        StatusPara:SetDesc(statusText)
    end
end)

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
    Name = "Auto Farm Quest",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(state)
        getgenv().IsFarm = state
        setStatus(state and "🟢 Auto Farm ON" or "⏸️ Auto Farm OFF")
    end
})

FarmSection:AddToggle({
    Name = "🛹 Plank Mode (hover)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(state)
        getgenv().PlankMode = state
    end
})

FarmSection:AddDropdown({
    Name = "🚀 Move Mode",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Outline = true,
    Flag = "MoveMode",
    Save = true,
    Callback = function(val)
        getgenv().MoveMode = val
    end
})

FarmSection:AddSlider({
    Name = "📏 Farm Height (Plank)",
    Min = 5,
    Max = 100,
    Default = 25,
    ValueName = "studs",
    Outline = true,
    Flag = "FarmHeight",
    Save = true,
    Callback = function(val)
        getgenv().FarmHeight = val
    end
})

FarmSection:AddSlider({
    Name = "💨 Farm Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    ValueName = "studs/s",
    Outline = true,
    Flag = "FarmSpeed",
    Save = true,
    Callback = function(val)
        getgenv().FarmSpeed = val
    end
})

FarmSection:AddSlider({
    Name = "⏱️ Attack Cooldown (ms)",
    Min = 100,
    Max = 1000,
    Default = 300,
    ValueName = "ms",
    Outline = true,
    Flag = "AttackCooldown",
    Save = true,
    Callback = function(val)
        getgenv().AttackCooldown = val / 1000
    end
})

-- Target Selection
buildMobDatabase()
local mobNames = {"Auto (Theo Level)"}
for _, mob in ipairs(MobDatabase) do
    table.insert(mobNames, string.format("[Lv.%d] %s", mob.level, mob.name))
end

FarmSection:AddDropdown({
    Name = "👾 Pilih Target",
    Default = "Auto (Theo Level)",
    Options = mobNames,
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "TargetMob",
    Save = true,
    Callback = function(val)
        if val == "Auto (Theo Level)" then
            getgenv().SelectedMob = nil
        else
            getgenv().SelectedMob = val:match("%] (.+)$")
        end
    end
})

FarmSection:AddButton({
    Name = "🔄 Refresh Mob List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildMobDatabase()
        local newMobs = {"Auto (Theo Level)"}
        for _, mob in ipairs(MobDatabase) do
            table.insert(newMobs, string.format("[Lv.%d] %s", mob.level, mob.name))
        end
        OrionLib.Flags["TargetMob"]:SetOptions(newMobs)
        setStatus("✅ Mob list refreshed: " .. #MobDatabase .. " mobs found")
    end
})

--==================================================
-- BOSS TAB
--==================================================
local BossMainSection = BossTab:AddSection({
    Name = "🐉 WORLD BOSS FIGHT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "Auto Boss Fight",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossFight",
    Save = true,
    Callback = function(state)
        getgenv().IsBossFight = state
        setStatus(state and "🐉 Boss Fight ON" or "Boss Fight OFF")
    end
})

-- Build boss list
local BossList = {}
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

BossMainSection:AddDropdown({
    Name = "🎯 Pilih Boss",
    Default = BossList[1],
    Options = BossList,
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectBoss",
    Save = true,
    Callback = function(val)
        getgenv().SelectedBoss = val
    end
})

BossMainSection:AddSection({
    Name = "🔮 SUMMON BOSS",
    TextSize = 16,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "Auto Summon Boss",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SummonBoss",
    Save = true,
    Callback = function(state)
        getgenv().IsSummonBoss = state
        setStatus(state and "🔮 Summon Boss ON" or "Summon OFF")
    end
})

BossMainSection:AddDropdown({
    Name = "💀 Difficulty",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Nightmare"},
    Multi = false,
    Outline = true,
    Flag = "SummonDifficulty",
    Save = true,
    Callback = function(val)
        getgenv().SummonDifficulty = val
    end
})

--==================================================
-- MODES TAB
--==================================================
local ModeMainSection = ModeTab:AddSection({
    Name = "🏰 DUNGEONS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "Auto Dungeon",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(state)
        getgenv().IsAutoDungeon = state
        setStatus(state and "🏰 Dungeon ON" or "Dungeon OFF")
    end
})

ModeMainSection:AddDropdown({
    Name = "🏰 Dungeon Type",
    Default = "Shadow",
    Options = DungeonTypes,
    Multi = false,
    Outline = true,
    Flag = "DungeonType",
    Save = true,
    Callback = function(val)
        getgenv().DungeonType = val
    end
})

ModeMainSection:AddSection({
    Name = "⚡ BOSS RUSH",
    TextSize = 16,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "Auto Boss Rush",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossRush",
    Save = true,
    Callback = function(state)
        getgenv().IsBossRush = state
        setStatus(state and "⚡ Boss Rush ON" or "Boss Rush OFF")
    end
})

ModeMainSection:AddSection({
    Name = "🔮 QUEST CHAINS",
    TextSize = 16,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "Dungeon Quest (6 pieces)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(state)
        getgenv().IsDungeonQuest = state
        setStatus(state and "🔮 Dungeon Quest ON" or "DQ OFF")
    end
})

ModeMainSection:AddToggle({
    Name = "Hogyoku Quest (5 fragments)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(state)
        getgenv().IsHogyokuQuest = state
        setStatus(state and "🔮 Hogyoku Quest ON" or "HQ OFF")
    end
})

--==================================================
-- SKILLS TAB
--==================================================
local SkillMainSection = SkillTab:AddSection({
    Name = "🎯 INDIVIDUAL SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local skillKeys = {"Z", "X", "C", "V", "F"}
local skillSlots = { Z=1, X=2, C=3, V=4, F=5 }

for _, key in ipairs(skillKeys) do
    SkillMainSection:AddToggle({
        Name = string.format("[%s] Skill %d", key, skillSlots[key]),
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Skill_" .. key,
        Save = true,
        Callback = function(state)
            getgenv().AutoSkills[key] = state
        end
    })
end

SkillMainSection:AddToggle({
    Name = "🔥 ALL Skills ON/OFF",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AllSkills",
    Save = true,
    Callback = function(state)
        for _, k in ipairs(skillKeys) do
            getgenv().AutoSkills[k] = state
            OrionLib.Flags["Skill_" .. k]:SetValue(state)
        end
    end
})

SkillMainSection:AddSlider({
    Name = "⏱️ Skill Cooldown (ms)",
    Min = 100,
    Max = 3000,
    Default = 500,
    ValueName = "ms",
    Outline = true,
    Flag = "SkillCooldown",
    Save = true,
    Callback = function(val)
        getgenv().SkillCooldown = val / 1000
    end
})

SkillMainSection:AddSection({
    Name = "⬛ HAKI",
    TextSize = 16,
    Glass = true,
    Outline = true
})

SkillMainSection:AddToggle({
    Name = "⬛ Auto Armament Haki",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(state)
        pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("HakiRemote"):FireServer("Toggle")
        end)
    end
})

SkillMainSection:AddToggle({
    Name = "👁️ Auto Observation Haki",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoObsHaki",
    Save = true,
    Callback = function(state)
        pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ObservationHakiRemote"):FireServer("Toggle")
        end)
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
    Name = "Auto Open Chests",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(state)
        getgenv().IsAutoChest = state
        setStatus(state and "📦 Auto Chest ON" or "Chest OFF")
    end
})

ItemMainSection:AddSection({
    Name = "🛒 AUTO MERCHANT",
    TextSize = 16,
    Glass = true,
    Outline = true
})

ItemMainSection:AddToggle({
    Name = "Auto Buy from Merchant",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoMerchant",
    Save = true,
    Callback = function(state)
        getgenv().IsAutoMerchant = state
    end
})

ItemMainSection:AddDropdown({
    Name = "🛒 Item to Buy",
    Default = "HealthPotion",
    Options = {"HealthPotion", "StaminaPotion", "BoostScroll", "SummonStone"},
    Multi = false,
    Outline = true,
    Flag = "MerchantItem",
    Save = true,
    Callback = function(val)
        getgenv().MerchantItem = val
    end
})

--==================================================
-- SETTINGS TAB
--==================================================
local CombatSection = SettingsTab:AddSection({
    Name = "🔧 COMBAT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

CombatSection:AddDropdown({
    Name = "⚔️ Weapon Mode",
    Default = "Melee",
    Options = {"Melee", "Fruit"},
    Multi = false,
    Outline = true,
    Flag = "WeaponMode",
    Save = true,
    Callback = function(val)
        getgenv().WeaponMode = val
    end
})

CombatSection:AddToggle({
    Name = "👻 Noclip",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(state)
        getgenv().IsNoclip = state
        setStatus(state and "👻 Noclip ON" or "Noclip OFF")
    end
})

CombatSection:AddSection({
    Name = "🚀 OPTIMIZATION",
    TextSize = 16,
    Glass = true,
    Outline = true
})

CombatSection:AddToggle({
    Name = "Make Game Smoother",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Optimize",
    Save = true,
    Callback = function(state)
        pcall(function()
            local settingsRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SettingsToggle")
            local toggles = {
                {"MuteMusic", state}, {"MuteSFX", state},
                {"DisableVFX", state}, {"DisableCutscene", state},
                {"DisableOtherVFX", state}, {"RemoveTexture", state},
                {"RemoveShadows", state},
            }
            for _, t in ipairs(toggles) do
                settingsRemote:FireServer(t[1], t[2])
            end
            local settings = UserSettings():GetService("UserGameSettings")
            settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            settings.GraphicsQualityLevel = 1
        end)
    end
})

CombatSection:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(state)
        getgenv()._antiAFK = state
    end
})

CombatSection:AddSection({
    Name = "⌨️ KEYBINDS",
    TextSize = 16,
    Glass = true,
    Outline = true
})

CombatSection:AddKeybind({
    Name = "[F2] Toggle Farm",
    Default = Enum.KeyCode.F2,
    Flag = "KeybindF2",
    Save = true,
    Callback = function()
        getgenv().IsFarm = not getgenv().IsFarm
        setStatus(getgenv().IsFarm and "🟢 Farm ON (F2)" or "⏸️ Farm OFF (F2)")
    end
})

CombatSection:AddKeybind({
    Name = "[V] Toggle Farm",
    Default = Enum.KeyCode.V,
    Flag = "KeybindV",
    Save = true,
    Callback = function()
        getgenv().IsFarm = not getgenv().IsFarm
        setStatus(getgenv().IsFarm and "🟢 Farm ON (V)" or "⏸️ Farm OFF (V)")
    end
})

CombatSection:AddKeybind({
    Name = "[B] Toggle Boss Fight",
    Default = Enum.KeyCode.B,
    Flag = "KeybindB",
    Save = true,
    Callback = function()
        getgenv().IsBossFight = not getgenv().IsBossFight
        setStatus(getgenv().IsBossFight and "🐉 Boss ON (B)" or "Boss OFF (B)")
    end
})

CombatSection:AddKeybind({
    Name = "[M] Toggle All Skills",
    Default = Enum.KeyCode.M,
    Flag = "KeybindM",
    Save = true,
    Callback = function()
        local anyOn = false
        for _, v in pairs(getgenv().AutoSkills) do
            if v then anyOn = true break end
        end
        local newState = not anyOn
        for _, k in ipairs(skillKeys) do
            getgenv().AutoSkills[k] = newState
            OrionLib.Flags["Skill_" .. k]:SetValue(newState)
        end
        setStatus(newState and "🔥 All Skills ON (M)" or "Skills OFF (M)")
    end
})

CombatSection:AddSection({
    Name = "📝 DEBUG",
    TextSize = 16,
    Glass = true,
    Outline = true
})

CombatSection:AddButton({
    Name = "🗺️ Print Quest Data",
    Outline = true,
    Callback = function()
        print("\n═══ QUEST CONFIG ═══")
        for npcName, data in pairs(questcheck.RepeatableQuests) do
            local req = data.requirements and data.requirements[1]
            local mobType = req and req.npcType or "???"
            local amount = req and req.amount or "?"
            print(string.format("  [%s] Lv.%s → Kill %s x%s", npcName, tostring(data.recommendedLevel), mobType, tostring(amount)))
        end
        print("═══ END ═══\n")
    end
})

CombatSection:AddButton({
    Name = "🔄 Scan All Islands",
    Outline = true,
    Callback = function()
        setStatus("🔍 Scanning all islands...")
        task.spawn(function()
            getgenv().ScanAllIslands()
            setStatus("✅ Island scan complete!")
        end)
    end
})

--==================================================
-- MAIN LOOP (Priority System)
--==================================================
task.spawn(function()
    autoLearnIslandLevels()
    
    -- Start scan in background
    task.spawn(function()
        task.wait(5)
        getgenv().ScanAllIslands()
    end)

    while true do
        task.wait(0.1)

        local char = Player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(1)
            continue
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            setStatus("💀 Waiting for respawn...")
            task.wait(2)
            continue
        end

        -- Priority 1: Dungeon Quest
        if getgenv().IsDungeonQuest then
            if doDungeonQuest() then
                task.wait(getgenv().AttackCooldown)
                continue
            end
        end

        -- Priority 2: Hogyoku Quest
        if getgenv().IsHogyokuQuest then
            if doHogyokuQuest() then
                task.wait(getgenv().AttackCooldown)
                continue
            end
        end

        -- Priority 3: Auto Dungeon
        if getgenv().IsAutoDungeon then
            if doAutoDungeon() then
                task.wait(getgenv().AttackCooldown)
                continue
            end
        end

        -- Priority 4: Boss Rush
        if getgenv().IsBossRush then
            if doBossRush() then
                task.wait(getgenv().AttackCooldown)
                continue
            end
        end

        -- Priority 5: Summon Boss
        if getgenv().IsSummonBoss then
            -- Try to summon
            pcall(function()
                local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
                if remotes then
                    local summonRemote = remotes:FindFirstChild("SummonBoss") or remotes:FindFirstChild("BossSummon") or remotes:FindFirstChild("SpawnBoss")
                    if summonRemote then
                        summonRemote:FireServer(getgenv().SelectedBoss or "Boss1", getgenv().SummonDifficulty)
                    end
                end
            end)
            task.wait(2)
            local boss = findBoss(getgenv().SelectedBoss)
            if boss then
                tweenToMob(boss)
                autoAttack(boss)
                task.wait(getgenv().AttackCooldown)
                continue
            end
        end

        -- Priority 6: Boss Fight
        if getgenv().IsBossFight and getgenv().SelectedBoss then
            local boss = findBoss(getgenv().SelectedBoss)
            if boss then
                local h = boss:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    setStatus(string.format("🐉 Boss Fight: %s | HP: %d/%d", boss.Name, h.Health, h.MaxHealth))
                    tweenToMob(boss)
                    autoAttack(boss)
                    task.wait(getgenv().AttackCooldown)
                    continue
                end
            end
        end

        -- Priority 7: Auto Farm
        if getgenv().IsFarm then
            local targetMobName = getgenv().SelectedMob
            local targetNPC, _, chosenpc

            if not targetMobName then
                targetNPC, _, chosenpc = getTargetQuest()
                targetMobName = chosenpc
            end

            if not targetMobName then
                setStatus("❓ No suitable mob found for your level")
                task.wait(1)
                continue
            end

            if targetNPC then
                pcall(function()
                    ReplicatedStorage.RemoteEvents.QuestAccept:FireServer(targetNPC)
                end)
            end

            local mob, dist = findMob(targetMobName)

            if mob then
                local mobH = mob:FindFirstChildOfClass("Humanoid")
                if mobH and mobH.Health > 0 then
                    setStatus(string.format("⚔️ %s | HP:%d/%d | %dm", mob.Name, mobH.Health, mobH.MaxHealth, math.floor(dist)))

                    tweenToMob(mob)
                    task.wait(0.2)

                    while getgenv().IsFarm and mob and mob.Parent and mob:FindFirstChild("HumanoidRootPart") do
                        local h = mob:FindFirstChildOfClass("Humanoid")
                        if not h or h.Health <= 0 then break end
                        tweenToMob(mob)
                        autoAttack(mob)
                        setStatus(string.format("⚔️ %s | ❤️%d/%d | 🗡️%s", mob.Name, h.Health, h.MaxHealth, getgenv().WeaponMode))
                        task.wait(getgenv().AttackCooldown)
                    end

                    setStatus("✅ Killed: " .. (mob and mob.Name or "mob"))
                    task.wait(0.3)
                end
            else
                setStatus("🔍 " .. targetMobName .. " → Teleporting to island...")
                getgenv().TeleportToMobIsland(targetMobName)
                task.wait(3)
            end
        else
            task.wait(0.5)
        end
    end
end))

--==================================================
-- INITIALIZE
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")

print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE v3.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm System - COMPLETE")
print("✅ Boss Fight + Summon Boss")
print("✅ Dungeon System + Boss Rush")
print("✅ Quest Chains (Dungeon + Hogyoku)")
print("✅ Island Scanner (Teleport Bypass)")
print("✅ Auto Chest + Auto Merchant")
print("✅ Individual Skills + Haki")
print("✅ Anti-Kick + Anti-TP + Noclip")
print("═══════════════════════════════════════════════════════")
print("Keybinds: F2/V = Farm | B = Boss | M = All Skills")
print("═══════════════════════════════════════════════════════")