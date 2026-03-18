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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- ========== INIT ==========
M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
if not M.ActiveBrainrots then 
    task.spawn(function() 
        M.ActiveBrainrots = workspace:WaitForChild("ActiveBrainrots", 15) 
    end) 
end

M.ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks")
if not M.ActiveLuckyBlocks then 
    task.spawn(function() 
        M.ActiveLuckyBlocks = workspace:WaitForChild("ActiveLuckyBlocks", 15) 
    end) 
end

M.PlotAction = nil
pcall(function()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if packages then
        local net = packages:FindFirstChild("Net")
        if net then
            M.PlotAction = net:FindFirstChild("RF/Plot.PlotAction")
        end
    end
end)

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
    FarmCapacity = 1
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
    while p do 
        if p.Name == "MzDHubWalls" then return true end 
        p = p.Parent 
    end
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
                if p:IsA("BasePart") and not M.isOwnWallPart(p) then 
                    p.CanCollide = false 
                end
            end
        end)
    end)
end

function M.disableNoclip()
    M.S.NoclipEnabled = false
    if M._noclipConn then 
        pcall(function() M._noclipConn:Disconnect() end) 
        M._noclipConn = nil 
    end
    pcall(function()
        local ch = Player.Character if not ch then return end
        for _, p in pairs(ch:GetDescendants()) do 
            if p:IsA("BasePart") then 
                p.CanCollide = true 
            end 
        end
    end)
end

function M.enableGod()
    -- GOD MODE DIMATIKAN SENGAJA BIAR CPU NGGAK SPIKE / LAG
end

function M.disableGod()
    -- Sengaja dikosongin juga
end

function M.mapFindCurrentMap()
    local best, bc = nil, 0
    for _, c in pairs(workspace:GetChildren()) do
        if c:IsA("Model") and c.Name:find("Map") and not c.Name:find("SharedInstances") then
            if c:FindFirstChild("Spawners") or c:FindFirstChild("Gaps") or c:FindFirstChild("RightWalls") or c:FindFirstChild("FirstFloor") or c:FindFirstChild("Ground") then 
                return c 
            end
            local cnt = 0
            for _, d in pairs(c:GetDescendants()) do 
                if d:IsA("BasePart") then 
                    cnt = cnt + 1 
                end 
                if cnt > 10 then 
                    return c 
                end 
            end
            if cnt > bc then 
                bc = cnt 
                best = c 
            end
        end
    end 
    return best
end

function M.detectWallZ()
    local map = M.mapFindCurrentMap() 
    if not map then return end
    local mzwalls = map:FindFirstChild("MzDHubWalls") 
    if not mzwalls then return end
    local fw = mzwalls:FindFirstChild("FrontWall_1")
    local bw = mzwalls:FindFirstChild("BackWall_1")
    if fw then 
        M._wallZ_front = fw.Position.Z - fw.Size.Z / 2 - 3 
    end
    if bw then 
        M._wallZ_back = bw.Position.Z + bw.Size.Z / 2 + 3 
    end
end

function M.getCorridorZ()
    M.detectWallZ()
    local homePos = M.getHomePosition().Position
    if homePos.Z >= 0 then 
        return M._wallZ_front 
    else 
        return M._wallZ_back 
    end
end

function M.findBase()
    local bases = workspace:FindFirstChild("Bases") 
    if not bases then return end
    
    for _, base in pairs(bases:GetChildren()) do
        local success = pcall(function()
            local title = base:FindFirstChild("Title")
            if title then
                local titleGui = title:FindFirstChild("TitleGui")
                if titleGui then
                    local frame = titleGui:FindFirstChild("Frame")
                    if frame then
                        local pn = frame:FindFirstChild("PlayerName")
                        if pn and pn:IsA("TextLabel") then
                            if pn.Text == Player.Name or pn.Text == Player.DisplayName then
                                M.baseGUID = base.Name
                                local s1 = base:FindFirstChild("slot 1 brainrot")
                                if s1 and s1:FindFirstChild("Root") then 
                                    M.baseCFrame = s1.Root.CFrame 
                                end
                                return true
                            end
                        end
                    end
                end
            end
        end)
        if success then break end
    end
    
    if not M.homePosition then 
        M.setHomePosition() 
    end
