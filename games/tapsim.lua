-- ==================== TAP SIMULATOR - CATRAZ EDITION v2 ====================
-- Premium Auto Farm Script untuk Tap Simulator
-- Fitur: Auto Clicker Independent + Bubble Control
-- Author: Adapted for Catraz Hub
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
local TweenService = game:GetService("TweenService")

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
-- AUTO CLICKER VARIABLES
--==================================================
local AutoClicker = {
    Enabled = false,
    Speed = 0.001,
    Connection = nil,
    CPS = 1000, -- Calculated from speed
    VirtualClick = true, -- Use VirtualInputManager instead of mouse1click
    ClickThread = nil
}

-- Bubble UI untuk Auto Clicker
local BubbleUI = {
    ScreenGui = nil,
    Frame = nil,
    ToggleBtn = nil,
    StatusText = nil,
    CPSLabel = nil,
    Dragging = false,
    DragOffset = nil
}

--==================================================
-- FUNGSI UNTUK MEMBUAT BUBBLE UI
--==================================================
local function CreateBubbleUI()
    -- Hapus bubble lama jika ada
    local oldGui = game.CoreGui:FindFirstChild("TapSimBubble")
    if oldGui then oldGui:Destroy() end
    
    -- Buat ScreenGui
    BubbleUI.ScreenGui = Instance.new("ScreenGui")
    BubbleUI.ScreenGui.Name = "TapSimBubble"
    BubbleUI.ScreenGui.Parent = game.CoreGui
    BubbleUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    BubbleUI.ScreenGui.ResetOnSpawn = false
    
    -- Frame utama dengan glass morphism effect
    BubbleUI.Frame = Instance.new("Frame")
    BubbleUI.Frame.Name = "MainFrame"
    BubbleUI.Frame.Size = UDim2.new(0, 200, 0, 80)
    BubbleUI.Frame.Position = UDim2.new(0, 20, 0.8, -40) -- Posisi default di kiri bawah
    BubbleUI.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    BubbleUI.Frame.BackgroundTransparency = 0.2
    BubbleUI.Frame.BorderSizePixel = 0
    BubbleUI.Frame.Active = true
    BubbleUI.Frame.Draggable = true
    BubbleUI.Frame.Parent = BubbleUI.ScreenGui
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = BubbleUI.Frame
    
    -- Stroke/border
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(0, 255, 100)
    UIStroke.Transparency = 0.5
    UIStroke.Parent = BubbleUI.Frame
    
    -- Gradient background
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 40, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 25))
    })
    UIGradient.Rotation = 90
    UIGradient.Parent = BubbleUI.Frame
    
    -- Shadow
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.6
    Shadow.BorderSizePixel = 0
    Shadow.Parent = BubbleUI.Frame
    Shadow.ZIndex = -1
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 16)
    ShadowCorner.Parent = Shadow
    
    -- Icon (Auto Clicker icon)
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 10, 0.5, -20)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://3926305904" -- Mouse icon
    Icon.ImageColor3 = Color3.fromRGB(0, 255, 100)
    Icon.Parent = BubbleUI.Frame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 100, 0, 20)
    Title.Position = UDim2.new(0, 55, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "Auto Clicker"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = BubbleUI.Frame
    
    -- Status text (ON/OFF)
    BubbleUI.StatusText = Instance.new("TextLabel")
    BubbleUI.StatusText.Size = UDim2.new(0, 50, 0, 20)
    BubbleUI.StatusText.Position = UDim2.new(0, 55, 0, 30)
    BubbleUI.StatusText.BackgroundTransparency = 1
    BubbleUI.StatusText.Text = "OFF"
    BubbleUI.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    BubbleUI.StatusText.TextSize = 12
    BubbleUI.StatusText.Font = Enum.Font.GothamBold
    BubbleUI.StatusText.TextXAlignment = Enum.TextXAlignment.Left
    BubbleUI.StatusText.Parent = BubbleUI.Frame
    
    -- CPS Label
    BubbleUI.CPSLabel = Instance.new("TextLabel")
    BubbleUI.CPSLabel.Size = UDim2.new(0, 80, 0, 20)
    BubbleUI.CPSLabel.Position = UDim2.new(0, 55, 0, 50)
    BubbleUI.CPSLabel.BackgroundTransparency = 1
    BubbleUI.CPSLabel.Text = "0 CPS"
    BubbleUI.CPSLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    BubbleUI.CPSLabel.TextSize = 10
    BubbleUI.CPSLabel.Font = Enum.Font.Gotham
    BubbleUI.CPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    BubbleUI.CPSLabel.Parent = BubbleUI.Frame
    
    -- Toggle Button (besar)
    BubbleUI.ToggleBtn = Instance.new("TextButton")
    BubbleUI.ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    BubbleUI.ToggleBtn.Position = UDim2.new(1, -60, 0.5, -25)
    BubbleUI.ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    BubbleUI.ToggleBtn.Text = "OFF"
    BubbleUI.ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    BubbleUI.ToggleBtn.TextSize = 12
    BubbleUI.ToggleBtn.Font = Enum.Font.GothamBold
    BubbleUI.ToggleBtn.BorderSizePixel = 0
    BubbleUI.ToggleBtn.Parent = BubbleUI.Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0) -- Circular
    BtnCorner.Parent = BubbleUI.ToggleBtn
    
    -- Close button (small)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -25, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = BubbleUI.Frame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseBtn
    
    -- Make frame draggable (custom drag handling)
    local dragToggle = nil
    local dragSpeed = 0.25
    local dragStart = nil
    local startPos = nil
    
    BubbleUI.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = BubbleUI.Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    BubbleUI.Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                local delta = input.Position - dragStart
                local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                TweenService:Create(BubbleUI.Frame, TweenInfo.new(dragSpeed), {Position = newPos}):Play()
            end
        end
    end)
    
    -- Button functions
    BubbleUI.ToggleBtn.MouseButton1Click:Connect(function()
        Toggles.AutoClicker = not Toggles.AutoClicker
        UpdateAutoClicker(Toggles.AutoClicker)
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        BubbleUI.ScreenGui:Destroy()
        BubbleUI.Frame = nil
    end)
    
    -- Hover effects
    BubbleUI.ToggleBtn.MouseEnter:Connect(function()
        TweenService:Create(BubbleUI.ToggleBtn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 55, 0, 55),
            Position = UDim2.new(1, -62, 0.5, -27.5)
        }):Play()
    end)
    
    BubbleUI.ToggleBtn.MouseLeave:Connect(function()
        TweenService:Create(BubbleUI.ToggleBtn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(1, -60, 0.5, -25)
        }):Play()
    end)
    
    return BubbleUI
