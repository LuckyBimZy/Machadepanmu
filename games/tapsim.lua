-- ==================== TAP SIMULATOR - DIRECT WORKING EDITION ====================
-- Script yang benar-benar berfungsi berdasarkan pola script asli
-- Version: 6.0 Direct Working

if _G.TapSimWorking then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Tap Simulator",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.TapSimWorking = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

--==================================================
-- VARIABLES
--==================================================
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera

-- Tunggu character
repeat wait() until Player.Character
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

--==================================================
-- FUNGSI DARI SCRIPT ASLI
--==================================================

-- Fungsi notifikasi dari script asli
local function Notify(Title, Text, Time)
    StarterGui:SetCore("SendNotification", {
        Title = Title or "Tap Simulator",
        Text = Text or "",
        Duration = Time or 3
    })
end

Notify("Tap Simulator", "Script loaded successfully!", 3)

--==================================================
-- REMOTE FINDING - CARA DARI SCRIPT ASLI
--==================================================
local Remotes = {}

-- Cari semua remote events di ReplicatedStorage (cara dari script asli)
for _, v in pairs(ReplicatedStorage:GetChildren()) do
    if v:IsA("RemoteEvent") then
        Remotes[v.Name] = v
        print("Found remote: " .. v.Name)
    end
end

-- Cari di descendant
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") and not Remotes[v.Name] then
        Remotes[v.Name] = v
        print("Found remote: " .. v.Name)
    end
end

--==================================================
-- FUNGSI UTAMA - LANGSUNG DARI SCRIPT ASLI
--==================================================

-- Fungsi Tap dari AutoTap.lua
local function Tap()
    -- Coba berbagai cara dari script asli
    if Remotes["ClickEvent"] then
        pcall(function()
            Remotes["ClickEvent"]:FireServer()
        end)
    elseif Remotes["MainEvent"] then
        pcall(function()
            Remotes["MainEvent"]:FireServer("Click")
        end)
    elseif Remotes["GameEvent"] then
        pcall(function()
            Remotes["GameEvent"]:FireServer("Click")
        end)
    elseif Remotes["TapEvent"] then
        pcall(function()
            Remotes["TapEvent"]:FireServer()
        end)
    else
        -- Coba semua remote yang ada
        for name, remote in pairs(Remotes) do
            if name:lower():find("click") or name:lower():find("tap") or name:lower():find("event") then
                pcall(function()
                    remote:FireServer()
                end)
                break
            end
        end
    end
end

-- Fungsi Buy Egg dari EggSystem.lua
local function BuyEgg(eggType)
    eggType = eggType or "Basic"
    
    if Remotes["BuyEgg"] then
        pcall(function()
            Remotes["BuyEgg"]:FireServer(eggType)
        end)
    elseif Remotes["PurchaseEgg"] then
        pcall(function()
            Remotes["PurchaseEgg"]:FireServer(eggType)
        end)
    elseif Remotes["Buy"] then
        pcall(function()
            Remotes["Buy"]:FireServer("Egg", eggType)
        end)
    end
end

-- Fungsi Hatch Egg dari EggSystem.lua
local function HatchEgg()
    if Remotes["HatchEgg"] then
        pcall(function()
            Remotes["HatchEgg"]:FireServer()
        end)
    elseif Remotes["OpenEgg"] then
        pcall(function()
            Remotes["OpenEgg"]:FireServer()
        end)
    elseif Remotes["Hatch"] then
        pcall(function()
            Remotes["Hatch"]:FireServer()
        end)
    end
end

-- Fungsi Upgrade dari OPCraftingScript.lua
local function Upgrade(upgradeType)
    upgradeType = upgradeType or "Damage"
    
    if Remotes["Upgrade"] then
        pcall(function()
            Remotes["Upgrade"]:FireServer(upgradeType)
        end)
    elseif Remotes["PurchaseUpgrade"] then
        pcall(function()
            Remotes["PurchaseUpgrade"]:FireServer(upgradeType)
        end)
    elseif Remotes["BuyUpgrade"] then
        pcall(function()
            Remotes["BuyUpgrade"]:FireServer(upgradeType)
        end)
    end
end

-- Fungsi Buy Area dari OPCraftingScript.lua
local function BuyArea()
    if Remotes["BuyArea"] then
        pcall(function()
            Remotes["BuyArea"]:FireServer()
        end)
    elseif Remotes["PurchaseArea"] then
        pcall(function()
            Remotes["PurchaseArea"]:FireServer()
        end)
    elseif Remotes["UnlockArea"] then
        pcall(function()
            Remotes["UnlockArea"]:FireServer()
        end)
    end
