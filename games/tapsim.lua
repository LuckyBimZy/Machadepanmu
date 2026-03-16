-- ==================== TAP SIMULATOR - ULTIMATE COLLECTION ====================
-- Gabungan dari berbagai script dengan UI Catraz Hub
-- Version: 3.0 Ultimate - All Features Combined

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
local TweenService = game:GetService("TweenService")

--==================================================
-- REMOTE FINDING - Dari semua script
--==================================================
local Remotes = {
    Tap = nil,
    BuyEgg = nil,
    HatchEgg = nil,
    BuyArea = nil,
    Upgrade = nil,
    Collect = nil,
    Rebirth = nil,
    Click = nil,
    Purchase = nil,
    Claim = nil,
    Event = nil,
    Enchant = nil,
    Craft = nil,
    Unlock = nil,
    DailyReward = nil,
    Teleport = nil
}

-- Fungsi untuk mencari remotes (dari script 1-20)
local function FindRemotes()
    -- Script 1: Pencarian di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            
            -- Tap/Click remotes
            if name:find("tap") or name:find("click") then
                Remotes.Tap = v
                Remotes.Click = v
            end
            
            -- Egg remotes
            if (name:find("egg") and (name:find("buy") or name:find("purchase"))) or name:find("buyegg") then
                Remotes.BuyEgg = v
            end
            if name:find("hatch") or name:find("open") then
                Remotes.HatchEgg = v
            end
            
            -- Area remotes
            if (name:find("area") or name:find("zone")) and (name:find("buy") or name:find("purchase")) then
                Remotes.BuyArea = v
            end
            
            -- Upgrade remotes
            if name:find("upgrade") or name:find("power") or name:find("enhance") then
                Remotes.Upgrade = v
            end
            
            -- Collect/Claim remotes
            if name:find("collect") or name:find("claim") then
                Remotes.Collect = v
            end
            if name:find("daily") or name:find("reward") then
                Remotes.DailyReward = v
                Remotes.Claim = v
            end
            
            -- Rebirth remotes
            if name:find("rebirth") or name:find("prestige") or name:find("reset") then
                Remotes.Rebirth = v
            end
            
            -- Enchant/Craft remotes
            if name:find("enchant") then
                Remotes.Enchant = v
            end
            if name:find("craft") then
                Remotes.Craft = v
            end
            if name:find("unlock") then
                Remotes.Unlock = v
            end
            
            -- Teleport remotes
            if name:find("teleport") or name:find("tp") then
                Remotes.Teleport = v
            end
            
            -- Generic event
            if name:find("event") or name:find("main") then
                Remotes.Event = v
            end
        end
    end
    
    -- Script 2-20: Pencarian di PlayerScripts
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

--==================================================
-- TOGGLES - Semua fitur dari semua script
--==================================================
local Toggles = {
    -- Auto Tap (dari AutoTap.lua, AutoTapKeyless.lua)
    AutoTap = false,
    TapSpeed = 0.01,
    AutoClicker = false,
    ClickSpeed = 0.001,
    MultiTap = false,
    TapPower = 1,
    
    -- Auto Farm (dari AutoFarm&Rebirth.lua, AutoFarm&Hatch.lua, BalancedAutoFarmScript.lua)
    AutoFarm = false,
    FarmMode = "All",
    AutoCollectCoins = false,
    AutoCollectGems = false,
    AutoCollectRewards = false,
    
    -- Eggs (dari EggSystem.lua)
    AutoBuyEgg = false,
    EggType = "Basic",
    AutoHatch = false,
    AutoOpenEggs = false,
    EggPriority = "Lowest",
    
    -- Upgrades (dari OPCraftingScript.lua, OPFreeScript.lua, OPScript.lua)
    AutoUpgrade = false,
    UpgradeType = "All",
    UpgradePriority = "Damage",
    AutoBuyArea = false,
    AutoUnlockZones = false,
    
    -- Rebirth (dari AutoRebirth.lua)
    AutoRebirth = false,
    RebirthAt = 1000,
    RebirthMode = "Auto",
    MaxRebirths = 100,
    
    -- Enchant (dari AutoEnchant.lua, BestAutoEnchant.lua)
    AutoEnchant = false,
    EnchantType = "All",
    EnchantPriority = "Legendary",
    AutoCraft = false,
    AutoUnlock = false,
    
    -- Teleport (dari Teleport.lua, Teleports.lua, TeleportZones.lua)
    AutoTeleport = false,
    TeleportToZone = "Next",
    TeleportSpeed = 1,
    ZoneHopping = false,
    
    -- Visuals (dari SmoothUI.lua)
    ESP = false,
    ESPType = "Players",
    FullBright = false,
    NoFog = false,
    NoGrass = false,
    
    -- Misc (dari semua script)
    AntiAFK = false,
    AutoClaimDaily = false,
    AutoQuest = false,
    AutoSpin = false,
    AutoMerge = false,
    ServerHop = false,
    Rejoin = false,
    AutoSave = false
}

