-- ==================== GAMES/VIOLENCE.LUA ====================
-- Script Lengkap Violence District dengan UI Premium
-- Author: LuckyBimZy
-- Version: 3.0

if _G.ViolenceLoaded then 
    print("⚠️ Script sudah diload, melewati...")
    return 
end

_G.ViolenceLoaded = true

print("🔰 Memuat Violence District Script...")
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

-- Toggle variables
local Toggles = {
    SurvivorESP = false,
    KillerESP = false,
    GeneratorESP = false,
    UnlimitedZoom = false,
    FullBright = false,
    AutoFarmGenerator = false,
    AutoFarmPresent = false,
    FarmGift = false,
    NoClip = false,
    FlickerSpeed = false,
    NoSkillCheck = false,
    AutoTeleport = false,
    Aimbot = false,
    Wallhack = false,
    BodyLock = false,
    SpeedBoost = false,
    JumpBoost = false,
    KillAura = false,
    AntiAFK = false,
    AutoClick = false,
    AutoCollectPresent = false,
    AutoCollectGift = false
}

-- Target variables
local SelectedTarget = nil
local TPTarget = nil
local KillerTarget = nil

--==================================================
-- CREATE UI
--==================================================

-- Hapus GUI lama jika ada
local oldGUI = game.CoreGui:FindFirstChild("ViolencePremiumGUI")
if oldGUI then oldGUI:Destroy() end

-- Buat ScreenGui utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolencePremiumGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame utama dengan efek shadow
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
Shadow.Parent = MainFrame

-- Rounded corners untuk main frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Gradient background
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
Gradient.Rotation = 45
Gradient.Parent = MainFrame

--==================================================
-- HEADER / TITLE BAR
--==================================================
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 60)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = HeaderFrame

-- Garis pemisah
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -20, 0, 2)
HeaderLine.Position = UDim2.new(0, 10, 1, -2)
HeaderLine.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = HeaderFrame

local HeaderLineCorner = Instance.new("UICorner")
HeaderLineCorner.CornerRadius = UDim.new(0, 2)
HeaderLineCorner.Parent = HeaderLine

-- Icon/Logo
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Position = UDim2.new(0, 15, 0.5, -20)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://4483345998" -- Ganti dengan icon Anda
Logo.ImageColor3 = Color3.fromRGB(65, 105, 225)
Logo.Parent = HeaderFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 0, 30)
Title.Position = UDim2.new(0, 65, 0.5, -15)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HeaderFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 300, 0, 20)
SubTitle.Position = UDim2.new(0, 65, 0.5, 5)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Premium Edition v3.0"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.TextSize = 12
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = HeaderFrame

-- Status indicator
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 100, 0, 30)
StatusFrame.Position = UDim2.new(1, -115, 0.5, -15)
StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatusFrame.Parent = HeaderFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 15)
StatusCorner.Parent = StatusFrame

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0, 10, 0.5, -5)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
StatusDot.Parent = StatusFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 70, 1, 0)
StatusText.Position = UDim2.new(0, 25, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "ACTIVE"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamBold
StatusText.Parent = StatusFrame

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = HeaderFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--==================================================
-- TAB BUTTONS
--==================================================
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 50)
TabFrame.Position = UDim2.new(0, 0, 0, 60)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local TabList = {
    {name = "INFO", icon = "📊"},
    {name = "VISUALS", icon = "👁️"},
    {name = "SURVIVOR", icon = "🛡️"},
    {name = "KILLER", icon = "🔪"},
    {name = "TELEPORT", icon = "🌀"},
    {name = "FARM", icon = "⚡"},
    {name = "MISC", icon = "⚙️"},
    {name = "SETTINGS", icon = "🔧"}
}

local TabButtons = {}
local CurrentTab = "INFO"

-- Buat tab buttons
for i, tabData in ipairs(TabList) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabData.name .. "Btn"
    TabBtn.Size = UDim2.new(0, 87, 0, 40)
    TabBtn.Position = UDim2.new(0, (i-1) * 87, 0.5, -20)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TabBtn.Text = tabData.icon .. " " .. tabData.name
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Parent = TabFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn
    
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= tabData.name then
            TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= tabData.name then
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tabData.name
        -- Update semua button
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -130)
ContentFrame.Position = UDim2.new(0, 10, 0, 120)
ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- Scrolling frame untuk konten
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 105, 225)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

