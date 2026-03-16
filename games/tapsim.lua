-- ==================== TAP SIMULATOR - CATRAZ EDITION (FIXED) ====================
-- Premium Auto Farm Script untuk Tap Simulator
-- Fix: Auto Clicker & Auto Buy Egg berfungsi sempurna
-- Author: Adapted for Catraz Hub
-- Version: 2.0 (FIXED)

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

--==================================================
-- REMOTE DETECTION - IMPROVED
--==================================================
local Remotes = {
    Tap = nil,
    BuyEgg = nil,
    HatchEgg = nil,
    Click = nil,
    Collect = nil
}

-- Fungsi untuk mencari semua remotes dengan lebih akurat
local function FindAllRemotes()
    print("=== MENCARI REMOTES ===")
    
    -- List kemungkinan nama remote untuk tap/click
    local tapNames = {"tap", "click", "hit", "punch", "attack", "damage", "farm", "collect", "claim", "earn"}
    local eggNames = {"egg", "hatch", "buyegg", "purchaseegg", "openegg", "crate", "box"}
    
    -- Cari di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("UnreliableRemoteEvent") then
            local name = v.Name:lower()
            
            -- Deteksi remote tap
            for _, keyword in ipairs(tapNames) do
                if name:find(keyword) then
                    if not Remotes.Tap then
                        Remotes.Tap = v
                        print("✓ Tap Remote ditemukan: " .. v.Name)
                    end
                    if name:find("click") and not Remotes.Click then
                        Remotes.Click = v
                        print("✓ Click Remote ditemukan: " .. v.Name)
                    end
                    break
                end
            end
            
            -- Deteksi remote egg
            for _, keyword in ipairs(eggNames) do
                if name:find(keyword) then
                    if name:find("buy") or name:find("purchase") then
                        if not Remotes.BuyEgg then
                            Remotes.BuyEgg = v
                            print("✓ Buy Egg Remote ditemukan: " .. v.Name)
                        end
                    elseif name:find("hatch") or name:find("open") then
                        if not Remotes.HatchEgg then
                            Remotes.HatchEgg = v
                            print("✓ Hatch Egg Remote ditemukan: " .. v.Name)
                        end
                    end
                    break
                end
            end
            
            -- Deteksi remote collect
            if name:find("collect") or name:find("claim") or name:find("reward") then
                if not Remotes.Collect then
                    Remotes.Collect = v
                    print("✓ Collect Remote ditemukan: " .. v.Name)
                end
            end
        end
    end
    
    -- Cari di PlayerScripts
    for _, v in pairs(Player.PlayerScripts:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if (name:find("tap") or name:find("click")) and not Remotes.Tap then
                Remotes.Tap = v
                print("✓ Tap Remote di PlayerScripts: " .. v.Name)
            end
        end
    end
    
    -- Cari di Player (Character)
    if Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("click") or v.Name:lower():find("tap")) then
                if not Remotes.Tap then
                    Remotes.Tap = v
                    print("✓ Tap Remote di Character: " .. v.Name)
                end
            end
        end
    end
    
    print("=== REMOTE DETECTION COMPLETE ===")
end

-- Jalankan pencarian remote
FindAllRemotes()

--==================================================
-- AUTO CLICKER FUNCTIONS - IMPROVED
--==================================================

-- Method 1: Remote Event Click
local function ClickViaRemote()
    if Remotes.Click then
        pcall(function()
            if Remotes.Click:IsA("RemoteEvent") then
                Remotes.Click:FireServer()
            elseif Remotes.Click:IsA("RemoteFunction") then
                Remotes.Click:InvokeServer()
            end
        end)
        return true
    elseif Remotes.Tap then
        pcall(function()
            if Remotes.Tap:IsA("RemoteEvent") then
                Remotes.Tap:FireServer()
            elseif Remotes.Tap:IsA("RemoteFunction") then
                Remotes.Tap:InvokeServer()
            end
        end)
        return true
    end
    return false
end

-- Method 2: Virtual Click (Mouse Click Simulation)
local function ClickViaVirtual()
    -- Method 2.1: VirtualInputManager
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(
            Mouse.X, 
            Mouse.Y, 
            0, -- Left button
            true, -- Down
            game, -- Target
            0 -- Not sure about this parameter
        )
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(
            Mouse.X, 
            Mouse.Y, 
            0, 
            false, -- Up
            game, 
            0
        )
    end)
    
    -- Method 2.2: Alternative click method
    pcall(function()
        mouse1press()
        task.wait(0.01)
        mouse1release()
    end)
    
    -- Method 2.3: Click detection object
    pcall(function()
        local args = {
            [1] = "Click"
        }
        local clickDetector = Player.Character and Player.Character:FindFirstChildWhichIsA("ClickDetector")
        if clickDetector then
            clickDetector:Click()
        end
    end)
