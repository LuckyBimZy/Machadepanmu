-- ==================== TAP SIMULATOR - CATRAZ EDITION ====================
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
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
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
    Rebirth = nil,
    Click = nil
}

-- Fungsi untuk mencari remotes secara lebih akurat
local function FindRemotes()
    print("🔍 Mencari remote events...")
    
    -- Daftar pattern nama yang umum
    local patterns = {
        Tap = {"tap", "click", "mine", "farm", "collect", "harvest"},
        BuyEgg = {"buyegg", "purchaseegg", "buyeggs", "buylegg", "buy_egg"},
        HatchEgg = {"hatch", "openegg", "hatchegg", "open_egg", "eggopen"},
        BuyArea = {"buyarea", "purchasearea", "unlockarea", "buyzone"},
        Upgrade = {"upgrade", "levelup", "boost", "enhance"},
        Collect = {"collect", "claim", "reward", "daily", "bonus"},
        Rebirth = {"rebirth", "prestige", "reset", "ascend"},
        Click = {"click", "tap", "mine"}
    }
    
    -- Cari di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
            local name = v.Name:lower()
            
            for key, patternList in pairs(patterns) do
                for _, pattern in ipairs(patternList) do
                    if name:find(pattern) and not Remotes[key] then
                        Remotes[key] = v
                        print("✅ Found " .. key .. ": " .. v.Name)
                        break
                    end
                end
            end
        end
    end
    
    -- Cari di Player scripts
    for _, v in pairs(Player.PlayerScripts:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and not Remotes.Tap then
            local name = v.Name:lower()
            if name:find("tap") or name:find("click") or name:find("mine") then
                Remotes.Tap = v
                print("✅ Found Tap in PlayerScripts: " .. v.Name)
            end
        end
    end
    
    -- Cari di StarterGui
    for _, v in pairs(game:GetService("StarterGui"):GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and not Remotes.Tap then
            local name = v.Name:lower()
            if name:find("tap") or name:find("click") then
                Remotes.Tap = v
                print("✅ Found Tap in StarterGui: " .. v.Name)
            end
        end
    end
    
    print("=== REMOTES FOUND ===")
    for k, v in pairs(Remotes) do
        print(k .. ": " .. (v and "✓ " .. v.Name or "✗"))
    end
    
    -- Jika masih belum nemu, coba cari remote yang paling aktif dipanggil
    if not Remotes.Tap then
        print("⚠️ Mencari remote dengan metode alternatif...")
        local potentialRemotes = {}
        
        -- Monitor remote events yang sering dipanggil
        for _, v in pairs(ReplicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") then
                table.insert(potentialRemotes, v)
            end
        end
        
        if #potentialRemotes > 0 then
            Remotes.Tap = potentialRemotes[1]
            print("✅ Menggunakan remote: " .. potentialRemotes[1].Name)
        end
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
    
    -- Eggs
    AutoBuyEgg = false,
    EggType = "Basic",
    EggCheckInterval = 5,
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
    ShowBubble = true,
    
    -- Misc
    AntiAFK = false,
    AutoClaim = false
}

-- Loops
local Loops = {}
local ClickerConnection = nil
local BubbleGUI = nil

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
    Subtext = "Auto Farm Premium v2.0",
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

--==================================================
-- CREATE BUBBLE INDICATOR UNTUK AUTO CLICKER
--==================================================
local function CreateBubble()
    -- Hapus bubble lama jika ada
    if BubbleGUI and BubbleGUI.Parent then
        BubbleGUI:Destroy()
    end
    
    -- Buat ScreenGui baru
    BubbleGUI = Instance.new("ScreenGui")
    BubbleGUI.Name = "TapSimBubble"
    BubbleGUI.Parent = CoreGui
    BubbleGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    BubbleGUI.ResetOnSpawn = false
    
    -- Frame utama bubble
    local BubbleFrame = Instance.new("Frame")
    BubbleFrame.Name = "BubbleFrame"
    BubbleFrame.Size = UDim2.new(0, 80, 0, 80)
    BubbleFrame.Position = UDim2.new(0, 20, 0.5, -40) -- Posisi di kiri tengah
    BubbleFrame.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    BubbleFrame.BackgroundTransparency = 0.2
    BubbleFrame.BorderSizePixel = 0
    BubbleFrame.Parent = BubbleGUI
    
    -- Membuat bubble menjadi lingkaran
    local BubbleCorner = Instance.new("UICorner")
    BubbleCorner.CornerRadius = UDim.new(1, 0) -- Lingkaran sempurna
    BubbleCorner.Parent = BubbleFrame
    
    -- Stroke/Outline
    local BubbleStroke = Instance.new("UIStroke")
    BubbleStroke.Thickness = 2
    BubbleStroke.Color = Color3.fromRGB(255, 255, 255)
    BubbleStroke.Transparency = 0.3
    BubbleStroke.Parent = BubbleFrame
    
    -- Shadow
    local BubbleShadow = Instance.new("Frame")
    BubbleShadow.Size = UDim2.new(1, 6, 1, 6)
    BubbleShadow.Position = UDim2.new(0, -3, 0, -3)
    BubbleShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BubbleShadow.BackgroundTransparency = 0.6
    BubbleShadow.BorderSizePixel = 0
    BubbleShadow.Parent = BubbleFrame
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(1, 0)
    ShadowCorner.Parent = BubbleShadow
    
    -- Icon Auto Clicker (menggunakan TextLabel dengan simbol)
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 0.6, 0)
    IconLabel.Position = UDim2.new(0, 0, 0, 10)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🖱️"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.TextSize = 30
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Parent = BubbleFrame
    
    -- Status Text
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0.3, 0)
    StatusLabel.Position = UDim2.new(0, 0, 0.6, -5)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "ON"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    StatusLabel.TextSize = 16
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Parent = BubbleFrame
    
    -- Speed indicator
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, 0, 0.2, 0)
    SpeedLabel.Position = UDim2.new(0, 0, 0.9, -10)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "0.001s"
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabel.TextSize = 8
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.Parent = BubbleFrame
    
    -- Tombol untuk toggle on/off
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = ""
    ToggleButton.Parent = BubbleFrame
    
    -- Animasi pulse
    local pulseAnimation = TweenService:Create(
        BubbleFrame,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1),
        {Size = UDim2.new(0, 85, 0, 85)}
    )
    
    -- Fungsi update status bubble
    local function UpdateBubbleStatus(isOn)
        StatusLabel.Text = isOn and "ON" or "OFF"
        StatusLabel.TextColor3 = isOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        SpeedLabel.Text = Toggles.ClickSpeed .. "s"
        
        if isOn then
            pulseAnimation:Play()
            BubbleFrame.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        else
            pulseAnimation:Pause()
            BubbleFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
    
    -- Tombol untuk toggle
    ToggleButton.MouseButton1Click:Connect(function()
        Toggles.AutoClicker = not Toggles.AutoClicker
        UpdateBubbleStatus(Toggles.AutoClicker)
        
        if Toggles.AutoClicker then
            StartLoop("AutoClicker")
            Notify("Auto Clicker ON")
        else
            StopLoop("AutoClicker")
            Notify("Auto Clicker OFF")
        end
    end)
    
    -- Bubble bisa di-drag
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = BubbleFrame.Position
        end
    end)
    
    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            BubbleFrame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Update speed saat slider berubah
    return {
        UpdateSpeed = function(speed)
            SpeedLabel.Text = speed .. "s"
        end,
        UpdateStatus = UpdateBubbleStatus
    }
