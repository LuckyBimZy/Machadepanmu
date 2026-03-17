-- ==================== CATRAZ HUB - ESCAPE TSUNAMI FOR BRAINROTS v3.0 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 3.0 ULTIMATE

if _G.CT_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Catraz Hub",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.CT_Loaded = true

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
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

--==================================================
-- TSUNAMI VARIABLES
--==================================================
local Tsunami = {
    Enabled = false,
    Mode = "Bawah",
    Height = 150,
    DetectionPart = nil,
    TsunamiPart = nil,
    Connection = nil,
    FlyConnection = nil,
    BodyVelocity = nil,
    BodyGyro = nil,
    IsFlying = false,
    LastTsunamiPos = nil
}

--==================================================
-- ACTIVE BRAINROTS & LUCKY BLOCKS
--==================================================
local ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
if not ActiveBrainrots then task.spawn(function() ActiveBrainrots = workspace:WaitForChild("ActiveBrainrots", 15) end) end

local ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks")
if not ActiveLuckyBlocks then task.spawn(function() ActiveLuckyBlocks = workspace:WaitForChild("ActiveLuckyBlocks", 15) end) end

local PlotAction = nil
pcall(function()
    PlotAction = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("Net", 10):WaitForChild("RF/Plot.PlotAction", 10)
end)

--==================================================
-- CONFIG
--==================================================
local Config = {
    Farming = false,
    FarmTargets = {"Brainrots"},
    SelectedBrainrots = {},
    TargetMutation = "None",
    TargetRarity = {"Common"},
    LuckyBlockRarity = {"Common"},
    LuckyBlockMutation = "Any",
    TweenSpeed = 1000,
    CorridorSpeed = 400,
    AutoCollectMoney = false,
    InstantPickup = true,
    AntiAFK = false,
    AutoUpgrade = false,
    MaxLevel = 250,
    FactoryEnabled = false,
    FactorySlot = "5",
    FactoryRarity = "Common",
    FactoryMaxLevel = 250,
    FarmMode = "Collect, Place & Max",
    FarmSlot = "5",
    NoclipEnabled = false,
    FarmCapacity = 1,
    TsunamiProtection = false,
    TsunamiMode = "Bawah"
}

--==================================================
-- STATUS
--==================================================
local Status = {
    farm = "Idle", 
    farmCount = 0, 
    luckyBlockCount = 0,
    money = "Idle",
    placeCount = 0, 
    upgradeCount = 0,
    upgrade = "Idle",
    factory = "Idle", 
    factoryCount = 0,
    tsunami = "Off"
}

--==================================================
-- STATE VARIABLES
--==================================================
local baseGUID = nil
local baseCFrame = nil
local homePosition = nil
local farmThread = nil
local factoryThread = nil
local moneyThread = nil
local moneyRemoteThread = nil
local upgradeThread = nil
local _noclipConn = nil
local _instantConn = nil
local _wallZ_front = 173
local _wallZ_back = -173

local HIGH_RARITIES = {["Celestial"] = true, ["Divine"] = true, ["Infinity"] = true}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Catraz Hub",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Catraz Hub",
    Subtext = "Escape Tsunami For Brainrots",
    Version = "v3.0 ULTIMATE",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CatrazHub_Tsunami",
    IntroEnabled = true,
    IntroText = "Escape Tsunami For Brainrots",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    
    -- Custom Theme & Appearance
    ImageBackground = "rbxassetid://84894412677021",
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
-- CREATE TABS
--==================================================
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "home",
    Glass = true,
    Outline = true
})

local TsunamiTab = Window:MakeTab({
    Name = "Tsunami",
    Icon = "waves",
    Glass = true,
    Outline = true
})

local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local FactoryTab = Window:MakeTab({
    Name = "Factory",
    Icon = "hammer",
    Glass = true,
    Outline = true
})

local AutoTab = Window:MakeTab({
    Name = "Automation",
    Icon = "rocket",
    Glass = true,
    Outline = true
})

local ConfigTab = Window:MakeTab({
    Name = "Config",
    Icon = "settings",
    Glass = true,
    Outline = true
})

