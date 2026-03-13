-- ==================== GAMES/VIOLENCE.LUA ====================
-- Script Ultimate Violence District dengan UI Super Modern
-- Author: LuckyBimZy
-- Version: 6.0 (Ultimate Deluxe)

if _G.ViolenceLoaded then 
    print("⚠️ Script sudah diload, melewati...")
    return 
end

_G.ViolenceLoaded = true

print("🔰 Memuat Violence District Script Ultimate Deluxe...")
task.wait(1)

--==================================================
-- VARIABLES
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
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Toggle variables
local Toggles = {
    -- Visuals
    SurvivorESP = false,
    KillerESP = false,
    GeneratorESP = false,
    ItemESP = false,
    ChestESP = false,
    UnlimitedZoom = false,
    FullBright = false,
    Wallhack = false,
    XRay = false,
    RainbowMode = false,
    NoFog = false,
    ESPLines = false,
    ESPTracers = false,
    ESPBoxes = false,
    ESPNames = true,
    ESPDistance = true,
    
    -- Survivor
    AutoFarmPresent = false,
    AutoFarmGift = false,
    AutoOpenPresents = false,
    AutoCollectCoins = false,
    AutoHeal = false,
    FlickerSpeed = false,
    SpeedBoost = false,
    JumpBoost = false,
    BodyLock = false,
    AutoEscape = false,
    AutoHide = false,
    AutoRepair = false,
    AutoComplete = false,
    
    -- Killer
    Aimbot = false,
    SilentAim = false,
    KillAura = false,
    AutoAttack = false,
    InstantKill = false,
    WallhackKiller = false,
    AutoHunt = false,
    TeleportToKill = false,
    
    -- Teleport
    NoClip = false,
    TeleportToTarget = false,
    TeleportToMouse = false,
    TeleportToCursor = false,
    TeleportToWaypoint = false,
    AutoTeleport = false,
    
    -- Farm
    AutoFarmGenerator = false,
    AutoCompleteGenerator = false,
    AutoCollectGens = false,
    AutoFarmAll = false,
    AutoCollectLoot = false,
    
    -- Misc
    AntiAFK = false,
    AutoClick = false,
    NoSkillCheck = false,
    InfiniteStamina = false,
    AntiStun = false,
    AntiFall = false,
    AntiVoid = false,
    NoClipThrough = false,
    AutoRespawn = false,
    AutoClaim = false
}

-- Target variables
local SelectedTarget = nil
local TPTarget = nil
local KillerTarget = nil
local Waypoints = {}
local GUIHidden = false
local MenuKeybind = Enum.KeyCode.F4
local GUIEnabled = true
local Minimized = false
local MinimizedSize = {Width = 350, Height = 60}
local NormalSize = {Width = 1000, Height = 700}
local UIScale = 1
local Dragging = false
local DragStart = nil
local DragPosition = nil

-- Loop connections
local Loops = {}
local ESPConnections = {}
local ESPObjects = {}

--==================================================
-- CREATE ULTRA MODERN UI
--==================================================

-- Hapus GUI lama jika ada
local oldGUI = game.CoreGui:FindFirstChild("ViolenceUltimateDeluxe")
if oldGUI then oldGUI:Destroy() end

-- Buat ScreenGui utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceUltimateDeluxe"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true

-- Frame utama dengan efek glass morphism premium
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, NormalSize.Width, 0, NormalSize.Height)
MainFrame.Position = UDim2.new(0.5, -NormalSize.Width/2, 0.5, -NormalSize.Height/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Efek glass morphism premium
local GlassEffect = Instance.new("ImageLabel")
GlassEffect.Size = UDim2.new(1, 0, 1, 0)
GlassEffect.BackgroundTransparency = 1
GlassEffect.Image = "rbxassetid://13110653408"
GlassEffect.ImageColor3 = Color3.fromRGB(65, 105, 225)
GlassEffect.ImageTransparency = 0.9
GlassEffect.ScaleType = Enum.ScaleType.Slice
GlassEffect.SliceCenter = Rect.new(10, 10, 10, 10)
GlassEffect.Parent = MainFrame

-- Shadow premium
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 50, 1, 50)
Shadow.Position = UDim2.new(0, -25, 0, -25)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(50, 50, 50, 50)
Shadow.Parent = MainFrame

-- Rounded corners premium
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 25)
MainCorner.Parent = MainFrame

-- Border gradient premium
local BorderGradient = Instance.new("UIGradient")
BorderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 105, 225)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(147, 112, 219)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 105, 225))
})
BorderGradient.Rotation = 45
BorderGradient.Parent = MainFrame

-- Efek glow
local GlowFrame = Instance.new("Frame")
GlowFrame.Size = UDim2.new(1, 6, 1, 6)
GlowFrame.Position = UDim2.new(0, -3, 0, -3)
GlowFrame.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
GlowFrame.BackgroundTransparency = 0.85
GlowFrame.BorderSizePixel = 0
GlowFrame.Parent = MainFrame

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 28)
GlowCorner.Parent = GlowFrame

--==================================================
-- TITLE BAR SUPER PREMIUM
--==================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 70)
TitleBar.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 25)
TitleCorner.Parent = TitleBar

-- Garis bawah title bar dengan efek glow
local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, -40, 0, 3)
TitleLine.Position = UDim2.new(0, 20, 1, -3)
TitleLine.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
TitleLine.BorderSizePixel = 0
TitleLine.Parent = TitleBar

local LineGradient = Instance.new("UIGradient")
LineGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 105, 225)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(147, 112, 219)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 105, 225))
})
LineGradient.Rotation = 90
LineGradient.Parent = TitleLine

-- Logo dengan efek glow
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 50, 0, 50)
LogoContainer.Position = UDim2.new(0, 15, 0.5, -25)
LogoContainer.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
LogoContainer.BackgroundTransparency = 0.3
LogoContainer.Parent = TitleBar

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 15)
LogoCorner.Parent = LogoContainer

local LogoGlow = Instance.new("Frame")
LogoGlow.Size = UDim2.new(1, 4, 1, 4)
LogoGlow.Position = UDim2.new(0, -2, 0, -2)
LogoGlow.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
LogoGlow.BackgroundTransparency = 0.7
LogoGlow.BorderSizePixel = 0
LogoGlow.Parent = LogoContainer

local LogoGlowCorner = Instance.new("UICorner")
LogoGlowCorner.CornerRadius = UDim.new(0, 17)
LogoGlowCorner.Parent = LogoGlow

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(1, -4, 1, -4)
Logo.Position = UDim2.new(0, 2, 0, 2)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://4483345998"
Logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
Logo.Parent = LogoContainer

-- Title dengan efek gradient
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 350, 0, 35)
Title.Position = UDim2.new(0, 75, 0.5, -17.5)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 105, 225))
})
TitleGradient.Rotation = 45
TitleGradient.Parent = Title

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(0, 150, 0, 20)
Version.Position = UDim2.new(0, 75, 0.5, 10)
Version.BackgroundTransparency = 1
Version.Text = "ULTIMATE DELUXE v6.0"
Version.TextColor3 = Color3.fromRGB(65, 105, 225)
Version.TextSize = 12
Version.Font = Enum.Font.Gotham
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = TitleBar

