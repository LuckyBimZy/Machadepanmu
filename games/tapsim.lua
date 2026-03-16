-- ==================== TAP SIMULATOR - STANDALONE WORKING EDITION ====================
-- Script mandiri tanpa loader dan tanpa key system
-- Version: 5.0 Standalone Working

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
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

--==================================================
-- REMOTE FINDING LENGKAP
--==================================================
local Remotes = {
    -- Main remotes
    Tap = nil,
    Click = nil,
    BuyEgg = nil,
    HatchEgg = nil,
    BuyArea = nil,
    Upgrade = nil,
    Collect = nil,
    Rebirth = nil,
    
    -- Additional remotes
    Purchase = nil,
    Claim = nil,
    Event = nil,
    Enchant = nil,
    Craft = nil,
    Unlock = nil,
    Open = nil,
    Reset = nil,
    Prestige = nil,
    Daily = nil,
    Reward = nil,
    GameEvent = nil,
    MainEvent = nil,
    ClickEvent = nil,
    Damage = nil,
    Speed = nil,
    Multiplier = nil,
    Critical = nil
}

-- Lokasi objects
local EggLocations = {}
local ZoneLocations = {}
local CoinLocations = {}

-- Fungsi pencarian remotes LENGKAP
local function FindAllRemotes()
    print("=== MENCARI SEMUA REMOTES ===")
    
    -- Cari di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            
            -- Tap/Click
            if name:find("tap") then Remotes.Tap = v end
            if name:find("click") then Remotes.Click = v end
            if name:find("game") and name:find("event") then Remotes.GameEvent = v end
            if name:find("main") and name:find("event") then Remotes.MainEvent = v end
            if name:find("click") and name:find("event") then Remotes.ClickEvent = v end
            
            -- Egg
            if name:find("egg") then
                if name:find("buy") or name:find("purchase") then Remotes.BuyEgg = v end
                if name:find("hatch") or name:find("open") then Remotes.HatchEgg = v end
            end
            
            -- Upgrade
            if name:find("upgrade") then Remotes.Upgrade = v end
            if name:find("purchase") then Remotes.Purchase = v end
            if name:find("damage") then Remotes.Damage = v end
            if name:find("speed") then Remotes.Speed = v end
            if name:find("multiplier") then Remotes.Multiplier = v end
            if name:find("critical") then Remotes.Critical = v end
            
            -- Area
            if name:find("area") or name:find("zone") then
                if name:find("buy") or name:find("unlock") then Remotes.BuyArea = v end
            end
            
            -- Collect/Claim
            if name:find("collect") then Remotes.Collect = v end
            if name:find("claim") then Remotes.Claim = v end
            if name:find("daily") then Remotes.Daily = v end
            if name:find("reward") then Remotes.Reward = v end
            
            -- Rebirth
            if name:find("rebirth") then Remotes.Rebirth = v end
            if name:find("prestige") then Remotes.Prestige = v end
            if name:find("reset") then Remotes.Reset = v end
            
            -- Enchant/Craft
            if name:find("enchant") then Remotes.Enchant = v end
            if name:find("craft") then Remotes.Craft = v end
            if name:find("unlock") then Remotes.Unlock = v end
            if name:find("open") then Remotes.Open = v end
        end
    end
    
    -- Cari di Player scripts
    for _, v in pairs(Player.PlayerScripts:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("tap") and not Remotes.Tap then Remotes.Tap = v end
            if name:find("click") and not Remotes.Click then Remotes.Click = v end
        end
    end
    
    -- Cari di Workspace
    for _, v in pairs(Workspace:GetDescendants()) do
        -- Cari eggs
        if v.Name:lower():find("egg") then
            if v:IsA("BasePart") and v.Transparency < 1 then
                table.insert(EggLocations, v)
            elseif v:IsA("Model") and v.PrimaryPart then
                table.insert(EggLocations, v.PrimaryPart)
            end
        end
        
        -- Cari zones/areas
        if v.Name:lower():find("zone") or v.Name:lower():find("area") or v.Name:lower():find("spawn") or v.Name:lower():find("island") then
            table.insert(ZoneLocations, v)
        end
        
        -- Cari coins
        if v.Name:lower():find("coin") and v:IsA("BasePart") then
            table.insert(CoinLocations, v)
        end
    end
    
    -- Tampilkan hasil
    print("=== REMOTES DITEMUKAN ===")
    for k, v in pairs(Remotes) do
        if v then
            print("✓ " .. k .. ": " .. v.ClassName .. " - " .. v.Name)
        end
    end
    print("=== EGGS DITEMUKAN: " .. #EggLocations .. " ===")
    print("=== ZONES DITEMUKAN: " .. #ZoneLocations .. " ===")
    print("=== COINS DITEMUKAN: " .. #CoinLocations .. " ===")
end

--==================================================
-- FUNGSI UTAMA
--==================================================

-- Fungsi Tap dengan berbagai metode
local function Tap()
    local success = false
    
    -- Coba semua kemungkinan remote
    if Remotes.Tap and not success then
        pcall(function()
            if Remotes.Tap:IsA("RemoteEvent") then
                Remotes.Tap:FireServer()
            else
                Remotes.Tap:InvokeServer()
            end
            success = true
        end)
    end
    
    if Remotes.Click and not success then
        pcall(function() Remotes.Click:FireServer() success = true end)
    end
    
    if Remotes.GameEvent and not success then
        pcall(function() Remotes.GameEvent:FireServer("Click") success = true end)
    end
    
    if Remotes.MainEvent and not success then
        pcall(function() Remotes.MainEvent:FireServer("Click") success = true end)
    end
    
    if Remotes.ClickEvent and not success then
        pcall(function() Remotes.ClickEvent:FireServer() success = true end)
    end
    
    -- Fallback: coba semua remote event
    if not success then
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") then
                pcall(function() v:FireServer() end)
                pcall(function() v:FireServer("Click") end)
                pcall(function() v:FireServer("Tap") end)
            end
        end
    end
    
    return success
end

-- Fungsi Click
local function AutoClick()
    mouse1click()
    mouse1press()
    mouse1release()
end

-- Fungsi Buy Egg
local function BuyEgg(eggType)
    if Remotes.BuyEgg then
        pcall(function() Remotes.BuyEgg:FireServer(eggType) end)
    elseif Remotes.Purchase then
        pcall(function() Remotes.Purchase:FireServer("Egg", eggType) end)
    else
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("buy") or v.Name:lower():find("purchase")) then
                pcall(function() v:FireServer(eggType or "Basic") end)
                pcall(function() v:FireServer("BuyEgg", eggType) end)
            end
        end
    end
end

-- Fungsi Hatch Egg
local function HatchEgg()
    if Remotes.HatchEgg then
        pcall(function() Remotes.HatchEgg:FireServer() end)
    elseif Remotes.Open then
        pcall(function() Remotes.Open:FireServer("Egg") end)
    else
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("hatch") or v.Name:lower():find("open")) then
                pcall(function() v:FireServer() end)
            end
        end
    end
end

-- Fungsi Upgrade
local function Upgrade(upgradeType)
    if Remotes.Upgrade then
        pcall(function() Remotes.Upgrade:FireServer(upgradeType) end)
    elseif Remotes.Purchase then
        pcall(function() Remotes.Purchase:FireServer("Upgrade", upgradeType) end)
    elseif upgradeType == "Damage" and Remotes.Damage then
        pcall(function() Remotes.Damage:FireServer() end)
    elseif upgradeType == "Speed" and Remotes.Speed then
        pcall(function() Remotes.Speed:FireServer() end)
    elseif upgradeType == "Multiplier" and Remotes.Multiplier then
        pcall(function() Remotes.Multiplier:FireServer() end)
    elseif upgradeType == "Critical" and Remotes.Critical then
        pcall(function() Remotes.Critical:FireServer() end)
    else
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("upgrade") then
                pcall(function() v:FireServer(upgradeType or "Damage") end)
            end
        end
    end
end

-- Fungsi Buy Area
local function BuyArea()
    if Remotes.BuyArea then
        pcall(function() Remotes.BuyArea:FireServer() end)
    elseif Remotes.Unlock then
        pcall(function() Remotes.Unlock:FireServer("Area") end)
    else
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("area") or v.Name:lower():find("zone")) then
                pcall(function() v:FireServer() end)
            end
        end
    end
end

-- Fungsi Collect
local function Collect()
    if Remotes.Collect then
        pcall(function() Remotes.Collect:FireServer() end)
    elseif Remotes.Claim then
        pcall(function() Remotes.Claim:FireServer() end)
    elseif Remotes.Reward then
        pcall(function() Remotes.Reward:FireServer() end)
    end
end

-- Fungsi Rebirth
local function Rebirth()
    if Remotes.Rebirth then
        pcall(function() Remotes.Rebirth:FireServer() end)
    elseif Remotes.Prestige then
        pcall(function() Remotes.Prestige:FireServer() end)
    elseif Remotes.Reset then
        pcall(function() Remotes.Reset:FireServer() end)
    else
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("rebirth") or v.Name:lower():find("prestige") or v.Name:lower():find("reset")) then
                pcall(function() v:FireServer() end)
            end
        end
    end
