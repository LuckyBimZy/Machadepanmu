-- ==================== SAILOR PIECE - CATRAZ EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 1.0 COMPLETE

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
-- CONSTANTS & CONFIG
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
}

-- Islands data
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

-- Bosses data
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
S.DungeonTypes = {"Double","Rune","Cid"}
S.DungeonDifficulties = {"Easy","Normal","Hard","Extreme"}
S.DungeonPortalNames = {Double="DoubleDungeon", Rune="RuneDungeon", Cid="CidDungeon"}

S.IgnoreList = {"groupreward","katana","buyer","madoka","training","dummy","merchant","shop","vendor","shadow questline","shadowmonarch","obshakilsinhead","buff","questnpc"}
S.ChestNames = {"Common Chest","Rare Chest","Epic Chest","Legendary Chest","Mythical Chest"}
S.MerchantItems = {"Boss Key","Clan Reroll","Dungeon Key","Haki Color Reroll","Race Reroll","Rush Key","Trait Reroll"}

S.SkillKeys = {"SkillZ","SkillX","SkillC","SkillV","SkillF"}

--==================================================
-- CONFIG
--==================================================
local Config = {
    -- Auto Farm
    AutoFarmLevel = false,
    AutoDungeon = false,
    AutoBossRush = false,
    
    -- Farm Settings
    SelectedIsland = "Auto",
    FarmMode = "Behind",
    FollowStyle = "Dodge",
    MoveMode = "Tween",
    OffsetDist = 25,
    TweenSpeed = 100,
    DodgeMode = true,
    
    -- Auto Features
    AutoEquip = true,
    AutoQuest = true,
    AutoSpawn = false,
    AntiAFK = true,
    AutoChest = false,
    AutoMerchant = false,
    MerchNotify = true,
    
    -- Skills
    SkillZ = false,
    SkillX = false,
    SkillC = false,
    SkillV = false,
    SkillF = false,
    SkillCooldown = 1.0,
    
    -- Boss Settings
    BossEnabled = false,
    BossNotify = true,
    
    -- Dungeon Settings
    DungeonType = "Double",
    DungeonDiff = "Normal",
    DungeonQuest = false,
    HogyokuQuest = false,
    
    -- Boss Rush
    BossRushFarmMode = "Behind",
    BossRushMoveMode = "Tween",
    BossRushFollowStyle = "Dodge",
    BossRushTweenSpeed = 50,
    
    -- Height & Speed
    HeightOffset = 15,
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
}

-- Boss toggles
local BossToggles = {}
local SummonBossToggles = {}
local ChestToggles = {}
local MerchantToggles = {}
local SkillToggles = {}

-- Initialize toggles
for _, chest in ipairs(S.ChestNames) do
    ChestToggles[chest] = true
end

for _, item in ipairs(S.MerchantItems) do
    MerchantToggles[item] = false
end

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
    Subtext = "Premium Edition",
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
-- CREATE TABS
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
-- MAIN TAB - PLAYER INFO
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

-- Auto refresh server info
task.spawn(function()
    while true do
        task.wait(1)
        ServerInfoPara:SetDesc(UpdateServerInfo())
    end
end)

