-- ==================== GAMES/VIOLENCE.LUA ====================
-- Script untuk game Violence District dengan GUI Lengkap

if _G.ViolenceLoaded then return end
_G.ViolenceLoaded = true

print("🔰 Violence District Script Starting...")

--==================================================
-- VARIABLES & CONFIGURATION
--==================================================

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

-- Global toggle variables
_G.SurvivorESP = false
_G.KillerESP = false
_G.GeneratorESP = false
_G.UnlimitedZoom = false
_G.FullBright = false
_G.AutoFarmGenerator = false
_G.AutoFarmPresent = false
_G.FarmGift = false
_G.NoClip = false
_G.FlickerSpeed = false
_G.NoSkillCheck = false
_G.AutoTeleport = false
_G.Aimbot = false
_G.Wallhack = false
_G.BodyLock = false
_G.AutoClick = false
_G.SpeedBoost = false
_G.JumpBoost = false
_G.SelectedTarget = nil
_G.KillAura = false

--==================================================
-- LIBRARY LOADER YANG DIPERBAIKI
--==================================================

local Library
local Window

-- Try loading Kavo UI
local success, lib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyBimZy/Machadepanmu/main/loader.lua"))()
end)

-- Fungsi untuk membuat custom GUI jika semua library gagal
function CreateCustomGUI()
    -- Hapus GUI lama jika ada
    local oldGUI = game.CoreGui:FindFirstChild("ViolenceCustomGUI")
    if oldGUI then oldGUI:Destroy() end
    
    -- Buat GUI baru
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ViolenceCustomGUI"
    ScreenGui.Parent = game.CoreGui
    
    -- Frame utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -10, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "Violence District - Complete Edition"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 18
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab buttons
    local Tabs = {"Info", "Visuals", "Survivor", "Killer", "Teleport", "Farm", "Misc", "Settings"}
    local TabButtons = {}
    local TabContents = {}
    local CurrentTab = "Info"
    
    for i, tabName in ipairs(Tabs) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 75, 0, 30)
        TabBtn.Position = UDim2.new(0, (i-1) * 75, 0, 45)
        TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = MainFrame
        
        TabBtn.MouseButton1Click:Connect(function()
            CurrentTab = tabName
            for _, btn in pairs(TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            TabBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            -- Sembunyikan semua konten
            for _, content in pairs(TabContents) do
                if content then content.Visible = false end
            end
            
            -- Tampilkan konten tab yang dipilih
            if TabContents[tabName] then
                TabContents[tabName].Visible = true
            end
        end)
        
        table.insert(TabButtons, TabBtn)
        
        -- Buat konten untuk tab
        local ContentFrame = Instance.new("ScrollingFrame")
        ContentFrame.Size = UDim2.new(1, -20, 1, -90)
        ContentFrame.Position = UDim2.new(0, 10, 0, 80)
        ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ContentFrame.BorderSizePixel = 0
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        ContentFrame.ScrollBarThickness = 6
        ContentFrame.Visible = (tabName == "Info")
        ContentFrame.Parent = MainFrame
        
        local ContentCorner = Instance.new("UICorner")
        ContentCorner.CornerRadius = UDim.new(0, 6)
        ContentCorner.Parent = ContentFrame
        
        TabContents[tabName] = ContentFrame
    end
    
    -- Return object dengan method untuk menambah elemen
    return {
        AddTab = function(_, tabName)
            local contentFrame = TabContents[tabName]
            if not contentFrame then return nil end
            
            local yOffset = 0
            
            return {
                AddSection = function(_, sectionName)
                    -- Section title
                    local SectionLabel = Instance.new("TextLabel")
                    SectionLabel.Size = UDim2.new(1, -20, 0, 30)
                    SectionLabel.Position = UDim2.new(0, 10, 0, yOffset)
                    SectionLabel.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                    SectionLabel.Text = "  " .. sectionName
                    SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SectionLabel.TextSize = 14
                    SectionLabel.Font = Enum.Font.GothamBold
                    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SectionLabel.Parent = contentFrame
                    
                    local SectionCorner = Instance.new("UICorner")
                    SectionCorner.CornerRadius = UDim.new(0, 4)
                    SectionCorner.Parent = SectionLabel
                    
                    yOffset = yOffset + 35
                    
                    return {
                        AddToggle = function(_, toggleName, callback)
                            local ToggleFrame = Instance.new("Frame")
                            ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
                            ToggleFrame.Position = UDim2.new(0, 10, 0, yOffset)
                            ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            ToggleFrame.Parent = contentFrame
                            
                            local ToggleCorner = Instance.new("UICorner")
                            ToggleCorner.CornerRadius = UDim.new(0, 4)
                            ToggleCorner.Parent = ToggleFrame
                            
                            local ToggleText = Instance.new("TextLabel")
                            ToggleText.Size = UDim2.new(0.7, -10, 1, 0)
                            ToggleText.Position = UDim2.new(0, 10, 0, 0)
                            ToggleText.BackgroundTransparency = 1
                            ToggleText.Text = toggleName
                            ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
                            ToggleText.TextSize = 13
                            ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                            ToggleText.Font = Enum.Font.Gotham
                            ToggleText.Parent = ToggleFrame
                            
                            local ToggleBtn = Instance.new("TextButton")
                            ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
                            ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
                            ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                            ToggleBtn.Text = "OFF"
                            ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
                            ToggleBtn.TextSize = 12
                            ToggleBtn.Font = Enum.Font.GothamBold
                            ToggleBtn.Parent = ToggleFrame
                            
                            local BtnCorner = Instance.new("UICorner")
                            BtnCorner.CornerRadius = UDim.new(0, 4)
                            BtnCorner.Parent = ToggleBtn
                            
                            local enabled = false
                            ToggleBtn.MouseButton1Click:Connect(function()
                                enabled = not enabled
                                if enabled then
                                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
                                    ToggleBtn.Text = "ON"
                                    ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
                                else
                                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                                    ToggleBtn.Text = "OFF"
                                    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
                                end
                                callback(enabled)
                            end)
                            
                            yOffset = yOffset + 35
                        end,
                        
                        AddButton = function(_, buttonName, callback)
                            local Button = Instance.new("TextButton")
                            Button.Size = UDim2.new(1, -20, 0, 35)
                            Button.Position = UDim2.new(0, 10, 0, yOffset)
                            Button.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
                            Button.Text = buttonName
                            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                            Button.TextSize = 14
                            Button.Font = Enum.Font.GothamBold
                            Button.Parent = contentFrame
                            
                            local BtnCorner = Instance.new("UICorner")
                            BtnCorner.CornerRadius = UDim.new(0, 4)
                            BtnCorner.Parent = Button
                            
                            Button.MouseButton1Click:Connect(callback)
                            
                            yOffset = yOffset + 40
                        end,
                        
                        AddDropdown = function(_, dropdownName, list, callback)
                            local DropdownFrame = Instance.new("Frame")
                            DropdownFrame.Size = UDim2.new(1, -20, 0, 30)
                            DropdownFrame.Position = UDim2.new(0, 10, 0, yOffset)
                            DropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            DropdownFrame.Parent = contentFrame
                            
                            local DropdownCorner = Instance.new("UICorner")
                            DropdownCorner.CornerRadius = UDim.new(0, 4)
                            DropdownCorner.Parent = DropdownFrame
                            
                            local DropdownText = Instance.new("TextLabel")
                            DropdownText.Size = UDim2.new(0.5, -10, 1, 0)
                            DropdownText.Position = UDim2.new(0, 10, 0, 0)
                            DropdownText.BackgroundTransparency = 1
                            DropdownText.Text = dropdownName
                            DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
                            DropdownText.TextSize = 13
                            DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                            DropdownText.Font = Enum.Font.Gotham
                            DropdownText.Parent = DropdownFrame
                            
                            local DropdownBtn = Instance.new("TextButton")
                            DropdownBtn.Size = UDim2.new(0.4, -10, 0, 25)
                            DropdownBtn.Position = UDim2.new(0.6, -10, 0.5, -12.5)
                            DropdownBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                            DropdownBtn.Text = list[1] or "Select"
                            DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            DropdownBtn.TextSize = 12
                            DropdownBtn.Font = Enum.Font.Gotham
                            DropdownBtn.Parent = DropdownFrame
                            
                            local BtnCorner = Instance.new("UICorner")
                            BtnCorner.CornerRadius = UDim.new(0, 4)
                            BtnCorner.Parent = DropdownBtn
                            
                            -- Simple dropdown menu
                            DropdownBtn.MouseButton1Click:Connect(function()
                                local menu = Instance.new("Frame")
                                menu.Size = UDim2.new(0, 150, 0, #list * 30)
                                menu.Position = UDim2.new(0.6, -10, 1, 5)
                                menu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                                menu.Parent = DropdownFrame
                                
                                for i, item in ipairs(list) do
                                    local itemBtn = Instance.new("TextButton")
                                    itemBtn.Size = UDim2.new(1, 0, 0, 30)
                                    itemBtn.Position = UDim2.new(0, 0, 0, (i-1) * 30)
                                    itemBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                                    itemBtn.Text = item
                                    itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    itemBtn.TextSize = 12
                                    itemBtn.Font = Enum.Font.Gotham
                                    itemBtn.Parent = menu
                                    
                                    itemBtn.MouseButton1Click:Connect(function()
                                        DropdownBtn.Text = item
                                        callback(item)
                                        menu:Destroy()
                                    end)
                                end
                            end)
                            
                            yOffset = yOffset + 35
                        end,
                        
                        AddLabel = function(_, text)
                            local Label = Instance.new("TextLabel")
                            Label.Size = UDim2.new(1, -20, 0, 25)
                            Label.Position = UDim2.new(0, 10, 0, yOffset)
                            Label.BackgroundTransparency = 1
                            Label.Text = text
                            Label.TextColor3 = Color3.fromRGB(180, 180, 180)
                            Label.TextSize = 12
                            Label.TextXAlignment = Enum.TextXAlignment.Left
                            Label.Font = Enum.Font.Gotham
                            Label.Parent = contentFrame
                            
                            yOffset = yOffset + 25
                        end,
                        
                        AddSlider = function(_, sliderName, min, max, callback)
                            local SliderFrame = Instance.new("Frame")
                            SliderFrame.Size = UDim2.new(1, -20, 0, 40)
                            SliderFrame.Position = UDim2.new(0, 10, 0, yOffset)
                            SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            SliderFrame.Parent = contentFrame
                            
                            local SliderCorner = Instance.new("UICorner")
                            SliderCorner.CornerRadius = UDim.new(0, 4)
                            SliderCorner.Parent = SliderFrame
                            
                            local SliderText = Instance.new("TextLabel")
                            SliderText.Size = UDim2.new(0.5, -10, 0, 20)
                            SliderText.Position = UDim2.new(0, 10, 0, 2)
                            SliderText.BackgroundTransparency = 1
                            SliderText.Text = sliderName
                            SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
                            SliderText.TextSize = 13
                            SliderText.TextXAlignment = Enum.TextXAlignment.Left
                            SliderText.Font = Enum.Font.Gotham
                            SliderText.Parent = SliderFrame
                            
                            local ValueLabel = Instance.new("TextLabel")
                            ValueLabel.Size = UDim2.new(0.3, -10, 0, 20)
                            ValueLabel.Position = UDim2.new(0.7, -10, 0, 2)
                            ValueLabel.BackgroundTransparency = 1
                            ValueLabel.Text = tostring(min)
                            ValueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                            ValueLabel.TextSize = 13
                            ValueLabel.Font = Enum.Font.GothamBold
                            ValueLabel.Parent = SliderFrame
                            
                            local SliderBg = Instance.new("Frame")
                            SliderBg.Size = UDim2.new(1, -20, 0, 5)
                            SliderBg.Position = UDim2.new(0, 10, 0, 25)
                            SliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                            SliderBg.Parent = SliderFrame
                            
                            local SliderFill = Instance.new("Frame")
                            SliderFill.Size = UDim2.new(0, 0, 1, 0)
                            SliderFill.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
                            SliderFill.Parent = SliderBg
                            
                            yOffset = yOffset + 45
                        end
                    }
                end
            }
        end
    }
end

--==================================================
-- CREATE TABS
--==================================================

local InfoTab = Window:AddTab("Info")
local VisualsTab = Window:AddTab("Visuals")
local SurvivorTab = Window:AddTab("Survivor")
local KillerTab = Window:AddTab("Killer")
local TeleportTab = Window:AddTab("Teleport")
local FarmTab = Window:AddTab("Farm")
local MiscTab = Window:AddTab("Misc")
local SettingsTab = Window:AddTab("Settings")

--==================================================
-- INFO TAB
--==================================================

local InfoSection = InfoTab:AddSection("Server Information")
InfoSection:AddLabel("Game: Violence District")
InfoSection:AddLabel("Server ID: " .. game.JobId)
InfoSection:AddLabel("Players: " .. #game.Players:GetPlayers())
InfoSection:AddLabel("Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms")

InfoSection:AddButton("Refresh Info", function()
    InfoSection:AddLabel("Players: " .. #game.Players:GetPlayers())
end)

local CreditSection = InfoTab:AddSection("Credits")
CreditSection:AddLabel("Script by: LuckyBimZy")
CreditSection:AddLabel("Version: 2.0")
CreditSection:AddLabel("GitHub: Machadepanmu")
CreditSection:AddLabel("Status: ✅ Loaded")

--==================================================
-- VISUALS TAB
--==================================================

local VisualsSection = VisualsTab:AddSection("ESP Settings")

-- Survivor ESP
VisualsSection:AddToggle("Survivor ESP (Blue)", function(state)
    _G.SurvivorESP = state
    if state then
        EnableESP("Survivor", Color3.fromRGB(0, 100, 255))
    else
        DisableESP()
    end
end)

-- Killer ESP
VisualsSection:AddToggle("Killer ESP (Red)", function(state)
    _G.KillerESP = state
    if state then
        EnableESP("Killer", Color3.fromRGB(255, 0, 0))
    else
        DisableESP()
    end
end)

-- Generator ESP
VisualsSection:AddToggle("Generator ESP (Green)", function(state)
    _G.GeneratorESP = state
    if state then
        EnableGeneratorESP()
    else
        DisableGeneratorESP()
    end
end)

-- Unlimited Zoom
VisualsSection:AddToggle("Unlimited Zoom", function(state)
    _G.UnlimitedZoom = state
    if state then
        Camera.FieldOfView = 120
    else
        Camera.FieldOfView = 70
    end
end)

-- Full Bright
VisualsSection:AddToggle("Full Bright", function(state)
    _G.FullBright = state
    if state then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.new(0, 0, 0)
    end
end)

-- Wallhack
VisualsSection:AddToggle("Wallhack", function(state)
    _G.Wallhack = state
    UpdateWallhack()
end)

--==================================================
-- SURVIVOR TAB
--==================================================

local SurvivorSection = SurvivorTab:AddSection("Survivor Features")

-- Auto-Farm Present
SurvivorSection:AddToggle("Auto-Farm Present", function(state)
    _G.AutoFarmPresent = state
    if state then StartAutoFarmPresent() end
end)

-- Farm Gift to Christmas Tree
SurvivorSection:AddToggle("Farm Gift → Teleport to Tree", function(state)
    _G.FarmGift = state
    if state then StartFarmGift() end
end)

-- Flicker/Blink Speed
SurvivorSection:AddToggle("Flicker/Blink Speed", function(state)
    _G.FlickerSpeed = state
    if state then
        Humanoid.WalkSpeed = 100
    else
        Humanoid.WalkSpeed = 16
    end
end)

-- Speed Boost
SurvivorSection:AddToggle("Speed Boost (x3)", function(state)
    _G.SpeedBoost = state
    if state then
        Humanoid.WalkSpeed = 48
    else
        Humanoid.WalkSpeed = 16
    end
end)

-- Jump Boost
SurvivorSection:AddToggle("Jump Boost (x2)", function(state)
    _G.JumpBoost = state
    if state then
        Humanoid.JumpPower = 100
    else
        Humanoid.JumpPower = 50
    end
end)

-- Body Lock Section
local BodyLockSection = SurvivorTab:AddSection("Body Lock System")

BodyLockSection:AddDropdown("Select Target", GetPlayerList(), function(playerName)
    _G.SelectedTarget = game.Players:FindFirstChild(playerName)
end)

BodyLockSection:AddButton("Refresh Player List", function()
    BodyLockSection:AddDropdown("Select Target", GetPlayerList(), function(playerName)
        _G.SelectedTarget = game.Players:FindFirstChild(playerName)
    end)
end)

BodyLockSection:AddToggle("Body Lock", function(state)
    _G.BodyLock = state
    if state then StartBodyLock() end
end)

--==================================================
-- KILLER TAB
--==================================================

local KillerSection = KillerTab:AddSection("Killer Features")

-- Aimbot
KillerSection:AddToggle("Aimbot", function(state)
    _G.Aimbot = state
    if state then StartAimbot() end
end)

-- Kill Aura
KillerSection:AddToggle("Kill Aura", function(state)
    _G.KillAura = state
    if state then StartKillAura() end
end)

-- Target Selection
local KillerTargetSection = KillerTab:AddSection("Target Selection")
KillerTargetSection:AddDropdown("Select Target", GetPlayerList(), function(playerName)
    _G.KillerTarget = game.Players:FindFirstChild(playerName)
end)

KillerTargetSection:AddButton("Refresh List", function()
    KillerTargetSection:AddDropdown("Select Target", GetPlayerList(), function(playerName)
        _G.KillerTarget = game.Players:FindFirstChild(playerName)
    end)
end)

--==================================================
-- TELEPORT TAB
--==================================================

local TeleportSection = TeleportTab:AddSection("Teleportation")

-- NoClip
TeleportSection:AddToggle("NoClip (Walk through walls)", function(state)
    _G.NoClip = state
    UpdateNoClip()
end)

-- Teleport to Player
local TPPlayerSection = TeleportTab:AddSection("Teleport to Player")
TPPlayerSection:AddDropdown("Target Player", GetPlayerList(), function(playerName)
    _G.TPTarget = game.Players:FindFirstChild(playerName)
end)

TPPlayerSection:AddButton("Refresh List", function()
    TPPlayerSection:AddDropdown("Target Player", GetPlayerList(), function(playerName)
        _G.TPTarget = game.Players:FindFirstChild(playerName)
    end)
end)

TPPlayerSection:AddButton("Teleport to Target", function()
    if _G.TPTarget and _G.TPTarget.Character then
        RootPart.CFrame = _G.TPTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
    end
end)

--==================================================
-- FARM TAB
--==================================================

local FarmSection = FarmTab:AddSection("Generator Farm")

FarmSection:AddToggle("Auto-Farm Generator", function(state)
    _G.AutoFarmGenerator = state
    if state then StartAutoFarmGenerator() end
end)

FarmSection:AddToggle("Auto Teleport & Complete", function(state)
    _G.AutoTeleport = state
    if state then StartAutoTeleport() end
end)

-- Present Farm
local PresentSection = FarmTab:AddSection("Present Farm")
PresentSection:AddToggle("Auto Collect Presents", function(state)
    _G.AutoCollectPresent = state
    if state then StartAutoCollectPresent() end
end)

--==================================================
-- MISC TAB
--==================================================

local MiscSection = MiscTab:AddSection("Utility")

-- Anti AFK
MiscSection:AddToggle("Anti AFK", function(state)
    _G.AntiAFK = state
    if state then
        Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Auto Click
MiscSection:AddToggle("Auto Click", function(state)
    _G.AutoClick = state
    if state then StartAutoClick() end
end)

--==================================================
-- SETTINGS TAB
--==================================================

local SettingsSection = SettingsTab:AddSection("Skill Check Settings")

SettingsSection:AddToggle("No Skill Check", function(state)
    _G.NoSkillCheck = state
    ToggleSkillCheck(state)
end)

SettingsSection:AddButton("Toggle GUI", function()
    local gui = game.CoreGui:FindFirstChild("ViolenceCustomGUI") or 
                game.CoreGui:FindFirstChild("KavoUI") or 
                game.CoreGui:FindFirstChild("LinoriaLib")
    if gui then
        gui.Enabled = not gui.Enabled
    end
end)

--==================================================
-- CORE FUNCTIONS
--==================================================

-- ESP Functions
function EnableESP(type, color)
    DisableESP() -- Hapus ESP lama dulu
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player then
            AddESP(player, color)
        end
    end
    
    -- Untuk player yang join belakangan
    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if (_G.SurvivorESP or _G.KillerESP) and player ~= Player then
                local espColor = _G.SurvivorESP and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 0, 0)
                AddESP(player, espColor)
            end
        end)
    end)
end

function AddESP(player, color)
    if not player.Character then return end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Parent = player.Character
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    
    -- Name tag with distance
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name"
    billboard.Parent = player.Character
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
end

function DisableESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if highlight then highlight:Destroy() end
            
            local nameTag = player.Character:FindFirstChild("ESP_Name")
            if nameTag then nameTag:Destroy() end
        end
    end
end

-- Generator ESP
function EnableGeneratorESP()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") then
            AddGeneratorESP(v)
        end
    end
end

function AddGeneratorESP(gen)
    local highlight = Instance.new("Highlight")
    highlight.Parent = gen
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.3
end

function DisableGeneratorESP()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Parent and v.Parent.Name == "Generator" then
            v:Destroy()
        end
    end
end

-- Wallhack Update
function UpdateWallhack()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if _G.Wallhack then
                if v.Name ~= "HumanoidRootPart" then
                    v.Material = Enum.Material.ForceField
                    v.Transparency = 0.5
                end
            else
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
            end
        end
    end
end

-- NoClip Update
function UpdateNoClip()
    if _G.NoClip then
        RunService:BindToRenderStep("NoClip", 0, function()
            if _G.NoClip and Character then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("NoClip")
        if Character then
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Auto Farm Functions
function StartAutoFarmGenerator()
    spawn(function()
        while _G.AutoFarmGenerator do
            task.wait(0.1)
            local generator = FindNearestGenerator()
            if generator then
                RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
                -- Coba berbagai method untuk repair generator
                local args = { [1] = "RepairGenerator", [2] = generator }
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then remote:FireServer(unpack(args)) end
                end)
            end
        end
    end)
end

function StartAutoTeleport()
    spawn(function()
        while _G.AutoTeleport do
            task.wait(0.1)
            local generator = FindNearestGenerator()
            if generator then
                RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
                local args = { [1] = "CompleteGenerator", [2] = generator }
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then remote:FireServer(unpack(args)) end
                end)
            end
        end
    end)
end

function StartAutoFarmPresent()
    spawn(function()
        while _G.AutoFarmPresent do
            task.wait(0.1)
            local present = FindNearestPresent()
            if present then
                RootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
            end
        end
    end)
end

function StartFarmGift()
    spawn(function()
        while _G.FarmGift do
            task.wait(0.1)
            local gift = FindNearestGift()
            if gift then
                RootPart.CFrame = gift.CFrame + Vector3.new(0, 3, 0)
                local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
                
                local tree = FindChristmasTree()
                if tree then
                    task.wait(0.5)
                    RootPart.CFrame = tree.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end)
end

function StartAutoCollectPresent()
    spawn(function()
        while _G.AutoCollectPresent do
            task.wait(0.1)
            local present = FindNearestPresent()
            if present then
                RootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
            end
        end
    end)
end

-- Body Lock
function StartBodyLock()
    spawn(function()
        while _G.BodyLock and _G.SelectedTarget do
            task.wait()
            if _G.SelectedTarget.Character and _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = _G.SelectedTarget.Character.HumanoidRootPart.Position
                RootPart.CFrame = CFrame.new(targetPos.x, targetPos.y + 3, targetPos.z)
            end
        end
    end)
end

-- Aimbot
function StartAimbot()
    spawn(function()
        while _G.Aimbot do
            task.wait()
            local target = FindNearestPlayer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Character.HumanoidRootPart.Position
                RootPart.CFrame = CFrame.lookAt(RootPart.Position, targetPos)
            end
        end
    end)
end

-- Kill Aura
function StartKillAura()
    spawn(function()
        while _G.KillAura do
            task.wait(0.1)
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
                    local dist = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= 20 then
                        player.Character.Humanoid.Health = 0
                    end
                end
            end
        end
    end)
end

-- Auto Click
function StartAutoClick()
    spawn(function()
        while _G.AutoClick do
            task.wait(0.01)
            mouse1click()
        end
    end)
end

-- Skill Check Handler
function ToggleSkillCheck(state)
    if state then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and tostring(self):find("SkillCheck") then
                return
            end
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
    end
end

-- Find Object Functions
function FindNearestGenerator()
    local nearest = nil
    local distance = math.huge
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") and v.PrimaryPart then
            local dist = (RootPart.Position - v.PrimaryPart.Position).Magnitude
            if dist < distance then
                distance = dist
                nearest = v
            end
        end
    end
    return nearest
end

function FindNearestPresent()
    local nearest = nil
    local distance = math.huge
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Present" and v:IsA("BasePart") then
            local dist = (RootPart.Position - v.Position).Magnitude
            if dist < distance then
                distance = dist
                nearest = v
            end
        end
    end
    return nearest
end

function FindNearestGift()
    local nearest = nil
    local distance = math.huge
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Gift" and v:IsA("BasePart") then
            local dist = (RootPart.Position - v.Position).Magnitude
            if dist < distance then
                distance = dist
                nearest = v
            end
        end
    end
    return nearest
end

function FindChristmasTree()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "ChristmasTree" or v.Name == "Tree" then
            return v
        end
    end
    return nil
end

function FindNearestPlayer()
    local nearest = nil
    local distance = math.huge
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < distance then
                distance = dist
                nearest = player
            end
        end
    end
    return nearest
end

-- Utility Functions
function GetPlayerList()
    local players = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player then
            table.insert(players, player.Name)
        end
    end
    return players
end

-- Character update
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

--==================================================
-- FINALIZATION
--==================================================

print("========================================")
print("✅ Violence District Script Loaded!")
print("📁 GitHub: LuckyBimZy/Machadepanmu")
print("🕒 " .. os.date("%Y-%m-%d %H:%M:%S"))
print("========================================")

_G.ViolenceLoaded = true
return true