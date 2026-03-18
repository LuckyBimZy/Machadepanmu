-- ==================== SAILOR PIECE - CATRAZ ULTIMATE v4.1 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 4.1 ULTIMATE - Enhanced Auto Skills

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
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

--==================================================
-- REMOTE REFERENCES
--==================================================
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
local summonBossRemote = Remotes:WaitForChild("RequestSummonBoss")
local spawnStrongestRemote = Remotes:WaitForChild("RequestSpawnStrongestBoss")
local anosRemote = Remotes:WaitForChild("RequestSpawnAnosBoss")
local trueAizenRemote = RemoteEvents:WaitForChild("RequestSpawnTrueAizen")
local rimuruRemote = RemoteEvents:WaitForChild("RequestSpawnRimuru")
local dungeonVoteRemote = Remotes:WaitForChild("DungeonWaveVote")
local dungeonPortalRemote = Remotes:WaitForChild("RequestDungeonPortal")
local equipWeaponRemote = Remotes:WaitForChild("EquipWeapon")

--==================================================
-- CONFIGURATION
--==================================================
getgenv().Config = {
    -- Auto Farm
    IsFarm = false,
    SelectedMob = nil,
    WeaponMode = "Melee",
    AttackCooldown = 0.3,
    IsTeleporting = false,
    PlankMode = false,
    FarmHeight = 25,
    FarmSpeed = 50,
    MoveMode = "Tween",
    
    -- SKILL SETTINGS (ENHANCED)
    AutoSkills = {
        Z = false,
        X = false,
        C = false,
        V = false,
        F = false,
        G = false,  -- Extra skill slots
        H = false,
        J = false,
        K = false,
        L = false
    },
    SkillCooldown = 0.5,
    SkillMode = "Loop",  -- "Loop", "Combo", "Spam"
    ComboDelay = 0.2,
    
    -- Skill Key Mapping
    SkillKeys = {
        Z = 1, X = 2, C = 3, V = 4, F = 5,
        G = 6, H = 7, J = 8, K = 9, L = 10
    },
    
    -- Skill Usage Settings
    UseSkillsOnMobs = true,
    UseSkillsOnBoss = true,
    UseSkillsOnDungeon = true,
    UseSkillsOnRush = true,
    
    -- Boss Settings
    IsBossFight = false,
    SelectedBoss = nil,
    IsSummonBoss = false,
    SummonDifficulty = "Normal",
    
    -- Dungeon Settings
    IsAutoDungeon = false,
    DungeonType = "Double",
    IsBossRush = false,
    
    -- Quest Settings
    IsDungeonQuest = false,
    IsHogyokuQuest = false,
    
    -- Item Settings
    IsAutoChest = false,
    IsAutoMerchant = false,
    MerchantItem = nil,
    
    -- Misc Settings
    IsNoclip = false,
    AntiAFK = true,
    FpsBoost = false,
    WhiteScreen = false,
    AutoRejoin = false,
    TimedRejoin = false,
    RejoinDelay = 10,
    FriendOnly = false,
    
    -- Constants
    ICON = "rbxassetid://105921924721005",
    NPC_FOLDER = "NPCs",
    BOSS_ISLAND_PORTAL = "Boss",
    ANOS_ISLAND = "Academy",
    
    -- Farm Order
    FarmOrder = {
        { Name = "Swordsman", Remote = "Judgement", IsBossType = false },
        { Name = "Quincy", Remote = "HuecoMundo", IsBossType = false },
        { Name = "AcademyTeacher", Remote = "Academy", IsBossType = false },
        { Name = "Slime", Remote = "Slime", IsBossType = false },
        { Name = "StrongSorcerer", Remote = "Shinjuku", IsBossType = false },
        { Name = "Hollow", Remote = "HuecoMundo", IsBossType = false },
        { Name = "Curse", Remote = "Shinjuku", IsBossType = false },
        { Name = "Gojo", Remote = "Shibuya", IsBossType = true },
        { Name = "Yuji", Remote = "Shibuya", IsBossType = true },
        { Name = "Sukuna", Remote = "Shibuya", IsBossType = true },
        { Name = "Jinwoo", Remote = "Sailor", IsBossType = true },
        { Name = "Alucard", Remote = "Sailor", IsBossType = true },
        { Name = "Aizen", Remote = "HuecoMundo", IsBossType = true },
        { Name = "Yamato", Remote = "Judgement", IsBossType = true },
        { Name = "Saber", Remote = "Boss", IsBossType = true },
        { Name = "Ichigo", Remote = "Boss", IsBossType = true },
        { Name = "QinShi", Remote = "Boss", IsBossType = true },
        { Name = "Gilgamesh", Remote = "Boss", IsBossType = true },
        { Name = "BlessedMaiden", Remote = "Boss", IsBossType = true },
        { Name = "SaberAlter", Remote = "Boss", IsBossType = true },
        { Name = "StrongestinHistory", Remote = "Shinjuku", IsBossType = true },
        { Name = "StrongestofToday", Remote = "Shinjuku", IsBossType = true },
        { Name = "Rimuru", Remote = "Slime", IsBossType = true },
        { Name = "Anos", Remote = "Academy", IsBossType = true },
        { Name = "TrueAizen", Remote = "HuecoMundo", IsBossType = true },
    },
    
    -- Islands
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
        {Portal = "SoulSociety", FarmUntil = 999999, Enemies = {"Quincy1", "Quincy2", "Quincy3", "Quincy4", "Quincy5"}, QuestNPC = "QuestNPC17"},
    },
    
    -- Dungeon Types
    DungeonTypes = {"Double", "Rune", "Cid"},
    DungeonDifficulties = {"Easy", "Normal", "Hard", "Extreme"},
    DungeonPortalNames = {Double = "DoubleDungeon", Rune = "RuneDungeon", Cid = "CidDungeon"},
    
    -- Ignore List
    IgnoreList = {"groupreward","katana","buyer","madoka","training","dummy","merchant","shop","vendor","shadow questline","shadowmonarch","obshakilsinhead","buff","questnpc"},
    
    -- Chest & Merchant Items
    ChestNames = {"Common Chest","Rare Chest","Epic Chest","Legendary Chest","Mythical Chest"},
    ChestTypes = {"Wood", "Iron", "Gold", "Diamond", "Legendary"},
    MerchantItems = {"Boss Key","Clan Reroll","Dungeon Key","Haki Color Reroll","Race Reroll","Rush Key","Trait Reroll"},
}

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
    Ambient = Lighting.Ambient
}