-- Window controls premium
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 160, 0, 45)
ControlFrame.Position = UDim2.new(1, -170, 0.5, -22.5)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 45, 0, 45)
MinBtn.Position = UDim2.new(0, 0, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 28
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = ControlFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 15)
MinCorner.Parent = MinBtn

-- Hover effect
MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
end)
MinBtn.MouseLeave:Connect(function()
    if not Minimized then
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = true
    
    -- Animasi minimize
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, MinimizedSize.Width, 0, MinimizedSize.Height),
        Position = UDim2.new(0.5, -MinimizedSize.Width/2, 0, 20)
    }):Play()
    
    task.wait(0.2)
    
    -- Sembunyikan semua kecuali title bar
    for _, v in pairs(MainFrame:GetChildren()) do
        if v ~= TitleBar and v ~= Shadow and v ~= GlassEffect and v ~= GlowFrame then
            v.Visible = false
        end
    end
    
    -- Update button states
    MaxBtn.Visible = true
    MinBtn.Visible = false
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    
    -- Ubah title saat minimize
    Title.Text = "VIOLENCE DISTRICT [MINIMIZED]"
    Title.TextSize = 18
end)

-- Maximize button
local MaxBtn = Instance.new("TextButton")
MaxBtn.Size = UDim2.new(0, 45, 0, 45)
MaxBtn.Position = UDim2.new(0, 0, 0, 0)
MaxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MaxBtn.Text = "□"
MaxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MaxBtn.TextSize = 24
MaxBtn.Font = Enum.Font.GothamBold
MaxBtn.Visible = false
MaxBtn.Parent = ControlFrame

local MaxCorner = Instance.new("UICorner")
MaxCorner.CornerRadius = UDim.new(0, 15)
MaxCorner.Parent = MaxBtn

MaxBtn.MouseEnter:Connect(function()
    TweenService:Create(MaxBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
end)
MaxBtn.MouseLeave:Connect(function()
    if Minimized then
        TweenService:Create(MaxBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end
end)

MaxBtn.MouseButton1Click:Connect(function()
    Minimized = false
    
    -- Tampilkan semua komponen
    for _, v in pairs(MainFrame:GetChildren()) do
        v.Visible = true
    end
    
    -- Animasi maximize
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, NormalSize.Width, 0, NormalSize.Height),
        Position = UDim2.new(0.5, -NormalSize.Width/2, 0.5, -NormalSize.Height/2)
    }):Play()
    
    -- Update button states
    MaxBtn.Visible = false
    MinBtn.Visible = true
    
    -- Kembalikan title
    Title.Text = "VIOLENCE DISTRICT"
    Title.TextSize = 24
    
    -- Refresh konten
    UpdateTabContent(CurrentTab)
end)

-- Settings button
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 45, 0, 45)
SettingsBtn.Position = UDim2.new(0, 50, 0, 0)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsBtn.TextSize = 22
SettingsBtn.Font = Enum.Font.Gotham
SettingsBtn.Parent = ControlFrame

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 15)
SettingsCorner.Parent = SettingsBtn

SettingsBtn.MouseEnter:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
end)
SettingsBtn.MouseLeave:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
end)

SettingsBtn.MouseButton1Click:Connect(function()
    UpdateTabContent("SETTINGS")
end)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 45, 0, 45)
CloseBtn.Position = UDim2.new(0, 100, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 32
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = ControlFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 15)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Animasi close
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.4)
    ScreenGui:Destroy()
end)

--==================================================
-- SIDE BAR ULTRA MODERN
--==================================================
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 220, 1, -80)
SideBar.Position = UDim2.new(0, 10, 0, 75)
SideBar.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
SideBar.BackgroundTransparency = 0.1
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 20)
SideCorner.Parent = SideBar

local SideGradient = Instance.new("UIGradient")
SideGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
})
SideGradient.Rotation = 180
SideGradient.Parent = SideBar

-- Side bar header
local SideHeader = Instance.new("Frame")
SideHeader.Size = UDim2.new(1, -20, 0, 50)
SideHeader.Position = UDim2.new(0, 15, 0, 15)
SideHeader.BackgroundTransparency = 1
SideHeader.Parent = SideBar

local SideTitle = Instance.new("TextLabel")
SideTitle.Size = UDim2.new(1, 0, 0, 25)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "NAVIGATION"
SideTitle.TextColor3 = Color3.fromRGB(65, 105, 225)
SideTitle.TextSize = 16
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextXAlignment = Enum.TextXAlignment.Left
SideTitle.Parent = SideHeader

local SideSub = Instance.new("TextLabel")
SideSub.Size = UDim2.new(1, 0, 0, 20)
SideSub.Position = UDim2.new(0, 0, 0, 25)
SideSub.BackgroundTransparency = 1
SideSub.Text = "Select a category"
SideSub.TextColor3 = Color3.fromRGB(150, 150, 150)
SideSub.TextSize = 11
SideSub.Font = Enum.Font.Gotham
SideSub.TextXAlignment = Enum.TextXAlignment.Left
SideSub.Parent = SideHeader

-- Separator line
local SideLine = Instance.new("Frame")
SideLine.Size = UDim2.new(1, -30, 0, 2)
SideLine.Position = UDim2.new(0, 15, 0, 70)
SideLine.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
SideLine.BackgroundTransparency = 0.5
SideLine.BorderSizePixel = 0
SideLine.Parent = SideBar

-- Tab list dengan ikon dan warna
local TabList = {
    {name = "DASHBOARD", icon = "🏠", color = Color3.fromRGB(65, 105, 225), desc = "Main overview"},
    {name = "VISUALS", icon = "👁️", color = Color3.fromRGB(147, 112, 219), desc = "ESP & effects"},
    {name = "SURVIVOR", icon = "🛡️", color = Color3.fromRGB(0, 200, 100), desc = "Survivor features"},
    {name = "KILLER", icon = "⚔️", color = Color3.fromRGB(220, 60, 60), desc = "Killer features"},
    {name = "TELEPORT", icon = "🌀", color = Color3.fromRGB(255, 165, 0), desc = "Movement & teleport"},
    {name = "FARM", icon = "⚡", color = Color3.fromRGB(255, 215, 0), desc = "Auto farm"},
    {name = "PLAYERS", icon = "👥", color = Color3.fromRGB(100, 200, 255), desc = "Player list"},
    {name = "MISC", icon = "⚙️", color = Color3.fromRGB(150, 150, 150), desc = "Utility features"},
    {name = "SETTINGS", icon = "🔧", color = Color3.fromRGB(180, 180, 180), desc = "Configuration"}
}

local TabButtons = {}
local CurrentTab = "DASHBOARD"

