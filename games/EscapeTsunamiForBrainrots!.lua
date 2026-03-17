-- [[ 📡 CATRAZ ANALYTICS SYSTEM (LIVE SERVER) ]] --
task.spawn(function()
    local BackendURL = "http://bot-service-asia-se-02.cybrancee.com:5023"
    local ScriptName = "Escape Tsunami For Brainrots"
    local ExecutorName = "Unknown"

    if identifyexecutor then ExecutorName = identifyexecutor() end
    local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

    if HttpRequest then
        pcall(function()
            local BodyJson = game:GetService("HttpService"):JSONEncode({
                ["script"] = ScriptName,
                ["executor"] = ExecutorName
            })
            HttpRequest({
                Url = BackendURL .. "/ping",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "CatrazHub/Client" },
                Body = BodyJson
            })
        end)
    end
end)

getgenv().MzD = {}
local M = getgenv().MzD

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LPlayer = Players.LocalPlayer
local Player = LPlayer
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

-- ========== INIT ==========
M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
if not M.ActiveBrainrots then task.spawn(function() M.ActiveBrainrots = workspace:WaitForChild("ActiveBrainrots", 15) end) end

M.ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks")
if not M.ActiveLuckyBlocks then task.spawn(function() M.ActiveLuckyBlocks = workspace:WaitForChild("ActiveLuckyBlocks", 15) end) end

M.PlotAction = nil
pcall(function()
    M.PlotAction = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("Net", 10):WaitForChild("RF/Plot.PlotAction", 10)
end)

