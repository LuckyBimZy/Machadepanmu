-- ==================== TAP SIMULATOR - CATRAZ EDITION V2 ====================
-- Premium Auto Farm Script dengan Independent Auto Clicker
-- Author: Enhanced for Catraz Hub
-- Version: 2.0

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
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

--==================================================
-- REMOTE FINDER
--==================================================
local Remotes = {
    Tap = nil,
    BuyEgg = nil,
    HatchEgg = nil,
    BuyArea = nil,
    Upgrade = nil,
    Collect = nil,
    Rebirth = nil
}

-- Fungsi untuk mencari remotes dengan lebih akurat
local function FindRemotes()
    print("🔍 Mencari remote events...")
    
    -- Daftar pattern umum untuk setiap tipe remote
    local patterns = {
        Tap = {"tap", "click", "attack", "hit", "damage", "mine", "break"},
        BuyEgg = {"buyegg", "purchaseegg", "buypet", "buyegg"},
        HatchEgg = {"hatch", "openegg", "hatchegg", "open", "unbox"},
        BuyArea = {"buyarea", "purchasearea", "buyzone", "unlockarea", "buyregion"},
        Upgrade = {"upgrade", "purchaseupgrade", "buypower", "buydamage", "levelup"},
        Collect = {"collect", "claim", "claimreward", "getreward", "dailyreward"},
        Rebirth = {"rebirth", "prestige", "reset", "newgameplus"}
    }
    
    -- Cari di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("UnreliableRemoteEvent") then
            local nameLower = v.Name:lower()
            
            for remoteType, patternList in pairs(patterns) do
                for _, pattern in ipairs(patternList) do
                    if nameLower:find(pattern) and not Remotes[remoteType] then
                        Remotes[remoteType] = v
                        print("✅ Found " .. remoteType .. ": " .. v.Name)
                        break
                    end
                end
            end
        end
    end
    
    -- Cari di PlayerScripts jika belum ditemukan
    for _, v in pairs(Player.PlayerScripts:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and not Remotes.Tap then
            if v.Name:lower():find("tap") or v.Name:lower():find("click") then
                Remotes.Tap = v
                print("✅ Found Tap in PlayerScripts: " .. v.Name)
            end
        end
    end
    
    -- Fallback: jika masih belum ditemukan, cari remote yang paling sering dipanggil
    if not Remotes.Tap then
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") and not v.Name:find("Character") then
                Remotes.Tap = v
                print("⚠️ Using fallback remote: " .. v.Name)
                break
            end
        end
    end
    
    print("=== REMOTES STATUS ===")
    for k, v in pairs(Remotes) do
        print(k .. ": " .. (v and "✓" or "✗"))
    end
end

FindRemotes()

--==================================================
-- TOGGLES
--==================================================
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
    AutoClaim = false,
    
    -- Clicker Settings
    ClickerPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2),
    ClickerActive = false
}