-- Buat tab buttons dengan desain premium
for i, tabData in ipairs(TabList) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabData.name .. "Btn"
    TabBtn.Size = UDim2.new(1, -20, 0, 55)
    TabBtn.Position = UDim2.new(0, 10, 0, 85 + (i-1) * 60)
    TabBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    TabBtn.BackgroundTransparency = 0.2
    TabBtn.Text = ""
    TabBtn.Parent = SideBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 15)
    BtnCorner.Parent = TabBtn
    
    -- Icon container
    local IconContainer = Instance.new("Frame")
    IconContainer.Size = UDim2.new(0, 35, 0, 35)
    IconContainer.Position = UDim2.new(0, 10, 0.5, -17.5)
    IconContainer.BackgroundColor3 = tabData.color
    IconContainer.BackgroundTransparency = 0.3
    IconContainer.Parent = TabBtn
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 10)
    IconCorner.Parent = IconContainer
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = tabData.icon
    Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    Icon.TextSize = 18
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = IconContainer
    
    -- Text
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -55, 0, 25)
    Text.Position = UDim2.new(0, 50, 0.5, -12.5)
    Text.BackgroundTransparency = 1
    Text.Text = tabData.name
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.TextSize = 13
    Text.Font = Enum.Font.GothamBold
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = TabBtn
    
    -- Description
    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -55, 0, 15)
    Desc.Position = UDim2.new(0, 50, 0.5, 7)
    Desc.BackgroundTransparency = 1
    Desc.Text = tabData.desc
    Desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    Desc.TextSize = 9
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = TabBtn
    
    -- Active indicator
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 1, -20)
    Indicator.Position = UDim2.new(1, -3, 0.5, -17.5)
    Indicator.BackgroundColor3 = tabData.color
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = TabBtn
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 3)
    IndicatorCorner.Parent = Indicator
    
    -- Hover effect
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= tabData.name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
            Text.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= tabData.name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 25)}):Play()
            Text.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tabData.name
        
        -- Update semua button
        for _, btn in pairs(TabButtons) do
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(15, 15, 25)}):Play()
            btn:FindFirstChild("TextLabel").TextColor3 = Color3.fromRGB(200, 200, 200)
            btn:FindFirstChild("Desc").TextColor3 = Color3.fromRGB(150, 150, 150)
            btn:FindFirstChild("Indicator").Visible = false
        end
        
        -- Highlight button aktif
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
        Text.TextColor3 = tabData.color
        Desc.TextColor3 = tabData.color
        Indicator.Visible = true
        
        -- Update content
        UpdateTabContent(tabData.name)
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Set tab pertama aktif
TabButtons[1].BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabButtons[1]:FindFirstChild("TextLabel").TextColor3 = TabList[1].color
TabButtons[1]:FindFirstChild("Desc").TextColor3 = TabList[1].color
TabButtons[1]:FindFirstChild("Indicator").Visible = true

--==================================================
-- CONTENT AREA PREMIUM
--==================================================
local ContentBg = Instance.new("Frame")
ContentBg.Size = UDim2.new(1, -250, 1, -90)
ContentBg.Position = UDim2.new(0, 240, 0, 80)
ContentBg.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
ContentBg.BackgroundTransparency = 0.1
ContentBg.BorderSizePixel = 0
ContentBg.ClipsDescendants = true
ContentBg.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 22)
ContentCorner.Parent = ContentBg

-- Content header premium
local ContentHeader = Instance.new("Frame")
ContentHeader.Size = UDim2.new(1, -20, 0, 60)
ContentHeader.Position = UDim2.new(0, 10, 0, 10)
ContentHeader.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
ContentHeader.BackgroundTransparency = 0.1
ContentHeader.Parent = ContentBg

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 18)
HeaderCorner.Parent = ContentHeader

-- Icon header
local HeaderIcon = Instance.new("Frame")
HeaderIcon.Size = UDim2.new(0, 40, 0, 40)
HeaderIcon.Position = UDim2.new(0, 15, 0.5, -20)
HeaderIcon.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
HeaderIcon.BackgroundTransparency = 0.3
HeaderIcon.Parent = ContentHeader

local HeaderIconCorner = Instance.new("UICorner")
HeaderIconCorner.CornerRadius = UDim.new(0, 12)
HeaderIconCorner.Parent = HeaderIcon

local HeaderIconLabel = Instance.new("TextLabel")
HeaderIconLabel.Size = UDim2.new(1, 0, 1, 0)
HeaderIconLabel.BackgroundTransparency = 1
HeaderIconLabel.Text = "📊"
HeaderIconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderIconLabel.TextSize = 22
HeaderIconLabel.Font = Enum.Font.Gotham
HeaderIconLabel.Parent = HeaderIcon

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0.5, -70, 0, 25)
HeaderTitle.Position = UDim2.new(0, 65, 0.5, -12.5)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "DASHBOARD"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = 20
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = ContentHeader

-- Timer real-time
local TimeFrame = Instance.new("Frame")
TimeFrame.Size = UDim2.new(0, 100, 0, 30)
TimeFrame.Position = UDim2.new(1, -110, 0.5, -15)
TimeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TimeFrame.BackgroundTransparency = 0.2
TimeFrame.Parent = ContentHeader

local TimeCorner = Instance.new("UICorner")
TimeCorner.CornerRadius = UDim.new(0, 10)
TimeCorner.Parent = TimeFrame

local TimeIcon = Instance.new("TextLabel")
TimeIcon.Size = UDim2.new(0, 25, 1, 0)
TimeIcon.Position = UDim2.new(0, 5, 0, 0)
TimeIcon.BackgroundTransparency = 1
TimeIcon.Text = "🕒"
TimeIcon.TextColor3 = Color3.fromRGB(65, 105, 225)
TimeIcon.TextSize = 14
TimeIcon.Font = Enum.Font.Gotham
TimeIcon.Parent = TimeFrame

local TimeText = Instance.new("TextLabel")
TimeText.Size = UDim2.new(0, 65, 1, 0)
TimeText.Position = UDim2.new(0, 30, 0, 0)
TimeText.BackgroundTransparency = 1
TimeText.Text = os.date("%H:%M")
TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeText.TextSize = 14
TimeText.Font = Enum.Font.GothamBold
TimeText.Parent = TimeFrame

-- Update time
task.spawn(function()
    while TimeText do
        task.wait(1)
        TimeText.Text = os.date("%H:%M")
    end
end)

-- Scrolling frame premium
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -80)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 80)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 105, 225)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentBg

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

--==================================================
-- FUNGSI UNTUK MEMBUAT ELEMEN UI PREMIUM
--==================================================

