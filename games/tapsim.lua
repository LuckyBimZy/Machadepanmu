-- Nexus System - No Key Required Version
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInput = game:GetService("UserInputService")

local player = players.LocalPlayer

-- Color Constants
local colors = {
    BORDER_DIM = Color3.fromRGB(5, 5, 5),
    NEON_GREEN = Color3.fromRGB(0, 255, 0),
    NEON_RED = Color3.fromRGB(255, 0, 0),
    NEON_AMBER = Color3.fromRGB(255, 191, 0),
    NEON_BLUE = Color3.fromRGB(0, 157, 255),
    BG_VOID = Color3.fromRGB(15, 15, 15),
    BG_PANEL = Color3.fromRGB(25, 25, 25),
    BG_INPUT = Color3.fromRGB(35, 35, 35),
    TEXT_DIM = Color3.fromRGB(150, 150, 150),
    TEXT_MID = Color3.fromRGB(200, 200, 200),
    TEXT_BRIGHT = Color3.fromRGB(255, 255, 255),
    SUCCESS = Color3.fromRGB(0, 255, 0),
    ERROR = Color3.fromRGB(255, 0, 0)
}

-- Success Callback
local ON_SUCCESS = function()
    print("NEXUS // SYSTEM LOADED SUCCESSFULLY - WELCOME!")
    -- Tambahkan script utama kalian di sini
    -- Contoh: loadstring(game:HttpGet("https://raw.githubusercontent.com/.../main/script.lua"))()
end

-- Utility Functions
local function tweenObject(obj, properties, duration, easingStyle, easingDirection)
    local tween = tweenService:Create(obj, 
        TweenInfo.new(duration or 0.3, 
        easingStyle or Enum.EasingStyle.Quint, 
        easingDirection or Enum.EasingDirection.Out), 
        properties)
    tween:Play()
    return tween
end

local function createInstance(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        pcall(function()
            instance[prop] = value
        end)
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function createUIPadding(amount)
    return createInstance("UIPadding", {
        PaddingTop = UDim.new(0, amount or 6),
        PaddingBottom = UDim.new(0, amount or 6),
        PaddingLeft = UDim.new(0, amount or 6),
        PaddingRight = UDim.new(0, amount or 6)
    })
end

local function createStroke(parent, color, thickness, transparency)
    return createInstance("UIStroke", {
        Color = color or colors.BORDER_DIM,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Enabled = true,
        Parent = parent
    })
end

local function typewriterEffect(textLabel, text, delay, color)
    textLabel.Text = ""
    if color then
        textLabel.TextColor3 = color
    end
    for i = 1, #text do
        if not textLabel or not textLabel.Parent then return end
        textLabel.Text = text:sub(1, i)
        task.wait(delay or 0.05)
    end
end

local function generateSessionID()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, 8 do
        result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

-- Cleanup existing GUI
pcall(function()
    if game:GetService("CoreGui"):FindFirstChild("NexusSystem") then
        game:GetService("CoreGui"):FindFirstChild("NexusSystem"):Destroy()
    end
end)

pcall(function()
    if player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("NexusSystem") then
        player.PlayerGui.NexusSystem:Destroy()
    end
end)

-- Create Main GUI
local screenGui = createInstance("ScreenGui", {
    Name = "NexusSystem",
    DisplayOrder = 10,
    ResetOnSpawn = true,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local success, parent = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Background
local background = createInstance("Frame", {
    Name = "Background",
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = colors.BG_VOID,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = screenGui
})

-- Glow Effect
local glowEffect = createInstance("Frame", {
    Name = "GlowEffect",
    Size = UDim2.new(1, 0, 0, 60),
    Position = UDim2.new(0, 0, -0.1, 0),
    BackgroundColor3 = colors.NEON_GREEN,
    BackgroundTransparency = 0.95,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = background
})

-- Glow animation
task.spawn(function()
    while screenGui and screenGui.Parent do
        glowEffect.Position = UDim2.new(0, 0, -0.1, 0)
        tweenObject(glowEffect, {
            Position = UDim2.new(0, 0, 1.1, 0)
        }, 4, Enum.EasingStyle.Linear)
        task.wait(5)
    end
end)

-- Main Frame
local mainFrame = createInstance("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 450, 0, 350),
    Position = UDim2.new(0.5, -225, 0.5, -175),
    BackgroundColor3 = colors.BG_PANEL,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 10,
    Parent = screenGui
})
createUIPadding(mainFrame, 6)
local mainStroke = createStroke(mainFrame, colors.NEON_GREEN, 1, 0.5)

-- Top Bar
local topBar = createInstance("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(8, 8, 18),
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    ZIndex = 11,
    Parent = mainFrame
})
createUIPadding(topBar, 6)

-- Top Bar Elements
createInstance("TextLabel", {
    Name = "TopBarLine",
    Text = "══════════════════════════",
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = Color3.fromRGB(8, 10, 18),
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    TextColor3 = colors.TEXT_DIM,
    TextScaled = true,
    Font = Enum.Font.Code,
    ZIndex = 12,
    Parent = topBar
})

createInstance("TextLabel", {
    Name = "TopBarGlow",
    Text = "▂",
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = colors.NEON_GREEN,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 21,
    Parent = topBar
})

-- Title
createInstance("TextLabel", {
    Name = "Title",
    Text = "⚡ NEXUS // LOADER",
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = colors.NEON_GREEN,
    TextScaled = true,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 14,
    Parent = topBar
})

-- Close Button
local closeButton = createInstance("TextButton", {
    Name = "CloseButton",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -38, 0, -15),
    BackgroundColor3 = colors.NEON_RED,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = colors.NEON_RED,
    TextScaled = true,
    Font = Enum.Font.Code,
    AutoButtonColor = false,
    ZIndex = 22,
    Parent = topBar
})
createUIPadding(closeButton, 4)

