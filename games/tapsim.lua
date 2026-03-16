-- ==================== TAP SIMULATOR - ULTIMATE COLLECTION ====================
-- Gabungan dari berbagai script dengan UI Catraz Hub
-- Version: 3.0 Ultimate Collection

if _G.TapSimLoaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Tap Simulator",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.TapSimLoaded = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- VARIABLES
--==================================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

--==================================================
-- KEY SYSTEM (DARI SEMUA SCRIPT)
--==================================================
local KeySystem = {
    Verified = false,
    UI = nil
}

-- Create Key System UI
local function createKeyUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local KeyInput = Instance.new("TextBox")
    local SubmitButton = Instance.new("TextButton")
    local GetKeyButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    
    -- Configure ScreenGui
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Configure MainFrame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    
    -- Configure Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = "Tap Simulator - Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16.000
    
    -- Configure KeyInput
    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0.5, -125, 0.3, 0)
    KeyInput.Size = UDim2.new(0, 250, 0, 30)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14.000
    
    -- Configure SubmitButton
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Parent = MainFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Position = UDim2.new(0.5, -60, 0.55, 0)
    SubmitButton.Size = UDim2.new(0, 120, 0, 30)
    SubmitButton.Font = Enum.Font.GothamSemibold
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14.000
    
    -- Configure GetKeyButton
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Parent = MainFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Position = UDim2.new(0.5, -60, 0.75, 0)
    GetKeyButton.Size = UDim2.new(0, 120, 0, 30)
    GetKeyButton.Font = Enum.Font.GothamSemibold
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14.000
    
    -- Configure StatusLabel
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.9, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 12.000
    
    return {
        ScreenGui = ScreenGui,
        KeyInput = KeyInput,
        SubmitButton = SubmitButton,
        GetKeyButton = GetKeyButton,
        StatusLabel = StatusLabel
    }
end

-- Verify key with server
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

-- Initialize key system
local function initKeySystem()
    local ui = createKeyUI()
    KeySystem.UI = ui
    
    -- Handle Get Key button
    ui.GetKeyButton.MouseButton1Click:Connect(function()
        local keyWebsite = "https://luarmor.org/"
        setclipboard(keyWebsite)
        ui.StatusLabel.Text = "Key website URL copied to clipboard! Paste in your browser."
        ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end)
    
    -- Handle Submit button
    ui.SubmitButton.MouseButton1Click:Connect(function()
        local key = ui.KeyInput.Text
        
        if key == "" then
            ui.StatusLabel.Text = "Please enter a key!"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            return
        end
        
        ui.StatusLabel.Text = "Verifying key..."
        ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        task.delay(1.5, function()
            local isValid, status = verifyKey(key)
            
            if isValid then
                ui.StatusLabel.Text = "Key verified successfully!"
                ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                task.delay(1, function()
                    ui.ScreenGui:Destroy()
                    KeySystem.Verified = true
                    -- Load main script after verification
                    loadMainScript()
                end)
            else
                if status == "expired" then
                    ui.StatusLabel.Text = "This key has expired! Keys expire after 24 hours."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif status == "used" then
                    ui.StatusLabel.Text = "This key has already been used!"
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                else
                    ui.StatusLabel.Text = "Invalid key! Please try again."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        end)
    end)
end

--==================================================
-- REMOTE FINDING (DARI SEMUA SCRIPT)
--==================================================
local Remotes = {
    Tap = nil,
    BuyEgg = nil,
    HatchEgg = nil,
    BuyArea = nil,
    Upgrade = nil,
    Collect = nil,
    Rebirth = nil,
    Click = nil,
    Purchase = nil,
    Claim = nil,
    Event = nil,
    Enchant = nil,
    Craft = nil,
    Unlock = nil
}

