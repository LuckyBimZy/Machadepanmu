-- ==================== GAMES/VIOLENCE.LUA ====================
-- Script Premium Violence District dengan UI Ultra Modern
-- Author: LuckyBimZy
-- Version: 5.0 (Ultimate Pro)

if _G.ViolenceLoaded then 
    print("⚠️ Script sudah diload, melewati...")
    return 
end

_G.ViolenceLoaded = true

print("🔰 Memuat Violence District Script Ultimate Pro...")
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

-- Toggle variables
local Toggles = {
    -- Visuals
    SurvivorESP = false,
    KillerESP = false,
    GeneratorESP = false,
    ItemESP = false,
    UnlimitedZoom = false,
    FullBright = false,
    Wallhack = false,
    XRay = false,
    RainbowMode = false,
    NoFog = false,
    
    -- Survivor
    AutoFarmPresent = false,
    AutoFarmGift = false,
    FlickerSpeed = false,
    SpeedBoost = false,
    JumpBoost = false,
    BodyLock = false,
    AutoOpenPresents = false,
    AutoCollectCoins = false,
    AutoHeal = false,
    
    -- Killer
    Aimbot = false,
    KillAura = false,
    AutoAttack = false,
    SilentAim = false,
    WallhackKiller = false,
    InstantKill = false,
    
    -- Teleport
    NoClip = false,
    TeleportToTarget = false,
    TeleportToMouse = false,
    TeleportToCursor = false,
    
    -- Farm
    AutoFarmGenerator = false,
    AutoCompleteGenerator = false,
    AutoRepair = false,
    AutoFarmAll = false,
    AutoCollectGens = false,
    
    -- Misc
    AntiAFK = false,
    AutoClick = false,
    NoSkillCheck = false,
    InfiniteStamina = false,
    AntiStun = false,
    AntiFall = false,
    AntiVoid = false,
    NoClipThrough = false
}

-- Target variables
local SelectedTarget = nil
local TPTarget = nil
local KillerTarget = nil
local GUIHidden = false
local MenuKeybind = Enum.KeyCode.F4
local GUIEnabled = true
local Minimized = false
local MinimizedSize = {Width = 300, Height = 50}
local NormalSize = {Width = 900, Height = 650}

-- Loop connections
local Loops = {}
local ESPConnections = {}
local UIScale = 1

--==================================================
-- CREATE UI ULTRA MODERN
--==================================================

-- Hapus GUI lama jika ada
local oldGUI = game.CoreGui:FindFirstChild("ViolenceUltimatePro")
if oldGUI then oldGUI:Destroy() end

-- Buat ScreenGui utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceUltimatePro"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

-- Frame utama dengan efek glass morphism yang lebih baik
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, NormalSize.Width, 0, NormalSize.Height)
MainFrame.Position = UDim2.new(0.5, -NormalSize.Width/2, 0.5, -NormalSize.Height/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Efek glass morphism yang lebih baik
local GlassEffect = Instance.new("ImageLabel")
GlassEffect.Size = UDim2.new(1, 0, 1, 0)
GlassEffect.BackgroundTransparency = 1
GlassEffect.Image = "rbxassetid://13110653408"
GlassEffect.ImageColor3 = Color3.fromRGB(65, 105, 225)
GlassEffect.ImageTransparency = 0.85
GlassEffect.ScaleType = Enum.ScaleType.Slice
GlassEffect.SliceCenter = Rect.new(10, 10, 10, 10)
GlassEffect.Parent = MainFrame

-- Shadow yang lebih dalam
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(50, 50, 50, 50)
Shadow.Parent = MainFrame

-- Rounded corners yang lebih halus
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- Border gradient yang lebih keren
local BorderGradient = Instance.new("UIGradient")
BorderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 105, 225)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(147, 112, 219)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 105, 225))
})
BorderGradient.Rotation = 45
BorderGradient.Parent = MainFrame

-- Efek glow di pinggir
local GlowFrame = Instance.new("Frame")
GlowFrame.Size = UDim2.new(1, 4, 1, 4)
GlowFrame.Position = UDim2.new(0, -2, 0, -2)
GlowFrame.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
GlowFrame.BackgroundTransparency = 0.9
GlowFrame.BorderSizePixel = 0
GlowFrame.Parent = MainFrame

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 22)
GlowCorner.Parent = GlowFrame

--==================================================
-- TITLE BAR SUPER MODERN
--==================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = TitleBar

