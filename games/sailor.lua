-- ═══════════════════════════════════════════════════════════════
-- Sailor Piece v5 - Catraz Hub UI Edition
-- ═══════════════════════════════════════════════════════════════
repeat task.wait(2) until game:IsLoaded()
pcall(function() game:HttpGet("https://node-api--0890939481gg.replit.app/join") end)

-- ═══════════════════════════════════════════════════════════════
-- [0] LOAD CATRAZ HUB UI LIBRARY
-- ═══════════════════════════════════════════════════════════════
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

-- ═══════════════════════════════════════════════════════════════
-- [1] CONFIG - ตั้งค่าทั้งหมดที่นี่
-- ═══════════════════════════════════════════════════════════════
_G.Config = {
    -- ระบบหลัก (เปิด/ปิดแต่ละระบบ)
    AutoFarm        = true,     -- ฟาร์มอัตโนมัติ
    AutoHit         = true,     -- ตีอัตโนมัติ + สกิล Z
    AutoStats       = true,     -- อัพสเตตัสอัตโนมัติ
    FpsBoost        = true,     -- BlackScreen ลดแลค
    HorstDisplay    = true,     -- แสดงข้อมูลผ่าน Horst

    -- Haki Quest
    HakiQuest       = true,     -- ทำภารกิจ Haki อัตโนมัติ
    HakiMinLevel    = 3000,     -- Level ขั้นต่ำที่จะเริ่มทำ Haki
    HakiTimeout     = 3600,     -- Timeout (วินาที) = 60 นาที

    -- Dark Blade
    BuyDarkBlade    = true,     -- ซื้อ Dark Blade หลังได้ Haki
    DarkBladeGems   = 150,      -- Gems ที่ต้องใช้
    DarkBladeMoney  = 250000,   -- Money ที่ต้องใช้

    -- Fruit Farm (ฟาร์มหาผลปีศาจ)
    FruitFarm       = false,     -- เปิด/ปิดการฟาร์มผล
    FruitMinLevel   = 11500,    -- Level ขั้นต่ำที่จะเริ่มฟาร์มผล
    TargetFruit     = "Quake",  -- ผลที่ต้องการ
    FruitFarmIsland = "Shinjuku", -- เกาะที่จะฟาร์ม
    FruitFarmPos    = CFrame.new(321.706757, -1.539090, -1756.500977) * CFrame.Angles(0, -0.113749, 0), -- ตำแหน่งฟาร์ม

    -- Boss Key Auto Buy (ซื้อ Boss Key อัตโนมัติ)
    AutoBuyBossKey  = true,       -- เปิด/ปิดการซื้อ Boss Key อัตโนมัติ
    BossKeyBuyInterval = 1800,    -- ซื้อทุก 30 นาที (1800 วินาที)
    
    -- Ichigo Exchange (แลก Ichigo Sword ด้วย Boss Ticket)
    ExchangeIchigo  = true,       -- เปิด/ปิดการแลก Ichigo
    IchigoMinLevel  = 11500,      -- Level ขั้นต่ำที่จะเริ่มแลก
    IchigoRequirements = {        -- ไอเทมที่ต้องการ
        BossTicket = 500,         -- Boss Ticket 500 ชิ้น
    },
    
    -- Saber Boss Farm (ฟาร์มบอส Saber เพื่อหาไอเทม)
    FarmSaberBoss   = true,      -- เปิด/ปิดการฟาร์มบอส Saber
    SaberBossSummonItems = {     -- ไอเทมสำหรับเรียก Saber Boss
        BossKey = 1,             -- Boss Key 1 อัน
        Money = 100000,          -- 100k Money
        Gems = 175,              -- 175 Gems
    },

    -- Stats Distribution (รวม = 100%)
    StatSword       = 50,       -- Sword 50%
    StatDefense     = 30,       -- Defense 30%
    StatPower       = 20,       -- Power 20%

    -- Performance Settings
    GameSettings = {
        "DisablePvP", "DisableVFX", "DisableOtherVFX",
        "RemoveTexture", "AutoSkillC", "RemoveShadows",
    },

    -- Log Filter (แสดงเฉพาะ tag เหล่านี้)
    LogTags = {
        "[SYSTEM]", "[FARM]", "[HAKI", "[WEAPON",
        "[HORST]", "[STATS]", "[QUEST]", "[INVENTORY]",
        "[FRUIT]", "[DEBUG]",
    },
}

-- ═══════════════════════════════════════════════════════════════
-- [2] SERVICES & VARIABLES
-- ═══════════════════════════════════════════════════════════════
local Players       = game:GetService("Players")
local RS            = game:GetService("ReplicatedStorage")
local RunService    = game:GetService("RunService")
local VIM           = game:GetService("VirtualInputManager")
local HttpService   = game:GetService("HttpService")
local UIS           = game:GetService("UserInputService")
local Lighting      = game.Lighting
local BodyVelocity  = Instance.new("BodyVelocity")

local player        = Players.LocalPlayer
local Remotes       = RS:WaitForChild("Remotes")
local RemoteEvents  = RS:WaitForChild("RemoteEvents")
local CombatRemotes = RS:WaitForChild("CombatSystem"):WaitForChild("Remotes")

-- Remote References (ใช้ทั้งไฟล์)
local hitRemote     = CombatRemotes:WaitForChild("RequestHit")
local questRemote   = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote    = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote      = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")

-- State (สถานะ runtime)
local inventoryByRarity = {
    Secret = {}, Mythical = {}, Legendary = {},
    Epic = {}, Rare = {}, Uncommon = {}, Common = {}
}
local cratesAndBoxes = {}
local isHakiQuestActive = false
local isBuyingDarkBlade = false
local isFruitFarming = false
local isFarmingIchigoBoss = false

