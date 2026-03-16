-- SCRIPT LENGKAP ALL IN ONE
-- Key System + Teleport + Auto Farm + Auto Rebirth + Auto Enchant + Egg System + Rewards + Automation

-- =============================================
-- KEY SYSTEM UI
-- =============================================

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
    Title.Text = "Script Key System"
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

-- =============================================
-- KEY VERIFICATION FUNCTION
-- =============================================

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

-- =============================================
-- GAME DETECTION AND SCRIPT LOADING
-- =============================================

-- Fungsi untuk memuat script berdasarkan game
local function loadGameScripts()
    local success, result = pcall(function()
        -- Coba load dari berbagai sumber
        local scriptSources = {
            "https://raw.githubusercontent.com/bigbeanscripts/TapSim/refs/heads/main/Main",
            "https://gist.githubusercontent.com/whoisnwr/5e7e84f108f429d64ff47ec160dd1883/raw/",
            "https://raw.githubusercontent.com/Sicalelak/Sicalelak/refs/heads/main/tapsim",
            "https://api.luarmor.net/files/v3/loaders/bc8e3326ded9dbd4f9f5b8089c393fc5.lua",
            "https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua",
            "https://gist.githubusercontent.com/gerelyncontiga-dot/de66cf3790f609468117ecebda06c30d/raw/e5f3f65ec51fccf22588fc7f455de77d247f7ad1/Tap%2520simulator%2520v41.lua"
        }
        
        for _, source in ipairs(scriptSources) do
            local success2, games = pcall(function()
                return loadstring(game:HttpGet(source))()
            end)
            
            if success2 and type(games) == "table" then
                for PlaceID, Execute in pairs(games) do
                    if PlaceID == game.PlaceId then
                        return loadstring(game:HttpGet(Execute))()
                    end
                end
            end
        end
    end)
    
    if not success then
        warn("Failed to load game scripts: " .. tostring(result))
    end
end

-- =============================================
-- TELEPORT ZONES FUNCTION
-- =============================================

local function setupTeleportZones()
    local TeleportZones = {}
    
    -- Fungsi untuk menambah teleport zone
    function TeleportZones:addZone(name, position, callback)
        local zone = {
            Name = name,
            Position = position,
            Callback = callback,
            Part = nil
        }
        
        -- Buat part untuk visualisasi
        local part = Instance.new("Part")
        part.Name = "TeleportZone_" .. name
        part.Size = Vector3.new(10, 10, 10)
        part.Position = position
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.5
        part.BrickColor = BrickColor.new("Bright blue")
        part.Parent = workspace
        
        -- Buat highlight
        local highlight = Instance.new("Highlight")
        highlight.Adornee = part
        highlight.FillColor = Color3.new(0, 0, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Parent = part
        
        zone.Part = part
        table.insert(self, zone)
    end
    
    -- Cek player masuk zone
    game:GetService("RunService").Heartbeat:Connect(function()
        local player = game.Players.LocalPlayer
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local characterPos = player.Character.HumanoidRootPart.Position
        
        for _, zone in ipairs(TeleportZones) do
            if zone.Part and (zone.Part.Position - characterPos).Magnitude < 15 then
                if zone.Callback then
                    zone.Callback(player)
                end
            end
        end
    end)
    
    return TeleportZones
end

-- =============================================
-- AUTO FARM FUNCTIONS
-- =============================================

local AutoFarm = {}
AutoFarm.Running = false
AutoFarm.FarmConnection = nil

function AutoFarm:start()
    if self.Running then return end
    self.Running = true
    
    self.FarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not self.Running then return end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        -- Auto tap logic
        local args = {
            [1] = "TouchEvent"
        }
        game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("TouchEvent"):FireServer(unpack(args))
    end)
end

function AutoFarm:stop()
    self.Running = false
    if self.FarmConnection then
        self.FarmConnection:Disconnect()
        self.FarmConnection = nil
    end
end

-- =============================================
-- AUTO REBIRTH FUNCTIONS
-- =============================================

local AutoRebirth = {}
AutoRebirth.Running = false
AutoRebirth.RebirthConnection = nil

function AutoRebirth:start()
    if self.Running then return end
    self.Running = true
    
    self.RebirthConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not self.Running then return end
        
        -- Auto rebirth logic
        local args = {
            [1] = "RebirthEvent"
        }
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RebirthEvent")
        if remote then
            remote:FireServer(unpack(args))
        end
    end)
end