--==================================================
-- FUNCTION UNTUK MEMBUAT ELEMEN UI
--==================================================

function CreateSection(parent, title)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, -20, 0, 30)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = SectionFrame
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -10, 1, 0)
    SectionTitle.Position = UDim2.new(0, 10, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = title
    SectionTitle.TextColor3 = Color3.fromRGB(65, 105, 225)
    SectionTitle.TextSize = 14
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = SectionFrame
    
    return SectionFrame
end

function CreateToggle(parent, text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, -15, 1, 0)
    ToggleText.Position = UDim2.new(0, 15, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 13
    ToggleText.Font = Enum.Font.Gotham
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 60, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -70, 0.5, -15)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 15)
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

function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 45)
    Button.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
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
    DropdownFrame.Size = UDim2.new(1, -20, 0, 40)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    DropdownFrame.Parent = parent
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -15, 1, 0)
    DropdownText.Position = UDim2.new(0, 15, 0, 0)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 13
    DropdownText.Font = Enum.Font.Gotham
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0.4, -10, 0, 30)
    DropdownBtn.Position = UDim2.new(0.6, -10, 0.5, -15)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    DropdownBtn.Text = items[1] or "Select"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 12
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 15)
    BtnCorner.Parent = DropdownBtn
    
    -- Dropdown menu
    DropdownBtn.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame")
        menu.Size = UDim2.new(0, 150, 0, #items * 30)
        menu.Position = UDim2.new(0.6, -10, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 6)
        menuCorner.Parent = menu
        
        for i, item in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.Position = UDim2.new(0, 0, 0, (i-1) * 30)
            itemBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
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
    
    return DropdownFrame
end

function CreateLabel(parent, text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.Parent = parent
    
    return Label
end

--==================================================
-- FUNCTION UPDATE TAB CONTENT
--==================================================
function UpdateTabContent(tabName)
    -- Hapus semua konten lama
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local yOffset = 5
    
    if tabName == "INFO" then
        CreateSection(ScrollingFrame, "SERVER INFORMATION")
        
        CreateLabel(ScrollingFrame, "📍 Server ID: " .. game.JobId)
        CreateLabel(ScrollingFrame, "👥 Players: " .. #game.Players:GetPlayers())
        CreateLabel(ScrollingFrame, "📊 Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms")
        CreateLabel(ScrollingFrame, "🎮 Game: Violence District")
        
        CreateSection(ScrollingFrame, "PLAYER INFORMATION")
        
        CreateLabel(ScrollingFrame, "👤 Username: " .. Player.Name)
        CreateLabel(ScrollingFrame, "🆔 User ID: " .. Player.UserId)
        CreateLabel(ScrollingFrame, "📈 Account Age: " .. Player.AccountAge .. " days")
        
        CreateSection(ScrollingFrame, "CREDITS")
        
        CreateLabel(ScrollingFrame, "⭐ Script by: LuckyBimZy")
        CreateLabel(ScrollingFrame, "📌 Version: 3.0 Premium")
        CreateLabel(ScrollingFrame, "📅 Date: " .. os.date("%d-%m-%Y"))
        CreateLabel(ScrollingFrame, "🔗 GitHub: Machadepanmu")
        
        CreateButton(ScrollingFrame, "🔄 REFRESH INFO", function()
            UpdateTabContent("INFO")
        end)
        
    elseif tabName == "VISUALS" then
        CreateSection(ScrollingFrame, "ESP SETTINGS")
        
        CreateToggle(ScrollingFrame, "Survivor ESP (Blue)", function(state)
            Toggles.SurvivorESP = state
            if state then
                EnableESP("Survivor", Color3.fromRGB(0, 100, 255))
            else
                DisableESP()
            end
        end)
        
        CreateToggle(ScrollingFrame, "Killer ESP (Red)", function(state)
            Toggles.KillerESP = state
            if state then
                EnableESP("Killer", Color3.fromRGB(255, 0, 0))
            else
                DisableESP()
            end
        end)
        
        CreateToggle(ScrollingFrame, "Generator ESP (Green)", function(state)
            Toggles.GeneratorESP = state
            if state then
                EnableGeneratorESP()
            else
                DisableGeneratorESP()
            end
        end)
        
        CreateSection(ScrollingFrame, "VISUAL EFFECTS")
        
        CreateToggle(ScrollingFrame, "Unlimited Zoom", function(state)
            Toggles.UnlimitedZoom = state
            if state then
                Camera.FieldOfView = 120
            else
                Camera.FieldOfView = 70
            end
        end)
        
        CreateToggle(ScrollingFrame, "Full Bright", function(state)
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
        
        CreateToggle(ScrollingFrame, "Wallhack", function(state)
            Toggles.Wallhack = state
            UpdateWallhack()
        end)
        
    elseif tabName == "SURVIVOR" then
        CreateSection(ScrollingFrame, "SURVIVOR FEATURES")
        
        CreateToggle(ScrollingFrame, "Auto-Farm Present", function(state)
            Toggles.AutoFarmPresent = state
            if state then StartAutoFarmPresent() end
        end)
        
        CreateToggle(ScrollingFrame, "Farm Gift → Teleport to Tree", function(state)
            Toggles.FarmGift = state
            if state then StartFarmGift() end
        end)
        
        CreateToggle(ScrollingFrame, "Flicker/Blink Speed", function(state)
            Toggles.FlickerSpeed = state
            if state then
                Humanoid.WalkSpeed = 100
            else
                Humanoid.WalkSpeed = 16
            end
        end)
        
        CreateToggle(ScrollingFrame, "Speed Boost (x3)", function(state)
            Toggles.SpeedBoost = state
            if state then
                Humanoid.WalkSpeed = 48
            else
                Humanoid.WalkSpeed = 16
            end
        end)
        
        CreateToggle(ScrollingFrame, "Jump Boost (x2)", function(state)
            Toggles.JumpBoost = state
            if state then
                Humanoid.JumpPower = 100
            else
                Humanoid.JumpPower = 50
            end
        end)
        
        CreateSection(ScrollingFrame, "BODY LOCK SYSTEM")
        
        CreateDropdown(ScrollingFrame, "Select Target", GetPlayerList(), function(playerName)
            SelectedTarget = game.Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh Player List", function()
            -- Update dropdown
        end)
        
        CreateToggle(ScrollingFrame, "Body Lock", function(state)
            Toggles.BodyLock = state
            if state then StartBodyLock() end
        end)
        
    elseif tabName == "KILLER" then
        CreateSection(ScrollingFrame, "KILLER FEATURES")
        
        CreateToggle(ScrollingFrame, "Aimbot", function(state)
            Toggles.Aimbot = state
            if state then StartAimbot() end
        end)
        
        CreateToggle(ScrollingFrame, "Kill Aura", function(state)
            Toggles.KillAura = state
            if state then StartKillAura() end
        end)
        
        CreateSection(ScrollingFrame, "TARGET SELECTION")
        
        CreateDropdown(ScrollingFrame, "Select Target", GetPlayerList(), function(playerName)
            KillerTarget = game.Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh List", function()
            -- Update dropdown
        end)
        
    elseif tabName == "TELEPORT" then
        CreateSection(ScrollingFrame, "TELEPORTATION")
        
        CreateToggle(ScrollingFrame, "NoClip (Walk through walls)", function(state)
            Toggles.NoClip = state
            UpdateNoClip()
        end)
        
        CreateSection(ScrollingFrame, "TELEPORT TO PLAYER")
        
        CreateDropdown(ScrollingFrame, "Target Player", GetPlayerList(), function(playerName)
            TPTarget = game.Players:FindFirstChild(playerName)
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh List", function()
            -- Update dropdown
        end)
        
        CreateButton(ScrollingFrame, "📌 Teleport to Target", function()
            if TPTarget and TPTarget.Character then
                RootPart.CFrame = TPTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        end)
        
    elseif tabName == "FARM" then
        CreateSection(ScrollingFrame, "GENERATOR FARM")
        
        CreateToggle(ScrollingFrame, "Auto-Farm Generator", function(state)
            Toggles.AutoFarmGenerator = state
            if state then StartAutoFarmGenerator() end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Teleport & Complete", function(state)
            Toggles.AutoTeleport = state
            if state then StartAutoTeleport() end
        end)
        
        CreateSection(ScrollingFrame, "PRESENT FARM")
        
        CreateToggle(ScrollingFrame, "Auto Collect Presents", function(state)
            Toggles.AutoCollectPresent = state
            if state then StartAutoCollectPresent() end
        end)
        
    elseif tabName == "MISC" then
        CreateSection(ScrollingFrame, "UTILITY")
        
        CreateToggle(ScrollingFrame, "Anti AFK", function(state)
            Toggles.AntiAFK = state
            if state then
                Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
        
        CreateToggle(ScrollingFrame, "Auto Click", function(state)
            Toggles.AutoClick = state
            if state then StartAutoClick() end
        end)
        
    elseif tabName == "SETTINGS" then
        CreateSection(ScrollingFrame, "SKILL CHECK SETTINGS")
        
        CreateToggle(ScrollingFrame, "No Skill Check", function(state)
            Toggles.NoSkillCheck = state
            ToggleSkillCheck(state)
        end)
        
        CreateSection(ScrollingFrame, "GUI SETTINGS")
        
        CreateButton(ScrollingFrame, "🎨 Toggle GUI", function()
            ScreenGui.Enabled = not ScreenGui.Enabled
        end)
        
        CreateButton(ScrollingFrame, "🔄 Refresh UI", function()
            UpdateTabContent(CurrentTab)
        end)
        
        CreateButton(ScrollingFrame, "❌ Close GUI", function()
            ScreenGui:Destroy()
        end)
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- CORE FUNCTIONS
--==================================================

-- ESP Functions
function EnableESP(type, color)
    DisableESP()
    
    for _, player in pairs(game.Players:GetPlayers()) do
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
    
    -- Name tag
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

-- Wallhack
function UpdateWallhack()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if Toggles.Wallhack then
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

-- Auto Farm Functions
function StartAutoFarmGenerator()
    task.spawn(function()
        while Toggles.AutoFarmGenerator do
            task.wait(0.1)
            local generator = FindNearestGenerator()
            if generator then
                RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer("RepairGenerator", generator)
                end
            end
        end
    end)
end

function StartAutoTeleport()
    task.spawn(function()
        while Toggles.AutoTeleport do
            task.wait(0.1)
            local generator = FindNearestGenerator()
            if generator then
                RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                if remote then
                    remote:FireServer("CompleteGenerator", generator)
                end
            end
        end
    end)
end

function StartAutoFarmPresent()
    task.spawn(function()
        while Toggles.AutoFarmPresent do
            task.wait(0.1)
            local present = FindNearestPresent()
            if present then
                RootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
        end
    end)
end

function StartFarmGift()
    task.spawn(function()
        while Toggles.FarmGift do
            task.wait(0.1)
            local gift = FindNearestGift()
            if gift then
                RootPart.CFrame = gift.CFrame + Vector3.new(0, 3, 0)
                local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
                
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
    task.spawn(function()
        while Toggles.AutoCollectPresent do
            task.wait(0.1)
            local present = FindNearestPresent()
            if present then
                RootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
        end
    end)
end

-- Body Lock
function StartBodyLock()
    task.spawn(function()
        while Toggles.BodyLock and SelectedTarget do
            task.wait()
            if SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = SelectedTarget.Character.HumanoidRootPart.Position
                RootPart.CFrame = CFrame.new(targetPos.x, targetPos.y + 3, targetPos.z)
            end
        end
    end)
end

-- Aimbot
function StartAimbot()
    task.spawn(function()
        while Toggles.Aimbot do
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
    task.spawn(function()
        while Toggles.KillAura do
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
    task.spawn(function()
        while Toggles.AutoClick do
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
-- INITIALIZE
--==================================================

-- Tampilkan tab pertama
UpdateTabContent("INFO")

print("========================================")
print("✅ VIOLENCE DISTRICT SCRIPT LOADED!")
print("📁 GitHub: LuckyBimZy/Machadepanmu")
print("🕒 " .. os.date("%Y-%m-%d %H:%M:%S"))
print("========================================")

return true