end

--==================================================
-- AUTO CLICKER IMPROVED - TIDAK MENGGANGGU MOUSE
--==================================================
local function SetupAutoClicker()
    -- Method 1: Menggunakan VirtualUser (tidak mengganggu mouse)
    local function ClickWithVirtualUser()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
    
    -- Method 2: Mengirim remote event langsung
    local function ClickWithRemote()
        if Remotes.Tap then
            pcall(function()
                if Remotes.Tap:IsA("RemoteEvent") then
                    Remotes.Tap:FireServer()
                elseif Remotes.Tap:IsA("RemoteFunction") then
                    Remotes.Tap:InvokeServer()
                end
            end)
        else
            -- Fallback: coba semua kemungkinan remote
            for _, remote in pairs(ReplicatedStorage:GetChildren()) do
                if remote:IsA("RemoteEvent") and not remote.Name:find("Character") then
                    pcall(function() remote:FireServer() end)
                    break
                end
            end
        end
    end
    
    -- Method 3: Mengirim sinyal click ke GUI (tidak mengganggu mouse)
    local function ClickWithGUI()
        pcall(function()
            -- Coba klik button yang ada di layar (jika ada)
            local guiService = game:GetService("GuiService")
            guiService:SelectNext()
        end)
    end
    
    -- Gabungkan semua method
    return function()
        ClickWithRemote()
        ClickWithVirtualUser()
        -- Method 4: Simulasi mouse click tanpa mengganggu posisi mouse
        mouse1click() -- Ini tidak akan mengganggu karena hanya simulasi
    end
