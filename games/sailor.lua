-- ==================== SAILOR PIECE - CATRAZ HUB EDITION v5 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 5.0 ULTIMATE

-- [[ ANALYTICS SYSTEM ]] --
task.spawn(function()
    local BackendURL = "http://bot-service-asia-se-02.cybrancee.com:5023"
    local ScriptName = "Sailor Piece v5"
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

if _G.SP_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Sailor Piece",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.SP_Loaded = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
repeat task.wait(2) until game:IsLoaded()
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- SERVICES & VARIABLES
--==================================================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local Lighting = game.Lighting
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local BodyVelocity = Instance.new("BodyVelocity")

-- Remote References
local Remotes = RS:WaitForChild("Remotes")
local RemoteEvents = RS:WaitForChild("RemoteEvents")
local CombatRemotes = RS:WaitForChild("CombatSystem"):WaitForChild("Remotes")

local hitRemote = CombatRemotes:WaitForChild("RequestHit")
local questRemote = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")

--==================================================
-- CONFIG
--==================================================
local Config = {
    -- Sistem Utama
    AutoFarm = true,
    AutoHit = true,
    AutoStats = true,
    FpsBoost = true,
    
    -- Haki Quest
    HakiQuest = true,
    HakiMinLevel = 3000,
    HakiTimeout = 3600,
    
    -- Dark Blade
    BuyDarkBlade = true,
    DarkBladeGems = 150,
    DarkBladeMoney = 250000,
    
    -- Fruit Farm
    FruitFarm = false,
    FruitMinLevel = 11500,
    TargetFruit = "Quake",
    FruitFarmIsland = "Shinjuku",
    FruitFarmPos = CFrame.new(321.706757, -1.539090, -1756.500977) * CFrame.Angles(0, -0.113749, 0),
    
    -- Boss Key
    AutoBuyBossKey = true,
    BossKeyBuyInterval = 1800,
    
    -- Ichigo Exchange
    ExchangeIchigo = true,
    IchigoMinLevel = 11500,
    
    -- Saber Boss Farm
    FarmSaberBoss = true,
    
    -- Stats Distribution
    StatSword = 50,
    StatDefense = 30,
    StatPower = 20,
    
    -- Performance
    GameSettings = {
        "DisablePvP", "DisableVFX", "DisableOtherVFX",
        "RemoveTexture", "AutoSkillC", "RemoveShadows",
    },
    
    -- Log Tags
    LogTags = {
        "[SYSTEM]", "[FARM]", "[HAKI]", "[WEAPON]",
        "[HORST]", "[STATS]", "[QUEST]", "[INVENTORY]",
        "[FRUIT]", "[DEBUG]",
    },
}

--==================================================
-- STATE VARIABLES
--==================================================
local inventoryByRarity = {
    Secret = {}, Mythical = {}, Legendary = {},
    Epic = {}, Rare = {}, Uncommon = {}, Common = {}
}
local cratesAndBoxes = {}
local isHakiQuestActive = false
local isBuyingDarkBlade = false
local isFruitFarming = false
local isFarmingIchigoBoss = false
local lastBossKeyBuyTime = 0
local isBuyingBossKey = false

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Sailor Piece",
        Content = msg,
        Image = "info",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece",
    Subtext = "Catraz Hub Edition v5",
    Version = "v5.0",
    VersionIcon = "anchor",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece v5",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
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
-- CREATE TABS
--==================================================
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "home",
    Glass = true,
    Outline = true
})

local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "swords",
    Glass = true,
    Outline = true
})

local WeaponTab = Window:MakeTab({
    Name = "Weapons",
    Icon = "sword",
    Glass = true,
    Outline = true
})

local FruitTab = Window:MakeTab({
    Name = "Fruits",
    Icon = "apple",
    Glass = true,
    Outline = true
})

local HakiTab = Window:MakeTab({
    Name = "Haki",
    Icon = "zap",
    Glass = true,
    Outline = true
})

