-- ==================== VIOLENCE DISTRICT - NEBULA EDITION ====================
-- UI Modern Premium dengan Animasi Halus
-- Author: LuckyBimZy
-- Version: 6.0 (Nebula)

--==================================================
-- CEK APAKAH SUDAH DILOAD
--==================================================
if _G.VD_Nebula then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Violence District",
        Text = "Script sudah diload!",
        Duration = 2
    })
    return 
end

_G.VD_Nebula = true

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
    ESPColor = Color3.fromRGB(0, 255, 255),
    Wallhack = false,
    FullBright = false,
    NoFog = false,
    RainbowESP = false,
    
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
    
    -- Teleport
    NoClip = false,
    TeleportToMouse = false,
    
    -- Farm
    AutoFarmGenerator = false,
    AutoCompleteGenerator = false,
    AutoRepair = false,
    
    -- Misc
    AntiAFK = false,
    NoSkillCheck = false,
    AutoClick = false,
    AntiStun = false
}

-- Loop control
local Loops = {}
local ESPObjects = {}
local GUIState = "open"
local SavedPosition = nil
local NebulaColors = {
    primary = Color3.fromRGB(0, 255, 255),    -- Cyan
    secondary = Color3.fromRGB(255, 0, 255),   -- Magenta
    accent = Color3.fromRGB(128, 0, 255),      -- Purple
    background = Color3.fromRGB(5, 5, 15),      -- Dark blue
    surface = Color3.fromRGB(15, 15, 25),       -- Slightly lighter
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 150)
}

--==================================================
-- NOTIFIKASI PREMIUM
--==================================================
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Violence District",
        Text = text or "",
        Duration = duration or 3
    })
end

Notify("Violence District", "Nebula Edition Loaded!", 2)

--==================================================
-- MEMBUAT UI NEBULA
--==================================================

-- Hapus GUI lama
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name:find("VD_") then
        v:Destroy()
    end
end

-- ScreenGui utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_Nebula"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

--==================================================
-- NEBULA ORB (FLOATING BUTTON)
--==================================================
local NebulaOrb = Instance.new("ImageButton")
NebulaOrb.Name = "NebulaOrb"
NebulaOrb.Size = UDim2.new(0, 60, 0, 60)
NebulaOrb.Position = UDim2.new(0, 20, 0.5, -30)
NebulaOrb.BackgroundColor3 = NebulaColors.primary
NebulaOrb.BackgroundTransparency = 0.2
NebulaOrb.Image = "rbxassetid://3926305904"
NebulaOrb.ImageColor3 = Color3.fromRGB(255, 255, 255)
NebulaOrb.ScaleType = Enum.ScaleType.Fit
NebulaOrb.BorderSizePixel = 0
NebulaOrb.Active = true
NebulaOrb.Draggable = true
NebulaOrb.Visible = true
NebulaOrb.Parent = ScreenGui
NebulaOrb.ZIndex = 1000

-- Shadow
local OrbShadow = Instance.new("ImageLabel")
OrbShadow.Name = "Shadow"
OrbShadow.Size = UDim2.new(1, 10, 1, 10)
OrbShadow.Position = UDim2.new(0, -5, 0, -5)
OrbShadow.BackgroundTransparency = 1
OrbShadow.Image = "rbxassetid://6015897843"
OrbShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
OrbShadow.ImageTransparency = 0.5
OrbShadow.ScaleType = Enum.ScaleType.Slice
OrbShadow.SliceCenter = Rect.new(50, 50, 50, 50)
OrbShadow.Parent = NebulaOrb
OrbShadow.ZIndex = 999

-- Rounded corners
local OrbCorner = Instance.new("UICorner")
OrbCorner.CornerRadius = UDim.new(1, 0)
OrbCorner.Parent = NebulaOrb

-- Glow effect
local OrbGlow = Instance.new("ImageLabel")
OrbGlow.Name = "Glow"
OrbGlow.Size = UDim2.new(1, 10, 1, 10)
OrbGlow.Position = UDim2.new(0, -5, 0, -5)
OrbGlow.BackgroundTransparency = 1
OrbGlow.Image = "rbxassetid://5028857648"
OrbGlow.ImageColor3 = NebulaColors.primary
OrbGlow.ImageTransparency = 0.3
OrbGlow.ScaleType = Enum.ScaleType.Slice
OrbGlow.SliceCenter = Rect.new(10, 10, 10, 10)
OrbGlow.Parent = NebulaOrb
OrbGlow.ZIndex = 998

-- Icon
local OrbIcon = Instance.new("TextLabel")
OrbIcon.Name = "Icon"
OrbIcon.Size = UDim2.new(1, 0, 1, 0)
OrbIcon.BackgroundTransparency = 1
OrbIcon.Text = "🌌"
OrbIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
OrbIcon.TextSize = 30
OrbIcon.Font = Enum.Font.Gotham
OrbIcon.Parent = NebulaOrb
OrbIcon.ZIndex = 1001

-- Tooltip
local OrbTooltip = Instance.new("Frame")
OrbTooltip.Name = "Tooltip"
OrbTooltip.Size = UDim2.new(0, 140, 0, 35)
OrbTooltip.Position = UDim2.new(1, 10, 0.5, -17.5)
OrbTooltip.BackgroundColor3 = NebulaColors.surface
OrbTooltip.BackgroundTransparency = 0.1
OrbTooltip.Visible = false
OrbTooltip.Parent = NebulaOrb
OrbTooltip.ZIndex = 1002

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0, 8)
TooltipCorner.Parent = OrbTooltip

