-- ==================== TAP SIMULATOR - CATRAZ EDITION (ENHANCED) ====================
-- Premium Auto Farm Script untuk Tap Simulator
-- Author: Adapted for Catraz Hub
-- Version: 2.0 (Enhanced)

if _G.TapSimLoaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Tap Simulator",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.TapSimLoaded = true

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
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

-- Toggles
local Toggles = {
    -- Auto Farm
    AutoTap = false,
    TapSpeed = 0.01,
    AutoClicker = false,
    ClickSpeed = 0.001,
    ClickMethod = "Mouse", -- Mouse, Virtual, Remote
    
    -- Eggs
    AutoBuyEgg = false,
    EggType = "Basic",
    AutoHatch = false,
    EggBuyDelay = 1,
    
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
local ClickConnection = nil

--==================================================
-- DETECT GAME MECHANICS
--==================================================

-- Deteksi elemen game yang bisa di-click
local ClickableElements = {
    Buttons = {},
    GUIs = {},
    Parts = {}
}

local function DetectClickableElements()
    -- Cari tombol di layar
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            if v.Active and v.Visible and v.AbsoluteSize.X > 0 then
                local name = v.Name:lower()
                if name:find("tap") or name:find("click") or name:find("egg") or name:find("buy") then
                    table.insert(ClickableElements.Buttons, v)
                end
            end
        end
    end
    
    -- Cari part yang bisa di-click di workspace
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildWhichIsA("ClickDetector") then
            table.insert(ClickableElements.Parts, v)
        elseif v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            table.insert(ClickableElements.Parts, v)
        end
    end
    
    print("=== CLICKABLE ELEMENTS FOUND ===")
    print("Buttons: " .. #ClickableElements.Buttons)
    print("Parts: " .. #ClickableElements.Parts)
end

-- Cari Remote Events dengan lebih teliti
local Remotes = {
    Tap = nil,
    BuyEgg = nil,
    HatchEgg = nil,
    BuyArea = nil,
    Upgrade = nil,
    Collect = nil,
    Rebirth = nil,
    Click = nil,
    Purchase = nil
}

local function FindRemotes()
    -- Metode 1: Scan semua descendants
    local allDescendants = {}
    for _, container in pairs({ReplicatedStorage, Player.PlayerScripts, game:GetService("ScriptContext")}) do
        for _, v in pairs(container:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("UnreliableRemoteEvent") then
                table.insert(allDescendants, v)
            end
        end
    end
    
    -- Analisis nama remote
    for _, v in pairs(allDescendants) do
        local name = v.Name:lower()
        
        -- Tap/Click related
        if name:find("tap") or name:find("click") or name:find("hit") or name:find("damage") then
            if not Remotes.Tap then Remotes.Tap = v end
            if name:find("click") and not Remotes.Click then Remotes.Click = v end
        end
        
        -- Egg related
        if name:find("egg") or name:find("hatch") or name:find("open") then
            if name:find("buy") or name:find("purchase") then
                if not Remotes.BuyEgg then Remotes.BuyEgg = v end
            elseif name:find("hatch") or name:find("open") then
                if not Remotes.HatchEgg then Remotes.HatchEgg = v end
            end
        end
        
        -- Purchase related
        if name:find("buy") or name:find("purchase") then
            if not Remotes.Purchase then Remotes.Purchase = v end
            if name:find("area") and not Remotes.BuyArea then Remotes.BuyArea = v end
        end
        
        -- Upgrade related
        if name:find("upgrade") or name:find("boost") then
            if not Remotes.Upgrade then Remotes.Upgrade = v end
        end
        
        -- Collect/Claim related
        if name:find("collect") or name:find("claim") or name:find("reward") then
            if not Remotes.Collect then Remotes.Collect = v end
        end
        
        -- Rebirth related
        if name:find("rebirth") or name:find("prestige") or name:find("reset") then
            if not Remotes.Rebirth then Remotes.Rebirth = v end
        end
    end
    
    -- Metode 2: Hook ke events (jika executor mendukung)
    local success, hookFunc = pcall(function()
        return hookfunction or replaceclosure or function() end
    end)
    
    if success then
        print("Advanced remote detection available")
    end
    
    print("=== REMOTES FOUND ===")
    for k, v in pairs(Remotes) do
        print(k, v and "✓" or "✗")
    end
end

--==================================================
-- ENHANCED CLICK METHODS
--==================================================

-- Method 1: Mouse Click Simulation
local function MouseClick()
    mouse1click()
    mouse1release()
end

-- Method 2: Virtual Input Manager
local function VirtualClick()
    VirtualInputManager:SendMouseButtonEvent(
        Mouse.X, Mouse.Y, 0, true, game, 0
    )
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(
        Mouse.X, Mouse.Y, 0, false, game, 0
    )
end

-- Method 3: Remote Event Spam
local function RemoteClick()
    if Remotes.Click then
        pcall(function()
            if Remotes.Click:IsA("RemoteEvent") then
                Remotes.Click:FireServer()
            elseif Remotes.Click:IsA("RemoteFunction") then
                Remotes.Click:InvokeServer()
            end
        end)
    end
    
    if Remotes.Tap then
        pcall(function()
            if Remotes.Tap:IsA("RemoteEvent") then
                Remotes.Tap:FireServer()
            elseif Remotes.Tap:IsA("RemoteFunction") then
                Remotes.Tap:InvokeServer()
            end
        end)
    end
end

-- Method 4: Find and Click GUI Button
local function FindAndClickButton()
    local bestButton = nil
    local bestScore = 0
    
    for _, btn in pairs(ClickableElements.Buttons) do
        if btn.Visible and btn.Active then
            local score = 0
            local name = btn.Name:lower()
            
            if name:find("tap") or name:find("click") then score = score + 10 end
            if name:find("main") or name:find("big") then score = score + 5 end
            if btn.AbsoluteSize.X > 100 then score = score + 3 end
            
            if score > bestScore then
                bestScore = score
                bestButton = btn
            end
        end
    end
    
    if bestButton then
        -- Simulate button click
        local pos = bestButton.AbsolutePosition + bestButton.AbsoluteSize / 2
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
        return true
    end
    return false
end

-- Method 5: ClickDetector trigger
local function TriggerClickDetectors()
    for _, part in pairs(ClickableElements.Parts) do
        local detector = part:FindFirstChildWhichIsA("ClickDetector") or 
                        (part:IsA("Model") and part:FindFirstChild("ClickDetector"))
        if detector then
            fireclickdetector(detector)
            return true
        end
    end
    return false
end

-- Main click function with multiple methods
local function PerformClick(method)
    method = method or Toggles.ClickMethod
    
    if method == "Mouse" then
        MouseClick()
    elseif method == "Virtual" then
        VirtualClick()
    elseif method == "Remote" then
        RemoteClick()
    elseif method == "Button" then
        FindAndClickButton()
    elseif method == "Detector" then
        TriggerClickDetectors()
    else
        -- Try all methods
        RemoteClick()
        task.wait(0.001)
        MouseClick()
        task.wait(0.001)
        VirtualClick()
        task.wait(0.001)
        FindAndClickButton()
        task.wait(0.001)
        TriggerClickDetectors()
    end
end

--==================================================
-- ENHANCED EGG FUNCTIONS
--==================================================

-- Cari egg prices dan jenis eggs
local EggData = {
    Basic = {price = 100, remoteName = "Basic", available = true},
    Rare = {price = 500, remoteName = "Rare", available = true},
    Epic = {price = 2000, remoteName = "Epic", available = true},
    Legendary = {price = 10000, remoteName = "Legendary", available = true},
    Mythic = {price = 50000, remoteName = "Mythic", available = true}
}

local function ScanEggPrices()
    -- Coba scan dari GUI untuk mendapatkan harga
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            local text = v.Text:lower()
            if text:find("egg") and text:find("%$") then
                -- Parse harga
                local price = text:match("%$([0-9,]+)")
                if price then
                    price = tonumber(price:gsub(",", ""))
                    for eggName, data in pairs(EggData) do
                        if text:find(eggName:lower()) then
                            data.price = price
                            print("Updated " .. eggName .. " price: $" .. price)
                        end
                    end
                end
            end
        end
    end
end

-- Buy egg dengan multiple methods
local function BuyEgg(eggType)
    eggType = eggType or Toggles.EggType
    local eggData = EggData[eggType]
    
    if not eggData then return false end
    
    -- Method 1: Direct remote
    if Remotes.BuyEgg then
        local success = pcall(function()
            if Remotes.BuyEgg:IsA("RemoteEvent") then
                Remotes.BuyEgg:FireServer(eggType)
            elseif Remotes.BuyEgg:IsA("RemoteFunction") then
                Remotes.BuyEgg:InvokeServer(eggType)
            end
        end)
        if success then return true end
    end
    
    -- Method 2: Purchase remote
    if Remotes.Purchase then
        local success = pcall(function()
            if Remotes.Purchase:IsA("RemoteEvent") then
                Remotes.Purchase:FireServer("Egg", eggType)
            else
                Remotes.Purchase:InvokeServer("Egg", eggType)
            end
        end)
        if success then return true end
    end
    
    -- Method 3: Find and click buy button
    for _, btn in pairs(ClickableElements.Buttons) do
        if btn.Visible and btn.Active then
            local text = btn.Text:lower()
            if text:find("buy") and text:find(eggType:lower()) then
                -- Click the button
                local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                return true
            end
        end
    end
    
    -- Method 4: Try common remote patterns
    local commonRemotes = {
        "BuyEgg",
        "PurchaseEgg",
        "Buy" .. eggType .. "Egg",
        "EggPurchase",
        "BuyEggs"
    }
    
    for _, remoteName in pairs(commonRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote then
            local success = pcall(function() remote:FireServer() end)
            if success then return true end
        end
    end
    
    return false
end

-- Hatch egg dengan multiple methods
local function HatchEgg()
    -- Method 1: Direct remote
    if Remotes.HatchEgg then
        local success = pcall(function()
            if Remotes.HatchEgg:IsA("RemoteEvent") then
                Remotes.HatchEgg:FireServer()
            else
                Remotes.HatchEgg:InvokeServer()
            end
        end)
        if success then return true end
    end
    
    -- Method 2: Find hatch button
    for _, btn in pairs(ClickableElements.Buttons) do
        if btn.Visible and btn.Active then
            local text = btn.Text:lower()
            if text:find("hatch") or text:find("open") then
                local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                return true
            end
        end
    end
    
    -- Method 3: Common remote patterns
    local commonRemotes = {
        "HatchEgg",
        "OpenEgg",
        "Hatch",
        "EggHatch"
    }
    
    for _, remoteName in pairs(commonRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote then
            local success = pcall(function() remote:FireServer() end)
            if success then return true end
        end
    end
    
    return false
end

--==================================================
-- COIN TRACKING
--==================================================

local function GetCoins()
    -- Cek leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("coin") or name:find("cash") or name:find("point") or name:find("money") then
                    return v.Value
                end
            end
        end
    end
    
    -- Cek di player
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
            return v.Value
        end
    end
    
    -- Cek di GUI
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible then
            local text = v.Text
            local num = text:match("^%$?([%d,]+)%s*$")
            if num then
                num = tonumber(num:gsub(",", ""))
                if num and num > 0 then
                    return num
                end
            end
        end
    end
    
    return 0
end

local function GetRebirths()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("rebirth") or name:find("prestige") or name:find("reset") then
                    return v.Value
                end
            end
        end
    end
    return 0
end

local function formatNumber(num)
    if num >= 1e12 then
        return string.format("%.2fT", num / 1e12)
    elseif num >= 1e9 then
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
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Tap Simulator",
        Content = msg,
        Image = "zap",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Tap Simulator",
    Subtext = "Enhanced Edition",
    Version = "v2.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSim_Config",
    IntroEnabled = true,
    IntroText = "Tap Simulator Enhanced",
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

Notify("Enhanced script loaded!")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

local ClickerTab = Window:MakeTab({
    Name = "Clicker",
    Icon = "mouse-pointer",
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
-- MAIN TAB
--==================================================
local StatsSection = MainTab:AddSection({
    Name = "Player Stats",
    TextSize = 17,
    Glass = true,
    Outline = true
})

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
            end
        }
    }
})

-- Update stats
task.spawn(function()
    while true do
        local coins = GetCoins()
        local rebirths = GetRebirths()
        StatsPara:SetDesc("Coins: " .. formatNumber(coins) .. "\nRebirths: " .. rebirths)
        task.wait(2)
    end
end)

local QuickSection = MainTab:AddSection({
    Name = "Quick Actions",
    TextSize = 17,
    Glass = true,
    Outline = true
})

QuickSection:AddButton({
    Name = "Super Tap (100x)",
    Icon = "zap",
    Outline = true,
    Callback = function()
        for i = 1, 100 do
            PerformClick("All")
            if i % 10 == 0 then
                task.wait(0.01)
            end
        end
        Notify("Tapped 100 times!")
    end
})

QuickSection:AddButton({
    Name = "Buy & Hatch Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        if BuyEgg(Toggles.EggType) then
            task.wait(0.5)
            HatchEgg()
            Notify("Bought and hatched egg!")
        else
            Notify("Failed to buy egg")
        end
    end
})

--==================================================
-- CLICKER TAB (ENHANCED)
--==================================================
local ClickMethodSection = ClickerTab:AddSection({
    Name = "Click Method",
    TextSize = 17,
    Glass = true,
    Outline = true
})

ClickMethodSection:AddDropdown({
    Name = "Click Method",
    Default = "All",
    Options = {"All", "Mouse", "Virtual", "Remote", "Button", "Detector"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.ClickMethod = Value
        Notify("Click method: " .. Value)
    end
})

ClickMethodSection:AddParagraph({
    Title = "Method Info",
    Desc = "Mouse: Basic mouse click\nVirtual: Virtual input\nRemote: Remote events\nButton: Find GUI button\nDetector: Click detectors\nAll: Try all methods",
    Image = "info",
    ImageSize = 32
})

local AutoClickSection = ClickerTab:AddSection({
    Name = "Auto Clicker",
    TextSize = 17,
    Glass = true,
    Outline = true
})

AutoClickSection:AddToggle({
    Name = "Enable Auto Clicker",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoClicker",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClicker = Value
        if Value then 
            StartLoop("AutoClicker") 
            Notify("Auto Clicker ON - Method: " .. Toggles.ClickMethod)
        else 
            StopLoop("AutoClicker") 
        end
    end
})

AutoClickSection:AddSlider({
    Name = "Click Speed (CPS)",
    Min = 1,
    Max = 1000,
    Default = 100,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "CPS",
    Outline = true,
    Callback = function(Value)
        -- Convert CPS to delay
        Toggles.ClickSpeed = 1 / Value
    end
})

AutoClickSection:AddSlider({
    Name = "Click Speed (Delay)",
    Min = 0.0001,
    Max = 0.1,
    Default = 0.001,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.0001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.ClickSpeed = Value
    end
})

AutoClickSection:AddToggle({
    Name = "Auto Tap (Remote)",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoTap",
    Save = true,
    Callback = function(Value)
        Toggles.AutoTap = Value
        if Value then StartLoop("AutoTap") else StopLoop("AutoTap") end
    end
})

AutoClickSection:AddSlider({
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

local TestSection = ClickerTab:AddSection({
    Name = "Test",
    TextSize = 17,
    Glass = true,
    Outline = true
})

TestSection:AddButton({
    Name = "Test Click (10x)",
    Icon = "play",
    Outline = true,
    Callback = function()
        for i = 1, 10 do
            PerformClick(Toggles.ClickMethod)
            task.wait(0.05)
        end
        Notify("Tested 10 clicks")
    end
})

TestSection:AddButton({
    Name = "Scan Clickable Elements",
    Icon = "search",
    Outline = true,
    Callback = function()
        DetectClickableElements()
        Notify("Found " .. #ClickableElements.Buttons .. " buttons, " .. #ClickableElements.Parts .. " parts")
    end
})

--==================================================
-- EGGS TAB (ENHANCED)
--==================================================
local EggBuySection = EggsTab:AddSection({
    Name = "Egg Purchase",
    TextSize = 17,
    Glass = true,
    Outline = true
})

EggBuySection:AddToggle({
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
            ScanEggPrices()
        else 
            StopLoop("AutoBuyEgg") 
        end
    end
})

EggBuySection:AddDropdown({
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

EggBuySection:AddSlider({
    Name = "Buy Delay",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.EggBuyDelay = Value
    end
})

EggBuySection:AddButton({
    Name = "Scan Egg Prices",
    Icon = "dollar-sign",
    Outline = true,
    Callback = function()
        ScanEggPrices()
        Notify("Egg prices scanned")
    end
})

local EggHatchSection = EggsTab:AddSection({
    Name = "Hatching",
    TextSize = 17,
    Glass = true,
    Outline = true
})

EggHatchSection:AddToggle({
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

EggHatchSection:AddButton({
    Name = "Hatch Now",
    Icon = "egg",
    Outline = true,
    Callback = function()
        if HatchEgg() then
            Notify("Egg hatched!")
        else
            Notify("Failed to hatch egg")
        end
    end
})

local EggInfoSection = EggsTab:AddSection({
    Name = "Egg Info",
    TextSize = 17,
    Glass = true,
    Outline = true
})

EggInfoSection:AddParagraph({
    Title = "Egg Prices",
    Desc = "Basic: $" .. formatNumber(EggData.Basic.price) .. 
           "\nRare: $" .. formatNumber(EggData.Rare.price) ..
           "\nEpic: $" .. formatNumber(EggData.Epic.price) ..
           "\nLegendary: $" .. formatNumber(EggData.Legendary.price) ..
           "\nMythic: $" .. formatNumber(EggData.Mythic.price),
    Image = "info",
    ImageSize = 32
})

--==================================================
-- UPGRADES TAB
--==================================================
local UpgradeSection = UpgradeTab:AddSection({
    Name = "Auto Upgrade",
    TextSize = 17,
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
        if Value then StartLoop("AutoUpgrade") else StopLoop("AutoUpgrade") end
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
    end
})

local RebirthSection = UpgradeTab:AddSection({
    Name = "Rebirth",
    TextSize = 17,
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
        if Value then StartLoop("AutoRebirth") else StopLoop("AutoRebirth") end
    end
})

RebirthSection:AddSlider({
    Name = "Rebirth At",
    Min = 100,
    Max = 10000000,
    Default = 10000,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 100,
    ValueName = "coins",
    Outline = true,
    Callback = function(Value)
        Toggles.RebirthAt = Value
    end
})

--==================================================
-- LOOP FUNCTIONS (ENHANCED)
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        local lastClickTime = tick()
        
        while Loops[name] do
            local currentTime = tick()
            
            if name == "AutoClicker" and Toggles.AutoClicker then
                -- High-speed clicking
                local clicksPerFrame = math.floor(Toggles.ClickSpeed * 60) + 1
                for i = 1, math.min(clicksPerFrame, 10) do
                    PerformClick(Toggles.ClickMethod)
                    if i < clicksPerFrame then
                        task.wait(0.0001)
                    end
                end
                
            elseif name == "AutoTap" and Toggles.AutoTap then
                -- Remote tapping
                RemoteClick()
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                -- Smart egg buying
                local coins = GetCoins()
                local eggData = EggData[Toggles.EggType]
                
                if coins >= eggData.price then
                    if BuyEgg(Toggles.EggType) then
                        Notify("Bought " .. Toggles.EggType .. " egg!")
                    end
                end
                task.wait(Toggles.EggBuyDelay)
                
            elseif name == "AutoHatch" and Toggles.AutoHatch then
                HatchEgg()
                task.wait(0.5)
                
            elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                -- Upgrade dengan smart logic
                if Remotes.Upgrade then
                    pcall(function()
                        if Toggles.UpgradeType == "All" then
                            Remotes.Upgrade:FireServer("Damage")
                            task.wait(0.1)
                            Remotes.Upgrade:FireServer("Speed")
                            task.wait(0.1)
                            Remotes.Upgrade:FireServer("Multiplier")
                        else
                            Remotes.Upgrade:FireServer(Toggles.UpgradeType)
                        end
                    end)
                end
                task.wait(1)
                
            elseif name == "AutoRebirth" and Toggles.AutoRebirth then
                local coins = GetCoins()
                if coins >= Toggles.RebirthAt then
                    if Remotes.Rebirth then
                        pcall(function() Remotes.Rebirth:FireServer() end)
                        Notify("Rebirthed!")
                        task.wait(3)
                    end
                else
                    task.wait(2)
                end
            end
            
            task.wait()
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

--==================================================
-- VISUALS TAB
--==================================================
local ESPSection = VisualsTab:AddSection({
    Name = "ESP",
    TextSize = 17,
    Glass = true,
    Outline = true
})

ESPSection:AddToggle({
    Name = "Egg ESP",
    Default = false,
    Color = Color3.fromRGB(255, 0, 255),
    Outline = true,
    Flag = "EggESP",
    Save = true,
    Callback = function(Value)
        Toggles.ESP = Value
        -- Update ESP logic here
    end
})

local LightingSection = VisualsTab:AddSection({
    Name = "Lighting",
    TextSize = 17,
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
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({
    Name = "Miscellaneous",
    TextSize = 17,
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
        end
    end
})

MiscSection:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

MiscSection:AddButton({
    Name = "Server Hop",
    Icon = "globe",
    Outline = true,
    Callback = function()
        -- Simple server hop
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"))
        end)
        
        if success and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, Player)
                    break
                end
            end
        end
    end
})

MiscSection:AddButton({
    Name = "Close GUI",
    Icon = "x",
    Outline = true,
    Callback = function()
        OrionLib:Destroy()
        _G.TapSimLoaded = false
    end
})

--==================================================
-- INITIALIZATION
--==================================================

-- Scan for remotes and clickable elements
FindRemotes()
DetectClickableElements()
ScanEggPrices()

-- Add config tab
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

-- Initialize
OrionLib:Init()

Notify("Enhanced script ready! Auto Clicker and Auto Buy Egg are optimized!")
print("=== Tap Simulator Enhanced Edition Loaded ===")
print("Auto Clicker: " .. tostring(Remotes.Tap and "Remote available" or "Using multiple methods"))
print("Auto Buy Egg: " .. tostring(Remotes.BuyEgg and "Remote available" or "Using button detection"))