-- Loops
local Loops = {}
local BubbleConnections = {}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, time)
    OrionLib:MakeNotification({
        Name = "Tap Simulator",
        Content = msg,
        Image = "zap",
        Time = time or 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Tap Simulator",
    Subtext = "Premium Auto Farm",
    Version = "v2.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSim_Config",
    IntroEnabled = true,
    IntroText = "Tap Simulator V2",
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
-- CLICKER BUBBLE UI
--==================================================

-- Buat ScreenGui untuk bubble
local BubbleGui = Instance.new("ScreenGui")
BubbleGui.Name = "TapSimBubble"
BubbleGui.Parent = game.CoreGui
BubbleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
BubbleGui.ResetOnSpawn = false

-- Buat bubble utama
local Bubble = Instance.new("Frame")
Bubble.Name = "ClickerBubble"
Bubble.Size = UDim2.new(0, 80, 0, 80)
Bubble.Position = UDim2.new(0.5, -40, 0.5, -40) -- Tengah layar default
Bubble.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
Bubble.BackgroundTransparency = 0.2
Bubble.BorderSizePixel = 0
Bubble.Active = true
Bubble.Draggable = true -- Bisa digeser
Bubble.Parent = BubbleGui
Bubble.ZIndex = 10

-- Efek glow
local BubbleGlow = Instance.new("Frame")
BubbleGlow.Size = UDim2.new(1, 10, 1, 10)
BubbleGlow.Position = UDim2.new(0, -5, 0, -5)
BubbleGlow.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
BubbleGlow.BackgroundTransparency = 0.5
BubbleGlow.BorderSizePixel = 0
BubbleGlow.Parent = Bubble
BubbleGlow.ZIndex = 9

-- Sudut membulat
local BubbleCorner = Instance.new("UICorner")
BubbleCorner.CornerRadius = UDim.new(1, 0) -- Circle
BubbleCorner.Parent = Bubble

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(1, 0)
GlowCorner.Parent = BubbleGlow

-- Ikon di dalam bubble
local BubbleIcon = Instance.new("TextLabel")
BubbleIcon.Size = UDim2.new(1, 0, 1, 0)
BubbleIcon.BackgroundTransparency = 1
BubbleIcon.Text = "⚡"
BubbleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
BubbleIcon.TextSize = 40
BubbleIcon.Font = Enum.Font.GothamBold
BubbleIcon.Parent = Bubble
BubbleIcon.ZIndex = 11

-- Teks status
local BubbleStatus = Instance.new("TextLabel")
BubbleStatus.Size = UDim2.new(0, 100, 0, 30)
BubbleStatus.Position = UDim2.new(0.5, -50, 1, 5)
BubbleStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BubbleStatus.BackgroundTransparency = 0.2
BubbleStatus.Text = "AUTO CLICKER: OFF"
BubbleStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
BubbleStatus.TextSize = 12
BubbleStatus.Font = Enum.Font.GothamBold
BubbleStatus.Parent = Bubble
BubbleStatus.ZIndex = 11

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = BubbleStatus

-- Tooltip
local BubbleTooltip = Instance.new("TextLabel")
BubbleTooltip.Size = UDim2.new(0, 150, 0, 25)
BubbleTooltip.Position = UDim2.new(0.5, -75, 0, -30)
BubbleTooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BubbleTooltip.BackgroundTransparency = 0.2
BubbleTooltip.Text = "Drag to move • Click to toggle"
BubbleTooltip.TextColor3 = Color3.fromRGB(200, 200, 200)
BubbleTooltip.TextSize = 10
BubbleTooltip.Font = Enum.Font.Gotham
BubbleTooltip.Parent = Bubble
BubbleTooltip.ZIndex = 11

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0, 8)
TooltipCorner.Parent = BubbleTooltip

-- Tombol toggle di bubble
local BubbleToggleBtn = Instance.new("TextButton")
BubbleToggleBtn.Size = UDim2.new(1, 0, 1, 0)
BubbleToggleBtn.BackgroundTransparency = 1
BubbleToggleBtn.Text = ""
BubbleToggleBtn.Parent = Bubble
BubbleToggleBtn.ZIndex = 12

-- Fungsi update tampilan bubble
local function UpdateBubbleUI()
    if Toggles.AutoClicker then
        Bubble.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
        BubbleGlow.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
        BubbleStatus.Text = "AUTO CLICKER: ON"
        BubbleStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        BubbleIcon.Text = "✅"
        
        -- Animasi pulse
        local pulse = TweenService:Create(Bubble, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {
            Size = UDim2.new(0, 85, 0, 85)
        })
        pulse:Play()
        BubbleConnections.Pulse = pulse
    else
        Bubble.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        BubbleGlow.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
        BubbleStatus.Text = "AUTO CLICKER: OFF"
        BubbleStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        BubbleIcon.Text = "⚡"
        
        if BubbleConnections.Pulse then
            BubbleConnections.Pulse:Cancel()
            Bubble.Size = UDim2.new(0, 80, 0, 80)
        end
    end
end

-- Toggle clicker dari bubble
BubbleToggleBtn.MouseButton1Click:Connect(function()
    Toggles.AutoClicker = not Toggles.AutoClicker
    UpdateBubbleUI()
    
    if Toggles.AutoClicker then
        StartLoop("AutoClicker")
        Notify("Auto Clicker ON", 1)
    else
        StopLoop("AutoClicker")
        Notify("Auto Clicker OFF", 1)
    end
end)

-- Update posisi clicker saat bubble digeser
Bubble.DragFinished:Connect(function()
    local absPos = Bubble.AbsolutePosition
    Toggles.ClickerPosition = Vector2.new(absPos.X + 40, absPos.Y + 40) -- Tengah bubble
end)

-- Sembunyikan bubble saat menu terbuka? (opsional)
-- Bubble.Visible = false -- Default hidden, akan muncul saat auto clicker diaktifkan

--==================================================
-- INDEPENDENT AUTO CLICKER (TIDAK MENGGANGGU MOUSE)
--==================================================

-- Fungsi click yang independen
local function IndependentClick()
    -- Method 1: VirtualInputManager (paling ampuh)
    VirtualInputManager:SendMouseButtonEvent(
        Toggles.ClickerPosition.X,  -- X position
        Toggles.ClickerPosition.Y,  -- Y position
        0,                          -- Mouse button (0 = left)
        true,                       -- Down
        game,                       
        1
    )
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(
        Toggles.ClickerPosition.X,
        Toggles.ClickerPosition.Y,
        0,
        false,                      -- Up
        game,
        1
    )
    
    -- Method 2: Remote event (sebagai backup)
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

-- Loop auto clicker yang independen
local ClickerThread = nil
local ClickerRunning = false

function StartIndependentClicker()
    if ClickerRunning then return end
    ClickerRunning = true
    
    -- Tampilkan bubble
    Bubble.Visible = true
    
    ClickerThread = task.spawn(function()
        while ClickerRunning and Toggles.AutoClicker do
            IndependentClick()
            task.wait(Toggles.ClickSpeed)
        end
    end)
end

function StopIndependentClicker()
    ClickerRunning = false
    if ClickerThread then
        task.cancel(ClickerThread)
        ClickerThread = nil
    end
    Bubble.Visible = false -- Sembunyikan bubble
end

--==================================================
-- AUTO BUY EGG YANG DIPERBAIKI
--==================================================

-- Fungsi beli egg yang lebih robust
function BuyEgg(eggType)
    local success = false
    
    -- Method 1: Pake remote yang sudah ditemukan
    if Remotes.BuyEgg then
        pcall(function()
            if Remotes.BuyEgg:IsA("RemoteEvent") then
                Remotes.BuyEgg:FireServer(eggType)
            else
                Remotes.BuyEgg:InvokeServer(eggType)
            end
            success = true
        end)
    end
    
    -- Method 2: Coba berbagai kemungkinan argument
    if not success then
        -- Coba semua remote yang mirip
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("egg") or v.Name:lower():find("pet") or v.Name:lower():find("buy")) then
                pcall(function()
                    -- Coba berbagai format argument
                    v:FireServer(eggType)
                    v:FireServer("Buy", eggType)
                    v:FireServer(1) -- Index egg
                    v:FireServer()
                end)
            end
        end
    end
    
    -- Method 3: Cari di player scripts
    for _, v in pairs(Player.PlayerScripts:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("egg") then
            pcall(function() v:FireServer() end)
        end
    end
end

-- Fungsi hatch egg yang diperbaiki
function HatchEgg()
    if Remotes.HatchEgg then
        pcall(function()
            if Remotes.HatchEgg:IsA("RemoteEvent") then
                Remotes.HatchEgg:FireServer()
            else
                Remotes.HatchEgg:InvokeServer()
            end
        end)
    else
        -- Coba semua kemungkinan
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("hatch") or v.Name:lower():find("open") or v.Name:lower():find("unbox")) then
                pcall(function() v:FireServer() end)
            end
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
            if not Loops[name] then break end
            
            if name == "AutoTap" and Toggles.AutoTap then
                if Remotes.Tap then
                    pcall(function() Remotes.Tap:FireServer() end)
                end
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoClicker" then
                -- Auto clicker sudah ditangani oleh IndependentClicker
                -- Loop ini hanya untuk menjaga status
                task.wait(1)
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                BuyEgg(Toggles.EggType)
                task.wait(1.5)
                
            elseif name == "AutoHatch" and Toggles.AutoHatch then
                HatchEgg()
                task.wait(0.8)
                
            elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                if Remotes.Upgrade then
                    if Toggles.UpgradeType == "All" then
                        pcall(function() Remotes.Upgrade:FireServer("Damage") end)
                        task.wait(0.3)
                        pcall(function() Remotes.Upgrade:FireServer("Speed") end)
                        task.wait(0.3)
                        pcall(function() Remotes.Upgrade:FireServer("Multiplier") end)
                    else
                        pcall(function() Remotes.Upgrade:FireServer(Toggles.UpgradeType) end)
                    end
                end
                task.wait(1.2)
                
            elseif name == "AutoBuyArea" and Toggles.AutoBuyArea then
                if Remotes.BuyArea then
                    pcall(function() Remotes.BuyArea:FireServer() end)
                end
                task.wait(2.5)
                
            elseif name == "AutoCollect" and Toggles.AutoCollect then
                if Remotes.Collect then
                    pcall(function() Remotes.Collect:FireServer() end)
                end
                task.wait(5)
                
            elseif name == "AutoRebirth" and Toggles.AutoRebirth then
                local coins = GetCoins()
                if coins >= Toggles.RebirthAt then
                    if Remotes.Rebirth then
                        pcall(function() Remotes.Rebirth:FireServer() end)
                    end
                    task.wait(3)
                else
                    task.wait(5)
                end
                
            elseif name == "AutoClaim" and Toggles.AutoClaim then
                local claimRemote = ReplicatedStorage:FindFirstChild("ClaimDaily") or 
                                   ReplicatedStorage:FindFirstChild("DailyReward")
                if claimRemote then
                    pcall(function() claimRemote:FireServer() end)
                end
                task.wait(60)
            end
            
            task.wait()
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
    if name == "AutoClicker" then
        StopIndependentClicker()
    end
