-- ==================== CATCH A MONSTER [98664161516921] ====================
-- Script Lengkap dengan Semua Fitur Remote
-- Author: LuckyBimZy
-- Version: 3.0 (Ultimate)

if _G.CAM_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Catch a Monster",
        Text = "Script sudah diload!",
        Duration = 2
    })
    return 
end

_G.CAM_Loaded = true

--==================================================
-- VARIABLES GLOBAL
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

-- Remote Function Utama
local DataPullFunc = ReplicatedStorage:WaitForChild("CommonLibrary"):WaitForChild("Tool"):WaitForChild("RemoteManager"):WaitForChild("Funcs"):WaitForChild("DataPullFunc")

--==================================================
-- DATABASE MONSTER
--==================================================
local MonsterDatabase = {}
local MonsterIds = {} -- Untuk menyimpan ID monster

-- Fungsi untuk update monster database
local function UpdateMonsterDatabase()
    local newMonsters = {}
    local newIds = {}
    
    -- Cari monster di workspace
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            -- Cek apakah ini monster (bisa dengan atribut atau nama)
            local isMonster = false
            local monsterId = nil
            
            -- Coba dapatkan ID monster (mungkin dari attribute atau nilai)
            if v:GetAttribute("MonsterId") then
                monsterId = v:GetAttribute("MonsterId")
                isMonster = true
            elseif v:FindFirstChild("MonsterId") and v.MonsterId:IsA("NumberValue") then
                monsterId = v.MonsterId.Value
                isMonster = true
            elseif v.Name:find("Monster") or v.Name:find("Enemy") or v.Name:find("Creature") then
                isMonster = true
                -- Generate ID sementara dari name hash
                monsterId = math.abs(v.Name:gsub(".", function(c) return string.byte(c) end):gsub("..", function(b) return tonumber(b,16) or 0 end) % 1000)
            end
            
            if isMonster then
                local hrp = v:FindFirstChild("HumanoidRootPart") or 
                            v:FindFirstChild("Torso") or 
                            v:FindFirstChild("UpperTorso") or
                            v:FindFirstChild("Head")
                
                if hrp then
                    local humanoid = v:FindFirstChild("Humanoid")
                    local data = {
                        Name = v.Name,
                        Instance = v,
                        Id = monsterId or math.random(1, 1000),
                        Position = hrp.Position,
                        HumanoidRootPart = hrp,
                        Humanoid = humanoid,
                        Health = humanoid and humanoid.Health or 0,
                        MaxHealth = humanoid and humanoid.MaxHealth or 0,
                        IsAlive = humanoid and humanoid.Health > 0 or false
                    }
                    
                    table.insert(newMonsters, data)
                    if monsterId then
                        newIds[monsterId] = data
                    end
                end
            end
        end
    end
    
    MonsterDatabase = newMonsters
    MonsterIds = newIds
    return newMonsters
end

-- Auto update setiap 3 detik
task.spawn(function()
    while _G.CAM_Loaded do
        UpdateMonsterDatabase()
        task.wait(3)
    end
end)

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Catch a Monster",
        Text = msg,
        Duration = duration or 2
    })
end

Notify("Script loaded! Remote functions ready", 3)

--==================================================
-- REMOTE FUNCTIONS (DARI HASIL RSPY)
--==================================================

-- Fungsi untuk toggle auto attack
local function SetAutoAttack(state)
    local args = {
        "SettingSetOnOffChannel",
        "AutoAttack",
        state
    }
    DataPullFunc:InvokeServer(unpack(args))
    return true
end

-- Fungsi untuk equip pet terbaik
local function EquipBestPet()
    local args = {
        "PetEquipBestChannel"
    }
    DataPullFunc:InvokeServer(unpack(args))
    Notify("Equipped best pet", 1)
end

