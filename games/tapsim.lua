-- ==================== TAP SIMULATOR ULTIMATE ====================
-- Premium Script dengan fitur lengkap dan UI modern
-- Game ID: 75992362647444
-- Last Updated: March 2026

--==================================================
-- LOAD LIBRARY
--==================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- VARIABLES GLOBAL
--==================================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- Cek apakah sudah terload
if _G.TapSimLoaded then
    Library:MakeNotification({
        Name = "Tap Simulator",
        Content = "Script sudah berjalan!",
        Time = 2
    })
    return
end
_G.TapSimLoaded = true

--==================================================
-- KONFIGURASI DEFAULT
--==================================================
local Settings = {
    -- Auto Tap
    AutoTap = false,
    TapSpeed = 1,
    TapMethod = "Remote", -- Remote atau Click
    
    -- Auto Rebirth
    AutoRebirth = false,
    RebirthAt = 100,
    RebirthMethod = "Auto", -- Auto atau Manual
    
    -- Auto Hatch
    AutoHatch = false,
    EggType = "Basic Egg",
    HatchDelay = 0.5,
    
    -- Auto Craft
    AutoCraft = false,
    CraftPriority = "Gold",
    CraftDelay = 1,
    
    -- Auto Enchant
    AutoEnchant = false,
    EnchantDelay = 1,
    
    -- Auto Equip
    AutoEquipBest = false,
    EquipDelay = 2,
    
    -- Auto Delete
    AutoDeleteCommon = false,
    DeleteDelay = 3,
    
    -- Auto Collect
    AutoCollect = false,
    CollectDelay = 2,
    
    -- Auto Codes
    AutoCodes = false,
    CodesDelay = 60,
    
    -- Teleport
    TeleportToZone = false,
    TeleportDelay = 5,
    
    -- Misc
    AntiAFK = false,
    FPSBoost = false,
}

--==================================================
-- FUNGSI UTILITY
--==================================================
local function Notify(msg, time)
    Library:MakeNotification({
        Name = "Tap Simulator",
        Content = msg,
        Image = "zap",
        Time = time or 2
    })
end

local function GetPlayerStats()
    local stats = {
        Clicks = 0,
        Rebirths = 0,
        Pets = 0,
        Level = 1
    }
    
    -- Coba ambil dari leaderstats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in pairs(leaderstats:GetChildren()) do
            if v.Name:lower():find("click") or v.Name:lower():find("tap") then
                stats.Clicks = v.Value
            elseif v.Name:lower():find("rebirth") then
                stats.Rebirths = v.Value
            elseif v.Name:lower():find("level") then
                stats.Level = v.Value
            end
        end
    end
    
    -- Hitung pets (jika ada folder pets)
    local petFolder = Player:FindFirstChild("Pets") or Player:FindFirstChild("Inventory")
    if petFolder then
        stats.Pets = #petFolder:GetChildren()
    end
    
    return stats
end

local function FindRemote(name)
    -- Cari remote event di berbagai lokasi
    local locations = {
        ReplicatedStorage,
        Player:FindFirstChild("PlayerGui"),
        Workspace
    }
    
    for _, location in pairs(locations) do
        if location then
            local remote = location:FindFirstChild(name, true)
            if remote then return remote end
        end
    end
    
    -- Cari berdasarkan pola umum
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (
            obj.Name:lower():find("tap") or
            obj.Name:lower():find("click") or
            obj.Name:lower():find("rebirth") or
            obj.Name:lower():find("hatch") or
            obj.Name:lower():find("craft")
        ) then
            return obj
        end
    end
    
    return nil
end

