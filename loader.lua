-- ==================== VIOLENCE DISTRICT SPEED HUB ====================
-- UI Style seperti Speed Hub - Simple, Clean, dan Powerful
-- Author: LuckyBimZy
-- Version: 1.0

-- Loadstring untuk menjalankan script
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyBimZy/Machadepanmu/main/games/violence.lua"))()

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
    ESPType = "Box",
    ESPColor = Color3.fromRGB(255, 255, 255),
    FullBright = false,
    NoFog = false,
    
    -- Survivor
    AutoFarmPresent = false,
    AutoFarmGift = false,
    SpeedBoost = false,
    JumpBoost = false,
    
    -- Killer
    Aimbot = false,
    KillAura = false,
    KillAuraRange = 20,
    
    -- Teleport
    NoClip = false,
    
    -- Farm
    AutoFarmGenerator = false,
    
    -- Misc
    AntiAFK = false,
    NoSkillCheck = false
}

-- Loop control
local Loops = {}
local ESPObjects = {}

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

Notify("Violence District", "Script loaded successfully!", 3)

--==================================================
-- SPEED HUB UI (SIMPLE TAPI ELEGAN)
--==================================================

-- Hapus GUI lama
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name:find("SpeedHub") then
        v:Destroy()
    end
end

-- ScreenGui utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHub_VD"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Rounded corners
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(50, 50, 50, 50)
Shadow.Parent = MainFrame

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Title text
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "VIOLENCE DISTRICT"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Version text
local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 60, 1, 0)
VersionText.Position = UDim2.new(1, -70, 0, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v1.0"
VersionText.TextColor3 = Color3.fromRGB(150, 150, 150)
VersionText.TextSize = 12
VersionText.Font = Enum.Font.Gotham
VersionText.TextXAlignment = Enum.TextXAlignment.Right
VersionText.Parent = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.VD_Loaded = false
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniFrame.Visible = true
end)

-- Mini frame (saat minimize)
local MiniFrame = Instance.new("Frame")
MiniFrame.Name = "MiniFrame"
MiniFrame.Size = UDim2.new(0, 200, 0, 35)
MiniFrame.Position = UDim2.new(0.5, -100, 0, 10)
MiniFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MiniFrame.BackgroundTransparency = 0.1
MiniFrame.BorderSizePixel = 0
MiniFrame.Active = true
MiniFrame.Draggable = true
MiniFrame.Visible = false
MiniFrame.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 8)
MiniCorner.Parent = MiniFrame

local MiniText = Instance.new("TextLabel")
MiniText.Size = UDim2.new(1, -60, 1, 0)
MiniText.Position = UDim2.new(0, 10, 0, 0)
MiniText.BackgroundTransparency = 1
MiniText.Text = "VD - Speed Hub"
MiniText.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniText.TextSize = 13
MiniText.Font = Enum.Font.GothamBold
MiniText.TextXAlignment = Enum.TextXAlignment.Left
MiniText.Parent = MiniFrame

local MaxBtn = Instance.new("TextButton")
MaxBtn.Size = UDim2.new(0, 25, 0, 25)
MaxBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
MaxBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MaxBtn.Text = "□"
MaxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MaxBtn.TextSize = 14
MaxBtn.Font = Enum.Font.GothamBold
MaxBtn.Parent = MiniFrame

local MaxCorner = Instance.new("UICorner")
MaxCorner.CornerRadius = UDim.new(0, 4)
MaxCorner.Parent = MaxBtn

MaxBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniFrame.Visible = false
end)

local MiniCloseBtn = Instance.new("TextButton")
MiniCloseBtn.Size = UDim2.new(0, 25, 0, 25)
MiniCloseBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
MiniCloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MiniCloseBtn.Text = "X"
MiniCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniCloseBtn.TextSize = 14
MiniCloseBtn.Font = Enum.Font.GothamBold
MiniCloseBtn.Parent = MiniFrame

local MiniCloseCorner = Instance.new("UICorner")
MiniCloseCorner.CornerRadius = UDim.new(0, 4)
MiniCloseCorner.Parent = MiniCloseBtn

MiniCloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.VD_Loaded = false
end)

-- Tab buttons
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 35)
TabFrame.Position = UDim2.new(0, 10, 0, 45)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local Tabs = {"Main", "Visuals", "Survivor", "Killer", "Teleport", "Farm", "Misc"}
local TabButtons = {}
local CurrentTab = "Main"

for i, tabName in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 35, 0, 35)
    TabBtn.Position = UDim2.new(0, (i-1) * 40, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    TabBtn.Text = ""
    TabBtn.Parent = TabFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabBtn
    
    local TabIcon = Instance.new("TextLabel")
    TabIcon.Size = UDim2.new(1, 0, 1, 0)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Text = getTabIcon(tabName)
    TabIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabIcon.TextSize = 16
    TabIcon.Font = Enum.Font.Gotham
    TabIcon.Parent = TabBtn
    
    TabBtn.MouseEnter:Connect(function()
        if CurrentTab ~= tabName then
            TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        end
    end)
    
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab ~= tabName then
            TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
    end)
    
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tabName
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            btn:FindFirstChild("TextLabel").TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        TabBtn:FindFirstChild("TextLabel").TextColor3 = Color3.fromRGB(255, 255, 255)
        UpdateTab(tabName)
    end)
    
    table.insert(TabButtons, TabBtn)
end

-- Content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -95)
ContentFrame.Position = UDim2.new(0, 10, 0, 85)
ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ContentFrame.BackgroundTransparency = 0.1
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- Scrolling frame untuk konten
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
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

--==================================================
-- FUNGSI UNTUK MEMBUAT ELEMEN UI
--==================================================

function getTabIcon(tab)
    local icons = {
        Main = "🏠",
        Visuals = "👁️",
        Survivor = "🛡️",
        Killer = "🔪",
        Teleport = "🌀",
        Farm = "⚡",
        Misc = "⚙️"
    }
    return icons[tab] or "📁"
end

function CreateSection(text)
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 25)
    Section.BackgroundTransparency = 1
    Section.Text = "  " .. text
    Section.TextColor3 = Color3.fromRGB(65, 105, 225)
    Section.TextSize = 13
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.Parent = ScrollingFrame
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, -10, 0, 1)
    Line.Position = UDim2.new(0, 5, 0, 24)
    Line.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Section
    
    return Section
end

function CreateToggle(text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ToggleFrame.BackgroundTransparency = 0.1
    ToggleFrame.Parent = ScrollingFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, -10, 1, 0)
    ToggleText.Position = UDim2.new(0, 10, 0, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = text
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 13
    ToggleText.Font = Enum.Font.Gotham
    ToggleText.TextXAlignment = Enum.TextXAlignment.Left
    ToggleText.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 11
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ToggleBtn
    
    local enabled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
            ToggleBtn.Text = "ON"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            ToggleBtn.Text = "OFF"
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(enabled)
    end)
    
    return ToggleFrame
end

