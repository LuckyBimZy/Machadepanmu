-- ==================== TAP SIMULATOR - PREMIUM EDITION ====================
-- Advanced Auto Farm Script dengan Remote Wrapper Professional
-- Author: Enhanced Version
-- Version: 2.0.0

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
-- ADVANCED REMOTE WRAPPER SYSTEM
--==================================================
local Network = {}
local Remotes = {}

do
    -- Optimized Remote Wrapper with caching and error handling
    -- Credit to @amazonek for base wrapper
    
    local Success, Result = pcall(function()
        local GetEventHandler = nil
        local GetFunctionHandler = nil
        local EquipBestFunc = nil
        
        -- Scan GC for network functions (optimized)
        for _, object in next, getgc(true) do
            if type(object) == "function" and islclosure(object) and not isexecutorclosure(object) then
                local source = debug.info(object, "s") or ""
                local functionName = debug.info(object, "n")
                local upvalues = getupvalues(object)
                
                if source:find("Modules.Network") then
                    if functionName == "GetEventHandler" and #upvalues >= 5 and typeof(upvalues[1]) == "table" then
                        GetEventHandler = object
                    elseif functionName == "GetFunctionHandler" and #upvalues >= 5 and typeof(upvalues[1]) == "table" then
                        GetFunctionHandler = object
                    end
                elseif source:find("Inventory.Pets") and functionName == "equipBest" and not getgenv().equipbestFunc then
                    EquipBestFunc = object
                    getgenv().equipbestFunc = object
                end
            end
        end

        if not GetEventHandler or not GetFunctionHandler then
            return nil, "Network functions not found"
        end

        -- Get remote tables
        local EventRemotes = getupvalues(GetEventHandler)[1]
        local FunctionRemotes = getupvalues(GetFunctionHandler)[1]
        
        -- Name remotes for easier access
        for remoteName, remoteInfo in next, EventRemotes do
            if remoteInfo.Remote then
                remoteInfo.Remote.Name = remoteName
            end
        end

        for remoteName, remoteInfo in next, FunctionRemotes do
            if remoteInfo.Remote then
                remoteInfo.Remote.Name = remoteName
            end
        end
        
        -- Get remote folder
        local RemoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild(game.JobId)
        if not RemoteFolder then
            RemoteFolder = Instance.new("Folder")
            RemoteFolder.Name = game.JobId
            RemoteFolder.Parent = game:GetService("ReplicatedStorage")
        end
        
        return {
            EventRemotes = EventRemotes,
            FunctionRemotes = FunctionRemotes,
            RemoteFolder = RemoteFolder,
            EquipBestFunc = EquipBestFunc
        }
    end)
    
    if not Success or not Result then
        warn("Remote Wrapper initialization failed:", Result)
        -- Fallback to basic remote finding
        Network.Fallback = true
    else
        Network.Data = Result
        Network.Fallback = false
    end
end

-- Enhanced Network:FireServer with caching and validation
function Network:FireServer(eventName: string, ...: any)
    local args = {...}
    
    -- Try primary method first
    if not self.Fallback and self.Data and self.Data.RemoteFolder then
        local remote = self.Data.RemoteFolder:FindFirstChild(eventName, true)
        if remote then
            local success, err = pcall(function()
                remote:FireServer(unpack(args))
            end)
            if success then return true end
            warn("Remote fire failed:", err)
        end
    end
    
    -- Fallback: Search in ReplicatedStorage
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild(eventName, true)
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(unpack(args)) end)
        return true
    end
    
    -- Last resort: Search all descendants
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find(eventName:lower()) then
            pcall(function() v:FireServer(unpack(args)) end)
            return true
        end
    end
    
    return false
end

-- Enhanced Network:InvokeServer
function Network:InvokeServer(eventName: string, ...: any)
    local args = {...}
    
    if not self.Fallback and self.Data and self.Data.RemoteFolder then
        local remote = self.Data.RemoteFolder:FindFirstChild(eventName, true)
        if remote and remote:IsA("RemoteFunction") then
            local success, result = pcall(function()
                return remote:InvokeServer(unpack(args))
            end)
            if success then return result end
        end
    end
    
    -- Fallback search
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild(eventName, true)
    if remote and remote:IsA("RemoteFunction") then
        return pcall(function() return remote:InvokeServer(unpack(args)) end)
    end
    
    return nil
end

