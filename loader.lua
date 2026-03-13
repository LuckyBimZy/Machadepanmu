-- ==================== VIOLENCE DISTRICT - ULTIMATE EDITION ====================
-- UI Modern dengan Floating Button yang Selalu Ada
-- Author: LuckyBimZy
-- Version: 3.0

--==================================================
-- CEK APAKAH SUDAH DILOAD
--==================================================
if _G.VD_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Violence District",
        Text = "Script sudah diload!",
        Duration = 2
    })
    return 
end

_G.VD_Loaded = true

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

-- Variable untuk toggle fitur
local Toggles = {
    -- Visuals
    ESP = false,
    ESPType = "Highlight",
    ESPColor = Color3.fromRGB(255, 255, 255),
    Wallhack = false,
    FullBright = false,
    NoFog = false,
    RainbowMode = false,
    
    -- Survivor
    AutoFarmPresent = false,
    AutoFarmGift = false,
    AutoOpenPresents = false,
    AutoCollectCoins = false,
    AutoHeal = false,
    SpeedBoost = false,
    JumpBoost = false,
    SpeedValue = 50,
    JumpValue = 100,
    
    -- Killer
    Aimbot = false,
    KillAura = false,
    KillAuraRange = 20,
    SilentAim = false,
    AutoAttack = false,
    
    -- Teleport
    NoClip = false,
    TeleportToMouse = false,
    
    -- Farm
    AutoFarmGenerator = false,
    AutoCompleteGenerator = false,
    AutoRepair = false,
    AutoCollectLoot = false,
    
    -- Misc
    AntiAFK = false,
    NoSkillCheck = false,
    AutoClick = false,
    AntiVoid = false
}

-- Loop control
local Loops = {}
local ESPObjects = {}
local GUIState = "open" -- open, floating
local WallhackMaterials = {}

--==================================================
-- NOTIFIKASI
--==================================================
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Violence District",
        Text = text or "",
        Duration = duration or 3
    })
end

Notify("Violence District", "Script loaded successfully!", 2)

--==================================================
-- MEMBUAT UI MODERN
--==================================================

-- Hapus GUI lama
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name:find("VD_") then
        v:Destroy()
    end
end

-- ScreenGui utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_Ultimate"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

--==================================================
-- FLOATING BUTTON (SELALU ADA)
--==================================================
local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Name = "FloatingButton"
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0, 20, 0.5, -25)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
FloatingBtn.BackgroundTransparency = 0.2
FloatingBtn.Image = "rbxassetid://3926305904"
FloatingBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.ScaleType = Enum.ScaleType.Fit
FloatingBtn.BorderSizePixel = 0
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Visible = true  -- Selalu visible
FloatingBtn.Parent = ScreenGui

-- Shadow untuk floating button
local FloatShadow = Instance.new("ImageLabel")
FloatShadow.Name = "Shadow"
FloatShadow.Size = UDim2.new(1, 10, 1, 10)
FloatShadow.Position = UDim2.new(0, -5, 0, -5)
FloatShadow.BackgroundTransparency = 1
FloatShadow.Image = "rbxassetid://6015897843"
FloatShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
FloatShadow.ImageTransparency = 0.5
FloatShadow.ScaleType = Enum.ScaleType.Slice
FloatShadow.SliceCenter = Rect.new(50, 50, 50, 50)
FloatShadow.Parent = FloatingBtn

-- Rounded corners untuk floating button
local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 25)
FloatCorner.Parent = FloatingBtn

-- Icon di floating button
local FloatIcon = Instance.new("TextLabel")
FloatIcon.Name = "Icon"
FloatIcon.Size = UDim2.new(1, 0, 1, 0)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Text = "🎮"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.TextSize = 30
FloatIcon.Font = Enum.Font.Gotham
FloatIcon.Parent = FloatingBtn

-- Tooltip untuk floating button
local FloatTooltip = Instance.new("Frame")
FloatTooltip.Name = "Tooltip"
FloatTooltip.Size = UDim2.new(0, 120, 0, 30)
FloatTooltip.Position = UDim2.new(1, 10, 0.5, -15)
FloatTooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
FloatTooltip.BackgroundTransparency = 0.1
FloatTooltip.Visible = false
FloatTooltip.Parent = FloatingBtn

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0, 6)
TooltipCorner.Parent = FloatTooltip

