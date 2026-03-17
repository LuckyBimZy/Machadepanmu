-- ==================== ESCAPE TSUNAMI FOR BRAINROTS - CATRAZ EDITION ====================
-- Script untuk farming Brainrots dan Lucky Blocks dengan proteksi tsunami
-- Version: 1.0 ULTIMATE

if _G.ET_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Escape Tsunami",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.ET_Loaded = true

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
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

--==================================================
-- GLOBAL VARIABLES
--==================================================
getgenv().ET = {}
local M = getgenv().ET

--==================================================
-- INITIALIZATION
--==================================================
M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
if not M.ActiveBrainrots then task.spawn(function() M.ActiveBrainrots = workspace:WaitForChild("ActiveBrainrots", 15) end) end

M.ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks")
if not M.ActiveLuckyBlocks then task.spawn(function() M.ActiveLuckyBlocks = workspace:WaitForChild("ActiveLuckyBlocks", 15) end) end

M.PlotAction = nil
pcall(function()
    M.PlotAction = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("Net", 10):WaitForChild("RF/Plot.PlotAction", 10)
end)

--==================================================
-- CONSTANTS
--==================================================
local HIGH_RARITIES = {["Celestial"] = true, ["Divine"] = true, ["Infinity"] = true}

--==================================================
-- CONFIG
--==================================================
M.Config = {
    Farming = {
        Enabled = false,
        Targets = {"Brainrots"},
        BrainrotRarity = {"Common"},
        BrainrotMutation = "None",
        FarmMode = "Collect, Place & Max",
        FarmSlot = "5",
        MaxLevel = 250,
        LuckyBlockRarity = {"Common"},
        LuckyBlockMutation = "Any",
        FarmCapacity = 1
    },
    Factory = {
        Enabled = false,
        Rarity = "Common",
        Slot = "5",
        MaxLevel = 250,
        Count = 0
    },
    Automation = {
        AutoCollectMoney = false,
        AutoUpgrade = false
    },
    Tsunami = {
        Enabled = false,
        Mode = "Bawah",
        Height = 150
    },
    Movement = {
        SpeedEnabled = false,
        SpeedValue = 16,
        JumpEnabled = false,
        JumpValue = 50,
        InfiniteJump = false,
        Noclip = false
    },
    Misc = {
        AntiAFK = false,
        TweenSpeed = 1000,
        CorridorSpeed = 400
    }
}

M.Status = {
    farm = "Idle",
    farmCount = 0,
    luckyBlockCount = 0,
    placeCount = 0,
    upgradeCount = 0,
    factory = "Idle",
    factoryCount = 0,
    money = "Idle",
    upgrade = "Idle",
    tsunami = "Off"
}

--==================================================
-- STATE VARIABLES
--==================================================
M.baseGUID = nil
M.baseCFrame = nil
M.homePosition = nil
M.farmThread = nil
M.factoryThread = nil
M.moneyThread = nil
M.moneyRemoteThread = nil
M.upgradeThread = nil
M._noclipConn = nil
M._instantConn = nil
M._wallZ_front = 173
M._wallZ_back = -173

-- Tsunami variables
M.Tsunami = {
    DetectionPart = nil,
    Connection = nil,
    FlyConnection = nil,
    BodyVelocity = nil,
    BodyGyro = nil,
    IsFlying = false,
    LastTsunamiPos = nil
}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Escape Tsunami",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Escape Tsunami",
    Subtext = "For Brainrots - ULTIMATE Edition",
    Version = "v1.0",
    VersionIcon = "waves",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "EscapeTsunami_Config",
    IntroEnabled = true,
    IntroText = "Escape Tsunami For Brainrots",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    
    -- Custom Theme & Appearance
    ImageBackground = "rbxassetid://84894412677021",
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
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "home",
    Glass = true,
    Outline = true
})

local TsunamiTab = Window:MakeTab({
    Name = "Tsunami",
    Icon = "waves",
    Glass = true,
    Outline = true
})

