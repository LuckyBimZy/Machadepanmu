-- ==================== VIOLENCE DISTRICT - PROFESSIONAL EDITION ====================
-- UI Sederhana, Ringan, dan Profesional
-- Author: LuckyBimZy
-- Version: 6.1 (Fixed)

if _G.VD_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Violence District",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.VD_Loaded = true

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

-- Toggles - SEMUA STATUS DISIMPAN DI SINI
local Toggles = {
    -- Visuals
    ESP = false,
    ESPType = "Highlight",
    Wallhack = false,
    FullBright = false,
    NoFog = false,
    
    -- Survivor
    AutoPresent = false,
    AutoGift = false,
    AutoCoins = false,
    AutoHeal = false,
    SpeedBoost = false,
    JumpBoost = false,
    SpeedValue = 50,
    JumpValue = 100,
    
    -- Killer
    Aimbot = false,
    KillAura = false,
    KillAuraRange = 20,
    
    -- Teleport
    NoClip = false,
    TeleportToMouse = false,
    
    -- Farm
    AutoGenerator = false,
    AutoComplete = false,
    
    -- Misc
    AntiAFK = false,
    NoSkillCheck = false,
    AutoClick = false
}

-- Loops
local Loops = {}
local SavedPosition = nil
local GUIState = "open"
local ESPObjects = {}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Violence District",
        Text = msg,
        Duration = 2
    })
end

Notify("Script loaded successfully!")

--==================================================
-- CREATE SIMPLE UI
--==================================================

-- Clean old GUI
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "VD_Pro" then v:Destroy() end
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_Pro"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

--==================================================
-- FLOATING BUTTON
--==================================================
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatBtn"
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -22.5)
FloatBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
FloatBtn.Text = "🎮"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextSize = 24
FloatBtn.Font = Enum.Font.Gotham
FloatBtn.BorderSizePixel = 0
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui

-- Rounded corners
local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 10)
FloatCorner.Parent = FloatBtn

-- Shadow
local FloatShadow = Instance.new("Frame")
FloatShadow.Size = UDim2.new(1, 6, 1, 6)
FloatShadow.Position = UDim2.new(0, -3, 0, -3)
FloatShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FloatShadow.BackgroundTransparency = 0.7
FloatShadow.BorderSizePixel = 0
FloatShadow.Parent = FloatBtn

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 12)
ShadowCorner.Parent = FloatShadow

-- Hover effect
FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 48, 0, 48)}):Play()
end)

FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 45, 0, 45)}):Play()
end)

--==================================================
-- MAIN MENU
--==================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 480)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Main corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Main shadow
local MainShadow = Instance.new("Frame")
MainShadow.Size = UDim2.new(1, 8, 1, 8)
MainShadow.Position = UDim2.new(0, -4, 0, -4)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.6
MainShadow.BorderSizePixel = 0
MainShadow.Parent = MainFrame

local MainShadowCorner = Instance.new("UICorner")
MainShadowCorner.CornerRadius = UDim.new(0, 10)
MainShadowCorner.Parent = MainShadow

--==================================================
-- TITLE BAR
--==================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Violence District"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 15
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 50, 1, 0)
VersionText.Position = UDim2.new(1, -60, 0, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v6.1"
VersionText.TextColor3 = Color3.fromRGB(150, 150, 150)
VersionText.TextSize = 11
VersionText.Font = Enum.Font.Gotham
VersionText.Parent = TitleBar

-- Control buttons
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -55, 0.5, -12.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Text = "🎯"
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.VD_Loaded = false
end)

--==================================================
-- TABS
--==================================================
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 35)
TabFrame.Position = UDim2.new(0, 10, 0, 45)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"Main", "Visuals", "Survivor", "Killer", "Teleport", "Farm", "Misc"}
local TabIcons = {"🏠", "👁️", "🛡️", "⚔️", "🌀", "⚡", "⚙️"}
local TabButtons = {}
local CurrentTab = "Main"

for i = 1, #Tabs do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 48, 0, 35)
    TabBtn.Position = UDim2.new(0, (i-1) * 50, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TabBtn.Text = TabIcons[i]
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 18
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn
    
    -- Hover
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= Tabs[i] then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= Tabs[i] then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = Tabs[i]
        for _, btn in pairs(TabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 105, 225)}):Play()
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        UpdateTab(Tabs[i])
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Set first tab active
TabButtons[1].BackgroundColor3 = Color3.fromRGB(65, 105, 225)
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

--==================================================
-- CONTENT AREA
--==================================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -95)
ContentFrame.Position = UDim2.new(0, 10, 0, 85)
ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 6)
ContentCorner.Parent = ContentFrame