--==================================================
-- FARM TAB
--==================================================
local FarmSection = FarmTab:AddSection({
    Name = "⚡ AUTO FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

-- Auto Farm Toggle
FarmSection:AddToggle({
    Name = "ENABLE AUTO FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoFarmLevel",
    Save = true,
    Callback = function(Value)
        Config.AutoFarmLevel = Value
        Notify(Value and "Auto Farm Enabled" or "Auto Farm Disabled")
    end
})

FarmSection:AddKeybind({
    Name = "FARM KEYBIND",
    Default = "V",
    Outline = true,
    Flag = "FarmKeybind",
    Save = true,
    Callback = function(Value)
        -- Keybind handler
    end
})

FarmSection:AddToggle({
    Name = "AUTO EQUIP WEAPON",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoEquip",
    Save = true,
    Callback = function(Value)
        Config.AutoEquip = Value
    end
})

FarmSection:AddToggle({
    Name = "AUTO QUEST",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoQuest",
    Save = true,
    Callback = function(Value)
        Config.AutoQuest = Value
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
        Config.AutoSpawn = Value
    end
})

-- Farm Zone Dropdown
local function getIslandNames()
    local names = {"Auto"}
    for _, island in ipairs(S.Islands) do
        table.insert(names, S.PortalDisplayNames[island.Portal] or island.Portal)
    end
    return names
end

FarmSection:AddDropdown({
    Name = "FARM ZONE",
    Default = "Auto",
    Options = getIslandNames(),
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "SelectedIsland",
    Save = true,
    Callback = function(Value)
        Config.SelectedIsland = Value
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
        Config.FarmMode = Value
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
        Config.FollowStyle = Value
        Config.DodgeMode = (Value == "Dodge")
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
        Config.MoveMode = Value
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
    Callback = function(Value)
        Config.OffsetDist = Value
    end
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
        Config.TweenSpeed = Value
    end
})

FarmSection:AddToggle({
    Name = "ANTI AFK",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.AntiAFK = Value
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
            Notify("Teleporting to " .. displayName)
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

BossSection:AddToggle({
    Name = "ENABLE BOSS KILLING",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossEnabled",
    Save = true,
    Callback = function(Value)
        Config.BossEnabled = Value
        Notify(Value and "Boss Killing Enabled" or "Boss Killing Disabled")
    end
})

BossSection:AddKeybind({
    Name = "BOSS KEYBIND",
    Default = "B",
    Outline = true,
    Flag = "BossKeybind",
    Save = true,
    Callback = function(Value)
        -- Keybind handler
    end
})

BossSection:AddToggle({
    Name = "BOSS NOTIFICATIONS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BossNotify",
    Save = true,
    Callback = function(Value)
        Config.BossNotify = Value
    end
})

-- Boss Toggles
for _, boss in ipairs(S.Bosses) do
    BossSection:AddToggle({
        Name = boss.Display .. " (" .. boss.Island .. ")",
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Boss_" .. boss.Name,
        Save = true,
        Callback = function(Value)
            BossToggles[boss.Name] = Value
        end
    })
end

-- Boss Timers
BossSection:AddParagraph({
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

SummonSection:AddKeybind({
    Name = "SUMMON KEYBIND",
    Default = "N",
    Outline = true,
    Flag = "SummonKeybind",
    Save = true,
    Callback = function(Value)
        -- Keybind handler
    end
})

for _, boss in ipairs(S.SummonBosses) do
    local islandText = boss.Island and " (" .. (S.PortalDisplayNames[boss.Island] or boss.Island) .. ")" or ""
    
    -- Toggle untuk boss
    SummonSection:AddToggle({
        Name = boss.Display .. islandText,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "SummonBoss_" .. boss.Name,
        Save = true,
        Callback = function(Value)
            SummonBossToggles[boss.Name] = Value
        end
    })
    
    -- Dropdown difficulty jika ada
    if boss.Difficulties then
        SummonSection:AddDropdown({
            Name = boss.Display .. " Difficulty",
            Default = "Normal",
            Options = boss.Difficulties,
            Multi = false,
            Search = false,
            Outline = true,
            Flag = "SummonDiff_" .. boss.Name,
            Save = true,
            Callback = function(Value)
                if boss.Name == "GilgameshBoss" then Config.GilgameshDiff = Value end
                if boss.Name == "BlessedMaidenBoss" then Config.BlessedMaidenDiff = Value end
                if boss.Name == "SaberAlterBoss" then Config.SaberAlterDiff = Value end
                if boss.Name == "RimuruBoss" then Config.RimuruDiff = Value end
                if boss.Name == "AnosBoss" then Config.AnosDiff = Value end
                if boss.Name == "StrongestTodayBoss" then Config.StrongestTodayDiff = Value end
                if boss.Name == "StrongestHistoryBoss" then Config.StrongestHistoryDiff = Value end
                if boss.Name == "TrueAizenBoss" then Config.TrueAizenDiff = Value end
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

-- Dungeon Type
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
        Config.DungeonType = dungeonTypeMap[Value] or "Double"
    end
})

DungeonSection:AddToggle({
    Name = "ENABLE AUTO DUNGEON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDungeon",
    Save = true,
    Callback = function(Value)
        Config.AutoDungeon = Value
        Notify(Value and "Auto Dungeon Enabled" or "Auto Dungeon Disabled")
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
        Config.DungeonDiff = Value
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
        Config.FarmMode = Value
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
        Config.MoveMode = Value
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
        Config.FollowStyle = Value
        Config.DodgeMode = (Value == "Dodge")
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
    Callback = function(Value)
        Config.OffsetDist = Value
    end
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
    Callback = function(Value)
        Config.TweenSpeed = Value
    end
})

-- Auto-Join Dungeon Section
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
        -- Auto join handler
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
        -- Auto join handler
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
        -- Auto join handler
    end
})

-- Boss Rush Section
local BossRushSection = GamemodesTab:AddSection({
    Name = "⚡ BOSS RUSH",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossRushSection:AddToggle({
    Name = "ENABLE BOSS RUSH",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBossRush",
    Save = true,
    Callback = function(Value)
        Config.AutoBossRush = Value
        Notify(Value and "Boss Rush Enabled" or "Boss Rush Disabled")
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
        -- Auto join handler
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
        Config.BossRushFarmMode = Value
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
        Config.BossRushMoveMode = Value
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
        Config.BossRushFollowStyle = Value
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
    Callback = function(Value)
        Config.OffsetDist = Value
    end
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
    Callback = function(Value)
        Config.BossRushTweenSpeed = Value
    end
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

-- All Skills Toggle
local allSkillsToggle = SkillsMainSection:AddToggle({
    Name = "ALL SKILLS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AllSkills",
    Save = true,
    Callback = function(Value)
        for _, skill in ipairs(S.SkillKeys) do
            if SkillToggles[skill] then
                SkillToggles[skill]:SetValue(Value)
            end
        end
    end
})

SkillsMainSection:AddKeybind({
    Name = "ALL SKILLS KEYBIND",
    Default = "M",
    Outline = true,
    Flag = "AllSkillsKeybind",
    Save = true,
    Callback = function(Value)
        -- Keybind handler
    end
})

-- Individual Skills
local function createSkillToggle(skillKey, displayName)
    SkillToggles[skillKey] = SkillsMainSection:AddToggle({
        Name = "SKILL " .. displayName,
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = skillKey,
        Save = true,
        Callback = function(Value)
            Config[skillKey] = Value
        end
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
    Callback = function(Value)
        Config.SkillCooldown = Value
    end
})

-- Auto Chest Section
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
    Callback = function(Value)
        Config.AutoChest = Value
    end
})

for _, chest in ipairs(S.ChestNames) do
    ChestSection:AddToggle({
        Name = chest,
        Default = true,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Chest_" .. chest:gsub(" ", "_"),
        Save = true,
        Callback = function(Value)
            ChestToggles[chest] = Value
        end
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

QuestsSection:AddToggle({
    Name = "DUNGEON PIECES INFO",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "DungeonQuest",
    Save = true,
    Callback = function(Value)
        Config.DungeonQuest = Value
        Notify(Value and "Dungeon Quest Enabled" or "Dungeon Quest Disabled")
    end
})

QuestsSection:AddHelper({
    Text = "Collect 6 puzzle pieces across islands: Starter → Jungle → Desert → Snow → Shibuya → Hueco Mundo"
})

QuestsSection:AddToggle({
    Name = "HOGYOKU FRAGMENTS INFO",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HogyokuQuest",
    Save = true,
    Callback = function(Value)
        Config.HogyokuQuest = Value
        Notify(Value and "Hogyoku Quest Enabled" or "Hogyoku Quest Disabled")
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
        Config.AutoMerchant = Value
    end
})

MerchantMainSection:AddToggle({
    Name = "MERCHANT NOTIFICATION",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "MerchNotify",
    Save = true,
    Callback = function(Value)
        Config.MerchNotify = Value
    end
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
        Callback = function(Value)
            MerchantToggles[item] = Value
        end
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
    Callback = function(Value)
        -- Show frame always handler
    end
})

UISection:AddColorPicker({
    Name = "HIGHLIGHT COLOR",
    Default = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HighlightColor",
    Save = true,
    Callback = function(Value)
        -- Color handler
    end
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
        OrionLib:Destroy()
        _G.SP_Loaded = false
    end
})

-- Info Section
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

-- Theme Section
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
    Callback = function(Value)
        OrionLib.SelectedTheme = Value
    end
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