-- ========== TSUNAMI DETECTION ==========
M.Tsunami = {
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

-- Fungsi untuk mendeteksi tsunami
function M.detectTsunami()
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
function M.createTsunamiDetector()
    if M.Tsunami.DetectionPart and M.Tsunami.DetectionPart.Parent then
        pcall(function() M.Tsunami.DetectionPart:Destroy() end)
    end
    
    local detector = Instance.new("Part")
    detector.Name = "TsunamiDetector"
    detector.Size = Vector3.new(100, 100, 100)
    detector.Transparency = 1
    detector.CanCollide = false
    detector.Anchored = true
    detector.Parent = Workspace
    
    M.Tsunami.DetectionPart = detector
    return detector
end

-- Fungsi untuk mendapatkan ketinggian aman
function M.getSafeHeight()
    if M.Tsunami.Mode == "Bawah" then
        return -50
    else
        return M.Tsunami.Height
    end
end

-- Fungsi untuk terbang menghindari tsunami
function M.enableTsunamiFlight()
    if M.Tsunami.IsFlying then return end
    
    local char = Player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
    end
    
    if M.Tsunami.BodyVelocity then
        pcall(function() M.Tsunami.BodyVelocity:Destroy() end)
    end
    if M.Tsunami.BodyGyro then
        pcall(function() M.Tsunami.BodyGyro:Destroy() end)
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
    
    M.Tsunami.BodyVelocity = bv
    M.Tsunami.BodyGyro = bg
    M.Tsunami.IsFlying = true
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    if M.Tsunami.FlyConnection then
        M.Tsunami.FlyConnection:Disconnect()
    end
    
    M.Tsunami.FlyConnection = RunService.Heartbeat:Connect(function()
        if not M.Tsunami.Enabled then
            M.disableTsunamiFlight()
            return
        end
        
        local currentChar = Player.Character
        if not currentChar then
            M.disableTsunamiFlight()
            return
        end
        
        local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHrp then return end
        
        local targetY = M.getSafeHeight()
        local currentY = currentHrp.Position.Y
        
        if math.abs(currentY - targetY) < 2 then
            if M.Tsunami.BodyVelocity then
                M.Tsunami.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        else
            local direction = (targetY > currentY) and 1 or -1
            if M.Tsunami.BodyVelocity then
                M.Tsunami.BodyVelocity.Velocity = Vector3.new(0, direction * 50, 0)
            end
        end
        
        if M.Tsunami.BodyGyro then
            M.Tsunami.BodyGyro.CFrame = CFrame.new(currentHrp.Position, currentHrp.Position + Vector3.new(0, 0, -1))
        end
        
        for _, part in pairs(currentChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function M.disableTsunamiFlight()
    if M.Tsunami.FlyConnection then
        M.Tsunami.FlyConnection:Disconnect()
        M.Tsunami.FlyConnection = nil
    end
    
    if M.Tsunami.BodyVelocity then
        pcall(function() M.Tsunami.BodyVelocity:Destroy() end)
        M.Tsunami.BodyVelocity = nil
    end
    
    if M.Tsunami.BodyGyro then
        pcall(function() M.Tsunami.BodyGyro:Destroy() end)
        M.Tsunami.BodyGyro = nil
    end
    
    M.Tsunami.IsFlying = false
    
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
        
        if not M.S.NoclipEnabled then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not M.isOwnWallPart(part) then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Fungsi untuk mengaktifkan sistem tsunami
function M.enableTsunamiProtection()
    if M.Tsunami.Connection then
        M.Tsunami.Connection:Disconnect()
    end
    
    M.Tsunami.Enabled = true
    M.createTsunamiDetector()
    
    M.Tsunami.Connection = RunService.Heartbeat:Connect(function()
        if not M.Tsunami.Enabled then return end
        
        local tsunami = M.detectTsunami()
        local char = Player.Character
        if not char or not tsunami then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local tsunamiPos = tsunami.Position
        local playerPos = hrp.Position
        local distance = (playerPos - tsunamiPos).Magnitude
        
        if M.Tsunami.Mode == "Bawah" then
            if playerPos.Y > -40 and distance < 100 then
                M.enableTsunamiFlight()
            end
        else
            if playerPos.Y < M.Tsunami.Height - 10 and distance < 100 then
                M.enableTsunamiFlight()
            end
        end
        
        if M.Tsunami.DetectionPart then
            M.Tsunami.DetectionPart.Position = Vector3.new(playerPos.X, M.getSafeHeight(), playerPos.Z)
        end
        
        M.Tsunami.LastTsunamiPos = tsunamiPos
    end)
end

function M.disableTsunamiProtection()
    M.Tsunami.Enabled = false
    if M.Tsunami.Connection then
        M.Tsunami.Connection:Disconnect()
        M.Tsunami.Connection = nil
    end
    M.disableTsunamiFlight()
    if M.Tsunami.DetectionPart then
        pcall(function() M.Tsunami.DetectionPart:Destroy() end)
        M.Tsunami.DetectionPart = nil
    end
end

-- ========== SETTINGS ==========
M.S = {
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
    ValentineEnabled = false,
    ArcadeEnabled = false,
    MapFixerEnabled = false,
    NoclipEnabled = false,
    GodEnabled = false,
    FarmCapacity = 1,
    TsunamiProtection = false,
    TsunamiMode = "Bawah"
}

M.Status = {
    farm = "Idle", farmCount = 0, luckyBlockCount = 0,
    money = "Idle",
    afk = "Off",
    placeCount = 0, upgradeCount = 0,
    upgrade = "Idle",
    factory = "Idle", factoryCount = 0,
    valentine = "Idle", valentineCount = 0,
    arcade = "Idle", arcadeCount = 0,
    mapFixer = "Off",
    tsunami = "Off"
}

-- ========== STATE ==========
M.baseGUID = nil
M.baseCFrame = nil
M.homePosition = nil
M.farmThread = nil
M.factoryThread = nil
M.moneyThread = nil
M.moneyRemoteThread = nil
M.afkThread = nil
M._afkSteppedConn = nil
M._instantConn = nil
M.upgradeThread = nil
M.valentineThread = nil
M.valentineCollectorConn = nil
M.valentineTurboThread = nil
M.valentineNoclipConn = nil
M._valentineDescAddedConn = nil
M.arcadeThread = nil
M.mapFixerThread = nil
M._valentineCachedParts = {}
M._valentineLastCacheScan = 0
M._noclipConn = nil
M._godThread = nil
M._isGod = false
M._healthConn = nil
M._wallZ_front = 173
M._wallZ_back = -173

local HIGH_RARITIES = {["Celestial"] = true, ["Divine"] = true, ["Infinity"] = true}

-- ========== CORE FUNCTIONS ==========
function M.isOwnWallPart(part)
    if not part then return false end
    local p = part.Parent
    while p do if p.Name == "MzDHubWalls" then return true end p = p.Parent end
    return false
end

function M.enableNoclip()
    if M._noclipConn then return end
    M.S.NoclipEnabled = true
    M._noclipConn = RunService.Stepped:Connect(function()
        if not M.S.NoclipEnabled then return end
        pcall(function()
            local ch = Player.Character if not ch then return end
            for _, p in pairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and not M.isOwnWallPart(p) then p.CanCollide = false end
            end
        end)
    end)
end

function M.disableNoclip()
    M.S.NoclipEnabled = false
    if M._noclipConn then pcall(function() M._noclipConn:Disconnect() end) M._noclipConn = nil end
    pcall(function()
        local ch = Player.Character if not ch then return end
        for _, p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end)
end

function M.mapFindCurrentMap()
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

function M.detectWallZ()
    local map = M.mapFindCurrentMap() if not map then return end
    local mzwalls = map:FindFirstChild("MzDHubWalls") if not mzwalls then return end
    local fw = mzwalls:FindFirstChild("FrontWall_1")
    local bw = mzwalls:FindFirstChild("BackWall_1")
    if fw then M._wallZ_front = fw.Position.Z - fw.Size.Z / 2 - 3 end
    if bw then M._wallZ_back = bw.Position.Z + bw.Size.Z / 2 + 3 end
end

function M.getCorridorZ()
    M.detectWallZ()
    local homePos = M.getHomePosition().Position
    if homePos.Z >= 0 then return M._wallZ_front else return M._wallZ_back end
end

function M.findBase()
    local bases = workspace:FindFirstChild("Bases") if not bases then return end
    for _, base in pairs(bases:GetChildren()) do
        pcall(function()
            local pn = base.Title.TitleGui.Frame.PlayerName
            if pn.Text == Player.Name or pn.Text == Player.DisplayName then
                M.baseGUID = base.Name
                local s1 = base:FindFirstChild("slot 1 brainrot")
                if s1 and s1:FindFirstChild("Root") then M.baseCFrame = s1.Root.CFrame end
            end
        end)
    end
    if not M.homePosition then M.setHomePosition() end
end

function M.setHomePosition()
    local ch = Player.Character if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return end
    M.homePosition = hrp.CFrame
end

function M.getHomePosition()
    if M.homePosition then return M.homePosition end
    if M.baseCFrame then return M.baseCFrame end
    return CFrame.new(124, 3.8, 22)
end

task.spawn(function() task.wait(3) M.findBase() end)

Player.CharacterAdded:Connect(function()
    task.wait(1.5)
    if M.S.InstantPickup then M.setupInstant() end
    task.wait(0.5) M.detectWallZ()
    if M.S.NoclipEnabled then
        if M._noclipConn then pcall(function() M._noclipConn:Disconnect() end) M._noclipConn = nil end
        M.S.NoclipEnabled = false task.wait(0.3) M.enableNoclip()
    end
    if M.S.TsunamiProtection then
        task.wait(1)
        M.enableTsunamiProtection()
    end
end)

function M.tweenTo(cf)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local d = (hrp.Position - cf.Position).Magnitude
    local speed = tonumber(M.S.TweenSpeed) or 1000
    if speed <= 0 then speed = 1000 end
    local t = math.max(d / speed, 0.05)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play() 
    tw.Completed:Wait()
    return true
end

function M.fastTween(cf)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local d = (hrp.Position - cf.Position).Magnitude
    local t = math.max(d / 9999, 0.01)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play() 
    tw.Completed:Wait()
    return true
end

function M.returnToBase() M.tweenTo(M.getHomePosition()) task.wait(0.1) end

function M.undergroundPathTo(targetCFrame)
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local bv = hrp:FindFirstChild("AntiFallMzD")
    if not bv then
        bv = Instance.new("BodyVelocity") 
        bv.Name = "AntiFallMzD" 
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0) 
        bv.Parent = hrp
    end
    local startPos = hrp.Position 
    local endPos = targetCFrame.Position 
    local DEEP_Y = -25
    M.fastTween(CFrame.new(startPos.X, DEEP_Y, startPos.Z)) 
    task.wait(0.05)
    M.tweenTo(CFrame.new(endPos.X, DEEP_Y, endPos.Z)) 
    task.wait(0.05)
    M.tweenTo(targetCFrame) 
    task.wait(0.05) 
    return true
end

function M.undergroundReturnToBase()
    local ch = Player.Character if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") if not hrp then return false end
    local curPos = hrp.Position 
    local homePos = M.getHomePosition().Position 
    local DEEP_Y = -25
    local bv = hrp:FindFirstChild("AntiFallMzD")
    if not bv then 
        bv = Instance.new("BodyVelocity") 
        bv.Name = "AntiFallMzD" 
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
        bv.Velocity = Vector3.new(0, 0, 0) 
        bv.Parent = hrp 
    end
    M.fastTween(CFrame.new(curPos.X, DEEP_Y, curPos.Z)) 
    task.wait(0.05)
    M.tweenTo(CFrame.new(homePos.X, DEEP_Y, homePos.Z)) 
    task.wait(0.05)
    M.tweenTo(M.getHomePosition()) 
    task.wait(0.05)
    if bv then bv:Destroy() end 
    return true
end

function M.isHighRarity(r) return HIGH_RARITIES[r] == true end

function M.isDead()
    local ch = Player.Character if not ch then return true end
    local hum = ch:FindFirstChild("Humanoid") if not hum then return true end
    return hum.Health <= 0
end

function M.waitForRespawn()
    if not M.isDead() then return true end
    local timeout = tick() + 15
    while M.isDead() and tick() < timeout do task.wait(0.2) end
    task.wait(1) return not M.isDead()
end

function M.forceGrabPrompt(target)
    if not target then return end
    local prompts = {}
    if target:IsA("ProximityPrompt") then 
        table.insert(prompts, target)
    else 
        for _, d in pairs(target:GetDescendants()) do 
            if d:IsA("ProximityPrompt") then 
                table.insert(prompts, d) 
            end 
        end 
    end
    
    for _, p in pairs(prompts) do
        pcall(function() 
            p.MaxActivationDistance = 99999 
            p.HoldDuration = 0 
        end)
        pcall(function() fireproximityprompt(p) end) 
        pcall(function() fireproximityprompt(p) end)
    end
    
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local parent = target 
        if parent:IsA("ProximityPrompt") then 
            parent = parent.Parent 
        end
        if parent and parent:IsA("BasePart") then 
            pcall(function() 
                firetouchinterest(hrp, parent, 0) 
                firetouchinterest(hrp, parent, 1) 
            end) 
        end
        local searchRoot = parent 
        if searchRoot and searchRoot.Parent and not searchRoot.Parent:IsA("Workspace") then 
            searchRoot = searchRoot.Parent 
        end
        if searchRoot then 
            for _, d in pairs(searchRoot:GetDescendants()) do 
                if d:IsA("BasePart") then 
                    pcall(function() 
                        firetouchinterest(hrp, d, 0) 
                        firetouchinterest(hrp, d, 1) 
                    end) 
                end 
            end 
        end
    end 
    task.wait(0.04)
end

function M.getTargetRarities() return type(M.S.TargetRarity) == "table" and M.S.TargetRarity or {M.S.TargetRarity} end

function M.rarityMatches(fn) 
    for _, r in pairs(M.getTargetRarities()) do 
        if r == "Any" or r == fn then 
            return true 
        end 
    end 
    return false 
end

function M.getBrainrotNames(rarity)
    local names, seen = {}, {}
    if not M.ActiveBrainrots then M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots") end
    if not M.ActiveBrainrots then return names end
    for _, f in pairs(M.ActiveBrainrots:GetChildren()) do
        if f:IsA("Folder") and (rarity == "Any" or f.Name == rarity) then
            for _, b in pairs(f:GetChildren()) do
                local n = b:FindFirstChild("RenderedBrainrot") and b.RenderedBrainrot:GetAttribute("BrainrotName") or b:GetAttribute("BrainrotName") or b.Name
                if n and n ~= "" and not seen[n] then 
                    seen[n] = true 
                    table.insert(names, n) 
                end
            end
        end
    end 
    table.sort(names) 
    return names
end

function M.matchesFilter(b, folderRarity)
    if not M.rarityMatches(folderRarity) then return false end
    if M.isHighRarity(folderRarity) then return true end
    local mut = b:GetAttribute("Mutation") or "None" 
    local isNone = (mut:lower() == "none" or mut == "")
    if M.S.TargetMutation == "None" then 
        if not isNone then return false end 
    elseif M.S.TargetMutation ~= "Any" then 
        if mut ~= M.S.TargetMutation then return false end 
    end
    return true
end

function M.toolMatchesRarity(tool, targetRarity, targetMutation)
    local tMut = tool:GetAttribute("Mutation") or "None" 
    local lvl = tonumber(tool:GetAttribute("Level")) or 0
    local bName = tool:GetAttribute("BrainrotName") 
    local toolRarity = tool:GetAttribute("Rarity")
    if not bName or bName == "" or lvl >= M.S.MaxLevel then return false end
    local tR = type(targetRarity) == "table" and targetRarity or {targetRarity}
    if toolRarity and M.isHighRarity(toolRarity) then
        for _, r in pairs(tR) do 
            if r == "Any" or r == toolRarity then 
                return true 
            end 
        end 
        return false
    end
    if targetMutation == "None" then 
        if not (tMut:lower() == "none" or tMut == "") then return false end
    elseif targetMutation ~= "Any" then 
        if tMut ~= targetMutation then return false end 
    end
    local isAny = false 
    for _, r in pairs(tR) do 
        if r == "Any" then 
            isAny = true 
            break 
        end 
    end
    if not isAny then
        if toolRarity and toolRarity ~= "" then
            local m = false 
            for _, r in pairs(tR) do 
                if toolRarity == r then 
                    m = true 
                    break 
                end 
            end 
            if not m then return false end
        else
            local wl = {} 
            for _, r in pairs(tR) do 
                for _, n in pairs(M.getBrainrotNames(r)) do 
                    wl[n] = true 
                end 
            end
            if not wl[bName] then return false end
        end
    end 
    return true
end

function M.findTargetToolInBackpack()
    local bp = Player:FindFirstChild("Backpack")
    if bp then 
        for _, t in pairs(bp:GetChildren()) do 
            if t:IsA("Tool") and M.toolMatchesRarity(t, M.S.TargetRarity, M.S.TargetMutation) then 
                return t 
            end 
        end 
    end
    local ch = Player.Character 
    if ch then 
        local eq = ch:FindFirstChildWhichIsA("Tool") 
        if eq and M.toolMatchesRarity(eq, M.S.TargetRarity, M.S.TargetMutation) then 
            return eq 
        end 
    end
    return nil
end

function M.findBrainrotRoot(b)
    local root = b:FindFirstChild("Root") 
    if root and root:IsA("BasePart") then return root end
    local rendered = b:FindFirstChild("RenderedBrainrot") 
    if rendered then 
        local rr = rendered:FindFirstChild("Root") 
        if rr and rr:IsA("BasePart") then return rr end 
    end
    for _, desc in pairs(b:GetDescendants()) do 
        if desc:IsA("BasePart") then 
            return desc 
        end 
    end
    if b:IsA("BasePart") then return b end 
    return nil
end

function M.isSlotEmpty(s)
    if not M.baseGUID then M.findBase() end 
    if not M.baseGUID then return true end
    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID) 
    if not mb then return true end
    local sm = mb:FindFirstChild("slot " .. s .. " brainrot") 
    if not sm then return true end
    local bn = sm:GetAttribute("BrainrotName") 
    return not bn or bn == ""
end

function M.findOccupiedSlots()
    if not M.baseGUID then M.findBase() end 
    if not M.baseGUID then return {} end
    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID) 
    if not mb then return {} end
    local o = {}
    for i = 1, 40 do
        local sm = mb:FindFirstChild("slot " .. i .. " brainrot")
        if sm then 
            local bn = sm:GetAttribute("BrainrotName") 
            local lv = sm:GetAttribute("Level")
            if bn and bn ~= "" then 
                table.insert(o, {slot = i, name = bn, level = lv or 1}) 
            end
        end
    end 
    return o