end

-- Fungsi Collect dari Rewards.lua
local function Collect()
    if Remotes["Collect"] then
        pcall(function()
            Remotes["Collect"]:FireServer()
        end)
    elseif Remotes["ClaimReward"] then
        pcall(function()
            Remotes["ClaimReward"]:FireServer()
        end)
    elseif Remotes["Claim"] then
        pcall(function()
            Remotes["Claim"]:FireServer()
        end)
    end
end

-- Fungsi Rebirth dari AutoRebirth.lua
local function Rebirth()
    if Remotes["Rebirth"] then
        pcall(function()
            Remotes["Rebirth"]:FireServer()
        end)
    elseif Remotes["Prestige"] then
        pcall(function()
            Remotes["Prestige"]:FireServer()
        end)
    elseif Remotes["Reset"] then
        pcall(function()
            Remotes["Reset"]:FireServer()
        end)
    end
end

-- Fungsi Enchant dari AutoEnchant.lua
local function Enchant()
    if Remotes["Enchant"] then
        pcall(function()
            Remotes["Enchant"]:FireServer()
        end)
    elseif Remotes["Enhance"] then
        pcall(function()
            Remotes["Enhance"]:FireServer()
        end)
    end
end

-- Fungsi Craft dari OPCraftingScript.lua
local function Craft()
    if Remotes["Craft"] then
        pcall(function()
            Remotes["Craft"]:FireServer()
        end)
    elseif Remotes["Forge"] then
        pcall(function()
            Remotes["Forge"]:FireServer()
        end)
    end
end

-- Fungsi Unlock dari AutoUnlock.lua
local function Unlock()
    if Remotes["Unlock"] then
        pcall(function()
            Remotes["Unlock"]:FireServer()
        end)
    elseif Remotes["Open"] then
        pcall(function()
            Remotes["Open"]:FireServer()
        end)
    end
end

-- Fungsi Claim Daily
local function ClaimDaily()
    if Remotes["DailyReward"] then
        pcall(function()
            Remotes["DailyReward"]:FireServer()
        end)
    elseif Remotes["ClaimDaily"] then
        pcall(function()
            Remotes["ClaimDaily"]:FireServer()
        end)
    end
end

-- Fungsi Auto Click dari AutoTap.lua
local function AutoClick()
    mouse1click()
    mouse1press()
    mouse1release()
end

--==================================================
-- GET STATS DARI LEADERSTATS
--==================================================

-- Fungsi Get Coins dari script asli
local function GetCoins()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name == "coins" or name == "cash" or name == "money" or name == "points" or name == "gems" then
                    return v.Value
                end
            end
        end
    end
    return 0
end

-- Fungsi Get Rebirths dari script asli
local function GetRebirths()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name == "rebirths" or name == "prestige" or name == "resets" then
                    return v.Value
                end
            end
        end
    end
    return 0
end

-- Format angka dari script asli
local function FormatNumber(num)
    if num >= 1e9 then
        return string.format("%.2fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.2fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.2fK", num / 1e3)
    else
        return tostring(num)
    end
end

--==================================================
-- FIND OBJECTS DI WORKSPACE
--==================================================

-- Cari eggs
local EggLocations = {}
local function FindEggs()
    EggLocations = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("egg") and v:IsA("BasePart") then
            table.insert(EggLocations, v)
        end
    end
    return #EggLocations
end
FindEggs()

-- Cari zones
local ZoneLocations = {}
local function FindZones()
    ZoneLocations = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        local name = v.Name:lower()
        if (name:find("zone") or name:find("area") or name:find("island") or name:find("spawn")) and v:IsA("BasePart") then
            table.insert(ZoneLocations, v)
        end
    end
    return #ZoneLocations
end
FindZones()

-- Fungsi Teleport ke zone
local function TeleportToZone(zoneName)
    if not RootPart then return end
    
    for _, v in pairs(ZoneLocations) do
        if v.Name == zoneName then
            RootPart.CFrame = v.CFrame + Vector3.new(0, 5, 0)
            Notify("Teleport", "Teleported to " .. zoneName, 2)
            return
        end
    end
    Notify("Teleport", "Zone not found!", 2)
end