end

-- Fungsi Enchant
local function Enchant()
    if Remotes.Enchant then
        pcall(function() Remotes.Enchant:FireServer() end)
    else
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("enchant") then
                pcall(function() v:FireServer() end)
            end
        end
    end
end

-- Fungsi Craft
local function Craft()
    if Remotes.Craft then
        pcall(function() Remotes.Craft:FireServer() end)
    else
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("craft") then
                pcall(function() v:FireServer() end)
            end
        end
    end
end

-- Fungsi Unlock
local function Unlock()
    if Remotes.Unlock then
        pcall(function() Remotes.Unlock:FireServer() end)
    elseif Remotes.Open then
        pcall(function() Remotes.Open:FireServer() end)
    end
end

-- Fungsi Claim Daily
local function ClaimDaily()
    if Remotes.Daily then
        pcall(function() Remotes.Daily:FireServer() end)
    elseif Remotes.Claim then
        pcall(function() Remotes.Claim:FireServer("Daily") end)
    end
end

-- Get coins dari leaderstats
local function GetCoins()
    -- Coba leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("coin") or name:find("cash") or name:find("point") or name:find("gem") or name:find("money") then
                    return v.Value
                end
            end
        end
    end
    
    -- Cari di Player
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
            return v.Value
        end
    end
    
    -- Cari di Data folder
    local data = Player:FindFirstChild("Data") or Player:FindFirstChild("Stats")
    if data then
        for _, v in pairs(data:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
                return v.Value
            end
        end
    end
    
    return 0
end

-- Get rebirths
local function GetRebirths()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("rebirth") or name:find("prestige") or name:find("reset") or name:find("prestiged") then
                    return v.Value
                end
            end
        end
    end
    
    -- Cari di Player
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("rebirth") or v.Name:lower():find("prestige")) then
            return v.Value
        end
    end
    
    return 0
