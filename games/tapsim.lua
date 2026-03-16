-- ==================== TAP SIMULATOR - CATRAZ EDITION ====================
-- Premium Auto Farm Script untuk Tap Simulator
-- Author: Adapted for Catraz Hub
-- Version: 1.0

--==================================================
-- NOTIFIKASI AWAL
--==================================================
local function ShowExecutionNotification()
    -- Notifikasi pertama menggunakan Roblox Core
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Tap Simulator",
        Text = "Script is loading... Please wait",
        Duration = 3,
        Icon = "rbxassetid://8834748103"
    })
    
    -- Print di console
    print("=== Tap Simulator Script ===")
    print("Loading script...")
    print("============================")
end

ShowExecutionNotification()

--==================================================
-- CEK DUPLICATE SCRIPT
--==================================================
if _G.TapSimLoaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Tap Simulator",
        Text = "Script already loaded!",
        Duration = 2,
        Icon = "rbxassetid://8834748103"
    })
    return 
end

_G.TapSimLoaded = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY DENGAN ERROR HANDLING
--==================================================
local OrionLib
local loadSuccess, loadError = pcall(function()
    OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()
end)

if not loadSuccess or not OrionLib then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ERROR",
        Text = "Failed to load UI Library! Check internet connection.",
        Duration = 5,
        Icon = "rbxassetid://8834748103"
    })
    print("Failed to load Catraz Hub:", loadError)
    _G.TapSimLoaded = false
    return
end

-- Notifikasi library berhasil dimuat
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Tap Simulator",
    Text = "UI Library loaded successfully!",
    Duration = 2,
    Icon = "rbxassetid://8834748103"
})

--==================================================
-- VARIABLES
--==================================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Cari Remote Events/Functions
local Remotes = {
    Tap = nil,
    BuyEgg = nil,
    HatchEgg = nil,
    BuyArea = nil,
    Upgrade = nil,
    Collect = nil,
    Rebirth = nil
}

-- Fungsi untuk mencari remotes
local function FindRemotes()
    print("Searching for remotes...")
    
    -- Cari di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("tap") or name:find("click") then
                Remotes.Tap = v
            elseif name:find("egg") or name:find("hatch") then
                Remotes.HatchEgg = v
            elseif name:find("buy") and (name:find("egg") or name:find("area")) then
                if name:find("egg") then
                    Remotes.BuyEgg = v
                elseif name:find("area") then
                    Remotes.BuyArea = v
                end
            elseif name:find("upgrade") or name:find("power") then
                Remotes.Upgrade = v
            elseif name:find("collect") or name:find("claim") then
                Remotes.Collect = v
            elseif name:find("rebirth") or name:find("prestige") then
                Remotes.Rebirth = v
            end
        end
    end
    
    -- Cari di Player scripts
    for _, v in pairs(Player.PlayerScripts:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("tap") or name:find("click") and not Remotes.Tap then
                Remotes.Tap = v
            end
        end
    end
    
    print("=== REMOTES FOUND ===")
    for k, v in pairs(Remotes) do
        print(k, v and "✓" or "✗")
    end
end

FindRemotes()

-- Toggles
local Toggles = {
    -- Auto Farm
    AutoTap = false,
    TapSpeed = 0.01,
    AutoClicker = false,
    ClickSpeed = 0.001,
    
    -- Eggs
    AutoBuyEgg = false,
    EggType = "Basic",
    AutoHatch = false,
    
    -- Upgrades
    AutoUpgrade = false,
    UpgradeType = "All",
    AutoBuyArea = false,
    
    -- Collection
    AutoCollect = false,
    AutoRebirth = false,
    RebirthAt = 1000,
    
    -- Visuals
    ESP = false,
    FullBright = false,
    NoFog = false,
    
    -- Misc
    AntiAFK = false,
    AutoClaim = false
}

-- Loops
local Loops = {}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    -- Gunakan kedua metode notifikasi
    pcall(function()
        OrionLib:MakeNotification({
            Name = "Tap Simulator",
            Content = msg,
            Image = "zap",
            Time = 2.5
        })
    end)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Tap Simulator",
        Text = msg,
        Duration = 2,
        Icon = "rbxassetid://8834748103"
    })
end

