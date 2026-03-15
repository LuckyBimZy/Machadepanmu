-- ==================== VIOLENCE DISTRICT - CATRAZ EDITION ====================
-- Premium UI dengan ESP + Distance + Fixed Features
-- Adapted for Catraz Hub UI Library
-- Version: 2.0

if _G.VD_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Violence District",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.VD_Loaded = true

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
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

-- Toggles - STATE AKAN TERSIMPAN
local Toggles = {
    -- Visuals
    ESP = false,
    ESPType = "Highlight",
    Wallhack = false,
    FullBright = false,
    NoFog = false,
    
    -- Survivor
    AutoPresent = false,
    AutoGift = false,
    AutoCoins = false,
    AutoHeal = false,
    SpeedBoost = false,
    JumpBoost = false,
    SpeedValue = 50,
    JumpValue = 100,
    
    -- Killer
    Aimbot = false,
    KillAura = false,
    KillAuraRange = 20,
    
    -- Teleport
    NoClip = false,
    TeleportToMouse = false,
    
    -- Farm
    AutoFarmGenerator = false,
    AutoCompleteGenerator = false,
    
    -- Misc
    AntiAFK = false,
    NoSkillCheck = false,
    AutoClick = false
}

-- Loops
local Loops = {}
local SavedPosition = nil
local ESPObjects = {}
local ESPConnections = {}
local NoClipConnection = nil

-- Untuk menyimpan referensi toggle elements
local ToggleElements = {}

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Violence District",
        Content = msg,
        Image = "shield",
        Time = duration or 3
    })
end

Notify("Script loaded successfully!", 2)

--==================================================
-- CREATE MAIN WINDOW - CATRAZ STYLE
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Violence District",
    Subtext = "Professional Edition",
    Version = "v2.0.0",
    VersionIcon = "shield-check",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "ViolenceDistrictConfig",
    IntroEnabled = true,
    IntroText = "Violence District",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    
    -- Custom Theme & Appearance
    ImageBackground = "rbxassetid://93195749393891",
    ImageTransparency = 0.8,
    WindowTransparency = 0.1,
    
    -- Floating Toggle Customization
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Set Theme (Ocean theme looks nice)
OrionLib.SelectedTheme = "Ocean"

--==================================================
-- ESP FUNCTIONS - DENGAN JARAK
--==================================================
function EnableESP()
    DisableESP()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            AddESP(player)
        end
    end
    
    -- Untuk player yang baru join
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Toggles.ESP and player ~= Player then
                AddESP(player)
            end
        end)
    end)
end

function AddESP(player)
    if not player.Character then return end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "VD_ESP"
    highlight.Parent = player.Character
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Name tag dengan jarak
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VD_Name"
    billboard.Parent = player.Character
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.ZIndex = 10
    
    -- Update jarak setiap 0.1 detik
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local distance = (player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
        nameLabel.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
    end)
    
    -- Simpan connection untuk cleanup nanti
    ESPConnections[player] = connection
end

function DisableESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("VD_ESP")
            if highlight then highlight:Destroy() end
            local nameTag = player.Character:FindFirstChild("VD_Name")
            if nameTag then nameTag:Destroy() end
        end
        
        -- Hapus connection
        if ESPConnections[player] then
            ESPConnections[player]:Disconnect()
            ESPConnections[player] = nil
        end
    end
end

--==================================================
-- WALLHACK FUNCTION
--==================================================
function UpdateWallhack()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if Toggles.Wallhack then
                if v.Transparency < 0.5 then
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

