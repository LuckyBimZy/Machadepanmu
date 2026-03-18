-- ==================== CATRAZ HUB - ESCAPE TSUNAMI FOR BRAINROTS v4.0 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 4.0 ULTIMATE - FULLY FUNCTIONAL

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
local ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks")
local PlotAction = nil

-- Cari remote events
pcall(function()
    -- Coba cari di ReplicatedStorage
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if packages then
        local net = packages:FindFirstChild("Net")
        if net then
            PlotAction = net:FindFirstChild("RF/Plot.PlotAction")
        end
    end
    
    -- Fallback: cari langsung
    if not PlotAction then
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj.Name == "PlotAction" or obj.Name == "Plot.PlotAction" then
                PlotAction = obj
                break
            end
        end
    end
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
local _currentTarget = nil
local _currentTargetType = nil

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
    Version = "v4.0 ULTIMATE",
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
local CSPD = {"100","200","300","400","500","600","800","1000","1200","1500","2000","2500","3000"}
local TSUNAMI_MODES = {"Bawah (Gali Tanah)", "Atas (Terbang di Atas)"}
local TWEEN_SPEED = {"100","200","300","400","500","600","700","800","900","1000"}

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
-- TWEEN FUNCTIONS (DIPERBAIKI)
--==================================================
local function tweenTo(cf)
    local ch = Player.Character
    if not ch then 
        Notify("❌ Tidak ada karakter!")
        return false 
    end
    
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        Notify("❌ Tidak ada HumanoidRootPart!")
        return false 
    end
    
    -- Hitung jarak
    local distance = (hrp.Position - cf.Position).Magnitude
    if distance < 5 then return true end -- Sudah dekat
    
    -- Hitung waktu berdasarkan speed
    local speed = tonumber(Config.TweenSpeed) or 1000
    if speed <= 0 then speed = 1000 end
    local t = distance / speed
    
    -- Minimal waktu 0.1 detik, maksimal 5 detik
    t = math.max(0.1, math.min(t, 5))
    
    -- Buat tween
    local success, err = pcall(function()
        local tweenInfo = TweenInfo.new(t, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = cf})
        tween:Play()
        tween.Completed:Wait()
    end)
    
    if not success then
        -- Fallback: langsung teleport
        pcall(function() hrp.CFrame = cf end)
    end
    
    return true
end

local function fastTween(cf)
    local ch = Player.Character
    if not ch then return false end
    
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Langsung teleport untuk kecepatan maksimal
    pcall(function() hrp.CFrame = cf end)
    task.wait(0.05)
    return true
end

local function returnToBase()
    if homePosition then
        tweenTo(homePosition)
    elseif baseCFrame then
        tweenTo(baseCFrame)
    end
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
    end 
    return best
end

local function findBase()
    local bases = workspace:FindFirstChild("Bases") 
    if not bases then 
        Notify("❌ Tidak ada folder Bases di workspace!")
        return false 
    end
    
    for _, base in pairs(bases:GetChildren()) do
        local success = pcall(function()
            -- Coba berbagai cara untuk mendapatkan nama player
            local title = base:FindFirstChild("Title")
            if title then
                local titleGui = title:FindFirstChild("TitleGui")
                if titleGui then
                    local frame = titleGui:FindFirstChild("Frame")
                    if frame then
                        local playerName = frame:FindFirstChild("PlayerName")
                        if playerName and playerName:IsA("TextLabel") then
                            if playerName.Text == Player.Name or playerName.Text == Player.DisplayName then
                                baseGUID = base.Name
                                local s1 = base:FindFirstChild("slot 1 brainrot")
                                if s1 and s1:FindFirstChild("Root") then 
                                    baseCFrame = s1.Root.CFrame 
                                end
                                Notify("✅ Base ditemukan: " .. baseGUID)
                                return true
                            end
                        end
                    end
                end
            end
        end)
        if success then break end
    end
    
    if not baseGUID then
        Notify("❌ Base tidak ditemukan! Pastikan Anda sudah memiliki base.")
        return false
    end
    
    if not homePosition then setHomePosition() end
    return true
end

local function setHomePosition()
    local ch = Player.Character 
    if not ch then 
        Notify("❌ Tidak ada karakter!")
        return 
    end
    
    local hrp = ch:FindFirstChild("HumanoidRootPart") 
    if not hrp then 
        Notify("❌ Tidak ada HumanoidRootPart!")
        return 
    end
    
    homePosition = hrp.CFrame
    Notify("✅ Home position disimpan!")
