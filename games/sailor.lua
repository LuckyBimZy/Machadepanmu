-- ==================== SAILOR PIECE HUB - CATRAZ EDITION ====================
-- Full Edition dengan UI Catraz Hub
-- Adapted from jachvn112-droid
-- Version: v4.0 Catraz

if _G.SP_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Sailor Piece Hub",
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
local TweenService = game:GetService("TweenService")
local RepStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local Mouse = player:GetMouse()

-- Cek apakah questcheck dan checkmap tersedia
local questcheck = pcall(function() return require(RepStorage:FindFirstChild("Modules") and RepStorage.Modules:FindFirstChild("QuestConfig")) end) and require(RepStorage.Modules.QuestConfig) or {}
local checkmap = pcall(function() return require(RepStorage:FindFirstChild("TravelConfig")) end) and require(RepStorage.TravelConfig) or {}

--==================================================
-- FARM STATE
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

-- Skill State
getgenv().SelectedSkill = 0
getgenv().AutoSkills = { Z = false, X = false, C = false, V = false, F = false }
getgenv().SkillCooldown = 0.5

-- Boss State
getgenv().IsBossFight = false
getgenv().SelectedBoss = nil
getgenv().IsSummonBoss = false
getgenv().SummonDifficulty = "Normal"

-- Dungeon / Gamemode State
getgenv().IsAutoDungeon = false
getgenv().DungeonType = "Shadow"
getgenv().IsBossRush = false

-- Quest Chain State
getgenv().IsDungeonQuest = false
getgenv().IsHogyokuQuest = false

-- Item State
getgenv().IsAutoChest = false
getgenv().IsAutoMerchant = false
getgenv().MerchantItem = nil

-- Misc State
getgenv().IsNoclip = false
getgenv()._antiAFK = true

--==================================================
-- NOTIFICATION FUNCTION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Sailor Piece Hub",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece Hub",
    Subtext = "Full Edition v4.0",
    Version = "v4.0",
    VersionIcon = "anchor",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece Hub",
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
    Icon = "zap",
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
    Icon = "gamepad",
    Glass = true,
    Outline = true
})