end

-- Format angka
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

-- Get zones
local function GetZones()
    local zones = {"Spawn"}
    for _, v in pairs(ZoneLocations) do
        if not table.find(zones, v.Name) then
            table.insert(zones, v.Name)
        end
    end
    return zones
end

-- Teleport ke zone
local function TeleportToZone(zoneName)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        Notify("No character found!")
        return
    end
    
    for _, v in pairs(ZoneLocations) do
        if v.Name == zoneName then
            if v:IsA("BasePart") then
                Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                Notify("Teleported to " .. zoneName)
                return
            elseif v:IsA("Model") and v.PrimaryPart then
                Player.Character.HumanoidRootPart.CFrame = v.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                Notify("Teleported to " .. zoneName)
                return
            end
        end
    end
    
    Notify("Zone not found: " .. zoneName)
end

-- Update Egg ESP
local function UpdateEggESP()
    for _, v in pairs(EggLocations) do
        if Toggles.EggESP then
            local highlight = v:FindFirstChild("EggHighlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "EggHighlight"
                highlight.Parent = v
                highlight.FillColor = Color3.fromRGB(255, 0, 255)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.3
            end
        else
            local highlight = v:FindFirstChild("EggHighlight")
            if highlight then highlight:Destroy() end
        end
    end
end

-- Find nearest egg
local function FindNearestEgg()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, egg in pairs(EggLocations) do
        if egg and egg.Position then
            local dist = (root.Position - egg.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = egg
            end
        end
    end
    
    return nearest
end

-- Teleport to egg
local function TeleportToEgg()
    local egg = FindNearestEgg()
    if egg and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = egg.CFrame + Vector3.new(0, 3, 0)
        Notify("Teleported to nearest egg")
    else
        Notify("No eggs found!")
    end
end

--==================================================
-- TOGGLES
--==================================================
local Toggles = {
    AutoTap = false,
    TapSpeed = 0.01,
    AutoClicker = false,
    ClickSpeed = 0.001,
    AutoBuyEgg = false,
    EggType = "Basic",
    AutoHatch = false,
    HatchDelay = 0.5,
    EggESP = false,
    AutoUpgrade = false,
    UpgradeType = "All",
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
    Name = "Tap Simulator - STANDALONE",
    Subtext = "Working Edition v5.0",
    Version = "v5.0.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSim_Standalone",
    IntroEnabled = true,
    IntroText = "Tap Simulator Standalone",
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
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({Name = "Main", Icon = "home", Glass = true, Outline = true})
local AutoTapTab = Window:MakeTab({Name = "Auto Tap", Icon = "hand", Glass = true, Outline = true})
local EggTab = Window:MakeTab({Name = "Egg System", Icon = "egg", Glass = true, Outline = true})
local UpgradeTab = Window:MakeTab({Name = "Upgrades", Icon = "trending-up", Glass = true, Outline = true})
local RebirthTab = Window:MakeTab({Name = "Rebirth", Icon = "refresh-cw", Glass = true, Outline = true})
local EnchantTab = Window:MakeTab({Name = "Enchant", Icon = "sparkles", Glass = true, Outline = true})
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "map-pin", Glass = true, Outline = true})
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "eye", Glass = true, Outline = true})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "settings", Glass = true, Outline = true})