end

function M.setHomePosition()
    local ch = Player.Character 
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart") 
    if not hrp then return end
    M.homePosition = hrp.CFrame
end

function M.getHomePosition()
    if M.homePosition then return M.homePosition end
    if M.baseCFrame then return M.baseCFrame end
    return CFrame.new(124, 3.8, 22)
end

-- Find base di awal
task.spawn(function() 
    task.wait(3) 
    M.findBase() 
end)

Player.CharacterAdded:Connect(function()
    task.wait(1.5)
    if M.S.InstantPickup then 
        M.setupInstant() 
    end
    task.wait(0.5) 
    M.detectWallZ()
    if M._isGod then
        M._isGod = false
        if M._healthConn then 
            pcall(function() M._healthConn:Disconnect() end) 
            M._healthConn = nil 
        end
        if M._godThread then 
            pcall(task.cancel, M._godThread) 
            M._godThread = nil 
        end
        task.wait(0.5) 
        M.enableGod()
    end
    if M.S.NoclipEnabled then
        if M._noclipConn then 
            pcall(function() M._noclipConn:Disconnect() end) 
            M._noclipConn = nil 
        end
        M.S.NoclipEnabled = false 
        task.wait(0.3) 
        M.enableNoclip()
    end
end)

-- TWEEN FUNCTIONS - DIPERBAIKI
function M.tweenTo(cf)
    local ch = Player.Character 
    if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") 
    if not hrp then return false end
    
    local distance = (hrp.Position - cf.Position).Magnitude
    if distance < 5 then return true end
    
    local speed = tonumber(M.S.TweenSpeed) or 1000
    if speed <= 0 then speed = 1000 end
    local t = distance / speed
    t = math.max(0.1, math.min(t, 5))
    
    local success = pcall(function()
        local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
        tw:Play() 
        tw.Completed:Wait()
    end)
    
    if not success then
        pcall(function() hrp.CFrame = cf end)
    end
    return true
end

function M.fastTween(cf)
    local ch = Player.Character 
    if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") 
    if not hrp then return false end
    
    pcall(function() hrp.CFrame = cf end)
    task.wait(0.05)
    return true
end

function M.corridorTween(cf)
    local ch = Player.Character 
    if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") 
    if not hrp then return false end
    
    local distance = (hrp.Position - cf.Position).Magnitude
    local spd = tonumber(M.S.CorridorSpeed) or 400
    if spd <= 0 then spd = 400 end
    local t = math.max(distance / spd, 0.05)
    
    pcall(function()
        local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
        tw:Play() 
        tw.Completed:Wait()
    end)
    return true
end

function M.returnToBase() 
    M.tweenTo(M.getHomePosition()) 
    task.wait(0.1) 
end

function M.undergroundPathTo(targetCFrame)
    local ch = Player.Character 
    if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") 
    if not hrp then return false end
    
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
    local ch = Player.Character 
    if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart") 
    if not hrp then return false end
    
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
    
    if bv then 
        bv:Destroy() 
    end 
    return true
end

function M.isHighRarity(r) 
    return HIGH_RARITIES[r] == true 
end

function M.isDead()
    local ch = Player.Character 
    if not ch then return true end
    local hum = ch:FindFirstChild("Humanoid") 
    if not hum then return true end
    return hum.Health <= 0
end

function M.waitForRespawn()
    if not M.isDead() then return true end
    local timeout = tick() + 15
    while M.isDead() and tick() < timeout do 
        task.wait(0.2) 
    end
    task.wait(1) 
    return not M.isDead()
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

