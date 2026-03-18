-- ==================== SAILOR PIECE - CATRAZ ULTIMATE v2.0 ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 2.0 FULLY FUNCTIONAL

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
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- VARIABLES & SERVICES
--==================================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

--==================================================
-- REMOTE REFERENCES (Dengan Error Handling)
--==================================================
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
local CombatSystem = ReplicatedStorage:FindFirstChild("CombatSystem")
local AbilitySystem = ReplicatedStorage:FindFirstChild("AbilitySystem")

-- Function aman untuk mendapatkan remote
local function getRemote(parent, ...)
    if not parent then return nil end
    for _, name in ipairs({...}) do
        parent = parent:FindFirstChild(name)
        if not parent then return nil end
    end
    return parent
end

-- Inisialisasi remote dengan fallback
local hitRemote = getRemote(CombatSystem, "Remotes", "RequestHit") or getRemote(ReplicatedStorage, "RequestHit")
local abilityRemote = getRemote(AbilitySystem, "Remotes", "RequestAbility") or getRemote(ReplicatedStorage, "RequestAbility")
local questRemote = getRemote(RemoteEvents, "QuestAccept") or getRemote(ReplicatedStorage, "QuestAccept")
local abandonRemote = getRemote(RemoteEvents, "QuestAbandon") or getRemote(ReplicatedStorage, "QuestAbandon")
local statRemote = getRemote(RemoteEvents, "AllocateStat") or getRemote(ReplicatedStorage, "AllocateStat")
local tpRemote = getRemote(Remotes, "TeleportToPortal") or getRemote(ReplicatedStorage, "TeleportToPortal")
local settingsToggle = getRemote(RemoteEvents, "SettingsToggle") or getRemote(ReplicatedStorage, "SettingsToggle")
local hakiRemote = getRemote(RemoteEvents, "HakiRemote") or getRemote(ReplicatedStorage, "HakiRemote")
local obsHakiRemote = getRemote(RemoteEvents, "ObservationHakiRemote") or getRemote(ReplicatedStorage, "ObservationHakiRemote")
local summonBossRemote = getRemote(Remotes, "RequestSummonBoss") or getRemote(ReplicatedStorage, "RequestSummonBoss")
local spawnStrongestRemote = getRemote(Remotes, "RequestSpawnStrongestBoss") or getRemote(ReplicatedStorage, "RequestSpawnStrongestBoss")
local anosRemote = getRemote(Remotes, "RequestSpawnAnosBoss") or getRemote(ReplicatedStorage, "RequestSpawnAnosBoss")
local trueAizenRemote = getRemote(RemoteEvents, "RequestSpawnTrueAizen") or getRemote(ReplicatedStorage, "RequestSpawnTrueAizen")
local rimuruRemote = getRemote(RemoteEvents, "RequestSpawnRimuru") or getRemote(ReplicatedStorage, "RequestSpawnRimuru")
local equipRemote = getRemote(Remotes, "EquipWeapon") or getRemote(ReplicatedStorage, "EquipWeapon")
local updateInventory = getRemote(Remotes, "UpdateInventory")
local requestInventory = getRemote(Remotes, "RequestInventory")
local fruitPowerRemote = getRemote(RemoteEvents, "FruitPowerRemote")
local fruitActionRemote = getRemote(RemoteEvents, "FruitAction")
local merchantRemotes = getRemote(Remotes, "MerchantRemotes")
local merchantPurchase = getRemote(merchantRemotes, "PurchaseMerchantItem")
local merchantStock = getRemote(merchantRemotes, "GetMerchantStock")
local merchantStockUpdate = getRemote(merchantRemotes, "MerchantStockUpdate")
local slimeCraftRemote = getRemote(Remotes, "RequestSlimeCraft")
local grailCraftRemote = getRemote(Remotes, "RequestGrailCraft")
local resetStatsRemote = getRemote(RemoteEvents, "ResetStats")

--==================================================
-- SAVE ORIGINAL SETTINGS
--==================================================
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient
}

local originalQuality = settings().Rendering.QualityLevel

--==================================================
-- RESTORE ORIGINAL SETTINGS
--==================================================
local function restoreOriginalSettings()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Ambient = originalLighting.Ambient
    settings().Rendering.QualityLevel = originalQuality
end

--==================================================
-- CONFIGURATION
--==================================================
local Config = {
    -- Auto Farm
    AutoFarm = {
        Enabled = false,
        AutoHit = true,
        AutoStats = true,
        AutoHaki = false,
        AutoObsHaki = false,
        AutoEquip = false,
        SelectedWeapon = "None",
        Skills = {
            Z = false, X = false, C = false, V = false, F = false
        }
    },
    
    -- Haki Quest
    HakiQuest = {
        Enabled = false,
        MinLevel = 3000,
        Timeout = 3600,
        BuyDarkBlade = true,
        DarkBladeGems = 150,
        DarkBladeMoney = 250000
    },
    
    -- Fruit Farm
    FruitFarm = {
        Enabled = false,
        MinLevel = 11500,
        TargetFruit = "Quake",
        Island = "Shinjuku",
        Position = CFrame.new(321.706757, -1.539090, -1756.500977)
    },
    
    -- Boss Systems
    Bosses = {
        AutoSpawn = false,
        Difficulty = "Normal",
        Selected = {},
        Specials = {
            TrueAizen = { Auto = false, Diff = "Normal" },
            Sukuna = { Auto = false, Diff = "Normal" },
            Gojo = { Auto = false, Diff = "Normal" },
            Rimuru = { Auto = false, Diff = "Normal" },
            Anos = { Auto = false, Diff = "Normal" }
        }
    },
    
    -- Entity Targeting
    Entities = {
        Hollow = true, Quincy = true, Swordsman = true, AcademyTeacher = true,
        Slime = true, StrongSorcerer = true, Curse = true,
        Gojo = true, Yuji = true, Sukuna = true, Jinwoo = true,
        Alucard = true, Aizen = true, Yamato = true,
        Saber = true, Ichigo = true, QinShi = true, Gilgamesh = true,
        BlessedMaiden = true, SaberAlter = true,
        StrongestinHistory = true, StrongestofToday = true,
        Rimuru = true, Anos = true, TrueAizen = true
    },
    
    -- Misc Features
    Misc = {
        AntiAFK = false,
        FpsBoost = false,
        WhiteScreen = false,
        AutoRejoin = false,
        TimedRejoin = false,
        RejoinDelay = 10,
        FriendOnly = false,
        AutoCraftSlimeKey = false,
        AutoCraftDivineGrail = false,
        AutoBuyBossKey = false,
        ExchangeIchigo = false,
        IchigoMinLevel = 11500,
        FarmSaberBoss = false
    },
    
    -- Stats Distribution
    Stats = {
        Sword = 50,
        Defense = 30,
        Power = 20
    }
}

