-- ═══════════════════════════════════════════════════════════════
-- LOAD LIBRARY & INITIALIZE UI
-- ═══════════════════════════════════════════════════════════════
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()
local Window = OrionLib:MakeWindow({
    Name = "Sailor Piece Auto Farm",
    Subtext = "Premium Auto Farm Script",
    Version = "v2.0.0",
    VersionIcon = "sword",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SailorPieceConfig",
    IntroEnabled = true,
    IntroText = "Loading Auto Farm...",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.1,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set theme (Ocean looks great for this)
OrionLib.SelectedTheme = "Ocean"

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & VARIABLES
-- ═══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- STATE VARIABLES
local selectedMob = nil
local autoFarmEnabled = false
local autoEquipEnabled = false
local selectedWeapon = nil
local tweenSpeed = 100
local farmDistance = 5
local farmMode = "Behind"

-- Mob to Quest NPC mapping
local mobQuestMap = {
    ["Thief"] = "QuestNPC1",
    ["ThiefBoss"] = "QuestNPC2",
    ["Monkey"] = "QuestNPC3",
    ["MonkeyBoss"] = "QuestNPC4",
    ["DesertBandit"] = "QuestNPC5",
    ["DesertBoss"] = "QuestNPC6",
    ["FrostRogue"] = "QuestNPC7",
    ["SnowBoss"] = "QuestNPC8",
    ["Sorcerer"] = "QuestNPC9",
    ["PandaMiniBoss"] = "QuestNPC10",
    ["Hollow"] = "QuestNPC11",
    ["StrongSorcerer"] = "QuestNPC12",
    ["Curse"] = "QuestNPC13",
    ["SlimeWarrior"] = "QuestNPC14",
    ["AcademyTeacher"] = "QuestNPC15",
    ["Swordsman"] = "QuestNPC16",
    ["Quincy"] = "QuestNPC17"
}

-- ═══════════════════════════════════════════════════════════════
-- CREATE TABS
-- ═══════════════════════════════════════════════════════════════

-- Main Auto Farm Tab
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "swords",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

-- Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

-- Stats Tab
local StatsTab = Window:MakeTab({
    Name = "Stats",
    Icon = "bar-chart-2",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

-- Info Tab
local InfoTab = Window:MakeTab({
    Name = "Info",
    Icon = "info",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

-- ═══════════════════════════════════════════════════════════════
-- AUTO FARM SECTION
-- ═══════════════════════════════════════════════════════════════
local FarmSection = FarmTab:AddSection({
    Name = "Farming Controls",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Mob Dropdown
local mobDropdown = FarmSection:AddDropdown({
    Name = "Select Mob to Farm",
    Default = "Thief",
    Options = {
        "Thief", "ThiefBoss", "Monkey", "MonkeyBoss",
        "DesertBandit", "DesertBoss", "FrostRogue", "SnowBoss",
        "Sorcerer", "PandaMiniBoss", "Hollow", "StrongSorcerer",
        "Curse", "SlimeWarrior", "AcademyTeacher", "Swordsman", "Quincy"
    },
    Multi = false,
    Search = true,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        selectedMob = Value
        OrionLib:MakeNotification({
            Name = "Mob Selected",
            Content = "Now farming: " .. Value,
            Image = "target",
            Time = 2
        })
    end
})

-- Auto Farm Toggle
local autoFarmToggle = FarmSection:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoFarmFlag",
    Save = true,
    Callback = function(Value)
        autoFarmEnabled = Value
        if Value then
            OrionLib:MakeNotification({
                Name = "Auto Farm",
                Content = "Auto farm ENABLED",
                Image = "play",
                Time = 2
            })
        else
            OrionLib:MakeNotification({
                Name = "Auto Farm",
                Content = "Auto farm DISABLED",
                Image = "square",
                Time = 2
            })
        end
    end
})

-- Farm Mode Dropdown
FarmSection:AddDropdown({
    Name = "Farm Position",
    Default = "Behind",
    Options = {"Behind", "Above"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        farmMode = Value
        OrionLib:MakeNotification({
            Name = "Farm Mode",
            Content = "Mode set to: " .. Value,
            Image = "map-pin",
            Time = 2
        })
    end
})

-- ═══════════════════════════════════════════════════════════════
-- WEAPON SECTION
-- ═══════════════════════════════════════════════════════════════
local WeaponSection = FarmTab:AddSection({
    Name = "Weapon Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Function to get weapons
local function getWeaponList()
    local weapons = {}
    local backpack = Player.Backpack
    local character = Player.Character
    
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(weapons, item.Name)
        end
    end
    
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") then
                if not table.find(weapons, item.Name) then
                    table.insert(weapons, item.Name)
                end
            end
        end
    end
    
    return weapons
end

-- Weapon Dropdown
local weaponDropdown = WeaponSection:AddDropdown({
    Name = "Select Weapon",
    Default = "None",
    Options = getWeaponList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Callback = function(Value)
        selectedWeapon = Value
        if Value and Value ~= "None" then
            local tool = Player.Backpack:FindFirstChild(Value)
            local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if tool and humanoid then
                humanoid:EquipTool(tool)
                OrionLib:MakeNotification({
                    Name = "Weapon Equipped",
                    Content = "Equipped: " .. Value,
                    Image = "sword",
                    Time = 2
                })
            end
        end
    end
})

-- Auto Equip Toggle
local autoEquipToggle = WeaponSection:AddToggle({
    Name = "Auto Equip Weapon",
    Default = false,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AutoEquipFlag",
    Save = true,
    Callback = function(Value)
        autoEquipEnabled = Value
        if Value and selectedWeapon and selectedWeapon ~= "None" then
            local tool = Player.Backpack:FindFirstChild(selectedWeapon)
            local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if tool and humanoid then
                humanoid:EquipTool(tool)
            end
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
-- SETTINGS SECTION
-- ═══════════════════════════════════════════════════════════════
local MovementSection = SettingsTab:AddSection({
    Name = "Movement Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Tween Speed Slider
MovementSection:AddSlider({
    Name = "Movement Speed",
    Min = 50,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(0, 150, 255),
    Increment = 10,
    ValueName = "Speed",
    Outline = true,
    Callback = function(Value)
        tweenSpeed = Value
    end
})

-- Farm Distance Slider
MovementSection:AddSlider({
    Name = "Farm Distance",
    Min = 2,
    Max = 30,
    Default = 5,
    Color = Color3.fromRGB(0, 150, 255),
    Increment = 1,
    ValueName = "Studs",
    Outline = true,
    Callback = function(Value)
        farmDistance = Value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- BYPASS SECTION
-- ═══════════════════════════════════════════════════════════════
local BypassSection = SettingsTab:AddSection({
    Name = "Bypass Settings",
    TextSize = 17,
    Folded = true,
    Glass = true,
    Outline = true
})

-- Noclip Toggle
local noclipEnabled = true
BypassSection:AddToggle({
    Name = "Noclip",
    Default = true,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "NoclipFlag",
    Save = true,
    Callback = function(Value)
        noclipEnabled = Value
        getgenv().NoclipEnabled = Value
    end
})

-- Anti Void Toggle
local antiVoidEnabled = true
BypassSection:AddToggle({
    Name = "Anti Void",
    Default = true,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AntiVoidFlag",
    Save = true,
    Callback = function(Value)
        antiVoidEnabled = Value
        getgenv().AntiVoid = Value
    end
})

-- Anti Idle Toggle
local antiIdleEnabled = true
BypassSection:AddToggle({
    Name = "Anti Idle",
    Default = true,
    Color = Color3.fromRGB(0, 150, 255),
    Outline = true,
    Flag = "AntiIdleFlag",
    Save = true,
    Callback = function(Value)
        antiIdleEnabled = Value
        getgenv().AntiIdle = Value
    end
})

-- ═══════════════════════════════════════════════════════════════
-- STATS SECTION
-- ═══════════════════════════════════════════════════════════════
local StatsSection = StatsTab:AddSection({
    Name = "Player Statistics",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Live Stats Paragraph
local statsParagraph = StatsSection:AddParagraph({
    Title = "Current Status",
    Desc = "Loading...",
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                refreshStats()
            end
        }
    }
})

-- Function to refresh stats
function refreshStats()
    local character = Player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp then
            local stats = string.format(
                "Health: %.0f/%.0f\nWalk Speed: %.0f\nJump Power: %.0f\nPosition: (%.0f, %.0f, %.0f)",
                humanoid.Health,
                humanoid.MaxHealth,
                humanoid.WalkSpeed,
                humanoid.JumpPower,
                hrp.Position.X,
                hrp.Position.Y,
                hrp.Position.Z
            )
            statsParagraph:SetDesc(stats)
        end
    end
end

-- Auto refresh stats
task.spawn(function()
    while task.wait(2) do
        refreshStats()
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- INFO SECTION
-- ═══════════════════════════════════════════════════════════════
local InfoSection = InfoTab:AddSection({
    Name = "About",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

InfoSection:AddParagraph({
    Title = "Sailor Piece Auto Farm",
    Desc = "Premium auto farming script for Sailor Piece\n\nFeatures:\n• Auto Farm Mobs\n• Auto Accept Quests\n• Auto Equip Weapons\n• Noclip & Anti-Void\n• Anti-Idle Protection\n• Island Scanner\n\nVersion: 2.0.0",
    Image = "info",
    ImageSize = 38,
    Buttons = {}
})

-- ═══════════════════════════════════════════════════════════════
-- ADD CONFIG TAB
-- ═══════════════════════════════════════════════════════════════
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Check if mob matches selected mob
local function isMobMatch(npcName, targetMob)
    if not npcName or not targetMob then return false end
    if npcName == targetMob then return true end
    local pattern = "^" .. targetMob .. "%d+$"
    return string.match(npcName, pattern) ~= nil
end

-- Find closest NPC
local function findClosestNPC()
    local npcsFolder = workspace:FindFirstChild("NPCs")
    if not npcsFolder then return nil end
    
    local character = Player.Character
    if not character then return nil end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local closestNPC = nil
    local closestDist = math.huge
    
    for _, npc in pairs(npcsFolder:GetChildren()) do
        if npc:IsA("Model") and isMobMatch(npc.Name, selectedMob) then
            local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
            local npcRoot = npc:FindFirstChild("HumanoidRootPart")
            if npcHumanoid and npcRoot and npcHumanoid.Health > 0 then
                local dist = (root.Position - npcRoot.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestNPC = npc
                end
            end
        end
    end
    
    return closestNPC
end

-- Get farm position based on mode
local function getFarmPosition(npcRoot)
    if farmMode == "Above" then
        local abovePos = npcRoot.CFrame * CFrame.new(0, farmDistance, 0)
        return abovePos * CFrame.Angles(math.rad(180), 0, 0)
    else
        return npcRoot.CFrame * CFrame.new(0, 0, farmDistance)
    end
end

-- Tween to position
local currentTween = nil
local function tweenTo(targetCFrame)
    local character = Player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if currentTween then
        currentTween:Cancel()
    end
    
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local tweenTime = distance / tweenSpeed
    
    if tweenTime < 0.05 then tweenTime = 0.05 end
    
    currentTween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {
        CFrame = targetCFrame
    })
    currentTween:Play()
end

-- Spam attack
local function spamAttack()
    pcall(function()
        ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()
    end)
end

-- Check quest UI visible
local function isQuestActive()
    local ok, result = pcall(function()
        local questUI = Player.PlayerGui:FindFirstChild("QuestUI")
        if questUI then
            local quest = questUI:FindFirstChild("Quest")
            if quest then return quest.Visible end
        end
        return false
    end)
    return ok and result
end

-- Accept quest
local function acceptQuest(questNPC)
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("QuestAccept"):FireServer(questNPC)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN LOOPS
-- ═══════════════════════════════════════════════════════════════

-- Quest auto-accept loop
task.spawn(function()
    while task.wait(0.5) do
        if autoFarmEnabled and selectedMob then
            local questNPC = mobQuestMap[selectedMob]
            if questNPC and not isQuestActive() then
                acceptQuest(questNPC)
                task.wait(1)
            end
        end
    end
end)

-- Auto farm loop
task.spawn(function()
    while task.wait(0.1) do
        if autoFarmEnabled and selectedMob then
            local npc = findClosestNPC()
            if npc then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                if npcRoot then
                    local character = Player.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local farmPos = getFarmPosition(npcRoot)
                        local dist = (root.Position - farmPos.Position).Magnitude
                        
                        if dist > 3 then
                            tweenTo(farmPos)
                        end
                        
                        if farmMode == "Above" then
                            local savedCFrame = root.CFrame
                            root.CFrame = npcRoot.CFrame * CFrame.new(0, 0, farmDistance)
                            spamAttack()
                            root.CFrame = savedCFrame
                        else
                            spamAttack()
                        end
                    end
                end
            end
        end
    end
end)

-- Auto equip loop
task.spawn(function()
    while task.wait(1) do
        if autoEquipEnabled and selectedWeapon and selectedWeapon ~= "None" then
            local character = Player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local alreadyEquipped = character:FindFirstChild(selectedWeapon)
                if humanoid and not alreadyEquipped then
                    local tool = Player.Backpack:FindFirstChild(selectedWeapon)
                    if tool then
                        humanoid:EquipTool(tool)
                    end
                end
            end
        end
    end
end)

-- Noclip loop
task.spawn(function()
    RunService.Stepped:Connect(function()
        if noclipEnabled then
            local char = Player.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- Anti Void loop
task.spawn(function()
    local lastSafe = CFrame.new(0, 100, 0)
    while task.wait(0.5) do
        if antiVoidEnabled then
            local char = Player.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            if hrp.Position.Y > -50 then
                lastSafe = hrp.CFrame
            else
                hrp.CFrame = lastSafe
            end
        end
    end
end)

-- Anti Idle loop
task.spawn(function()
    while task.wait(120) do
        if antiIdleEnabled then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.5)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

-- Refresh weapon dropdown when new tools are added
Player.Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        if weaponDropdown and weaponDropdown.Refresh then
            weaponDropdown:Refresh(getWeaponList())
        end
        if autoEquipEnabled and selectedWeapon and child.Name == selectedWeapon then
            task.wait(0.1)
            local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(child)
            end
        end
    end
end)

-- Re-equip on respawn
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    if autoEquipEnabled and selectedWeapon and selectedWeapon ~= "None" then
        local tool = Player.Backpack:FindFirstChild(selectedWeapon)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if tool and humanoid then
            humanoid:EquipTool(tool)
        end
    end
    refreshStats()
end)

-- ═══════════════════════════════════════════════════════════════
-- ISLAND SCANNER (Bypass + Teleport)
-- ═══════════════════════════════════════════════════════════════

-- Global cache
getgenv().IslandMobCache = getgenv().IslandMobCache or {}
getgenv().IslandScanDone = false

-- Get all islands
local function getAllIslands()
    local islands = {}
    
    local ok, travelConfig = pcall(function()
        return require(ReplicatedStorage:WaitForChild("TravelConfig", 5))
    end)
    
    if ok and travelConfig then
        local data = travelConfig.Islands or travelConfig.Zones
        if data then
            for name, _ in pairs(data) do
                local portalArg = name:gsub("Island", ""):gsub(" ", "")
                table.insert(islands, { name = name, portal = portalArg })
            end
        end
    end
    
    if #islands == 0 then
        local hardcoded = {
            "Starter", "Jungle", "Desert", "Snow", "Boss",
            "ShibuyaStation", "Sailor", "HuecoMundo", "Dungeon",
            "Shinjuku", "Slime", "Academy", "SoulSociety", "Judgement"
        }
        for _, name in ipairs(hardcoded) do
            table.insert(islands, { name = name .. "Island", portal = name })
        end
    end
    
    return islands
end

-- Scan current island NPCs
local function scanCurrentIslandNPCs(islandName)
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return 0 end
    
    local found = 0
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") then
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                if not getgenv().IslandMobCache[npc.Name] then
                    getgenv().IslandMobCache[npc.Name] = {
                        island = islandName,
                        position = hrp.Position,
                        maxHealth = hum.MaxHealth,
                    }
                    found = found + 1
                end
            end
        end
    end
    
    return found
end

-- Teleport to mob island
getgenv().TeleportToMobIsland = function(mobName)
    local cached = getgenv().IslandMobCache[mobName]
    if cached then
        local portalArg = cached.island:gsub("Island", ""):gsub(" ", "")
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(portalArg)
        end)
        task.wait(3)
        return true
    end
    return false
end

-- Scan all islands
getgenv().ScanAllIslands = function()
    local islands = getAllIslands()
    local totalMobs = 0
    
    for i, island in ipairs(islands) do
        local ok = pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(island.portal)
        end)
        
        if ok then
            task.wait(4)
            local found = scanCurrentIslandNPCs(island.name)
            totalMobs = totalMobs + found
        end
        task.wait(1)
    end
    
    getgenv().IslandScanDone = true
    return totalMobs
end

-- Auto start scan
task.spawn(function()
    if not Player.Character then
        Player.CharacterAdded:Wait()
    end
    task.wait(3)
    task.spawn(function()
        getgenv().ScanAllIslands()
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZE
-- ═══════════════════════════════════════════════════════════════
OrionLib:Init()

OrionLib:MakeNotification({
    Name = "Auto Farm Loaded",
    Content = "Sailor Piece Auto Farm is ready!",
    Image = "check-circle",
    Time = 3
})