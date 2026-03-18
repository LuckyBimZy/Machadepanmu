-- ==================== SAILOR PIECE - CATRAZ HUB EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Menggabungkan semua fitur: Auto Farm, Boss, Dungeon, Crafting, Bypass, dll
-- Version: 5.0 COMPLETE

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
-- SERVICES & VARIABLES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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
    Ambient = Lighting.Ambient,
}

--==================================================
-- CONFIGURATION
--==================================================
local Config = {
    -- Farm Settings
    AutoFarm = false,
    AutoHit = true,
    AutoStats = true,
    FpsBoost = false,
    
    -- Movement
    MoveMode = "Tween", -- "Tween" or "Teleport"
    FarmSpeed = 50,
    FarmHeight = 25,
    PlankMode = false,
    
    -- Combat
    AttackCooldown = 0.3,
    SkillCooldown = 0.5,
    AutoSkills = { Z = false, X = false, C = false, V = false, F = false },
    WeaponMode = "Melee", -- "Melee" or "Fruit"
    
    -- Target
    SelectedMob = nil,
    SelectedBoss = nil,
    SelectedSummonBoss = nil,
    SummonDifficulty = "Normal",
    
    -- Game Modes
    AutoBossFight = false,
    AutoSummonBoss = false,
    AutoDungeon = false,
    DungeonType = "Shadow",
    AutoBossRush = false,
    AutoDungeonQuest = false,
    AutoHogyokuQuest = false,
    
    -- Haki & Dark Blade
    AutoHaki = false,
    AutoObsHaki = false,
    AutoBuyDarkBlade = false,
    
    -- Fruit Farm
    FruitFarm = false,
    FruitMinLevel = 11500,
    TargetFruit = "Quake",
    FruitFarmIsland = "Shinjuku",
    FruitFarmPos = CFrame.new(321.706757, -1.539090, -1756.500977),
    
    -- Boss Key & Exchange
    AutoBuyBossKey = false,
    BossKeyBuyInterval = 1800,
    ExchangeIchigo = false,
    IchigoMinLevel = 11500,
    FarmSaberBoss = false,
    
    -- Crafting
    AutoCraftSlimeKey = false,
    AutoCraftDivineGrail = false,
    CraftAmount = 1,
    
    -- Misc
    AntiAFK = true,
    Noclip = false,
    AntiVoid = true,
    WhiteScreen = false,
    AutoRejoin = false,
    FriendOnly = false,
    
    -- Stats Distribution
    StatSword = 50,
    StatDefense = 30,
    StatPower = 20,
}

--==================================================
-- GLOBAL STATE
--==================================================
getgenv().IsFarm = false
getgenv().IsBossFight = false
getgenv().IsSummonBoss = false
getgenv().IsAutoDungeon = false
getgenv().IsBossRush = false
getgenv().IsDungeonQuest = false
getgenv().IsHogyokuQuest = false
getgenv().IsTeleporting = false
getgenv().IsFruitFarming = false
getgenv().IsBuyingDarkBlade = false
getgenv().IslandMobCache = getgenv().IslandMobCache or {}
getgenv().IslandScanDone = false

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
    Subtext = "Catraz Hub Edition v5.0",
    Version = "v5.0",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece Catraz Hub",
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
    Icon = "swords",
    Glass = true,
    Outline = true
})

local BossTab = Window:MakeTab({
    Name = "Boss",
    Icon = "skull",
    Glass = true,
    Outline = true
})

local ModeTab = Window:MakeTab({
    Name = "Modes",
    Icon = "gamepad-2",
    Glass = true,
    Outline = true
})