local TooltipText = Instance.new("TextLabel")
TooltipText.Size = UDim2.new(1, 0, 1, 0)
TooltipText.BackgroundTransparency = 1
TooltipText.Text = "Toggle Menu (F4)"
TooltipText.TextColor3 = NebulaColors.text
TooltipText.TextSize = 12
TooltipText.Font = Enum.Font.Gotham
TooltipText.Parent = OrbTooltip

-- Animasi hover
NebulaOrb.MouseEnter:Connect(function()
    TweenService:Create(NebulaOrb, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 65, 0, 65)
    }):Play()
    TweenService:Create(OrbGlow, TweenInfo.new(0.3), {
        ImageTransparency = 0.1
    }):Play()
    OrbTooltip.Visible = true
end)

NebulaOrb.MouseLeave:Connect(function()
    TweenService:Create(NebulaOrb, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 60, 0, 60)
    }):Play()
    TweenService:Create(OrbGlow, TweenInfo.new(0.3), {
        ImageTransparency = 0.3
    }):Play()
    OrbTooltip.Visible = false
end)

--==================================================
-- MAIN NEBULA FRAME
--==================================================
local NebulaFrame = Instance.new("Frame")
NebulaFrame.Name = "NebulaFrame"
NebulaFrame.Size = UDim2.new(0, 420, 0, 600)
NebulaFrame.Position = UDim2.new(0.5, -210, 0.5, -300)
NebulaFrame.BackgroundColor3 = NebulaColors.background
NebulaFrame.BackgroundTransparency = 0.1
NebulaFrame.BorderSizePixel = 0
NebulaFrame.Active = true
NebulaFrame.Draggable = true
NebulaFrame.ClipsDescendants = true
NebulaFrame.Visible = true
NebulaFrame.Parent = ScreenGui
NebulaFrame.ZIndex = 10

-- Shadow
local NebulaShadow = Instance.new("ImageLabel")
NebulaShadow.Name = "Shadow"
NebulaShadow.Size = UDim2.new(1, 30, 1, 30)
NebulaShadow.Position = UDim2.new(0, -15, 0, -15)
NebulaShadow.BackgroundTransparency = 1
NebulaShadow.Image = "rbxassetid://6015897843"
NebulaShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
NebulaShadow.ImageTransparency = 0.6
NebulaShadow.ScaleType = Enum.ScaleType.Slice
NebulaShadow.SliceCenter = Rect.new(50, 50, 50, 50)
NebulaShadow.Parent = NebulaFrame
NebulaShadow.ZIndex = 9

-- Rounded corners
local NebulaCorner = Instance.new("UICorner")
NebulaCorner.CornerRadius = UDim.new(0, 20)
NebulaCorner.Parent = NebulaFrame

-- Nebula gradient background
local NebulaGradient = Instance.new("UIGradient")
NebulaGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, NebulaColors.background),
    ColorSequenceKeypoint.new(0.5, NebulaColors.surface),
    ColorSequenceKeypoint.new(1, NebulaColors.background)
})
NebulaGradient.Rotation = 45
NebulaGradient.Parent = NebulaFrame

-- Animated border
local NebulaBorder = Instance.new("Frame")
NebulaBorder.Size = UDim2.new(1, 4, 1, 4)
NebulaBorder.Position = UDim2.new(0, -2, 0, -2)
NebulaBorder.BackgroundColor3 = NebulaColors.primary
NebulaBorder.BackgroundTransparency = 0.7
NebulaBorder.BorderSizePixel = 0
NebulaBorder.Parent = NebulaFrame
NebulaBorder.ZIndex = 11

local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 22)
BorderCorner.Parent = NebulaBorder

-- Animasi border berubah warna
task.spawn(function()
    local hue = 0
    while NebulaBorder do
        hue = (hue + 0.01) % 1
        NebulaBorder.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.05)
    end
end)

--==================================================
-- NEBULA HEADER
--==================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = NebulaColors.surface
Header.BackgroundTransparency = 0.2
Header.BorderSizePixel = 0
Header.Parent = NebulaFrame
Header.ZIndex = 12

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = Header

-- Header glow
local HeaderGlow = Instance.new("ImageLabel")
HeaderGlow.Size = UDim2.new(1, 0, 0, 20)
HeaderGlow.Position = UDim2.new(0, 0, 1, -10)
HeaderGlow.BackgroundTransparency = 1
HeaderGlow.Image = "rbxassetid://5028857648"
HeaderGlow.ImageColor3 = NebulaColors.primary
HeaderGlow.ImageTransparency = 0.5
HeaderGlow.ScaleType = Enum.ScaleType.Slice
HeaderGlow.SliceCenter = Rect.new(10, 10, 10, 10)
HeaderGlow.Parent = Header
HeaderGlow.ZIndex = 13

-- Nebula logo
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 45, 0, 45)
LogoContainer.Position = UDim2.new(0, 15, 0.5, -22.5)
LogoContainer.BackgroundColor3 = NebulaColors.primary
LogoContainer.BackgroundTransparency = 0.3
LogoContainer.Parent = Header
LogoContainer.ZIndex = 14

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 12)
LogoCorner.Parent = LogoContainer

local LogoGlow = Instance.new("Frame")
LogoGlow.Size = UDim2.new(1, 4, 1, 4)
LogoGlow.Position = UDim2.new(0, -2, 0, -2)
LogoGlow.BackgroundColor3 = NebulaColors.secondary
LogoGlow.BackgroundTransparency = 0.5
LogoGlow.BorderSizePixel = 0
LogoGlow.Parent = LogoContainer
LogoGlow.ZIndex = 13