-- Cache remotes
local Remotes = {
    Tap = FindRemote("TapEvent") or FindRemote("Click") or FindRemote("Tap"),
    Rebirth = FindRemote("RebirthEvent") or FindRemote("Rebirth"),
    Hatch = FindRemote("HatchEvent") or FindRemote("HatchEgg") or FindRemote("Hatch"),
    Craft = FindRemote("CraftEvent") or FindRemote("CraftPet") or FindRemote("Craft"),
    Enchant = FindRemote("EnchantEvent") or FindRemote("Enchant"),
    Equip = FindRemote("EquipEvent") or FindRemote("EquipBest"),
    Delete = FindRemote("DeletePet") or FindRemote("Delete"),
    Collect = FindRemote("CollectReward") or FindRemote("Claim"),
    Code = FindRemote("RedeemCode") or FindRemote("Code"),
}

--==================================================
-- CREATE WINDOW UTAMA
--==================================================
local Window = Library:MakeWindow({
    Name = "Tap Simulator Ultimate",
    Subtext = "Premium Edition",
    Version = "v3.0.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSimConfig",
    IntroEnabled = true,
    IntroText = "Tap Simulator Script",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

-- Pilih tema (Default, Ocean, Void, Hackerman)
Library.SelectedTheme = "Ocean"

Notify("Script berhasil diload! Tekan F4 untuk toggle menu", 3)

--==================================================
-- TAB UTAMA (DASHBOARD)
--==================================================
local MainTab = Window:MakeTab({
    Name = "Dashboard",
    Icon = "home",
    Glass = true,
    Outline = true
})

-- Player Info dengan auto-refresh
local stats = GetPlayerStats()
local InfoPara = MainTab:AddParagraph({
    Title = Player.DisplayName,
    Desc = string.format("Clicks: %s\nRebirths: %s\nPets: %s\nLevel: %s", 
           stats.Clicks, stats.Rebirths, stats.Pets, stats.Level),
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                local newStats = GetPlayerStats()
                InfoPara:SetDesc(string.format("Clicks: %s\nRebirths: %s\nPets: %s\nLevel: %s", 
                    newStats.Clicks, newStats.Rebirths, newStats.Pets, newStats.Level))
            end
        }
    }
})

-- Status Koneksi
local function CheckRemotes()
    local working = {}
    for name, remote in pairs(Remotes) do
        if remote then
            table.insert(working, name)
        end
    end
    return #working > 0 and ("✓ " .. table.concat(working, ", ")) or "✗ No remotes found"
end

MainTab:AddParagraph({
    Title = "Connection Status",
    Desc = CheckRemotes(),
    Image = "wifi",
    ImageSize = 38
})

--==================================================
-- TAB AUTO TAP
--==================================================
local TapTab = Window:MakeTab({
    Name = "Auto Tap",
    Icon = "hand",
    Glass = true,
    Outline = true
})

local TapSection = TapTab:AddSection({
    Name = "Pengaturan Auto Tap",
    TextSize = 17,
    Glass = true,
    Outline = true
})

-- Auto Tap Toggle
local AutoTapToggle = TapSection:AddToggle({
    Name = "Auto Tap",
    Default = Settings.AutoTap,
    Color = Color3.fromRGB(0, 255, 0),
    Outline = true,
    Flag = "AutoTap",
    Save = true,
    Callback = function(Value)
        Settings.AutoTap = Value
        if Value then
            Notify("Auto Tap diaktifkan")
            startAutoTap()
        else
            Notify("Auto Tap dimatikan")
            stopAutoTap()
        end
    end
})