-- Get remote with caching
function Network:GetRemote(eventName: string)
    -- Check cache
    if Remotes[eventName] then
        return Remotes[eventName]
    end
    
    -- Try primary
    if not self.Fallback and self.Data and self.Data.RemoteFolder then
        local remote = self.Data.RemoteFolder:FindFirstChild(eventName, true)
        if remote then
            Remotes[eventName] = remote
            return remote
        end
    end
    
    -- Search in ReplicatedStorage
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild(eventName, true)
    if remote then
        Remotes[eventName] = remote
        return remote
    end
    
    return nil
end

-- Equip best pet function
function Network:EquipBestPet()
    if self.Data and self.Data.EquipBestFunc then
        pcall(self.Data.EquipBestFunc)
        return true
    end
    return false
end

-- Get all available remotes
function Network:GetAllRemotes()
    local remotes = {}
    
    -- From primary source
    if self.Data and self.Data.EventRemotes then
        for name, _ in pairs(self.Data.EventRemotes) do
            table.insert(remotes, name)
        end
    end
    
    if self.Data and self.Data.FunctionRemotes then
        for name, _ in pairs(self.Data.FunctionRemotes) do
            table.insert(remotes, name)
        end
    end
    
    -- From ReplicatedStorage
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and not table.find(remotes, v.Name) then
            table.insert(remotes, v.Name)
        end
    end
    
    return remotes
end

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
local Lighting = game:GetService("Lighting")

-- Stats tracking
local Stats = {
    TotalTaps = 0,
    EggsHatched = 0,
    CoinsEarned = 0,
    StartTime = os.time(),
    Sessions = {}
}

-- Toggles dengan struktur lebih baik
local Toggles = {
    -- Auto Farm
    AutoTap = {Enabled = false, Speed = 0.01, MultiTap = 1},
    AutoClicker = {Enabled = false, Speed = 0.001},
    
    -- Eggs
    AutoBuyEgg = {Enabled = false, Type = "Basic", Amount = 1},
    AutoHatch = {Enabled = false, Delay = 0.5},
    
    -- Upgrades
    AutoUpgrade = {Enabled = false, Type = "All", Priority = "Damage"},
    AutoBuyArea = {Enabled = false, Area = "Next"},
    
    -- Collection
    AutoCollect = {Enabled = false, Interval = 5},
    AutoRebirth = {Enabled = false, At = 1000, Type = "Auto"},
    AutoClaim = {Enabled = false},
    
    -- Pets
    AutoEquipBest = {Enabled = false, Interval = 10},
    AutoMerge = {Enabled = false},
    
    -- Visuals
    ESP = {Enabled = false, Color = Color3.fromRGB(255, 0, 255)},
    FullBright = {Enabled = false},
    NoFog = {Enabled = false},
    
    -- Misc
    AntiAFK = {Enabled = false},
    AutoReconnect = {Enabled = false},
    FPSBoost = {Enabled = false}
}

-- Loops
local Loops = {}
local Cache = {
    Coins = 0,
    Rebirths = 0,
    LastUpdate = 0,
    Remotes = {}
}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, type)
    OrionLib:MakeNotification({
        Name = "Tap Simulator " .. (type or ""),
        Content = msg,
        Image = type == "Error" and "alert-circle" or "zap",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Tap Simulator",
    Subtext = "Premium Edition v2.0",
    Version = "v2.0.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSim_Premium",
    IntroEnabled = true,
    IntroText = "Tap Simulator Premium",
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

Notify("Script loaded successfully! Remote Wrapper: " .. (Network.Fallback and "Fallback Mode" or "Advanced Mode"))

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({Name = "Main", Icon = "home", Glass = true, Outline = true})
local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "zap", Glass = true, Outline = true})
local EggsTab = Window:MakeTab({Name = "Eggs", Icon = "egg", Glass = true, Outline = true})
local PetsTab = Window:MakeTab({Name = "Pets", Icon = "dog", Glass = true, Outline = true})
local UpgradeTab = Window:MakeTab({Name = "Upgrades", Icon = "trending-up", Glass = true, Outline = true})
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "eye", Glass = true, Outline = true})
local DebugTab = Window:MakeTab({Name = "Debug", Icon = "bug", Glass = true, Outline = true})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "settings", Glass = true, Outline = true})

--==================================================
-- ADVANCED UTILITY FUNCTIONS
--==================================================

