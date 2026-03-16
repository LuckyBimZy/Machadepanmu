--[[
    ====================================================
    SCRIPT FUSION - CATRAZ UI EDITION
    Complete standalone script with Catraz UI styling
    All features are built-in and ready to use
    Created: March 16, 2026
    ====================================================
]]

-- Check if in Roblox environment
local function checkEnvironment()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    return success
end

if not checkEnvironment() then
    warn("This script must be run in Roblox!")
    return
end

-- ====================================================
-- CATRAZ UI LIBRARY
-- ====================================================

local Catraz = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Colors
local Colors = {
    Background = Color3.fromRGB(20, 20, 30),
    Surface = Color3.fromRGB(30, 30, 40),
    Element = Color3.fromRGB(40, 40, 50),
    ElementHover = Color3.fromRGB(50, 50, 60),
    Accent = Color3.fromRGB(0, 170, 255),
    AccentDark = Color3.fromRGB(0, 140, 210),
    Success = Color3.fromRGB(0, 200, 100),
    Danger = Color3.fromRGB(255, 80, 80),
    Warning = Color3.fromRGB(255, 170, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(50, 50, 60)
}

-- Create gradient
local function createGradient(color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Rotation = rotation or 90
    return gradient
end

-- Create shadow
local function addShadow(parent, transparency, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = parent
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    return shadow
end

-- Create corner
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

-- Create stroke
local function addStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Colors.Border
    stroke.Parent = parent
    return stroke
end

-- Main window creation
function Catraz:CreateWindow(title, subtitle, size)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Catraz_" .. title:gsub("%s+", "")
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.Size = size
    MainFrame.ClipsDescendants = true
    
    -- Add shadow
    addShadow(MainFrame, 0.3)
    addCorner(MainFrame, 12)
    addStroke(MainFrame, 1, Colors.Border)
    
    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Colors.Surface
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    
    addCorner(TitleBar, 12)
    addStroke(TitleBar, 1, Colors.Border)
    
    -- Make draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Title text
    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Size = UDim2.new(0.5, 0, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = title
    TitleText.TextColor3 = Colors.Text
    TitleText.TextSize = 18
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Subtitle text
    local SubtitleText = Instance.new("TextLabel")
    SubtitleText.Parent = TitleBar
    SubtitleText.BackgroundTransparency = 1
    SubtitleText.Position = UDim2.new(0.5, 0, 0, 0)
    SubtitleText.Size = UDim2.new(0.5, -15, 1, 0)
    SubtitleText.Font = Enum.Font.Gotham
    SubtitleText.Text = subtitle
    SubtitleText.TextColor3 = Colors.TextDim
    SubtitleText.TextSize = 14
    SubtitleText.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Colors.Danger
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -12)
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Colors.Text
    CloseBtn.TextSize = 14
    CloseBtn.AutoButtonColor = false
    
    addCorner(CloseBtn, 6)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Danger}):Play()
    end)
    
    -- Content frame
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = MainFrame
    Content.BackgroundColor3 = Colors.Background
    Content.BorderSizePixel = 0
    Content.Position = UDim2.new(0, 0, 0, 45)
    Content.Size = UDim2.new(1, 0, 1, -45)
    
    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Content = Content,
        CloseBtn = CloseBtn
    }
end

