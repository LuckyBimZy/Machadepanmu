-- ==================== CATCH A MONSTER - ULTIMATE AUTO FARM ====================
-- Script Lengkap dengan Auto Farm by Pet Name & Teleport
-- Author: LuckyBimZy
-- Version: 3.0 (Complete)

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

-- Path ke RemoteManager
local RemoteManager = ReplicatedStorage:WaitForChild("CommonLibrary"):WaitForChild("Tool"):WaitForChild("RemoteManager"):WaitForChild("Funcs"):WaitForChild("DataPullFunc")

--==================================================
-- DATABASE PET & MONSTER (AUTO SCAN)
--==================================================
local PetDatabase = {}
local MonsterDatabase = {}
local AreaDatabase = {}

-- Fungsi untuk scan area dan pet di dalamnya
function ScanAreaForPets()
    local areas = {}
    local pets = {}
    
    -- Scan semua area di workspace
    for _, area in pairs(Workspace:GetDescendants()) do
        if area.Name:find("Area") or area.Name:find("Zone") or area.Name:find("Region") then
            -- Simpan area
            table.insert(areas, {
                Name = area.Name,
                Instance = area,
                Position = area:IsA("BasePart") and area.Position or 
                          (area:FindFirstChild("HumanoidRootPart") and area.HumanoidRootPart.Position) or
                          (area:FindFirstChild("Part") and area.Part.Position)
            })
            
            -- Scan pets di dalam area
            for _, pet in pairs(area:GetDescendants()) do
                if pet:IsA("Model") and (pet.Name:find("Pet") or pet:FindFirstChild("Pet")) then
                    local hrp = pet:FindFirstChild("HumanoidRootPart") or pet:FindFirstChild("Torso") or pet:FindFirstChild("Head")
                    if hrp then
                        table.insert(pets, {
                            Name = pet.Name,
                            Instance = pet,
                            Position = hrp.Position,
                            HumanoidRootPart = hrp,
                            Area = area.Name,
                            Level = pet:GetAttribute("Level") or 1,
                            Rarity = pet:GetAttribute("Rarity") or "Common"
                        })
                    end
                end
            end
        end
    end
    
    AreaDatabase = areas
    PetDatabase = pets
    return pets, areas
end

-- Scan monster di semua area
function ScanMonsters()
    local monsters = {}
    
    for _, pet in pairs(PetDatabase) do
        -- Cari monster di sekitar pet
        local radius = 50
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v ~= pet.Instance then
                local hrp = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                if hrp and pet.Position then
                    local dist = (pet.Position - hrp.Position).Magnitude
                    if dist < radius then
                        if v.Name:find("Monster") or v:FindFirstChild("Humanoid") then
                            table.insert(monsters, {
                                Name = v.Name,
                                Instance = v,
                                Position = hrp.Position,
                                HumanoidRootPart = hrp,
                                Distance = dist,
                                Pet = pet.Name
                            })
                        end
                    end
                end
            end
        end
    end
    
    MonsterDatabase = monsters
    return monsters
end

-- Auto scan setiap 5 detik
task.spawn(function()
    while _G.CAM_Loaded do
        ScanAreaForPets()
        ScanMonsters()
        task.wait(5)
    end
end)

--==================================================
-- FUNGSI REMOTE CALL
--==================================================
local function CallRemote(channel, ...)
    local args = {channel, ...}
    local success, result = pcall(function()
        return RemoteManager:InvokeServer(unpack(args))
    end)
    return success, result
end

--==================================================
-- AUTO FARM BY PET NAME
--==================================================
local AutoFarmActive = false
local SelectedPet = nil
local AutoAttackActive = false
local AutoCatchActive = false
local AutoSellActive = false
local AutoEquipBest = false
local AutoClaimTask = false