end

--==================================================
-- UPDATE BUBBLE UI STATUS
--==================================================
local function UpdateBubbleUI()
    if not BubbleUI.Frame then return end
    
    if AutoClicker.Enabled then
        BubbleUI.ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        BubbleUI.ToggleBtn.Text = "ON"
        BubbleUI.ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BubbleUI.StatusText.Text = "ON"
        BubbleUI.StatusText.TextColor3 = Color3.fromRGB(0, 255, 100)
        
        -- Animate border
        local UIStroke = BubbleUI.Frame:FindFirstChildOfClass("UIStroke")
        if UIStroke then
            UIStroke.Color = Color3.fromRGB(0, 255, 100)
            UIStroke.Transparency = 0
        end
    else
        BubbleUI.ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        BubbleUI.ToggleBtn.Text = "OFF"
        BubbleUI.ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        BubbleUI.StatusText.Text = "OFF"
        BubbleUI.StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        local UIStroke = BubbleUI.Frame:FindFirstChildOfClass("UIStroke")
        if UIStroke then
            UIStroke.Color = Color3.fromRGB(255, 100, 100)
            UIStroke.Transparency = 0.5
        end
    end
    
    -- Update CPS display
    local cps = math.floor(1 / AutoClicker.Speed)
    BubbleUI.CPSLabel.Text = cps .. " CPS"
end

