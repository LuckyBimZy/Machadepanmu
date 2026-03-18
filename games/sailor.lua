-- ==================== SAILOR PIECE - CATRAZ ULTIMATE v5 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Auto Farm System v4 dengan Priority Loop + Bypass TP
-- Version: 5.0 ULTIMATE

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
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RepStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Remote References
local Remotes = RepStorage:WaitForChild("Remotes")
local RemoteEvents = RepStorage:WaitForChild("RemoteEvents")
local CombatRemotes = RepStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes")
local AbilityRemote = RepStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")

local hitRemote = CombatRemotes:WaitForChild("RequestHit")
local questRemote = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")
local hakiRemote = RemoteEvents:WaitForChild("HakiRemote")
local obsHakiRemote = RemoteEvents:WaitForChild("ObservationHakiRemote")
local summonBossRemote = Remotes:WaitForChild("RequestSummonBoss")
local dungeonRemote = RemoteEvents:WaitForChild("DungeonEnter") or RemoteEvents:WaitForChild("EnterDungeon")
local merchantRemote = RemoteEvents:WaitForChild("Merchant") or RemoteEvents:WaitForChild("Shop")

-- Quest Config
local questcheck = require(RepStorage.Modules.QuestConfig)
local checkmap = require(RepStorage.TravelConfig)

--==================================================
-- BYPASS TELEPORT SYSTEM (v4)
--==================================================
getgenv().BypassLoaded = true
getgenv().NoclipEnabled = true
getgenv().AntiVoid = true
getgenv().AntiIdle = true

-- Blocked remote names
local BLOCKED_NAMES = {
    "sanity", "checksanity", "positioncheck", "antiteleport",
    "validateposition", "checkpos", "anticheat", "positionvalidate",
    "sanitycheck", "movementcheck", "speedcheck", "teleportback",
    "checkposition", "poscheck", "verifyposition", "servercheck",
    "validate", "verification", "exploit",
}

local blockedLookup = {}
for _, name in ipairs(BLOCKED_NAMES) do
    blockedLookup[name] = true
end

-- Hook __namecall untuk block kick + anti-TP
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if (method == "Kick" or method == "kick") then
        if self == Player or self == Players then
            warn("[AntiKick] Blocked kick:", args[1])
            return nil
        end
    end

    if method == "FireServer" or method == "InvokeServer" then
        local ok, isRemote = pcall(function()
            return self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
        end)
        if ok and isRemote then
            local remoteName = self.Name:lower():gsub("_", ""):gsub("-", "")
            if blockedLookup[remoteName] then
                warn("[AntiTP] Blocked remote:", self.Name)
                return nil
            end
        end
    end

    return OldNamecall(self, ...)
end)

-- Hook getgc untuk disable anti-cheat functions
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
    print("[BYPASS] Hooked " .. tostring(hookedCount) .. " AC functions")
end

-- Island Scanner Cache
getgenv().IslandMobCache = getgenv().IslandMobCache or {}
getgenv().IslandScanDone = false

