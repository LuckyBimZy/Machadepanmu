-- ==================== GAMES/VIOLENCE.LUA ====================
-- Script untuk game Violence District
-- File ini akan dipanggil oleh loader.lua ketika placeId cocok

-- Cek apakah sudah diload
if _G.ViolenceLoaded then
    return -- Hindari double load
end
_G.ViolenceLoaded = true

print("🔰 Violence District Script Starting...")

--==================================================
-- VARIABLES & CONFIGURATION
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

-- Global toggle variables
_G.SurvivorESP = false
_G.KillerESP = false
_G.GeneratorESP = false
_G.UnlimitedZoom = false
_G.FullBright = false
_G.AutoFarmGenerator = false
_G.AutoFarmPresent = false
_G.FarmGift = false
_G.NoClip = false
_G.FlickerSpeed = false
_G.NoSkillCheck = false
_G.RemoveAllSkillCheck = false
_G.AutoTeleport = false
_G.Aimbot = false
_G.Wallhack = false
_G.BodyLock = false
_G.AutoClick = false
_G.InfiniteStamina = false
_G.SpeedBoost = false
_G.JumpBoost = false
_G.GravityControl = false
_G.SelectedTarget = nil

--==================================================
-- LIBRARY LOADER
--==================================================

local Library
local Window

-- Try loading Kavo UI
local success, lib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyBimZy/Machadepanmu/refs/heads/main/loader.lua"))()
end)

if success and lib then
    Library = lib
    Window = Library.CreateLib("Violence District", "DarkTheme")
    print("✅ Kavo UI loaded")
else
    -- Fallback: Create custom GUI
    print("⚠️ Using custom GUI fallback")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ViolenceDistrictGUI"
    ScreenGui.Parent = game.CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.Text = "Violence District"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Simple tab system
    Window = {
        CurrentTab = "Visuals",
        Tabs = {},
        AddTab = function(_, name)
            return {
                AddSection = function(_, sectionName)
                    return {
                        AddToggle = function(_, toggleName, _, callback) end,
                        AddButton = function(_, buttonName, _, callback) end,
                        AddDropdown = function(_, dropdownName, _, list, callback) end,
                        AddLabel = function(_, text) end,
                        AddSlider = function(_, sliderName, _, min, max, callback) end
                    }
                end
            }
        end
    }
end

--==================================================
-- CREATE TABS
--==================================================

local InfoTab = Window:AddTab("Info")
local VisualsTab = Window:AddTab("Visuals")
local SurvivorTab = Window:AddTab("Survivor")
local KillerTab = Window:AddTab("Killer")
local TeleportTab = Window:AddTab("Teleport")
local FarmTab = Window:AddTab("Auto Farm")
local MiscTab = Window:AddTab("Misc")
local SettingsTab = Window:AddTab("Settings")

--==================================================
-- INFO TAB
--==================================================

