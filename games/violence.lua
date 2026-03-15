-- ==================== VIOLENCE DISTRICT - CATRAZ EDITION ====================
-- Versi Stabil - Siap Jalan
-- Fixed & Optimized

-- Cek apakah sudah running
if _G.VD_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Violence District",
        Text = "Script sudah berjalan!",
        Duration = 2
    })
    return 
end

_G.VD_Loaded = true

--==================================================
-- HANDLE ERROR & LOAD LIBRARY
--==================================================

-- Fungsi notifikasi darurat jika library gagal
local function emergencyNotify(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Violence District",
            Text = msg,
            Duration = 3
        })
    end)
end

-- Load Library dengan error handling
local OrionLib
local loadSuccess, loadResult = pcall(function()
    -- Coba beberapa URL cadangan
    local urls = {
        "https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/main/source.lua",
        "https://raw.githubusercontent.com/shlexware/Orion/main/source",
        "https://pastebin.com/raw/7n0qQr1D" -- Backup Orion URL
    }
    
    for _, url in ipairs(urls) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if success and result then
            return result
        end
    end
    error("Gagal load semua URL library")
end)

if not loadSuccess or not OrionLib then
    emergencyNotify("Gagal load library, menggunakan UI sederhana")
    -- Fallback ke UI sederhana
    loadstring([[
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "VD_Simple"
        ScreenGui.Parent = game.CoreGui
        
        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 300, 0, 400)
        MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
        MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Title.Text = "Violence District - Simple"
        Title.TextColor3 = Color3.new(1, 1, 1)
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 16
        Title.Parent = MainFrame
        
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 30, 0, 30)
        CloseBtn.Position = UDim2.new(1, -35, 0, 5)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.new(1, 1, 1)
        CloseBtn.Parent = Title
        CloseBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
            _G.VD_Loaded = false
        end)
        
        local Notif = Instance.new("TextLabel")
        Notif.Size = UDim2.new(1, -20, 0, 50)
        Notif.Position = UDim2.new(0, 10, 0, 50)
        Notif.BackgroundTransparency = 1
        Notif.Text = "Catraz Hub gagal load,\ngunakan executor lain (Krnl/Synapse)"
        Notif.TextColor3 = Color3.new(1, 1, 0)
        Notif.TextWrapped = true
        Notif.Parent = MainFrame
        
        print("Violence District - Simple Mode Loaded")
    ]])()
    return
end

--==================================================
-- VARIABLES
--==================================================
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Toggles
local Toggles = {
    ESP = false,
    Wallhack = false,
    FullBright = false,
    NoFog = false,
    AutoPresent = false,
    AutoGift = false,
    AutoCoins = false,
    AutoHeal = false,
    SpeedBoost = false,
    JumpBoost = false,
    Aimbot = false,
    KillAura = false,
    NoClip = false,
    TeleportToMouse = false,
    AutoFarmGenerator = false,
    AutoCompleteGenerator = false,
    AntiAFK = false,
    AutoClick = false,
    
    -- Values
    SpeedValue = 50,
    JumpValue = 100,
    KillAuraRange = 20
}

-- Loops
local Loops = {}
local SavedPosition = nil
local ESPConnections = {}
local NoClipConnection = nil

--==================================================
-- NOTIFICATION
--==================================================
local function Notify(msg, duration)
    pcall(function()
        OrionLib:MakeNotification({
            Name = "Violence District",
            Content = msg,
            Image = "shield",
            Time = duration or 3
        })
    end)
end

Notify("Script loaded! Press F4", 2)

--==================================================
-- CREATE WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Violence District",
    Subtext = "Professional Edition",
    Version = "v2.0",
    SaveConfig = true,
    ConfigFolder = "VDConfig",
    IntroEnabled = false, -- Matikan intro biar cepet
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 45
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