--==================================================
-- CREATE MAIN WINDOW DENGAN ERROR HANDLING
--==================================================
local Window
local windowSuccess, windowError = pcall(function()
    Window = OrionLib:MakeWindow({
        Name = "Tap Simulator",
        Subtext = "Auto Farm Premium",
        Version = "v1.0.0",
        VersionIcon = "zap",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "TapSim_Config",
        IntroEnabled = true,
        IntroText = "Tap Simulator",
        IntroIcon = "rbxassetid://8834748103",
        Icon = "rbxassetid://8834748103",
        ShowIcon = true,
        
        -- Custom Theme
        ImageBackground = "",
        ImageTransparency = 0.8,
        WindowTransparency = 0.05,
        
        -- Floating Toggle
        ToggleIcon = "rbxassetid://105921924721005",
        ToggleSize = 50
    })
end)

if not windowSuccess or not Window then
    Notify("Failed to create UI window!")
    print("Window creation error:", windowError)
    _G.TapSimLoaded = false
    return
end

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

-- Notifikasi sukses
Notify("Script loaded successfully! Press F4 to open menu")
print("=== Tap Simulator Script Loaded ===")
print("Press F4 to toggle menu")
print("===================================")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local EggsTab = Window:MakeTab({
    Name = "Eggs",
    Icon = "egg",
    Glass = true,
    Outline = true
})