local TooltipText = Instance.new("TextLabel")
TooltipText.Size = UDim2.new(1, 0, 1, 0)
TooltipText.BackgroundTransparency = 1
TooltipText.Text = "Click to Toggle Menu"
TooltipText.TextColor3 = Color3.fromRGB(255, 255, 255)
TooltipText.TextSize = 12
TooltipText.Font = Enum.Font.Gotham
TooltipText.Parent = FloatTooltip

-- Hover effect untuk floating button
FloatingBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatingBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 55, 0, 55)}):Play()
    FloatTooltip.Visible = true
end)

FloatingBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatingBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    FloatTooltip.Visible = false
end)

-- Floating button click untuk toggle menu
FloatingBtn.MouseButton1Click:Connect(function()
    if GUIState == "open" then
        GUIState = "floating"
        MainFrame.Visible = false
        FloatTooltip.Text = "Click to Open Menu"
        FloatIcon.Text = "🎮"
    else
        GUIState = "open"
        MainFrame.Visible = true
        FloatTooltip.Text = "Click to Close Menu"
        FloatIcon.Text = "✕"
    end
end)

--==================================================
-- MAIN MENU FRAME
--==================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 550)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Shadow untuk main menu
local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "Shadow"
MainShadow.Size = UDim2.new(1, 20, 1, 20)
MainShadow.Position = UDim2.new(0, -10, 0, -10)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://6015897843"
MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.ImageTransparency = 0.6
MainShadow.ScaleType = Enum.ScaleType.Slice
MainShadow.SliceCenter = Rect.new(50, 50, 50, 50)
MainShadow.Parent = MainFrame

-- Rounded corners
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Gradient background
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame

--==================================================
-- TITLE BAR
--==================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BackgroundTransparency = 0.1
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

-- Icon di title bar
local TitleIcon = Instance.new("Frame")
TitleIcon.Size = UDim2.new(0, 30, 0, 30)
TitleIcon.Position = UDim2.new(0, 15, 0.5, -15)
TitleIcon.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
TitleIcon.BackgroundTransparency = 0.2
TitleIcon.Parent = TitleBar

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 8)
IconCorner.Parent = TitleIcon

local IconLabel = Instance.new("TextLabel")
IconLabel.Size = UDim2.new(1, 0, 1, 0)
IconLabel.BackgroundTransparency = 1
IconLabel.Text = "🎮"
IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IconLabel.TextSize = 18
IconLabel.Font = Enum.Font.Gotham
IconLabel.Parent = TitleIcon

-- Title text
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 0, 25)
TitleText.Position = UDim2.new(0, 55, 0.5, -12.5)
TitleText.BackgroundTransparency = 1
TitleText.Text = "VIOLENCE DISTRICT"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 50, 0, 20)
VersionText.Position = UDim2.new(0, 55, 0.5, 7)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v3.0"
VersionText.TextColor3 = Color3.fromRGB(150, 150, 150)
VersionText.TextSize = 10
VersionText.Font = Enum.Font.Gotham
VersionText.TextXAlignment = Enum.TextXAlignment.Left
VersionText.Parent = TitleBar

-- Control buttons
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 60, 0, 30)
ControlFrame.Position = UDim2.new(1, -70, 0.5, -15)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = TitleBar

-- Minimize button (ke floating)
local FloatModeBtn = Instance.new("TextButton")
FloatModeBtn.Size = UDim2.new(0, 30, 0, 30)
FloatModeBtn.Position = UDim2.new(0, 0, 0, 0)
FloatModeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
FloatModeBtn.Text = "-"
FloatModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatModeBtn.TextSize = 20
FloatModeBtn.Font = Enum.Font.GothamBold
FloatModeBtn.Parent = ControlFrame

local FloatBtnCorner = Instance.new("UICorner")
FloatBtnCorner.CornerRadius = UDim.new(0, 8)
FloatBtnCorner.Parent = FloatModeBtn

