-- ==================== CATCH A MONSTER - ULTIMATE AUTO FARM ====================
-- Script Lengkap dengan Auto Farm by Pet Name & Teleport
-- Author: LuckyBimZy
-- Version: 4.0 (FULLY FIXED)

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
    local areaList = {}
    
    print("🔍 Scanning for areas and pets...")
    
    -- Scan semua area di workspace
    for _, v in pairs(Workspace:GetDescendants()) do
        -- Deteksi area
        if v:IsA("Model") or v:IsA("Part") then
            local isArea = false
            local areaName = ""
            
            -- Cek berbagai kemungkinan nama area
            if v.Name:find("Area") or v.Name:find("Zone") or v.Name:find("Region") or 
               v.Name:find("Spawn") or v.Name:find("Location") then
                isArea = true
                areaName = v.Name
            end
            
            -- Cek attribute
            if v:GetAttribute("Area") or v:GetAttribute("Zone") then
                isArea = true
                areaName = v:GetAttribute("Area") or v:GetAttribute("Zone") or v.Name
            end
            
            if isArea and not areaList[areaName] then
                areaList[areaName] = true
                local position = v:IsA("BasePart") and v.Position or 
                                 (v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position) or
                                 (v:FindFirstChild("Part") and v.Part.Position)
                
                table.insert(areas, {
                    Name = areaName,
                    Instance = v,
                    Position = position
                })
                print("✅ Area ditemukan: " .. areaName)
            end
        end
        
        -- Deteksi pet (model dengan nama mengandung "Pet")
        if v:IsA("Model") and (v.Name:find("Pet") or v:FindFirstChild("Pet")) then
            local hrp = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso") or v:FindFirstChild("Head")
            if hrp then
                local petData = {
                    Name = v.Name,
                    Instance = v,
                    Position = hrp.Position,
                    HumanoidRootPart = hrp,
                    Area = "Unknown",
                    Level = v:GetAttribute("Level") or 1,
                    Rarity = v:GetAttribute("Rarity") or "Common"
                }
                
                -- Cari area pet ini
                for _, area in ipairs(areas) do
                    if area.Position and hrp.Position then
                        local dist = (area.Position - hrp.Position).Magnitude
                        if dist < 100 then
                            petData.Area = area.Name
                            break
                        end
                    end
                end
                
                table.insert(pets, petData)
                print("🐕 Pet ditemukan: " .. v.Name .. " di area " .. petData.Area)
            end
        end
    end
    
    AreaDatabase = areas
    PetDatabase = pets
    print("✅ Scan selesai. Ditemukan " .. #areas .. " area dan " .. #pets .. " pet")
    return pets, areas
end

-- Scan monster di semua area
function ScanMonsters()
    local monsters = {}
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:find("Monster") or v.Name:find("Enemy") or v:FindFirstChild("Humanoid")) then
            local hrp = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso") or v:FindFirstChild("Head")
            if hrp then
                local monsterData = {
                    Name = v.Name,
                    Instance = v,
                    Position = hrp.Position,
                    HumanoidRootPart = hrp,
                    Health = v:FindFirstChild("Humanoid") and v.Humanoid.Health or 0,
                    MaxHealth = v:FindFirstChild("Humanoid") and v.Humanoid.MaxHealth or 0
                }
                
                -- Cari area monster ini
                for _, area in ipairs(AreaDatabase) do
                    if area.Position and hrp.Position then
                        local dist = (area.Position - hrp.Position).Magnitude
                        if dist < 100 then
                            monsterData.Area = area.Name
                            break
                        end
                    end
                end
                
                table.insert(monsters, monsterData)
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
    if not success then
        print("⚠️ Remote error: " .. tostring(result))
    end
    return success, result
end

--==================================================
-- AUTO FARM BY PET NAME - FIXED
--==================================================
local AutoFarmActive = false
local SelectedPet = nil
local AutoAttackActive = false
local AutoCatchActive = false
local AutoSellActive = false
local AutoEquipBest = false
local AutoClaimTask = false
local FarmLoop = nil