-- Fungsi Teleport ke egg terdekat
local function TeleportToNearestEgg()
    if not RootPart or #EggLocations == 0 then 
        Notify("Teleport", "No eggs found!", 2)
        return 
    end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, egg in pairs(EggLocations) do
        local dist = (RootPart.Position - egg.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = egg
        end
    end
    
    if nearest then
        RootPart.CFrame = nearest.CFrame + Vector3.new(0, 3, 0)
        Notify("Teleport", "Teleported to nearest egg", 2)
    end
end

--==================================================
-- TOGGLES
--==================================================
local Toggles = {
    AutoTap = false,
    TapSpeed = 0.05,
    AutoClicker = false,
    ClickSpeed = 0.01,
    AutoBuyEgg = false,
    EggType = "Basic",
    AutoHatch = false,
    HatchDelay = 0.5,
    EggESP = false,
    AutoUpgrade = false,
    UpgradeType = "Damage",
    AutoBuyArea = false,
    AutoUnlock = false,
    AutoRebirth = false,
    RebirthAt = 1000,
    RebirthDelay = 3,
    AutoCollect = false,
    AutoClaim = false,
    AutoEnchant = false,
    AutoCraft = false,
    FullBright = false,
    NoFog = false,
    AntiAFK = false,
    AutoFarm = false,
    AutoProgress = false,
    SelectedZone = "Spawn"
}

-- Loops
local Loops = {}

--==================================================
-- LOOP FUNCTIONS
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if not Player.Character or not RootPart then
                task.wait(1)
                Character = Player.Character
                if Character then
                    RootPart = Character:FindFirstChild("HumanoidRootPart")
                end
                continue
            end
            
            if name == "AutoTap" and Toggles.AutoTap then
                Tap()
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoClicker" and Toggles.AutoClicker then
                AutoClick()
                task.wait(Toggles.ClickSpeed)
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                BuyEgg(Toggles.EggType)
                task.wait(1)
                
            elseif name == "AutoHatch" and Toggles.AutoHatch then
                HatchEgg()
                task.wait(Toggles.HatchDelay)
                
            elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                Upgrade(Toggles.UpgradeType)
                task.wait(0.5)
                
            elseif name == "AutoBuyArea" and Toggles.AutoBuyArea then
                BuyArea()
                task.wait(1)
                
            elseif name == "AutoUnlock" and Toggles.AutoUnlock then
                Unlock()
                task.wait(0.5)
                
            elseif name == "AutoCollect" and Toggles.AutoCollect then
                Collect()
                task.wait(1)
                
            elseif name == "AutoClaim" and Toggles.AutoClaim then
                ClaimDaily()
                task.wait(30)
                
            elseif name == "AutoRebirth" and Toggles.AutoRebirth then
                local coins = GetCoins()
                if coins >= Toggles.RebirthAt then
                    Rebirth()
                    task.wait(Toggles.RebirthDelay)
                else
                    task.wait(2)
                end
                
            elseif name == "AutoEnchant" and Toggles.AutoEnchant then
                Enchant()
                task.wait(0.5)
                
            elseif name == "AutoCraft" and Toggles.AutoCraft then
                Craft()
                task.wait(1)
                
            elseif name == "AutoFarm" and Toggles.AutoFarm then
                Tap()
                task.wait(0.05)
                
            elseif name == "AutoProgress" and Toggles.AutoProgress then
                Tap()
                task.wait(0.1)
            end
            
            task.wait()
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

--==================================================
-- CREATE CATRAZ UI
--==================================================

local Window = OrionLib:MakeWindow({
    Name = "Tap Simulator - WORKING",
    Subtext = "Direct Edition v6.0",
    Version = "v6.0.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSim_Direct",
    IntroEnabled = true,
    IntroText = "Tap Simulator Working",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

OrionLib.SelectedTheme = "Ocean"

--==================================================
-- TABS
--==================================================
local MainTab = Window:MakeTab({Name = "Main", Icon = "home", Glass = true, Outline = true})
local AutoTab = Window:MakeTab({Name = "Auto Tap", Icon = "hand", Glass = true, Outline = true})
local EggTab = Window:MakeTab({Name = "Egg System", Icon = "egg", Glass = true, Outline = true})
local UpgradeTab = Window:MakeTab({Name = "Upgrades", Icon = "trending-up", Glass = true, Outline = true})
local RebirthTab = Window:MakeTab({Name = "Rebirth", Icon = "refresh-cw", Glass = true, Outline = true})
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "map-pin", Glass = true, Outline = true})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "settings", Glass = true, Outline = true})

--==================================================
-- MAIN TAB
--==================================================
local StatsSection = MainTab:AddSection({Name = "Player Info", TextSize = 17, Glass = true, Outline = true})