local UpgradeTab = Window:MakeTab({
    Name = "Upgrades",
    Icon = "trending-up",
    Glass = true,
    Outline = true
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "eye",
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
-- UTILITY FUNCTIONS
--==================================================

-- Tap/Click function
local function Tap()
    if Remotes.Tap then
        pcall(function()
            if Remotes.Tap:IsA("RemoteEvent") then
                Remotes.Tap:FireServer()
            elseif Remotes.Tap:IsA("RemoteFunction") then
                Remotes.Tap:InvokeServer()
            end
        end)
    else
        -- Fallback: Try to find any remote that might work
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and not v.Name:find("Character") then
                pcall(function() v:FireServer() end)
                break
            end
        end
    end
end

-- Get coins/points
local function GetCoins()
    -- Coba berbagai cara untuk mendapatkan jumlah coins
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash") or v.Name:lower():find("point")) then
                return v.Value
            end
        end
    end
    
    -- Cari di player
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
            return v.Value
        end
    end
    
    return 0
end

-- Get rebirths
local function GetRebirths()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("rebirth") or v.Name:lower():find("prestige")) then
                return v.Value
            end
        end
    end
    return 0
end

-- Format angka
local function formatNumber(num)
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

-- Buy egg function
local function BuyEgg(eggType)
    if Remotes.BuyEgg then
        pcall(function() Remotes.BuyEgg:FireServer(eggType) end)
    else
        -- Coba remote umum
        local remote = ReplicatedStorage:FindFirstChild("BuyEgg") or 
                      ReplicatedStorage:FindFirstChild("PurchaseEgg")
        if remote then
            pcall(function() remote:FireServer(eggType) end)
        end
    end
end

-- Hatch egg function
local function HatchEgg()
    if Remotes.HatchEgg then
        pcall(function() Remotes.HatchEgg:FireServer() end)
    else
        local remote = ReplicatedStorage:FindFirstChild("HatchEgg") or 
                      ReplicatedStorage:FindFirstChild("OpenEgg")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Upgrade function
local function Upgrade(upgradeType)
    if Remotes.Upgrade then
        pcall(function() Remotes.Upgrade:FireServer(upgradeType) end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Upgrade") or 
                      ReplicatedStorage:FindFirstChild("PurchaseUpgrade")
        if remote then
            pcall(function() remote:FireServer(upgradeType) end)
        end
    end
end

-- Buy area function
local function BuyArea()
    if Remotes.BuyArea then
        pcall(function() Remotes.BuyArea:FireServer() end)
    else
        local remote = ReplicatedStorage:FindFirstChild("BuyArea") or 
                      ReplicatedStorage:FindFirstChild("PurchaseArea")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Collect rewards
local function Collect()
    if Remotes.Collect then
        pcall(function() Remotes.Collect:FireServer() end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Collect") or 
                      ReplicatedStorage:FindFirstChild("ClaimReward")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Rebirth function
local function Rebirth()
    if Remotes.Rebirth then
        pcall(function() Remotes.Rebirth:FireServer() end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Rebirth") or 
                      ReplicatedStorage:FindFirstChild("Prestige")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

--==================================================
-- LOOP FUNCTIONS
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if name == "AutoTap" and Toggles.AutoTap then
                Tap()
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoClicker" and Toggles.AutoClicker then
                -- Simulate mouse click
                mouse1click()
                task.wait(Toggles.ClickSpeed)
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                BuyEgg(Toggles.EggType)
                task.wait(1)
                
            elseif name == "AutoHatch" and Toggles.AutoHatch then
                HatchEgg()
                task.wait(0.5)
                
            elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                if Toggles.UpgradeType == "All" then
                    -- Try to upgrade everything
                    Upgrade("All")
                    Upgrade("Damage")
                    Upgrade("Speed")
                    Upgrade("Multiplier")
                else
                    Upgrade(Toggles.UpgradeType)
                end
                task.wait(1)
                
            elseif name == "AutoBuyArea" and Toggles.AutoBuyArea then
                BuyArea()
                task.wait(2)
                
            elseif name == "AutoCollect" and Toggles.AutoCollect then
                Collect()
                task.wait(5)
                
            elseif name == "AutoRebirth" and Toggles.AutoRebirth then
                local coins = GetCoins()
                if coins >= Toggles.RebirthAt then
                    Rebirth()
                    task.wait(3)
                else
                    task.wait(5)
                end
                
            elseif name == "AutoClaim" and Toggles.AutoClaim then
                -- Claim daily rewards etc
                local claimRemote = ReplicatedStorage:FindFirstChild("ClaimDaily") or 
                                   ReplicatedStorage:FindFirstChild("DailyReward")
                if claimRemote then
                    pcall(function() claimRemote:FireServer() end)
                end
                task.wait(60) -- Check every minute
            end
            
            task.wait()
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

--==================================================
-- MAIN TAB CONTENT
--==================================================
local StatsSection = MainTab:AddSection({
    Name = "Player Stats",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Paragraph yang akan diupdate
local StatsPara = StatsSection:AddParagraph({
    Title = Player.Name,
    Desc = "Loading stats...",
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                local coins = GetCoins()
                local rebirths = GetRebirths()
                StatsPara:SetDesc("Coins: " .. formatNumber(coins) .. "\nRebirths: " .. rebirths)
                Notify("Stats refreshed!")
            end
        }
    }
})

-- Update stats setiap 5 detik
task.spawn(function()
    while true do
        local coins = GetCoins()
        local rebirths = GetRebirths()
        StatsPara:SetDesc("Coins: " .. formatNumber(coins) .. "\nRebirths: " .. rebirths)
        task.wait(5)
    end
end)

local QuickSection = MainTab:AddSection({
    Name = "Quick Actions",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

QuickSection:AddButton({
    Name = "Tap Now!",
    Icon = "hand",
    Outline = true,
    Callback = function()
        for i = 1, 10 do
            Tap()
            task.wait(0.05)
        end
        Notify("Tapped 10 times!")
    end
})

QuickSection:AddButton({
    Name = "Hatch Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        HatchEgg()
        Notify("Hatched egg!")
    end
})

--==================================================
-- AUTO FARM TAB
--==================================================
local TapSection = FarmTab:AddSection({
    Name = "Auto Tap",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

TapSection:AddToggle({
    Name = "Auto Tap",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoTap",
    Save = true,
    Callback = function(Value)
        Toggles.AutoTap = Value
        if Value then 
            StartLoop("AutoTap")
            Notify("Auto Tap enabled")
        else 
            StopLoop("AutoTap")
            Notify("Auto Tap disabled")
        end
    end
})

TapSection:AddSlider({
    Name = "Tap Speed",
    Min = 0.001,
    Max = 0.1,
    Default = 0.01,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.TapSpeed = Value
    end
})

TapSection:AddToggle({
    Name = "Auto Clicker",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoClicker",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClicker = Value
        if Value then 
            StartLoop("AutoClicker")
            Notify("Auto Clicker enabled")
        else 
            StopLoop("AutoClicker")
            Notify("Auto Clicker disabled")
        end
    end
})

local CollectSection = FarmTab:AddSection({
    Name = "Auto Collection",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

CollectSection:AddToggle({
    Name = "Auto Collect Rewards",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollect = Value
        if Value then 
            StartLoop("AutoCollect")
            Notify("Auto Collect enabled")
        else 
            StopLoop("AutoCollect")
            Notify("Auto Collect disabled")
        end
    end
})

--==================================================
-- EGGS TAB
--==================================================
local EggSection = EggsTab:AddSection({
    Name = "Egg Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

EggSection:AddToggle({
    Name = "Auto Buy Egg",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoBuyEgg",
    Save = true,
    Callback = function(Value)
        Toggles.AutoBuyEgg = Value
        if Value then 
            StartLoop("AutoBuyEgg")
            Notify("Auto Buy Egg enabled")
        else 
            StopLoop("AutoBuyEgg")
            Notify("Auto Buy Egg disabled")
        end
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
        Notify("Egg type set to: " .. Value)
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
        if Value then 
            StartLoop("AutoHatch")
            Notify("Auto Hatch enabled")
        else 
            StopLoop("AutoHatch")
            Notify("Auto Hatch disabled")
        end
    end
})

--==================================================
-- UPGRADES TAB
--==================================================
local UpgradeSection = UpgradeTab:AddSection({
    Name = "Auto Upgrade",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

UpgradeSection:AddToggle({
    Name = "Auto Upgrade",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoUpgrade",
    Save = true,
    Callback = function(Value)
        Toggles.AutoUpgrade = Value
        if Value then 
            StartLoop("AutoUpgrade")
            Notify("Auto Upgrade enabled")
        else 
            StopLoop("AutoUpgrade")
            Notify("Auto Upgrade disabled")
        end
    end
})

UpgradeSection:AddDropdown({
    Name = "Upgrade Type",
    Default = "All",
    Options = {"All", "Damage", "Speed", "Multiplier", "Critical"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.UpgradeType = Value
        Notify("Upgrade type set to: " .. Value)
    end
})

local RebirthSection = UpgradeTab:AddSection({
    Name = "Rebirth",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

RebirthSection:AddToggle({
    Name = "Auto Rebirth",
    Default = false,
    Color = Color3.fromRGB(255, 50, 50),
    Outline = true,
    Flag = "AutoRebirth",
    Save = true,
    Callback = function(Value)
        Toggles.AutoRebirth = Value
        if Value then 
            StartLoop("AutoRebirth")
            Notify("Auto Rebirth enabled")
        else 
            StopLoop("AutoRebirth")
            Notify("Auto Rebirth disabled")
        end
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

--==================================================
-- VISUALS TAB
--==================================================
local LightingSection = VisualsTab:AddSection({
    Name = "Lighting",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

LightingSection:AddToggle({
    Name = "Full Bright",
    Default = false,
    Color = Color3.fromRGB(255, 255, 0),
    Outline = true,
    Flag = "FullBright",
    Save = true,
    Callback = function(Value)
        Toggles.FullBright = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.new(1, 1, 1)
            Notify("Full Bright enabled")
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0, 0, 0)
            Notify("Full Bright disabled")
        end
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({
    Name = "Miscellaneous",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
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
            Notify("Anti AFK enabled")
        else
            Notify("Anti AFK disabled")
        end
    end
})

MiscSection:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        Notify("Rejoining server...")
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

MiscSection:AddButton({
    Name = "Close GUI",
    Icon = "x",
    Outline = true,
    Callback = function()
        OrionLib:Destroy()
        _G.TapSimLoaded = false
        Notify("GUI closed")
    end
})

-- Server Info
local ServerSection = MiscTab:AddSection({
    Name = "Server Info",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local function GetServerPlayers()
    local count = 0
    for _, v in pairs(Players:GetPlayers()) do
        count = count + 1
    end
    return count .. "/" .. game.Players.MaxPlayers
end

ServerSection:AddParagraph({
    Title = "Server Status",
    Desc = "Players: " .. GetServerPlayers() .. "\nPing: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms",
    Image = "server",
    ImageSize = 38
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

--==================================================
-- INITIALIZE
--==================================================
local initSuccess, initError = pcall(function()
    OrionLib:Init()
end)

if initSuccess then
    print("=== TAP SIMULATOR SCRIPT LOADED SUCCESSFULLY ===")
    print("Press F4 or click floating button to open menu")
    print("================================================")
    
    -- Notifikasi final
    Notify("✅ Script loaded! Press F4 to open menu")
else
    print("Failed to initialize UI:", initError)
    Notify("❌ Failed to initialize UI. Please re-execute.")
end