local BossTab = Window:MakeTab({
    Name = "Bosses",
    Icon = "skull",
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
local FRUIT_LIST = {"Quake", "Flame", "Ice", "Sand", "Dark", "Light", "Magma", "Gura", "Bomb", "Spin"}
local ISLAND_LIST = {"Starter", "Shinjuku", "Saoba", "Marineford", "Skypiea", "ImpelDown", "Wano"}
local STAT_DIST = {"50/30/20", "40/30/30", "60/20/20", "70/20/10", "80/10/10"}

--==================================================
-- UTILITY FUNCTIONS
--==================================================
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    return char, hrp, hum
end

-- Portal Map
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

-- Smart Teleport
function _G.SmartTP(pos)
    local targetPos = CFrame.new(pos)
    local island = getNearestIsland(targetPos.Position)
    if not island then return print("[SmartTP] No portal found!") end
    tpRemote:FireServer(island)
    task.wait(0.5)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(targetPos.Position) end
end

-- Tween Position
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

-- Format Number
local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

-- Check Dark Blade
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

-- Get Best Weapon
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

-- Check Haki Status
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
    return hasHaki, hakiInfo
end

-- Check Observation Haki
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
    return hasObs
end

-- Find NPC
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

-- Get Quest Info
local function getQuestInfo()
    local ok, result = pcall(function()
        return RemoteEvents.GetQuestArrowTarget:InvokeServer()
    end)
    return ok and result or nil
end

-- Get NPC Type
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

--==================================================
-- FPS BOOST
--==================================================
local BlackScreen = Config.FpsBoost

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

-- Apply game settings
for _, setting in ipairs(Config.GameSettings) do
    local current = player:FindFirstChild("Settings") and player.Settings:FindFirstChild(setting)
    if not current or current.Value ~= true then
        settingsToggle:FireServer(setting, true)
    end
end

--==================================================
-- HEARTBEAT PHYSICS LOCK
--==================================================
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

--==================================================
-- AUTO HIT
--==================================================
if Config.AutoHit then
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

--==================================================
-- AUTO STATS
--==================================================
if Config.AutoStats then
    task.spawn(function()
        while task.wait(5) do
            pcall(function()
                local points = player.Data.StatPoints.Value or 0
                if points <= 0 then return end

                local level = player.Data.Level.Value or 0

                if level < Config.HakiMinLevel then
                    local melee, defense = 0, 0
                    while points > 0 do
                        local m = math.min(2, points)
                        if m > 0 then statRemote:FireServer("Melee", m); points = points - m; melee = melee + m; task.wait(0.1) end
                        if points <= 0 then break end

                        local d = math.min(1, points)
                        if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d; task.wait(0.1) end
                    end
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
                end
            end)
        end
    end)
end

--==================================================
-- INVENTORY TRACKER
--==================================================
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
            end
        end
    end)

    task.wait(3)
    pcall(function() requestInventory:FireServer() end)
end)

--==================================================
-- AUTO BUY BOSS KEY
--==================================================
local function checkBossKeyCount()
    pcall(function() RS.Remotes.RequestInventory:FireServer() end)
    task.wait(1)
    local count = inventoryByRarity["Epic"]["Boss Key"] or 0
    return count
end

local function buyBossKeysFromStock(bossKeyStock)
    if isBuyingBossKey then return false end
    
    local currentTime = tick()
    if currentTime - lastBossKeyBuyTime < 5 then return false end
    
    isBuyingBossKey = true
    
    local merchantCF = CFrame.new(368.817719, 2.79983521, 783.589844, -0.0566431284, 0, 0.998394549, 0, 1, 0, -0.998394549, 0, -0.0566431284)
    tweenPos(merchantCF)
    task.wait(3)
    
    for i = 1, bossKeyStock do
        pcall(function()
            RS.Remotes.MerchantRemotes.PurchaseMerchantItem:InvokeServer("Boss Key", 1)
        end)
        task.wait(0.5)
    end
    
    lastBossKeyBuyTime = currentTime
    isBuyingBossKey = false
    return true
end