-- Format numbers
local function FormatNumber(num)
    if num >= 1e12 then
        return string.format("%.2fT", num / 1e12)
    elseif num >= 1e9 then
        return string.format("%.2fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.2fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.2fK", num / 1e3)
    else
        return tostring(math.floor(num))
    end
end

-- Get coins dengan multiple methods
local function GetCoins()
    -- Try cached value first (update every 2 seconds)
    if os.time() - Cache.LastUpdate < 2 then
        return Cache.Coins
    end
    
    -- Method 1: leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash") or v.Name:lower():find("point")) then
                Cache.Coins = v.Value
                Cache.LastUpdate = os.time()
                return v.Value
            end
        end
    end
    
    -- Method 2: Player values
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
            Cache.Coins = v.Value
            Cache.LastUpdate = os.time()
            return v.Value
        end
    end
    
    -- Method 3: Try to get from remote
    local coinRemote = Network:GetRemote("GetCoins") or Network:GetRemote("GetStats")
    if coinRemote then
        local result = Network:InvokeServer(coinRemote.Name)
        if result and type(result) == "number" then
            Cache.Coins = result
            Cache.LastUpdate = os.time()
            return result
        end
    end
    
    return Cache.Coins
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

-- Enhanced tap function
local function Tap(multiTap)
    multiTap = multiTap or 1
    
    -- Try multiple tap methods
    local methods = {
        function() Network:FireServer("Tap", true, nil, true) end,
        function() Network:FireServer("Click") end,
        function() Network:FireServer("PlayerTap") end,
        function() Network:FireServer("TapEvent") end,
        function() mouse1click() end
    }
    
    for i = 1, multiTap do
        for _, method in ipairs(methods) do
            local success = pcall(method)
            if success then
                Stats.TotalTaps = Stats.TotalTaps + 1
                break
            end
        end
        if multiTap > 1 then task.wait(0.001) end
    end
end

-- Buy egg dengan berbagai tipe
local function BuyEgg(eggType, amount)
    amount = amount or 1
    
    local eggTypes = {
        Basic = {"BuyEgg", "Basic", "PurchaseEgg"},
        Rare = {"BuyRareEgg", "Rare"},
        Epic = {"BuyEpicEgg", "Epic"},
        Legendary = {"BuyLegendaryEgg", "Legendary"},
        Mythic = {"BuyMythicEgg", "Mythic"}
    }
    
    local selected = eggTypes[eggType] or eggTypes.Basic
    
    for i = 1, amount do
        for _, remoteName in ipairs(selected) do
            local success = Network:FireServer(remoteName)
            if success then
                Stats.EggsHatched = Stats.EggsHatched + 1
                break
            end
        end
        if amount > 1 then task.wait(0.1) end
    end
end

-- Hatch egg
local function HatchEgg()
    local methods = {
        function() Network:FireServer("HatchEgg") end,
        function() Network:FireServer("OpenEgg") end,
        function() Network:FireServer("Hatch") end
    }
    
    for _, method in ipairs(methods) do
        local success = pcall(method)
        if success then return true end
    end
    return false
end

-- Upgrade dengan priority
local function Upgrade(upgradeType, priority)
    local upgrades = {
        Damage = {"UpgradeDamage", "DamageUpgrade", "BuyDamage"},
        Speed = {"UpgradeSpeed", "SpeedUpgrade", "BuySpeed"},
        Multiplier = {"UpgradeMultiplier", "MultiUpgrade"},
        Critical = {"UpgradeCritical", "CritUpgrade"},
        All = {"UpgradeAll", "MassUpgrade"}
    }
    
    local selected = upgrades[upgradeType] or upgrades[priority] or upgrades.Damage
    
    for _, remoteName in ipairs(selected) do
        local success = Network:FireServer(remoteName)
        if success then return true end
    end
    return false
end

-- Buy area
local function BuyArea(areaType)
    areaType = areaType or "Next"
    
    local methods = {
        function() Network:FireServer("BuyArea", areaType) end,
        function() Network:FireServer("PurchaseArea") end,
        function() Network:FireServer("UnlockArea") end
    }
    
    for _, method in ipairs(methods) do
        local success = pcall(method)
        if success then return true end
    end
    return false
end

-- Collect rewards
local function Collect()
    local methods = {
        function() Network:FireServer("Collect") end,
        function() Network:FireServer("ClaimReward") end,
        function() Network:FireServer("GetRewards") end
    }
    
    for _, method in ipairs(methods) do
        pcall(method)
    end
end