local SkillTab = Window:MakeTab({
    Name = "Skills",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local FruitTab = Window:MakeTab({
    Name = "Fruit",
    Icon = "apple",
    Glass = true,
    Outline = true
})

local CraftTab = Window:MakeTab({
    Name = "Crafting",
    Icon = "hammer",
    Glass = true,
    Outline = true
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- BYPASS SYSTEM (ANTI-TELEPORT, ANTI-KICK)
--==================================================
local function setupBypass()
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

    -- Hook __namecall
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- Block kick
        if (method == "Kick" or method == "kick") then
            if self == Player or self == Players then
                return nil
            end
        end

        -- Block anti-TP remotes
        if method == "FireServer" or method == "InvokeServer" then
            local ok, isRemote = pcall(function()
                return self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
            end)
            if ok and isRemote then
                local remoteName = self.Name:lower():gsub("_", ""):gsub("-", "")
                if blockedLookup[remoteName] then
                    return nil
                end
            end
        end

        return OldNamecall(self, ...)
    end)

    -- Hook getgc functions
    if getgc and hookfunction then
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" then
                local ok, info = pcall(getinfo, v)
                if ok and info and info.source then
                    local src = info.source:lower()
                    if src:find("anticheat") or src:find("controlclient") or src:find("sanity")
                        or src:find("idle") or src:find("movement") or src:find("speed") then
                        pcall(function()
                            hookfunction(v, function(...) return nil end)
                        end)
                    end
                end
            end
        end
    end

    print("[BYPASS] ✅ Anti-teleport & Anti-kick active")
end

--==================================================
-- NOCLIP SYSTEM
--==================================================
local noclipConnection = nil

local function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not Config.Noclip then return end
        
        local char = Player.Character
        if not char then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

--==================================================
-- ANTI-VOID SYSTEM
--==================================================
local lastSafePos = CFrame.new(0, 100, 0)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not Config.AntiVoid then continue end
        
        local char = Player.Character
        if not char then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        if hrp.Position.Y > -50 then
            lastSafePos = hrp.CFrame
        elseif hrp.Position.Y < -50 then
            hrp.CFrame = lastSafePos
        end
    end
end)

--==================================================
-- ANTI-AFK SYSTEM
--==================================================
local antiAFKConnection = nil

local function setupAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    
    if Config.AntiAFK then
        antiAFKConnection = Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

--==================================================
-- UTILITY FUNCTIONS
--==================================================
local function getChar()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    return char, hrp, hum
end

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function getWeapons()
    local weapons = {}
    local char = Player.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then table.insert(weapons, v.Name) end
        end
    end
    for _, v in ipairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") then table.insert(weapons, v.Name) end
    end
    return #weapons > 0 and weapons or { "None" }
end

--==================================================
-- TWEEN MOVEMENT SYSTEM
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

local function tweenToPosition(targetPos, callback)
    local char = Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    local distance = (targetPos - root.Position).Magnitude

    if Config.MoveMode == "Teleport" or distance <= CLOSE_RANGE then
        root.CFrame = CFrame.new(targetPos)
        if callback then callback() end
        return
    end

    getgenv().IsTeleporting = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    local steps = math.ceil(distance / STEP_SIZE)
    local startPos = root.Position

    for i = 1, steps do
        if not Config.AutoFarm and not Config.AutoBossFight and not Config.AutoDungeon then break end
        
        local nextPos
        if i == steps then
            nextPos = targetPos
        else
            local progress = i / steps
            nextPos = startPos:Lerp(targetPos, progress)
        end

        root.Velocity = (nextPos - root.Position).Unit * Config.FarmSpeed
        microTween(root, CFrame.new(nextPos))
        task.wait(STEP_DELAY)
    end

    root.Velocity = Vector3.zero
    getgenv().IsTeleporting = false
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    
    if callback then callback() end
end

local function tweenToMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    
    local offset = Config.PlankMode and Vector3.new(0, Config.FarmHeight, 0) or Vector3.new(0, 0, 5)
    local targetPos = mob.HumanoidRootPart.Position + offset
    tweenToPosition(targetPos)
end

--==================================================
-- WEAPON SYSTEM
--==================================================
local function equipWeapon()
    local char = Player.Character
    if not char then return nil end
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return nil end

    local mode = Config.WeaponMode

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
                    if n:find("fruit") or n:find("devil") or n:find("power") then
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

--==================================================
-- COMBAT SYSTEM
--==================================================
local function autoAttack(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end

    local tool = equipWeapon()
    if tool then
        pcall(function() tool:Activate() end)
    end

    pcall(function() hitRemote:FireServer() end)

    -- Individual skills
    local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
    for key, slot in pairs(skillMap) do
        if Config.AutoSkills[key] then
            pcall(function() AbilityRemote:FireServer(slot) end)
        end
    end
end

--==================================================
-- HAKI SYSTEM
--==================================================
local function toggleHaki()
    pcall(function() hakiRemote:FireServer("Toggle") end)
end

local function toggleObsHaki()
    pcall(function() obsHakiRemote:FireServer("Toggle") end)
end

--==================================================
-- STATS SYSTEM
--==================================================
local function allocateStats()
    local points = 0
    pcall(function() points = Player.Data.StatPoints.Value or 0 end)
    if points <= 0 then return end

    local level = 0
    pcall(function() level = Player.Data.Level.Value or 0 end)

    if level < 3000 then
        -- Low level: Melee focus
        local melee, defense = 0, 0
        while points > 0 do
            local m = math.min(2, points)
            if m > 0 then statRemote:FireServer("Melee", m); points = points - m; melee = melee + m end
            task.wait(0.1)
            if points <= 0 then break end
            local d = math.min(1, points)
            if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d end
            task.wait(0.1)
        end
    else
        -- High level: Sword/Defense/Power
        local sword, defense, power = 0, 0, 0
        while points > 0 do
            local s = math.min(3, points)
            if s > 0 then statRemote:FireServer("Sword", s); points = points - s; sword = sword + s end
            task.wait(0.1)
            if points <= 0 then break end
            local d = math.min(2, points)
            if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d end
            task.wait(0.1)
            if points <= 0 then break end
            local p = math.min(1, points)
            if p > 0 then statRemote:FireServer("Power", p); points = points - p; power = power + p end
            task.wait(0.1)
        end
    end
end

--==================================================
-- QUEST SYSTEM
--==================================================
local questcheck = require(ReplicatedStorage.Modules.QuestConfig)

local function getTargetQuest()
    local level = Player.Data.Level.Value
    local bestNPC = nil
    local maxLevel = -1
    local targetMob = nil

    for npcName, data in pairs(questcheck.RepeatableQuests) do
        local req = tonumber(data.recommendedLevel) or 0
        if level >= req and req > maxLevel then
            maxLevel = req
            bestNPC = npcName
            if data.requirements and data.requirements[1] then
                targetMob = data.requirements[1].npcType
            end
        end
    end

    return bestNPC, maxLevel, targetMob
end

local function findMob(targetName)
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil, math.huge end

    local closest = nil
    local closestDist = math.huge
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil, math.huge end
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

--==================================================
-- ISLAND SCANNER SYSTEM (TELEPORT BYPASS)
--==================================================
local function getAllIslands()
    local islands = {}
    
    -- Try TravelConfig
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
    
    -- Hardcoded fallback
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
    
    return found
end

getgenv().TeleportToMobIsland = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    if not cached then return false end
    
    local portalArg = cached.island:gsub("Island", ""):gsub(" ", "")
    pcall(function() tpRemote:FireServer(portalArg) end)
    task.wait(3)
    return true
end

getgenv().GetIslandForMob = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    return cached and cached.island or nil
end

getgenv().ScanAllIslands = function()
    local islands = getAllIslands()
    
    for i, island in ipairs(islands) do
        pcall(function() tpRemote:FireServer(island.portal) end)
        task.wait(4)
        scanCurrentIslandNPCs(island.name)
        task.wait(1)
    end
    
    getgenv().IslandScanDone = true
    Notify("Island scan completed!")
end

--==================================================
-- BOSS SYSTEM
--==================================================
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

local function summonBoss()
    pcall(function()
        local summonRemote = RemoteEvents:FindFirstChild("SummonBoss") or RemoteEvents:FindFirstChild("BossSummon")
        if summonRemote then
            summonRemote:FireServer(Config.SelectedSummonBoss or "Boss1", Config.SummonDifficulty)
        end
    end)
    task.wait(2)
end

--==================================================
-- DUNGEON SYSTEM
--==================================================
local function enterDungeon()
    pcall(function()
        local dungeonRemote = RemoteEvents:FindFirstChild("Dungeon") or RemoteEvents:FindFirstChild("DungeonEnter")
        if dungeonRemote then
            dungeonRemote:FireServer("Enter", Config.DungeonType)
        end
    end)
    task.wait(3)
end

local function enterBossRush()
    pcall(function()
        local rushRemote = RemoteEvents:FindFirstChild("BossRush") or RemoteEvents:FindFirstChild("EnterBossRush")
        if rushRemote then
            rushRemote:FireServer("Enter")
        end
    end)
    task.wait(2)
end

--==================================================
-- DARK BLADE SYSTEM
--==================================================
local function findDarkBlade()
    for _, container in pairs({Player.Character, Player.Backpack}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:find("Dark Blade") or tool.Name:find("ดาบสีเข้ม")) then
                    return tool
                end
            end
        end
    end
    return nil
end

local function buyDarkBlade()
    if findDarkBlade() then
        Notify("Already have Dark Blade!")
        return true
    end

    local npcCF = CFrame.new(-132.516449, 13.2661686, -1091.2699)
    tweenToPosition(npcCF.Position)
    task.wait(2)

    pcall(function()
        local npc = Workspace.ServiceNPCs.DarkBladeNPC
        if npc then
            local prompt = npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart:FindFirstChild("DarkBladeShopPrompt")
            if prompt then
                fireproximityprompt(prompt)
                task.wait(3)
            end
        end
    end)

    return findDarkBlade() ~= nil
end

--==================================================
-- FRUIT SYSTEM
--==================================================
local function checkHasFruit(fruitName)
    local char = Player.Character
    local backpack = Player:FindFirstChild("Backpack")
    
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                return true
            end
        end
    end
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                return true
            end
        end
    end
    
    return false
end

local function equipFruit(fruitName)
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:EquipTool(tool)
                    return true
                end
            end
        end
    end
    return false
end

--==================================================
-- CRAFTING SYSTEM
--==================================================
local function craftSlimeKey(amount)
    pcall(function()
        local args = { "SlimeKey", amount }
        Remotes:WaitForChild("RequestSlimeCraft"):InvokeServer(unpack(args))
    end)
end

local function craftDivineGrail(amount)
    pcall(function()
        local args = { "DivineGrail", amount }
        Remotes:WaitForChild("RequestGrailCraft"):InvokeServer(unpack(args))
    end)
end

--==================================================
-- AUTO CRAFT LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(5)
        if Config.AutoCraftSlimeKey then
            craftSlimeKey(Config.CraftAmount)
        end
        if Config.AutoCraftDivineGrail then
            craftDivineGrail(Config.CraftAmount)
        end
    end
end)

--==================================================
-- AUTO STATS LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(5)
        if Config.AutoStats then
            pcall(allocateStats)
        end
    end
end)

--==================================================
-- AUTO HAKI LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(3)
        if Config.AutoHaki then
            pcall(toggleHaki)
        end
        if Config.AutoObsHaki then
            pcall(toggleObsHaki)
        end
    end
end)