-- Metode Tap
TapSection:AddDropdown({
    Name = "Metode Tap",
    Default = "Remote",
    Options = {"Remote", "Click", "Hybrid"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        Settings.TapMethod = Value
        Notify("Metode diubah ke: " .. Value)
    end
})

-- Kecepatan Tap (ms)
local TapSpeedSlider = TapSection:AddSlider({
    Name = "Kecepatan (ms)",
    Min = 1,
    Max = 100,
    Default = Settings.TapSpeed,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "ms",
    Outline = true,
    Callback = function(Value)
        Settings.TapSpeed = Value
    end
})

-- Tombol Test
TapSection:AddButton({
    Name = "Test Tap (10x)",
    Icon = "play",
    Outline = true,
    Callback = function()
        for i = 1, 10 do
            performTap()
            task.wait(0.05)
        end
        Notify("Test selesai!")
    end
})

--==================================================
-- TAB REBIRTH
--==================================================
local RebirthTab = Window:MakeTab({
    Name = "Rebirth",
    Icon = "refresh-cw",
    Glass = true,
    Outline = true
})

local RebirthSection = RebirthTab:AddSection({
    Name = "Auto Rebirth",
    TextSize = 17,
    Glass = true,
    Outline = true
})

-- Auto Rebirth Toggle
RebirthSection:AddToggle({
    Name = "Auto Rebirth",
    Default = Settings.AutoRebirth,
    Color = Color3.fromRGB(255, 165, 0),
    Outline = true,
    Flag = "AutoRebirth",
    Save = true,
    Callback = function(Value)
        Settings.AutoRebirth = Value
        if Value then
            Notify("Auto Rebirth diaktifkan")
            startAutoRebirth()
        else
            stopAutoRebirth()
        end
    end
})

-- Level untuk Rebirth
RebirthSection:AddSlider({
    Name = "Rebirth di Level",
    Min = 1,
    Max = 1000,
    Default = Settings.RebirthAt,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    ValueName = "lvl",
    Outline = true,
    Callback = function(Value)
        Settings.RebirthAt = Value
    end
})

-- Metode Rebirth
RebirthSection:AddDropdown({
    Name = "Metode",
    Default = "Auto",
    Options = {"Auto", "Manual"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        Settings.RebirthMethod = Value
    end
})

-- Tombol Rebirth Manual
RebirthSection:AddButton({
    Name = "Rebirth Sekarang",
    Icon = "zap",
    Outline = true,
    Callback = function()
        performRebirth()
    end
})

--==================================================
-- TAB PETS
--==================================================
local PetsTab = Window:MakeTab({
    Name = "Pets",
    Icon = "dog",
    Glass = true,
    Outline = true
})

-- Auto Hatch
local HatchSection = PetsTab:AddSection({
    Name = "Auto Hatch",
    TextSize = 17,
    Glass = true,
    Outline = true
})

HatchSection:AddToggle({
    Name = "Auto Hatch",
    Default = Settings.AutoHatch,
    Color = Color3.fromRGB(147, 112, 219),
    Outline = true,
    Flag = "AutoHatch",
    Save = true,
    Callback = function(Value)
        Settings.AutoHatch = Value
        if Value then startAutoHatch() else stopAutoHatch() end
    end
})

-- Pilih Egg
local eggOptions = {"Basic Egg", "Rare Egg", "Epic Egg", "Legendary Egg", "Mythic Egg"}
HatchSection:AddDropdown({
    Name = "Tipe Telur",
    Default = Settings.EggType,
    Options = eggOptions,
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        Settings.EggType = Value
    end
})

-- Delay Hatch
HatchSection:AddSlider({
    Name = "Delay (detik)",
    Min = 0.1,
    Max = 5,
    Default = Settings.HatchDelay,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "s",
    Outline = true,
    Callback = function(Value)
        Settings.HatchDelay = Value
    end
})

-- Auto Equip
local EquipSection = PetsTab:AddSection({
    Name = "Auto Equip",
    TextSize = 17,
    Glass = true,
    Outline = true
})

EquipSection:AddToggle({
    Name = "Auto Equip Best Pet",
    Default = Settings.AutoEquipBest,
    Color = Color3.fromRGB(50, 205, 50),
    Outline = true,
    Flag = "AutoEquip",
    Save = true,
    Callback = function(Value)
        Settings.AutoEquipBest = Value
        if Value then startAutoEquip() else stopAutoEquip() end
    end
})

-- Auto Delete
EquipSection:AddToggle({
    Name = "Auto Delete Common",
    Default = Settings.AutoDeleteCommon,
    Color = Color3.fromRGB(255, 99, 71),
    Outline = true,
    Flag = "AutoDelete",
    Save = true,
    Callback = function(Value)
        Settings.AutoDeleteCommon = Value
        if Value then startAutoDelete() else stopAutoDelete() end
    end
})

--==================================================
-- TAB CRAFTING
--==================================================
local CraftTab = Window:MakeTab({
    Name = "Crafting",
    Icon = "hammer",
    Glass = true,
    Outline = true
})

-- Auto Craft
local CraftSection = CraftTab:AddSection({
    Name = "Auto Craft",
    TextSize = 17,
    Glass = true,
    Outline = true
})

CraftSection:AddToggle({
    Name = "Auto Craft",
    Default = Settings.AutoCraft,
    Color = Color3.fromRGB(255, 215, 0),
    Outline = true,
    Flag = "AutoCraft",
    Save = true,
    Callback = function(Value)
        Settings.AutoCraft = Value
        if Value then startAutoCraft() else stopAutoCraft() end
    end
})

-- Priority
CraftSection:AddDropdown({
    Name = "Prioritas",
    Default = Settings.CraftPriority,
    Options = {"Gold", "Rainbow", "Shiny", "Dark", "All"},
    Multi = false,
    Search = false,
    Outline = true,
    Callback = function(Value)
        Settings.CraftPriority = Value
    end
})

-- Auto Enchant
local EnchantSection = CraftTab:AddSection({
    Name = "Auto Enchant",
    TextSize = 17,
    Glass = true,
    Outline = true
})

EnchantSection:AddToggle({
    Name = "Auto Enchant",
    Default = Settings.AutoEnchant,
    Color = Color3.fromRGB(138, 43, 226),
    Outline = true,
    Flag = "AutoEnchant",
    Save = true,
    Callback = function(Value)
        Settings.AutoEnchant = Value
        if Value then startAutoEnchant() else stopAutoEnchant() end
    end
})

--==================================================
-- TAB TELEPORT
--==================================================
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "map-pin",
    Glass = true,
    Outline = true
})