local LogoGlowCorner = Instance.new("UICorner")
LogoGlowCorner.CornerRadius = UDim.new(0, 14)
LogoGlowCorner.Parent = LogoGlow

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 1, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "🌌"
Logo.TextColor3 = NebulaColors.text
Logo.TextSize = 25
Logo.Font = Enum.Font.Gotham
Logo.Parent = LogoContainer
Logo.ZIndex = 15

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 0, 30)
Title.Position = UDim2.new(0, 70, 0.5, -15)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT"
Title.TextColor3 = NebulaColors.text
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header
Title.ZIndex = 14

local TitleGlow = Instance.new("TextLabel")
TitleGlow.Size = UDim2.new(0, 250, 0, 30)
TitleGlow.Position = UDim2.new(0, 70, 0.5, -15)
TitleGlow.BackgroundTransparency = 1
TitleGlow.Text = "VIOLENCE DISTRICT"
TitleGlow.TextColor3 = NebulaColors.primary
TitleGlow.TextSize = 18
TitleGlow.Font = Enum.Font.GothamBold
TitleGlow.TextXAlignment = Enum.TextXAlignment.Left
TitleGlow.TextTransparency = 0.7
TitleGlow.Parent = Header
TitleGlow.ZIndex = 13

-- Version
local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(0, 100, 0, 20)
Version.Position = UDim2.new(0, 70, 0.5, 8)
Version.BackgroundTransparency = 1
Version.Text = "NEBULA v6.0"
Version.TextColor3 = NebulaColors.primary
Version.TextSize = 11
Version.Font = Enum.Font.Gotham
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Header
Version.ZIndex = 14

-- Control buttons
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 100, 0, 35)
ControlFrame.Position = UDim2.new(1, -110, 0.5, -17.5)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = Header
ControlFrame.ZIndex = 14

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(0, 0, 0, 0)
MinBtn.BackgroundColor3 = NebulaColors.surface
MinBtn.Text = "−"
MinBtn.TextColor3 = NebulaColors.text
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = ControlFrame
MinBtn.ZIndex = 15

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 10)
MinCorner.Parent = MinBtn

MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.primary}):Play()
end)

MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.surface}):Play()
end)

MinBtn.MouseButton1Click:Connect(function()
    NebulaFrame.Visible = false
    OrbIcon.Text = "🌠"
    OrbTooltip.Text = "Tampilkan menu"
end)

-- Settings button
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 35, 0, 35)
SettingsBtn.Position = UDim2.new(0, 40, 0, 0)
SettingsBtn.BackgroundColor3 = NebulaColors.surface
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = NebulaColors.text
SettingsBtn.TextSize = 18
SettingsBtn.Font = Enum.Font.Gotham
SettingsBtn.Parent = ControlFrame
SettingsBtn.ZIndex = 15

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 10)
SettingsCorner.Parent = SettingsBtn

SettingsBtn.MouseEnter:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.accent}):Play()
end)

SettingsBtn.MouseLeave:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.surface}):Play()
end)

SettingsBtn.MouseButton1Click:Connect(function()
    CurrentTab = "Misc"
    UpdateTab("Misc")
    -- Update tab buttons
    for i, btn in ipairs(TabButtons) do
        if i == 7 then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.primary}):Play()
            btn:FindFirstChild("Icon").TextColor3 = NebulaColors.text
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.surface}):Play()
            btn:FindFirstChild("Icon").TextColor3 = NebulaColors.textDim
        end
    end
end)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(0, 80, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = NebulaColors.text
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = ControlFrame
CloseBtn.ZIndex = 15

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)

CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Animasi close
    TweenService:Create(NebulaFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(NebulaOrb, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
    _G.VD_Nebula = false
end)

--==================================================
-- NEBULA TABS
--==================================================
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 50)
TabContainer.Position = UDim2.new(0, 10, 0, 75)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = NebulaFrame
TabContainer.ZIndex = 12

local Tabs = {
    {name = "Main", icon = "🌌", color = NebulaColors.primary},
    {name = "Visuals", icon = "👁️", color = NebulaColors.primary},
    {name = "Survivor", icon = "🛡️", color = NebulaColors.primary},
    {name = "Killer", icon = "⚔️", color = NebulaColors.primary},
    {name = "Teleport", icon = "🌀", color = NebulaColors.primary},
    {name = "Farm", icon = "⚡", color = NebulaColors.primary},
    {name = "Misc", icon = "⚙️", color = NebulaColors.primary}
}

local TabButtons = {}
local CurrentTab = "Main"

for i, tabData in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 52, 0, 50)
    TabBtn.Position = UDim2.new(0, (i-1) * 54, 0, 0)
    TabBtn.BackgroundColor3 = NebulaColors.surface
    TabBtn.BackgroundTransparency = 0.2
    TabBtn.Text = ""
    TabBtn.Parent = TabContainer
    TabBtn.ZIndex = 13
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = TabBtn
    
    local Icon = Instance.new("TextLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = tabData.icon
    Icon.TextColor3 = NebulaColors.textDim
    Icon.TextSize = 22
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = TabBtn
    Icon.ZIndex = 14
    
    -- Hover effect
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= tabData.name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.surface:lerp(NebulaColors.primary, 0.3)}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {TextColor3 = NebulaColors.text}):Play()
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= tabData.name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.surface}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {TextColor3 = NebulaColors.textDim}):Play()
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tabData.name
        for _, btn in pairs(TabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                BackgroundColor3 = NebulaColors.surface,
                Size = UDim2.new(0, 52, 0, 50)
            }):Play()
            btn:FindFirstChild("Icon").TextColor3 = NebulaColors.textDim
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundColor3 = NebulaColors.primary,
            Size = UDim2.new(0, 54, 0, 52)
        }):Play()
        Icon.TextColor3 = NebulaColors.text
        UpdateTab(tabData.name)
    end)
    
    table.insert(TabButtons, TabBtn)