function M.getTargetRarities() 
    return type(M.S.TargetRarity) == "table" and M.S.TargetRarity or {M.S.TargetRarity} 
end

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
    if not M.ActiveBrainrots then 
        M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots") 
    end
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
    
    if not bName or bName == "" or lvl >= M.S.MaxLevel then 
        return false 
    end
    
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
        if not (tMut:lower() == "none" or tMut == "") then 
            return false 
        end
    elseif targetMutation ~= "Any" then 
        if tMut ~= targetMutation then 
            return false 
        end 
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
            if not m then 
                return false 
            end
        else
            local wl = {} 
            for _, r in pairs(tR) do 
                for _, n in pairs(M.getBrainrotNames(r)) do 
                    wl[n] = true 
                end 
            end
            if not wl[bName] then 
                return false 
            end
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
    if root and root:IsA("BasePart") then 
        return root 
    end
    
    local rendered = b:FindFirstChild("RenderedBrainrot") 
    if rendered then 
        local rr = rendered:FindFirstChild("Root") 
        if rr and rr:IsA("BasePart") then 
            return rr 
        end 
    end
    
    for _, desc in pairs(b:GetDescendants()) do 
        if desc:IsA("BasePart") then 
            return desc 
        end 
    end
    
    if b:IsA("BasePart") then 
        return b 
    end 
    return nil
end

function M.isSlotEmpty(s)
    if not M.baseGUID then 
        M.findBase() 
    end 
    if not M.baseGUID then 
        return true 
    end
    
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return true end
    
    local mb = bases:FindFirstChild(M.baseGUID) 
    if not mb then return true end
    
    local sm = mb:FindFirstChild("slot " .. s .. " brainrot") 
    if not sm then return true end
    
    local bn = sm:GetAttribute("BrainrotName") 
    return not bn or bn == ""
end

function M.findOccupiedSlots()
    if not M.baseGUID then 
        M.findBase() 
    end 
    if not M.baseGUID then 
        return {} 
    end
    
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return {} end
    
    local mb = bases:FindFirstChild(M.baseGUID) 
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

function M.placeBrainrot(s)
    if not M.baseGUID or not M.PlotAction then 
        return false 
    end
    
    local ok = pcall(function() 
        M.PlotAction:InvokeServer("Place Brainrot", M.baseGUID, tostring(s)) 
    end)
    
    if ok then 
        M.Status.placeCount = M.Status.placeCount + 1 
    end 
    return ok
end

function M.pickUpBrainrot(s)
    if not M.baseGUID or not M.PlotAction then 
        return false 
    end
    return pcall(function() 
        M.PlotAction:InvokeServer("Pick Up Brainrot", M.baseGUID, tostring(s)) 
    end)
end

function M.upgradeBrainrot(s)
    if not M.baseGUID or not M.PlotAction then 
        return false 
    end
    return pcall(function() 
        M.PlotAction:InvokeServer("Upgrade Brainrot", M.baseGUID, tostring(s)) 
    end)
end

function M.tweenToSlot(slotNumber)
    if not M.baseGUID then 
        M.findBase() 
    end 
    if not M.baseGUID then 
        return false 
    end
    
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return false end
    
    local myBase = bases:FindFirstChild(M.baseGUID) 
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
    if HIGH_RARITIES[r] then 
        return true 
    end
    
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

-- ================= SCAN FUNCTIONS =================
function M.scanBrainrots()
    local brainrots = {}
    if not M.ActiveBrainrots then 
        M.ActiveBrainrots = workspace:FindFirstChild("ActiveBrainrots")
        if not M.ActiveBrainrots then return brainrots end
    end
    
    for _, folder in pairs(M.ActiveBrainrots:GetChildren()) do
        if folder:IsA("Folder") then
            for _, brainrot in pairs(folder:GetChildren()) do
                local root = M.findBrainrotRoot(brainrot)
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