FloatModeBtn.MouseButton1Click:Connect(function()
    GUIState = "floating"
    MainFrame.Visible = false
    FloatTooltip.Text = "Click to Open Menu"
    FloatIcon.Text = "🎮"
end)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0, 35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = ControlFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.VD_Loaded = false
end)

--==================================================
-- TAB BUTTONS
--==================================================
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 45)
TabFrame.Position = UDim2.new(0, 10, 0, 55)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {
    {name = "Main", icon = "🏠"},
    {name = "Visuals", icon = "👁️"},
    {name = "Survivor", icon = "🛡️"},
    {name = "Killer", icon = "⚔️"},
    {name = "Teleport", icon = "🌀"},
    {name = "Farm", icon = "⚡"},
    {name = "Misc", icon = "⚙️"}
}

local TabButtons = {}
local CurrentTab = "Main"

for i, tabData in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 48, 0, 45)
    TabBtn.Position = UDim2.new(0, (i-1) * 50, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TabBtn.Text = ""
    TabBtn.Parent = TabFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = TabBtn
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = tabData.icon
    Icon.TextColor3 = Color3.fromRGB(200, 200, 200)
    Icon.TextSize = 20
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = TabBtn
    
    -- Hover effect
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= tabData.name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= tabData.name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tabData.name
        for _, btn in pairs(TabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
            btn:FindFirstChild("TextLabel").TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 105, 225)}):Play()
        Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        UpdateTab(tabData.name)
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Set tab pertama aktif
TabButtons[1].BackgroundColor3 = Color3.fromRGB(65, 105, 225)
TabButtons[1]:FindFirstChild("TextLabel").TextColor3 = Color3.fromRGB(255, 255, 255)

--==================================================
-- CONTENT AREA
--==================================================
local ContentBg = Instance.new("Frame")
ContentBg.Size = UDim2.new(1, -20, 1, -120)
ContentBg.Position = UDim2.new(0, 10, 0, 105)
ContentBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentBg.BackgroundTransparency = 0.1
ContentBg.ClipsDescendants = true
ContentBg.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 12)
ContentCorner.Parent = ContentBg

-- Header content
local ContentHeader = Instance.new("Frame")
ContentHeader.Size = UDim2.new(1, -20, 0, 35)
ContentHeader.Position = UDim2.new(0, 10, 0, 10)
ContentHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ContentHeader.BackgroundTransparency = 0.1
ContentHeader.Parent = ContentBg

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = ContentHeader

local HeaderIcon = Instance.new("TextLabel")
HeaderIcon.Size = UDim2.new(0, 30, 1, 0)
HeaderIcon.Position = UDim2.new(0, 5, 0, 0)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.Text = "🏠"
HeaderIcon.TextColor3 = Color3.fromRGB(65, 105, 225)
HeaderIcon.TextSize = 18
HeaderIcon.Font = Enum.Font.Gotham
HeaderIcon.Parent = ContentHeader

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -40, 1, 0)
HeaderTitle.Position = UDim2.new(0, 35, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "MAIN"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = 13
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = ContentHeader

-- Scrolling frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 105, 225)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentBg

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

--==================================================
-- FUNGSI UNTUK MEMBUAT ELEMEN UI
--==================================================

function CreateSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 30)
    Section.BackgroundTransparency = 1
    Section.Text = "  " .. text
    Section.TextColor3 = Color3.fromRGB(65, 105, 225)
    Section.TextSize = 14
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -10, 0, 1)
    Line.Position = UDim2.new(0, 5, 0, 28)
    Line.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section
    
    return Section
end

function CreateToggle(text, desc, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleFrame.BackgroundTransparency = 0.1
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, -20, 0, 20)
    ToggleText.Position = UDim2.new(0, 15, 0, 8)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 14
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleDesc = Instance.new("TextLabel")
    ToggleDesc.Size = UDim2.new(0.7, -20, 0, 15)
    ToggleDesc.Position = UDim2.new(0, 15, 0, 28)
    ToggleDesc.BackgroundTransparency = 1
    ToggleDesc.Text = desc or ""
    ToggleDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleDesc.TextSize = 10
    ToggleDesc.Font = Enum.Font.Gotham
    ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
    ToggleDesc.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 70, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -85, 0.5, -15)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = ToggleBtn
    
    local enabled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(65, 105, 225),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            ToggleBtn.Text = "ON"
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 55),
                TextColor3 = Color3.fromRGB(255, 100, 100)
            }):Play()
            ToggleBtn.Text = "OFF"
        end
        callback(enabled)
    end)
    
    return ToggleFrame