end

--==================================================
-- NEBULA CONTENT
--==================================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -140)
ContentFrame.Position = UDim2.new(0, 10, 0, 130)
ContentFrame.BackgroundColor3 = NebulaColors.surface
ContentFrame.BackgroundTransparency = 0.1
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = NebulaFrame
ContentFrame.ZIndex = 12

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 16)
ContentCorner.Parent = ContentFrame

-- Content header
local ContentHeader = Instance.new("Frame")
ContentHeader.Size = UDim2.new(1, -20, 0, 45)
ContentHeader.Position = UDim2.new(0, 10, 0, 10)
ContentHeader.BackgroundColor3 = NebulaColors.background
ContentHeader.BackgroundTransparency = 0.2
ContentHeader.Parent = ContentFrame
ContentHeader.ZIndex = 13

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = ContentHeader

local HeaderIcon = Instance.new("TextLabel")
HeaderIcon.Size = UDim2.new(0, 35, 1, 0)
HeaderIcon.Position = UDim2.new(0, 10, 0, 0)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.Text = "🌌"
HeaderIcon.TextColor3 = NebulaColors.primary
HeaderIcon.TextSize = 20
HeaderIcon.Font = Enum.Font.Gotham
HeaderIcon.Parent = ContentHeader
HeaderIcon.ZIndex = 14

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -60, 1, 0)
HeaderTitle.Position = UDim2.new(0, 45, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "MAIN"
HeaderTitle.TextColor3 = NebulaColors.text
HeaderTitle.TextSize = 15
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = ContentHeader
HeaderTitle.ZIndex = 14

-- Time display
local TimeFrame = Instance.new("Frame")
TimeFrame.Size = UDim2.new(0, 70, 0, 30)
TimeFrame.Position = UDim2.new(1, -80, 0.5, -15)
TimeFrame.BackgroundColor3 = NebulaColors.background
TimeFrame.BackgroundTransparency = 0.2
TimeFrame.Parent = ContentHeader
TimeFrame.ZIndex = 14

local TimeCorner = Instance.new("UICorner")
TimeCorner.CornerRadius = UDim.new(0, 8)
TimeCorner.Parent = TimeFrame

local TimeText = Instance.new("TextLabel")
TimeText.Size = UDim2.new(1, 0, 1, 0)
TimeText.BackgroundTransparency = 1
TimeText.Text = os.date("%H:%M")
TimeText.TextColor3 = NebulaColors.primary
TimeText.TextSize = 13
TimeText.Font = Enum.Font.GothamBold
TimeText.Parent = TimeFrame
TimeText.ZIndex = 15

-- Update time
task.spawn(function()
    while TimeText do
        task.wait(1)
        TimeText.Text = os.date("%H:%M")
    end
end)

-- Scrolling frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -70)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = NebulaColors.primary
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentFrame
ScrollingFrame.ZIndex = 13

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

--==================================================
-- FUNGSI UI NEBULA
--==================================================

function CreateSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 35)
    Section.BackgroundTransparency = 1
    Section.Text = "  " .. text
    Section.TextColor3 = NebulaColors.primary
    Section.TextSize = 15
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
    Section.ZIndex = 14
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -10, 0, 2)
    Line.Position = UDim2.new(0, 5, 0, 32)
    Line.BackgroundColor3 = NebulaColors.primary
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section
    Line.ZIndex = 13
    
    return Section
end

function CreateToggle(text, desc, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 60)
    ToggleFrame.BackgroundColor3 = NebulaColors.background
    ToggleFrame.BackgroundTransparency = 0.2
    ToggleFrame.Parent = ScrollingFrame
    ToggleFrame.ZIndex = 14
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleFrame
    
    local IconContainer = Instance.new("Frame")
    IconContainer.Size = UDim2.new(0, 35, 0, 35)
    IconContainer.Position = UDim2.new(0, 12, 0.5, -17.5)
    IconContainer.BackgroundColor3 = NebulaColors.surface
    IconContainer.Parent = ToggleFrame
    IconContainer.ZIndex = 15
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8)
    IconCorner.Parent = IconContainer
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "⚡"
    Icon.TextColor3 = NebulaColors.primary
    Icon.TextSize = 18
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = IconContainer
    Icon.ZIndex = 16
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.6, -60, 0, 22)
    ToggleText.Position = UDim2.new(0, 55, 0, 10)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = NebulaColors.text
    ToggleText.TextSize = 14
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    ToggleText.ZIndex = 15
    
    local ToggleDesc = Instance.new("TextLabel")
    ToggleDesc.Size = UDim2.new(0.6, -60, 0, 16)
    ToggleDesc.Position = UDim2.new(0, 55, 0, 32)
    ToggleDesc.BackgroundTransparency = 1
    ToggleDesc.Text = desc or ""
    ToggleDesc.TextColor3 = NebulaColors.textDim
    ToggleDesc.TextSize = 11
    ToggleDesc.Font = Enum.Font.Gotham
    ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
    ToggleDesc.Parent = ToggleFrame
    ToggleDesc.ZIndex = 15
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 75, 0, 35)
    ToggleBtn.Position = UDim2.new(1, -90, 0.5, -17.5)
    ToggleBtn.BackgroundColor3 = NebulaColors.surface
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.ZIndex = 16
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = ToggleBtn
    
    local enabled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                BackgroundColor3 = NebulaColors.primary,
                TextColor3 = NebulaColors.text
            }):Play()
            ToggleBtn.Text = "ON"
            TweenService:Create(Icon, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(0, 255, 100)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                BackgroundColor3 = NebulaColors.surface,
                TextColor3 = Color3.fromRGB(255, 100, 100)
            }):Play()
            ToggleBtn.Text = "OFF"
            TweenService:Create(Icon, TweenInfo.new(0.3), {TextColor3 = NebulaColors.primary}):Play()
        end
        callback(enabled)
    end)
    
    return ToggleFrame