function CreateButton(text, color, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = color or Color3.fromRGB(65, 105, 225)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ScrollingFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

function CreateDropdown(text, options, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    DropdownFrame.BackgroundTransparency = 0.1
    DropdownFrame.Parent = ScrollingFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownText = Instance.new("TextLabel")
    DropdownText.Size = UDim2.new(0.5, -10, 1, 0)
    DropdownText.Position = UDim2.new(0, 10, 0, 0)
    DropdownText.BackgroundTransparency = 1
    DropdownText.Text = text
    DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.TextSize = 13
    DropdownText.Font = Enum.Font.Gotham
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(0, 100, 0, 25)
    DropdownBtn.Position = UDim2.new(1, -110, 0.5, -12.5)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    DropdownBtn.Text = options[1] or "Select"
    DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownBtn.TextSize = 11
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.Parent = DropdownFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = DropdownBtn
    
    DropdownBtn.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame")
        menu.Size = UDim2.new(0, 120, 0, math.min(#options, 5) * 30)
        menu.Position = UDim2.new(1, -110, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        menu.BorderSizePixel = 0
        menu.Parent = DropdownFrame
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 6)
        menuCorner.Parent = menu
        
        for i, option in ipairs(options) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(1, 0, 0, 30)
            optionBtn.Position = UDim2.new(0, 0, 0, (i-1) * 30)
            optionBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            optionBtn.Text = option
            optionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optionBtn.TextSize = 11
            optionBtn.Font = Enum.Font.Gotham
            optionBtn.Parent = menu
            
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
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.Parent = ScrollingFrame
    
    return Label
end

function CreateSlider(text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SliderFrame.BackgroundTransparency = 0.1
    SliderFrame.Parent = ScrollingFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local SliderText = Instance.new("TextLabel")
    SliderText.Size = UDim2.new(0.7, -10, 0, 20)
    SliderText.Position = UDim2.new(0, 10, 0, 5)
    SliderText.BackgroundTransparency = 1
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 12
    SliderText.Font = Enum.Font.Gotham
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    SliderText.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.2, -10, 0, 20)
    ValueLabel.Position = UDim2.new(0.8, -10, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(65, 105, 225)
    ValueLabel.TextSize = 12
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Parent = SliderFrame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 4)
    SliderBg.Position = UDim2.new(0, 10, 0, 35)
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    SliderFill.Parent = SliderBg
    
    -- Drag functionality sederhana
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
-- UPDATE TAB
--==================================================
function UpdateTab(tab)
    -- Clear content
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if tab == "Main" then
        CreateSection("INFO")
        CreateLabel("Player: " .. Player.Name)
        CreateLabel("Server: " .. game.JobId:sub(1, 8) .. "...")
        CreateLabel("Players: " .. #Players:GetPlayers())
        CreateLabel("Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms")
        
        CreateSection("QUICK ACTIONS")
        CreateButton("Refresh Info", Color3.fromRGB(65, 105, 225), function()
            UpdateTab("Main")
        end)
        
        CreateButton("Rejoin Server", Color3.fromRGB(255, 100, 100), function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end)
        
        CreateSection("CREDITS")
        CreateLabel("Speed Hub UI")
        CreateLabel("Version 1.0")
        CreateLabel("Made by LuckyBimZy")
        
    elseif tab == "Visuals" then
        CreateSection("ESP SETTINGS")
        CreateToggle("Enable ESP", function(state)
            Toggles.ESP = state
            if state then
                EnableESP()
            else
                DisableESP()
            end
        end)
        
        CreateDropdown("ESP Type", {"Box", "Highlight", "Tracer", "Name"}, function(option)
            Toggles.ESPType = option
            if Toggles.ESP then
                DisableESP()
                EnableESP()
            end
        end)
        
        CreateSection("VISUAL EFFECTS")
        CreateToggle("Full Bright", function(state)
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
        
        CreateToggle("No Fog", function(state)
            Toggles.NoFog = state
            if state then
                Lighting.FogEnd = 1e9
            else
                Lighting.FogEnd = 100000
            end
        end)
        
    elseif tab == "Survivor" then
        CreateSection("AUTO FARM")
        CreateToggle("Auto Farm Present", function(state)
            Toggles.AutoFarmPresent = state
            if state then StartLoop("AutoFarmPresent") end
        end)
        
        CreateToggle("Auto Farm Gift", function(state)
            Toggles.AutoFarmGift = state
            if state then StartLoop("AutoFarmGift") end
        end)
        
        CreateSection("MOVEMENT")
        CreateToggle("Speed Boost", function(state)
            Toggles.SpeedBoost = state
            if state then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
            else
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end)
        
        CreateToggle("Jump Boost", function(state)
            Toggles.JumpBoost = state
            if state then
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
            else
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
            end
        end)
        
    elseif tab == "Killer" then
        CreateSection("COMBAT")
        CreateToggle("Aimbot", function(state)
            Toggles.Aimbot = state
            if state then StartLoop("Aimbot") end
        end)
        
        CreateToggle("Kill Aura", function(state)
            Toggles.KillAura = state
            if state then StartLoop("KillAura") end
        end)
        
        CreateSlider("Kill Aura Range", 5, 50, 20, function(value)
            Toggles.KillAuraRange = value
        end)
        
    elseif tab == "Teleport" then
        CreateSection("MOVEMENT")
        CreateToggle("NoClip", function(state)
            Toggles.NoClip = state
            UpdateNoClip()
        end)
        
        CreateSection("TELEPORT")
        CreateDropdown("Target Player", GetPlayerList(), function(name)
            local target = Players:FindFirstChild(name)
            if target and target.Character then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        end)
        
        CreateButton("Refresh List", Color3.fromRGB(80, 80, 90), function()
            UpdateTab("Teleport")
        end)
        
    elseif tab == "Farm" then
        CreateSection("GENERATOR")
        CreateToggle("Auto Farm Generator", function(state)
            Toggles.AutoFarmGenerator = state
            if state then StartLoop("AutoFarmGenerator") end
        end)
        
        CreateButton("Find Generator", Color3.fromRGB(65, 105, 225), function()
            local gen = FindNearestGenerator()
            if gen then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
            end
        end)
        
    elseif tab == "Misc" then
        CreateSection("UTILITY")
        CreateToggle("Anti AFK", function(state)
            Toggles.AntiAFK = state
            if state then
                game.Players.LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
        
        CreateToggle("No Skill Check", function(state)
            Toggles.NoSkillCheck = state
            ToggleSkillCheck(state)
        end)
        
        CreateSection("CONTROLS")
        CreateButton("Minimize", Color3.fromRGB(100, 100, 100), function()
            MainFrame.Visible = false
            MiniFrame.Visible = true
        end)
        
        CreateButton("Close GUI", Color3.fromRGB(220, 60, 60), function()
            ScreenGui:Destroy()
            _G.VD_Loaded = false
        end)
    end
    
    -- Update canvas size
    task.wait()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- CORE FUNCTIONS
--==================================================

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if name == "AutoFarmPresent" then
                local present = FindNearestPresent()
                if present then
                    local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            elseif name == "AutoFarmGift" then
                local gift = FindNearestGift()
                if gift then
                    local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            elseif name == "Aimbot" then
                local target = FindNearestPlayer()
                if target and target.Character then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(
                        game.Players.LocalPlayer.Character.HumanoidRootPart.Position, 
                        targetPos
                    )
                end
            elseif name == "KillAura" then
                local range = Toggles.KillAuraRange or 20
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                        local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= range then
                            player.Character.Humanoid.Health = 0
                        end
                    end
                end
            elseif name == "AutoFarmGenerator" then
                local gen = FindNearestGenerator()
                if gen then
                    local prompt = gen:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            end
            task.wait(0.1)
        end
    end)
end

function EnableESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            AddESP(player)
        end
    end
end

function AddESP(player)
    if not player.Character then return end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "VD_ESP"
    highlight.Parent = player.Character
    highlight.FillColor = Toggles.ESPColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    
    -- Name tag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VD_Name"
    billboard.Parent = player.Character
    billboard.Size = UDim2.new(0, 100, 0, 25)
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

function UpdateNoClip()
    if Toggles.NoClip then
        RunService:BindToRenderStep("NoClip", 0, function()
            if Toggles.NoClip and game.Players.LocalPlayer.Character then
                for _, part in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("NoClip")
        if game.Players.LocalPlayer.Character then
            for _, part in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
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

function FindNearestGenerator()
    local nearest = nil
    local dist = math.huge
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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

function FindNearestPresent()
    local nearest = nil
    local dist = math.huge
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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

function FindNearestGift()
    local nearest = nil
    local dist = math.huge
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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

function FindNearestPlayer()
    local nearest = nil
    local dist = math.huge
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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
        if player ~= game.Players.LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

--==================================================
-- INITIALIZE
--==================================================

-- Set tab pertama
UpdateTab("Main")

-- Keybind untuk toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F4 then
        if MainFrame.Visible then
            MainFrame.Visible = false
            MiniFrame.Visible = true
        elseif MiniFrame.Visible then
            MiniFrame.Visible = false
            MainFrame.Visible = true
        else
            MainFrame.Visible = true
        end
    end
end)

Notify("Violence District", "Press F4 to toggle menu", 3)

print("✅ Violence District Speed Hub loaded!")
print("Press F4 to toggle menu")