function StartAutoFarm()
    if FarmLoop then
        FarmLoop:Disconnect()
        FarmLoop = nil
    end
    
    AutoFarmActive = true
    print("🚀 Auto Farm started. Target: " .. (SelectedPet or "All Pets"))
    
    FarmLoop = RunService.Heartbeat:Connect(function()
        if not AutoFarmActive or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        task.spawn(function()
            -- 1. Equip best pet otomatis
            if AutoEquipBest then
                CallRemote("PetEquipBestChannel")
                task.wait(0.2)
            end
            
            -- 2. Cari pet target
            local targetPet = nil
            if SelectedPet and SelectedPet ~= "All" then
                for _, pet in ipairs(PetDatabase) do
                    if pet.Name == SelectedPet then
                        targetPet = pet
                        break
                    end
                end
            end
            
            -- 3. Jika ada pet target, teleport ke areanya
            if targetPet and targetPet.Position then
                local root = Player.Character.HumanoidRootPart
                local distToPet = (root.Position - targetPet.Position).Magnitude
                
                if distToPet > 30 then
                    -- Teleport ke pet
                    root.CFrame = CFrame.new(targetPet.Position) * CFrame.new(0, 3, 0)
                    task.wait(0.3)
                end
                
                -- 4. Cari monster di area yang sama
                for _, monster in ipairs(MonsterDatabase) do
                    if monster.Area == targetPet.Area then
                        local monsterDist = (root.Position - monster.Position).Magnitude
                        
                        if monsterDist > 15 then
                            root.CFrame = CFrame.new(monster.Position) * CFrame.new(0, 3, 0)
                            task.wait(0.2)
                        end
                        
                        -- 5. Auto attack
                        if AutoAttackActive then
                            CallRemote("MonsterAttackChannel")
                            task.wait(0.1)
                        end
                        
                        -- 6. Auto catch
                        if AutoCatchActive then
                            CallRemote("MonsterCatchStartChannel")
                            task.wait(0.2)
                            CallRemote("MonsterCatchCompleteChannel")
                            task.wait(0.1)
                        end
                        
                        break -- Hanya serang 1 monster per loop
                    end
                end
            end
            
            -- 7. Auto sell
            if AutoSellActive then
                CallRemote("PetAutoSellChannel")
                CallRemote("PetSellChannel")
            end
            
            -- 8. Auto claim task
            if AutoClaimTask then
                CallRemote("TaskClaimRewardChannel")
            end
        end)
    end)
end

function StopAutoFarm()
    AutoFarmActive = false
    if FarmLoop then
        FarmLoop:Disconnect()
        FarmLoop = nil
    end
    CallRemote("SettingSetOnOffChannel", "AutoAttack", false)
    print("⏹️ Auto Farm stopped")
end

--==================================================
-- TELEPORT KE AREA - FIXED
--==================================================
function TeleportToArea(areaName)
    for _, area in ipairs(AreaDatabase) do
        if area.Name == areaName then
            if area.Position then
                local success = pcall(function()
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(area.Position) * CFrame.new(0, 3, 0)
                end)
                if success then
                    CallRemote("AreaTeleportToRegionChannel", area.Name)
                    return true
                end
            end
        end
    end
    return false
end

function TeleportToPet(petName)
    for _, pet in ipairs(PetDatabase) do
        if pet.Name == petName then
            if pet.Position then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(pet.Position) * CFrame.new(0, 3, 0)
                return true
            end
        end
    end
    return false
end

function TeleportToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        return true
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
MainFrame.Size = UDim2.new(0, 550, 0, 650)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -325)
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
TitleText.Text = "CATCH A MONSTER - ULTIMATE"
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

local Tabs = {"🏠 HOME", "🐕 PETS", "⚡ AUTO FARM", "🌀 TELEPORT", "⚙️ SETTINGS"}
local TabButtons = {}
local CurrentTab = "🏠 HOME"