end

function CreateButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.BackgroundColor3 = color or NebulaColors.primary
    Button.Text = ""
    Button.Parent = ScrollingFrame
    Button.ZIndex = 14
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Button
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -20, 1, 0)
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = text
    TextLabel.TextColor3 = NebulaColors.text
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextXAlignment = Enum.TextXAlignment.Center
    TextLabel.Parent = Button
    TextLabel.ZIndex = 15
    
    -- Hover effect
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = (color or NebulaColors.primary):lerp(NebulaColors.text, 0.2)
        }):Play()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 52)
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = color or NebulaColors.primary
        }):Play()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 50)
        }):Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

function CreateDropdown(text, options, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
    DropdownFrame.BackgroundColor3 = NebulaColors.background
    DropdownFrame.BackgroundTransparency = 0.2
    DropdownFrame.Parent = ScrollingFrame
    DropdownFrame.ZIndex = 14
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 12)
    DropdownCorner.Parent = DropdownFrame
    
    local IconContainer = Instance.new("Frame")
    IconContainer.Size = UDim2.new(0, 35, 0, 35)
    IconContainer.Position = UDim2.new(0, 12, 0.5, -17.5)
    IconContainer.BackgroundColor3 = NebulaColors.surface
    IconContainer.Parent = DropdownFrame
    IconContainer.ZIndex = 15
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8)
    IconCorner.Parent = IconContainer
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "📋"
    Icon.TextColor3 = NebulaColors.primary
    Icon.TextSize = 18
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = IconContainer
    Icon.ZIndex = 16
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -60, 0, 22)
    DropdownText.Position = UDim2.new(0, 55, 0, 10)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = NebulaColors.text
    DropdownText.TextSize = 14
    DropdownText.Font = Enum.Font.GothamBold
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    DropdownText.ZIndex = 15
    
    local DropdownDesc = Instance.new("TextLabel")
    DropdownDesc.Size = UDim2.new(0.5, -60, 0, 16)
    DropdownDesc.Position = UDim2.new(0, 55, 0, 32)
    DropdownDesc.BackgroundTransparency = 1
    DropdownDesc.Text = "Click to select"
    DropdownDesc.TextColor3 = NebulaColors.textDim
    DropdownDesc.TextSize = 11
    DropdownDesc.Font = Enum.Font.Gotham
    DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
    DropdownDesc.Parent = DropdownFrame
    DropdownDesc.ZIndex = 15
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 120, 0, 35)
    DropdownBtn.Position = UDim2.new(1, -135, 0.5, -17.5)
    DropdownBtn.BackgroundColor3 = NebulaColors.surface
    DropdownBtn.Text = options[1] or "Select"
    DropdownBtn.TextColor3 = NebulaColors.text
    DropdownBtn.TextSize = 12
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.Parent = DropdownFrame
    DropdownBtn.ZIndex = 16
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        -- Hapus menu lama
        local oldMenu = DropdownFrame:FindFirstChild("DropdownMenu")
        if oldMenu then oldMenu:Destroy() end
        
        -- Buat menu baru dengan ZIndex tinggi
        local menu = Instance.new("Frame")
        menu.Name = "DropdownMenu"
        menu.Size = UDim2.new(0, 140, 0, math.min(#options, 5) * 40)
        menu.Position = UDim2.new(1, -135, 1, 5)
        menu.BackgroundColor3 = NebulaColors.surface
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        menu.ZIndex = 999
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 12)
        menuCorner.Parent = menu
        
        local menuList = Instance.new("ScrollingFrame")
        menuList.Size = UDim2.new(1, -2, 1, -2)
        menuList.Position = UDim2.new(0, 1, 0, 1)
        menuList.BackgroundTransparency = 1
        menuList.ScrollBarThickness = 4
        menuList.CanvasSize = UDim2.new(0, 0, 0, #options * 40)
        menuList.Parent = menu
        menuList.ZIndex = 1000
        
        for i, option in ipairs(options) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(1, 0, 0, 40)
            optionBtn.Position = UDim2.new(0, 0, 0, (i-1) * 40)
            optionBtn.BackgroundColor3 = NebulaColors.background
            optionBtn.Text = option
            optionBtn.TextColor3 = NebulaColors.text
            optionBtn.TextSize = 13
            optionBtn.Font = Enum.Font.Gotham
            optionBtn.Parent = menuList
            optionBtn.ZIndex = 1001
            optionBtn.BorderSizePixel = 0
            
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 8)
            optionCorner.Parent = optionBtn
            
            optionBtn.MouseEnter:Connect(function()
                TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = NebulaColors.primary
                }):Play()
            end)
            
            optionBtn.MouseLeave:Connect(function()
                TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = NebulaColors.background
                }):Play()
            end)
            
            optionBtn.MouseButton1Click:Connect(function()
                DropdownBtn.Text = option
                callback(option)
                TweenService:Create(menu, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1
                }):Play()
                task.wait(0.2)
                menu:Destroy()
            end)
        end
    end)
    
    return DropdownFrame
end

function CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 28)
    Label.BackgroundTransparency = 1
    Label.Text = "• " .. text
    Label.TextColor3 = NebulaColors.textDim
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ScrollingFrame
    Label.ZIndex = 14
    
    return Label
end