--==================================================
-- AUTO CLICKER FUNCTIONS - IMPROVED
--==================================================
local function StartAutoClicker()
    if AutoClicker.Connection then
        AutoClicker.Connection:Disconnect()
        AutoClicker.Connection = nil
    end
    
    AutoClicker.Enabled = true
    UpdateBubbleUI()
    
    -- Method 1: Menggunakan VirtualInputManager untuk klik independen
    -- Ini tidak akan mengganggu pergerakan mouse karena menggunakan input virtual
    
    -- Buat thread terpisah untuk auto clicker
    AutoClicker.ClickThread = task.spawn(function()
        local lastClick = tick()
        
        while AutoClicker.Enabled do
            local now = tick()
            local elapsed = now - lastClick
            
            -- Hitung delay berdasarkan speed
            local delay = AutoClicker.Speed
            
            if elapsed >= delay then
                -- Method 1: Virtual Input Manager (Tidak mempengaruhi mouse)
                VirtualInputManager:SendMouseButtonEvent(
                    Mouse.X, Mouse.Y,  -- Posisi mouse saat ini
                    0,                  -- Left button (0 = left, 1 = right, 2 = middle)
                    true,               -- Press
                    game, 1             -- 
                )
                
                -- Release after tiny delay
                task.wait(0.001)
                
                VirtualInputManager:SendMouseButtonEvent(
                    Mouse.X, Mouse.Y,
                    0,
                    false,              -- Release
                    game, 1
                )
                
                -- Method 2: Fire remote tap juga sebagai backup
                if Remotes.Tap then
                    pcall(function()
                        if Remotes.Tap:IsA("RemoteEvent") then
                            Remotes.Tap:FireServer()
                        elseif Remotes.Tap:IsA("RemoteFunction") then
                            Remotes.Tap:InvokeServer()
                        end
                    end)
                end
                
                lastClick = now
            end
            
            -- Wait sedikit agar tidak membebani CPU
            task.wait(0.0001)
        end
    end)
    
    -- Backup method menggunakan RunService (alternatif)
    AutoClicker.Connection = RunService.Heartbeat:Connect(function()
        if not AutoClicker.Enabled then return end
        
        -- Method tambahan: Fire remote langsung
        if Remotes.Tap then
            pcall(function()
                if Remotes.Tap:IsA("RemoteEvent") then
                    Remotes.Tap:FireServer()
                elseif Remotes.Tap:IsA("RemoteFunction") then
                    Remotes.Tap:InvokeServer()
                end
            end)
        end
    end)
end

local function StopAutoClicker()
    AutoClicker.Enabled = false
    
    -- Hentikan thread
    if AutoClicker.ClickThread then
        task.cancel(AutoClicker.ClickThread)
        AutoClicker.ClickThread = nil
    end
    
    -- Hentikan connection
    if AutoClicker.Connection then
        AutoClicker.Connection:Disconnect()
        AutoClicker.Connection = nil
    end
    
    UpdateBubbleUI()
end

local function UpdateAutoClicker(state)
    if state then
        StartAutoClicker()
    else
        StopAutoClicker()
    end
end

--==================================================
-- FUNGSI UNTUK MENCARI REMOTES
--==================================================
local function FindRemotes()
    -- Cari di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("tap") or name:find("click") then
                Remotes.Tap = v
            elseif name:find("egg") and (name:find("buy") or name:find("purchase")) then
                Remotes.BuyEgg = v
            elseif name:find("hatch") or name:find("open") then
                Remotes.HatchEgg = v
            elseif name:find("buy") and name:find("area") then
                Remotes.BuyArea = v
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
    
    -- Eggs - IMPROVED
    AutoBuyEgg = false,
    EggType = "Basic",
    EggBuyDelay = 2,
    AutoHatch = false,
    HatchDelay = 1,
    
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
    Subtext = "Auto Farm Premium v2",
    Version = "v2.0.0",
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

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded successfully!")
Notify("Auto Clicker bubble appears when enabled!")

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
        -- Fallback: Cari remote yang mungkin bekerja
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
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash") or v.Name:lower():find("point")) then
                return v.Value
            end
        end
    end
    
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

-- Buy egg function - IMPROVED dengan multiple method
local function BuyEgg(eggType)
    local success = false
    
    -- Method 1: Menggunakan remote yang sudah ditemukan
    if Remotes.BuyEgg then
        success = pcall(function() 
            Remotes.BuyEgg:FireServer(eggType) 
            return true
        end)
    end
    
    -- Method 2: Coba berbagai remote umum
    if not success then
        local possibleRemotes = {
            ReplicatedStorage:FindFirstChild("BuyEgg"),
            ReplicatedStorage:FindFirstChild("PurchaseEgg"),
            ReplicatedStorage:FindFirstChild("BuyEggs"),
            ReplicatedStorage:FindFirstChild("EggShop"),
            ReplicatedStorage:FindFirstChild("ShopEvent")
        }
        
        for _, remote in pairs(possibleRemotes) do
            if remote then
                success = pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(eggType)
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(eggType)
                    end
                    return true
                end)
                if success then break end
            end
        end
    end
    
    -- Method 3: Cari remote berdasarkan nama
    if not success then
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("egg") or v.Name:lower():find("shop")) then
                success = pcall(function() v:FireServer(eggType) end)
                if success then 
                    Remotes.BuyEgg = v -- Simpan untuk penggunaan selanjutnya
                    break 
                end
            end
        end
    end
    
    return success
end

