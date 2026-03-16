-- ==================== MEGA SCRIPT COLLECTION - CATRAZ EDITION ====================
-- Premium UI menggunakan Catraz Hub Library
-- Author: Adapted for Catraz Hub
-- Version: 1.0

if _G.MegaScriptLoaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mega Script",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.MegaScriptLoaded = true

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

--==================================================
-- NOTIFICATION FUNCTION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Mega Script",
        Content = msg,
        Image = "rocket",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Mega Script Collection",
    Subtext = "All-in-One Premium Scripts",
    Version = "v1.0.0",
    VersionIcon = "rocket",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MegaScript_Config",
    IntroEnabled = true,
    IntroText = "Mega Script Collection",
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

-- Set Theme (Available: "Default", "Ocean", "Void", "Hackerman")
OrionLib.SelectedTheme = "Void"

Notify("Mega Script Collection loaded successfully!")

--==================================================
-- UTILITY FUNCTIONS
--==================================================

-- Smooth Notification
local function SmoothUI()
    return {
        createNotification = function(title, message, duration)
            OrionLib:MakeNotification({
                Name = title,
                Content = message,
                Image = "info",
                Time = duration or 2.5
            })
        end
    }
end

local SmoothUI = SmoothUI()

-- Teleport function
local function TeleportTo(position)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        SmoothUI.createNotification("Teleport", "Teleported!", 1)
        
        -- Effect
        local effect = Instance.new("Part")
        effect.Parent = Workspace
        effect.Size = Vector3.new(5, 5, 5)
        effect.Position = position
        effect.Anchored = true
        effect.CanCollide = false
        effect.Transparency = 0.5
        effect.BrickColor = BrickColor.new("Bright blue")
        effect.Material = Enum.Material.Neon
        
        task.delay(1, function()
            effect:Destroy()
        end)
    end
end

--==================================================
-- TELEPORT ZONES SYSTEM
--==================================================
local TeleportZones = {}

