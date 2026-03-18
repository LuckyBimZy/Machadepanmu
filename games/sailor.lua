-- ==================== SAILOR PIECE - CATRAZ ULTIMATE ====================
-- Premium UI menggunakan Catraz Hub Library
-- Version: 1.0 ULTIMATE

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

-- Remote References
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local CombatRemotes = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes")
local AbilityRemote = ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")

local hitRemote = CombatRemotes:WaitForChild("RequestHit")
local questRemote = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")
local hakiRemote = RemoteEvents:WaitForChild("HakiRemote")
local obsHakiRemote = RemoteEvents:WaitForChild("ObservationHakiRemote")
local summonBossRemote = Remotes:WaitForChild("RequestSummonBoss")
local spawnStrongestRemote = Remotes:WaitForChild("RequestSpawnStrongestBoss")
local anosRemote = Remotes:WaitForChild("RequestSpawnAnosBoss")
local trueAizenRemote = RemoteEvents:WaitForChild("RequestSpawnTrueAizen")
local rimuruRemote = RemoteEvents:WaitForChild("RequestSpawnRimuru")

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
        SkillZ = false,
        SkillX = false,
        SkillC = false,
        SkillV = false,
        SkillF = false
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
        Hollow = true,
        Quincy = true,
        Swordsman = true,
        AcademyTeacher = true,
        Slime = true,
        StrongSorcerer = true,
        Curse = true,
        Gojo = true,
        Yuji = true,
        Sukuna = true,
        Jinwoo = true,
        Alucard = true,
        Aizen = true,
        Yamato = true,
        Saber = true,
        Ichigo = true,
        QinShi = true,
        Gilgamesh = true,
        BlessedMaiden = true,
        SaberAlter = true,
        StrongestinHistory = true,
        StrongestofToday = true,
        Rimuru = true,
        Anos = true,
        TrueAizen = true
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
        BossKeyBuyInterval = 1800,
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
    Subtext = "Catraz Ultimate Edition",
    Version = "v1.0",
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
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    return char, hrp, hum
end

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function getBestWeapon()
    local weapons = {}
    for _, container in pairs({Player.Backpack, Player.Character}) do
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
    return #weapons > 0 and weapons[1].name or "Combat"
end