-- Create tab system
function Catraz:CreateTabs(parent, tabs)
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = parent
    TabContainer.BackgroundColor3 = Colors.Surface
    TabContainer.BorderSizePixel = 0
    TabContainer.Size = UDim2.new(1, 0, 0, 35)
    
    addCorner(TabContainer, 8)
    
    local TabButtons = {}
    local TabContents = {}
    
    for i, tabData in ipairs(tabs) do
        -- Create tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabData.Name .. "Tab"
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundColor3 = i == 1 and Colors.Accent or Colors.Element
        TabBtn.BorderSizePixel = 0
        TabBtn.Position = UDim2.new((i-1) * (1/#tabs), 2, 0.1, 0)
        TabBtn.Size = UDim2.new(1/#tabs, -4, 0.8, 0)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Text = tabData.Name
        TabBtn.TextColor3 = Colors.Text
        TabBtn.TextSize = 14
        TabBtn.AutoButtonColor = false
        
        addCorner(TabBtn, 6)
        
        -- Create content frame for tab
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabData.Name .. "Content"
        TabContent.Parent = parent
        TabContent.BackgroundColor3 = Colors.Background
        TabContent.BorderSizePixel = 0
        TabContent.Position = UDim2.new(0, 0, 0, 40)
        TabContent.Size = UDim2.new(1, 0, 1, -45)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = Colors.Accent
        TabContent.Visible = i == 1
        
        local Layout = Instance.new("UIListLayout")
        Layout.Parent = TabContent
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 8)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
        end)
        
        TabButtons[i] = TabBtn
        TabContents[i] = TabContent
        
        -- Tab switching
        TabBtn.MouseButton1Click:Connect(function()
            for j, btn in ipairs(TabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = j == i and Colors.Accent or Colors.Element}):Play()
                TabContents[j].Visible = j == i
            end
        end)
        
        TabBtn.MouseEnter:Connect(function()
            if TabBtn.BackgroundColor3 ~= Colors.Accent then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play()
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if TabBtn.BackgroundColor3 ~= Colors.Accent then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Element}):Play()
            end
        end)
    end
    
    return TabContents
end

-- Create section
function Catraz:CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Name = title .. "Section"
    Section.Parent = parent
    Section.BackgroundColor3 = Colors.Surface
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(0.95, 0, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    
    addCorner(Section, 8)
    addStroke(Section, 1, Colors.Border)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Section
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Colors.Accent
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = Section
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 5, 0, 35)
    Content.Size = UDim2.new(1, -10, 0, 0)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Content
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    return Content
end

-- Create toggle
function Catraz:CreateToggle(parent, text, default, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Name = text .. "Toggle"
    Toggle.Parent = parent
    Toggle.BackgroundColor3 = Colors.Element
    Toggle.BorderSizePixel = 0
    Toggle.Size = UDim2.new(1, -10, 0, 40)
    Toggle.AutomaticSize = Enum.AutomaticSize.None
    
    addCorner(Toggle, 6)
    
    local state = default or false
    
    local function updateState()
        if state then
            Toggle.BackgroundColor3 = Colors.Success
        else
            Toggle.BackgroundColor3 = Colors.Element
        end
    end
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Toggle
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.Text = text
    TextLabel.TextColor3 = Colors.Text
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Toggle
    ToggleBtn.BackgroundColor3 = state and Colors.Success or Colors.ElementHover
    ToggleBtn.Position = UDim2.new(0.85, -15, 0.5, -10)
    ToggleBtn.Size = UDim2.new(0, 30, 0, 20)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = state and "ON" or "OFF"
    ToggleBtn.TextColor3 = Colors.Text
    ToggleBtn.TextSize = 10
    ToggleBtn.AutoButtonColor = false
    
    addCorner(ToggleBtn, 10)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.Text = state and "ON" or "OFF"
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Colors.Success or Colors.ElementHover}):Play()
        updateState()
        if callback then
            pcall(callback, state)
        end
    end)
    
    Toggle.MouseEnter:Connect(function()
        if not state then
            TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play()
        end
    end)
    
    Toggle.MouseLeave:Connect(function()
        if not state then
            TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Element}):Play()
        end
    end)
    
    updateState()
    
    return {
        Set = function(value)
            state = value
            ToggleBtn.Text = state and "ON" or "OFF"
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Colors.Success or Colors.ElementHover}):Play()
            updateState()
        end,
        Get = function() return state end
    }
end

-- Create button
function Catraz:CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Name = text .. "Button"
    Button.Parent = parent
    Button.BackgroundColor3 = Colors.Element
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.TextColor3 = Colors.Text
    Button.TextSize = 14
    Button.AutoButtonColor = false
    
    addCorner(Button, 6)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Element}):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Accent}):Play()
        task.wait(0.1)
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Element}):Play()
        if callback then
            pcall(callback)
        end
    end)
    
    return Button
end

