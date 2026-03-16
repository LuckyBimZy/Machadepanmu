-- ==================== TAP SIMULATOR - CATRAZ EDITION ====================
-- Premium Auto Farm Script untuk Tap Simulator
-- Author: Adapted for Catraz Hub
-- Version: 2.0 (Enhanced Auto Clicker)

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
local TweenService = game:GetService("TweenService")

-- Auto Clicker Variables
local AutoClickerEnabled = false
local AutoClickerConnection = nil
local ClickInterval = 0.001 -- 1ms default (super fast)
local ClickCount = 0
local IsClicking = false

-- Untuk memastikan clicker tidak mengganggu mouse
local LastMousePosition = Vector2.new(0, 0)
local MouseMoved = false

-- Cari Remote Events/Functions
local RemoteEvent = nil
local Remotes = {
    Tap = nil,
    BuyEgg = nil,
    HatchEgg = nil,
    BuyArea = nil,
    Upgrade = nil,
    Collect = nil,
    Rebirth = nil
}

--==================================================
-- AUTO CLICKER FLOATING BUTTON
--==================================================

-- Buat ScreenGui untuk floating button
local ClickerGui = Instance.new("ScreenGui")
ClickerGui.Name = "TapSimClicker"
ClickerGui.Parent = CoreGui
ClickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ClickerGui.ResetOnSpawn = false

-- Floating button untuk auto clicker
local ClickerButton = Instance.new("Frame")
ClickerButton.Name = "ClickerButton"
ClickerButton.Size = UDim2.new(0, 60, 0, 60)
ClickerButton.Position = UDim2.new(0, 100, 0.5, -30)
ClickerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ClickerButton.BackgroundTransparency = 0.2
ClickerButton.BorderSizePixel = 0
ClickerButton.Active = true
ClickerButton.Draggable = true
ClickerButton.Parent = ClickerGui
ClickerButton.ClipsDescendants = true

-- Shadow
local ClickerShadow = Instance.new("Frame")
ClickerShadow.Name = "Shadow"
ClickerShadow.Size = UDim2.new(1, 8, 1, 8)
ClickerShadow.Position = UDim2.new(0, -4, 0, -4)
ClickerShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ClickerShadow.BackgroundTransparency = 0.7
ClickerShadow.BorderSizePixel = 0
ClickerShadow.Parent = ClickerButton

-- Corner
local ClickerCorner = Instance.new("UICorner")
ClickerCorner.CornerRadius = UDim.new(0, 30)
ClickerCorner.Parent = ClickerButton

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 34)
ShadowCorner.Parent = ClickerShadow

-- Icon
local ClickerIcon = Instance.new("TextLabel")
ClickerIcon.Name = "Icon"
ClickerIcon.Size = UDim2.new(1, 0, 0.7, 0)
ClickerIcon.Position = UDim2.new(0, 0, 0, 5)
ClickerIcon.BackgroundTransparency = 1
ClickerIcon.Text = "🖱️"
ClickerIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickerIcon.TextSize = 30
ClickerIcon.Font = Enum.Font.Gotham
ClickerIcon.Parent = ClickerButton

-- Status text
local ClickerStatus = Instance.new("TextLabel")
ClickerStatus.Name = "Status"
ClickerStatus.Size = UDim2.new(1, 0, 0.3, 0)
ClickerStatus.Position = UDim2.new(0, 0, 0.7, -5)
ClickerStatus.BackgroundTransparency = 1
ClickerStatus.Text = "OFF"
ClickerStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
ClickerStatus.TextSize = 12
ClickerStatus.Font = Enum.Font.GothamBold
ClickerStatus.Parent = ClickerButton

-- Click counter
local ClickCounter = Instance.new("TextLabel")
ClickCounter.Name = "Counter"
ClickCounter.Size = UDim2.new(0, 40, 0, 20)
ClickCounter.Position = UDim2.new(1, -45, 0, -25)
ClickCounter.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ClickCounter.BackgroundTransparency = 0.3
ClickCounter.Text = "0"
ClickCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickCounter.TextSize = 12
ClickCounter.Font = Enum.Font.GothamBold
ClickCounter.Parent = ClickerButton
ClickCounter.ZIndex = 5
ClickCounter.Visible = false

local CounterCorner = Instance.new("UICorner")
CounterCorner.CornerRadius = UDim.new(0, 10)
CounterCorner.Parent = ClickCounter