end

function M.placeBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    local ok = pcall(function() M.PlotAction:InvokeServer("Place Brainrot", M.baseGUID, tostring(s)) end)
    if ok then M.Status.placeCount = M.Status.placeCount + 1 end 
    return ok
end

function M.pickUpBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    return pcall(function() M.PlotAction:InvokeServer("Pick Up Brainrot", M.baseGUID, tostring(s)) end)
end

function M.upgradeBrainrot(s)
    if not M.baseGUID or not M.PlotAction then return false end
    return pcall(function() M.PlotAction:InvokeServer("Upgrade Brainrot", M.baseGUID, tostring(s)) end)
end

function M.tweenToSlot(slotNumber)
    if not M.baseGUID then M.findBase() end 
    if not M.baseGUID then return false end
    local myBase = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID) 
    if not myBase then return false end
    local sm = myBase:FindFirstChild("slot " .. slotNumber .. " brainrot") 
    if not sm then return false end
    local root = sm:FindFirstChild("Root") 
    if root then 
        return M.tweenTo(root.CFrame * CFrame.new(0, 3, 0)) 
    end
    for _, part in pairs(sm:GetDescendants()) do 
        if part:IsA("BasePart") then 
            return M.tweenTo(part.CFrame * CFrame.new(0, 3, 0)) 
        end 
    end 
    return false
end

function M.isHighRarityTool(tool)
    if not tool then return false end 
    local r = tool:GetAttribute("Rarity") or "" 
    if HIGH_RARITIES[r] then return true end
    local bName = tool:GetAttribute("BrainrotName") or ""
    if M.ActiveBrainrots then
        for _, folder in pairs(M.ActiveBrainrots:GetChildren()) do
            if HIGH_RARITIES[folder.Name] then 
                for _, b in pairs(folder:GetChildren()) do 
                    if (b:GetAttribute("BrainrotName") or "") == bName then 
                        return true 
                    end 
                end 
            end
        end
    end 
    return false
end

-- ================= NEW MASTER FARM SYSTEM =================
function M.getLuckyBlockRarities() 
    return type(M.S.LuckyBlockRarity) == "table" and M.S.LuckyBlockRarity or {M.S.LuckyBlockRarity} 
end

function M.luckyBlockRarityMatches(bn) 
    for _, r in pairs(M.getLuckyBlockRarities()) do 
        if r == "Any" or bn:find("" .. r) or bn == r then 
            return true 
        end 
    end 
    return false 