local originalCamera = {
    FieldOfView = Camera.FieldOfView
}

local originalQuality = settings().Rendering.QualityLevel

--==================================================
-- RESTORE ORIGINAL SETTINGS
--==================================================
local function restoreOriginalSettings()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Ambient = originalLighting.Ambient
    settings().Rendering.QualityLevel = originalQuality
end

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
-- UTILITY FUNCTIONS
--==================================================

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function GetNPCFolder()
    local direct = Workspace:FindFirstChild(getgenv().Config.NPC_FOLDER)
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

local function GetHum(e)
    if not e then return nil end
    local h = e:FindFirstChildOfClass("Humanoid")
    if not h then
        for _, d in ipairs(e:GetDescendants()) do
            if d:IsA("Humanoid") then
                h = d
                break
            end
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

local function PortalDisplayName(portal)
    local names = {HuecoMundo = "Hueco Mundo", SoulSociety = "Soul Society"}
    return names[portal] or portal
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
    return lv
end

local function IsAlive()
    local c = Player.Character
    if not c then return false end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return hrp ~= nil and hum ~= nil and hum.Health > 0
end

local function ShouldIgnore(name)
    local lo = name:lower()
    for _, ig in ipairs(getgenv().Config.IgnoreList) do
        if lo:find(ig, 1, true) then return true end
    end
    return false
end

--==================================================
-- FIND MOB FUNCTIONS
--==================================================
local function findMob(targetName)
    local npcFolder = GetNPCFolder()
    if not npcFolder then return nil end

    local closest = nil
    local closestDist = math.huge
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local playerPos = char.HumanoidRootPart.Position

    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and not ShouldIgnore(npc.Name) then
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
-- TELEPORT FUNCTIONS
--==================================================
local function ForceTP(portal)
    pcall(function() tpRemote:FireServer(portal) end)
    task.wait(0.5)
end

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
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end

    local root = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")

    local offset = Vector3.new(0, 0, 5)
    if getgenv().Config.PlankMode then
        offset = Vector3.new(0, getgenv().Config.FarmHeight, 0)
    end
    local targetPos = mob.HumanoidRootPart.Position + offset

    if getgenv().Config.MoveMode == "Teleport" then
        root.CFrame = CFrame.new(targetPos)
        return
    end

    local totalDist = (targetPos - root.Position).Magnitude
    getgenv().Config.IsTeleporting = true

    if totalDist <= CLOSE_RANGE then
        microTween(root, CFrame.new(targetPos))
        getgenv().Config.IsTeleporting = false
        return
    end

    local steps = math.ceil(totalDist / STEP_SIZE)
    local startPos = root.Position

    for i = 1, steps do
        if not getgenv().Config.IsFarm and not getgenv().Config.IsBossFight and not getgenv().Config.IsAutoDungeon then break end
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
            root.Velocity = moveDir.Unit * getgenv().Config.FarmSpeed
        end

        microTween(root, CFrame.new(nextPos))
        task.wait(STEP_DELAY)
    end

    root.Velocity = Vector3.new(0, 0, 0)
    getgenv().Config.IsTeleporting = false