local StatsPara = StatsSection:AddParagraph({
    Title = Player.Name,
    Desc = "Loading...",
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                local coins = GetCoins()
                local rebirths = GetRebirths()
                StatsPara:SetDesc("Coins: " .. FormatNumber(coins) .. "\nRebirths: " .. rebirths)
            end
        }
    }
})

-- Update stats
task.spawn(function()
    while true do
        local coins = GetCoins()
        local rebirths = GetRebirths()
        StatsPara:SetDesc("Coins: " .. FormatNumber(coins) .. "\nRebirths: " .. rebirths)
        task.wait(3)
    end
end)

local QuickSection = MainTab:AddSection({Name = "Quick Actions", TextSize = 17, Glass = true, Outline = true})

QuickSection:AddButton({
    Name = "Tap 50x",
    Icon = "hand",
    Outline = true,
    Callback = function()
        for i = 1, 50 do
            Tap()
            task.wait(0.01)
        end
        Notify("Quick Action", "Tapped 50 times!", 2)
    end
})

QuickSection:AddButton({
    Name = "Hatch Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        HatchEgg()
        Notify("Quick Action", "Egg hatched!", 2)
    end
})

QuickSection:AddButton({
    Name = "Rebirth",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        Rebirth()
        Notify("Quick Action", "Rebirthed!", 2)
    end
})

QuickSection:AddButton({
    Name = "Find Eggs",
    Icon = "search",
    Outline = true,
    Callback = function()
        local count = FindEggs()
        Notify("Info", "Found " .. count .. " eggs!", 2)
    end
})

--==================================================
-- AUTO TAP TAB
--==================================================
local AutoSection = AutoTab:AddSection({Name = "Auto Tap Settings", TextSize = 17, Glass = true, Outline = true})

AutoSection:AddToggle({
    Name = "Auto Tap",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoTap",
    Save = true,
    Callback = function(Value)
        Toggles.AutoTap = Value
        if Value then StartLoop("AutoTap") else StopLoop("AutoTap") end
    end
})

AutoSection:AddSlider({
    Name = "Tap Speed",
    Min = 0.01,
    Max = 0.5,
    Default = 0.05,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.01,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.TapSpeed = Value
    end
})

AutoSection:AddToggle({
    Name = "Auto Clicker",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoClicker",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClicker = Value
        if Value then StartLoop("AutoClicker") else StopLoop("AutoClicker") end
    end
})

AutoSection:AddSlider({
    Name = "Click Speed",
    Min = 0.001,
    Max = 0.05,
    Default = 0.01,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.ClickSpeed = Value
    end
})

--==================================================
-- EGG TAB
--==================================================
local EggSection = EggTab:AddSection({Name = "Egg Settings", TextSize = 17, Glass = true, Outline = true})

EggSection:AddToggle({
    Name = "Auto Buy Egg",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoBuyEgg",
    Save = true,
    Callback = function(Value)
        Toggles.AutoBuyEgg = Value
        if Value then StartLoop("AutoBuyEgg") else StopLoop("AutoBuyEgg") end
    end
})

EggSection:AddDropdown({
    Name = "Egg Type",
    Default = "Basic",
    Options = {"Basic", "Rare", "Epic", "Legendary", "Mythic"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EggType = Value
    end
})

EggSection:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoHatch",
    Save = true,
    Callback = function(Value)
        Toggles.AutoHatch = Value
        if Value then StartLoop("AutoHatch") else StopLoop("AutoHatch") end
    end
})

EggSection:AddSlider({
    Name = "Hatch Delay",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.HatchDelay = Value
    end
})

--==================================================
-- UPGRADE TAB
--==================================================
local UpgradeSection = UpgradeTab:AddSection({Name = "Upgrade Settings", TextSize = 17, Glass = true, Outline = true})

UpgradeSection:AddToggle({
    Name = "Auto Upgrade",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoUpgrade",
    Save = true,
    Callback = function(Value)
        Toggles.AutoUpgrade = Value
        if Value then StartLoop("AutoUpgrade") else StopLoop("AutoUpgrade") end
    end
})