--==================================================
-- LOOP FUNCTIONS
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
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
                if Toggles.UpgradeType == "All" then
                    Upgrade("Damage")
                    task.wait(0.2)
                    Upgrade("Speed")
                    task.wait(0.2)
                    Upgrade("Multiplier")
                    task.wait(0.2)
                    Upgrade("Critical")
                else
                    Upgrade(Toggles.UpgradeType)
                end
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
                if math.random(1, 5) == 1 then
                    Collect()
                end
                task.wait(0.05)
                
            elseif name == "AutoProgress" and Toggles.AutoProgress then
                Tap()
                local coins = GetCoins()
                if coins > 1000 then
                    Upgrade("Damage")
                end
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
-- MAIN TAB
--==================================================
local StatsSection = MainTab:AddSection({Name = "Player Stats", TextSize = 17, Glass = true, Outline = true})

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

-- Update stats setiap 3 detik
task.spawn(function()
    while true do
        local coins = GetCoins()
        local rebirths = GetRebirths()
        StatsPara:SetDesc("Coins: " .. formatNumber(coins) .. "\nRebirths: " .. rebirths)
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
        Notify("Tapped 50 times!")
    end
})

QuickSection:AddButton({
    Name = "Hatch Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        HatchEgg()
        Notify("Egg hatched!")
    end
})

QuickSection:AddButton({
    Name = "Rebirth Now",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        Rebirth()
        Notify("Rebirthed!")
    end
})

QuickSection:AddButton({
    Name = "Teleport to Egg",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        TeleportToEgg()
    end
})

--==================================================
-- AUTO TAP TAB
--==================================================
local TapSection = AutoTapTab:AddSection({Name = "Auto Tap Settings", TextSize = 17, Glass = true, Outline = true})

TapSection:AddToggle({
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
        if Value then StartLoop("AutoClicker") else StopLoop("AutoClicker") end
    end
})

TapSection:AddSlider({
    Name = "Click Speed",
    Min = 0.0001,
    Max = 0.01,
    Default = 0.001,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.0001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.ClickSpeed = Value
    end
})

--==================================================
-- EGG SYSTEM TAB
--==================================================
local EggMainSection = EggTab:AddSection({Name = "Egg Settings", TextSize = 17, Glass = true, Outline = true})

