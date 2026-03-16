-- ==================== TAP SIMULATOR SCRIPT ====================
-- All-in-One Automation Script
-- Fitur: Auto Tap, Auto Hatch, Auto Rebirth, Teleport, dll
-- Last Updated: 2026

-- Load UI Library (Menggunakan Catraz Hub untuk tampilan premium)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

-- Variabel Utama
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Toggle States
local Toggles = {
    AutoTap = false,
    AutoRebirth = false,
    AutoHatch = false,
    AutoCraft = false,
    AutoEnchant = false,
    AutoCollect = false,
    AutoEquipBest = false,
    AutoDeleteCommon = false,
    TeleportToZone = false,
    InfiniteYield = false
}

-- Loops
local Loops = {}

--==================================================
-- CREATE WINDOW
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Tap Simulator Pro",
    Subtext = "All-in-One Automation",
    Version = "v2.0.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSimConfig",
    IntroEnabled = true,
    IntroText = "Tap Simulator Script",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    WindowTransparency = 0.05
})

-- Set Theme
OrionLib.SelectedTheme = "Ocean"

--==================================================
-- NOTIFICATION FUNCTION
--==================================================
local function Notify(msg)
    OrionLib:MakeNotification({
        Name = "Tap Simulator",
        Content = msg,
        Image = "info",
        Time = 2
    })
end

Notify("Script loaded successfully!")

--==================================================
-- MAIN TAB
--==================================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    Glass = true,
    Outline = true
})

-- Player Info Section
local InfoSection = MainTab:AddSection({
    Name = "Player Info",
    TextSize = 17,
    Glass = true,
    Outline = true
})

-- Get game currency (adjust based on actual game)
local function getClicks()
    -- This depends on the game's actual value storage
    -- You may need to adjust this based on the game's structure
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                return v.Value
            end
        end
    end
    return "N/A"
end

InfoSection:AddParagraph({
    Title = Player.Name,
    Desc = "Clicks: " .. tostring(getClicks()) .. "\nStatus: Connected",
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                -- Refresh info
            end
        }
    }
})

-- Auto Tap Section
local TapSection = MainTab:AddSection({
    Name = "Auto Tap",
    TextSize = 17,
    Glass = true,
    Outline = true
})

TapSection:AddToggle({
    Name = "Auto Tap",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoTap",
    Save = true,
    Callback = function(Value)
        Toggles.AutoTap = Value
        if Value then StartLoop("Tap") else StopLoop("Tap") end
    end
})

TapSection:AddSlider({
    Name = "Tap Speed (ms)",
    Min = 1,
    Max = 100,
    Default = 10,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "ms",
    Outline = true,
    Callback = function(Value)
        _G.TapSpeed = Value
    end
})

-- Auto Rebirth Section
local RebirthSection = MainTab:AddSection({
    Name = "Rebirth",
    TextSize = 17,
    Glass = true,
    Outline = true
})

RebirthSection:AddToggle({
    Name = "Auto Rebirth",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoRebirth",
    Save = true,
    Callback = function(Value)
        Toggles.AutoRebirth = Value
        if Value then StartLoop("Rebirth") else StopLoop("Rebirth") end
    end
})

RebirthSection:AddSlider({
    Name = "Rebirth At Level",
    Min = 1,
    Max = 1000,
    Default = 100,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "lvl",
    Outline = true,
    Callback = function(Value)
        _G.RebirthLevel = Value
    end
})

--==================================================
-- PETS TAB
--==================================================
local PetsTab = Window:MakeTab({
    Name = "Pets",
    Icon = "dog",
    Glass = true,
    Outline = true
})

local HatchSection = PetsTab:AddSection({
    Name = "Egg Hatching",
    TextSize = 17,
    Glass = true,
    Outline = true
})

HatchSection:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoHatch",
    Save = true,
    Callback = function(Value)
        Toggles.AutoHatch = Value
        if Value then StartLoop("Hatch") else StopLoop("Hatch") end
    end
})

HatchSection:AddDropdown({
    Name = "Egg Type",
    Default = "Basic Egg",
    Options = {"Basic Egg", "Rare Egg", "Epic Egg", "Legendary Egg"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        _G.EggType = Value
    end
})

-- Pet Management Section
local PetManageSection = PetsTab:AddSection({
    Name = "Pet Management",
    TextSize = 17,
    Glass = true,
    Outline = true
})

PetManageSection:AddToggle({
    Name = "Auto Equip Best",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoEquip",
    Save = true,
    Callback = function(Value)
        Toggles.AutoEquipBest = Value
        if Value then StartLoop("Equip") else StopLoop("Equip") end
    end
})

PetManageSection:AddToggle({
    Name = "Auto Delete Common",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoDelete",
    Save = true,
    Callback = function(Value)
        Toggles.AutoDeleteCommon = Value
        if Value then StartLoop("Delete") else StopLoop("Delete") end
    end
})

--==================================================
-- CRAFTING TAB
--==================================================
local CraftTab = Window:MakeTab({
    Name = "Crafting",
    Icon = "hammer",
    Glass = true,
    Outline = true
})

local CraftSection = CraftTab:AddSection({
    Name = "Auto Craft",
    TextSize = 17,
    Glass = true,
    Outline = true
})

CraftSection:AddToggle({
    Name = "Auto Craft Pets",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoCraft",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCraft = Value
        if Value then StartLoop("Craft") else StopLoop("Craft") end
    end
})

CraftSection:AddToggle({
    Name = "Auto Enchant",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoEnchant",
    Save = true,
    Callback = function(Value)
        Toggles.AutoEnchant = Value
        if Value then StartLoop("Enchant") else StopLoop("Enchant") end
    end
})

CraftSection:AddDropdown({
    Name = "Craft Priority",
    Default = "Gold",
    Options = {"Gold", "Rainbow", "Shiny", "All"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        _G.CraftPriority = Value
    end
})

--==================================================
-- TELEPORT TAB
--==================================================
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "map-pin",
    Glass = true,
    Outline = true
})