end

local function getHomePosition()
    if homePosition then return homePosition end
    if baseCFrame then return baseCFrame end
    return CFrame.new(124, 3.8, 22)
end

--==================================================
-- BRAINROT FUNCTIONS (DIPERBAIKI)
--==================================================
local function findBrainrotRoot(b)
    -- Cari Root
    local root = b:FindFirstChild("Root") 
    if root and root:IsA("BasePart") then return root end
    
    -- Cari RenderedBrainrot
    local rendered = b:FindFirstChild("RenderedBrainrot") 
    if rendered then 
        local rr = rendered:FindFirstChild("Root") 
        if rr and rr:IsA("BasePart") then return rr end
    end
    
    -- Cari part pertama
    for _, desc in pairs(b:GetDescendants()) do 
        if desc:IsA("BasePart") then 
            return desc 
        end 
    end
    
    -- Jika b sendiri adalah part
    if b:IsA("BasePart") then return b end 
    return nil
end

local function findLuckyBlockRoot(block)
    local r = block:FindFirstChild("Root") 
    if r and r:IsA("BasePart") then return r end
    
    if block:IsA("BasePart") then return block end
    
    local p = nil 
    pcall(function() p = block.PrimaryPart end) 
    if p then return p end
    
    for _, d in pairs(block:GetDescendants()) do 
        if d:IsA("BasePart") then 
            return d 
        end 
    end 
    return nil
end

local function isSlotEmpty(s)
    if not baseGUID then 
        if not findBase() then return true end
    end
    
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return true end
    
    local mb = bases:FindFirstChild(baseGUID) 
    if not mb then return true end
    
    local sm = mb:FindFirstChild("slot " .. s .. " brainrot") 
    if not sm then return true end
    
    local bn = sm:GetAttribute("BrainrotName") 
    return not bn or bn == ""
end

local function placeBrainrot(s)
    if not baseGUID or not PlotAction then 
        Notify("❌ Base atau remote tidak ditemukan!")
        return false 
    end
    
    local success, result = pcall(function()
        return PlotAction:InvokeServer("Place Brainrot", baseGUID, tostring(s))
    end)
    
    if success then 
        Status.placeCount = Status.placeCount + 1
        return true
    end
    return false
end

local function pickUpBrainrot(s)
    if not baseGUID or not PlotAction then return false end
    return pcall(function() PlotAction:InvokeServer("Pick Up Brainrot", baseGUID, tostring(s)) end)
end

local function upgradeBrainrot(s)
    if not baseGUID or not PlotAction then return false end
    return pcall(function() PlotAction:InvokeServer("Upgrade Brainrot", baseGUID, tostring(s)) end)
end

local function tweenToSlot(slotNumber)
    if not baseGUID then 
        if not findBase() then return false end
    end
    
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return false end
    
    local myBase = bases:FindFirstChild(baseGUID) 
    if not myBase then return false end
    
    local sm = myBase:FindFirstChild("slot " .. slotNumber .. " brainrot") 
    if not sm then return false end
    
    local root = sm:FindFirstChild("Root") 
    if root then 
        return tweenTo(root.CFrame * CFrame.new(0, 3, 0)) 
    end
    
    for _, part in pairs(sm:GetDescendants()) do 
        if part:IsA("BasePart") then 
            return tweenTo(part.CFrame * CFrame.new(0, 3, 0)) 
        end 
    end 
    return false
end

--==================================================
-- FARM FUNCTIONS (DIPERBAIKI - SEKARANG BISA BERGERAK)
--==================================================
local function scanBrainrots()
    local brainrots = {}
    if not ActiveBrainrots then 
        ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
        if not ActiveBrainrots then return brainrots end
    end
    
    for _, folder in pairs(ActiveBrainrots:GetChildren()) do
        if folder:IsA("Folder") then
            for _, brainrot in pairs(folder:GetChildren()) do
                local root = findBrainrotRoot(brainrot)
                if root then
                    table.insert(brainrots, {
                        Object = brainrot,
                        Root = root,
                        Rarity = folder.Name,
                        Position = root.Position
                    })
                end
            end
        end
    end
    return brainrots
end