function CreateSection(parent, title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 45)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    SectionFrame.BackgroundTransparency = 0.1
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 14)
    SectionCorner.Parent = SectionFrame
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -20, 1, 0)
    SectionTitle.Position = UDim2.new(0, 15, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = "  " .. title
    SectionTitle.TextColor3 = Color3.fromRGB(65, 105, 225)
    SectionTitle.TextSize = 16
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = SectionFrame
    
    return SectionFrame
end

function CreateToggle(parent, text, desc, icon, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 70)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    ToggleFrame.BackgroundTransparency = 0.1
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 14)
    ToggleCorner.Parent = ToggleFrame
    
    -- Icon background
    local IconBg = Instance.new("Frame")
    IconBg.Size = UDim2.new(0, 40, 0, 40)
    IconBg.Position = UDim2.new(0, 15, 0.5, -20)
    IconBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    IconBg.Parent = ToggleFrame
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 12)
    IconCorner.Parent = IconBg
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon or "⚡"
    IconLabel.TextColor3 = Color3.fromRGB(65, 105, 225)
    IconLabel.TextSize = 20
    IconLabel.Font = Enum.Font.Gotham
    IconLabel.Parent = IconBg
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.6, -70, 0, 25)
    ToggleText.Position = UDim2.new(0, 65, 0.5, -12.5)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 15
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleDesc = Instance.new("TextLabel")
    ToggleDesc.Size = UDim2.new(0.6, -70, 0, 20)
    ToggleDesc.Position = UDim2.new(0, 65, 0.5, 7)
    ToggleDesc.BackgroundTransparency = 1
    ToggleDesc.Text = desc or ""
    ToggleDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleDesc.TextSize = 11
    ToggleDesc.Font = Enum.Font.Gotham
    ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
    ToggleDesc.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 80, 0, 40)
    ToggleBtn.Position = UDim2.new(1, -95, 0.5, -20)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 30)
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
            TweenService:Create(IconLabel, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(0, 255, 100)}):Play()
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                TextColor3 = Color3.fromRGB(255, 100, 100)
            }):Play()
            ToggleBtn.Text = "OFF"
            TweenService:Create(IconLabel, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(65, 105, 225)}):Play()
        end
        callback(enabled)
    end)
    
    return ToggleFrame
end

function CreateButton(parent, text, color, icon, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 55)
    Button.BackgroundColor3 = color or Color3.fromRGB(65, 105, 225)
    Button.Text = ""
    Button.Parent = parent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 14)
    BtnCorner.Parent = Button
    
    -- Icon
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 30, 1, 0)
    IconLabel.Position = UDim2.new(0, 15, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon or "🔘"
    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.TextSize = 18
    IconLabel.Font = Enum.Font.Gotham
    IconLabel.Parent = Button
    
    -- Text
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -60, 1, 0)
    TextLabel.Position = UDim2.new(0, 50, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = text
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = Button
    
    -- Hover effect
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

function CreateDropdown(parent, text, items, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 70)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    DropdownFrame.BackgroundTransparency = 0.1
    DropdownFrame.Parent = parent
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 14)
    DropdownCorner.Parent = DropdownFrame
    
    -- Icon
    local IconBg = Instance.new("Frame")
    IconBg.Size = UDim2.new(0, 40, 0, 40)
    IconBg.Position = UDim2.new(0, 15, 0.5, -20)
    IconBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    IconBg.Parent = DropdownFrame
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 12)
    IconCorner.Parent = IconBg
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "👤"
    IconLabel.TextColor3 = Color3.fromRGB(65, 105, 225)
    IconLabel.TextSize = 20
    IconLabel.Font = Enum.Font.Gotham
    IconLabel.Parent = IconBg
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -70, 0, 25)
    DropdownText.Position = UDim2.new(0, 65, 0.5, -12.5)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 15
    DropdownText.Font = Enum.Font.GothamBold
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownDesc = Instance.new("TextLabel")
    DropdownDesc.Size = UDim2.new(0.5, -70, 0, 20)
    DropdownDesc.Position = UDim2.new(0, 65, 0.5, 7)
    DropdownDesc.BackgroundTransparency = 1
    DropdownDesc.Text = "Click to select"
    DropdownDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    DropdownDesc.TextSize = 11
    DropdownDesc.Font = Enum.Font.Gotham
    DropdownDesc.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 140, 0, 40)
    DropdownBtn.Position = UDim2.new(1, -155, 0.5, -20)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    DropdownBtn.Text = items[1] or "Select"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 12
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 30)
    BtnCorner.Parent = DropdownBtn
    
    -- Dropdown menu
    DropdownBtn.MouseButton1Click:Connect(function()
        -- Hapus menu lama jika ada
        local oldMenu = DropdownFrame:FindFirstChild("DropdownMenu")
        if oldMenu then oldMenu:Destroy() end
        
        local menu = Instance.new("Frame")
        menu.Name = "DropdownMenu"
        menu.Size = UDim2.new(0, 180, 0, math.min(#items, 6) * 45)
        menu.Position = UDim2.new(1, -155, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 12)
        menuCorner.Parent = menu
        
        local menuList = Instance.new("ScrollingFrame")
        menuList.Size = UDim2.new(1, -2, 1, -2)
        menuList.Position = UDim2.new(0, 1, 0, 1)
        menuList.BackgroundTransparency = 1
        menuList.ScrollBarThickness = 4
        menuList.CanvasSize = UDim2.new(0, 0, 0, #items * 45)
        menuList.Parent = menu
        
        for i, item in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 45)
            itemBtn.Position = UDim2.new(0, 0, 0, (i-1) * 45)
            itemBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            itemBtn.Text = item
            itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemBtn.TextSize = 13
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.Parent = menuList
            
            itemBtn.MouseEnter:Connect(function()
                TweenService:Create(itemBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
            end)
            
            itemBtn.MouseLeave:Connect(function()
                TweenService:Create(itemBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
            end)
            
            itemBtn.MouseButton1Click:Connect(function()
                DropdownBtn.Text = item
                callback(item)
                menu:Destroy()
            end)
        end
    end)
    
    return DropdownFrame
end

function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 80)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    SliderFrame.BackgroundTransparency = 0.1
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 14)
    SliderCorner.Parent = SliderFrame
    
    -- Icon
    local IconBg = Instance.new("Frame")
    IconBg.Size = UDim2.new(0, 40, 0, 40)
    IconBg.Position = UDim2.new(0, 15, 0.5, -20)
    IconBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    IconBg.Parent = SliderFrame
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 12)
    IconCorner.Parent = IconBg
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "🎚️"
    IconLabel.TextColor3 = Color3.fromRGB(65, 105, 225)
    IconLabel.TextSize = 20
    IconLabel.Font = Enum.Font.Gotham
    IconLabel.Parent = IconBg
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.6, -70, 0, 25)
    SliderText.Position = UDim2.new(0, 65, 0.5, -12.5)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 15
    SliderText.Font = Enum.Font.GothamBold
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.2, -10, 0, 25)
    ValueLabel.Position = UDim2.new(0.8, -10, 0.5, -12.5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(65, 105, 225)
    ValueLabel.TextSize = 16
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = SliderFrame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -30, 0, 6)
    SliderBg.Position = UDim2.new(0, 15, 0, 60)
    SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    SliderFill.Parent = SliderBg
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Text = ""
    SliderButton.Parent = SliderFill
    
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(1, 0)
    SliderButtonCorner.Parent = SliderButton
    
    -- Drag functionality
    local dragging = false
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
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
            SliderButton.Position = UDim2.new(percent, -10, 0.5, -10)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
    end)
    
    return SliderFrame
end

function CreateLabel(parent, text, color, size, icon)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, size or 30)
    Label.BackgroundTransparency = 1
    Label.Text = (icon or "•") .. " " .. text
    Label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.Parent = parent
    
    return Label
end