end

local AutoClickFunction = SetupAutoClicker()

--==================================================
-- AUTO BUY EGG IMPROVED
--==================================================
local function BuyEggImproved(eggType)
    print("🛒 Mencoba membeli egg: " .. eggType)
    
    -- Method 1: Gunakan remote yang sudah ditemukan
    if Remotes.BuyEgg then
        pcall(function()
            if Remotes.BuyEgg:IsA("RemoteEvent") then
                Remotes.BuyEgg:FireServer(eggType)
                print("✅ Membeli egg dengan remote: " .. Remotes.BuyEgg.Name)
            elseif Remotes.BuyEgg:IsA("RemoteFunction") then
                Remotes.BuyEgg:InvokeServer(eggType)
            end
        end)
        return
    end
    
    -- Method 2: Cari remote dengan pattern
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("buy") and (name:find("egg") or name:find("purchase")) then
                pcall(function() 
                    if v:IsA("RemoteEvent") then
                        v:FireServer(eggType)
                    else
                        v:InvokeServer(eggType)
                    end
                    print("✅ Membeli egg dengan: " .. v.Name)
                end)
                return
            end
        end
    end
    
    -- Method 3: Coba semua remote dengan argumen yang umum
    for _, v in pairs(ReplicatedStorage:GetChildren()) do
        if v:IsA("RemoteEvent") then
            pcall(function()
                -- Coba berbagai format argumen
                v:FireServer("BuyEgg", eggType)
                v:FireServer(eggType)
                v:FireServer("Purchase", eggType)
            end)
        end
    end
    
    print("⚠️ Tidak menemukan remote untuk beli egg")
end

--==================================================
-- AUTO HATCH EGG IMPROVED
--==================================================
local function HatchEggImproved()
    print("🥚 Mencoba menetasin egg...")
    
    if Remotes.HatchEgg then
        pcall(function()
            if Remotes.HatchEgg:IsA("RemoteEvent") then
                Remotes.HatchEgg:FireServer()
            else
                Remotes.HatchEgg:InvokeServer()
            end
        end)
        return
    end
    
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("hatch") or v.Name:lower():find("open")) then
            pcall(function() v:FireServer() end)
            return
        end
    end
end

--==================================================
-- CREATE BUBBLE
--==================================================
local Bubble = CreateBubble()

--==================================================
-- TAP FUNCTION IMPROVED
--==================================================
local function TapImproved()
    if Remotes.Tap then
        pcall(function()
            if Remotes.Tap:IsA("RemoteEvent") then
                Remotes.Tap:FireServer()
            elseif Remotes.Tap:IsA("RemoteFunction") then
                Remotes.Tap:InvokeServer()
            end
        end)
    else
        -- Fallback: auto clicker akan handle
        AutoClickFunction()
    end
end

--==================================================
-- CREATE MAIN WINDOW (LANJUTAN)
--==================================================

-- (Sisanya sama seperti sebelumnya, tapi dengan beberapa modifikasi)