function AutoRebirth:stop()
    self.Running = false
    if self.RebirthConnection then
        self.RebirthConnection:Disconnect()
        self.RebirthConnection = nil
    end
end

-- =============================================
-- AUTO ENCHANT FUNCTIONS
-- =============================================

local AutoEnchant = {}
AutoEnchant.Running = false
AutoEnchant.EnchantConnection = nil

function AutoEnchant:start()
    if self.Running then return end
    self.Running = true
    
    self.EnchantConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not self.Running then return end
        
        -- Auto enchant logic
        local args = {
            [1] = "EnchantEvent"
        }
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("EnchantEvent")
        if remote then
            remote:FireServer(unpack(args))
        end
    end)
end

function AutoEnchant:stop()
    self.Running = false
    if self.EnchantConnection then
        self.EnchantConnection:Disconnect()
        self.EnchantConnection = nil
    end
end

-- =============================================
-- EGG SYSTEM FUNCTIONS
-- =============================================

local EggSystem = {}
EggSystem.AutoHatch = false
EggSystem.HatchConnection = nil

function EggSystem:startHatching()
    if self.AutoHatch then return end
    self.AutoHatch = true
    
    self.HatchConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not self.AutoHatch then return end
        
        -- Auto hatch logic
        local args = {
            [1] = "HatchEgg"
        }
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("HatchEgg")
        if remote then
            remote:FireServer(unpack(args))
        end
    end)
end

function EggSystem:stopHatching()
    self.AutoHatch = false
    if self.HatchConnection then
        self.HatchConnection:Disconnect()
        self.HatchConnection = nil
    end
end

-- =============================================
-- REWARDS SYSTEM
-- =============================================

local RewardsSystem = {}

function RewardsSystem:claimDailyRewards()
    local args = {
        [1] = "ClaimDailyReward"
    }
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("ClaimDailyReward")
    if remote then
        remote:FireServer(unpack(args))
    end
end

function RewardsSystem:claimQuestRewards()
    local args = {
        [1] = "ClaimQuestReward"
    }
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("ClaimQuestReward")
    if remote then
        remote:FireServer(unpack(args))
    end
end

-- =============================================
-- AUTOMATION CONTROL UI
-- =============================================