-- Fungsi scan zone
local function ScanZones()
    local zones = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = v.Name
            if name:find("Zone") or name:find("World") or name:find("Island") or name:find("Area") then
                if not zones[name] then
                    table.insert(zones, name)
                end
            end
        end
    end
    
    -- Fallback jika tidak ditemukan
    if #zones == 0 then
        zones = {"World 1", "World 2", "World 3", "World 4", "World 5"}
    end
    
    return zones
end

local TeleportSection = TeleportTab:AddSection({
    Name = "Zone Teleporter",
    TextSize = 17,
    Glass = true,
    Outline = true
})

local zones = ScanZones()
local zoneDropdown

zoneDropdown = TeleportSection:AddDropdown({
    Name = "Pilih Zone",
    Default = zones[1] or "World 1",
    Options = zones,
    Multi = false,
    Search = true,
    Outline = true,
    Callback = function(Value)
        _G.SelectedZone = Value
    end
})

-- Tombol Teleport
TeleportSection:AddButton({
    Name = "Teleport Sekarang",
    Icon = "send",
    Outline = true,
    Callback = function()
        TeleportToZone(_G.SelectedZone or zones[1])
    end
})

-- Auto Teleport
TeleportSection:AddToggle({
    Name = "Auto Teleport (Loop)",
    Default = Settings.TeleportToZone,
    Color = Color3.fromRGB(0, 191, 255),
    Outline = true,
    Flag = "AutoTeleport",
    Save = true,
    Callback = function(Value)
        Settings.TeleportToZone = Value
        if Value then startAutoTeleport() else stopAutoTeleport() end
    end
})