-- Create slider
function Catraz:CreateSlider(parent, text, min, max, default, callback)
    local Slider = Instance.new("Frame")
    Slider.Name = text .. "Slider"
    Slider.Parent = parent
    Slider.BackgroundColor3 = Colors.Element
    Slider.BorderSizePixel = 0
    Slider.Size = UDim2.new(1, -10, 0, 60)
    
    addCorner(Slider, 6)
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Slider
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 10, 0, 5)
    TextLabel.Size = UDim2.new(1, -20, 0, 20)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.Text = text
    TextLabel.TextColor3 = Colors.Text
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = Slider
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(1, -50, 0, 5)
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Colors.Accent
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Parent = Slider
    SliderBg.BackgroundColor3 = Colors.ElementHover
    SliderBg.Position = UDim2.new(0.1, 0, 0.6, 0)
    SliderBg.Size = UDim2.new(0.8, 0, 0, 6)
    
    addCorner(SliderBg, 3)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBg
    SliderFill.BackgroundColor3 = Colors.Accent
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
    addCorner(SliderFill, 3)
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Parent = SliderBg
    SliderBtn.BackgroundColor3 = Colors.AccentDark
    SliderBtn.Size = UDim2.new(0, 16, 0, 16)
    SliderBtn.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    SliderBtn.Font = Enum.Font.SourceSans
    SliderBtn.Text = ""
    SliderBtn.AutoButtonColor = false
    
    addCorner(SliderBtn, 8)
    addStroke(SliderBtn, 1, Colors.Text)
    
    local value = default
    local dragging = false
    
    local function updateSlider(input)
        local pos = UserInputService:GetMouseLocation()
        local sliderPos = SliderBg.AbsolutePosition
        local sliderSize = SliderBg.AbsoluteSize.X
        
        local relativeX = math.clamp(pos.X - sliderPos.X, 0, sliderSize)
        local percent = relativeX / sliderSize
        value = math.floor(min + (percent * (max - min)) * 10) / 10
        
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderBtn.Position = UDim2.new(percent, -8, 0.5, -8)
        ValueLabel.Text = tostring(value)
        
        if callback then
            pcall(callback, value)
        end
    end
    
    SliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    SliderBtn.MouseEnter:Connect(function()
        TweenService:Create(SliderBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Accent}):Play()
    end)
    
    SliderBtn.MouseLeave:Connect(function()
        TweenService:Create(SliderBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.AccentDark}):Play()
    end)
    
    return {
        Set = function(newValue)
            value = math.clamp(newValue, min, max)
            local percent = (value - min) / (max - min)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderBtn.Position = UDim2.new(percent, -8, 0.5, -8)
            ValueLabel.Text = tostring(value)
        end,
        Get = function() return value end
    }
end

-- Create dropdown
function Catraz:CreateDropdown(parent, text, options, default, callback)
    local Dropdown = Instance.new("Frame")
    Dropdown.Name = text .. "Dropdown"
    Dropdown.Parent = parent
    Dropdown.BackgroundColor3 = Colors.Element
    Dropdown.BorderSizePixel = 0
    Dropdown.Size = UDim2.new(1, -10, 0, 40)
    Dropdown.ClipsDescendants = true
    
    addCorner(Dropdown, 6)
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Dropdown
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.Text = text
    TextLabel.TextColor3 = Colors.Text
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SelectedBtn = Instance.new("TextButton")
    SelectedBtn.Parent = Dropdown
    SelectedBtn.BackgroundColor3 = Colors.ElementHover
    SelectedBtn.Position = UDim2.new(0.7, 0, 0.1, 0)
    SelectedBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
    SelectedBtn.Font = Enum.Font.Gotham
    SelectedBtn.Text = default or options[1]
    SelectedBtn.TextColor3 = Colors.Text
    SelectedBtn.TextSize = 12
    SelectedBtn.AutoButtonColor = false
    
    addCorner(SelectedBtn, 4)
    
    local expanded = false
    
    SelectedBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        Dropdown.Size = expanded and UDim2.new(1, -10, 0, 40 + 35 * #options) or UDim2.new(1, -10, 0, 40)
    end)
    
    for i, option in ipairs(options) do
        local OptionBtn = Instance.new("TextButton")
        OptionBtn.Parent = Dropdown
        OptionBtn.BackgroundColor3 = Colors.ElementHover
        OptionBtn.Position = UDim2.new(0.7, 0, 0.1 + i * 0.2, 0)
        OptionBtn.Size = UDim2.new(0.25, 0, 0.15, 0)
        OptionBtn.Font = Enum.Font.Gotham
        OptionBtn.Text = option
        OptionBtn.TextColor3 = Colors.Text
        OptionBtn.TextSize = 12
        OptionBtn.AutoButtonColor = false
        OptionBtn.Visible = false
        
        addCorner(OptionBtn, 4)
        
        OptionBtn.MouseButton1Click:Connect(function()
            SelectedBtn.Text = option
            expanded = false
            Dropdown.Size = UDim2.new(1, -10, 0, 40)
            if callback then
                pcall(callback, option)
            end
        end)
    end
    
    return Dropdown