end

function M.luckyBlockMutationMatches(block)
    local mut = block:GetAttribute("Mutation") or "None" 
    local isNone = (mut:lower() == "none" or mut == "")
    if M.S.LuckyBlockMutation == "Any" then return true end 
    if M.S.LuckyBlockMutation == "None" then return isNone end
    return mut == M.S.LuckyBlockMutation
end

function M.luckyBlockGetRarityFromName(bn) 
    return bn:match("LuckyBlock_(.+)") or bn 
end

function M.findLuckyBlockRoot(block)
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

function M.hasFarmTarget(targetName)
    for _, v in pairs(M.S.FarmTargets) do 
        if v == targetName then 
            return true 
        end 
    end
    return false
end

function M.startFarming()
    if M.farmThread then return end
    M.S.Farming = true 
    M.Status.farmCount = 0 
    M.Status.luckyBlockCount = 0
    M.setHomePosition() 
    M.detectWallZ() 
    M.returnToBase() 
    M.enableNoclip()

    M.farmThread = task.spawn(function()
        local currentBackpackCount = 0
        local maxBackpackCount = M.S.FarmCapacity or 1

        while M.S.Farming do
            local ok, err = pcall(function()
                if M.isDead() then
                    M.Status.farm = "Dead! Waiting..."
                    M.waitForRespawn() 
                    task.wait(1) 
                    M.setHomePosition() 
                    task.wait(0.5) 
                    currentBackpackCount = 0 
                    return
                end
                local ch = Player.Character 
                local hum = ch and ch:FindFirstChild("Humanoid")
                if not ch or not hum then 
                    task.wait(1) 
                    return 
                end
                
                if M.hasFarmTarget("Lucky Blocks") then
                    if not M.ActiveLuckyBlocks then 
                        M.ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks") 
                    end
                    if M.ActiveLuckyBlocks then
                        local foundLB = false
                        for _, block in pairs(M.ActiveLuckyBlocks:GetChildren()) do
                            if not M.S.Farming or M.isDead() then break end
                            if M.luckyBlockRarityMatches(block.Name) and M.luckyBlockMutationMatches(block) then
                                local rootPart = M.findLuckyBlockRoot(block) 
                                if not rootPart then continue end
                                foundLB = true
                                local rarityName = M.luckyBlockGetRarityFromName(block.Name)
                                
                                M.Status.farm = "Opening LB " .. rarityName .. "..." 
                                M.undergroundPathTo(rootPart.CFrame * CFrame.new(0, 3, 0))
                                
                                for attempt = 1, 5 do
                                    if not M.S.Farming then break end
                                    if M.isDead() then 
                                        M.waitForRespawn() 
                                        task.wait(1) 
                                        M.setHomePosition() 
                                        if rootPart and rootPart.Parent then 
                                            M.undergroundPathTo(rootPart.CFrame * CFrame.new(0, 3, 0)) 
                                        else 
                                            break 
                                        end
                                    end
                                    if rootPart and rootPart.Parent then 
                                        M.forceGrabPrompt(block) 
                                        task.wait(0.04) 
                                        M.forceGrabPrompt(rootPart) 
                                        task.wait(0.04)
                                        if not block.Parent or not rootPart.Parent then 
                                            M.Status.luckyBlockCount = M.Status.luckyBlockCount + 1 
                                        end 
                                        break
                                    else 
                                        break 
                                    end
                                end
                                pcall(function() hum:UnequipTools() end) 
                                task.wait(0.04)
                                
                                local hrp = ch:FindFirstChild("HumanoidRootPart")
                                if hrp then 
                                    M.fastTween(CFrame.new(hrp.Position.X, -25, hrp.Position.Z)) 
                                end
                                
                                M.Status.farm = "LB Secured. Returning underground..." 
                                M.undergroundReturnToBase() 
                                return
                            end
                        end
                        if foundLB then return end 
                    end
                end

                if M.hasFarmTarget("Brainrots") then
                    if not M.baseGUID then M.findBase() end
                    if not M.baseGUID then 
                        M.Status.farm = "No base found!" 
                        task.wait(2) 
                        return 
                    end
                    local ws = tonumber(M.S.FarmSlot) or 5

                    if M.S.FarmMode == "Collect" then
                        M.Status.farm = "Searching Brainrots..."
                        if not M.ActiveBrainrots then 
                            M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots") 
                        end
                        if M.ActiveBrainrots then
                            for _, folder in pairs(M.ActiveBrainrots:GetChildren()) do
                                if not M.S.Farming then break end
                                if folder:IsA("Folder") and M.rarityMatches(folder.Name) then
                                    for _, b in pairs(folder:GetChildren()) do
                                        if not M.S.Farming or M.isDead() then break end
                                        if M.matchesFilter(b, folder.Name) then
                                            local root = M.findBrainrotRoot(b) 
                                            if not root then continue end
                                            M.Status.farm = "Going to " .. folder.Name .. "..."
                                            M.undergroundPathTo(root.CFrame * CFrame.new(0, 3, 0))
                                            
                                            for attempt = 1, 5 do
                                                if not M.S.Farming then break end
                                                if M.isDead() then 
                                                    M.waitForRespawn() 
                                                    task.wait(1) 
                                                    M.setHomePosition() 
                                                    if root and root.Parent then 
                                                        M.undergroundPathTo(root.CFrame * CFrame.new(0, 3, 0)) 
                                                    else 
                                                        break 
                                                    end
                                                end
                                                if root and root.Parent then 
                                                    M.Status.farm = "Grabbing " .. folder.Name .. "..."
                                                    M.forceGrabPrompt(root) 
                                                    M.forceGrabPrompt(b) 
                                                    task.wait(0.04) 
                                                    M.Status.farmCount = M.Status.farmCount + 1 
                                                    currentBackpackCount = currentBackpackCount + 1 
                                                    break
                                                else 
                                                    break 
                                                end
                                            end
                                            pcall(function() hum:UnequipTools() end) 
                                            task.wait(0.04)
                                            local hrp = ch:FindFirstChild("HumanoidRootPart")
                                            if hrp then 
                                                M.fastTween(CFrame.new(hrp.Position.X, -25, hrp.Position.Z)) 
                                            end

                                            if currentBackpackCount >= maxBackpackCount then
                                                M.Status.farm = "Returning underground..." 
                                                M.undergroundReturnToBase() 
                                                currentBackpackCount = 0
                                            end
                                            return
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(1) 
                        return
                    end

                    if not M.isSlotEmpty(ws) then
                        M.Status.farm = "Clearing slot..."
                        M.pickUpBrainrot(ws) 
                        task.wait(0.5)
                        pcall(function() hum:UnequipTools() end) 
                        task.wait(0.3)
                    end

                    local tool = M.findTargetToolInBackpack()
                    if tool and M.isHighRarityTool(tool) then
                        M.Status.farm = "✓ " .. (tool:GetAttribute("Rarity") or "High") .. " in backpack"
                        M.Status.farmCount = M.Status.farmCount + 1 
                        task.wait(0.5) 
                        tool = nil
                    end

                    if not tool then
                        M.Status.farm = "Searching Brainrots..."
                        local found = false
                        if not M.ActiveBrainrots then 
                            M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots") 
                        end
                        if M.ActiveBrainrots then
                            for _, folder in pairs(M.ActiveBrainrots:GetChildren()) do
                                if not M.S.Farming then break end
                                if folder:IsA("Folder") and M.rarityMatches(folder.Name) then
                                    for _, b in pairs(folder:GetChildren()) do
                                        if not M.S.Farming or M.isDead() then break end
                                        if M.matchesFilter(b, folder.Name) then
                                            local root = M.findBrainrotRoot(b) 
                                            if not root then continue end
                                            found = true 
                                            M.Status.farm = "Retrieving " .. folder.Name .. "..."
                                            M.undergroundPathTo(root.CFrame * CFrame.new(0, 3, 0))
                                            
                                            for attempt = 1, 5 do
                                                if not M.S.Farming then break end
                                                if M.isDead() then 
                                                    M.waitForRespawn() 
                                                    task.wait(1) 
                                                    M.setHomePosition() 
                                                    if root and root.Parent then 
                                                        M.undergroundPathTo(root.CFrame * CFrame.new(0, 3, 0)) 
                                                    else 
                                                        found = false 
                                                        break 
                                                    end
                                                end
                                                if root and root.Parent then 
                                                    M.forceGrabPrompt(root) 
                                                    M.forceGrabPrompt(b)
                                                    task.wait(0.04) 
                                                    M.Status.farmCount = M.Status.farmCount + 1 
                                                    break
                                                else 
                                                    found = false 
                                                    break 
                                                end
                                            end
                                            pcall(function() hum:UnequipTools() end) 
                                            task.wait(0.04)
                                            local hrp = ch:FindFirstChild("HumanoidRootPart")
                                            if hrp then 
                                                M.fastTween(CFrame.new(hrp.Position.X, -25, hrp.Position.Z)) 
                                            end
                                            
                                            M.Status.farm = "Returning underground..." 
                                            M.undergroundReturnToBase() 
                                            break
                                        end
                                    end
                                end
                                if found then break end
                            end
                        end
                        if not found then 
                            M.Status.farm = "Searching Targets..." 
                            task.wait(2) 
                            return 
                        end
                        task.wait(0.3) 
                        tool = M.findTargetToolInBackpack()
                        if not tool then return end
                    end

                    if M.isHighRarityTool(tool) then 
                        M.Status.farmCount = M.Status.farmCount + 1 
                        task.wait(0.5) 
                        return 
                    end

                    local bName = tool:GetAttribute("BrainrotName") or "Brainrot"
                    M.Status.farm = "Heading to slot " .. ws
                    M.tweenToSlot(ws) 
                    task.wait(0.3)
                    local eq = ch:FindFirstChildWhichIsA("Tool")
                    if eq and eq ~= tool then 
                        hum:UnequipTools() 
                        task.wait(0.2) 
                    end
                    hum:EquipTool(tool) 
                    task.wait(0.5)
                    M.Status.farm = "Placing " .. bName
                    M.placeBrainrot(ws) 
                    task.wait(0.8)
                    if M.isSlotEmpty(ws) then 
                        M.Status.farm = "Placement failed..." 
                        pcall(function() hum:UnequipTools() end) 
                        task.wait(1) 
                        return 
                    end
                    M.Status.farm = "Upgrading " .. bName .. "..."
                    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
                    local sm = mb and mb:FindFirstChild("slot " .. ws .. " brainrot")
                    if sm then
                        local cur = tonumber(sm:GetAttribute("Level")) or 0 
                        local fails = 0
                        while cur < M.S.MaxLevel and M.S.Farming do
                            M.upgradeBrainrot(ws) 
                            task.wait(0.05)
                            local nw = tonumber(sm:GetAttribute("Level")) or cur
                            if nw > cur then 
                                fails = 0 
                                cur = nw 
                                M.Status.upgradeCount = M.Status.upgradeCount + 1 
                                M.Status.farm = bName .. " Lv." .. cur .. "/" .. M.S.MaxLevel
                            else 
                                fails = fails + 1 
                                if fails > 20 then 
                                    task.wait(1) 
                                    break 
                                end 
                            end
                        end
                    end
                    M.Status.farm = bName .. " DONE!" 
                    task.wait(0.3)
                    M.pickUpBrainrot(ws) 
                    task.wait(0.8) 
                    pcall(function() hum:UnequipTools() end) 
                    task.wait(0.3)
                    if not M.isSlotEmpty(ws) then 
                        M.pickUpBrainrot(ws) 
                        task.wait(0.5) 
                        pcall(function() hum:UnequipTools() end) 
                        task.wait(0.3) 
                    end
                end
                
            end)
            if not ok then 
                warn("[Catraz Farm] " .. tostring(err)) 
                task.wait(1) 
            end
            task.wait(0.3)
        end
        M.disableNoclip() 
        M.Status.farm = "Idle" 
        M.farmThread = nil
    end)
