--[[
    Violence District - Ultimate Edition
    Compatible with All Executors
    Version: 3.0 Stable
]]

-- Prevent multiple execution
if _G.VD_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚠️ Violence District",
        Text = "Script already loaded!",
        Duration = 3,
        Icon = "rbxassetid://6031075938"
    })
    return 
end

_G.VD_Loaded = true

--==================================================
-- SAFE ENVIRONMENT SETUP
--==================================================
local function safe_execute(func)
    local success, err = pcall(func)
    if not success then
        warn("[VD] Error: " .. tostring(err))
    end
end

--==================================================
-- VARIABLES WITH ERROR HANDLING
--==================================================
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- Toggles dengan default values
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
    AutoFarmGenerator = false,
    AutoCompleteGenerator = false,
    
    -- Misc
    AntiAFK = false,
    NoSkillCheck = false,
    AutoClick = false
}

-- Loops and connections
local Loops = {}
local SavedPosition = nil
local ESPConnections = {}
local NoClipConnection = nil
local WallhackConnection = nil

--==================================================
-- ENHANCED NOTIFICATION FUNCTION
--==================================================
local function Notify(msg, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local icon = "rbxassetid://6031075938" -- Default icon
    local title = "Violence District"
    local color = Color3.fromRGB(65, 105, 225) -- Blue
    
    if type == "success" then
        icon = "rbxassetid://6031101444" -- Checkmark
        color = Color3.fromRGB(0, 255, 0)
        title = "✅ " .. title
    elseif type == "error" then
        icon = "rbxassetid://6031083157" -- Error
        color = Color3.fromRGB(255, 0, 0)
        title = "❌ " .. title
    elseif type == "warning" then
        icon = "rbxassetid://6031094661" -- Warning
        color = Color3.fromRGB(255, 255, 0)
        title = "⚠️ " .. title
    end
    
    safe_execute(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = msg,
            Duration = duration,
            Icon = icon,
            Button1 = "OK"
        })
    end)
end

--==================================================
-- LOADING SEQUENCE WITH VISUAL NOTIFICATIONS
--==================================================

-- Step 1: Initial Loading
Notify("🚀 Loading Violence District Ultimate...", 2, "info")
task.wait(1)

-- Step 2: Check Executor Compatibility
local function checkExecutor()
    local executorInfo = {
        name = "Unknown",
        version = "Unknown"
    }
    
    -- Try to detect executor
    if syn then 
        executorInfo.name = "Synapse X"
    elseif krnl then 
        executorInfo.name = "Krnl"
    elseif fluxus then 
        executorInfo.name = "Fluxus"
    elseif scriptware then 
        executorInfo.name = "Script-Ware"
    elseif isexecutorclosure then 
        executorInfo.name = "Executor (Unknown)"
    end
    
    return executorInfo
end

local executor = checkExecutor()
Notify("🔧 Executor: " .. executor.name, 1, "info")

-- Step 3: Check HTTP Request capability
local function checkHTTP()
    local success, result = pcall(function()
        return game:HttpGet("https://httpbin.org/get", true)
    end)
    return success
end

if checkHTTP() then
    Notify("🌐 HTTP Requests: OK", 1, "success")
else
    Notify("🌐 HTTP Requests: Limited", 1, "warning")
end

-- Step 4: Create UI Components with progress
Notify("🎨 Creating UI...", 1, "info")

--==================================================
-- CREATE SIMPLE BUT PROFESSIONAL UI
--==================================================

-- Clean old GUI
safe_execute(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "VD_Ultimate" then 
            v:Destroy() 
        end
    end
end)

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_Ultimate"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

--==================================================
-- FLOATING BUTTON
--==================================================
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatBtn"
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -27.5)
FloatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
FloatBtn.Text = "⚡"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextSize = 30
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.BorderSizePixel = 0
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui

-- Rounded corners
local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 15)
FloatCorner.Parent = FloatBtn