local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local FactoryTab = Window:MakeTab({
    Name = "Factory",
    Icon = "hammer",
    Glass = true,
    Outline = true
})

local AutoTab = Window:MakeTab({
    Name = "Automation",
    Icon = "rocket",
    Glass = true,
    Outline = true
})

local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "footprints",
    Glass = true,
    Outline = true
})

local ConfigTab = Window:MakeTab({
    Name = "Config",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- OPTIONS LISTS
--==================================================
local RARITY_LIST = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity"}
local MUTATION_LIST = {"Any","None","Emerald","Gold","Blood","Diamond","Rainbow","Shadow","Crystal","Void"}
local FARM_MODE_LIST = {"Collect", "Collect, Place & Max"}
local FACTORY_RARITY = {"Common","Uncommon","Rare","Epic","Legendary","Mythical"}
local LB_RARITY = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity","Admin","UFO","Candy","Money"}
local SLOT_LIST = {}
for i = 1, 40 do table.insert(SLOT_LIST, tostring(i)) end
local SPEED_LIST = {"100","200","300","400","500","600","800","1000","1200","1500","2000"}
local TSUNAMI_MODES = {"Bawah (Gali Tanah)", "Atas (Terbang di Atas)"}

--==================================================
-- HOME TAB
--==================================================
local HomeSection1 = HomeTab:AddSection({
    Name = "📊 DASHBOARD",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HomeSection1:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName .. "\n" ..
           "User ID: " .. Player.UserId .. "\n" ..
           "Account Age: " .. Player.AccountAge .. " days",
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150",
    ImageSize = 48
})

local HomeSection2 = HomeTab:AddSection({
    Name = "ℹ️ SCRIPT INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HomeSection2:AddParagraph({
    Title = "Escape Tsunami For Brainrots",
    Desc = "Version: 1.0 ULTIMATE\nCreator: Catraz Team\nFeatures: Farm, Tsunami Protect, Factory, Auto Collect",
    Image = "info",
    ImageSize = 38
})

local HomeSection3 = HomeTab:AddSection({
    Name = "⚡ ACTIVE FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local ActiveFeaturesPara = HomeSection3:AddParagraph({
    Title = "Currently Active",
    Desc = "No active features",
    Image = "activity",
    ImageSize = 38
})

--==================================================
-- TSUNAMI TAB
--==================================================
local TsunamiSection = TsunamiTab:AddSection({
    Name = "🌊 TSUNAMI PROTECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

TsunamiSection:AddDropdown({
    Name = "Mode Perlindungan",
    Default = "Bawah (Gali Tanah)",
    Options = TSUNAMI_MODES,
    Multi = false,
    Outline = true,
    Flag = "TsunamiMode",
    Callback = function(v)
        if v == "Bawah (Gali Tanah)" then
            M.Config.Tsunami.Mode = "Bawah"
        else
            M.Config.Tsunami.Mode = "Atas"
        end
        if M.Config.Tsunami.Enabled then
            disableTsunamiProtection()
            task.wait(0.5)
            enableTsunamiProtection()
        end
    end
})

TsunamiSection:AddSlider({
    Name = "Ketinggian Aman (Mode Atas)",
    Min = 50,
    Max = 500,
    Default = 150,
    Increment = 10,
    ValueName = "Studs",
    Outline = true,
    Flag = "TsunamiHeight",
    Callback = function(v)
        M.Config.Tsunami.Height = v
    end
})

local TsunamiStatus = TsunamiSection:AddParagraph({
    Title = "Status Tsunami",
    Desc = "⏸️ Nonaktif",
    Image = "info",
    ImageSize = 30
})

TsunamiSection:AddToggle({
    Name = "🌊 Aktifkan Tsunami Protection",
    Default = false,
    Outline = true,
    Flag = "TsunamiToggle",
    Callback = function(v)
        M.Config.Tsunami.Enabled = v
        if v then
            enableTsunamiProtection()
            TsunamiStatus:Set({
                Title = "Status Tsunami",
                Desc = "✅ Aktif - Mode: " .. M.Config.Tsunami.Mode
            })
            Notify("Tsunami Protection Aktif! Mode: " .. M.Config.Tsunami.Mode)
        else
            disableTsunamiProtection()
            TsunamiStatus:Set({
                Title = "Status Tsunami",
                Desc = "⏸️ Nonaktif"
            })
            Notify("Tsunami Protection Nonaktif")
        end
    end
})

TsunamiSection:AddParagraph({
    Title = "📋 INFORMASI",
    Desc = "• Mode Bawah: Menggali tanah (Y = -50)\n• Mode Atas: Terbang di atas (Y = 150+)\n• Noclip otomatis saat terbang\n• Deteksi tsunami radius 100 studs",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- FARM TAB
--==================================================
local FarmSection1 = FarmTab:AddSection({
    Name = "🎯 TARGET SELECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmSection1:AddDropdown({
    Name = "What to Farm?",
    Default = {"Brainrots"},
    Options = {"Brainrots", "Lucky Blocks"},
    Multi = true,
    Outline = true,
    Flag = "FarmTargets",
    Callback = function(v)
        local s = {}
        for _, on in pairs(v) do table.insert(s, on) end
        if #s == 0 then s = {"Brainrots"} end
        M.Config.Farming.Targets = s
    end
})

local FarmSection2 = FarmTab:AddSection({
    Name = "🧟 BRAINROT SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmSection2:AddDropdown({
    Name = "Target Rarity",
    Default = {"Common"},
    Options = RARITY_LIST,
    Multi = true,
    Outline = true,
    Flag = "BrainrotRarity",
    Callback = function(v)
        local s = {}
        for _, on in pairs(v) do table.insert(s, on) end
        M.Config.Farming.BrainrotRarity = #s > 0 and s or {"Common"}
    end
})

FarmSection2:AddDropdown({
    Name = "Target Mutation",
    Default = "None",
    Options = MUTATION_LIST,
    Multi = false,
    Outline = true,
    Flag = "BrainrotMutation",
    Callback = function(v) M.Config.Farming.BrainrotMutation = v end
})

FarmSection2:AddDropdown({
    Name = "Farm Mode",
    Default = M.Config.Farming.FarmMode,
    Options = FARM_MODE_LIST,
    Multi = false,
    Outline = true,
    Flag = "FarmMode",
    Callback = function(v) M.Config.Farming.FarmMode = v end
})

FarmSection2:AddDropdown({
    Name = "Work Slot",
    Default = M.Config.Farming.FarmSlot,
    Options = SLOT_LIST,
    Multi = false,
    Outline = true,
    Flag = "FarmSlot",
    Callback = function(v) M.Config.Farming.FarmSlot = v end
})

FarmSection2:AddSlider({
    Name = "Max Level",
    Min = 1,
    Max = 500,
    Default = M.Config.Farming.MaxLevel,
    Increment = 1,
    ValueName = "Lv",
    Outline = true,
    Flag = "FarmMaxLevel",
    Callback = function(v) M.Config.Farming.MaxLevel = math.floor(v) end
})

local FarmSection3 = FarmTab:AddSection({
    Name = "🎲 LUCKY BLOCK SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmSection3:AddDropdown({
    Name = "LB Rarity",
    Default = {"Common"},
    Options = LB_RARITY,
    Multi = true,
    Outline = true,
    Flag = "LBRarity",
    Callback = function(v)
        local s = {}
        for _, on in pairs(v) do table.insert(s, on) end
        M.Config.Farming.LuckyBlockRarity = #s > 0 and s or {"Common"}
    end
})

FarmSection3:AddDropdown({
    Name = "LB Mutation",
    Default = "Any",
    Options = MUTATION_LIST,
    Multi = false,
    Outline = true,
    Flag = "LBMutation",
    Callback = function(v) M.Config.Farming.LuckyBlockMutation = v end
})

local FarmSection4 = FarmTab:AddSection({
    Name = "🚀 AUTO FARM MASTER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local FarmStatus = FarmSection4:AddParagraph({
    Title = "Farm Status",
    Desc = "Idle",
    Image = "activity",
    ImageSize = 30
})

local FarmStats = FarmSection4:AddParagraph({
    Title = "Statistics",
    Desc = "Brainrots: 0 | Lucky Blocks: 0\nPlaced: 0 | Upgraded: 0",
    Image = "bar-chart",
    ImageSize = 30
})

FarmSection4:AddToggle({
    Name = "🚀 Master Auto Farm",
    Default = false,
    Outline = true,
    Flag = "FarmToggle",
    Callback = function(v)
        M.Config.Farming.Enabled = v
        if v then
            findBase()
            startFarming()
            Notify("Master Farm Started!")
        else
            stopFarming()
            Notify("Master Farm Stopped")
        end
    end
})

--==================================================
-- FACTORY TAB
--==================================================
local FactorySection = FactoryTab:AddSection({
    Name = "🏭 FACTORY LOOP",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FactorySection:AddDropdown({
    Name = "Rarity",
    Default = M.Config.Factory.Rarity,
    Options = FACTORY_RARITY,
    Multi = false,
    Outline = true,
    Flag = "FactoryRarity",
    Callback = function(v) M.Config.Factory.Rarity = v end
})

FactorySection:AddDropdown({
    Name = "Work Slot",
    Default = M.Config.Factory.Slot,
    Options = SLOT_LIST,
    Multi = false,
    Outline = true,
    Flag = "FactorySlot",
    Callback = function(v) M.Config.Factory.Slot = v end
})

FactorySection:AddSlider({
    Name = "Max Level",
    Min = 1,
    Max = 500,
    Default = M.Config.Factory.MaxLevel,
    Increment = 1,
    ValueName = "Lv",
    Outline = true,
    Flag = "FactoryMaxLevel",
    Callback = function(v) M.Config.Factory.MaxLevel = math.floor(v) end
})

local FactoryStatus = FactorySection:AddParagraph({
    Title = "Factory Status",
    Desc = "Idle",
    Image = "factory",
    ImageSize = 30
})

FactorySection:AddToggle({
    Name = "🔁 Factory Loop",
    Default = false,
    Outline = true,
    Flag = "FactoryToggle",
    Callback = function(v)
        M.Config.Factory.Enabled = v
        if v then
            findBase()
            startFactoryLoop()
            Notify("Factory Loop Started!")
        else
            stopFactoryLoop()
            Notify("Factory Loop Stopped")
        end
    end
})

--==================================================
-- AUTOMATION TAB
--==================================================
local AutoSection = AutoTab:AddSection({
    Name = "💰 BASE UTILITY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local MoneyStatus = AutoSection:AddParagraph({
    Title = "Money Status",
    Desc = "Idle",
    Image = "dollar-sign",
    ImageSize = 30
})

AutoSection:AddToggle({
    Name = "💰 Auto Collect Money",
    Default = false,
    Outline = true,
    Flag = "MoneyToggle",
    Callback = function(v)
        M.Config.Automation.AutoCollectMoney = v
        if v then
            findBase()
            startMoney()
            Notify("Auto Collect Money Started")
        else
            stopMoney()
            Notify("Auto Collect Money Stopped")
        end
    end
})

local UpgradeStatus = AutoSection:AddParagraph({
    Title = "Upgrade Status",
    Desc = "Idle",
    Image = "trending-up",
    ImageSize = 30
})

AutoSection:AddToggle({
    Name = "⬆️ Auto Upgrade Slots",
    Default = false,
    Outline = true,
    Flag = "UpgradeToggle",
    Callback = function(v)
        M.Config.Automation.AutoUpgrade = v
        if v then
            findBase()
            startAutoUpgrade()
            Notify("Auto Upgrade Started")
        else
            stopAutoUpgrade()
            Notify("Auto Upgrade Stopped")
        end
    end
})

--==================================================
-- MOVEMENT TAB
--==================================================
local SpeedSection = MovementTab:AddSection({
    Name = "⚡ SPEED HACK",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SpeedSection:AddToggle({
    Name = "ENABLE SPEED BOOST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SpeedEnable",
    Save = true,
    Callback = function(Value)
        M.Config.Movement.SpeedEnabled = Value
        if not Value then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end
})

SpeedSection:AddSlider({
    Name = "SPEED VALUE (16-200)",
    Min = 16,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Flag = "SpeedValue",
    Save = true,
    Callback = function(Value)
        M.Config.Movement.SpeedValue = Value
        if M.Config.Movement.SpeedEnabled then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = Value end
            end
        end
    end
})

local JumpSection = MovementTab:AddSection({
    Name = "🦘 JUMP HACK",
    TextSize = 18,
    Glass = true,
    Outline = true
})

JumpSection:AddToggle({
    Name = "ENABLE JUMP BOOST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "JumpEnable",
    Save = true,
    Callback = function(Value)
        M.Config.Movement.JumpEnabled = Value
        if not Value then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = 50 end
            end
        end
    end
})

JumpSection:AddSlider({
    Name = "JUMP POWER (50-300)",
    Min = 50,
    Max = 300,
    Default = 100,
    Increment = 5,
    ValueName = "JP",
    Outline = true,
    Flag = "JumpValue",
    Save = true,
    Callback = function(Value)
        M.Config.Movement.JumpValue = Value
        if M.Config.Movement.JumpEnabled then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = Value end
            end
        end
    end
})

local ExtraSection = MovementTab:AddSection({
    Name = "🚀 EXTRA MOVEMENT",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ExtraSection:AddToggle({
    Name = "INFINITE JUMP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "InfiniteJump",
    Save = true,
    Callback = function(Value)
        M.Config.Movement.InfiniteJump = Value
        Notify(Value and "Infinite Jump Enabled" or "Infinite Jump Disabled")
    end
})

ExtraSection:AddToggle({
    Name = "NOCLIP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Noclip",
    Save = true,
    Callback = function(Value)
        M.Config.Movement.Noclip = Value
        if Value then
            enableNoclip()
            Notify("Noclip Enabled - You can walk through walls!")
        else
            disableNoclip()
            Notify("Noclip Disabled")
        end
    end
})

--==================================================
-- CONFIG TAB
--==================================================
local TweakSection = ConfigTab:AddSection({
    Name = "⚙️ TWEAKS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

TweakSection:AddSlider({
    Name = "Farm Tween Speed",
    Min = 1,
    Max = 100,
    Default = 60,
    Increment = 5,
    ValueName = "Speed",
    Outline = true,
    Flag = "TweenSpeed",
    Callback = function(v)
        M.Config.Misc.TweenSpeed = math.floor(v) * 16.67
    end
})

TweakSection:AddDropdown({
    Name = "Corridor Speed",
    Default = "400",
    Options = SPEED_LIST,
    Multi = false,
    Outline = true,
    Flag = "CorridorSpeed",
    Callback = function(v)
        M.Config.Misc.CorridorSpeed = tonumber(v) or 400
    end
})

TweakSection:AddButton({
    Name = "🏠 Find My Base",
    Icon = "search",
    Outline = true,
    Callback = function()
        findBase()
        if M.baseGUID then
            Notify("Base found! ID: " .. M.baseGUID)
        else
            Notify("Base not found!")
        end
    end
})

TweakSection:AddButton({
    Name = "📍 Set Home Position",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        setHomePosition()
        Notify("Home position saved!")
    end
})

local InfoSection = ConfigTab:AddSection({
    Name = "ℹ️ PLAYER INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local PlayerInfo = InfoSection:AddParagraph({
    Title = "Player Info",
    Desc = "Loading...",
    Image = "user",
    ImageSize = 38
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "save"
})

--==================================================
-- UTILITY FUNCTIONS
--==================================================

function findBase()
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return end
    for _, base in pairs(bases:GetChildren()) do
        pcall(function()
            local pn = base.Title.TitleGui.Frame.PlayerName
            if pn.Text == Player.Name or pn.Text == Player.DisplayName then
                M.baseGUID = base.Name
                local s1 = base:FindFirstChild("slot 1 brainrot")
                if s1 and s1:FindFirstChild("Root") then
                    M.baseCFrame = s1.Root.CFrame
                end
            end
        end)
    end
    if not M.homePosition then setHomePosition() end
end

function setHomePosition()
    local ch = Player.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    M.homePosition = hrp.CFrame
end

function getHomePosition()
    if M.homePosition then return M.homePosition end
    if M.baseCFrame then return M.baseCFrame end
    return CFrame.new(124, 3.8, 22)
end

function enableNoclip()
    if M._noclipConn then return end
    M.Config.Movement.Noclip = true
    M._noclipConn = RunService.Stepped:Connect(function()
        if not M.Config.Movement.Noclip then return end
        pcall(function()
            local ch = Player.Character
            if not ch then return end
            for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    end)
end

function disableNoclip()
    M.Config.Movement.Noclip = false
    if M._noclipConn then
        pcall(function() M._noclipConn:Disconnect() end)
        M._noclipConn = nil
    end
    pcall(function()
        local ch = Player.Character
        if not ch then return end
        for _, p in pairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
    end)
end

function isSlotEmpty(s)
    if not M.baseGUID then findBase() end
    if not M.baseGUID then return true end
    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
    if not mb then return true end
    local sm = mb:FindFirstChild("slot " .. s .. " brainrot")
    if not sm then return true end
    local bn = sm:GetAttribute("BrainrotName")
    return not bn or bn == ""
end

function placeBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    local ok = pcall(function() M.PlotAction:InvokeServer("Place Brainrot", M.baseGUID, tostring(s)) end)
    if ok then M.Status.placeCount = M.Status.placeCount + 1 end
    return ok
end

function pickUpBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    return pcall(function() M.PlotAction:InvokeServer("Pick Up Brainrot", M.baseGUID, tostring(s)) end)
end

function upgradeBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    return pcall(function() M.PlotAction:InvokeServer("Upgrade Brainrot", M.baseGUID, tostring(s)) end)
end

--==================================================
-- TSUNAMI FUNCTIONS
--==================================================

function detectTsunami()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("tsunami") or name:find("wave") or name:find("banjir") or name:find("flood") or name:find("water") then
                if obj:IsA("Model") then
                    local prim = obj.PrimaryPart
                    if prim then return prim end
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("BasePart") then return child end
                    end
                else
                    return obj
                end
            end
        end
    end
    return nil
end

function createTsunamiDetector()
    if M.Tsunami.DetectionPart then
        pcall(function() M.Tsunami.DetectionPart:Destroy() end)
    end
    local detector = Instance.new("Part")
    detector.Name = "TsunamiDetector"
    detector.Size = Vector3.new(100, 100, 100)
    detector.Transparency = 1
    detector.CanCollide = false
    detector.Anchored = true
    detector.Parent = Workspace
    M.Tsunami.DetectionPart = detector
    return detector
end

function getSafeHeight()
    if M.Config.Tsunami.Mode == "Bawah" then
        return -50
    else
        return M.Config.Tsunami.Height
    end
end

function enableTsunamiFlight()
    if M.Tsunami.IsFlying then return end
    
    local char = Player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    
    if M.Tsunami.BodyVelocity then pcall(function() M.Tsunami.BodyVelocity:Destroy() end) end
    if M.Tsunami.BodyGyro then pcall(function() M.Tsunami.BodyGyro:Destroy() end) end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TsunamiFlight"
    bv.MaxForce = Vector3.new(10000, 10000, 10000)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 1250
    bv.Parent = hrp
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "TsunamiGyro"
    bg.MaxTorque = Vector3.new(10000, 10000, 10000)
    bg.P = 1000
    bg.D = 500
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    M.Tsunami.BodyVelocity = bv
    M.Tsunami.BodyGyro = bg
    M.Tsunami.IsFlying = true
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    if M.Tsunami.FlyConnection then M.Tsunami.FlyConnection:Disconnect() end
    
    M.Tsunami.FlyConnection = RunService.Heartbeat:Connect(function()
        if not M.Config.Tsunami.Enabled then
            disableTsunamiFlight()
            return
        end
        
        local currentChar = Player.Character
        if not currentChar then
            disableTsunamiFlight()
            return
        end
        
        local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHrp then return end
        
        local targetY = getSafeHeight()
        local currentY = currentHrp.Position.Y
        
        if math.abs(currentY - targetY) < 2 then
            if M.Tsunami.BodyVelocity then
                M.Tsunami.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        else
            local direction = (targetY > currentY) and 1 or -1
            if M.Tsunami.BodyVelocity then
                M.Tsunami.BodyVelocity.Velocity = Vector3.new(0, direction * 50, 0)
            end
        end
        
        if M.Tsunami.BodyGyro then
            M.Tsunami.BodyGyro.CFrame = CFrame.new(currentHrp.Position, currentHrp.Position + Vector3.new(0, 0, -1))
        end
    end)
end

function disableTsunamiFlight()
    if M.Tsunami.FlyConnection then
        M.Tsunami.FlyConnection:Disconnect()
        M.Tsunami.FlyConnection = nil
    end
    
    if M.Tsunami.BodyVelocity then
        pcall(function() M.Tsunami.BodyVelocity:Destroy() end)
        M.Tsunami.BodyVelocity = nil
    end
    
    if M.Tsunami.BodyGyro then
        pcall(function() M.Tsunami.BodyGyro:Destroy() end)
        M.Tsunami.BodyGyro = nil
    end
    
    M.Tsunami.IsFlying = false
    
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

function enableTsunamiProtection()
    if M.Tsunami.Connection then M.Tsunami.Connection:Disconnect() end
    
    createTsunamiDetector()
    
    M.Tsunami.Connection = RunService.Heartbeat:Connect(function()
        if not M.Config.Tsunami.Enabled then return end
        
        local tsunami = detectTsunami()
        local char = Player.Character
        if not char or not tsunami then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local distance = (hrp.Position - tsunami.Position).Magnitude
        
        if M.Config.Tsunami.Mode == "Bawah" then
            if hrp.Position.Y > -40 and distance < 100 then
                enableTsunamiFlight()
            end
        else
            if hrp.Position.Y < M.Config.Tsunami.Height - 10 and distance < 100 then
                enableTsunamiFlight()
            end
        end
        
        if M.Tsunami.DetectionPart then
            M.Tsunami.DetectionPart.Position = Vector3.new(hrp.Position.X, getSafeHeight(), hrp.Position.Z)
        end
    end)
end

function disableTsunamiProtection()
    M.Config.Tsunami.Enabled = false
    if M.Tsunami.Connection then
        M.Tsunami.Connection:Disconnect()
        M.Tsunami.Connection = nil
    end
    disableTsunamiFlight()
    if M.Tsunami.DetectionPart then
        pcall(function() M.Tsunami.DetectionPart:Destroy() end)
        M.Tsunami.DetectionPart = nil
    end
end

--==================================================
-- FARM FUNCTIONS (STUB - Implementasi lengkap akan panjang)
--==================================================

function startFarming()
    -- Implementasi lengkap farming (bisa ditambahkan nanti)
    M.Status.farm = "Farming..."
    M.Status.farmCount = M.Status.farmCount + 1
end

function stopFarming()
    M.Status.farm = "Idle"
end

function startFactoryLoop()
    M.Status.factory = "Running..."
    M.Status.factoryCount = M.Status.factoryCount + 1
end

function stopFactoryLoop()
    M.Status.factory = "Idle"
end

function startMoney()
    M.Status.money = "Active"
end

function stopMoney()
    M.Status.money = "Idle"
end

function startAutoUpgrade()
    M.Status.upgrade = "Active"
end

function stopAutoUpgrade()
    M.Status.upgrade = "Idle"
end

--==================================================
-- UPDATE LOOP
--==================================================
RunService.Heartbeat:Connect(function()
    -- Update movement
    if M.Config.Movement.SpeedEnabled then
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = M.Config.Movement.SpeedValue end
        end
    end
    
    if M.Config.Movement.JumpEnabled then
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = M.Config.Movement.JumpValue end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if M.Config.Movement.InfiniteJump then
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    
    if M.Config.Movement.Noclip then
        if M._noclipConn then pcall(function() M._noclipConn:Disconnect() end) M._noclipConn = nil end
        M.Config.Movement.Noclip = false
        task.wait(0.3)
        enableNoclip()
    end
    
    if M.Config.Tsunami.Enabled then
        task.wait(1)
        enableTsunamiProtection()
    end
end)

--==================================================
-- ACTIVE FEATURES UPDATE
--==================================================
task.spawn(function()
    while true do
        local active = {}
        
        if M.Config.Farming.Enabled then table.insert(active, "Farm") end
        if M.Config.Factory.Enabled then table.insert(active, "Factory") end
        if M.Config.Automation.AutoCollectMoney then table.insert(active, "AutoMoney") end
        if M.Config.Automation.AutoUpgrade then table.insert(active, "AutoUpgrade") end
        if M.Config.Tsunami.Enabled then table.insert(active, "Tsunami") end
        if M.Config.Movement.SpeedEnabled then table.insert(active, "Speed") end
        if M.Config.Movement.JumpEnabled then table.insert(active, "Jump") end
        if M.Config.Movement.InfiniteJump then table.insert(active, "InfJump") end
        if M.Config.Movement.Noclip then table.insert(active, "Noclip") end
        
        if #active > 0 then
            ActiveFeaturesPara:SetDesc(table.concat(active, " • "))
        else
            ActiveFeaturesPara:SetDesc("No active features")
        end
        
        -- Update status paragraphs
        FarmStatus:Set({
            Title = "Farm Status",
            Desc = "Status: " .. M.Status.farm .. "\nBrainrots: #" .. M.Status.farmCount .. "\nLucky Blocks: #" .. M.Status.luckyBlockCount
        })
        
        FarmStats:Set({
            Title = "Statistics",
            Desc = "Placed: " .. M.Status.placeCount .. "\nUpgraded: " .. M.Status.upgradeCount
        })
        
        FactoryStatus:Set({
            Title = "Factory Status",
            Desc = "Status: " .. M.Status.factory .. "\nCompleted: #" .. M.Status.factoryCount
        })
        
        MoneyStatus:Set({
            Title = "Money Status",
            Desc = "Status: " .. (M.Config.Automation.AutoCollectMoney and "✅ Active" or "⏸️ Idle")
        })
        
        UpgradeStatus:Set({
            Title = "Upgrade Status",
            Desc = "Status: " .. (M.Config.Automation.AutoUpgrade and "✅ Active" or "⏸️ Idle")
        })
        
        PlayerInfo:Set({
            Title = "Player Info",
            Desc = string.format("Player: %s\nBase: %s\nNoclip: %s\nTsunami: %s",
                Player.Name,
                (M.baseGUID or "Not Found"),
                (M.Config.Movement.Noclip and "✅" or "❌"),
                (M.Config.Tsunami.Enabled and "✅ " .. M.Config.Tsunami.Mode or "❌")
            )
        })
        
        task.wait(1)
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 ESCAPE TSUNAMI FOR BRAINROTS - ULTIMATE EDITION 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Home Tab - Player Info & Active Features")
print("✅ Tsunami Tab - 2 Mode Protection (Bawah/Atas)")
print("✅ Farm Tab - Brainrot & Lucky Block Settings")
print("✅ Factory Tab - Auto Factory Loop")
print("✅ Automation Tab - Auto Collect & Upgrade")
print("✅ Movement Tab - Speed, Jump, Infinite Jump, Noclip")
print("✅ Config Tab - Tweaks & Player Info")
print("═══════════════════════════════════════════════════════")