-- Scan Ulang
TeleportSection:AddButton({
    Name = "Scan Ulang Zone",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        local newZones = ScanZones()
        zoneDropdown:Refresh(newZones, true)
        Notify("Zone berhasil di-scan: " .. #newZones .. " ditemukan")
    end
})

--==================================================
-- TAB COLLECTION
--==================================================
local CollectTab = Window:MakeTab({
    Name = "Collection",
    Icon = "gift",
    Glass = true,
    Outline = true
})

-- Auto Collect
CollectTab:AddToggle({
    Name = "Auto Collect Rewards",
    Default = Settings.AutoCollect,
    Color = Color3.fromRGB(255, 215, 0),
    Outline = true,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Settings.AutoCollect = Value
        if Value then startAutoCollect() else stopAutoCollect() end
    end
})

-- Auto Codes
CollectTab:AddToggle({
    Name = "Auto Redeem Codes",
    Default = Settings.AutoCodes,
    Color = Color3.fromRGB(50, 205, 50),
    Outline = true,
    Flag = "AutoCodes",
    Save = true,
    Callback = function(Value)
        Settings.AutoCodes = Value
        if Value then startAutoCodes() else stopAutoCodes() end
    end
})

-- Daftar Codes
local CodesList = {
    "VALENTINES", "SPEEDYTOTEM", "LUCKYTOTEM", "TELEPORT",
    "russo", "lucky", "tacos", "enchant", "update2026",
    "rebirth", "hatchboost", "community", "discord"
}

CollectTab:AddParagraph({
    Title = "Active Codes (March 2026)",
    Desc = table.concat(CodesList, "\n• ", 1, 5) .. "\n• ...dan " .. (#CodesList - 5) .. " lainnya",
    Image = "ticket",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Copy All",
            Callback = function()
                setclipboard(table.concat(CodesList, ", "))
                Notify("Codes copied to clipboard!")
            end
        },
        {
            Title = "Redeem All",
            Callback = function()
                for _, code in ipairs(CodesList) do
                    redeemCode(code)
                    task.wait(1)
                end
            end
        }
    }
})

--==================================================
-- TAB MISC
--==================================================
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "settings",
    Glass = true,
    Outline = true
})

-- Anti AFK
MiscTab:AddToggle({
    Name = "Anti AFK",
    Default = Settings.AntiAFK,
    Color = Color3.fromRGB(255, 255, 255),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Settings.AntiAFK = Value
        if Value then
            Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            Notify("Anti-AFK diaktifkan")
        end
    end
})

-- FPS Boost
MiscTab:AddToggle({
    Name = "FPS Boost",
    Default = Settings.FPSBoost,
    Color = Color3.fromRGB(0, 255, 0),
    Outline = true,
    Flag = "FPSBoost",
    Save = true,
    Callback = function(Value)
        Settings.FPSBoost = Value
        if Value then
            -- Settings for FPS boost
            game:GetService("RunService"):Set3dRenderingEnabled(false)
            workspace.DescendantAdded:Connect(function()
                task.wait()
            end)
            Notify("FPS Boost diaktifkan")
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
    end
})

-- Rejoin
MiscTab:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

-- Server Hop
MiscTab:AddButton({
    Name = "Server Hop",
    Icon = "globe",
    Outline = true,
    Callback = function()
        local x = {}
        for _, v in pairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")).data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(x, v.id)
            end
        end
        if #x > 0 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)], Player)
        end
    end
})

--==================================================
-- TAB CONFIG
--==================================================
Window:AddConfigTab({
    Name = "Settings",
    Icon = "sliders"
})

--==================================================
-- FUNGSI UTAMA
--==================================================

-- Auto Tap
local tapConnection
function performTap()
    if Settings.TapMethod == "Remote" and Remotes.Tap then
        pcall(function()
            Remotes.Tap:FireServer()
        end)
    elseif Settings.TapMethod == "Click" then
        mouse1click()
    elseif Settings.TapMethod == "Hybrid" then
        if Remotes.Tap then
            pcall(function() Remotes.Tap:FireServer() end)
        end
        mouse1click()
    end