end

function CreateButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = color or Color3.fromRGB(65, 105, 225)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ScrollingFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = color and color:Lerp(Color3.fromRGB(255, 255, 255), 0.2) or Color3.fromRGB(85, 125, 245)
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = color or Color3.fromRGB(65, 105, 225)
        }):Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

function CreateDropdown(text, options, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 50)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    DropdownFrame.BackgroundTransparency = 0.1
    DropdownFrame.Parent = ScrollingFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.6, -20, 0, 20)
    DropdownText.Position = UDim2.new(0, 15, 0, 8)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 14
    DropdownText.Font = Enum.Font.GothamBold
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownDesc = Instance.new("TextLabel")
    DropdownDesc.Size = UDim2.new(0.6, -20, 0, 15)
    DropdownDesc.Position = UDim2.new(0, 15, 0, 28)
    DropdownDesc.BackgroundTransparency = 1
    DropdownDesc.Text = "Select an option"
    DropdownDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    DropdownDesc.TextSize = 10
    DropdownDesc.Font = Enum.Font.Gotham
    DropdownDesc.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 100, 0, 30)
    DropdownBtn.Position = UDim2.new(1, -115, 0.5, -15)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    DropdownBtn.Text = options[1] or "Select"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 11
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        local oldMenu = DropdownFrame:FindFirstChild("DropdownMenu")
        if oldMenu then oldMenu:Destroy() end
        
        local menu = Instance.new("Frame")
        menu.Name = "DropdownMenu"
        menu.Size = UDim2.new(0, 120, 0, math.min(#options, 5) * 35)
        menu.Position = UDim2.new(1, -115, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 8)
        menuCorner.Parent = menu
        
        for i, option in ipairs(options) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(1, 0, 0, 35)
            optionBtn.Position = UDim2.new(0, 0, 0, (i-1) * 35)
            optionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            optionBtn.Text = option
            optionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optionBtn.TextSize = 11
            optionBtn.Font = Enum.Font.Gotham
            optionBtn.Parent = menu
            
            optionBtn.MouseEnter:Connect(function()
                optionBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
            end)
            
            optionBtn.MouseLeave:Connect(function()
                optionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            end)
            
            optionBtn.MouseButton1Click:Connect(function()
                DropdownBtn.Text = option
                callback(option)
                menu:Destroy()
            end)
        end
    end)
    
    return DropdownFrame
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
    
    return Label
end

function CreateSlider(text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SliderFrame.BackgroundTransparency = 0.1
    SliderFrame.Parent = ScrollingFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.6, -20, 0, 20)
    SliderText.Position = UDim2.new(0, 15, 0, 8)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 14
    SliderText.Font = Enum.Font.GothamBold
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, -10, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, -10, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(65, 105, 225)
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = SliderFrame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -30, 0, 4)
    SliderBg.Position = UDim2.new(0, 15, 0, 40)
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    SliderFill.Parent = SliderBg
    
    local dragging = false
    SliderFill.InputBegan:Connect(function(input)
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
            local value = math.floor(min + (max - min) * percent)
            
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
    end)
    
    return SliderFrame
end