--==================================================
-- UPDATE TAB CONTENT
--==================================================
function UpdateTabContent(tabName)
    -- Hapus semua konten lama
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Update header
    HeaderTitle.Text = tabName
    
    -- Update header icon berdasarkan tab
    local headerIcons = {
        DASHBOARD = "📊",
        VISUALS = "👁️",
        SURVIVOR = "🛡️",
        KILLER = "⚔️",
        TELEPORT = "🌀",
        FARM = "⚡",
        PLAYERS = "👥",
        MISC = "⚙️",
        SETTINGS = "🔧"
    }
    HeaderIconLabel.Text = headerIcons[tabName] or "📊"
    
    if tabName == "DASHBOARD" then
        CreateSection(ScrollingFrame, "SYSTEM STATUS")
        
        -- Status grid dengan 2 kolom
        local StatusGrid = Instance.new("Frame")
        StatusGrid.Size = UDim2.new(1, 0, 0, 250)
        StatusGrid.BackgroundTransparency = 1
        StatusGrid.Parent = ScrollingFrame
        
        local function CreateStatusCard(icon, title, value, color, x, y, width)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(width or 0.48, 0, 0, 110)
            card.Position = UDim2.new(x, 0, y, 0)
            card.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
            card.BackgroundTransparency = 0.1
            card.Parent = StatusGrid
            
            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 14)
            cardCorner.Parent = card
            
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(1, 0, 0, 45)
            iconLabel.Position = UDim2.new(0, 0, 0, 10)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = icon
            iconLabel.TextColor3 = color
            iconLabel.TextSize = 32
            iconLabel.Font = Enum.Font.Gotham
            iconLabel.Parent = card
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 20)
            titleLabel.Position = UDim2.new(0, 0, 0, 60)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            titleLabel.TextSize = 12
            titleLabel.Font = Enum.Font.Gotham
            titleLabel.Parent = card
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, 0, 0, 25)
            valueLabel.Position = UDim2.new(0, 0, 0, 80)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = value
            valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            valueLabel.TextSize = 18
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.Parent = card
        end
        
        CreateStatusCard("🎮", "GAME", "Violence District", Color3.fromRGB(65, 105, 225), 0, 0)
        CreateStatusCard("👤", "PLAYER", Player.Name, Color3.fromRGB(0, 200, 100), 0.52, 0)
        CreateStatusCard("📊", "PING", math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms", Color3.fromRGB(255, 165, 0), 0, 130)
        CreateStatusCard("👥", "PLAYERS", #Players:GetPlayers() .. " Online", Color3.fromRGB(100, 200, 255), 0.52, 130)
        
        CreateSection(ScrollingFrame, "QUICK ACTIONS")
        
        -- Quick actions grid
        local QuickGrid = Instance.new("Frame")
        QuickGrid.Size = UDim2.new(1, 0, 0, 180)
        QuickGrid.BackgroundTransparency = 1
        QuickGrid.Parent = ScrollingFrame
        
        local function CreateQuickBtn(icon, text, color, x, y, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.23, 0, 0, 80)
            btn.Position = UDim2.new(x, 0, y, 0)
            btn.BackgroundColor3 = color
            btn.Text = ""
            btn.Parent = QuickGrid
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 14)
            btnCorner.Parent = btn
            
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(1, 0, 0, 35)
            iconLabel.Position = UDim2.new(0, 0, 0, 10)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = icon
            iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            iconLabel.TextSize = 24
            iconLabel.Font = Enum.Font.Gotham
            iconLabel.Parent = btn
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 0, 20)
            textLabel.Position = UDim2.new(0, 0, 0, 50)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = text
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextSize = 11
            textLabel.Font = Enum.Font.GothamBold
            textLabel.Parent = btn
            
            btn.MouseButton1Click:Connect(callback)
        end
        
        CreateQuickBtn("🔄", "REFRESH", Color3.fromRGB(65, 105, 225), 0, 0, function()
            UpdateTabContent("DASHBOARD")
        end)
        
        CreateQuickBtn("🧹", "CLEAR ALL", Color3.fromRGB(220, 60, 60), 0.26, 0, function()
            StopAllLoops()
        end)
        
        CreateQuickBtn("⬇️", "MINIMIZE", Color3.fromRGB(147, 112, 219), 0.52, 0, function()
            if not Minimized then
                MinBtn.MouseButton1Click:Fire()
            end
        end)
        
        CreateQuickBtn("⬆️", "MAXIMIZE", Color3.fromRGB(0, 200, 100), 0.78, 0, function()
            if Minimized then
                MaxBtn.MouseButton1Click:Fire()
            end
        end)
        
        CreateQuickBtn("⚙️", "SETTINGS", Color3.fromRGB(100, 100, 100), 0, 100, function()
            UpdateTabContent("SETTINGS")
        end)
        
        CreateQuickBtn("👁️", "VISUALS", Color3.fromRGB(147, 112, 219), 0.26, 100, function()
            UpdateTabContent("VISUALS")
        end)
        
        CreateQuickBtn("🛡️", "SURVIVOR", Color3.fromRGB(0, 200, 100), 0.52, 100, function()
            UpdateTabContent("SURVIVOR")
        end)
        
        CreateQuickBtn("⚔️", "KILLER", Color3.fromRGB(220, 60, 60), 0.78, 100, function()
            UpdateTabContent("KILLER")
        end)
        
        CreateSection(ScrollingFrame, "SERVER INFORMATION")
        
        CreateLabel(ScrollingFrame, "Server ID: " .. game.JobId, nil, 25, "📍")
        CreateLabel(ScrollingFrame, "Time: " .. os.date("%H:%M:%S"), nil, 25, "🕒")
        CreateLabel(ScrollingFrame, "Date: " .. os.date("%d-%m-%Y"), nil, 25, "📅")
        CreateLabel(ScrollingFrame, "Uptime: " .. math.floor(workspace.DistributedGameTime/60) .. " minutes", nil, 25, "⚡")
        
    elseif tabName == "VISUALS" then
        CreateSection(ScrollingFrame, "ESP SETTINGS")
        
        CreateToggle(ScrollingFrame, "Survivor ESP", "Highlight survivors with blue", "👤", function(state)
            Toggles.SurvivorESP = state
            if state then
                EnableESP("Survivor", Color3.fromRGB(0, 100, 255))
            else
                DisableESP()
            end
        end)
        
        CreateToggle(ScrollingFrame, "Killer ESP", "Highlight killers with red", "🗡️", function(state)
            Toggles.KillerESP = state
            if state then
                EnableESP("Killer", Color3.fromRGB(255, 0, 0))
            else
                DisableESP()
            end
        end)
        
        CreateToggle(ScrollingFrame, "Generator ESP", "Highlight generators with green", "⚡", function(state)
            Toggles.GeneratorESP = state
            if state then
                EnableGeneratorESP()
            else
                DisableGeneratorESP()
            end
        end)
        
        CreateToggle(ScrollingFrame, "Chest ESP", "Highlight chests with gold", "📦", function(state)
            Toggles.ChestESP = state
        end)
        
        CreateToggle(ScrollingFrame, "ESP Tracers", "Draw lines to players", "📏", function(state)
            Toggles.ESPTracers = state
        end)
        
        CreateToggle(ScrollingFrame, "ESP Boxes", "Draw boxes around players", "🔲", function(state)
            Toggles.ESPBoxes = state
        end)
        
        CreateSection(ScrollingFrame, "VISUAL EFFECTS")
        
        CreateToggle(ScrollingFrame, "Unlimited Zoom", "Extend camera zoom distance", "🔍", function(state)
            Toggles.UnlimitedZoom = state
            if state then
                Camera.FieldOfView = 120
            else
                Camera.FieldOfView = 70
            end
        end)
        
        CreateToggle(ScrollingFrame, "Full Bright", "Maximum brightness", "☀️", function(state)
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
        
        CreateToggle(ScrollingFrame, "Wallhack", "See through walls", "🧱", function(state)
            Toggles.Wallhack = state
            UpdateWallhack()
        end)
        
        CreateToggle(ScrollingFrame, "X-Ray Vision", "See all objects", "🔬", function(state)
            Toggles.XRay = state
            UpdateWallhack()
        end)
        
        CreateToggle(ScrollingFrame, "Rainbow Mode", "Rainbow colors", "🌈", function(state)
            Toggles.RainbowMode = state
        end)
        
        CreateToggle(ScrollingFrame, "No Fog", "Remove fog", "🌫️", function(state)
            Toggles.NoFog = state
            if state then
                Lighting.FogEnd = 1e9
            else
                Lighting.FogEnd = 100000
            end
        end)
        
    elseif tabName == "SURVIVOR" then
        CreateSection(ScrollingFrame, "AUTO FARM")
        
        CreateToggle(ScrollingFrame, "Auto-Farm Present", "Automatically collect presents", "🎁", function(state)
            Toggles.AutoFarmPresent = state
            if state then StartLoop("AutoFarmPresent") end
        end)
        
        CreateToggle(ScrollingFrame, "Auto-Farm Gift", "Collect gifts and teleport to tree", "🎄", function(state)
            Toggles.AutoFarmGift = state
            if state then StartLoop("AutoFarmGift") end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Open Presents", "Automatically open presents", "📦", function(state)
            Toggles.AutoOpenPresents = state
        end)
        
        CreateToggle(ScrollingFrame, "Auto Collect Coins", "Collect coins automatically", "💰", function(state)
            Toggles.AutoCollectCoins = state
        end)
        
        CreateToggle(ScrollingFrame, "Auto Heal", "Auto heal when low health", "💊", function(state)
            Toggles.AutoHeal = state
        end)
        
        CreateSection(ScrollingFrame, "MOVEMENT")
        
        CreateToggle(ScrollingFrame, "Flicker Speed", "Fast movement with blink effect", "⚡", function(state)
            Toggles.FlickerSpeed = state
            if state then
                Humanoid.WalkSpeed = 100
            else
                Humanoid.WalkSpeed = 16
            end
        end)
        
        CreateSlider(ScrollingFrame, "Speed Boost", 16, 200, 16, function(value)
            if Toggles.SpeedBoost then
                Humanoid.WalkSpeed = value
            end
        end)
        
        CreateToggle(ScrollingFrame, "Jump Boost", "Higher jumps", "🦘", function(state)
            Toggles.JumpBoost = state
            if state then
                Humanoid.JumpPower = 100
            else
                Humanoid.JumpPower = 50
            end
        end)
        
        CreateToggle(ScrollingFrame, "Infinite Stamina", "Never run out of stamina", "💪", function(state)
            Toggles.InfiniteStamina = state
        end)
        
        CreateSection(ScrollingFrame, "BODY LOCK")
        
        CreateDropdown(ScrollingFrame, "Target Player", GetPlayerList(), function(playerName)
            SelectedTarget = Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh List", Color3.fromRGB(80, 80, 90), "🔄", function()
            UpdateTabContent("SURVIVOR")
        end)
        
        CreateToggle(ScrollingFrame, "Body Lock", "Follow selected player", "🔒", function(state)
            Toggles.BodyLock = state
            if state then StartLoop("BodyLock") end
        end)
        
    elseif tabName == "KILLER" then
        CreateSection(ScrollingFrame, "COMBAT")
        
        CreateToggle(ScrollingFrame, "Aimbot", "Auto aim at nearest player", "🎯", function(state)
            Toggles.Aimbot = state
            if state then StartLoop("Aimbot") end
        end)
        
        CreateToggle(ScrollingFrame, "Silent Aim", "Aim without moving camera", "🤫", function(state)
            Toggles.SilentAim = state
        end)
        
        CreateToggle(ScrollingFrame, "Kill Aura", "Auto kill nearby players", "💀", function(state)
            Toggles.KillAura = state
            if state then StartLoop("KillAura") end
        end)
        
        CreateSlider(ScrollingFrame, "Kill Aura Range", 5, 50, 20, function(value)
            _G.KillAuraRange = value
        end)
        
        CreateToggle(ScrollingFrame, "Auto Attack", "Automatically attack", "⚔️", function(state)
            Toggles.AutoAttack = state
            if state then StartLoop("AutoAttack") end
        end)
        
        CreateToggle(ScrollingFrame, "Instant Kill", "One hit kill", "💥", function(state)
            Toggles.InstantKill = state
        end)
        
        CreateSection(ScrollingFrame, "TARGET SELECTION")
        
        CreateDropdown(ScrollingFrame, "Target Player", GetPlayerList(), function(playerName)
            KillerTarget = Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh List", Color3.fromRGB(80, 80, 90), "🔄", function()
            UpdateTabContent("KILLER")
        end)
        
        CreateToggle(ScrollingFrame, "Auto Hunt", "Automatically hunt target", "🎯", function(state)
            Toggles.AutoHunt = state
        end)
        
    elseif tabName == "TELEPORT" then
        CreateSection(ScrollingFrame, "MOVEMENT")
        
        CreateToggle(ScrollingFrame, "NoClip", "Walk through walls", "🚪", function(state)
            Toggles.NoClip = state
            UpdateNoClip()
        end)
        
        CreateToggle(ScrollingFrame, "NoClip Through", "NoClip through everything", "🌀", function(state)
            Toggles.NoClipThrough = state
        end)
        
        CreateSection(ScrollingFrame, "TELEPORT TO PLAYER")
        
        CreateDropdown(ScrollingFrame, "Target Player", GetPlayerList(), function(playerName)
            TPTarget = Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "📌 Teleport to Target", Color3.fromRGB(65, 105, 225), "📌", function()
            if TPTarget and TPTarget.Character then
                RootPart.CFrame = TPTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        end)
        
        CreateToggle(ScrollingFrame, "Teleport to Mouse", "Teleport to mouse position (Right Click)", "🖱️", function(state)
            Toggles.TeleportToMouse = state
        end)
        
        CreateToggle(ScrollingFrame, "Teleport to Cursor", "Teleport to cursor position", "📍", function(state)
            Toggles.TeleportToCursor = state
        end)
        
        CreateButton(ScrollingFrame, "➕ Save Waypoint", Color3.fromRGB(0, 200, 100), "💾", function()
            table.insert(Waypoints, {Name = "Waypoint " .. #Waypoints+1, Position = RootPart.Position})
        end)
        
    elseif tabName == "FARM" then
        CreateSection(ScrollingFrame, "GENERATOR FARM")
        
        CreateToggle(ScrollingFrame, "Auto-Farm Generator", "Auto repair generators", "⚡", function(state)
            Toggles.AutoFarmGenerator = state
            if state then StartLoop("AutoFarmGenerator") end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Complete", "Auto complete generators", "✅", function(state)
            Toggles.AutoCompleteGenerator = state
            if state then StartLoop("AutoCompleteGenerator") end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Repair", "Auto repair when damaged", "🔧", function(state)
            Toggles.AutoRepair = state
        end)
        
        CreateToggle(ScrollingFrame, "Auto Collect Gens", "Auto collect from generators", "📦", function(state)
            Toggles.AutoCollectGens = state
        end)
        
        CreateButton(ScrollingFrame, "🔍 Find Nearest Generator", Color3.fromRGB(80, 80, 90), "🔍", function()
            local gen = FindNearestGenerator()
            if gen then
                RootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
            end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Farm All", "Farm all resources", "⚡", function(state)
            Toggles.AutoFarmAll = state
        end)
        
        CreateToggle(ScrollingFrame, "Auto Collect Loot", "Auto collect all loot", "💰", function(state)
            Toggles.AutoCollectLoot = state
        end)
        
    elseif tabName == "PLAYERS" then
        CreateSection(ScrollingFrame, "PLAYER LIST (" .. #Players:GetPlayers()-1 .. " others)")
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                local PlayerFrame = Instance.new("Frame")
                PlayerFrame.Size = UDim2.new(1, 0, 0, 70)
                PlayerFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
                PlayerFrame.BackgroundTransparency = 0.1
                PlayerFrame.Parent = ScrollingFrame
                
                local PlayerCorner = Instance.new("UICorner")
                PlayerCorner.CornerRadius = UDim.new(0, 14)
                PlayerCorner.Parent = PlayerFrame
                
                -- Avatar
                local Avatar = Instance.new("ImageLabel")
                Avatar.Size = UDim2.new(0, 50, 0, 50)
                Avatar.Position = UDim2.new(0, 15, 0.5, -25)
                Avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                Avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
                Avatar.Parent = PlayerFrame
                
                local AvatarCorner = Instance.new("UICorner")
                AvatarCorner.CornerRadius = UDim.new(0, 12)
                AvatarCorner.Parent = Avatar
                
                -- Player info
                local PlayerName = Instance.new("TextLabel")
                PlayerName.Size = UDim2.new(0.4, -80, 0, 25)
                PlayerName.Position = UDim2.new(0, 75, 0.5, -12.5)
                PlayerName.BackgroundTransparency = 1
                PlayerName.Text = player.Name
                PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                PlayerName.TextSize = 15
                PlayerName.TextXAlignment = Enum.TextXAlignment.Left
                PlayerName.Font = Enum.Font.GothamBold
                PlayerName.Parent = PlayerFrame
                
                -- Distance
                local distance = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and 
                    math.floor((player.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude) or "?"
                
                local DistanceLabel = Instance.new("TextLabel")
                DistanceLabel.Size = UDim2.new(0.2, -40, 0, 20)
                DistanceLabel.Position = UDim2.new(0.4, -40, 0.5, -10)
                DistanceLabel.BackgroundTransparency = 1
                DistanceLabel.Text = distance .. "m"
                DistanceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                DistanceLabel.TextSize = 12
                DistanceLabel.Font = Enum.Font.Gotham
                DistanceLabel.Parent = PlayerFrame
                
                -- Teleport button
                local TeleportBtn = Instance.new("TextButton")
                TeleportBtn.Size = UDim2.new(0, 40, 0, 40)
                TeleportBtn.Position = UDim2.new(1, -55, 0.5, -20)
                TeleportBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
                TeleportBtn.Text = "📌"
                TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                TeleportBtn.TextSize = 20
                TeleportBtn.Font = Enum.Font.Gotham
                TeleportBtn.Parent = PlayerFrame
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 12)
                BtnCorner.Parent = TeleportBtn
                
                TeleportBtn.MouseButton1Click:Connect(function()
                    if player.Character then
                        RootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    end
                end)
                
                -- ESP toggle button
                local ESPBtn = Instance.new("TextButton")
                ESPBtn.Size = UDim2.new(0, 40, 0, 40)
                ESPBtn.Position = UDim2.new(1, -100, 0.5, -20)
                ESPBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                ESPBtn.Text = "👁️"
                ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                ESPBtn.TextSize = 18
                ESPBtn.Font = Enum.Font.Gotham
                ESPBtn.Parent = PlayerFrame
                
                local ESPCorner = Instance.new("UICorner")
                ESPCorner.CornerRadius = UDim.new(0, 12)
                ESPCorner.Parent = ESPBtn
                
                local espEnabled = false
                ESPBtn.MouseButton1Click:Connect(function()
                    espEnabled = not espEnabled
                    if espEnabled then
                        ESPBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
                        AddESP(player, Color3.fromRGB(65, 105, 225))
                    else
                        ESPBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                        if player.Character then
                            local highlight = player.Character:FindFirstChild("ESP_Highlight")
                            if highlight then highlight:Destroy() end
                        end
                    end
                end)
            end
        end
        
    elseif tabName == "MISC" then
        CreateSection(ScrollingFrame, "UTILITY")
        
        CreateToggle(ScrollingFrame, "Anti AFK", "Prevent being kicked", "💤", function(state)
            Toggles.AntiAFK = state
            if state then
                Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Click", "Automatically click", "🖱️", function(state)
            Toggles.AutoClick = state
            if state then StartLoop("AutoClick") end
        end)
        
        CreateToggle(ScrollingFrame, "No Skill Check", "Remove all skill checks", "🎯", function(state)
            Toggles.NoSkillCheck = state
            ToggleSkillCheck(state)
        end)
        
        CreateToggle(ScrollingFrame, "Anti Stun", "Prevent stun effects", "⚡", function(state)
            Toggles.AntiStun = state
        end)
        
        CreateToggle(ScrollingFrame, "Anti Fall", "Prevent falling damage", "🛡️", function(state)
            Toggles.AntiFall = state
        end)
        
        CreateToggle(ScrollingFrame, "Anti Void", "Prevent falling into void", "🌌", function(state)
            Toggles.AntiVoid = state
        end)
        
        CreateToggle(ScrollingFrame, "Auto Respawn", "Auto respawn when dead", "🔄", function(state)
            Toggles.AutoRespawn = state
        end)
        
    elseif tabName == "SETTINGS" then
        CreateSection(ScrollingFrame, "SKILL CHECK")
        
        CreateToggle(ScrollingFrame, "No Skill Check", "Remove all skill checks", "🎯", function(state)
            Toggles.NoSkillCheck = state
            ToggleSkillCheck(state)
        end)
        
        CreateSection(ScrollingFrame, "GUI SETTINGS")
        
        CreateButton(ScrollingFrame, "🎨 Toggle GUI (F4)", Color3.fromRGB(65, 105, 225), "🔘", function()
            ScreenGui.Enabled = not ScreenGui.Enabled
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh UI", Color3.fromRGB(80, 80, 90), "🔄", function()
            UpdateTabContent(CurrentTab)
        end)
        
        CreateButton(ScrollingFrame, "⬇️ Minimize", Color3.fromRGB(100, 100, 100), "⬇️", function()
            if not Minimized then
                MinBtn.MouseButton1Click:Fire()
            end
        end)
        
        CreateButton(ScrollingFrame, "⬆️ Maximize", Color3.fromRGB(100, 100, 100), "⬆️", function()
            if Minimized then
                MaxBtn.MouseButton1Click:Fire()
            end
        end)
        
        CreateButton(ScrollingFrame, "❌ Close GUI", Color3.fromRGB(220, 60, 60), "❌", function()
            CloseBtn.MouseButton1Click:Fire()
        end)
        
        CreateSection(ScrollingFrame, "INFORMATION")
        
        CreateLabel(ScrollingFrame, "Keybind: F4 to toggle menu", Color3.fromRGB(150, 150, 150), 25, "⌨️")
        CreateLabel(ScrollingFrame, "Version: 6.0 Ultimate Deluxe", Color3.fromRGB(150, 150, 150), 25, "📌")
        CreateLabel(ScrollingFrame, "Author: LuckyBimZy", Color3.fromRGB(150, 150, 150), 25, "👤")
        CreateLabel(ScrollingFrame, "GitHub: Machadepanmu", Color3.fromRGB(150, 150, 150), 25, "🔗")
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

--==================================================
-- LOOP MANAGEMENT
--==================================================

function StartLoop(loopName)
    if Loops[loopName] then return end
    
    Loops[loopName] = true
    task.spawn(function()
        while Loops[loopName] do
            if loopName == "AutoFarmGenerator" then
                AutoFarmGenerator()
            elseif loopName == "AutoCompleteGenerator" then
                AutoCompleteGenerator()
            elseif loopName == "AutoFarmPresent" then
                AutoFarmPresent()
            elseif loopName == "AutoFarmGift" then
                AutoFarmGift()
            elseif loopName == "BodyLock" then
                BodyLock()
            elseif loopName == "Aimbot" then
                Aimbot()
            elseif loopName == "KillAura" then
                KillAura()
            elseif loopName == "AutoAttack" then
                AutoAttack()
            elseif loopName == "AutoClick" then
                AutoClick()
            end
            task.wait(0.1)
        end
    end)
end

function StopAllLoops()
    for name, _ in pairs(Loops) do
        Loops[name] = false
    end
    Loops = {}
end

--==================================================
-- CORE FUNCTIONS
--==================================================

-- Auto Farm Generator
function AutoFarmGenerator()
    local generator = FindNearestGenerator()
    if generator then
        RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
        
        local args = {[1] = "RepairGenerator", [2] = generator}
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or
                      game:GetService("ReplicatedStorage"):FindFirstChild("GeneratorEvent")
        
        if remote then
            pcall(function() remote:FireServer(unpack(args)) end)
        end
        
        local prompt = generator:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then fireproximityprompt(prompt) end
    end
end

-- Auto Complete Generator
function AutoCompleteGenerator()
    local generator = FindNearestGenerator()
    if generator then
        RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
        
        local args = {[1] = "CompleteGenerator", [2] = generator}
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
        
        if remote then
            pcall(function() remote:FireServer(unpack(args)) end)
        end
    end
end

-- Auto Farm Present
function AutoFarmPresent()
    local present = FindNearestPresent()
    if present then
        RootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
        local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then fireproximityprompt(prompt) end
    end
end

-- Auto Farm Gift
function AutoFarmGift()
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

-- Body Lock
function BodyLock()
    if SelectedTarget and SelectedTarget.Character then
        local targetPos = SelectedTarget.Character.HumanoidRootPart.Position
        RootPart.CFrame = CFrame.new(targetPos.x, targetPos.y + 3, targetPos.z)
    end
end

-- Aimbot
function Aimbot()
    local target = FindNearestPlayer()
    if target and target.Character then
        local targetPos = target.Character.HumanoidRootPart.Position
        RootPart.CFrame = CFrame.lookAt(RootPart.Position, targetPos)
    end
end

-- Kill Aura
function KillAura()
    local range = _G.KillAuraRange or 20
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local dist = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist <= range then
                player.Character.Humanoid.Health = 0
            end
        end
    end
end

-- Auto Attack
function AutoAttack()
    local target = FindNearestPlayer()
    if target and target.Character then
        local tool = Player.Character:FindFirstChildWhichIsA("Tool")
        if tool then tool:Activate() end
    end
end

-- Auto Click
function AutoClick()
    mouse1click()
end

-- ESP Functions
function EnableESP(type, color)
    DisableESP()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            AddESP(player, color)
        end
    end
end

function AddESP(player, color)
    if not player.Character then return end
    
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
    
    -- Update distance
    task.spawn(function()
        while billboard and billboard.Parent do
            task.wait(0.5)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((player.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude)
                nameLabel.Text = player.Name .. " [" .. dist .. "m]"
            end
        end
    end)
end

function DisableESP()
    for _, player in pairs(Players:GetPlayers()) do
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
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") then
            local highlight = Instance.new("Highlight")
            highlight.Parent = v
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.FillTransparency = 0.3
        end
    end
end

function DisableGeneratorESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Parent and v.Parent.Name == "Generator" then
            v:Destroy()
        end
    end
end

-- Wallhack
function UpdateWallhack()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if Toggles.Wallhack or Toggles.XRay then
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

-- NoClip
function UpdateNoClip()
    if Toggles.NoClip then
        RunService:BindToRenderStep("NoClip", 0, function()
            if Toggles.NoClip and Character then
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

-- Teleport to Mouse
UserInputService.InputBegan:Connect(function(input)
    if Toggles.TeleportToMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local mouse = Player:GetMouse()
        local targetPos = mouse.Hit.p
        RootPart.CFrame = CFrame.new(targetPos.x, targetPos.y + 3, targetPos.z)
    end
end)

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
    
    for _, v in pairs(Workspace:GetDescendants()) do
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
    
    for _, v in pairs(Workspace:GetDescendants()) do
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
    
    for _, v in pairs(Workspace:GetDescendants()) do
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
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "ChristmasTree" or v.Name == "Tree" then
            return v
        end
    end
    return nil
end

function FindNearestPlayer()
    local nearest = nil
    local distance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
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

function GetPlayerList()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
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

-- Keybind untuk toggle menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == MenuKeybind then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

--==================================================
-- INITIALIZE
--==================================================

-- Tampilkan tab pertama
UpdateTabContent("DASHBOARD")

print("========================================")
print("✅ VIOLENCE DISTRICT ULTIMATE DELUXE LOADED!")
print("📁 GitHub: LuckyBimZy/Machadepanmu")
print("🕒 " .. os.date("%Y-%m-%d %H:%M:%S"))
print("========================================")

return true