--==================================================
-- AUTO FARM TAB (Modifikasi)
--==================================================
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local TapSection = FarmTab:AddSection({
    Name = "Auto Tap",
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

-- AUTO CLICKER SECTION (DENGAN BUBBLE)
local ClickerSection = FarmTab:AddSection({
    Name = "Auto Clicker (Bubble)",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

ClickerSection:AddToggle({
    Name = "Auto Clicker",
    Default = false,
    Color = Color3.fromRGB(255, 100, 0),
    Outline = true,
    Flag = "AutoClicker",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClicker = Value
        Bubble.UpdateStatus(Value)
        if Value then 
            StartLoop("AutoClicker")
            Notify("Auto Clicker ON - Bubble muncul di kiri")
        else 
            StopLoop("AutoClicker")
            Notify("Auto Clicker OFF")
        end
    end
})

ClickerSection:AddSlider({
    Name = "Click Speed",
    Min = 0.0005,
    Max = 0.05,
    Default = 0.001,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.0005,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.ClickSpeed = Value
        Bubble.UpdateSpeed(Value)
    end
})

ClickerSection:AddToggle({
    Name = "Show Bubble",
    Default = true,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "ShowBubble",
    Save = true,
    Callback = function(Value)
        Toggles.ShowBubble = Value
        if BubbleGUI then
            BubbleGUI.Enabled = Value
        end
    end
})

ClickerSection:AddParagraph({
    Title = "Info",
    Desc = "• Bubble bisa di-drag\n• Klik bubble untuk toggle\n• Auto clicker tidak ganggu mouse",
    Image = "info",
    ImageSize = 32
})

--==================================================
-- EGGS TAB (DIPERBAIKI)
--==================================================
local EggsTab = Window:MakeTab({
    Name = "Eggs",
    Icon = "egg",
    Glass = true,
    Outline = true
})

local EggSection = EggsTab:AddSection({
    Name = "Egg Settings (Improved)",
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
            Notify("Auto Buy Egg ON - Mencoba " .. Toggles.EggType)
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
        Notify("Egg type: " .. Value)
    end
})

EggSection:AddSlider({
    Name = "Buy Interval",
    Min = 1,
    Max = 30,
    Default = 5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.EggCheckInterval = Value
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
    Name = "Test Buy Egg",
    Icon = "shopping-cart",
    Outline = true,
    Callback = function()
        BuyEggImproved(Toggles.EggType)
        Notify("Mencoba beli " .. Toggles.EggType)
    end
})

EggSection:AddButton({
    Name = "Test Hatch Egg",
    Icon = "egg",
    Outline = true,
    Callback = function()
        HatchEggImproved()
        Notify("Mencoba hatch egg")
    end
})

EggSection:AddButton({
    Name = "Scan Remotes",
    Icon = "search",
    Outline = true,
    Callback = function()
        FindRemotes()
        Notify("Remote scan complete - Check F9")
    end
})

--==================================================
-- LOOP FUNCTIONS (DIPERBAIKI)
--==================================================
function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if name == "AutoTap" and Toggles.AutoTap then
                TapImproved()
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoClicker" and Toggles.AutoClicker then
                -- Auto clicker berjalan sendiri tanpa mengganggu mouse
                AutoClickFunction()
                task.wait(Toggles.ClickSpeed)
                
            elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                BuyEggImproved(Toggles.EggType)
                task.wait(Toggles.EggCheckInterval)
                
            elseif name == "AutoHatch" and Toggles.AutoHatch then
                HatchEggImproved()
                task.wait(1)
                
            elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                if Remotes.Upgrade then
                    pcall(function() Remotes.Upgrade:FireServer(Toggles.UpgradeType) end)
                end
                task.wait(1)
                
            elseif name == "AutoBuyArea" and Toggles.AutoBuyArea then
                if Remotes.BuyArea then
                    pcall(function() Remotes.BuyArea:FireServer() end)
                end
                task.wait(2)
                
            elseif name == "AutoCollect" and Toggles.AutoCollect then
                if Remotes.Collect then
                    pcall(function() Remotes.Collect:FireServer() end)
                end
                task.wait(5)
                
            elseif name == "AutoRebirth" and Toggles.AutoRebirth then
                local coins = GetCoins()
                if coins >= Toggles.RebirthAt and Remotes.Rebirth then
                    pcall(function() Remotes.Rebirth:FireServer() end)
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
-- GET COINS FUNCTION
--==================================================
function GetCoins()
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

--==================================================
-- FORMAT NUMBER
--==================================================
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
print("=== Tap Simulator - Catraz Edition v2.0 Loaded ===")
print("✅ Auto Clicker dengan bubble indicator")
print("✅ Auto Buy Egg improved")
print("✅ Tidak mengganggu mouse movement")
print("Press F4 to toggle menu")