function StartAutoFarm()
    AutoFarmActive = true
    
    task.spawn(function()
        while AutoFarmActive do
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            
            -- 1. Equip best pet otomatis
            if AutoEquipBest then
                CallRemote("PetEquipBestChannel")
                task.wait(0.5)
            end
            
            -- 2. Cari pet target
            local targetPet = nil
            if SelectedPet then
                for _, pet in ipairs(PetDatabase) do
                    if pet.Name == SelectedPet then
                        targetPet = pet
                        break
                    end
                end
            else
                -- Jika tidak ada pet dipilih, ambil pet pertama
                targetPet = PetDatabase[1]
            end
            
            if targetPet and targetPet.Position then
                -- 3. Teleport ke area pet
                local root = Player.Character.HumanoidRootPart
                local distToPet = (root.Position - targetPet.Position).Magnitude
                
                if distToPet > 20 then
                    -- Teleport ke pet
                    root.CFrame = CFrame.new(targetPet.Position) * CFrame.new(0, 3, 0)
                    task.wait(0.3)
                end
                
                -- 4. Cari monster terdekat dari pet
                local nearestMonster = nil
                local nearestDist = math.huge
                
                for _, monster in ipairs(MonsterDatabase) do
                    if monster.Pet == targetPet.Name then
                        local dist = (root.Position - monster.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestMonster = monster
                        end
                    end
                end
                
                if nearestMonster then
                    -- 5. Teleport ke monster
                    if nearestDist > 10 then
                        root.CFrame = CFrame.new(nearestMonster.Position) * CFrame.new(0, 3, 0)
                        task.wait(0.2)
                    end
                    
                    -- 6. Auto attack
                    if AutoAttackActive then
                        CallRemote("MonsterAttackChannel")
                        task.wait(0.2)
                    end
                    
                    -- 7. Auto catch
                    if AutoCatchActive then
                        CallRemote("MonsterCatchStartChannel")
                        task.wait(0.3)
                        CallRemote("MonsterCatchCompleteChannel")
                        task.wait(0.2)
                    end
                end
            end
            
            -- 8. Auto sell
            if AutoSellActive then
                CallRemote("PetAutoSellChannel")
                CallRemote("PetSellChannel")
            end
            
            -- 9. Auto claim task
            if AutoClaimTask then
                CallRemote("TaskClaimRewardChannel")
            end
            
            task.wait(0.5)
        end
    end)
end

--==================================================
-- TELEPORT KE AREA
--==================================================
function TeleportToArea(areaName)
    for _, area in ipairs(AreaDatabase) do
        if area.Name == areaName or areaName == "All" then
            if area.Position then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(area.Position) * CFrame.new(0, 3, 0)
                CallRemote("AreaTeleportToRegionChannel", area.Name)
                return true
            end
        end
    end
    return false
end

--==================================================
-- CREATE UI
--==================================================

-- Hapus GUI lama
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "CAM_Ultimate" then v:Destroy() end
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CAM_Ultimate"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Floating Button
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

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 27)
FloatCorner.Parent = FloatBtn

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 650)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 20, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "CATCH A MONSTER - AUTO FARM"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -80, 0.5, -17.5)
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
CloseBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
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
end)

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 50)
TabFrame.Position = UDim2.new(0, 10, 0, 65)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"🏠 Home", "🐕 Pets", "⚡ Auto Farm", "🌀 Teleport", "⚙️ Settings"}
local TabButtons = {}
local CurrentTab = "🏠 Home"

for i = 1, #Tabs do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 90, 0, 50)
    TabBtn.Position = UDim2.new(0, (i-1) * 92, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
    TabBtn.Text = Tabs[i]
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = TabBtn
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = Tabs[i]
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        UpdateTab(Tabs[i])
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Content Area
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -130)
ContentFrame.Position = UDim2.new(0, 10, 0, 120)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 12)
ContentCorner.Parent = ContentFrame

-- Scrolling Frame
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
    Section.Size = UDim2.new(1, 0, 0, 35)
    Section.BackgroundTransparency = 1
    Section.Text = "  " .. title
    Section.TextColor3 = Color3.fromRGB(255, 85, 85)
    Section.TextSize = 16
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
end