-- Fungsi untuk toggle auto sell
local function SetAutoSell(state, tier)
    tier = tier or 1
    local args = {
        "PetAutoSellChannel",
        tier,
        state
    }
    DataPullFunc:InvokeServer(unpack(args))
    return true
end

-- Fungsi untuk menjual pet tertentu
local function SellPets(petIds)
    -- petIds bisa berupa table {1,2,3} atau single id
    if type(petIds) ~= "table" then
        petIds = {petIds}
    end
    
    local args = {
        "PetSellChannel",
        petIds
    }
    DataPullFunc:InvokeServer(unpack(args))
    Notify("Sold " .. #petIds .. " pet(s)", 1)
end

-- Fungsi untuk menyerang monster
local function AttackMonster(monsterId)
    local args = {
        "MonsterAttackChannel",
        monsterId
    }
    DataPullFunc:InvokeServer(unpack(args))
end

-- Fungsi untuk mulai menangkap monster
local function StartCatchMonster(monsterId)
    local args = {
        "MonsterCatchStartChannel",
        monsterId
    }
    DataPullFunc:InvokeServer(unpack(args))
end

-- Fungsi untuk menyelesaikan penangkapan (pasti berhasil)
local function CompleteCatchMonster(monsterId)
    local args = {
        "MonsterCatchCompleteChannel",
        monsterId
    }
    DataPullFunc:InvokeServer(unpack(args))
    Notify("Monster caught! ID: " .. monsterId, 1)
end

-- Fungsi lengkap untuk menangkap monster (start + complete)
local function CatchMonster(monsterId)
    StartCatchMonster(monsterId)
    task.wait(0.1) -- Sedikit delay antar remote
    CompleteCatchMonster(monsterId)
end

--==================================================
-- GET MONSTER ID FUNCTIONS
--==================================================

-- Cari monster berdasarkan nama
local function FindMonsterIdByName(name)
    UpdateMonsterDatabase()
    for _, monster in ipairs(MonsterDatabase) do
        if monster.Name:lower():find(name:lower()) then
            return monster.Id, monster
        end
    end
    return nil, nil
end

-- Cari monster terdekat
local function FindNearestMonsterId()
    UpdateMonsterDatabase()
    local nearest = nil
    local nearestId = nil
    local dist = math.huge
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not root then return nil end
    
    for _, monster in ipairs(MonsterDatabase) do
        if monster.IsAlive and monster.HumanoidRootPart then
            local d = (root.Position - monster.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = monster
                nearestId = monster.Id
            end
        end
    end
    
    return nearestId, nearest
end

--==================================================
-- AUTO FARM SYSTEM
--==================================================
local AutoFarmSettings = {
    Enabled = false,
    TargetMonster = "All",
    AutoAttack = true,
    AutoCatch = true,
    AutoEquipBestPet = true,
    AutoSell = false,
    AutoSellTier = 1,
    AttackInterval = 0.5,
    CatchDelay = 0.3
}

local AutoFarmThread = nil

local function StartAutoFarm()
    if AutoFarmThread then return end
    
    AutoFarmThread = task.spawn(function()
        while AutoFarmSettings.Enabled do
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            
            -- Auto equip best pet
            if AutoFarmSettings.AutoEquipBestPet then
                EquipBestPet()
                task.wait(0.5)
            end
            
            -- Cari target monster
            local targetId, targetMonster = nil, nil
            
            if AutoFarmSettings.TargetMonster == "All" then
                targetId, targetMonster = FindNearestMonsterId()
            else
                targetId, targetMonster = FindMonsterIdByName(AutoFarmSettings.TargetMonster)
            end
            
            if targetId and targetMonster then
                -- Teleport ke monster
                if targetMonster.HumanoidRootPart then
                    Player.Character.HumanoidRootPart.CFrame = targetMonster.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    task.wait(0.2)
                end
                
                -- Auto attack
                if AutoFarmSettings.AutoAttack then
                    AttackMonster(targetId)
                    task.wait(AutoFarmSettings.AttackInterval)
                end
                
                -- Auto catch
                if AutoFarmSettings.AutoCatch and targetMonster.Humanoid and targetMonster.Humanoid.Health < 50 then
                    StartCatchMonster(targetId)
                    task.wait(AutoFarmSettings.CatchDelay)
                    CompleteCatchMonster(targetId)
                    task.wait(1)
                end
            end
            
            -- Auto sell
            if AutoFarmSettings.AutoSell then
                SetAutoSell(true, AutoFarmSettings.AutoSellTier)
            end
            
            task.wait(0.3)
        end
    end)
end

local function StopAutoFarm()
    AutoFarmSettings.Enabled = false
    if AutoFarmThread then
        AutoFarmThread = nil
    end
    -- Matikan auto attack
    SetAutoAttack(false)
    Notify("Auto Farm stopped", 2)
end

--==================================================
-- CREATE UI
--==================================================

-- Clean old GUI
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "CAM_Ultimate" then v:Destroy() end
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CAM_Ultimate"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

--==================================================
-- FLOATING BUTTON
--==================================================
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatBtn"
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -27.5)
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
FloatBtn.Text = "🐾"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextSize = 28
FloatBtn.Font = Enum.Font.Gotham
FloatBtn.BorderSizePixel = 0
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui

-- Rounded corners
local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 27)
FloatCorner.Parent = FloatBtn