function CreateSlider(text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 95)
    SliderFrame.BackgroundColor3 = NebulaColors.background
    SliderFrame.BackgroundTransparency = 0.2
    SliderFrame.Parent = ScrollingFrame
    SliderFrame.ZIndex = 14
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 12)
    SliderCorner.Parent = SliderFrame
    
    local IconContainer = Instance.new("Frame")
    IconContainer.Size = UDim2.new(0, 35, 0, 35)
    IconContainer.Position = UDim2.new(0, 12, 0.5, -17.5)
    IconContainer.BackgroundColor3 = NebulaColors.surface
    IconContainer.Parent = SliderFrame
    IconContainer.ZIndex = 15
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8)
    IconCorner.Parent = IconContainer
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "🎚️"
    Icon.TextColor3 = NebulaColors.primary
    Icon.TextSize = 18
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = IconContainer
    Icon.ZIndex = 16
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.5, -60, 0, 22)
    SliderText.Position = UDim2.new(0, 55, 0, 10)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = NebulaColors.text
    SliderText.TextSize = 14
    SliderText.Font = Enum.Font.GothamBold
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    SliderText.ZIndex = 15
    
    -- Control panel untuk nilai
    local ControlPanel = Instance.new("Frame")
    ControlPanel.Size = UDim2.new(0, 140, 0, 30)
    ControlPanel.Position = UDim2.new(1, -155, 0, 10)
    ControlPanel.BackgroundColor3 = NebulaColors.surface
    ControlPanel.Parent = SliderFrame
    ControlPanel.ZIndex = 15
    
    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 8)
    PanelCorner.Parent = ControlPanel
    
    -- Nilai slider
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 45, 1, 0)
    ValueLabel.Position = UDim2.new(0, 5, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = NebulaColors.primary
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = ControlPanel
    ValueLabel.ZIndex = 16
    
    -- Tombol decrease
    local DecBtn = Instance.new("TextButton")
    DecBtn.Size = UDim2.new(0, 25, 0, 25)
    DecBtn.Position = UDim2.new(0, 55, 0.5, -12.5)
    DecBtn.BackgroundColor3 = NebulaColors.background
    DecBtn.Text = "−"
    DecBtn.TextColor3 = NebulaColors.text
    DecBtn.TextSize = 16
    DecBtn.Font = Enum.Font.GothamBold
    DecBtn.Parent = ControlPanel
    DecBtn.ZIndex = 17
    
    local DecCorner = Instance.new("UICorner")
    DecCorner.CornerRadius = UDim.new(0, 6)
    DecCorner.Parent = DecBtn
    
    -- Input box
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 35, 0, 25)
    InputBox.Position = UDim2.new(0, 85, 0.5, -12.5)
    InputBox.BackgroundColor3 = NebulaColors.background
    InputBox.Text = tostring(default)
    InputBox.TextColor3 = NebulaColors.text
    InputBox.TextSize = 12
    InputBox.Font = Enum.Font.GothamBold
    InputBox.ClearTextOnFocus = true
    InputBox.Parent = ControlPanel
    InputBox.ZIndex = 17
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputBox
    
    -- Tombol increase
    local IncBtn = Instance.new("TextButton")
    IncBtn.Size = UDim2.new(0, 25, 0, 25)
    IncBtn.Position = UDim2.new(0, 125, 0.5, -12.5)
    IncBtn.BackgroundColor3 = NebulaColors.background
    IncBtn.Text = "+"
    IncBtn.TextColor3 = NebulaColors.text
    IncBtn.TextSize = 16
    IncBtn.Font = Enum.Font.GothamBold
    IncBtn.Parent = ControlPanel
    IncBtn.ZIndex = 17
    
    local IncCorner = Instance.new("UICorner")
    IncCorner.CornerRadius = UDim.new(0, 6)
    IncCorner.Parent = IncBtn
    
    -- Slider
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -30, 0, 8)
    SliderBg.Position = UDim2.new(0, 15, 0, 65)
    SliderBg.BackgroundColor3 = NebulaColors.surface
    SliderBg.Parent = SliderFrame
    SliderBg.ZIndex = 15
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = NebulaColors.primary
    SliderFill.Parent = SliderBg
    SliderFill.ZIndex = 16
    
    local SliderButton = Instance.new("Frame")
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    SliderButton.BackgroundColor3 = NebulaColors.text
    SliderButton.Parent = SliderFill
    SliderButton.ZIndex = 17
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = SliderButton
    
    -- Fungsi update nilai
    local function updateValue(newValue)
        newValue = math.clamp(newValue, min, max)
        local percent = (newValue - min) / (max - min)
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
        ValueLabel.Text = tostring(newValue)
        InputBox.Text = tostring(newValue)
        callback(newValue)
    end
    
    -- Decrease button
    DecBtn.MouseButton1Click:Connect(function()
        local current = tonumber(ValueLabel.Text) or default
        updateValue(current - 1)
        -- Animasi button
        TweenService:Create(DecBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 23, 0, 23)}):Play()
        task.wait(0.1)
        TweenService:Create(DecBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 25, 0, 25)}):Play()
    end)
    
    -- Increase button
    IncBtn.MouseButton1Click:Connect(function()
        local current = tonumber(ValueLabel.Text) or default
        updateValue(current + 1)
        TweenService:Create(IncBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 23, 0, 23)}):Play()
        task.wait(0.1)
        TweenService:Create(IncBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 25, 0, 25)}):Play()
    end)
    
    -- Input box
    InputBox.FocusLost:Connect(function()
        local val = tonumber(InputBox.Text)
        if val then
            updateValue(val)
        else
            InputBox.Text = tostring(default)
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
            local value = math.floor(min + (max - min) * percent)
            updateValue(value)
        end
    end)
    
    return SliderFrame
end