-- Animation on click
local ClickerGlow = Instance.new("Frame")
ClickerGlow.Name = "Glow"
ClickerGlow.Size = UDim2.new(1, 0, 1, 0)
ClickerGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ClickerGlow.BackgroundTransparency = 1
ClickerGlow.BorderSizePixel = 0
ClickerGlow.Parent = ClickerButton
ClickerGlow.ZIndex = 2

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 30)
GlowCorner.Parent = ClickerGlow

-- Tooltip saat hover
local ClickerTooltip = Instance.new("Frame")
ClickerTooltip.Name = "Tooltip"
ClickerTooltip.Size = UDim2.new(0, 120, 0, 25)
ClickerTooltip.Position = UDim2.new(1, 10, 0.5, -12.5)
ClickerTooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ClickerTooltip.BackgroundTransparency = 0.1
ClickerTooltip.BorderSizePixel = 0
ClickerTooltip.Parent = ClickerButton
ClickerTooltip.Visible = false
ClickerTooltip.ZIndex = 10

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0, 8)
TooltipCorner.Parent = ClickerTooltip

local TooltipText = Instance.new("TextLabel")
TooltipText.Size = UDim2.new(1, -10, 1, 0)
TooltipText.Position = UDim2.new(0, 5, 0, 0)
TooltipText.BackgroundTransparency = 1
TooltipText.Text = "Klik untuk ON/OFF"
TooltipText.TextColor3 = Color3.fromRGB(200, 200, 200)
TooltipText.TextSize = 12
TooltipText.Font = Enum.Font.Gotham
TooltipText.TextXAlignment = Enum.TextXAlignment.Left
TooltipText.Parent = ClickerTooltip

-- Hover effects
ClickerButton.MouseEnter:Connect(function()
    TweenService:Create(ClickerButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 65, 0, 65)}):Play()
    ClickerTooltip.Visible = true
end)