end

function startAutoTap()
    if tapConnection then tapConnection:Disconnect() end
    tapConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoTap then
            performTap()
            task.wait(Settings.TapSpeed / 1000)
        end
    end)
end

function stopAutoTap()
    if tapConnection then
        tapConnection:Disconnect()
        tapConnection = nil
    end
end

-- Auto Rebirth
local rebirthConnection
function performRebirth()
    if Remotes.Rebirth then
        pcall(function()
            Remotes.Rebirth:FireServer()
            Notify("Rebirth dilakukan!")
        end)
    else
        -- Coba cari GUI Rebirth
        local gui = Player.PlayerGui:FindFirstChildWhichIsA("ScreenGui", true)
        if gui then
            local btn = gui:FindFirstChild("RebirthButton", true)
            if btn and btn:IsA("TextButton") then
                btn:Click()
            end
        end
    end
end

function startAutoRebirth()
    if rebirthConnection then rebirthConnection:Disconnect() end
    rebirthConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoRebirth then
            local stats = GetPlayerStats()
            if stats.Level >= Settings.RebirthAt then
                performRebirth()
                task.wait(1)
            end
        end
    end)
end

function stopAutoRebirth()
    if rebirthConnection then
        rebirthConnection:Disconnect()
        rebirthConnection = nil
    end
end

-- Auto Hatch
local hatchConnection
function performHatch()
    if Remotes.Hatch then
        pcall(function()
            Remotes.Hatch:FireServer(Settings.EggType)
        end)
    end
end

function startAutoHatch()
    if hatchConnection then hatchConnection:Disconnect() end
    hatchConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoHatch then
            performHatch()
            task.wait(Settings.HatchDelay)
        end
    end)
end

function stopAutoHatch()
    if hatchConnection then
        hatchConnection:Disconnect()
        hatchConnection = nil
    end
end

-- Auto Craft
local craftConnection
function performCraft()
    if Remotes.Craft then
        pcall(function()
            Remotes.Craft:FireServer(Settings.CraftPriority)
        end)
    end
end

function startAutoCraft()
    if craftConnection then craftConnection:Disconnect() end
    craftConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoCraft then
            performCraft()
            task.wait(Settings.CraftDelay)
        end
    end)
end

function stopAutoCraft()
    if craftConnection then
        craftConnection:Disconnect()
        craftConnection = nil
    end
end

-- Auto Enchant
local enchantConnection
function performEnchant()
    if Remotes.Enchant then
        pcall(function()
            Remotes.Enchant:FireServer()
        end)
    end
end

function startAutoEnchant()
    if enchantConnection then enchantConnection:Disconnect() end
    enchantConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoEnchant then
            performEnchant()
            task.wait(Settings.EnchantDelay)
        end
    end)
end

function stopAutoEnchant()
    if enchantConnection then
        enchantConnection:Disconnect()
        enchantConnection = nil
    end
end

-- Auto Equip
local equipConnection
function performEquip()
    if Remotes.Equip then
        pcall(function()
            Remotes.Equip:FireServer("Best")
        end)
    end
end

function startAutoEquip()
    if equipConnection then equipConnection:Disconnect() end
    equipConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoEquipBest then
            performEquip()
            task.wait(Settings.EquipDelay)
        end
    end)
end

function stopAutoEquip()
    if equipConnection then
        equipConnection:Disconnect()
        equipConnection = nil
    end
end

-- Auto Delete
local deleteConnection
function performDelete()
    if Remotes.Delete then
        pcall(function()
            Remotes.Delete:FireServer("Common")
        end)
    end
end

function startAutoDelete()
    if deleteConnection then deleteConnection:Disconnect() end
    deleteConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoDeleteCommon then
            performDelete()
            task.wait(Settings.DeleteDelay)
        end
    end)
end