-- Scrolling frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 105, 225)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

--==================================================
-- UI ELEMENTS FUNCTIONS
--==================================================

function CreateSection(title)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, -10, 0, 25)
    Section.Position = UDim2.new(0, 5, 0, 0)
    Section.BackgroundTransparency = 1
    Section.Text = title
    Section.TextColor3 = Color3.fromRGB(65, 105, 225)
    Section.TextSize = 13
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, -1)
    Line.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section
end

function CreateToggle(text, varName)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 32)
    ToggleFrame.Position = UDim2.new(0, 5, 0, 0)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, -10, 1, 0)
    ToggleText.Position = UDim2.new(0, 10, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 12
    ToggleText.Font = Enum.Font.Gotham
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 55, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -65, 0.5, -12)
    ToggleBtn.BackgroundColor3 = Toggles[varName] and Color3.fromRGB(65, 105, 225) or Color3.fromRGB(50, 50, 55)
    ToggleBtn.Text = Toggles[varName] and "ON" or "OFF"
    ToggleBtn.TextColor3 = Toggles[varName] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 11
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Toggles[varName] = not Toggles[varName]
        if Toggles[varName] then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
            ToggleBtn.Text = "ON"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            ToggleBtn.Text = "OFF"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        -- Panggil fungsi sesuai toggle
        HandleToggle(varName, Toggles[varName])
    end)
end

function CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Position = UDim2.new(0, 5, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Parent = ScrollingFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
end

function CreateDropdown(text, varName, options)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -10, 0, 32)
    DropdownFrame.Position = UDim2.new(0, 5, 0, 0)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Parent = ScrollingFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 4)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -10, 1, 0)
    DropdownText.Position = UDim2.new(0, 10, 0, 0)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 12
    DropdownText.Font = Enum.Font.Gotham
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 100, 0, 24)
    DropdownBtn.Position = UDim2.new(1, -110, 0.5, -12)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    DropdownBtn.Text = Toggles[varName] or options[1]
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 11
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        -- Hapus menu lama
        local oldMenu = DropdownFrame:FindFirstChild("DropdownMenu")
        if oldMenu then oldMenu:Destroy() end
        
        -- Buat menu baru
        local menu = Instance.new("Frame")
        menu.Name = "DropdownMenu"
        menu.Size = UDim2.new(0, 120, 0, math.min(#options, 5) * 28)
        menu.Position = UDim2.new(1, -110, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        menu.ZIndex = 10
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 4)
        menuCorner.Parent = menu
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -2, 0, 28)
            optBtn.Position = UDim2.new(0, 1, 0, (i-1) * 28)
            optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextSize = 11
            optBtn.Font = Enum.Font.Gotham
            optBtn.BorderSizePixel = 0
            optBtn.Parent = menu
            optBtn.ZIndex = 11
            
            optBtn.MouseButton1Click:Connect(function()
                DropdownBtn.Text = option
                Toggles[varName] = option
                HandleToggle(varName, option)
                menu:Destroy()
            end)
        end
    end)
end

function CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "• " .. text
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ScrollingFrame
end

function CreateSlider(text, varName, min, max)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.Position = UDim2.new(0, 5, 0, 0)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = ScrollingFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.5, -10, 0, 18)
    SliderText.Position = UDim2.new(0, 10, 0, 5)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 12
    SliderText.Font = Enum.Font.Gotham
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueBox = Instance.new("TextBox")
    ValueBox.Size = UDim2.new(0, 50, 0, 20)
    ValueBox.Position = UDim2.new(1, -60, 0, 4)
    ValueBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ValueBox.Text = tostring(Toggles[varName])
    ValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueBox.TextSize = 11
    ValueBox.Font = Enum.Font.GothamBold
    ValueBox.ClearTextOnFocus = false
    ValueBox.Parent = SliderFrame
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 4)
    ValueCorner.Parent = ValueBox
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -80, 0, 4)
    SliderBg.Position = UDim2.new(0, 10, 0, 35)
    SliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Toggles[varName] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    SliderFill.Parent = SliderBg
    
    local SliderButton = Instance.new("Frame")
    SliderButton.Size = UDim2.new(0, 12, 0, 12)
    SliderButton.Position = UDim2.new((Toggles[varName] - min) / (max - min), -6, 0.5, -6)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Parent = SliderFill
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = SliderButton
    
    -- Value update function
    local function updateValue(newValue)
        newValue = math.clamp(newValue, min, max)
        local percent = (newValue - min) / (max - min)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderButton.Position = UDim2.new(percent, -6, 0.5, -6)
        ValueBox.Text = tostring(math.floor(newValue))
        Toggles[varName] = math.floor(newValue)
        HandleToggle(varName, math.floor(newValue))
    end
    
    -- Input box
    ValueBox.FocusLost:Connect(function()
        local val = tonumber(ValueBox.Text)
        if val then
            updateValue(val)
        else
            ValueBox.Text = tostring(Toggles[varName])
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
            local value = min + (max - min) * percent
            updateValue(value)
        end
    end)