--==================================================
-- FPS BOOST
--==================================================
local function setFpsBoost(state)
    if state then
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 1
            end
        end
    else
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

--==================================================
-- WHITE SCREEN
--==================================================
local function setWhiteScreen(state)
    RunService:Set3dRenderingEnabled(not state)
end

--==================================================
-- FARM TAB UI
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
        Config.AutoFarm = Value
        getgenv().IsFarm = Value
        Notify(Value and "Auto Farm Enabled" or "Auto Farm Disabled")
    end
})

FarmMainSection:AddToggle({
    Name = "AUTO HIT",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHit",
    Save = true,
    Callback = function(Value) Config.AutoHit = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO STATS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoStats",
    Save = true,
    Callback = function(Value) Config.AutoStats = Value end
})

FarmMainSection:AddToggle({
    Name = "PLANK MODE (HOVER)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(Value) Config.PlankMode = Value end
})

FarmMainSection:AddDropdown({
    Name = "MOVE MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value) Config.MoveMode = Value end
})

FarmMainSection:AddSlider({
    Name = "FARM HEIGHT",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Callback = function(Value) Config.FarmHeight = Value end
})

FarmMainSection:AddSlider({
    Name = "FARM SPEED",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    ValueName = "speed",
    Outline = true,
    Callback = function(Value) Config.FarmSpeed = Value end
})