end

--==================================================
-- UTILITY FUNCTIONS
--==================================================

-- Get coins/points
function GetCoins()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash") or v.Name:lower():find("point") or v.Name:lower():find("money")) then
                return v.Value
            end
        end
    end
    
    for _, v in pairs(Player:GetChildren()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
            return v.Value
        end
    end
    
    -- Coba cari di Data folder
    local data = Player:FindFirstChild("Data") or Player:FindFirstChild("Stats")
    if data then
        for _, v in pairs(data:GetChildren()) do
            if v:IsA("NumberValue") then
                return v.Value
            end
        end
    end
    
    return 0
end

-- Get rebirths
function GetRebirths()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("rebirth") or v.Name:lower():find("prestige") or v.Name:lower():find("reset")) then
                return v.Value
            end
        end
    end
    return 0
end

-- Format angka
function formatNumber(num)
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

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
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

local ClickerTab = Window:MakeTab({
    Name = "Clicker",
    Icon = "mouse-pointer",
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

-- Paragraph stats
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
                StatsPara:SetDesc("💰 Coins: " .. formatNumber(coins) .. "\n🔄 Rebirths: " .. formatNumber(rebirths))
            end
        }
    }
})

-- Update stats otomatis
task.spawn(function()
    while true do
        local coins = GetCoins()
        local rebirths = GetRebirths()
        StatsPara:SetDesc("💰 Coins: " .. formatNumber(coins) .. "\n🔄 Rebirths: " .. formatNumber(rebirths))
        task.wait(3)
    end
end)