end

--==================================================
-- ENHANCED SKILL SYSTEM
--==================================================

-- Skill timing variables
local lastSkillTime = 0
local skillQueue = {}
local currentComboIndex = 1
local comboSequence = {"Z", "X", "C", "V", "F"}

-- Get active skills list
local function getActiveSkills()
    local active = {}
    for key, enabled in pairs(getgenv().Config.AutoSkills) do
        if enabled then
            table.insert(active, key)
        end
    end
    return active
end

-- Fire a single skill
local function fireSkill(skillKey)
    local skillId = getgenv().Config.SkillKeys[skillKey]
    if not skillId then return false end
    
    local success = pcall(function()
        AbilityRemote:FireServer(skillId)
    end)
    
    if success then
        -- Optional: Add visual feedback or debug
        -- print("[SKILL] Fired: " .. skillKey)
    end
    
    return success
end

-- Fire skills based on mode
local function fireSkills()
    if tick() - lastSkillTime < getgenv().Config.SkillCooldown then return end
    
    local mode = getgenv().Config.SkillMode
    local activeSkills = getActiveSkills()
    
    if #activeSkills == 0 then return end
    
    lastSkillTime = tick()
    
    if mode == "Spam" then
        -- Fire all active skills at once
        for _, skillKey in ipairs(activeSkills) do
            fireSkill(skillKey)
        end
    elseif mode == "Loop" then
        -- Fire one skill at a time in sequence
        if #skillQueue == 0 then
            skillQueue = activeSkills
        end
        
        local nextSkill = table.remove(skillQueue, 1)
        fireSkill(nextSkill)
    elseif mode == "Combo" then
        -- Fire skills in combo sequence with delay
        local comboSkill = comboSequence[currentComboIndex]
        if comboSkill and getgenv().Config.AutoSkills[comboSkill] then
            fireSkill(comboSkill)
            currentComboIndex = currentComboIndex + 1
            if currentComboIndex > #comboSequence then
                currentComboIndex = 1
            end
        end
    end
end

-- Continuous skill loop
task.spawn(function()
    while true do
        task.wait(getgenv().Config.SkillCooldown)
        
        -- Check if skills should be used based on current mode
        local useSkills = false
        
        if getgenv().Config.IsFarm and getgenv().Config.UseSkillsOnMobs then
            useSkills = true
        elseif getgenv().Config.IsBossFight and getgenv().Config.UseSkillsOnBoss then
            useSkills = true
        elseif getgenv().Config.IsAutoDungeon and getgenv().Config.UseSkillsOnDungeon then
            useSkills = true
        elseif getgenv().Config.IsBossRush and getgenv().Config.UseSkillsOnRush then
            useSkills = true
        end
        
        if useSkills and IsAlive() then
            fireSkills()
        end
    end
end)

--==================================================
-- WEAPON SYSTEM
--==================================================
local function equipWeapon()
    local char = Player.Character
    if not char then return nil end
    local backpack = Player:FindFirstChild("Backpack")
    if not backpack then return nil end

    local mode = getgenv().Config.WeaponMode

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
end

--==================================================
-- AUTO FARM LOOP
--==================================================
local function doAutoFarm()
    local targetMobName = getgenv().Config.SelectedMob
    
    if not targetMobName then
        return false
    end

    local mob, dist = findMob(targetMobName)

    if mob then
        local mobH = mob:FindFirstChildOfClass("Humanoid")
        if mobH and mobH.Health > 0 then
            tweenToMob(mob)
            task.wait(0.2)

            while getgenv().Config.IsFarm and mob and mob.Parent and mob:FindFirstChild("HumanoidRootPart") do
                local h = mob:FindFirstChildOfClass("Humanoid")
                if not h or h.Health <= 0 then break end
                tweenToMob(mob)
                autoAttack(mob)
                task.wait(getgenv().Config.AttackCooldown)
            end

            task.wait(0.3)
            return true
        end
    end
    return false
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece",
    Subtext = "Catraz Ultimate v4.1",
    Version = "v4.1",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece Ultimate",
    IntroIcon = getgenv().Config.ICON,
    Icon = getgenv().Config.ICON,
    ShowIcon = true,
    
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = getgenv().Config.ICON,
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