ClickerButton.MouseLeave:Connect(function()
    TweenService:Create(ClickerButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    ClickerTooltip.Visible = false
end)

-- Fungsi untuk update status auto clicker
local function UpdateClickerButton(state)
    AutoClickerEnabled = state
    
    if state then
        -- ON state
        TweenService:Create(ClickerButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}):Play()
        ClickerStatus.Text = "ON"
        ClickerStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        ClickerIcon.Text = "⚡"
        ClickCounter.Visible = true
        ClickCounter.Text = "0"
        ClickCount = 0
    else
        -- OFF state
        TweenService:Create(ClickerButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
        ClickerStatus.Text = "OFF"
        ClickerStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        ClickerIcon.Text = "🖱️"
        ClickCounter.Visible = false
    end
end

-- Animasi klik
local function PlayClickAnimation()
    -- Glow effect
    ClickerGlow.BackgroundTransparency = 0.7
    TweenService:Create(ClickerGlow, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
    
    -- Scale effect
    TweenService:Create(ClickerButton, TweenInfo.new(0.05), {Size = UDim2.new(0, 55, 0, 55)}):Play()
    task.wait(0.05)
    TweenService:Create(ClickerButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    
    -- Update counter
    ClickCount = ClickCount + 1
    ClickCounter.Text = formatNumber(ClickCount)
end

-- Click handler
ClickerButton.MouseButton1Click:Connect(function()
    PlayClickAnimation()
    
    if AutoClickerEnabled then
        StopAutoClicker()
        UpdateClickerButton(false)
        Notify("Auto Clicker OFF")
    else
        StartAutoClicker()
        UpdateClickerButton(true)
        Notify("Auto Clicker ON")
    end
end)

--==================================================
-- AUTO CLICKER CORE (BACKGROUND CLICKER)
--==================================================

-- Fungsi untuk melakukan click di background (tidak mengganggu mouse)
local function PerformBackgroundClick()
    -- Method 1: Menggunakan VirtualInputManager (paling aman)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(
            0, 0, -- Posisi 0,0 (tidak mengganggu mouse)
            0, -- Left button
            true, -- Down
            game, 1
        )
        task.wait(0.0001)
        VirtualInputManager:SendMouseButtonEvent(
            0, 0,
            0,
            false, -- Up
            game, 1
        )
    end)
    
    -- Method 2: Fire remote tap sebagai backup
    if Remotes.Tap then
        pcall(function()
            if Remotes.Tap:IsA("RemoteEvent") then
                Remotes.Tap:FireServer()
            elseif Remotes.Tap:IsA("RemoteFunction") then
                Remotes.Tap:InvokeServer()
            end
        end)
    else
        -- Fallback: Cari remote event lain
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and not v.Name:find("Character") then
                pcall(function() v:FireServer() end)
                break
            end
        end
    end
    
    -- Update counter di UI
    ClickCount = ClickCount + 1
    ClickCounter.Text = formatNumber(ClickCount)
end

-- Start auto clicker (background)
function StartAutoClicker()
    if AutoClickerConnection then
        AutoClickerConnection:Disconnect()
        AutoClickerConnection = nil
    end
    
    IsClicking = true
    ClickCount = 0
    ClickCounter.Text = "0"
    
    -- Gunakan RunService.Heartbeat untuk click loop yang sangat cepat
    AutoClickerConnection = RunService.Heartbeat:Connect(function()
        if AutoClickerEnabled and IsClicking then
            PerformBackgroundClick()
            task.wait(ClickInterval)
        end
    end)
    
    -- Backup dengan spawn thread untuk redundancy
    task.spawn(function()
        while AutoClickerEnabled do
            if IsClicking then
                PerformBackgroundClick()
            end
            task.wait(ClickInterval)
        end
    end)
end

function StopAutoClicker()
    AutoClickerEnabled = false
    IsClicking = false
    if AutoClickerConnection then
        AutoClickerConnection:Disconnect()
        AutoClickerConnection = nil
    end
end

--==================================================
-- AUTO BUY EGG ENHANCED
--==================================================

-- Fungsi untuk auto buy egg yang lebih cerdas
local function SmartBuyEgg()
    if not Remotes.BuyEgg then
        -- Coba cari remote yang tepat
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("buy") and v.Name:lower():find("egg")) then
                Remotes.BuyEgg = v
                break
            end
        end
    end
    
    if Remotes.BuyEgg then
        -- Coba beli egg dengan berbagai parameter
        local eggTypes = {"Basic", "Common", "Rare", "Epic", "Legendary", "Mythic"}
        local eggIndex = 1
        
        -- Tentukan egg type berdasarkan setting
        if Toggles.EggType == "Basic" then eggIndex = 1
        elseif Toggles.EggType == "Rare" then eggIndex = 3
        elseif Toggles.EggType == "Epic" then eggIndex = 4
        elseif Toggles.EggType == "Legendary" then eggIndex = 5
        elseif Toggles.EggType == "Mythic" then eggIndex = 6
        end
        
        -- Coba berbagai format parameter
        local success = pcall(function()
            -- Format 1: String
            Remotes.BuyEgg:FireServer(eggTypes[eggIndex])
        end)
        
        if not success then
            pcall(function()
                -- Format 2: Number
                Remotes.BuyEgg:FireServer(eggIndex)
            end)
        end
        
        -- Update counter
        if AutoBuyEggCount then
            AutoBuyEggCount = AutoBuyEggCount + 1
        end
    end
end

--==================================================
-- FUNGSI LAINNYA (SAMA DENGAN SEBELUMNYA)
--==================================================

-- Fungsi untuk mencari remotes
local function FindRemotes()
    -- Cari di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("tap") or name:find("click") then
                Remotes.Tap = v
            elseif (name:find("egg") and name:find("buy")) or name:find("purchaseegg") then
                Remotes.BuyEgg = v
            elseif name:find("hatch") or name:find("openegg") then
                Remotes.HatchEgg = v
            elseif name:find("upgrade") or name:find("power") then
                Remotes.Upgrade = v
            elseif name:find("collect") or name:find("claim") then
                Remotes.Collect = v
            elseif name:find("rebirth") or name:find("prestige") then
                Remotes.Rebirth = v
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

-- Counter untuk auto buy egg
local AutoBuyEggCount = 0

-- Loops
local Loops = {}

-- Format number
local function formatNumber(num)
    if num >= 1e9 then
        return string.format("%.1fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
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
    Subtext = "Auto Farm Premium",
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

Notify("Script loaded successfully! Click the floating mouse button for auto clicker")

--==================================================
-- CREATE TABS (SAMA DENGAN SEBELUMNYA)
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
-- MAIN TAB CONTENT
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
                local rebirths = GetRebirths()
                StatsPara:SetDesc("Coins: " .. formatNumber(coins) .. "\nRebirths: " .. rebirths .. "\nClicks: " .. formatNumber(ClickCount))
            end
        }
    }
})