local TeleportSection = TeleportTab:AddSection({
    Name = "Zone Teleporter",
    TextSize = 17,
    Glass = true,
    Outline = true
})

-- Function to find teleport parts (adjust based on game)
local function getZones()
    local zones = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:find("Zone") or v.Name:find("Island") or v.Name:find("World") then
            if v:IsA("BasePart") or v:IsA("Model") then
                table.insert(zones, v.Name)
            end
        end
    end
    if #zones == 0 then
        return {"World 1", "World 2", "World 3"}
    end
    return zones
end

TeleportSection:AddDropdown({
    Name = "Select Zone",
    Default = getZones()[1] or "World 1",
    Options = getZones(),
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        _G.TargetZone = Value
    end
})

TeleportSection:AddButton({
    Name = "Teleport to Zone",
    Icon = "send",
    Outline = true,
    Callback = function()
        TeleportToZone(_G.TargetZone)
    end
})

TeleportSection:AddToggle({
    Name = "Auto Teleport (Loop)",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoTeleport",
    Save = true,
    Callback = function(Value)
        Toggles.TeleportToZone = Value
        if Value then StartLoop("Teleport") else StopLoop("Teleport") end
    end
})

--==================================================
-- COLLECTION TAB
--==================================================
local CollectTab = Window:MakeTab({
    Name = "Collection",
    Icon = "gift",
    Glass = true,
    Outline = true
})

local CollectSection = CollectTab:AddSection({
    Name = "Auto Collect",
    TextSize = 17,
    Glass = true,
    Outline = true
})

CollectSection:AddToggle({
    Name = "Auto Collect Rewards",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCollect = Value
        if Value then StartLoop("Collect") else StopLoop("Collect") end
    end
})

CollectSection:AddToggle({
    Name = "Auto Claim Codes",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "AutoCodes",
    Save = true,
    Callback = function(Value)
        Toggles.AutoCodes = Value
        if Value then StartLoop("Codes") else StopLoop("Codes") end
    end
})

--==================================================
-- MISC TAB
--==================================================
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    Glass = true,
    Outline = true
})

local MiscSection = MiscTab:AddSection({
    Name = "Utilities",
    TextSize = 17,
    Glass = true,
    Outline = true
})

MiscSection:AddToggle({
    Name = "Infinite Yield",
    Default = false,
    Color = Color3.fromRGB(65, 105, 225),
    Outline = true,
    Flag = "InfiniteYield",
    Save = true,
    Callback = function(Value)
        Toggles.InfiniteYield = Value
        if Value then
            -- Infinite yield would require modifying game values
            Notify("Feature in development")
        end
    end
})

MiscSection:AddButton({
    Name = "Anti-AFK",
    Icon = "shield",
    Outline = true,
    Callback = function()
        Player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        Notify("Anti-AFK enabled")
    end
})

MiscSection:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

--==================================================
-- GAME CODES (Updated March 2026) [citation:3]
--==================================================
local CodesSection = MiscTab:AddSection({
    Name = "Active Game Codes",
    TextSize = 17,
    Glass = true,
    Outline = true
})

CodesSection:AddParagraph({
    Title = "Working Codes (March 2026)",
    Desc = "• VALENTINES - Social Dragon\n• SPEEDYTOTEM - Hatch Speed Totem x2\n• LUCKYTOTEM - Lucky Totem x1\n• TELEPORT - Teleport Crystal x2\n• russo - 5 Tokens\n• lucky - Lucky Potion III\n• tacos - Taco Potion\n• enchant - Enchant Crystal x5",
    Image = "ticket",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Copy All",
            Callback = function()
                setclipboard("VALENTINES, SPEEDYTOTEM, LUCKYTOTEM, TELEPORT, russo, lucky, tacos, enchant")
                Notify("Codes copied to clipboard!")
            end
        }
    }
})

--==================================================
-- CONFIG TAB
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "sliders"
})

--==================================================
-- LOOP FUNCTIONS
--==================================================
_G.TapSpeed = 10
_G.RebirthLevel = 100
_G.EggType = "Basic Egg"
_G.CraftPriority = "Gold"

