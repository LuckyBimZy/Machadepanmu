-- ═══════════════════════════════════════════════════════════════
-- Sailor Piece v5 - Catraz Hub UI Edition (No Node Links)
-- ═══════════════════════════════════════════════════════════════
repeat task.wait(2) until game:IsLoaded()

-- ═══════════════════════════════════════════════════════════════
-- [0] LOAD CATRAZ HUB UI LIBRARY
-- ═══════════════════════════════════════════════════════════════
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

-- ═══════════════════════════════════════════════════════════════
-- [1] CONFIG - ALL FEATURES DEFAULT OFF
-- ═══════════════════════════════════════════════════════════════
_G.Config = {
    -- ระบบหลัก (เปิด/ปิดแต่ละระบบ) - DEFAULT ALL OFF
    AutoFarm        = false,    -- ฟาร์มอัตโนมัติ (OFF by default)
    AutoHit         = false,    -- ตีอัตโนมัติ + สกิล Z (OFF by default)
    AutoStats       = false,    -- อัพสเตตัสอัตโนมัติ (OFF by default)
    FpsBoost        = false,    -- BlackScreen ลดแลค (OFF by default)
    HorstDisplay    = true,     -- แสดงข้อมูลผ่าน Horst

    -- Haki Quest
    HakiQuest       = false,    -- ทำภารกิจ Haki อัตโนมัติ (OFF by default)
    HakiMinLevel    = 3000,     -- Level ขั้นต่ำที่จะเริ่มทำ Haki
    HakiTimeout     = 3600,     -- Timeout (วินาที) = 60 นาที

    -- Dark Blade
    BuyDarkBlade    = false,    -- ซื้อ Dark Blade หลังได้ Haki (OFF by default)
    DarkBladeGems   = 150,      -- Gems ที่ต้องใช้
    DarkBladeMoney  = 250000,   -- Money ที่ต้องใช้

    -- Fruit Farm (ฟาร์มหาผลปีศาจ)
    FruitFarm       = false,     -- เปิด/ปิดการฟาร์มผล (OFF by default)
    FruitMinLevel   = 11500,    -- Level ขั้นต่ำที่จะเริ่มฟาร์มผล
    TargetFruit     = "Quake",  -- ผลที่ต้องการ
    FruitFarmIsland = "Shinjuku", -- เกาะที่จะฟาร์ม
    FruitFarmPos    = CFrame.new(321.706757, -1.539090, -1756.500977) * CFrame.Angles(0, -0.113749, 0),

    -- Boss Key Auto Buy
    AutoBuyBossKey  = false,    -- (OFF by default)
    BossKeyBuyInterval = 1800,
    
    -- Ichigo Exchange
    ExchangeIchigo  = false,    -- (OFF by default)
    IchigoMinLevel  = 11500,
    IchigoRequirements = { BossTicket = 500 },
    
    -- Saber Boss Farm
    FarmSaberBoss   = false,    -- (OFF by default)
    SaberBossSummonItems = { BossKey = 1, Money = 100000, Gems = 175 },

    -- Stats Distribution
    StatSword       = 50,
    StatDefense     = 30,
    StatPower       = 20,

    -- Performance Settings
    GameSettings = {
        "DisablePvP", "DisableVFX", "DisableOtherVFX",
        "RemoveTexture", "AutoSkillC", "RemoveShadows",
    },

    -- Log Filter
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

-- Remote References
local hitRemote     = CombatRemotes:WaitForChild("RequestHit")
local questRemote   = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote    = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote      = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")

-- State
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
-- [3] ERROR SUPPRESSION
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

-- ═══════════════════════════════════════════════════════════════
-- [4] UTILITY FUNCTIONS
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

OrionLib.SelectedTheme = "Ocean"

-- ===== MAIN TAB =====
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local StatusSection = MainTab:AddSection({
    Name = "Status & Information",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local PlayerStatsPara = StatusSection:AddParagraph({
    Title = "Player Statistics",
    Desc = "Loading...",
    Image = "user",
    ImageSize = 38,
})

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
        if Value then
            task.spawn(function()
                if not _G.farmLoopRunning then
                    _G.farmLoopRunning = true
                    pcall(farmLoop)
                end
            end)
        end
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
-- [7] INVENTORY TRACKER
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
-- [8] HORST DISPLAY
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
end

-- ═══════════════════════════════════════════════════════════════
-- [9] AUTO HIT + AUTO STATS
-- ═══════════════════════════════════════════════════════════════
_G.autoHitRunning = false
_G.autoStatsRunning = false

if _G.Config.AutoHit then
    _G.autoHitRunning = true
    task.spawn(function()
        while _G.autoHitRunning do
            task.wait(0.4)
            if not _G.Config.AutoHit then continue end
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

if _G.Config.AutoStats then
    _G.autoStatsRunning = true
    task.spawn(function()
        while _G.autoStatsRunning do
            task.wait(5)
            if not _G.Config.AutoStats then continue end
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
-- [10] STATS & WEAPON SYSTEM
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
-- [11] FRUIT FARM SYSTEM
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
    
    return false
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
    return false
end

local function startFruitFarm()
    oldPrint("[FRUIT] ========== FRUIT FARM START ==========")
    isFruitFarming = true
    
    local targetFruit = _G.Config.TargetFruit
    
    if checkHasFruit(targetFruit) then
        oldPrint("[FRUIT] ✅ Already have", targetFruit)
        equipFruit(targetFruit)
        
        oldPrint("[FRUIT] 📍 Teleporting to farm position...")
        local island = _G.Config.FruitFarmIsland
        local pos = _G.Config.FruitFarmPos
        
        pcall(function() tpRemote:FireServer(island) end)
        task.wait(3)
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = pos
        end
        
        oldPrint("[FRUIT] ✅ Fruit farm setup complete!")
        task.spawn(fruitFarmLoop)
        return true
    end
    
    oldPrint("[FRUIT] ❌ Don't have target fruit yet")
    isFruitFarming = false
    return false
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

-- ═══════════════════════════════════════════════════════════════
-- [12] NORMAL QUEST FARM
-- ═══════════════════════════════════════════════════════════════
_G.farmLoopRunning = false

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
    _G.farmLoopRunning = true
    
    while _G.Config.AutoFarm and _G.farmLoopRunning do
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

            while _G.Config.AutoFarm and _G.farmLoopRunning do
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
    
    _G.farmLoopRunning = false
end

-- ═══════════════════════════════════════════════════════════════
-- [13] MAIN CONTROLLER
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
        print("[BOSS KEY] Auto buy system ready")
    end
end)

task.spawn(function()
    task.wait(5)
    if _G.Config.AutoFarm then
        task.spawn(farmLoop)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- [14] EVENT HANDLERS
-- ═══════════════════════════════════════════════════════════════
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        task.wait(1.5)
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- [15] HEARTBEAT PHYSICS LOCK
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
-- [16] INITIALIZE UI CONFIG
-- ═══════════════════════════════════════════════════════════════
OrionLib:Init()

print("[SYSTEM] Sailor Piece v5 loaded - All features OFF by default. Enable them from UI!")
OrionLib:MakeNotification({
    Name = "Sailor Piece v5",
    Content = "All features are OFF by default. Enable them from the UI!",
    Image = "info",
    Time = 5
})