--[[
    ====================================================
    SCRIPT FUSION - ALL IN ONE EXECUTABLE
    Combines multiple scripts into a single file
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
-- KEY SYSTEM UI CREATION (Shared across all scripts)
-- ====================================================

local function createKeyUI(scriptName)
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local KeyInput = Instance.new("TextBox")
    local SubmitButton = Instance.new("TextButton")
    local GetKeyButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    
    -- Configure ScreenGui
    ScreenGui.Name = "KeySystemUI_" .. scriptName
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Configure MainFrame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 220)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Add a subtle gradient or corner rounding (optional)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    -- Configure Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = scriptName .. " - Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16.000
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title
    
    -- Configure KeyInput
    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0.5, -125, 0.3, 5)
    KeyInput.Size = UDim2.new(0, 250, 0, 35)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14.000
    KeyInput.ClearTextOnFocus = false
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = KeyInput
    
    -- Configure SubmitButton
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Parent = MainFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Position = UDim2.new(0.5, -110, 0.55, 0)
    SubmitButton.Size = UDim2.new(0, 100, 0, 35)
    SubmitButton.Font = Enum.Font.GothamSemibold
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14.000
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 6)
    SubmitCorner.Parent = SubmitButton
    
    -- Configure GetKeyButton
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Parent = MainFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Position = UDim2.new(0.5, 10, 0.55, 0)
    GetKeyButton.Size = UDim2.new(0, 100, 0, 35)
    GetKeyButton.Font = Enum.Font.GothamSemibold
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14.000
    
    local GetCorner = Instance.new("UICorner")
    GetCorner.CornerRadius = UDim.new(0, 6)
    GetCorner.Parent = GetKeyButton
    
    -- Configure StatusLabel
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.85, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Please enter your key"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 12.000
    
    return {
        ScreenGui = ScreenGui,
        KeyInput = KeyInput,
        SubmitButton = SubmitButton,
        GetKeyButton = GetKeyButton,
        StatusLabel = StatusLabel
    }
end

-- ====================================================
-- KEY VERIFICATION FUNCTION
-- ====================================================

local function verifyKey(key)
    local url = "https://luarmor.org/?verify=1&key=" .. key
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        if response == "valid" then
            return true, "valid"
        elseif response == "expired" then
            return false, "expired"
        elseif response == "used" then
            return false, "used"
        else
            return false, "invalid"
        end
    else
        return false, "error"
    end
end

-- ====================================================
-- SCRIPT SELECTION UI
-- ====================================================

local function createScriptSelector()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Subtitle = Instance.new("TextLabel")
    local ScrollingFrame = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local StatusLabel = Instance.new("TextLabel")
    
    -- Configure ScreenGui
    ScreenGui.Name = "ScriptSelectorUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Configure MainFrame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Configure Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = "SCRIPT FUSION - SELECT A SCRIPT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18.000
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Configure Subtitle
    Subtitle.Name = "Subtitle"
    Subtitle.Parent = MainFrame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 0, 0.12, 0)
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Choose a script to execute (requires key verification)"
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextSize = 14.000
    
    -- Configure ScrollingFrame
    ScrollingFrame.Name = "ScriptList"
    ScrollingFrame.Parent = MainFrame
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    ScrollingFrame.Size = UDim2.new(0.9, 0, 0.65, 0)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 8
    ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    
    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 8)
    ScrollCorner.Parent = ScrollingFrame
    
    -- Configure UIListLayout
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    
    -- Configure StatusLabel
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.9, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Click any script to begin key verification"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 12.000
    
    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ScrollingFrame = ScrollingFrame,
        UIListLayout = UIListLayout,
        StatusLabel = StatusLabel
    }
end

-- ====================================================
-- SCRIPT DEFINITIONS
-- ====================================================

