-- ==================== GAMES/VIOLENCE.LUA ====================
-- Script Premium Violence District dengan UI Modern
-- Author: LuckyBimZy
-- Version: 4.0 (Ultimate)

if _G.ViolenceLoaded then 
    print("⚠️ Script sudah diload, melewati...")
    return 
end

_G.ViolenceLoaded = true

print("🔰 Memuat Violence District Script Ultimate...")
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
    
    -- Survivor
    AutoFarmPresent = false,
    AutoFarmGift = false,
    FlickerSpeed = false,
    SpeedBoost = false,
    JumpBoost = false,
    BodyLock = false,
    AutoOpenPresents = false,
    AutoCollectCoins = false,
    
    -- Killer
    Aimbot = false,
    KillAura = false,
    AutoAttack = false,
    SilentAim = false,
    WallhackKiller = false,
    
    -- Teleport
    NoClip = false,
    TeleportToTarget = false,
    TeleportToMouse = false,
    
    -- Farm
    AutoFarmGenerator = false,
    AutoCompleteGenerator = false,
    AutoRepair = false,
    AutoFarmAll = false,
    
    -- Misc
    AntiAFK = false,
    AutoClick = false,
    NoSkillCheck = false,
    InfiniteStamina = false,
    AntiStun = false,
    AntiFall = false
}

-- Target variables
local SelectedTarget = nil
local TPTarget = nil
local KillerTarget = nil
local GUIHidden = false
local MenuKeybind = Enum.KeyCode.F4

-- Loop connections
local Loops = {}

--==================================================
-- CREATE UI MODERN
--==================================================

-- Hapus GUI lama jika ada
local oldGUI = game.CoreGui:FindFirstChild("ViolenceUltimateGUI")
if oldGUI then oldGUI:Destroy() end

-- Buat ScreenGui utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceUltimateGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

-- Frame utama dengan efek glass morphism
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 800, 0, 600)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Glass morphism effect
local GlassEffect = Instance.new("ImageLabel")
GlassEffect.Size = UDim2.new(1, 0, 1, 0)
GlassEffect.BackgroundTransparency = 1
GlassEffect.Image = "rbxassetid://8994744986"
GlassEffect.ImageColor3 = Color3.fromRGB(30, 30, 40)
GlassEffect.ImageTransparency = 0.7
GlassEffect.ScaleType = Enum.ScaleType.Slice
GlassEffect.SliceCenter = Rect.new(10, 10, 10, 10)
GlassEffect.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(50, 50, 50, 50)
Shadow.Parent = MainFrame

-- Rounded corners
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Gradient border
local BorderGradient = Instance.new("UIGradient")
BorderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 105, 225)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(147, 112, 219)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 105, 225))
})
BorderGradient.Rotation = 45
BorderGradient.Parent = MainFrame

--==================================================
-- TITLE BAR
--==================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

-- Logo
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 30, 0, 30)
Logo.Position = UDim2.new(0, 15, 0.5, -15)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://4483345998"
Logo.ImageColor3 = Color3.fromRGB(65, 105, 225)
Logo.Parent = TitleBar

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 0, 30)
Title.Position = UDim2.new(0, 55, 0.5, -15)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(0, 100, 0, 20)
Version.Position = UDim2.new(0, 55, 0.5, 5)
Version.BackgroundTransparency = 1
Version.Text = "Ultimate v4.0"
Version.TextColor3 = Color3.fromRGB(65, 105, 225)
Version.TextSize = 11
Version.Font = Enum.Font.Gotham
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = TitleBar

-- Window controls
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 90, 0, 30)
ControlFrame.Position = UDim2.new(1, -100, 0.5, -15)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0, 0, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = ControlFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

MinBtn.MouseEnter:Connect(function()
    MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
end)
MinBtn.MouseLeave:Connect(function()
    MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Size = UDim2.new(0, 300, 0, 50)
    MainFrame.Position = UDim2.new(0.5, -150, 0, 10)
    for _, v in pairs(MainFrame:GetChildren()) do
        if v ~= TitleBar and v ~= Shadow then
            v.Visible = false
        end
    end
    MaxBtn.Visible = true
    MinBtn.Visible = false
end)

-- Maximize button
local MaxBtn = Instance.new("TextButton")
MaxBtn.Size = UDim2.new(0, 30, 0, 30)
MaxBtn.Position = UDim2.new(0, 0, 0, 0)
MaxBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MaxBtn.Text = "□"
MaxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MaxBtn.TextSize = 18
MaxBtn.Font = Enum.Font.GothamBold
MaxBtn.Visible = false
MaxBtn.Parent = ControlFrame

