-- ==================== CATCH A MONSTER [98664161516921] ====================
-- Script Khusus dengan Auto Farm by Name & Pet Auto Update
-- Author: LuckyBimZy
-- Version: 2.0 (Game Specific)

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
local HttpService = game:GetService("HttpService")

--==================================================
-- DATABASE MONSTER & PET (AUTO UPDATE)
--==================================================
local MonsterDatabase = {}
local PetDatabase = {}
local PlayerPets = {}

-- Fungsi untuk update monster database
local function UpdateMonsterDatabase()
    local newMonsters = {}
    
    -- Cari monster di workspace
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            -- Deteksi monster berdasarkan karakteristik game
            local isMonster = false
            local monsterData = {}
            
            -- Cek berbagai indikator monster
            if v:FindFirstChild("Humanoid") or v:FindFirstChild("Monster") then
                isMonster = true
            end
            
            -- Cek nama yang umum untuk monster
            local name = v.Name
            if name:find("Monster") or name:find("Enemy") or name:find("Creature") or 
               name:find("Boss") or name:find("Mob") or name:find("Pet") then
                isMonster = true
            end
            
            -- Cek tag atau attribute
            if v:GetAttribute("Monster") or v:GetAttribute("Enemy") then
                isMonster = true
            end
            
            if isMonster then
                local hrp = v:FindFirstChild("HumanoidRootPart") or 
                            v:FindFirstChild("Torso") or 
                            v:FindFirstChild("UpperTorso") or
                            v:FindFirstChild("Head")
                
                if hrp then
                    local humanoid = v:FindFirstChild("Humanoid")
                    monsterData = {
                        Name = name,
                        Instance = v,
                        Position = hrp.Position,
                        HumanoidRootPart = hrp,
                        Humanoid = humanoid,
                        Health = humanoid and humanoid.Health or 0,
                        MaxHealth = humanoid and humanoid.MaxHealth or 0,
                        IsAlive = humanoid and humanoid.Health > 0 or false
                    }
                    
                    if not newMonsters[name] then
                        newMonsters[name] = monsterData
                    end
                end
            end
        end
    end
    
    MonsterDatabase = newMonsters
    return newMonsters
end

-- Fungsi untuk update pet database (dari inventory player)
local function UpdatePetDatabase()
    local newPets = {}
    
    -- Cari pet di player (biasanya di folder tertentu)
    local playerFolder = Player:FindFirstChild("PlayerGui") or 
                        Player:FindFirstChild("Backpack") or 
                        Player:FindFirstChild("StarterGear")
    
    if playerFolder then
        for _, v in pairs(playerFolder:GetDescendants()) do
            if v:IsA("Tool") or v:IsA("Model") then
                if v.Name:find("Pet") or v:FindFirstChild("Pet") then
                    table.insert(newPets, {
                        Name = v.Name,
                        Instance = v,
                        Level = v:GetAttribute("Level") or 1,
                        Rarity = v:GetAttribute("Rarity") or "Common"
                    })
                end
            end
        end
    end
    
    -- Cek juga di workspace (pet yang sedang aktif)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            if v:GetAttribute("Pet") or v.Name:find("Pet") then
                table.insert(newPets, {
                    Name = v.Name,
                    Instance = v,
                    Level = v:GetAttribute("Level") or 1,
                    Rarity = v:GetAttribute("Rarity") or "Common",
                    IsActive = true
                })
            end
        end
    end
    
    PetDatabase = newPets
    return newPets
end

-- Auto update setiap 5 detik
task.spawn(function()
    while _G.CAM_Loaded do
        UpdateMonsterDatabase()
        UpdatePetDatabase()
        task.wait(5)
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

Notify("Script loaded! Scanning monsters...", 3)

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
MainFrame.Size = UDim2.new(0, 450, 0, 600)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
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

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 80, 0, 20)
VersionText.Position = UDim2.new(0, 65, 0.5, 10)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v2.0 | ID: 9866..."
VersionText.TextColor3 = Color3.fromRGB(180, 180, 180)
VersionText.TextSize = 10
VersionText.Font = Enum.Font.Gotham
VersionText.TextXAlignment = Enum.TextXAlignment.Left
VersionText.Parent = TitleBar

-- Control buttons
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -70, 0.5, -16)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 55)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 24
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.CAM_Loaded = false
end)

--==================================================
-- TABS
--==================================================
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 50)
TabFrame.Position = UDim2.new(0, 10, 0, 65)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"🏠 Home", "👾 Monsters", "🐕 Pets", "⚡ Auto Farm", "🌀 Teleport", "👁️ Visuals", "⚙️ Misc"}
local TabButtons = {}
local CurrentTab = "🏠 Home"