-- Close Button Events
closeButton.MouseEnter:Connect(function()
    tweenObject(closeButton, {
        BackgroundTransparency = 0.3,
        TextColor3 = Color3.fromRGB(255, 100, 100)
    }, 0.15)
end)

closeButton.MouseLeave:Connect(function()
    tweenObject(closeButton, {
        BackgroundTransparency = 0.8,
        TextColor3 = colors.NEON_RED
    }, 0.15)
end)

closeButton.MouseButton1Click:Connect(function()
    tweenObject(mainFrame, {
        Size = UDim2.new(0, 450, 0, 40)
    }, 0.3, Enum.EasingStyle.Quint)
    tweenObject(background, {
        BackgroundTransparency = 1
    }, 0.3)
    task.wait(0.35)
    screenGui:Destroy()
end)

-- Dragging Functionality
local dragging = false
local dragInput, dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

userInput.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Content Frame
local contentFrame = createInstance("Frame", {
    Name = "ContentFrame",
    Size = UDim2.new(1, -40, 1, -60),
    Position = UDim2.new(0, 20, 0, 50),
    BackgroundColor3 = colors.BG_INPUT,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 12,
    Parent = mainFrame
})
createUIPadding(contentFrame, 15)
createStroke(contentFrame, colors.BORDER_DIM, 1, 0)

-- Welcome Text
local welcomeLabel = createInstance("TextLabel", {
    Name = "WelcomeLabel",
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = colors.NEON_GREEN,
    TextScaled = true,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 13,
    Parent = contentFrame
})

-- Status Label
local statusLabel = createInstance("TextLabel", {
    Name = "StatusLabel",
    Size = UDim2.new(1, 0, 0, 60),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = colors.TEXT_MID,
    TextScaled = true,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 13,
    Parent = contentFrame
})

-- Loading Bar
local loadingBar = createInstance("Frame", {
    Name = "LoadingBar",
    Size = UDim2.new(1, 0, 0, 4),
    Position = UDim2.new(0, 0, 0, 120),
    BackgroundColor3 = colors.BG_PANEL,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 13,
    Parent = contentFrame
})
createStroke(loadingBar, colors.BORDER_DIM, 1, 0.5)

local loadingBarFill = createInstance("Frame", {
    Name = "LoadingBarFill",
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = colors.NEON_GREEN,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    ZIndex = 14,
    Parent = loadingBar
})

-- Session Info
local sessionLabel = createInstance("TextLabel", {
    Name = "SessionLabel",
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 140),
    BackgroundTransparency = 1,
    Text = "SESSION: " .. generateSessionID(),
    TextColor3 = colors.TEXT_DIM,
    TextScaled = true,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 13,
    Parent = contentFrame
})