-- Function to get all islands
local function getAllIslands()
    local islands = {}
    
    local ok, travelConfig = pcall(function()
        return require(RepStorage:WaitForChild("TravelConfig", 5))
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
        for _, child in ipairs(workspace:GetChildren()) do
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

-- Scan NPCs at current island
local function scanCurrentIslandNPCs(islandName)
    local npcFolder = workspace:FindFirstChild("NPCs")
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
        local folder = workspace:FindFirstChild(folderName)
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

-- API for autofarm
getgenv().TeleportToMobIsland = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    if not cached then
        getgenv().ScanAllIslands()
        cached = getgenv().IslandMobCache[mobName]
    end
    
    if cached then
        local portalArg = cached.island:gsub("Island", ""):gsub(" ", "")
        pcall(function()
            tpRemote:FireServer(portalArg)
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
        local ok = pcall(function()
            tpRemote:FireServer(island.portal)
        end)
        
        if ok then
            task.wait(4)
            
            local waitCount = 0
            while not workspace:FindFirstChild("NPCs") and waitCount < 5 do
                task.wait(1)
                waitCount = waitCount + 1
            end
            
            local found = scanCurrentIslandNPCs(island.name)
            totalMobs = totalMobs + found
        end
        task.wait(1)
    end
    
    if startIsland then
        local portalBack = startIsland:gsub("Island", ""):gsub(" ", "")
        pcall(function()
            tpRemote:FireServer(portalBack)
        end)
        task.wait(3)
    end
    
    getgenv().IslandScanDone = true
    print("[Scanner] Scan completed! Found " .. totalMobs .. " mob types")
end

-- Noclip
task.spawn(function()
    RunService.Stepped:Connect(function()
        if not getgenv().NoclipEnabled then return end
        local char = Player.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end)

-- Anti-Void
task.spawn(function()
    local lastSafe = CFrame.new(0, 100, 0)
    while task.wait(0.5) do
        if not getgenv().AntiVoid then continue end
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

-- Anti-Idle
task.spawn(function()
    while task.wait(120) do
        if not getgenv().AntiIdle then continue end
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

--==================================================
-- AUTO FARM STATE (v4)
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
    local npcFolder = workspace:FindFirstChild("NPCs")
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
-- QUEST SYSTEM
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
-- ISLAND LEARNING
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
                    local npcFolder = workspace:FindFirstChild("NPCs")
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

local function getPortalForLevel(lvl)
    for zoneId, rangeData in pairs(autoLevelRanges) do
        if lvl >= rangeData.MinLevel and lvl <= rangeData.MaxLevel then
            return rangeData.PortalKey
        end
    end
    return "StarterIsland"
end

local function teleportToIsland(currentLevel, targetMobName)
    if targetMobName and getgenv().TeleportToMobIsland then
        local ok = getgenv().TeleportToMobIsland(targetMobName)
        if ok then
            hasLearned = false
            autoLearnIslandLevels()
            buildMobDatabase()
            return
        end
    end

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

--==================================================
-- FIND MOB & TWEEN
--==================================================
local STEP_SIZE = 50
local STEP_TIME = 0.08
local STEP_DELAY = 0.03
local CLOSE_RANGE = 15

local function findMob(targetName)
    local npcFolder = workspace:FindFirstChild("NPCs")
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
        local f = workspace:FindFirstChild(folder)
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

    pcall(function() hitRemote:FireServer() end)

    local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
    for key, slot in pairs(skillMap) do
        if getgenv().AutoSkills[key] then
            pcall(function() AbilityRemote:FireServer(slot) end)
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
                        pcall(function() AbilityRemote:FireServer(slot) end)
                    end
                end
            end
        end
    end
end)

--==================================================
-- BOSS SYSTEM
--==================================================
local BossList = {}

local function buildBossList()
    table.clear(BossList)
    for _, folder in ipairs({"Bosses", "Boss", "WorldBoss", "NPCs"}) do
        local f = workspace:FindFirstChild(folder)
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

local function doBossFight()
    local bossName = getgenv().SelectedBoss
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

-- Summon Boss
local function doSummonBoss()
    pcall(function()
        local summonRemote = RemoteEvents:FindFirstChild("SummonBoss") or RemoteEvents:FindFirstChild("BossSummon") or RemoteEvents:FindFirstChild("SpawnBoss")
        if summonRemote then
            summonRemote:FireServer(getgenv().SelectedBoss or BossList[1], getgenv().SummonDifficulty)
        end
    end)

    pcall(function()
        local craftRemote = RemoteEvents:FindFirstChild("Crafting") or RemoteEvents:FindFirstChild("Craft")
        if craftRemote then
            craftRemote:FireServer("SummonStone")
        end
    end)

    task.wait(2)

    local boss = findBoss(getgenv().SelectedBoss)
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

-- Dungeon
local DungeonTypes = {"Shadow", "Rune", "Cid"}

local function doAutoDungeon()
    pcall(function()
        local dungeonRemote = RemoteEvents:FindFirstChild("Dungeon") or RemoteEvents:FindFirstChild("DungeonEnter") or RemoteEvents:FindFirstChild("EnterDungeon")
        if dungeonRemote then
            dungeonRemote:FireServer("Enter", getgenv().DungeonType)
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

-- Boss Rush
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

-- Dungeon Quest
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

local DungeonQuestOrder = {"Shadow", "Rune", "Cid", "Shadow", "Rune", "Cid"}

local function doDungeonQuest()
    local progress = getDungeonQuestProgress()
    if progress >= 6 then
        return false
    end

    local nextDungeon = DungeonQuestOrder[progress + 1] or "Shadow"
    getgenv().DungeonType = nextDungeon
    return doAutoDungeon()
end

-- Hogyoku Quest
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

local HogyokuBosses = {"Boss1", "Boss2", "Boss3", "Boss4", "Boss5"}

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

    local targetBoss = HogyokuBosses[progress + 1] or "Boss1"
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
                    local chestR = RemoteEvents:FindFirstChild("Chest") or RemoteEvents:FindFirstChild("OpenChest")
                    if chestR then
                        chestR:FireServer("Open", chestType)
                    end
                end)
            end
        end
    end
end)

-- Auto Merchant
task.spawn(function()
    while true do
        task.wait(30)
        if getgenv().IsAutoMerchant and getgenv().MerchantItem then
            pcall(function()
                local merchantR = RemoteEvents:FindFirstChild("Merchant") or RemoteEvents:FindFirstChild("Shop") or RemoteEvents:FindFirstChild("Buy")
                if merchantR then
                    merchantR:FireServer("Buy", getgenv().MerchantItem)
                end
            end)
        end
    end
end)

--==================================================
-- SAVE ORIGINAL LIGHTING
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
    Subtext = "Catraz Ultimate v5",
    Version = "v5.0",
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
    Name = "Boss System",
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

local function UpdatePlayerInfo()
    local level = 0
    local money = 0
    local gems = 0
    pcall(function() 
        level = Player.Data.Level.Value or 0
        money = Player.Data.Money.Value or 0
        gems = Player.Data.Gems.Value or 0
    end)
    
    return "Display: " .. Player.DisplayName .. "\n" ..
           "Level: " .. level .. "\n" ..
           "Money: " .. formatNumber(money) .. "\n" ..
           "Gems: " .. formatNumber(gems) .. "\n" ..
           "Age: " .. Player.AccountAge .. " days"
end

local PlayerInfoPara = PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = UpdatePlayerInfo(),
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

-- Auto refresh
task.spawn(function()
    while true do
        task.wait(1)
        ServerInfoPara:SetDesc(UpdateServerInfo())
        PlayerInfoPara:SetDesc(UpdatePlayerInfo())
    end
end)

--==================================================
-- FARM TAB
--==================================================
local FarmMainSection = FarmTab:AddSection({
    Name = "⚡ AUTO FARM SETTINGS",
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
        getgenv().IsFarm = Value
        Notify(Value and "Auto Farm Enabled" or "Auto Farm Disabled")
    end
})

FarmMainSection:AddDropdown({
    Name = "WEAPON MODE",
    Default = "Melee",
    Options = {"Melee", "Fruit"},
    Multi = false,
    Outline = true,
    Flag = "WeaponMode",
    Save = true,
    Callback = function(Value)
        getgenv().WeaponMode = Value
    end
})

FarmMainSection:AddDropdown({
    Name = "MOVE MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Outline = true,
    Flag = "MoveMode",
    Save = true,
    Callback = function(Value)
        getgenv().MoveMode = Value
    end
})

FarmMainSection:AddToggle({
    Name = "PLANK MODE (HOVER)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(Value)
        getgenv().PlankMode = Value
    end
})

FarmMainSection:AddSlider({
    Name = "FARM HEIGHT (PLANK)",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "FarmHeight",
    Save = true,
    Callback = function(Value)
        getgenv().FarmHeight = Value
    end
})

FarmMainSection:AddSlider({
    Name = "FARM SPEED",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    ValueName = "speed",
    Outline = true,
    Flag = "FarmSpeed",
    Save = true,
    Callback = function(Value)
        getgenv().FarmSpeed = Value
    end
})

FarmMainSection:AddSlider({
    Name = "ATTACK COOLDOWN (ms)",
    Min = 100,
    Max = 1000,
    Default = 300,
    Increment = 10,
    ValueName = "ms",
    Outline = true,
    Flag = "AttackCooldown",
    Save = true,
    Callback = function(Value)
        getgenv().AttackCooldown = Value / 1000
    end
})

local MobSection = FarmTab:AddSection({
    Name = "🎯 TARGET SELECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Build mob database
buildMobDatabase()
local mobNames = {"Auto (by Level)"}
for _, mob in ipairs(MobDatabase) do
    table.insert(mobNames, string.format("[Lv.%d] %s", mob.level, mob.name))
end

MobSection:AddDropdown({
    Name = "SELECT MOB",
    Default = "Auto (by Level)",
    Options = mobNames,
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedMob",
    Save = true,
    Callback = function(Value)
        if Value == "Auto (by Level)" then
            getgenv().SelectedMob = nil
        else
            getgenv().SelectedMob = Value:match("%] (.+)$")
        end
    end
})

MobSection:AddButton({
    Name = "🔄 REFRESH MOB LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildMobDatabase()
        local newMobs = {"Auto (by Level)"}
        for _, mob in ipairs(MobDatabase) do
            table.insert(newMobs, string.format("[Lv.%d] %s", mob.level, mob.name))
        end
        OrionLib.Flags["SelectedMob"]:SetOptions(newMobs)
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
    Name = "AUTO BOSS FIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossFight",
    Save = true,
    Callback = function(Value)
        getgenv().IsBossFight = Value
    end
})

buildBossList()
BossMainSection:AddDropdown({
    Name = "SELECT BOSS",
    Default = BossList[1] or "WorldBoss",
    Options = BossList,
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedBoss",
    Save = true,
    Callback = function(Value)
        getgenv().SelectedBoss = Value
    end
})

local SummonSection = BossTab:AddSection({
    Name = "🔮 SUMMON BOSS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SummonSection:AddToggle({
    Name = "AUTO SUMMON BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SummonBoss",
    Save = true,
    Callback = function(Value)
        getgenv().IsSummonBoss = Value
    end
})

SummonSection:AddDropdown({
    Name = "DIFFICULTY",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Nightmare"},
    Multi = false,
    Outline = true,
    Flag = "SummonDifficulty",
    Save = true,
    Callback = function(Value)
        getgenv().SummonDifficulty = Value
    end
})

--==================================================
-- DUNGEON TAB
--==================================================
local DungeonMainSection = DungeonTab:AddSection({
    Name = "🏰 DUNGEON",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonMainSection:AddToggle({
    Name = "AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        getgenv().IsAutoDungeon = Value
    end
})

DungeonMainSection:AddDropdown({
    Name = "DUNGEON TYPE",
    Default = "Shadow",
    Options = DungeonTypes,
    Multi = false,
    Outline = true,
    Flag = "DungeonType",
    Save = true,
    Callback = function(Value)
        getgenv().DungeonType = Value
    end
})

local RushSection = DungeonTab:AddSection({
    Name = "⚡ BOSS RUSH",
    TextSize = 18,
    Glass = true,
    Outline = true
})

RushSection:AddToggle({
    Name = "AUTO BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossRush",
    Save = true,
    Callback = function(Value)
        getgenv().IsBossRush = Value
    end
})

local QuestSection = DungeonTab:AddSection({
    Name = "🔮 QUEST CHAINS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

QuestSection:AddToggle({
    Name = "DUNGEON QUEST (6 pieces)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(Value)
        getgenv().IsDungeonQuest = Value
    end
})

QuestSection:AddToggle({
    Name = "HOGYOKU QUEST (5 fragments)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(Value)
        getgenv().IsHogyokuQuest = Value
    end
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

for _, key in ipairs({"Z", "X", "C", "V", "F"}) do
    local slotNum = ({ Z=1, X=2, C=3, V=4, F=5 })[key]
    SkillMainSection:AddToggle({
        Name = string.format("USE SKILL %s (Slot %d)", key, slotNum),
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Skill_" .. key,
        Save = true,
        Callback = function(Value)
            getgenv().AutoSkills[key] = Value
        end
    })
end

SkillMainSection:AddButton({
    Name = "🔥 ALL SKILLS ON",
    Icon = "zap",
    Outline = true,
    Callback = function()
        for _, k in ipairs({"Z","X","C","V","F"}) do
            getgenv().AutoSkills[k] = true
            OrionLib.Flags["Skill_" .. k]:SetValue(true)
        end
        Notify("All skills enabled")
    end
})

SkillMainSection:AddButton({
    Name = "❄️ ALL SKILLS OFF",
    Icon = "x",
    Outline = true,
    Callback = function()
        for _, k in ipairs({"Z","X","C","V","F"}) do
            getgenv().AutoSkills[k] = false
            OrionLib.Flags["Skill_" .. k]:SetValue(false)
        end
        Notify("All skills disabled")
    end
})

SkillMainSection:AddSlider({
    Name = "SKILL COOLDOWN (ms)",
    Min = 100,
    Max = 3000,
    Default = 500,
    Increment = 10,
    ValueName = "ms",
    Outline = true,
    Flag = "SkillCooldown",
    Save = true,
    Callback = function(Value)
        getgenv().SkillCooldown = Value / 1000
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
-- ITEM TAB
--==================================================
local ChestSection = ItemTab:AddSection({
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
    Callback = function(Value)
        getgenv().IsAutoChest = Value
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
        getgenv().IsAutoMerchant = Value
    end
})

MerchantSection:AddDropdown({
    Name = "ITEM TO BUY",
    Default = "HealthPotion",
    Options = {"HealthPotion", "StaminaPotion", "BoostScroll", "SummonStone", "BossKey"},
    Multi = false,
    Outline = true,
    Flag = "MerchantItem",
    Save = true,
    Callback = function(Value)
        getgenv().MerchantItem = Value
    end
})

--==================================================
-- SETTINGS TAB
--==================================================
local BypassSection = SettingsTab:AddSection({
    Name = "🔧 BYPASS SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BypassSection:AddToggle({
    Name = "NOCLIP",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        getgenv().NoclipEnabled = Value
    end
})

BypassSection:AddToggle({
    Name = "ANTI-VOID",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiVoid",
    Save = true,
    Callback = function(Value)
        getgenv().AntiVoid = Value
    end
})

BypassSection:AddToggle({
    Name = "ANTI-IDLE",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiIdle",
    Save = true,
    Callback = function(Value)
        getgenv().AntiIdle = Value
    end
})

BypassSection:AddButton({
    Name = "🗺️ SCAN ALL ISLANDS",
    Icon = "map",
    Outline = true,
    Callback = function()
        task.spawn(function()
            Notify("Scanning all islands... This may take a minute")
            getgenv().ScanAllIslands()
            Notify("Scan completed!")
        end)
    end
})

local PerformanceSection = SettingsTab:AddSection({
    Name = "⚡ PERFORMANCE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

PerformanceSection:AddToggle({
    Name = "FPS BOOST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        if Value then
            pcall(function()
                local toggles = {
                    {"MuteMusic", true}, {"MuteSFX", true},
                    {"DisableVFX", true}, {"DisableCutscene", true},
                    {"DisableOtherVFX", true}, {"RemoveTexture", true},
                    {"RemoveShadows", true},
                }
                for _, t in ipairs(toggles) do
                    settingsToggle:FireServer(t[1], t[2])
                end
                local settings = UserSettings():GetService("UserGameSettings")
                settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
                settings.GraphicsQualityLevel = 1
                sethiddenproperty(settings, "GraphicsOptimizationMode", 1)
            end)
        end
    end
})

local KeybindSection = SettingsTab:AddSection({
    Name = "⌨️ KEYBINDS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

KeybindSection:AddParagraph({
    Title = "F2",
    Desc = "Toggle Auto Farm",
    Image = "key",
    ImageSize = 32
})

KeybindSection:AddParagraph({
    Title = "B",
    Desc = "Toggle Boss Fight",
    Image = "key",
    ImageSize = 32
})

KeybindSection:AddParagraph({
    Title = "N",
    Desc = "Toggle Summon Boss",
    Image = "key",
    ImageSize = 32
})

KeybindSection:AddParagraph({
    Title = "M",
    Desc = "Toggle All Skills",
    Image = "key",
    ImageSize = 32
})

local DebugSection = SettingsTab:AddSection({
    Name = "📝 DEBUG",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DebugSection:AddButton({
    Name = "🗺️ PRINT QUEST DATA",
    Icon = "file-text",
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
    end
})

DebugSection:AddButton({
    Name = "👾 PRINT MOBS IN MAP",
    Icon = "users",
    Outline = true,
    Callback = function()
        local npcFolder = workspace:FindFirstChild("NPCs")
        if not npcFolder then 
            Notify("NPCs folder not found!")
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
    end
})

--==================================================
-- KEYBINDS
--==================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        getgenv().IsFarm = not getgenv().IsFarm
        Notify(getgenv().IsFarm and "Farm ON (F2)" or "Farm OFF (F2)")
        if OrionLib.Flags["AutoFarm"] then
            OrionLib.Flags["AutoFarm"]:SetValue(getgenv().IsFarm)
        end
    elseif input.KeyCode == Enum.KeyCode.B then
        getgenv().IsBossFight = not getgenv().IsBossFight
        Notify(getgenv().IsBossFight and "Boss Fight ON (B)" or "Boss Fight OFF (B)")
        if OrionLib.Flags["BossFight"] then
            OrionLib.Flags["BossFight"]:SetValue(getgenv().IsBossFight)
        end
    elseif input.KeyCode == Enum.KeyCode.N then
        getgenv().IsSummonBoss = not getgenv().IsSummonBoss
        Notify(getgenv().IsSummonBoss and "Summon Boss ON (N)" or "Summon Boss OFF (N)")
        if OrionLib.Flags["SummonBoss"] then
            OrionLib.Flags["SummonBoss"]:SetValue(getgenv().IsSummonBoss)
        end
    elseif input.KeyCode == Enum.KeyCode.M then
        local anyOn = false
        for _, v in pairs(getgenv().AutoSkills) do
            if v then anyOn = true break end
        end
        local newState = not anyOn
        for _, k in ipairs({"Z","X","C","V","F"}) do
            getgenv().AutoSkills[k] = newState
            if OrionLib.Flags["Skill_" .. k] then
                OrionLib.Flags["Skill_" .. k]:SetValue(newState)
            end
        end
        Notify(newState and "All Skills ON (M)" or "All Skills OFF (M)")
    end
end)

--==================================================
-- PRIORITY MAIN LOOP (v4)
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
            if doSummonBoss() then
                task.wait(getgenv().AttackCooldown)
                continue
            end
        end

        -- Priority 6: Boss Fight
        if getgenv().IsBossFight then
            if doBossFight() then
                task.wait(getgenv().AttackCooldown)
                continue
            end
        end

        -- Priority 7: Auto Farm
        if getgenv().IsFarm then
            local targetMobName = getgenv().SelectedMob
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
                pcall(function()
                    questRemote:FireServer(targetNPC)
                end)
            end

            local mob, dist = findMob(targetMobName)

            if mob then
                local mobH = mob:FindFirstChildOfClass("Humanoid")
                if mobH and mobH.Health > 0 then
                    tweenToMob(mob)
                    task.wait(0.2)

                    while getgenv().IsFarm and mob and mob.Parent and mob:FindFirstChild("HumanoidRootPart") do
                        local h = mob:FindFirstChildOfClass("Humanoid")
                        if not h or h.Health <= 0 then break end
                        tweenToMob(mob)
                        autoAttack(mob)
                        task.wait(getgenv().AttackCooldown)
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
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE v5 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm System v4 - Priority Loop")
print("✅ Teleport Bypass - Island Scanner")
print("✅ Boss System - Fight & Summon")
print("✅ Dungeon System - Auto Dungeon & Boss Rush")
print("✅ Quest Chains - Dungeon & Hogyoku")
print("✅ Auto Skills - Z,X,C,V,F")
print("✅ Auto Chest & Auto Merchant")
print("✅ Noclip, Anti-Void, Anti-Idle")
print("═══════════════════════════════════════════════════════")