local function setupBossKeyAutoListener()
    pcall(function()
        RS.Remotes.MerchantRemotes.MerchantStockUpdate.OnClientEvent:Connect(function(...)
            if not Config.AutoBuyBossKey then return end
            
            local args = {...}
            for i, arg in ipairs(args) do
                if type(arg) == "table" then
                    for _, item in pairs(arg) do
                        if type(item) == "table" and (item.name == "Boss Key" or item.itemId == "Boss Key") then
                            local stock = item.stock or item.quantity or 0
                            if stock > 0 then
                                task.spawn(function() buyBossKeysFromStock(stock) end)
                            end
                            return
                        end
                    end
                end
            end
        end)
    end)
end

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
    Title = "👤 " .. player.Name,
    Desc = "Display Name: " .. player.DisplayName .. "\n" ..
           "User ID: " .. player.UserId .. "\n" ..
           "Account Age: " .. player.AccountAge .. " days",
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
    ImageSize = 48,
    Buttons = {
        {
            Title = "🔄 Refresh",
            Callback = function()
                ServerPara:SetDesc("Players: " .. #Players:GetPlayers() .. "\n" ..
                                  "Uptime: " .. getUptime())
            end
        }
    }
})

task.spawn(function()
    while true do
        task.wait(1)
        ServerPara:SetDesc("Players: " .. #Players:GetPlayers() .. "\n" ..
                          "Uptime: " .. getUptime())
    end
end)

local PlayerInfoPara = HomeTab:AddParagraph({
    Title = "📊 PLAYER STATS",
    Desc = "Loading...",
    Image = "bar-chart",
    ImageSize = 38
})

-- Update player stats
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local level = player.Data.Level.Value or 0
            local money = player.Data.Money.Value or 0
            local gems = player.Data.Gems.Value or 0
            local points = player.Data.StatPoints.Value or 0
            
            PlayerInfoPara:SetDesc(
                "Level: " .. level .. "\n" ..
                "Money: " .. formatNumber(money) .. "\n" ..
                "Gems: " .. formatNumber(gems) .. "\n" ..
                "Stat Points: " .. points
            )
        end)
    end
end)

--==================================================
-- FARM TAB
--==================================================
local FarmMainSection = FarmTab:AddSection({
    Name = "🚀 AUTO FARM SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmMainSection:AddToggle({
    Name = "✅ Auto Farm",
    Default = Config.AutoFarm,
    Outline = true,
    Flag = "AutoFarm",
    Callback = function(v) Config.AutoFarm = v end
})

FarmMainSection:AddToggle({
    Name = "⚔️ Auto Hit + Skill Z",
    Default = Config.AutoHit,
    Outline = true,
    Flag = "AutoHit",
    Callback = function(v) Config.AutoHit = v end
})

FarmMainSection:AddToggle({
    Name = "📈 Auto Stats",
    Default = Config.AutoStats,
    Outline = true,
    Flag = "AutoStats",
    Callback = function(v) Config.AutoStats = v end
})