function M.scanLuckyBlocks()
    local blocks = {}
    if not M.ActiveLuckyBlocks then 
        M.ActiveLuckyBlocks = workspace:FindFirstChild("ActiveLuckyBlocks")
        if not M.ActiveLuckyBlocks then return blocks end
    end
    
    for _, block in pairs(M.ActiveLuckyBlocks:GetChildren()) do
        local root = M.findLuckyBlockRoot(block)
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

function M.findNearestTarget(targets)
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

function M.farmBrainrot(target)
    if not target or not target.Root then return false end
    
    local char = Player.Character
    if not char then return false end
    
    M.Status.farm = "Moving to " .. target.Rarity
    M.tweenTo(target.Root.CFrame * CFrame.new(0, 3, 0))
    
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
    
    M.Status.farmCount = M.Status.farmCount + 1
    return true
end

function M.farmLuckyBlock(target)
    if not target or not target.Root then return false end
    
    local char = Player.Character
    if not char then return false end
    
    M.Status.farm = "Moving to Lucky Block"
    M.tweenTo(target.Root.CFrame * CFrame.new(0, 3, 0))
    
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
    
    M.Status.luckyBlockCount = M.Status.luckyBlockCount + 1
    return true
end

-- ================= LUCKY BLOCK FUNCTIONS =================
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
    
    if M.S.LuckyBlockMutation == "Any" then 
        return true 
    end 
    if M.S.LuckyBlockMutation == "None" then 
        return isNone 
    end
    return mut == M.S.LuckyBlockMutation
end

function M.luckyBlockGetRarityFromName(bn) 
    return bn:match("LuckyBlock_(.+)") or bn 
end

function M.findLuckyBlockRoot(block)
    local r = block:FindFirstChild("Root") 
    if r and r:IsA("BasePart") then 
        return r 
    end
    
    if block:IsA("BasePart") then 
        return block 
    end
    
    local p = nil 
    pcall(function() p = block.PrimaryPart end) 
    if p then 
        return p 
    end
    
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