-- Hover effect
FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
end)

FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 55, 0, 55)}):Play()
end)

--==================================================
-- MAIN MENU
--==================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Main corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Gradient background
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 20))
})
Gradient.Parent = MainFrame

--==================================================
-- TITLE BAR
--==================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

-- Icon
local IconFrame = Instance.new("Frame")
IconFrame.Size = UDim2.new(0, 40, 0, 40)
IconFrame.Position = UDim2.new(0, 15, 0.5, -20)
IconFrame.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
IconFrame.Parent = TitleBar

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 12)
IconCorner.Parent = IconFrame

local IconLabel = Instance.new("TextLabel")
IconLabel.Size = UDim2.new(1, 0, 1, 0)
IconLabel.BackgroundTransparency = 1
IconLabel.Text = "🐾"
IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IconLabel.TextSize = 24
IconLabel.Font = Enum.Font.Gotham
IconLabel.Parent = IconFrame

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 300, 0, 30)
TitleText.Position = UDim2.new(0, 65, 0.5, -15)
TitleText.BackgroundTransparency = 1
TitleText.Text = "CATCH A MONSTER"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 20
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Version
local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 100, 0, 20)
VersionText.Position = UDim2.new(0, 65, 0.5, 10)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v3.0 | Ultimate"
VersionText.TextColor3 = Color3.fromRGB(180, 180, 180)
VersionText.TextSize = 11
VersionText.Font = Enum.Font.Gotham
VersionText.TextXAlignment = Enum.TextXAlignment.Left
VersionText.Parent = TitleBar

-- Control buttons
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -75, 0.5, -17.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 55)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 24
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 10)
MinCorner.Parent = MinBtn

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.CAM_Loaded = false
    StopAutoFarm()
end)

--==================================================
-- TABS
--==================================================
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 50)
TabFrame.Position = UDim2.new(0, 10, 0, 65)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"🏠 Home", "👾 Monsters", "⚡ Auto Farm", "🐕 Pets", "🌀 Teleport", "⚙️ Settings"}
local TabButtons = {}
local CurrentTab = "🏠 Home"

for i = 1, #Tabs do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 75, 0, 50)
    TabBtn.Position = UDim2.new(0, (i-1) * 77, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
    TabBtn.Text = Tabs[i]
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn
    
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= Tabs[i] then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 40, 45)}):Play()
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= Tabs[i] then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 30, 35)}):Play()
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = Tabs[i]
        for _, btn in pairs(TabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 30, 35)}):Play()
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 85, 85)}):Play()
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        UpdateTab(Tabs[i])
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Set first tab active
TabButtons[1].BackgroundColor3 = Color3.fromRGB(255, 85, 85)
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