--==================================================
-- FLOATING BUTTON CLICK
--==================================================
NebulaOrb.MouseButton1Click:Connect(function()
    NebulaFrame.Visible = not NebulaFrame.Visible
    if NebulaFrame.Visible then
        OrbIcon.Text = "🌌"
        OrbTooltip.Text = "Sembunyikan menu"
        TweenService:Create(NebulaFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 420, 0, 600),
            Position = UDim2.new(0.5, -210, 0.5, -300)
        }):Play()
    else
        OrbIcon.Text = "🌠"
        OrbTooltip.Text = "Tampilkan menu"
    end
end)

--==================================================
-- KEYBIND F4
--==================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        NebulaFrame.Visible = not NebulaFrame.Visible
        if NebulaFrame.Visible then
            OrbIcon.Text = "🌌"
            OrbTooltip.Text = "Sembunyikan menu"
        else
            OrbIcon.Text = "🌠"
            OrbTooltip.Text = "Tampilkan menu"
        end
    end
end)

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
        Main = "🌌",
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
        CreateButton("Refresh Info", NebulaColors.primary, function()
            UpdateTab("Main")
        end)
        
        CreateButton("Rejoin Server", Color3.fromRGB(220, 60, 60), function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end)
        
        CreateSection("CREDITS")
        CreateLabel("Violence District - Nebula Edition")
        CreateLabel("Version 6.0")
        CreateLabel("Made by LuckyBimZy")
        CreateLabel("UI Design: Nebula")
        
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
        
        CreateToggle("Rainbow ESP", "ESP changes colors", function(state)
            Toggles.RainbowESP = state
        end)
        
    elseif tab == "Survivor" then
        CreateSection("AUTO FARM")
        CreateToggle("Auto Farm Present", "Automatically collect presents", function(state)
            Toggles.AutoFarmPresent = state
            if state then StartLoop("AutoFarmPresent") else StopLoop("AutoFarmPresent") end
        end)
        
        CreateToggle("Auto Farm Gift", "Collect gifts and teleport to tree", function(state)
            Toggles.AutoFarmGift = state
            if state then StartLoop("AutoFarmGift") else StopLoop("AutoFarmGift") end
        end)
        
        CreateToggle("Auto Open Presents", "Automatically open presents", function(state)
            Toggles.AutoOpenPresents = state
        end)
        
        CreateToggle("Auto Collect Coins", "Collect coins automatically", function(state)
            Toggles.AutoCollectCoins = state
            if state then StartLoop("AutoCollectCoins") else StopLoop("AutoCollectCoins") end
        end)
        
        CreateToggle("Auto Heal", "Auto heal when health low", function(state)
            Toggles.AutoHeal = state
            if state then StartLoop("AutoHeal") else StopLoop("AutoHeal") end
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
            if state then StartLoop("Aimbot") else StopLoop("Aimbot") end
        end)
        
        CreateToggle("Silent Aim", "Aim without moving camera", function(state)
            Toggles.SilentAim = state
        end)
        
        CreateToggle("Kill Aura", "Auto kill nearby players", function(state)
            Toggles.KillAura = state
            if state then StartLoop("KillAura") else StopLoop("KillAura") end
        end)
        
        CreateSlider("Kill Aura Range", 5, 50, Toggles.KillAuraRange, function(value)
            Toggles.KillAuraRange = value
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
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                Notify("Teleport", "Teleported to " .. name, 1)
            end
        end)
        
        CreateButton("Refresh List", NebulaColors.surface, function()
            UpdateTab("Teleport")
        end)
        
        CreateSection("WAYPOINTS")
        CreateButton("Save Current Position", Color3.fromRGB(0, 200, 100), function()
            SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Waypoint", "Position saved!", 1)
        end)
        
        CreateButton("Teleport to Saved", NebulaColors.primary, function()
            if SavedPosition then
                Player.Character.HumanoidRootPart.CFrame = SavedPosition
                Notify("Teleport", "Teleported to saved position", 1)
            else
                Notify("Error", "No saved position!", 1)
            end
        end)
        
    elseif tab == "Farm" then
        CreateSection("GENERATOR FARM")
        CreateToggle("Auto Farm Generator", "Automatically repair generators", function(state)
            Toggles.AutoFarmGenerator = state
            if state then StartLoop("AutoFarmGenerator") else StopLoop("AutoFarmGenerator") end
        end)
        
        CreateToggle("Auto Complete", "Auto complete generators", function(state)
            Toggles.AutoCompleteGenerator = state
            if state then StartLoop("AutoCompleteGenerator") else StopLoop("AutoCompleteGenerator") end
        end)
        
        CreateToggle("Auto Repair", "Auto repair when damaged", function(state)
            Toggles.AutoRepair = state
        end)
        
        CreateSection("GENERATOR INFO")
        CreateButton("Find Nearest Generator", NebulaColors.primary, function()
            local gen = FindNearestGenerator()
            if gen then
                Player.Character.HumanoidRootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
                Notify("Generator", "Found at " .. math.floor((Player.Character.HumanoidRootPart.Position - gen.PrimaryPart.Position).Magnitude) .. "m", 1)
            else
                Notify("Error", "No generator found!", 1)
            end
        end)
        
        CreateLabel("Generators nearby: " .. CountGenerators())
        
        CreateSection("RESOURCES")
        local presents = CountPresents()
        local gifts = CountGifts()
        CreateLabel("Presents: " .. presents)
        CreateLabel("Gifts: " .. gifts)
        
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
            if state then StartLoop("AutoClick") else StopLoop("AutoClick") end
        end)
        
        CreateToggle("No Skill Check", "Remove all skill checks", function(state)
            Toggles.NoSkillCheck = state
            ToggleSkillCheck(state)
        end)
        
        CreateToggle("Anti Stun", "Prevent stun effects", function(state)
            Toggles.AntiStun = state
        end)
        
        CreateSection("GUI CONTROLS")
        CreateButton("Toggle Menu (F4)", NebulaColors.primary, function()
            NebulaFrame.Visible = not NebulaFrame.Visible
            if NebulaFrame.Visible then
                OrbIcon.Text = "🌌"
                OrbTooltip.Text = "Sembunyikan menu"
            else
                OrbIcon.Text = "🌠"
                OrbTooltip.Text = "Tampilkan menu"
            end
        end)
        
        CreateButton("Minimize", NebulaColors.surface, function()
            NebulaFrame.Visible = false
            OrbIcon.Text = "🌠"
            OrbTooltip.Text = "Tampilkan menu"
        end)
        
        CreateButton("Close GUI", Color3.fromRGB(220, 60, 60), function()
            TweenService:Create(NebulaFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(NebulaOrb, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.3)
            ScreenGui:Destroy()
            _G.VD_Nebula = false
        end)
        
        CreateSection("STATUS")
        local activeLoops = 0
        for _, v in pairs(Loops) do if v then activeLoops = activeLoops + 1 end end
        CreateLabel("Active Features: " .. activeLoops)
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- CORE FUNCTIONS (Sama seperti sebelumnya)
--==================================================
function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(0.5)
                continue
            end
            
            if name == "AutoFarmPresent" then
                local present = FindNearestPresent()
                if present then
                    Player.Character.HumanoidRootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                    else
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or
                                      game:GetService("ReplicatedStorage"):FindFirstChild("PresentEvent")
                        if remote then
                            pcall(function()
                                remote:FireServer("CollectPresent", present)
                            end)
                        end
                    end
                end
                
            elseif name == "AutoFarmGift" then
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
                
            elseif name == "AutoCollectCoins" then
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
                
            elseif name == "AutoHeal" then
                if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                    if Player.Character.Humanoid.Health < 50 then
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or
                                      game:GetService("ReplicatedStorage"):FindFirstChild("HealEvent")
                        if remote then
                            pcall(function()
                                remote:FireServer("Heal")
                            end)
                        end
                    end
                end
                
            elseif name == "Aimbot" then
                local target = FindNearestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    Player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(
                        Player.Character.HumanoidRootPart.Position, 
                        targetPos
                    )
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
                
            elseif name == "AutoFarmGenerator" then
                local gen = FindNearestGenerator()
                if gen then
                    if gen.PrimaryPart then
                        Player.Character.HumanoidRootPart.CFrame = gen.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.05)
                    end
                    local prompt = gen:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                    else
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or
                                      game:GetService("ReplicatedStorage"):FindFirstChild("GeneratorEvent") or
                                      game:GetService("ReplicatedStorage"):FindFirstChild("RepairEvent")
                        if remote then
                            pcall(function()
                                remote:FireServer("RepairGenerator", gen)
                                remote:FireServer("Repair", gen)
                            end)
                        end
                    end
                end
                
            elseif name == "AutoCompleteGenerator" then
                local gen = FindNearestGenerator()
                if gen then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or
                                  game:GetService("ReplicatedStorage"):FindFirstChild("CompleteEvent")
                    if remote then
                        pcall(function()
                            remote:FireServer("CompleteGenerator", gen)
                            remote:FireServer("Complete", gen)
                        end)
                    end
                end
                
            elseif name == "AutoClick" then
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
            AddESP(player)
        end
    end