function StartLoop(name)
    if Loops[name] then return end
    Loops[name] = true
    
    task.spawn(function()
        while Loops[name] do
            if name == "Tap" and Toggles.AutoTap then
                -- Simulate tap
                local args = { [1] = "Tap" } -- Adjust based on game's remote
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent") or 
                              game:GetService("ReplicatedStorage"):FindFirstChild("TapEvent")
                if remote then
                    pcall(function()
                        remote:FireServer(unpack(args))
                    end)
                else
                    -- Fallback: click at center
                    mouse1click()
                end
                task.wait(_G.TapSpeed / 1000)
                
            elseif name == "Rebirth" and Toggles.AutoRebirth then
                -- Check if can rebirth and do it
                local rebirthRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Rebirth") or
                                     game:GetService("ReplicatedStorage"):FindFirstChild("RebirthEvent")
                if rebirthRemote then
                    pcall(function()
                        rebirthRemote:FireServer()
                    end)
                end
                task.wait(1)
                
            elseif name == "Hatch" and Toggles.AutoHatch then
                -- Hatch egg
                local hatchRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Hatch") or
                                   game:GetService("ReplicatedStorage"):FindFirstChild("HatchEgg")
                if hatchRemote then
                    pcall(function()
                        hatchRemote:FireServer(_G.EggType)
                    end)
                end
                task.wait(0.5)
                
            elseif name == "Craft" and Toggles.AutoCraft then
                -- Craft pets
                local craftRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Craft") or
                                   game:GetService("ReplicatedStorage"):FindFirstChild("CraftPets")
                if craftRemote then
                    pcall(function()
                        craftRemote:FireServer(_G.CraftPriority)
                    end)
                end
                task.wait(1)
                
            elseif name == "Enchant" and Toggles.AutoEnchant then
                -- Enchant pets
                local enchantRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Enchant") or
                                     game:GetService("ReplicatedStorage"):FindFirstChild("EnchantPet")
                if enchantRemote then
                    pcall(function()
                        enchantRemote:FireServer()
                    end)
                end
                task.wait(1)
                
            elseif name == "Equip" and Toggles.AutoEquipBest then
                -- Equip best pet
                local equipRemote = game:GetService("ReplicatedStorage"):FindFirstChild("EquipBest") or
                                   game:GetService("ReplicatedStorage"):FindFirstChild("EquipPet")
                if equipRemote then
                    pcall(function()
                        equipRemote:FireServer("Best")
                    end)
                end
                task.wait(2)
                
            elseif name == "Delete" and Toggles.AutoDeleteCommon then
                -- Delete common pets
                local deleteRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DeletePet") or
                                    game:GetService("ReplicatedStorage"):FindFirstChild("Delete")
                if deleteRemote then
                    pcall(function()
                        deleteRemote:FireServer("Common")
                    end)
                end
                task.wait(3)
                
            elseif name == "Collect" and Toggles.AutoCollect then
                -- Collect rewards
                local collectRemote = game:GetService("ReplicatedStorage"):FindFirstChild("CollectReward") or
                                     game:GetService("ReplicatedStorage"):FindFirstChild("Claim")
                if collectRemote then
                    pcall(function()
                        collectRemote:FireServer()
                    end)
                end
                task.wait(2)
                
            elseif name == "Codes" and Toggles.AutoCodes then
                -- Auto redeem codes
                local codes = {"VALENTINES", "SPEEDYTOTEM", "LUCKYTOTEM", "TELEPORT", "russo", "lucky", "tacos", "enchant"}
                local codeRemote = game:GetService("ReplicatedStorage"):FindFirstChild("RedeemCode") or
                                  game:GetService("ReplicatedStorage"):FindFirstChild("Code")
                if codeRemote then
                    for _, code in ipairs(codes) do
                        pcall(function()
                            codeRemote:FireServer(code)
                        end)
                        task.wait(1)
                    end
                end
                task.wait(60) -- Check every minute
                
            elseif name == "Teleport" and Toggles.TeleportToZone then
                TeleportToZone(_G.TargetZone)
                task.wait(5)
            end
            
            task.wait()
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

--==================================================
-- TELEPORT FUNCTION
--==================================================
function TeleportToZone(zoneName)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Try to find the zone part
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == zoneName or v.Name:find(zoneName) then
            local targetCFrame
            if v:IsA("BasePart") then
                targetCFrame = v.CFrame
            elseif v:IsA("Model") and v.PrimaryPart then
                targetCFrame = v.PrimaryPart.CFrame
            end
            
            if targetCFrame then
                Player.Character.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 5, 0)
                Notify("Teleported to " .. zoneName)
                return
            end
        end
    end
    
    -- Fallback: try to find by common zone names
    local commonZones = {
        ["World 1"] = Vector3.new(0, 10, 0),
        ["World 2"] = Vector3.new(100, 10, 100),
        ["World 3"] = Vector3.new(200, 10, 200)
    }
    
    if commonZones[zoneName] then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(commonZones[zoneName])
        Notify("Teleported to " .. zoneName)
    else
        Notify("Zone not found!")
    end
end

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("Press F4 to toggle menu | Tap Simulator Script v2.0")
print("=== Tap Simulator Script Loaded ===")
print("Features: Auto Tap, Auto Hatch, Auto Rebirth, Teleport")