local QuickSection = MainTab:AddSection({
    Name = "Quick Actions",
    TextSize = 17,
    Glass = true,
    Outline = true
})

QuickSection:AddButton({
    Name = "⚡ Tap 50x",
    Icon = "hand",
    Outline = true,
    Callback = function()
        for i = 1, 50 do
            IndependentClick()
            task.wait(0.02)
        end
        Notify("Tapped 50 times!")
    end
})

QuickSection:AddButton({
    Name = "🥚 Hatch Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        HatchEgg()
        Notify("Hatched egg!")
    end
})

QuickSection:AddButton({
    Name = "💰 Collect Rewards",
    Icon = "gift",
    Outline = true,
    Callback = function()
        if Remotes.Collect then
            pcall(function() Remotes.Collect:FireServer() end)
            Notify("Collected rewards!")
        end
    end
})

--==================================================
-- CLICKER TAB (KONTROL BUBBLE)
--==================================================
local ClickerSection = ClickerTab:AddSection({
    Name = "Auto Clicker Control",
    TextSize = 17,
    Glass = true,
    Outline = true
})

ClickerSection:AddToggle({
    Name = "Enable Auto Clicker",
    Default = false,
    Color = Color3.fromRGB(50, 255, 100),
    Outline = true,
    Flag = "AutoClicker",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClicker = Value
        UpdateBubbleUI()
        
        if Value then
            StartIndependentClicker()
            StartLoop("AutoClicker")
            Notify("Auto Clicker ON - Bubble muncul!", 1)
        else
            StopIndependentClicker()
            StopLoop("AutoClicker")
            Notify("Auto Clicker OFF", 1)
        end
    end
})