end

function AddESP(player)
    if not player.Character then return end
    
    if Toggles.ESPType == "Highlight" or Toggles.ESPType == "Box" then
        local highlight = Instance.new("Highlight")
        highlight.Name = "VD_ESP"
        highlight.Parent = player.Character
        highlight.FillColor = Toggles.RainbowESP and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Toggles.ESPColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    
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
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    
    task.spawn(function()
        while billboard and billboard.Parent do
            task.wait(0.5)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude)
                nameLabel.Text = player.Name .. " [" .. dist .. "m]"
            end
            if Toggles.RainbowESP and Toggles.ESP then
                local highlight = player.Character:FindFirstChild("VD_ESP")
                if highlight then
                    highlight.FillColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
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
        end
    end
end

function UpdateWallhack()
    if Toggles.Wallhack then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
                if v.Name ~= "HumanoidRootPart" and v.Transparency < 0.5 then
                    v.Material = Enum.Material.ForceField
                    v.Transparency = 0.5
                end
            end
        end
    else
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Material == Enum.Material.ForceField then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
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
        if not mt then return end
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

-- Character update
Player.CharacterAdded:Connect(function(newChar)
    Player.Character = newChar
    task.wait(1)
end)

--==================================================
-- INITIALIZE
--==================================================

-- Set tab pertama
UpdateTab("Main")

-- Set tab pertama aktif
for i, btn in ipairs(TabButtons) do
    if i == 1 then
        TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundColor3 = NebulaColors.primary,
            Size = UDim2.new(0, 54, 0, 52)
        }):Play()
        btn:FindFirstChild("Icon").TextColor3 = NebulaColors.text
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = NebulaColors.surface}):Play()
        btn:FindFirstChild("Icon").TextColor3 = NebulaColors.textDim
    end
end

-- Notifikasi
Notify("Violence District", "Nebula Edition Loaded! Press F4 to toggle menu", 3)

print("========================================")
print("✅ VIOLENCE DISTRICT - NEBULA EDITION LOADED!")
print("Tekan F4 untuk toggle menu")
print("Floating orb selalu tersedia")
print("========================================")