-- Loops
local Loops = {}
local Stats = {
    Coins = 0,
    Gems = 0,
    Rebirths = 0,
    Eggs = 0,
    Upgrades = 0,
    PlayTime = 0
}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Tap Simulator",
        Content = msg,
        Image = "zap",
        Time = duration or 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Tap Simulator",
    Subtext = "Ultimate Collection v3.0",
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
    
    -- Custom Theme
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    -- Floating Toggle
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

Notify("Ultimate Script Loaded! All features combined!")

--==================================================
-- CREATE TABS - Dari semua script
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local AutoTapTab = Window:MakeTab({
    Name = "Auto Tap",
    Icon = "hand",
    Glass = true,
    Outline = true
})

local AutoFarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local EggTab = Window:MakeTab({
    Name = "Egg System",
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

local RebirthTab = Window:MakeTab({
    Name = "Rebirth",
    Icon = "refresh-cw",
    Glass = true,
    Outline = true
})

local EnchantTab = Window:MakeTab({
    Name = "Enchant",
    Icon = "sparkles",
    Glass = true,
    Outline = true
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "map-pin",
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
-- UTILITY FUNCTIONS - Dari semua script
--==================================================

-- Format angka (dari berbagai script)
local function formatNumber(num)
    if num >= 1e15 then
        return string.format("%.2fQ", num / 1e15)
    elseif num >= 1e12 then
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

-- Get coins/points (dari semua script)
local function GetCoins()
    -- Coba leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("coin") or name:find("cash") or name:find("point") or name:find("money") then
                    Stats.Coins = v.Value
                    return v.Value
                end
            end
        end
    end
    
    -- Coba di Player
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
            Stats.Coins = v.Value
            return v.Value
        end
    end
    
    -- Coba di PlayerStats
    local stats = Player:FindFirstChild("PlayerStats") or Player:FindFirstChild("Stats")
    if stats then
        for _, v in pairs(stats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
                Stats.Coins = v.Value
                return v.Value
            end
        end
    end
    
    return Stats.Coins
end

-- Get gems (dari OPCraftingScript.lua)
local function GetGems()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("gem") or v.Name:lower():find("diamond")) then
                Stats.Gems = v.Value
                return v.Value
            end
        end
    end
    return Stats.Gems
end

-- Get rebirths (dari AutoRebirth.lua)
local function GetRebirths()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("rebirth") or v.Name:lower():find("prestige")) then
                Stats.Rebirths = v.Value
                return v.Value
            end
        end
    end
    return Stats.Rebirths
end

-- Tap function (dari AutoTap.lua, AutoTapKeyless.lua)
local function Tap()
    if Remotes.Tap then
        pcall(function()
            if Remotes.Tap:IsA("RemoteEvent") then
                if Toggles.MultiTap and Toggles.TapPower > 1 then
                    for i = 1, Toggles.TapPower do
                        Remotes.Tap:FireServer()
                    end
                else
                    Remotes.Tap:FireServer()
                end
            elseif Remotes.Tap:IsA("RemoteFunction") then
                Remotes.Tap:InvokeServer()
            end
        end)
    elseif Remotes.Click then
        pcall(function() Remotes.Click:FireServer() end)
    elseif Remotes.Event then
        pcall(function() Remotes.Event:FireServer("Tap") end)
        pcall(function() Remotes.Event:FireServer("Click") end)
    else
        -- Fallback: Cari remote apapun
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and not v.Name:find("Character") then
                pcall(function() v:FireServer() end)
                break
            end
        end
    end
end

-- Buy egg function (dari EggSystem.lua)
local function BuyEgg(eggType)
    if Remotes.BuyEgg then
        pcall(function() 
            if Remotes.BuyEgg:IsA("RemoteEvent") then
                Remotes.BuyEgg:FireServer(eggType)
            else
                Remotes.BuyEgg:InvokeServer(eggType)
            end
        end)
    else
        local remote = ReplicatedStorage:FindFirstChild("BuyEgg") or 
                      ReplicatedStorage:FindFirstChild("PurchaseEgg") or
                      ReplicatedStorage:FindFirstChild("EggEvent")
        if remote then
            pcall(function() remote:FireServer(eggType) end)
        end
    end
end

-- Hatch egg function (dari EggSystem.lua)
local function HatchEgg()
    if Remotes.HatchEgg then
        pcall(function() 
            if Remotes.HatchEgg:IsA("RemoteEvent") then
                Remotes.HatchEgg:FireServer()
            else
                Remotes.HatchEgg:InvokeServer()
            end
        end)
    else
        local remote = ReplicatedStorage:FindFirstChild("HatchEgg") or 
                      ReplicatedStorage:FindFirstChild("OpenEgg") or
                      ReplicatedStorage:FindFirstChild("Hatch")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Upgrade function (dari OPScript.lua, OPFreeScript.lua)
local function Upgrade(upgradeType)
    if Remotes.Upgrade then
        pcall(function() 
            if Remotes.Upgrade:IsA("RemoteEvent") then
                Remotes.Upgrade:FireServer(upgradeType)
            else
                Remotes.Upgrade:InvokeServer(upgradeType)
            end
        end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Upgrade") or 
                      ReplicatedStorage:FindFirstChild("PurchaseUpgrade") or
                      ReplicatedStorage:FindFirstChild("Enhance")
        if remote then
            pcall(function() remote:FireServer(upgradeType) end)
        end
    end
end

-- Buy area function (dari Teleport.lua, Teleports.lua)
local function BuyArea()
    if Remotes.BuyArea then
        pcall(function() Remotes.BuyArea:FireServer() end)
    else
        local remote = ReplicatedStorage:FindFirstChild("BuyArea") or 
                      ReplicatedStorage:FindFirstChild("PurchaseArea") or
                      ReplicatedStorage:FindFirstChild("UnlockZone")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Collect rewards function (dari Rewards.lua)
local function Collect()
    if Remotes.Collect then
        pcall(function() Remotes.Collect:FireServer() end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Collect") or 
                      ReplicatedStorage:FindFirstChild("ClaimReward") or
                      ReplicatedStorage:FindFirstChild("GetReward")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Claim daily function (dari Rewards.lua)
local function ClaimDaily()
    if Remotes.DailyReward then
        pcall(function() Remotes.DailyReward:FireServer() end)
    else
        local remote = ReplicatedStorage:FindFirstChild("DailyReward") or 
                      ReplicatedStorage:FindFirstChild("ClaimDaily") or
                      ReplicatedStorage:FindFirstChild("Daily")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Rebirth function (dari AutoRebirth.lua)
local function Rebirth()
    if Remotes.Rebirth then
        pcall(function() 
            if Remotes.Rebirth:IsA("RemoteEvent") then
                Remotes.Rebirth:FireServer()
            else
                Remotes.Rebirth:InvokeServer()
            end
        end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Rebirth") or 
                      ReplicatedStorage:FindFirstChild("Prestige") or
                      ReplicatedStorage:FindFirstChild("Reset")
        if remote then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- Enchant function (dari AutoEnchant.lua, BestAutoEnchant.lua)
local function Enchant(itemType)
    if Remotes.Enchant then
        pcall(function() Remotes.Enchant:FireServer(itemType) end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Enchant") or 
                      ReplicatedStorage:FindFirstChild("EnchantItem")
        if remote then
            pcall(function() remote:FireServer(itemType) end)
        end
    end
end

-- Craft function (dari OPCraftingScript.lua)
local function Craft(itemType)
    if Remotes.Craft then
        pcall(function() Remotes.Craft:FireServer(itemType) end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Craft") or 
                      ReplicatedStorage:FindFirstChild("CraftItem")
        if remote then
            pcall(function() remote:FireServer(itemType) end)
        end
    end
end

-- Unlock function (dari AutoUnlock.lua)
local function Unlock(itemType)
    if Remotes.Unlock then
        pcall(function() Remotes.Unlock:FireServer(itemType) end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Unlock") or 
                      ReplicatedStorage:FindFirstChild("UnlockItem")
        if remote then
            pcall(function() remote:FireServer(itemType) end)
        end
    end
end

-- Teleport function (dari Teleport.lua, Teleports.lua, TeleportZones.lua)
local function TeleportToZone(zoneName)
    if Remotes.Teleport then
        pcall(function() Remotes.Teleport:FireServer(zoneName) end)
    else
        local remote = ReplicatedStorage:FindFirstChild("Teleport") or 
                      ReplicatedStorage:FindFirstChild("TeleportToZone")
        if remote then
            pcall(function() remote:FireServer(zoneName) end)
        end
    end
end

-- Find eggs in workspace (dari EggSystem.lua)
local function FindEggs()
    local eggs = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("egg") then
            if v:IsA("BasePart") and v.Transparency < 1 then
                table.insert(eggs, v)
            elseif v:IsA("Model") and v.PrimaryPart then
                table.insert(eggs, v.PrimaryPart)
            end
        end
    end
    return eggs
end

-- Find zones/areas (dari TeleportZones.lua)
local function FindZones()
    local zones = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("zone") or v.Name:lower():find("area") then
            if v:IsA("BasePart") then
                table.insert(zones, v)
            elseif v:IsA("Model") and v.PrimaryPart then
                table.insert(zones, v.PrimaryPart)
            end
        end
    end
    return zones
end

-- Egg ESP (dari Visuals)
local function UpdateEggESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("egg") then
            if v:IsA("BasePart") and Toggles.ESP then
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
end

-- Zone ESP (dari TeleportZones.lua)
local function UpdateZoneESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("zone") or v.Name:lower():find("area") then
            if v:IsA("BasePart") and Toggles.ESP then
                local highlight = v:FindFirstChild("ZoneHighlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ZoneHighlight"
                    highlight.Parent = v
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.3
                end
            else
                local highlight = v:FindFirstChild("ZoneHighlight")
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- Server hop function (dari QuickProgress.lua)
local function ServerHop()
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
        Notify("No servers available!")
    end
end

--==================================================
-- LOOP FUNCTIONS - Dari semua script
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
                mouse1click()
                task.wait(Toggles.ClickSpeed)
                
            elseif name == "AutoFarm" and Toggles.AutoFarm then
                if Toggles.FarmMode == "All" or Toggles.FarmMode == "Tap" then
                    Tap()
                end
                if Toggles.FarmMode == "All" or Toggles.FarmMode == "Collect" then
                    Collect()
                end
                task.wait(0.05)
                
            elseif name == "AutoCollectCoins" and Toggles.AutoCollectCoins then
                Collect()
                task.wait(1)
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                BuyEgg(Toggles.EggType)
                task.wait(1)
                
            elseif name == "AutoHatch" and Toggles.AutoHatch then
                HatchEgg()
                task.wait(0.5)
                
            elseif name == "AutoOpenEggs" and Toggles.AutoOpenEggs then
                HatchEgg()
                task.wait(0.3)
                
            elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                if Toggles.UpgradeType == "All" then
                    Upgrade("Damage")
                    Upgrade("Speed")
                    Upgrade("Multiplier")
                    Upgrade("Critical")
                else
                    Upgrade(Toggles.UpgradeType)
                end
                task.wait(1)
                
            elseif name == "AutoBuyArea" and Toggles.AutoBuyArea then
                BuyArea()
                task.wait(2)
                
            elseif name == "AutoUnlockZones" and Toggles.AutoUnlockZones then
                BuyArea()
                task.wait(1)
                
            elseif name == "AutoRebirth" and Toggles.AutoRebirth then
                local coins = GetCoins()
                if coins >= Toggles.RebirthAt then
                    Rebirth()
                    task.wait(3)
                else
                    task.wait(5)
                end
                
            elseif name == "AutoEnchant" and Toggles.AutoEnchant then
                Enchant(Toggles.EnchantType)
                task.wait(2)
                
            elseif name == "AutoCraft" and Toggles.AutoCraft then
                Craft("All")
                task.wait(2)
                
            elseif name == "AutoUnlock" and Toggles.AutoUnlock then
                Unlock("All")
                task.wait(2)
                
            elseif name == "AutoTeleport" and Toggles.AutoTeleport then
                local zones = FindZones()
                if #zones > 0 then
                    local zone = zones[math.random(1, #zones)]
                    Player.Character.HumanoidRootPart.CFrame = zone.CFrame + Vector3.new(0, 3, 0)
                end
                task.wait(Toggles.TeleportSpeed)
                
            elseif name == "ZoneHopping" and Toggles.ZoneHopping then
                local zones = FindZones()
                for _, zone in ipairs(zones) do
                    Player.Character.HumanoidRootPart.CFrame = zone.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.5)
                end
                
            elseif name == "AutoClaimDaily" and Toggles.AutoClaimDaily then
                ClaimDaily()
                task.wait(60)
                
            elseif name == "AutoQuest" and Toggles.AutoQuest then
                -- Auto complete quests
                local remote = ReplicatedStorage:FindFirstChild("QuestEvent") or 
                              ReplicatedStorage:FindFirstChild("CompleteQuest")
                if remote then
                    pcall(function() remote:FireServer() end)
                end
                task.wait(5)
                
            elseif name == "AutoSpin" and Toggles.AutoSpin then
                local remote = ReplicatedStorage:FindFirstChild("Spin") or 
                              ReplicatedStorage:FindFirstChild("WheelSpin")
                if remote then
                    pcall(function() remote:FireServer() end)
                end
                task.wait(1)
                
            elseif name == "AutoMerge" and Toggles.AutoMerge then
                local remote = ReplicatedStorage:FindFirstChild("Merge") or 
                              ReplicatedStorage:FindFirstChild("MergeItems")
                if remote then
                    pcall(function() remote:FireServer() end)
                end
                task.wait(1)
                
            elseif name == "AutoSave" and Toggles.AutoSave then
                local remote = ReplicatedStorage:FindFirstChild("Save") or 
                              ReplicatedStorage:FindFirstChild("AutoSave")
                if remote then
                    pcall(function() remote:FireServer() end)
                end
                task.wait(30)
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
local StatsSection = MainTab:AddSection({
    Name = "Player Stats",
    TextSize = 17,
    Folded = false,
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
                local gems = GetGems()
                local rebirths = GetRebirths()
                StatsPara:SetDesc(
                    "Coins: " .. formatNumber(coins) .. "\n" ..
                    "Gems: " .. formatNumber(gems) .. "\n" ..
                    "Rebirths: " .. rebirths
                )
            end
        }
    }
})

-- Update stats setiap 5 detik
task.spawn(function()
    while true do
        local coins = GetCoins()
        local gems = GetGems()
        local rebirths = GetRebirths()
        StatsPara:SetDesc(
            "Coins: " .. formatNumber(coins) .. "\n" ..
            "Gems: " .. formatNumber(gems) .. "\n" ..
            "Rebirths: " .. rebirths
        )
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
    Name = "Tap 100x",
    Icon = "hand",
    Outline = true,
    Callback = function()
        for i = 1, 100 do
            Tap()
            task.wait(0.01)
        end
        Notify("Tapped 100 times!")
    end
})

QuickSection:AddButton({
    Name = "Hatch All Eggs",
    Icon = "egg",
    Outline = true,
    Callback = function()
        for i = 1, 10 do
            HatchEgg()
            task.wait(0.1)
        end
        Notify("Hatched 10 eggs!")
    end
})

QuickSection:AddButton({
    Name = "Collect All",
    Icon = "gift",
    Outline = true,
    Callback = function()
        Collect()
        Notify("Collected rewards!")
    end
})

--==================================================
-- AUTO TAP TAB (dari AutoTap.lua, AutoTapKeyless.lua)
--==================================================
local TapSection = AutoTapTab:AddSection({
    Name = "Auto Tap Settings",
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
    Name = "Multi Tap",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "MultiTap",
    Save = true,
    Callback = function(Value)
        Toggles.MultiTap = Value
    end
})

TapSection:AddSlider({
    Name = "Tap Power",
    Min = 1,
    Max = 10,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "x",
    Outline = true,
    Callback = function(Value)
        Toggles.TapPower = Value
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
-- AUTO FARM TAB (dari AutoFarm&Rebirth.lua, AutoFarm&Hatch.lua)
--==================================================
local FarmSection = AutoFarmTab:AddSection({
    Name = "Auto Farm",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

FarmSection:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
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
    Default = "All",
    Options = {"All", "Tap Only", "Collect Only"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.FarmMode = Value
    end
})

local CollectSection = AutoFarmTab:AddSection({
    Name = "Auto Collect",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

CollectSection:AddToggle({
    Name = "Auto Collect Coins",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoCollectCoins",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollectCoins = Value
        if Value then StartLoop("AutoCollectCoins") else StopLoop("AutoCollectCoins") end
    end
})

CollectSection:AddToggle({
    Name = "Auto Collect Gems",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoCollectGems",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollectGems = Value
    end
})

CollectSection:AddToggle({
    Name = "Auto Collect Rewards",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoCollectRewards",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollectRewards = Value
        if Value then StartLoop("AutoCollectRewards") else StopLoop("AutoCollectRewards") end
    end
})

--==================================================
-- EGG SYSTEM TAB (dari EggSystem.lua)
--==================================================
local EggSection = EggTab:AddSection({
    Name = "Egg Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

EggSection:AddToggle({
    Name = "Auto Buy Egg",
    Default = false,
    Color = Color3.fromRGB(255, 0, 255),
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

EggSection:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Color = Color3.fromRGB(255, 0, 255),
    Outline = true,
    Flag = "AutoHatch",
    Save = true,
    Callback = function(Value)
        Toggles.AutoHatch = Value
        if Value then StartLoop("AutoHatch") else StopLoop("AutoHatch") end
    end
})

EggSection:AddToggle({
    Name = "Auto Open Eggs",
    Default = false,
    Color = Color3.fromRGB(255, 0, 255),
    Outline = true,
    Flag = "AutoOpenEggs",
    Save = true,
    Callback = function(Value)
        Toggles.AutoOpenEggs = Value
        if Value then StartLoop("AutoOpenEggs") else StopLoop("AutoOpenEggs") end
    end
})

EggSection:AddDropdown({
    Name = "Egg Priority",
    Default = "Lowest",
    Options = {"Lowest", "Highest", "Random"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EggPriority = Value
    end
})

EggSection:AddButton({
    Name = "Count Eggs",
    Icon = "search",
    Outline = true,
    Callback = function()
        local eggs = FindEggs()
        Notify("Found " .. #eggs .. " eggs in workspace!")
    end
})

--==================================================
-- UPGRADES TAB (dari OPScript.lua, OPFreeScript.lua)
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
        if Value then StartLoop("AutoUpgrade") else StopLoop("AutoUpgrade") end
    end
})

UpgradeSection:AddDropdown({
    Name = "Upgrade Type",
    Default = "All",
    Options = {"All", "Damage", "Speed", "Multiplier", "Critical", "Luck"},
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.UpgradeType = Value
    end
})

UpgradeSection:AddDropdown({
    Name = "Priority",
    Default = "Damage",
    Options = {"Damage", "Speed", "Multiplier", "Critical"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.UpgradePriority = Value
    end
})

local AreaSection = UpgradeTab:AddSection({
    Name = "Areas & Zones",
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

AreaSection:AddToggle({
    Name = "Auto Unlock Zones",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoUnlockZones",
    Save = true,
    Callback = function(Value)
        Toggles.AutoUnlockZones = Value
        if Value then StartLoop("AutoUnlockZones") else StopLoop("AutoUnlockZones") end
    end
})

--==================================================
-- REBIRTH TAB (dari AutoRebirth.lua)
--==================================================
local RebirthSection = RebirthTab:AddSection({
    Name = "Auto Rebirth",
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

RebirthSection:AddDropdown({
    Name = "Rebirth Mode",
    Default = "Auto",
    Options = {"Auto", "Manual", "Smart"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.RebirthMode = Value
    end
})

RebirthSection:AddSlider({
    Name = "Max Rebirths",
    Min = 1,
    Max = 1000,
    Default = 100,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "times",
    Outline = true,
    Callback = function(Value)
        Toggles.MaxRebirths = Value
    end
})

--==================================================
-- ENCHANT TAB (dari AutoEnchant.lua, BestAutoEnchant.lua)
--==================================================
local EnchantSection = EnchantTab:AddSection({
    Name = "Auto Enchant",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

EnchantSection:AddToggle({
    Name = "Auto Enchant",
    Default = false,
    Color = Color3.fromRGB(150, 0, 255),
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
    Options = {"All", "Weapon", "Armor", "Pet", "Accessory"},
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EnchantType = Value
    end
})

EnchantSection:AddDropdown({
    Name = "Priority",
    Default = "Legendary",
    Options = {"Common", "Rare", "Epic", "Legendary", "Mythic"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EnchantPriority = Value
    end
})

local CraftSection = EnchantTab:AddSection({
    Name = "Auto Craft",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

CraftSection:AddToggle({
    Name = "Auto Craft",
    Default = false,
    Color = Color3.fromRGB(150, 0, 255),
    Outline = true,
    Flag = "AutoCraft",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCraft = Value
        if Value then StartLoop("AutoCraft") else StopLoop("AutoCraft") end
    end
})

CraftSection:AddToggle({
    Name = "Auto Unlock",
    Default = false,
    Color = Color3.fromRGB(150, 0, 255),
    Outline = true,
    Flag = "AutoUnlock",
    Save = true,
    Callback = function(Value)
        Toggles.AutoUnlock = Value
        if Value then StartLoop("AutoUnlock") else StopLoop("AutoUnlock") end
    end
})

--==================================================
-- TELEPORT TAB (dari Teleport.lua, Teleports.lua, TeleportZones.lua)
--==================================================
local TeleportSection = TeleportTab:AddSection({
    Name = "Auto Teleport",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

TeleportSection:AddToggle({
    Name = "Auto Teleport",
    Default = false,
    Color = Color3.fromRGB(0, 255, 255),
    Outline = true,
    Flag = "AutoTeleport",
    Save = true,
    Callback = function(Value)
        Toggles.AutoTeleport = Value
        if Value then StartLoop("AutoTeleport") else StopLoop("AutoTeleport") end
    end
})

TeleportSection:AddDropdown({
    Name = "Teleport To",
    Default = "Next",
    Options = {"Next", "Random", "Highest", "Lowest"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.TeleportToZone = Value
    end
})

TeleportSection:AddSlider({
    Name = "Teleport Speed",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.TeleportSpeed = Value
    end
})

TeleportSection:AddToggle({
    Name = "Zone Hopping",
    Default = false,
    Color = Color3.fromRGB(0, 255, 255),
    Outline = true,
    Flag = "ZoneHopping",
    Save = true,
    Callback = function(Value)
        Toggles.ZoneHopping = Value
        if Value then StartLoop("ZoneHopping") else StopLoop("ZoneHopping") end
    end
})

TeleportSection:AddButton({
    Name = "Find Zones",
    Icon = "map",
    Outline = true,
    Callback = function()
        local zones = FindZones()
        Notify("Found " .. #zones .. " zones!")
    end
})

--==================================================
-- VISUALS TAB (dari SmoothUI.lua)
--==================================================
local ESPSection = VisualsTab:AddSection({
    Name = "ESP",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ESPSection:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Color = Color3.fromRGB(255, 255, 0),
    Outline = true,
    Flag = "ESP",
    Save = true,
    Callback = function(Value)
        Toggles.ESP = Value
        UpdateEggESP()
        UpdateZoneESP()
    end
})

ESPSection:AddDropdown({
    Name = "ESP Type",
    Default = "Players",
    Options = {"Players", "Eggs", "Zones", "All"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.ESPType = Value
    end
})

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
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end
})

LightingSection:AddToggle({
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

LightingSection:AddToggle({
    Name = "No Grass",
    Default = false,
    Color = Color3.fromRGB(255, 255, 0),
    Outline = true,
    Flag = "NoGrass",
    Save = true,
    Callback = function(Value)
        Toggles.NoGrass = Value
        -- Implementation depends on game
    end
})

--==================================================
-- MISC TAB (dari semua script)
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
        end
    end
})

MiscSection:AddToggle({
    Name = "Auto Claim Daily",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoClaimDaily",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClaimDaily = Value
        if Value then StartLoop("AutoClaimDaily") else StopLoop("AutoClaimDaily") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Quest",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoQuest",
    Save = true,
    Callback = function(Value)
        Toggles.AutoQuest = Value
        if Value then StartLoop("AutoQuest") else StopLoop("AutoQuest") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Spin",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoSpin",
    Save = true,
    Callback = function(Value)
        Toggles.AutoSpin = Value
        if Value then StartLoop("AutoSpin") else StopLoop("AutoSpin") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Merge",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoMerge",
    Save = true,
    Callback = function(Value)
        Toggles.AutoMerge = Value
        if Value then StartLoop("AutoMerge") else StopLoop("AutoMerge") end
    end
})

MiscSection:AddToggle({
    Name = "Auto Save",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoSave",
    Save = true,
    Callback = function(Value)
        Toggles.AutoSave = Value
        if Value then StartLoop("AutoSave") else StopLoop("AutoSave") end
    end
})

local ServerSection = MiscTab:AddSection({
    Name = "Server",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ServerSection:AddButton({
    Name = "Server Hop",
    Icon = "globe",
    Outline = true,
    Callback = function()
        ServerHop()
    end
})

ServerSection:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

local function GetServerPlayers()
    local count = 0
    for _, v in pairs(Players:GetPlayers()) do
        count = count + 1
    end
    return count .. "/" .. game.Players.MaxPlayers
end

ServerSection:AddParagraph({
    Title = "Server Info",
    Desc = "Players: " .. GetServerPlayers() .. "\nPing: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms",
    Image = "server",
    ImageSize = 38
})

local GUISection = MiscTab:AddSection({
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

Notify("Tap Simulator Ultimate Collection Loaded!\nAll features from 20+ scripts combined!", 5)

print("=== TAP SIMULATOR - ULTIMATE COLLECTION ===")
print("Version: 3.0")
print("Features from:")
print("- AutoTap.lua, AutoTapKeyless.lua")
print("- AutoFarm&Rebirth.lua, AutoFarm&Hatch.lua")
print("- EggSystem.lua, AutoRebirth.lua")
print("- OPScript.lua, OPFreeScript.lua, OPCraftingScript.lua")
print("- AutoEnchant.lua, BestAutoEnchant.lua")
print("- Teleport.lua, Teleports.lua, TeleportZones.lua")
print("- Rewards.lua, QuickProgress.lua")
print("- AutoUnlock.lua, AutomationScript.lua")
print("- Automations.lua, FullProgressAutomation.lua")
print("- BalancedAutoFarmScript.lua")
print("=== ALL FEATURES COMBINED ===")