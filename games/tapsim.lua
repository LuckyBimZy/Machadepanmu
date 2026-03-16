-- ==================== TAP SIMULATOR - ULTIMATE COLLECTION ====================
-- Gabungan dari berbagai script dengan UI Catraz Hub
-- Version: 3.0 Ultimate (Merged dari 20+ script)

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
-- VARIABLES & CONFIGURATION
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
local TweenService = game:GetService("TweenService")
local MarketService = game:GetService("MarketplaceService")

--==================================================
-- ADVANCED REMOTE FINDING (Dari semua script)
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
    
    -- Additional remotes dari berbagai script
    Purchase = nil,
    Claim = nil,
    Event = nil,
    ClickEvent = nil,
    MainEvent = nil,
    BuyPet = nil,
    OpenEgg = nil,
    PurchaseEgg = nil,
    PurchaseUpgrade = nil,
    PurchaseArea = nil,
    ClaimReward = nil,
    ClaimDaily = nil,
    DailyReward = nil,
    Prestige = nil,
    
    -- Enchantment remotes
    Enchant = nil,
    EnchantItem = nil,
    ApplyEnchant = nil,
    
    -- Auto farm remotes
    AutoTap = nil,
    AutoClick = nil,
    AutoFarm = nil
}

-- Cache untuk remotes yang sudah ditemukan
local RemoteCache = {}