-- Rebirth
local function Rebirth()
    local methods = {
        function() Network:FireServer("Rebirth") end,
        function() Network:FireServer("Prestige") end,
        function() Network:FireServer("Reset") end
    }
    
    for _, method in ipairs(methods) do
        local success = pcall(method)
        if success then return true end
    end
    return false
end

-- Get pet list
local function GetPets()
    local pets = {}
    
    -- Try to get from inventory
    local inventory = Player:FindFirstChild("Inventory") or Player:FindFirstChild("Pets")
    if inventory then
        for _, v in pairs(inventory:GetChildren()) do
            if v:IsA("Folder") or v:IsA("Configuration") then
                table.insert(pets, v.Name)
            end
        end
    end
    
    return pets
end

-- Merge pets
local function MergePets()
    Network:FireServer("MergePets")
    Network:FireServer("CombinePets")
end

--==================================================
-- LOOP MANAGEMENT
--==================================================

function StartLoop(name, func, interval)
    if Loops[name] then return end
    
    Loops[name] = true
    task.spawn(function()
        while Loops[name] do
            local success, err = pcall(func)
            if not success then
                warn("Loop error [" .. name .. "]:", err)
            end
            task.wait(interval or 0.1)
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

--==================================================
-- MAIN TAB CONTENT
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
                StatsPara:SetDesc(string.format(
                    "Coins: %s\nRebirths: %s\nTaps: %s\nEggs: %s\nSession: %s",
                    FormatNumber(coins),
                    FormatNumber(rebirths),
                    FormatNumber(Stats.TotalTaps),
                    Stats.EggsHatched,
                    os.date("%H:%M:%S", os.time() - Stats.StartTime)
                ))
            end
        }
    }
})

-- Auto-update stats
task.spawn(function()
    while true do
        local coins = GetCoins()
        local rebirths = GetRebirths()
        StatsPara:SetDesc(string.format(
            "Coins: %s\nRebirths: %s\nTaps: %s\nEggs: %s\nSession: %s",
            FormatNumber(coins),
            FormatNumber(rebirths),
            FormatNumber(Stats.TotalTaps),
            Stats.EggsHatched,
            os.date("%H:%M:%S", os.time() - Stats.StartTime)
        ))
        task.wait(2)
    end
end)

local QuickSection = MainTab:AddSection({Name = "Quick Actions", TextSize = 17, Glass = true, Outline = true})

QuickSection:AddButton({
    Name = "Tap 100x",
    Icon = "hand",
    Outline = true,
    Callback = function()
        for i = 1, 100 do
            Tap(5) -- Multi-tap 5x each iteration
            task.wait(0.01)
        end
        Notify("Tapped 500 times!")
    end
})

QuickSection:AddButton({
    Name = "Hatch 10 Eggs",
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
    Name = "Equip Best Pet",
    Icon = "star",
    Outline = true,
    Callback = function()
        Network:EquipBestPet()
        Notify("Best pet equipped!")
    end
})

--==================================================
-- AUTO FARM TAB
--==================================================
local TapSection = FarmTab:AddSection({Name = "Auto Tap", TextSize = 17, Glass = true, Outline = true})

TapSection:AddToggle({
    Name = "Auto Tap",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoTap",
    Save = true,
    Callback = function(Value)
        Toggles.AutoTap.Enabled = Value
        if Value then 
            StartLoop("AutoTap", function()
                Tap(Toggles.AutoTap.MultiTap)
            end, Toggles.AutoTap.Speed)
        else 
            StopLoop("AutoTap")
        end
    end
})

TapSection:AddSlider({
    Name = "Tap Speed (sec)",
    Min = 0.001,
    Max = 0.1,
    Default = 0.01,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.AutoTap.Speed = Value
    end
})

TapSection:AddSlider({
    Name = "Multi-Tap",
    Min = 1,
    Max = 20,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "x",
    Outline = true,
    Callback = function(Value)
        Toggles.AutoTap.MultiTap = Value
    end
})

local CollectSection = FarmTab:AddSection({Name = "Auto Collection", TextSize = 17, Glass = true, Outline = true})

CollectSection:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Color = Color3.fromRGB(0, 255, 100),
    Outline = true,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollect.Enabled = Value
        if Value then 
            StartLoop("AutoCollect", Collect, Toggles.AutoCollect.Interval)
        else 
            StopLoop("AutoCollect")
        end
    end
})

CollectSection:AddSlider({
    Name = "Collect Interval",
    Min = 1,
    Max = 30,
    Default = 5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.AutoCollect.Interval = Value
    end
})

