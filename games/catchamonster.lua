-- ==================== CATCH A MONSTER - ULTIMATE SCRIPT ====================
-- Fitur: Auto Farm by Name, Teleport Area, Auto Catch, Auto Sell
-- Berdasarkan Remote yang Disediakan
-- Author: LuckyBimZy
-- Version: 2.0

if _G.CAM_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Catch a Monster",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.CAM_Loaded = true

--==================================================
-- VARIABLES
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

-- Remote Path
local RemotePath = ReplicatedStorage:WaitForChild("CommonLibrary"):WaitForChild("Tool"):WaitForChild("RemoteManager"):WaitForChild("Funcs"):WaitForChild("DataPullFunc")

-- Database monster dan area
local MonsterDatabase = {}
local AreaDatabase = {}

-- Toggles
local Toggles = {
    -- Auto Farm
    AutoFarm = false,
    SelectedMonster = "All",
    AutoTeleport = false,
    AutoAttack = false,
    AutoCatch = false,
    AutoSell = false,
    AutoEquipBestPet = false,
    AutoClaimTask = false,
    
    -- Settings
    AutoSellEnabled = false,
    AutoAttackEnabled = false,
    
    -- Visuals
    MonsterESP = false,
    PlayerESP = false,
    FullBright = false,
    
    -- Movement
    SpeedBoost = false,
    SpeedValue = 50,
    JumpBoost = false,
    JumpValue = 100,
    NoClip = false,
    FlyMode = false,
    
    -- Misc
    AntiAFK = false
}

-- Loops
local Loops = {}
local ESPConnections = {}
local FlyConnection = nil
local FlyBodyGyro = nil
local FlyBodyVelocity = nil
local NoClipConnection = nil
local SavedPosition = nil
local CurrentArea = "Unknown"
local MonsterList = {}

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

Notify("Script loaded successfully!")

--==================================================
-- REMOTE FUNCTIONS
--==================================================