end

function M.stopFarming()
    M.S.Farming = false
    if M.farmThread then 
        pcall(task.cancel, M.farmThread) 
        M.farmThread = nil 
    end
    M.disableNoclip()
    pcall(function()
        local ch = Player.Character 
        if ch then
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then 
                local bv = hrp:FindFirstChild("AntiFallMzD") 
                if bv then 
                    bv:Destroy() 
                end 
            end
        end
    end)
    M.Status.farm = "Idle"
end

function M.startFactoryLoop()
    if M.factoryThread then return end
    M.S.FactoryEnabled = true 
    M.Status.factoryCount = 0
    M.factoryThread = task.spawn(function()
        local stopR = "Idle"
        while M.S.FactoryEnabled do
            local ok = pcall(function()
                M.Status.factory = "Scanning..."
                if not M.baseGUID then M.findBase() end 
                if not M.baseGUID then 
                    M.Status.factory = "No base found!" 
                    task.wait(2) 
                    return 
                end
                local ws = tonumber(M.S.FactorySlot) or 5
                if not M.isSlotEmpty(ws) then 
                    M.pickUpBrainrot(ws) 
                    task.wait(0.5) 
                    pcall(function() Player.Character.Humanoid:UnequipTools() end) 
                    task.wait(0.3) 
                end
                local bp = Player:FindFirstChild("Backpack") 
                if not bp then return end 
                local tool = nil
                for _, t in pairs(bp:GetChildren()) do 
                    if t:IsA("Tool") and M.toolMatchesRarity(t, M.S.FactoryRarity, "None") then 
                        tool = t 
                        break 
                    end 
                end
                if not tool then 
                    stopR = "All " .. M.S.FactoryRarity .. "s maxed!" 
                    M.S.FactoryEnabled = false 
                    return 
                end
                local bName = tool:GetAttribute("BrainrotName") or "Item" 
                M.Status.factory = "Equipping " .. bName
                local hum = Player.Character and Player.Character:FindFirstChild("Humanoid") 
                if hum then 
                    hum:EquipTool(tool) 
                    task.wait(0.5) 
                end
                M.placeBrainrot(ws) 
                task.wait(0.8)
                if M.isSlotEmpty(ws) then 
                    pcall(function() hum:UnequipTools() end) 
                    task.wait(1) 
                    return 
                end
                M.Status.factory = "Maxing " .. bName
                local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
                local sm = mb and mb:FindFirstChild("slot " .. ws .. " brainrot")
                if sm then
                    local cur = tonumber(sm:GetAttribute("Level")) or 0 
                    local fails = 0
                    while cur < M.S.FactoryMaxLevel and M.S.FactoryEnabled do
                        M.upgradeBrainrot(ws) 
                        task.wait(0.05)
                        local nw = tonumber(sm:GetAttribute("Level")) or cur
                        if nw > cur then 
                            fails = 0 
                            cur = nw 
                            M.Status.factory = bName .. " Lv." .. cur
                        else 
                            fails = fails + 1 
                            if fails > 10 then 
                                stopR = "Out of money!" 
                                M.S.FactoryEnabled = false 
                                break 
                            end 
                        end
                    end
                end
                task.wait(0.5) 
                M.pickUpBrainrot(ws) 
                task.wait(0.8) 
                M.Status.factoryCount = M.Status.factoryCount + 1
                pcall(function() Player.Character.Humanoid:UnequipTools() end) 
                task.wait(0.3)
            end)
            if not ok then 
                task.wait(1) 
            end 
            if M.S.FactoryEnabled then 
                task.wait(0.5) 
            end
        end
        M.Status.factory = stopR 
        M.factoryThread = nil
    end)