--==================================================
-- CONTENT AREA
--==================================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -130)
ContentFrame.Position = UDim2.new(0, 10, 0, 120)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentFrame

-- Scrolling frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 85, 85)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollingFrame

--==================================================
-- UI ELEMENTS FUNCTIONS
--==================================================

function CreateSection(title)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 30)
    Section.BackgroundTransparency = 1
    Section.Text = "  " .. title
    Section.TextColor3 = Color3.fromRGB(255, 85, 85)
    Section.TextSize = 15
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -10, 0, 1)
    Line.Position = UDim2.new(0, 5, 0, 28)
    Line.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section
end

function CreateToggle(text, var, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, -15, 1, 0)
    ToggleText.Position = UDim2.new(0, 15, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 14
    ToggleText.Font = Enum.Font.Gotham
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 70, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -85, 0.5, -15)
    ToggleBtn.BackgroundColor3 = var and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(50, 45, 50)
    ToggleBtn.Text = var and "ON" or "OFF"
    ToggleBtn.TextColor3 = var and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 100, 100)
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        var = not var
        if var then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(255, 85, 85),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            ToggleBtn.Text = "ON"
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(50, 45, 50),
                TextColor3 = Color3.fromRGB(200, 100, 100)
            }):Play()
            ToggleBtn.Text = "OFF"
        end
        callback(var)
    end)
end

function CreateButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 45)
    Button.BackgroundColor3 = color or Color3.fromRGB(255, 85, 85)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Parent = ScrollingFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
end

function CreateDropdown(text, options, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 45)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Parent = ScrollingFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -15, 1, 0)
    DropdownText.Position = UDim2.new(0, 15, 0, 0)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 14
    DropdownText.Font = Enum.Font.Gotham
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 140, 0, 30)
    DropdownBtn.Position = UDim2.new(1, -155, 0.5, -15)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 40, 45)
    DropdownBtn.Text = options[1] or "Select"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 12
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame")
        menu.Size = UDim2.new(0, 160, 0, math.min(#options, 6) * 35)
        menu.Position = UDim2.new(1, -155, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(40, 35, 40)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        menu.ZIndex = 10
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 8)
        menuCorner.Parent = menu
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 35)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 35)
            optBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 50)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextSize = 12
            optBtn.Font = Enum.Font.Gotham
            optBtn.Parent = menu
            optBtn.ZIndex = 11
            
            optBtn.MouseButton1Click:Connect(function()
                DropdownBtn.Text = option
                callback(option)
                menu:Destroy()
            end)
        end
    end)
end

function CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = "• " .. text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ScrollingFrame
end

function CreateSlider(text, min, max, value, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = ScrollingFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.6, -15, 0, 20)
    SliderText.Position = UDim2.new(0, 15, 0, 8)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 14
    SliderText.Font = Enum.Font.Gotham
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueBox = Instance.new("TextBox")
    ValueBox.Size = UDim2.new(0, 60, 0, 25)
    ValueBox.Position = UDim2.new(1, -75, 0, 6)
    ValueBox.BackgroundColor3 = Color3.fromRGB(45, 40, 45)
    ValueBox.Text = tostring(value)
    ValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueBox.TextSize = 13
    ValueBox.Font = Enum.Font.GothamBold
    ValueBox.ClearTextOnFocus = false
    ValueBox.Parent = SliderFrame
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 6)
    ValueCorner.Parent = ValueBox
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 6)
    SliderBg.Position = UDim2.new(0, 10, 0, 40)
    SliderBg.BackgroundColor3 = Color3.fromRGB(45, 40, 45)
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    SliderFill.Parent = SliderBg
    
    local SliderButton = Instance.new("Frame")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Parent = SliderFill
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = SliderButton
    
    -- Update function
    local function updateValue(newValue)
        newValue = math.clamp(newValue, min, max)
        local percent = (newValue - min) / (max - min)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderButton.Position = UDim2.new(percent, -8, 0.5, -8)
        ValueBox.Text = tostring(math.floor(newValue))
        callback(math.floor(newValue))
    end
    
    -- Input box
    ValueBox.FocusLost:Connect(function()
        local val = tonumber(ValueBox.Text)
        if val then
            updateValue(val)
        else
            ValueBox.Text = tostring(value)
        end
    end)
    
    -- Drag
    local dragging = false
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = SliderBg.AbsolutePosition
            local size = SliderBg.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - absPos.X) / size, 0, 1)
            local val = min + (max - min) * percent
            updateValue(val)
        end
    end)