end

-- Create label
function Catraz:CreateLabel(parent, text, color)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -10, 0, 30)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = color or Colors.TextDim
    Label.TextSize = 14
    Label.TextWrapped = true
    return Label
end

-- ====================================================
-- SCRIPT MODULES
-- ====================================================

-- Teleport Zones Module
local TeleportZones = {
    Name = "Teleport Zones",
    Description = "Create and teleport between zones",
    Zones = {},
    Active = false
}

function TeleportZones:Load(content)
    local section = Catraz:CreateSection(content, "Teleport Zones")
    
    Catraz:CreateLabel(section, "Create up to 5 teleport zones")
    
    local zoneStatus = Catraz:CreateLabel(section, "Zones: 0/5")
    
    local createBtn = Catraz:CreateButton(section, "Create Zone", function()
        local player = Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = player.Character.HumanoidRootPart.Position
            local zoneNum = #self.Zones + 1
            
            if zoneNum <= 5 then
                table.insert(self.Zones, {
                    Name = "Zone " .. zoneNum,
                    Position = pos
                })
                
                local zoneBtn = Catraz:CreateButton(section, "Zone " .. zoneNum .. " (Click to teleport)", function()
                    local player = Players.LocalPlayer
                    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(self.Zones[zoneNum].Position)
                    end
                end)
                
                zoneStatus.Text = "Zones: " .. #self.Zones .. "/5"
            end
        end
    end)
    
    local clearBtn = Catraz:CreateButton(section, "Clear All Zones", function()
        self.Zones = {}
        zoneStatus.Text = "Zones: 0/5"
        -- Refresh section (simplified)
        section.Parent:ClearAllChildren()
        self:Load(content)
    end)
end

-- Auto Tap Module
local AutoTap = {
    Name = "Auto Tap",
    Description = "Automatically clicks for you",
    Active = false,
    CPS = 10,
    Connection = nil
}

function AutoTap:Load(content)
    local section = Catraz:CreateSection(content, "Auto Tap")
    
    local status = Catraz:CreateLabel(section, "Status: OFF", Color3.fromRGB(255, 100, 100))
    
    local toggle = Catraz:CreateToggle(section, "Enable Auto Tap", false, function(state)
        self.Active = state
        status.Text = state and "Status: ON" or "Status: OFF"
        status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if state then
            self:Start()
        else
            self:Stop()
        end
    end)
    
    local slider = Catraz:CreateSlider(section, "CPS", 1, 20, self.CPS, function(value)
        self.CPS = value
    end)
end

function AutoTap:Start()
    if self.Connection then self.Connection:Disconnect() end
    
    self.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if self.Active then
            mouse1click()
            task.wait(1 / self.CPS)
        end
    end)
end

function AutoTap:Stop()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

-- Auto Farm Module
local AutoFarm = {
    Name = "Auto Farm",
    Description = "Automatically farms objects",
    Active = false,
    Target = nil,
    Connection = nil
}