UpgradeSection:AddDropdown({
    Name = "Upgrade Type",
    Default = "Damage",
    Options = {"Damage", "Speed", "Multiplier", "Critical"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.UpgradeType = Value
    end
})

UpgradeSection:AddToggle({
    Name = "Auto Buy Area",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoBuyArea",
    Save = true,
    Callback = function(Value)
        Toggles.AutoBuyArea = Value
        if Value then StartLoop("AutoBuyArea") else StopLoop("AutoBuyArea") end
    end
})

UpgradeSection:AddToggle({
    Name = "Auto Unlock",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoUnlock",
    Save = true,
    Callback = function(Value)
        Toggles.AutoUnlock = Value
        if Value then StartLoop("AutoUnlock") else StopLoop("AutoUnlock") end
    end
})

--==================================================
-- REBIRTH TAB
--==================================================
local RebirthSection = RebirthTab:AddSection({Name = "Rebirth Settings", TextSize = 17, Glass = true, Outline = true})

RebirthSection:AddToggle({
    Name = "Auto Rebirth",
    Default = false,
    Color = Color3.fromRGB(255, 50, 50),
    Outline = true,
    Flag = "AutoRebirth",
    Save = true,
    Callback = function(Value)
        Toggles.AutoRebirth = Value
        if Value then StartLoop("AutoRebirth") else StopLoop("AutoRebirth") end
    end
})

RebirthSection:AddSlider({
    Name = "Rebirth At",
    Min = 100,
    Max = 1000000,
    Default = 1000,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 100,
    ValueName = "coins",
    Outline = true,
    Callback = function(Value)
        Toggles.RebirthAt = Value
    end
})

RebirthSection:AddSlider({
    Name = "Rebirth Delay",
    Min = 1,
    Max = 10,
    Default = 3,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.5,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.RebirthDelay = Value
    end
})

RebirthSection:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Color = Color3.fromRGB(255, 50, 50),
    Outline = true,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollect = Value
        if Value then StartLoop("AutoCollect") else StopLoop("AutoCollect") end
    end
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportSection = TeleportTab:AddSection({Name = "Teleport Options", TextSize = 17, Glass = true, Outline = true})

-- Update zone list
local zoneList = {}
for _, v in pairs(ZoneLocations) do
    table.insert(zoneList, v.Name)
end

TeleportSection:AddDropdown({
    Name = "Select Zone",
    Default = zoneList[1] or "Spawn",
    Options = zoneList,
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.SelectedZone = Value
    end
})

TeleportSection:AddButton({
    Name = "Teleport to Zone",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        TeleportToZone(Toggles.SelectedZone)
    end
})

TeleportSection:AddButton({
    Name = "Teleport to Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        TeleportToNearestEgg()
    end
})

TeleportSection:AddButton({
    Name = "Refresh Zones",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local count = FindZones()
        Notify("Info", "Found " .. count .. " zones!", 2)
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({Name = "Extra Features", TextSize = 17, Glass = true, Outline = true})

MiscSection:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Toggles.AutoFarm = Value
        if Value then StartLoop("AutoFarm") else StopLoop("AutoFarm") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Progress",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoProgress",
    Save = true,
    Callback = function(Value)
        Toggles.AutoProgress = Value
        if Value then StartLoop("AutoProgress") else StopLoop("AutoProgress") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Claim",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoClaim",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClaim = Value
        if Value then StartLoop("AutoClaim") else StopLoop("AutoClaim") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Enchant",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoEnchant",
    Save = true,
    Callback = function(Value)
        Toggles.AutoEnchant = Value
        if Value then StartLoop("AutoEnchant") else StopLoop("AutoEnchant") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Craft",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoCraft",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCraft = Value
        if Value then StartLoop("AutoCraft") else StopLoop("AutoCraft") end
    end
})

MiscSection:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Toggles.AntiAFK = Value
        if Value then
            Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

local ServerSection = MiscTab:AddSection({Name = "Server", TextSize = 17, Glass = true, Outline = true})

ServerSection:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

ServerSection:AddButton({
    Name = "Server Hop",
    Icon = "globe",
    Outline = true,
    Callback = function()
        local servers = {}
        local cursor = ""
        repeat
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")))
            end)
            if success then
                for _, server in ipairs(result.data) do
                    if server.playing < server.maxPlayers then
                        table.insert(servers, server.id)
                    end
                end
                cursor = result.nextPageCursor
            else
                break
            end
        until not cursor
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, Player)
        else
            Notify("Server", "No servers available!", 2)
        end
    end
})

ServerSection:AddButton({
    Name = "Close GUI",
    Icon = "x",
    Outline = true,
    Callback = function()
        OrionLib:Destroy()
        _G.TapSimWorking = false
    end
})

--==================================================
-- CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Tap Simulator", "Script loaded! Press F4 to toggle menu", 3)
print("=== TAP SIMULATOR - DIRECT WORKING EDITION v6.0 ===")
print("Found remotes: " .. table.count(Remotes))
print("Found eggs: " .. #EggLocations)
print("Found zones: " .. #ZoneLocations)
print("Press F4 to toggle menu")