function CreateToggle(text, var, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
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
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
            ToggleBtn.Text = "ON"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 45, 50)
            ToggleBtn.Text = "OFF"
            ToggleBtn.TextColor3 = Color3.fromRGB(200, 100, 100)
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
    BtnCorner.CornerRadius = UDim.new(0, 10)
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
    DropdownCorner.CornerRadius = UDim.new(0, 10)
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
    DropdownBtn.Size = UDim2.new(0, 150, 0, 30)
    DropdownBtn.Position = UDim2.new(1, -165, 0.5, -15)
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
        menu.Size = UDim2.new(0, 170, 0, math.min(#options, 6) * 35)
        menu.Position = UDim2.new(1, -165, 1, 5)
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
    ScanAreaForPets()
    ScanMonsters()
    
    if tab == "🏠 Home" then
        CreateSection("📊 DASHBOARD")
        CreateLabel("Player: " .. Player.Name)
        CreateLabel("Server: " .. game.JobId:sub(1, 10) .. "...")
        CreateLabel("Players: " .. #Players:GetPlayers())
        
        CreateSection("📈 STATISTICS")
        CreateLabel("Areas: " .. #AreaDatabase)
        CreateLabel("Pets Found: " .. #PetDatabase)
        CreateLabel("Monsters: " .. #MonsterDatabase)
        
        CreateSection("🎮 QUICK ACTIONS")
        CreateButton("🔄 Refresh Data", Color3.fromRGB(100, 100, 200), function()
            UpdateTab("🏠 Home")
        end)
        
        CreateButton("⚡ Start Auto Farm", Color3.fromRGB(255, 85, 85), function()
            AutoFarmActive = true
            StartAutoFarm()
            UpdateTab("⚡ Auto Farm")
        end)
        
    elseif tab == "🐕 Pets" then
        CreateSection("🐕 PETS DATABASE")
        CreateLabel("Total: " .. #PetDatabase .. " pets ditemukan")
        
        if #PetDatabase == 0 then
            CreateLabel("Tidak ada pet ditemukan")
        end
        
        for i, pet in ipairs(PetDatabase) do
            CreateButton("🐕 " .. pet.Name .. " | Lv." .. pet.Level .. " | " .. pet.Rarity .. " | Area: " .. (pet.Area or "Unknown"), Color3.fromRGB(100, 200, 100), function()
                SelectedPet = pet.Name
                Notify("Selected pet: " .. pet.Name)
                
                -- Teleport ke pet
                if pet.Position then
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(pet.Position) * CFrame.new(0, 3, 0)
                end
            end)
        end
        
    elseif tab == "⚡ Auto Farm" then
        CreateSection("⚡ AUTO FARM SETTINGS")
        
        -- List pets untuk dropdown
        local petNames = {"Pilih Pet"}
        for _, pet in ipairs(PetDatabase) do
            table.insert(petNames, pet.Name)
        end
        
        CreateDropdown("Target Pet", petNames, function(opt)
            if opt ~= "Pilih Pet" then
                SelectedPet = opt
                Notify("Target pet: " .. opt)
            end
        end)
        
        CreateToggle("Auto Attack", AutoAttackActive, function(state)
            AutoAttackActive = state
            CallRemote("SettingSetOnOffChannel", "AutoAttack", state)
        end)
        
        CreateToggle("Auto Catch", AutoCatchActive, function(state)
            AutoCatchActive = state
        end)
        
        CreateToggle("Auto Sell", AutoSellActive, function(state)
            AutoSellActive = state
            if state then
                CallRemote("PetAutoSellChannel")
            end
        end)
        
        CreateToggle("Equip Best Pet", AutoEquipBest, function(state)
            AutoEquipBest = state
            if state then
                CallRemote("PetEquipBestChannel")
            end
        end)
        
        CreateToggle("Auto Claim Task", AutoClaimTask, function(state)
            AutoClaimTask = state
        end)
        
        CreateSection("🎯 CONTROL")
        CreateButton("▶️ START AUTO FARM", Color3.fromRGB(0, 200, 0), function()
            AutoFarmActive = true
            StartAutoFarm()
            Notify("Auto Farm Started - Target: " .. (SelectedPet or "All Pets"))
        end)
        
        CreateButton("⏹️ STOP AUTO FARM", Color3.fromRGB(200, 0, 0), function()
            AutoFarmActive = false
            CallRemote("SettingSetOnOffChannel", "AutoAttack", false)
            Notify("Auto Farm Stopped")
        end)
        
        CreateSection("📊 STATUS")
        CreateLabel("Target Pet: " .. (SelectedPet or "None"))
        CreateLabel("Pets Available: " .. #PetDatabase)
        CreateLabel("Monsters Nearby: " .. #MonsterDatabase)
        
    elseif tab == "🌀 Teleport" then
        CreateSection("🌀 TELEPORT MENU")
        
        -- Teleport ke pet
        CreateSection("📍 TELEPORT KE PET")
        local petNames = {"Pilih Pet"}
        for _, pet in ipairs(PetDatabase) do
            table.insert(petNames, pet.Name)
        end
        
        CreateDropdown("Pilih Pet", petNames, function(opt)
            if opt ~= "Pilih Pet" then
                for _, pet in ipairs(PetDatabase) do
                    if pet.Name == opt and pet.Position then
                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(pet.Position) * CFrame.new(0, 3, 0)
                        Notify("Teleport ke " .. opt)
                        break
                    end
                end
            end
        end)
        
        -- Teleport ke area
        CreateSection("📍 TELEPORT KE AREA")
        local areaNames = {"Pilih Area"}
        for _, area in ipairs(AreaDatabase) do
            table.insert(areaNames, area.Name)
        end
        
        CreateDropdown("Pilih Area", areaNames, function(opt)
            if opt ~= "Pilih Area" then
                if TeleportToArea(opt) then
                    Notify("Teleport ke area: " .. opt)
                end
            end
        end)
        
        -- Teleport ke player
        CreateSection("📍 TELEPORT KE PLAYER")
        local playerNames = {"Pilih Player"}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                table.insert(playerNames, player.Name)
            end
        end
        
        CreateDropdown("Pilih Player", playerNames, function(opt)
            if opt ~= "Pilih Player" then
                local target = Players:FindFirstChild(opt)
                if target and target.Character then
                    Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    Notify("Teleport ke " .. opt)
                end
            end
        end)
        
        CreateSection("📍 WAYPOINT")
        CreateButton("💾 Save Current Position", Color3.fromRGB(0, 200, 0), function()
            if Player.Character then
                _G.SavedPosition = Player.Character.HumanoidRootPart.CFrame
                Notify("Position saved!")
            end
        end)
        
        CreateButton("📌 Load Saved Position", Color3.fromRGB(255, 165, 0), function()
            if _G.SavedPosition then
                Player.Character.HumanoidRootPart.CFrame = _G.SavedPosition
                Notify("Teleported to saved position")
            end
        end)
        
    elseif tab == "⚙️ Settings" then
        CreateSection("⚙️ SETTINGS")
        
        CreateButton("🔄 Refresh Database", Color3.fromRGB(100, 100, 200), function()
            ScanAreaForPets()
            ScanMonsters()
            Notify("Database refreshed! Pets: " .. #PetDatabase .. ", Areas: " .. #AreaDatabase)
            UpdateTab("⚙️ Settings")
        end)
        
        CreateButton("🎮 Toggle Menu (F4)", Color3.fromRGB(255, 85, 85), function()
            MainFrame.Visible = not MainFrame.Visible
        end)
        
        CreateButton("❌ Close GUI", Color3.fromRGB(200, 50, 50), function()
            ScreenGui:Destroy()
            _G.CAM_Loaded = false
        end)
        
        CreateSection("ℹ️ INFO")
        CreateLabel("Game: Catch a Monster")
        CreateLabel("Version: 3.0")
        CreateLabel("Status: Running")
        CreateLabel("Auto Farm: " .. (AutoFarmActive and "✅ Active" or "⭕ Inactive"))
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- NOTIFICATION FUNCTION
--==================================================
function Notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Catch a Monster",
        Text = msg,
        Duration = 2
    })
end

--==================================================
-- INITIALIZE
--==================================================
UpdateTab("🏠 Home")
Notify("Script loaded! Press F4 to open menu")

print("========================================")
print("✅ CATCH A MONSTER - ULTIMATE AUTO FARM")
print("Press F4 to toggle menu")
print("Auto Farm by Pet Name ready!")
print("Found " .. #PetDatabase .. " pets in database")
print("========================================")