-- User Info
local userLabel = createInstance("TextLabel", {
    Name = "UserLabel",
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 190),
    BackgroundTransparency = 1,
    Text = "USER: " .. player.Name,
    TextColor3 = colors.TEXT_DIM,
    TextScaled = true,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 13,
    Parent = contentFrame
})

-- Load Button
local loadButton = createInstance("TextButton", {
    Name = "LoadButton",
    Size = UDim2.new(0.6, 0, 0, 40),
    Position = UDim2.new(0.2, 0, 0, 240),
    BackgroundColor3 = Color3.fromRGB(0, 40, 22),
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Text = "▶ LOAD SCRIPT",
    TextColor3 = colors.NEON_GREEN,
    TextScaled = true,
    Font = Enum.Font.Code,
    AutoButtonColor = false,
    ZIndex = 14,
    Parent = contentFrame
})
createUIPadding(loadButton, 8)
local loadButtonStroke = createStroke(loadButton, colors.NEON_GREEN, 1, 0.3)

-- Load Button Events
loadButton.MouseEnter:Connect(function()
    tweenObject(loadButton, {
        BackgroundColor3 = Color3.fromRGB(0, 60, 35)
    }, 0.15)
    tweenObject(loadButtonStroke, {
        Transparency = 0
    }, 0.15)
end)

loadButton.MouseLeave:Connect(function()
    tweenObject(loadButton, {
        BackgroundColor3 = Color3.fromRGB(0, 40, 22)
    }, 0.15)
    tweenObject(loadButtonStroke, {
        Transparency = 0.3
    }, 0.15)
end)

-- Load Button Click
loadButton.MouseButton1Click:Connect(function()
    -- Disable button during loading
    loadButton.Text = "⏳ LOADING..."
    loadButton.Active = false
    
    -- Start loading animation
    tweenObject(loadingBarFill, {
        Size = UDim2.new(1, 0, 1, 0)
    }, 2, Enum.EasingStyle.Quad)
    
    -- Update status
    statusLabel.TextColor3 = colors.NEON_AMBER
    typewriterEffect(statusLabel, "INITIALIZING SYSTEM...", 0.03, colors.NEON_AMBER)
    
    task.wait(1)
    
    typewriterEffect(statusLabel, "LOADING MODULES...", 0.03, colors.NEON_AMBER)
    
    task.wait(1)
    
    typewriterEffect(statusLabel, "✓ SYSTEM READY", 0.03, colors.SUCCESS)
    
    -- Success animation
    loadButton.Text = "✓ LOADED"
    loadButton.TextColor3 = colors.SUCCESS
    loadButtonStroke.Color = colors.SUCCESS
    loadingBarFill.BackgroundColor3 = colors.SUCCESS
    
    task.wait(0.5)
    
    -- Close GUI
    tweenObject(mainFrame, {
        Size = UDim2.new(0, 450, 0, 40)
    }, 0.3, Enum.EasingStyle.Quint)
    tweenObject(background, {
        BackgroundTransparency = 1
    }, 0.3)
    
    task.wait(0.35)
    screenGui:Destroy()
    
    -- Execute main script
    ON_SUCCESS()
end)

-- Startup Animation
task.spawn(function()
    mainFrame.BackgroundTransparency = 0
    mainFrame.Size = UDim2.new(0, 450, 0, 40)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    
    task.wait(0.1)
    
    tweenObject(mainFrame, {
        Size = UDim2.new(0, 450, 0, 350)
    }, 0.5, Enum.EasingStyle.Quint)
    
    task.wait(0.5)
    
    typewriterEffect(welcomeLabel, "⚡ WELCOME TO NEXUS ⚡", 0.03, colors.NEON_GREEN)
    
    task.wait(0.3)
    
    typewriterEffect(statusLabel, "SYSTEM READY - CLICK LOAD TO CONTINUE", 0.03, colors.TEXT_MID)
end)

-- Display Order Animation
task.spawn(function()
    while screenGui and screenGui.Parent do
        screenGui.DisplayOrder = 999
        task.wait(2)
    end
end)

print("NEXUS SYSTEM LOADED SUCCESSFULLY - NO KEY REQUIRED")