local scripts = {
    {
        name = "TeleportZones",
        description = "Teleport between different zones",
        category = "Movement",
        mainScript = function()
            -- Original TeleportZones script logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/bigbeanscripts/TapSim/refs/heads/main/Main"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "Teleports",
        description = "Advanced teleportation system",
        category = "Movement",
        mainScript = function()
            -- Original Teleports script logic
            local Games = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/tapsim'))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "Teleport",
        description = "Basic teleport functionality",
        category = "Movement",
        mainScript = function()
            -- Original Teleport script logic
            local Games = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/tapsim'))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "SmoothUI",
        description = "Smooth user interface",
        category = "UI",
        mainScript = function()
            -- Original SmoothUI script logic
            local Games = loadstring(game:HttpGet("https://gist.githubusercontent.com/whoisnwr/5e7e84f108f429d64ff47ec160dd1883/raw/"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "Rewards",
        description = "Automated rewards system",
        category = "Automation",
        mainScript = function()
            -- Original Rewards script logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/bigbeanscripts/TapSim/refs/heads/main/Main"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "QuickProgress",
        description = "Fast progress automation",
        category = "Automation",
        mainScript = function()
            -- Original QuickProgress script logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "OPScript",
        description = "OP script with multiple features",
        category = "OP",
        mainScript = function()
            -- Original OPScript logic
            local Games = loadstring(game:HttpGet("https://gist.githubusercontent.com/whoisnwr/5e7e84f108f429d64ff47ec160dd1883/raw/"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "OPFreeScript",
        description = "Free OP script",
        category = "OP",
        mainScript = function()
            -- Original OPFreeScript logic
            local Games = loadstring(game:HttpGet("https://gist.githubusercontent.com/whoisnwr/5e7e84f108f429d64ff47ec160dd1883/raw/"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "OPCraftingScript",
        description = "OP crafting automation",
        category = "OP",
        mainScript = function()
            -- Original OPCraftingScript logic
            local Games = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/tapsim'))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "KeylessV2",
        description = "Keyless version 2 script",
        category = "Keyless",
        mainScript = function()
            -- Original KeylessV2 logic
            local Games = loadstring(game:HttpGet("https://gist.githubusercontent.com/gerelyncontiga-dot/de66cf3790f609468117ecebda06c30d/raw/e5f3f65ec51fccf22588fc7f455de77d247f7ad1/Tap%2520simulator%2520v41.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "KeylessScript",
        description = "Basic keyless script",
        category = "Keyless",
        mainScript = function()
            -- Original KeylessScript logic
            local Games = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/tapsim'))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "FullProgressAutomation",
        description = "Complete progress automation",
        category = "Automation",
        mainScript = function()
            -- Original FullProgressAutomation logic
            local Games = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/tapsim'))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "EggSystem",
        description = "Automated egg hatching system",
        category = "Automation",
        mainScript = function()
            -- Original EggSystem logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/bigbeanscripts/TapSim/refs/heads/main/Main"))() 
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "BestAutoEnchant",
        description = "Best auto enchant system",
        category = "Enchant",
        mainScript = function()
            -- Original BestAutoEnchant logic
            local Games = loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/bc8e3326ded9dbd4f9f5b8089c393fc5.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "BalancedAutoFarmScript",
        description = "Balanced auto farm script",
        category = "Farm",
        mainScript = function()
            -- Original BalancedAutoFarmScript logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/bigbeanscripts/TapSim/refs/heads/main/Main"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "AutoUnlock",
        description = "Auto unlock features",
        category = "Automation",
        mainScript = function()
            -- Original AutoUnlock logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "AutoTapKeyless",
        description = "Keyless auto tap",
        category = "Tap",
        mainScript = function()
            -- Original AutoTapKeyless logic
            local Games = loadstring(game:HttpGet("https://gist.githubusercontent.com/gerelyncontiga-dot/de66cf3790f609468117ecebda06c30d/raw/e5f3f65ec51fccf22588fc7f455de77d247f7ad1/Tap%2520simulator%2520v41.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "AutoTap",
        description = "Basic auto tap",
        category = "Tap",
        mainScript = function()
            -- Original AutoTap logic
            local Games = loadstring(game:HttpGet("https://gist.githubusercontent.com/gerelyncontiga-dot/de66cf3790f609468117ecebda06c30d/raw/e5f3f65ec51fccf22588fc7f455de77d247f7ad1/Tap%2520simulator%2520v41.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "AutoRebirth",
        description = "Auto rebirth system",
        category = "Rebirth",
        mainScript = function()
            -- Original AutoRebirth logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "AutomationScript",
        description = "General automation script",
        category = "Automation",
        mainScript = function()
            -- Original AutomationScript logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/bigbeanscripts/TapSim/refs/heads/main/Main"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "Automations",
        description = "Multiple automations",
        category = "Automation",
        mainScript = function()
            -- Original Automations logic
            local Games = loadstring(game:HttpGet('https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/tapsim'))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "AutoFarm&Rebirth",
        description = "Farm and rebirth combined",
        category = "Farm",
        mainScript = function()
            -- Original AutoFarm&Rebirth logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "AutoFarm&Hatch",
        description = "Farm and hatch eggs",
        category = "Farm",
        mainScript = function()
            -- Original AutoFarm&Hatch logic
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    },
    {
        name = "AutoEnchant",
        description = "Auto enchant system",
        category = "Enchant",
        mainScript = function()
            -- Original AutoEnchant logic
            local Games = loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/bc8e3326ded9dbd4f9f5b8089c393fc5.lua"))()
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                end
            end
        end
    }
}

-- ====================================================
-- CREATE SCRIPT BUTTONS
-- ====================================================

local function createScriptButton(container, scriptData, onClickCallback)
    local Button = Instance.new("TextButton")
    local NameLabel = Instance.new("TextLabel")
    local DescLabel = Instance.new("TextLabel")
    local CategoryLabel = Instance.new("TextLabel")
    
    Button.Name = scriptData.name .. "Button"
    Button.Parent = container
    Button.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, -10, 0, 60)
    Button.AutoButtonColor = true
    Button.Font = Enum.Font.SourceSans
    Button.Text = ""
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    -- Name Label
    NameLabel.Name = "NameLabel"
    NameLabel.Parent = Button
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0.02, 0, 0.1, 0)
    NameLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
    NameLabel.Font = Enum.Font.GothamSemibold
    NameLabel.Text = scriptData.name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 16.000
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Description Label
    DescLabel.Name = "DescLabel"
    DescLabel.Parent = Button
    DescLabel.BackgroundTransparency = 1
    DescLabel.Position = UDim2.new(0.02, 0, 0.5, 0)
    DescLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.Text = scriptData.description
    DescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    DescLabel.TextSize = 12.000
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Category Label
    CategoryLabel.Name = "CategoryLabel"
    CategoryLabel.Parent = Button
    CategoryLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    CategoryLabel.BackgroundTransparency = 0.3
    CategoryLabel.Position = UDim2.new(0.82, 0, 0.2, 0)
    CategoryLabel.Size = UDim2.new(0.15, 0, 0.6, 0)
    CategoryLabel.Font = Enum.Font.Gotham
    CategoryLabel.Text = scriptData.category
    CategoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CategoryLabel.TextSize = 11.000
    
    local CategoryCorner = Instance.new("UICorner")
    CategoryCorner.CornerRadius = UDim.new(0, 4)
    CategoryCorner.Parent = CategoryLabel
    
    -- Hover effect
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(71, 85, 105)
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    end)
    
    Button.MouseButton1Click:Connect(function()
        onClickCallback(scriptData)
    end)
    
    return Button
end

-- ====================================================
-- KEY VERIFICATION PROCESS
-- ====================================================

local function startKeyVerification(scriptData, selectorUI)
    -- Close selector UI
    if selectorUI and selectorUI.ScreenGui then
        selectorUI.ScreenGui:Destroy()
    end
    
    -- Create key UI
    local ui = createKeyUI(scriptData.name)
    
    -- Handle Get Key button
    ui.GetKeyButton.MouseButton1Click:Connect(function()
        local keyWebsite = "https://luarmor.org/"
        
        local success, err = pcall(function()
            setclipboard(keyWebsite)
        end)
        
        if success then
            ui.StatusLabel.Text = "✓ URL copied to clipboard!"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            ui.StatusLabel.Text = "✗ Failed to copy. URL: " .. keyWebsite
            ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end)
    
    -- Handle Submit button
    ui.SubmitButton.MouseButton1Click:Connect(function()
        local key = ui.KeyInput.Text
        
        if key == "" then
            ui.StatusLabel.Text = "✗ Please enter a key!"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            return
        end
        
        ui.StatusLabel.Text = "⏳ Verifying key..."
        ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        -- Disable buttons during verification
        ui.SubmitButton.Active = false
        ui.SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        ui.GetKeyButton.Active = false
        ui.GetKeyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        task.delay(1.5, function()
            local isValid, status = verifyKey(key)
            
            if isValid then
                ui.StatusLabel.Text = "✓ Key verified successfully!"
                ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                task.delay(1, function()
                    ui.ScreenGui:Destroy()
                    
                    -- Run the main script
                    local success, err = pcall(scriptData.mainScript)
                    if not success then
                        warn("Error running script: " .. tostring(err))
                        
                        -- Show error notification
                        local notification = Instance.new("ScreenGui")
                        local frame = Instance.new("Frame")
                        local label = Instance.new("TextLabel")
                        
                        notification.Parent = game:GetService("CoreGui")
                        notification.Name = "ErrorNotification"
                        
                        frame.Parent = notification
                        frame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                        frame.Position = UDim2.new(0.5, -150, 0.8, 0)
                        frame.Size = UDim2.new(0, 300, 0, 50)
                        
                        local corner = Instance.new("UICorner")
                        corner.CornerRadius = UDim.new(0, 8)
                        corner.Parent = frame
                        
                        label.Parent = frame
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = "Error: " .. tostring(err):sub(1, 50)
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextWrapped = true
                        
                        task.delay(5, function()
                            notification:Destroy()
                        end)
                    end
                end)
            else
                -- Re-enable buttons
                ui.SubmitButton.Active = true
                ui.SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
                ui.GetKeyButton.Active = true
                ui.GetKeyButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
                
                if status == "expired" then
                    ui.StatusLabel.Text = "✗ This key has expired! Keys expire after 24 hours."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif status == "used" then
                    ui.StatusLabel.Text = "✗ This key has already been used!"
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif status == "error" then
                    ui.StatusLabel.Text = "✗ Connection error! Check your internet."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                else
                    ui.StatusLabel.Text = "✗ Invalid key! Please try again."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        end)
    end)
end

-- ====================================================
-- INITIALIZE SCRIPT SELECTOR
-- ====================================================

local function initScriptSelector()
    local selector = createScriptSelector()
    
    -- Create buttons for each script
    for _, scriptData in ipairs(scripts) do
        createScriptButton(selector.ScrollingFrame, scriptData, function(data)
            startKeyVerification(data, selector)
        end)
    end
    
    -- Update canvas size
    local count = #scripts
    local canvasHeight = count * 65
    selector.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    
    -- Add close button (optional)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = selector.MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.95, -20, 0.03, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14.000
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 12)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        selector.ScreenGui:Destroy()
    end)
    
    return selector
end

-- ====================================================
-- START THE APPLICATION
-- ====================================================

-- Welcome message
local function showWelcomeMessage()
    local messageGui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local message = Instance.new("TextLabel")
    local continueBtn = Instance.new("TextButton")
    
    messageGui.Name = "WelcomeMessage"
    messageGui.Parent = game:GetService("CoreGui")
    messageGui.ResetOnSpawn = false
    
    frame.Parent = messageGui
    frame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Active = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0.1, 0)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "SCRIPT FUSION"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24.000
    
    message.Parent = frame
    message.BackgroundTransparency = 1
    message.Position = UDim2.new(0, 0, 0.3, 0)
    message.Size = UDim2.new(1, 0, 0, 60)
    message.Font = Enum.Font.Gotham
    message.Text = "24 scripts combined into one file!\nSelect a script to begin key verification."
    message.TextColor3 = Color3.fromRGB(200, 200, 200)
    message.TextSize = 14.000
    message.TextWrapped = true
    
    continueBtn.Parent = frame
    continueBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    continueBtn.Position = UDim2.new(0.5, -75, 0.75, 0)
    continueBtn.Size = UDim2.new(0, 150, 0, 40)
    continueBtn.Font = Enum.Font.GothamSemibold
    continueBtn.Text = "CONTINUE"
    continueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    continueBtn.TextSize = 16.000
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = continueBtn
    
    continueBtn.MouseButton1Click:Connect(function()
        messageGui:Destroy()
        initScriptSelector()
    end)
    
    -- Auto-close after 5 seconds (optional)
    task.delay(5, function()
        if messageGui and messageGui.Parent then
            messageGui:Destroy()
            initScriptSelector()
        end
    end)
end

-- Start everything
print("=== SCRIPT FUSION LOADED ===")
print("Total scripts combined: " .. #scripts)
print("Loading interface...")

showWelcomeMessage()

-- Return info for debugging (optional)
return {
    scripts = scripts,
    version = "1.0.0",
    count = #scripts
}