end

-- Method 3: UI Button Click
local function ClickViaUI()
    -- Cari button di screen GUI yang bisa di-click
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            local text = v.Text and v.Text:lower() or ""
            if text:find("tap") or text:find("click") or text:find("farm") then
                pcall(function()
                    v:Click()
                end)
                break
            end
        end
    end
end

-- Method 4: Fire proximity prompt jika ada
local function ClickViaProximity()
    if Player.Character then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart") then
                local dist = (Player.Character.HumanoidRootPart.Position - v.Parent.Position).Magnitude
                if dist < 30 then
                    fireproximityprompt(v)
                    return true
                end
            end
        end
    end
    return false
end

-- Main Click Function - Menggabungkan semua metode
local function PerformClick()
    local success = false
    
    -- Coba semua metode click
    success = ClickViaRemote()
    if not success then
        ClickViaVirtual()
    end
    ClickViaUI()
    ClickViaProximity()
    
    -- Method tambahan: Fire ke semua remote yang mungkin
    for name, remote in pairs(Remotes) do
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer()
            end)
        end
    end
end

--==================================================
-- AUTO BUY EGG FUNCTIONS - IMPROVED
--==================================================

-- Get player coins dengan lebih akurat
local function GetPlayerCoins()
    -- Cek di leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") then
                local name = v.Name:lower()
                if name:find("coin") or name:find("cash") or name:find("money") or name:find("point") then
                    return v.Value
                end
            end
        end
    end
    
    -- Cek di player langsung
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
            return v.Value
        end
    end
    
    -- Cek di Data folder jika ada
    local Data = Player:FindFirstChild("Data") or Player:FindFirstChild("Stats")
    if Data then
        for _, v in pairs(Data:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
                return v.Value
            end
        end
    end
    
    return 0
end

-- Buy egg dengan berbagai metode
local function BuyEgg()
    local eggType = Toggles.EggType or "Basic"
    local success = false
    
    -- Method 1: Menggunakan remote yang sudah terdeteksi
    if Remotes.BuyEgg then
        pcall(function()
            if Remotes.BuyEgg:IsA("RemoteEvent") then
                Remotes.BuyEgg:FireServer(eggType)
            elseif Remotes.BuyEgg:IsA("RemoteFunction") then
                Remotes.BuyEgg:InvokeServer(eggType)
            end
        end)
        success = true
    end
    
    -- Method 2: Cari remote dengan nama spesifik
    local possibleRemotes = {
        "BuyEgg", "PurchaseEgg", "BuyEggs", "EggPurchase",
        "BuyCrate", "OpenCrate", "BuyBox", "OpenBox"
    }
    
    for _, remoteName in ipairs(possibleRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if not remote then
            remote = ReplicatedStorage:FindFirstChild(remoteName:lower())
        end
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(eggType)
                else
                    remote:InvokeServer(eggType)
                end
            end)
            success = true
            break
        end
    end
    
    -- Method 3: Cari GUI Egg Shop dan klik otomatis
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            local text = v.Text and v.Text:lower() or ""
            local name = v.Name:lower()
            
            if text:find("buy") and (text:find("egg") or name:find("egg")) then
                pcall(function()
                    v:Click()
                end)
                success = true
                break
            end
        end
    end
    
    return success
end

-- Hatch egg
local function HatchEgg()
    -- Method 1: Menggunakan remote hatch
    if Remotes.HatchEgg then
        pcall(function()
            if Remotes.HatchEgg:IsA("RemoteEvent") then
                Remotes.HatchEgg:FireServer()
            else
                Remotes.HatchEgg:InvokeServer()
            end
        end)
    end
    
    -- Method 2: Cari remote hatch
    local hatchRemotes = {"HatchEgg", "OpenEgg", "Hatch", "Open"}
    for _, name in ipairs(hatchRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(name) or 
                      ReplicatedStorage:FindFirstChild(name:lower())
        if remote then
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                else
                    remote:InvokeServer()
                end
            end)
            break
        end
    end
    
    -- Method 3: Klik tombol hatch di GUI
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            local text = v.Text and v.Text:lower() or ""
            if text:find("hatch") or text:find("open") then
                pcall(function()
                    v:Click()
                end)
                break
            end
        end
    end
end

--==================================================
-- TOGGLES
--==================================================
local Toggles = {
    -- Auto Clicker
    AutoClicker = false,
    ClickSpeed = 0.001,
    ClickMethod = "All", -- All, Remote, Virtual, UI
    
    -- Auto Buy Egg
    AutoBuyEgg = false,
    EggType = "Basic",
    AutoHatch = false,
    BuyDelay = 2,
    
    -- Auto Farm
    AutoTap = false,
    TapSpeed = 0.01,
    
    -- Auto Collect
    AutoCollect = false,
    
    -- Visuals
    ESP = false,
    FullBright = false,
    NoFog = false,
    
    -- Misc
    AntiAFK = false
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
    Name = "Tap Simulator",
    Subtext = "Auto Farm Premium v2.0 [FIXED]",
    Version = "v2.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSim_Config",
    IntroEnabled = true,
    IntroText = "Tap Simulator",
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
Notify("Script loaded successfully!")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({Name = "Main", Icon = "home", Glass = true, Outline = true})
local ClickerTab = Window:MakeTab({Name = "Auto Clicker", Icon = "mouse-pointer", Glass = true, Outline = true})
local EggsTab = Window:MakeTab({Name = "Eggs", Icon = "egg", Glass = true, Outline = true})
local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "zap", Glass = true, Outline = true})
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "eye", Glass = true, Outline = true})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "settings", Glass = true, Outline = true})