-- Setting Auto Attack On/Off
function SetAutoAttack(state)
    local success, err = pcall(function()
        local args = {
            "SettingSetOnOffChannel",
            "AutoAttack",
            state
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    if success then
        Toggles.AutoAttackEnabled = state
        Notify("Auto Attack: " .. (state and "ON" or "OFF"))
    else
        Notify("Failed to set Auto Attack")
    end
end

-- Equip Best Pet
function EquipBestPet()
    local success, err = pcall(function()
        local args = {
            "PetEquipBestChannel"
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    if success then
        Notify("Best pet equipped!")
    else
        Notify("Failed to equip best pet")
    end
end

-- Auto Sell
function SetAutoSell(state)
    local success, err = pcall(function()
        local args = {
            "PetAutoSellChannel"
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    if success then
        Toggles.AutoSellEnabled = state
        Notify("Auto Sell: " .. (state and "ON" or "OFF"))
    else
        Notify("Failed to set Auto Sell")
    end
end

-- Sell Pets
function SellPets()
    local success, err = pcall(function()
        local args = {
            "PetSellChannel"
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    if success then
        Notify("Pets sold!")
    end
end

-- Attack Monster
function AttackMonster()
    local success, err = pcall(function()
        local args = {
            "MonsterAttackChannel"
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    return success
end

-- Start Catching Monster
function StartCatchMonster()
    local success, err = pcall(function()
        local args = {
            "MonsterCatchStartChannel"
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    return success
end

-- Complete Catching Monster (Instant Success)
function CompleteCatchMonster()
    local success, err = pcall(function()
        local args = {
            "MonsterCatchCompleteChannel"
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    return success
end

-- Teleport to Area/Region
function TeleportToRegion(region)
    local success, err = pcall(function()
        local args = {
            "AreaTeleportToRegionChannel",
            region
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    if success then
        Notify("Teleported to " .. tostring(region))
    end
    return success
end

-- Claim Task Reward
function ClaimTaskReward()
    local success, err = pcall(function()
        local args = {
            "TaskClaimRewardChannel"
        }
        RemotePath:InvokeServer(unpack(args))
    end)
    if success then
        Notify("Task reward claimed!")
    end
    return success
end

--==================================================
-- SCAN AREA DAN MONSTER
--==================================================

-- Scan semua area yang tersedia
function ScanAreas()
    local areas = {}
    
    -- Cari area dari Workspace atau dari data game
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:find("Area") or v.Name:find("Region") or v.Name:find("Zone") then
            if not areas[v.Name] then
                areas[v.Name] = {
                    Name = v.Name,
                    Position = v:IsA("BasePart") and v.Position or nil,
                    CFrame = v:IsA("BasePart") and v.CFrame or nil
                }
            end
        end
    end
    
    -- Update database
    AreaDatabase = areas
    return areas
end

-- Scan semua monster di semua area
function ScanAllMonsters()
    local monsters = {}
    local monsterNames = {"All"} -- Default untuk "All" option
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            -- Deteksi monster berdasarkan berbagai kriteria
            local isMonster = false
            local monsterName = v.Name
            
            -- Cek berdasarkan nama umum monster
            if monsterName:find("Monster") or 
               monsterName:find("Enemy") or 
               monsterName:find("Creature") or
               monsterName:find("Boss") or
               monsterName:find("Slime") or
               monsterName:find("Dragon") or
               monsterName:find("Goblin") or
               monsterName:find("Orc") or
               monsterName:find("Troll") or
               monsterName:find("Wolf") or
               monsterName:find("Bear") or
               monsterName:find("Spider") then
                isMonster = true
            end
            
            -- Cek berdasarkan komponen
            if v:FindFirstChild("Humanoid") or 
               v:FindFirstChild("Monster") or 
               v:FindFirstChild("Enemy") or
               v:FindFirstChild("Health") then
                isMonster = true
            end
            
            if isMonster and not monsters[monsterName] then
                monsters[monsterName] = true
                table.insert(monsterNames, monsterName)
                
                -- Simpan data monster
                local hrp = v:FindFirstChild("HumanoidRootPart") or 
                           v:FindFirstChild("Torso") or 
                           v:FindFirstChild("UpperTorso")
                
                MonsterDatabase[monsterName] = {
                    Name = monsterName,
                    Model = v,
                    HumanoidRootPart = hrp,
                    Position = hrp and hrp.Position or nil,
                    CFrame = hrp and hrp.CFrame or nil,
                    Health = v:FindFirstChild("Humanoid") and v.Humanoid.Health or 0,
                    MaxHealth = v:FindFirstChild("Humanoid") and v.Humanoid.MaxHealth or 0
                }
            end
        end
    end
    
    MonsterList = monsterNames
    return monsterNames
end

-- Cari monster berdasarkan nama
function FindMonsterByName(name)
    if name == "All" then
        return FindNearestMonster()
    end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == name then
            local hrp = v:FindFirstChild("HumanoidRootPart") or 
                       v:FindFirstChild("Torso") or 
                       v:FindFirstChild("UpperTorso")
            if hrp then
                return v, hrp
            end
        end
    end
    return nil, nil
end

-- Cari monster terdekat
function FindNearestMonster()
    local nearest = nil
    local nearestHrp = nil
    local dist = math.huge
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local hrp = v:FindFirstChild("HumanoidRootPart") or 
                       v:FindFirstChild("Torso") or 
                       v:FindFirstChild("UpperTorso")
            if hrp then
                -- Cek apakah ini monster
                local isMonster = v.Name:find("Monster") or 
                                 v.Name:find("Enemy") or 
                                 v.Name:find("Creature") or
                                 v:FindFirstChild("Humanoid") or
                                 v:FindFirstChild("Monster")
                
                if isMonster then
                    local d = (root.Position - hrp.Position).Magnitude
                    if d < dist then
                        dist = d
                        nearest = v
                        nearestHrp = hrp
                    end
                end
            end
        end
    end
    
    return nearest, nearestHrp
end

--==================================================
-- AUTO FARM BY NAME - DENGAN TELEPORT AREA
--==================================================
function StartAutoFarm()
    if Loops["AutoFarm"] then return end
    Loops["AutoFarm"] = true
    
    task.spawn(function()
        local lastAttack = 0
        local lastCatch = 0
        local lastTeleport = 0
        
        while Loops["AutoFarm"] and Toggles.AutoFarm do
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            
            local targetMonster = nil
            local targetHrp = nil
            
            -- Cari monster berdasarkan yang dipilih
            if Toggles.SelectedMonster and Toggles.SelectedMonster ~= "All" then
                targetMonster, targetHrp = FindMonsterByName(Toggles.SelectedMonster)
            else
                targetMonster, targetHrp = FindNearestMonster()
            end
            
            if targetMonster and targetHrp then
                local distance = (Player.Character.HumanoidRootPart.Position - targetHrp.Position).Magnitude
                
                -- Teleport ke monster jika Auto Teleport aktif dan jarak jauh
                if Toggles.AutoTeleport and distance > 20 then
                    if tick() - lastTeleport > 2 then -- Cooldown teleport
                        Player.Character.HumanoidRootPart.CFrame = targetHrp.CFrame * CFrame.new(0, 3, 0)
                        lastTeleport = tick()
                        task.wait(0.3)
                    end
                end
                
                -- Auto Attack
                if Toggles.AutoAttack then
                    if tick() - lastAttack > 0.5 then -- Cooldown attack
                        AttackMonster()
                        lastAttack = tick()
                    end
                end
                
                -- Auto Catch
                if Toggles.AutoCatch then
                    if distance < 15 then
                        if tick() - lastCatch > 1 then -- Cooldown catch
                            StartCatchMonster()
                            task.wait(0.2)
                            CompleteCatchMonster() -- Instant success
                            lastCatch = tick()
                        end
                    end
                end
                
                -- Auto Equip Best Pet
                if Toggles.AutoEquipBestPet then
                    EquipBestPet()
                end
            end
            
            -- Auto Sell
            if Toggles.AutoSell then
                SellPets()
            end
            
            -- Auto Claim Task
            if Toggles.AutoClaimTask then
                ClaimTaskReward()
            end
            
            task.wait(0.3)
        end
    end)
end

--==================================================
-- CREATE MODERN UI
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
ScreenGui.DisplayOrder = 999

-- Floating Button
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatBtn"
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -25)
FloatBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
FloatBtn.Text = "🐾"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextSize = 24
FloatBtn.Font = Enum.Font.Gotham
FloatBtn.BorderSizePixel = 0
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui

-- Rounded corners
local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 25)
FloatCorner.Parent = FloatBtn

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 600)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Main corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 55)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Icon
local IconFrame = Instance.new("Frame")
IconFrame.Size = UDim2.new(0, 35, 0, 35)
IconFrame.Position = UDim2.new(0, 15, 0.5, -17.5)
IconFrame.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
IconFrame.BorderSizePixel = 0
IconFrame.Parent = TitleBar

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 10)
IconCorner.Parent = IconFrame

local IconLabel = Instance.new("TextLabel")
IconLabel.Size = UDim2.new(1, 0, 1, 0)
IconLabel.BackgroundTransparency = 1
IconLabel.Text = "🐾"
IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IconLabel.TextSize = 20
IconLabel.Font = Enum.Font.Gotham
IconLabel.Parent = IconFrame

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 250, 0, 25)
TitleText.Position = UDim2.new(0, 60, 0.5, -12.5)
TitleText.BackgroundTransparency = 1
TitleText.Text = "CATCH A MONSTER"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Version
local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 50, 0, 20)
VersionText.Position = UDim2.new(0, 60, 0.5, 8)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v2.0"
VersionText.TextColor3 = Color3.fromRGB(180, 180, 180)
VersionText.TextSize = 11
VersionText.Font = Enum.Font.Gotham
VersionText.TextXAlignment = Enum.TextXAlignment.Left
VersionText.Parent = TitleBar

-- Control buttons
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 60, 0, 30)
ControlFrame.Position = UDim2.new(1, -70, 0.5, -15)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(0, 0, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 55)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = ControlFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0, 32, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = ControlFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.CAM_Loaded = false
end)

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 45)
TabFrame.Position = UDim2.new(0, 10, 0, 60)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"Auto Farm", "Monsters", "Settings", "Teleport", "Movement", "Misc"}
local TabIcons = {"⚡", "👾", "⚙️", "🌀", "🏃", "🔧"}
local TabButtons = {}
local CurrentTab = "Auto Farm"

for i = 1, #Tabs do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 68, 0, 45)
    TabBtn.Position = UDim2.new(0, (i-1) * 70, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
    TabBtn.Text = TabIcons[i] .. " " .. Tabs[i]
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.Gotham
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
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 85)}):Play()
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        UpdateTab(Tabs[i])
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Set first tab active
TabButtons[1].BackgroundColor3 = Color3.fromRGB(255, 70, 85)
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- Content Area
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -120)
ContentFrame.Position = UDim2.new(0, 10, 0, 110)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- Scrolling frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 70, 85)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

--==================================================
-- UI ELEMENTS FUNCTIONS
--==================================================

function CreateSection(title)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 30)
    Section.BackgroundTransparency = 1
    Section.Text = "  " .. title
    Section.TextColor3 = Color3.fromRGB(255, 70, 85)
    Section.TextSize = 14
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -10, 0, 1)
    Line.Position = UDim2.new(0, 5, 0, 28)
    Line.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section