-- Fungsi untuk mencari remotes (gabungan dari semua script)
local function FindRemotes()
    -- Script 1: Pencarian di ReplicatedStorage
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            
            -- Tap/Click remotes
            if name:find("tap") or name:find("click") then
                Remotes.Tap = v
                Remotes.Click = v
            end
            
            -- Egg remotes
            if name:find("egg") then
                if name:find("buy") or name:find("purchase") then
                    Remotes.BuyEgg = v
                end
                if name:find("hatch") or name:find("open") then
                    Remotes.HatchEgg = v
                end
            end
            
            -- Upgrade remotes
            if name:find("upgrade") or name:find("power") or name:find("damage") then
                Remotes.Upgrade = v
            end
            
            -- Area remotes
            if name:find("area") or name:find("zone") then
                if name:find("buy") or name:find("unlock") then
                    Remotes.BuyArea = v
                end
            end
            
            -- Collection remotes
            if name:find("collect") or name:find("claim") or name:find("reward") then
                Remotes.Collect = v
                Remotes.Claim = v
            end
            
            -- Rebirth remotes
            if name:find("rebirth") or name:find("prestige") then
                Remotes.Rebirth = v
            end
            
            -- Enchant remotes
            if name:find("enchant") or name:find("enhance") then
                Remotes.Enchant = v
            end
            
            -- Craft remotes
            if name:find("craft") or name:find("forge") then
                Remotes.Craft = v
            end
            
            -- Unlock remotes
            if name:find("unlock") or name:find("open") then
                Remotes.Unlock = v
            end
        end
    end
    
    -- Cari di Player scripts
    for _, v in pairs(Player.PlayerScripts:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if (name:find("tap") or name:find("click")) and not Remotes.Tap then
                Remotes.Tap = v
            end
        end
    end
    
    -- Cari di Workspace untuk eggs
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("egg") and v:IsA("BasePart") and v.Transparency < 1 then
            table.insert(EggLocations, v)
        elseif v:IsA("Model") and v.Name:lower():find("egg") and v.PrimaryPart then
            table.insert(EggLocations, v.PrimaryPart)
        end
    end
    
    print("=== REMOTES FOUND ===")
    for k, v in pairs(Remotes) do
        print(k, v and "✓" or "✗")
    end
end

--==================================================
-- TOGGLES
--==================================================
local Toggles = {
    -- Auto Tap (dari AutoTap.lua, AutoTapKeyless.lua)
    AutoTap = false,
    TapSpeed = 0.01,
    AutoClicker = false,
    ClickSpeed = 0.001,
    
    -- Eggs (dari EggSystem.lua)
    AutoBuyEgg = false,
    EggType = "Basic",
    AutoHatch = false,
    HatchDelay = 0.5,
    EggESP = false,
    
    -- Upgrades (dari OPCraftingScript.lua)
    AutoUpgrade = false,
    UpgradeType = "All",
    AutoBuyArea = false,
    AutoUnlock = false,
    
    -- Rebirth (dari AutoRebirth.lua, AutoFarm&Rebirth.lua)
    AutoRebirth = false,
    RebirthAt = 1000,
    RebirthDelay = 3,
    
    -- Collection (dari Rewards.lua)
    AutoCollect = false,
    AutoClaim = false,
    
    -- Enchant (dari AutoEnchant.lua, BestAutoEnchant.lua)
    AutoEnchant = false,
    EnchantType = "All",
    
    -- Craft (dari OPCraftingScript.lua)
    AutoCraft = false,
    CraftType = "All",
    
    -- Visuals (dari Visuals tab)
    FullBright = false,
    NoFog = false,
    
    -- Misc (dari AutomationScript.lua, Automations.lua)
    AntiAFK = false,
    AutoFarm = false,
    AutoProgress = false,
    
    -- Teleport (dari TeleportZones.lua, Teleports.lua)
    TeleportEnabled = false,
    SelectedZone = "Spawn"
}

-- Egg locations
local EggLocations = {}

-- Loops
local Loops = {}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Tap Simulator",
        Content = msg,
        Image = "zap",
        Time = 2.5
    })
end