-- Garis bawah title bar
local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, -40, 0, 2)
TitleLine.Position = UDim2.new(0, 20, 1, -2)
TitleLine.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
TitleLine.BorderSizePixel = 0
TitleLine.Parent = TitleBar

-- Logo dengan efek glow
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 40, 0, 40)
LogoContainer.Position = UDim2.new(0, 15, 0.5, -20)
LogoContainer.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
LogoContainer.BackgroundTransparency = 0.3
LogoContainer.Parent = TitleBar

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 10)
LogoCorner.Parent = LogoContainer

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(1, -4, 1, -4)
Logo.Position = UDim2.new(0, 2, 0, 2)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://4483345998"
Logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
Logo.Parent = LogoContainer

-- Title dengan efek gradient
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 0, 30)
Title.Position = UDim2.new(0, 65, 0.5, -15)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
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
Version.Size = UDim2.new(0, 100, 0, 20)
Version.Position = UDim2.new(0, 65, 0.5, 8)
Version.BackgroundTransparency = 1
Version.Text = "ULTIMATE PRO v5.0"
Version.TextColor3 = Color3.fromRGB(65, 105, 225)
Version.TextSize = 11
Version.Font = Enum.Font.Gotham
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = TitleBar

-- Window controls yang lebih modern
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 120, 0, 40)
ControlFrame.Position = UDim2.new(1, -130, 0.5, -20)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(0, 0, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 24
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = ControlFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 12)
MinCorner.Parent = MinBtn

MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
end)
MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
end)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = true
    -- Animasi minimize
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, MinimizedSize.Width, 0, MinimizedSize.Height),
        Position = UDim2.new(0.5, -MinimizedSize.Width/2, 0, 20)
    }):Play()
    
    task.wait(0.15)
    for _, v in pairs(MainFrame:GetChildren()) do
        if v ~= TitleBar and v ~= Shadow and v ~= GlassEffect and v ~= GlowFrame then
            v.Visible = false
        end
    end
    MaxBtn.Visible = true
    MinBtn.Visible = false
end)

-- Maximize button
local MaxBtn = Instance.new("TextButton")
MaxBtn.Size = UDim2.new(0, 40, 0, 40)
MaxBtn.Position = UDim2.new(0, 0, 0, 0)
MaxBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MaxBtn.Text = "□"
MaxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MaxBtn.TextSize = 24
MaxBtn.Font = Enum.Font.GothamBold
MaxBtn.Visible = false
MaxBtn.Parent = ControlFrame

local MaxCorner = Instance.new("UICorner")
MaxCorner.CornerRadius = UDim.new(0, 12)
MaxCorner.Parent = MaxBtn

MaxBtn.MouseEnter:Connect(function()
    TweenService:Create(MaxBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
end)
MaxBtn.MouseLeave:Connect(function()
    TweenService:Create(MaxBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
end)

MaxBtn.MouseButton1Click:Connect(function()
    Minimized = false
    -- Animasi maximize
    for _, v in pairs(MainFrame:GetChildren()) do
        v.Visible = true
    end
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, NormalSize.Width, 0, NormalSize.Height),
        Position = UDim2.new(0.5, -NormalSize.Width/2, 0.5, -NormalSize.Height/2)
    }):Play()
    
    MaxBtn.Visible = false
    MinBtn.Visible = true
end)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(0, 45, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 28
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = ControlFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Animasi close
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- Settings button
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0, 40, 0, 40)
SettingsBtn.Position = UDim2.new(0, 90, 0, 0)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsBtn.TextSize = 20
SettingsBtn.Font = Enum.Font.Gotham
SettingsBtn.Parent = ControlFrame

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 12)
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

--==================================================
-- SIDE BAR SUPER MODERN
--==================================================
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 200, 1, -70)
SideBar.Position = UDim2.new(0, 0, 0, 65)
SideBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
SideBar.BackgroundTransparency = 0.1
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 15)
SideCorner.Parent = SideBar

local SideGradient = Instance.new("UIGradient")
SideGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12))
})
SideGradient.Rotation = 180
SideGradient.Parent = SideBar

-- Side bar title
local SideTitle = Instance.new("TextLabel")
SideTitle.Size = UDim2.new(1, -20, 0, 40)
SideTitle.Position = UDim2.new(0, 15, 0, 15)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "NAVIGATION"
SideTitle.TextColor3 = Color3.fromRGB(65, 105, 225)
SideTitle.TextSize = 14
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextXAlignment = Enum.TextXAlignment.Left
SideTitle.Parent = SideBar