local InfoSection = InfoTab:AddSection("Server Information")
InfoSection:AddLabel("Game: Violence District")
InfoSection:AddLabel("Server ID: " .. game.JobId)
InfoSection:AddLabel("Players: " .. #game.Players:GetPlayers())
InfoSection:AddLabel("Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms")

InfoSection:AddButton("Refresh Info", function()
    InfoSection:AddLabel("Players: " .. #game.Players:GetPlayers())
end)

local CreditSection = InfoTab:AddSection("Credits")
CreditSection:AddLabel("Script by: LuckyBimZy")
CreditSection:AddLabel("Version: 1.0")
CreditSection:AddLabel("GitHub: Machadepanmu")

--==================================================
-- VISUALS TAB
--==================================================

local VisualsSection = VisualsTab:AddSection("ESP Settings")

-- Survivor ESP
VisualsSection:AddToggle("Survivor ESP (Blue)", function(state)
    _G.SurvivorESP = state
    if state then
        EnableESP("Survivor", Color3.fromRGB(0, 100, 255))
    else
        DisableESP("Survivor")
    end
end)

-- Killer ESP
VisualsSection:AddToggle("Killer ESP (Red)", function(state)
    _G.KillerESP = state
    if state then
        EnableESP("Killer", Color3.fromRGB(255, 0, 0))
    else
        DisableESP("Killer")
    end
end)

-- Generator ESP
VisualsSection:AddToggle("Generator ESP (Green)", function(state)
    _G.GeneratorESP = state
    if state then
        EnableGeneratorESP()
    else
        DisableGeneratorESP()
    end
end)

-- Unlimited Zoom
VisualsSection:AddToggle("Unlimited Zoom", function(state)
    _G.UnlimitedZoom = state
    if state then
        Camera.FieldOfView = 120
    else
        Camera.FieldOfView = 70
    end
end)

-- Full Bright
VisualsSection:AddToggle("Full Bright", function(state)
    _G.FullBright = state
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

-- Wallhack
VisualsSection:AddToggle("Wallhack", function(state)
    _G.Wallhack = state
    UpdateWallhack()
end)

--==================================================
-- SURVIVOR TAB
--==================================================

local SurvivorSection = SurvivorTab:AddSection("Survivor Features")

-- Auto-Farm Present
SurvivorSection:AddToggle("Auto-Farm Present", function(state)
    _G.AutoFarmPresent = state
    StartAutoFarmPresent()
end)

-- Farm Gift to Christmas Tree
SurvivorSection:AddToggle("Farm Gift → Teleport to Tree", function(state)
    _G.FarmGift = state
    StartFarmGift()
end)

-- Flicker/Blink Speed
SurvivorSection:AddToggle("Flicker/Blink Speed", function(state)
    _G.FlickerSpeed = state
    if state then
        Humanoid.WalkSpeed = 100
    else
        Humanoid.WalkSpeed = 16
    end
end)

-- Infinite Stamina
SurvivorSection:AddToggle("Infinite Stamina", function(state)
    _G.InfiniteStamina = state
end)

-- Speed Boost
SurvivorSection:AddToggle("Speed Boost", function(state)
    _G.SpeedBoost = state
    if state then
        Humanoid.WalkSpeed = 50
    else
        Humanoid.WalkSpeed = 16
    end
end)

-- Jump Boost
SurvivorSection:AddToggle("Jump Boost", function(state)
    _G.JumpBoost = state
    if state then
        Humanoid.JumpPower = 100
    else
        Humanoid.JumpPower = 50
    end
end)

-- Body Lock Section
local BodyLockSection = SurvivorTab:AddSection("Body Lock System")

BodyLockSection:AddDropdown("Select Target", GetPlayerList(), function(playerName)
    _G.SelectedTarget = game.Players:FindFirstChild(playerName)
end)

BodyLockSection:AddButton("Refresh List", function()
    BodyLockSection:AddDropdown("Select Target", GetPlayerList(), function(playerName)
        _G.SelectedTarget = game.Players:FindFirstChild(playerName)
    end)
end)

BodyLockSection:AddToggle("Body Lock", function(state)
    _G.BodyLock = state
    StartBodyLock()
end)

--==================================================
-- KILLER TAB
--==================================================

local KillerSection = KillerTab:AddSection("Killer Features")

-- Aimbot
KillerSection:AddToggle("Aimbot", function(state)
    _G.Aimbot = state
    StartAimbot()
end)

-- Target Selection
local KillerTargetSection = KillerTab:AddSection("Target Selection")
KillerTargetSection:AddDropdown("Select Target", GetPlayerList(), function(playerName)
    _G.KillerTarget = game.Players:FindFirstChild(playerName)
end)

KillerTargetSection:AddButton("Refresh", function()
    KillerTargetSection:AddDropdown("Select Target", GetPlayerList(), function(playerName)
        _G.KillerTarget = game.Players:FindFirstChild(playerName)
    end)
end)

-- Kill Aura
KillerTargetSection:AddToggle("Kill Aura", function(state)
    _G.KillAura = state
    StartKillAura()
end)

--==================================================
-- TELEPORT TAB
--==================================================

local TeleportSection = TeleportTab:AddSection("Teleportation")

-- NoClip
TeleportSection:AddToggle("NoClip", function(state)
    _G.NoClip = state
    UpdateNoClip()
end)

-- Teleport to Player
local TPPlayerSection = TeleportTab:AddSection("Teleport to Player")
TPPlayerSection:AddDropdown("Target Player", GetPlayerList(), function(playerName)
    _G.TPTarget = game.Players:FindFirstChild(playerName)
end)

TPPlayerSection:AddButton("Refresh List", function()
    TPPlayerSection:AddDropdown("Target Player", GetPlayerList(), function(playerName)
        _G.TPTarget = game.Players:FindFirstChild(playerName)
    end)
end)

TPPlayerSection:AddButton("Teleport to Target", function()
    if _G.TPTarget and _G.TPTarget.Character then
        RootPart.CFrame = _G.TPTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
    end
end)

--==================================================
-- AUTO FARM TAB
--==================================================

local FarmSection = FarmTab:AddSection("Generator Farm")

FarmSection:AddToggle("Auto-Farm Generator", function(state)
    _G.AutoFarmGenerator = state
    StartAutoFarmGenerator()
end)

FarmSection:AddToggle("Auto Teleport & Complete", function(state)
    _G.AutoTeleport = state
    StartAutoTeleport()
end)

-- Present Farm
local PresentSection = FarmTab:AddSection("Present Farm")
PresentSection:AddToggle("Auto Collect Presents", function(state)
    _G.AutoCollectPresent = state
    StartAutoCollectPresent()
end)

--==================================================
-- MISC TAB
--==================================================

local MiscSection = MiscTab:AddSection("Utility")

-- Anti AFK
MiscSection:AddToggle("Anti AFK", function(state)
    _G.AntiAFK = state
    if state then
        Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Auto Click
MiscSection:AddToggle("Auto Click", function(state)
    _G.AutoClick = state
    StartAutoClick()
end)

--==================================================
-- SETTINGS TAB
--==================================================

local SettingsSection = SettingsTab:AddSection("Skill Check Settings")

SettingsSection:AddToggle("No Skill Check", function(state)
    _G.NoSkillCheck = state
    ToggleSkillCheck(state)
end)

SettingsSection:AddToggle("Remove Generator Skill Check", function(state)
    _G.RemoveGeneratorSC = state
end)

SettingsSection:AddToggle("Remove Healing Skill Check", function(state)
    _G.RemoveHealingSC = state
end)

--==================================================
-- CORE FUNCTIONS
--==================================================

-- ESP Functions
function EnableESP(type, color)
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
end

function DisableESP(type)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if highlight then highlight:Destroy() end
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

-- Wallhack Update
function UpdateWallhack()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Player.Character) then
            if _G.Wallhack then
                if v.Name ~= "HumanoidRootPart" and v.Transparency < 0.5 then
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

-- NoClip Update
function UpdateNoClip()
    if _G.NoClip then
        RunService:BindToRenderStep("NoClip", 0, function()
            if _G.NoClip and Character then
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
    spawn(function()
        while _G.AutoFarmGenerator do
            task.wait(0.1)
            local generator = FindNearestGenerator()
            if generator then
                RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
                local args = { [1] = "RepairGenerator", [2] = generator }
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then remote:FireServer(unpack(args)) end
                end)
            end
        end
    end)
end

function StartAutoTeleport()
    spawn(function()
        while _G.AutoTeleport do
            task.wait(0.1)
            local generator = FindNearestGenerator()
            if generator then
                RootPart.CFrame = generator.CFrame + Vector3.new(0, 3, 0)
                local args = { [1] = "CompleteGenerator", [2] = generator }
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
                    if remote then remote:FireServer(unpack(args)) end
                end)
            end
        end
    end)
end

function StartAutoFarmPresent()
    spawn(function()
        while _G.AutoFarmPresent do
            task.wait(0.1)
            local present = FindNearestPresent()
            if present then
                RootPart.CFrame = present.CFrame + Vector3.new(0, 3, 0)
                local prompt = present:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
            end
        end
    end)
end

function StartFarmGift()
    spawn(function()
        while _G.FarmGift do
            task.wait(0.1)
            local gift = FindNearestGift()
            if gift then
                RootPart.CFrame = gift.CFrame + Vector3.new(0, 3, 0)
                local prompt = gift:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
                
                local tree = FindChristmasTree()
                if tree then
                    task.wait(0.5)
                    RootPart.CFrame = tree.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end)
end

-- Body Lock
function StartBodyLock()
    spawn(function()
        while _G.BodyLock and _G.SelectedTarget do
            task.wait()
            if _G.SelectedTarget.Character and _G.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = _G.SelectedTarget.Character.HumanoidRootPart.Position
                RootPart.CFrame = CFrame.new(targetPos.x, targetPos.y + 3, targetPos.z)
            end
        end
    end)
end

-- Aimbot
function StartAimbot()
    spawn(function()
        while _G.Aimbot do
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
    spawn(function()
        while _G.KillAura do
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
    spawn(function()
        while _G.AutoClick do
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

-- Utility Functions
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
-- FINALIZATION
--==================================================

print("========================================")
print("✅ Violence District Script Loaded!")
print("📁 GitHub: LuckyBimZy/Machadepanmu")
print("🕒 " .. os.date("%Y-%m-%d %H:%M:%S"))
print("========================================")

_G.ViolenceLoaded = true
return true