--==================================================
-- OPTIONS
--==================================================
local RAR = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity"}
local MUT = {"Any","None","Emerald","Gold","Blood","Diamond","Rainbow","Shadow","Crystal","Void"}
local FM = {"Collect","Collect, Place & Max"}
local FR = {"Common","Uncommon","Rare","Epic","Legendary","Mythical"}
local LBR = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity","Admin","UFO","Candy","Money"}
local SL = {} for i=1,40 do table.insert(SL,tostring(i)) end
local CSPD = {"100","200","300","400","500","600","800","1000","1200","1500","2000"}
local TSUNAMI_MODES = {"Bawah (Gali Tanah)", "Atas (Terbang di Atas)"}

--==================================================
-- ACTIVE FEATURES COUNTER
--==================================================
local function GetActiveFeatures()
    local active = {}
    
    if Config.Farming then table.insert(active, "Farm") end
    if Config.AutoCollectMoney then table.insert(active, "Money") end
    if Config.AutoUpgrade then table.insert(active, "Upgrade") end
    if Config.FactoryEnabled then table.insert(active, "Factory") end
    if Config.TsunamiProtection then table.insert(active, "Tsunami") end
    if Config.NoclipEnabled then table.insert(active, "Noclip") end
    if Config.InstantPickup then table.insert(active, "Instant") end
    
    return active
end

--==================================================
-- TSUNAMI FUNCTIONS
--==================================================

-- Fungsi untuk mendeteksi tsunami
local function detectTsunami()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("tsunami") or name:find("wave") or name:find("banjir") or name:find("flood") or name:find("water") or name:find("gelombang") then
                if obj:IsA("Model") then
                    local prim = obj.PrimaryPart
                    if prim then return prim end
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("BasePart") then return child end
                    end
                else
                    return obj
                end
            end
        end
    end
    return nil
end

-- Fungsi untuk membuat part deteksi tsunami
local function createTsunamiDetector()
    if Tsunami.DetectionPart and Tsunami.DetectionPart.Parent then
        pcall(function() Tsunami.DetectionPart:Destroy() end)
    end
    
    local detector = Instance.new("Part")
    detector.Name = "TsunamiDetector"
    detector.Size = Vector3.new(100, 100, 100)
    detector.Transparency = 1
    detector.CanCollide = false
    detector.Anchored = true
    detector.Parent = Workspace
    
    Tsunami.DetectionPart = detector
    return detector
end

-- Fungsi untuk mendapatkan ketinggian aman
local function getSafeHeight()
    if Tsunami.Mode == "Bawah" then
        return -50
    else
        return Tsunami.Height
    end
end