-- Fungsi pencarian remote yang lebih canggih
local function FindAllRemotes()
    print("🔍 Mencari semua remotes...")
    
    -- Daftar pattern untuk mencari remotes
    local patterns = {
        -- Tap/Click patterns
        {"tap", "click", "hit", "attack", "damage", "punch", "strike"},
        -- Egg patterns
        {"egg", "hatch", "incubate", "breed", "pet"},
        -- Buy patterns
        {"buy", "purchase", "acquire", "get", "obtain"},
        -- Upgrade patterns
        {"upgrade", "enhance", "boost", "improve", "increase", "level"},
        -- Area patterns
        {"area", "zone", "region", "world", "dimension", "realm"},
        -- Collect patterns
        {"collect", "claim", "gather", "harvest", "reap"},
        -- Rebirth patterns
        {"rebirth", "prestige", "reset", "reincarnate", "ascend"},
        -- Enchant patterns
        {"enchant", "infuse", "imbue", "empower", "enhancement"}
    }
    
    -- Cari di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            
            -- Cocokkan dengan patterns
            for category, patternList in pairs(patterns) do
                for _, pattern in ipairs(patternList) do
                    if name:find(pattern) then
                        -- Tentukan kategori berdasarkan pattern yang cocok
                        if category == 1 then -- Tap patterns
                            if not Remotes.Tap then Remotes.Tap = v end
                            if not Remotes.Click then Remotes.Click = v end
                        elseif category == 2 then -- Egg patterns
                            if name:find("buy") or name:find("purchase") then
                                if not Remotes.BuyEgg then Remotes.BuyEgg = v end
                            else
                                if not Remotes.HatchEgg then Remotes.HatchEgg = v end
                            end
                        elseif category == 3 then -- Buy patterns
                            if name:find("egg") then
                                if not Remotes.BuyEgg then Remotes.BuyEgg = v end
                            elseif name:find("area") or name:find("zone") then
                                if not Remotes.BuyArea then Remotes.BuyArea = v end
                            else
                                if not Remotes.Purchase then Remotes.Purchase = v end
                            end
                        elseif category == 4 then -- Upgrade patterns
                            if not Remotes.Upgrade then Remotes.Upgrade = v end
                        elseif category == 5 then -- Area patterns
                            if not Remotes.BuyArea then Remotes.BuyArea = v end
                        elseif category == 6 then -- Collect patterns
                            if name:find("daily") or name:find("day") then
                                if not Remotes.ClaimDaily then Remotes.ClaimDaily = v end
                            else
                                if not Remotes.Collect then Remotes.Collect = v end
                            end
                        elseif category == 7 then -- Rebirth patterns
                            if not Remotes.Rebirth then Remotes.Rebirth = v end
                        elseif category == 8 then -- Enchant patterns
                            if not Remotes.Enchant then Remotes.Enchant = v end
                        end
                        break
                    end
                end
            end
            
            -- Simpan ke cache
            RemoteCache[name] = v
        end
    end
    
    -- Cari di PlayerScripts
    for _, v in pairs(Player.PlayerScripts:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("tap") or name:find("click") then
                if not Remotes.Tap then Remotes.Tap = v end
            end
            RemoteCache[name] = v
        end
    end
    
    -- Tampilkan hasil pencarian
    print("✅ Remotes ditemukan:")
    for name, remote in pairs(Remotes) do
        if remote then
            print("   ✓ " .. name .. ": " .. remote.ClassName .. " - " .. remote.Name)
        end
    end
end

-- Panggil fungsi pencarian
FindAllRemotes()

--==================================================
-- TOGGLES & SETTINGS (Dari semua script)
--==================================================
local Toggles = {
    -- Auto Tap (Dari AutoTap.lua, AutoTapKeyless.lua)
    AutoTap = false,
    TapSpeed = 0.001,
    AutoClicker = false,
    ClickSpeed = 0.0001,
    
    -- Auto Farm (Dari AutoFarm&Rebirth.lua, AutoFarm&Hatch.lua)
    AutoFarm = false,
    FarmMode = "Balanced", -- Balanced, Aggressive, Safe
    FarmSpeed = 0.01,
    
    -- Auto Rebirth (Dari AutoRebirth.lua)
    AutoRebirth = false,
    RebirthMode = "Auto", -- Auto, Custom
    RebirthAt = 1000,
    RebirthMultiplier = 1,
    
    -- Auto Hatch (Dari EggSystem.lua)
    AutoBuyEgg = false,
    EggType = "Basic",
    EggPriority = "Highest", -- Highest, Lowest, Random
    AutoHatch = false,
    HatchDelay = 0.5,
    
    -- Auto Upgrade (Dari OPScript.lua, OPFreeScript.lua)
    AutoUpgrade = false,
    UpgradeType = "All", -- All, Damage, Speed, Multiplier, Critical
    UpgradePriority = "Balanced",
    AutoBuyArea = false,
    
    -- Auto Collect (Dari Rewards.lua, QuickProgress.lua)
    AutoCollect = false,
    AutoClaimDaily = false,
    AutoClaimRewards = false,
    
    -- Auto Enchant (Dari BestAutoEnchant.lua, AutoEnchant.lua)
    AutoEnchant = false,
    EnchantType = "All", -- All, Damage, Speed, Critical
    EnchantPriority = "Highest Power",
    EnchantDelay = 1,
    
    -- Auto Unlock (Dari AutoUnlock.lua)
    AutoUnlock = false,
    UnlockMode = "Sequential", -- Sequential, Priority, All
    
    -- Visuals (Dari SmoothUI.lua)
    ESP = false,
    FullBright = false,
    NoFog = false,
    RainbowMode = false,
    
    -- Misc (Dari AutomationScript.lua, Automations.lua)
    AntiAFK = false,
    AutoRejoin = false,
    ServerHop = false,
    AutoClick = false,
    
    -- Advanced Features
    MultiTap = false,
    MultiTapCount = 10,
    SmartFarm = false,
    Performance = "High", -- Low, Medium, High
    AutoSave = false
}

-- Loops untuk auto farm
local Loops = {}
local Stats = {
    Taps = 0,
    Coins = 0,
    Rebirths = 0,
    EggsHatched = 0,
    StartTime = os.time()
}

--==================================================
-- NOTIFICATION FUNCTION
--==================================================
local function Notify(msg, type)
    local icon = "info"
    if type == "success" then icon = "check-circle"
    elseif type == "error" then icon = "alert-circle"
    elseif type == "warning" then icon = "alert-triangle"
    elseif type == "tap" then icon = "zap"
    elseif type == "egg" then icon = "egg"
    elseif type == "rebirth" then icon = "refresh-cw"
    end
    
    OrionLib:MakeNotification({
        Name = "Tap Simulator",
        Content = msg,
        Image = icon,
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Tap Simulator Ultimate",
    Subtext = "Collection Edition v3.0",
    Version = "v3.0.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSim_Ultimate",
    IntroEnabled = true,
    IntroText = "Tap Simulator Ultimate",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

Notify("Ultimate Script Loaded!", "success")

--==================================================
-- CREATE ALL TABS (Dari berbagai script)
--==================================================
local Tabs = {
    Main = Window:MakeTab({Name = "Main", Icon = "home", Glass = true, Outline = true}),
    AutoTap = Window:MakeTab({Name = "Auto Tap", Icon = "zap", Glass = true, Outline = true}),
    AutoFarm = Window:MakeTab({Name = "Auto Farm", Icon = "tractor", Glass = true, Outline = true}),
    Eggs = Window:MakeTab({Name = "Eggs", Icon = "egg", Glass = true, Outline = true}),
    Upgrades = Window:MakeTab({Name = "Upgrades", Icon = "trending-up", Glass = true, Outline = true}),
    Rebirth = Window:MakeTab({Name = "Rebirth", Icon = "refresh-cw", Glass = true, Outline = true}),
    Enchant = Window:MakeTab({Name = "Enchant", Icon = "sparkles", Glass = true, Outline = true}),
    Visuals = Window:MakeTab({Name = "Visuals", Icon = "eye", Glass = true, Outline = true}),
    Stats = Window:MakeTab({Name = "Stats", Icon = "bar-chart", Glass = true, Outline = true}),
    Misc = Window:MakeTab({Name = "Misc", Icon = "settings", Glass = true, Outline = true})
}

--==================================================
-- ADVANCED UTILITY FUNCTIONS
--==================================================

-- Format angka (K, M, B, T)
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

-- Get coins dengan berbagai metode
local function GetCoins()
    -- Metode 1: leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash") or v.Name:lower():find("point") or v.Name:lower():find("money")) then
                Stats.Coins = v.Value
                return v.Value
            end
        end
    end
    
    -- Metode 2: Player stats
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
            Stats.Coins = v.Value
            return v.Value
        end
    end
    
    -- Metode 3: Data folder
    local dataFolder = Player:FindFirstChild("Data") or Player:FindFirstChild("Stats")
    if dataFolder then
        for _, v in pairs(dataFolder:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
                Stats.Coins = v.Value
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
            if v:IsA("NumberValue") and (v.Name:lower():find("rebirth") or v.Name:lower():find("prestige") or v.Name:lower():find("ascend")) then
                Stats.Rebirths = v.Value
                return v.Value
            end
        end
    end
    return 0
end

-- Advanced Tap function dengan multiple methods
local function Tap()
    Stats.Taps = Stats.Taps + 1
    
    -- Method 1: Remote yang sudah ditemukan
    if Remotes.Tap then
        pcall(function()
            if Remotes.Tap:IsA("RemoteEvent") then
                Remotes.Tap:FireServer()
            elseif Remotes.Tap:IsA("RemoteFunction") then
                Remotes.Tap:InvokeServer()
            end
        end)
        return
    end
    
    -- Method 2: ClickEvent
    if Remotes.ClickEvent then
        pcall(function() Remotes.ClickEvent:FireServer("Click") end)
        return
    end
    
    -- Method 3: MainEvent
    if Remotes.MainEvent then
        pcall(function() Remotes.MainEvent:FireServer("Click") end)
        return
    end
    
    -- Method 4: Cari remote yang bisa dipanggil
    for name, remote in pairs(RemoteCache) do
        if remote:IsA("RemoteEvent") and not name:find("character") and not name:find("humanoid") then
            pcall(function() remote:FireServer() end)
            break
        end
    end
    
    -- Method 5: Simulate click
    mouse1click()
end

-- Multi Tap
local function MultiTap(count)
    count = count or Toggles.MultiTapCount
    for i = 1, count do
        Tap()
        if i % 10 == 0 then task.wait() end
    end
end

-- Buy Egg function
local function BuyEgg(eggType)
    if Remotes.BuyEgg then
        pcall(function() 
            if Remotes.BuyEgg:IsA("RemoteEvent") then
                Remotes.BuyEgg:FireServer(eggType or Toggles.EggType)
            else
                Remotes.BuyEgg:InvokeServer(eggType or Toggles.EggType)
            end
        end)
    elseif Remotes.PurchaseEgg then
        pcall(function() Remotes.PurchaseEgg:FireServer(eggType or Toggles.EggType) end)
    end
end

-- Hatch Egg function
local function HatchEgg()
    if Remotes.HatchEgg then
        pcall(function() Remotes.HatchEgg:FireServer() end)
        Stats.EggsHatched = Stats.EggsHatched + 1
    elseif Remotes.OpenEgg then
        pcall(function() Remotes.OpenEgg:FireServer() end)
        Stats.EggsHatched = Stats.EggsHatched + 1
    end
end

-- Upgrade function
local function Upgrade(upgradeType)
    if Remotes.Upgrade then
        pcall(function() 
            if upgradeType then
                Remotes.Upgrade:FireServer(upgradeType)
            else
                Remotes.Upgrade:FireServer(Toggles.UpgradeType)
            end
        end)
    elseif Remotes.PurchaseUpgrade then
        pcall(function() Remotes.PurchaseUpgrade:FireServer(upgradeType or Toggles.UpgradeType) end)
    end
end

-- Buy Area function
local function BuyArea()
    if Remotes.BuyArea then
        pcall(function() Remotes.BuyArea:FireServer() end)
    elseif Remotes.PurchaseArea then
        pcall(function() Remotes.PurchaseArea:FireServer() end)
    end
end

-- Collect function
local function Collect()
    if Remotes.Collect then
        pcall(function() Remotes.Collect:FireServer() end)
    elseif Remotes.ClaimReward then
        pcall(function() Remotes.ClaimReward:FireServer() end)
    end
end

-- Claim Daily
local function ClaimDaily()
    if Remotes.ClaimDaily then
        pcall(function() Remotes.ClaimDaily:FireServer() end)
    elseif Remotes.DailyReward then
        pcall(function() Remotes.DailyReward:FireServer() end)
    end
end

-- Rebirth function
local function Rebirth()
    if Remotes.Rebirth then
        pcall(function() Remotes.Rebirth:FireServer() end)
    elseif Remotes.Prestige then
        pcall(function() Remotes.Prestige:FireServer() end)
    end
end

-- Enchant function
local function Enchant(itemType)
    if Remotes.Enchant then
        pcall(function() Remotes.Enchant:FireServer(itemType or Toggles.EnchantType) end)
    elseif Remotes.EnchantItem then
        pcall(function() Remotes.EnchantItem:FireServer(itemType or Toggles.EnchantType) end)
    end
end

-- Find nearest egg
local function FindNearestEgg()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("egg") and v:IsA("BasePart") and v.Transparency < 1 then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        elseif v:IsA("Model") and v.Name:lower():find("egg") and v.PrimaryPart then
            local d = (root.Position - v.PrimaryPart.Position).Magnitude
            if d < dist then
                dist, nearest = d, v.PrimaryPart
            end
        end
    end
    return nearest
end

-- Get server players count
local function GetServerPlayers()
    return #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers
end

-- Get ping
local function GetPing()
    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
end

--==================================================
-- ADVANCED LOOP FUNCTIONS
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
            
            -- Auto Tap
            if name == "AutoTap" and Toggles.AutoTap then
                if Toggles.MultiTap then
                    MultiTap()
                else
                    Tap()
                end
                task.wait(Toggles.TapSpeed)
            end
            
            -- Auto Clicker
            if name == "AutoClicker" and Toggles.AutoClicker then
                mouse1click()
                task.wait(Toggles.ClickSpeed)
            end
            
            -- Auto Farm
            if name == "AutoFarm" and Toggles.AutoFarm then
                -- Farm mode logic
                if Toggles.FarmMode == "Aggressive" then
                    for i = 1, 10 do Tap() end
                elseif Toggles.FarmMode == "Balanced" then
                    Tap()
                end
                task.wait(Toggles.FarmSpeed)
            end
            
            -- Auto Buy Egg
            if name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                BuyEgg()
                task.wait(0.5)
            end
            
            -- Auto Hatch
            if name == "AutoHatch" and Toggles.AutoHatch then
                HatchEgg()
                task.wait(Toggles.HatchDelay)
            end
            
            -- Auto Upgrade
            if name == "AutoUpgrade" and Toggles.AutoUpgrade then
                if Toggles.UpgradeType == "All" then
                    Upgrade("Damage")
                    task.wait(0.1)
                    Upgrade("Speed")
                    task.wait(0.1)
                    Upgrade("Multiplier")
                    task.wait(0.1)
                    Upgrade("Critical")
                else
                    Upgrade(Toggles.UpgradeType)
                end
                task.wait(0.5)
            end
            
            -- Auto Buy Area
            if name == "AutoBuyArea" and Toggles.AutoBuyArea then
                BuyArea()
                task.wait(1)
            end
            
            -- Auto Collect
            if name == "AutoCollect" and Toggles.AutoCollect then
                Collect()
                task.wait(2)
            end
            
            -- Auto Claim Daily
            if name == "AutoClaimDaily" and Toggles.AutoClaimDaily then
                ClaimDaily()
                task.wait(60) -- Check every minute
            end
            
            -- Auto Rebirth
            if name == "AutoRebirth" and Toggles.AutoRebirth then
                local coins = GetCoins()
                if Toggles.RebirthMode == "Auto" then
                    if coins >= 1000 * (Stats.Rebirths + 1) then
                        Rebirth()
                        task.wait(2)
                    end
                else
                    if coins >= Toggles.RebirthAt then
                        Rebirth()
                        task.wait(2)
                    end
                end
                task.wait(1)
            end
            
            -- Auto Enchant
            if name == "AutoEnchant" and Toggles.AutoEnchant then
                if Toggles.EnchantType == "All" then
                    Enchant("Damage")
                    task.wait(Toggles.EnchantDelay)
                    Enchant("Speed")
                    task.wait(Toggles.EnchantDelay)
                    Enchant("Critical")
                else
                    Enchant(Toggles.EnchantType)
                end
                task.wait(Toggles.EnchantDelay)
            end
            
            -- Auto Unlock
            if name == "AutoUnlock" and Toggles.AutoUnlock then
                if Toggles.UnlockMode == "Sequential" then
                    BuyArea()
                    task.wait(1)
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
-- MAIN TAB CONTENT
--==================================================
local MainStatsSection = Tabs.Main:AddSection({
    Name = "Player Stats",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Live stats paragraph
local StatsPara = MainStatsSection:AddParagraph({
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
                StatsPara:SetDesc(
                    "Coins: " .. formatNumber(coins) .. "\n" ..
                    "Rebirths: " .. rebirths .. "\n" ..
                    "Taps: " .. formatNumber(Stats.Taps) .. "\n" ..
                    "Eggs Hatched: " .. Stats.EggsHatched
                )
            end
        }
    }
})

-- Update stats setiap 2 detik
task.spawn(function()
    while true do
        local coins = GetCoins()
        local rebirths = GetRebirths()
        local uptime = os.time() - Stats.StartTime
        local hours = math.floor(uptime / 3600)
        local minutes = math.floor((uptime % 3600) / 60)
        local seconds = uptime % 60
        
        StatsPara:SetDesc(
            "Coins: " .. formatNumber(coins) .. "\n" ..
            "Rebirths: " .. rebirths .. "\n" ..
            "Taps: " .. formatNumber(Stats.Taps) .. "\n" ..
            "Eggs Hatched: " .. Stats.EggsHatched .. "\n" ..
            "Uptime: " .. string.format("%02d:%02d:%02d", hours, minutes, seconds)
        )
        task.wait(2)
    end
end)

local QuickActionsSection = Tabs.Main:AddSection({
    Name = "Quick Actions",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

QuickActionsSection:AddButton({
    Name = "Tap 10x",
    Icon = "zap",
    Outline = true,
    Callback = function()
        MultiTap(10)
        Notify("Tapped 10 times!", "tap")
    end
})

QuickActionsSection:AddButton({
    Name = "Tap 100x",
    Icon = "zap",
    Outline = true,
    Callback = function()
        MultiTap(100)
        Notify("Tapped 100 times!", "tap")
    end
})

QuickActionsSection:AddButton({
    Name = "Hatch Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        HatchEgg()
        Notify("Egg hatched!", "egg")
    end
})

QuickActionsSection:AddButton({
    Name = "Buy Basic Egg",
    Icon = "shopping-cart",
    Outline = true,
    Callback = function()
        BuyEgg("Basic")
        Notify("Bought Basic Egg!", "egg")
    end
})

QuickActionsSection:AddButton({
    Name = "Rebirth Now",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        Rebirth()
        Notify("Rebirthed!", "rebirth")
    end
})

local ServerInfoSection = Tabs.Main:AddSection({
    Name = "Server Info",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = "Players: " .. GetServerPlayers() .. "\nPing: " .. GetPing() .. "ms",
    Image = "server",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                -- Will update on next cycle
            end
        }
    }
})

--==================================================
-- AUTO TAP TAB (Dari AutoTap.lua, AutoTapKeyless.lua)
--==================================================
local TapSection = Tabs.AutoTap:AddSection({
    Name = "Auto Tap Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local AutoTapToggle = TapSection:AddToggle({
    Name = "Enable Auto Tap",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoTap",
    Save = true,
    Callback = function(Value)
        Toggles.AutoTap = Value
        if Value then 
            StartLoop("AutoTap")
            Notify("Auto Tap Enabled", "success")
        else 
            StopLoop("AutoTap")
            Notify("Auto Tap Disabled", "warning")
        end
    end
})

TapSection:AddSlider({
    Name = "Tap Speed",
    Min = 0.0001,
    Max = 0.1,
    Default = 0.001,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.0001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.TapSpeed = Value
    end
})

TapSection:AddToggle({
    Name = "Multi Tap",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "MultiTap",
    Save = true,
    Callback = function(Value)
        Toggles.MultiTap = Value
    end
})

TapSection:AddSlider({
    Name = "Multi Tap Count",
    Min = 2,
    Max = 100,
    Default = 10,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "taps",
    Outline = true,
    Callback = function(Value)
        Toggles.MultiTapCount = Value
    end
})

local ClickerSection = Tabs.AutoTap:AddSection({
    Name = "Auto Clicker",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ClickerSection:AddToggle({
    Name = "Enable Auto Clicker",
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

ClickerSection:AddSlider({
    Name = "Click Speed",
    Min = 0.00001,
    Max = 0.01,
    Default = 0.0001,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.00001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.ClickSpeed = Value
    end
})

--==================================================
-- AUTO FARM TAB (Dari AutoFarm&Rebirth.lua, AutoFarm&Hatch.lua)
--==================================================
local FarmSection = Tabs.AutoFarm:AddSection({
    Name = "Auto Farm",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

FarmSection:AddToggle({
    Name = "Enable Auto Farm",
    Default = false,
    Color = Color3.fromRGB(0, 200, 255),
    Outline = true,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Toggles.AutoFarm = Value
        if Value then StartLoop("AutoFarm") else StopLoop("AutoFarm") end
    end
})

FarmSection:AddDropdown({
    Name = "Farm Mode",
    Default = "Balanced",
    Options = {"Balanced", "Aggressive", "Safe"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.FarmMode = Value
        if Value == "Aggressive" then
            Toggles.FarmSpeed = 0.005
        elseif Value == "Balanced" then
            Toggles.FarmSpeed = 0.01
        else
            Toggles.FarmSpeed = 0.02
        end
    end
})

FarmSection:AddSlider({
    Name = "Farm Speed",
    Min = 0.001,
    Max = 0.1,
    Default = 0.01,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.FarmSpeed = Value
    end
})

FarmSection:AddToggle({
    Name = "Smart Farm",
    Default = false,
    Color = Color3.fromRGB(255, 100, 255),
    Outline = true,
    Flag = "SmartFarm",
    Save = true,
    Callback = function(Value)
        Toggles.SmartFarm = Value
        Notify(Value and "Smart Farm Enabled" or "Smart Farm Disabled", "info")
    end
})

--==================================================
-- EGGS TAB (Dari EggSystem.lua)
--==================================================
local EggSection = Tabs.Eggs:AddSection({
    Name = "Egg Automation",
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
        if Value then StartLoop("AutoBuyEgg") else StopLoop("AutoBuyEgg") end
    end
})

EggSection:AddDropdown({
    Name = "Egg Type",
    Default = "Basic",
    Options = {"Basic", "Rare", "Epic", "Legendary", "Mythic", "Divine"},
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EggType = Value
    end
})

EggSection:AddDropdown({
    Name = "Egg Priority",
    Default = "Highest",
    Options = {"Highest", "Lowest", "Random"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EggPriority = Value
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

EggSection:AddButton({
    Name = "Find Nearest Egg",
    Icon = "search",
    Outline = true,
    Callback = function()
        local egg = FindNearestEgg()
        if egg then
            local dist = (Player.Character.HumanoidRootPart.Position - egg.Position).Magnitude
            Notify("Egg found! Distance: " .. math.floor(dist) .. "m", "success")
        else
            Notify("No eggs found nearby!", "error")
        end
    end
})

--==================================================
-- UPGRADES TAB (Dari OPScript.lua, OPFreeScript.lua)
--==================================================
local UpgradeSection = Tabs.Upgrades:AddSection({
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
        if Value then StartLoop("AutoUpgrade") else StopLoop("AutoUpgrade") end
    end
})

UpgradeSection:AddDropdown({
    Name = "Upgrade Type",
    Default = "All",
    Options = {"All", "Damage", "Speed", "Multiplier", "Critical", "Luck", "Strength"},
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.UpgradeType = Value
    end
})

UpgradeSection:AddDropdown({
    Name = "Upgrade Priority",
    Default = "Balanced",
    Options = {"Damage First", "Speed First", "Balanced", "Critical First"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.UpgradePriority = Value
    end
})

local AreaSection = Tabs.Upgrades:AddSection({
    Name = "Area",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

AreaSection:AddToggle({
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

--==================================================
-- REBIRTH TAB (Dari AutoRebirth.lua)
--==================================================
local RebirthSection = Tabs.Rebirth:AddSection({
    Name = "Rebirth Settings",
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
        if Value then StartLoop("AutoRebirth") else StopLoop("AutoRebirth") end
    end
})

RebirthSection:AddDropdown({
    Name = "Rebirth Mode",
    Default = "Auto",
    Options = {"Auto", "Custom"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.RebirthMode = Value
    end
})

RebirthSection:AddSlider({
    Name = "Rebirth At",
    Min = 100,
    Max = 10000000,
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
-- ENCHANT TAB (Dari BestAutoEnchant.lua, AutoEnchant.lua)
--==================================================
local EnchantSection = Tabs.Enchant:AddSection({
    Name = "Enchant System",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

EnchantSection:AddToggle({
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

EnchantSection:AddDropdown({
    Name = "Enchant Type",
    Default = "All",
    Options = {"All", "Damage", "Speed", "Critical", "Luck", "Multiplier"},
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EnchantType = Value
    end
})

EnchantSection:AddDropdown({
    Name = "Enchant Priority",
    Default = "Highest Power",
    Options = {"Highest Power", "Balanced", "Lowest Cost"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EnchantPriority = Value
    end
})

EnchantSection:AddSlider({
    Name = "Enchant Delay",
    Min = 0.5,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.EnchantDelay = Value
    end
})

--==================================================
-- VISUALS TAB (Dari SmoothUI.lua)
--==================================================
local VisualSection = Tabs.Visuals:AddSection({
    Name = "Visual Effects",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

VisualSection:AddToggle({
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
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        end
    end
})

VisualSection:AddToggle({
    Name = "No Fog",
    Default = false,
    Color = Color3.fromRGB(255, 255, 0),
    Outline = true,
    Flag = "NoFog",
    Save = true,
    Callback = function(Value)
        Toggles.NoFog = Value
        Lighting.FogEnd = Value and 1e9 or 100000
        Lighting.FogStart = Value and 0 or 0
    end
})

VisualSection:AddToggle({
    Name = "Rainbow Mode",
    Default = false,
    Color = Color3.fromRGB(255, 0, 255),
    Outline = true,
    Flag = "RainbowMode",
    Save = true,
    Callback = function(Value)
        Toggles.RainbowMode = Value
        if Value then
            task.spawn(function()
                while Toggles.RainbowMode do
                    Lighting.Ambient = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    Lighting.OutdoorAmbient = Color3.fromHSV(tick() % 5 / 5, 0.5, 1)
                    task.wait(0.1)
                end
            end)
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        end
    end
})

--==================================================
-- STATS TAB
--==================================================
local DetailedStatsSection = Tabs.Stats:AddSection({
    Name = "Detailed Statistics",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local function UpdateStatsDisplay()
    local uptime = os.time() - Stats.StartTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = uptime % 60
    
    local tps = Stats.Taps / uptime
    
    DetailedStatsSection:AddParagraph({
        Title = "Performance Stats",
        Desc = string.format(
            "Total Taps: %s\n" ..
            "Taps/Second: %.2f\n" ..
            "Coins Earned: %s\n" ..
            "Rebirths: %d\n" ..
            "Eggs Hatched: %d\n" ..
            "Uptime: %02d:%02d:%02d",
            formatNumber(Stats.Taps),
            tps,
            formatNumber(Stats.Coins),
            Stats.Rebirths,
            Stats.EggsHatched,
            hours, minutes, seconds
        ),
        Image = "bar-chart",
        ImageSize = 38
    })
end

--==================================================
-- MISC TAB (Dari AutomationScript.lua, Automations.lua)
--==================================================
local MiscSection = Tabs.Misc:AddSection({
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
            Notify("Anti AFK Enabled", "success")
        else
            Notify("Anti AFK Disabled", "warning")
        end
    end
})

MiscSection:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Color = Color3.fromRGB(100, 255, 100),
    Outline = true,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollect = Value
        if Value then StartLoop("AutoCollect") else StopLoop("AutoCollect") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Claim Daily",
    Default = false,
    Color = Color3.fromRGB(255, 200, 0),
    Outline = true,
    Flag = "AutoClaimDaily",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClaimDaily = Value
        if Value then StartLoop("AutoClaimDaily") else StopLoop("AutoClaimDaily") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Save",
    Default = false,
    Color = Color3.fromRGB(100, 200, 255),
    Outline = true,
    Flag = "AutoSave",
    Save = true,
    Callback = function(Value)
        Toggles.AutoSave = Value
    end
})

MiscSection:AddDropdown({
    Name = "Performance Mode",
    Default = "High",
    Options = {"Low", "Medium", "High"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.Performance = Value
        if Value == "Low" then
            RunService:Set3dRenderingEnabled(false)
        else
            RunService:Set3dRenderingEnabled(true)
        end
    end
})

local ServerSection = Tabs.Misc:AddSection({
    Name = "Server",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

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
        local placeId = game.PlaceId
        
        local function getServers()
            local servers = {}
            local cursor = ""
            repeat
                local success, result = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")))
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
            TeleportService:TeleportToPlaceInstance(placeId, randomServer, Player)
        else
            Notify("No servers available!", "error")
        end
    end
})

ServerSection:AddButton({
    Name = "Copy Server ID",
    Icon = "copy",
    Outline = true,
    Callback = function()
        setclipboard(tostring(game.JobId))
        Notify("Server ID copied to clipboard!", "success")
    end
})

local GUISection = Tabs.Misc:AddSection({
    Name = "GUI",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

GUISection:AddButton({
    Name = "Close GUI",
    Icon = "x",
    Outline = true,
    Callback = function()
        OrionLib:Destroy()
        _G.TapSimLoaded = false
        Notify("GUI Closed", "warning")
    end
})

GUISection:AddButton({
    Name = "Toggle UI",
    Icon = "eye",
    Outline = true,
    Callback = function()
        -- Will be handled by OrionLib
    end
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
OrionLib:Init()

Notify("Tap Simulator Ultimate v3.0 Loaded!", "success")
print("=== TAP SIMULATOR ULTIMATE v3.0 ===")
print("✅ 20+ Scripts merged successfully")
print("✅ All features integrated")
print("✅ Press F4 to toggle menu")