end

function M.stopFactoryLoop()
    M.S.FactoryEnabled = false
    if M.factoryThread then 
        pcall(task.cancel, M.factoryThread) 
        M.factoryThread = nil 
    end
    if not (string.find(M.Status.factory or "", "maxed") or string.find(M.Status.factory or "", "money")) then 
        M.Status.factory = "Idle" 
    end
end

function M.startMoney()
    if M.moneyThread then return end 
    M.S.AutoCollectMoney = true 
    M.Status.money = "Active"
    if not M.baseGUID then M.findBase() end
    M.moneyThread = task.spawn(function()
        while M.S.AutoCollectMoney do 
            pcall(function()
                if not M.baseGUID then M.findBase() end 
                if not M.baseGUID then return end
                local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") 
                if not mb or not hrp then return end
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
            task.wait(0.1) 
        end 
        M.Status.money = "Idle"
    end)
    M.moneyRemoteThread = task.spawn(function()
        while M.S.AutoCollectMoney do 
            pcall(function()
                if M.baseGUID and M.PlotAction then 
                    for i = 1, 40 do 
                        task.spawn(function() 
                            pcall(function() 
                                M.PlotAction:InvokeServer("Collect Money", M.baseGUID, tostring(i)) 
                            end) 
                        end) 
                    end 
                end
            end) 
            task.wait(1) 
        end
    end)
end

function M.stopMoney()
    M.S.AutoCollectMoney = false
    if M.moneyThread then 
        pcall(task.cancel, M.moneyThread) 
        M.moneyThread = nil 
    end
    if M.moneyRemoteThread then 
        pcall(task.cancel, M.moneyRemoteThread) 
        M.moneyRemoteThread = nil 
    end
    M.Status.money = "Idle"
end

function M.startAutoUpgrade()
    if M.upgradeThread then return end 
    M.S.AutoUpgrade = true 
    M.Status.upgradeCount = 0
    M.upgradeThread = task.spawn(function()
        while M.S.AutoUpgrade do 
            pcall(function()
                for _, info in pairs(M.findOccupiedSlots()) do 
                    if not M.S.AutoUpgrade then break end 
                    if info.level < M.S.MaxLevel then 
                        M.upgradeSlotToMax(info.slot) 
                    end 
                end
                M.Status.upgrade = "Finished (#" .. M.Status.upgradeCount .. ")"
            end) 
            task.wait(3) 
        end 
        M.Status.upgrade = "Idle"
    end)
end

function M.upgradeSlotToMax(slot)
    if not M.baseGUID or not M.PlotAction then return end
    local mb = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(M.baseGUID)
    local sm = mb and mb:FindFirstChild("slot " .. slot .. " brainrot")
    if not sm then return end
    local cur = tonumber(sm:GetAttribute("Level")) or 0
    while cur < M.S.MaxLevel and M.S.AutoUpgrade do
        M.upgradeBrainrot(slot) 
        task.wait(0.05)
        local nw = tonumber(sm:GetAttribute("Level")) or cur
        if nw > cur then 
            cur = nw 
            M.Status.upgradeCount = M.Status.upgradeCount + 1 
        end
    end
end

function M.stopAutoUpgrade() 
    M.S.AutoUpgrade = false 
    if M.upgradeThread then 
        pcall(task.cancel, M.upgradeThread) 
        M.upgradeThread = nil 
    end 
    M.Status.upgrade = "Idle" 
end

function M.setupInstant()
    for _, o in pairs(workspace:GetDescendants()) do 
        if o:IsA("ProximityPrompt") then 
            pcall(function() o.HoldDuration = 0 end) 
        end 
    end
    if not M._instantConn then 
        M._instantConn = workspace.DescendantAdded:Connect(function(o) 
            if o:IsA("ProximityPrompt") then 
                pcall(function() o.HoldDuration = 0 end) 
            end 
        end) 
    end
end
M.setupInstant()

-- =================================================================
-- UI IMPLEMENTATION (CATRAZ HUB x ORIONLIB)
-- =================================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))() 