--==================================================
-- EGGS TAB
--==================================================
local EggSection = EggsTab:AddSection({Name = "Egg Settings", TextSize = 17, Glass = true, Outline = true})

EggSection:AddToggle({
    Name = "Auto Buy Egg",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoBuyEgg",
    Save = true,
    Callback = function(Value)
        Toggles.AutoBuyEgg.Enabled = Value
        if Value then 
            StartLoop("AutoBuyEgg", function()
                BuyEgg(Toggles.AutoBuyEgg.Type, Toggles.AutoBuyEgg.Amount)
            end, 1)
        else 
            StopLoop("AutoBuyEgg")
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
        Toggles.AutoBuyEgg.Type = Value
    end
})

EggSection:AddSlider({
    Name = "Buy Amount",
    Min = 1,
    Max = 10,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "eggs",
    Outline = true,
    Callback = function(Value)
        Toggles.AutoBuyEgg.Amount = Value
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
        Toggles.AutoHatch.Enabled = Value
        if Value then 
            StartLoop("AutoHatch", HatchEgg, Toggles.AutoHatch.Delay)
        else 
            StopLoop("AutoHatch")
        end
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
        Toggles.AutoHatch.Delay = Value
    end
})

--==================================================
-- PETS TAB
--==================================================
local PetSection = PetsTab:AddSection({Name = "Pet Management", TextSize = 17, Glass = true, Outline = true})

PetSection:AddToggle({
    Name = "Auto Equip Best",
    Default = false,
    Color = Color3.fromRGB(255, 100, 255),
    Outline = true,
    Flag = "AutoEquipBest",
    Save = true,
    Callback = function(Value)
        Toggles.AutoEquipBest.Enabled = Value
        if Value then 
            StartLoop("AutoEquipBest", Network.EquipBestPet, Toggles.AutoEquipBest.Interval)
        else 
            StopLoop("AutoEquipBest")
        end
    end
})

PetSection:AddSlider({
    Name = "Equip Interval",
    Min = 5,
    Max = 60,
    Default = 10,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.AutoEquipBest.Interval = Value
    end
})

PetSection:AddToggle({
    Name = "Auto Merge",
    Default = false,
    Color = Color3.fromRGB(255, 100, 255),
    Outline = true,
    Flag = "AutoMerge",
    Save = true,
    Callback = function(Value)
        Toggles.AutoMerge.Enabled = Value
        if Value then 
            StartLoop("AutoMerge", MergePets, 30)
        else 
            StopLoop("AutoMerge")
        end
    end
})