--==================================================
-- STATE VARIABLES
--==================================================
local isHakiQuestActive = false
local isBuyingDarkBlade = false
local isFruitFarming = false
local isFarmingIchigoBoss = false
local lastBossKeyBuyTime = 0
local isBuyingBossKey = false
local inventoryByRarity = {
    Secret = {}, Mythical = {}, Legendary = {},
    Epic = {}, Rare = {}, Uncommon = {}, Common = {}
}
local cratesAndBoxes = {}
local farmLoopRunning = false
local fruitFarmLoopRunning = false
local hakiQuestRunning = false
local saberBossRunning = false

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Sailor Piece",
        Content = msg,
        Image = "info",
        Time = duration or 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece",
    Subtext = "Catraz Ultimate v2.0",
    Version = "v2.0",
    VersionIcon = "ship",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPiece_Catraz",
    IntroEnabled = true,
    IntroText = "Sailor Piece Ultimate",
    IntroIcon = "rbxassetid://105921924721005",
    Icon = "rbxassetid://105921924721005",
    ShowIcon = true,
    
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded successfully!")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
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

local HakiTab = Window:MakeTab({
    Name = "Haki & Dark Blade",
    Icon = "shield",
    Glass = true,
    Outline = true
})

local FruitTab = Window:MakeTab({
    Name = "Fruit Farm",
    Icon = "apple",
    Glass = true,
    Outline = true
})

local BossTab = Window:MakeTab({
    Name = "Bosses",
    Icon = "skull",
    Glass = true,
    Outline = true
})

local EntityTab = Window:MakeTab({
    Name = "Entities",
    Icon = "users",
    Glass = true,
    Outline = true
})