function stopAutoDelete()
    if deleteConnection then
        deleteConnection:Disconnect()
        deleteConnection = nil
    end
end

-- Auto Collect
local collectConnection
function performCollect()
    if Remotes.Collect then
        pcall(function()
            Remotes.Collect:FireServer()
        end)
    end
end

function startAutoCollect()
    if collectConnection then collectConnection:Disconnect() end
    collectConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoCollect then
            performCollect()
            task.wait(Settings.CollectDelay)
        end
    end)
end

function stopAutoCollect()
    if collectConnection then
        collectConnection:Disconnect()
        collectConnection = nil
    end
end

-- Auto Codes
local codesConnection
function redeemCode(code)
    if Remotes.Code then
        pcall(function()
            Remotes.Code:FireServer(code)
            print("Redeeming code: " .. code)
        end)
    end
end

function startAutoCodes()
    if codesConnection then codesConnection:Disconnect() end
    local codeIndex = 1
    codesConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoCodes then
            if codeIndex > #CodesList then codeIndex = 1 end
            redeemCode(CodesList[codeIndex])
            codeIndex = codeIndex + 1
            task.wait(Settings.CodesDelay)
        end
    end)
end

function stopAutoCodes()
    if codesConnection then
        codesConnection:Disconnect()
        codesConnection = nil
    end
end

-- Teleport
function TeleportToZone(zoneName)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Character not found!")
        return
    end
    
    local found = false
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == zoneName then
            local targetPos
            if v:IsA("BasePart") then
                targetPos = v.Position
            elseif v:IsA("Model") and v.PrimaryPart then
                targetPos = v.PrimaryPart.Position
            end
            
            if targetPos then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos.X, targetPos.Y + 5, targetPos.Z)
                found = true
                Notify("Teleported to " .. zoneName)
                break
            end
        end
    end
    
    if not found then
        -- Fallback to spawn
        local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
        if spawn then
            Player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
            Notify("Zone not found, teleported to spawn")
        end
    end
end

-- Auto Teleport
local teleportConnection
function startAutoTeleport()
    if teleportConnection then teleportConnection:Disconnect() end
    local zoneIndex = 1
    teleportConnection = RunService.Heartbeat:Connect(function()
        if Settings.TeleportToZone and zones and #zones > 0 then
            if zoneIndex > #zones then zoneIndex = 1 end
            TeleportToZone(zones[zoneIndex])
            zoneIndex = zoneIndex + 1
            task.wait(Settings.TeleportDelay)
        end
    end)
end

function stopAutoTeleport()
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
end

--==================================================
-- CLEANUP FUNCTION
--==================================================
local function Cleanup()
    stopAutoTap()
    stopAutoRebirth()
    stopAutoHatch()
    stopAutoCraft()
    stopAutoEnchant()
    stopAutoEquip()
    stopAutoDelete()
    stopAutoCollect()
    stopAutoCodes()
    stopAutoTeleport()
end

--==================================================
-- INITIALIZATION
--==================================================
Library:Init()

-- Auto-refresh player info setiap 5 detik
task.spawn(function()
    while true do
        task.wait(5)
        local newStats = GetPlayerStats()
        InfoPara:SetDesc(string.format("Clicks: %s\nRebirths: %s\nPets: %s\nLevel: %s", 
            newStats.Clicks, newStats.Rebirths, newStats.Pets, newStats.Level))
    end
end)

-- Handle character respawn
Player.CharacterAdded:Connect(function()
    task.wait(2)
    if Settings.AutoTap then startAutoTap() end
    if Settings.AutoRebirth then startAutoRebirth() end
end)

-- Cleanup on unload
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "TapSimulator" then
        Cleanup()
        _G.TapSimLoaded = false
    end
end)

Notify("Script siap digunakan! Tekan F4 untuk toggle menu", 3)
print("=== Tap Simulator Ultimate v3.0 ===")
print("Fitur lengkap dengan UI premium!")