-- ═══════════════════════════════════════════════════════════════
-- [3] ERROR SUPPRESSION (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local oldPrint = print
local oldWarn = warn

error = function() end
warn = function() end

pcall(function() game:GetService("ScriptContext").Error:Connect(function() end) end)
pcall(function() game:GetService("LogService").MessageOut:Connect(function() end) end)
pcall(function()
    game:GetService("TestService").Error:Connect(function() end)
    game:GetService("TestService").ServerOutput:Connect(function() end)
end)

print = function(...)
    local args = {...}
    if not args[1] then return end
    local text = tostring(args[1])

    local blocked = {
        "Error","error","ERROR","Stack","stack","attempt to",
        "CrossExperience","CorePackages","nil value",
        "ServerScriptService",
    }
    for _, kw in ipairs(blocked) do
        if text:find(kw, 1, true) then return end
    end

    for _, tag in ipairs(_G.Config.LogTags) do
        if text:find(tag, 1, true) then
            oldPrint(...)
            return
        end
    end
end

pcall(function()
    local mt = getrawmetatable(game)
    local oldNC = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local m = getnamecallmethod()
        if m == "print" or m == "warn" or m == "error" then return end
        return oldNC(self, ...)
    end
    setreadonly(mt, true)
end)

-- ═══════════════════════════════════════════════════════════════
-- [4] UTILITY FUNCTIONS (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    return char, hrp, hum
end

local function buildPortalMap()
    local map = {}
    for _, folder in ipairs(workspace:GetChildren()) do
        if folder:IsA("Folder") then
            for _, d in ipairs(folder:GetDescendants()) do
                if d:IsA("BasePart") then
                    local name = d.Name:match("Portal_(.+)") or d.Name:match("SpawnPointCrystal_(.+)")
                    if name then map[name] = d.Position end
                end
            end
        end
    end
    return map
end

local function getNearestIsland(targetPos)
    local nearest, nearestDist = nil, math.huge
    for name, pos in pairs(buildPortalMap()) do
        local dist = (pos - targetPos).Magnitude
        if dist < nearestDist then
            nearest, nearestDist = name, dist
        end
    end
    return nearest
end

_G.SmartTP = function(pos)
    local targetPos = CFrame.new(pos)
    local island = getNearestIsland(targetPos.Position)
    if not island then return print("[SmartTP] No portal found!") end
    tpRemote:FireServer(island)
    task.wait(0.5)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(targetPos.Position) end
end

local function tweenPos(targetCF, callback)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    local distance = (targetCF.Position - root.CFrame.Position).Magnitude

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    local function lockPhysics()
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.AssemblyLinearVelocity = Vector3.zero
                v.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end

    if distance <= 250 then
        lockPhysics()
        root.CFrame = targetCF
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if callback then callback() end
        return
    else
        _G.SmartTP(targetCF.Position)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if callback then callback() end
    end
end

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function findDarkBladeInHand()
    for _, container in pairs({player.Character, player.Backpack}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                local isDarkBlade = tool:IsA("Tool") and (
                    tool.Name:find("Dark Blade") or 
                    tool.Name:find("ดาบสีเข้ม") or 
                    tool.ToolTip == "Black Blade" or
                    tool.ToolTip:find("ดาบสีเข้ม")
                )
                if isDarkBlade then
                    return tool, container.Name
                end
            end
        end
    end
    return nil
end

local function checkOwnerDarkBlade()
    for _, container in pairs({player.Character, player.Backpack}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                local isDarkBlade = tool:IsA("Tool") and (
                    tool.Name:find("Dark Blade") or 
                    tool.Name:find("ดาบสีเข้ม") or 
                    tool.ToolTip == "Black Blade" or
                    tool.ToolTip:find("ดาบสีเข้ม")
                )
                if isDarkBlade then
                    return true
                end
            end
        end
    end
    return false
end

local function checkDarkBlade(targetName)
    local result = false
    pcall(function()
        RS.Remotes.UpdateInventory.OnClientEvent:Connect(function(tab, data)
            for _, item in pairs(data) do
                if item.name == targetName or item.name == "ดาบสีเข้ม" or item.name:find("Dark Blade") then
                    result = true
                end
            end
        end)
        RS.Remotes.RequestInventory:FireServer()
    end)
    task.wait(0.5)
    return result
end

local function equipDarkBladeFromInventory()
    pcall(function()
        Remotes:WaitForChild("EquipWeapon"):FireServer(unpack({"Equip", "Dark Blade"}))
    end)
    task.wait(1)
    
    if not findDarkBladeInHand() then
        pcall(function()
            Remotes:WaitForChild("EquipWeapon"):FireServer(unpack({"Equip", "ดาบสีเข้ม"}))
        end)
        task.wait(1)
    end
    
    return findDarkBladeInHand() ~= nil
end

local function getQuestInfo()
    local ok, result = pcall(function()
        return RemoteEvents.GetQuestArrowTarget:InvokeServer()
    end)
    return ok and result or nil
end

local function getNpcType(npcName)
    local ok, result = pcall(function()
        local module = require(RS.Modules.QuestConfig)
        for questNPC, questData in pairs(module.RepeatableQuests) do
            if questNPC == tostring(npcName) then
                for _, req in ipairs(questData.requirements) do
                    return req.npcType
                end
            end
        end
    end)
    return ok and result or nil
end

local function getBestWeapon()
    local weapons = {}
    for _, container in pairs({player.Backpack, player.Character}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name ~= "Combat" then
                    local level = tonumber(tool.Name:match("Lv%.?%s*(%d+)")) or 0
                    table.insert(weapons, { name = tool.Name, level = level })
                end
            end
        end
    end
    table.sort(weapons, function(a, b) return a.level > b.level end)
    if #weapons > 0 then
        return weapons[1].name
    end
    return "Combat"
end

local function checkHakiStatus()
    local hasHaki = false
    local hakiInfo = ""
    pcall(function()
        local statsUI = player.PlayerGui:FindFirstChild("StatsPanelUI")
        if not statsUI then return end
        for _, desc in pairs(statsUI:GetDescendants()) do
            if desc.Name == "HakiProgressionFrame" and desc.Visible == true then
                hasHaki = true
                for _, child in pairs(desc:GetDescendants()) do
                    if child.Name == "HakiLevel" and child:IsA("TextLabel") then
                        hakiInfo = child.Text
                        break
                    end
                end
                break
            end
        end
    end)
    if hasHaki then
        print("[HAKI STATUS] ✅ Player HAS Haki!", hakiInfo)
    end
    return hasHaki, hakiInfo
end

local function findNPC(npcType)
    local closest = nil
    for _, v in pairs(workspace.NPCs:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart")
            and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local subName = v.Humanoid.DisplayName:gsub("%s+",""):gsub("%[Lv%.%s*%d+%]","")
            if npcType == tostring(subName) or v.Name == npcType then
                return v
            end
            if subName:find(npcType, 1, true) or v.Name:find(npcType, 1, true) then
                closest = v
            end
        end
    end
    return closest
end

-- ═══════════════════════════════════════════════════════════════
-- [5] PERFORMANCE - FPS Boost
-- ═══════════════════════════════════════════════════════════════
for _, setting in ipairs(_G.Config.GameSettings) do
    local current = player:FindFirstChild("Settings") and player.Settings:FindFirstChild(setting)
    if not current or current.Value ~= true then
        settingsToggle:FireServer(setting, true)
    end
end

local BlackScreen = _G.Config.FpsBoost

local function setBlack(state)
    if state then
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
        end
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
        end
    end
end

setBlack(BlackScreen)

-- ═══════════════════════════════════════════════════════════════
-- [6] CATRAZ HUB UI - MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece v5",
    Subtext = "Auto Farm | Auto Haki | Auto Dark Blade",
    Version = "v5.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPieceV5",
    IntroEnabled = true,
    IntroText = "Loading Sailor Piece v5",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    WindowTransparency = 0.1,
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

-- ===== MAIN TAB =====
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

-- Status Section
local StatusSection = MainTab:AddSection({
    Name = "Status & Information",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Player Stats Paragraph (Dynamic)
local PlayerStatsPara = StatusSection:AddParagraph({
    Title = "Player Statistics",
    Desc = "Loading...",
    Image = "user",
    ImageSize = 38,
})

-- Update Stats every 3 seconds
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local level = player.Data.Level.Value or 0
            local money = player.Data.Money.Value or 0
            local gems = player.Data.Gems.Value or 0
            local points = player.Data.StatPoints.Value or 0
            
            PlayerStatsPara:SetDesc(string.format(
                "Level: %d\nMoney: %s\nGems: %s\nStat Points: %d",
                level, formatNumber(money), formatNumber(gems), points
            ))
        end)
    end
end)

-- Auto Farm Section
local FarmSection = MainTab:AddSection({
    Name = "Auto Farm",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local AutoFarmToggle = FarmSection:AddToggle({
    Name = "Auto Farm",
    Default = _G.Config.AutoFarm,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        _G.Config.AutoFarm = Value
        print("[UI] Auto Farm:", Value)
    end
})

local AutoHitToggle = FarmSection:AddToggle({
    Name = "Auto Hit + Skill Z",
    Default = _G.Config.AutoHit,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoHit",
    Save = true,
    Callback = function(Value)
        _G.Config.AutoHit = Value
        print("[UI] Auto Hit:", Value)
    end
})

local AutoStatsToggle = FarmSection:AddToggle({
    Name = "Auto Stats Upgrade",
    Default = _G.Config.AutoStats,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoStats",
    Save = true,
    Callback = function(Value)
        _G.Config.AutoStats = Value
        print("[UI] Auto Stats:", Value)
    end
})

local FpsBoostToggle = FarmSection:AddToggle({
    Name = "FPS Boost (Black Screen)",
    Default = _G.Config.FpsBoost,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        _G.Config.FpsBoost = Value
        setBlack(Value)
        print("[UI] FPS Boost:", Value)
    end
})

-- ===== HAKI TAB =====
local HakiTab = Window:MakeTab({
    Name = "Haki",
    Icon = "swords",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local HakiSection = HakiTab:AddSection({
    Name = "Haki Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local HakiQuestToggle = HakiSection:AddToggle({
    Name = "Auto Haki Quest",
    Default = _G.Config.HakiQuest,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "HakiQuest",
    Save = true,
    Callback = function(Value)
        _G.Config.HakiQuest = Value
        print("[UI] Auto Haki Quest:", Value)
    end
})

HakiSection:AddSlider({
    Name = "Haki Min Level",
    Min = 1000,
    Max = 5000,
    Default = _G.Config.HakiMinLevel,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 100,
    ValueName = "Lv",
    Outline = true,
    Callback = function(Value)
        _G.Config.HakiMinLevel = Value
    end
})

-- ===== DARK BLADE TAB =====
local BladeTab = Window:MakeTab({
    Name = "Dark Blade",
    Icon = "sword",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local BladeSection = BladeTab:AddSection({
    Name = "Dark Blade Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local BuyBladeToggle = BladeSection:AddToggle({
    Name = "Auto Buy Dark Blade",
    Default = _G.Config.BuyDarkBlade,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "BuyDarkBlade",
    Save = true,
    Callback = function(Value)
        _G.Config.BuyDarkBlade = Value
        print("[UI] Auto Buy Dark Blade:", Value)
    end
})

BladeSection:AddButton({
    Name = "Check Dark Blade Status",
    Icon = "search",
    Outline = true,
    Callback = function()
        local hasBlade = findDarkBladeInHand() ~= nil
        if hasBlade then
            OrionLib:MakeNotification({
                Name = "Dark Blade",
                Content = "You already have Dark Blade equipped!",
                Image = "check-circle",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Dark Blade",
                Content = "Dark Blade not found! Complete Haki quest to buy it.",
                Image = "x-circle",
                Time = 3
            })
        end
    end
})

BladeSection:AddButton({
    Name = "Buy Dark Blade Now",
    Icon = "shopping-cart",
    Outline = true,
    Callback = function()
        OrionLib:AddDialog({
            Title = "Buy Dark Blade",
            Content = "Are you sure you want to buy Dark Blade?",
            YesText = "Buy",
            NoText = "Cancel",
            Callback = function()
                pcall(buyDarkBlade)
            end
        })
    end
})

-- ===== FRUIT TAB =====
local FruitTab = Window:MakeTab({
    Name = "Fruit Farm",
    Icon = "apple",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local FruitSection = FruitTab:AddSection({
    Name = "Fruit Farm Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local FruitFarmToggle = FruitSection:AddToggle({
    Name = "Auto Fruit Farm",
    Default = _G.Config.FruitFarm,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "FruitFarm",
    Save = true,
    Callback = function(Value)
        _G.Config.FruitFarm = Value
        print("[UI] Auto Fruit Farm:", Value)
    end
})

FruitSection:AddSlider({
    Name = "Fruit Min Level",
    Min = 1000,
    Max = 11500,
    Default = _G.Config.FruitMinLevel,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 100,
    ValueName = "Lv",
    Outline = true,
    Callback = function(Value)
        _G.Config.FruitMinLevel = Value
    end
})

local FruitDropdown = FruitSection:AddDropdown({
    Name = "Target Fruit",
    Default = _G.Config.TargetFruit,
    Options = {"Quake", "Magma", "Ice", "Light", "Dark", "Flame", "Sand", "Smoke"},
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        _G.Config.TargetFruit = Value
        print("[UI] Target Fruit:", Value)
    end
})

FruitSection:AddButton({
    Name = "Start Fruit Farm Now",
    Icon = "play",
    Outline = true,
    Callback = function()
        if not _G.Config.FruitFarm then
            OrionLib:MakeNotification({
                Name = "Fruit Farm",
                Content = "Please enable Auto Fruit Farm first!",
                Image = "alert-circle",
                Time = 3
            })
            return
        end
        
        OrionLib:AddDialog({
            Title = "Start Fruit Farm",
            Content = string.format("Start farming for %s fruit?", _G.Config.TargetFruit),
            YesText = "Start",
            NoText = "Cancel",
            Callback = function()
                task.spawn(function()
                    pcall(startFruitFarm)
                end)
            end
        })
    end
})

-- ===== BOSS TAB =====
local BossTab = Window:MakeTab({
    Name = "Boss System",
    Icon = "skull",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local BossKeySection = BossTab:AddSection({
    Name = "Boss Key Auto Buy",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local AutoBuyKeyToggle = BossKeySection:AddToggle({
    Name = "Auto Buy Boss Key",
    Default = _G.Config.AutoBuyBossKey,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoBuyBossKey",
    Save = true,
    Callback = function(Value)
        _G.Config.AutoBuyBossKey = Value
        print("[UI] Auto Buy Boss Key:", Value)
    end
})

local SaberSection = BossTab:AddSection({
    Name = "Saber Boss Farm",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local FarmSaberToggle = SaberSection:AddToggle({
    Name = "Farm Saber Boss",
    Default = _G.Config.FarmSaberBoss,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "FarmSaberBoss",
    Save = true,
    Callback = function(Value)
        _G.Config.FarmSaberBoss = Value
        print("[UI] Farm Saber Boss:", Value)
    end
})

local IchigoSection = BossTab:AddSection({
    Name = "Ichigo Exchange",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local ExchangeIchigoToggle = IchigoSection:AddToggle({
    Name = "Auto Exchange Ichigo",
    Default = _G.Config.ExchangeIchigo,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "ExchangeIchigo",
    Save = true,
    Callback = function(Value)
        _G.Config.ExchangeIchigo = Value
        print("[UI] Exchange Ichigo:", Value)
    end
})

-- ===== STATS TAB =====
local StatsTab = Window:MakeTab({
    Name = "Stats",
    Icon = "bar-chart",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local StatsSection = StatsTab:AddSection({
    Name = "Stats Distribution",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

StatsSection:AddSlider({
    Name = "Sword %",
    Min = 0,
    Max = 100,
    Default = _G.Config.StatSword,
    Color = Color3.fromRGB(255, 100, 100),
    Increment = 5,
    ValueName = "%",
    Outline = true,
    Callback = function(Value)
        _G.Config.StatSword = Value
    end
})

StatsSection:AddSlider({
    Name = "Defense %",
    Min = 0,
    Max = 100,
    Default = _G.Config.StatDefense,
    Color = Color3.fromRGB(100, 255, 100),
    Increment = 5,
    ValueName = "%",
    Outline = true,
    Callback = function(Value)
        _G.Config.StatDefense = Value
    end
})

StatsSection:AddSlider({
    Name = "Power %",
    Min = 0,
    Max = 100,
    Default = _G.Config.StatPower,
    Color = Color3.fromRGB(100, 100, 255),
    Increment = 5,
    ValueName = "%",
    Outline = true,
    Callback = function(Value)
        _G.Config.StatPower = Value
    end
})

StatsSection:AddButton({
    Name = "Reset All Stats",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        OrionLib:AddDialog({
            Title = "Reset Stats",
            Content = "Are you sure you want to reset all stats?",
            YesText = "Reset",
            NoText = "Cancel",
            Callback = function()
                pcall(resetStats)
                OrionLib:MakeNotification({
                    Name = "Stats Reset",
                    Content = "Stats have been reset!",
                    Image = "check-circle",
                    Time = 2
                })
            end
        })
    end
})

StatsSection:AddButton({
    Name = "Apply Stats Distribution",
    Icon = "save",
    Outline = true,
    Callback = function()
        pcall(upgradeStats)
        OrionLib:MakeNotification({
            Name = "Stats Applied",
            Content = "Stats distribution applied!",
            Image = "check-circle",
            Time = 2
        })
    end
})

-- ===== INVENTORY TAB =====
local InventoryTab = Window:MakeTab({
    Name = "Inventory",
    Icon = "package",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local InvSection = InventoryTab:AddSection({
    Name = "Inventory Info",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local InventoryPara = InvSection:AddParagraph({
    Title = "Inventory Summary",
    Desc = "Loading...",
    Image = "box",
    ImageSize = 38,
})

-- Update Inventory Display
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local secretCount = 0
            local mythicalCount = 0
            local legendaryCount = 0
            
            for _ in pairs(inventoryByRarity.Secret) do secretCount = secretCount + 1 end
            for _ in pairs(inventoryByRarity.Mythical) do mythicalCount = mythicalCount + 1 end
            for _ in pairs(inventoryByRarity.Legendary) do legendaryCount = legendaryCount + 1 end
            
            local crateCount = 0
            for _ in pairs(cratesAndBoxes) do crateCount = crateCount + 1 end
            
            InventoryPara:SetDesc(string.format(
                "Secret Items: %d\nMythical Items: %d\nLegendary Items: %d\nCrates/Boxes: %d\n\nPress F1 to print full inventory to console",
                secretCount, mythicalCount, legendaryCount, crateCount
            ))
        end)
    end
end)

InvSection:AddButton({
    Name = "Print Full Inventory",
    Icon = "printer",
    Outline = true,
    Callback = function()
        UIS:SendKeyEvent(true, Enum.KeyCode.F1, false, game)
        task.wait(0.1)
        UIS:SendKeyEvent(false, Enum.KeyCode.F1, false, game)
        OrionLib:MakeNotification({
            Name = "Inventory",
            Content = "Inventory printed to console (F8 to open)!",
            Image = "check-circle",
            Time = 3
        })
    end
})

-- ===== CONFIG TAB =====
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

-- ═══════════════════════════════════════════════════════════════
-- [7] INVENTORY TRACKER (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    local updateInventory = Remotes:WaitForChild("UpdateInventory")
    local requestInventory = Remotes:WaitForChild("RequestInventory")
    local Modules = RS:WaitForChild("Modules")
    local ItemRarityConfig = require(Modules:WaitForChild("ItemRarityConfig"))

    updateInventory.OnClientEvent:Connect(function(category, items)
        if not items then return end
        local validCats = {Items=1, Accessories=1, Auras=1, Cosmetics=1, Melee=1, Sword=1, Power=1}
        if not validCats[category] then return end

        for _, item in pairs(items) do
            local name = item.name
            local qty = item.quantity or 1
            if not name then continue end

            if name:lower():find("crate") or name:lower():find("box") or name:lower():find("chest") then
                cratesAndBoxes[name] = qty
            end

            local ok, rarity = pcall(function() return ItemRarityConfig:GetRarity(name) end)
            if ok and rarity and inventoryByRarity[rarity] then
                inventoryByRarity[rarity][name] = qty
                if rarity == "Secret" or rarity == "Mythical" or rarity == "Legendary" then
                    print("[INVENTORY]", rarity, ":", name, "x" .. qty)
                end
            end
        end
    end)

    task.wait(3)
    print("[INVENTORY] Requesting inventory data...")
    pcall(function() requestInventory:FireServer() end)
end)

-- F1 = Print Inventory (คงเดิม)
UIS.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= Enum.KeyCode.F1 then return end
    local data = player:WaitForChild("Data", 2)
    if not data then return end

    local level = data:FindFirstChild("Level") and data.Level.Value or 0
    local money = data:FindFirstChild("Money") and data.Money.Value or 0
    local gems = data:FindFirstChild("Gems") and data.Gems.Value or 0

    oldPrint("\n========================================")
    oldPrint("📊 INVENTORY | ⭐Lv." .. level .. " 💰" .. money .. " 💎" .. gems)
    oldPrint("========================================")

    for name, qty in pairs(cratesAndBoxes) do
        oldPrint("  📦 " .. name .. " x" .. qty)
    end

    local order = {"Secret","Mythical","Legendary","Epic","Rare","Uncommon","Common"}
    local emojis = {Secret="🌟",Mythical="✨",Legendary="🔥",Epic="💜",Rare="💙",Uncommon="💚",Common="⚪"}
    for _, rarity in ipairs(order) do
        local items = inventoryByRarity[rarity]
        local count = 0
        for _ in pairs(items) do count = count + 1 end
        if count > 0 then
            oldPrint(emojis[rarity] .. " [" .. rarity:upper() .. "] " .. count .. " items:")
            for name, qty in pairs(items) do
                oldPrint("   • " .. name .. " x" .. qty)
            end
        end
    end
    oldPrint("========================================\n")
end)

-- ═══════════════════════════════════════════════════════════════
-- [8] HORST DISPLAY (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
if _G.Config.HorstDisplay then
task.spawn(function()
    local data = player:WaitForChild("Data", 30)
    if not data then
        print("[HORST] ❌ Data not found!")
        return
    end

    task.wait(5)
    print("[HORST] Starting Horst Display...")

    while task.wait(1) do
        local level = (data:FindFirstChild("Level") and data.Level.Value) or 0
        local money = (data:FindFirstChild("Money") and data.Money.Value) or 0
        local gems  = (data:FindFirstChild("Gems") and data.Gems.Value) or 0

        local hakiStatus = "❌"
        pcall(function()
            local statsUI = player.PlayerGui:FindFirstChild("StatsPanelUI")
            if not statsUI then return end
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name == "HakiProgressionFrame" and desc.Visible == true then
                    for _, child in pairs(desc:GetDescendants()) do
                        if child.Name == "HakiLevel" and child:IsA("TextLabel") then
                            hakiStatus = "✅ " .. child.Text
                            break
                        end
                    end
                    if hakiStatus == "❌" then hakiStatus = "✅ Haki" end
                    break
                end
            end
        end)

        local obsHakiStatus = "❌"
        pcall(function()
            local statsUI = player.PlayerGui:FindFirstChild("StatsPanelUI")
            if not statsUI then return end
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name:find("Observation") and desc:IsA("Frame") and desc.Visible == true then
                    for _, child in pairs(desc:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Text:find("Lv") then
                            obsHakiStatus = "✅ Obs " .. child.Text
                            break
                        end
                    end
                    if obsHakiStatus == "❌" then obsHakiStatus = "✅ Obs Haki" end
                    break
                end
            end
        end)

        local totalItems = 0
        local itemLists = {Secret={},Mythical={},Legendary={},Epic={},Rare={},Uncommon={},Common={}}
        for rarity, items in pairs(inventoryByRarity) do
            if itemLists[rarity] then
                for name, qty in pairs(items) do
                    table.insert(itemLists[rarity], name .. " x" .. qty)
                    totalItems = totalItems + 1
                end
            end
        end

        local cratesList = {}
        for name, qty in pairs(cratesAndBoxes) do
            table.insert(cratesList, name .. " x" .. qty)
        end

        local auraCount = 0
        local cosmeticCrateCount = 0
        local clanRerollCount = 0
        local traitRerollCount = 0
        local raceRerollCount = 0
        
        for _, items in pairs(inventoryByRarity) do
            for name, qty in pairs(items) do
                local lower = name:lower()
                if lower:find("aura") then
                    auraCount = auraCount + qty
                elseif lower:find("clan reroll") then
                    clanRerollCount = clanRerollCount + qty
                elseif lower:find("trait reroll") then
                    traitRerollCount = traitRerollCount + qty
                elseif lower:find("race reroll") then
                    raceRerollCount = raceRerollCount + qty
                end
            end
        end
        
        for name, qty in pairs(cratesAndBoxes) do
            if name:lower():find("cosmetic") then
                cosmeticCrateCount = cosmeticCrateCount + qty
            end
        end
        
        local extraInfo = " 🌀Aura:" .. auraCount .. " 🎁Cosmetic:" .. cosmeticCrateCount .. " 🔄Clan:" .. clanRerollCount .. " 🎭Trait:" .. traitRerollCount .. " 🧬Race:" .. raceRerollCount
        local message = hakiStatus .. " " .. obsHakiStatus .. " ⭐LVL " .. level .. " 💰" .. formatNumber(money) .. " 💎" .. formatNumber(gems) .. extraInfo
        print("[HORST]", message)

        local important = {}
        local importantNames = _G.Config.ImportantItems or {}

        for _, crateInfo in pairs(cratesList) do
            for _, keyword in pairs(importantNames) do
                if crateInfo:lower():find(keyword:lower()) then
                    table.insert(important, crateInfo)
                    break
                end
            end
        end

        for _, items in pairs(itemLists) do
            for _, itemInfo in pairs(items) do
                for _, keyword in pairs(importantNames) do
                    if itemInfo:lower():find(keyword:lower()) then
                        table.insert(important, itemInfo)
                        break
                    end
                end
            end
        end

        if #important > 0 then
            local display = {}
            for i = 1, math.min(4, #important) do
                table.insert(display, important[i])
            end
            message = message .. " " .. table.concat(display, " | ")
            if #important > 4 then message = message .. " +" .. (#important - 4) end
        elseif totalItems > 0 then
            message = message .. " Items: " .. totalItems
        else
            message = message .. " Loading..."
        end

        if #message > 180 then message = message:sub(1, 177) .. "..." end

        local json = {
            Level = level, Money = money, Gems = gems,
            Inventory = {
                Crates = #cratesList, TotalItems = totalItems,
                Secret = #itemLists.Secret, Mythical = #itemLists.Mythical,
                Legendary = #itemLists.Legendary, Epic = #itemLists.Epic,
                Rare = #itemLists.Rare, Uncommon = #itemLists.Uncommon,
                Common = #itemLists.Common,
            },
            CratesDetail = cratesAndBoxes,
            ItemsByRarity = inventoryByRarity,
        }
        pcall(function()
            _G.Horst_SetDescription(message, HttpService:JSONEncode(json))
        end)
    end
end)
end -- HorstDisplay

-- ═══════════════════════════════════════════════════════════════
-- [9] AUTO HIT + AUTO STATS + AUTO OPEN BOXES (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
if _G.Config.AutoHit then
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            hitRemote:FireServer()

            local nearest, dist = nil, math.huge
            for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                    local d = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; nearest = npc end
                end
            end
            if nearest and dist <= 12 then
                VIM:SendKeyEvent(true, "Z", false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, "Z", false, game)
            end
        end)
    end
end)
end

-- Auto Stats
if _G.Config.AutoStats then
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local points = player.Data.StatPoints.Value or 0
            if points <= 0 then return end

            local level = player.Data.Level.Value or 0
            print("[STATS] Lv." .. level .. " | Stat points:", points)

            if level < _G.Config.HakiMinLevel then
                local melee, defense = 0, 0
                while points > 0 do
                    local m = math.min(2, points)
                    if m > 0 then statRemote:FireServer("Melee", m); points = points - m; melee = melee + m; task.wait(0.1) end
                    if points <= 0 then break end

                    local d = math.min(1, points)
                    if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d; task.wait(0.1) end
                end
                print("[STATS] ✅ Melee +" .. melee .. ", Defense +" .. defense .. " (Lv." .. level .. ")")
            else
                local sword, defense, power = 0, 0, 0
                while points > 0 do
                    local s = math.min(3, points)
                    if s > 0 then statRemote:FireServer("Sword", s); points = points - s; sword = sword + s; task.wait(0.1) end
                    if points <= 0 then break end

                    local d = math.min(2, points)
                    if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d; task.wait(0.1) end
                    if points <= 0 then break end

                    local p = math.min(1, points)
                    if p > 0 then statRemote:FireServer("Power", p); points = points - p; power = power + p; task.wait(0.1) end
                end
                print("[STATS] ✅ Sword +" .. sword .. ", Defense +" .. defense .. ", Power +" .. power)
            end
        end)
    end
end)
end

-- ═══════════════════════════════════════════════════════════════
-- [10] STATS & WEAPON SYSTEM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function resetStats()
    print("[STATS] Resetting all stats...")
    pcall(function()
        local r = RemoteEvents:FindFirstChild("ResetStats")
        if r then r:FireServer() end
    end)
    task.wait(2)
    print("[STATS] ✅ Stats reset!")
end

local function upgradeStats()
    print("[STATS] Upgrading stats after reset...")
    local points = 0
    pcall(function() points = player.Data.StatPoints.Value or 0 end)
    if points <= 0 then return end

    local swordPts   = math.floor(points * _G.Config.StatSword / 100)
    local defensePts = math.floor(points * _G.Config.StatDefense / 100)
    local powerPts   = math.floor(points * _G.Config.StatPower / 100)

    local stats = {
        { name = "Sword",   amount = swordPts },
        { name = "Defense", amount = defensePts },
        { name = "Power",   amount = powerPts },
    }

    pcall(function()
        local remote = RemoteEvents:FindFirstChild("UpdatePlayerStats")
            or RemoteEvents:FindFirstChild("AllocateStat")
        if not remote then return end

        for _, s in ipairs(stats) do
            for i = 1, s.amount do
                remote:FireServer(s.name, 1)
                task.wait(0.1)
            end
            task.wait(0.5)
        end
    end)

    print("[STATS] ✅ Sword +" .. swordPts .. ", Defense +" .. defensePts .. ", Power +" .. powerPts)
end

local function buyDarkBlade()
    print("[WEAPON] ========== BUYING DARK BLADE ==========")
    isBuyingDarkBlade = true

    if checkOwnerDarkBlade() then
        print("[WEAPON] ✅ Dark Blade already equipped!")
        isBuyingDarkBlade = false
        return true
    end
    if checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") then
        print("[WEAPON] ✅ Equipping from inventory...")
        equipDarkBladeFromInventory()
        isBuyingDarkBlade = false
        return true
    end

    local gem = player.Data.Gems.Value
    local money = player.Data.Money.Value
    print("[WEAPON] Gems:", gem, "Money:", money)

    if gem < _G.Config.DarkBladeGems or money < _G.Config.DarkBladeMoney then
        print("[WEAPON] ❌ Not enough resources!")
        isBuyingDarkBlade = false
        return false
    end

    local npcCF = CFrame.new(-132.516449, 13.2661686, -1091.2699, 0.972926259, 0, 0.231115878, 0, 1, 0, -0.231115878, 0, 0.972926259)
    local maxAttempts = 20

    while not (checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") or checkOwnerDarkBlade()) and maxAttempts > 0 do
        maxAttempts = maxAttempts - 1
        print("[WEAPON] 🔄 Purchase attempt", 20 - maxAttempts)

        pcall(function()
            RemoteEvents:WaitForChild("ResetStats"):FireServer()
        end)

        local npcHRP = nil
        pcall(function()
            npcHRP = workspace.ServiceNPCs.DarkBladeNPC:FindFirstChild("HumanoidRootPart")
        end)

        if not npcHRP then
            print("[WEAPON] ❌ NPC HRP not found, teleporting...")
            tweenPos(npcCF)
            task.wait(1)
        else
            local prompt = npcHRP:FindFirstChild("DarkBladeShopPrompt")
            if prompt then
                print("[WEAPON] ✅ Buying Dark Blade (fireproximityprompt)...")
                prompt.MaxActivationDistance = math.huge
                fireproximityprompt(prompt)
                pcall(function()
                    RemoteEvents:WaitForChild("ResetStats"):FireServer()
                end)
                task.wait(5)
                equipDarkBladeFromInventory()
                task.wait(1)
            else
                print("[WEAPON] ❌ Prompt not found")
                tweenPos(npcCF)
                task.wait(1)
            end
        end
    end

    local purchased = checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") or checkOwnerDarkBlade()
    if purchased then
        print("[WEAPON] 🎉 Dark Blade purchased!")
        resetStats()
        upgradeStats()
        
        print("[WEAPON] 🗡️ Equipping Dark Blade...")
        task.wait(2)
        equipDarkBladeFromInventory()
        task.wait(1)
        
        if checkOwnerDarkBlade() then
            print("[WEAPON] ✅ Dark Blade equipped!")
        else
            print("[WEAPON] ⚠️ Dark Blade not equipped yet")
        end
    else
        print("[WEAPON] ❌ Failed to purchase")
    end

    isBuyingDarkBlade = false
    print("[WEAPON] ================================")
    return purchased
end

-- ═══════════════════════════════════════════════════════════════
-- [11] FRUIT FARM SYSTEM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function checkHasFruit(fruitName)
    oldPrint("[FRUIT] 🔍 Checking for", fruitName, "...")
    
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                oldPrint("[FRUIT] ✅ Found", tool.Name, "in Character")
                return true
            end
        end
    end
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                oldPrint("[FRUIT] ✅ Found", tool.Name, "in Backpack")
                return true
            end
        end
    end
    
    oldPrint("[FRUIT] 🔍 Not in Character/Backpack, checking Inventory Remote...")
    local hasFruit = false
    local connection = nil
    
    connection = RS.Remotes.UpdateInventory.OnClientEvent:Connect(function(tab, data)
        for _, item in pairs(data) do
            if item.name and item.name:find(fruitName) then
                hasFruit = true
                oldPrint("[FRUIT] ✅ Found", item.name, "in Inventory!")
            end
        end
        if connection then
            connection:Disconnect()
        end
    end)
    
    pcall(function()
        RS.Remotes.RequestInventory:FireServer()
    end)
    
    task.wait(1)
    
    if connection then
        connection:Disconnect()
    end
    
    if hasFruit then
        oldPrint("[FRUIT] ✅ Has", fruitName)
    else
        oldPrint("[FRUIT] ❌ No", fruitName)
    end
    
    return hasFruit
end

local function equipFruit(fruitName)
    print("[FRUIT] 🍎 Equipping fruit:", fruitName)
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    print("[FRUIT] 🎯 Equipping:", tool.Name)
                    char.Humanoid:EquipTool(tool)
                    task.wait(1)
                    return true
                end
            end
        end
    end
    
    pcall(function()
        RS:WaitForChild("Remotes"):WaitForChild("EquipWeapon"):FireServer(unpack({"Equip", fruitName}))
    end)
    task.wait(0.5)
    pcall(function()
        RS:WaitForChild("Remotes"):WaitForChild("EquipWeapon"):FireServer(unpack({"Equip", fruitName .. " Fruit"}))
    end)
    task.wait(1)
    
    return checkHasFruit(fruitName)
end

local function buyRandomFruit()
    oldPrint("[FRUIT] 🎲 Buying random fruit...")
    
    local npcCF = CFrame.new(400.641937, 2.79983521, 752.175842, 0.444819272, 0, 0.895620406, 0, 1, 0, -0.895620406, 0, 0.444819272)
    
    tweenPos(npcCF)
    task.wait(3)
    
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = npcCF * CFrame.new(0, 0, -3)
    end
    task.wait(1)
    
    local prompt = nil
    pcall(function()
        local npc = workspace.ServiceNPCs.GemFruitDealer
        for _, desc in pairs(npc:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                prompt = desc
                break
            end
        end
    end)
    
    if not prompt then
        oldPrint("[FRUIT] ❌ Prompt not found!")
        return false
    end
    
    oldPrint("[FRUIT] 💰 Firing prompt...")
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(3)
    
    return true
end

local function getAnyFruitFromBackpack()
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                oldPrint("[FRUIT] 📦 Found fruit in Backpack:", tool.Name)
                return tool
            end
        end
    end
    
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                oldPrint("[FRUIT] 📦 Found fruit in Character:", tool.Name)
                return tool
            end
        end
    end
    
    return nil
end

local function eatFruit(fruitTool)
    if not fruitTool then return end
    
    local fruitName = fruitTool.Name
    oldPrint("[FRUIT] 🍽️ Eating fruit:", fruitName)
    
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    
    if humanoid and fruitTool.Parent == backpack then
        oldPrint("[FRUIT] 📦 Equipping fruit...")
        humanoid:EquipTool(fruitTool)
        task.wait(0.5)
    end
    
    oldPrint("[FRUIT] 🔨 Activating fruit to open ConfirmUI...")
    pcall(function()
        fruitTool:Activate()
    end)
    task.wait(1)
    
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        oldPrint("[FRUIT] ✅ ConfirmUI found, clicking Yes...")
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then
            yesButton = yesButton:FindFirstChild("ButtonsHolder")
        end
        if yesButton then
            yesButton = yesButton:FindFirstChild("Yes")
        end
        
        if yesButton then
            pcall(function()
                for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end)
            oldPrint("[FRUIT] 🖱️ Clicked Yes button")
        end
    else
        oldPrint("[FRUIT] ⚠️ No ConfirmUI, firing FruitAction remote directly...")
        pcall(function()
            RemoteEvents:WaitForChild("FruitAction"):FireServer("eat", fruitName)
        end)
    end
    
    task.wait(3)
    
    local fruitTool = nil
    if backpack then
        fruitTool = backpack:FindFirstChild(fruitName)
    end
    if not fruitTool and char then
        fruitTool = char:FindFirstChild(fruitName)
    end
    
    if fruitTool and fruitTool:FindFirstChild("FruitData") then
        oldPrint("[FRUIT] ⚠️ Fruit still has FruitData - trying to destroy...")
        pcall(function()
            fruitTool:Destroy()
        end)
    else
        oldPrint("[FRUIT] ✅ Ate fruit successfully:", fruitName)
    end
end

local function allocateStatsPowerFirst()
    print("[FRUIT] 📊 Allocating stats: Power first (11500), then Sword")
    
    local points = 0
    pcall(function()
        points = player.Data.StatPoints.Value or 0
    end)
    
    if points <= 0 then
        print("[FRUIT] ✅ No stat points to allocate")
        return
    end
    
    local powerStat = 0
    pcall(function()
        powerStat = player.Data.Power.Value or 0
    end)
    
    if powerStat < 11500 then
        local needed = 11500 - powerStat
        local toAllocate = math.min(needed, points)
        
        print("[FRUIT] 🔥 Allocating", toAllocate, "points to Power (batch)")
        local remaining = toAllocate
        while remaining > 0 do
            local batch = math.min(100, remaining)
            pcall(function()
                statRemote:FireServer("Power", batch)
            end)
            remaining = remaining - batch
            task.wait(0.1)
        end
        
        points = points - toAllocate
    end
    
    if points > 0 then
        print("[FRUIT] ⚔️ Allocating", points, "points to Sword (batch)")
        local remaining = points
        while remaining > 0 do
            local batch = math.min(100, remaining)
            pcall(function()
                statRemote:FireServer("Sword", batch)
            end)
            remaining = remaining - batch
            task.wait(0.1)
        end
    end
    
    print("[FRUIT] ✅ Stats allocated!")
end

local function fruitFarmLoop()
    print("[FRUIT FARM] 🍎 Starting AFK Fruit Farm Loop...")
    
    local keyCodes = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
    
    while _G.Config.FruitFarm and isFruitFarming do
        task.wait(0.5)
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        if char.Humanoid.Health <= 0 then continue end
        
        local hrp = char.HumanoidRootPart
        local lockPos = _G.Config.FruitFarmPos
        
        if (hrp.Position - lockPos.Position).Magnitude > 5 then
            hrp.CFrame = lockPos
        end
        
        local targetFruit = _G.Config.TargetFruit
        equipFruit(targetFruit)
        
        pcall(function() RemoteEvents:WaitForChild("HakiRemote"):FireServer("Toggle") end)
        pcall(function() RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle") end)
        
        for i, keyCode in ipairs(keyCodes) do
            pcall(function()
                local args = {
                    "UseAbility",
                    {
                        TargetPosition = hrp.Position,
                        FruitPower = targetFruit,
                        KeyCode = keyCode
                    }
                }
                RemoteEvents:WaitForChild("FruitPowerRemote"):FireServer(unpack(args))
            end)
            task.wait(0.3)
        end
        
        task.wait(1.5)
    end
    
    print("[FRUIT FARM] ❌ Fruit Farm Loop ended")
end

local function startFruitFarm()
    oldPrint("[FRUIT] ========== FRUIT FARM START ==========")
    isFruitFarming = true
    
    local targetFruit = _G.Config.TargetFruit
    
    oldPrint("[FRUIT] STEP 1: checkHasFruit...")
    local hasFruitAlready = checkHasFruit(targetFruit)
    oldPrint("[FRUIT] STEP 1 result:", tostring(hasFruitAlready))
    
    if hasFruitAlready then
        oldPrint("[FRUIT] ✅ Already have", targetFruit)
        
        local fruitTool = getAnyFruitFromBackpack()
        if fruitTool then
            oldPrint("[FRUIT] 🍽️ Eating target fruit before farming:", fruitTool.Name)
            eatFruit(fruitTool)
            task.wait(2)
        else
            oldPrint("[FRUIT] ⚠️ No fruit tool found in Backpack/Character!")
        end
        
        equipFruit(targetFruit)
        
        oldPrint("[FRUIT] STEP 6: Teleporting to farm position...")
        local island = _G.Config.FruitFarmIsland
        local pos = _G.Config.FruitFarmPos
        
        pcall(function()
            tpRemote:FireServer(island)
        end)
        task.wait(3)
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for i = 1, 10 do
                char.HumanoidRootPart.CFrame = pos
                task.wait(0.1)
            end
        end
        
        oldPrint("[FRUIT] ✅ Fruit farm setup complete!")
        task.spawn(fruitFarmLoop)
        return true
    end
    
    local currentPower = 0
    pcall(function()
        currentPower = player.Data.Power.Value or 0
    end)
    
    if currentPower < 11500 then
        oldPrint("[FRUIT] STEP 2: Reset Stats (Power < 11500)...")
        pcall(function()
            RemoteEvents:WaitForChild("ResetStats"):FireServer()
        end)
        task.wait(3)
        oldPrint("[FRUIT] STEP 2: Reset Stats done")
        
        oldPrint("[FRUIT] STEP 3: Allocate Stats...")
        local ok3, err3 = pcall(allocateStatsPowerFirst)
        if not ok3 then
            oldPrint("[FRUIT] STEP 3 ERROR:", tostring(err3))
        else
            oldPrint("[FRUIT] STEP 3: Stats allocated OK")
        end
        task.wait(2)
    else
        oldPrint("[FRUIT] ⏭️ STEP 2-3: Power already >= 11500, skipping reset...")
    end
    
    oldPrint("[FRUIT] STEP 4: Starting buy loop...")
    local maxAttempts = 100
    local attemptNum = 0
    local gotTarget = false
    
    while maxAttempts > 0 and not gotTarget do
        maxAttempts = maxAttempts - 1
        attemptNum = attemptNum + 1
        oldPrint("[FRUIT] ══════════════════════════════════")
        oldPrint("[FRUIT] 🎲 Attempt " .. attemptNum .. " / 100")
        
        local ok4, err4 = pcall(buyRandomFruit)
        if not ok4 then
            oldPrint("[FRUIT] ❌ buyRandomFruit ERROR:", tostring(err4))
            task.wait(2)
        else
            oldPrint("[FRUIT] ⏳ Waiting for fruit to load into Backpack...")
            task.wait(3)
            local fruitTool = getAnyFruitFromBackpack()
            
            if fruitTool then
                oldPrint("[FRUIT] 🍎 Got: " .. fruitTool.Name)
                
                local isTargetFruit = fruitTool.Name:find(targetFruit) ~= nil
                
                if isTargetFruit then
                    oldPrint("[FRUIT] 🎉🎉🎉 GOT TARGET FRUIT: " .. fruitTool.Name .. " !!! 🎉🎉🎉")
                    oldPrint("[FRUIT] 🍽️ Eating target fruit...")
                    eatFruit(fruitTool)
                    task.wait(2)
                    gotTarget = true
                else
                    oldPrint("[FRUIT] ❌ Not " .. targetFruit .. " → Eating " .. fruitTool.Name .. "...")
                    eatFruit(fruitTool)
                    task.wait(2)
                end
            else
                oldPrint("[FRUIT] ⚠️ No fruit found in Backpack after buying!")
                task.wait(2)
            end
        end
    end
    
    oldPrint("[FRUIT] STEP 5: Check final result...")
    if checkHasFruit(targetFruit) then
        oldPrint("[FRUIT] ✅ Got " .. targetFruit .. "! Equipping...")
        equipFruit(targetFruit)
        
        oldPrint("[FRUIT] STEP 6: Teleporting to farm position...")
        local island = _G.Config.FruitFarmIsland
        local pos = _G.Config.FruitFarmPos
        
        pcall(function()
            tpRemote:FireServer(island)
        end)
        task.wait(3)
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for i = 1, 10 do
                char.HumanoidRootPart.CFrame = pos
                task.wait(0.1)
            end
        end
        
        oldPrint("[FRUIT] ✅ Fruit farm setup complete!")
        task.spawn(fruitFarmLoop)
        return true
    else
        oldPrint("[FRUIT] ❌ Failed to get " .. targetFruit)
        isFruitFarming = false
        return false
    end
end

-- ═══════════════════════════════════════════════════════════════
-- [12] ARTIFACTS UNLOCK SYSTEM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function checkArtifactsUnlocked()
    local unlocked = false
    pcall(function()
        local data = RS:WaitForChild("RemoteFunctions"):WaitForChild("GetArtifactData"):InvokeServer()
        if data and type(data) == "table" and data.Unlocked == true then
            unlocked = true
            print("[ARTIFACTS] ✅ Already unlocked")
        else
            print("[ARTIFACTS] ❌ Not unlocked yet")
        end
    end)
    return unlocked
end

local function unlockArtifacts()
    print("[ARTIFACTS] ========== UNLOCK ARTIFACTS START ==========")
    
    if checkArtifactsUnlocked() then
        print("[ARTIFACTS] ⏭️ Already unlocked, skipping...")
        return true
    end
    
    print("[ARTIFACTS] 📍 Teleporting to ArtifactsUnlocker NPC...")
    local npcCFrame = CFrame.new(-440.516388, 1.77979147, -1095.86072, -0.289305925, -0, -0.957236767, 0, 1, -0, 0.957236767, 0, -0.289305925)
    
    tweenPos(npcCFrame)
    task.wait(3)
    
    print("[ARTIFACTS] 🔍 Finding ArtifactPrompt...")
    local npc = workspace:FindFirstChild("ServiceNPCs")
    if npc then
        npc = npc:FindFirstChild("ArtifactsUnlocker")
    end
    if npc then
        npc = npc:FindFirstChild("HumanoidRootPart")
    end
    
    local prompt = nil
    if npc then
        prompt = npc:FindFirstChild("ArtifactPrompt")
    end
    
    if not prompt then
        print("[ARTIFACTS] ❌ ArtifactPrompt not found!")
        return false
    end
    
    print("[ARTIFACTS] 💰 Firing ArtifactPrompt...")
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(2)
    
    print("[ARTIFACTS] ⏳ Waiting for ConfirmUI...")
    task.wait(1)
    
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        print("[ARTIFACTS] ✅ ConfirmUI found, clicking Yes...")
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then
            yesButton = yesButton:FindFirstChild("ButtonsHolder")
        end
        if yesButton then
            yesButton = yesButton:FindFirstChild("Yes")
        end
        
        if yesButton then
            pcall(function()
                for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end)
            print("[ARTIFACTS] 🖱️ Clicked Yes button")
        end
    else
        print("[ARTIFACTS] ⚠️ No ConfirmUI, firing ArtifactUnlockSystem remote...")
        pcall(function()
            RemoteEvents:WaitForChild("ArtifactUnlockSystem"):FireServer()
        end)
    end
    
    task.wait(3)
    
    if checkArtifactsUnlocked() then
        print("[ARTIFACTS] ✅ Artifacts unlocked successfully!")
        return true
    else
        print("[ARTIFACTS] ❌ Failed to unlock Artifacts")
        return false
    end
end

local function equipArtifacts()
    oldPrint("[ARTIFACTS] 🎯 Equipping Artifacts...")
    
    pcall(function()
        RemoteEvents:WaitForChild("ArtifactUIOpened"):FireServer()
    end)
    oldPrint("[ARTIFACTS] 📂 Opened Artifact UI")
    task.wait(2)
    
    local data = nil
    local ok, err = pcall(function()
        data = RS:WaitForChild("RemoteFunctions"):WaitForChild("GetArtifactData"):InvokeServer()
    end)
    oldPrint("[ARTIFACTS] 📡 GetArtifactData ok:", tostring(ok), "err:", tostring(err))
    
    if data and type(data) == "table" then
        local allIds = {}
        local function deepScan(tbl, prefix)
            for k, v in pairs(tbl) do
                local key = prefix .. tostring(k)
                if type(v) == "table" then
                    oldPrint("[ARTIFACTS] 📊 " .. key .. " = {table}")
                    deepScan(v, key .. ".")
                else
                    oldPrint("[ARTIFACTS] 📊 " .. key .. " = " .. tostring(v))
                    if type(v) == "string" and v:match("%x%x%x%x%x%x%x%x%-%x%x%x%x") then
                        table.insert(allIds, v)
                        oldPrint("[ARTIFACTS] 🔑 Found UUID: " .. v)
                    end
                end
            end
        end
        deepScan(data, "")
        
        oldPrint("[ARTIFACTS] 🔑 Total UUIDs found: " .. #allIds)
        for i, uuid in ipairs(allIds) do
            pcall(function()
                RemoteEvents:WaitForChild("ArtifactEquip"):FireServer(uuid)
            end)
            oldPrint("[ARTIFACTS] ✅ Equipped #" .. i .. ": " .. uuid)
            task.wait(0.5)
        end
    else
        oldPrint("[ARTIFACTS] ⚠️ No artifact data, type:", type(data))
    end
    
    task.wait(1)
    
    pcall(function()
        local artifactsUI = player.PlayerGui:FindFirstChild("ArtifactsUI")
        if artifactsUI then
            local mainFrame = artifactsUI:FindFirstChild("ArtifactsMainFrame")
            if mainFrame then
                local closeHolder = mainFrame:FindFirstChild("CloseButtonFrameHolder")
                if closeHolder then
                    for _, btn in pairs(closeHolder:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            oldPrint("[ARTIFACTS] 🔒 Clicking close button:", btn.Name)
                            pcall(function()
                                for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                    conn:Fire()
                                end
                            end)
                            break
                        end
                    end
                end
            end
        end
    end)
    task.wait(0.5)
    
    pcall(function()
        RemoteEvents:WaitForChild("ArtifactCloseUI"):FireServer()
    end)
    pcall(function()
        local artifactsUI = player.PlayerGui:FindFirstChild("ArtifactsUI")
        if artifactsUI then
            artifactsUI.Enabled = false
            oldPrint("[ARTIFACTS] 🔒 Force disabled ArtifactsUI")
        end
    end)
    
    oldPrint("[ARTIFACTS] ✅ Closed Artifact UI")
end

-- ═══════════════════════════════════════════════════════════════
-- [13] OBSERVATION HAKI BUY SYSTEM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function checkHasObservationHaki()
    local hasObs = false
    pcall(function()
        local statsUI = player.PlayerGui:FindFirstChild("StatsPanelUI")
        if statsUI then
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name:find("Observation") and desc:IsA("Frame") and desc.Visible == true then
                    hasObs = true
                    break
                end
            end
        end
    end)
    
    if not hasObs then
        pcall(function()
            RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle")
            task.wait(0.3)
            RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle")
            local char = player.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v.Name:find("Observation") or v.Name:find("observation") then
                        hasObs = true
                        break
                    end
                end
            end
        end)
    end
    
    oldPrint("[OBS HAKI] Check hasObservationHaki:", tostring(hasObs))
    return hasObs
end

local function buyObservationHaki()
    oldPrint("[OBS HAKI] ========== BUY OBSERVATION HAKI START ==========")
    
    if checkHasObservationHaki() then
        oldPrint("[OBS HAKI] ⏭️ Already have Observation Haki, skipping...")
        return true
    end
    
    oldPrint("[OBS HAKI] 📍 Teleporting to ObservationBuyer NPC...")
    local npcCFrame = CFrame.new(-713.182922, 12.1339779, -527.289795, -0.763382077, 0, 0.645947695, 0, 1, 0, -0.645947695, 0, -0.763382077)
    
    tweenPos(npcCFrame)
    task.wait(3)
    
    oldPrint("[OBS HAKI] 🔍 Finding ObservationHakiPrompt...")
    local npc = workspace:FindFirstChild("ServiceNPCs")
    if npc then npc = npc:FindFirstChild("ObservationBuyer") end
    if npc then npc = npc:FindFirstChild("HumanoidRootPart") end
    
    local prompt = nil
    if npc then
        prompt = npc:FindFirstChild("ObservationHakiPrompt")
    end
    
    if not prompt then
        oldPrint("[OBS HAKI] ❌ ObservationHakiPrompt not found!")
        return false
    end
    
    oldPrint("[OBS HAKI] 💰 Firing ObservationHakiPrompt...")
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(2)
    
    oldPrint("[OBS HAKI] ⏳ Waiting for ConfirmUI...")
    task.wait(1)
    
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        oldPrint("[OBS HAKI] ✅ ConfirmUI found, clicking Yes...")
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then yesButton = yesButton:FindFirstChild("ButtonsHolder") end
        if yesButton then yesButton = yesButton:FindFirstChild("Yes") end
        
        if yesButton then
            pcall(function()
                for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end)
            oldPrint("[OBS HAKI] 🖱️ Clicked Yes button")
        end
    else
        oldPrint("[OBS HAKI] ⚠️ No ConfirmUI found")
    end
    
    task.wait(3)
    
    oldPrint("[OBS HAKI] ✅ Observation Haki purchase attempted!")
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- [14] BOSS KEY AUTO BUY SYSTEM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local lastBossKeyBuyTime = 0
local isBuyingBossKey = false

local function buyBossKeysFromStock(bossKeyStock)
    if isBuyingBossKey then
        oldPrint("[BOSS KEY] ⏰ Already buying, skipping...")
        return false
    end
    
    local currentTime = tick()
    
    if currentTime - lastBossKeyBuyTime < 5 then
        return false
    end
    
    isBuyingBossKey = true
    oldPrint("[BOSS KEY] ========== AUTO BUY BOSS KEY START ==========")
    oldPrint(string.format("[BOSS KEY] 🔑 Boss Key in stock: %d", bossKeyStock))
    
    local merchantCF = CFrame.new(368.817719, 2.79983521, 783.589844, -0.0566431284, 0, 0.998394549, 0, 1, 0, -0.998394549, 0, -0.0566431284)
    oldPrint("[BOSS KEY] 📍 Teleporting to MerchantNPC...")
    tweenPos(merchantCF)
    task.wait(3)
    
    oldPrint(string.format("[BOSS KEY] 💰 Buying %d Boss Keys...", bossKeyStock))
    for i = 1, bossKeyStock do
        pcall(function()
            RS.Remotes.MerchantRemotes.PurchaseMerchantItem:InvokeServer("Boss Key", 1)
        end)
        task.wait(0.5)
    end
    
    lastBossKeyBuyTime = currentTime
    isBuyingBossKey = false
    oldPrint("[BOSS KEY] ✅ Boss Key purchase complete!")
    oldPrint("[BOSS KEY] ========== AUTO BUY BOSS KEY END ==========")
    return true
end

local function setupBossKeyAutoListener()
    oldPrint("[BOSS KEY] 🎧 Setting up real-time stock listener...")
    
    task.spawn(function()
        task.wait(2)
        oldPrint("[BOSS KEY] 📦 Checking initial stock...")
        local success, stock = pcall(function()
            return RS.Remotes.MerchantRemotes.GetMerchantStock:InvokeServer()
        end)
        
        if success then
            oldPrint(string.format("[BOSS KEY] 📋 Stock type: %s", type(stock)))
            
            if type(stock) == "table" then
                local items = stock.stock or stock
                oldPrint(string.format("[BOSS KEY] 📦 Items type: %s", type(items)))
                
                if type(items) == "table" then
                    local itemCount = 0
                    for _ in pairs(items) do itemCount = itemCount + 1 end
                    oldPrint(string.format("[BOSS KEY] 📊 Total items: %d", itemCount))
                    
                    local foundBossKey = false
                    for key, item in pairs(items) do
                        if type(item) == "table" then
                            for k, v in pairs(item) do
                                oldPrint(string.format("[BOSS KEY]   - %s = %s (%s)", tostring(k), tostring(v), type(v)))
                            end
                            
                            local itemName = item.name or item.itemId or item.Name or item.ItemId or item.itemName or tostring(key)
                            local itemStock = item.stock or item.quantity or item.Stock or item.Quantity or 0
                            
                            if itemName == "Boss Key" or (type(itemName) == "string" and string.find(itemName, "Boss Key")) then
                                foundBossKey = true
                                oldPrint(string.format("[BOSS KEY] 🔑 Boss Key found! Stock: %d", itemStock))
                                if itemStock > 0 then
                                    buyBossKeysFromStock(itemStock)
                                end
                                break
                            end
                        end
                    end
                    
                    if not foundBossKey then
                        oldPrint("[BOSS KEY] ❌ Boss Key not found in stock")
                    end
                else
                    oldPrint("[BOSS KEY] ⚠️ Items is not a table")
                end
            else
                oldPrint("[BOSS KEY] ⚠️ Stock is not a table")
            end
        else
            oldPrint("[BOSS KEY] ❌ Failed to get initial stock")
        end
    end)
    
    pcall(function()
        RS.Remotes.MerchantRemotes.MerchantStockUpdate.OnClientEvent:Connect(function(...)
            if not _G.Config.AutoBuyBossKey then return end
            
            local args = {...}
            oldPrint("[BOSS KEY] 🔔 Stock update event received!")
            oldPrint(string.format("[BOSS KEY] 📊 Event args count: %d", #args))
            
            for i, arg in ipairs(args) do
                if type(arg) == "table" then
                    oldPrint(string.format("[BOSS KEY] 📦 Arg[%d] is table", i))
                    for _, item in pairs(arg) do
                        if type(item) == "table" and (item.name == "Boss Key" or item.itemId == "Boss Key") then
                            local stock = item.stock or item.quantity or 0
                            oldPrint(string.format("[BOSS KEY] 🔑 Boss Key found! Stock: %d", stock))
                            if stock > 0 then
                                task.spawn(function()
                                    buyBossKeysFromStock(stock)
                                end)
                            end
                            return
                        end
                    end
                end
            end
        end)
    end)
    
    oldPrint("[BOSS KEY] ✅ Real-time stock listener ready!")
end

-- ═══════════════════════════════════════════════════════════════
-- [15] ICHIGO EXCHANGE SYSTEM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function checkIchigoRequirements()
    local bossTicketCount = inventoryByRarity["Epic"]["Boss Ticket"] or 0
    
    if bossTicketCount == 0 then
        pcall(function() RS.Remotes.RequestInventory:FireServer() end)
        task.wait(1)
        bossTicketCount = inventoryByRarity["Epic"]["Boss Ticket"] or 0
    end
    
    local hasAllItems = bossTicketCount >= 500
    local missingItems = {}
    
    if not hasAllItems then
        table.insert(missingItems, string.format("Boss Ticket: %d / 500", bossTicketCount))
    end
    
    return hasAllItems, missingItems
end

local function exchangeIchigo()
    oldPrint("[ICHIGO] ========== EXCHANGE ICHIGO START ==========")
    
    if checkDarkBlade("Ichigo") then
        oldPrint("[ICHIGO] ⏭️ Already have Ichigo, skipping...")
        return true
    end
    
    local hasAll, missing = checkIchigoRequirements()
    
    if not hasAll then
        oldPrint("[ICHIGO] ❌ Missing requirements:")
        for _, item in pairs(missing) do
            oldPrint("[ICHIGO]   - " .. item)
        end
        oldPrint("[ICHIGO] 🎯 Farm Saber Boss to get Boss Tickets!")
        return false
    end
    
    oldPrint("[ICHIGO] ✅ All requirements met (Boss Ticket: 500)! Exchanging...")
    
    oldPrint("[ICHIGO] 💰 Calling ExchangeItem remote...")
    local success = pcall(function()
        RS.Remotes.ExchangeItem:InvokeServer("Ichigo")
    end)
    
    if not success then
        oldPrint("[ICHIGO] ❌ Failed to call ExchangeItem remote")
        return false
    end
    
    task.wait(3)
    
    if checkDarkBlade("Ichigo") then
        oldPrint("[ICHIGO] ✅ Ichigo exchange successful!")
        return true
    else
        oldPrint("[ICHIGO] ⚠️ Ichigo not found in inventory after exchange")
        return false
    end
end

-- ═══════════════════════════════════════════════════════════════
-- [16] SABER BOSS FARM SYSTEM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function checkBossKeyCount()
    pcall(function() RS.Remotes.RequestInventory:FireServer() end)
    task.wait(1)
    
    local count = inventoryByRarity["Epic"]["Boss Key"] or 0
    
    oldPrint(string.format("[SABER BOSS] 🔑 Boss Key: %d", count))
    return count
end

local function farmSaberBoss()
    oldPrint("[SABER BOSS] ========== FARM SABER BOSS START ==========")
    isFarmingIchigoBoss = true
    
    while isFarmingIchigoBoss do
        local bossKeyCount = checkBossKeyCount()
        oldPrint(string.format("[SABER BOSS] 🎫 Boss Key: %d", bossKeyCount))
        
        if bossKeyCount < 1 then
            oldPrint("[SABER BOSS] ❌ Not enough Boss Keys! Need 1 to summon.")
            break
        end
        
        local summonNPCCFrame = CFrame.new(651.810181, -3.67419362, -1021.13123, 0.999550879, 0, 0.0299676117, 0, 1, 0, -0.0299676117, 0, 0.999550879)
        oldPrint("[SABER BOSS] 📍 Teleporting to SummonBossNPC...")
        tweenPos(summonNPCCFrame)
        task.wait(3)
    
    oldPrint("[SABER BOSS] 🔔 Summoning SaberBoss...")
    local success = pcall(function()
        RS.Remotes.RequestSummonBoss:FireServer("SaberBoss")
    end)
    
    if not success then
        pcall(function()
            RS.Remotes.RequestAutoSpawn:FireServer("SaberBoss")
        end)
    end
    
    task.wait(5)
    
    oldPrint("[SABER BOSS] 🔍 Finding SaberBoss...")
    local boss = workspace:FindFirstChild("NPCs")
    if boss then boss = boss:FindFirstChild("SaberBoss") end
    
    if not boss then
        oldPrint("[SABER BOSS] ❌ SaberBoss not found! Waiting...")
        task.wait(10)
        boss = workspace:FindFirstChild("NPCs")
        if boss then boss = boss:FindFirstChild("SaberBoss") end
    end
    
    if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") then
        oldPrint("[SABER BOSS] ✅ SaberBoss found! Starting combat...")
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            oldPrint("[SABER BOSS] ❌ Character not found!")
            return
        end
        
        local tool = findDarkBladeInHand()
        if not tool then
            equipDarkBladeFromInventory()
            tool = findDarkBladeInHand()
        end
        if tool and tool.Parent == player.Backpack then
            char.Humanoid:EquipTool(tool)
        end
        
        local bossRoot = boss.HumanoidRootPart
        local bossHumanoid = boss.Humanoid
        local YPOS = 15
        local skillIndex = 1
        
        local box = Instance.new("SelectionBox")
        box.Adornee = boss
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.LineThickness = 0.1
        box.SurfaceTransparency = 0.6
        box.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
        box.Parent = workspace
        
        repeat task.wait()
            if not boss or not boss.Parent or not boss:FindFirstChild("HumanoidRootPart") or bossHumanoid.Health <= 0 then
                break
            end
            if not char or not char:FindFirstChild("HumanoidRootPart") then break end
            if char.Humanoid.Health <= 0 then break end
            
            local tool = findDarkBladeInHand()
            if not tool then
                equipDarkBladeFromInventory()
                tool = findDarkBladeInHand()
            end
            if tool and tool.Parent == player.Backpack then
                char.Humanoid:EquipTool(tool)
            end
            
            BodyVelocity.Velocity = Vector3.zero
            BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            BodyVelocity.Parent = char.HumanoidRootPart
            
            local success, owner = pcall(function()
                return bossRoot:GetNetworkOwner()
            end)
            if success and owner == player then
                bossRoot.CFrame = CFrame.new(bossRoot.Position)
                bossRoot.AssemblyLinearVelocity = Vector3.zero
                bossRoot.AssemblyAngularVelocity = Vector3.zero
            end
            
            tweenPos(
                CFrame.new(bossRoot.Position + Vector3.new(0, YPOS, 0)) * CFrame.Angles(math.rad(-90), 0, 0),
                function()
                    pcall(function()
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        if tool then tool:Activate() end
                    end)
                    hitRemote:FireServer()
                end
            )
            
            pcall(function() RemoteEvents:WaitForChild("HakiRemote"):FireServer("Toggle") end)
            pcall(function() RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle") end)
            
            pcall(function()
                RS:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility"):FireServer(skillIndex)
            end)
            pcall(function()
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool then tool:Activate() end
            end)
            hitRemote:FireServer()
            
            skillIndex = skillIndex + 1
            if skillIndex > 4 then skillIndex = 1 end
            
        until not boss.Parent or bossHumanoid.Health <= 0 or char.Humanoid.Health <= 0
        
        box:Destroy()
        
        local bossStillAlive = boss and boss.Parent and boss:FindFirstChild("HumanoidRootPart") and bossHumanoid.Health > 0
        
        if bossStillAlive then
            oldPrint("[SABER BOSS] ⚠️ Player died! Waiting for respawn...")
            task.wait(5)
            
            if boss and boss.Parent and boss:FindFirstChild("HumanoidRootPart") and bossHumanoid.Health > 0 then
                local newChar = player.Character or player.CharacterAdded:Wait()
                if newChar and newChar:FindFirstChild("HumanoidRootPart") then
                    oldPrint("[SABER BOSS] 🔄 Respawned! Returning to boss...")
                    
                    local bossPos = boss.HumanoidRootPart.Position
                    tweenPos(CFrame.new(bossPos + Vector3.new(0, 15, 0)))
                    task.wait(3)
                end
            else
                oldPrint("[SABER BOSS] ⚠️ Boss died while waiting for respawn!")
            end
        else
            oldPrint("[SABER BOSS] ✅ SaberBoss defeated!")
            
            oldPrint("[SABER BOSS] 📦 Checking drops...")
            task.wait(2)
            
            oldPrint("[SABER BOSS] 🔄 Checking Boss Keys for next round...")
        end
    else
        oldPrint("[SABER BOSS] ❌ SaberBoss not spawned or already dead!")
        task.wait(5)
    end
    
    end
    
    isFarmingIchigoBoss = false
    oldPrint("[SABER BOSS] ========== FARM SABER BOSS END ==========")
end

-- ═══════════════════════════════════════════════════════════════
-- [17] HAKI QUEST SYSTEM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function acceptHakiQuest()
    print("[HAKI QUEST] Accepting quest...")
    local hakiPos = Vector3.new(-497.94, 23.66, -1252.64)

    pcall(function()
        local questUI = player.PlayerGui:FindFirstChild("QuestUI")
        if questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible then
            local title = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
            if not title:find("Path to Haki") then
                abandonRemote:FireServer("repeatable")
                task.wait(2)
            else
                return
            end
        end
    end)

    tweenPos(CFrame.new(hakiPos))
    task.wait(2)
    pcall(function() questRemote:FireServer("HakiQuestNPC") end)
    task.wait(2)
end

local function goToHakiNPC()
    local hakiPos = Vector3.new(-497.94, 23.66, -1252.64)
    tweenPos(CFrame.new(hakiPos))
    task.wait(4)

    local char = player.Character

    for i = 1, 5 do
        print("[HAKI QUEST] Press E attempt", i)
        pcall(function()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(hakiPos) * CFrame.new(0, 0, 3)
            end
        end)
        task.wait(0.5)
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(2)

        if checkHakiStatus() then
            print("[HAKI QUEST] 🎉 Haki obtained via E key!")
            return true
        end
    end

    print("[HAKI QUEST] ❌ Failed to get Haki after E key attempts")

    return false
end

local function farmThiefForHaki()
    print("[HAKI QUEST] Starting Haki farm...")
    local targetNPC = "Thief"
    local killCount = 0
    local lastCheckKills = 0

    pcall(function()
        local questUI = player.PlayerGui:FindFirstChild("QuestUI")
        if questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible then
            local title = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
            if not title:find("Path to Haki") then
                abandonRemote:FireServer("repeatable")
                task.wait(2)
            end
            local desc = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestDescription.Text
            local name = desc:match("Defeat the (%w+)") or desc:match("defeat (%w+)")
            if name then targetNPC = name end
        end
    end)

    pcall(function() tpRemote:FireServer("Starter") end)
    task.wait(3)

    local farmStart = tick()

    while task.wait(0.5) do
        if not isHakiQuestActive then break end
        if tick() - farmStart > _G.Config.HakiTimeout then
            print("[HAKI QUEST] ⚠️ Timeout!")
            isHakiQuestActive = false
            break
        end

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        if char.Humanoid.Health <= 0 then continue end

        local shouldGoToNPC = false
        local questUI = player.PlayerGui:FindFirstChild("QuestUI")
        local questVisible = questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible

        if questVisible then
            pcall(function()
                for _, child in pairs(questUI.Quest.Quest.Holder.Content.QuestInfo:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        if child.Text:find("Completed!") then
                            shouldGoToNPC = true
                            break
                        end
                        local cur, tot = child.Text:match("(%d+)/(%d+)")
                        if cur and tot and tonumber(cur) >= tonumber(tot) then
                            shouldGoToNPC = true
                        end
                    end
                end
            end)
        else
            if killCount > 5 and (killCount - lastCheckKills) >= 5 then
                shouldGoToNPC = true
            end
        end

        if shouldGoToNPC then
            print("[HAKI QUEST] 🔄 Going to NPC...")
            lastCheckKills = killCount

            if goToHakiNPC() then
                print("[HAKI QUEST] 🎉🎉 HAKI OBTAINED!")

                if _G.Config.BuyDarkBlade then
                    print("[HAKI QUEST] 🛒 Buying Dark Blade...")
                    isHakiQuestActive = false
                    pcall(buyDarkBlade)
                end

                print("[HAKI QUEST] ✅ Complete!")
                return
            end

            pcall(function()
                local q = player.PlayerGui:FindFirstChild("QuestUI")
                if q and q:FindFirstChild("Quest") and q.Quest.Visible then
                    local desc = q.Quest.Quest.Holder.Content.QuestInfo.QuestDescription.Text
                    local name = desc:match("Defeat the (%w+)") or desc:match("defeat (%w+)")
                    if name then targetNPC = name; print("[HAKI QUEST] New target:", targetNPC) end
                end
            end)

            pcall(function() tpRemote:FireServer("Starter") end)
            task.wait(3)
            continue
        end

        local npcFound = false
        for i = 1, 5 do
            local npc = workspace.NPCs:FindFirstChild(targetNPC .. i)
            if npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                npcFound = true
                local target = npc:FindFirstChild("HumanoidRootPart")
                if target then
                    while npc.Parent and npc.Humanoid.Health > 0 do
                        if not char or not char:FindFirstChild("HumanoidRootPart") then break end
                        if char.Humanoid.Health <= 0 then break end
                        pcall(function() char.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 0, 5) end)
                        pcall(function() hitRemote:FireServer() end)
                        task.wait(0.3)
                    end
                    killCount = killCount + 1
                    break
                end
            end
        end

        if not npcFound then task.wait(3) end
    end
end

local function startHakiQuest()
    if not _G.Config.HakiQuest then return end
    print("[HAKI QUEST] Starting...")
    pcall(acceptHakiQuest)
    pcall(farmThiefForHaki)
end

-- ═══════════════════════════════════════════════════════════════
-- [18] NORMAL QUEST FARM (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
local function selectWeapon()
    local blade = findDarkBladeInHand()
    if blade then return "Dark Blade" end

    if equipDarkBladeFromInventory() then return "Dark Blade" end

    return getBestWeapon()
end

local function equipToolByName(toolName, char)
    local tool = nil
    if toolName == "Dark Blade" then
        tool = findDarkBladeInHand()
    else
        tool = player.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
    end

    if tool and tool.Parent == player.Backpack then
        print("[FARM] Equipping:", tool.Name)
        char.Humanoid:EquipTool(tool)
    end
    return tool
end

local function farmLoop()
    while _G.Config.AutoFarm do
        task.wait()

        if isHakiQuestActive or isBuyingDarkBlade or isFruitFarming or isFarmingIchigoBoss then
            task.wait(10)
            continue
        end

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        if char.Humanoid.Health <= 0 then continue end

        local questInfo = getQuestInfo()
        if not questInfo then continue end

        local questUI = player.PlayerGui:FindFirstChild("QuestUI")
        if not questUI then continue end

        if not questUI.Quest.Visible then
            _G.SmartTP(questInfo.position)
            questRemote:FireServer(questInfo.npcName)

        elseif questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text ~= questInfo.questTitle then
            abandonRemote:FireServer("repeatable")

        else
            local toolName = selectWeapon()
            local npcType = getNpcType(questInfo.npcName)
            if not npcType then continue end

            equipToolByName(toolName, char)

            local YPOS = 9
            local firstMob = true

            while _G.Config.AutoFarm do
                if char.Humanoid.Health <= 0 then break end
                if not questUI.Quest.Visible then break end
                if questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text ~= questInfo.questTitle then break end

                local closest = findNPC(npcType)

                if not closest then
                    if firstMob then
                        print("[FARM] NPC:", npcType, "| Weapon:", toolName)
                        tweenPos(CFrame.new(questInfo.position))
                        task.wait(3)
                    end
                    task.wait(1)
                    firstMob = false
                    continue
                end
                firstMob = false

                print("[FARM] Found:", closest.Name)

                equipToolByName(toolName, char)

                local box = Instance.new("SelectionBox")
                box.Adornee = closest
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.LineThickness = 0.08
                box.SurfaceTransparency = 0.6
                box.SurfaceColor3 = Color3.fromRGB(0, 255, 0)
                box.Parent = workspace

                local skillIndex = 1

                repeat task.wait()

                    if not closest or not closest.Parent
                        or not closest:FindFirstChild("HumanoidRootPart")
                        or closest.Humanoid.Health <= 0 then
                        break
                    end

                    equipToolByName(toolName, char)

                    BodyVelocity.Velocity = Vector3.zero
                    BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    BodyVelocity.Parent = char.HumanoidRootPart

                    local success, owner = pcall(function()
                        return closest.HumanoidRootPart:GetNetworkOwner()
                    end)
                    if success and owner == player then
                        closest.HumanoidRootPart.CFrame = CFrame.new(closest.HumanoidRootPart.Position)
                        closest.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        closest.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                    end

                    tweenPos(
                        CFrame.new(closest.HumanoidRootPart.Position + Vector3.new(0, YPOS, 0)) * CFrame.Angles(math.rad(-90), 0, 0),
                        function()
                            hitRemote:FireServer()
                        end
                    )

                    pcall(function() RemoteEvents:WaitForChild("HakiRemote"):FireServer("Toggle") end)
                    pcall(function() RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle") end)

                    pcall(function()
                        RS:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility"):FireServer(skillIndex)
                    end)
                    hitRemote:FireServer()
                    
                    skillIndex = skillIndex + 1
                    if skillIndex > 4 then skillIndex = 1 end

                until char.Humanoid.Health <= 0 or not questUI.Quest.Visible or questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text ~= questInfo.questTitle

                box:Destroy()

                equipToolByName(toolName, char)
                print("[FARM] Killed:", closest.Name, "→ Finding next mob...")
                task.wait(0.3)
            end

            print("[FARM] Exit Farm Loop")
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- [19] MAIN CONTROLLER (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(3)
    pcall(function()
        local backpack = player:WaitForChild("Backpack", 10)
        if not backpack then return end
        local char = player.Character
        if not char then return end
        local tool = backpack:FindFirstChild("Combat")
        if tool then char:FindFirstChild("Humanoid"):EquipTool(tool) end
    end)
end)

task.spawn(function()
    task.wait(15)
    
    if _G.Config.AutoBuyBossKey then
        setupBossKeyAutoListener()
    end
end)

task.spawn(function()
    task.wait(10)

    while _G.Config.AutoFarm do
        local level = 0
        pcall(function() level = player.Data.Level.Value or 0 end)
        print("[SYSTEM] 🔍 Level check:", level)

        if level >= 11500 then
            print("[SYSTEM] 🎯 Level >= 11500 → Checking account completion...")
            
            local hasArmamentHaki = false
            local hasObservationHaki = false
            
            pcall(function()
                local data = RemoteEvents:WaitForChild("HakiRemote"):FireServer("GetProgression")
                if data and data.Armament then
                    hasArmamentHaki = true
                end
                
                hasObservationHaki = checkHasObservationHaki()
            end)
            
            if hasArmamentHaki and hasObservationHaki then
                print("[SYSTEM] ✅ Level 11500+ with both Haki types!")
                print("[SYSTEM] 🔄 Calling Horst_AccountChangeDone...")
                
                if _G.Horst_AccountChangeDone then
                    local ok, err = _G.Horst_AccountChangeDone()
                    if ok then
                        print("[SYSTEM] ✅ Account change done sent successfully!")
                        print("[SYSTEM] 🔄 Waiting for account switch...")
                        task.wait(999999)
                    else
                        print("[SYSTEM] ❌ Failed to send DONE:", err)
                    end
                else
                    print("[SYSTEM] ⚠️ _G.Horst_AccountChangeDone not found!")
                end
            else
                print(string.format("[SYSTEM] ⏳ Haki status: Armament=%s, Observation=%s", 
                    tostring(hasArmamentHaki), tostring(hasObservationHaki)))
            end
        end

        if level < _G.Config.HakiMinLevel then
            print("[SYSTEM] 📈 Level " .. level .. " - Normal Farm (Melee)")
            task.wait(60)
            continue
        end

        if level >= 4000 then
            print("[SYSTEM] 💎 Level >= 4000 → Checking Artifacts...")
            if not checkArtifactsUnlocked() then
                print("[SYSTEM] 🔓 Unlocking Artifacts...")
                local unlocked = unlockArtifacts()
                if unlocked then
                    print("[SYSTEM] ✅ Artifacts unlocked! Equipping...")
                    equipArtifacts()
                end
            else
                print("[SYSTEM] ✅ Artifacts already unlocked")
            end
        end

        if level >= 6000 then
            print("[SYSTEM] 👁️ Level >= 6000 → Checking Observation Haki...")
            if not checkHasObservationHaki() then
                print("[SYSTEM] 🔓 Buying Observation Haki...")
                buyObservationHaki()
            else
                print("[SYSTEM] ✅ Observation Haki already owned")
            end
        end

        if _G.Config.FarmSaberBoss then
            local bossKeyCount = checkBossKeyCount()
            if bossKeyCount >= 1 then
                print("[SYSTEM] 🎯 Starting Saber Boss farm...")
                farmSaberBoss()
                task.wait(5)
            else
                print("[SYSTEM] ⚠️ Not enough Boss Keys for Saber Boss (need 1)")
            end
        end

        if _G.Config.ExchangeIchigo and level >= _G.Config.IchigoMinLevel then
            print("[SYSTEM] ⚔️ Checking Ichigo Exchange...")
            if not checkDarkBlade("Ichigo") then
                local hasAll, missing = checkIchigoRequirements()
                
                if hasAll then
                    print("[SYSTEM] ✅ All Ichigo requirements met! Exchanging...")
                    exchangeIchigo()
                else
                    print("[SYSTEM] ❌ Missing Ichigo requirements:")
                    for _, item in pairs(missing) do
                        print("[SYSTEM]   - " .. item)
                    end
                end
            else
                print("[SYSTEM] ✅ Ichigo already owned")
            end
        end

        print("[SYSTEM] 🗡️ Checking Dark Blade...")
        local hasBlade = findDarkBladeInHand() ~= nil
        if not hasBlade then
            hasBlade = equipDarkBladeFromInventory()
        end

        if hasBlade then
            print("[SYSTEM] ✅ Dark Blade found!")
            
            if _G.Config.FruitFarm and level >= _G.Config.FruitMinLevel then
                print("[SYSTEM] 🍎 Level " .. level .. " >= " .. _G.Config.FruitMinLevel .. " → Checking Fruit Farm...")
                
                local hasFruit = checkHasFruit(_G.Config.TargetFruit)
                if hasFruit then
                    print("[SYSTEM] ✅ Already have " .. _G.Config.TargetFruit .. " → Fruit Farm Mode!")
                    isFruitFarming = true
                    equipFruit(_G.Config.TargetFruit)
                    
                    local island = _G.Config.FruitFarmIsland
                    local pos = _G.Config.FruitFarmPos
                    pcall(function() tpRemote:FireServer(island) end)
                    task.wait(3)
                    
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for i = 1, 10 do
                            char.HumanoidRootPart.CFrame = pos
                            task.wait(0.1)
                        end
                    end
                    
                    task.spawn(fruitFarmLoop)
                    break
                else
                    print("[SYSTEM] ❌ No " .. _G.Config.TargetFruit .. " → Starting Fruit Farm process...")
                    oldPrint("[DEBUG] About to call startFruitFarm...")
                    local ok, err = pcall(startFruitFarm)
                    if ok then
                        oldPrint("[DEBUG] startFruitFarm completed OK")
                    else
                        oldPrint("[DEBUG] startFruitFarm ERROR:", tostring(err))
                    end
                    break
                end
            else
                print("[SYSTEM] ✅ Dark Blade found! Normal Farm...")
                break
            end
        end

        print("[SYSTEM] ❌ No Dark Blade | Checking Haki...")
        local hasHaki = checkHakiStatus()

        if hasHaki then
            print("[SYSTEM] ✅ Has Haki but no Dark Blade → Buying...")
            if _G.Config.BuyDarkBlade then
                pcall(buyDarkBlade)
            end
            print("[SYSTEM] 🗡️ Dark Blade process done! Normal Farm...")
            break
        end

        if _G.Config.HakiQuest and not isHakiQuestActive then
            print("[SYSTEM] 🔥 No Haki + No Dark Blade → Starting Haki Quest...")
            isHakiQuestActive = true
            pcall(startHakiQuest)
            isHakiQuestActive = false
            print("[SYSTEM] ✅ Haki Quest done! Normal Farm...")
            break
        end

        task.wait(60)
    end
end)

task.spawn(function()
    task.wait(15)
    pcall(farmLoop)
end)

-- ═══════════════════════════════════════════════════════════════
-- [20] EVENT HANDLERS (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        task.wait(1.5)
        pcall(rejoin)
    end
end)

Players.PlayerRemoving:Connect(function()
    pcall(function()
        game:HttpGet("https://node-api--0890939481gg.replit.app/leave")
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- [21] HEARTBEAT PHYSICS LOCK (คงเดิม)
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if player.Character then
            for _, v in pairs(player.Character:GetChildren()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.CanCollide = false
                    v.AssemblyLinearVelocity = Vector3.zero
                    v.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- [22] INITIALIZE UI CONFIG
-- ═══════════════════════════════════════════════════════════════
OrionLib:Init()