local Window = OrionLib:MakeWindow({
    Name = "Catraz Hub",
    Subtext = "Escape Tsunami For Brainrots",
    Version = "v3.0 - ULTIMATE",
    VersionIcon = "crown",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CatrazHub_Tsunami",
    IntroEnabled = true,
    IntroText = "Escape Tsunami For Brainrots",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    ImageBackground = "rbxassetid://84894412677021",
    ImageTransparency = 0.1,
    WindowTransparency = 0.1,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

-- Options Lists
local RAR = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity"}
local MUT = {"Any","None","Emerald","Gold","Blood","Diamond","Rainbow","Shadow","Crystal","Void"}
local FM = {"Collect","Collect, Place & Max"}
local FR = {"Common","Uncommon","Rare","Epic","Legendary","Mythical"}
local LBR = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity","Admin","UFO","Candy","Money"}
local SL = {} 
for i=1,40 do 
    table.insert(SL, tostring(i)) 
end
local CSPD = {"100","200","300","400","500","600","800","1000","1200","1500","2000"}
local TSUNAMI_MODES = {"Bawah (Gali Tanah)", "Atas (Terbang di Atas)"}

-- ================== HOME TAB ==================
local HomeTab = Window:MakeTab({ 
    Name = "Home", 
    Icon = "home", 
    Glass = true, 
    Outline = true 
})

local DashSec = HomeTab:AddSection({ 
    Name = "📊 DASHBOARD", 
    Glass = true, 
    Outline = true 
})

DashSec:AddParagraph({ 
    Title = "Welcome, " .. LPlayer.DisplayName, 
    Desc = "Catraz Hub v3.0 - ULTIMATE\nEscape Tsunami For Brainrots\nAll features ready!", 
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LPlayer.UserId .. "&w=150&h=150", 
    ImageSize = 45 
})

local InfoSec = HomeTab:AddSection({ 
    Name = "ℹ️ SCRIPT INFO", 
    Glass = true, 
    Outline = true 
})

InfoSec:AddParagraph({
    Title = "Information",
    Desc = "Creator: Catraz Team\nVersion: 3.0 ULTIMATE\nFeatures: Farm, Tsunami Protect, Factory, Auto Collect",
    Image = "info",
    ImageSize = 38
})

-- ================== TSUNAMI TAB ==================
local TsunamiTab = Window:MakeTab({ 
    Name = "Tsunami", 
    Icon = "waves", 
    Glass = true, 
    Outline = true 
})

local TsunamiSet = TsunamiTab:AddSection({ 
    Name = "🌊 TSUNAMI PROTECTION", 
    Glass = true, 
    Outline = true 
})

TsunamiSet:AddDropdown({
    Name = "Mode Perlindungan",
    Default = "Bawah (Gali Tanah)",
    Options = TSUNAMI_MODES,
    Multi = false,
    Outline = true,
    Flag = "TsunamiMode",
    Callback = function(v)
        if v == "Bawah (Gali Tanah)" then
            M.S.TsunamiMode = "Bawah"
            M.Tsunami.Mode = "Bawah"
        else
            M.S.TsunamiMode = "Atas"
            M.Tsunami.Mode = "Atas"
        end
        if M.S.TsunamiProtection then
            M.disableTsunamiProtection()
            task.wait(0.5)
            M.enableTsunamiProtection()
        end
    end
})

TsunamiSet:AddSlider({
    Name = "Ketinggian Aman (Mode Atas)",
    Min = 50,
    Max = 500,
    Default = 150,
    Increment = 10,
    ValueName = "Studs",
    Outline = true,
    Flag = "TsunamiHeight",
    Callback = function(v)
        M.Tsunami.Height = v
    end
})

local TsunamiStatus = TsunamiSet:AddParagraph({ 
    Title = "Status Tsunami", 
    Desc = "⏸️ Nonaktif", 
    Image = "info",
    ImageSize = 30
})

TsunamiSet:AddToggle({
    Name = "🌊 Aktifkan Tsunami Protection",
    Default = false,
    Outline = true,
    Flag = "TsunamiToggle",
    Callback = function(v)
        M.S.TsunamiProtection = v
        if v then
            M.enableTsunamiProtection()
            TsunamiStatus:Set({ 
                Title = "Status Tsunami", 
                Desc = "✅ Aktif - Mode: " .. M.S.TsunamiMode,
                Image = "info",
                ImageSize = 30
            })
            OrionLib:MakeNotification({ 
                Name = "Tsunami Protection", 
                Content = "Aktif! Mode: " .. M.S.TsunamiMode, 
                Time = 3 
            })
        else
            M.disableTsunamiProtection()
            TsunamiStatus:Set({ 
                Title = "Status Tsunami", 
                Desc = "⏸️ Nonaktif",
                Image = "info",
                ImageSize = 30
            })
            OrionLib:MakeNotification({ 
                Name = "Tsunami Protection", 
                Content = "Nonaktif", 
                Time = 2 
            })
        end
    end
})

TsunamiSet:AddParagraph({
    Title = "📋 INFORMASI",
    Desc = "• Mode Bawah: Menggali tanah (Y = -50)\n• Mode Atas: Terbang di atas (Y = 150+)\n• Noclip otomatis saat terbang\n• Deteksi tsunami radius 100 studs",
    Image = "info",
    ImageSize = 38
})

-- ================== FARM TAB ==================
local FarmTab = Window:MakeTab({ 
    Name = "Farm", 
    Icon = "swords", 
    Glass = true, 
    Outline = true 
})

local FarmFilterSec = FarmTab:AddSection({ 
    Name = "🎯 TARGET SELECTION", 
    Glass = true, 
    Outline = true 
})

FarmFilterSec:AddDropdown({
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
        M.S.FarmTargets = s 
    end
})

local BrainrotSet = FarmTab:AddSection({ 
    Name = "🧟 BRAINROT SETTINGS", 
    Glass = true, 
    Outline = true 
})

BrainrotSet:AddDropdown({ 
    Name = "Target Rarity", 
    Default = {"Common"}, 
    Options = RAR, 
    Multi = true, 
    Outline = true, 
    Flag = "TargetRarity",
    Callback = function(v) 
        local s = {} 
        for _, on in pairs(v) do table.insert(s, on) end 
        M.S.TargetRarity = #s>0 and s or {"Common"} 
    end 
})

BrainrotSet:AddDropdown({ 
    Name = "Target Mutation", 
    Default = "None", 
    Options = MUT, 
    Multi = false, 
    Outline = true, 
    Flag = "TargetMutation",
    Callback = function(v) M.S.TargetMutation = v end 
})

BrainrotSet:AddDropdown({ 
    Name = "Farm Mode", 
    Default = M.S.FarmMode, 
    Options = FM, 
    Multi = false, 
    Outline = true, 
    Flag = "FarmMode",
    Callback = function(v) M.S.FarmMode = v end 
})

BrainrotSet:AddDropdown({ 
    Name = "Work Slot", 
    Default = M.S.FarmSlot, 
    Options = SL, 
    Multi = false, 
    Outline = true, 
    Flag = "FarmSlot",
    Callback = function(v) M.S.FarmSlot = v end 
})

BrainrotSet:AddSlider({ 
    Name = "Max Level", 
    Min = 1, 
    Max = 500, 
    Default = M.S.MaxLevel, 
    Increment = 1, 
    ValueName = "Lv", 
    Outline = true, 
    Flag = "MaxLevel",
    Callback = function(v) M.S.MaxLevel = math.floor(v) end 
})

local LBSet = FarmTab:AddSection({ 
    Name = "🎲 LUCKY BLOCK SETTINGS", 
    Glass = true, 
    Outline = true 
})

LBSet:AddDropdown({ 
    Name = "LB Rarity", 
    Default = {"Common"}, 
    Options = LBR, 
    Multi = true, 
    Outline = true, 
    Flag = "LBRarity",
    Callback = function(v) 
        local s = {} 
        for _, on in pairs(v) do table.insert(s, on) end 
        M.S.LuckyBlockRarity = #s>0 and s or {"Common"} 
    end 
})

LBSet:AddDropdown({ 
    Name = "LB Mutation", 
    Default = "Any", 
    Options = MUT, 
    Multi = false, 
    Outline = true, 
    Flag = "LBMutation",
    Callback = function(v) M.S.LuckyBlockMutation = v end 
})

local FarmControlSec = FarmTab:AddSection({ 
    Name = "🚀 AUTO FARM MASTER", 
    Glass = true, 
    Outline = true 
})

local FSP = FarmControlSec:AddParagraph({
    Title = "Master Farm Status", 
    Desc = "Idle", 
    Image = "activity",
    ImageSize = 30
})

local FPP = FarmControlSec:AddParagraph({
    Title = "Statistics", 
    Desc = "Placed: 0 | Upgraded: 0", 
    Image = "bar-chart",
    ImageSize = 30
})

FarmControlSec:AddToggle({
    Name = "🚀 Master Auto Farm", 
    Default = false, 
    Outline = true, 
    Flag = "FarmToggle",
    Callback = function(v)
        if v then 
            M.findBase() 
            M.startFarming() 
            OrionLib:MakeNotification({
                Name = "Master Farm", 
                Content = "Started! Prioritizing targets...", 
                Time = 3 
            })
        else 
            M.stopFarming() 
            OrionLib:MakeNotification({
                Name = "Master Farm", 
                Content = "Stopped.", 
                Time = 3 
            }) 
        end
    end
})

-- ================== FACTORY TAB ==================
local FactoryTab = Window:MakeTab({ 
    Name = "Factory", 
    Icon = "hammer", 
    Glass = true, 
    Outline = true 
})

local FCTSec = FactoryTab:AddSection({ 
    Name = "🏭 FACTORY LOOP", 
    Glass = true, 
    Outline = true 
})

FCTSec:AddDropdown({ 
    Name = "Rarity", 
    Default = M.S.FactoryRarity, 
    Options = FR, 
    Multi = false, 
    Outline = true, 
    Flag = "FactoryRarity",
    Callback = function(v) M.S.FactoryRarity = v end 
})

FCTSec:AddDropdown({ 
    Name = "Work Slot", 
    Default = M.S.FactorySlot, 
    Options = SL, 
    Multi = false, 
    Outline = true, 
    Flag = "FactorySlot",
    Callback = function(v) M.S.FactorySlot = v end 
})

FCTSec:AddSlider({ 
    Name = "Max Level", 
    Min = 1, 
    Max = 500, 
    Default = M.S.FactoryMaxLevel, 
    Increment = 1, 
    ValueName = "Lv", 
    Outline = true, 
    Flag = "FactoryMaxLevel",
    Callback = function(v) M.S.FactoryMaxLevel = math.floor(v) end 
})

local FCSP = FCTSec:AddParagraph({
    Title = "Factory Status", 
    Desc = "Idle", 
    Image = "factory",
    ImageSize = 30
})

FCTSec:AddToggle({ 
    Name = "🔁 Factory Loop", 
    Default = false, 
    Outline = true, 
    Flag = "FactoryToggle",
    Callback = function(v) 
        if v then 
            M.findBase() 
            M.startFactoryLoop() 
            OrionLib:MakeNotification({
                Name = "Factory", 
                Content = "Started!", 
                Time = 2
            })
        else 
            M.stopFactoryLoop() 
            OrionLib:MakeNotification({
                Name = "Factory", 
                Content = "Stopped.", 
                Time = 2
            })
        end 
    end 
})

-- ================== AUTOMATION TAB ==================
local AutoTab = Window:MakeTab({ 
    Name = "Automation", 
    Icon = "rocket", 
    Glass = true, 
    Outline = true 
})

local UtilSec = AutoTab:AddSection({ 
    Name = "💰 BASE UTILITY", 
    Glass = true, 
    Outline = true 
})

local MSP = UtilSec:AddParagraph({
    Title = "Money Status", 
    Desc = "Idle", 
    Image = "dollar-sign",
    ImageSize = 30
})

UtilSec:AddToggle({ 
    Name = "💰 Auto Collect Money", 
    Default = false, 
    Outline = true, 
    Flag = "MoneyToggle",
    Callback = function(v) 
        if v then 
            M.findBase() 
            M.startMoney() 
            OrionLib:MakeNotification({
                Name = "Auto Collect", 
                Content = "Money collector started", 
                Time = 2
            })
        else 
            M.stopMoney() 
            OrionLib:MakeNotification({
                Name = "Auto Collect", 
                Content = "Stopped", 
                Time = 2
            })
        end 
    end 
})

local USP = UtilSec:AddParagraph({
    Title = "Upgrade Status", 
    Desc = "Idle", 
    Image = "trending-up",
    ImageSize = 30
})

UtilSec:AddToggle({ 
    Name = "⬆️ Auto Upgrade Slots", 
    Default = false, 
    Outline = true, 
    Flag = "UpgradeToggle",
    Callback = function(v) 
        if v then 
            M.findBase() 
            M.startAutoUpgrade() 
            OrionLib:MakeNotification({
                Name = "Auto Upgrade", 
                Content = "Started", 
                Time = 2
            })
        else 
            M.stopAutoUpgrade() 
            OrionLib:MakeNotification({
                Name = "Auto Upgrade", 
                Content = "Stopped", 
                Time = 2
            })
        end 
    end 
})

-- ================== CONFIG TAB ==================
local ConfigTab = Window:MakeTab({ 
    Name = "Config", 
    Icon = "settings", 
    Glass = true, 
    Outline = true 
})

local TweakSec = ConfigTab:AddSection({ 
    Name = "⚙️ TWEAKS", 
    Glass = true, 
    Outline = true 
})

TweakSec:AddSlider({
    Name = "Farm Tween Speed",
    Min = 1, 
    Max = 100, 
    Default = 60, 
    Increment = 5,
    ValueName = "Speed", 
    Outline = true, 
    Flag = "TweenSpeed",
    Callback = function(v) 
        M.S.TweenSpeed = math.floor(v) * 16.67 
    end
})

TweakSec:AddDropdown({ 
    Name = "Corridor Speed", 
    Default = "400", 
    Options = CSPD, 
    Multi = false, 
    Outline = true, 
    Flag = "CorridorSpeed",
    Callback = function(v) 
        M.S.CorridorSpeed = tonumber(v) or 400 
    end 
})

TweakSec:AddButton({ 
    Name = "🏠 Find My Base", 
    Outline = true, 
    Callback = function() 
        M.findBase() 
        if M.baseGUID then
            OrionLib:MakeNotification({
                Name = "Base Found", 
                Content = "Base ID: " .. M.baseGUID, 
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Base Not Found", 
                Content = "Could not locate your base", 
                Time = 3
            })
        end
    end 
})

TweakSec:AddButton({ 
    Name = "📍 Set Home Position", 
    Outline = true, 
    Callback = function() 
        M.setHomePosition() 
        OrionLib:MakeNotification({
            Name = "Home Position", 
            Content = "Position saved!", 
            Time = 2
        })
    end 
})

TweakSec:AddToggle({
    Name = "👻 Noclip",
    Default = false,
    Outline = true,
    Flag = "NoclipToggle",
    Callback = function(v)
        if v then
            M.enableNoclip()
            OrionLib:MakeNotification({
                Name = "Noclip", 
                Content = "Enabled - Walk through walls", 
                Time = 2
            })
        else
            M.disableNoclip()
            OrionLib:MakeNotification({
                Name = "Noclip", 
                Content = "Disabled", 
                Time = 2
            })
        end
    end
})

local IPSec = ConfigTab:AddSection({ 
    Name = "ℹ️ PLAYER INFO", 
    Glass = true, 
    Outline = true 
})

local IP = IPSec:AddParagraph({
    Title = "Player Info", 
    Desc = "Loading...", 
    Image = "user",
    ImageSize = 38
})

-- ================== CONFIG SAVING TAB ==================
Window:AddConfigTab({ 
    Name = "Settings", 
    Icon = "save" 
})

-- ================== UPDATE LOOP ==================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local farmStatus = M.S.Farming and M.Status.farm or "Idle"
            FSP:Set({
                Title = "Master Farm Status", 
                Desc = "Status: " .. farmStatus .. "\nBrainrots: #" .. M.Status.farmCount .. "\nLucky Blocks: #" .. M.Status.luckyBlockCount
            })
        end)
        
        pcall(function() 
            FPP:Set({ 
                Title = "Statistics", 
                Desc = "Placed: " .. M.Status.placeCount .. "\nUpgraded: " .. M.Status.upgradeCount 
            }) 
        end)
        
        pcall(function() 
            FCSP:Set({ 
                Title = "Factory Status", 
                Desc = "Status: " .. (M.Status.factory or "Idle") .. "\nCompleted: #" .. M.Status.factoryCount 
            }) 
        end)
        
        pcall(function()
            local tsunamiStatus = "❌ Nonaktif"
            if M.S.TsunamiProtection then
                tsunamiStatus = "✅ Aktif (" .. M.S.TsunamiMode .. ")"
            end
            
            IP:Set({ 
                Title = "Player Info", 
                Desc = string.format("Player: %s\nBase: %s\nNoclip: %s\nTsunami: %s\nFarming: %s", 
                    LPlayer.Name, 
                    (M.baseGUID or "Not Found"), 
                    (M.S.NoclipEnabled and "✅" or "❌"),
                    tsunamiStatus,
                    (M.S.Farming and "✅" or "❌")
                )
            })
        end)
        
        pcall(function() 
            MSP:Set({
                Title = "Money Status", 
                Desc = "Status: " .. (M.S.AutoCollectMoney and "✅ Active" or "⏸️ Idle")
            })
        end)
        
        pcall(function() 
            USP:Set({
                Title = "Upgrade Status", 
                Desc = "Status: " .. (M.S.AutoUpgrade and M.Status.upgrade or "Idle") .. "\nUpgraded: #" .. M.Status.upgradeCount
            })
        end)
    end
end)

-- ================== INIT ==================
OrionLib:Init()

print("═══════════════════════════════════════════════════════")
print("🔥 CATRAZ HUB - ESCAPE TSUNAMI FOR BRAINROTS 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Version: 3.0 ULTIMATE")
print("✅ Tsunami Protection - 2 MODES (Bawah/Atas)")
print("✅ Auto Farm - Brainrots + Lucky Blocks")
print("✅ Factory Loop - Auto maxing")
print("✅ Auto Collect Money & Upgrade")
print("✅ Noclip + Tween System")
print("═══════════════════════════════════════════════════════")
print("🚀 Script siap digunakan! Semua tab sudah muncul.")
print("═══════════════════════════════════════════════════════")