-- Separator line
local SideLine = Instance.new("Frame")
SideLine.Size = UDim2.new(1, -30, 0, 2)
SideLine.Position = UDim2.new(0, 15, 0, 55)
SideLine.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
SideLine.BackgroundTransparency = 0.5
SideLine.BorderSizePixel = 0
SideLine.Parent = SideBar

local TabList = {
    {name = "DASHBOARD", icon = "🏠", color = Color3.fromRGB(65, 105, 225)},
    {name = "VISUALS", icon = "👁️", color = Color3.fromRGB(147, 112, 219)},
    {name = "SURVIVOR", icon = "🛡️", color = Color3.fromRGB(0, 200, 100)},
    {name = "KILLER", icon = "⚔️", color = Color3.fromRGB(220, 60, 60)},
    {name = "TELEPORT", icon = "🌀", color = Color3.fromRGB(255, 165, 0)},
    {name = "FARM", icon = "⚡", color = Color3.fromRGB(255, 215, 0)},
    {name = "PLAYERS", icon = "👥", color = Color3.fromRGB(100, 200, 255)},
    {name = "MISC", icon = "⚙️", color = Color3.fromRGB(150, 150, 150)},
    {name = "SETTINGS", icon = "🔧", color = Color3.fromRGB(180, 180, 180)}
}

local TabButtons = {}
local CurrentTab = "DASHBOARD"

-- Buat tab buttons di side bar dengan desain modern
for i, tabData in ipairs(TabList) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabData.name .. "Btn"
    TabBtn.Size = UDim2.new(1, -20, 0, 50)
    TabBtn.Position = UDim2.new(0, 10, 0, 70 + (i-1) * 55)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TabBtn.BackgroundTransparency = 0.3
    TabBtn.Text = ""
    TabBtn.Parent = SideBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = TabBtn
    
    -- Icon
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 40, 1, 0)
    Icon.Position = UDim2.new(0, 5, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = tabData.icon
    Icon.TextColor3 = tabData.color
    Icon.TextSize = 22
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = TabBtn
    
    -- Text
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -50, 1, 0)
    Text.Position = UDim2.new(0, 45, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = tabData.name
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.TextSize = 13
    Text.Font = Enum.Font.GothamBold
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = TabBtn
    
    -- Indicator (untuk tab aktif)
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 1, -10)
    Indicator.Position = UDim2.new(1, -3, 0.5, -20)
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
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
            Text.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= tabData.name then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 28)}):Play()
            Text.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tabData.name
        -- Update semua button
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
            btn:FindFirstChild("TextLabel").TextColor3 = Color3.fromRGB(200, 200, 200)
            btn:FindFirstChild("Indicator").Visible = false
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        Text.TextColor3 = tabData.color
        Indicator.Visible = true
        
        -- Update content dengan animasi
        UpdateTabContent(tabData.name)
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Set tab pertama aktif
TabButtons[1].BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabButtons[1]:FindFirstChild("TextLabel").TextColor3 = TabList[1].color
TabButtons[1]:FindFirstChild("Indicator").Visible = true

--==================================================
-- CONTENT AREA SUPER MODERN
--==================================================
local ContentBg = Instance.new("Frame")
ContentBg.Size = UDim2.new(1, -220, 1, -80)
ContentBg.Position = UDim2.new(0, 210, 0, 70)
ContentBg.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
ContentBg.BackgroundTransparency = 0.1
ContentBg.BorderSizePixel = 0
ContentBg.ClipsDescendants = true
ContentBg.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 18)
ContentCorner.Parent = ContentBg

-- Content header
local ContentHeader = Instance.new("Frame")
ContentHeader.Size = UDim2.new(1, -20, 0, 50)
ContentHeader.Position = UDim2.new(0, 10, 0, 10)
ContentHeader.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentHeader.BackgroundTransparency = 0.2
ContentHeader.Parent = ContentBg

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = ContentHeader

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0.5, -15, 1, 0)
HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "DASHBOARD"
HeaderTitle.TextColor3 = Color3.fromRGB(65, 105, 225)
HeaderTitle.TextSize = 18
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = ContentHeader

local HeaderTime = Instance.new("TextLabel")
HeaderTime.Size = UDim2.new(0.5, -15, 1, 0)
HeaderTime.Position = UDim2.new(0.5, 5, 0, 0)
HeaderTime.BackgroundTransparency = 1
HeaderTime.Text = os.date("%H:%M:%S")
HeaderTime.TextColor3 = Color3.fromRGB(150, 150, 150)
HeaderTime.TextSize = 14
HeaderTime.Font = Enum.Font.Gotham
HeaderTime.TextXAlignment = Enum.TextXAlignment.Right
HeaderTime.Parent = ContentHeader