--==================================================
-- UPDATE TAB CONTENT
--==================================================
function UpdateTab(tab)
    -- Clear content
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Update header
    local icons = {
        Main = "🏠",
        Visuals = "👁️",
        Survivor = "🛡️",
        Killer = "⚔️",
        Teleport = "🌀",
        Farm = "⚡",
        Misc = "⚙️"
    }
    HeaderIcon.Text = icons[tab] or "📁"
    HeaderTitle.Text = tab
    
    if tab == "Main" then
        CreateSection("PLAYER INFO")
        CreateLabel("Name: " .. Player.Name)
        CreateLabel("Display Name: " .. Player.DisplayName)
        CreateLabel("User ID: " .. Player.UserId)
        CreateLabel("Account Age: " .. Player.AccountAge .. " days")
        
        CreateSection("SERVER INFO")
        CreateLabel("Server ID: " .. game.JobId:sub(1, 10) .. "...")
        CreateLabel("Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers)
        CreateLabel("Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms")
        CreateLabel("Game Time: " .. math.floor(workspace.DistributedGameTime/60) .. " minutes")
        
        CreateSection("QUICK ACTIONS")
        CreateButton("Refresh Info", Color3.fromRGB(65, 105, 225), function()
            UpdateTab("Main")
        end)
        
        CreateButton("Rejoin Server", Color3.fromRGB(220, 60, 60), function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end)
        
        CreateButton("Server Hop", Color3.fromRGB(255, 165, 0), function()
            local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                    break
                end
            end
        end)
        
        CreateSection("CREDITS")
        CreateLabel("Violence District Ultimate")
        CreateLabel("Version 3.0")
        CreateLabel("Made by LuckyBimZy")
        CreateLabel("Floating Button Always Available")
        
    elseif tab == "Visuals" then
        CreateSection("ESP SETTINGS")
        CreateToggle("Enable ESP", "Show players through walls", function(state)
            Toggles.ESP = state
            if state then
                EnableESP()
            else
                DisableESP()
            end
        end)
        
        CreateDropdown("ESP Type", {"Highlight", "Box", "Tracer", "Name Only"}, function(option)
            Toggles.ESPType = option
            if Toggles.ESP then
                DisableESP()
                EnableESP()
            end
        end)
        
        CreateToggle("Wallhack", "See through all walls", function(state)
            Toggles.Wallhack = state
            UpdateWallhack()
        end)
        
        CreateSection("VISUAL EFFECTS")
        CreateToggle("Full Bright", "Maximum brightness", function(state)
            Toggles.FullBright = state
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
        
        CreateToggle("No Fog", "Remove fog effect", function(state)
            Toggles.NoFog = state
            if state then
                Lighting.FogEnd = 1e9
            else
                Lighting.FogEnd = 100000
            end
        end)
        
        CreateToggle("Rainbow Mode", "Rainbow colors", function(state)
            Toggles.RainbowMode = state
        end)
        
    elseif tab == "Survivor" then
        CreateSection("AUTO FARM")
        CreateToggle("Auto Farm Present", "Automatically collect presents", function(state)
            Toggles.AutoFarmPresent = state
            if state then StartLoop("AutoFarmPresent") end
        end)
        
        CreateToggle("Auto Farm Gift", "Collect gifts and teleport to tree", function(state)
            Toggles.AutoFarmGift = state
            if state then StartLoop("AutoFarmGift") end
        end)
        
        CreateToggle("Auto Open Presents", "Automatically open presents", function(state)
            Toggles.AutoOpenPresents = state
            if state then StartLoop("AutoOpenPresents") end
        end)
        
        CreateToggle("Auto Collect Coins", "Collect coins automatically", function(state)
            Toggles.AutoCollectCoins = state
            if state then StartLoop("AutoCollectCoins") end
        end)
        
        CreateToggle("Auto Heal", "Auto heal when low health", function(state)
            Toggles.AutoHeal = state
        end)
        
        CreateSection("MOVEMENT")
        CreateToggle("Speed Boost", "Increase movement speed", function(state)
            Toggles.SpeedBoost = state
            if state then
                Player.Character.Humanoid.WalkSpeed = Toggles.SpeedValue
            else
                Player.Character.Humanoid.WalkSpeed = 16
            end
        end)
        
        CreateSlider("Speed Value", 16, 200, Toggles.SpeedValue, function(value)
            Toggles.SpeedValue = value
            if Toggles.SpeedBoost then
                Player.Character.Humanoid.WalkSpeed = value
            end
        end)
        
        CreateToggle("Jump Boost", "Higher jumps", function(state)
            Toggles.JumpBoost = state
            if state then
                Player.Character.Humanoid.JumpPower = Toggles.JumpValue
            else
                Player.Character.Humanoid.JumpPower = 50
            end
        end)
        
        CreateSlider("Jump Value", 50, 200, Toggles.JumpValue, function(value)
            Toggles.JumpValue = value
            if Toggles.JumpBoost then
                Player.Character.Humanoid.JumpPower = value
            end
        end)
        
    elseif tab == "Killer" then
        CreateSection("COMBAT")
        CreateToggle("Aimbot", "Auto aim at nearest player", function(state)
            Toggles.Aimbot = state
            if state then StartLoop("Aimbot") end
        end)
        
        CreateToggle("Silent Aim", "Aim without moving camera", function(state)
            Toggles.SilentAim = state
        end)
        
        CreateToggle("Kill Aura", "Auto kill nearby players", function(state)
            Toggles.KillAura = state
            if state then StartLoop("KillAura") end
        end)
        
        CreateSlider("Kill Aura Range", 5, 50, Toggles.KillAuraRange, function(value)
            Toggles.KillAuraRange = value
        end)
        
        CreateToggle("Auto Attack", "Automatically attack", function(state)
            Toggles.AutoAttack = state
            if state then StartLoop("AutoAttack") end
        end)
        
        CreateSection("TARGET INFO")
        local target = FindNearestPlayer()
        if target then
            CreateLabel("Nearest: " .. target.Name)
            local dist = (Player.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
            CreateLabel("Distance: " .. math.floor(dist) .. "m")
        else
            CreateLabel("No players nearby")
        end
        
    elseif tab == "Teleport" then
        CreateSection("MOVEMENT")
        CreateToggle("NoClip", "Walk through walls", function(state)
            Toggles.NoClip = state
            UpdateNoClip()
        end)
        
        CreateToggle("Teleport to Mouse", "Right click to teleport", function(state)
            Toggles.TeleportToMouse = state
        end)
        
        CreateSection("TELEPORT TO PLAYER")
        CreateDropdown("Select Player", GetPlayerList(), function(name)
            local target = Players:FindFirstChild(name)
            if target and target.Character then
                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                Notify("Teleport", "Teleported to " .. name, 1)
            end
        end)
        
        CreateButton("Refresh List", Color3.fromRGB(100, 100, 100), function()
            UpdateTab("Teleport")
        end)
        
        CreateSection("WAYPOINTS")
        CreateButton("Save Current Position", Color3.fromRGB(0, 200, 100), function()
            _G.SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Waypoint", "Position saved!", 1)
        end)
        
        CreateButton("Teleport to Saved", Color3.fromRGB(65, 105, 225), function()
            if _G.SavedPosition then
                Player.Character.HumanoidRootPart.CFrame = _G.SavedPosition
                Notify("Teleport", "Teleported to saved position", 1)
            else
                Notify("Error", "No saved position!", 1)
            end
        end)
        
    elseif tab == "Farm" then
        CreateSection("GENERATOR FARM")
        CreateToggle("Auto Farm Generator", "Automatically repair generators", function(state)
            Toggles.AutoFarmGenerator = state
            if state then StartLoop("AutoFarmGenerator") end
        end)
        
        CreateToggle("Auto Complete", "Auto complete generators", function(state)
            Toggles.AutoCompleteGenerator = state
            if state then StartLoop("AutoCompleteGenerator") end
        end)
        
        CreateToggle("Auto Repair", "Auto repair when damaged", function(state)
            Toggles.AutoRepair = state
        end)
        
        CreateToggle("Auto Collect Loot", "Auto collect all loot", function(state)
            Toggles.AutoCollectLoot = state
            if state then StartLoop("AutoCollectLoot") end
        end)
        
        CreateButton("Find Nearest Generator", Color3.fromRGB(65, 105, 225), function()
            local gen = FindNearestGenerator()
            if gen then
                Player.Character.HumanoidRootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
                Notify("Generator", "Found at " .. math.floor((Player.Character.HumanoidRootPart.Position - gen.PrimaryPart.Position).Magnitude) .. "m", 1)
            else
                Notify("Error", "No generator found!", 1)
            end
        end)
        
        CreateSection("RESOURCES")
        CreateLabel("Generators nearby: " .. CountGenerators())
        CreateLabel("Presents nearby: " .. CountPresents())
        CreateLabel("Gifts nearby: " .. CountGifts())
        
    elseif tab == "Misc" then
        CreateSection("UTILITY")
        CreateToggle("Anti AFK", "Prevent being kicked", function(state)
            Toggles.AntiAFK = state
            if state then
                Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
        
        CreateToggle("Auto Click", "Automatically click", function(state)
            Toggles.AutoClick = state
            if state then StartLoop("AutoClick") end
        end)
        
        CreateToggle("No Skill Check", "Remove all skill checks", function(state)
            Toggles.NoSkillCheck = state
            ToggleSkillCheck(state)
        end)
        
        CreateToggle("Anti Void", "Prevent falling into void", function(state)
            Toggles.AntiVoid = state
            if state then StartLoop("AntiVoid") end
        end)
        
        CreateSection("GUI CONTROLS")
        CreateButton("Hide Menu (Floating Mode)", Color3.fromRGB(100, 100, 100), function()
            GUIState = "floating"
            MainFrame.Visible = false
            FloatTooltip.Text = "Click to Open Menu"
            FloatIcon.Text = "🎮"
        end)
        
        CreateButton("Show Menu", Color3.fromRGB(65, 105, 225), function()
            GUIState = "open"
            MainFrame.Visible = true
            FloatTooltip.Text = "Click to Close Menu"
            FloatIcon.Text = "✕"
        end)
        
        CreateButton("Close GUI", Color3.fromRGB(220, 60, 60), function()
            ScreenGui:Destroy()
            _G.VD_Loaded = false
        end)
        
        CreateSection("STATUS")
        CreateLabel("GUI Mode: " .. GUIState)
        CreateLabel("Active Loops: " .. table.count(Loops))
        CreateLabel("Floating Button: Always Available")
        CreateLabel("Press '-' on title bar to hide")
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- CORE FUNCTIONS (IMPROVED)
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
            
            if name == "AutoFarmPresent" then
                local present = FindNearestPresent()
                if present then
                    Player.Character.HumanoidRootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                    local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                    end
                end
                
            elseif name == "AutoFarmGift" then
                local gift = FindNearestGift()
                if gift then
                    Player.Character.HumanoidRootPart.CFrame = gift.CFrame + Vector3.new(0, 3, 0)
                    local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                    end
                end
                
            elseif name == "AutoOpenPresents" then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Present" and v:IsA("BasePart") and (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude < 10 then
                        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then fireproximityprompt(prompt) end
                    end
                end
                
            elseif name == "AutoCollectCoins" then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Coin" and v:IsA("BasePart") and (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude < 20 then
                        Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.1)
                    end
                end
                
            elseif name == "Aimbot" then
                local target = FindNearestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    if Toggles.SilentAim then
                        -- Silent aim implementation
                        local tool = Player.Character:FindFirstChildWhichIsA("Tool")
                        if tool then
                            tool:Activate()
                        end
                    else
                        Player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(
                            Player.Character.HumanoidRootPart.Position, 
                            targetPos
                        )
                    end
                end
                
            elseif name == "KillAura" then
                local range = Toggles.KillAuraRange or 20
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
                        local dist = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= range then
                            player.Character.Humanoid.Health = 0
                        end
                    end
                end
                
            elseif name == "AutoAttack" then
                local target = FindNearestPlayer()
                if target and target.Character then
                    local tool = Player.Character:FindFirstChildWhichIsA("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
                
            elseif name == "AutoFarmGenerator" then
                local gen = FindNearestGenerator()
                if gen then
                    Player.Character.HumanoidRootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
                    local prompt = gen:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                    end
                end
                
            elseif name == "AutoCompleteGenerator" then
                local gen = FindNearestGenerator()
                if gen then
                    Player.Character.HumanoidRootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then
                        remote:FireServer("CompleteGenerator", gen)
                    end
                end
                
            elseif name == "AutoCollectLoot" then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name == "Loot" or v.Name == "Item") and (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude < 15 then
                        Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then fireproximityprompt(prompt) end
                        task.wait(0.1)
                    end
                end
                
            elseif name == "AutoClick" then
                mouse1click()
                
            elseif name == "AntiVoid" then
                if Player.Character and Player.Character.HumanoidRootPart.Position.Y < -50 then
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
                end
            end
            
            task.wait(0.1)
        end
    end)
end

-- ESP Functions (IMPROVED)
function EnableESP()
    DisableESP()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            AddESP(player)
        end
    end
    
    -- Update ESP for new players
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Toggles.ESP then
                AddESP(player)
            end
        end)
    end)
end

function AddESP(player)
    if not player.Character then return end
    
    if Toggles.ESPType == "Highlight" or Toggles.ESPType == "Box" then
        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "VD_ESP"
        highlight.Parent = player.Character
        highlight.FillColor = Toggles.ESPColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
    end
    
    -- Name tag with distance (always on)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VD_Name"
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
    
    -- Tracers
    if Toggles.ESPType == "Tracer" then
        local tracer = Instance.new("Frame")
        tracer.Name = "VD_Tracer"
        tracer.Size = UDim2.new(0, 2, 0, 100)
        tracer.BackgroundColor3 = Toggles.ESPColor
        tracer.BorderSizePixel = 0
        tracer.Parent = player.Character
    end
    
    -- Update distance
    task.spawn(function()
        while billboard and billboard.Parent do
            task.wait(0.3)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude)
                nameLabel.Text = player.Name .. " [" .. dist .. "m]"
                
                -- Update tracer
                if Toggles.ESPType == "Tracer" then
                    -- Tracer implementation would go here
                end
            end
        end
    end)