function AutoFarm:Load(content)
    local section = Catraz:CreateSection(content, "Auto Farm")
    
    local status = Catraz:CreateLabel(section, "Status: OFF", Color3.fromRGB(255, 100, 100))
    
    local scanBtn = Catraz:CreateButton(section, "Scan for Farmable Objects", function()
        local farmable = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and (obj.Name:lower():find("farm") or obj.Name:lower():find("ore") or obj.Name:lower():find("node")) then
                table.insert(farmable, obj)
            end
        end
        
        if #farmable > 0 then
            self.Target = farmable[1]
            Catraz:CreateLabel(section, "Found " .. #farmable .. " objects")
        else
            Catraz:CreateLabel(section, "No farmable objects found")
        end
    end)
    
    local toggle = Catraz:CreateToggle(section, "Enable Auto Farm", false, function(state)
        self.Active = state
        status.Text = state and "Status: ON" or "Status: OFF"
        status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if state then
            self:Start()
        else
            self:Stop()
        end
    end)
end

function AutoFarm:Start()
    if self.Connection then self.Connection:Disconnect() end
    
    self.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if self.Active and self.Target then
            local player = Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(self.Target.Position + Vector3.new(0, 3, 0))
                mouse1click()
                task.wait(0.1)
            end
        end
    end)
end

function AutoFarm:Stop()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

-- Auto Rebirth Module
local AutoRebirth = {
    Name = "Auto Rebirth",
    Description = "Automatically rebirths",
    Active = false,
    Price = 1000,
    Connection = nil
}

function AutoRebirth:Load(content)
    local section = Catraz:CreateSection(content, "Auto Rebirth")
    
    local status = Catraz:CreateLabel(section, "Status: OFF", Color3.fromRGB(255, 100, 100))
    
    local priceSlider = Catraz:CreateSlider(section, "Rebirth Price", 100, 10000, self.Price, function(value)
        self.Price = value
    end)
    
    local toggle = Catraz:CreateToggle(section, "Enable Auto Rebirth", false, function(state)
        self.Active = state
        status.Text = state and "Status: ON" or "Status: OFF"
        status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if state then
            self:Start()
        else
            self:Stop()
        end
    end)
end

function AutoRebirth:Start()
    if self.Connection then self.Connection:Disconnect() end
    
    self.Connection = game:GetService("RunService").Stepped:Connect(function()
        if self.Active then
            for _, obj in ipairs(Players.LocalPlayer.PlayerGui:GetDescendants()) do
                if obj:IsA("TextButton") and obj.Name:lower():find("rebirth") then
                    obj:Click()
                    break
                end
            end
        end
    end)
end

function AutoRebirth:Stop()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

-- Auto Enchant Module
local AutoEnchant = {
    Name = "Auto Enchant",
    Description = "Automatically enchants items",
    Active = false,
    EnchantType = "Damage",
    Connection = nil
}

function AutoEnchant:Load(content)
    local section = Catraz:CreateSection(content, "Auto Enchant")
    
    local status = Catraz:CreateLabel(section, "Status: OFF", Color3.fromRGB(255, 100, 100))
    
    local enchantInput = Instance.new("TextBox")
    enchantInput.Parent = section
    enchantInput.BackgroundColor3 = Colors.Element
    enchantInput.Size = UDim2.new(1, -10, 0, 35)
    enchantInput.Font = Enum.Font.Gotham
    enchantInput.PlaceholderText = "Enchant type (e.g., Damage)"
    enchantInput.Text = self.EnchantType
    enchantInput.TextColor3 = Colors.Text
    enchantInput.TextSize = 14
    
    addCorner(enchantInput, 6)
    
    enchantInput.FocusLost:Connect(function()
        if enchantInput.Text ~= "" then
            self.EnchantType = enchantInput.Text
        end
    end)
    
    local toggle = Catraz:CreateToggle(section, "Enable Auto Enchant", false, function(state)
        self.Active = state
        status.Text = state and "Status: ON" or "Status: OFF"
        status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if state then
            self:Start()
        else
            self:Stop()
        end
    end)
end

function AutoEnchant:Start()
    if self.Connection then self.Connection:Disconnect() end
    
    self.Connection = game:GetService("RunService").Stepped:Connect(function()
        if self.Active then
            for _, obj in ipairs(Players.LocalPlayer.PlayerGui:GetDescendants()) do
                if obj:IsA("TextButton") and obj.Name:lower():find(self.EnchantType:lower()) then
                    obj:Click()
                    task.wait(0.5)
                    break
                end
            end
        end
    end)