--==================================================
-- ESP FUNCTIONS
--==================================================
function AddESP(player)
    if not player.Character then return end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "VD_ESP"
    highlight.Parent = player.Character
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    
    -- Name tag dengan jarak
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VD_Name"
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
    
    -- Update jarak
    local connection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or 
               not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                return
            end
            local distance = (player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            nameLabel.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
        end)
    end)
    
    ESPConnections[player] = connection
end

function EnableESP()
    -- Hapus ESP lama
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local old = player.Character:FindFirstChild("VD_ESP")
            if old then old:Destroy() end
            local oldName = player.Character:FindFirstChild("VD_Name")
            if oldName then oldName:Destroy() end
        end
        if ESPConnections[player] then
            ESPConnections[player]:Disconnect()
            ESPConnections[player] = nil
        end
    end
    
    -- Tambah ESP baru
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            AddESP(player)
        end
    end
    
    -- Untuk player baru
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Toggles.ESP and player ~= Player then
                AddESP(player)
            end
        end)
    end)
end

function DisableESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("VD_ESP")
            if highlight then highlight:Destroy() end
            local nameTag = player.Character:FindFirstChild("VD_Name")
            if nameTag then nameTag:Destroy() end
        end
        if ESPConnections[player] then
            ESPConnections[player]:Disconnect()
            ESPConnections[player] = nil
        end
    end
end

--==================================================
-- NOCLIP FUNCTION
--==================================================
function UpdateNoClip()
    if Toggles.NoClip then
        if NoClipConnection then
            NoClipConnection:Disconnect()
        end
        NoClipConnection = RunService.Stepped:Connect(function()
            pcall(function()
                if Toggles.NoClip and Player.Character then
                    for _, part in pairs(Player.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
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
        while Loops[name] and Toggles[name] do
            pcall(function()
                if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    return
                end
                
                if name == "AutoPresent" then
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if v.Name == "Present" and v:IsA("BasePart") then
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
                    
                elseif name == "AutoCoins" then
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
                    
                elseif name == "Aimbot" then
                    local target = FindNearestPlayer()
                    if target and target.Character then
                        local targetPos = target.Character.HumanoidRootPart.Position
                        Player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(Player.Character.HumanoidRootPart.Position, targetPos)
                    end
                    
                elseif name == "KillAura" then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
                            local dist = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= Toggles.KillAuraRange then
                                player.Character.Humanoid.Health = 0
                            end
                        end
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

--==================================================
-- UTILITY FUNCTIONS
--==================================================
function FindNearestPlayer()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local root = Player.Character.HumanoidRootPart
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

-- Teleport to mouse
UserInputService.InputBegan:Connect(function(input)
    if Toggles.TeleportToMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
        pcall(function()
            local target = Mouse.Hit.p
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(target.X, target.Y + 3, target.Z)
        end)
    end
end)

-- Anti AFK
Player.Idled:Connect(function()
    if Toggles.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Character added
Player.CharacterAdded:Connect(function(char)
    Player.Character = char
    task.wait(1)
    if Toggles.NoClip then
        UpdateNoClip()
    end
    if Toggles.SpeedBoost then
        char.Humanoid.WalkSpeed = Toggles.SpeedValue
    end
    if Toggles.JumpBoost then
        char.Humanoid.JumpPower = Toggles.JumpValue
    end
end)

--==================================================
-- CREATE TABS
--==================================================

-- MAIN TAB
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true
})

MainTab:AddParagraph({
    Title = "Player Info",
    Desc = "Name: " .. Player.Name .. "\nDisplay: " .. Player.DisplayName .. "\nAge: " .. Player.AccountAge .. " days",
    Image = "user"
})

MainTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

-- VISUALS TAB
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "eye",
    Glass = true
})

VisualsTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        Toggles.ESP = Value
        if Value then EnableESP() else DisableESP() end
    end
})

VisualsTab:AddToggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(Value)
        Toggles.FullBright = Value
        Lighting.Brightness = Value and 2 or 1
        Lighting.GlobalShadows = not Value
        Lighting.Ambient = Value and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
    end
})