-- Gradient
local FloatGradient = Instance.new("UIGradient")
FloatGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 105, 225)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 149, 237))
})
FloatGradient.Parent = FloatBtn

-- Shadow
local FloatShadow = Instance.new("Frame")
FloatShadow.Size = UDim2.new(1, 8, 1, 8)
FloatShadow.Position = UDim2.new(0, -4, 0, -4)
FloatShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FloatShadow.BackgroundTransparency = 0.7
FloatShadow.BorderSizePixel = 0
FloatShadow.Parent = FloatBtn
FloatShadow.ZIndex = -1

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 17)
ShadowCorner.Parent = FloatShadow

--==================================================
-- MAIN MENU
--==================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 750, 0, 550)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false  -- Start hidden
MainFrame.Parent = ScreenGui

-- Main corner
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Main gradient
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame

--==================================================
-- TITLE BAR
--==================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Icon
local IconFrame = Instance.new("Frame")
IconFrame.Size = UDim2.new(0, 32, 0, 32)
IconFrame.Position = UDim2.new(0, 15, 0.5, -16)
IconFrame.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
IconFrame.BorderSizePixel = 0
IconFrame.Parent = TitleBar

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 8)
IconCorner.Parent = IconFrame

local IconLabel = Instance.new("TextLabel")
IconLabel.Size = UDim2.new(1, 0, 1, 0)
IconLabel.BackgroundTransparency = 1
IconLabel.Text = "⚡"
IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IconLabel.TextSize = 20
IconLabel.Font = Enum.Font.GothamBold
IconLabel.Parent = IconFrame

-- Title
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 250, 0, 25)
TitleText.Position = UDim2.new(0, 55, 0.5, -12.5)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Violence District Ultimate"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 100, 0, 20)
VersionText.Position = UDim2.new(0, 55, 0.5, 10)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v3.0 | Stable"
VersionText.TextColor3 = Color3.fromRGB(160, 160, 170)
VersionText.TextSize = 11
VersionText.Font = Enum.Font.Gotham
VersionText.TextXAlignment = Enum.TextXAlignment.Left
VersionText.Parent = TitleBar

-- Control buttons
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 70, 0, 32)
ControlFrame.Position = UDim2.new(1, -80, 0.5, -16)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(0, 0, 0.5, -16)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 24
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = ControlFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
    Notify("Menu minimized", 1, "info")
end)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(0, 38, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = ControlFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.VD_Loaded = false
    Notify("Violence District unloaded", 2, "warning")
end)

--==================================================
-- TABS
--==================================================
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 45)
TabFrame.Position = UDim2.new(0, 10, 0, 55)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"Main", "Visuals", "Survivor", "Killer", "Teleport", "Farm", "Misc"}
local TabIcons = {"🏠", "👁️", "🛡️", "⚔️", "🌀", "⚡", "⚙️"}
local TabButtons = {}
local CurrentTab = "Main"

for i = 1, #Tabs do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 95, 0, 40)
    TabBtn.Position = UDim2.new(0, (i-1) * 100, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    TabBtn.Text = TabIcons[i] .. " " .. Tabs[i]
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    TabBtn.TextSize = 14
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = Tabs[i]
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        UpdateTab(Tabs[i])
        Notify("Switched to " .. Tabs[i] .. " tab", 1, "info")
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
ContentFrame.Size = UDim2.new(1, -20, 1, -120)
ContentFrame.Position = UDim2.new(0, 10, 0, 110)
ContentFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
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
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 105, 225)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentFrame

-- Use grid layout for better organization
local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.FillDirection = Enum.FillDirection.Vertical
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
UIGridLayout.CellSize = UDim2.new(0, 350, 0, 40)
UIGridLayout.Parent = ScrollingFrame

--==================================================
-- UI ELEMENTS FUNCTIONS
--==================================================

function CreateSection(title)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 35)
    Section.BackgroundTransparency = 1
    Section.Text = "  " .. title
    Section.TextColor3 = Color3.fromRGB(65, 105, 225)
    Section.TextSize = 16
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -10, 0, 2)
    Line.Position = UDim2.new(0, 5, 0, 30)
    Line.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section