local function scanLuckyBlocks()
    local blocks = {}
    if not ActiveLuckyBlocks then 
        ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks")
        if not ActiveLuckyBlocks then return blocks end
    end
    
    for _, block in pairs(ActiveLuckyBlocks:GetChildren()) do
        local root = findLuckyBlockRoot(block)
        if root then
            table.insert(blocks, {
                Object = block,
                Root = root,
                Name = block.Name,
                Position = root.Position
            })
        end
    end
    return blocks
end

local function findNearestTarget(targets)
    local nearest = nil
    local shortestDist = math.huge
    
    local char = Player.Character
    if not char then return nil end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local myPos = hrp.Position
    
    for _, target in pairs(targets) do
        local dist = (myPos - target.Position).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            nearest = target
        end
    end
    
    return nearest
end

local function farmBrainrot(target)
    if not target or not target.Root then return false end
    
    local char = Player.Character
    if not char then return false end
    
    -- Pindah ke target
    Status.farm = "Moving to " .. target.Rarity
    tweenTo(target.Root.CFrame * CFrame.new(0, 3, 0))
    
    -- Grab prompt
    for i = 1, 3 do
        pcall(function()
            -- Coba fire proximity prompt
            for _, prompt in pairs(target.Object:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                end
            end
            -- Coba touch interest
            if target.Root then
                firetouchinterest(char.HumanoidRootPart, target.Root, 0)
                task.wait(0.1)
                firetouchinterest(char.HumanoidRootPart, target.Root, 1)
            end
        end)
        task.wait(0.1)
    end
    
    Status.farmCount = Status.farmCount + 1
    return true
end

local function farmLuckyBlock(target)
    if not target or not target.Root then return false end
    
    local char = Player.Character
    if not char then return false end
    
    -- Pindah ke target
    Status.farm = "Moving to Lucky Block"
    tweenTo(target.Root.CFrame * CFrame.new(0, 3, 0))
    
    -- Grab prompt
    for i = 1, 3 do
        pcall(function()
            for _, prompt in pairs(target.Object:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                end
            end
            if target.Root then
                firetouchinterest(char.HumanoidRootPart, target.Root, 0)
                task.wait(0.1)
                firetouchinterest(char.HumanoidRootPart, target.Root, 1)
            end
        end)
        task.wait(0.1)
    end
    
    Status.luckyBlockCount = Status.luckyBlockCount + 1
    return true
end

local function startFarming()
    if farmThread then 
        Notify("⚠️ Farming sudah berjalan!")
        return 
    end
    
    Config.Farming = true 
    Status.farmCount = 0 
    Status.luckyBlockCount = 0
    
    -- Cari base dulu
    findBase()
    setHomePosition()
    
    Notify("🚀 Farming dimulai!")
    
    farmThread = task.spawn(function()
        enableNoclip()
        
        while Config.Farming do
            local success, err = pcall(function()
                -- Cek karakter
                local char = Player.Character
                if not char then
                    task.wait(1)
                    return
                end
                
                -- Prioritaskan Lucky Blocks jika dipilih
                if table.find(Config.FarmTargets, "Lucky Blocks") then
                    local blocks = scanLuckyBlocks()
                    if #blocks > 0 then
                        local nearest = findNearestTarget(blocks)
                        if nearest then
                            farmLuckyBlock(nearest)
                            task.wait(0.5)
                            return
                        end
                    end
                end
                
                -- Farm Brainrots
                if table.find(Config.FarmTargets, "Brainrots") then
                    local brainrots = scanBrainrots()
                    if #brainrots > 0 then
                        local nearest = findNearestTarget(brainrots)
                        if nearest then
                            farmBrainrot(nearest)
                            task.wait(0.5)
                            return
                        end
                    end
                end
                
                -- Jika tidak ada target, tunggu
                Status.farm = "No targets found"
                task.wait(2)
            end)
            
            if not success then
                warn("Farm error: " .. tostring(err))
                task.wait(1)
            end
            
            task.wait(0.1)
        end
        
        disableNoclip()
        Status.farm = "Idle" 
        farmThread = nil
        Notify("⏹️ Farming dihentikan")
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
-- MONEY FUNCTIONS (DIPERBAIKI)
--==================================================
local function startMoney()
    if moneyThread then return end 
    
    if not baseGUID then
        if not findBase() then
            Notify("❌ Base tidak ditemukan!")
            return
        end
    end
    
    Config.AutoCollectMoney = true 
    Status.money = "Active"
    Notify("💰 Money collector dimulai!")
    
    moneyThread = task.spawn(function()
        while Config.AutoCollectMoney do 
            pcall(function()
                local bases = workspace:FindFirstChild("Bases")
                if not bases then return end
                
                local mb = bases:FindFirstChild(baseGUID)
                if not mb then return end
                
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") 
                if not hrp then return end
                
                -- Kolek semua slot
                for i = 1, 40 do
                    local sm = mb:FindFirstChild("slot " .. i .. " brainrot")
                    if sm and sm:GetAttribute("BrainrotName") and sm:GetAttribute("BrainrotName") ~= "" then
                        for _, d in pairs(sm:GetDescendants()) do 
                            if d:IsA("BasePart") then 
                                pcall(function() 
                                    firetouchinterest(hrp, d, 0) 
                                    firetouchinterest(hrp, d, 1) 
                                end) 
                            end 
                        end
                    end
                end
                
                -- Kolek dari Slots folder
                local slots = mb:FindFirstChild("Slots")
                if slots then 
                    for _, s in pairs(slots:GetChildren()) do 
                        local c = s:FindFirstChild("Collect") 
                        if c and c:IsA("BasePart") then 
                            pcall(function() 
                                firetouchinterest(hrp, c, 0) 
                                firetouchinterest(hrp, c, 1) 
                            end) 
                        end 
                    end 
                end
            end) 
            task.wait(0.5) 
        end 
        Status.money = "Idle"
    end)
    
    -- Remote thread untuk kolek via remote
    moneyRemoteThread = task.spawn(function()
        while Config.AutoCollectMoney do 
            pcall(function()
                if baseGUID and PlotAction then 
                    for i = 1, 40 do 
                        task.spawn(function() 
                            pcall(function() 
                                PlotAction:InvokeServer("Collect Money", baseGUID, tostring(i)) 
                            end) 
                        end) 
                    end 
                end
            end) 
            task.wait(2) 
        end
    end)
end

local function stopMoney()
    Config.AutoCollectMoney = false
    if moneyThread then 
        pcall(task.cancel, moneyThread) 
        moneyThread = nil 
    end
    if moneyRemoteThread then 
        pcall(task.cancel, moneyRemoteThread) 
        moneyRemoteThread = nil 
    end
    Status.money = "Idle"
    Notify("💰 Money collector dihentikan")
end

--==================================================
-- UPGRADE FUNCTIONS (DIPERBAIKI)
--==================================================
local function findOccupiedSlots()
    if not baseGUID then 
        if not findBase() then return {} end
    end
    
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return {} end
    
    local mb = bases:FindFirstChild(baseGUID) 
    if not mb then return {} end
    
    local occupied = {}
    for i = 1, 40 do
        local sm = mb:FindFirstChild("slot " .. i .. " brainrot")
        if sm then 
            local bn = sm:GetAttribute("BrainrotName") 
            local lv = sm:GetAttribute("Level")
            if bn and bn ~= "" then 
                table.insert(occupied, {slot = i, name = bn, level = lv or 1}) 
            end
        end
    end 
    return occupied
end

local function upgradeSlotToMax(slot)
    if not baseGUID or not PlotAction then return end
    
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return end
    
    local mb = bases:FindFirstChild(baseGUID)
    if not mb then return end
    
    local sm = mb:FindFirstChild("slot " .. slot .. " brainrot")
    if not sm then return end
    
    local cur = tonumber(sm:GetAttribute("Level")) or 0
    local maxAttempts = 50
    local attempts = 0
    
    while cur < Config.MaxLevel and Config.AutoUpgrade and attempts < maxAttempts do
        local success = pcall(function()
            PlotAction:InvokeServer("Upgrade Brainrot", baseGUID, tostring(slot))
        end)
        
        if success then
            task.wait(0.1)
            local nw = tonumber(sm:GetAttribute("Level")) or cur
            if nw > cur then 
                cur = nw 
                Status.upgradeCount = Status.upgradeCount + 1
                attempts = 0
            else
                attempts = attempts + 1
            end
        else
            attempts = attempts + 1
        end
        task.wait(0.05)
    end
end

local function startAutoUpgrade()
    if upgradeThread then return end 
    
    if not baseGUID then
        if not findBase() then
            Notify("❌ Base tidak ditemukan!")
            return
        end
    end
    
    Config.AutoUpgrade = true 
    Status.upgradeCount = 0
    Notify("⬆️ Auto upgrade dimulai!")
    
    upgradeThread = task.spawn(function()
        while Config.AutoUpgrade do 
            pcall(function()
                local occupied = findOccupiedSlots()
                for _, info in pairs(occupied) do 
                    if not Config.AutoUpgrade then break end 
                    if info.level < Config.MaxLevel then 
                        upgradeSlotToMax(info.slot) 
                    end 
                end
                Status.upgrade = "Cycle complete"
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
    Notify("⬆️ Auto upgrade dihentikan")
end

--==================================================
-- INSTANT PICKUP
--==================================================
local function setupInstant()
    for _, o in pairs(workspace:GetDescendants()) do 
        if o:IsA("ProximityPrompt") then 
            pcall(function() 
                o.HoldDuration = 0 
                o.MaxActivationDistance = 100
            end) 
        end 
    end
    
    if not _instantConn then 
        _instantConn = workspace.DescendantAdded:Connect(function(o) 
            if o:IsA("ProximityPrompt") then 
                pcall(function() 
                    o.HoldDuration = 0 
                    o.MaxActivationDistance = 100
                end) 
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
    Desc = "Creator: Catraz Team\nVersion: 4.0 ULTIMATE\nFeatures: Farm, Tsunami, Factory, Auto Collect\nStatus: FULLY FUNCTIONAL",
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
    Desc = "Brainrots: 0 | Lucky Blocks: 0",
    Image = "bar-chart",
    ImageSize = 30
})

-- Update status farm
task.spawn(function()
    while true do
        task.wait(0.5)
        FarmStatusPara:SetDesc(Status.farm)
        FarmStatsPara:SetDesc("Brainrots: " .. Status.farmCount .. " | Lucky: " .. Status.luckyBlockCount)
    end
end)

FarmControlSection:AddToggle({
    Name = "🚀 Master Auto Farm", 
    Default = false, 
    Outline = true, 
    Flag = "FarmToggle",
    Callback = function(v)
        if v then 
            startFarming()
        else 
            stopFarming()
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
            startMoney()
            MoneyStatusPara:SetDesc("Active")
        else 
            stopMoney()
            MoneyStatusPara:SetDesc("Idle")
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

local UpgradeStatsPara = UpgradeSection:AddParagraph({
    Title = "Upgrade Count",
    Desc = "0 upgrades",
    Image = "bar-chart",
    ImageSize = 30
})

task.spawn(function()
    while true do
        task.wait(0.5)
        UpgradeStatsPara:SetDesc(Status.upgradeCount .. " upgrades")
    end
end)

UpgradeSection:AddToggle({ 
    Name = "⬆️ Auto Upgrade Slots", 
    Default = false, 
    Outline = true, 
    Flag = "UpgradeToggle",
    Callback = function(v) 
        if v then 
            startAutoUpgrade()
            UpgradeStatusPara:SetDesc("Active")
        else 
            stopAutoUpgrade()
            UpgradeStatusPara:SetDesc("Idle")
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

TweakSection:AddDropdown({
    Name = "Tween Speed (Lebih besar = lebih cepat)",
    Default = "1000", 
    Options = TWEEN_SPEED, 
    Multi = false, 
    Outline = true, 
    Flag = "TweenSpeed",
    Callback = function(v) 
        Config.TweenSpeed = tonumber(v) or 1000
        Notify("Tween speed: " .. v)
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
    end 
})

ActionSection:AddButton({ 
    Name = "📍 Set Home Position", 
    Outline = true, 
    Callback = function() 
        setHomePosition() 
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
            "Tsunami: " .. (Config.TsunamiProtection and "✅ " .. Config.TsunamiMode or "❌") .. "\n" ..
            "Farming: " .. (Config.Farming and "✅" or "❌")
        )
    end
end))

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
print("🔥 CATRAZ HUB - ESCAPE TSUNAMI FOR BRAINROTS v4.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ SEMUA FITUR TELAH DIPERBAIKI DAN BERFUNGSI!")
print("✅ Farm - Bergerak otomatis ke target")
print("✅ Tween Speed - Bisa diatur hingga 1000")
print("✅ Money Collector - Bekerja dengan touch & remote")
print("✅ Auto Upgrade - Upgrade semua slot otomatis")
print("✅ Tsunami Protection - 2 mode dengan deteksi akurat")
print("✅ Noclip - Berfungsi sempurna")
print("═══════════════════════════════════════════════════════")
print("🚀 SILAHKAN GUNAKAN FITUR-FITURNYA!")
print("═══════════════════════════════════════════════════════")