--==================================================
-- NOCLIP FUNCTION - FIXED
--==================================================
function UpdateNoClip()
    if Toggles.NoClip then
        -- Hapus koneksi lama jika ada
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        
        -- Buat koneksi baru
        NoClipConnection = RunService.Stepped:Connect(function()
            if Toggles.NoClip and Player.Character then
                for _, part in pairs(Player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        -- Hapus koneksi
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        
        -- Kembalikan collision
        if Player.Character then
            for _, part in pairs(Player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
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
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            
            if name == "Present" and Toggles.AutoPresent then
                local present = FindNearestPresent()
                if present then
                    Player.Character.HumanoidRootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
                
            elseif name == "Gift" and Toggles.AutoGift then
                local gift = FindNearestGift()
                if gift then
                    Player.Character.HumanoidRootPart.CFrame = gift.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                        local tree = FindChristmasTree()
                        if tree then
                            task.wait(0.3)
                            if tree:IsA("Model") and tree.PrimaryPart then
                                Player.Character.HumanoidRootPart.CFrame = tree.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
                            elseif tree:IsA("BasePart") then
                                Player.Character.HumanoidRootPart.CFrame = tree.CFrame * CFrame.new(0, 5, 0)
                            end
                        end
                    end
                end
                
            elseif name == "Coins" and Toggles.AutoCoins then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "Coin" and v:IsA("BasePart") then
                        local dist = (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude
                        if dist < 30 then
                            Player.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.1)
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then fireproximityprompt(prompt) end
                            break
                        end
                    end
                end
                
            elseif name == "Heal" and Toggles.AutoHeal then
                if Player.Character.Humanoid.Health < 50 then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then pcall(function() remote:FireServer("Heal") end) end
                end
                
            elseif name == "Aimbot" and Toggles.Aimbot then
                local target = FindNearestPlayer()
                if target and target.Character then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    Player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(Player.Character.HumanoidRootPart.Position, targetPos)
                end
                
            elseif name == "KillAura" and Toggles.KillAura then
                local range = Toggles.KillAuraRange
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
                        local dist = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= range then
                            player.Character.Humanoid.Health = 0
                        end
                    end
                end
                
            elseif name == "Generator" and Toggles.AutoFarmGenerator then
                local gen = FindNearestGenerator()
                if gen and gen.PrimaryPart then
                    Player.Character.HumanoidRootPart.CFrame = gen.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                    local prompt = gen:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then 
                        fireproximityprompt(prompt)
                    else
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                        if remote then pcall(function() remote:FireServer("RepairGenerator", gen) end) end
                    end
                end
                
            elseif name == "Complete" and Toggles.AutoCompleteGenerator then
                local gen = FindNearestGenerator()
                if gen then
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then pcall(function() remote:FireServer("CompleteGenerator", gen) end) end
                end
                
            elseif name == "Click" and Toggles.AutoClick then
                mouse1click()
            end
            
            task.wait(0.1)
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

--==================================================
-- UTILITY FUNCTIONS
--==================================================

function ToggleSkillCheck(state)
    if state then
        local mt = getrawmetatable(game)
        if mt then
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "FireServer" and tostring(self):find("SkillCheck") then
                    return
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end
end

-- Teleport to mouse
UserInputService.InputBegan:Connect(function(input)
    if Toggles.TeleportToMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = Mouse.Hit.p
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(target.X, target.Y + 3, target.Z)
    end
end)

-- Find functions
function FindNearestGenerator()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") and v.PrimaryPart then
            local d = (root.Position - v.PrimaryPart.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function CountGenerators()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Generator" and v:IsA("Model") then
            count = count + 1
        end
    end
    return count
end

function FindNearestPresent()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Present" and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function CountPresents()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Present" and v:IsA("BasePart") then
            count = count + 1
        end
    end
    return count
end

function FindNearestGift()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Gift" and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < dist then
                dist, nearest = d, v
            end
        end
    end
    return nearest
end

function CountGifts()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "Gift" and v:IsA("BasePart") then
            count = count + 1
        end
    end
    return count
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
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist, nearest = d, player
            end
        end
    end
    return nearest
end

function GetPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(list, player.Name)
        end
    end
    return list
end

-- Character update
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    -- Re-apply NoClip if enabled
    if Toggles.NoClip then
        UpdateNoClip()
    end
end)

--==================================================
-- CREATE TABS - CATRAZ STYLE
--==================================================

-- MAIN TAB
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

-- Info Section
local InfoSection = MainTab:AddSection({
    Name = "Player Info",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Player Stats Paragraph
local StatsParagraph = InfoSection:AddParagraph({
    Title = "Stats",
    Desc = "Loading...",
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                StatsParagraph:SetDesc("Name: " .. Player.Name .. "\nDisplay: " .. Player.DisplayName .. "\nAge: " .. Player.AccountAge .. " days\nPlayers: " .. #Players:GetPlayers())
            end
        }
    }
})

StatsParagraph:SetDesc("Name: " .. Player.Name .. "\nDisplay: " .. Player.DisplayName .. "\nAge: " .. Player.AccountAge .. " days\nPlayers: " .. #Players:GetPlayers())

-- Quick Actions Section
local QuickSection = MainTab:AddSection({
    Name = "Quick Actions",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

QuickSection:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

-- Credits Section
local CreditsSection = MainTab:AddSection({
    Name = "Credits",
    TextSize = 17,
    Folded = true,
    Glass = true,
    Outline = true
})

CreditsSection:AddParagraph({
    Title = "Violence District",
    Desc = "Professional Edition v2.0\nAdapted for Catraz Hub",
    Image = "shield",
    ImageSize = 38
})

-- VISUALS TAB
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "eye",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local ESPSection = VisualsTab:AddSection({
    Name = "ESP Settings",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- ESP Toggle
ESPSection:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "ESPToggle",
    Save = true,
    Callback = function(Value)
        Toggles.ESP = Value
        if Value then 
            EnableESP() 
        else 
            DisableESP() 
        end
    end
})

-- ESP Type Dropdown
ESPSection:AddDropdown({
    Name = "ESP Type",
    Default = "Highlight",
    Options = {"Highlight", "Box", "Name"},
    Multi = false,
    Search = false,
    AllowNone = false,
    Outline = true,
    Callback = function(Value)
        Toggles.ESPType = Value
        if Toggles.ESP then 
            DisableESP() 
            EnableESP() 
        end
    end
})

-- Wallhack Toggle
ESPSection:AddToggle({
    Name = "Wallhack",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "WallhackToggle",
    Save = true,
    Callback = function(Value)
        Toggles.Wallhack = Value
        UpdateWallhack()
    end
})

local WorldSection = VisualsTab:AddSection({
    Name = "World Visuals",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Full Bright Toggle
WorldSection:AddToggle({
    Name = "Full Bright",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "FullBrightToggle",
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

-- No Fog Toggle
WorldSection:AddToggle({
    Name = "No Fog",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "NoFogToggle",
    Save = true,
    Callback = function(Value)
        Toggles.NoFog = Value
        Lighting.FogEnd = Value and 1e9 or 100000
    end
})

-- SURVIVOR TAB
local SurvivorTab = Window:MakeTab({
    Name = "Survivor",
    Icon = "shield",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local AutoFarmSection = SurvivorTab:AddSection({
    Name = "Auto Farm",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Auto Present
AutoFarmSection:AddToggle({
    Name = "Auto Present",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoPresent",
    Save = true,
    Callback = function(Value)
        Toggles.AutoPresent = Value
        if Value then StartLoop("Present") else StopLoop("Present") end
    end
})

-- Auto Gift
AutoFarmSection:AddToggle({
    Name = "Auto Gift",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoGift",
    Save = true,
    Callback = function(Value)
        Toggles.AutoGift = Value
        if Value then StartLoop("Gift") else StopLoop("Gift") end
    end
})

-- Auto Coins
AutoFarmSection:AddToggle({
    Name = "Auto Coins",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoCoins",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCoins = Value
        if Value then StartLoop("Coins") else StopLoop("Coins") end
    end
})

-- Auto Heal
AutoFarmSection:AddToggle({
    Name = "Auto Heal",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHeal",
    Save = true,
    Callback = function(Value)
        Toggles.AutoHeal = Value
        if Value then StartLoop("Heal") else StopLoop("Heal") end
    end
})

local MovementSection = SurvivorTab:AddSection({
    Name = "Movement",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Speed Boost
MovementSection:AddToggle({
    Name = "Speed Boost",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "SpeedBoost",
    Save = true,
    Callback = function(Value)
        Toggles.SpeedBoost = Value
        if Value then
            Player.Character.Humanoid.WalkSpeed = Toggles.SpeedValue
        else
            Player.Character.Humanoid.WalkSpeed = 16
        end
    end
})

-- Speed Slider
MovementSection:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(65, 105, 225),
    Increment = 1,
    ValueName = "WS",
    Outline = true,
    Callback = function(Value)
        Toggles.SpeedValue = Value
        if Toggles.SpeedBoost then
            Player.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- Jump Boost
MovementSection:AddToggle({
    Name = "Jump Boost",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "JumpBoost",
    Save = true,
    Callback = function(Value)
        Toggles.JumpBoost = Value
        if Value then
            Player.Character.Humanoid.JumpPower = Toggles.JumpValue
        else
            Player.Character.Humanoid.JumpPower = 50
        end
    end
})

-- Jump Slider
MovementSection:AddSlider({
    Name = "Jump Value",
    Min = 50,
    Max = 200,
    Default = 100,
    Color = Color3.fromRGB(65, 105, 225),
    Increment = 1,
    ValueName = "JP",
    Outline = true,
    Callback = function(Value)
        Toggles.JumpValue = Value
        if Toggles.JumpBoost then
            Player.Character.Humanoid.JumpPower = Value
        end
    end
})

-- KILLER TAB
local KillerTab = Window:MakeTab({
    Name = "Killer",
    Icon = "swords",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local CombatSection = KillerTab:AddSection({
    Name = "Combat",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Aimbot
CombatSection:AddToggle({
    Name = "Aimbot",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "Aimbot",
    Save = true,
    Callback = function(Value)
        Toggles.Aimbot = Value
        if Value then StartLoop("Aimbot") else StopLoop("Aimbot") end
    end
})

-- Kill Aura
CombatSection:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "KillAura",
    Save = true,
    Callback = function(Value)
        Toggles.KillAura = Value
        if Value then StartLoop("KillAura") else StopLoop("KillAura") end
    end
})

-- Kill Aura Range
CombatSection:AddSlider({
    Name = "Aura Range",
    Min = 5,
    Max = 50,
    Default = 20,
    Color = Color3.fromRGB(65, 105, 225),
    Increment = 1,
    ValueName = "m",
    Outline = true,
    Callback = function(Value)
        Toggles.KillAuraRange = Value
    end
})

-- Nearest Player Info
local TargetSection = KillerTab:AddSection({
    Name = "Target Info",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local TargetParagraph = TargetSection:AddParagraph({
    Title = "Nearest Player",
    Desc = "None",
    Image = "target",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                local target = FindNearestPlayer()
                if target then
                    local dist = (Player.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                    TargetParagraph:SetDesc(target.Name .. "\nDistance: " .. math.floor(dist) .. "m")
                else
                    TargetParagraph:SetDesc("No players nearby")
                end
            end
        }
    }
})

-- TELEPORT TAB
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "move",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local MovementSection2 = TeleportTab:AddSection({
    Name = "Movement",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- NoClip
MovementSection2:AddToggle({
    Name = "NoClip",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "NoClip",
    Save = true,
    Callback = function(Value)
        Toggles.NoClip = Value
        UpdateNoClip()
        Notify(Value and "NoClip ON" or "NoClip OFF", 2)
    end
})

-- TP to Mouse
MovementSection2:AddToggle({
    Name = "TP to Mouse (Right Click)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "TPMouse",
    Save = true,
    Callback = function(Value)
        Toggles.TeleportToMouse = Value
        Notify(Value and "Teleport to Mouse ON" or "Teleport to Mouse OFF", 2)
    end
})

local TeleportSection = TeleportTab:AddSection({
    Name = "Teleport to Player",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Player Dropdown
local PlayerDropdown = TeleportSection:AddDropdown({
    Name = "Select Player",
    Default = "None",
    Options = GetPlayerList(),
    Multi = false,
    Search = true,
    AllowNone = true,
    Outline = true,
    Callback = function(Value)
        local target = Players:FindFirstChild(Value)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            Notify("Teleported to " .. Value, 2)
        end
    end
})

-- Refresh Button
TeleportSection:AddButton({
    Name = "Refresh Player List",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        PlayerDropdown:Refresh(GetPlayerList(), true)
    end
})

local WaypointSection = TeleportTab:AddSection({
    Name = "Waypoints",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Save Position
WaypointSection:AddButton({
    Name = "Save Position",
    Icon = "save",
    Outline = true,
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Position saved!", 2)
        end
    end
})

-- Load Position
WaypointSection:AddButton({
    Name = "Load Position",
    Icon = "download",
    Outline = true,
    Callback = function()
        if SavedPosition then
            Player.Character.HumanoidRootPart.CFrame = SavedPosition
            Notify("Teleported to saved position", 2)
        else
            Notify("No saved position!", 2)
        end
    end
})

-- FARM TAB
local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "zap",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local GeneratorSection = FarmTab:AddSection({
    Name = "Generator",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Auto Farm Generator
GeneratorSection:AddToggle({
    Name = "Auto Farm Generator",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoFarmGen",
    Save = true,
    Callback = function(Value)
        Toggles.AutoFarmGenerator = Value
        if Value then StartLoop("Generator") else StopLoop("Generator") end
    end
})

-- Auto Complete Generator
GeneratorSection:AddToggle({
    Name = "Auto Complete",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoComplete",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCompleteGenerator = Value
        if Value then StartLoop("Complete") else StopLoop("Complete") end
    end
})

-- Find Generator Button
GeneratorSection:AddButton({
    Name = "Find Generator",
    Icon = "search",
    Outline = true,
    Callback = function()
        local gen = FindNearestGenerator()
        if gen then
            Player.Character.HumanoidRootPart.CFrame = gen.CFrame + Vector3.new(0, 3, 0)
            Notify("Found generator", 2)
        else
            Notify("No generator found", 2)
        end
    end
})

-- Stats Paragraph
local StatsSection = FarmTab:AddSection({
    Name = "Stats",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

local FarmStatsParagraph = StatsSection:AddParagraph({
    Title = "World Stats",
    Desc = "Loading...",
    Image = "bar-chart",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                FarmStatsParagraph:SetDesc("Generators: " .. CountGenerators() .. "\nPresents: " .. CountPresents() .. "\nGifts: " .. CountGifts())
            end
        }
    }
})

FarmStatsParagraph:SetDesc("Generators: " .. CountGenerators() .. "\nPresents: " .. CountPresents() .. "\nGifts: " .. CountGifts())

-- MISC TAB
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    PremiumOnly = false,
    Glass = true,
    Outline = true
})

local UtilitySection = MiscTab:AddSection({
    Name = "Utility",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Anti AFK
UtilitySection:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
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

-- Auto Click
UtilitySection:AddToggle({
    Name = "Auto Click",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoClick",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClick = Value
        if Value then StartLoop("Click") else StopLoop("Click") end
    end
})

-- No Skill Check
UtilitySection:AddToggle({
    Name = "No Skill Check",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "NoSkillCheck",
    Save = true,
    Callback = function(Value)
        Toggles.NoSkillCheck = Value
        ToggleSkillCheck(Value)
    end
})

local GUISection = MiscTab:AddSection({
    Name = "GUI",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
})

-- Close GUI Button
GUISection:AddButton({
    Name = "Close GUI",
    Icon = "x-circle",
    Outline = true,
    Callback = function()
        OrionLib:Destroy()
        _G.VD_Loaded = false
    end
})

-- Active Features Counter
local function UpdateActiveCount()
    local active = 0
    for _, v in pairs(Loops) do if v then active = active + 1 end
    for _, toggle in pairs(Toggles) do if toggle then active = active + 1 end end
    return active
end

local StatusParagraph = MiscTab:AddSection({
    Name = "Status",
    TextSize = 17,
    Folded = false,
    Glass = true,
    Outline = true
}):AddParagraph({
    Title = "Active Features",
    Desc = "Calculating...",
    Image = "activity",
    ImageSize = 38
})

StatusParagraph:SetDesc("Active: " .. UpdateActiveCount() .. " features")

--==================================================
-- ADD CONFIG TAB (BUILT-IN)
--==================================================
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 or click floating button", 3)

print("=== Violence District Catraz Edition v2.0 ===")
print("Press F4 to toggle menu")
print("ESP with distance enabled!")
print("NoClip fixed and working!")