end

--==================================================
-- HANDLE TOGGLE FUNCTIONS
--==================================================
function HandleToggle(name, value)
    if name == "ESP" then
        if value then EnableESP() else DisableESP() end
    elseif name == "ESPType" then
        if Toggles.ESP then DisableESP() EnableESP() end
    elseif name == "Wallhack" then
        UpdateWallhack()
    elseif name == "FullBright" then
        if value then
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
    elseif name == "NoFog" then
        Lighting.FogEnd = value and 1e9 or 100000
    elseif name == "AutoPresent" then
        if value then StartLoop("Present") else StopLoop("Present") end
    elseif name == "AutoGift" then
        if value then StartLoop("Gift") else StopLoop("Gift") end
    elseif name == "AutoCoins" then
        if value then StartLoop("Coins") else StopLoop("Coins") end
    elseif name == "AutoHeal" then
        if value then StartLoop("Heal") else StopLoop("Heal") end
    elseif name == "SpeedBoost" then
        if value then
            Player.Character.Humanoid.WalkSpeed = Toggles.SpeedValue
        else
            Player.Character.Humanoid.WalkSpeed = 16
        end
    elseif name == "SpeedValue" then
        if Toggles.SpeedBoost then
            Player.Character.Humanoid.WalkSpeed = value
        end
    elseif name == "JumpBoost" then
        if value then
            Player.Character.Humanoid.JumpPower = Toggles.JumpValue
        else
            Player.Character.Humanoid.JumpPower = 50
        end
    elseif name == "JumpValue" then
        if Toggles.JumpBoost then
            Player.Character.Humanoid.JumpPower = value
        end
    elseif name == "Aimbot" then
        if value then StartLoop("Aimbot") else StopLoop("Aimbot") end
    elseif name == "KillAura" then
        if value then StartLoop("KillAura") else StopLoop("KillAura") end
    elseif name == "NoClip" then
        UpdateNoClip()
    elseif name == "AutoGenerator" then
        if value then StartLoop("Generator") else StopLoop("Generator") end
    elseif name == "AutoComplete" then
        if value then StartLoop("Complete") else StopLoop("Complete") end
    elseif name == "AntiAFK" then
        if value then
            Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    elseif name == "AutoClick" then
        if value then StartLoop("Click") else StopLoop("Click") end
    elseif name == "NoSkillCheck" then
        ToggleSkillCheck(value)
    end
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
    
    if tab == "Main" then
        CreateSection("PLAYER INFO")
        CreateLabel("Name: " .. Player.Name)
        CreateLabel("Display: " .. Player.DisplayName)
        CreateLabel("Age: " .. Player.AccountAge .. " days")
        
        CreateSection("SERVER INFO")
        CreateLabel("Players: " .. #Players:GetPlayers())
        CreateLabel("Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms")
        
        CreateSection("QUICK ACTIONS")
        CreateButton("Refresh", function() UpdateTab("Main") end)
        CreateButton("Rejoin", function() game:GetService("TeleportService"):Teleport(game.PlaceId, Player) end)
        
        CreateSection("CREDITS")
        CreateLabel("Violence District v6.1")
        CreateLabel("Professional Edition")
        
    elseif tab == "Visuals" then
        CreateSection("ESP SETTINGS")
        CreateToggle("Enable ESP", "ESP")
        CreateDropdown("ESP Type", "ESPType", {"Highlight", "Box", "Name"})
        CreateToggle("Wallhack", "Wallhack")
        
        CreateSection("VISUALS")
        CreateToggle("Full Bright", "FullBright")
        CreateToggle("No Fog", "NoFog")
        
    elseif tab == "Survivor" then
        CreateSection("AUTO FARM")
        CreateToggle("Auto Present", "AutoPresent")
        CreateToggle("Auto Gift", "AutoGift")
        CreateToggle("Auto Coins", "AutoCoins")
        CreateToggle("Auto Heal", "AutoHeal")
        
        CreateSection("MOVEMENT")
        CreateToggle("Speed Boost", "SpeedBoost")
        CreateSlider("Speed", "SpeedValue", 16, 200)
        CreateToggle("Jump Boost", "JumpBoost")
        CreateSlider("Jump", "JumpValue", 50, 200)
        
    elseif tab == "Killer" then
        CreateSection("COMBAT")
        CreateToggle("Aimbot", "Aimbot")
        CreateToggle("Kill Aura", "KillAura")
        CreateSlider("Range", "KillAuraRange", 5, 50)
        
        CreateSection("TARGET")
        local target = FindNearestPlayer()
        if target then
            local dist = (Player.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
            CreateLabel("Nearest: " .. target.Name)
            CreateLabel("Distance: " .. math.floor(dist) .. "m")
        else
            CreateLabel("No players nearby")
        end
        
    elseif tab == "Teleport" then
        CreateSection("MOVEMENT")
        CreateToggle("NoClip", "NoClip")
        CreateToggle("TP to Mouse", "TeleportToMouse")
        
        CreateSection("TELEPORT")
        CreateDropdown("Target", "TeleportTarget", GetPlayerList())
        CreateButton("Refresh List", function() UpdateTab("Teleport") end)
        
        CreateSection("WAYPOINTS")
        CreateButton("Save Position", function()
            SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Position saved!")
        end)
        
        CreateButton("Load Position", function()
            if SavedPosition then
                Player.Character.HumanoidRootPart.CFrame = SavedPosition
                Notify("Teleported to saved position")
            end
        end)
        
    elseif tab == "Farm" then
        CreateSection("GENERATOR")
        CreateToggle("Auto Farm", "AutoGenerator")
        CreateToggle("Auto Complete", "AutoComplete")
        
        CreateButton("Find Generator", function()
            local gen = FindNearestGenerator()
            if gen then
                Player.Character.HumanoidRootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
                Notify("Found generator")
            end
        end)
        
        CreateLabel("Generators: " .. CountGenerators())
        CreateLabel("Presents: " .. CountPresents())
        CreateLabel("Gifts: " .. CountGifts())
        
    elseif tab == "Misc" then
        CreateSection("UTILITY")
        CreateToggle("Anti AFK", "AntiAFK")
        CreateToggle("Auto Click", "AutoClick")
        CreateToggle("No Skill Check", "NoSkillCheck")
        
        CreateSection("GUI")
        CreateButton("Toggle Menu", function()
            MainFrame.Visible = not MainFrame.Visible
            FloatBtn.Text = MainFrame.Visible and "🎮" or "🎯"
        end)
        
        CreateButton("Close GUI", function()
            ScreenGui:Destroy()
            _G.VD_Loaded = false
        end)
        
        local active = 0
        for _, v in pairs(Loops) do if v then active = active + 1 end end
        CreateLabel("Active: " .. active .. " features")
    end
    
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- TOGGLE HANDLERS
--==================================================
FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    FloatBtn.Text = MainFrame.Visible and "🎮" or "🎯"
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        MainFrame.Visible = not MainFrame.Visible
        FloatBtn.Text = MainFrame.Visible and "🎮" or "🎯"
    end
end)

--==================================================
-- CORE FUNCTIONS
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            
            if name == "Present" and Toggles.AutoPresent then
                local present = FindNearestPresent()
                if present then
                    Player.Character.HumanoidRootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
                
            elseif name == "Gift" and Toggles.AutoGift then
                local gift = FindNearestGift()
                if gift then
                    Player.Character.HumanoidRootPart.CFrame = gift.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                        local tree = FindChristmasTree()
                        if tree then
                            task.wait(0.3)
                            if tree:IsA("Model") and tree.PrimaryPart then
                                Player.Character.HumanoidRootPart.CFrame = tree.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                            end
                        end
                    end
                end
                
            elseif name == "Coins" and Toggles.AutoCoins then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Coin" and v:IsA("BasePart") then
                        local dist = (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude
                        if dist < 30 then
                            Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.1)
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then fireproximityprompt(prompt) end
                            break
                        end
                    end
                end
                
            elseif name == "Heal" and Toggles.AutoHeal then
                if Player.Character.Humanoid.Health < 50 then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then pcall(function() remote:FireServer("Heal") end) end
                end
                
            elseif name == "Aimbot" and Toggles.Aimbot then
                local target = FindNearestPlayer()
                if target and target.Character then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    Player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(Player.Character.HumanoidRootPart.Position, targetPos)
                end
                
            elseif name == "KillAura" and Toggles.KillAura then
                local range = Toggles.KillAuraRange
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
                        local dist = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= range then
                            player.Character.Humanoid.Health = 0
                        end
                    end
                end
                
            elseif name == "Generator" and Toggles.AutoGenerator then
                local gen = FindNearestGenerator()
                if gen and gen.PrimaryPart then
                    Player.Character.HumanoidRootPart.CFrame = gen.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = gen:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                    else
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                        if remote then pcall(function() remote:FireServer("RepairGenerator", gen) end) end
                    end
                end
                
            elseif name == "Complete" and Toggles.AutoComplete then
                local gen = FindNearestGenerator()
                if gen then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then pcall(function() remote:FireServer("CompleteGenerator", gen) end) end
                end
                
            elseif name == "Click" and Toggles.AutoClick then
                mouse1click()
            end
            
            task.wait(0.1)
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

function EnableESP()
    DisableESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "VD_ESP"
            highlight.Parent = player.Character
            highlight.FillColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.5
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "VD_Name"
            billboard.Parent = player.Character
            billboard.Size = UDim2.new(0, 100, 0, 20)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = billboard
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
        end
    end
end

function DisableESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("VD_ESP")
            if highlight then highlight:Destroy() end
            local nameTag = player.Character:FindFirstChild("VD_Name")
            if nameTag then nameTag:Destroy() end
        end
    end
end

function UpdateWallhack()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if Toggles.Wallhack then
                if v.Transparency < 0.5 then
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

function UpdateNoClip()
    if Toggles.NoClip then
        RunService:BindToRenderStep("NoClip", 0, function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("NoClip")
        if Player.Character then
            for _, part in pairs(Player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

function ToggleSkillCheck(state)
    if state then
        local mt = getrawmetatable(game)
        if mt then
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "FireServer" and tostring(self):find("SkillCheck") then
                    return
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end
end

-- Teleport to mouse
UserInputService.InputBegan:Connect(function(input)
    if Toggles.TeleportToMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = Mouse.Hit.p
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(target.X, target.Y + 3, target.Z)
    end
end)

-- Dropdown untuk target teleport
function CreateDropdown(text, varName, options)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -10, 0, 32)
    DropdownFrame.Position = UDim2.new(0, 5, 0, 0)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Parent = ScrollingFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 4)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -10, 1, 0)
    DropdownText.Position = UDim2.new(0, 10, 0, 0)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 12
    DropdownText.Font = Enum.Font.Gotham
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 100, 0, 24)
    DropdownBtn.Position = UDim2.new(1, -110, 0.5, -12)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    DropdownBtn.Text = options[1] or "Select"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 11
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        -- Hapus menu lama
        local oldMenu = DropdownFrame:FindFirstChild("DropdownMenu")
        if oldMenu then oldMenu:Destroy() end
        
        -- Buat menu baru
        local menu = Instance.new("Frame")
        menu.Name = "DropdownMenu"
        menu.Size = UDim2.new(0, 120, 0, math.min(#options, 5) * 28)
        menu.Position = UDim2.new(1, -110, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        menu.ZIndex = 10
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 4)
        menuCorner.Parent = menu
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -2, 0, 28)
            optBtn.Position = UDim2.new(0, 1, 0, (i-1) * 28)
            optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextSize = 11
            optBtn.Font = Enum.Font.Gotham
            optBtn.BorderSizePixel = 0
            optBtn.Parent = menu
            optBtn.ZIndex = 11
            
            optBtn.MouseButton1Click:Connect(function()
                DropdownBtn.Text = option
                local target = Players:FindFirstChild(option)
                if target and target.Character then
                    Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    Notify("Teleported to " .. option)
                end
                menu:Destroy()
            end)
        end
    end)
end

-- Find functions
function FindNearestGenerator()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") and v.PrimaryPart then
            local d = (root.Position - v.PrimaryPart.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function CountGenerators()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") then
            count = count + 1
        end
    end
    return count
end

function FindNearestPresent()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Present" and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function CountPresents()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Present" and v:IsA("BasePart") then
            count = count + 1
        end
    end
    return count
end

function FindNearestGift()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Gift" and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function CountGifts()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Gift" and v:IsA("BasePart") then
            count = count + 1
        end
    end
    return count
end

function FindChristmasTree()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "ChristmasTree" or v.Name == "Tree" then
            return v
        end
    end
    return nil
end

function FindNearestPlayer()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist, nearest = d, player
            end
        end
    end
    return nearest
end

function GetPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(list, player.Name)
        end
    end
    return list
end

-- Character update
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
end)

--==================================================
-- INITIALIZE
--==================================================
UpdateTab("Main")
Notify("Press F4 or click floating button")

print("=== Violence District Professional Loaded ===")
print("Press F4 to toggle menu")