-- Update stats setiap 5 detik
task.spawn(function()
    while true do
        local coins = GetCoins()
        local rebirths = GetRebirths()
        StatsPara:SetDesc("Coins: " .. formatNumber(coins) .. "\nRebirths: " .. rebirths .. "\nClicks: " .. formatNumber(ClickCount))
        task.wait(5)
    end
end)

--==================================================
-- AUTO FARM TAB (DENGAN AUTO CLICKER SETTINGS)
--==================================================
local TapSection = FarmTab:AddSection({
    Name = "Auto Clicker Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

TapSection:AddParagraph({
    Title = "Auto Clicker Status",
    Desc = "Klik tombol mouse 🖱️ di layar untuk ON/OFF\nBerjalan di BACKGROUND - tidak ganggu mouse",
    Image = "info",
    ImageSize = 38
})

TapSection:AddSlider({
    Name = "Click Speed (ms)",
    Min = 0.0001,
    Max = 0.01,
    Default = 0.001,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.0001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        ClickInterval = Value
    end
})

TapSection:AddButton({
    Name = "Test Click (10x)",
    Icon = "hand",
    Outline = true,
    Callback = function()
        for i = 1, 10 do
            PerformBackgroundClick()
            task.wait(0.05)
        end
        Notify("Test clicked 10 times!")
    end
})

local TapSection2 = FarmTab:AddSection({
    Name = "Auto Tap (Remote)",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

TapSection2:AddToggle({
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

TapSection2:AddSlider({
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
-- EGGS TAB (DENGAN AUTO BUY EGG ENHANCED)
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
            Notify("Auto Buy Egg ON - Smart buying enabled")
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
    Name = "Buy Egg Now",
    Icon = "shopping-cart",
    Outline = true,
    Callback = function()
        SmartBuyEgg()
        Notify("Buying egg...")
    end
})

--==================================================
-- FUNGSI UTILITY
--==================================================

-- Get coins/points
local function GetCoins()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash") or v.Name:lower():find("point")) then
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
            if v:IsA("NumberValue") and (v.Name:lower():find("rebirth") or v.Name:lower():find("prestige")) then
                return v.Value
            end
        end
    end
    return 0
end

-- Hatch egg function
local function HatchEgg()
    if Remotes.HatchEgg then
        pcall(function() Remotes.HatchEgg:FireServer() end)
    end
end

-- Upgrade function
local function Upgrade(upgradeType)
    if Remotes.Upgrade then
        pcall(function() Remotes.Upgrade:FireServer(upgradeType) end)
    end
end

-- Buy area function
local function BuyArea()
    if Remotes.BuyArea then
        pcall(function() Remotes.BuyArea:FireServer() end)
    end
end

-- Collect rewards
local function Collect()
    if Remotes.Collect then
        pcall(function() Remotes.Collect:FireServer() end)
    end
end

-- Rebirth function
local function Rebirth()
    if Remotes.Rebirth then
        pcall(function() Remotes.Rebirth:FireServer() end)
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
                if Remotes.Tap then
                    pcall(function() Remotes.Tap:FireServer() end)
                end
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                SmartBuyEgg()
                task.wait(1)
                
            elseif name == "AutoHatch" and Toggles.AutoHatch then
                HatchEgg()
                task.wait(0.5)
                
            elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                Upgrade(Toggles.UpgradeType)
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
end

--==================================================
-- SISANYA (UPGRADE TAB, VISUALS TAB, MISC TAB)
-- (Sama seperti sebelumnya, tidak diubah)
--==================================================

-- Upgrade Tab
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
    Options = {"All", "Damage", "Speed", "Multiplier", "Critical"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.UpgradeType = Value
    end
})

local AreaSection = UpgradeTab:AddSection({
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

-- Visuals Tab
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

-- Misc Tab
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
                    return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")))
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
})

MiscSection:AddButton({
    Name = "Close GUI",
    Icon = "x",
    Outline = true,
    Callback = function()
        OrionLib:Destroy()
        ClickerGui:Destroy()
        _G.TapSimLoaded = false
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

-- Config Tab
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("=== Tap Simulator - Catraz Edition v2.0 ===")
print("✅ Auto Clicker: Background clicker with floating button")
print("✅ Auto Buy Egg: Smart buying with multiple formats")
print("✅ All features ready!")