for i = 1, #Tabs do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 0, 50)
    TabBtn.Position = UDim2.new(0, (i-1) * 102, 0, 0)
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
    if not options or #options == 0 then
        options = {"Tidak ada data"}
    end
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 45)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Parent = ScrollingFrame
    DropdownFrame.ZIndex = 5
    
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
    DropdownText.ZIndex = 5
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 180, 0, 30)
    DropdownBtn.Position = UDim2.new(1, -195, 0.5, -15)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 40, 45)
    DropdownBtn.Text = options[1] or "Pilih"
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
        -- Hapus menu lama
        local oldMenu = DropdownFrame:FindFirstChild("DropdownMenu")
        if oldMenu then oldMenu:Destroy() end
        
        -- Buat menu baru
        local menu = Instance.new("Frame")
        menu.Name = "DropdownMenu"
        menu.Size = UDim2.new(0, 200, 0, math.min(#options, 6) * 35)
        menu.Position = UDim2.new(1, -195, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(40, 35, 40)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        menu.ZIndex = 10
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 8)
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
    
    if tab == "🏠 HOME" then
        CreateSection("📊 DASHBOARD")
        CreateLabel("Player: " .. Player.Name)
        CreateLabel("Display: " .. Player.DisplayName)
        CreateLabel("Server: " .. game.JobId:sub(1, 10) .. "...")
        CreateLabel("Players: " .. #Players:GetPlayers())
        
        CreateSection("📈 STATISTICS")
        CreateLabel("Areas Ditemukan: " .. #AreaDatabase)
        CreateLabel("Pets Ditemukan: " .. #PetDatabase)
        CreateLabel("Monsters Ditemukan: " .. #MonsterDatabase)
        
        CreateSection("🎮 QUICK ACTIONS")
        CreateButton("🔄 REFRESH DATA", Color3.fromRGB(100, 100, 200), function()
            UpdateTab("🏠 HOME")
            Notify("Data refreshed!")
        end)
        
        CreateButton("⚡ START AUTO FARM", Color3.fromRGB(0, 200, 0), function()
            CurrentTab = "⚡ AUTO FARM"
            for i, btn in ipairs(TabButtons) do
                if i == 3 then
                    btn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            UpdateTab("⚡ AUTO FARM")
        end)
        
    elseif tab == "🐕 PETS" then
        CreateSection("🐕 PETS DATABASE")
        CreateLabel("Total: " .. #PetDatabase .. " pets ditemukan")
        
        if #PetDatabase == 0 then
            CreateLabel("⚠️ Tidak ada pet ditemukan")
            CreateLabel("Tunggu scan otomatis...")
        end
        
        for i, pet in ipairs(PetDatabase) do
            if i <= 15 then -- Batasi 15 pet
                CreateButton("🐕 " .. pet.Name .. " | Lv." .. pet.Level .. " | " .. pet.Rarity, Color3.fromRGB(100, 200, 100), function()
                    SelectedPet = pet.Name
                    Notify("Selected pet: " .. pet.Name)
                    
                    -- Teleport ke pet
                    if TeleportToPet(pet.Name) then
                        Notify("Teleported to " .. pet.Name)
                    end
                end)
            end
        end
        
        if #PetDatabase > 15 then
            CreateLabel("... dan " .. (#PetDatabase - 15) .. " pet lainnya")
        end
        
    elseif tab == "⚡ AUTO FARM" then
        CreateSection("⚡ AUTO FARM SETTINGS")
        
        -- List pets untuk dropdown
        local petNames = {"All Pets"}
        for _, pet in ipairs(PetDatabase) do
            table.insert(petNames, pet.Name)
        end
        
        if #petNames > 1 then
            CreateDropdown("🎯 Target Pet", petNames, function(opt)
                SelectedPet = opt
                Notify("Target pet: " .. opt)
            end)
        else
            CreateLabel("⚠️ Belum ada pet terdeteksi")
            CreateButton("🔄 SCAN ULANG", Color3.fromRGB(255, 165, 0), function()
                ScanAreaForPets()
                UpdateTab("⚡ AUTO FARM")
            end)
        end
        
        CreateToggle("⚔️ Auto Attack", AutoAttackActive, function(state)
            AutoAttackActive = state
            CallRemote("SettingSetOnOffChannel", "AutoAttack", state)
            Notify("Auto Attack: " .. (state and "ON" or "OFF"))
        end)
        
        CreateToggle("🪤 Auto Catch", AutoCatchActive, function(state)
            AutoCatchActive = state
            Notify("Auto Catch: " .. (state and "ON" or "OFF"))
        end)
        
        CreateToggle("💰 Auto Sell", AutoSellActive, function(state)
            AutoSellActive = state
            Notify("Auto Sell: " .. (state and "ON" or "OFF"))
        end)
        
        CreateToggle("👑 Equip Best Pet", AutoEquipBest, function(state)
            AutoEquipBest = state
            Notify("Equip Best Pet: " .. (state and "ON" or "OFF"))
        end)
        
        CreateToggle("📋 Auto Claim Task", AutoClaimTask, function(state)
            AutoClaimTask = state
            Notify("Auto Claim Task: " .. (state and "ON" or "OFF"))
        end)
        
        CreateSection("🎯 CONTROL")
        CreateButton("▶️ START AUTO FARM", Color3.fromRGB(0, 200, 0), function()
            if #PetDatabase > 0 then
                StartAutoFarm()
                Notify("✅ Auto Farm Started - Target: " .. (SelectedPet or "All Pets"))
            else
                Notify("❌ Tidak ada pet ditemukan!")
            end
        end)
        
        CreateButton("⏹️ STOP AUTO FARM", Color3.fromRGB(200, 0, 0), function()
            StopAutoFarm()
            Notify("⏹️ Auto Farm Stopped")
        end)
        
        CreateSection("📊 STATUS")
        CreateLabel("Target: " .. (SelectedPet or "All Pets"))
        CreateLabel("Pets Available: " .. #PetDatabase)
        CreateLabel("Areas: " .. #AreaDatabase)
        CreateLabel("Monsters: " .. #MonsterDatabase)
        CreateLabel("Auto Farm: " .. (AutoFarmActive and "✅ ACTIVE" or "⭕ INACTIVE"))
        
    elseif tab == "🌀 TELEPORT" then
        CreateSection("🌀 TELEPORT MENU")
        
        -- Teleport ke pet
        CreateSection("📍 TELEPORT KE PET")
        local petNames = {}
        for _, pet in ipairs(PetDatabase) do
            table.insert(petNames, pet.Name)
        end
        
        if #petNames > 0 then
            CreateDropdown("Pilih Pet", petNames, function(opt)
                if TeleportToPet(opt) then
                    Notify("✅ Teleported to " .. opt)
                else
                    Notify("❌ Gagal teleport")
                end
            end)
        else
            CreateLabel("⚠️ Tidak ada pet ditemukan")
        end
        
        -- Teleport ke area
        CreateSection("📍 TELEPORT KE AREA")
        local areaNames = {}
        for _, area in ipairs(AreaDatabase) do
            table.insert(areaNames, area.Name)
        end
        
        if #areaNames > 0 then
            CreateDropdown("Pilih Area", areaNames, function(opt)
                if TeleportToArea(opt) then
                    Notify("✅ Teleported to area: " .. opt)
                else
                    Notify("❌ Gagal teleport")
                end
            end)
        else
            CreateLabel("⚠️ Tidak ada area ditemukan")
        end
        
        -- Teleport ke player
        CreateSection("📍 TELEPORT KE PLAYER")
        local playerNames = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                table.insert(playerNames, player.Name)
            end
        end
        
        if #playerNames > 0 then
            CreateDropdown("Pilih Player", playerNames, function(opt)
                if TeleportToPlayer(opt) then
                    Notify("✅ Teleported to " .. opt)
                else
                    Notify("❌ Gagal teleport")
                end
            end)
        else
            CreateLabel("⚠️ Tidak ada player lain")
        end
        
        CreateSection("📍 WAYPOINT")
        CreateButton("💾 SAVE POSITION", Color3.fromRGB(0, 200, 0), function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                _G.SavedPosition = Player.Character.HumanoidRootPart.CFrame
                Notify("✅ Position saved!")
            end
        end)
        
        CreateButton("📌 LOAD POSITION", Color3.fromRGB(255, 165, 0), function()
            if _G.SavedPosition then
                Player.Character.HumanoidRootPart.CFrame = _G.SavedPosition
                Notify("✅ Teleported to saved position")
            else
                Notify("❌ No saved position!")
            end
        end)
        
    elseif tab == "⚙️ SETTINGS" then
        CreateSection("⚙️ SETTINGS")
        
        CreateButton("🔄 REFRESH DATABASE", Color3.fromRGB(100, 100, 200), function()
            ScanAreaForPets()
            ScanMonsters()
            Notify("✅ Database refreshed! Pets: " .. #PetDatabase .. ", Areas: " .. #AreaDatabase)
            UpdateTab("⚙️ SETTINGS")
        end))
        
        CreateButton("🎮 TOGGLE MENU (F4)", Color3.fromRGB(255, 85, 85), function()
            MainFrame.Visible = not MainFrame.Visible
        end)
        
        CreateButton("❌ CLOSE GUI", Color3.fromRGB(200, 50, 50), function()
            ScreenGui:Destroy()
            _G.CAM_Loaded = false
        end)
        
        CreateSection("ℹ️ INFO")
        CreateLabel("Game: Catch a Monster")
        CreateLabel("Version: 4.0 (FULLY FIXED)")
        CreateLabel("Status: ✅ Running")
        CreateLabel("Auto Farm: " .. (AutoFarmActive and "✅ ACTIVE" or "⭕ INACTIVE"))
        CreateLabel("Pets: " .. #PetDatabase)
        CreateLabel("Areas: " .. #AreaDatabase)
        CreateLabel("Monsters: " .. #MonsterDatabase)
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- INITIALIZE
--==================================================
-- Scan awal
ScanAreaForPets()
ScanMonsters()

-- Set tab pertama
UpdateTab("🏠 HOME")

Notify("✅ Script loaded! Press F4 to open menu")

print("========================================")
print("✅ CATCH A MONSTER - ULTIMATE AUTO FARM v4.0")
print("Press F4 to toggle menu")
print("Found " .. #PetDatabase .. " pets")
print("Found " .. #AreaDatabase .. " areas")
print("Found " .. #MonsterDatabase .. " monsters")
print("========================================")