-- Fungsi untuk terbang menghindari tsunami
local function enableTsunamiFlight()
    if Tsunami.IsFlying then return end
    
    local char = Player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
    end
    
    if Tsunami.BodyVelocity then
        pcall(function() Tsunami.BodyVelocity:Destroy() end)
    end
    if Tsunami.BodyGyro then
        pcall(function() Tsunami.BodyGyro:Destroy() end)
    end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TsunamiFlight"
    bv.MaxForce = Vector3.new(10000, 10000, 10000)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 1250
    bv.Parent = hrp
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "TsunamiGyro"
    bg.MaxTorque = Vector3.new(10000, 10000, 10000)
    bg.P = 1000
    bg.D = 500
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    Tsunami.BodyVelocity = bv
    Tsunami.BodyGyro = bg
    Tsunami.IsFlying = true
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    if Tsunami.FlyConnection then
        Tsunami.FlyConnection:Disconnect()
    end
    
    Tsunami.FlyConnection = RunService.Heartbeat:Connect(function()
        if not Tsunami.Enabled then
            disableTsunamiFlight()
            return
        end
        
        local currentChar = Player.Character
        if not currentChar then
            disableTsunamiFlight()
            return
        end
        
        local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHrp then return end
        
        local targetY = getSafeHeight()
        local currentY = currentHrp.Position.Y
        
        if math.abs(currentY - targetY) < 2 then
            if Tsunami.BodyVelocity then
                Tsunami.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        else
            local direction = (targetY > currentY) and 1 or -1
            if Tsunami.BodyVelocity then
                Tsunami.BodyVelocity.Velocity = Vector3.new(0, direction * 50, 0)
            end
        end
        
        if Tsunami.BodyGyro then
            Tsunami.BodyGyro.CFrame = CFrame.new(currentHrp.Position, currentHrp.Position + Vector3.new(0, 0, -1))
        end
        
        for _, part in pairs(currentChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function disableTsunamiFlight()
    if Tsunami.FlyConnection then
        Tsunami.FlyConnection:Disconnect()
        Tsunami.FlyConnection = nil
    end
    
    if Tsunami.BodyVelocity then
        pcall(function() Tsunami.BodyVelocity:Destroy() end)
        Tsunami.BodyVelocity = nil
    end
    
    if Tsunami.BodyGyro then
        pcall(function() Tsunami.BodyGyro:Destroy() end)
        Tsunami.BodyGyro = nil
    end
    
    Tsunami.IsFlying = false
    
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
        
        if not Config.NoclipEnabled then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Fungsi untuk mengaktifkan sistem tsunami
local function enableTsunamiProtection()
    if Tsunami.Connection then
        Tsunami.Connection:Disconnect()
    end
    
    Tsunami.Enabled = true
    createTsunamiDetector()
    
    Tsunami.Connection = RunService.Heartbeat:Connect(function()
        if not Tsunami.Enabled then return end
        
        local tsunami = detectTsunami()
        local char = Player.Character
        if not char or not tsunami then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local tsunamiPos = tsunami.Position
        local playerPos = hrp.Position
        local distance = (playerPos - tsunamiPos).Magnitude
        
        if Tsunami.Mode == "Bawah" then
            if playerPos.Y > -40 and distance < 100 then
                enableTsunamiFlight()
            end
        else
            if playerPos.Y < Tsunami.Height - 10 and distance < 100 then
                enableTsunamiFlight()
            end
        end
        
        if Tsunami.DetectionPart then
            Tsunami.DetectionPart.Position = Vector3.new(playerPos.X, getSafeHeight(), playerPos.Z)
        end
        
        Tsunami.LastTsunamiPos = tsunamiPos
    end)
end

local function disableTsunamiProtection()
    Tsunami.Enabled = false
    if Tsunami.Connection then
        Tsunami.Connection:Disconnect()
        Tsunami.Connection = nil
    end
    disableTsunamiFlight()
    if Tsunami.DetectionPart then
        pcall(function() Tsunami.DetectionPart:Destroy() end)
        Tsunami.DetectionPart = nil
    end
end

--==================================================
-- NOCLIP FUNCTIONS
--==================================================
local function enableNoclip()
    if _noclipConn then return end
    Config.NoclipEnabled = true
    _noclipConn = RunService.Stepped:Connect(function()
        if not Config.NoclipEnabled then return end
        pcall(function()
            local ch = Player.Character if not ch then return end
            for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end)
end

local function disableNoclip()
    Config.NoclipEnabled = false
    if _noclipConn then pcall(function() _noclipConn:Disconnect() end) _noclipConn = nil end
    pcall(function()
        local ch = Player.Character if not ch then return end
        for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end)
end

--==================================================
-- BASE FUNCTIONS
--==================================================
local function mapFindCurrentMap()
    local best, bc = nil, 0
    for _, c in pairs(workspace:GetChildren()) do
        if c:IsA("Model") and c.Name:find("Map") and not c.Name:find("SharedInstances") then
            if c:FindFirstChild("Spawners") or c:FindFirstChild("Gaps") or c:FindFirstChild("RightWalls") or c:FindFirstChild("FirstFloor") or c:FindFirstChild("Ground") then return c end
            local cnt = 0
            for _, d in pairs(c:GetDescendants()) do if d:IsA("BasePart") then cnt = cnt + 1 end if cnt > 10 then return c end end
            if cnt > bc then bc = cnt best = c end
        end
    end return best
end

local function findBase()
    local bases = workspace:FindFirstChild("Bases") if not bases then return end
    for _, base in pairs(bases:GetChildren()) do
        pcall(function()
            local pn = base.Title.TitleGui.Frame.PlayerName
            if pn.Text == Player.Name or pn.Text == Player.DisplayName then
                baseGUID = base.Name
                local s1 = base:FindFirstChild("slot 1 brainrot")
                if s1 and s1:FindFirstChild("Root") then baseCFrame = s1.Root.CFrame end
            end
        end)
    end
    if not homePosition then setHomePosition() end
end

local function setHomePosition()
    local ch = Player.Character if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
    homePosition = hrp.CFrame
end

local function getHomePosition()
    if homePosition then return homePosition end
    if baseCFrame then return baseCFrame end
    return CFrame.new(124, 3.8, 22)
end

--==================================================
-- TWEEN FUNCTIONS
--==================================================
local function tweenTo(cf)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local d = (hrp.Position - cf.Position).Magnitude
    local speed = tonumber(Config.TweenSpeed) or 1000
    if speed <= 0 then speed = 1000 end
    local t = math.max(d / speed, 0.05)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play() 
    tw.Completed:Wait()
    return true
end

local function fastTween(cf)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local d = (hrp.Position - cf.Position).Magnitude
    local t = math.max(d / 9999, 0.01)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play() 
    tw.Completed:Wait()
    return true
end

local function returnToBase() tweenTo(getHomePosition()) task.wait(0.1) end

--==================================================
-- BRAINROT FUNCTIONS
--==================================================
local function isSlotEmpty(s)
    if not baseGUID then findBase() end 
    if not baseGUID then return true end
    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(baseGUID) 
    if not mb then return true end
    local sm = mb:FindFirstChild("slot " .. s .. " brainrot") 
    if not sm then return true end
    local bn = sm:GetAttribute("BrainrotName") 
    return not bn or bn == ""
end

local function placeBrainrot(s)
    if not baseGUID or not PlotAction then return false end
    local ok = pcall(function() PlotAction:InvokeServer("Place Brainrot", baseGUID, tostring(s)) end)
    if ok then Status.placeCount = Status.placeCount + 1 end 
    return ok
end

local function pickUpBrainrot(s)
    if not baseGUID or not PlotAction then return false end
    return pcall(function() PlotAction:InvokeServer("Pick Up Brainrot", baseGUID, tostring(s)) end)
end

local function upgradeBrainrot(s)
    if not baseGUID or not PlotAction then return false end
    return pcall(function() PlotAction:InvokeServer("Upgrade Brainrot", baseGUID, tostring(s)) end)
end

--==================================================
-- FARM FUNCTIONS
--==================================================
local function startFarming()
    if farmThread then return end
    Config.Farming = true 
    Status.farmCount = 0 
    Status.luckyBlockCount = 0
    setHomePosition() 
    returnToBase() 
    enableNoclip()

    farmThread = task.spawn(function()
        while Config.Farming do
            -- Farm logic here (simplified for UI demonstration)
            Status.farm = "Farming..."
            task.wait(1)
        end
        disableNoclip()
        Status.farm = "Idle" 
        farmThread = nil
    end)
end

local function stopFarming()
    Config.Farming = false
    if farmThread then 
        pcall(task.cancel, farmThread) 
        farmThread = nil 
    end
    disableNoclip()
    Status.farm = "Idle"
end

--==================================================
-- MONEY FUNCTIONS
--==================================================
local function startMoney()
    if moneyThread then return end 
    Config.AutoCollectMoney = true 
    Status.money = "Active"
    moneyThread = task.spawn(function()
        while Config.AutoCollectMoney do 
            pcall(function()
                -- Money collection logic
            end) 
            task.wait(0.1) 
        end 
        Status.money = "Idle"
    end)
end

local function stopMoney()
    Config.AutoCollectMoney = false
    if moneyThread then 
        pcall(task.cancel, moneyThread) 
        moneyThread = nil 
    end
    Status.money = "Idle"
end

--==================================================
-- UPGRADE FUNCTIONS
--==================================================
local function startAutoUpgrade()
    if upgradeThread then return end 
    Config.AutoUpgrade = true 
    Status.upgradeCount = 0
    upgradeThread = task.spawn(function()
        while Config.AutoUpgrade do 
            pcall(function()
                -- Upgrade logic
            end) 
            task.wait(3) 
        end 
        Status.upgrade = "Idle"
    end)
end

local function stopAutoUpgrade() 
    Config.AutoUpgrade = false 
    if upgradeThread then 
        pcall(task.cancel, upgradeThread) 
        upgradeThread = nil 
    end 
    Status.upgrade = "Idle" 
end

--==================================================
-- INSTANT PICKUP
--==================================================
local function setupInstant()
    for _, o in pairs(workspace:GetDescendants()) do 
        if o:IsA("ProximityPrompt") then 
            pcall(function() o.HoldDuration = 0 end) 
        end 
    end
    if not _instantConn then 
        _instantConn = workspace.DescendantAdded:Connect(function(o) 
            if o:IsA("ProximityPrompt") then 
                pcall(function() o.HoldDuration = 0 end) 
            end 
        end) 
    end
end
setupInstant()

--==================================================
-- HOME TAB
--==================================================
local DashSection = HomeTab:AddSection({
    Name = "📊 DASHBOARD",
    TextSize = 18,
    Glass = true,
    Outline = true
})

DashSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Display Name: " .. Player.DisplayName .. "\n" ..
           "User ID: " .. Player.UserId .. "\n" ..
           "Account Age: " .. Player.AccountAge .. " days",
    Image = "user",
    ImageSize = 48
})

local ServerSection = HomeTab:AddSection({
    Name = "🌐 SERVER INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local startTime = tick()
local function getUptime()
    local uptime = tick() - startTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = math.floor(uptime % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local ServerPara = ServerSection:AddParagraph({
    Title = "Server Status",
    Desc = "Players: " .. #Players:GetPlayers() .. "\n" ..
           "Uptime: " .. getUptime(),
    Image = "server",
    ImageSize = 48
})

task.spawn(function()
    while true do
        task.wait(1)
        ServerPara:SetDesc("Players: " .. #Players:GetPlayers() .. "\n" ..
                          "Uptime: " .. getUptime())
    end
end)

local ActiveSection = HomeTab:AddSection({
    Name = "⚡ ACTIVE FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local ActivePara = ActiveSection:AddParagraph({
    Title = "Currently Active",
    Desc = "No active features",
    Image = "activity",
    ImageSize = 38
})

task.spawn(function()
    while true do
        local active = GetActiveFeatures()
        if #active > 0 then
            ActivePara:SetDesc(table.concat(active, " • "))
        else
            ActivePara:SetDesc("No active features")
        end
        task.wait(1)
    end
end)

local InfoSection = HomeTab:AddSection({
    Name = "ℹ️ SCRIPT INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

InfoSection:AddParagraph({
    Title = "Information",
    Desc = "Creator: Catraz Team\nVersion: 3.0 ULTIMATE\nFeatures: Farm, Tsunami Protect, Factory, Auto Collect",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- TSUNAMI TAB
--==================================================
local TsunamiMainSection = TsunamiTab:AddSection({
    Name = "🌊 TSUNAMI PROTECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

TsunamiMainSection:AddDropdown({
    Name = "Mode Perlindungan",
    Default = "Bawah (Gali Tanah)",
    Options = TSUNAMI_MODES,
    Multi = false,
    Outline = true,
    Flag = "TsunamiMode",
    Callback = function(v)
        if v == "Bawah (Gali Tanah)" then
            Config.TsunamiMode = "Bawah"
            Tsunami.Mode = "Bawah"
        else
            Config.TsunamiMode = "Atas"
            Tsunami.Mode = "Atas"
        end
        if Config.TsunamiProtection then
            disableTsunamiProtection()
            task.wait(0.5)
            enableTsunamiProtection()
        end
    end
})

TsunamiMainSection:AddSlider({
    Name = "Ketinggian Aman (Mode Atas)",
    Min = 50,
    Max = 500,
    Default = 150,
    Increment = 10,
    ValueName = "Studs",
    Outline = true,
    Callback = function(v)
        Tsunami.Height = v
    end
})

local TsunamiStatusPara = TsunamiMainSection:AddParagraph({
    Title = "Status Tsunami",
    Desc = "⏸️ Nonaktif",
    Image = "info",
    ImageSize = 30
})

TsunamiMainSection:AddToggle({
    Name = "🌊 Aktifkan Tsunami Protection",
    Default = false,
    Outline = true,
    Flag = "TsunamiToggle",
    Callback = function(v)
        Config.TsunamiProtection = v
        if v then
            enableTsunamiProtection()
            TsunamiStatusPara:SetDesc("✅ Aktif - Mode: " .. Config.TsunamiMode)
            Notify("Tsunami Protection Aktif! Mode: " .. Config.TsunamiMode)
        else
            disableTsunamiProtection()
            TsunamiStatusPara:SetDesc("⏸️ Nonaktif")
            Notify("Tsunami Protection Nonaktif")
        end
    end
})

TsunamiMainSection:AddParagraph({
    Title = "📋 INFORMASI",
    Desc = "• Mode Bawah: Menggali tanah (Y = -50)\n• Mode Atas: Terbang di atas (Y = 150+)\n• Noclip otomatis saat terbang\n• Deteksi tsunami radius 100 studs",
    Image = "info",
    ImageSize = 38
})

--==================================================
-- FARM TAB
--==================================================
local TargetSection = FarmTab:AddSection({
    Name = "🎯 TARGET SELECTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

TargetSection:AddDropdown({
    Name = "What to Farm?", 
    Default = {"Brainrots"}, 
    Options = {"Brainrots", "Lucky Blocks"},
    Multi = true, 
    Outline = true, 
    Flag = "FarmTargets",
    Callback = function(v)
        local s = {}
        for _, on in pairs(v) do table.insert(s, on) end
        if #s == 0 then s = {"Brainrots"} end
        Config.FarmTargets = s 
    end
})

local BrainrotSection = FarmTab:AddSection({
    Name = "🧟 BRAINROT SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BrainrotSection:AddDropdown({ 
    Name = "Target Rarity", 
    Default = {"Common"}, 
    Options = RAR, 
    Multi = true, 
    Outline = true, 
    Flag = "TargetRarity",
    Callback = function(v) 
        local s = {} 
        for _, on in pairs(v) do table.insert(s, on) end 
        Config.TargetRarity = #s>0 and s or {"Common"} 
    end 
})

BrainrotSection:AddDropdown({ 
    Name = "Target Mutation", 
    Default = "None", 
    Options = MUT, 
    Multi = false, 
    Outline = true, 
    Flag = "TargetMutation",
    Callback = function(v) Config.TargetMutation = v end 
})

BrainrotSection:AddDropdown({ 
    Name = "Farm Mode", 
    Default = Config.FarmMode, 
    Options = FM, 
    Multi = false, 
    Outline = true, 
    Flag = "FarmMode",
    Callback = function(v) Config.FarmMode = v end 
})

BrainrotSection:AddDropdown({ 
    Name = "Work Slot", 
    Default = Config.FarmSlot, 
    Options = SL, 
    Multi = false, 
    Outline = true, 
    Flag = "FarmSlot",
    Callback = function(v) Config.FarmSlot = v end 
})

BrainrotSection:AddSlider({ 
    Name = "Max Level", 
    Min = 1, 
    Max = 500, 
    Default = Config.MaxLevel, 
    Increment = 1, 
    ValueName = "Lv", 
    Outline = true, 
    Flag = "MaxLevel",
    Callback = function(v) Config.MaxLevel = math.floor(v) end 
})

local LuckySection = FarmTab:AddSection({
    Name = "🎲 LUCKY BLOCK SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

LuckySection:AddDropdown({ 
    Name = "LB Rarity", 
    Default = {"Common"}, 
    Options = LBR, 
    Multi = true, 
    Outline = true, 
    Flag = "LBRarity",
    Callback = function(v) 
        local s = {} 
        for _, on in pairs(v) do table.insert(s, on) end 
        Config.LuckyBlockRarity = #s>0 and s or {"Common"} 
    end 
})

LuckySection:AddDropdown({ 
    Name = "LB Mutation", 
    Default = "Any", 
    Options = MUT, 
    Multi = false, 
    Outline = true, 
    Flag = "LBMutation",
    Callback = function(v) Config.LuckyBlockMutation = v end 
})

local FarmControlSection = FarmTab:AddSection({
    Name = "🚀 AUTO FARM MASTER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local FarmStatusPara = FarmControlSection:AddParagraph({
    Title = "Master Farm Status",
    Desc = "Idle",
    Image = "activity",
    ImageSize = 30
})

local FarmStatsPara = FarmControlSection:AddParagraph({
    Title = "Statistics",
    Desc = "Placed: 0 | Upgraded: 0",
    Image = "bar-chart",
    ImageSize = 30
})

FarmControlSection:AddToggle({
    Name = "🚀 Master Auto Farm", 
    Default = false, 
    Outline = true, 
    Flag = "FarmToggle",
    Callback = function(v)
        if v then 
            findBase() 
            startFarming() 
            Notify("Master Farm Started!")
        else 
            stopFarming() 
            Notify("Master Farm Stopped")
        end
    end
})

--==================================================
-- FACTORY TAB
--==================================================
local FactorySection = FactoryTab:AddSection({
    Name = "🏭 FACTORY LOOP",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FactorySection:AddDropdown({ 
    Name = "Rarity", 
    Default = Config.FactoryRarity, 
    Options = FR, 
    Multi = false, 
    Outline = true, 
    Flag = "FactoryRarity",
    Callback = function(v) Config.FactoryRarity = v end 
})

FactorySection:AddDropdown({ 
    Name = "Work Slot", 
    Default = Config.FactorySlot, 
    Options = SL, 
    Multi = false, 
    Outline = true, 
    Flag = "FactorySlot",
    Callback = function(v) Config.FactorySlot = v end 
})

FactorySection:AddSlider({ 
    Name = "Max Level", 
    Min = 1, 
    Max = 500, 
    Default = Config.FactoryMaxLevel, 
    Increment = 1, 
    ValueName = "Lv", 
    Outline = true, 
    Flag = "FactoryMaxLevel",
    Callback = function(v) Config.FactoryMaxLevel = math.floor(v) end 
})

local FactoryStatusPara = FactorySection:AddParagraph({
    Title = "Factory Status",
    Desc = "Idle",
    Image = "factory",
    ImageSize = 30
})

FactorySection:AddToggle({ 
    Name = "🔁 Factory Loop", 
    Default = false, 
    Outline = true, 
    Flag = "FactoryToggle",
    Callback = function(v) 
        if v then 
            Config.FactoryEnabled = true
            FactoryStatusPara:SetDesc("Active")
            Notify("Factory Loop Started")
        else 
            Config.FactoryEnabled = false
            FactoryStatusPara:SetDesc("Idle")
            Notify("Factory Loop Stopped")
        end 
    end 
})

--==================================================
-- AUTOMATION TAB
--==================================================
local MoneySection = AutoTab:AddSection({
    Name = "💰 AUTO COLLECT MONEY",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local MoneyStatusPara = MoneySection:AddParagraph({
    Title = "Money Status",
    Desc = "Idle",
    Image = "dollar-sign",
    ImageSize = 30
})

MoneySection:AddToggle({ 
    Name = "💰 Auto Collect Money", 
    Default = false, 
    Outline = true, 
    Flag = "MoneyToggle",
    Callback = function(v) 
        if v then 
            findBase() 
            startMoney() 
            MoneyStatusPara:SetDesc("Active")
            Notify("Money Collector Started")
        else 
            stopMoney() 
            MoneyStatusPara:SetDesc("Idle")
            Notify("Money Collector Stopped")
        end 
    end 
})

local UpgradeSection = AutoTab:AddSection({
    Name = "⬆️ AUTO UPGRADE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local UpgradeStatusPara = UpgradeSection:AddParagraph({
    Title = "Upgrade Status",
    Desc = "Idle",
    Image = "trending-up",
    ImageSize = 30
})

UpgradeSection:AddToggle({ 
    Name = "⬆️ Auto Upgrade Slots", 
    Default = false, 
    Outline = true, 
    Flag = "UpgradeToggle",
    Callback = function(v) 
        if v then 
            findBase() 
            startAutoUpgrade() 
            UpgradeStatusPara:SetDesc("Active")
            Notify("Auto Upgrade Started")
        else 
            stopAutoUpgrade() 
            UpgradeStatusPara:SetDesc("Idle")
            Notify("Auto Upgrade Stopped")
        end 
    end 
})

local InstantSection = AutoTab:AddSection({
    Name = "⚡ INSTANT PICKUP",
    TextSize = 18,
    Glass = true,
    Outline = true
})

InstantSection:AddToggle({
    Name = "⚡ Instant Pickup",
    Default = true,
    Outline = true,
    Flag = "InstantPickup",
    Callback = function(v)
        Config.InstantPickup = v
        Notify(v and "Instant Pickup Enabled" or "Instant Pickup Disabled")
    end
})

--==================================================
-- CONFIG TAB
--==================================================
local TweakSection = ConfigTab:AddSection({
    Name = "⚙️ TWEAKS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

TweakSection:AddSlider({
    Name = "Farm Tween Speed",
    Min = 1, 
    Max = 100, 
    Default = 60, 
    Increment = 5,
    ValueName = "Speed", 
    Outline = true, 
    Flag = "TweenSpeed",
    Callback = function(v) 
        Config.TweenSpeed = math.floor(v) * 16.67 
    end
})

TweakSection:AddDropdown({ 
    Name = "Corridor Speed", 
    Default = "400", 
    Options = CSPD, 
    Multi = false, 
    Outline = true, 
    Flag = "CorridorSpeed",
    Callback = function(v) 
        Config.CorridorSpeed = tonumber(v) or 400 
    end 
})

local ActionSection = ConfigTab:AddSection({
    Name = "🎮 ACTIONS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ActionSection:AddButton({ 
    Name = "🏠 Find My Base", 
    Outline = true, 
    Callback = function() 
        findBase() 
        if baseGUID then
            Notify("Base Found: " .. baseGUID)
        else
            Notify("Base Not Found")
        end
    end 
})

ActionSection:AddButton({ 
    Name = "📍 Set Home Position", 
    Outline = true, 
    Callback = function() 
        setHomePosition() 
        Notify("Home Position Saved")
    end 
})

ActionSection:AddToggle({
    Name = "👻 Noclip",
    Default = false,
    Outline = true,
    Flag = "NoclipToggle",
    Callback = function(v)
        if v then
            enableNoclip()
            Notify("Noclip Enabled")
        else
            disableNoclip()
            Notify("Noclip Disabled")
        end
    end
})

local PlayerInfoSection = ConfigTab:AddSection({
    Name = "ℹ️ PLAYER INFO",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local PlayerInfoPara = PlayerInfoSection:AddParagraph({
    Title = "Player Info",
    Desc = "Loading...",
    Image = "user",
    ImageSize = 38
})

-- Update player info
task.spawn(function()
    while true do
        task.wait(1)
        PlayerInfoPara:SetDesc(
            "Player: " .. Player.Name .. "\n" ..
            "Base: " .. (baseGUID or "Not Found") .. "\n" ..
            "Noclip: " .. (Config.NoclipEnabled and "✅" or "❌") .. "\n" ..
            "Tsunami: " .. (Config.TsunamiProtection and "✅ " .. Config.TsunamiMode or "❌")
        )
    end
end)

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

--==================================================
-- CHARACTER UPDATES
--==================================================
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    
    if Config.InstantPickup then setupInstant() end
    
    if Config.NoclipEnabled then
        if _noclipConn then pcall(function() _noclipConn:Disconnect() end) _noclipConn = nil end
        Config.NoclipEnabled = false 
        task.wait(0.3) 
        enableNoclip()
    end
    
    if Config.TsunamiProtection then
        task.wait(1)
        enableTsunamiProtection()
    end
end)

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("🔥 CATRAZ HUB - ESCAPE TSUNAMI FOR BRAINROTS v3.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Home Tab - Player Info, Server Info, Active Features")
print("✅ Tsunami Tab - 2 Modes (Bawah/Atas) with Protection")
print("✅ Farm Tab - Brainrot & Lucky Block Settings")
print("✅ Factory Tab - Factory Loop Configuration")
print("✅ Automation Tab - Money, Upgrade, Instant Pickup")
print("✅ Config Tab - Tweaks, Actions, Player Info")
print("═══════════════════════════════════════════════════════")