end

function DisableESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("VD_ESP")
            if highlight then highlight:Destroy() end
            local nameTag = player.Character:FindFirstChild("VD_Name")
            if nameTag then nameTag:Destroy() end
            local tracer = player.Character:FindFirstChild("VD_Tracer")
            if tracer then tracer:Destroy() end
        end
    end
end

-- Wallhack (IMPROVED)
function UpdateWallhack()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if Toggles.Wallhack then
                if v.Name ~= "HumanoidRootPart" then
                    -- Save original material
                    if not WallhackMaterials[v] then
                        WallhackMaterials[v] = v.Material
                    end
                    v.Material = Enum.Material.ForceField
                    v.Transparency = 0.5
                end
            else
                -- Restore original material
                if WallhackMaterials[v] then
                    v.Material = WallhackMaterials[v]
                    v.Transparency = 0
                    WallhackMaterials[v] = nil
                end
            end
        end
    end
end

function UpdateNoClip()
    if Toggles.NoClip then
        RunService:BindToRenderStep("NoClip", 0, function()
            if Toggles.NoClip and Player.Character then
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
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and tostring(self):find("SkillCheck") then
                return
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end

-- Teleport to mouse
UserInputService.InputBegan:Connect(function(input)
    if Toggles.TeleportToMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local mouse = Player:GetMouse()
        local targetPos = mouse.Hit.p
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos.x, targetPos.y + 3, targetPos.z)
    end
end)