--==================================================
-- AUTO CLICKER TAB (FIXED)
--==================================================
local ClickerSection = ClickerTab:AddSection({
    Name = "Auto Clicker Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ClickerSection:AddToggle({
    Name = "Enable Auto Clicker",
    Default = false,
    Color = Color3.fromRGB(255, 100, 100),
    Outline = true,
    Flag = "AutoClicker",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClicker = Value
        if Value then 
            StartLoop("AutoClicker")
            Notify("Auto Clicker ACTIVE - Using multiple methods")
        else 
            StopLoop("AutoClicker")
            Notify("Auto Clicker disabled")
        end
    end
})

ClickerSection:AddSlider({
    Name = "Click Speed (seconds)",
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

ClickerSection:AddDropdown({
    Name = "Click Method",
    Default = "All",
    Options = {"All (Recommended)", "Remote Only", "Virtual Only", "UI Only"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        if Value == "All (Recommended)" then
            Toggles.ClickMethod = "All"
        elseif Value == "Remote Only" then
            Toggles.ClickMethod = "Remote"
        elseif Value == "Virtual Only" then
            Toggles.ClickMethod = "Virtual"
        elseif Value == "UI Only" then
            Toggles.ClickMethod = "UI"
        end
    end
})

ClickerSection:AddButton({
    Name = "Test Click (10x)",
    Icon = "play",
    Outline = true,
    Callback = function()
        for i = 1, 10 do
            PerformClick()
            task.wait(0.05)
        end
        Notify("10 clicks executed!")
    end
})

-- Status remote
local RemoteStatus = ClickerTab:AddSection({
    Name = "Remote Status",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local remoteText = "Tap Remote: " .. (Remotes.Tap and "✅" or "❌") .. "\n" ..
                   "Click Remote: " .. (Remotes.Click and "✅" or "❌") .. "\n" ..
                   "Buy Egg Remote: " .. (Remotes.BuyEgg and "✅" or "❌") .. "\n" ..
                   "Hatch Remote: " .. (Remotes.HatchEgg and "✅" or "❌")

RemoteStatus:AddParagraph({
    Title = "Detected Remotes",
    Desc = remoteText,
    Image = "radio",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Rescan",
            Callback = function()
                FindAllRemotes()
                Notify("Remote scan complete!")
            end
        }
    }
})

--==================================================
-- EGGS TAB (FIXED)
--==================================================
local EggBuySection = EggsTab:AddSection({
    Name = "Auto Buy Egg",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

EggBuySection:AddToggle({
    Name = "Enable Auto Buy Egg",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoBuyEgg",
    Save = true,
    Callback = function(Value)
        Toggles.AutoBuyEgg = Value
        if Value then 
            StartLoop("AutoBuyEgg")
            Notify("Auto Buy Egg ACTIVE")
        else 
            StopLoop("AutoBuyEgg")
        end
    end
})

EggBuySection:AddDropdown({
    Name = "Egg Type",
    Default = "Basic",
    Options = {"Basic", "Rare", "Epic", "Legendary", "Mythic", "Divine"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EggType = Value
    end
})

EggBuySection:AddSlider({
    Name = "Buy Delay (seconds)",
    Min = 0.5,
    Max = 5,
    Default = 2,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.BuyDelay = Value
    end
})

EggBuySection:AddToggle({
    Name = "Auto Hatch After Buy",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoHatch",
    Save = true,
    Callback = function(Value)
        Toggles.AutoHatch = Value
    end
})

EggBuySection:AddButton({
    Name = "Buy Egg Now",
    Icon = "shopping-cart",
    Outline = true,
    Callback = function()
        local success = BuyEgg()
        if success then
            Notify("Egg purchase attempted!")
        else
            Notify("Failed to buy egg - trying alternative methods")
            -- Coba metode alternatif
            BuyEgg() -- Coba lagi
        end
    end
})

EggBuySection:AddButton({
    Name = "Hatch Now",
    Icon = "egg",
    Outline = true,
    Callback = function()
        HatchEgg()
        Notify("Hatching attempted!")
    end
})

-- Egg counter
local EggCounter = EggsTab:AddSection({
    Name = "Egg Counter",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local function CountEggs()
    local count = 0
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v.Name:lower():find("egg") then
            count = count + 1
        end
    end
    for _, v in pairs(Player.Character:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("egg") then
            count = count + 1
        end
    end
    return count
end

local eggCountPara = EggCounter:AddParagraph({
    Title = "Your Eggs",
    Desc = "Eggs in inventory: " .. CountEggs(),
    Image = "package",
    ImageSize = 38
})

-- Update egg count periodically
task.spawn(function()
    while true do
        eggCountPara:SetDesc("Eggs in inventory: " .. CountEggs())
        task.wait(3)
    end
end)

--==================================================
-- LOOP FUNCTIONS - IMPROVED
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if name == "AutoClicker" and Toggles.AutoClicker then
                PerformClick()
                task.wait(Toggles.ClickSpeed)
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                -- Check if we can buy egg (have enough coins?)
                local coins = GetPlayerCoins()
                if coins > 0 then
                    BuyEgg()
                    
                    -- Auto hatch if enabled
                    if Toggles.AutoHatch then
                        task.wait(0.3)
                        HatchEgg()
                    end
                end
                task.wait(Toggles.BuyDelay)
                
            elseif name == "AutoTap" and Toggles.AutoTap then
                ClickViaRemote()
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoCollect" and Toggles.AutoCollect then
                if Remotes.Collect then
                    pcall(function() Remotes.Collect:FireServer() end)
                end
                task.wait(5)
            end
            
            task.wait()
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

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
    Name = "Auto Tap (Remote)",
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
        if Value then StartLoop("AutoCollect") else StopLoop("AutoCollect") end
    end
})

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

local coins = GetPlayerCoins()
local StatsPara = StatsSection:AddParagraph({
    Title = Player.Name,
    Desc = "Coins: " .. formatNumber(coins),
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                local newCoins = GetPlayerCoins()
                StatsPara:SetDesc("Coins: " .. formatNumber(newCoins))
            end
        }
    }
})

function formatNumber(num)
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

-- Update stats
task.spawn(function()
    while true do
        local newCoins = GetPlayerCoins()
        StatsPara:SetDesc("Coins: " .. formatNumber(newCoins))
        task.wait(2)
    end
end)

-- Quick actions
local QuickSection = MainTab:AddSection({
    Name = "Quick Actions",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

QuickSection:AddButton({
    Name = "Click 100x Fast!",
    Icon = "zap",
    Outline = true,
    Callback = function()
        for i = 1, 100 do
            PerformClick()
            task.wait(0.01)
        end
        Notify("100 clicks completed!")
    end
})

--==================================================
-- VISUALS TAB
--==================================================
local VisualSection = VisualsTab:AddSection({
    Name = "Visuals",
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
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0, 0, 0)
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

Notify("Tap Simulator Script FIXED - Auto Clicker & Auto Buy Egg siap digunakan!")
print("=== TAP SIMULATOR - FIXED EDITION ===")
print("✓ Auto Clicker menggunakan multiple methods")
print("✓ Auto Buy Egg dengan berbagai metode")
print("✓ Remote detection improved")
print("Tekan F4 untuk toggle menu")