end

--==================================================
-- TOGGLE HANDLERS
--==================================================
FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--==================================================
-- UPDATE TAB CONTENT
--==================================================
function UpdateTab(tab)
    -- Clear content
    for _, v in pairs(ScrollingFrame:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") then
            v:Destroy()
        end
    end
    
    -- Update database
    UpdateMonsterDatabase()
    
    if tab == "🏠 Home" then
        CreateSection("📊 DASHBOARD")
        
        CreateLabel("Player: " .. Player.Name)
        CreateLabel("Display: " .. Player.DisplayName)
        CreateLabel("Server: " .. game.JobId:sub(1, 8) .. "...")
        CreateLabel("Players: " .. #Players:GetPlayers())
        
        CreateSection("📈 STATISTICS")
        CreateLabel("Monsters Found: " .. #MonsterDatabase)
        
        CreateSection("🎮 QUICK ACTIONS")
        
        CreateButton("Refresh Data", Color3.fromRGB(100, 100, 200), function()
            UpdateTab("🏠 Home")
            Notify("Data refreshed!")
        end)
        
        CreateButton("Equip Best Pet", Color3.fromRGB(0, 200, 100), function()
            EquipBestPet()
        end)
        
        CreateButton("Rejoin Server", Color3.fromRGB(220, 60, 60), function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end)
        
        CreateSection("ℹ️ INFO")
        CreateLabel("Remote Functions Ready")
        CreateLabel("Auto Attack: ON/OFF via toggle")
        CreateLabel("Auto Catch: Available in Auto Farm")
        
    elseif tab == "👾 Monsters" then
        CreateSection("👾 MONSTER LIST")
        
        CreateLabel("Total: " .. #MonsterDatabase)
        
        if #MonsterDatabase == 0 then
            CreateLabel("No monsters found")
            CreateLabel("Waiting for scan...")
        end
        
        for i, monster in ipairs(MonsterDatabase) do
            if i <= 20 then -- Batasi 20 monster
                local dist = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and 
                            monster.HumanoidRootPart and 
                            math.floor((Player.Character.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude) or "?"
                
                local healthPercent = monster.MaxHealth > 0 and math.floor((monster.Health / monster.MaxHealth) * 100) or 0
                local status = monster.IsAlive and "🟢" or "💀"
                
                CreateButton(status .. " " .. monster.Name .. " [ID:" .. monster.Id .. "] " .. dist .. "m HP:" .. healthPercent .. "%", Color3.fromRGB(200, 100, 100), function()
                    if monster.HumanoidRootPart then
                        Player.Character.HumanoidRootPart.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        Notify("Teleported to " .. monster.Name)
                    end
                end)
            end
        end
        
        if #MonsterDatabase > 20 then
            CreateLabel("... and " .. (#MonsterDatabase - 20) .. " more")
        end
        
    elseif tab == "⚡ Auto Farm" then
        CreateSection("⚡ AUTO FARM SETTINGS")
        
        -- Buat list monster untuk dropdown
        local monsterNames = {"All"}
        for _, monster in ipairs(MonsterDatabase) do
            if not table.find(monsterNames, monster.Name) then
                table.insert(monsterNames, monster.Name)
            end
        end
        
        CreateToggle("Auto Farm", AutoFarmSettings.Enabled, function(state)
            AutoFarmSettings.Enabled = state
            if state then 
                SetAutoAttack(true)
                StartAutoFarm()
                Notify("Auto Farm started")
            else 
                SetAutoAttack(false)
                StopAutoFarm()
            end
        end)
        
        CreateDropdown("Target Monster", monsterNames, function(opt)
            AutoFarmSettings.TargetMonster = opt
            Notify("Target: " .. opt)
        end)
        
        CreateSection("⚡ AUTO ACTIONS")
        
        CreateToggle("Auto Attack", AutoFarmSettings.AutoAttack, function(state)
            AutoFarmSettings.AutoAttack = state
            SetAutoAttack(state)
        end)
        
        CreateToggle("Auto Catch", AutoFarmSettings.AutoCatch, function(state)
            AutoFarmSettings.AutoCatch = state
        end)
        
        CreateToggle("Auto Equip Best Pet", AutoFarmSettings.AutoEquipBestPet, function(state)
            AutoFarmSettings.AutoEquipBestPet = state
            if state then EquipBestPet() end
        end)
        
        CreateToggle("Auto Sell", AutoFarmSettings.AutoSell, function(state)
            AutoFarmSettings.AutoSell = state
            SetAutoSell(state, AutoFarmSettings.AutoSellTier)
        end)
        
        CreateSlider("Sell Tier", 1, 10, AutoFarmSettings.AutoSellTier, function(val)
            AutoFarmSettings.AutoSellTier = val
            if AutoFarmSettings.AutoSell then
                SetAutoSell(true, val)
            end
        end)
        
        CreateSection("🎯 CURRENT TARGET")
        
        if AutoFarmSettings.TargetMonster == "All" then
            local id, monster = FindNearestMonsterId()
            if monster then
                local dist = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and 
                            monster.HumanoidRootPart and 
                            math.floor((Player.Character.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude) or "?"
                CreateLabel("Nearest: " .. monster.Name .. " [" .. dist .. "m]")
                CreateLabel("ID: " .. id)
            else
                CreateLabel("No monsters nearby")
            end
        else
            local id, monster = FindMonsterIdByName(AutoFarmSettings.TargetMonster)
            if monster then
                local dist = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and 
                            monster.HumanoidRootPart and 
                            math.floor((Player.Character.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude) or "?"
                CreateLabel("Distance: " .. dist .. "m")
                CreateLabel("ID: " .. id)
                if monster.Humanoid then
                    CreateLabel("Health: " .. math.floor(monster.Humanoid.Health) .. "/" .. math.floor(monster.Humanoid.MaxHealth))
                end
            else
                CreateLabel("Target not found")
            end
        end
        
    elseif tab == "🐕 Pets" then
        CreateSection("🐕 PET COMMANDS")
        
        CreateButton("Equip Best Pet", Color3.fromRGB(0, 200, 100), function()
            EquipBestPet()
        end)
        
        CreateButton("Sell All Tier 1", Color3.fromRGB(200, 100, 0), function()
            SellPets({1,2,3,4,5}) -- Contoh ID pet
            Notify("Selling tier 1 pets...")
        end)
        
        CreateSection("⚙️ AUTO SELL SETTINGS")
        
        CreateToggle("Auto Sell", AutoFarmSettings.AutoSell, function(state)
            AutoFarmSettings.AutoSell = state
            SetAutoSell(state, AutoFarmSettings.AutoSellTier)
        end)
        
        CreateSlider("Sell Tier", 1, 10, AutoFarmSettings.AutoSellTier, function(val)
            AutoFarmSettings.AutoSellTier = val
            if AutoFarmSettings.AutoSell then
                SetAutoSell(true, val)
            end
        end)
        
    elseif tab == "🌀 Teleport" then
        CreateSection("🌀 TELEPORTATION")
        
        CreateSection("📍 TELEPORT TO PLAYER")
        
        local playerNames = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                table.insert(playerNames, player.Name)
            end
        end
        
        if #playerNames > 0 then
            CreateDropdown("Select Player", playerNames, function(name)
                local target = Players:FindFirstChild(name)
                if target and target.Character then
                    Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    Notify("Teleported to " .. name)
                end
            end)
        else
            CreateLabel("No other players")
        end
        
        CreateSection("📍 TELEPORT TO MONSTER")
        
        local monsterNames = {"Select Monster"}
        for _, monster in ipairs(MonsterDatabase) do
            if not table.find(monsterNames, monster.Name) then
                table.insert(monsterNames, monster.Name)
            end
        end
        
        if #monsterNames > 1 then
            CreateDropdown("Select Monster", monsterNames, function(name)
                if name ~= "Select Monster" then
                    local id, monster = FindMonsterIdByName(name)
                    if monster and monster.HumanoidRootPart then
                        Player.Character.HumanoidRootPart.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        Notify("Teleported to " .. name)
                    end
                end
            end)
        end
        
        CreateSection("📍 SAVE POSITION")
        
        CreateButton("Save Current Position", Color3.fromRGB(0, 200, 0), function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                _G.SavedPosition = Player.Character.HumanoidRootPart.CFrame
                Notify("Position saved!")
            end
        end)
        
        CreateButton("Load Saved Position", Color3.fromRGB(255, 165, 0), function()
            if _G.SavedPosition then
                Player.Character.HumanoidRootPart.CFrame = _G.SavedPosition
                Notify("Teleported to saved position")
            else
                Notify("No saved position!")
            end
        end)
        
    elseif tab == "⚙️ Settings" then
        CreateSection("⚙️ REMOTE FUNCTIONS")
        
        CreateToggle("Auto Attack", AutoFarmSettings.AutoAttack, function(state)
            AutoFarmSettings.AutoAttack = state
            SetAutoAttack(state)
        end)
        
        CreateSection("🎮 CONTROLS")
        
        CreateButton("Toggle Menu (F4)", Color3.fromRGB(255, 85, 85), function()
            MainFrame.Visible = not MainFrame.Visible
        end)
        
        CreateButton("Emergency Stop", Color3.fromRGB(220, 60, 60), function()
            StopAutoFarm()
            SetAutoAttack(false)
            SetAutoSell(false, 1)
            Notify("All features stopped", 2)
        end)
        
        CreateButton("Close GUI", Color3.fromRGB(150, 50, 50), function()
            ScreenGui:Destroy()
            _G.CAM_Loaded = false
            StopAutoFarm()
        end)
        
        CreateSection("ℹ️ INFO")
        CreateLabel("Active Features: " .. (AutoFarmSettings.Enabled and "Auto Farm ON" or "Idle"))
        CreateLabel("Monsters: " .. #MonsterDatabase)
        CreateLabel("Remote: DataPullFunc")
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Helper function untuk table.find
function table.find(t, value)
    for i, v in ipairs(t) do
        if v == value then return i end
    end
    return nil
end

--==================================================
-- INITIALIZE
--==================================================
UpdateTab("🏠 Home")

-- Auto update untuk tab tertentu
task.spawn(function()
    while _G.CAM_Loaded do
        task.wait(5)
        if CurrentTab == "👾 Monsters" or CurrentTab == "⚡ Auto Farm" then
            UpdateTab(CurrentTab)
        end
    end
end)

Notify("Catch a Monster script ready! Found " .. #MonsterDatabase .. " monsters", 3)

print("========================================")
print("✅ CATCH A MONSTER ULTIMATE v3.0")
print("Game ID: 98664161516921")
print("Remote Functions: DataPullFunc")
print("Features: Auto Farm | Auto Attack | Auto Catch | Auto Sell")
print("Press F4 to toggle menu")
print("========================================")