local function createAutomationUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local AutoFarmToggle = Instance.new("TextButton")
    local AutoRebirthToggle = Instance.new("TextButton")
    local AutoEnchantToggle = Instance.new("TextButton")
    local AutoHatchToggle = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    
    ScreenGui.Name = "AutomationUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 200, 0, 250)
    
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = "Automation Controls"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14.000
    
    -- Auto Farm Toggle
    AutoFarmToggle.Name = "AutoFarmToggle"
    AutoFarmToggle.Parent = MainFrame
    AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    AutoFarmToggle.BorderSizePixel = 0
    AutoFarmToggle.Position = UDim2.new(0.1, 0, 0.15, 0)
    AutoFarmToggle.Size = UDim2.new(0, 160, 0, 30)
    AutoFarmToggle.Font = Enum.Font.GothamSemibold
    AutoFarmToggle.Text = "Auto Farm: OFF"
    AutoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoFarmToggle.TextSize = 14.000
    
    -- Auto Rebirth Toggle
    AutoRebirthToggle.Name = "AutoRebirthToggle"
    AutoRebirthToggle.Parent = MainFrame
    AutoRebirthToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    AutoRebirthToggle.BorderSizePixel = 0
    AutoRebirthToggle.Position = UDim2.new(0.1, 0, 0.3, 0)
    AutoRebirthToggle.Size = UDim2.new(0, 160, 0, 30)
    AutoRebirthToggle.Font = Enum.Font.GothamSemibold
    AutoRebirthToggle.Text = "Auto Rebirth: OFF"
    AutoRebirthToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoRebirthToggle.TextSize = 14.000
    
    -- Auto Enchant Toggle
    AutoEnchantToggle.Name = "AutoEnchantToggle"
    AutoEnchantToggle.Parent = MainFrame
    AutoEnchantToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    AutoEnchantToggle.BorderSizePixel = 0
    AutoEnchantToggle.Position = UDim2.new(0.1, 0, 0.45, 0)
    AutoEnchantToggle.Size = UDim2.new(0, 160, 0, 30)
    AutoEnchantToggle.Font = Enum.Font.GothamSemibold
    AutoEnchantToggle.Text = "Auto Enchant: OFF"
    AutoEnchantToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoEnchantToggle.TextSize = 14.000
    
    -- Auto Hatch Toggle
    AutoHatchToggle.Name = "AutoHatchToggle"
    AutoHatchToggle.Parent = MainFrame
    AutoHatchToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    AutoHatchToggle.BorderSizePixel = 0
    AutoHatchToggle.Position = UDim2.new(0.1, 0, 0.6, 0)
    AutoHatchToggle.Size = UDim2.new(0, 160, 0, 30)
    AutoHatchToggle.Font = Enum.Font.GothamSemibold
    AutoHatchToggle.Text = "Auto Hatch: OFF"
    AutoHatchToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoHatchToggle.TextSize = 14.000
    
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 40)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Ready"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 12.000
    StatusLabel.TextWrapped = true
    
    -- Toggle functions
    AutoFarmToggle.MouseButton1Click:Connect(function()
        if AutoFarm.Running then
            AutoFarm:stop()
            AutoFarmToggle.Text = "Auto Farm: OFF"
            AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        else
            AutoFarm:start()
            AutoFarmToggle.Text = "Auto Farm: ON"
            AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        end
    end)
    
    AutoRebirthToggle.MouseButton1Click:Connect(function()
        if AutoRebirth.Running then
            AutoRebirth:stop()
            AutoRebirthToggle.Text = "Auto Rebirth: OFF"
            AutoRebirthToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        else
            AutoRebirth:start()
            AutoRebirthToggle.Text = "Auto Rebirth: ON"
            AutoRebirthToggle.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        end
    end)
    
    AutoEnchantToggle.MouseButton1Click:Connect(function()
        if AutoEnchant.Running then
            AutoEnchant:stop()
            AutoEnchantToggle.Text = "Auto Enchant: OFF"
            AutoEnchantToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        else
            AutoEnchant:start()
            AutoEnchantToggle.Text = "Auto Enchant: ON"
            AutoEnchantToggle.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        end
    end)
    
    AutoHatchToggle.MouseButton1Click:Connect(function()
        if EggSystem.AutoHatch then
            EggSystem:stopHatching()
            AutoHatchToggle.Text = "Auto Hatch: OFF"
            AutoHatchToggle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        else
            EggSystem:startHatching()
            AutoHatchToggle.Text = "Auto Hatch: ON"
            AutoHatchToggle.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        end
    end)
    
    return {
        ScreenGui = ScreenGui,
        StatusLabel = StatusLabel
    }
end

-- =============================================
-- PROGRESS AUTOMATION
-- =============================================

local ProgressAutomation = {}

function ProgressAutomation:startFullAutomation()
    -- Mulai semua automation
    AutoFarm:start()
    AutoRebirth:start()
    AutoEnchant:start()
    EggSystem:startHatching()
end

function ProgressAutomation:stopFullAutomation()
    AutoFarm:stop()
    AutoRebirth:stop()
    AutoEnchant:stop()
    EggSystem:stopHatching()
end

-- =============================================
-- MAIN SCRIPT EXECUTION
-- =============================================

local function runMainScript()
    -- Setup teleport zones
    local teleportZones = setupTeleportZones()
    
    -- Tambahkan beberapa teleport zone contoh
    teleportZones:addZone("Spawn", Vector3.new(0, 10, 0), function(player)
        print("Player entered spawn zone")
    end)
    
    teleportZones:addZone("Farm Area", Vector3.new(50, 10, 50), function(player)
        print("Player entered farm area")
    end)
    
    -- Load game scripts
    loadGameScripts()
    
    -- Create automation UI
    local automationUI = createAutomationUI()
    
    -- Claim rewards periodically
    task.spawn(function()
        while true do
            task.wait(300) -- Setiap 5 menit
            RewardsSystem:claimDailyRewards()
            RewardsSystem:claimQuestRewards()
        end
    end)
    
    -- Notifikasi
    if automationUI and automationUI.StatusLabel then
        automationUI.StatusLabel.Text = "All systems initialized!"
    end
end

-- =============================================
-- INITIALIZE KEY SYSTEM
-- =============================================

local function initKeySystem()
    local ui = createKeyUI()
    
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
                    runMainScript()
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
    
    return ui
end

-- =============================================
-- START THE SCRIPT
-- =============================================

-- Cek apakah sudah terverifikasi
local success, message = pcall(function()
    -- Mulai key system
    initKeySystem()
end)

if not success then
    warn("Failed to start script: " .. tostring(message))
    -- Fallback: langsung jalankan main script tanpa key
    runMainScript()
end