-- Update time setiap detik
task.spawn(function()
    while ContentHeader do
        task.wait(1)
        HeaderTime.Text = os.date("%H:%M:%S")
    end
end)

-- Scrolling frame untuk konten
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -80)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 70)
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
-- FUNCTION UNTUK MEMBUAT ELEMEN UI MODERN
--==================================================

function CreateSection(parent, title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 40)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    SectionFrame.BackgroundTransparency = 0.2
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 10)
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

function CreateToggle(parent, text, desc, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 65)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    ToggleFrame.BackgroundTransparency = 0.2
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleFrame
    
    -- Icon background
    local IconBg = Instance.new("Frame")
    IconBg.Size = UDim2.new(0, 35, 0, 35)
    IconBg.Position = UDim2.new(0, 12, 0.5, -17.5)
    IconBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    IconBg.Parent = ToggleFrame
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8)
    IconCorner.Parent = IconBg
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "⚡"
    Icon.TextColor3 = Color3.fromRGB(65, 105, 225)
    Icon.TextSize = 18
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = IconBg
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.6, -55, 0, 25)
    ToggleText.Position = UDim2.new(0, 55, 0, 10)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 15
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleDesc = Instance.new("TextLabel")
    ToggleDesc.Size = UDim2.new(0.6, -55, 0, 20)
    ToggleDesc.Position = UDim2.new(0, 55, 0, 33)
    ToggleDesc.BackgroundTransparency = 1
    ToggleDesc.Text = desc or ""
    ToggleDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    ToggleDesc.TextSize = 11
    ToggleDesc.Font = Enum.Font.Gotham
    ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
    ToggleDesc.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 70, 0, 35)
    ToggleBtn.Position = UDim2.new(1, -85, 0.5, -17.5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 25)
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
            Icon.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 60),
                TextColor3 = Color3.fromRGB(255, 100, 100)
            }):Play()
            ToggleBtn.Text = "OFF"
            Icon.TextColor3 = Color3.fromRGB(65, 105, 225)
        end
        callback(enabled)
    end)
    
    return ToggleFrame
end