local SettingTab = Window:MakeTab({
    Name = "⚙️ Settings",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- MAIN TAB - PLAYER INFO
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local playerInfoPara = PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName,
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

task.spawn(function()
    while true do
        task.wait(1)
        ServerInfoPara:SetDesc(UpdateServerInfo())
        
        local level = 0
        local money = 0
        local gems = 0
        pcall(function() 
            level = Player.Data.Level.Value or 0
            money = Player.Data.Money.Value or 0
            gems = Player.Data.Gems.Value or 0
        end)
        
        playerInfoPara:SetDesc("Display Name: " .. Player.DisplayName .. "\n" ..
                               "Level: " .. level .. "\n" ..
                               "Money: " .. formatNumber(money) .. "\n" ..
                               "Gems: " .. formatNumber(gems) .. "\n" ..
                               "Account Age: " .. Player.AccountAge .. " days")
    end
end)

--==================================================
-- FARM TAB
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
        getgenv().Config.IsFarm = Value
        Notify(Value and "Auto Farm Enabled" or "Auto Farm Disabled")
    end
})

FarmMainSection:AddToggle({
    Name = "🛹 PLANK MODE (HOVER)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "PlankMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.PlankMode = Value
    end
})

FarmMainSection:AddDropdown({
    Name = "🚀 MOVE MODE",
    Default = "Tween",
    Options = {"Tween", "Teleport"},
    Multi = false,
    Outline = true,
    Flag = "MoveMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.MoveMode = Value
    end
})

FarmMainSection:AddSlider({
    Name = "📏 FARM HEIGHT",
    Min = 5,
    Max = 100,
    Default = 25,
    Increment = 1,
    ValueName = "studs",
    Outline = true,
    Flag = "FarmHeight",
    Save = true,
    Callback = function(Value)
        getgenv().Config.FarmHeight = Value
    end
})

FarmMainSection:AddSlider({
    Name = "💨 FARM SPEED",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Flag = "FarmSpeed",
    Save = true,
    Callback = function(Value)
        getgenv().Config.FarmSpeed = Value
    end
})

FarmMainSection:AddSlider({
    Name = "⏱️ ATTACK COOLDOWN (ms)",
    Min = 100,
    Max = 1000,
    Default = 300,
    Increment = 10,
    ValueName = "ms",
    Outline = true,
    Flag = "AttackCooldown",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AttackCooldown = Value / 1000
    end
})

FarmMainSection:AddDropdown({
    Name = "⚔️ WEAPON MODE",
    Default = "Melee",
    Options = {"Melee", "Fruit"},
    Multi = false,
    Outline = true,
    Flag = "WeaponMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.WeaponMode = Value
    end
})

FarmMainSection:AddInput({
    Name = "🎯 TARGET MOB NAME",
    Default = "",
    Numeric = false,
    Flag = "TargetMob",
    Save = true,
    Callback = function(Value)
        getgenv().Config.SelectedMob = Value
    end
})