end

function AutoEnchant:Stop()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

-- WalkBoost Module
local WalkBoost = {
    Name = "WalkBoost",
    Description = "Increase walk speed",
    Active = false,
    Speed = 50,
    OriginalSpeed = 16
}

function WalkBoost:Load(content)
    local section = Catraz:CreateSection(content, "WalkBoost")
    
    local status = Catraz:CreateLabel(section, "Status: OFF", Color3.fromRGB(255, 100, 100))
    
    local speedSlider = Catraz:CreateSlider(section, "Walk Speed", 16, 250, self.Speed, function(value)
        self.Speed = value
        if self.Active then
            self:Apply()
        end
    end)
    
    local toggle = Catraz:CreateToggle(section, "Enable WalkBoost", false, function(state)
        self.Active = state
        status.Text = state and "Status: ON" or "Status: OFF"
        status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if state then
            self:Apply()
        else
            self:Reset()
        end
    end)
end

function WalkBoost:Apply()
    local player = Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            self.OriginalSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = self.Speed
        end
    end
end

function WalkBoost:Reset()
    local player = Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = self.OriginalSpeed
        end
    end
end

-- JumpBoost Module
local JumpBoost = {
    Name = "JumpBoost",
    Description = "Increase jump power",
    Active = false,
    Power = 100,
    OriginalPower = 50
}

function JumpBoost:Load(content)
    local section = Catraz:CreateSection(content, "JumpBoost")
    
    local status = Catraz:CreateLabel(section, "Status: OFF", Color3.fromRGB(255, 100, 100))
    
    local powerSlider = Catraz:CreateSlider(section, "Jump Power", 50, 500, self.Power, function(value)
        self.Power = value
        if self.Active then
            self:Apply()
        end
    end)
    
    local toggle = Catraz:CreateToggle(section, "Enable JumpBoost", false, function(state)
        self.Active = state
        status.Text = state and "Status: ON" or "Status: OFF"
        status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if state then
            self:Apply()
        else
            self:Reset()
        end
    end)
end

function JumpBoost:Apply()
    local player = Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            self.OriginalPower = humanoid.JumpPower
            humanoid.JumpPower = self.Power
        end
    end
end

function JumpBoost:Reset()
    local player = Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = self.OriginalPower
        end
    end
end

-- Auto Click Module
local AutoClick = {
    Name = "Auto Click",
    Description = "Simple auto clicker",
    Active = false,
    CPS = 10,
    Connection = nil
}

function AutoClick:Load(content)
    local section = Catraz:CreateSection(content, "Auto Click")
    
    local status = Catraz:CreateLabel(section, "Status: OFF", Color3.fromRGB(255, 100, 100))
    
    local slider = Catraz:CreateSlider(section, "CPS", 1, 30, self.CPS, function(value)
        self.CPS = value
    end)
    
    local toggle = Catraz:CreateToggle(section, "Enable Auto Click", false, function(state)
        self.Active = state
        status.Text = state and "Status: ON" or "Status: OFF"
        status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        if state then
            self:Start()
        else
            self:Stop()
        end
    end)
end

function AutoClick:Start()
    if self.Connection then self.Connection:Disconnect() end
    
    self.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if self.Active then
            mouse1click()
            task.wait(1 / self.CPS)
        end
    end)
end

function AutoClick:Stop()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

-- ====================================================
-- MAIN WINDOW CREATION
-- ====================================================

-- Create main window
local Window = Catraz:CreateWindow(
    "SCRIPT FUSION", 
    "Catraz UI Edition - 8 Scripts", 
    UDim2.new(0, 700, 0, 500)
)

-- Create tabs
local Tabs = Catraz:CreateTabs(Window.Content, {
    {Name = "Movement"},
    {Name = "Automation"},
    {Name = "Boost"},
    {Name = "Click"},
    {Name = "About"}
})

-- Movement Tab
local function setupMovementTab()
    Catraz:CreateLabel(Tabs[1], "Movement Scripts", Colors.Accent)
    TeleportZones:Load(Tabs[1])
end