for i = 1, #Tabs do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 60, 0, 50)
    TabBtn.Position = UDim2.new(0, (i-1) * 62, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
    TabBtn.Text = Tabs[i]
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 11
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
-- FIND MONSTER FUNCTIONS
--==================================================
function FindMonsterByName(name)
    UpdateMonsterDatabase()
    
    for _, monster in pairs(MonsterDatabase) do
        if monster.Name == name and monster.IsAlive then
            return monster.Instance, monster.HumanoidRootPart
        end
    end
    return nil, nil
end

function FindNearestMonster()
    UpdateMonsterDatabase()
    
    local nearest = nil
    local nearestHrp = nil
    local dist = math.huge
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not root then return nil, nil end
    
    for _, monster in pairs(MonsterDatabase) do
        if monster.IsAlive and monster.HumanoidRootPart then
            local d = (root.Position - monster.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = monster.Instance
                nearestHrp = monster.HumanoidRootPart
            end
        end
    end
    
    return nearest, nearestHrp
end

--==================================================
-- AUTO FARM BY NAME
--==================================================
local AutoFarmActive = false
local SelectedMonster = "All"

function StartAutoFarm()
    AutoFarmActive = true
    
    task.spawn(function()
        while AutoFarmActive do
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            
            local targetMonster, targetHrp = nil, nil
            
            if SelectedMonster == "All" then
                targetMonster, targetHrp = FindNearestMonster()
            else
                targetMonster, targetHrp = FindMonsterByName(SelectedMonster)
            end
            
            if targetMonster and targetHrp then
                -- Teleport ke monster
                Player.Character.HumanoidRootPart.CFrame = targetHrp.CFrame * CFrame.new(0, 3, 0)
                task.wait(0.1)
                
                -- Coba catch monster
                local tool = Player.Character:FindFirstChildWhichIsA("Tool")
                if tool then
                    tool:Activate()
                end
                
                -- Coba remote event
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent") or
                              ReplicatedStorage:FindFirstChild("Catch") or
                              ReplicatedStorage:FindFirstChild("CatchMonster")
                if remote then
                    pcall(function()
                        remote:FireServer("Catch", targetMonster)
                    end)
                end
                
                -- Coba proximity prompt
                local prompt = targetMonster:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
            
            task.wait(0.3)
        end
    end)
end

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
    UpdatePetDatabase()
    
    if tab == "🏠 Home" then
        CreateSection("📊 DASHBOARD")
        
        CreateLabel("Player: " .. Player.Name)
        CreateLabel("Display: " .. Player.DisplayName)
        CreateLabel("Server: " .. game.JobId:sub(1, 8) .. "...")
        CreateLabel("Players: " .. #Players:GetPlayers())
        
        CreateSection("📈 STATISTICS")
        
        local monsterCount = 0
        for _, v in pairs(MonsterDatabase) do monsterCount = monsterCount + 1 end
        
        CreateLabel("Monsters Detected: " .. monsterCount)
        CreateLabel("Pets Owned: " .. #PetDatabase)
        
        CreateSection("🎯 QUICK ACTIONS")
        
        CreateButton("Refresh Data", Color3.fromRGB(100, 100, 200), function()
            UpdateTab("🏠 Home")
            Notify("Data refreshed!")
        end)
        
        CreateButton("Rejoin Server", Color3.fromRGB(220, 60, 60), function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end)
        
        CreateSection("ℹ️ INFO")
        CreateLabel("Game ID: 98664161516921")
        CreateLabel("Script Version: 2.0")
        CreateLabel("Auto Update: Every 5s")
        
    elseif tab == "👾 Monsters" then
        CreateSection("👾 MONSTER LIST")
        
        CreateLabel("Total: " .. table.count(MonsterDatabase))
        
        local count = 0
        for name, monster in pairs(MonsterDatabase) do
            count = count + 1
            if count <= 15 then -- Batasi 15 monster
                local dist = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and 
                            monster.HumanoidRootPart and 
                            math.floor((Player.Character.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude) or "?"
                
                local healthPercent = monster.MaxHealth > 0 and math.floor((monster.Health / monster.MaxHealth) * 100) or 0
                
                CreateButton("📍 " .. name .. " [" .. dist .. "m] HP: " .. healthPercent .. "%", Color3.fromRGB(200, 100, 100), function()
                    if monster.HumanoidRootPart then
                        Player.Character.HumanoidRootPart.CFrame = monster.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        Notify("Teleported to " .. name)
                    end
                end)
            end
        end
        
        if count > 15 then
            CreateLabel("... and " .. (count - 15) .. " more")
        end
        
    elseif tab == "🐕 Pets" then
        CreateSection("🐕 YOUR PETS")
        
        CreateLabel("Total: " .. #PetDatabase)
        
        if #PetDatabase == 0 then
            CreateLabel("No pets found")
        end
        
        for i, pet in ipairs(PetDatabase) do
            local status = pet.IsActive and "✅ Active" or "💤 Inactive"
            CreateButton("🐕 " .. pet.Name .. " | Lv." .. pet.Level .. " | " .. pet.Rarity .. " | " .. status, Color3.fromRGB(100, 200, 100), function()
                Notify("Selected: " .. pet.Name)
            end)
        end
        
    elseif tab == "⚡ Auto Farm" then
        CreateSection("⚡ AUTO FARM SETTINGS")
        
        -- Buat list monster untuk dropdown
        local monsterNames = {"All"}
        for name, _ in pairs(MonsterDatabase) do
            table.insert(monsterNames, name)
        end
        
        CreateDropdown("Target Monster", monsterNames, function(opt)
            SelectedMonster = opt
            Notify("Target: " .. opt)
        end)
        
        CreateToggle("Auto Farm", AutoFarmActive, function(state)
            AutoFarmActive = state
            if state then 
                StartAutoFarm()
                Notify("Auto Farm started")
            else 
                Notify("Auto Farm stopped")
            end
        end)
        
        CreateSection("📊 TARGET INFO")
        
        if SelectedMonster == "All" then
            local _, hrp = FindNearestMonster()
            if hrp then
                local dist = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and 
                            math.floor((Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or "?"
                CreateLabel("Nearest monster: " .. dist .. "m")
            else
                CreateLabel("No monsters nearby")
            end
        else
            local monster, hrp = FindMonsterByName(SelectedMonster)
            if monster and hrp then
                local dist = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and 
                            math.floor((Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or "?"
                CreateLabel("Distance: " .. dist .. "m")
                
                local humanoid = monster:FindFirstChild("Humanoid")
                if humanoid then
                    CreateLabel("Health: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth))
                end
            else
                CreateLabel("Target monster not found")
            end
        end
        
    elseif tab == "🌀 Teleport" then
        CreateSection("🌀 TELEPORTATION")
        
        CreateSection("📍 TELEPORT TO PLAYER")
        
        local playerNames = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                table.insert(playerNames, player.Name)
            end
        end
        
        CreateDropdown("Select Player", playerNames, function(name)
            local target = Players:FindFirstChild(name)
            if target and target.Character then
                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                Notify("Teleported to " .. name)
            end
        end)
        
        CreateSection("📍 TELEPORT TO MONSTER")
        
        local monsterNames = {"Select Monster"}
        for name, _ in pairs(MonsterDatabase) do
            table.insert(monsterNames, name)
        end
        
        CreateDropdown("Select Monster", monsterNames, function(name)
            if name ~= "Select Monster" then
                local monster, hrp = FindMonsterByName(name)
                if monster and hrp then
                    Player.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
                    Notify("Teleported to " .. name)
                end
            end
        end)
        
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
        
    elseif tab == "👁️ Visuals" then
        CreateSection("👁️ VISUAL ENHANCEMENTS")
        
        CreateToggle("Full Bright", false, function(state)
            if state then
                Lighting.Brightness = 2
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.new(1, 1, 1)
            else
                Lighting.Brightness = 1
                Lighting.GlobalShadows = true
                Lighting.Ambient = Color3.new(0, 0, 0)
            end
        end)
        
        CreateToggle("No Fog", false, function(state)
            Lighting.FogEnd = state and 1e9 or 100000
        end)
        
    elseif tab == "⚙️ Misc" then
        CreateSection("⚙️ UTILITY")
        
        CreateToggle("Anti AFK", false, function(state)
            if state then
                Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
        
        CreateSection("🎮 CONTROLS")
        
        CreateButton("Toggle Menu (F4)", Color3.fromRGB(255, 85, 85), function()
            MainFrame.Visible = not MainFrame.Visible
        end)
        
        CreateButton("Close GUI", Color3.fromRGB(200, 50, 50), function()
            ScreenGui:Destroy()
            _G.CAM_Loaded = false
        end)
        
        CreateSection("ℹ️ INFO")
        CreateLabel("Active Features: 0")
        CreateLabel("Monsters: " .. table.count(MonsterDatabase))
        CreateLabel("Pets: " .. #PetDatabase)
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Helper function untuk count table
function table.count(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

--==================================================
-- INITIALIZE
--==================================================
UpdateTab("🏠 Home")

-- Auto update setiap 5 detik untuk pets dan monsters
task.spawn(function()
    while _G.CAM_Loaded do
        task.wait(5)
        if CurrentTab == "👾 Monsters" or CurrentTab == "🐕 Pets" or CurrentTab == "⚡ Auto Farm" then
            UpdateTab(CurrentTab)
        end
    end
end)

Notify("Catch a Monster script ready!", 3)

print("========================================")
print("✅ CATCH A MONSTER SCRIPT LOADED")
print("Game ID: 98664161516921")
print("Features: Auto Farm by Name | Pet Auto Update")
print("Press F4 to toggle menu")
print("========================================")