local MaxCorner = Instance.new("UICorner")
MaxCorner.CornerRadius = UDim.new(0, 8)
MaxCorner.Parent = MaxBtn

MaxBtn.MouseEnter:Connect(function()
    MaxBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
end)
MaxBtn.MouseLeave:Connect(function()
    MaxBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
end)

MaxBtn.MouseButton1Click:Connect(function()
    MainFrame.Size = UDim2.new(0, 800, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    for _, v in pairs(MainFrame:GetChildren()) do
        if v ~= TitleBar and v ~= Shadow then
            v.Visible = true
        end
    end
    MaxBtn.Visible = false
    MinBtn.Visible = true
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

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--==================================================
-- SIDE BAR (MODERN)
--==================================================
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 150, 1, -60)
SideBar.Position = UDim2.new(0, 0, 0, 50)
SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SideBar.BackgroundTransparency = 0.2
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = SideBar

local TabList = {
    {name = "DASHBOARD", icon = "🏠"},
    {name = "VISUALS", icon = "👁️"},
    {name = "SURVIVOR", icon = "🛡️"},
    {name = "KILLER", icon = "⚔️"},
    {name = "TELEPORT", icon = "🌀"},
    {name = "FARM", icon = "⚡"},
    {name = "PLAYERS", icon = "👥"},
    {name = "MISC", icon = "⚙️"},
    {name = "SETTINGS", icon = "🔧"}
}

local TabButtons = {}
local CurrentTab = "DASHBOARD"

-- Buat tab buttons di side bar
for i, tabData in ipairs(TabList) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabData.name .. "Btn"
    TabBtn.Size = UDim2.new(1, -10, 0, 40)
    TabBtn.Position = UDim2.new(0, 5, 0, 5 + (i-1) * 45)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBtn.BackgroundTransparency = 0.3
    TabBtn.Text = tabData.icon .. "   " .. tabData.name
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Parent = SideBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn
    
    -- Hover effect
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= tabData.name then
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= tabData.name then
            TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tabData.name
        -- Update semua button
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- Update content
        UpdateTabContent(tabData.name)
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Set tab pertama aktif
TabButtons[1].BackgroundColor3 = Color3.fromRGB(65, 105, 225)
TabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

--==================================================
-- CONTENT AREA
--==================================================
local ContentBg = Instance.new("Frame")
ContentBg.Size = UDim2.new(1, -160, 1, -70)
ContentBg.Position = UDim2.new(0, 155, 0, 60)
ContentBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentBg.BackgroundTransparency = 0.2
ContentBg.BorderSizePixel = 0
ContentBg.ClipsDescendants = true
ContentBg.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 12)
ContentCorner.Parent = ContentBg

-- Scrolling frame untuk konten
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -20)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 10)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 105, 225)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentBg

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

--==================================================
-- FUNCTION UNTUK MEMBUAT ELEMEN UI MODERN
--==================================================

function CreateSection(parent, title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 35)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    SectionFrame.BackgroundTransparency = 0.3
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = SectionFrame
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -15, 1, 0)
    SectionTitle.Position = UDim2.new(0, 15, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = "  " .. title
    SectionTitle.TextColor3 = Color3.fromRGB(65, 105, 225)
    SectionTitle.TextSize = 15
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = SectionFrame
    
    return SectionFrame
end

function CreateToggle(parent, text, desc, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 55)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ToggleFrame.BackgroundTransparency = 0.2
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, -20, 0, 25)
    ToggleText.Position = UDim2.new(0, 15, 0, 8)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 14
    ToggleText.Font = Enum.Font.GothamBold
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleDesc = Instance.new("TextLabel")
    ToggleDesc.Size = UDim2.new(0.7, -20, 0, 20)
    ToggleDesc.Position = UDim2.new(0, 15, 0, 30)
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
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
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
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
            ToggleBtn.Text = "ON"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            ToggleBtn.Text = "OFF"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(enabled)
    end)
    
    return ToggleFrame
end

function CreateButton(parent, text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 45)
    Button.BackgroundColor3 = color or Color3.fromRGB(65, 105, 225)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = parent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