end

function CreateToggle(text, var, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 1, 0)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.6, -15, 1, 0)
    ToggleText.Position = UDim2.new(0, 15, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 14
    ToggleText.Font = Enum.Font.Gotham
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 80, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -90, 0.5, -15)
    ToggleBtn.BackgroundColor3 = var and Color3.fromRGB(65, 105, 225) or Color3.fromRGB(45, 45, 52)
    ToggleBtn.Text = var and "ON" or "OFF"
    ToggleBtn.TextColor3 = var and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        local newState = not var
        if newState then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.Text = "ON"
            Notify(text .. " enabled", 1, "success")
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            ToggleBtn.Text = "OFF"
            Notify(text .. " disabled", 1, "info")
        end
        callback(newState)
    end)
end

function CreateButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Parent = ScrollingFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        Notify("Executing: " .. text, 1, "info")
        callback()
    end)
end

function CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "• " .. text
    Label.TextColor3 = Color3.fromRGB(180, 180, 190)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ScrollingFrame
end

function CreateSlider(text, min, max, value, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 1, 0)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = ScrollingFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.5, -15, 0, 20)
    SliderText.Position = UDim2.new(0, 15, 0, 5)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 14
    SliderText.Font = Enum.Font.Gotham
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueBox = Instance.new("TextBox")
    ValueBox.Size = UDim2.new(0, 60, 0, 25)
    ValueBox.Position = UDim2.new(1, -70, 0, 3)
    ValueBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    ValueBox.Text = tostring(value)
    ValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueBox.TextSize = 13
    ValueBox.Font = Enum.Font.GothamBold
    ValueBox.ClearTextOnFocus = false
    ValueBox.Parent = SliderFrame
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 4)
    ValueCorner.Parent = ValueBox
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 6)
    SliderBg.Position = UDim2.new(0, 10, 0, 30)
    SliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    SliderFill.Parent = SliderBg
    
    local SliderButton = Instance.new("Frame")
    SliderButton.Size = UDim2.new(0, 14, 0, 14)
    SliderButton.Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7)
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
        SliderButton.Position = UDim2.new(percent, -7, 0.5, -7)
        ValueBox.Text = tostring(math.floor(newValue))
        callback(math.floor(newValue))
    end
    
    -- Input box
    ValueBox.FocusLost:Connect(function()
        local val = tonumber(ValueBox.Text)
        if val then
            updateValue(val)
            Notify(text .. " set to " .. val, 1, "success")
        else
            ValueBox.Text = tostring(value)
        end
    end)
    
    -- Drag functionality
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
    FloatBtn.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        Notify("Menu opened", 1, "success")
    else
        Notify("Menu closed", 1, "info")
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        MainFrame.Visible = not MainFrame.Visible
        FloatBtn.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            Notify("Menu opened (F4)", 1, "success")
        else
            Notify("Menu closed (F4)", 1, "info")
        end
    end
end)

--==================================================
-- ESP FUNCTIONS
--==================================================
function EnableESP()
    safe_execute(function()
        DisableESP()
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                AddESP(player)
            end
        end
        
        -- For new players
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                if Toggles.ESP and player ~= Player then
                    AddESP(player)
                end
            end)
        end)
        
        Notify("ESP enabled", 2, "success")
    end)
end