local function getWeaponList()
    local weapons = {"None", "Combat"}
    for _, container in pairs({Player.Backpack, Player.Character}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name ~= "Combat" then
                    table.insert(weapons, tool.Name)
                end
            end
        end
    end
    local unique = {}
    for _, v in ipairs(weapons) do
        if not table.find(unique, v) then
            table.insert(unique, v)
        end
    end
    return unique
end

local function buildPortalMap()
    local map = {}
    for _, folder in ipairs(Workspace:GetChildren()) do
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

local function smartTP(pos)
    local targetPos = CFrame.new(pos)
    local island = getNearestIsland(targetPos.Position)
    if not island then 
        print("[SmartTP] No portal found!")
        return 
    end
    tpRemote:FireServer(island)
    task.wait(0.5)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = targetPos end
end

local function tweenPos(targetCF, callback)
    local char = Player.Character
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
    else
        smartTP(targetCF.Position)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if callback then callback() end
    end
end

--==================================================
-- DARK BLADE FUNCTIONS
--==================================================

local function findDarkBladeInHand()
    for _, container in pairs({Player.Character, Player.Backpack}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                local isDarkBlade = tool:IsA("Tool") and (
                    tool.Name:find("Dark Blade") or 
                    tool.Name:find("ดาบสีเข้ม") or 
                    (tool.ToolTip and (tool.ToolTip:find("Black Blade") or tool.ToolTip:find("ดาบสีเข้ม")))
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
        ReplicatedStorage.Remotes.UpdateInventory.OnClientEvent:Connect(function(tab, data)
            for _, item in pairs(data) do
                if item.name == targetName or item.name == "ดาบสีเข้ม" or item.name:find("Dark Blade") then
                    result = true
                end
            end
        end)
        ReplicatedStorage.Remotes.RequestInventory:FireServer()
    end)
    task.wait(0.5)
    return result
end

local function equipDarkBladeFromInventory()
    pcall(function()
        Remotes:WaitForChild("EquipWeapon"):FireServer("Equip", "Dark Blade")
    end)
    task.wait(1)
    if not findDarkBladeInHand() then
        pcall(function()
            Remotes:WaitForChild("EquipWeapon"):FireServer("Equip", "ดาบสีเข้ม")
        end)
        task.wait(1)
    end
    return findDarkBladeInHand() ~= nil
end

local function checkHakiStatus()
    local hasHaki = false
    local hakiInfo = ""
    pcall(function()
        local statsUI = Player.PlayerGui:FindFirstChild("StatsPanelUI")
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

--==================================================
-- INVENTORY TRACKER
--==================================================
task.spawn(function()
    local updateInventory = Remotes:WaitForChild("UpdateInventory")
    local requestInventory = Remotes:WaitForChild("RequestInventory")
    
    updateInventory.OnClientEvent:Connect(function(category, items)
        if not items then return end
        
        for _, item in pairs(items) do
            local name = item.name
            local qty = item.quantity or 1
            if not name then continue end

            if name:lower():find("crate") or name:lower():find("box") or name:lower():find("chest") then
                cratesAndBoxes[name] = qty
            end
        end
    end)

    task.wait(3)
    pcall(function() requestInventory:FireServer() end)
end)

--==================================================
-- AUTO FARM SYSTEM
--==================================================

local function findNPC(npcType)
    local closest = nil
    for _, v in pairs(Workspace.NPCs:GetChildren()) do
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

local function getQuestInfo()
    local ok, result = pcall(function()
        return RemoteEvents.GetQuestArrowTarget:InvokeServer()
    end)
    return ok and result or nil
end

local function getNpcType(npcName)
    local ok, result = pcall(function()
        local module = require(ReplicatedStorage.Modules.QuestConfig)
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

local function selectWeapon()
    local blade = findDarkBladeInHand()
    if blade then return "Dark Blade" end
    if equipDarkBladeFromInventory() then return "Dark Blade" end
    return Config.AutoFarm.SelectedWeapon ~= "None" and Config.AutoFarm.SelectedWeapon or getBestWeapon()
end

local function equipToolByName(toolName, char)
    local tool = nil
    if toolName == "Dark Blade" then
        tool = findDarkBladeInHand()
    else
        tool = Player.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
    end
    if tool and tool.Parent == Player.Backpack and char and char:FindFirstChild("Humanoid") then
        char.Humanoid:EquipTool(tool)
    end
    return tool
end

local function farmLoop()
    while Config.AutoFarm.Enabled do
        task.wait()
        
        if isHakiQuestActive or isBuyingDarkBlade or isFruitFarming or isFarmingIchigoBoss then
            task.wait(10)
            continue
        end

        local char, hrp, hum = getChar()
        if hum.Health <= 0 then continue end

        local questInfo = getQuestInfo()
        if not questInfo then continue end

        local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
        if not questUI then continue end

        if not questUI.Quest.Visible then
            smartTP(questInfo.position)
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

            while Config.AutoFarm.Enabled do
                if hum.Health <= 0 then break end
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
                box.Parent = Workspace

                local skillIndex = 1

                repeat task.wait()
                    if not closest or not closest.Parent or not closest:FindFirstChild("HumanoidRootPart") or closest.Humanoid.Health <= 0 then
                        break
                    end

                    equipToolByName(toolName, char)

                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = Vector3.zero
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bv.Parent = hrp

                    local success, owner = pcall(function()
                        return closest.HumanoidRootPart:GetNetworkOwner()
                    end)
                    if success and owner == Player then
                        closest.HumanoidRootPart.CFrame = CFrame.new(closest.HumanoidRootPart.Position)
                        closest.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        closest.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                    end

                    tweenPos(CFrame.new(closest.HumanoidRootPart.Position + Vector3.new(0, YPOS, 0)) * CFrame.Angles(math.rad(-90), 0, 0),
                        function() hitRemote:FireServer() end
                    )

                    if Config.AutoFarm.AutoHaki then
                        pcall(function() hakiRemote:FireServer("Toggle") end)
                    end
                    if Config.AutoFarm.AutoObsHaki then
                        pcall(function() obsHakiRemote:FireServer("Toggle") end)
                    end

                    if Config.AutoFarm.SkillZ then pcall(function() AbilityRemote:FireServer(1) end) end
                    if Config.AutoFarm.SkillX then pcall(function() AbilityRemote:FireServer(2) end) end
                    if Config.AutoFarm.SkillC then pcall(function() AbilityRemote:FireServer(3) end) end
                    if Config.AutoFarm.SkillV then pcall(function() AbilityRemote:FireServer(4) end) end
                    if Config.AutoFarm.SkillF then pcall(function() AbilityRemote:FireServer(5) end) end
                    
                    hitRemote:FireServer()
                    
                until hum.Health <= 0 or not questUI.Quest.Visible or questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text ~= questInfo.questTitle

                box:Destroy()
                equipToolByName(toolName, char)
                task.wait(0.3)
            end
        end
    end
end

--==================================================
-- HAKI QUEST SYSTEM
--==================================================

local function acceptHakiQuest()
    print("[HAKI QUEST] Accepting quest...")
    local hakiPos = Vector3.new(-497.94, 23.66, -1252.64)

    pcall(function()
        local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
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

    local char = Player.Character

    for i = 1, 5 do
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
            return true
        end
    end
    return false
end

local function farmThiefForHaki()
    print("[HAKI QUEST] Starting Haki farm...")
    local targetNPC = "Thief"
    local killCount = 0
    local lastCheckKills = 0

    pcall(function()
        local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
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
        if tick() - farmStart > Config.HakiQuest.Timeout then
            isHakiQuestActive = false
            break
        end

        local char, hrp, hum = getChar()
        if hum.Health <= 0 then continue end

        local shouldGoToNPC = false
        local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
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
            lastCheckKills = killCount

            if goToHakiNPC() then
                if Config.HakiQuest.BuyDarkBlade then
                    isHakiQuestActive = false
                end
                return
            end

            pcall(function()
                local q = Player.PlayerGui:FindFirstChild("QuestUI")
                if q and q:FindFirstChild("Quest") and q.Quest.Visible then
                    local desc = q.Quest.Quest.Holder.Content.QuestInfo.QuestDescription.Text
                    local name = desc:match("Defeat the (%w+)") or desc:match("defeat (%w+)")
                    if name then targetNPC = name end
                end
            end)

            pcall(function() tpRemote:FireServer("Starter") end)
            task.wait(3)
            continue
        end

        local npcFound = false
        for i = 1, 5 do
            local npc = Workspace.NPCs:FindFirstChild(targetNPC .. i)
            if npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                npcFound = true
                local target = npc:FindFirstChild("HumanoidRootPart")
                if target then
                    while npc.Parent and npc.Humanoid.Health > 0 do
                        if not char or not hrp then break end
                        if hum.Health <= 0 then break end
                        pcall(function() hrp.CFrame = target.CFrame * CFrame.new(0, 0, 5) end)
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
    if not Config.HakiQuest.Enabled then return end
    isHakiQuestActive = true
    pcall(acceptHakiQuest)
    pcall(farmThiefForHaki)
    isHakiQuestActive = false
end

--==================================================
-- FRUIT FARM SYSTEM
--==================================================

local function checkHasFruit(fruitName)
    local char = Player.Character
    local backpack = Player:FindFirstChild("Backpack")
    
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                return true
            end
        end
    end
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                return true
            end
        end
    end
    
    return false
end

local function equipFruit(fruitName)
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                local char = Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:EquipTool(tool)
                    task.wait(1)
                    return true
                end
            end
        end
    end
    pcall(function()
        ReplicatedStorage.Remotes.EquipWeapon:FireServer("Equip", fruitName)
    end)
    task.wait(1)
    return checkHasFruit(fruitName)
end

local function buyRandomFruit()
    local npcCF = CFrame.new(400.641937, 2.79983521, 752.175842)
    tweenPos(npcCF)
    task.wait(3)
    
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = npcCF * CFrame.new(0, 0, -3)
    end
    task.wait(1)
    
    local prompt = nil
    pcall(function()
        local npc = Workspace.ServiceNPCs.GemFruitDealer
        for _, desc in pairs(npc:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                prompt = desc
                break
            end
        end
    end)
    
    if not prompt then return false end
    
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(3)
    return true
end

local function getAnyFruitFromBackpack()
    local backpack = Player:FindFirstChild("Backpack")
    local char = Player.Character
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                return tool
            end
        end
    end
    
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                return tool
            end
        end
    end
    
    return nil
end

local function eatFruit(fruitTool)
    if not fruitTool then return end
    
    local fruitName = fruitTool.Name
    local char = Player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    local backpack = Player:FindFirstChild("Backpack")
    
    if humanoid and fruitTool.Parent == backpack then
        humanoid:EquipTool(fruitTool)
        task.wait(0.5)
    end
    
    pcall(function() fruitTool:Activate() end)
    task.wait(1)
    
    local confirmUI = Player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then yesButton = yesButton:FindFirstChild("ButtonsHolder") end
        if yesButton then yesButton = yesButton:FindFirstChild("Yes") end
        if yesButton then
            pcall(function()
                for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end)
        end
    else
        pcall(function()
            RemoteEvents:WaitForChild("FruitAction"):FireServer("eat", fruitName)
        end)
    end
    
    task.wait(3)
end

local function fruitFarmLoop()
    print("[FRUIT FARM] Starting AFK Fruit Farm Loop...")
    local keyCodes = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
    
    while Config.FruitFarm.Enabled and isFruitFarming do
        task.wait(0.5)
        
        local char, hrp, hum = getChar()
        if hum.Health <= 0 then continue end
        
        local lockPos = Config.FruitFarm.Position
        if (hrp.Position - lockPos.Position).Magnitude > 5 then
            hrp.CFrame = lockPos
        end
        
        equipFruit(Config.FruitFarm.TargetFruit)
        
        pcall(function() hakiRemote:FireServer("Toggle") end)
        pcall(function() obsHakiRemote:FireServer("Toggle") end)
        
        for i, keyCode in ipairs(keyCodes) do
            pcall(function()
                local args = {
                    "UseAbility",
                    {
                        TargetPosition = hrp.Position,
                        FruitPower = Config.FruitFarm.TargetFruit,
                        KeyCode = keyCode
                    }
                }
                RemoteEvents:WaitForChild("FruitPowerRemote"):FireServer(unpack(args))
            end)
            task.wait(0.3)
        end
        task.wait(1.5)
    end
end

local function startFruitFarm()
    isFruitFarming = true
    local targetFruit = Config.FruitFarm.TargetFruit
    
    if checkHasFruit(targetFruit) then
        local fruitTool = getAnyFruitFromBackpack()
        if fruitTool then
            eatFruit(fruitTool)
            task.wait(2)
        end
        equipFruit(targetFruit)
        
        pcall(function() tpRemote:FireServer(Config.FruitFarm.Island) end)
        task.wait(3)
        
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for i = 1, 10 do
                char.HumanoidRootPart.CFrame = Config.FruitFarm.Position
                task.wait(0.1)
            end
        end
        
        task.spawn(fruitFarmLoop)
        return true
    end
    
    local currentPower = 0
    pcall(function() currentPower = Player.Data.Power.Value or 0 end)
    
    if currentPower < 11500 then
        pcall(function() RemoteEvents:WaitForChild("ResetStats"):FireServer() end)
        task.wait(3)
    end
    
    local maxAttempts = 100
    local gotTarget = false
    
    while maxAttempts > 0 and not gotTarget do
        maxAttempts = maxAttempts - 1
        pcall(buyRandomFruit)
        task.wait(3)
        
        local fruitTool = getAnyFruitFromBackpack()
        if fruitTool then
            local isTargetFruit = fruitTool.Name:find(targetFruit) ~= nil
            if isTargetFruit then
                eatFruit(fruitTool)
                task.wait(2)
                gotTarget = true
            else
                eatFruit(fruitTool)
                task.wait(2)
            end
        end
    end
    
    if checkHasFruit(targetFruit) then
        equipFruit(targetFruit)
        
        pcall(function() tpRemote:FireServer(Config.FruitFarm.Island) end)
        task.wait(3)
        
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for i = 1, 10 do
                char.HumanoidRootPart.CFrame = Config.FruitFarm.Position
                task.wait(0.1)
            end
        end
        
        task.spawn(fruitFarmLoop)
        return true
    else
        isFruitFarming = false
        return false
    end
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
    Desc = "Display Name: " .. Player.DisplayName .. "\n" ..
           "User ID: " .. Player.UserId .. "\n" ..
           "Account Age: " .. Player.AccountAge .. " days",
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

local function UpdateServerInfo()
    local players = Players:GetPlayers()
    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 100) / 100
    
    return "Players: " .. #players .. "/" .. (Players.MaxPlayers or "??") .. "\n" ..
           "Ping: " .. ping .. "ms\n" ..
           "Uptime: " .. getUptime()
end

local ServerInfoPara = ServerInfoSection:AddParagraph({
    Title = "Server Status",
    Desc = UpdateServerInfo(),
    Image = "server",
    ImageSize = 48,
    Buttons = {
        {
            Title = "🔄 Refresh",
            Callback = function()
                ServerInfoPara:SetDesc(UpdateServerInfo())
            end
        }
    }
})

task.spawn(function()
    while true do
        task.wait(1)
        ServerInfoPara:SetDesc(UpdateServerInfo())
        
        local level = 0
        local money = 0
        local gems = 0
        pcall(function() 
            level = Player.Data.Level.Value or 0
            money = Player.Data.Money.Value or 0
            gems = Player.Data.Gems.Value or 0
        end)
        
        playerInfoPara:SetDesc("Display Name: " .. Player.DisplayName .. "\n" ..
                               "Level: " .. level .. "\n" ..
                               "Money: " .. formatNumber(money) .. "\n" ..
                               "Gems: " .. formatNumber(gems) .. "\n" ..
                               "Account Age: " .. Player.AccountAge .. " days")
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
    Callback = function(Value) Config.AutoFarm.SkillZ = Value end
})

SkillSection:AddToggle({
    Name = "USE SKILL X",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillX",
    Save = true,
    Callback = function(Value) Config.AutoFarm.SkillX = Value end
})

SkillSection:AddToggle({
    Name = "USE SKILL C",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillC",
    Save = true,
    Callback = function(Value) Config.AutoFarm.SkillC = Value end
})

SkillSection:AddToggle({
    Name = "USE SKILL V",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillV",
    Save = true,
    Callback = function(Value) Config.AutoFarm.SkillV = Value end
})

SkillSection:AddToggle({
    Name = "USE SKILL F",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SkillF",
    Save = true,
    Callback = function(Value) Config.AutoFarm.SkillF = Value end
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

HakiSection:AddParagraph({
    Title = "DARK BLADE REQUIREMENTS",
    Desc = "Gems: " .. Config.HakiQuest.DarkBladeGems .. "\nMoney: " .. formatNumber(Config.HakiQuest.DarkBladeMoney),
    Image = "info",
    ImageSize = 38
})

HakiSection:AddButton({
    Name = "🔄 CHECK HAKI STATUS",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local hasHaki, info = checkHakiStatus()
        Notify(hasHaki and "✅ You have Haki! " .. info or "❌ You don't have Haki yet")
    end
})

HakiSection:AddButton({
    Name = "🗡️ CHECK DARK BLADE",
    Icon = "shield",
    Outline = true,
    Callback = function()
        local hasBlade = findDarkBladeInHand() ~= nil
        Notify(hasBlade and "✅ Dark Blade equipped!" or "❌ Dark Blade not found")
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
            task.spawn(startFruitFarm)
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
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            Config.FruitFarm.Position = CFrame.new(char.HumanoidRootPart.Position)
            Notify("Farm position saved!")
        end
    end
})

FruitSection:AddButton({
    Name = "🍎 CHECK TARGET FRUIT",
    Icon = "search",
    Outline = true,
    Callback = function()
        local hasFruit = checkHasFruit(Config.FruitFarm.TargetFruit)
        Notify(hasFruit and "✅ You have " .. Config.FruitFarm.TargetFruit or "❌ You don't have " .. Config.FruitFarm.TargetFruit)
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
    Callback = function(Value) Config.Bosses.AutoSpawn = Value end
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
        pcall(function()
            Remotes:WaitForChild("RequestSlimeCraft"):InvokeServer("SlimeKey", 1)
            Notify("Crafted 1x Slime Key")
        end)
    end
})

CraftSection:AddButton({
    Name = "🔨 CRAFT DIVINE GRAIL (1x)",
    Icon = "hammer",
    Outline = true,
    Callback = function()
        pcall(function()
            Remotes:WaitForChild("RequestGrailCraft"):InvokeServer("DivineGrail", 1)
            Notify("Crafted 1x Divine Grail")
        end)
    end
})

-- Auto craft loop
task.spawn(function()
    while true do
        task.wait(5)
        if Config.Misc.AutoCraftSlimeKey then
            pcall(function() Remotes:WaitForChild("RequestSlimeCraft"):InvokeServer("SlimeKey", 1) end)
        end
        if Config.Misc.AutoCraftDivineGrail then
            pcall(function() Remotes:WaitForChild("RequestGrailCraft"):InvokeServer("DivineGrail", 1) end)
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
            local conn = Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            _G.AntiAFKConn = conn
        else
            if _G.AntiAFKConn then
                _G.AntiAFKConn:Disconnect()
                _G.AntiAFKConn = nil
            end
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
    Callback = function(Value) Config.Misc.FarmSaberBoss = Value end
})

MiscSection:AddSlider({
    Name = "ICHIGO MIN LEVEL",
    Min = 5000,
    Max = 20000,
    Default = 11500,
    Increment = 100,
    ValueName = "lvl",
    Outline = true,
    Flag = "IchigoMinLevel",
    Save = true,
    Callback = function(Value) Config.Misc.IchigoMinLevel = Value end
})

MiscSection:AddButton({
    Name = "📦 SHOW INVENTORY (F1)",
    Icon = "package",
    Outline = true,
    Callback = function()
        local data = Player:FindFirstChild("Data")
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
        print("========================================\n")
    end
})

--==================================================
-- AUTO REJOIN HANDLER
--==================================================
local function handleAutoRejoin()
    local GuiService = game:GetService("GuiService")
    local conn = GuiService.ErrorMessageChanged:Connect(function()
        if not Config.Misc.AutoRejoin then return end
        
        local lastError = GuiService:GetErrorMessage()
        if lastError:find("ArcX Security") then return end
        
        task.spawn(function()
            while task.wait(5) do
                if pcall(function() TeleportService:Teleport(game.PlaceId, Player) end) then
                    break
                end
                task.wait(10)
            end
        end)
    end)
    _G.AutoRejoinConn = conn
end

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
-- FRIEND ONLY MODE HANDLER
--==================================================
local function checkAndKick(player)
    if not Config.Misc.FriendOnly or player == Player then return end
    
    local isFriend = false
    pcall(function() isFriend = Player:IsFriendsWith(player.UserId) end)
    
    if not isFriend then
        Player:Kick("\n[Security]\nStranger Detected: " .. player.Name)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    checkAndKick(player)
end

Players.PlayerAdded:Connect(checkAndKick)

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
print("🔥 SAILOR PIECE - CATRAZ ULTIMATE EDITION 🔥")
print("═══════════════════════════════════════════════════════")
print("✅ Auto Farm System - Complete")
print("✅ Haki Quest + Dark Blade")
print("✅ Fruit Farm System")
print("✅ Boss Spawner (Multi-select)")
print("✅ Entity Targeting")
print("✅ Crafting System")
print("✅ Misc Utilities")
print("═══════════════════════════════════════════════════════")