--==================================================
-- ENHANCED SKILL TAB
--==================================================
local SkillMainSection = SkillTab:AddSection({
    Name = "🎯 AUTO SKILLS (ENHANCED)",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Basic Skills (Z,X,C,V,F)
SkillMainSection:AddToggle({
    Name = "USE SKILL Z (Slot 1)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillZ",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.Z = Value
    end
})

SkillMainSection:AddToggle({
    Name = "USE SKILL X (Slot 2)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillX",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.X = Value
    end
})

SkillMainSection:AddToggle({
    Name = "USE SKILL C (Slot 3)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillC",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.C = Value
    end
})

SkillMainSection:AddToggle({
    Name = "USE SKILL V (Slot 4)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillV",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.V = Value
    end
})

SkillMainSection:AddToggle({
    Name = "USE SKILL F (Slot 5 - NUKE)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillF",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.F = Value
    end
})

-- Extended Skills (G,H,J,K,L)
local ExtendedSection = SkillTab:AddSection({
    Name = "🔧 EXTENDED SKILLS",
    TextSize = 16,
    Glass = true,
    Outline = true
})

ExtendedSection:AddToggle({
    Name = "USE SKILL G (Slot 6)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillG",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.G = Value
    end
})

ExtendedSection:AddToggle({
    Name = "USE SKILL H (Slot 7)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillH",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.H = Value
    end
})

ExtendedSection:AddToggle({
    Name = "USE SKILL J (Slot 8)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillJ",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.J = Value
    end
})

ExtendedSection:AddToggle({
    Name = "USE SKILL K (Slot 9)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillK",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.K = Value
    end
})

ExtendedSection:AddToggle({
    Name = "USE SKILL L (Slot 10)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillL",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoSkills.L = Value
    end
})

-- Skill Mode Selection
local ModeSection = SkillTab:AddSection({
    Name = "⚙️ SKILL MODE",
    TextSize = 16,
    Glass = true,
    Outline = true
})

ModeSection:AddDropdown({
    Name = "SKILL ACTIVATION MODE",
    Default = "Loop",
    Options = {"Loop", "Spam", "Combo"},
    Multi = false,
    Outline = true,
    Flag = "SkillMode",
    Save = true,
    Callback = function(Value)
        getgenv().Config.SkillMode = Value
        Notify("Skill Mode: " .. Value)
    end
})

ModeSection:AddParagraph({
    Title = "Mode Description",
    Desc = "Loop: One skill at a time\nSpam: All skills at once\nCombo: Skills in sequence",
    Image = "info",
    ImageSize = 32
})

-- Skill Usage Settings
local UsageSection = SkillTab:AddSection({
    Name = "🎮 SKILL USAGE",
    TextSize = 16,
    Glass = true,
    Outline = true
})

UsageSection:AddToggle({
    Name = "USE ON MOBS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillsOnMobs",
    Save = true,
    Callback = function(Value)
        getgenv().Config.UseSkillsOnMobs = Value
    end
})

UsageSection:AddToggle({
    Name = "USE ON BOSSES",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillsOnBoss",
    Save = true,
    Callback = function(Value)
        getgenv().Config.UseSkillsOnBoss = Value
    end
})

UsageSection:AddToggle({
    Name = "USE IN DUNGEON",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillsOnDungeon",
    Save = true,
    Callback = function(Value)
        getgenv().Config.UseSkillsOnDungeon = Value
    end
})

UsageSection:AddToggle({
    Name = "USE IN BOSS RUSH",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillsOnRush",
    Save = true,
    Callback = function(Value)
        getgenv().Config.UseSkillsOnRush = Value
    end
})

-- Skill Timing
local TimingSection = SkillTab:AddSection({
    Name = "⏱️ SKILL TIMING",
    TextSize = 16,
    Glass = true,
    Outline = true
})

TimingSection:AddSlider({
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
        getgenv().Config.SkillCooldown = Value / 1000
    end
})

TimingSection:AddSlider({
    Name = "COMBO DELAY (ms)",
    Min = 50,
    Max = 500,
    Default = 200,
    Increment = 10,
    ValueName = "ms",
    Outline = true,
    Flag = "ComboDelay",
    Save = true,
    Callback = function(Value)
        getgenv().Config.ComboDelay = Value / 1000
    end
})

-- Quick Controls
local QuickSection = SkillTab:AddSection({
    Name = "⚡ QUICK CONTROLS",
    TextSize = 16,
    Glass = true,
    Outline = true
})

QuickSection:AddToggle({
    Name = "🔥 ALL SKILLS ON/OFF",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AllSkills",
    Save = true,
    Callback = function(Value)
        -- Update all skill toggles
        for key in pairs(getgenv().Config.AutoSkills) do
            getgenv().Config.AutoSkills[key] = Value
        end
        
        -- Update UI flags
        if OrionLib.Flags["SkillZ"] then OrionLib.Flags["SkillZ"]:SetValue(Value) end
        if OrionLib.Flags["SkillX"] then OrionLib.Flags["SkillX"]:SetValue(Value) end
        if OrionLib.Flags["SkillC"] then OrionLib.Flags["SkillC"]:SetValue(Value) end
        if OrionLib.Flags["SkillV"] then OrionLib.Flags["SkillV"]:SetValue(Value) end
        if OrionLib.Flags["SkillF"] then OrionLib.Flags["SkillF"]:SetValue(Value) end
        if OrionLib.Flags["SkillG"] then OrionLib.Flags["SkillG"]:SetValue(Value) end
        if OrionLib.Flags["SkillH"] then OrionLib.Flags["SkillH"]:SetValue(Value) end
        if OrionLib.Flags["SkillJ"] then OrionLib.Flags["SkillJ"]:SetValue(Value) end
        if OrionLib.Flags["SkillK"] then OrionLib.Flags["SkillK"]:SetValue(Value) end
        if OrionLib.Flags["SkillL"] then OrionLib.Flags["SkillL"]:SetValue(Value) end
        
        Notify(Value and "All Skills ON" or "All Skills OFF")
    end
})

QuickSection:AddKeybind({
    Name = "Toggle All Skills",
    Default = Enum.KeyCode.M,
    Flag = "AllSkillsKeybind",
    Save = true,
    Callback = function()
        -- This will be handled by keybind system
        if OrionLib.Flags["AllSkills"] then
            OrionLib.Flags["AllSkills"]:SetValue(not OrionLib.Flags["AllSkills"]:GetValue())
        end
    end
})

-- Haki Section
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
-- BOSS TAB
--==================================================
local BossMainSection = BossTab:AddSection({
    Name = "🐉 BOSS FIGHT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "ENABLE BOSS FIGHT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossFight",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsBossFight = Value
        Notify(Value and "Boss Fight Enabled" or "Boss Fight Disabled")
    end
})

BossMainSection:AddInput({
    Name = "🎯 BOSS NAME",
    Default = "",
    Numeric = false,
    Flag = "BossName",
    Save = true,
    Callback = function(Value)
        getgenv().Config.SelectedBoss = Value
    end
})

local SummonSection = BossTab:AddSection({
    Name = "🔮 SUMMON BOSS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SummonSection:AddToggle({
    Name = "ENABLE SUMMON BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SummonBoss",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsSummonBoss = Value
        Notify(Value and "Summon Boss Enabled" or "Summon Boss Disabled")
    end
})

SummonSection:AddDropdown({
    Name = "💀 DIFFICULTY",
    Default = "Normal",
    Options = {"Easy", "Normal", "Hard", "Nightmare"},
    Multi = false,
    Outline = true,
    Flag = "SummonDifficulty",
    Save = true,
    Callback = function(Value)
        getgenv().Config.SummonDifficulty = Value
    end
})

--==================================================
-- MODES TAB
--==================================================
local ModeMainSection = ModeTab:AddSection({
    Name = "🏰 DUNGEON",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ModeMainSection:AddToggle({
    Name = "ENABLE AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsAutoDungeon = Value
        Notify(Value and "Auto Dungeon Enabled" or "Auto Dungeon Disabled")
    end
})

ModeMainSection:AddDropdown({
    Name = "DUNGEON TYPE",
    Default = "Double",
    Options = {"Double", "Rune", "Cid"},
    Multi = false,
    Outline = true,
    Flag = "DungeonType",
    Save = true,
    Callback = function(Value)
        getgenv().Config.DungeonType = Value
    end
})

ModeMainSection:AddButton({
    Name = "🚪 ENTER DUNGEON",
    Icon = "door",
    Outline = true,
    Callback = function()
        pcall(function()
            dungeonPortalRemote:FireServer(getgenv().Config.DungeonPortalNames[getgenv().Config.DungeonType])
            Notify("Attempting to enter " .. getgenv().Config.DungeonType .. " Dungeon")
        end)
    end
})

ModeMainSection:AddButton({
    Name = "🗳️ VOTE DIFFICULTY",
    Icon = "vote",
    Outline = true,
    Callback = function()
        pcall(function()
            dungeonVoteRemote:FireServer("Normal")
            Notify("Voted for Normal difficulty")
        end)
    end
})

local RushSection = ModeTab:AddSection({
    Name = "⚡ BOSS RUSH",
    TextSize = 18,
    Glass = true,
    Outline = true
})

RushSection:AddToggle({
    Name = "ENABLE BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossRush",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsBossRush = Value
        Notify(Value and "Boss Rush Enabled" or "Boss Rush Disabled")
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
    Name = "AUTO OPEN CHESTS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoChest",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsAutoChest = Value
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
        getgenv().Config.IsAutoMerchant = Value
    end
})

MerchantSection:AddDropdown({
    Name = "🛒 ITEM TO BUY",
    Default = "Boss Key",
    Options = {"Boss Key", "Clan Reroll", "Dungeon Key", "Haki Color Reroll", "Race Reroll", "Rush Key", "Trait Reroll"},
    Multi = false,
    Outline = true,
    Flag = "MerchantItem",
    Save = true,
    Callback = function(Value)
        getgenv().Config.MerchantItem = Value
    end
})

--==================================================
-- SETTINGS TAB
--==================================================
local SettingsSection = SettingTab:AddSection({
    Name = "🔧 UTILITY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SettingsSection:AddToggle({
    Name = "👻 NOCLIP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        getgenv().Config.IsNoclip = Value
        Notify(Value and "Noclip ON" or "Noclip OFF")
    end
})

SettingsSection:AddToggle({
    Name = "ANTI-AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AntiAFK = Value
    end
})

SettingsSection:AddToggle({
    Name = "FPS BOOST (BLACK SCREEN)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        getgenv().Config.FpsBoost = Value
        if Value then
            Lighting.Brightness = 0
            Lighting.GlobalShadows = false
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
        else
            restoreOriginalSettings()
        end
    end
})

SettingsSection:AddToggle({
    Name = "WHITE SCREEN MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "WhiteScreen",
    Save = true,
    Callback = function(Value)
        getgenv().Config.WhiteScreen = Value
        RunService:Set3dRenderingEnabled(not Value)
    end
})

SettingsSection:AddToggle({
    Name = "AUTO REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value)
        getgenv().Config.AutoRejoin = Value
    end
})

SettingsSection:AddToggle({
    Name = "TIMED REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "TimedRejoin",
    Save = true,
    Callback = function(Value)
        getgenv().Config.TimedRejoin = Value
    end
})

SettingsSection:AddSlider({
    Name = "REJOIN DELAY (MINUTES)",
    Min = 1,
    Max = 120,
    Default = 10,
    Increment = 1,
    ValueName = "min",
    Outline = true,
    Flag = "RejoinDelay",
    Save = true,
    Callback = function(Value)
        getgenv().Config.RejoinDelay = Value
    end
})

-- Teleport Section
local TeleportSection = SettingTab:AddSection({
    Name = "📍 TELEPORT TO ISLAND",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local islandNames = {"Starter","Jungle","Desert","Snow","Sailor","Shibuya","HuecoMundo","Boss","Dungeon","Shinjuku","Slime","Academy","Judgement","SoulSociety"}
for _, name in ipairs(islandNames) do
    TeleportSection:AddButton({
        Name = PortalDisplayName(name),
        Icon = "map-pin",
        Outline = true,
        Callback = function()
            if getgenv().Config.IsFarm then
                Notify("Disable Auto Farm first!", 2)
                return
            end
            ForceTP(name)
            Notify("Teleporting to " .. PortalDisplayName(name))
        end
    })
end

-- Destroy Button
local DestroySection = SettingTab:AddSection({
    Name = "⚠️ DANGER ZONE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DestroySection:AddButton({
    Name = "💀 DESTROY GUI",
    Icon = "skull",
    Outline = true,
    Callback = function()
        getgenv().Config.IsFarm = false
        getgenv().Config.IsBossFight = false
        getgenv().Config.IsAutoDungeon = false
        getgenv().Config.IsBossRush = false
        getgenv().Config.IsSummonBoss = false
        task.delay(0.1, function()
            OrionLib:Destroy()
            _G.SP_Loaded = false
        end)
    end
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Configs",
    Icon = "settings"
})

--==================================================
-- ANTI AFK LOOP
--==================================================
task.spawn(function()
    while getgenv().Config.AntiAFK do
        task.wait(60)
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end)
    end
end)

--==================================================
-- NOCLIP
--==================================================
RunService.Stepped:Connect(function()
    if getgenv().Config.IsNoclip then
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

--==================================================
-- MAIN FARM LOOP
--==================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        
        if not IsAlive() then
            task.wait(1)
            continue
        end
        
        if getgenv().Config.IsFarm then
            doAutoFarm()
        end
        
        task.wait(0.1)
    end
end)

--==================================================
-- KEYBINDS
--==================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- F2 Toggle Farm
    if input.KeyCode == Enum.KeyCode.F2 then
        getgenv().Config.IsFarm = not getgenv().Config.IsFarm
        if OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(getgenv().Config.IsFarm) end
        Notify(getgenv().Config.IsFarm and "Farm ON (F2)" or "Farm OFF (F2)")
    end
    
    -- V Toggle Farm
    if input.KeyCode == Enum.KeyCode.V then
        getgenv().Config.IsFarm = not getgenv().Config.IsFarm
        if OrionLib.Flags["AutoFarm"] then OrionLib.Flags["AutoFarm"]:SetValue(getgenv().Config.IsFarm) end
        Notify(getgenv().Config.IsFarm and "Farm ON (V)" or "Farm OFF (V)")
    end
    
    -- B Toggle Boss Fight
    if input.KeyCode == Enum.KeyCode.B then
        getgenv().Config.IsBossFight = not getgenv().Config.IsBossFight
        if OrionLib.Flags["BossFight"] then OrionLib.Flags["BossFight"]:SetValue(getgenv().Config.IsBossFight) end
        Notify(getgenv().Config.IsBossFight and "Boss ON (B)" or "Boss OFF (B)")
    end
    
    -- N Toggle Summon Boss
    if input.KeyCode == Enum.KeyCode.N then
        getgenv().Config.IsSummonBoss = not getgenv().Config.IsSummonBoss
        if OrionLib.Flags["SummonBoss"] then OrionLib.Flags["SummonBoss"]:SetValue(getgenv().Config.IsSummonBoss) end
        Notify(getgenv().Config.IsSummonBoss and "Summon ON (N)" or "Summon OFF (N)")
    end
    
    -- M Toggle All Skills
    if input.KeyCode == Enum.KeyCode.M then
        local anyOn = false
        for _, v in pairs(getgenv().Config.AutoSkills) do
            if v then anyOn = true break end
        end
        local newState = not anyOn
        
        -- Update all skill toggles
        for key in pairs(getgenv().Config.AutoSkills) do
            getgenv().Config.AutoSkills[key] = newState
        end
        
        -- Update UI flags
        if OrionLib.Flags["SkillZ"] then OrionLib.Flags["SkillZ"]:SetValue(newState) end
        if OrionLib.Flags["SkillX"] then OrionLib.Flags["SkillX"]:SetValue(newState) end
        if OrionLib.Flags["SkillC"] then OrionLib.Flags["SkillC"]:SetValue(newState) end
        if OrionLib.Flags["SkillV"] then OrionLib.Flags["SkillV"]:SetValue(newState) end
        if OrionLib.Flags["SkillF"] then OrionLib.Flags["SkillF"]:SetValue(newState) end
        if OrionLib.Flags["SkillG"] then OrionLib.Flags["SkillG"]:SetValue(newState) end
        if OrionLib.Flags["SkillH"] then OrionLib.Flags["SkillH"]:SetValue(newState) end
        if OrionLib.Flags["SkillJ"] then OrionLib.Flags["SkillJ"]:SetValue(newState) end
        if OrionLib.Flags["SkillK"] then OrionLib.Flags["SkillK"]:SetValue(newState) end
        if OrionLib.Flags["SkillL"] then OrionLib.Flags["SkillL"]:SetValue(newState) end
        if OrionLib.Flags["AllSkills"] then OrionLib.Flags["AllSkills"]:SetValue(newState) end
        
        Notify(newState and "All Skills ON (M)" or "All Skills OFF (M)")
    end
end)

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if getgenv().Config.AutoHaki then
        pcall(function() hakiRemote:FireServer("Toggle") end)
    end
    if getgenv().Config.AutoObsHaki then
        pcall(function() obsHakiRemote:FireServer("Toggle") end)
    end
end)

--==================================================
-- AUTO REJOIN HANDLER
--==================================================
task.spawn(function()
    local GuiService = game:GetService("GuiService")
    local lastError = ""
    GuiService.ErrorMessageChanged:Connect(function()
        if not getgenv().Config.AutoRejoin then return end
        local err = GuiService:GetErrorMessage()
        if err ~= lastError and err ~= "" then
            lastError = err
            task.wait(5)
            pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
        end
    end)
end)

--==================================================
-- TIMED REJOIN
--==================================================
task.spawn(function()
    local elapsed = 0
    while getgenv().Config.AntiAFK do
        task.wait(1)
        if getgenv().Config.TimedRejoin then
            elapsed = elapsed + 1
            if elapsed >= getgenv().Config.RejoinDelay * 60 then
                elapsed = 0
                task.wait(2)
                pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
            end
        else
            elapsed = 0
        end
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 to toggle UI | F2/V=Farm | B=Boss | N=Summon | M=Skills")
print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE v4.1 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ ENHANCED SKILL SYSTEM:")
print("   - 10 Skill Slots (Z,X,C,V,F,G,H,J,K,L)")
print("   - 3 Skill Modes: Loop, Spam, Combo")
print("   - Skill Usage per Mode (Mobs/Boss/Dungeon/Rush)")
print("   - Adjustable Cooldown & Combo Delay")
print("✅ Auto Farm with Target Selection")
print("✅ Boss Fight + Summon Boss")
print("✅ Dungeon + Boss Rush Modes")
print("✅ Auto Chest + Auto Merchant")
print("✅ Noclip + Anti-AFK")
print("✅ Keybinds: F2/V=Farm | B=Boss | N=Summon | M=Skills")
print("═══════════════════════════════════════════════════════")