function CreateDropdown(parent, text, items, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 55)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    DropdownFrame.BackgroundTransparency = 0.2
    DropdownFrame.Parent = parent
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -15, 0, 25)
    DropdownText.Position = UDim2.new(0, 15, 0, 8)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 14
    DropdownText.Font = Enum.Font.GothamBold
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownDesc = Instance.new("TextLabel")
    DropdownDesc.Size = UDim2.new(0.5, -15, 0, 20)
    DropdownDesc.Position = UDim2.new(0, 15, 0, 30)
    DropdownDesc.BackgroundTransparency = 1
    DropdownDesc.Text = "Select a player"
    DropdownDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    DropdownDesc.TextSize = 11
    DropdownDesc.Font = Enum.Font.Gotham
    DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
    DropdownDesc.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0.4, -10, 0, 35)
    DropdownBtn.Position = UDim2.new(0.6, -10, 0.5, -17.5)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DropdownBtn.Text = items[1] or "Select"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 12
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 20)
    BtnCorner.Parent = DropdownBtn
    
    -- Dropdown menu
    DropdownBtn.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame")
        menu.Size = UDim2.new(0, 150, 0, math.min(#items, 6) * 35)
        menu.Position = UDim2.new(0.6, -10, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 8)
        menuCorner.Parent = menu
        
        local menuList = Instance.new("ScrollingFrame")
        menuList.Size = UDim2.new(1, 0, 1, 0)
        menuList.BackgroundTransparency = 1
        menuList.ScrollBarThickness = 4
        menuList.CanvasSize = UDim2.new(0, 0, 0, #items * 35)
        menuList.Parent = menu
        
        for i, item in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 35)
            itemBtn.Position = UDim2.new(0, 0, 0, (i-1) * 35)
            itemBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            itemBtn.Text = item
            itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemBtn.TextSize = 12
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.Parent = menuList
            
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
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    SliderFrame.BackgroundTransparency = 0.2
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.7, -15, 0, 25)
    SliderText.Position = UDim2.new(0, 15, 0, 8)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 14
    SliderText.Font = Enum.Font.GothamBold
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.2, -10, 0, 25)
    ValueLabel.Position = UDim2.new(0.8, -10, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(65, 105, 225)
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = SliderFrame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -30, 0, 5)
    SliderBg.Position = UDim2.new(0, 15, 0, 40)
    SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    SliderFill.Parent = SliderBg
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 15, 0, 15)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -7.5, 0.5, -7.5)
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
            SliderButton.Position = UDim2.new(percent, -7.5, 0.5, -7.5)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
    end)
    
    return SliderFrame
end