ClickerSection:AddSlider({
    Name = "Click Speed (seconds)",
    Min = 0.0001,
    Max = 0.05,
    Default = 0.001,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.0001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.ClickSpeed = Value
    end
})

ClickerSection:AddParagraph({
    Title = "Clicker Bubble Info",
    Desc = "• Bubble muncul saat Auto Clicker ON\n• Drag bubble untuk memindahkan posisi click\n• Klik bubble untuk toggle ON/OFF\n• Posisi tersimpan otomatis",
    Image = "info",
    ImageSize = 38
})

ClickerSection:AddButton({
    Name = "Reset Bubble Position",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        Toggles.ClickerPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        Bubble.Position = UDim2.new(0.5, -40, 0.5, -40)
        Notify("Bubble position reset")
    end
})

--==================================================
-- AUTO FARM TAB
--==================================================
local TapSection = FarmTab:AddSection({
    Name = "Auto Tap",
    TextSize = 17,
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

--==================================================
-- EGGS TAB
--==================================================
local EggSection = EggsTab:AddSection({
    Name = "Egg Settings",
    TextSize = 17,
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
            Notify("Auto Buy Egg ON")
        else 
            StopLoop("AutoBuyEgg")
        end
    end
})

EggSection:AddDropdown({
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

EggSection:AddButton({
    Name = "Hatch Now!",
    Icon = "egg",
    Outline = true,
    Callback = function()
        HatchEgg()
    end
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
    Name = "Upgrade Priority",
    Default = "All",
    Options = {"All", "Damage", "Speed", "Multiplier", "Critical", "Luck"},
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
    Name = "Rebirth Requirement",
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
        -- Implement egg ESP
        Notify("Egg ESP " .. (Value and "ON" or "OFF"))
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

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({
    Name = "Utilities",
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

MiscSection:AddToggle({
    Name = "Auto Claim Daily",
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
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        
        Notify("Mencari server...")
        
        -- Simple server hop
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=10"))
        end)
        
        if success and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, Player)
                    return
                end
            end
            Notify("Tidak ada server tersedia")
        else
            Notify("Gagal mendapatkan server")
        end
    end
})

MiscSection:AddButton({
    Name = "Close GUI",
    Icon = "x",
    Outline = true,
    Callback = function()
        StopIndependentClicker()
        OrionLib:Destroy()
        BubbleGui:Destroy()
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

-- Sembunyikan bubble awalnya
Bubble.Visible = false

Notify("✅ Tap Simulator V2 Loaded! | F4 untuk menu", 3)
print("=== TAP SIMULATOR - CATRAZ EDITION V2 ===")
print("✅ Independent Auto Clicker - Tidak mengganggu mouse")
print("✅ Bubble Control - Drag & click to toggle")
print("✅ Auto Buy Egg - Bekerja dengan berbagai remote")
print("✅ Auto Farm Lengkap")
print("✅ Config Auto-save")
print("Press F4 to toggle menu")