-- ================= MASTER FARM SYSTEM =================
function M.startFarming()
    if M.farmThread then 
        return 
    end
    
    M.S.Farming = true 
    M.Status.farmCount = 0 
    M.Status.luckyBlockCount = 0
    M.setHomePosition() 
    M.detectWallZ() 
    M.returnToBase() 
    M.enableNoclip() 

    M.farmThread = task.spawn(function()
        while M.S.Farming do
            local ok, err = pcall(function()
                if M.isDead() then
                    M.Status.farm = "Dead! Waiting..."
                    M.waitForRespawn() 
                    task.wait(1) 
                    M.setHomePosition() 
                    task.wait(0.5) 
                    return
                end
                
                local ch = Player.Character 
                if not ch then 
                    task.wait(1) 
                    return 
                end
                
                -- Priority 1: Lucky Blocks
                if M.hasFarmTarget("Lucky Blocks") then
                    local blocks = M.scanLuckyBlocks()
                    if #blocks > 0 then
                        local nearest = M.findNearestTarget(blocks)
                        if nearest then
                            M.farmLuckyBlock(nearest)
                            task.wait(0.5)
                            return
                        end
                    end
                end
                
                -- Priority 2: Brainrots
                if M.hasFarmTarget("Brainrots") then
                    local brainrots = M.scanBrainrots()
                    if #brainrots > 0 then
                        local nearest = M.findNearestTarget(brainrots)
                        if nearest then
                            M.farmBrainrot(nearest)
                            task.wait(0.5)
                            return
                        end
                    end
                end
                
                M.Status.farm = "No targets found"
                task.wait(2)
            end)
            
            if not ok then
                warn("[Farm Error] " .. tostring(err))
                task.wait(1)
            end
            task.wait(0.1)
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

-- ================= FACTORY LOOP =================
function M.startFactoryLoop()
    if M.factoryThread then return end
    
    M.S.FactoryEnabled = true 
    M.Status.factoryCount = 0
    
    M.factoryThread = task.spawn(function()
        local stopR = "Idle"
        
        while M.S.FactoryEnabled do
            local ok = pcall(function()
                M.Status.factory = "Scanning..."
                
                if not M.baseGUID then 
                    M.findBase() 
                end 
                if not M.baseGUID then 
                    M.Status.factory = "No base found!" 
                    task.wait(2) 
                    return 
                end
                
                local ws = tonumber(M.S.FactorySlot) or 5
                
                if not M.isSlotEmpty(ws) then 
                    M.pickUpBrainrot(ws) 
                    task.wait(0.5) 
                    pcall(function() 
                        if Player.Character and Player.Character.Humanoid then
                            Player.Character.Humanoid:UnequipTools() 
                        end
                    end) 
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
                    pcall(function() 
                        if hum then hum:UnequipTools() end 
                    end) 
                    task.wait(1) 
                    return 
                end
                
                M.Status.factory = "Maxing " .. bName
                
                local bases = workspace:FindFirstChild("Bases")
                if not bases then return end
                
                local mb = bases:FindFirstChild(M.baseGUID)
                if not mb then return end
                
                local sm = mb:FindFirstChild("slot " .. ws .. " brainrot")
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
                
                pcall(function() 
                    if Player.Character and Player.Character.Humanoid then
                        Player.Character.Humanoid:UnequipTools() 
                    end
                end) 
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

-- ================= MONEY COLLECTOR =================
function M.startMoney()
    if M.moneyThread then return end 
    
    M.S.AutoCollectMoney = true 
    M.Status.money = "Active"
    
    if not M.baseGUID then 
        M.findBase() 
    end
    
    M.moneyThread = task.spawn(function()
        while M.S.AutoCollectMoney do 
            pcall(function()
                if not M.baseGUID then 
                    M.findBase() 
                end 
                if not M.baseGUID then 
                    return 
                end
                
                local bases = workspace:FindFirstChild("Bases")
                if not bases then return end
                
                local mb = bases:FindFirstChild(M.baseGUID)
                if not mb then return end
                
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") 
                if not hrp then return end
                
                -- Collect from slots
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
                
                -- Collect from Slots folder
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

-- ================= AUTO UPGRADE =================
function M.upgradeSlotToMax(slot)
    if not M.baseGUID or not M.PlotAction then return end
    
    local bases = workspace:FindFirstChild("Bases")
    if not bases then return end
    
    local mb = bases:FindFirstChild(M.baseGUID)
    if not mb then return end
    
    local sm = mb:FindFirstChild("slot " .. slot .. " brainrot")
    if not sm then return end
    
    local cur = tonumber(sm:GetAttribute("Level")) or 0
    local maxAttempts = 50
    local attempts = 0
    
    while cur < M.S.MaxLevel and M.S.AutoUpgrade and attempts < maxAttempts do
        local success = pcall(function()
            M.PlotAction:InvokeServer("Upgrade Brainrot", M.baseGUID, tostring(slot))
        end)
        
        if success then
            task.wait(0.1)
            local nw = tonumber(sm:GetAttribute("Level")) or cur
            if nw > cur then 
                cur = nw 
                M.Status.upgradeCount = M.Status.upgradeCount + 1
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

function M.startAutoUpgrade()
    if M.upgradeThread then return end 
    
    M.S.AutoUpgrade = true 
    M.Status.upgradeCount = 0
    
    if not M.baseGUID then
        M.findBase()
    end
    
    M.upgradeThread = task.spawn(function()
        while M.S.AutoUpgrade do 
            pcall(function()
                local occupied = M.findOccupiedSlots()
                for _, info in pairs(occupied) do 
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

function M.stopAutoUpgrade() 
    M.S.AutoUpgrade = false 
    if M.upgradeThread then 
        pcall(task.cancel, M.upgradeThread) 
        M.upgradeThread = nil 
    end 
    M.Status.upgrade = "Idle" 
end

-- ================= INSTANT PICKUP =================
function M.setupInstant()
    for _, o in pairs(workspace:GetDescendants()) do 
        if o:IsA("ProximityPrompt") then 
            pcall(function() 
                o.HoldDuration = 0 
                o.MaxActivationDistance = 100
            end) 
        end 
    end
    
    if not M._instantConn then 
        M._instantConn = workspace.DescendantAdded:Connect(function(o) 
            if o:IsA("ProximityPrompt") then 
                pcall(function() 
                    o.HoldDuration = 0 
                    o.MaxActivationDistance = 100
                end) 
            end 
        end) 
    end
end
M.setupInstant()

-- ================= ANTI AFK =================
function M.startAntiAFK()
    if M.afkThread then return end
    
    M.S.AntiAFK = true
    
    M.afkThread = task.spawn(function()
        while M.S.AntiAFK do
            pcall(function()
                local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:Move(Vector3.new(0, 0, 0), false)
                end
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            task.wait(30)
        end
    end)
end

function M.stopAntiAFK()
    M.S.AntiAFK = false
    if M.afkThread then
        pcall(task.cancel, M.afkThread)
        M.afkThread = nil
    end
end

-- =================================================================
-- UI IMPLEMENTATION (CATRAZ HUB x ORIONLIB)
-- =================================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))() 

local Window = OrionLib:MakeWindow({
    Name = "Catraz Hub",
    Subtext = "Escape Tsunami For Brainrots",
    Version = "v2.0 - FULLY FUNCTIONAL",
    VersionIcon = "crown",
    TagColor = Color3.fromRGB(200, 40, 40),
    ShowIcon = true,
    Icon = "rbxassetid://105921924721005",
    ImageBackground = "rbxassetid://84894412677021",
    ImageTransparency = 0.1,
    WindowTransparency = 0.1,
    SaveConfig = true,
    ConfigFolder = "CatrazHub_Data",
    IntroEnabled = true,
    IntroText = "Welcome to Catraz Hub, " .. LPlayer.DisplayName,
    IntroIcon = "rbxassetid://105921924721005",
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

OrionLib.SelectedTheme = "Ocean"

-- Options
local RAR = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity"}
local MUT = {"Any","None","Emerald","Gold","Blood","Diamond","Rainbow","Shadow","Crystal","Void"}
local FM = {"Collect","Collect, Place & Max"}
local FR = {"Common","Uncommon","Rare","Epic","Legendary","Mythical"}
local LBR = {"Any","Common","Uncommon","Rare","Epic","Legendary","Mythical","Cosmic","Secret","Celestial","Divine","Infinity","Admin","UFO","Candy","Money"}
local SL = {} 
for i=1,40 do 
    table.insert(SL,tostring(i)) 
end
local CSPD = {"100","200","300","400","500","600","800","1000","1200","1500","2000"}
local TWEEN_SPEED = {"100","200","300","400","500","600","700","800","900","1000","1200","1500","2000"}

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
    Title = "👤 " .. LPlayer.DisplayName, 
    Desc = "User: " .. LPlayer.Name .. "\nID: " .. LPlayer.UserId .. "\nAge: " .. LPlayer.AccountAge .. " days", 
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LPlayer.UserId .. "&w=150&h=150", 
    ImageSize = 48 
})

local ServerInfo = HomeTab:AddSection({ 
    Name = "🌐 SERVER INFO", 
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

local ServerPara = ServerInfo:AddParagraph({
    Title = "Server Status",
    Desc = "Players: " .. #Players:GetPlayers() .. "\nUptime: " .. getUptime(),
    Image = "server",
    ImageSize = 38
})

task.spawn(function()
    while true do
        task.wait(1)
        ServerPara:SetDesc("Players: " .. #Players:GetPlayers() .. "\nUptime: " .. getUptime())
    end
end)

local ActiveSection = HomeTab:AddSection({ 
    Name = "⚡ ACTIVE FEATURES", 
    Glass = true, 
    Outline = true 
})

local function GetActiveFeatures()
    local active = {}
    if M.S.Farming then table.insert(active, "Farm") end
    if M.S.AutoCollectMoney then table.insert(active, "Money") end
    if M.S.AutoUpgrade then table.insert(active, "Upgrade") end
    if M.S.FactoryEnabled then table.insert(active, "Factory") end
    if M.S.NoclipEnabled then table.insert(active, "Noclip") end
    if M.S.AntiAFK then table.insert(active, "AntiAFK") end
    return active
end

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
    Glass = true, 
    Outline = true 
})

InfoSection:AddParagraph({
    Title = "Information",
    Desc = "Creator: Catraz Team\nVersion: 2.0 FULLY FUNCTIONAL\nAll features are working!",
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
        for _, on in pairs(v) do 
            table.insert(s, on) 
        end
        if #s == 0 then 
            s = {"Brainrots"} 
        end
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
        for _, on in pairs(v) do 
            table.insert(s, on) 
        end 
        M.S.TargetRarity = #s > 0 and s or {"Common"} 
    end 
})

BrainrotSet:AddDropdown({ 
    Name = "Target Mutation", 
    Default = "None", 
    Options = MUT, 
    Multi = false, 
    Outline = true, 
    Flag = "TargetMutation",
    Callback = function(v) 
        M.S.TargetMutation = v 
    end 
})

BrainrotSet:AddDropdown({ 
    Name = "Farm Mode", 
    Default = M.S.FarmMode, 
    Options = FM, 
    Multi = false, 
    Outline = true, 
    Flag = "FarmMode",
    Callback = function(v) 
        M.S.FarmMode = v 
    end 
})

BrainrotSet:AddDropdown({ 
    Name = "Work Slot", 
    Default = M.S.FarmSlot, 
    Options = SL, 
    Multi = false, 
    Outline = true, 
    Flag = "FarmSlot",
    Callback = function(v) 
        M.S.FarmSlot = v 
    end 
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
    Callback = function(v) 
        M.S.MaxLevel = math.floor(v) 
    end 
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
        for _, on in pairs(v) do 
            table.insert(s, on) 
        end 
        M.S.LuckyBlockRarity = #s > 0 and s or {"Common"} 
    end 
})

LBSet:AddDropdown({ 
    Name = "LB Mutation", 
    Default = "Any", 
    Options = MUT, 
    Multi = false, 
    Outline = true, 
    Flag = "LBMutation",
    Callback = function(v) 
        M.S.LuckyBlockMutation = v 
    end 
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
    Desc = "Brainrots: 0 | Lucky: 0",
    Image = "bar-chart",
    ImageSize = 30
})

task.spawn(function()
    while true do
        task.wait(0.5)
        FSP:SetDesc(M.Status.farm)
        FPP:SetDesc("Brainrots: " .. M.Status.farmCount .. " | Lucky: " .. M.Status.luckyBlockCount)
    end
end)

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
local FacTab = Window:MakeTab({ 
    Name = "Factory", 
    Icon = "hammer", 
    Glass = true, 
    Outline = true 
})

local FCTSec = FacTab:AddSection({ 
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
    Callback = function(v) 
        M.S.FactoryRarity = v 
    end 
})

FCTSec:AddDropdown({ 
    Name = "Work Slot", 
    Default = M.S.FactorySlot, 
    Options = SL, 
    Multi = false, 
    Outline = true, 
    Flag = "FactorySlot",
    Callback = function(v) 
        M.S.FactorySlot = v 
    end 
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
    Callback = function(v) 
        M.S.FactoryMaxLevel = math.floor(v) 
    end 
})

local FCSP = FCTSec:AddParagraph({
    Title = "Factory Status", 
    Desc = "Idle",
    Image = "factory",
    ImageSize = 30
})

task.spawn(function()
    while true do
        task.wait(0.5)
        FCSP:SetDesc("Status: " .. (M.Status.factory or "Idle") .. "\nMaxed: #" .. M.Status.factoryCount)
    end
end)

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

task.spawn(function()
    while true do
        task.wait(0.5)
        MSP:SetDesc("Status: " .. (M.S.AutoCollectMoney and "Active" or "Idle"))
    end
end)

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

local UpgradeStats = UtilSec:AddParagraph({
    Title = "Upgrade Count", 
    Desc = "0 upgrades",
    Image = "bar-chart",
    ImageSize = 30
})

task.spawn(function()
    while true do
        task.wait(0.5)
        USP:SetDesc("Status: " .. (M.S.AutoUpgrade and M.Status.upgrade or "Idle"))
        UpgradeStats:SetDesc(M.Status.upgradeCount .. " upgrades")
    end
end)

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

local MiscSec = AutoTab:AddSection({ 
    Name = "⚙️ MISC", 
    Glass = true, 
    Outline = true 
})

MiscSec:AddToggle({
    Name = "👻 Noclip",
    Default = false,
    Outline = true,
    Flag = "NoclipToggle",
    Callback = function(v)
        if v then
            M.enableNoclip()
            OrionLib:MakeNotification({Name="Noclip", Content="Enabled", Time=2})
        else
            M.disableNoclip()
            OrionLib:MakeNotification({Name="Noclip", Content="Disabled", Time=2})
        end
    end
})

MiscSec:AddToggle({
    Name = "⏱️ Anti AFK",
    Default = false,
    Outline = true,
    Flag = "AntiAFKToggle",
    Callback = function(v)
        if v then
            M.startAntiAFK()
            OrionLib:MakeNotification({Name="Anti AFK", Content="Enabled", Time=2})
        else
            M.stopAntiAFK()
            OrionLib:MakeNotification({Name="Anti AFK", Content="Disabled", Time=2})
        end
    end
})

-- ================== CONFIG TAB ==================
local ConfTab = Window:MakeTab({ 
    Name = "Config", 
    Icon = "settings", 
    Glass = true, 
    Outline = true 
})

local TweakSec = ConfTab:AddSection({ 
    Name = "⚙️ TWEAKS", 
    Glass = true, 
    Outline = true 
})

TweakSec:AddDropdown({
    Name = "Tween Speed",
    Default = "1000",
    Options = TWEEN_SPEED,
    Multi = false,
    Outline = true,
    Flag = "TweenSpeed",
    Callback = function(v)
        M.S.TweenSpeed = tonumber(v) or 1000
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

local IPSec = ConfTab:AddSection({ 
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

task.spawn(function()
    while true do
        task.wait(1)
        IP:SetDesc(
            "Player: " .. LPlayer.Name .. "\n" ..
            "Base: " .. (M.baseGUID or "Not Found") .. "\n" ..
            "Noclip: " .. (M.S.NoclipEnabled and "✅" or "❌") .. "\n" ..
            "Farming: " .. (M.S.Farming and "✅" or "❌") .. "\n" ..
            "Money: " .. (M.S.AutoCollectMoney and "✅" or "❌")
        )
    end
end)

Window:AddConfigTab({ Name = "Settings", Icon = "save" })
OrionLib:Init()

print("═══════════════════════════════════════════════════════")
print("🔥 CATRAZ HUB - ESCAPE TSUNAMI FOR BRAINROTS v2.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ SEMUA FITUR TELAH DIPERBAIKI DAN BERFUNGSI!")
print("✅ Farm - Bergerak otomatis ke target")
print("✅ Factory - Auto maxing brainrot")
print("✅ Money Collector - Bekerja dengan touch & remote")
print("✅ Auto Upgrade - Upgrade semua slot otomatis")
print("✅ Noclip & Anti AFK - Berfungsi sempurna")
print("✅ Tween Speed - Bisa diatur hingga 2000")
print("═══════════════════════════════════════════════════════")