-- Hatch egg function - IMPROVED
local function HatchEgg()
    local success = false
    
    if Remotes.HatchEgg then
        success = pcall(function() Remotes.HatchEgg:FireServer() end)
    end
    
    if not success then
        local possibleRemotes = {
            ReplicatedStorage:FindFirstChild("HatchEgg"),
            ReplicatedStorage:FindFirstChild("OpenEgg"),
            ReplicatedStorage:FindFirstChild("Hatch"),
            ReplicatedStorage:FindFirstChild("Open")
        }
        
        for _, remote in pairs(possibleRemotes) do
            if remote then
                success = pcall(function() remote:FireServer() end)
                if success then 
                    Remotes.HatchEgg = remote
                    break 
                end
            end
        end
    end
    
    return success
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
-- LOOP FUNCTIONS - IMPROVED UNTUK EGG
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if not Player.Character then
                task.wait(1)
                continue
            end
            
            if name == "AutoTap" and Toggles.AutoTap then
                Tap()
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoClicker" and Toggles.AutoClicker then
                -- Auto clicker sekarang dihandle oleh sistem terpisah
                -- Loop ini hanya untuk backup/remote tapping
                Tap()
                task.wait(0.05) -- Lebih lambat dari auto clicker utama
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                local success = BuyEgg(Toggles.EggType)
                if success then
                    print("Bought egg:", Toggles.EggType)
                end
                task.wait(Toggles.EggBuyDelay)
                
            elseif name == "AutoHatch" and Toggles.AutoHatch then
                local success = HatchEgg()
                if success then
                    print("Hatched egg")
                end
                task.wait(Toggles.HatchDelay)
                
            elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                if Toggles.UpgradeType == "All" then
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
-- AUTO FARM TAB - DENGAN AUTO CLICKER IMPROVED
--==================================================
local TapSection = FarmTab:AddSection({
    Name = "Auto Clicker (Independent)",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
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
            -- Buat bubble UI jika belum ada
            if not BubbleUI.Frame then
                CreateBubbleUI()
            end
            UpdateAutoClicker(true)
        else
            UpdateAutoClicker(false)
        end
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
        AutoClicker.Speed = Value
        AutoClicker.CPS = math.floor(1 / Value)
        
        -- Update bubble CPS jika ada
        if BubbleUI.CPSLabel then
            BubbleUI.CPSLabel.Text = AutoClicker.CPS .. " CPS"
        end
        
        -- Restart auto clicker jika sedang berjalan
        if AutoClicker.Enabled then
            StopAutoClicker()
            StartAutoClicker()
        end
    end
})

TapSection:AddParagraph({
    Title = "Info",
    Desc = "Auto Clicker berjalan independen\nTidak mengganggu pergerakan mouse\nBubble kontrol akan muncul saat diaktifkan",
    Image = "info",
    ImageSize = 32
})

local TapRemoteSection = FarmTab:AddSection({
    Name = "Auto Tap (Remote)",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

TapRemoteSection:AddToggle({
    Name = "Auto Tap (Backup)",
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

TapRemoteSection:AddSlider({
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
-- EGGS TAB - IMPROVED DENGAN FITUR LEBIH BANYAK
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
        if Value then StartLoop("AutoBuyEgg") else StopLoop("AutoBuyEgg") end
    end
})

EggSection:AddDropdown({
    Name = "Egg Type",
    Default = "Basic",
    Options = {"Basic", "Rare", "Epic", "Legendary", "Mythic", "Godly"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.EggType = Value
    end
})

EggSection:AddSlider({
    Name = "Buy Delay",
    Min = 0.5,
    Max = 5,
    Default = 2,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.EggBuyDelay = Value
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
    Min = 0.5,
    Max = 3,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.HatchDelay = Value
    end
})

EggSection:AddButton({
    Name = "Test Buy Egg",
    Icon = "test-tube",
    Outline = true,
    Callback = function()
        local success = BuyEgg(Toggles.EggType)
        if success then
            Notify("Success bought " .. Toggles.EggType .. " egg!")
        else
            Notify("Failed to buy egg. Trying to find remote...")
            FindRemotes() -- Refresh remote list
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
        if Value then StartLoop("AutoUpgrade") else StopLoop("AutoUpgrade") end
    end
})

UpgradeSection:AddDropdown({
    Name = "Upgrade Type",
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
print("=== Tap Simulator - Catraz Edition v2 Loaded ===")
print("Press F4 to toggle menu")
print("✓ Auto Clicker independen - tidak mengganggu mouse")
print("✓ Bubble UI untuk kontrol cepat")
print("✓ Auto Buy Egg dengan multiple method")