function CreateLabel(parent, text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
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
    
    if tabName == "DASHBOARD" then
        CreateSection(ScrollingFrame, "SYSTEM STATUS")
        
        local StatusFrame = Instance.new("Frame")
        StatusFrame.Size = UDim2.new(1, 0, 0, 100)
        StatusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        StatusFrame.BackgroundTransparency = 0.2
        StatusFrame.Parent = ScrollingFrame
        
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(0, 8)
        StatusCorner.Parent = StatusFrame
        
        local function CreateStatusItem(icon, label, value, y)
            local item = Instance.new("TextLabel")
            item.Size = UDim2.new(1, -20, 0, 25)
            item.Position = UDim2.new(0, 15, 0, y)
            item.BackgroundTransparency = 1
            item.Text = icon .. "  " .. label .. ": " .. value
            item.TextColor3 = Color3.fromRGB(255, 255, 255)
            item.TextSize = 14
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.Font = Enum.Font.Gotham
            item.Parent = StatusFrame
        end
        
        CreateStatusItem("🎮", "Game", "Violence District", 10)
        CreateStatusItem("👤", "Player", Player.Name, 35)
        CreateStatusItem("📊", "Ping", math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms", 60)
        
        CreateSection(ScrollingFrame, "QUICK ACTIONS")
        
        CreateButton(ScrollingFrame, "🔄 REFRESH ALL", Color3.fromRGB(65, 105, 225), function()
            UpdateTabContent("DASHBOARD")
        end)
        
        CreateButton(ScrollingFrame, "🧹 CLEAR ALL LOOPS", Color3.fromRGB(220, 60, 60), function()
            StopAllLoops()
        end)
        
        CreateSection(ScrollingFrame, "SERVER INFO")
        
        CreateLabel(ScrollingFrame, "📍 Server ID: " .. game.JobId)
        CreateLabel(ScrollingFrame, "👥 Total Players: " .. #Players:GetPlayers())
        CreateLabel(ScrollingFrame, "⏰ Time: " .. os.date("%H:%M:%S"))
        
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
            UpdateXRay()
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
        
        CreateSection(ScrollingFrame, "TELEPORT TO PLAYER")
        
        CreateDropdown(ScrollingFrame, "Target Player", GetPlayerList(), function(playerName)
            TPTarget = Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "📌 Teleport to Target", Color3.fromRGB(65, 105, 225), function()
            if TPTarget and TPTarget.Character then
                RootPart.CFrame = TPTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        end)
        
        CreateToggle(ScrollingFrame, "Teleport to Mouse", "Teleport to mouse position", function(state)
            Toggles.TeleportToMouse = state
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
                PlayerFrame.Size = UDim2.new(1, 0, 0, 45)
                PlayerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                PlayerFrame.BackgroundTransparency = 0.2
                PlayerFrame.Parent = ScrollingFrame
                
                local PlayerCorner = Instance.new("UICorner")
                PlayerCorner.CornerRadius = UDim.new(0, 8)
                PlayerCorner.Parent = PlayerFrame
                
                local PlayerName = Instance.new("TextLabel")
                PlayerName.Size = UDim2.new(0.5, -15, 1, 0)
                PlayerName.Position = UDim2.new(0, 15, 0, 0)
                PlayerName.BackgroundTransparency = 1
                PlayerName.Text = player.Name
                PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                PlayerName.TextSize = 14
                PlayerName.TextXAlignment = Enum.TextXAlignment.Left
                PlayerName.Font = Enum.Font.GothamBold
                PlayerName.Parent = PlayerFrame
                
                local TeleportBtn = Instance.new("TextButton")
                TeleportBtn.Size = UDim2.new(0, 70, 0, 30)
                TeleportBtn.Position = UDim2.new(1, -80, 0.5, -15)
                TeleportBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
                TeleportBtn.Text = "TP"
                TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                TeleportBtn.TextSize = 12
                TeleportBtn.Font = Enum.Font.GothamBold
                TeleportBtn.Parent = PlayerFrame
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 15)
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
        
    elseif tabName == "SETTINGS" then
        CreateSection(ScrollingFrame, "SKILL CHECK")
        
        CreateToggle(ScrollingFrame, "No Skill Check", "Remove all skill checks", function(state)
            Toggles.NoSkillCheck = state
            ToggleSkillCheck(state)
        end)
        
        CreateSection(ScrollingFrame, "GUI SETTINGS")
        
        CreateButton(ScrollingFrame, "🎨 Toggle GUI", Color3.fromRGB(65, 105, 225), function()
            ScreenGui.Enabled = not ScreenGui.Enabled
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh UI", Color3.fromRGB(80, 80, 90), function()
            UpdateTabContent(CurrentTab)
        end)
        
        CreateLabel(ScrollingFrame, "Press F4 to toggle menu")
        CreateLabel(ScrollingFrame, "Version: 4.0 Ultimate")
        CreateLabel(ScrollingFrame, "Author: LuckyBimZy")
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
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
-- CORE FUNCTIONS (FIXED)
--==================================================

-- Auto Farm Generator (FIXED)
function AutoFarmGenerator()
    local generator = FindNearestGenerator()
    if generator then
        -- Teleport ke generator
        RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
        
        -- Coba repair generator
        local args = {
            [1] = "RepairGenerator",
            [2] = generator
        }
        
        -- Coba berbagai kemungkinan remote event
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or
                      game:GetService("ReplicatedStorage"):FindFirstChild("GeneratorEvent") or
                      game:GetService("ReplicatedStorage"):FindFirstChild("RepairEvent")
        
        if remote then
            pcall(function()
                remote:FireServer(unpack(args))
            end)
        end
        
        -- Alternatif: fire proximity prompt
        local prompt = generator:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        end
    end
end

-- Auto Complete Generator (FIXED)
function AutoCompleteGenerator()
    local generator = FindNearestGenerator()
    if generator then
        RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
        
        local args = {
            [1] = "CompleteGenerator",
            [2] = generator
        }
        
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or
                      game:GetService("ReplicatedStorage"):FindFirstChild("CompleteEvent")
        
        if remote then
            pcall(function()
                remote:FireServer(unpack(args))
            end)
        end
    end
end

-- Auto Farm Present
function AutoFarmPresent()
    local present = FindNearestPresent()
    if present then
        RootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
        local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        end
    end
end

-- Auto Farm Gift
function AutoFarmGift()
    local gift = FindNearestGift()
    if gift then
        RootPart.CFrame = gift.CFrame + Vector3.new(0, 3, 0)
        local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        end
        
        -- Teleport ke Christmas tree
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
        if tool then
            tool:Activate()
        end
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
    
    -- Distance ESP
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
    nameLabel.Text = player.Name .. " [" .. math.floor((player.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude) .. "m]"
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

function UpdateXRay()
    UpdateWallhack()
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
print("✅ VIOLENCE DISTRICT ULTIMATE LOADED!")
print("📁 GitHub: LuckyBimZy/Machadepanmu")
print("🕒 " .. os.date("%Y-%m-%d %H:%M:%S"))
print("========================================")

return true