-- Automation Tab
local function setupAutomationTab()
    Catraz:CreateLabel(Tabs[2], "Automation Scripts", Colors.Accent)
    AutoFarm:Load(Tabs[2])
    AutoRebirth:Load(Tabs[2])
    AutoEnchant:Load(Tabs[2])
end

-- Boost Tab
local function setupBoostTab()
    Catraz:CreateLabel(Tabs[3], "Boost Scripts", Colors.Accent)
    WalkBoost:Load(Tabs[3])
    JumpBoost:Load(Tabs[3])
end

-- Click Tab
local function setupClickTab()
    Catraz:CreateLabel(Tabs[4], "Click Scripts", Colors.Accent)
    AutoTap:Load(Tabs[4])
    AutoClick:Load(Tabs[4])
end

-- About Tab
local function setupAboutTab()
    Catraz:CreateLabel(Tabs[5], "About Script Fusion", Colors.Accent)
    Catraz:CreateLabel(Tabs[5], "Version: 2.0.0")
    Catraz:CreateLabel(Tabs[5], "UI: Catraz Edition")
    Catraz:CreateLabel(Tabs[5], "")
    Catraz:CreateLabel(Tabs[5], "Features:")
    Catraz:CreateLabel(Tabs[5], "• 8 Built-in Scripts")
    Catraz:CreateLabel(Tabs[5], "• No Keys Required")
    Catraz:CreateLabel(Tabs[5], "• Catraz UI Design")
    Catraz:CreateLabel(Tabs[5], "• Draggable Windows")
    Catraz:CreateLabel(Tabs[5], "• Smooth Animations")
    Catraz:CreateLabel(Tabs[5], "")
    Catraz:CreateLabel(Tabs[5], "Created: March 16, 2026")
    
    Catraz:CreateButton(Tabs[5], "Unload All Scripts", function()
        AutoTap:Stop()
        AutoFarm:Stop()
        AutoRebirth:Stop()
        AutoEnchant:Stop()
        WalkBoost:Reset()
        JumpBoost:Reset()
        AutoClick:Stop()
        
        WalkBoost.Active = false
        JumpBoost.Active = false
        
        Catraz:CreateLabel(Tabs[5], "All scripts unloaded!", Colors.Success)
    end)
end

-- Initialize all tabs
setupMovementTab()
setupAutomationTab()
setupBoostTab()
setupClickTab()
setupAboutTab()

-- Close button functionality
Window.CloseBtn.MouseButton1Click:Connect(function()
    -- Cleanup all scripts
    AutoTap:Stop()
    AutoFarm:Stop()
    AutoRebirth:Stop()
    AutoEnchant:Stop()
    WalkBoost:Reset()
    JumpBoost:Reset()
    AutoClick:Stop()
    
    Window.ScreenGui:Destroy()
end)

-- Welcome notification
local Notification = Instance.new("ScreenGui")
local NotifFrame = Instance.new("Frame")
local NotifText = Instance.new("TextLabel")

Notification.Name = "WelcomeNotification"
Notification.Parent = game:GetService("CoreGui")
Notification.ResetOnSpawn = false
Notification.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

NotifFrame.Parent = Notification
NotifFrame.BackgroundColor3 = Colors.Surface
NotifFrame.BorderSizePixel = 0
NotifFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
NotifFrame.Size = UDim2.new(0, 300, 0, 50)

addCorner(NotifFrame, 8)
addStroke(NotifFrame, 1, Colors.Accent)

NotifText.Parent = NotifFrame
NotifText.BackgroundTransparency = 1
NotifText.Size = UDim2.new(1, 0, 1, 0)
NotifText.Font = Enum.Font.GothamBold
NotifText.Text = "Script Fusion loaded successfully!"
NotifText.TextColor3 = Colors.Accent
NotifText.TextSize = 14

-- Animate notification
local startPos = NotifFrame.Position
NotifFrame.Position = UDim2.new(0.5, -150, 0, -50)

TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = startPos
}):Play()

task.wait(3)

TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
    Position = UDim2.new(0.5, -150, 0, -50)
}):Play()

task.wait(0.5)
Notification:Destroy()

print("=== SCRIPT FUSION - CATRAZ UI EDITION LOADED ===")
print("8 scripts ready to use")