FarmMainSection:AddSlider({
    Name = "ATTACK COOLDOWN",
    Min = 0.1,
    Max = 1.0,
    Default = 0.3,
    Increment = 0.05,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value) Config.AttackCooldown = Value end
})

--==================================================
-- BOSS TAB UI
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
    Flag = "AutoBoss",
    Save = true,
    Callback = function(Value)
        Config.AutoBossFight = Value
        getgenv().IsBossFight = Value
        Notify(Value and "Auto Boss Enabled" or "Auto Boss Disabled")
    end
})

BossMainSection:AddDropdown({
    Name = "SELECT BOSS",
    Default = "Boss1",
    Options = {"Boss1", "Boss2", "Boss3", "WorldBoss", "SaberBoss", "Ichigo"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.SelectedBoss = Value end
})

BossMainSection:AddSection({
    Name = "🔮 SUMMON BOSS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "AUTO SUMMON BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoSummon",
    Save = true,
    Callback = function(Value)
        Config.AutoSummonBoss = Value
        getgenv().IsSummonBoss = Value
    end
})

BossMainSection:AddDropdown({
    Name = "SUMMON BOSS",
    Default = "Boss1",
    Options = {"Boss1", "Boss2", "Boss3", "SaberBoss"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.SelectedSummonBoss = Value end
})

BossMainSection:AddDropdown({
    Name = "DIFFICULTY",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Nightmare"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value) Config.SummonDifficulty = Value end
})

--==================================================
-- MODES TAB UI
--==================================================
local ModeMainSection = ModeTab:AddSection({
    Name = "🏰 DUNGEONS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        Config.AutoDungeon = Value
        getgenv().IsAutoDungeon = Value
    end
})

ModeMainSection:AddDropdown({
    Name = "DUNGEON TYPE",
    Default = "Shadow",
    Options = {"Shadow", "Rune", "Cid"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value) Config.DungeonType = Value end
})

ModeMainSection:AddToggle({
    Name = "AUTO BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBossRush",
    Save = true,
    Callback = function(Value)
        Config.AutoBossRush = Value
        getgenv().IsBossRush = Value
    end
})

ModeMainSection:AddSection({
    Name = "🔮 QUEST CHAINS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "DUNGEON QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(Value)
        Config.AutoDungeonQuest = Value
        getgenv().IsDungeonQuest = Value
    end
})

ModeMainSection:AddToggle({
    Name = "HOGYOKU QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(Value)
        Config.AutoHogyokuQuest = Value
        getgenv().IsHogyokuQuest = Value
    end
})

--==================================================
-- SKILLS TAB UI
--==================================================
local SkillMainSection = SkillTab:AddSection({
    Name = "🔮 AUTO SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

for _, key in ipairs({"Z", "X", "C", "V", "F"}) do
    SkillMainSection:AddToggle({
        Name = "SKILL " .. key,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Skill" .. key,
        Save = true,
        Callback = function(Value) Config.AutoSkills[key] = Value end
    })
end

SkillMainSection:AddSlider({
    Name = "SKILL COOLDOWN",
    Min = 0.1,
    Max = 3.0,
    Default = 0.5,
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value) Config.SkillCooldown = Value end
})

SkillMainSection:AddDropdown({
    Name = "WEAPON MODE",
    Default = "Melee",
    Options = {"Melee", "Fruit"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value) Config.WeaponMode = Value end
})

SkillMainSection:AddButton({
    Name = "REFRESH WEAPON LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        Notify("Weapon list refreshed")
    end
})

SkillMainSection:AddSection({
    Name = "⬛ HAKI",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SkillMainSection:AddToggle({
    Name = "AUTO ARMAMENT HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(Value) Config.AutoHaki = Value end
})

SkillMainSection:AddToggle({
    Name = "AUTO OBSERVATION HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoObsHaki",
    Save = true,
    Callback = function(Value) Config.AutoObsHaki = Value end
})

--==================================================
-- FRUIT TAB UI
--==================================================
local FruitMainSection = FruitTab:AddSection({
    Name = "🍎 FRUIT FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FruitMainSection:AddToggle({
    Name = "ENABLE FRUIT FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FruitFarm",
    Save = true,
    Callback = function(Value)
        Config.FruitFarm = Value
        getgenv().IsFruitFarming = Value
    end
})

FruitMainSection:AddSlider({
    Name = "MIN LEVEL",
    Min = 1000,
    Max = 15000,
    Default = 11500,
    Increment = 100,
    ValueName = "lvl",
    Outline = true,
    Callback = function(Value) Config.FruitMinLevel = Value end
})

FruitMainSection:AddDropdown({
    Name = "TARGET FRUIT",
    Default = "Quake",
    Options = {"Quake", "Flame", "Ice", "Gravity", "Light", "Dark", "String", "Rumble"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value) Config.TargetFruit = Value end
})

FruitMainSection:AddButton({
    Name = "BUY DARK BLADE",
    Icon = "sword",
    Outline = true,
    Callback = function()
        getgenv().IsBuyingDarkBlade = true
        buyDarkBlade()
        getgenv().IsBuyingDarkBlade = false
    end
})

--==================================================
-- CRAFTING TAB UI
--==================================================
local CraftMainSection = CraftTab:AddSection({
    Name = "🔨 CRAFTING",
    TextSize = 18,
    Glass = true,
    Outline = true
})

CraftMainSection:AddInput({
    Name = "CRAFT AMOUNT",
    Default = "1",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            Config.CraftAmount = num
        end
    end
})

CraftMainSection:AddToggle({
    Name = "AUTO CRAFT SLIME KEY",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoSlimeKey",
    Save = true,
    Callback = function(Value) Config.AutoCraftSlimeKey = Value end
})

CraftMainSection:AddToggle({
    Name = "AUTO CRAFT DIVINE GRAIL",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoGrail",
    Save = true,
    Callback = function(Value) Config.AutoCraftDivineGrail = Value end
})

CraftMainSection:AddButton({
    Name = "CRAFT SLIME KEY NOW",
    Icon = "hammer",
    Outline = true,
    Callback = function()
        craftSlimeKey(Config.CraftAmount)
        Notify("Crafting " .. Config.CraftAmount .. " Slime Key(s)")
    end
})

CraftMainSection:AddButton({
    Name = "CRAFT DIVINE GRAIL NOW",
    Icon = "hammer",
    Outline = true,
    Callback = function()
        craftDivineGrail(Config.CraftAmount)
        Notify("Crafting " .. Config.CraftAmount .. " Divine Grail(s)")
    end
})

--==================================================
-- MISC TAB UI
--==================================================
local MiscMainSection = MiscTab:AddSection({
    Name = "⚙️ UTILITY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddToggle({
    Name = "ANTI AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.AntiAFK = Value
        setupAntiAFK()
    end
})

MiscMainSection:AddToggle({
    Name = "NOCLIP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        Config.Noclip = Value
        if Value then
            enableNoclip()
        else
            disableNoclip()
        end
    end
})

MiscMainSection:AddToggle({
    Name = "ANTI VOID",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiVoid",
    Save = true,
    Callback = function(Value) Config.AntiVoid = Value end
})

MiscMainSection:AddToggle({
    Name = "FPS BOOST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        Config.FpsBoost = Value
        setFpsBoost(Value)
    end
})

MiscMainSection:AddToggle({
    Name = "WHITE SCREEN MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "WhiteScreen",
    Save = true,
    Callback = function(Value)
        Config.WhiteScreen = Value
        setWhiteScreen(Value)
    end
})

MiscMainSection:AddSection({
    Name = "🗺️ ISLAND SCANNER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddButton({
    Name = "SCAN ALL ISLANDS",
    Icon = "map",
    Outline = true,
    Callback = function()
        task.spawn(function()
            Notify("Scanning islands...")
            getgenv().ScanAllIslands()
        end)
    end
})

MiscMainSection:AddButton({
    Name = "PRINT CACHED MOBS",
    Icon = "list",
    Outline = true,
    Callback = function()
        print("\n=== CACHED MOBS ===")
        for mobName, data in pairs(getgenv().IslandMobCache) do
            print(string.format("  %s → %s", mobName, data.island))
        end
        print("===================\n")
    end
})

MiscMainSection:AddSection({
    Name = "⚡ BOSS KEY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscMainSection:AddToggle({
    Name = "AUTO BUY BOSS KEY",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBossKey",
    Save = true,
    Callback = function(Value) Config.AutoBuyBossKey = Value end
})

MiscMainSection:AddToggle({
    Name = "EXCHANGE ICHIGO",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ExchangeIchigo",
    Save = true,
    Callback = function(Value) Config.ExchangeIchigo = Value end
})

MiscMainSection:AddToggle({
    Name = "FARM SABER BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FarmSaber",
    Save = true,
    Callback = function(Value) Config.FarmSaberBoss = Value end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

--==================================================
-- INITIALIZE BYPASS
--==================================================
setupBypass()
setupAntiAFK()

--==================================================
-- MAIN FARM LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(Config.AttackCooldown)
        
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

        -- Priority: Dungeon Quest
        if getgenv().IsDungeonQuest then
            enterDungeon()
            task.wait(Config.AttackCooldown)
            continue
        end

        -- Priority: Hogyoku Quest
        if getgenv().IsHogyokuQuest then
            local boss = findBoss("Boss")
            if boss then
                tweenToMob(boss)
                autoAttack(boss)
            end
            task.wait(Config.AttackCooldown)
            continue
        end

        -- Priority: Auto Dungeon
        if getgenv().IsAutoDungeon then
            enterDungeon()
            task.wait(Config.AttackCooldown)
            continue
        end

        -- Priority: Boss Rush
        if getgenv().IsBossRush then
            enterBossRush()
            task.wait(Config.AttackCooldown)
            continue
        end

        -- Priority: Summon Boss
        if getgenv().IsSummonBoss then
            summonBoss()
            task.wait(2)
            continue
        end

        -- Priority: Boss Fight
        if getgenv().IsBossFight and Config.SelectedBoss then
            local boss = findBoss(Config.SelectedBoss)
            if boss then
                tweenToMob(boss)
                autoAttack(boss)
            end
            task.wait(Config.AttackCooldown)
            continue
        end

        -- Default: Auto Farm
        if getgenv().IsFarm then
            local _, _, targetMob = getTargetQuest()
            local mob, dist = findMob(targetMob or Config.SelectedMob)

            if mob then
                tweenToMob(mob)
                autoAttack(mob)
            else
                -- Try teleport to mob's island
                if targetMob and getgenv().TeleportToMobIsland then
                    getgenv().TeleportToMobIsland(targetMob)
                end
                task.wait(1)
            end
        end
    end
end)

--==================================================
-- AUTO BUY BOSS KEY LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(Config.BossKeyBuyInterval)
        if Config.AutoBuyBossKey then
            pcall(function()
                local merchantCF = CFrame.new(368.817719, 2.79983521, 783.589844)
                tweenToPosition(merchantCF.Position)
                task.wait(2)
                Remotes.MerchantRemotes.PurchaseMerchantItem:InvokeServer("Boss Key", 1)
            end)
        end
    end
end)

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    task.wait(3)
    if Config.Noclip then
        enableNoclip()
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

-- Start island scan after UI loads
task.spawn(function()
    task.wait(5)
    task.spawn(function() getgenv().ScanAllIslands() end)
end)

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ HUB EDITION v5.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm - Quest-based farming")
print("✅ Auto Boss - Fight & Summon bosses")
print("✅ Auto Dungeon - Shadow/Rune/Cid dungeons")
print("✅ Auto Skills - Z, X, C, V, F with cooldown")
print("✅ Auto Haki - Armament & Observation")
print("✅ Fruit Farm - Target fruit farming")
print("✅ Crafting - Slime Key & Divine Grail")
print("✅ Bypass - Anti-TP, Anti-Kick, Anti-Void")
print("✅ Island Scanner - Cache all mob locations")
print("═══════════════════════════════════════════════════════")