local StatsSection = FarmTab:AddSection({
    Name = "📊 STATS DISTRIBUTION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

StatsSection:AddDropdown({
    Name = "Distribution (Sword/Defense/Power)",
    Default = "50/30/20",
    Options = STAT_DIST,
    Multi = false,
    Outline = true,
    Flag = "StatDist",
    Callback = function(v)
        if v == "50/30/20" then
            Config.StatSword = 50
            Config.StatDefense = 30
            Config.StatPower = 20
        elseif v == "40/30/30" then
            Config.StatSword = 40
            Config.StatDefense = 30
            Config.StatPower = 30
        elseif v == "60/20/20" then
            Config.StatSword = 60
            Config.StatDefense = 20
            Config.StatPower = 20
        elseif v == "70/20/10" then
            Config.StatSword = 70
            Config.StatDefense = 20
            Config.StatPower = 10
        elseif v == "80/10/10" then
            Config.StatSword = 80
            Config.StatDefense = 10
            Config.StatPower = 10
        end
    end
})

--==================================================
-- WEAPON TAB
--==================================================
local WeaponMainSection = WeaponTab:AddSection({
    Name = "🗡️ DARK BLADE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

WeaponMainSection:AddToggle({
    Name = "💰 Auto Buy Dark Blade",
    Default = Config.BuyDarkBlade,
    Outline = true,
    Flag = "BuyDarkBlade",
    Callback = function(v) Config.BuyDarkBlade = v end
})

local DarkBladeStatus = WeaponMainSection:AddParagraph({
    Title = "Dark Blade Status",
    Desc = "Checking...",
    Image = "sword",
    ImageSize = 30
})

WeaponMainSection:AddButton({
    Name = "🔍 Check Dark Blade",
    Outline = true,
    Callback = function()
        local hasBlade = findDarkBladeInHand() ~= nil
        if not hasBlade then hasBlade = equipDarkBladeFromInventory() end
        DarkBladeStatus:SetDesc(hasBlade and "✅ Owned" or "❌ Not Owned")
    end
})

WeaponMainSection:AddButton({
    Name = "🗡️ Equip Dark Blade",
    Outline = true,
    Callback = function()
        if equipDarkBladeFromInventory() then
            Notify("Dark Blade equipped!")
        else
            Notify("Dark Blade not found!")
        end
    end
})

local IchigoSection = WeaponTab:AddSection({
    Name = "⚔️ ICHIGO SWORD",
    TextSize = 18,
    Glass = true,
    Outline = true
})

IchigoSection:AddToggle({
    Name = "🔄 Auto Exchange Ichigo",
    Default = Config.ExchangeIchigo,
    Outline = true,
    Flag = "ExchangeIchigo",
    Callback = function(v) Config.ExchangeIchigo = v end
})

IchigoSection:AddSlider({
    Name = "Min Level",
    Min = 1000,
    Max = 20000,
    Default = Config.IchigoMinLevel,
    Increment = 100,
    ValueName = "Lv",
    Outline = true,
    Flag = "IchigoMinLevel",
    Callback = function(v) Config.IchigoMinLevel = v end
})

--==================================================
-- FRUIT TAB
--==================================================
local FruitMainSection = FruitTab:AddSection({
    Name = "🍎 FRUIT FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FruitMainSection:AddToggle({
    Name = "🍎 Auto Fruit Farm",
    Default = Config.FruitFarm,
    Outline = true,
    Flag = "FruitFarm",
    Callback = function(v) Config.FruitFarm = v end
})

FruitMainSection:AddSlider({
    Name = "Min Level",
    Min = 1000,
    Max = 20000,
    Default = Config.FruitMinLevel,
    Increment = 100,
    ValueName = "Lv",
    Outline = true,
    Flag = "FruitMinLevel",
    Callback = function(v) Config.FruitMinLevel = v end
})

FruitMainSection:AddDropdown({
    Name = "Target Fruit",
    Default = Config.TargetFruit,
    Options = FRUIT_LIST,
    Multi = false,
    Outline = true,
    Flag = "TargetFruit",
    Callback = function(v) Config.TargetFruit = v end
})

FruitMainSection:AddDropdown({
    Name = "Farm Island",
    Default = Config.FruitFarmIsland,
    Options = ISLAND_LIST,
    Multi = false,
    Outline = true,
    Flag = "FruitIsland",
    Callback = function(v) Config.FruitFarmIsland = v end
})

--==================================================
-- HAKI TAB
--==================================================
local HakiMainSection = HakiTab:AddSection({
    Name = "🔥 HAKI SYSTEM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HakiMainSection:AddToggle({
    Name = "⚡ Auto Haki Quest",
    Default = Config.HakiQuest,
    Outline = true,
    Flag = "HakiQuest",
    Callback = function(v) Config.HakiQuest = v end
})

HakiMainSection:AddSlider({
    Name = "Min Level",
    Min = 1000,
    Max = 10000,
    Default = Config.HakiMinLevel,
    Increment = 100,
    ValueName = "Lv",
    Outline = true,
    Flag = "HakiMinLevel",
    Callback = function(v) Config.HakiMinLevel = v end
})

local HakiStatus = HakiMainSection:AddParagraph({
    Title = "Haki Status",
    Desc = "Checking...",
    Image = "zap",
    ImageSize = 30
})

HakiMainSection:AddButton({
    Name = "🔍 Check Haki",
    Outline = true,
    Callback = function()
        local hasHaki, info = checkHakiStatus()
        local hasObs = checkHasObservationHaki()
        HakiStatus:SetDesc(
            "Armament: " .. (hasHaki and "✅" or "❌") .. "\n" ..
            "Observation: " .. (hasObs and "✅" or "❌")
        )
    end
})

--==================================================
-- BOSS TAB
--==================================================
local BossMainSection = BossTab:AddSection({
    Name = "👾 BOSS FARM",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "🔑 Auto Buy Boss Key",
    Default = Config.AutoBuyBossKey,
    Outline = true,
    Flag = "AutoBuyBossKey",
    Callback = function(v) Config.AutoBuyBossKey = v end
})

BossMainSection:AddToggle({
    Name = "⚔️ Farm Saber Boss",
    Default = Config.FarmSaberBoss,
    Outline = true,
    Flag = "FarmSaberBoss",
    Callback = function(v) Config.FarmSaberBoss = v end
})

local BossKeyCount = BossMainSection:AddParagraph({
    Title = "Boss Key Count",
    Desc = "Loading...",
    Image = "key",
    ImageSize = 30
})

task.spawn(function()
    while true do
        task.wait(3)
        local count = checkBossKeyCount()
        BossKeyCount:SetDesc(count .. " Keys")
    end
end)

--==================================================
-- CONFIG TAB
--==================================================
local PerfSection = ConfigTab:AddSection({
    Name = "⚙️ PERFORMANCE",
    TextSize = 18,
    Glass = true,
    Outline = true
})

PerfSection:AddToggle({
    Name = "🎮 FPS Boost (Black Screen)",
    Default = Config.FpsBoost,
    Outline = true,
    Flag = "FpsBoost",
    Callback = function(v)
        Config.FpsBoost = v
        setBlack(v)
    end
})

PerfSection:AddButton({
    Name = "🔄 Apply Game Settings",
    Outline = true,
    Callback = function()
        for _, setting in ipairs(Config.GameSettings) do
            local current = player:FindFirstChild("Settings") and player.Settings:FindFirstChild(setting)
            if not current or current.Value ~= true then
                settingsToggle:FireServer(setting, true)
            end
        end
        Notify("Game settings applied!")
    end
})

local ActionSection = ConfigTab:AddSection({
    Name = "🎮 ACTIONS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

ActionSection:AddButton({
    Name = "📋 Show Inventory (F1)",
    Outline = true,
    Callback = function()
        local data = player:WaitForChild("Data", 2)
        if not data then return end

        local level = data:FindFirstChild("Level") and data.Level.Value or 0
        local money = data:FindFirstChild("Money") and data.Money.Value or 0
        local gems = data:FindFirstChild("Gems") and data.Gems.Value or 0

        print("\n========================================")
        print("📊 INVENTORY | ⭐Lv." .. level .. " 💰" .. money .. " 💎" .. gems)
        print("========================================")

        for name, qty in pairs(cratesAndBoxes) do
            print("  📦 " .. name .. " x" .. qty)
        end

        local order = {"Secret","Mythical","Legendary","Epic","Rare","Uncommon","Common"}
        local emojis = {Secret="🌟",Mythical="✨",Legendary="🔥",Epic="💜",Rare="💙",Uncommon="💚",Common="⚪"}
        for _, rarity in ipairs(order) do
            local items = inventoryByRarity[rarity]
            local count = 0
            for _ in pairs(items) do count = count + 1 end
            if count > 0 then
                print(emojis[rarity] .. " [" .. rarity:upper() .. "] " .. count .. " items:")
                for name, qty in pairs(items) do
                    print("   • " .. name .. " x" .. qty)
                end
            end
        end
        print("========================================\n")
    end
})

ActionSection:AddButton({
    Name = "📍 Set Home Position",
    Outline = true,
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            _G.HomePos = char.HumanoidRootPart.CFrame
            Notify("Home position saved!")
        end
    end
})

ActionSection:AddButton({
    Name = "🏠 Teleport to Home",
    Outline = true,
    Callback = function()
        if _G.HomePos then
            tweenPos(_G.HomePos)
            Notify("Teleported to home!")
        else
            Notify("No home position saved!")
        end
    end
})

--==================================================
-- MAIN FARM LOOP
--==================================================
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
        char.Humanoid:EquipTool(tool)
    end
    return tool
end

local function farmLoop()
    while Config.AutoFarm do
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
            local skillIndex = 1

            while Config.AutoFarm do
                if char.Humanoid.Health <= 0 then break end
                if not questUI.Quest.Visible then break end
                if questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text ~= questInfo.questTitle then break end

                local closest = findNPC(npcType)

                if not closest then
                    if firstMob then
                        tweenPos(CFrame.new(questInfo.position))
                        task.wait(3)
                    end
                    task.wait(1)
                    firstMob = false
                    continue
                end
                firstMob = false

                equipToolByName(toolName, char)

                local box = Instance.new("SelectionBox")
                box.Adornee = closest
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.LineThickness = 0.08
                box.SurfaceTransparency = 0.6
                box.SurfaceColor3 = Color3.fromRGB(0, 255, 0)
                box.Parent = workspace

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
                task.wait(0.3)
            end
        end
    end
end

--==================================================
-- INITIALIZE SYSTEMS
--==================================================
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
    if Config.AutoBuyBossKey then
        setupBossKeyAutoListener()
    end
end)

task.spawn(function()
    task.wait(15)
    pcall(farmLoop)
end)

--==================================================
-- F1 KEYBIND
--==================================================
UIS.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= Enum.KeyCode.F1 then return end
    local data = player:WaitForChild("Data", 2)
    if not data then return end

    local level = data:FindFirstChild("Level") and data.Level.Value or 0
    local money = data:FindFirstChild("Money") and data.Money.Value or 0
    local gems = data:FindFirstChild("Gems") and data.Gems.Value or 0

    print("\n========================================")
    print("📊 INVENTORY | ⭐Lv." .. level .. " 💰" .. money .. " 💎" .. gems)
    print("========================================")

    for name, qty in pairs(cratesAndBoxes) do
        print("  📦 " .. name .. " x" .. qty)
    end

    local order = {"Secret","Mythical","Legendary","Epic","Rare","Uncommon","Common"}
    local emojis = {Secret="🌟",Mythical="✨",Legendary="🔥",Epic="💜",Rare="💙",Uncommon="💚",Common="⚪"}
    for _, rarity in ipairs(order) do
        local items = inventoryByRarity[rarity]
        local count = 0
        for _ in pairs(items) do count = count + 1 end
        if count > 0 then
            print(emojis[rarity] .. " [" .. rarity:upper() .. "] " .. count .. " items:")
            for name, qty in pairs(items) do
                print("   • " .. name .. " x" .. qty)
            end
        end
    end
    print("========================================\n")
end)

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "save"
})

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")
print("═══════════════════════════════════════════════════════")
print("⚓ SAILOR PIECE - CATRAZ HUB EDITION v5 ⚓")
print("═══════════════════════════════════════════════════════")
print("✅ Home Tab - Player Info & Stats")
print("✅ Farm Tab - Auto Farm Settings")
print("✅ Weapons Tab - Dark Blade & Ichigo")
print("✅ Fruits Tab - Fruit Farm System")
print("✅ Haki Tab - Haki Quest & Status")
print("✅ Bosses Tab - Boss Key & Saber Boss")
print("✅ Config Tab - Performance & Actions")
print("═══════════════════════════════════════════════════════")
print("🚀 Script siap digunakan!")
print("═══════════════════════════════════════════════════════")