local CraftTab = Window:MakeTab({
    Name = "Crafting",
    Icon = "hammer",
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

local function getChar()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    return char, hrp, hum
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function getWeaponList()
    local weapons = {"None", "Combat"}
    local seen = {None=true, Combat=true}
    
    local function addWeapons(container)
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and not seen[tool.Name] then
                    table.insert(weapons, tool.Name)
                    seen[tool.Name] = true
                end
            end
        end
    end
    
    addWeapons(Player.Character)
    addWeapons(Player:FindFirstChild("Backpack"))
    
    return weapons
end

local function findDarkBlade()
    for _, container in pairs({Player.Character, Player:FindFirstChild("Backpack")}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    if tool.Name:find("Dark Blade") or tool.Name:find("ดาบสีเข้ม") then
                        return tool
                    end
                end
            end
        end
    end
    return nil
end

local function checkHakiStatus()
    local hasHaki = false
    safeCall(function()
        local statsUI = Player.PlayerGui:FindFirstChild("StatsPanelUI")
        if statsUI then
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name == "HakiProgressionFrame" and desc.Visible then
                    hasHaki = true
                    break
                end
            end
        end
    end)
    return hasHaki
end

local function checkObservationHaki()
    local hasObs = false
    safeCall(function()
        local statsUI = Player.PlayerGui:FindFirstChild("StatsPanelUI")
        if statsUI then
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name:find("Observation") and desc:IsA("Frame") and desc.Visible then
                    hasObs = true
                    break
                end
            end
        end
    end)
    return hasObs
end

--==================================================
-- TELEPORT SYSTEM (FIXED)
--==================================================

local function smartTP(pos)
    if not tpRemote then
        print("[ERROR] Teleport remote not found!")
        return false
    end
    
    local success = safeCall(function()
        tpRemote:FireServer(pos)
    end)
    
    if not success then
        -- Fallback: Coba cari portal terdekat
        local island = "Starter" -- Default
        safeCall(function() tpRemote:FireServer(island) end)
    end
    
    task.wait(1)
    
    local char, hrp = getChar()
    if hrp then
        hrp.CFrame = CFrame.new(pos)
    end
    
    return true
end

local function tweenPos(targetCF, callback)
    local char, hrp, hum = getChar()
    if not hrp or not hum then return end
    
    local distance = (targetCF.Position - hrp.Position).Magnitude
    
    if distance > 250 then
        smartTP(targetCF.Position)
        task.wait(2)
    end
    
    -- Smooth movement untuk jarak dekat
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCF})
    tween:Play()
    tween.Completed:Wait()
    
    if callback then callback() end
end

--==================================================
-- AUTO FARM SYSTEM (FIXED)
--==================================================

local function findNPC(npcType)
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end
    
    local closest = nil
    local closestDist = math.huge
    local char, hrp = getChar()
    
    for _, v in pairs(npcs:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local name = v.Name:gsub("%[Lv%.?%d+%]", ""):gsub("%s+", "")
            if name:find(npcType, 1, true) or npcType:find(name, 1, true) then
                local root = v:FindFirstChild("HumanoidRootPart")
                if root and hrp then
                    local dist = (root.Position - hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = v
                    end
                end
            end
        end
    end
    
    return closest
end

local function getQuestInfo()
    if not RemoteEvents then return nil end
    local func = RemoteEvents:FindFirstChild("GetQuestArrowTarget")
    if not func then return nil end
    
    local success, result = safeCall(function()
        return func:InvokeServer()
    end)
    
    return success and result or nil
end

local function getNpcTypeFromQuest(questName)
    local success, module = safeCall(function()
        return require(ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("QuestConfig"))
    end)
    
    if not success then return nil end
    
    for npc, data in pairs(module.RepeatableQuests) do
        if npc == questName and data.requirements and data.requirements[1] then
            return data.requirements[1].npcType
        end
    end
    
    return nil
end

local function equipWeapon(weaponName)
    if weaponName == "None" then return end
    
    local char, hum = getChar()
    
    -- Cek apakah sudah di tangan
    if char:FindFirstChild(weaponName) then return true end
    
    -- Cari di backpack
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(weaponName)
        if tool and hum then
            hum:EquipTool(tool)
            task.wait(0.5)
            return true
        end
    end
    
    -- Coba equip via remote
    if equipRemote then
        safeCall(function() equipRemote:FireServer("Equip", weaponName) end)
        task.wait(0.5)
    end
    
    return char:FindFirstChild(weaponName) ~= nil
end

local function farmLoop()
    if farmLoopRunning then return end
    farmLoopRunning = true
    
    while Config.AutoFarm.Enabled and farmLoopRunning do
        task.wait(0.5)
        
        -- Skip jika fitur lain sedang berjalan
        if isHakiQuestActive or isFruitFarming or isFarmingIchigoBoss then
            task.wait(5)
            continue
        end
        
        local char, hrp, hum = getChar()
        if hum.Health <= 0 then 
            task.wait(3)
            continue 
        end
        
        -- Auto Stats
        if Config.AutoFarm.AutoStats then
            safeCall(function()
                local points = Player.Data.StatPoints.Value or 0
                if points > 0 and statRemote then
                    statRemote:FireServer("Sword", points)
                end
            end)
        end
        
        -- Auto Haki
        if Config.AutoFarm.AutoHaki and hakiRemote then
            safeCall(function() hakiRemote:FireServer("Toggle") end)
        end
        
        -- Auto Observation Haki
        if Config.AutoFarm.AutoObsHaki and obsHakiRemote then
            safeCall(function() obsHakiRemote:FireServer("Toggle") end)
        end
        
        -- Auto Equip
        if Config.AutoFarm.AutoEquip and Config.AutoFarm.SelectedWeapon ~= "None" then
            equipWeapon(Config.AutoFarm.SelectedWeapon)
        end
        
        -- Auto Hit
        if Config.AutoFarm.AutoHit and hitRemote then
            -- Cari musuh terdekat
            local target = nil
            local targetDist = 20
            
            local npcs = Workspace:FindFirstChild("NPCs")
            if npcs then
                for _, v in pairs(npcs:GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        local root = v:FindFirstChild("HumanoidRootPart")
                        if root then
                            local dist = (root.Position - hrp.Position).Magnitude
                            if dist < targetDist then
                                targetDist = dist
                                target = root
                            end
                        end
                    end
                end
            end
            
            if target then
                -- Gerak ke target
                if targetDist > 8 then
                    hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 0, 5))
                end
                
                -- Hit
                hitRemote:FireServer()
                
                -- Skills
                if Config.AutoFarm.Skills.Z then
                    safeCall(function() abilityRemote:FireServer(1) end)
                end
                if Config.AutoFarm.Skills.X then
                    safeCall(function() abilityRemote:FireServer(2) end)
                end
                if Config.AutoFarm.Skills.C then
                    safeCall(function() abilityRemote:FireServer(3) end)
                end
                if Config.AutoFarm.Skills.V then
                    safeCall(function() abilityRemote:FireServer(4) end)
                end
                if Config.AutoFarm.Skills.F then
                    safeCall(function() abilityRemote:FireServer(5) end)
                end
            end
        end
        
        -- Quest System
        local questInfo = getQuestInfo()
        if questInfo then
            local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
            if questUI and questUI:FindFirstChild("Quest") then
                if not questUI.Quest.Visible then
                    -- Ambil quest
                    if questRemote then
                        questRemote:FireServer(questInfo.npcName)
                        task.wait(1)
                    end
                else
                    -- Cari target NPC
                    local npcType = getNpcTypeFromQuest(questInfo.npcName)
                    if npcType then
                        local target = findNPC(npcType)
                        if target then
                            local root = target:FindFirstChild("HumanoidRootPart")
                            if root then
                                hrp.CFrame = CFrame.new(root.Position + Vector3.new(0, 0, 3))
                                hitRemote:FireServer()
                            end
                        end
                    end
                end
            end
        end
    end
    
    farmLoopRunning = false
end

--==================================================
-- HAKI QUEST SYSTEM (FIXED)
--==================================================

local function startHakiQuest()
    if hakiQuestRunning or not Config.HakiQuest.Enabled then return end
    hakiQuestRunning = true
    isHakiQuestActive = true
    
    Notify("Starting Haki Quest...", 3)
    
    -- Teleport ke lokasi Haki
    local hakiPos = Vector3.new(-497.94, 23.66, -1252.64)
    tweenPos(CFrame.new(hakiPos))
    task.wait(2)
    
    -- Interact dengan NPC
    for i = 1, 5 do
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(1)
    end
    
    -- Ambil quest
    if questRemote then
        questRemote:FireServer("HakiQuestNPC")
    end
    
    -- Farm Thief
    local startTime = tick()
    local killCount = 0
    
    while isHakiQuestActive and tick() - startTime < Config.HakiQuest.Timeout do
        task.wait(0.5)
        
        local char, hrp, hum = getChar()
        if hum.Health <= 0 then
            task.wait(3)
            continue
        end
        
        -- Cari Thief
        local target = findNPC("Thief")
        if target then
            local root = target:FindFirstChild("HumanoidRootPart")
            if root then
                hrp.CFrame = CFrame.new(root.Position + Vector3.new(0, 0, 3))
                if hitRemote then hitRemote:FireServer() end
                
                -- Cek progress
                if target.Humanoid.Health <= 0 then
                    killCount = killCount + 1
                end
            end
        end
        
        -- Cek quest complete
        local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
        if questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible then
            local desc = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestDescription.Text
            if desc:find("Completed") then
                -- Kembali ke NPC
                tweenPos(CFrame.new(hakiPos))
                task.wait(2)
                
                for i = 1, 5 do
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(1)
                end
                
                if checkHakiStatus() then
                    Notify("✅ Haki Obtained!", 3)
                    
                    if Config.HakiQuest.BuyDarkBlade then
                        task.spawn(function() 
                            -- Buy Dark Blade logic
                            Notify("Buying Dark Blade...", 3)
                        end)
                    end
                    
                    break
                end
            end
        end
    end
    
    isHakiQuestActive = false
    hakiQuestRunning = false
end

--==================================================
-- FRUIT FARM SYSTEM (FIXED)
--==================================================

local function checkHasFruit(fruitName)
    local containers = {Player.Character, Player:FindFirstChild("Backpack")}
    
    for _, container in pairs(containers) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:find(fruitName) then
                    return true, tool
                end
            end
        end
    end
    
    return false
end

local function eatFruit(fruitTool)
    if not fruitTool then return end
    
    local char, hum = getChar()
    local backpack = Player:FindFirstChild("Backpack")
    
    -- Equip fruit
    if fruitTool.Parent == backpack and hum then
        hum:EquipTool(fruitTool)
        task.wait(1)
    end
    
    -- Activate
    safeCall(function() fruitTool:Activate() end)
    task.wait(2)
    
    -- Confirm
    local confirmUI = Player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then yesButton = yesButton:FindFirstChild("ButtonsHolder") end
        if yesButton then yesButton = yesButton:FindFirstChild("Yes") end
        if yesButton then
            safeCall(function()
                for _, conn in pairs(getconnections(yesButton.MouseButton1Click)) do
                    conn:Fire()
                end
            end)
        end
    elseif fruitActionRemote then
        safeCall(function() fruitActionRemote:FireServer("eat", fruitTool.Name) end)
    end
    
    task.wait(3)
end

local function buyRandomFruit()
    local npcCF = CFrame.new(400.641937, 2.79983521, 752.175842)
    tweenPos(npcCF)
    task.wait(3)
    
    -- Cari prompt
    local npc = Workspace:FindFirstChild("ServiceNPCs")
    if npc then npc = npc:FindFirstChild("GemFruitDealer") end
    
    if npc then
        for _, desc in pairs(npc:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                desc.MaxActivationDistance = math.huge
                fireproximityprompt(desc)
                task.wait(3)
                return true
            end
        end
    end
    
    return false
end

local function fruitFarmLoop()
    if fruitFarmLoopRunning or not Config.FruitFarm.Enabled then return end
    fruitFarmLoopRunning = true
    isFruitFarming = true
    
    Notify("Starting Fruit Farm...", 3)
    
    -- Teleport ke lokasi farm
    if tpRemote then
        safeCall(function() tpRemote:FireServer(Config.FruitFarm.Island) end)
        task.wait(3)
    end
    
    local char, hrp = getChar()
    if hrp then
        hrp.CFrame = Config.FruitFarm.Position
    end
    
    -- Equip fruit
    local hasFruit, fruitTool = checkHasFruit(Config.FruitFarm.TargetFruit)
    
    if not hasFruit then
        -- Reset stats dulu
        if resetStatsRemote then
            safeCall(function() resetStatsRemote:FireServer() end)
            task.wait(3)
        end
        
        -- Beli random fruit sampai dapat target
        local attempts = 0
        while attempts < 50 and not hasFruit and isFruitFarming do
            attempts = attempts + 1
            Notify("Buying fruit attempt " .. attempts .. "/50", 2)
            
            if buyRandomFruit() then
                task.wait(3)
                hasFruit, fruitTool = checkHasFruit(Config.FruitFarm.TargetFruit)
                
                if hasFruit then
                    Notify("✅ Got " .. Config.FruitFarm.TargetFruit, 3)
                else
                    -- Eat the wrong fruit
                    local anyFruit = nil
                    for _, container in pairs({Player.Character, Player:FindFirstChild("Backpack")}) do
                        if container then
                            for _, tool in pairs(container:GetChildren()) do
                                if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                                    anyFruit = tool
                                    break
                                end
                            end
                        end
                        if anyFruit then break end
                    end
                    
                    if anyFruit then
                        eatFruit(anyFruit)
                    end
                end
            end
        end
    end
    
    -- Farming loop
    if hasFruit then
        equipWeapon(Config.FruitFarm.TargetFruit)
        
        while isFruitFarming and Config.FruitFarm.Enabled do
            task.wait(1)
            
            local char, hrp, hum = getChar()
            if hum.Health <= 0 then
                task.wait(5)
                continue
            end
            
            -- Maintain position
            if (hrp.Position - Config.FruitFarm.Position.Position).Magnitude > 10 then
                hrp.CFrame = Config.FruitFarm.Position
            end
            
            -- Activate haki
            if hakiRemote then safeCall(function() hakiRemote:FireServer("Toggle") end) end
            
            -- Use fruit skills
            if fruitPowerRemote then
                local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
                for _, key in ipairs(keys) do
                    safeCall(function()
                        fruitPowerRemote:FireServer("UseAbility", {
                            TargetPosition = hrp.Position,
                            FruitPower = Config.FruitFarm.TargetFruit,
                            KeyCode = key
                        })
                    end)
                    task.wait(0.5)
                end
            end
        end
    end
    
    isFruitFarming = false
    fruitFarmLoopRunning = false
end

--==================================================
-- BOSS SYSTEM (FIXED)
--==================================================

local function spawnBoss(bossName, difficulty)
    if summonBossRemote then
        safeCall(function() summonBossRemote:FireServer(bossName .. "Boss", difficulty) end)
    elseif bossName == "TrueAizen" and trueAizenRemote then
        safeCall(function() trueAizenRemote:FireServer(difficulty) end)
    elseif bossName == "Sukuna" and spawnStrongestRemote then
        safeCall(function() spawnStrongestRemote:FireServer("StrongestHistory", difficulty) end)
    elseif bossName == "Gojo" and spawnStrongestRemote then
        safeCall(function() spawnStrongestRemote:FireServer("StrongestToday", difficulty) end)
    elseif bossName == "Rimuru" and rimuruRemote then
        safeCall(function() rimuruRemote:FireServer(difficulty) end)
    elseif bossName == "Anos" and anosRemote then
        safeCall(function() anosRemote:FireServer("Anos", difficulty) end)
    end
end

local function bossSpawnerLoop()
    while Config.Bosses.AutoSpawn do
        task.wait(10)
        
        -- Spawn selected bosses
        for boss, enabled in pairs(Config.Bosses.Selected) do
            if enabled then
                spawnBoss(boss, Config.Bosses.Difficulty)
                task.wait(2)
            end
        end
        
        -- Spawn special bosses
        for boss, data in pairs(Config.Bosses.Specials) do
            if data.Auto then
                spawnBoss(boss, data.Diff)
                task.wait(2)
            end
        end
    end
end

--==================================================
-- SABER BOSS FARM (FIXED)
--==================================================

local function farmSaberBoss()
    if saberBossRunning or not Config.Misc.FarmSaberBoss then return end
    saberBossRunning = true
    isFarmingIchigoBoss = true
    
    Notify("Starting Saber Boss Farm...", 3)
    
    -- Teleport ke summon area
    local summonPos = CFrame.new(651.810181, -3.67419362, -1021.13123)
    tweenPos(summonPos)
    task.wait(3)
    
    -- Summon boss
    spawnBoss("Saber", "Normal")
    task.wait(5)
    
    -- Cari boss
    local boss = nil
    for i = 1, 10 do
        local npcs = Workspace:FindFirstChild("NPCs")
        if npcs then
            boss = npcs:FindFirstChild("SaberBoss")
            if boss then break end
        end
        task.wait(3)
    end
    
    if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") then
        local bossRoot = boss.HumanoidRootPart
        local bossHum = boss.Humanoid
        
        -- Equip weapon
        local blade = findDarkBlade()
        if blade then
            local char, hum = getChar()
            if blade.Parent == Player:FindFirstChild("Backpack") and hum then
                hum:EquipTool(blade)
            end
        end
        
        -- Fight boss
        while isFarmingIchigoBoss and boss.Parent and bossHum.Health > 0 do
            task.wait(0.5)
            
            local char, hrp, hum = getChar()
            if hum.Health <= 0 then
                task.wait(5)
                continue
            end
            
            -- Move to boss
            hrp.CFrame = CFrame.new(bossRoot.Position + Vector3.new(0, 5, 5))
            
            -- Hit
            if hitRemote then hitRemote:FireServer() end
            
            -- Activate haki
            if hakiRemote then safeCall(function() hakiRemote:FireServer("Toggle") end) end
            if obsHakiRemote then safeCall(function() obsHakiRemote:FireServer("Toggle") end) end
        end
        
        if bossHum.Health <= 0 then
            Notify("✅ Saber Boss Defeated!", 3)
        end
    end
    
    isFarmingIchigoBoss = false
    saberBossRunning = false
end

--==================================================
-- MAIN TAB CONTENT
--==================================================
local PlayerInfoSection = MainTab:AddSection({
    Name = "📊 PLAYER INFORMATION",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local playerInfoPara = PlayerInfoSection:AddParagraph({
    Title = "👤 " .. Player.Name,
    Desc = "Loading...",
    Image = "user",
    ImageSize = 48
})

local ServerInfoSection = MainTab:AddSection({
    Name = "🌐 SERVER INFORMATION",
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

local ServerInfoPara = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = "Loading...",
    Image = "server",
    ImageSize = 48
})

-- Auto refresh info
task.spawn(function()
    while true do
        task.wait(2)
        
        local level = safeCall(function() return Player.Data.Level.Value end) or 0
        local money = safeCall(function() return Player.Data.Money.Value end) or 0
        local gems = safeCall(function() return Player.Data.Gems.Value end) or 0
        
        playerInfoPara:SetDesc(
            "Display Name: " .. Player.DisplayName .. "\n" ..
            "Level: " .. level .. "\n" ..
            "Money: " .. formatNumber(money) .. "\n" ..
            "Gems: " .. formatNumber(gems) .. "\n" ..
            "Account Age: " .. Player.AccountAge .. " days"
        )
        
        local players = Players:GetPlayers()
        local ping = safeCall(function() 
            return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
        end) or 0
        
        ServerInfoPara:SetDesc(
            "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
            "Ping: " .. ping .. "ms\n" ..
            "Uptime: " .. getUptime()
        )
    end
end)

--==================================================
-- FARM TAB
--==================================================
local FarmMainSection = FarmTab:AddSection({
    Name = "⚡ AUTO FARM SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FarmMainSection:AddToggle({
    Name = "ENABLE AUTO FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm.Enabled = Value
        Notify(Value and "Auto Farm Enabled" or "Auto Farm Disabled")
        if Value then
            task.spawn(farmLoop)
        end
    end
})

FarmMainSection:AddToggle({
    Name = "AUTO HIT",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHit",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoHit = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO STATS",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoStats",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoStats = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO ARMAMENT HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHaki",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoHaki = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO OBSERVATION HAKI",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoObsHaki",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoObsHaki = Value end
})

FarmMainSection:AddToggle({
    Name = "AUTO EQUIP WEAPON",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoEquip",
    Save = true,
    Callback = function(Value) Config.AutoFarm.AutoEquip = Value end
})

FarmMainSection:AddDropdown({
    Name = "SELECT WEAPON",
    Default = "None",
    Options = getWeaponList(),
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "WeaponSelect",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm.SelectedWeapon = Value
    end
})

FarmMainSection:AddButton({
    Name = "🔄 REFRESH WEAPON LIST",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local weapons = getWeaponList()
        OrionLib.Flags["WeaponSelect"]:SetOptions(weapons)
        Notify("Weapon list refreshed")
    end
})

local SkillSection = FarmTab:AddSection({
    Name = "🎯 AUTO SKILLS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

SkillSection:AddToggle({
    Name = "USE SKILL Z",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillZ",
    Save = true,
    Callback = function(Value) Config.AutoFarm.Skills.Z = Value end
})

SkillSection:AddToggle({
    Name = "USE SKILL X",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillX",
    Save = true,
    Callback = function(Value) Config.AutoFarm.Skills.X = Value end
})

SkillSection:AddToggle({
    Name = "USE SKILL C",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillC",
    Save = true,
    Callback = function(Value) Config.AutoFarm.Skills.C = Value end
})

SkillSection:AddToggle({
    Name = "USE SKILL V",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillV",
    Save = true,
    Callback = function(Value) Config.AutoFarm.Skills.V = Value end
})

SkillSection:AddToggle({
    Name = "USE SKILL F",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillF",
    Save = true,
    Callback = function(Value) Config.AutoFarm.Skills.F = Value end
})

--==================================================
-- HAKI & DARK BLADE TAB
--==================================================
local HakiSection = HakiTab:AddSection({
    Name = "🗡️ HAKI QUEST SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

HakiSection:AddToggle({
    Name = "ENABLE HAKI QUEST",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "HakiQuest",
    Save = true,
    Callback = function(Value)
        Config.HakiQuest.Enabled = Value
        if Value then
            task.spawn(startHakiQuest)
        end
    end
})

HakiSection:AddSlider({
    Name = "MIN LEVEL TO START",
    Min = 1000,
    Max = 10000,
    Default = 3000,
    Increment = 100,
    ValueName = "lvl",
    Outline = true,
    Flag = "HakiMinLevel",
    Save = true,
    Callback = function(Value) Config.HakiQuest.MinLevel = Value end
})

HakiSection:AddSlider({
    Name = "TIMEOUT (SECONDS)",
    Min = 600,
    Max = 7200,
    Default = 3600,
    Increment = 60,
    ValueName = "s",
    Outline = true,
    Flag = "HakiTimeout",
    Save = true,
    Callback = function(Value) Config.HakiQuest.Timeout = Value end
})

HakiSection:AddToggle({
    Name = "BUY DARK BLADE AFTER HAKI",
    Default = true,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "BuyDarkBlade",
    Save = true,
    Callback = function(Value) Config.HakiQuest.BuyDarkBlade = Value end
})

HakiSection:AddButton({
    Name = "🔄 CHECK HAKI STATUS",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local hasHaki = checkHakiStatus()
        Notify(hasHaki and "✅ You have Haki!" or "❌ You don't have Haki yet")
    end
})

HakiSection:AddButton({
    Name = "🗡️ CHECK DARK BLADE",
    Icon = "shield",
    Outline = true,
    Callback = function()
        local hasBlade = findDarkBlade() ~= nil
        Notify(hasBlade and "✅ Dark Blade found!" or "❌ Dark Blade not found")
    end
})

--==================================================
-- FRUIT FARM TAB
--==================================================
local FruitSection = FruitTab:AddSection({
    Name = "🍎 FRUIT FARM SETTINGS",
    TextSize = 18,
    Glass = true,
    Outline = true
})

FruitSection:AddToggle({
    Name = "ENABLE FRUIT FARM",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FruitFarm",
    Save = true,
    Callback = function(Value)
        Config.FruitFarm.Enabled = Value
        if Value then
            task.spawn(fruitFarmLoop)
        end
    end
})

FruitSection:AddSlider({
    Name = "MIN LEVEL TO START",
    Min = 5000,
    Max = 20000,
    Default = 11500,
    Increment = 100,
    ValueName = "lvl",
    Outline = true,
    Flag = "FruitMinLevel",
    Save = true,
    Callback = function(Value) Config.FruitFarm.MinLevel = Value end
})

FruitSection:AddInput({
    Name = "TARGET FRUIT",
    Default = "Quake",
    Numeric = false,
    Flag = "TargetFruit",
    Save = true,
    Callback = function(Value)
        Config.FruitFarm.TargetFruit = Value
    end
})

FruitSection:AddDropdown({
    Name = "FARM ISLAND",
    Default = "Shinjuku",
    Options = {"Shinjuku", "Starter", "HuecoMundo", "SoulSociety", "Judgement", "Academy", "Slime", "Boss"},
    Multi = false,
    Search = true,
    Outline = true,
    Flag = "FruitIsland",
    Save = true,
    Callback = function(Value) Config.FruitFarm.Island = Value end
})

FruitSection:AddButton({
    Name = "🎯 SET CURRENT POSITION AS FARM SPOT",
    Icon = "map-pin",
    Outline = true,
    Callback = function()
        local char, hrp = getChar()
        if hrp then
            Config.FruitFarm.Position = CFrame.new(hrp.Position)
            Notify("Farm position saved!")
        end
    end
})

--==================================================
-- BOSS TAB
--==================================================
local BossMainSection = BossTab:AddSection({
    Name = "👾 BOSS SPAWNER",
    TextSize = 18,
    Glass = true,
    Outline = true
})

BossMainSection:AddToggle({
    Name = "AUTO SPAWN BOSSES",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoSpawnBoss",
    Save = true,
    Callback = function(Value)
        Config.Bosses.AutoSpawn = Value
        if Value then
            task.spawn(bossSpawnerLoop)
        end
    end
})

BossMainSection:AddDropdown({
    Name = "DIFFICULTY",
    Default = "Normal",
    Options = {"Normal", "Medium", "Hard", "Extreme"},
    Multi = false,
    Outline = true,
    Flag = "BossDifficulty",
    Save = true,
    Callback = function(Value) Config.Bosses.Difficulty = Value end
})

BossMainSection:AddDropdown({
    Name = "SELECT BOSSES (MULTI)",
    Default = {},
    Options = {"Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden", "SaberAlter"},
    Multi = true,
    Search = true,
    Outline = true,
    Flag = "SelectedBosses",
    Save = true,
    Callback = function(Value) Config.Bosses.Selected = Value end
})

local SpecialBossSection = BossTab:AddSection({
    Name = "⭐ SPECIAL BOSSES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local specialBosses = {"TrueAizen", "Sukuna", "Gojo", "Rimuru", "Anos"}
for _, boss in ipairs(specialBosses) do
    SpecialBossSection:AddToggle({
        Name = "AUTO SPAWN " .. boss:upper(),
        Default = false,
        Color = Color3.fromRGB(65, 105, 225),
        Outline = true,
        Flag = "Special_" .. boss,
        Save = true,
        Callback = function(Value) Config.Bosses.Specials[boss].Auto = Value end
    })
    
    SpecialBossSection:AddDropdown({
        Name = boss .. " DIFFICULTY",
        Default = "Normal",
        Options = {"Normal", "Medium", "Hard", "Extreme"},
        Multi = false,
        Outline = true,
        Flag = "SpecialDiff_" .. boss,
        Save = true,
        Callback = function(Value) Config.Bosses.Specials[boss].Diff = Value end
    })
end

--==================================================
-- ENTITIES TAB
--==================================================
local EntitySection = EntityTab:AddSection({
    Name = "🎯 ENTITY TARGETING",
    TextSize = 18,
    Glass = true,
    Outline = true
})

local entityCategories = {
    { Name = "NPCs", List = {"Hollow", "Quincy", "Swordsman", "AcademyTeacher", "Slime", "StrongSorcerer", "Curse"} },
    { Name = "Timed Bosses", List = {"Gojo", "Yuji", "Sukuna", "Jinwoo", "Alucard", "Aizen", "Yamato"} },
    { Name = "Summon Bosses", List = {"Saber", "Ichigo", "QinShi", "Gilgamesh", "BlessedMaiden", "SaberAlter", "StrongestinHistory", "StrongestofToday", "Rimuru", "Anos", "TrueAizen"} }
}

for _, category in ipairs(entityCategories) do
    EntityTab:AddSection({
        Name = category.Name,
        TextSize = 16,
        Glass = true,
        Outline = true
    })
    
    for _, entityName in ipairs(category.List) do
        EntityTab:AddToggle({
            Name = "FARM " .. entityName,
            Default = true,
            Color = Color3.fromRGB(65, 105, 225),
            Outline = true,
            Flag = "Entity_" .. entityName,
            Save = true,
            Callback = function(Value) Config.Entities[entityName] = Value end
        })
    end
end

--==================================================
-- CRAFTING TAB
--==================================================
local CraftSection = CraftTab:AddSection({
    Name = "🔨 CRAFTING",
    TextSize = 18,
    Glass = true,
    Outline = true
})

CraftSection:AddToggle({
    Name = "AUTO CRAFT SLIME KEY",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoSlimeKey",
    Save = true,
    Callback = function(Value) Config.Misc.AutoCraftSlimeKey = Value end
})

CraftSection:AddToggle({
    Name = "AUTO CRAFT DIVINE GRAIL",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDivineGrail",
    Save = true,
    Callback = function(Value) Config.Misc.AutoCraftDivineGrail = Value end
})

CraftSection:AddButton({
    Name = "🔨 CRAFT SLIME KEY (1x)",
    Icon = "hammer",
    Outline = true,
    Callback = function()
        if slimeCraftRemote then
            safeCall(function() slimeCraftRemote:InvokeServer("SlimeKey", 1) end)
            Notify("Crafted 1x Slime Key")
        end
    end
})

CraftSection:AddButton({
    Name = "🔨 CRAFT DIVINE GRAIL (1x)",
    Icon = "hammer",
    Outline = true,
    Callback = function()
        if grailCraftRemote then
            safeCall(function() grailCraftRemote:InvokeServer("DivineGrail", 1) end)
            Notify("Crafted 1x Divine Grail")
        end
    end
})

-- Auto craft loop
task.spawn(function()
    while true do
        task.wait(10)
        if Config.Misc.AutoCraftSlimeKey and slimeCraftRemote then
            safeCall(function() slimeCraftRemote:InvokeServer("SlimeKey", 1) end)
        end
        if Config.Misc.AutoCraftDivineGrail and grailCraftRemote then
            safeCall(function() grailCraftRemote:InvokeServer("DivineGrail", 1) end)
        end
    end
end)

--==================================================
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({
    Name = "⚙️ UTILITY FEATURES",
    TextSize = 18,
    Glass = true,
    Outline = true
})

MiscSection:AddToggle({
    Name = "ANTI AFK",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.Misc.AntiAFK = Value
        if Value then
            _G.AntiAFKConn = Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        elseif _G.AntiAFKConn then
            _G.AntiAFKConn:Disconnect()
            _G.AntiAFKConn = nil
        end
    end
})

MiscSection:AddToggle({
    Name = "FPS BOOST (BLACK SCREEN)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FpsBoost",
    Save = true,
    Callback = function(Value)
        Config.Misc.FpsBoost = Value
        if Value then
            Lighting.Brightness = 0
            Lighting.GlobalShadows = false
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
            end
        end
    end
})

MiscSection:AddToggle({
    Name = "WHITE SCREEN MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "WhiteScreen",
    Save = true,
    Callback = function(Value)
        Config.Misc.WhiteScreen = Value
        RunService:Set3dRenderingEnabled(not Value)
    end
})

MiscSection:AddToggle({
    Name = "AUTO REJOIN ON DISCONNECT",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value) Config.Misc.AutoRejoin = Value end
})

MiscSection:AddToggle({
    Name = "TIMED AUTO REJOIN",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "TimedRejoin",
    Save = true,
    Callback = function(Value) Config.Misc.TimedRejoin = Value end
})

MiscSection:AddSlider({
    Name = "REJOIN DELAY (MINUTES)",
    Min = 1,
    Max = 120,
    Default = 10,
    Increment = 1,
    ValueName = "min",
    Outline = true,
    Flag = "RejoinDelay",
    Save = true,
    Callback = function(Value) Config.Misc.RejoinDelay = Value end
})

MiscSection:AddToggle({
    Name = "FRIEND ONLY MODE",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FriendOnly",
    Save = true,
    Callback = function(Value) Config.Misc.FriendOnly = Value end
})

MiscSection:AddToggle({
    Name = "AUTO BUY BOSS KEY",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoBuyBossKey",
    Save = true,
    Callback = function(Value) Config.Misc.AutoBuyBossKey = Value end
})

MiscSection:AddToggle({
    Name = "EXCHANGE ICHIGO",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ExchangeIchigo",
    Save = true,
    Callback = function(Value) Config.Misc.ExchangeIchigo = Value end
})

MiscSection:AddToggle({
    Name = "FARM SABER BOSS",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FarmSaberBoss",
    Save = true,
    Callback = function(Value) 
        Config.Misc.FarmSaberBoss = Value
        if Value then
            task.spawn(farmSaberBoss)
        end
    end
})

--==================================================
-- TIMED REJOIN HANDLER
--==================================================
local timedRejoinRunning = false
task.spawn(function()
    while true do
        task.wait(1)
        if not Config.Misc.TimedRejoin then
            timedRejoinRunning = false
            continue
        end
        
        if not timedRejoinRunning then
            timedRejoinRunning = true
            task.spawn(function()
                local elapsed = 0
                while timedRejoinRunning and Config.Misc.TimedRejoin do
                    task.wait(1)
                    elapsed = elapsed + 1
                    local target = Config.Misc.RejoinDelay * 60
                    if elapsed >= target then
                        elapsed = 0
                        Notify("Timed rejoin executing...", 3)
                        task.wait(3)
                        for _ = 1, 10 do
                            if pcall(function() TeleportService:Teleport(game.PlaceId, Player) end) then
                                break
                            end
                            task.wait(10)
                        end
                    end
                end
            end)
        end
    end
end)

--==================================================
-- AUTO REJOIN HANDLER
--==================================================
local GuiService = game:GetService("GuiService")
GuiService.ErrorMessageChanged:Connect(function()
    if Config.Misc.AutoRejoin then
        local lastError = GuiService:GetErrorMessage()
        if not lastError:find("Security") then
            task.spawn(function()
                task.wait(5)
                for _ = 1, 10 do
                    if pcall(function() TeleportService:Teleport(game.PlaceId, Player) end) then
                        break
                    end
                    task.wait(10)
                end
            end)
        end
    end
end)

--==================================================
-- FRIEND ONLY MODE
--==================================================
local function checkFriend(player)
    if not Config.Misc.FriendOnly or player == Player then return end
    
    local isFriend = false
    pcall(function() isFriend = Player:IsFriendsWith(player.UserId) end)
    
    if not isFriend then
        Player:Kick("\n[Security]\nStranger Detected: " .. player.Name)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    checkFriend(player)
end

Players.PlayerAdded:Connect(checkFriend)

--==================================================
-- HEARTBEAT PHYSICS LOCK
--==================================================
RunService.Heartbeat:Connect(function()
    if Player.Character then
        for _, v in pairs(Player.Character:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.AssemblyLinearVelocity = Vector3.zero
                v.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end)

--==================================================
-- INITIALIZE
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "settings"
})

OrionLib:Init()

Notify("Press F4 or click floating button to toggle menu")

print("═══════════════════════════════════════════════════════")
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE v2.0 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm System - COMPLETE")
print("✅ Haki Quest + Dark Blade - FIXED")
print("✅ Fruit Farm System - FIXED")
print("✅ Boss Spawner (Multi-select) - FIXED")
print("✅ Saber Boss Farm - FIXED")
print("✅ Entity Targeting - COMPLETE")
print("✅ Crafting System - FIXED")
print("✅ Misc Utilities - COMPLETE")
print("═══════════════════════════════════════════════════════")