local SkillTab = Window:MakeTab({
    Name = "Skills",
    Icon = "zap-off",
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
-- MOB DATABASE
--==================================================
local MobDatabase = {}

local function buildMobDatabase()
    table.clear(MobDatabase)

    local npcLevelMap = {}
    if questcheck and questcheck.RepeatableQuests then
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
                    if checkmap and checkmap.GetZoneAt then
                        pcall(function()
                            local zoneId, _ = checkmap.GetZoneAt(npc.HumanoidRootPart.Position)
                            if zoneId then island = zoneId end
                        end)
                    end

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
-- BOSS LIST
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

--==================================================
-- DUNGEON TYPES
--==================================================
local DungeonTypes = {"Shadow", "Rune", "Cid"}

--==================================================
-- FIND FUNCTIONS
--==================================================
local function findMob(targetName)
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end

    local closest = nil
    local closestDist = math.huge
    local char = player.Character
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

--==================================================
-- TWEEN FUNCTIONS
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

local function tweenToMob(mob)
    local char = player.Character
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
-- WEAPON & ATTACK SYSTEM
--==================================================
local function equipWeapon()
    local char = player.Character
    if not char then return nil end
    local backpack = player:FindFirstChild("Backpack")
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
        local combatRemote = RepStorage:FindFirstChild("CombatSystem") and RepStorage.CombatSystem:FindFirstChild("Remotes") and RepStorage.CombatSystem.Remotes:FindFirstChild("RequestHit")
        if combatRemote then
            combatRemote:FireServer()
        end
    end)

    -- Skill spam
    local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
    for key, slot in pairs(skillMap) do
        if getgenv().AutoSkills[key] then
            pcall(function()
                local abilityRemote = RepStorage:FindFirstChild("AbilitySystem") and RepStorage.AbilitySystem:FindFirstChild("Remotes") and RepStorage.AbilitySystem.Remotes:FindFirstChild("RequestAbility")
                if abilityRemote then
                    abilityRemote:FireServer(slot)
                end
            end)
        end
    end
end

--==================================================
-- SKILL SPAM LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(getgenv().SkillCooldown)
        if getgenv().IsFarm or getgenv().IsBossFight or getgenv().IsAutoDungeon or getgenv().IsBossRush then
            local char = player.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local skillMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
                for key, slot in pairs(skillMap) do
                    if getgenv().AutoSkills[key] then
                        pcall(function()
                            local abilityRemote = RepStorage:FindFirstChild("AbilitySystem") and RepStorage.AbilitySystem:FindFirstChild("Remotes") and RepStorage.AbilitySystem.Remotes:FindFirstChild("RequestAbility")
                            if abilityRemote then
                                abilityRemote:FireServer(slot)
                            end
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
            local char = player.Character
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
-- ANTI AFK
--==================================================
task.spawn(function()
    while getgenv()._antiAFK do
        task.wait(60)
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

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
                    local chestR = RepStorage:FindFirstChild("RemoteEvents") and RepStorage.RemoteEvents:FindFirstChild("Chest") or RepStorage.RemoteEvents:FindFirstChild("OpenChest")
                    if chestR then
                        chestR:FireServer("Open", chestType)
                    end
                end)
            end
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
                local merchantR = RepStorage:FindFirstChild("RemoteEvents") and RepStorage.RemoteEvents:FindFirstChild("Merchant") or RepStorage.RemoteEvents:FindFirstChild("Shop") or RepStorage.RemoteEvents:FindFirstChild("Buy")
                if merchantR then
                    merchantR:FireServer("Buy", getgenv().MerchantItem)
                end
            end)
        end
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
    Callback = function(Value)
        getgenv().IsFarm = Value
        Notify(Value and "Auto Farm ON" or "Auto Farm OFF")
    end
})

FarmSection:AddToggle({
    Name = "🛹 Plank Mode (hover)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(Value)
        getgenv().PlankMode = Value
    end
})

FarmSection:AddDropdown({
    Name = "Move Mode",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        getgenv().MoveMode = Value
    end
})

FarmSection:AddSlider({
    Name = "Farm Height (Plank)",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Callback = function(Value)
        getgenv().FarmHeight = Value
    end
})

FarmSection:AddSlider({
    Name = "Farm Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "speed",
    Outline = true,
    Callback = function(Value)
        getgenv().FarmSpeed = Value
    end
})

FarmSection:AddSlider({
    Name = "Attack Cooldown (ms)",
    Min = 100,
    Max = 1000,
    Default = 300,
    Increment = 10,
    ValueName = "ms",
    Outline = true,
    Callback = function(Value)
        getgenv().AttackCooldown = Value / 1000
    end
})