end

function CreateToggle(text, var, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, -15, 1, 0)
    ToggleText.Position = UDim2.new(0, 15, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 13
    ToggleText.Font = Enum.Font.Gotham
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 70, 0, 28)
    ToggleBtn.Position = UDim2.new(1, -85, 0.5, -14)
    ToggleBtn.BackgroundColor3 = var and Color3.fromRGB(255, 70, 85) or Color3.fromRGB(50, 45, 50)
    ToggleBtn.Text = var and "ON" or "OFF"
    ToggleBtn.TextColor3 = var and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 100, 100)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        local newState = not var
        if newState then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(255, 70, 85),
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
        callback(newState)
    end)
end

function CreateButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = color or Color3.fromRGB(255, 70, 85)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Parent = ScrollingFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
end

function CreateDropdown(text, options, current, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Parent = ScrollingFrame
    DropdownFrame.ZIndex = 5
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -15, 1, 0)
    DropdownText.Position = UDim2.new(0, 15, 0, 0)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 13
    DropdownText.Font = Enum.Font.Gotham
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    DropdownText.ZIndex = 5
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 140, 0, 28)
    DropdownBtn.Position = UDim2.new(1, -155, 0.5, -14)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 40, 45)
    DropdownBtn.Text = current
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 12
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Parent = DropdownFrame
    DropdownBtn.ZIndex = 5
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        local oldMenu = DropdownFrame:FindFirstChild("DropdownMenu")
        if oldMenu then oldMenu:Destroy() end
        
        local menu = Instance.new("Frame")
        menu.Name = "DropdownMenu"
        menu.Size = UDim2.new(0, 160, 0, math.min(#options, 6) * 35)
        menu.Position = UDim2.new(1, -155, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(40, 35, 40)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        menu.ZIndex = 10
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 6)
        menuCorner.Parent = menu
        
        local menuList = Instance.new("ScrollingFrame")
        menuList.Size = UDim2.new(1, -2, 1, -2)
        menuList.Position = UDim2.new(0, 1, 0, 1)
        menuList.BackgroundTransparency = 1
        menuList.ScrollBarThickness = 4
        menuList.CanvasSize = UDim2.new(0, 0, 0, #options * 35)
        menuList.Parent = menu
        menuList.ZIndex = 11
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 35)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 35)
            optBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 50)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextSize = 12
            optBtn.Font = Enum.Font.Gotham
            optBtn.BorderSizePixel = 0
            optBtn.Parent = menuList
            optBtn.ZIndex = 12
            
            optBtn.MouseEnter:Connect(function()
                optBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 60)
            end)
            
            optBtn.MouseLeave:Connect(function()
                optBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 50)
            end)
            
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
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 12
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
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.5, -15, 0, 20)
    SliderText.Position = UDim2.new(0, 15, 0, 8)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 13
    SliderText.Font = Enum.Font.Gotham
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueBox = Instance.new("TextBox")
    ValueBox.Size = UDim2.new(0, 60, 0, 24)
    ValueBox.Position = UDim2.new(1, -75, 0, 6)
    ValueBox.BackgroundColor3 = Color3.fromRGB(45, 40, 45)
    ValueBox.Text = tostring(value)
    ValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueBox.TextSize = 12
    ValueBox.Font = Enum.Font.GothamBold
    ValueBox.ClearTextOnFocus = false
    ValueBox.Parent = SliderFrame
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 4)
    ValueCorner.Parent = ValueBox
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 6)
    SliderBg.Position = UDim2.new(0, 10, 0, 40)
    SliderBg.BackgroundColor3 = Color3.fromRGB(45, 40, 45)
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
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
    
    if tab == "Auto Farm" then
        CreateSection("⚡ AUTO FARM SETTINGS")
        
        -- Scan monsters
        local monsterList = ScanAllMonsters()
        
        CreateToggle("Auto Farm", Toggles.AutoFarm, function(state)
            Toggles.AutoFarm = state
            if state then 
                StartAutoFarm()
                Notify("Auto Farm started")
            else 
                Loops["AutoFarm"] = false
                Notify("Auto Farm stopped")
            end
        end)
        
        CreateDropdown("Target Monster", monsterList, Toggles.SelectedMonster or "All", function(opt)
            Toggles.SelectedMonster = opt
            Notify("Target: " .. opt)
        end)
        
        CreateSection("⚡ AUTO ACTIONS")
        
        CreateToggle("Auto Teleport to Monster", Toggles.AutoTeleport, function(state)
            Toggles.AutoTeleport = state
        end)
        
        CreateToggle("Auto Attack", Toggles.AutoAttack, function(state)
            Toggles.AutoAttack = state
            SetAutoAttack(state)
        end)
        
        CreateToggle("Auto Catch (Instant)", Toggles.AutoCatch, function(state)
            Toggles.AutoCatch = state
        end)
        
        CreateToggle("Auto Equip Best Pet", Toggles.AutoEquipBestPet, function(state)
            Toggles.AutoEquipBestPet = state
            if state then EquipBestPet() end
        end)
        
        CreateToggle("Auto Sell", Toggles.AutoSell, function(state)
            Toggles.AutoSell = state
            SetAutoSell(state)
        end)
        
        CreateToggle("Auto Claim Task", Toggles.AutoClaimTask, function(state)
            Toggles.AutoClaimTask = state
        end)
        
        CreateSection("📊 CURRENT STATUS")
        
        local nearest, hrp = FindNearestMonster()
        if nearest then
            local dist = hrp and (Player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude or 0
            CreateLabel("Nearest: " .. nearest.Name)
            CreateLabel("Distance: " .. math.floor(dist) .. "m")
        else
            CreateLabel("No monsters nearby")
        end
        
    elseif tab == "Monsters" then
        CreateSection("👾 MONSTER LIST")
        
        CreateButton("Refresh Monster List", Color3.fromRGB(255, 70, 85), function()
            UpdateTab("Monsters")
        end)
        
        -- Tampilkan daftar monster dengan tombol teleport
        for i = 2, #MonsterList do
            local monsterName = MonsterList[i]
            CreateButton("📍 Teleport to " .. monsterName, Color3.fromRGB(100, 100, 200), function()
                local monster, hrp = FindMonsterByName(monsterName)
                if monster and hrp then
                    Player.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
                    Notify("Teleported to " .. monsterName)
                end
            end)
        end
        
    elseif tab == "Settings" then
        CreateSection("⚙️ GAME SETTINGS")
        
        CreateButton("Equip Best Pet", Color3.fromRGB(255, 70, 85), function()
            EquipBestPet()
        end)
        
        CreateButton("Sell Pets", Color3.fromRGB(200, 100, 100), function()
            SellPets()
        end)
        
        CreateButton("Claim Task Reward", Color3.fromRGB(100, 200, 100), function()
            ClaimTaskReward()
        end)
        
        CreateSection("🎮 MANUAL CONTROLS")
        
        CreateButton("Attack Monster", Color3.fromRGB(200, 50, 50), function()
            AttackMonster()
        end)
        
        CreateButton("Start Catch", Color3.fromRGB(50, 150, 200), function()
            StartCatchMonster()
        end)
        
        CreateButton("Complete Catch", Color3.fromRGB(50, 200, 50), function()
            CompleteCatchMonster()
        end)
        
    elseif tab == "Teleport" then
        CreateSection("🌀 TELEPORTATION")
        
        CreateToggle("Fly Mode", Toggles.FlyMode, function(state)
            Toggles.FlyMode = state
            Notify(state and "Fly Mode ON" or "Fly Mode OFF")
        end)
        
        CreateToggle("NoClip", Toggles.NoClip, function(state)
            Toggles.NoClip = state
            Notify(state and "NoClip ON" or "NoClip OFF")
        end)
        
        CreateSection("📍 SAVE POSITION")
        
        CreateButton("Save Current Position", Color3.fromRGB(0, 200, 100), function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                SavedPosition = Player.Character.HumanoidRootPart.CFrame
                Notify("Position saved!")
            end
        end)
        
        CreateButton("Load Saved Position", Color3.fromRGB(255, 70, 85), function()
            if SavedPosition then
                Player.Character.HumanoidRootPart.CFrame = SavedPosition
                Notify("Teleported to saved position")
            end
        end)
        
    elseif tab == "Movement" then
        CreateSection("🏃 MOVEMENT")
        
        CreateToggle("Speed Boost", Toggles.SpeedBoost, function(state)
            Toggles.SpeedBoost = state
            if state then
                Player.Character.Humanoid.WalkSpeed = Toggles.SpeedValue
            else
                Player.Character.Humanoid.WalkSpeed = 16
            end
        end)
        
        CreateSlider("Speed", 16, 200, Toggles.SpeedValue, function(val)
            Toggles.SpeedValue = val
            if Toggles.SpeedBoost then
                Player.Character.Humanoid.WalkSpeed = val
            end
        end)
        
        CreateToggle("Jump Boost", Toggles.JumpBoost, function(state)
            Toggles.JumpBoost = state
            if state then
                Player.Character.Humanoid.JumpPower = Toggles.JumpValue
            else
                Player.Character.Humanoid.JumpPower = 50
            end
        end)
        
        CreateSlider("Jump", 50, 200, Toggles.JumpValue, function(val)
            Toggles.JumpValue = val
            if Toggles.JumpBoost then
                Player.Character.Humanoid.JumpPower = val
            end
        end)
        
    elseif tab == "Misc" then
        CreateSection("🔧 UTILITY")
        
        CreateToggle("Anti AFK", Toggles.AntiAFK, function(state)
            Toggles.AntiAFK = state
            if state then
                Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
        
        CreateSection("🎮 CONTROLS")
        
        CreateButton("Toggle Menu (F4)", Color3.fromRGB(255, 70, 85), function()
            MainFrame.Visible = not MainFrame.Visible
        end)
        
        CreateButton("Emergency Stop", Color3.fromRGB(220, 60, 60), function()
            for k, _ in pairs(Loops) do
                Loops[k] = false
            end
            Toggles.AutoFarm = false
            Notify("All features stopped")
        end)
        
        CreateButton("Close GUI", Color3.fromRGB(150, 50, 50), function()
            ScreenGui:Destroy()
            _G.CAM_Loaded = false
        end)
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- INITIALIZE
--==================================================
UpdateTab("Auto Farm")
Notify("Catch a Monster Script loaded! Press F4", 3)

print("=== CATCH A MONSTER ULTIMATE SCRIPT v2.0 ===")
print("Press F4 to toggle menu")
print("Auto Farm by Name - Ready!")