--==================================================
-- CREATE MAIN WINDOW
--==================================================
local function loadMainScript()
    local Window = OrionLib:MakeWindow({
        Name = "Tap Simulator - Ultimate",
        Subtext = "Collection Edition v3.0",
        Version = "v3.0.0",
        VersionIcon = "zap",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "TapSim_Ultimate",
        IntroEnabled = true,
        IntroText = "Tap Simulator Ultimate",
        IntroIcon = "rbxassetid://8834748103",
        Icon = "rbxassetid://8834748103",
        ShowIcon = true,
        
        -- Custom Theme
        ImageBackground = "",
        ImageTransparency = 0.8,
        WindowTransparency = 0.05,
        
        -- Floating Toggle
        ToggleIcon = "rbxassetid://105921924721005",
        ToggleSize = 50
    })

    -- Set Theme
    OrionLib.SelectedTheme = "Ocean"

    Notify("Script loaded successfully!")

    --==================================================
    -- CREATE TABS
    --==================================================
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "home",
        PremiumOnly = false,
        Glass = true,
        Outline = true
    })

    local AutoTapTab = Window:MakeTab({
        Name = "Auto Tap",
        Icon = "hand",
        Glass = true,
        Outline = true
    })

    local EggTab = Window:MakeTab({
        Name = "Egg System",
        Icon = "egg",
        Glass = true,
        Outline = true
    })

    local UpgradeTab = Window:MakeTab({
        Name = "Upgrades",
        Icon = "trending-up",
        Glass = true,
        Outline = true
    })

    local RebirthTab = Window:MakeTab({
        Name = "Rebirth",
        Icon = "refresh-cw",
        Glass = true,
        Outline = true
    })

    local EnchantTab = Window:MakeTab({
        Name = "Enchant",
        Icon = "sparkles",
        Glass = true,
        Outline = true
    })

    local TeleportTab = Window:MakeTab({
        Name = "Teleport",
        Icon = "map-pin",
        Glass = true,
        Outline = true
    })

    local VisualsTab = Window:MakeTab({
        Name = "Visuals",
        Icon = "eye",
        Glass = true,
        Outline = true
    })

    local MiscTab = Window:MakeTab({
        Name = "Misc",
        Icon = "settings",
        Glass = true,
        Outline = true
    })

    --==================================================
    -- UTILITY FUNCTIONS
    --==================================================

    -- Tap function (dari AutoTap.lua)
    local function Tap()
        if Remotes.Tap then
            pcall(function()
                if Remotes.Tap:IsA("RemoteEvent") then
                    Remotes.Tap:FireServer()
                elseif Remotes.Tap:IsA("RemoteFunction") then
                    Remotes.Tap:InvokeServer()
                end
            end)
        else
            -- Fallback dari berbagai script
            local events = {
                ReplicatedStorage:FindFirstChild("ClickEvent"),
                ReplicatedStorage:FindFirstChild("MainEvent"),
                ReplicatedStorage:FindFirstChild("GameEvent"),
                ReplicatedStorage:FindFirstChild("RemoteEvent")
            }
            for _, event in pairs(events) do
                if event then
                    pcall(function() event:FireServer("Click") end)
                    pcall(function() event:FireServer("Tap") end)
                    pcall(function() event:FireServer() end)
                    break
                end
            end
        end
    end

    -- Get coins (dari berbagai script)
    local function GetCoins()
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            for _, v in pairs(leaderstats:GetChildren()) do
                if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash") or v.Name:lower():find("point") or v.Name:lower():find("gem")) then
                    return v.Value
                end
            end
        end
        
        for _, v in pairs(Player:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
                return v.Value
            end
        end
        
        return 0
    end

    -- Get rebirths (dari AutoRebirth.lua)
    local function GetRebirths()
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            for _, v in pairs(leaderstats:GetChildren()) do
                if v:IsA("NumberValue") and (v.Name:lower():find("rebirth") or v.Name:lower():find("prestige") or v.Name:lower():find("reset")) then
                    return v.Value
                end
            end
        end
        return 0
    end

    -- Buy egg (dari EggSystem.lua)
    local function BuyEgg(eggType)
        if Remotes.BuyEgg then
            pcall(function() Remotes.BuyEgg:FireServer(eggType) end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("BuyEgg"),
                ReplicatedStorage:FindFirstChild("PurchaseEgg"),
                ReplicatedStorage:FindFirstChild("Buy"),
                ReplicatedStorage:FindFirstChild("Purchase")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer(eggType or "Basic") end)
                    break
                end
            end
        end
    end

    -- Hatch egg (dari EggSystem.lua)
    local function HatchEgg()
        if Remotes.HatchEgg then
            pcall(function() Remotes.HatchEgg:FireServer() end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("HatchEgg"),
                ReplicatedStorage:FindFirstChild("OpenEgg"),
                ReplicatedStorage:FindFirstChild("Hatch"),
                ReplicatedStorage:FindFirstChild("Open")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer() end)
                    break
                end
            end
        end
    end

    -- Upgrade (dari OPCraftingScript.lua)
    local function Upgrade(upgradeType)
        if Remotes.Upgrade then
            pcall(function() Remotes.Upgrade:FireServer(upgradeType) end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("Upgrade"),
                ReplicatedStorage:FindFirstChild("PurchaseUpgrade"),
                ReplicatedStorage:FindFirstChild("BuyUpgrade")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer(upgradeType or "Damage") end)
                    break
                end
            end
        end
    end

    -- Buy area (dari OPCraftingScript.lua)
    local function BuyArea()
        if Remotes.BuyArea then
            pcall(function() Remotes.BuyArea:FireServer() end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("BuyArea"),
                ReplicatedStorage:FindFirstChild("PurchaseArea"),
                ReplicatedStorage:FindFirstChild("UnlockArea"),
                ReplicatedStorage:FindFirstChild("BuyZone")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer() end)
                    break
                end
            end
        end
    end

    -- Collect rewards (dari Rewards.lua)
    local function Collect()
        if Remotes.Collect then
            pcall(function() Remotes.Collect:FireServer() end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("Collect"),
                ReplicatedStorage:FindFirstChild("ClaimReward"),
                ReplicatedStorage:FindFirstChild("GetReward"),
                ReplicatedStorage:FindFirstChild("Claim")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer() end)
                    break
                end
            end
        end
    end

    -- Rebirth (dari AutoRebirth.lua, AutoFarm&Rebirth.lua)
    local function Rebirth()
        if Remotes.Rebirth then
            pcall(function() Remotes.Rebirth:FireServer() end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("Rebirth"),
                ReplicatedStorage:FindFirstChild("Prestige"),
                ReplicatedStorage:FindFirstChild("Reset"),
                ReplicatedStorage:FindFirstChild("NewGame")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer() end)
                    break
                end
            end
        end
    end

    -- Enchant (dari AutoEnchant.lua, BestAutoEnchant.lua)
    local function Enchant()
        if Remotes.Enchant then
            pcall(function() Remotes.Enchant:FireServer() end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("Enchant"),
                ReplicatedStorage:FindFirstChild("Enhance"),
                ReplicatedStorage:FindFirstChild("UpgradeEnchant")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer() end)
                    break
                end
            end
        end
    end

    -- Craft (dari OPCraftingScript.lua)
    local function Craft()
        if Remotes.Craft then
            pcall(function() Remotes.Craft:FireServer() end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("Craft"),
                ReplicatedStorage:FindFirstChild("Forge"),
                ReplicatedStorage:FindFirstChild("Create")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer() end)
                    break
                end
            end
        end
    end

    -- Unlock (dari AutoUnlock.lua)
    local function Unlock()
        if Remotes.Unlock then
            pcall(function() Remotes.Unlock:FireServer() end)
        else
            local remotes = {
                ReplicatedStorage:FindFirstChild("Unlock"),
                ReplicatedStorage:FindFirstChild("Open"),
                ReplicatedStorage:FindFirstChild("Activate")
            }
            for _, remote in pairs(remotes) do
                if remote then
                    pcall(function() remote:FireServer() end)
                    break
                end
            end
        end
    end

    -- Format numbers
    local function formatNumber(num)
        if num >= 1e9 then
            return string.format("%.2fB", num / 1e9)
        elseif num >= 1e6 then
            return string.format("%.2fM", num / 1e6)
        elseif num >= 1e3 then
            return string.format("%.2fK", num / 1e3)
        else
            return tostring(num)
        end
    end

    -- Get zones/areas (dari TeleportZones.lua, Teleports.lua)
    local function GetZones()
        local zones = {"Spawn"}
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("zone") or v.Name:lower():find("area") then
                table.insert(zones, v.Name)
            end
        end
        return zones
    end

    -- Teleport to zone (dari TeleportZones.lua, Teleports.lua)
    local function TeleportToZone(zoneName)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == zoneName then
                if v:IsA("BasePart") then
                    Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                elseif v:IsA("Model") and v.PrimaryPart then
                    Player.Character.HumanoidRootPart.CFrame = v.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                end
                Notify("Teleported to " .. zoneName)
                break
            end
        end
    end

    -- Update Egg ESP (dari EggSystem.lua)
    local function UpdateEggESP()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("egg") then
                if v:IsA("BasePart") and Toggles.EggESP then
                    local highlight = v:FindFirstChild("EggHighlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "EggHighlight"
                        highlight.Parent = v
                        highlight.FillColor = Color3.fromRGB(255, 0, 255)
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        highlight.FillTransparency = 0.3
                    end
                else
                    local highlight = v:FindFirstChild("EggHighlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end

    --==================================================
    -- LOOP FUNCTIONS
    --==================================================

    function StartLoop(name)
        if Loops[name] then return end
        Loops[name] = true
        
        task.spawn(function()
            while Loops[name] do
                if name == "AutoTap" and Toggles.AutoTap then
                    Tap()
                    task.wait(Toggles.TapSpeed)
                    
                elseif name == "AutoClicker" and Toggles.AutoClicker then
                    mouse1click()
                    task.wait(Toggles.ClickSpeed)
                    
                elseif name == "AutoBuyEgg" and Toggles.AutoBuyEgg then
                    BuyEgg(Toggles.EggType)
                    task.wait(1)
                    
                elseif name == "AutoHatch" and Toggles.AutoHatch then
                    HatchEgg()
                    task.wait(Toggles.HatchDelay)
                    
                elseif name == "AutoUpgrade" and Toggles.AutoUpgrade then
                    if Toggles.UpgradeType == "All" then
                        Upgrade("Damage")
                        task.wait(0.1)
                        Upgrade("Speed")
                        task.wait(0.1)
                        Upgrade("Multiplier")
                        task.wait(0.1)
                        Upgrade("Critical")
                    else
                        Upgrade(Toggles.UpgradeType)
                    end
                    task.wait(0.5)
                    
                elseif name == "AutoBuyArea" and Toggles.AutoBuyArea then
                    BuyArea()
                    task.wait(2)
                    
                elseif name == "AutoUnlock" and Toggles.AutoUnlock then
                    Unlock()
                    task.wait(1)
                    
                elseif name == "AutoCollect" and Toggles.AutoCollect then
                    Collect()
                    task.wait(2)
                    
                elseif name == "AutoClaim" and Toggles.AutoClaim then
                    local claimRemote = ReplicatedStorage:FindFirstChild("ClaimDaily") or 
                                       ReplicatedStorage:FindFirstChild("DailyReward")
                    if claimRemote then
                        pcall(function() claimRemote:FireServer() end)
                    end
                    task.wait(60)
                    
                elseif name == "AutoRebirth" and Toggles.AutoRebirth then
                    local coins = GetCoins()
                    if coins >= Toggles.RebirthAt then
                        Rebirth()
                        task.wait(Toggles.RebirthDelay)
                    else
                        task.wait(5)
                    end
                    
                elseif name == "AutoEnchant" and Toggles.AutoEnchant then
                    Enchant()
                    task.wait(1)
                    
                elseif name == "AutoCraft" and Toggles.AutoCraft then
                    Craft()
                    task.wait(2)
                    
                elseif name == "AutoFarm" and Toggles.AutoFarm then
                    -- Auto farm dari AutomationScript.lua
                    Tap()
                    if math.random(1, 10) == 1 then
                        Collect()
                    end
                    task.wait(0.1)
                    
                elseif name == "AutoProgress" and Toggles.AutoProgress then
                    -- Auto progress dari QuickProgress.lua
                    Tap()
                    if GetCoins() > 1000 then
                        Upgrade("Damage")
                    end
                    task.wait(0.2)
                end
                
                task.wait()
            end
        end)
    end

    function StopLoop(name)
        Loops[name] = false
    end

    --==================================================
    -- MAIN TAB
    --==================================================
    local StatsSection = MainTab:AddSection({
        Name = "Player Stats",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    local StatsPara = StatsSection:AddParagraph({
        Title = Player.Name,
        Desc = "Loading stats...",
        Image = "user",
        ImageSize = 38,
        Buttons = {
            {
                Title = "Refresh",
                Callback = function()
                    local coins = GetCoins()
                    local rebirths = GetRebirths()
                    StatsPara:SetDesc("Coins: " .. formatNumber(coins) .. "\nRebirths: " .. rebirths)
                end
            }
        }
    })

    -- Update stats setiap 5 detik
    task.spawn(function()
        while true do
            local coins = GetCoins()
            local rebirths = GetRebirths()
            StatsPara:SetDesc("Coins: " .. formatNumber(coins) .. "\nRebirths: " .. rebirths)
            task.wait(5)
        end
    end)

    local QuickSection = MainTab:AddSection({
        Name = "Quick Actions",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    QuickSection:AddButton({
        Name = "Tap 10x",
        Icon = "hand",
        Outline = true,
        Callback = function()
            for i = 1, 10 do
                Tap()
                task.wait(0.05)
            end
            Notify("Tapped 10 times!")
        end
    })

    QuickSection:AddButton({
        Name = "Hatch Egg",
        Icon = "egg",
        Outline = true,
        Callback = function()
            HatchEgg()
            Notify("Egg hatched!")
        end
    })

    QuickSection:AddButton({
        Name = "Rebirth Now",
        Icon = "refresh-cw",
        Outline = true,
        Callback = function()
            Rebirth()
            Notify("Rebirthed!")
        end
    })

    --==================================================
    -- AUTO TAP TAB (dari AutoTap.lua, AutoTapKeyless.lua)
    --==================================================
    local TapSection = AutoTapTab:AddSection({
        Name = "Auto Tap Settings",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    TapSection:AddToggle({
        Name = "Auto Tap",
        Default = false,
        Color = Color3.fromRGB(0, 255, 100),
        Outline = true,
        Flag = "AutoTap",
        Save = true,
        Callback = function(Value)
            Toggles.AutoTap = Value
            if Value then StartLoop("AutoTap") else StopLoop("AutoTap") end
        end
    })

    TapSection:AddSlider({
        Name = "Tap Speed",
        Min = 0.001,
        Max = 0.1,
        Default = 0.01,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 0.001,
        ValueName = "sec",
        Outline = true,
        Callback = function(Value)
            Toggles.TapSpeed = Value
        end
    })

    TapSection:AddToggle({
        Name = "Auto Clicker",
        Default = false,
        Color = Color3.fromRGB(0, 255, 100),
        Outline = true,
        Flag = "AutoClicker",
        Save = true,
        Callback = function(Value)
            Toggles.AutoClicker = Value
            if Value then StartLoop("AutoClicker") else StopLoop("AutoClicker") end
        end
    })

    TapSection:AddSlider({
        Name = "Click Speed",
        Min = 0.0001,
        Max = 0.01,
        Default = 0.001,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 0.0001,
        ValueName = "sec",
        Outline = true,
        Callback = function(Value)
            Toggles.ClickSpeed = Value
        end
    })

    --==================================================
    -- EGG SYSTEM TAB (dari EggSystem.lua)
    --==================================================
    local EggMainSection = EggTab:AddSection({
        Name = "Egg Settings",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    EggMainSection:AddToggle({
        Name = "Auto Buy Egg",
        Default = false,
        Color = Color3.fromRGB(255, 150, 0),
        Outline = true,
        Flag = "AutoBuyEgg",
        Save = true,
        Callback = function(Value)
            Toggles.AutoBuyEgg = Value
            if Value then StartLoop("AutoBuyEgg") else StopLoop("AutoBuyEgg") end
        end
    })

    EggMainSection:AddDropdown({
        Name = "Egg Type",
        Default = "Basic",
        Options = {"Basic", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Godly"},
        Multi = false,
        Search = false,
        AllowNone = false,
        Outline = true,
        Callback = function(Value)
            Toggles.EggType = Value
        end
    })

    EggMainSection:AddToggle({
        Name = "Auto Hatch",
        Default = false,
        Color = Color3.fromRGB(255, 150, 0),
        Outline = true,
        Flag = "AutoHatch",
        Save = true,
        Callback = function(Value)
            Toggles.AutoHatch = Value
            if Value then StartLoop("AutoHatch") else StopLoop("AutoHatch") end
        end
    })

    EggMainSection:AddSlider({
        Name = "Hatch Delay",
        Min = 0.1,
        Max = 2,
        Default = 0.5,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 0.1,
        ValueName = "sec",
        Outline = true,
        Callback = function(Value)
            Toggles.HatchDelay = Value
        end
    })

    EggMainSection:AddToggle({
        Name = "Egg ESP",
        Default = false,
        Color = Color3.fromRGB(255, 0, 255),
        Outline = true,
        Flag = "EggESP",
        Save = true,
        Callback = function(Value)
            Toggles.EggESP = Value
            UpdateEggESP()
        end
    })

    EggMainSection:AddButton({
        Name = "Find Eggs",
        Icon = "search",
        Outline = true,
        Callback = function()
            EggLocations = {}
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name:lower():find("egg") then
                    table.insert(EggLocations, v)
                end
            end
            Notify("Found " .. #EggLocations .. " eggs!")
        end
    })

    --==================================================
    -- UPGRADES TAB (dari OPCraftingScript.lua)
    --==================================================
    local UpgradeMainSection = UpgradeTab:AddSection({
        Name = "Auto Upgrade",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    UpgradeMainSection:AddToggle({
        Name = "Auto Upgrade",
        Default = false,
        Color = Color3.fromRGB(0, 150, 255),
        Outline = true,
        Flag = "AutoUpgrade",
        Save = true,
        Callback = function(Value)
            Toggles.AutoUpgrade = Value
            if Value then StartLoop("AutoUpgrade") else StopLoop("AutoUpgrade") end
        end
    })

    UpgradeMainSection:AddDropdown({
        Name = "Upgrade Type",
        Default = "All",
        Options = {"All", "Damage", "Speed", "Multiplier", "Critical", "Luck", "Strength"},
        Multi = false,
        Search = false,
        AllowNone = false,
        Outline = true,
        Callback = function(Value)
            Toggles.UpgradeType = Value
        end
    })

    UpgradeMainSection:AddToggle({
        Name = "Auto Buy Area",
        Default = false,
        Color = Color3.fromRGB(0, 150, 255),
        Outline = true,
        Flag = "AutoBuyArea",
        Save = true,
        Callback = function(Value)
            Toggles.AutoBuyArea = Value
            if Value then StartLoop("AutoBuyArea") else StopLoop("AutoBuyArea") end
        end
    })

    UpgradeMainSection:AddToggle({
        Name = "Auto Unlock",
        Default = false,
        Color = Color3.fromRGB(0, 150, 255),
        Outline = true,
        Flag = "AutoUnlock",
        Save = true,
        Callback = function(Value)
            Toggles.AutoUnlock = Value
            if Value then StartLoop("AutoUnlock") else StopLoop("AutoUnlock") end
        end
    })

    --==================================================
    -- REBIRTH TAB (dari AutoRebirth.lua, AutoFarm&Rebirth.lua)
    --==================================================
    local RebirthMainSection = RebirthTab:AddSection({
        Name = "Rebirth Settings",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    RebirthMainSection:AddToggle({
        Name = "Auto Rebirth",
        Default = false,
        Color = Color3.fromRGB(255, 50, 50),
        Outline = true,
        Flag = "AutoRebirth",
        Save = true,
        Callback = function(Value)
            Toggles.AutoRebirth = Value
            if Value then StartLoop("AutoRebirth") else StopLoop("AutoRebirth") end
        end
    })

    RebirthMainSection:AddSlider({
        Name = "Rebirth At",
        Min = 100,
        Max = 1000000,
        Default = 1000,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 100,
        ValueName = "coins",
        Outline = true,
        Callback = function(Value)
            Toggles.RebirthAt = Value
        end
    })

    RebirthMainSection:AddSlider({
        Name = "Rebirth Delay",
        Min = 1,
        Max = 10,
        Default = 3,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 0.5,
        ValueName = "sec",
        Outline = true,
        Callback = function(Value)
            Toggles.RebirthDelay = Value
        end
    })

    --==================================================
    -- ENCHANT TAB (dari AutoEnchant.lua, BestAutoEnchant.lua)
    --==================================================
    local EnchantMainSection = EnchantTab:AddSection({
        Name = "Enchant Settings",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    EnchantMainSection:AddToggle({
        Name = "Auto Enchant",
        Default = false,
        Color = Color3.fromRGB(255, 0, 255),
        Outline = true,
        Flag = "AutoEnchant",
        Save = true,
        Callback = function(Value)
            Toggles.AutoEnchant = Value
            if Value then StartLoop("AutoEnchant") else StopLoop("AutoEnchant") end
        end
    })

    EnchantMainSection:AddDropdown({
        Name = "Enchant Type",
        Default = "All",
        Options = {"All", "Weapon", "Armor", "Tool", "Accessory"},
        Multi = false,
        Search = false,
        AllowNone = false,
        Outline = true,
        Callback = function(Value)
            Toggles.EnchantType = Value
        end
    })

    EnchantMainSection:AddToggle({
        Name = "Auto Craft",
        Default = false,
        Color = Color3.fromRGB(255, 0, 255),
        Outline = true,
        Flag = "AutoCraft",
        Save = true,
        Callback = function(Value)
            Toggles.AutoCraft = Value
            if Value then StartLoop("AutoCraft") else StopLoop("AutoCraft") end
        end
    })

    --==================================================
    -- TELEPORT TAB (dari TeleportZones.lua, Teleports.lua)
    --==================================================
    local TeleportMainSection = TeleportTab:AddSection({
        Name = "Teleport Zones",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    local zones = GetZones()
    TeleportMainSection:AddDropdown({
        Name = "Select Zone",
        Default = zones[1] or "Spawn",
        Options = zones,
        Multi = false,
        Search = true,
        AllowNone = false,
        Outline = true,
        Callback = function(Value)
            Toggles.SelectedZone = Value
        end
    })

    TeleportMainSection:AddButton({
        Name = "Teleport",
        Icon = "map-pin",
        Outline = true,
        Callback = function()
            TeleportToZone(Toggles.SelectedZone)
        end
    })

    TeleportMainSection:AddButton({
        Name = "Refresh Zones",
        Icon = "refresh-cw",
        Outline = true,
        Callback = function()
            zones = GetZones()
            Notify("Found " .. #zones .. " zones!")
        end
    })

    --==================================================
    -- VISUALS TAB
    --==================================================
    local VisualsMainSection = VisualsTab:AddSection({
        Name = "Lighting",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    VisualsMainSection:AddToggle({
        Name = "Full Bright",
        Default = false,
        Color = Color3.fromRGB(255, 255, 0),
        Outline = true,
        Flag = "FullBright",
        Save = true,
        Callback = function(Value)
            Toggles.FullBright = Value
            if Value then
                Lighting.Brightness = 2
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.new(1, 1, 1)
            else
                Lighting.Brightness = 1
                Lighting.GlobalShadows = true
                Lighting.Ambient = Color3.new(0, 0, 0)
            end
        end
    })

    VisualsMainSection:AddToggle({
        Name = "No Fog",
        Default = false,
        Color = Color3.fromRGB(255, 255, 0),
        Outline = true,
        Flag = "NoFog",
        Save = true,
        Callback = function(Value)
            Toggles.NoFog = Value
            Lighting.FogEnd = Value and 1e9 or 100000
        end
    })

    --==================================================
    -- MISC TAB (dari AutomationScript.lua, Automations.lua, dll)
    --==================================================
    local MiscMainSection = MiscTab:AddSection({
        Name = "Automation",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    MiscMainSection:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Color = Color3.fromRGB(100, 100, 255),
        Outline = true,
        Flag = "AutoFarm",
        Save = true,
        Callback = function(Value)
            Toggles.AutoFarm = Value
            if Value then StartLoop("AutoFarm") else StopLoop("AutoFarm") end
        end
    })

    MiscMainSection:AddToggle({
        Name = "Auto Progress",
        Default = false,
        Color = Color3.fromRGB(100, 100, 255),
        Outline = true,
        Flag = "AutoProgress",
        Save = true,
        Callback = function(Value)
            Toggles.AutoProgress = Value
            if Value then StartLoop("AutoProgress") else StopLoop("AutoProgress") end
        end
    })

    MiscMainSection:AddToggle({
        Name = "Auto Collect",
        Default = false,
        Color = Color3.fromRGB(100, 100, 255),
        Outline = true,
        Flag = "AutoCollect",
        Save = true,
        Callback = function(Value)
            Toggles.AutoCollect = Value
            if Value then StartLoop("AutoCollect") else StopLoop("AutoCollect") end
        end
    })

    MiscMainSection:AddToggle({
        Name = "Auto Claim",
        Default = false,
        Color = Color3.fromRGB(100, 100, 255),
        Outline = true,
        Flag = "AutoClaim",
        Save = true,
        Callback = function(Value)
            Toggles.AutoClaim = Value
            if Value then StartLoop("AutoClaim") else StopLoop("AutoClaim") end
        end
    })

    MiscMainSection:AddToggle({
        Name = "Anti AFK",
        Default = false,
        Color = Color3.fromRGB(100, 100, 255),
        Outline = true,
        Flag = "AntiAFK",
        Save = true,
        Callback = function(Value)
            Toggles.AntiAFK = Value
            if Value then
                Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end
    })

    local ServerSection = MiscTab:AddSection({
        Name = "Server",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    ServerSection:AddButton({
        Name = "Rejoin Server",
        Icon = "refresh-cw",
        Outline = true,
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end
    })

    ServerSection:AddButton({
        Name = "Server Hop",
        Icon = "globe",
        Outline = true,
        Callback = function()
            local function getServers()
                local servers = {}
                local cursor = ""
                repeat
                    local success, result = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")))
                    end)
                    if success then
                        for _, server in ipairs(result.data) do
                            if server.playing < server.maxPlayers then
                                table.insert(servers, server.id)
                            end
                        end
                        cursor = result.nextPageCursor
                    else
                        break
                    end
                until not cursor
                return servers
            end
            
            local servers = getServers()
            if #servers > 0 then
                local randomServer = servers[math.random(1, #servers)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, Player)
            else
                Notify("No servers available!")
            end
        end
    })

    ServerSection:AddButton({
        Name = "Close GUI",
        Icon = "x",
        Outline = true,
        Callback = function()
            OrionLib:Destroy()
            _G.TapSimLoaded = false
        end
    })

    local InfoSection = MiscTab:AddSection({
        Name = "Server Info",
        TextSize = 17,
        Folded = false,
        Glass = true,
        Outline = true
    })

    InfoSection:AddParagraph({
        Title = "Server Status",
        Desc = "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers .. "\nPing: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms",
        Image = "server",
        ImageSize = 38
    })

    --==================================================
    -- ADD CONFIG TAB
    --==================================================
    Window:AddConfigTab({
        Name = "Settings",
        Icon = "settings"
    })

    --==================================================
    -- INITIALIZE
    --==================================================
    OrionLib:Init()

    Notify("Tap Simulator Ultimate loaded! Press F4 to toggle menu")
    print("=== Tap Simulator - Ultimate Collection v3.0 ===")
    print("Loaded from " .. #zones .. " zones")
    print("Found " .. #EggLocations .. " eggs")
    print("Press F4 to toggle menu")
end

--==================================================
-- START THE SCRIPT
--==================================================

-- Find remotes first
FindRemotes()

-- Start key system
initKeySystem()