EggMainSection:AddToggle({
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

EggMainSection:AddDropdown({
    Name = "Egg Type",
    Default = "Basic",
    Options = {"Basic", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Godly"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EggType = Value
    end
})

EggMainSection:AddToggle({
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

EggMainSection:AddSlider({
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

EggMainSection:AddToggle({
    Name = "Egg ESP",
    Default = false,
    Color = Color3.fromRGB(255, 0, 255),
    Outline = true,
    Flag = "EggESP",
    Save = true,
    Callback = function(Value)
        Toggles.EggESP = Value
        UpdateEggESP()
    end
})

EggMainSection:AddButton({
    Name = "Find Eggs",
    Icon = "search",
    Outline = true,
    Callback = function()
        Notify("Found " .. #EggLocations .. " eggs!")
    end
})

--==================================================
-- UPGRADES TAB
--==================================================
local UpgradeMainSection = UpgradeTab:AddSection({Name = "Auto Upgrade", TextSize = 17, Glass = true, Outline = true})

UpgradeMainSection:AddToggle({
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

UpgradeMainSection:AddDropdown({
    Name = "Upgrade Type",
    Default = "All",
    Options = {"All", "Damage", "Speed", "Multiplier", "Critical", "Luck", "Strength"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.UpgradeType = Value
    end
})

UpgradeMainSection:AddToggle({
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

UpgradeMainSection:AddToggle({
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
local RebirthMainSection = RebirthTab:AddSection({Name = "Rebirth Settings", TextSize = 17, Glass = true, Outline = true})

RebirthMainSection:AddToggle({
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

RebirthMainSection:AddSlider({
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

RebirthMainSection:AddSlider({
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

--==================================================
-- ENCHANT TAB
--==================================================
local EnchantMainSection = EnchantTab:AddSection({Name = "Enchant Settings", TextSize = 17, Glass = true, Outline = true})

EnchantMainSection:AddToggle({
    Name = "Auto Enchant",
    Default = false,
    Color = Color3.fromRGB(255, 0, 255),
    Outline = true,
    Flag = "AutoEnchant",
    Save = true,
    Callback = function(Value)
        Toggles.AutoEnchant = Value
        if Value then StartLoop("AutoEnchant") else StopLoop("AutoEnchant") end
    end
})

EnchantMainSection:AddDropdown({
    Name = "Enchant Type",
    Default = "All",
    Options = {"All", "Weapon", "Armor", "Tool", "Accessory"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EnchantType = Value
    end
})

EnchantMainSection:AddToggle({
    Name = "Auto Craft",
    Default = false,
    Color = Color3.fromRGB(255, 0, 255),
    Outline = true,
    Flag = "AutoCraft",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCraft = Value
        if Value then StartLoop("AutoCraft") else StopLoop("AutoCraft") end
    end
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportMainSection = TeleportTab:AddSection({Name = "Teleport Zones", TextSize = 17, Glass = true, Outline = true})

local zones = GetZones()
TeleportMainSection:AddDropdown({
    Name = "Select Zone",
    Default = zones[1] or "Spawn",
    Options = zones,
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.SelectedZone = Value
    end
})

TeleportMainSection:AddButton({
    Name = "Teleport",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        TeleportToZone(Toggles.SelectedZone)
    end
})

TeleportMainSection:AddButton({
    Name = "Teleport to Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        TeleportToEgg()
    end
})

TeleportMainSection:AddButton({
    Name = "Refresh Zones",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        zones = GetZones()
        Notify("Found " .. #zones .. " zones!")
    end
})

--==================================================
-- VISUALS TAB
--==================================================
local VisualsMainSection = VisualsTab:AddSection({Name = "Lighting", TextSize = 17, Glass = true, Outline = true})

VisualsMainSection:AddToggle({
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

VisualsMainSection:AddToggle({
    Name = "No Fog",
    Default = false,
    Color = Color3.fromRGB(255, 255, 0),
    Outline = true,
    Flag = "NoFog",
    Save = true,
    Callback = function(Value)
        Toggles.NoFog = Value
        Lighting.FogEnd = Value and 1e9 or 100000
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscMainSection = MiscTab:AddSection({Name = "Automation", TextSize = 17, Glass = true, Outline = true})

MiscMainSection:AddToggle({
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

MiscMainSection:AddToggle({
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

MiscMainSection:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollect = Value
        if Value then StartLoop("AutoCollect") else StopLoop("AutoCollect") end
    end
})

MiscMainSection:AddToggle({
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

MiscMainSection:AddToggle({
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
        local function getServers()
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
            return servers
        end
        
        local servers = getServers()
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, Player)
        else
            Notify("No servers available!")
        end
    end
})

ServerSection:AddButton({
    Name = "Close GUI",
    Icon = "x",
    Outline = true,
    Callback = function()
        OrionLib:Destroy()
        _G.TapSimLoaded = false
    end
})

local InfoSection = MiscTab:AddSection({Name = "Server Info", TextSize = 17, Glass = true, Outline = true})

InfoSection:AddParagraph({
    Title = "Server Status",
    Desc = "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers .. "\nPing: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms",
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

-- Find all remotes
FindAllRemotes()

-- Initialize UI
OrionLib:Init()

Notify("Tap Simulator STANDALONE loaded! Press F4 to toggle menu")
print("=== TAP SIMULATOR - STANDALONE WORKING EDITION v5.0 ===")
print("Found remotes: " .. table.count(Remotes))
print("Found eggs: " .. #EggLocations)
print("Found zones: " .. #ZoneLocations)
print("Found coins: " .. #CoinLocations)
print("Press F4 to toggle menu")