function CreateButton(parent, text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.BackgroundColor3 = color or Color3.fromRGB(65, 105, 225)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = parent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Button
    
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
    DropdownFrame.Size = UDim2.new(1, 0, 0, 65)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    DropdownFrame.BackgroundTransparency = 0.2
    DropdownFrame.Parent = parent
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 12)
    DropdownCorner.Parent = DropdownFrame
    
    local IconBg = Instance.new("Frame")
    IconBg.Size = UDim2.new(0, 35, 0, 35)
    IconBg.Position = UDim2.new(0, 12, 0.5, -17.5)
    IconBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    IconBg.Parent = DropdownFrame
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8)
    IconCorner.Parent = IconBg
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "👤"
    Icon.TextColor3 = Color3.fromRGB(65, 105, 225)
    Icon.TextSize = 18
    Icon.Font = Enum.Font.Gotham
    Icon.Parent = IconBg
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -55, 0, 25)
    DropdownText.Position = UDim2.new(0, 55, 0, 10)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 15
    DropdownText.Font = Enum.Font.GothamBold
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownDesc = Instance.new("TextLabel")
    DropdownDesc.Size = UDim2.new(0.5, -55, 0, 20)
    DropdownDesc.Position = UDim2.new(0, 55, 0, 33)
    DropdownDesc.BackgroundTransparency = 1
    DropdownDesc.Text = "Click to select"
    DropdownDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    DropdownDesc.TextSize = 11
    DropdownDesc.Font = Enum.Font.Gotham
    DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
    DropdownDesc.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 120, 0, 40)
    DropdownBtn.Position = UDim2.new(1, -135, 0.5, -20)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    DropdownBtn.Text = items[1] or "Select"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 12
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 25)
    BtnCorner.Parent = DropdownBtn
    
    -- Dropdown menu dengan animasi
    DropdownBtn.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame")
        menu.Size = UDim2.new(0, 150, 0, math.min(#items, 6) * 40)
        menu.Position = UDim2.new(1, -135, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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
        menuList.CanvasSize = UDim2.new(0, 0, 0, #items * 40)
        menuList.Parent = menu
        
        for i, item in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 40)
            itemBtn.Position = UDim2.new(0, 0, 0, (i-1) * 40)
            itemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            itemBtn.Text = item
            itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemBtn.TextSize = 12
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.Parent = menuList
            
            itemBtn.MouseEnter:Connect(function()
                itemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            end)
            
            itemBtn.MouseLeave:Connect(function()
                itemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
    SliderFrame.Size = UDim2.new(1, 0, 0, 75)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    SliderFrame.BackgroundTransparency = 0.2
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 12)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.7, -20, 0, 25)
    SliderText.Position = UDim2.new(0, 15, 0, 10)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 15
    SliderText.Font = Enum.Font.GothamBold
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.2, -10, 0, 25)
    ValueLabel.Position = UDim2.new(0.8, -10, 0, 10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(65, 105, 225)
    ValueLabel.TextSize = 16
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = SliderFrame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -30, 0, 8)
    SliderBg.Position = UDim2.new(0, 15, 0, 45)
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

function CreateLabel(parent, text, color, size)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, size or 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
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
    
    if tabName == "DASHBOARD" then
        CreateSection(ScrollingFrame, "SYSTEM STATUS")
        
        local StatusGrid = Instance.new("Frame")
        StatusGrid.Size = UDim2.new(1, 0, 0, 120)
        StatusGrid.BackgroundTransparency = 1
        StatusGrid.Parent = ScrollingFrame
        
        local function CreateStatusCard(icon, title, value, color, x, y)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0.48, 0, 0, 110)
            card.Position = UDim2.new(x, 0, y, 0)
            card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            card.BackgroundTransparency = 0.2
            card.Parent = StatusGrid
            
            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 12)
            cardCorner.Parent = card
            
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(1, 0, 0, 40)
            iconLabel.Position = UDim2.new(0, 0, 0, 10)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = icon
            iconLabel.TextColor3 = color
            iconLabel.TextSize = 30
            iconLabel.Font = Enum.Font.Gotham
            iconLabel.Parent = card
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 20)
            titleLabel.Position = UDim2.new(0, 0, 0, 55)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            titleLabel.TextSize = 12
            titleLabel.Font = Enum.Font.Gotham
            titleLabel.Parent = card
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, 0, 0, 25)
            valueLabel.Position = UDim2.new(0, 0, 0, 75)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = value
            valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            valueLabel.TextSize = 18
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.Parent = card
        end
        
        CreateStatusCard("🎮", "GAME", "Violence District", Color3.fromRGB(65, 105, 225), 0, 0)
        CreateStatusCard("👤", "PLAYER", Player.Name, Color3.fromRGB(0, 200, 100), 0.52, 0)
        CreateStatusCard("📊", "PING", math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms", Color3.fromRGB(255, 165, 0), 0, 120)
        CreateStatusCard("👥", "PLAYERS", #Players:GetPlayers() .. " Online", Color3.fromRGB(100, 200, 255), 0.52, 120)
        
        CreateSection(ScrollingFrame, "QUICK ACTIONS")
        
        local QuickGrid = Instance.new("Frame")
        QuickGrid.Size = UDim2.new(1, 0, 0, 110)
        QuickGrid.BackgroundTransparency = 1
        QuickGrid.Parent = ScrollingFrame
        
        local function CreateQuickBtn(icon, text, color, x, y, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.23, 0, 0, 100)
            btn.Position = UDim2.new(x, 0, y, 0)
            btn.BackgroundColor3 = color
            btn.Text = ""
            btn.Parent = QuickGrid
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 12)
            btnCorner.Parent = btn
            
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(1, 0, 0, 40)
            iconLabel.Position = UDim2.new(0, 0, 0, 15)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = icon
            iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            iconLabel.TextSize = 24
            iconLabel.Font = Enum.Font.Gotham
            iconLabel.Parent = btn
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 0, 20)
            textLabel.Position = UDim2.new(0, 0, 0, 60)
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
        
        CreateQuickBtn("🧹", "CLEAR", Color3.fromRGB(220, 60, 60), 0.26, 0, function()
            StopAllLoops()
        end)
        
        CreateQuickBtn("🎨", "THEME", Color3.fromRGB(147, 112, 219), 0.52, 0, function()
            -- Theme changer
        end)
        
        CreateQuickBtn("🔧", "RESET", Color3.fromRGB(255, 165, 0), 0.78, 0, function()
            -- Reset settings
        end)
        
        CreateSection(ScrollingFrame, "SERVER INFORMATION")
        
        CreateLabel(ScrollingFrame, "📍 Server ID: " .. game.JobId, nil, 25)
        CreateLabel(ScrollingFrame, "🕒 Server Time: " .. os.date("%H:%M:%S"), nil, 25)
        CreateLabel(ScrollingFrame, "📅 Date: " .. os.date("%d-%m-%Y"), nil, 25)
        CreateLabel(ScrollingFrame, "⚡ Uptime: " .. math.floor(workspace.DistributedGameTime/60) .. " minutes", nil, 25)
        
    elseif tabName == "VISUALS" then
        CreateSection(ScrollingFrame, "ESP SETTINGS")
        
        CreateToggle(ScrollingFrame, "Survivor ESP", "Highlight survivors with blue color", function(state)
            Toggles.SurvivorESP = state
            if state then
                EnableESP("Survivor", Color3.fromRGB(0, 100, 255))
            else
                DisableESP()
            end
        end)
        
        CreateToggle(ScrollingFrame, "Killer ESP", "Highlight killers with red color", function(state)
            Toggles.KillerESP = state
            if state then
                EnableESP("Killer", Color3.fromRGB(255, 0, 0))
            else
                DisableESP()
            end
        end)
        
        CreateToggle(ScrollingFrame, "Generator ESP", "Highlight generators with green", function(state)
            Toggles.GeneratorESP = state
            if state then
                EnableGeneratorESP()
            else
                DisableGeneratorESP()
            end
        end)
        
        CreateToggle(ScrollingFrame, "Item ESP", "Highlight items with yellow", function(state)
            Toggles.ItemESP = state
            -- Implement item ESP
        end)
        
        CreateSection(ScrollingFrame, "VISUAL EFFECTS")
        
        CreateToggle(ScrollingFrame, "Unlimited Zoom", "Extend camera zoom distance", function(state)
            Toggles.UnlimitedZoom = state
            if state then
                Camera.FieldOfView = 120
            else
                Camera.FieldOfView = 70
            end
        end)
        
        CreateToggle(ScrollingFrame, "Full Bright", "Maximum brightness", function(state)
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
        
        CreateToggle(ScrollingFrame, "Wallhack", "See through walls", function(state)
            Toggles.Wallhack = state
            UpdateWallhack()
        end)
        
        CreateToggle(ScrollingFrame, "X-Ray Vision", "See all objects", function(state)
            Toggles.XRay = state
            UpdateWallhack()
        end)
        
        CreateToggle(ScrollingFrame, "Rainbow Mode", "Rainbow colors", function(state)
            Toggles.RainbowMode = state
        end)
        
        CreateToggle(ScrollingFrame, "No Fog", "Remove fog", function(state)
            Toggles.NoFog = state
            if state then
                Lighting.FogEnd = 1e9
            else
                Lighting.FogEnd = 100000
            end
        end)
        
    elseif tabName == "SURVIVOR" then
        CreateSection(ScrollingFrame, "AUTO FARM")
        
        CreateToggle(ScrollingFrame, "Auto-Farm Present", "Automatically collect presents", function(state)
            Toggles.AutoFarmPresent = state
            if state then StartLoop("AutoFarmPresent") end
        end)
        
        CreateToggle(ScrollingFrame, "Auto-Farm Gift", "Collect gifts and teleport to tree", function(state)
            Toggles.AutoFarmGift = state
            if state then StartLoop("AutoFarmGift") end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Open Presents", "Automatically open presents", function(state)
            Toggles.AutoOpenPresents = state
        end)
        
        CreateToggle(ScrollingFrame, "Auto Collect Coins", "Collect coins automatically", function(state)
            Toggles.AutoCollectCoins = state
        end)
        
        CreateToggle(ScrollingFrame, "Auto Heal", "Auto heal when low health", function(state)
            Toggles.AutoHeal = state
        end)
        
        CreateSection(ScrollingFrame, "MOVEMENT")
        
        CreateToggle(ScrollingFrame, "Flicker Speed", "Fast movement with blink effect", function(state)
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
        
        CreateToggle(ScrollingFrame, "Jump Boost", "Higher jumps", function(state)
            Toggles.JumpBoost = state
            if state then
                Humanoid.JumpPower = 100
            else
                Humanoid.JumpPower = 50
            end
        end)
        
        CreateToggle(ScrollingFrame, "Infinite Stamina", "Never run out of stamina", function(state)
            Toggles.InfiniteStamina = state
        end)
        
        CreateSection(ScrollingFrame, "BODY LOCK")
        
        CreateDropdown(ScrollingFrame, "Target Player", GetPlayerList(), function(playerName)
            SelectedTarget = Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh List", Color3.fromRGB(80, 80, 90), function()
            UpdateTabContent("SURVIVOR")
        end)
        
        CreateToggle(ScrollingFrame, "Body Lock", "Follow selected player", function(state)
            Toggles.BodyLock = state
            if state then StartLoop("BodyLock") end
        end)
        
    elseif tabName == "KILLER" then
        CreateSection(ScrollingFrame, "COMBAT")
        
        CreateToggle(ScrollingFrame, "Aimbot", "Auto aim at nearest player", function(state)
            Toggles.Aimbot = state
            if state then StartLoop("Aimbot") end
        end)
        
        CreateToggle(ScrollingFrame, "Silent Aim", "Aim without moving camera", function(state)
            Toggles.SilentAim = state
        end)
        
        CreateToggle(ScrollingFrame, "Kill Aura", "Auto kill nearby players", function(state)
            Toggles.KillAura = state
            if state then StartLoop("KillAura") end
        end)
        
        CreateSlider(ScrollingFrame, "Kill Aura Range", 5, 50, 20, function(value)
            _G.KillAuraRange = value
        end)
        
        CreateToggle(ScrollingFrame, "Auto Attack", "Automatically attack", function(state)
            Toggles.AutoAttack = state
            if state then StartLoop("AutoAttack") end
        end)
        
        CreateToggle(ScrollingFrame, "Instant Kill", "One hit kill", function(state)
            Toggles.InstantKill = state
        end)
        
        CreateSection(ScrollingFrame, "TARGET SELECTION")
        
        CreateDropdown(ScrollingFrame, "Target Player", GetPlayerList(), function(playerName)
            KillerTarget = Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh List", Color3.fromRGB(80, 80, 90), function()
            UpdateTabContent("KILLER")
        end)
        
    elseif tabName == "TELEPORT" then
        CreateSection(ScrollingFrame, "MOVEMENT")
        
        CreateToggle(ScrollingFrame, "NoClip", "Walk through walls", function(state)
            Toggles.NoClip = state
            UpdateNoClip()
        end)
        
        CreateToggle(ScrollingFrame, "NoClip Through", "NoClip through everything", function(state)
            Toggles.NoClipThrough = state
        end)
        
        CreateSection(ScrollingFrame, "TELEPORT TO PLAYER")
        
        CreateDropdown(ScrollingFrame, "Target Player", GetPlayerList(), function(playerName)
            TPTarget = Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "📌 Teleport to Target", Color3.fromRGB(65, 105, 225), function()
            if TPTarget and TPTarget.Character then
                RootPart.CFrame = TPTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        end)
        
        CreateToggle(ScrollingFrame, "Teleport to Mouse", "Teleport to mouse position (Right Click)", function(state)
            Toggles.TeleportToMouse = state
        end)
        
        CreateToggle(ScrollingFrame, "Teleport to Cursor", "Teleport to cursor position", function(state)
            Toggles.TeleportToCursor = state
        end)
        
    elseif tabName == "FARM" then
        CreateSection(ScrollingFrame, "GENERATOR FARM")
        
        CreateToggle(ScrollingFrame, "Auto-Farm Generator", "Auto repair generators", function(state)
            Toggles.AutoFarmGenerator = state
            if state then StartLoop("AutoFarmGenerator") end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Complete", "Auto complete generators", function(state)
            Toggles.AutoCompleteGenerator = state
            if state then StartLoop("AutoCompleteGenerator") end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Repair", "Auto repair when damaged", function(state)
            Toggles.AutoRepair = state
        end)
        
        CreateToggle(ScrollingFrame, "Auto Collect Gens", "Auto collect from generators", function(state)
            Toggles.AutoCollectGens = state
        end)
        
        CreateButton(ScrollingFrame, "🔍 Find Nearest Generator", Color3.fromRGB(80, 80, 90), function()
            local gen = FindNearestGenerator()
            if gen then
                RootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
            end
        end)
        
    elseif tabName == "PLAYERS" then
        CreateSection(ScrollingFrame, "PLAYER LIST")
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                local PlayerFrame = Instance.new("Frame")
                PlayerFrame.Size = UDim2.new(1, 0, 0, 60)
                PlayerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                PlayerFrame.BackgroundTransparency = 0.2
                PlayerFrame.Parent = ScrollingFrame
                
                local PlayerCorner = Instance.new("UICorner")
                PlayerCorner.CornerRadius = UDim.new(0, 12)
                PlayerCorner.Parent = PlayerFrame
                
                local Avatar = Instance.new("ImageLabel")
                Avatar.Size = UDim2.new(0, 40, 0, 40)
                Avatar.Position = UDim2.new(0, 10, 0.5, -20)
                Avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
                Avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
                Avatar.Parent = PlayerFrame
                
                local AvatarCorner = Instance.new("UICorner")
                AvatarCorner.CornerRadius = UDim.new(0, 8)
                AvatarCorner.Parent = Avatar
                
                local PlayerName = Instance.new("TextLabel")
                PlayerName.Size = UDim2.new(0.5, -60, 0, 25)
                PlayerName.Position = UDim2.new(0, 60, 0.5, -12.5)
                PlayerName.BackgroundTransparency = 1
                PlayerName.Text = player.Name
                PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                PlayerName.TextSize = 15
                PlayerName.TextXAlignment = Enum.TextXAlignment.Left
                PlayerName.Font = Enum.Font.GothamBold
                PlayerName.Parent = PlayerFrame
                
                local TeleportBtn = Instance.new("TextButton")
                TeleportBtn.Size = UDim2.new(0, 40, 0, 40)
                TeleportBtn.Position = UDim2.new(1, -50, 0.5, -20)
                TeleportBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
                TeleportBtn.Text = "📌"
                TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                TeleportBtn.TextSize = 20
                TeleportBtn.Font = Enum.Font.Gotham
                TeleportBtn.Parent = PlayerFrame
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 8)
                BtnCorner.Parent = TeleportBtn
                
                TeleportBtn.MouseButton1Click:Connect(function()
                    if player.Character then
                        RootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    end
                end)
            end
        end
        
    elseif tabName == "MISC" then
        CreateSection(ScrollingFrame, "UTILITY")
        
        CreateToggle(ScrollingFrame, "Anti AFK", "Prevent being kicked", function(state)
            Toggles.AntiAFK = state
            if state then
                Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Click", "Automatically click", function(state)
            Toggles.AutoClick = state
            if state then StartLoop("AutoClick") end
        end)
        
        CreateToggle(ScrollingFrame, "Anti Stun", "Prevent stun effects", function(state)
            Toggles.AntiStun = state
        end)
        
        CreateToggle(ScrollingFrame, "Anti Fall", "Prevent falling damage", function(state)
            Toggles.AntiFall = state
        end)
        
        CreateToggle(ScrollingFrame, "Anti Void", "Prevent falling into void", function(state)
            Toggles.AntiVoid = state
        end)
        
    elseif tabName == "SETTINGS" then
        CreateSection(ScrollingFrame, "SKILL CHECK")
        
        CreateToggle(ScrollingFrame, "No Skill Check", "Remove all skill checks", function(state)
            Toggles.NoSkillCheck = state
            ToggleSkillCheck(state)
        end)
        
        CreateSection(ScrollingFrame, "GUI SETTINGS")
        
        CreateButton(ScrollingFrame, "🎨 Toggle GUI (F4)", Color3.fromRGB(65, 105, 225), function()
            ScreenGui.Enabled = not ScreenGui.Enabled
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh UI", Color3.fromRGB(80, 80, 90), function()
            UpdateTabContent(CurrentTab)
        end)
        
        CreateButton(ScrollingFrame, "⬇️ Minimize", Color3.fromRGB(100, 100, 100), function()
            if not Minimized then
                MinBtn.MouseButton1Click:Fire()
            end
        end)
        
        CreateButton(ScrollingFrame, "⬆️ Maximize", Color3.fromRGB(100, 100, 100), function()
            if Minimized then
                MaxBtn.MouseButton1Click:Fire()
            end
        end)
        
        CreateLabel(ScrollingFrame, "📌 Keybind: F4 to toggle menu", Color3.fromRGB(150, 150, 150), 25)
        CreateLabel(ScrollingFrame, "📌 Version: 5.0 Ultimate Pro", Color3.fromRGB(150, 150, 150), 25)
        CreateLabel(ScrollingFrame, "📌 Author: LuckyBimZy", Color3.fromRGB(150, 150, 150), 25)
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
print("✅ VIOLENCE DISTRICT ULTIMATE PRO LOADED!")
print("📁 GitHub: LuckyBimZy/Machadepanmu")
print("🕒 " .. os.date("%Y-%m-%d %H:%M:%S"))
print("========================================")

return true