local TargetSection = FarmTab:AddSection({
    Name = "🎯 TARGET",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Build mob database
buildMobDatabase()
local mobNames = {"Auto (theo Level)"}
for _, mob in ipairs(MobDatabase) do
    table.insert(mobNames, string.format("[Lv.%d] %s", mob.level, mob.name))
end

TargetSection:AddDropdown({
    Name = "Pilih Quái",
    Default = "Auto (theo Level)",
    Options = mobNames,
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        if Value == "Auto (theo Level)" then
            getgenv().SelectedMob = nil
        else
            getgenv().SelectedMob = Value:match("%] (.+)$")
        end
    end
})

TargetSection:AddButton({
    Name = "🔄 Refresh Mob List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildMobDatabase()
        Notify("Mob list refreshed!")
    end
})

--==================================================
-- BOSS TAB
--==================================================
local BossSection = BossTab:AddSection({
    Name = "🐉 WORLD BOSS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossSection:AddToggle({
    Name = "Auto Boss Fight",
    Default = false,
    Color = Color3.fromRGB(255, 0, 0),
    Outline = true,
    Flag = "AutoBoss",
    Save = true,
    Callback = function(Value)
        getgenv().IsBossFight = Value
        Notify(Value and "Boss Fight ON" or "Boss Fight OFF")
    end
})

buildBossList()
BossSection:AddDropdown({
    Name = "Pilih Boss",
    Default = BossList[1] or "Boss1",
    Options = BossList,
    Multi = false,
    Search = true,
    Outline = true,
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
    Name = "Auto Summon Boss",
    Default = false,
    Color = Color3.fromRGB(255, 165, 0),
    Outline = true,
    Flag = "AutoSummon",
    Save = true,
    Callback = function(Value)
        getgenv().IsSummonBoss = Value
        Notify(Value and "Summon Boss ON" or "Summon Boss OFF")
    end
})

SummonSection:AddDropdown({
    Name = "Difficulty",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Nightmare"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        getgenv().SummonDifficulty = Value
    end
})

SummonSection:AddButton({
    Name = "🔄 Refresh Boss List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        buildBossList()
        Notify("Boss list refreshed!")
    end
})

--==================================================
-- MODES TAB
--==================================================
local DungeonSection = ModeTab:AddSection({
    Name = "🏰 DUNGEONS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DungeonSection:AddToggle({
    Name = "Auto Dungeon",
    Default = false,
    Color = Color3.fromRGB(75, 0, 130),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        getgenv().IsAutoDungeon = Value
        Notify(Value and "Auto Dungeon ON" or "Auto Dungeon OFF")
    end
})

DungeonSection:AddDropdown({
    Name = "Dungeon Type",
    Default = "Shadow",
    Options = DungeonTypes,
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        getgenv().DungeonType = Value
    end
})

local RushSection = ModeTab:AddSection({
    Name = "⚡ BOSS RUSH",
    TextSize = 18,
    Glass = true,
    Outline = true
})

RushSection:AddToggle({
    Name = "Auto Boss Rush",
    Default = false,
    Color = Color3.fromRGB(255, 215, 0),
    Outline = true,
    Flag = "AutoBossRush",
    Save = true,
    Callback = function(Value)
        getgenv().IsBossRush = Value
        Notify(Value and "Boss Rush ON" or "Boss Rush OFF")
    end
})

local QuestSection = ModeTab:AddSection({
    Name = "🔮 QUEST CHAINS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

QuestSection:AddToggle({
    Name = "Dungeon Quest (6 pieces)",
    Default = false,
    Color = Color3.fromRGB(0, 100, 0),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(Value)
        getgenv().IsDungeonQuest = Value
        Notify(Value and "Dungeon Quest ON" or "Dungeon Quest OFF")
    end
})

QuestSection:AddToggle({
    Name = "Hogyoku Quest (5 fragments)",
    Default = false,
    Color = Color3.fromRGB(148, 0, 211),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(Value)
        getgenv().IsHogyokuQuest = Value
        Notify(Value and "Hogyoku Quest ON" or "Hogyoku Quest OFF")
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

for _, key in ipairs({"Z", "X", "C", "V", "F"}) do
    local slotNum = ({ Z=1, X=2, C=3, V=4, F=5 })[key]
    SkillMainSection:AddToggle({
        Name = string.format("[%s] Skill %d", key, slotNum),
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Skill" .. key,
        Save = true,
        Callback = function(Value)
            getgenv().AutoSkills[key] = Value
        end
    })
end

SkillMainSection:AddToggle({
    Name = "🔥 ALL Skills ON/OFF",
    Default = false,
    Color = Color3.fromRGB(255, 0, 0),
    Outline = true,
    Flag = "AllSkills",
    Save = true,
    Callback = function(Value)
        for _, k in ipairs({"Z","X","C","V","F"}) do
            getgenv().AutoSkills[k] = Value
        end
    end
})

SkillMainSection:AddSlider({
    Name = "Skill Cooldown (ms)",
    Min = 100,
    Max = 3000,
    Default = 500,
    Increment = 10,
    ValueName = "ms",
    Outline = true,
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
    Name = "⬛ Auto Haki",
    Default = false,
    Color = Color3.fromRGB(0, 0, 0),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(Value)
        if Value then
            pcall(function()
                local hakiRemote = RepStorage:FindFirstChild("RemoteEvents") and RepStorage.RemoteEvents:FindFirstChild("HakiRemote")
                if hakiRemote then
                    hakiRemote:FireServer("Toggle")
                end
            end)
        end
    end
})

HakiSection:AddToggle({
    Name = "👁️ Observation Haki",
    Default = false,
    Color = Color3.fromRGB(255, 255, 0),
    Outline = true,
    Flag = "ObsHaki",
    Save = true,
    Callback = function(Value)
        if Value then
            pcall(function()
                local obsRemote = RepStorage:FindFirstChild("RemoteEvents") and RepStorage.RemoteEvents:FindFirstChild("ObservationHakiRemote")
                if obsRemote then
                    obsRemote:FireServer("Toggle")
                end
            end)
        end
    end
})

--==================================================
-- ITEMS TAB
--==================================================
local ChestSection = ItemTab:AddSection({
    Name = "📦 AUTO CHEST",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ChestSection:AddToggle({
    Name = "Auto Open Chests",
    Default = false,
    Color = Color3.fromRGB(255, 215, 0),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(Value)
        getgenv().IsAutoChest = Value
        Notify(Value and "Auto Chest ON" or "Auto Chest OFF")
    end
})

local MerchantSection = ItemTab:AddSection({
    Name = "🛒 AUTO MERCHANT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MerchantSection:AddToggle({
    Name = "Auto Buy from Merchant",
    Default = false,
    Color = Color3.fromRGB(0, 255, 0),
    Outline = true,
    Flag = "AutoMerchant",
    Save = true,
    Callback = function(Value)
        getgenv().IsAutoMerchant = Value
        Notify(Value and "Auto Merchant ON" or "Auto Merchant OFF")
    end
})

MerchantSection:AddDropdown({
    Name = "Item to Buy",
    Default = "HealthPotion",
    Options = {"HealthPotion", "StaminaPotion", "BoostScroll", "SummonStone"},
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        getgenv().MerchantItem = Value
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
    Name = "Weapon Mode",
    Default = "Melee",
    Options = {"Melee", "Fruit"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        getgenv().WeaponMode = Value
    end
})

local UtilitySection = SettingsTab:AddSection({
    Name = "🔧 UTILITY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

UtilitySection:AddToggle({
    Name = "👻 Noclip",
    Default = false,
    Color = Color3.fromRGB(255, 255, 255),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        getgenv().IsNoclip = Value
        Notify(Value and "Noclip ON" or "Noclip OFF")
    end
})

UtilitySection:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Color = Color3.fromRGB(0, 255, 0),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        getgenv()._antiAFK = Value
    end
})

UtilitySection:AddToggle({
    Name = "Make Game Smoother",
    Default = false,
    Color = Color3.fromRGB(0, 255, 255),
    Outline = true,
    Flag = "Smoother",
    Save = true,
    Callback = function(Value)
        if Value then
            pcall(function()
                local settings = UserSettings():GetService("UserGameSettings")
                settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
                settings.GraphicsQualityLevel = 1
                pcall(function() sethiddenproperty(settings, "GraphicsOptimizationMode", 1) end)
            end)
        end
    end
})

local DebugSection = SettingsTab:AddSection({
    Name = "🐛 DEBUG",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DebugSection:AddButton({
    Name = "🗺️ Print Quest Data",
    Outline = true,
    Callback = function()
        print("\n═══ QUEST CONFIG DUMP ═══")
        if questcheck and questcheck.RepeatableQuests then
            for npcName, data in pairs(questcheck.RepeatableQuests) do
                local req = data.requirements and data.requirements[1]
                local mobType = req and req.npcType or "???"
                local amount = req and req.amount or "?"
                print(string.format("  [%s] Lv.%s → Kill %s x%s", npcName, tostring(data.recommendedLevel), mobType, tostring(amount)))
            end
        else
            print("  Quest data not available")
        end
        print("═══ END ═══\n")
    end
})

DebugSection:AddButton({
    Name = "👾 Print Mobs in Map",
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
local KeybindSection = SettingsTab:AddSection({
    Name = "⌨️ KEYBINDS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Catraz Hub doesn't have built-in keybinds, so we'll use UserInputService
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        getgenv().IsFarm = not getgenv().IsFarm
        Notify(getgenv().IsFarm and "Farm ON (F2)" or "Farm OFF (F2)")
    elseif input.KeyCode == Enum.KeyCode.V then
        getgenv().IsFarm = not getgenv().IsFarm
        Notify(getgenv().IsFarm and "Farm ON (V)" or "Farm OFF (V)")
    elseif input.KeyCode == Enum.KeyCode.B then
        getgenv().IsBossFight = not getgenv().IsBossFight
        Notify(getgenv().IsBossFight and "Boss Fight ON (B)" or "Boss Fight OFF (B)")
    elseif input.KeyCode == Enum.KeyCode.N then
        getgenv().IsSummonBoss = not getgenv().IsSummonBoss
        Notify(getgenv().IsSummonBoss and "Summon Boss ON (N)" or "Summon Boss OFF (N)")
    elseif input.KeyCode == Enum.KeyCode.M then
        local anyOn = false
        for _, v in pairs(getgenv().AutoSkills) do
            if v then anyOn = true break end
        end
        local newState = not anyOn
        for _, k in ipairs({"Z","X","C","V","F"}) do
            getgenv().AutoSkills[k] = newState
        end
        Notify(newState and "All Skills ON (M)" or "Skills OFF (M)")
    end
end)

KeybindSection:AddParagraph({
    Title = "Keybinds",
    Desc = "F2 / V : Toggle Farm\nB : Toggle Boss Fight\nN : Toggle Summon Boss\nM : Toggle All Skills",
    Image = "key",
    ImageSize = 38
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

--==================================================
-- MAIN LOOP
--==================================================
local function getTargetQuest()
    if not questcheck or not questcheck.RepeatableQuests then return nil end
    
    local level = player.Data and player.Data.Level and player.Data.Level.Value or 0
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

local function doDungeonQuest()
    Notify("Dungeon Quest feature - check game mechanics")
    return false
end

local function doHogyokuQuest()
    Notify("Hogyoku Quest feature - check game mechanics")
    return false
end

local function doAutoDungeon()
    Notify("Auto Dungeon feature - check game mechanics")
    return false
end

local function doBossRush()
    Notify("Boss Rush feature - check game mechanics")
    return false
end

local function doSummonBoss()
    Notify("Summon Boss feature - check game mechanics")
    return false
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

-- Main loop
task.spawn(function()
    while true do
        task.wait(0.1)

        local char = player.Character
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
                    local questRemote = RepStorage:FindFirstChild("RemoteEvents") and RepStorage.RemoteEvents:FindFirstChild("QuestAccept")
                    if questRemote then
                        questRemote:FireServer(targetNPC)
                    end
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
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE HUB - CATRAZ EDITION v4.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Farm - Auto Quest dengan target mob")
print("✅ Boss - Auto Fight & Summon")
print("✅ Modes - Dungeon, Boss Rush, Quest Chains")
print("✅ Skills - Individual skill toggles")
print("✅ Items - Auto Chest & Merchant")
print("✅ Settings - Noclip, Anti-AFK, Keybinds")
print("═══════════════════════════════════════════════════════")
print("Keybinds: F2/V=Farm | B=Boss | N=Summon | M=Skills")
print("═══════════════════════════════════════════════════════")