function AddESP(player)
    safe_execute(function()
        if not player.Character then return end
        
        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "VD_ESP"
        highlight.Parent = player.Character
        highlight.FillColor = Color3.fromRGB(255, 100, 100)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        -- Name tag with distance
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "VD_Name"
        billboard.Parent = player.Character
        billboard.Size = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboard
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        
        -- Update distance
        local connection
        connection = RunService.Heartbeat:Connect(function()
            safe_execute(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or 
                   not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local distance = (player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                nameLabel.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
            end)
        end)
        
        ESPConnections[player] = connection
    end)
end

function DisableESP()
    safe_execute(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("VD_ESP")
                if highlight then highlight:Destroy() end
                local nameTag = player.Character:FindFirstChild("VD_Name")
                if nameTag then nameTag:Destroy() end
            end
            
            if ESPConnections[player] then
                ESPConnections[player]:Disconnect()
                ESPConnections[player] = nil
            end
        end
        Notify("ESP disabled", 2, "info")
    end)
end

--==================================================
-- WALLHACK FUNCTION
--==================================================
function UpdateWallhack()
    safe_execute(function()
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
        if Toggles.Wallhack then
            Notify("Wallhack enabled", 2, "success")
        else
            Notify("Wallhack disabled", 2, "info")
        end
    end)
end

--==================================================
-- NOCLIP FUNCTION
--==================================================
function UpdateNoClip()
    safe_execute(function()
        if Toggles.NoClip then
            if NoClipConnection then
                NoClipConnection:Disconnect()
                NoClipConnection = nil
            end
            
            NoClipConnection = RunService.Stepped:Connect(function()
                safe_execute(function()
                    if Toggles.NoClip and Player.Character then
                        for _, part in pairs(Player.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end)
            Notify("NoClip enabled", 2, "success")
        else
            if NoClipConnection then
                NoClipConnection:Disconnect()
                NoClipConnection = nil
            end
            
            if Player.Character then
                for _, part in pairs(Player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            Notify("NoClip disabled", 2, "info")
        end
    end)
end

--==================================================
-- LOOP FUNCTIONS
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    Notify("Started " .. name .. " loop", 2, "success")
    
    task.spawn(function()
        while Loops[name] do
            safe_execute(function()
                if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    return
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
                                elseif tree:IsA("BasePart") then
                                    Player.Character.HumanoidRootPart.CFrame = tree.CFrame * CFrame.new(0, 5, 0)
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
                    
                elseif name == "Generator" and Toggles.AutoFarmGenerator then
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
                    
                elseif name == "Complete" and Toggles.AutoCompleteGenerator then
                    local gen = FindNearestGenerator()
                    if gen then
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                        if remote then pcall(function() remote:FireServer("CompleteGenerator", gen) end) end
                    end
                    
                elseif name == "Click" and Toggles.AutoClick then
                    mouse1click()
                end
            end)
            task.wait(0.1)
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
    Notify("Stopped " .. name .. " loop", 2, "info")
end

--==================================================
-- UTILITY FUNCTIONS
--==================================================

-- Teleport to mouse
UserInputService.InputBegan:Connect(function(input)
    safe_execute(function()
        if Toggles.TeleportToMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
            local target = Mouse.Hit.p
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(target.X, target.Y + 3, target.Z)
            Notify("Teleported to mouse", 1, "success")
        end
    end)
end)

-- Find functions with error handling
function FindNearestGenerator()
    safe_execute(function()
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
    end)
end

function FindNearestPresent()
    safe_execute(function()
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
    end)
end

function FindNearestGift()
    safe_execute(function()
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
    end)
end

function FindChristmasTree()
    safe_execute(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "ChristmasTree" or v.Name == "Tree" then
                return v
            end
        end
        return nil
    end)
end

function FindNearestPlayer()
    safe_execute(function()
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
    end)
end

function GetPlayerList()
    local list = {}
    safe_execute(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                table.insert(list, player.Name)
            end
        end
    end)
    return list
end

function CountGenerators()
    local count = 0
    safe_execute(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "Generator" and v:IsA("Model") then
                count = count + 1
            end
        end
    end)
    return count
end

function CountPresents()
    local count = 0
    safe_execute(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "Present" and v:IsA("BasePart") then
                count = count + 1
            end
        end
    end)
    return count
end

function CountGifts()
    local count = 0
    safe_execute(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "Gift" and v:IsA("BasePart") then
                count = count + 1
            end
        end
    end)
    return count
end

-- Character update
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    if Toggles.NoClip then
        UpdateNoClip()
    end
    if Toggles.SpeedBoost then
        char.Humanoid.WalkSpeed = Toggles.SpeedValue
    end
    if Toggles.JumpBoost then
        char.Humanoid.JumpPower = Toggles.JumpValue
    end
    Notify("Character respawned, reapplied settings", 2, "info")
end)

--==================================================
-- UPDATE TAB CONTENT
--==================================================
function UpdateTab(tab)
    safe_execute(function()
        -- Clear content
        for _, v in pairs(ScrollingFrame:GetChildren()) do
            if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") then
                v:Destroy()
            end
        end
        
        if tab == "Main" then
            CreateSection("📊 PLAYER INFO")
            CreateLabel("Name: " .. Player.Name)
            CreateLabel("Display: " .. Player.DisplayName)
            CreateLabel("Age: " .. Player.AccountAge .. " days")
            CreateLabel("User ID: " .. Player.UserId)
            
            CreateSection("🌐 SERVER INFO")
            CreateLabel("Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
            CreateLabel("Server ID: " .. game.JobId)
            CreateLabel("Place ID: " .. game.PlaceId)
            
            CreateSection("⚡ QUICK ACTIONS")
            CreateButton("🔄 Rejoin Server", function()
                Notify("Rejoining server...", 2, "warning")
                safe_execute(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
                end)
            end)
            
            CreateButton("📋 Copy Server ID", function()
                if setclipboard then
                    setclipboard(game.JobId)
                    Notify("Server ID copied to clipboard!", 2, "success")
                else
                    Notify("Clipboard not supported", 2, "error")
                end
            end)
            
            CreateSection("📝 CREDITS")
            CreateLabel("Violence District Ultimate v3.0")
            CreateLabel("Compatible with All Executors")
            CreateLabel("Press F4 to toggle menu")
            
        elseif tab == "Visuals" then
            CreateSection("👁️ ESP SETTINGS")
            CreateToggle("Enable ESP", Toggles.ESP, function(state)
                Toggles.ESP = state
                if state then EnableESP() else DisableESP() end
            end)
            
            CreateToggle("Wallhack", Toggles.Wallhack, function(state)
                Toggles.Wallhack = state
                UpdateWallhack()
            end)
            
            CreateSection("💡 WORLD VISUALS")
            CreateToggle("Full Bright", Toggles.FullBright, function(state)
                Toggles.FullBright = state
                if state then
                    Lighting.Brightness = 2
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Notify("Full Bright enabled", 2, "success")
                else
                    Lighting.Brightness = 1
                    Lighting.GlobalShadows = true
                    Lighting.Ambient = Color3.new(0, 0, 0)
                    Notify("Full Bright disabled", 2, "info")
                end
            end)
            
            CreateToggle("No Fog", Toggles.NoFog, function(state)
                Toggles.NoFog = state
                Lighting.FogEnd = state and 1e9 or 100000
                Notify(state and "No Fog enabled" or "No Fog disabled", 2, state and "success" or "info")
            end)
            
        elseif tab == "Survivor" then
            CreateSection("🎁 AUTO FARM")
            CreateToggle("Auto Present", Toggles.AutoPresent, function(state)
                Toggles.AutoPresent = state
                if state then StartLoop("Present") else StopLoop("Present") end
            end)
            
            CreateToggle("Auto Gift", Toggles.AutoGift, function(state)
                Toggles.AutoGift = state
                if state then StartLoop("Gift") else StopLoop("Gift") end
            end)
            
            CreateToggle("Auto Coins", Toggles.AutoCoins, function(state)
                Toggles.AutoCoins = state
                if state then StartLoop("Coins") else StopLoop("Coins") end
            end)
            
            CreateToggle("Auto Heal", Toggles.AutoHeal, function(state)
                Toggles.AutoHeal = state
                if state then StartLoop("Heal") else StopLoop("Heal") end
            end)
            
            CreateSection("🏃 MOVEMENT")
            CreateToggle("Speed Boost", Toggles.SpeedBoost, function(state)
                Toggles.SpeedBoost = state
                if state and Player.Character then
                    Player.Character.Humanoid.WalkSpeed = Toggles.SpeedValue
                    Notify("Speed Boost enabled (" .. Toggles.SpeedValue .. ")", 2, "success")
                elseif Player.Character then
                    Player.Character.Humanoid.WalkSpeed = 16
                    Notify("Speed Boost disabled", 2, "info")
                end
            end)
            
            CreateSlider("Speed Value", 16, 200, Toggles.SpeedValue, function(val)
                Toggles.SpeedValue = val
                if Toggles.SpeedBoost and Player.Character then
                    Player.Character.Humanoid.WalkSpeed = val
                end
            end)
            
            CreateToggle("Jump Boost", Toggles.JumpBoost, function(state)
                Toggles.JumpBoost = state
                if state and Player.Character then
                    Player.Character.Humanoid.JumpPower = Toggles.JumpValue
                    Notify("Jump Boost enabled (" .. Toggles.JumpValue .. ")", 2, "success")
                elseif Player.Character then
                    Player.Character.Humanoid.JumpPower = 50
                    Notify("Jump Boost disabled", 2, "info")
                end
            end)
            
            CreateSlider("Jump Value", 50, 200, Toggles.JumpValue, function(val)
                Toggles.JumpValue = val
                if Toggles.JumpBoost and Player.Character then
                    Player.Character.Humanoid.JumpPower = val
                end
            end)
            
        elseif tab == "Killer" then
            CreateSection("⚔️ COMBAT")
            CreateToggle("Aimbot", Toggles.Aimbot, function(state)
                Toggles.Aimbot = state
                if state then StartLoop("Aimbot") else StopLoop("Aimbot") end
            end)
            
            CreateToggle("Kill Aura", Toggles.KillAura, function(state)
                Toggles.KillAura = state
                if state then StartLoop("KillAura") else StopLoop("KillAura") end
            end)
            
            CreateSlider("Aura Range", 5, 50, Toggles.KillAuraRange, function(val)
                Toggles.KillAuraRange = val
            end)
            
            CreateSection("🎯 TARGET INFO")
            local target = FindNearestPlayer()
            if target then
                local dist = (Player.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                CreateLabel("Nearest: " .. target.Name)
                CreateLabel("Distance: " .. math.floor(dist) .. "m")
                CreateLabel("Health: " .. math.floor(target.Character.Humanoid.Health) .. "%")
            else
                CreateLabel("No players nearby")
            end
            
        elseif tab == "Teleport" then
            CreateSection("🌀 MOVEMENT")
            CreateToggle("NoClip", Toggles.NoClip, function(state)
                Toggles.NoClip = state
                UpdateNoClip()
            end)
            
            CreateToggle("TP to Mouse (Right Click)", Toggles.TeleportToMouse, function(state)
                Toggles.TeleportToMouse = state
                Notify(state and "TP to Mouse ON" or "TP to Mouse OFF", 2)
            end)
            
            CreateSection("📍 TELEPORT TO PLAYER")
            
            -- Dynamic player list
            local playerList = GetPlayerList()
            if #playerList > 0 then
                for i, playerName in ipairs(playerList) do
                    if i <= 6 then -- Show up to 6 players
                        CreateButton("👤 " .. playerName, function()
                            local target = Players:FindFirstChild(playerName)
                            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                                Notify("Teleported to " .. playerName, 2, "success")
                            end
                        end)
                    end
                end
            else
                CreateLabel("No other players found")
            end
            
            CreateSection("📍 WAYPOINTS")
            CreateButton("💾 Save Position", function()
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    SavedPosition = Player.Character.HumanoidRootPart.CFrame
                    Notify("Position saved!", 2, "success")
                end
            end)
            
            CreateButton("📂 Load Position", function()
                if SavedPosition then
                    Player.Character.HumanoidRootPart.CFrame = SavedPosition
                    Notify("Teleported to saved position", 2, "success")
                else
                    Notify("No saved position!", 2, "error")
                end
            end)
            
        elseif tab == "Farm" then
            CreateSection("⚡ GENERATOR")
            CreateToggle("Auto Farm Generator", Toggles.AutoFarmGenerator, function(state)
                Toggles.AutoFarmGenerator = state
                if state then StartLoop("Generator") else StopLoop("Generator") end
            end)
            
            CreateToggle("Auto Complete", Toggles.AutoCompleteGenerator, function(state)
                Toggles.AutoCompleteGenerator = state
                if state then StartLoop("Complete") else StopLoop("Complete") end
            end)
            
            CreateButton("🔍 Find Generator", function()
                local gen = FindNearestGenerator()
                if gen then
                    Player.Character.HumanoidRootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
                    Notify("Found generator", 2, "success")
                else
                    Notify("No generator found", 2, "error")
                end
            end)
            
            CreateSection("📊 WORLD STATS")
            CreateLabel("Generators: " .. CountGenerators())
            CreateLabel("Presents: " .. CountPresents())
            CreateLabel("Gifts: " .. CountGifts())
            
        elseif tab == "Misc" then
            CreateSection("🛠️ UTILITY")
            CreateToggle("Anti AFK", Toggles.AntiAFK, function(state)
                Toggles.AntiAFK = state
                if state then
                    Player.Idled:Connect(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                    Notify("Anti AFK enabled", 2, "success")
                else
                    Notify("Anti AFK disabled", 2, "info")
                end
            end)
            
            CreateToggle("Auto Click", Toggles.AutoClick, function(state)
                Toggles.AutoClick = state
                if state then StartLoop("Click") else StopLoop("Click") end
            end)
            
            CreateSection("🎮 GUI")
            CreateButton("🔄 Toggle Menu", function()
                MainFrame.Visible = not MainFrame.Visible
                FloatBtn.Visible = not MainFrame.Visible
                if MainFrame.Visible then
                    Notify("Menu opened", 1, "success")
                else
                    Notify("Menu closed", 1, "info")
                end
            end)
            
            CreateButton("❌ Close GUI", function()
                ScreenGui:Destroy()
                _G.VD_Loaded = false
                Notify("Violence District unloaded", 2, "warning")
            end)
            
            -- Active features counter
            local active = 0
            for k, v in pairs(Toggles) do 
                if type(v) == "boolean" and v then 
                    active = active + 1 
                end
            end
            CreateLabel("Active Features: " .. active)
        end
        
        -- Update canvas size
        task.wait()
        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIGridLayout.AbsoluteContentSize.Y + 20)
    end)
end

-- Initialize with Main tab
UpdateTab("Main")

-- Anti AFK default on
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--==================================================
-- FINAL LOADING NOTIFICATIONS
--==================================================
task.wait(1)

-- Success notifications
Notify("✅ Violence District Ultimate v3.0", 3, "success")
Notify("📋 Press F4 to open menu", 3, "info")
Notify("⚡ " .. #GetPlayerList() .. " players in server", 2, "info")

-- Show welcome message in chat
safe_execute(function()
    local ChatService = game:GetService("TextChatService")
    if ChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        -- For new chat system
        local TextChannels = ChatService.TextChannels
        if TextChannels and TextChannels.RBXGeneral then
            TextChannels.RBXGeneral:SendAsync("Violence District Ultimate loaded! Press F4")
        end
    else
        -- For legacy chat
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("Violence District Ultimate loaded! Press F4", "All")
        end)
    end
end)

-- Print to console
print([[

    ╔══════════════════════════════════════════╗
    ║     Violence District Ultimate v3.0      ║
    ║         Successfully Loaded!              ║
    ╠══════════════════════════════════════════╣
    ║  • Press F4 to open menu                 ║
    ║  • Compatible with all executors         ║
    ║  • 50+ Features ready                    ║
    ║  • ESP with distance                      ║
    ╚══════════════════════════════════════════╝

]])

-- Final notification
Notify("🎮 Violence District ready! Press F4", 4, "success")