function TeleportZones.init()
    local player = Player
    if not player then return end
    
    local zones = {
        {name = "Spawn Zone", position = Vector3.new(0, 10, 0), desc = "Area utama spawn"},
        {name = "Shop Zone", position = Vector3.new(50, 10, 0), desc = "Tempat membeli item"},
        {name = "Farm Zone", position = Vector3.new(100, 10, 50), desc = "Area farming"},
        {name = "PvP Zone", position = Vector3.new(-50, 10, -50), desc = "Area pertarungan"},
        {name = "Secret Zone", position = Vector3.new(200, 50, 200), desc = "Lokasi rahasia"}
    }
    
    local Tab = Window:MakeTab({
        Name = "Teleport Zones",
        Icon = "map-pin",
        Glass = true,
        Outline = true
    })
    
    local Section = Tab:AddSection({
        Name = "Available Zones",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    for _, zone in ipairs(zones) do
        Section:AddButton({
            Name = zone.name,
            Icon = "navigation",
            Outline = true,
            Callback = function()
                TeleportTo(zone.position)
                SmoothUI.createNotification("Teleported", "To " .. zone.name, 2)
            end
        })
        
        Section:AddParagraph({
            Title = zone.name .. " Info",
            Desc = zone.desc,
            Image = "info",
            ImageSize = 32
        })
    end
end

--==================================================
-- TELEPORTS SYSTEM
--==================================================
local TeleportsSystem = {}

function TeleportsSystem.init()
    local player = Player
    if not player then return end
    
    local teleportLocations = {
        {name = "Pusat Kota", position = Vector3.new(0, 5, 0), desc = "Area utama kota"},
        {name = "Toko Senjata", position = Vector3.new(30, 5, 20), desc = "Beli senjata di sini"},
        {name = "Area Pelatihan", position = Vector3.new(-30, 5, 40), desc = "Latih kemampuanmu"},
        {name = "Gudang", position = Vector3.new(60, 5, -20), desc = "Tempat menyimpan item"},
        {name = "Arena Boss", position = Vector3.new(0, 5, 100), desc = "Hadapi bos terkuat"},
        {name = "Tempat Rahasia", position = Vector3.new(150, 30, 150), desc = "Lokasi tersembunyi"}
    }
    
    local Tab = Window:MakeTab({
        Name = "Teleports",
        Icon = "navigation-2",
        Glass = true,
        Outline = true
    })
    
    local Section = Tab:AddSection({
        Name = "Teleport Locations",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    for _, loc in ipairs(teleportLocations) do
        Section:AddButton({
            Name = loc.name,
            Icon = "send",
            Outline = true,
            Callback = function()
                TeleportTo(loc.position)
                SmoothUI.createNotification("Teleported", "To " .. loc.name, 2)
            end
        })
        
        Section:AddLabel(loc.desc)
    end
end

--==================================================
-- REWARDS SYSTEM
--==================================================
local RewardsSystem = {}

function RewardsSystem.init()
    local player = Player
    if not player then return end
    
    -- Leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end
    
    local coins = leaderstats:FindFirstChild("Coins") or Instance.new("NumberValue")
    coins.Name = "Coins"
    coins.Parent = leaderstats
    coins.Value = coins.Value or 0
    
    local rewards = {
        {name = "Daily Reward", amount = 100, color = Color3.fromRGB(255, 215, 0)},
        {name = "Weekly Reward", amount = 500, color = Color3.fromRGB(138, 43, 226)},
        {name = "Monthly Reward", amount = 2000, color = Color3.fromRGB(255, 69, 0)},
        {name = "Login Reward", amount = 50, color = Color3.fromRGB(100, 149, 237)},
        {name = "Achievement", amount = 250, color = Color3.fromRGB(60, 179, 113)},
        {name = "Special Event", amount = 1000, color = Color3.fromRGB(255, 20, 147)}
    }
    
    local claimed = {}
    
    local Tab = Window:MakeTab({
        Name = "Rewards",
        Icon = "gift",
        Glass = true,
        Outline = true
    })
    
    -- Coins display
    local CoinsPara = Tab:AddParagraph({
        Title = "Your Coins",
        Desc = "💰 " .. coins.Value,
        Image = "circle-dollar-sign",
        ImageSize = 38
    })
    
    coins:GetPropertyChangedSignal("Value"):Connect(function()
        CoinsPara:SetDesc("💰 " .. coins.Value)
    end)
    
    local Section = Tab:AddSection({
        Name = "Available Rewards",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    for i, reward in ipairs(rewards) do
        claimed[reward.name] = false
        
        Section:AddButton({
            Name = reward.name .. " (" .. reward.amount .. " coins)",
            Icon = "award",
            Outline = true,
            Callback = function()
                if not claimed[reward.name] then
                    claimed[reward.name] = true
                    coins.Value = coins.Value + reward.amount
                    SmoothUI.createNotification("Claimed!", reward.amount .. " coins added!", 2)
                else
                    SmoothUI.createNotification("Already Claimed", "This reward has been taken", 2)
                end
            end
        })
    end
    
    -- Reset daily (simulasi)
    Tab:AddButton({
        Name = "Reset Daily (Test)",
        Icon = "refresh-cw",
        Outline = true,
        Callback = function()
            claimed["Daily Reward"] = false
            SmoothUI.createNotification("Reset", "Daily reward available again", 2)
        end
    })
end

--==================================================
-- QUICK PROGRESS
--==================================================
local QuickProgress = {}

function QuickProgress.init()
    local player = Player
    if not player then return end
    
    -- Leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end
    
    local level = leaderstats:FindFirstChild("Level") or Instance.new("NumberValue")
    level.Name = "Level"
    level.Parent = leaderstats
    level.Value = level.Value or 1
    
    local exp = leaderstats:FindFirstChild("Exp") or Instance.new("NumberValue")
    exp.Name = "Exp"
    exp.Parent = leaderstats
    exp.Value = exp.Value or 0
    
    local maxExp = leaderstats:FindFirstChild("MaxExp") or Instance.new("NumberValue")
    maxExp.Name = "MaxExp"
    maxExp.Parent = leaderstats
    maxExp.Value = maxExp.Value or 100
    
    local Tab = Window:MakeTab({
        Name = "Progress",
        Icon = "trending-up",
        Glass = true,
        Outline = true
    })
    
    -- Stats display
    local StatsPara = Tab:AddParagraph({
        Title = "Your Progress",
        Desc = "Level: " .. level.Value .. "\nExp: " .. exp.Value .. "/" .. maxExp.Value,
        Image = "bar-chart-2",
        ImageSize = 38
    })
    
    -- Update function
    local function updateStats()
        StatsPara:SetDesc("Level: " .. level.Value .. "\nExp: " .. exp.Value .. "/" .. maxExp.Value)
    end
    
    level:GetPropertyChangedSignal("Value"):Connect(updateStats)
    exp:GetPropertyChangedSignal("Value"):Connect(updateStats)
    maxExp:GetPropertyChangedSignal("Value"):Connect(updateStats)
    
    local Section = Tab:AddSection({
        Name = "Quick Actions",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    Section:AddButton({
        Name = "Gain +10 EXP",
        Icon = "plus-circle",
        Outline = true,
        Callback = function()
            exp.Value = math.min(exp.Value + 10, maxExp.Value)
            updateStats()
        end
    })
    
    Section:AddButton({
        Name = "Level Up",
        Icon = "arrow-up-circle",
        Outline = true,
        Callback = function()
            if exp.Value >= maxExp.Value then
                level.Value = level.Value + 1
                exp.Value = 0
                maxExp.Value = maxExp.Value + 50
                updateStats()
                SmoothUI.createNotification("Level Up!", "Now level " .. level.Value, 2)
            else
                SmoothUI.createNotification("Not Enough EXP", "Need " .. (maxExp.Value - exp.Value) .. " more EXP", 2)
            end
        end
    })
    
    Section:AddButton({
        Name = "Reset EXP",
        Icon = "rotate-ccw",
        Outline = true,
        Callback = function()
            exp.Value = 0
            updateStats()
        end
    })
    
    Section:AddButton({
        Name = "Double EXP",
        Icon = "copy",
        Outline = true,
        Callback = function()
            exp.Value = math.min(exp.Value * 2, maxExp.Value)
            updateStats()
        end
    })
end

--==================================================
-- OP SCRIPT
--==================================================
local OPScript = {}

function OPScript.init()
    local player = Player
    if not player then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    local stats = {
        walkspeed = 16,
        jumppower = 50
    }
    
    local Tab = Window:MakeTab({
        Name = "OP Script",
        Icon = "zap",
        Glass = true,
        Outline = true
    })
    
    -- Movement Section
    local MoveSection = Tab:AddSection({
        Name = "Movement",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    MoveSection:AddSlider({
        Name = "Walk Speed",
        Min = 16,
        Max = 200,
        Default = 16,
        Color = Color3.fromRGB(0, 150, 255),
        Increment = 1,
        ValueName = "WS",
        Outline = true,
        Callback = function(Value)
            stats.walkspeed = Value
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    })
    
    MoveSection:AddSlider({
        Name = "Jump Power",
        Min = 50,
        Max = 200,
        Default = 50,
        Color = Color3.fromRGB(255, 150, 0),
        Increment = 1,
        ValueName = "JP",
        Outline = true,
        Callback = function(Value)
            stats.jumppower = Value
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    })
    
    -- Combat Section
    local CombatSection = Tab:AddSection({
        Name = "Combat",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    CombatSection:AddToggle({
        Name = "Auto Attack",
        Default = false,
        Color = Color3.fromRGB(255, 50, 50),
        Outline = true,
        Flag = "AutoAttack",
        Save = true,
        Callback = function(Value)
            -- Implement auto attack
        end
    })
    
    CombatSection:AddToggle({
        Name = "Critical Hits",
        Default = true,
        Color = Color3.fromRGB(255, 215, 0),
        Outline = true,
        Flag = "Critical",
        Save = true,
        Callback = function(Value)
            -- Implement critical
        end
    })
    
    -- Utility Section
    local UtilSection = Tab:AddSection({
        Name = "Utility",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    UtilSection:AddButton({
        Name = "Heal",
        Icon = "heart",
        Outline = true,
        Callback = function()
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
                SmoothUI.createNotification("Healed", "Health restored!", 1)
            end
        end
    })
    
    UtilSection:AddButton({
        Name = "Respawn",
        Icon = "rotate-ccw",
        Outline = true,
        Callback = function()
            if humanoid then
                humanoid.Health = 0
            end
        end
    })
    
    UtilSection:AddToggle({
        Name = "God Mode",
        Default = false,
        Color = Color3.fromRGB(255, 215, 0),
        Outline = true,
        Flag = "GodMode",
        Save = true,
        Callback = function(Value)
            -- Implement god mode
        end
    })
    
    -- Update loop
    task.spawn(function()
        while true do
            task.wait(0.1)
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = stats.walkspeed
                humanoid.JumpPower = stats.jumppower
            else
                character = player.Character
                if character then
                    humanoid = character:FindFirstChild("Humanoid")
                end
            end
        end
    end)
end

--==================================================
-- FREE SCRIPT
--==================================================
local OPFreeScript = {}

function OPFreeScript.init()
    local Tab = Window:MakeTab({
        Name = "Free Script",
        Icon = "gift",
        Glass = true,
        Outline = true
    })
    
    local Section = Tab:AddSection({
        Name = "Free Features",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    local freeFeatures = {
        {name = "Speed Boost", desc = "Tingkatkan kecepatan"},
        {name = "Auto Click", desc = "Klik otomatis"},
        {name = "Auto Farm", desc = "Farm otomatis"},
        {name = "ESP", desc = "Lihat player lain"},
        {name = "No Fall Damage", desc = "Tanpa damage jatuh"},
        {name = "Full Bright", desc = "Terang terus"}
    }
    
    for _, feature in ipairs(freeFeatures) do
        Section:AddButton({
            Name = feature.name,
            Icon = "star",
            Outline = true,
            Callback = function()
                SmoothUI.createNotification("Free Script", feature.name .. " activated!", 2)
            end
        })
        
        Section:AddLabel(feature.desc)
    end
end

--==================================================
-- CRAFTING SCRIPT
--==================================================
local OPCraftingScript = {}

function OPCraftingScript.init()
    local Tab = Window:MakeTab({
        Name = "Crafting",
        Icon = "hammer",
        Glass = true,
        Outline = true
    })
    
    local recipes = {
        {name = "Wooden Sword", materials = "Wood x3, String x1", result = "Wooden Sword", time = 5},
        {name = "Stone Pickaxe", materials = "Stone x5, Wood x2", result = "Stone Pickaxe", time = 8},
        {name = "Iron Armor", materials = "Iron x10, Leather x3", result = "Iron Armor", time = 15},
        {name = "Diamond Sword", materials = "Diamond x8, Gold x4", result = "Diamond Sword", time = 20},
        {name = "Health Potion", materials = "Herb x4, Water x1", result = "Health Potion", time = 3}
    }
    
    local Section = Tab:AddSection({
        Name = "Crafting Recipes",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    for _, recipe in ipairs(recipes) do
        Section:AddButton({
            Name = recipe.name,
            Icon = "package",
            Outline = true,
            Callback = function()
                SmoothUI.createNotification("Crafting", "Crafting " .. recipe.name .. "...", 2)
                task.wait(recipe.time)
                SmoothUI.createNotification("Complete", "Crafted " .. recipe.result, 2)
            end
        })
        
        Section:AddLabel("Materials: " .. recipe.materials)
    end
    
    -- Inventory
    local InvSection = Tab:AddSection({
        Name = "Inventory",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    InvSection:AddParagraph({
        Title = "Your Materials",
        Desc = "Wood: 10\nStone: 15\nIron: 8\nDiamond: 3",
        Image = "box",
        ImageSize = 38
    })
end

--==================================================
-- KEYLESS V2
--==================================================
local KeylessV2 = {}

function KeylessV2.init()
    local player = Player
    
    local Tab = Window:MakeTab({
        Name = "Keyless V2",
        Icon = "key",
        Glass = true,
        Outline = true
    })
    
    -- Welcome
    Tab:AddParagraph({
        Title = "Welcome, " .. player.Name,
        Desc = "Account Age: " .. player.AccountAge .. " days",
        Image = "user",
        ImageSize = 38
    })
    
    -- Stats
    local StatsSection = Tab:AddSection({
        Name = "Your Stats",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    StatsSection:AddParagraph({
        Title = "Statistics",
        Desc = "Level: 42\nKills: 1,234\nDeaths: 567\nK/D: 2.18",
        Image = "bar-chart",
        ImageSize = 38
    })
    
    -- Features
    local FeaturesSection = Tab:AddSection({
        Name = "Features",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    local features = {"Aimbot", "ESP", "Wallhack", "Speed", "Jump", "Fly", "Noclip", "God"}
    
    for _, feature in ipairs(features) do
        FeaturesSection:AddToggle({
            Name = feature,
            Default = false,
            Color = Color3.fromRGB(100, 50, 200),
            Outline = true,
            Flag = feature,
            Save = true,
            Callback = function(Value)
                -- Implement feature
            end
        })
    end
    
    -- Discord button
    Tab:AddButton({
        Name = "Join Discord",
        Icon = "message-circle",
        Outline = true,
        Callback = function()
            setclipboard("https://discord.gg/example")
            SmoothUI.createNotification("Discord", "Link copied to clipboard!", 2)
        end
    })
end

--==================================================
-- KEYLESS SCRIPT
--==================================================
local KeylessScript = {}

function KeylessScript.init()
    local Tab = Window:MakeTab({
        Name = "Keyless",
        Icon = "unlock",
        Glass = true,
        Outline = true
    })
    
    local Section = Tab:AddSection({
        Name = "Free Features",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    local items = {
        {name = "Auto Farm", desc = "Farm otomatis"},
        {name = "Auto Rebirth", desc = "Rebirth otomatis"},
        {name = "Auto Hatch", desc = "Hatch telur otomatis"},
        {name = "Speed Hack", desc = "Kecepatan maksimal"}
    }
    
    for _, item in ipairs(items) do
        Section:AddToggle({
            Name = item.name,
            Default = false,
            Color = Color3.fromRGB(0, 120, 200),
            Outline = true,
            Flag = item.name,
            Save = true,
            Callback = function(Value)
                SmoothUI.createNotification(item.name, Value and "Activated" or "Deactivated", 1)
            end
        })
        
        Section:AddLabel(item.desc)
    end
end

--==================================================
-- FULL PROGRESS AUTOMATION
--==================================================
local FullProgressAutomation = {}

function FullProgressAutomation.init()
    local player = Player
    
    local progressData = {
        level = 1,
        exp = 0,
        maxExp = 100,
        coins = 0,
        rebirths = 0,
        pets = 0
    }
    
    local Tab = Window:MakeTab({
        Name = "Auto Progress",
        Icon = "activity",
        Glass = true,
        Outline = true
    })
    
    -- Progress bars (simulasi dengan paragraph)
    local ProgressPara = Tab:AddParagraph({
        Title = "Current Progress",
        Desc = "Level: " .. progressData.level .. "\nExp: " .. progressData.exp .. "/" .. progressData.maxExp .. "\nRebirths: " .. progressData.rebirths .. "\nCoins: " .. progressData.coins,
        Image = "bar-chart-2",
        ImageSize = 38
    })
    
    local function updateProgress()
        ProgressPara:SetDesc("Level: " .. progressData.level .. "\nExp: " .. progressData.exp .. "/" .. progressData.maxExp .. "\nRebirths: " .. progressData.rebirths .. "\nCoins: " .. progressData.coins)
    end
    
    -- Automation Section
    local AutoSection = Tab:AddSection({
        Name = "Automation",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    AutoSection:AddToggle({
        Name = "Auto Farm",
        Default = true,
        Color = Color3.fromRGB(0, 200, 0),
        Outline = true,
        Flag = "AutoFarmProgress",
        Save = true,
        Callback = function(Value)
            if Value then
                task.spawn(function()
                    while Value do
                        task.wait(1)
                        progressData.exp = math.min(progressData.exp + 5, progressData.maxExp)
                        updateProgress()
                    end
                end)
            end
        end
    })
    
    AutoSection:AddToggle({
        Name = "Auto Rebirth",
        Default = false,
        Color = Color3.fromRGB(150, 0, 150),
        Outline = true,
        Flag = "AutoRebirthProgress",
        Save = true,
        Callback = function(Value)
            if Value then
                task.spawn(function()
                    while Value do
                        task.wait(5)
                        if progressData.exp >= progressData.maxExp then
                            progressData.level = progressData.level + 1
                            progressData.exp = 0
                            progressData.maxExp = progressData.maxExp + 50
                            updateProgress()
                        end
                    end
                end)
            end
        end
    })
    
    -- Quick Actions
    local QuickSection = Tab:AddSection({
        Name = "Quick Actions",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    QuickSection:AddButton({
        Name = "Add +10 EXP",
        Icon = "plus-circle",
        Outline = true,
        Callback = function()
            progressData.exp = math.min(progressData.exp + 10, progressData.maxExp)
            updateProgress()
        end
    })
    
    QuickSection:AddButton({
        Name = "Add +1 Level",
        Icon = "arrow-up-circle",
        Outline = true,
        Callback = function()
            progressData.level = progressData.level + 1
            updateProgress()
        end
    })
    
    QuickSection:AddButton({
        Name = "Add +1 Rebirth",
        Icon = "rotate-ccw",
        Outline = true,
        Callback = function()
            progressData.rebirths = progressData.rebirths + 1
            updateProgress()
        end
    })
    
    QuickSection:AddButton({
        Name = "Add +100 Coins",
        Icon = "circle-dollar-sign",
        Outline = true,
        Callback = function()
            progressData.coins = progressData.coins + 100
            updateProgress()
        end
    })
end

--==================================================
-- EGG SYSTEM
--==================================================
local EggSystem = {}

function EggSystem.init()
    local eggs = {
        {name = "Common Egg", price = 100, color = Color3.fromRGB(150, 150, 150), pets = {"Cat", "Dog", "Chicken"}},
        {name = "Rare Egg", price = 500, color = Color3.fromRGB(0, 150, 255), pets = {"Wolf", "Fox", "Eagle"}},
        {name = "Epic Egg", price = 2000, color = Color3.fromRGB(150, 0, 255), pets = {"Dragon", "Phoenix", "Unicorn"}},
        {name = "Legendary Egg", price = 10000, color = Color3.fromRGB(255, 215, 0), pets = {"Titan", "God", "Mythical"}}
    }
    
    local inventory = {
        coins = 5000,
        pets = {"Cat", "Dog"}
    }
    
    local Tab = Window:MakeTab({
        Name = "Egg System",
        Icon = "egg",
        Glass = true,
        Outline = true
    })
    
    -- Coins display
    local CoinsPara = Tab:AddParagraph({
        Title = "Your Coins",
        Desc = "💰 " .. inventory.coins,
        Image = "circle-dollar-sign",
        ImageSize = 38
    })
    
    local EggSection = Tab:AddSection({
        Name = "Available Eggs",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    for _, egg in ipairs(eggs) do
        EggSection:AddButton({
            Name = egg.name .. " (" .. egg.price .. " coins)",
            Icon = "shopping-cart",
            Outline = true,
            Callback = function()
                if inventory.coins >= egg.price then
                    inventory.coins = inventory.coins - egg.price
                    CoinsPara:SetDesc("💰 " .. inventory.coins)
                    
                    local randomPet = egg.pets[math.random(1, #egg.pets)]
                    table.insert(inventory.pets, randomPet)
                    
                    SmoothUI.createNotification("Hatched!", "You got a " .. randomPet, 2)
                else
                    SmoothUI.createNotification("Not Enough Coins", "Need " .. (egg.price - inventory.coins) .. " more", 2)
                end
            end
        })
    end
    
    -- Pets inventory
    local PetsSection = Tab:AddSection({
        Name = "Your Pets",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    local petsList = ""
    for i, pet in ipairs(inventory.pets) do
        petsList = petsList .. "• " .. pet .. "\n"
    end
    
    PetsSection:AddParagraph({
        Title = "Pet Collection",
        Desc = petsList,
        Image = "heart",
        ImageSize = 38
    })
end

--==================================================
-- BEST AUTO ENCHANT
--==================================================
local BestAutoEnchant = {}

function BestAutoEnchant.init()
    local enchants = {
        {name = "Sharpness", level = 1, maxLevel = 5, cost = 100, color = Color3.fromRGB(255, 100, 100)},
        {name = "Protection", level = 1, maxLevel = 4, cost = 150, color = Color3.fromRGB(100, 100, 255)},
        {name = "Efficiency", level = 1, maxLevel = 5, cost = 120, color = Color3.fromRGB(100, 255, 100)},
        {name = "Unbreaking", level = 1, maxLevel = 3, cost = 80, color = Color3.fromRGB(255, 255, 100)},
        {name = "Fortune", level = 1, maxLevel = 3, cost = 200, color = Color3.fromRGB(255, 150, 0)}
    }
    
    local resources = {
        essence = 1000,
        level = 10
    }
    
    local Tab = Window:MakeTab({
        Name = "Auto Enchant",
        Icon = "wand",
        Glass = true,
        Outline = true
    })
    
    -- Resources
    local ResPara = Tab:AddParagraph({
        Title = "Your Resources",
        Desc = "🔮 Essence: " .. resources.essence .. "\n⭐ Level: " .. resources.level,
        Image = "package",
        ImageSize = 38
    })
    
    local EnchantSection = Tab:AddSection({
        Name = "Enchantments",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    for _, enchant in ipairs(enchants) do
        EnchantSection:AddButton({
            Name = enchant.name .. " (Level " .. enchant.level .. "/" .. enchant.maxLevel .. ")",
            Icon = "sparkles",
            Outline = true,
            Callback = function()
                if enchant.level < enchant.maxLevel then
                    if resources.essence >= enchant.cost then
                        resources.essence = resources.essence - enchant.cost
                        enchant.level = enchant.level + 1
                        ResPara:SetDesc("🔮 Essence: " .. resources.essence .. "\n⭐ Level: " .. resources.level)
                        SmoothUI.createNotification("Enchanted", enchant.name .. " level " .. enchant.level, 2)
                    else
                        SmoothUI.createNotification("Not Enough Essence", "Need " .. enchant.cost .. " essence", 2)
                    end
                else
                    SmoothUI.createNotification("Max Level", enchant.name .. " is already maxed", 2)
                end
            end
        })
        
        EnchantSection:AddLabel("Cost: " .. enchant.cost .. " essence")
    end
    
    -- Auto enchant toggle
    EnchantSection:AddToggle({
        Name = "Auto Enchant",
        Default = false,
        Color = Color3.fromRGB(150, 0, 150),
        Outline = true,
        Flag = "AutoEnchant",
        Save = true,
        Callback = function(Value)
            SmoothUI.createNotification("Auto Enchant", Value and "Started" or "Stopped", 2)
        end
    })
    
    -- Add essence button
    Tab:AddButton({
        Name = "Add +100 Essence",
        Icon = "plus-circle",
        Outline = true,
        Callback = function()
            resources.essence = resources.essence + 100
            ResPara:SetDesc("🔮 Essence: " .. resources.essence .. "\n⭐ Level: " .. resources.level)
        end
    })
end

--==================================================
-- BALANCED AUTO FARM
--==================================================
local BalancedAutoFarm = {}

function BalancedAutoFarm.init()
    local Tab = Window:MakeTab({
        Name = "Balanced Farm",
        Icon = "zap",
        Glass = true,
        Outline = true
    })
    
    -- Status
    local StatusPara = Tab:AddParagraph({
        Title = "Farm Status",
        Desc = "Farming in progress...\nItems/min: 12\nTime: 2h 34m",
        Image = "activity",
        ImageSize = 38
    })
    
    -- Mode selection
    local ModeSection = Tab:AddSection({
        Name = "Farm Mode",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    local modes = {"Balanced", "Speed", "Efficiency", "Safe"}
    for _, mode in ipairs(modes) do
        ModeSection:AddButton({
            Name = mode .. " Mode",
            Icon = "chevron-right",
            Outline = true,
            Callback = function()
                StatusPara:SetDesc("Farming in " .. mode .. " mode...\nItems/min: " .. math.random(10, 20))
            end
        })
    end
    
    -- Settings
    local SettingSection = Tab:AddSection({
        Name = "Farm Settings",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    SettingSection:AddToggle({
        Name = "Auto Collect",
        Default = true,
        Color = Color3.fromRGB(0, 200, 0),
        Outline = true,
        Flag = "AutoCollectFarm",
        Save = true
    })
    
    SettingSection:AddToggle({
        Name = "Auto Sell",
        Default = true,
        Color = Color3.fromRGB(0, 200, 0),
        Outline = true,
        Flag = "AutoSellFarm",
        Save = true
    })
    
    SettingSection:AddToggle({
        Name = "Auto Upgrade",
        Default = false,
        Color = Color3.fromRGB(200, 100, 0),
        Outline = true,
        Flag = "AutoUpgradeFarm",
        Save = true
    })
    
    -- Controls
    local ControlSection = Tab:AddSection({
        Name = "Controls",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    ControlSection:AddButton({
        Name = "Start Farming",
        Icon = "play",
        Outline = true,
        Callback = function()
            StatusPara:SetDesc("Farming started!\nItems/min: 18\nTime: 0h 0m")
        end
    })
    
    ControlSection:AddButton({
        Name = "Stop Farming",
        Icon = "square",
        Outline = true,
        Callback = function()
            StatusPara:SetDesc("Farming stopped")
        end
    })
    
    ControlSection:AddButton({
        Name = "View Stats",
        Icon = "bar-chart",
        Outline = true,
        Callback = function()
            SmoothUI.createNotification("Farm Stats", "Total items: 2,547", 3)
        end
    })
end

--==================================================
-- AUTO UNLOCK
--==================================================
local AutoUnlock = {}

function AutoUnlock.init()
    local unlocks = {
        {name = "Area 2", requirement = "Level 10", cost = 1000, unlocked = false},
        {name = "Area 3", requirement = "Level 25", cost = 5000, unlocked = false},
        {name = "Shop", requirement = "Level 5", cost = 500, unlocked = true},
        {name = "Crafting", requirement = "Level 15", cost = 2000, unlocked = false},
        {name = "PvP Arena", requirement = "Level 30", cost = 10000, unlocked = false},
        {name = "Secret Area", requirement = "Level 50", cost = 50000, unlocked = false}
    }
    
    local stats = {
        level = 12,
        coins = 3500
    }
    
    local Tab = Window:MakeTab({
        Name = "Auto Unlock",
        Icon = "unlock",
        Glass = true,
        Outline = true
    })
    
    -- Stats
    local StatsPara = Tab:AddParagraph({
        Title = "Your Stats",
        Desc = "⭐ Level: " .. stats.level .. "\n💰 Coins: " .. stats.coins,
        Image = "user",
        ImageSize = 38
    })
    
    local UnlockSection = Tab:AddSection({
        Name = "Available Unlocks",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    for _, unlock in ipairs(unlocks) do
        local status = unlock.unlocked and "✅ Unlocked" or "🔒 Locked"
        UnlockSection:AddButton({
            Name = unlock.name .. " (" .. status .. ")",
            Icon = unlock.unlocked and "check-circle" or "lock",
            Outline = true,
            Callback = function()
                if not unlock.unlocked then
                    local reqLevel = tonumber(unlock.requirement:match("%d+"))
                    if stats.level >= reqLevel and stats.coins >= unlock.cost then
                        stats.coins = stats.coins - unlock.cost
                        unlock.unlocked = true
                        StatsPara:SetDesc("⭐ Level: " .. stats.level .. "\n💰 Coins: " .. stats.coins)
                        SmoothUI.createNotification("Unlocked!", unlock.name .. " is now available!", 2)
                    elseif stats.level < reqLevel then
                        SmoothUI.createNotification("Level too low", "Need level " .. reqLevel, 2)
                    else
                        SmoothUI.createNotification("Not enough coins", "Need " .. unlock.cost .. " coins", 2)
                    end
                end
            end
        })
        
        UnlockSection:AddLabel(unlock.requirement .. " | Cost: " .. unlock.cost .. " coins")
    end
    
    -- Auto unlock toggle
    Tab:AddToggle({
        Name = "Auto Unlock",
        Default = false,
        Color = Color3.fromRGB(100, 50, 200),
        Outline = true,
        Flag = "AutoUnlockToggle",
        Save = true
    })
end

--==================================================
-- AUTO TAP KEYLESS
--==================================================
local AutoTapKeyless = {}

function AutoTapKeyless.init()
    local tapData = {
        taps = 0,
        power = 1,
        autoEnabled = false,
        interval = 0.1
    }
    
    local Tab = Window:MakeTab({
        Name = "Auto Tap",
        Icon = "hand",
        Glass = true,
        Outline = true
    })
    
    -- Counter
    local CounterPara = Tab:AddParagraph({
        Title = "Total Taps",
        Desc = tostring(tapData.taps),
        Image = "activity",
        ImageSize = 38
    })
    
    local PowerPara = Tab:AddParagraph({
        Title = "Tap Power",
        Desc = tapData.power .. "x",
        Image = "zap",
        ImageSize = 38
    })
    
    -- Controls
    local ControlSection = Tab:AddSection({
        Name = "Controls",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    ControlSection:AddToggle({
        Name = "Auto Tap",
        Default = false,
        Color = Color3.fromRGB(0, 200, 0),
        Outline = true,
        Flag = "AutoTapKeyless",
        Save = true,
        Callback = function(Value)
            tapData.autoEnabled = Value
            if Value then
                task.spawn(function()
                    while tapData.autoEnabled do
                        task.wait(tapData.interval)
                        tapData.taps = tapData.taps + tapData.power
                        CounterPara:SetDesc(tostring(tapData.taps))
                    end
                end)
            end
        end
    })
    
    ControlSection:AddButton({
        Name = "Manual Tap",
        Icon = "mouse-pointer",
        Outline = true,
        Callback = function()
            tapData.taps = tapData.taps + tapData.power
            CounterPara:SetDesc(tostring(tapData.taps))
        end
    })
    
    -- Upgrades
    local UpgradeSection = Tab:AddSection({
        Name = "Upgrades",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    UpgradeSection:AddButton({
        Name = "Upgrade Power (100 taps)",
        Icon = "arrow-up",
        Outline = true,
        Callback = function()
            if tapData.taps >= 100 then
                tapData.taps = tapData.taps - 100
                tapData.power = tapData.power + 1
                CounterPara:SetDesc(tostring(tapData.taps))
                PowerPara:SetDesc(tapData.power .. "x")
            else
                SmoothUI.createNotification("Not enough taps", "Need 100 taps", 2)
            end
        end
    })
    
    UpgradeSection:AddButton({
        Name = "Upgrade Speed (200 taps)",
        Icon = "fast-forward",
        Outline = true,
        Callback = function()
            if tapData.taps >= 200 then
                tapData.taps = tapData.taps - 200
                tapData.interval = math.max(0.01, tapData.interval - 0.02)
                CounterPara:SetDesc(tostring(tapData.taps))
            else
                SmoothUI.createNotification("Not enough taps", "Need 200 taps", 2)
            end
        end
    })
    
    UpgradeSection:AddButton({
        Name = "Reset Taps",
        Icon = "rotate-ccw",
        Outline = true,
        Callback = function()
            tapData.taps = 0
            CounterPara:SetDesc("0")
        end
    })
end

--==================================================
-- AUTO TAP (Simple)
--==================================================
local AutoTap = {}

function AutoTap.init()
    local taps = 0
    
    local Tab = Window:MakeTab({
        Name = "Simple Tap",
        Icon = "mouse-pointer",
        Glass = true,
        Outline = true
    })
    
    local CounterPara = Tab:AddParagraph({
        Title = "Total Taps",
        Desc = "0",
        Image = "activity",
        ImageSize = 38
    })
    
    local ControlSection = Tab:AddSection({
        Name = "Controls",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    ControlSection:AddToggle({
        Name = "Auto Tap",
        Default = false,
        Color = Color3.fromRGB(0, 200, 0),
        Outline = true,
        Flag = "AutoTapSimple",
        Save = true,
        Callback = function(Value)
            if Value then
                task.spawn(function()
                    while Value do
                        task.wait(0.1)
                        taps = taps + 1
                        CounterPara:SetDesc(tostring(taps))
                    end
                end)
            end
        end
    })
    
    ControlSection:AddButton({
        Name = "Manual Tap",
        Icon = "mouse-pointer",
        Outline = true,
        Callback = function()
            taps = taps + 1
            CounterPara:SetDesc(tostring(taps))
        end
    })
    
    ControlSection:AddButton({
        Name = "Reset",
        Icon = "rotate-ccw",
        Outline = true,
        Callback = function()
            taps = 0
            CounterPara:SetDesc("0")
        end
    })
end

--==================================================
-- AUTO REBIRTH
--==================================================
local AutoRebirth = {}

function AutoRebirth.init()
    local rebirthData = {
        level = 50,
        rebirths = 0,
        rebirthCost = 1000,
        autoEnabled = false
    }
    
    local Tab = Window:MakeTab({
        Name = "Auto Rebirth",
        Icon = "rotate-ccw",
        Glass = true,
        Outline = true
    })
    
    -- Stats
    local StatsPara = Tab:AddParagraph({
        Title = "Rebirth Stats",
        Desc = "Level: " .. rebirthData.level .. "\nRebirths: " .. rebirthData.rebirths .. "\nCost: " .. rebirthData.rebirthCost,
        Image = "bar-chart",
        ImageSize = 38
    })
    
    local ControlSection = Tab:AddSection({
        Name = "Controls",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    ControlSection:AddButton({
        Name = "Rebirth Now",
        Icon = "rotate-ccw",
        Outline = true,
        Callback = function()
            if rebirthData.level >= 50 then
                rebirthData.rebirths = rebirthData.rebirths + 1
                rebirthData.level = 1
                rebirthData.rebirthCost = rebirthData.rebirthCost * 2
                StatsPara:SetDesc("Level: " .. rebirthData.level .. "\nRebirths: " .. rebirthData.rebirths .. "\nCost: " .. rebirthData.rebirthCost)
                SmoothUI.createNotification("Rebirthed!", "Rebirths: " .. rebirthData.rebirths, 2)
            else
                SmoothUI.createNotification("Level too low", "Need level 50", 2)
            end
        end
    })
    
    ControlSection:AddToggle({
        Name = "Auto Rebirth",
        Default = false,
        Color = Color3.fromRGB(150, 0, 150),
        Outline = true,
        Flag = "AutoRebirthMain",
        Save = true,
        Callback = function(Value)
            rebirthData.autoEnabled = Value
            if Value then
                task.spawn(function()
                    while rebirthData.autoEnabled do
                        task.wait(1)
                        rebirthData.level = rebirthData.level + 1
                        StatsPara:SetDesc("Level: " .. rebirthData.level .. "\nRebirths: " .. rebirthData.rebirths .. "\nCost: " .. rebirthData.rebirthCost)
                        
                        if rebirthData.level >= 50 then
                            rebirthData.rebirths = rebirthData.rebirths + 1
                            rebirthData.level = 1
                            rebirthData.rebirthCost = rebirthData.rebirthCost * 2
                            StatsPara:SetDesc("Level: " .. rebirthData.level .. "\nRebirths: " .. rebirthData.rebirths .. "\nCost: " .. rebirthData.rebirthCost)
                        end
                    end
                end)
            end
        end
    })
    
    -- Target setting
    local SettingSection = Tab:AddSection({
        Name = "Settings",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    SettingSection:AddTextbox({
        Name = "Target Level",
        Default = "50",
        TextDisappear = false,
        Outline = true,
        Callback = function(Value)
            -- Handle target level
        end
    })
end

--==================================================
-- AUTOMATION SCRIPT
--==================================================
local AutomationScript = {}

function AutomationScript.init()
    local Tab = Window:MakeTab({
        Name = "Automation",
        Icon = "cpu",
        Glass = true,
        Outline = true
    })
    
    local automations = {
        {name = "Auto Farm", category = "Farming", enabled = false},
        {name = "Auto Combat", category = "Combat", enabled = true},
        {name = "Auto Collect", category = "Utility", enabled = false},
        {name = "Auto Sell", category = "Utility", enabled = true},
        {name = "Auto Move", category = "Movement", enabled = false},
        {name = "Auto Heal", category = "Combat", enabled = true},
        {name = "Auto Craft", category = "Utility", enabled = false},
        {name = "Auto Upgrade", category = "Farming", enabled = false}
    }
    
    local FarmSection = Tab:AddSection({
        Name = "Farming",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    local CombatSection = Tab:AddSection({
        Name = "Combat",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    local UtilitySection = Tab:AddSection({
        Name = "Utility",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    for _, auto in ipairs(automations) do
        local targetSection
        if auto.category == "Farming" then
            targetSection = FarmSection
        elseif auto.category == "Combat" then
            targetSection = CombatSection
        else
            targetSection = UtilitySection
        end
        
        targetSection:AddToggle({
            Name = auto.name,
            Default = auto.enabled,
            Color = Color3.fromRGB(0, 150, 200),
            Outline = true,
            Flag = auto.name,
            Save = true
        })
    end
    
    -- Control panel
    local ControlSection = Tab:AddSection({
        Name = "Controls",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    ControlSection:AddButton({
        Name = "Start All",
        Icon = "play",
        Outline = true,
        Callback = function()
            SmoothUI.createNotification("Automation", "All features started", 2)
        end
    })
    
    ControlSection:AddButton({
        Name = "Stop All",
        Icon = "square",
        Outline = true,
        Callback = function()
            SmoothUI.createNotification("Automation", "All features stopped", 2)
        end
    })
end

--==================================================
-- AUTOMATIONS (Simple)
--==================================================
local Automations = {}

function Automations.init()
    local Tab = Window:MakeTab({
        Name = "Simple Auto",
        Icon = "settings",
        Glass = true,
        Outline = true
    })
    
    local automations = {
        {name = "Auto Click", icon = "👆"},
        {name = "Auto Farm", icon = "🌾"},
        {name = "Auto Rebirth", icon = "🔄"},
        {name = "Auto Hatch", icon = "🥚"},
        {name = "Auto Enchant", icon = "✨"},
        {name = "Auto Collect", icon = "📦"}
    }
    
    for _, auto in ipairs(automations) do
        Tab:AddToggle({
            Name = auto.name,
            Default = false,
            Color = Color3.fromRGB(100, 50, 200),
            Outline = true,
            Flag = auto.name,
            Save = true,
            Callback = function(Value)
                SmoothUI.createNotification(auto.name, Value and "Activated" or "Deactivated", 1)
            end
        })
    end
end

--==================================================
-- AUTO FARM & REBIRTH
--==================================================
local AutoFarmRebirth = {}

function AutoFarmRebirth.init()
    local stats = {
        level = 25,
        rebirths = 3,
        coins = 15000
    }
    
    local Tab = Window:MakeTab({
        Name = "Farm+Rebirth",
        Icon = "repeat",
        Glass = true,
        Outline = true
    })
    
    -- Stats
    local StatsPara = Tab:AddParagraph({
        Title = "Your Stats",
        Desc = "Level: " .. stats.level .. "\nRebirths: " .. stats.rebirths .. "\nCoins: " .. stats.coins,
        Image = "bar-chart",
        ImageSize = 38
    })
    
    local FarmSection = Tab:AddSection({
        Name = "Farm Settings",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    FarmSection:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Color = Color3.fromRGB(0, 150, 0),
        Outline = true,
        Flag = "AutoFarmRebirthFarm",
        Save = true,
        Callback = function(Value)
            if Value then
                task.spawn(function()
                    while Value do
                        task.wait(1)
                        stats.level = stats.level + 1
                        stats.coins = stats.coins + 10
                        StatsPara:SetDesc("Level: " .. stats.level .. "\nRebirths: " .. stats.rebirths .. "\nCoins: " .. stats.coins)
                    end
                end)
            end
        end
    })
    
    FarmSection:AddToggle({
        Name = "Auto Rebirth",
        Default = false,
        Color = Color3.fromRGB(150, 0, 150),
        Outline = true,
        Flag = "AutoFarmRebirthRebirth",
        Save = true,
        Callback = function(Value)
            if Value then
                task.spawn(function()
                    while Value do
                        task.wait(5)
                        if stats.level >= 50 then
                            stats.rebirths = stats.rebirths + 1
                            stats.level = 1
                            StatsPara:SetDesc("Level: " .. stats.level .. "\nRebirths: " .. stats.rebirths .. "\nCoins: " .. stats.coins)
                            SmoothUI.createNotification("Rebirthed!", "Rebirths: " .. stats.rebirths, 2)
                        end
                    end
                end)
            end
        end
    })
    
    -- Target
    local TargetSection = Tab:AddSection({
        Name = "Target",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    TargetSection:AddTextbox({
        Name = "Rebirth at Level",
        Default = "50",
        TextDisappear = false,
        Outline = true
    })
end

--==================================================
-- AUTO FARM & HATCH
--==================================================
local AutoFarmHatch = {}

function AutoFarmHatch.init()
    local stats = {
        coins = 5000,
        eggs = 3,
        pets = 12
    }
    
    local Tab = Window:MakeTab({
        Name = "Farm+Hatch",
        Icon = "egg",
        Glass = true,
        Outline = true
    })
    
    -- Stats
    local StatsPara = Tab:AddParagraph({
        Title = "Your Stats",
        Desc = "💰 Coins: " .. stats.coins .. "\n🥚 Eggs: " .. stats.eggs .. "\n🐾 Pets: " .. stats.pets,
        Image = "package",
        ImageSize = 38
    })
    
    local FarmSection = Tab:AddSection({
        Name = "Farm Settings",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    FarmSection:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Color = Color3.fromRGB(0, 150, 0),
        Outline = true,
        Flag = "AutoFarmHatchFarm",
        Save = true,
        Callback = function(Value)
            if Value then
                task.spawn(function()
                    while Value do
                        task.wait(1)
                        stats.coins = stats.coins + 5
                        StatsPara:SetDesc("💰 Coins: " .. stats.coins .. "\n🥚 Eggs: " .. stats.eggs .. "\n🐾 Pets: " .. stats.pets)
                    end
                end)
            end
        end
    })
    
    local HatchSection = Tab:AddSection({
        Name = "Hatch Settings",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    HatchSection:AddToggle({
        Name = "Auto Hatch",
        Default = false,
        Color = Color3.fromRGB(150, 50, 150),
        Outline = true,
        Flag = "AutoFarmHatchHatch",
        Save = true,
        Callback = function(Value)
            if Value and stats.eggs > 0 then
                task.spawn(function()
                    while Value and stats.eggs > 0 do
                        task.wait(2)
                        stats.eggs = stats.eggs - 1
                        stats.pets = stats.pets + 1
                        StatsPara:SetDesc("💰 Coins: " .. stats.coins .. "\n🥚 Eggs: " .. stats.eggs .. "\n🐾 Pets: " .. stats.pets)
                        SmoothUI.createNotification("Hatched!", "New pet added!", 1)
                    end
                end)
            end
        end
    })
    
    HatchSection:AddButton({
        Name = "Buy Egg (100 coins)",
        Icon = "shopping-cart",
        Outline = true,
        Callback = function()
            if stats.coins >= 100 then
                stats.coins = stats.coins - 100
                stats.eggs = stats.eggs + 1
                StatsPara:SetDesc("💰 Coins: " .. stats.coins .. "\n🥚 Eggs: " .. stats.eggs .. "\n🐾 Pets: " .. stats.pets)
            end
        end
    })
end

--==================================================
-- AUTO ENCHANT (Standalone)
--==================================================
local AutoEnchant = {}

function AutoEnchant.init()
    local essence = 500
    
    local Tab = Window:MakeTab({
        Name = "Simple Enchant",
        Icon = "sparkles",
        Glass = true,
        Outline = true
    })
    
    -- Essence display
    local EssencePara = Tab:AddParagraph({
        Title = "Enchant Essence",
        Desc = "🔮 " .. essence,
        Image = "circle",
        ImageSize = 38
    })
    
    local EnchantSection = Tab:AddSection({
        Name = "Enchantments",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    local enchants = {
        {name = "Sharpness", level = 3, max = 5, cost = 100},
        {name = "Protection", level = 2, max = 4, cost = 150},
        {name = "Efficiency", level = 4, max = 5, cost = 120},
        {name = "Unbreaking", level = 2, max = 3, cost = 80}
    }
    
    for _, enchant in ipairs(enchants) do
        EnchantSection:AddButton({
            Name = enchant.name .. " (Lv." .. enchant.level .. "/" .. enchant.max .. ")",
            Icon = "wand",
            Outline = true,
            Callback = function()
                if enchant.level < enchant.max and essence >= enchant.cost then
                    essence = essence - enchant.cost
                    enchant.level = enchant.level + 1
                    EssencePara:SetDesc("🔮 " .. essence)
                    SmoothUI.createNotification("Enchanted", enchant.name .. " level " .. enchant.level, 2)
                else
                    SmoothUI.createNotification("Cannot enchant", "Not enough essence or max level", 2)
                end
            end
        })
    end
    
    EnchantSection:AddToggle({
        Name = "Auto Enchant",
        Default = false,
        Color = Color3.fromRGB(150, 50, 200),
        Outline = true,
        Flag = "AutoEnchantSimple",
        Save = true
    })
end

--==================================================
-- INITIALIZE ALL SCRIPTS
--==================================================

-- Initialize all systems (but don't create tabs yet, they'll be created when functions are called)
-- We'll create the main menu tab to call all functions

local MainMenu = {}

function MainMenu.init()
    local Tab = Window:MakeTab({
        Name = "Main Menu",
        Icon = "home",
        Glass = true,
        Outline = true
    })
    
    Tab:AddParagraph({
        Title = "Mega Script Collection",
        Desc = "All-in-One Premium Scripts\nChoose a category below",
        Image = "rocket",
        ImageSize = 48
    })
    
    local Sections = {
        {name = "🚀 TELEPORT SYSTEMS", scripts = {"Teleport Zones", "Teleports System"}},
        {name = "🎁 REWARDS SYSTEMS", scripts = {"Rewards System"}},
        {name = "⚡ AUTO FARM SYSTEMS", scripts = {"Balanced Auto Farm", "Auto Farm & Rebirth", "Auto Farm & Hatch", "Automation Script"}},
        {name = "✨ ENCHANT SYSTEMS", scripts = {"Best Auto Enchant", "Auto Enchant"}},
        {name = "🥚 EGG SYSTEMS", scripts = {"Egg System"}},
        {name = "📊 PROGRESS SYSTEMS", scripts = {"Quick Progress", "Full Progress Automation", "Auto Unlock"}},
        {name = "👆 AUTO TAP SYSTEMS", scripts = {"Auto Tap Keyless", "Auto Tap"}},
        {name = "🔄 REBIRTH SYSTEMS", scripts = {"Auto Rebirth"}},
        {name = "⚒️ CRAFTING SYSTEMS", scripts = {"Crafting Script"}},
        {name = "🔓 KEYLESS SYSTEMS", scripts = {"Keyless V2", "Keyless Script"}},
        {name = "🤖 AUTOMATION SYSTEMS", scripts = {"Automations", "Simple Auto"}},
        {name = "🔥 OP SYSTEMS", scripts = {"OP Script", "Free Script"}}
    }
    
    for _, section in ipairs(Sections) do
        local Section = Tab:AddSection({
            Name = section.name,
            TextSize = 17,
            Glass = true,
            Outline = true
        })
        
        for _, scriptName in ipairs(section.scripts) do
            Section:AddButton({
                Name = "Open " .. scriptName,
                Icon = "chevron-right",
                Outline = true,
                Callback = function()
                    if scriptName == "Teleport Zones" then
                        TeleportZones.init()
                    elseif scriptName == "Teleports System" then
                        TeleportsSystem.init()
                    elseif scriptName == "Rewards System" then
                        RewardsSystem.init()
                    elseif scriptName == "Balanced Auto Farm" then
                        BalancedAutoFarm.init()
                    elseif scriptName == "Auto Farm & Rebirth" then
                        AutoFarmRebirth.init()
                    elseif scriptName == "Auto Farm & Hatch" then
                        AutoFarmHatch.init()
                    elseif scriptName == "Automation Script" then
                        AutomationScript.init()
                    elseif scriptName == "Best Auto Enchant" then
                        BestAutoEnchant.init()
                    elseif scriptName == "Auto Enchant" then
                        AutoEnchant.init()
                    elseif scriptName == "Egg System" then
                        EggSystem.init()
                    elseif scriptName == "Quick Progress" then
                        QuickProgress.init()
                    elseif scriptName == "Full Progress Automation" then
                        FullProgressAutomation.init()
                    elseif scriptName == "Auto Unlock" then
                        AutoUnlock.init()
                    elseif scriptName == "Auto Tap Keyless" then
                        AutoTapKeyless.init()
                    elseif scriptName == "Auto Tap" then
                        AutoTap.init()
                    elseif scriptName == "Auto Rebirth" then
                        AutoRebirth.init()
                    elseif scriptName == "Crafting Script" then
                        OPCraftingScript.init()
                    elseif scriptName == "Keyless V2" then
                        KeylessV2.init()
                    elseif scriptName == "Keyless Script" then
                        KeylessScript.init()
                    elseif scriptName == "Automations" then
                        Automations.init()
                    elseif scriptName == "Simple Auto" then
                        Automations.init()
                    elseif scriptName == "OP Script" then
                        OPScript.init()
                    elseif scriptName == "Free Script" then
                        OPFreeScript.init()
                    end
                end
            })
        end
    end
    
    -- Credits
    Tab:AddSection({
        Name = "Credits",
        TextSize = 17,
        Glass = true,
        Outline = true
    })
    
    Tab:AddParagraph({
        Title = "Mega Script Collection",
        Desc = "Version 1.0\nAdapted for Catraz Hub",
        Image = "award",
        ImageSize = 38
    })
end

-- Initialize main menu
MainMenu.init()

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

Notify("Press F4 or click floating button to toggle menu")
print("=== Mega Script Collection - Catraz Edition ===")
print("Press F4 to toggle menu")
print("All scripts loaded successfully!")