VisualsTab:AddToggle({
    Name = "No Fog",
    Default = false,
    Callback = function(Value)
        Toggles.NoFog = Value
        Lighting.FogEnd = Value and 1e9 or 100000
    end
})

-- MOVEMENT TAB
local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "zap",
    Glass = true
})

MovementTab:AddToggle({
    Name = "Speed Boost",
    Default = false,
    Callback = function(Value)
        Toggles.SpeedBoost = Value
        if Player.Character then
            Player.Character.Humanoid.WalkSpeed = Value and Toggles.SpeedValue or 16
        end
    end
})

MovementTab:AddSlider({
    Name = "Speed Value",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(Value)
        Toggles.SpeedValue = Value
        if Toggles.SpeedBoost and Player.Character then
            Player.Character.Humanoid.WalkSpeed = Value
        end
    end
})

MovementTab:AddToggle({
    Name = "Jump Boost",
    Default = false,
    Callback = function(Value)
        Toggles.JumpBoost = Value
        if Player.Character then
            Player.Character.Humanoid.JumpPower = Value and Toggles.JumpValue or 50
        end
    end
})

MovementTab:AddSlider({
    Name = "Jump Value",
    Min = 50,
    Max = 200,
    Default = 100,
    Callback = function(Value)
        Toggles.JumpValue = Value
        if Toggles.JumpBoost and Player.Character then
            Player.Character.Humanoid.JumpPower = Value
        end
    end
})

MovementTab:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(Value)
        Toggles.NoClip = Value
        UpdateNoClip()
        Notify(Value and "NoClip ON" or "NoClip OFF", 1)
    end
})

MovementTab:AddToggle({
    Name = "TP to Mouse (Right Click)",
    Default = false,
    Callback = function(Value)
        Toggles.TeleportToMouse = Value
    end
})

-- COMBAT TAB
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "swords",
    Glass = true
})

CombatTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        Toggles.Aimbot = Value
        if Value then StartLoop("Aimbot") else StopLoop("Aimbot") end
    end
})

CombatTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(Value)
        Toggles.KillAura = Value
        if Value then StartLoop("KillAura") else StopLoop("KillAura") end
    end
})

CombatTab:AddSlider({
    Name = "Aura Range",
    Min = 5,
    Max = 50,
    Default = 20,
    Callback = function(Value)
        Toggles.KillAuraRange = Value
    end
})

-- FARM TAB
local FarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "package",
    Glass = true
})

FarmTab:AddToggle({
    Name = "Auto Present",
    Default = false,
    Callback = function(Value)
        Toggles.AutoPresent = Value
        if Value then StartLoop("AutoPresent") else StopLoop("AutoPresent") end
    end
})

FarmTab:AddToggle({
    Name = "Auto Coins",
    Default = false,
    Callback = function(Value)
        Toggles.AutoCoins = Value
        if Value then StartLoop("AutoCoins") else StopLoop("AutoCoins") end
    end
})

-- MISC TAB
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    Glass = true
})

MiscTab:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Callback = function(Value)
        Toggles.AntiAFK = Value
    end
})

MiscTab:AddButton({
    Name = "Save Position",
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SavedPosition = Player.Character.HumanoidRootPart.CFrame
            Notify("Position saved!", 1)
        end
    end
})

MiscTab:AddButton({
    Name = "Load Position",
    Callback = function()
        if SavedPosition and Player.Character then
            Player.Character.HumanoidRootPart.CFrame = SavedPosition
            Notify("Teleported!", 1)
        end
    end
})

MiscTab:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        local target = FindNearestPlayer()
        if target and target.Character then
            Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            Notify("Teleported to " .. target.Name, 1)
        end
    end
})

-- Add Config Tab
Window:AddConfigTab({
    Name = "Config",
    Icon = "settings"
})

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

print("=== Violence District Loaded ===")
print("Press F4 to toggle menu")