-- Find object functions
function FindNearestGenerator()
    local nearest = nil
    local dist = math.huge
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") and v.PrimaryPart then
            local d = (root.Position - v.PrimaryPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
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
    local nearest = nil
    local dist = math.huge
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Present" and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
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
    local nearest = nil
    local dist = math.huge
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Gift" and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
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
    local nearest = nil
    local dist = math.huge
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = player
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

function table.count(t)
    local c = 0
    for _ in pairs(t) do c = c + 1 end
    return c
end

-- Character update
Player.CharacterAdded:Connect(function(newChar)
    Player.Character = newChar
    task.wait(1)
end)

--==================================================
-- RAINBOW MODE
--==================================================
task.spawn(function()
    while true do
        if Toggles.RainbowMode then
            Toggles.ESPColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            if Toggles.ESP then
                DisableESP()
                EnableESP()
            end
        end
        task.wait(0.1)
    end
end)

--==================================================
-- INITIALIZE
--==================================================

-- Set tab pertama
UpdateTab("Main")

-- Notifikasi
Notify("Violence District", "Floating button always available | Click '-' to hide", 3)

print("========================================")
print("✅ VIOLENCE DISTRICT ULTIMATE LOADED!")
print("Floating button: Always visible on screen")
print("Click '-' on title bar to hide menu")
print("========================================")