PetSection:AddButton({
    Name = "Show Pets",
    Icon = "list",
    Outline = true,
    Callback = function()
        local pets = GetPets()
        local msg = "Pets: " .. (#pets > 0 and table.concat(pets, ", ") or "None")
        Notify(msg)
    end
})

--==================================================
-- UPGRADES TAB
--==================================================
local UpgradeSection = UpgradeTab:AddSection({Name = "Auto Upgrade", TextSize = 17, Glass = true, Outline = true})

UpgradeSection:AddToggle({
    Name = "Auto Upgrade",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoUpgrade",
    Save = true,
    Callback = function(Value)
        Toggles.AutoUpgrade.Enabled = Value
        if Value then 
            StartLoop("AutoUpgrade", function()
                Upgrade(Toggles.AutoUpgrade.Type, Toggles.AutoUpgrade.Priority)
            end, 1)
        else 
            StopLoop("AutoUpgrade")
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
        Toggles.AutoUpgrade.Type = Value
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
        Toggles.AutoUpgrade.Priority = Value
    end
})

local AreaSection = UpgradeTab:AddSection({Name = "Area", TextSize = 17, Glass = true, Outline = true})

AreaSection:AddToggle({
    Name = "Auto Buy Area",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoBuyArea",
    Save = true,
    Callback = function(Value)
        Toggles.AutoBuyArea.Enabled = Value
        if Value then 
            StartLoop("AutoBuyArea", function()
                BuyArea(Toggles.AutoBuyArea.Area)
            end, 2)
        else 
            StopLoop("AutoBuyArea")
        end
    end
})

AreaSection:AddDropdown({
    Name = "Area Type",
    Default = "Next",
    Options = {"Next", "Cheapest", "Best"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.AutoBuyArea.Area = Value
    end
})

local RebirthSection = UpgradeTab:AddSection({Name = "Rebirth", TextSize = 17, Glass = true, Outline = true})

RebirthSection:AddToggle({
    Name = "Auto Rebirth",
    Default = false,
    Color = Color3.fromRGB(255, 50, 50),
    Outline = true,
    Flag = "AutoRebirth",
    Save = true,
    Callback = function(Value)
        Toggles.AutoRebirth.Enabled = Value
        if Value then 
            StartLoop("AutoRebirth", function()
                local coins = GetCoins()
                if coins >= Toggles.AutoRebirth.At then
                    Rebirth()
                end
            end, 3)
        else 
            StopLoop("AutoRebirth")
        end
    end
})

RebirthSection:AddSlider({
    Name = "Rebirth At",
    Min = 100,
    Max = 10000000,
    Default = 1000,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 100,
    ValueName = FormatNumber(GetCoins()),
    Outline = true,
    Callback = function(Value)
        Toggles.AutoRebirth.At = Value
    end
})

--==================================================
-- DEBUG TAB
--==================================================
local RemoteSection = DebugTab:AddSection({Name = "Remote Explorer", TextSize = 17, Glass = true, Outline = true})

RemoteSection:AddButton({
    Name = "Scan Remotes",
    Icon = "search",
    Outline = true,
    Callback = function()
        local remotes = Network:GetAllRemotes()
        local msg = "Found " .. #remotes .. " remotes"
        Notify(msg)
        
        -- Create dropdown with remotes
        local remoteDropdown = RemoteSection:AddDropdown({
            Name = "Remote List",
            Default = remotes[1] or "None",
            Options = #remotes > 0 and remotes or {"None"},
            Multi = false,
            Search = true,
            Outline = true,
            Callback = function(Value)
                Cache.SelectedRemote = Value
            end
        })
    end
})

RemoteSection:AddTextbox({
    Name = "Remote Name",
    Default = "",
    TextDisappear = true,
    Outline = true,
    Callback = function(Value)
        Cache.CustomRemote = Value
    end
})

RemoteSection:AddButton({
    Name = "Fire Remote",
    Icon = "zap",
    Outline = true,
    Callback = function()
        local remoteName = Cache.SelectedRemote or Cache.CustomRemote
        if remoteName then
            Network:FireServer(remoteName)
            Notify("Fired: " .. remoteName)
        end
    end
})

local NetworkSection = DebugTab:AddSection({Name = "Network Status", TextSize = 17, Glass = true, Outline = true})

NetworkSection:AddParagraph({
    Title = "Wrapper Status",
    Desc = "Mode: " .. (Network.Fallback and "Fallback ⚠️" or "Advanced ✅") .. "\nPing: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms",
    Image = "activity",
    ImageSize = 38
})

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({Name = "Miscellaneous", TextSize = 17, Glass = true, Outline = true})

MiscSection:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Toggles.AntiAFK.Enabled = Value
        if Value then
            local connection
            connection = RunService.Stepped:Connect(function()
                if Toggles.AntiAFK.Enabled then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                else
                    connection:Disconnect()
                end
            end)
        end
    end
})

MiscSection:AddToggle({
    Name = "Auto Reconnect",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AutoReconnect",
    Save = true,
    Callback = function(Value)
        Toggles.AutoReconnect.Enabled = Value
    end
})

MiscSection:AddToggle({
    Name = "FPS Boost",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "FPSBoost",
    Save = true,
    Callback = function(Value)
        Toggles.FPSBoost.Enabled = Value
        if Value then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
            settings().Rendering.QualityLevel = 1
        else
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = 21
        end
    end
})

local ServerSection = MiscTab:AddSection({Name = "Server", TextSize = 17, Glass = true, Outline = true})

ServerSection:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

ServerSection:AddButton({
    Name = "Server Hop",
    Icon = "globe",
    Outline = true,
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
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
            Notify("No servers available!", "Error")
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

-- Auto reconnect handler
if Toggles.AutoReconnect.Enabled then
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child.Name == "RobloxPromptGui" then
            task.wait(5)
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end
    end)
end

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

Notify("Premium script loaded! Remote System: " .. (Network.Fallback and "Basic Mode" or "Advanced Mode"))
print("=== Tap Simulator Premium v2.0 ===")
print("✅ Remote Wrapper: " .. (Network.Fallback and "Fallback" or "Advanced"))
print("✅ Features: Auto Farm, Eggs, Pets, Upgrades")
print("✅ Press F4 to toggle menu")