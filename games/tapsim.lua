-- ==================== TAP SIMULATOR - ULTIMATE EDITION ====================
-- Premium Auto Farm Script dengan Advanced Features
-- Menggabungkan: Exploit Toolkit + Auto Farm + Advanced Recon
-- UI: Catraz Hub Library
-- Version: 2.0

if _G.TapSimUltimate then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Tap Simulator",
        Text = "Script already loaded!",
        Duration = 2
    })
    return 
end

_G.TapSimUltimate = true

--==================================================
-- LOAD CATRAZ HUB LIBRARY
--==================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nurvian/Catraz-x-Orion-UI/refs/heads/main/source.lua"))()

--==================================================
-- SERVICES & VARIABLES
--==================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local Mouse = player:GetMouse()
local gui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIGURATION
--==================================================
local CONFIG = {
    maxDepth = 20,
    autoScan = true,
    maxItemsPerCategory = 100,
    maxTextSize = 50000,
    paginationSize = 50
}

--==================================================
-- TOGGLES & STATE
--==================================================
local Toggles = {
    -- Auto Farm
    AutoTap = false,
    TapSpeed = 0.01,
    AutoClicker = false,
    ClickSpeed = 0.001,
    
    -- Rebirth
    AutoRebirth = false,
    RebirthDelay = 1,
    
    -- Eggs & Pets
    AutoBuyEggs = false,
    AutoHatchEggs = false,
    EggType = "Basic",
    AutoPetFarm = false,
    
    -- Rewards
    AutoClaimPacks = false,
    ClaimDelay = 5,
    AutoCollect = false,
    
    -- Exploits
    RemoteSpy = false,
    FireAllClickDetectors = false,
    ShowHiddenUIs = false,
    
    -- Visuals
    ESP = false,
    FullBright = false,
    NoFog = false,
    
    -- Misc
    AntiAFK = false,
    ServerHop = false
}

-- Stats
local Stats = {
    clicks = 0,
    rebirths = 0,
    packsClaimed = 0,
    eggsHatched = 0,
    runtime = 0,
    remotesFound = 0,
    hiddenUIs = 0
}

-- Remote storage
local Remotes = {
    click = nil,
    rebirth = nil,
    purchase = nil,
    foreverPackRequest = nil,
    foreverPackClaim = nil,
    petAttack = nil,
    
    -- Categories
    byCategory = {
        purchase = {},
        claim = {},
        rebirth = {},
        pet = {},
        upgrade = {},
        other = {}
    }
}

-- Exploit data
local exploitData = {
    remotes = {events = {}, functions = {}},
    hiddenGuis = {},
    accessibleButtons = {},
    clickDetectors = {},
    proximityPrompts = {},
    antiCheatScripts = {},
    playerValues = {}
}

-- Loops
local Loops = {}
local remoteSpyActive = false
local remoteLogs = {}

--==================================================
-- UTILITY FUNCTIONS
--==================================================

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

local function Notify(msg, duration)
    OrionLib:MakeNotification({
        Name = "Tap Simulator",
        Content = msg,
        Image = "zap",
        Time = duration or 2.5
    })
end

local function safe_call(func)
    local success, result = pcall(func)
    if not success then
        warn("[Error]:", result)
        return false, result
    end
    return true, result
end

--==================================================
-- REMOTE FINDER (Dari Advanced Recon)
--==================================================
local function findObfuscatedRemotes()
    Notify("🔍 Scanning for remotes...", 3)
    
    -- Search in obfuscated folder
    local obfFolder = ReplicatedStorage:FindFirstChild("8b37e5ec-5fad-4ce6-b47e-4504b6dd4200")
    if not obfFolder then
        for _, child in ipairs(ReplicatedStorage:GetChildren()) do
            if child.Name:match("%x+-%x+-%x+-%x+-%x+") then
                obfFolder = child
                break
            end
        end
    end
    
    if obfFolder then
        local eventsFolder = obfFolder:FindFirstChild("Events")
        if eventsFolder then
            local allEvents = eventsFolder:GetChildren()
            if #allEvents >= 1 then
                Remotes.click = allEvents[1]
                Notify("✅ Click Remote: " .. Remotes.click.Name, 2)
            end
            if #allEvents >= 2 then
                Remotes.rebirth = allEvents[2]
                Notify("✅ Rebirth Remote: " .. Remotes.rebirth.Name, 2)
            end
        end
    end
    
    -- Fallback: Search in GUI buttons
    if not Remotes.click then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                if name:find("tap") or text:find("tap") or name:find("click") then
                    Remotes.click = ui
                    Notify("✅ Click Button: " .. ui.Name, 2)
                    break
                end
            end
        end
    end
    
    if not Remotes.rebirth then
        for _, ui in ipairs(gui:GetDescendants()) do
            if ui:IsA("TextButton") then
                local name = ui.Name:lower()
                local text = ui.Text:lower()
                if name:find("rebirth") or text:find("rebirth") or name:find("prestige") then
                    Remotes.rebirth = ui
                    Notify("✅ Rebirth Button: " .. ui.Name, 2)
                    break
                end
            end
        end
    end
    
    -- Find other remotes
    Remotes.purchase = ReplicatedStorage:FindFirstChild("PurchasePack")
    Remotes.foreverPackRequest = ReplicatedStorage:FindFirstChild("ForeverPackRequest")
    Remotes.foreverPackClaim = ReplicatedStorage:FindFirstChild("ForeverPackClaim")
    Remotes.petAttack = ReplicatedStorage:FindFirstChild("PetAttackEvent")
    
    -- Count found remotes
    Stats.remotesFound = 0
    for _, v in pairs(Remotes) do
        if v then Stats.remotesFound = Stats.remotesFound + 1 end
    end
end

--==================================================
-- CATEGORIZE REMOTES (Dari Advanced Recon)
--==================================================
local function categorizeRemotes()
    local function categorize(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            local info = {
                name = obj.Name,
                path = obj:GetFullName(),
                type = obj.ClassName
            }
            
            if name:find("purchase") or name:find("buy") or name:find("shop") then
                table.insert(Remotes.byCategory.purchase, info)
            elseif name:find("claim") or name:find("reward") or name:find("collect") then
                table.insert(Remotes.byCategory.claim, info)
            elseif name:find("rebirth") or name:find("prestige") then
                table.insert(Remotes.byCategory.rebirth, info)
            elseif name:find("pet") or name:find("egg") or name:find("hatch") then
                table.insert(Remotes.byCategory.pet, info)
            elseif name:find("upgrade") or name:find("level") then
                table.insert(Remotes.byCategory.upgrade, info)
            else
                table.insert(Remotes.byCategory.other, info)
            end
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            categorize(child)
        end
    end
    
    categorize(ReplicatedStorage)
end

--==================================================
-- EXPLOIT SCANNER (Dari Exploit Toolkit)
--==================================================
local function scanExploitables()
    exploitData = {
        remotes = {events = {}, functions = {}},
        hiddenGuis = {},
        accessibleButtons = {},
        clickDetectors = {},
        proximityPrompts = {},
        antiCheatScripts = {},
        playerValues = {}
    }
    
    -- Scan remotes
    local function scanRemotes(obj, depth)
        if depth > CONFIG.maxDepth then return end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("RemoteEvent") then
                table.insert(exploitData.remotes.events, {
                    name = child.Name,
                    path = child:GetFullName(),
                    obj = child
                })
            elseif child:IsA("RemoteFunction") then
                table.insert(exploitData.remotes.functions, {
                    name = child.Name,
                    path = child:GetFullName(),
                    obj = child
                })
            end
            scanRemotes(child, depth + 1)
        end
    end
    
    -- Scan hidden UIs
    local function scanHiddenUIs(obj, depth)
        if depth > CONFIG.maxDepth then return end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("ScreenGui") and not child.Enabled then
                table.insert(exploitData.hiddenGuis, {
                    name = child.Name,
                    path = child:GetFullName(),
                    obj = child
                })
            end
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                table.insert(exploitData.accessibleButtons, {
                    name = child.Name,
                    path = child:GetFullName(),
                    obj = child
                })
            end
            scanHiddenUIs(child, depth + 1)
        end
    end
    
    -- Scan interactions
    local function scanInteractions(obj, depth)
        if depth > CONFIG.maxDepth then return end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("ClickDetector") then
                table.insert(exploitData.clickDetectors, {
                    name = child.Parent.Name,
                    path = child.Parent:GetFullName(),
                    obj = child
                })
            elseif child:IsA("ProximityPrompt") then
                table.insert(exploitData.proximityPrompts, {
                    name = child.Parent.Name,
                    path = child.Parent:GetFullName(),
                    obj = child
                })
            end
            scanInteractions(child, depth + 1)
        end
    end
    
    -- Scan anti-cheat
    local suspiciousNames = {"AntiCheat", "AntiExploit", "Security", "Detection", "Kick", "Ban"}
    local function scanAntiCheat(obj, depth)
        if depth > CONFIG.maxDepth then return end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("LocalScript") or child:IsA("Script") then
                for _, keyword in ipairs(suspiciousNames) do
                    if child.Name:lower():find(keyword:lower()) then
                        table.insert(exploitData.antiCheatScripts, {
                            name = child.Name,
                            path = child:GetFullName()
                        })
                        break
                    end
                end
            end
            scanAntiCheat(child, depth + 1)
        end
    end
    
    -- Execute scans
    scanRemotes(ReplicatedStorage, 0)
    scanInteractions(Workspace, 0)
    scanAntiCheat(ReplicatedStorage, 0)
    scanHiddenUIs(gui, 0)
    
    Stats.hiddenUIs = #exploitData.hiddenGuis
    
    Notify(string.format("Scan complete: %d remotes, %d hidden UIs", 
        #exploitData.remotes.events + #exploitData.remotes.functions,
        #exploitData.hiddenGuis), 3)
end

--==================================================
-- REMOTE SPY (Dari Exploit Toolkit)
--==================================================
local function setupRemoteSpy()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if remoteSpyActive and (method == "FireServer" or method == "InvokeServer") then
            local log = {
                remote = self:GetFullName(),
                method = method,
                args = args,
                time = os.date("%H:%M:%S")
            }
            table.insert(remoteLogs, log)
            
            print(string.format("[SPY] %s -> %s(%s)", 
                log.time, 
                log.remote, 
                table.concat(args, ", ")
            ))
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end

--==================================================
-- EXECUTE REMOTE FUNCTION
--==================================================
local function executeRemote(remote)
    if not remote then return false end
    
    safe_call(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer()
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer()
        elseif remote:IsA("TextButton") then
            for _, connection in pairs(getconnections(remote.MouseButton1Click)) do
                connection:Fire()
            end
        end
    end)
    
    return true
end

--==================================================
-- GET STATS
--==================================================
local function updateStats()
    if player:FindFirstChild("leaderstats") then
        local clicks = player.leaderstats:FindFirstChild("Clicks")
        local rebirths = player.leaderstats:FindFirstChild("Rebirths")
        
        if clicks then
            Stats.clicks = tonumber(clicks.Value) or 0
        end
        
        if rebirths then
            Stats.rebirths = tonumber(rebirths.Value) or 0
        end
    end
end

--==================================================
-- EXPLOIT ACTIONS
--==================================================
local function fireAllClickDetectors()
    local count = 0
    for _, click in ipairs(exploitData.clickDetectors) do
        safe_call(function()
            fireclickdetector(click.obj)
            count = count + 1
        end)
    end
    return count
end

local function activateHiddenUIs()
    local count = 0
    for _, ui in ipairs(exploitData.hiddenGuis) do
        safe_call(function()
            ui.obj.Enabled = true
            count = count + 1
        end)
    end
    return count
end

local function fireAllPurchaseRemotes()
    if Remotes.purchase then
        Remotes.purchase:FireServer("Free", 0)
        Remotes.purchase:FireServer("ForeverPack", 0)
        return true
    end
    return false
end

local function spamAllObfuscatedRemotes()
    local obfFolder = ReplicatedStorage:FindFirstChild("8b37e5ec-5fad-4ce6-b47e-4504b6dd4200")
    if obfFolder then
        local eventsFolder = obfFolder:FindFirstChild("Events")
        if eventsFolder then
            for _, remote in ipairs(eventsFolder:GetChildren()) do
                executeRemote(remote)
                task.wait(0.1)
            end
            return true
        end
    end
    return false
end

--==================================================
-- SERVER HOP FUNCTION
--==================================================
local function serverHop()
    local placeId = game.PlaceId
    
    local function getServers()
        local servers = {}
        local cursor = ""
        repeat
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")))
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
        TeleportService:TeleportToPlaceInstance(placeId, randomServer, player)
        return true
    end
    return false
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
                executeRemote(Remotes.click)
                task.wait(Toggles.TapSpeed)
                
            elseif name == "AutoClicker" and Toggles.AutoClicker then
                mouse1click()
                task.wait(Toggles.ClickSpeed)
                
            elseif name == "AutoRebirth" and Toggles.AutoRebirth then
                executeRemote(Remotes.rebirth)
                task.wait(Toggles.RebirthDelay)
                
            elseif name == "AutoClaimPacks" and Toggles.AutoClaimPacks then
                safe_call(function()
                    if Remotes.foreverPackClaim then
                        Remotes.foreverPackClaim:FireServer()
                        Stats.packsClaimed = Stats.packsClaimed + 1
                    end
                    if Remotes.foreverPackRequest then
                        Remotes.foreverPackRequest:FireServer()
                    end
                    
                    -- Claim all visible rewards
                    for _, ui in ipairs(gui:GetDescendants()) do
                        if ui:IsA("TextButton") and ui.Visible then
                            local name = ui.Name:lower()
                            local text = ui.Text:lower()
                            if name:find("claim") or text:find("claim") then
                                for _, connection in pairs(getconnections(ui.MouseButton1Click)) do
                                    connection:Fire()
                                end
                            end
                        end
                    end
                end)
                task.wait(Toggles.ClaimDelay)
                
            elseif name == "AutoBuyEggs" and Toggles.AutoBuyEggs then
                safe_call(function()
                    local storeUI = gui.Tabs and gui.Tabs:FindFirstChild("Store")
                    if storeUI then
                        for _, desc in ipairs(storeUI:GetDescendants()) do
                            if desc:IsA("TextButton") and desc.Visible then
                                local name = desc.Name:lower()
                                if name:find("buy") then
                                    for _, connection in pairs(getconnections(desc.MouseButton1Click)) do
                                        connection:Fire()
                                    end
                                    Stats.eggsHatched = Stats.eggsHatched + 1
                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                end)
                task.wait(2)
                
            elseif name == "AutoPetFarm" and Toggles.AutoPetFarm then
                executeRemote(Remotes.petAttack)
                task.wait(0.1)
                
            elseif name == "StatsUpdate" then
                updateStats()
                task.wait(1)
                Stats.runtime = Stats.runtime + 1
            end
            
            task.wait()
        end
    end)
end

function StopLoop(name)
    Loops[name] = false
end

--==================================================
-- CREATE MAIN WINDOW (Catraz Hub)
--==================================================
local Window = OrionLib:MakeWindow({
    Name = "Tap Simulator - Ultimate",
    Subtext = "Auto Farm + Exploit Toolkit",
    Version = "v2.0",
    VersionIcon = "zap",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TapSim_Ultimate",
    IntroEnabled = true,
    IntroText = "Tap Simulator Ultimate",
    IntroIcon = "rbxassetid://8834748103",
    Icon = "rbxassetid://8834748103",
    ShowIcon = true,
    
    ImageBackground = "",
    ImageTransparency = 0.8,
    WindowTransparency = 0.05,
    
    ToggleIcon = "rbxassetid://105921924721005",
    ToggleSize = 50
})

OrionLib.SelectedTheme = "Ocean"

Notify("Script loaded! Scanning remotes...", 3)

-- Find remotes on load
task.wait(2)
findObfuscatedRemotes()
categorizeRemotes()
scanExploitables()
setupRemoteSpy()

-- Start stats update loop
StartLoop("StatsUpdate")

--==================================================
-- CREATE TABS
--==================================================
local MainTab = Window:MakeTab({Name = "Main", Icon = "home", Glass = true, Outline = true})
local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "zap", Glass = true, Outline = true})
local EggsTab = Window:MakeTab({Name = "Eggs & Pets", Icon = "egg", Glass = true, Outline = true})
local RebirthTab = Window:MakeTab({Name = "Rebirth", Icon = "trending-up", Glass = true, Outline = true})
local ExploitTab = Window:MakeTab({Name = "Exploit", Icon = "skull", Glass = true, Outline = true})
local ReconTab = Window:MakeTab({Name = "Recon", Icon = "search", Glass = true, Outline = true})
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "eye", Glass = true, Outline = true})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "settings", Glass = true, Outline = true})

--==================================================
-- MAIN TAB
--==================================================
local StatsSection = MainTab:AddSection({Name = "Player Stats", TextSize = 17, Glass = true, Outline = true})

local StatsPara = StatsSection:AddParagraph({
    Title = player.Name,
    Desc = "Loading stats...",
    Image = "user",
    ImageSize = 38,
    Buttons = {
        {
            Title = "Refresh",
            Callback = function()
                updateStats()
                StatsPara:SetDesc(string.format(
                    "Clicks: %s\nRebirths: %s\nRuntime: %ds\nRemotes: %d",
                    formatNumber(Stats.clicks),
                    formatNumber(Stats.rebirths),
                    Stats.runtime,
                    Stats.remotesFound
                ))
            end
        }
    }
})

-- Update stats paragraph periodically
task.spawn(function()
    while true do
        StatsPara:SetDesc(string.format(
            "Clicks: %s\nRebirths: %s\nRuntime: %ds\nRemotes: %d",
            formatNumber(Stats.clicks),
            formatNumber(Stats.rebirths),
            Stats.runtime,
            Stats.remotesFound
        ))
        task.wait(2)
    end
end)

local QuickSection = MainTab:AddSection({Name = "Quick Actions", Glass = true, Outline = true})

QuickSection:AddButton({
    Name = "Tap 10x",
    Icon = "hand",
    Outline = true,
    Callback = function()
        for i = 1, 10 do
            executeRemote(Remotes.click)
            task.wait(0.05)
        end
        Notify("Tapped 10 times!")
    end
})

QuickSection:AddButton({
    Name = "Rebirth Now",
    Icon = "trending-up",
    Outline = true,
    Callback = function()
        executeRemote(Remotes.rebirth)
        Notify("Rebirthed!")
    end
})

QuickSection:AddButton({
    Name = "Re-scan Remotes",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        findObfuscatedRemotes()
        categorizeRemotes()
        Notify("Rescan complete! Found " .. Stats.remotesFound .. " remotes")
    end
})

--==================================================
-- AUTO FARM TAB
--==================================================
local TapSection = FarmTab:AddSection({Name = "Auto Tap", Glass = true, Outline = true})

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
    Name = "Tap Speed (seconds)",
    Min = 0.001,
    Max = 0.1,
    Default = 0.01,
    Increment = 0.001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.TapSpeed = Value
    end
})

TapSection:AddToggle({
    Name = "Auto Clicker (Hardware)",
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
    Increment = 0.0001,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.ClickSpeed = Value
    end
})

local RewardSection = FarmTab:AddSection({Name = "Auto Rewards", Glass = true, Outline = true})

RewardSection:AddToggle({
    Name = "Auto Claim Packs",
    Default = false,
    Color = Color3.fromRGB(255, 150, 0),
    Outline = true,
    Flag = "AutoClaimPacks",
    Save = true,
    Callback = function(Value)
        Toggles.AutoClaimPacks = Value
        if Value then StartLoop("AutoClaimPacks") else StopLoop("AutoClaimPacks") end
    end
})

RewardSection:AddSlider({
    Name = "Claim Delay",
    Min = 1,
    Max = 30,
    Default = 5,
    Increment = 1,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.ClaimDelay = Value
    end
})

--==================================================
-- EGGS & PETS TAB
--==================================================
local EggSection = EggsTab:AddSection({Name = "Eggs", Glass = true, Outline = true})

EggSection:AddToggle({
    Name = "Auto Buy Eggs",
    Default = false,
    Color = Color3.fromRGB(255, 150, 255),
    Outline = true,
    Flag = "AutoBuyEggs",
    Save = true,
    Callback = function(Value)
        Toggles.AutoBuyEggs = Value
        if Value then StartLoop("AutoBuyEggs") else StopLoop("AutoBuyEggs") end
    end
})

EggSection:AddDropdown({
    Name = "Egg Type",
    Default = "Basic",
    Options = {"Basic", "Rare", "Epic", "Legendary", "Mythic"},
    Outline = true,
    Callback = function(Value)
        Toggles.EggType = Value
    end
})

EggSection:AddToggle({
    Name = "Auto Pet Farm",
    Default = false,
    Color = Color3.fromRGB(255, 150, 255),
    Outline = true,
    Flag = "AutoPetFarm",
    Save = true,
    Callback = function(Value)
        Toggles.AutoPetFarm = Value
        if Value then StartLoop("AutoPetFarm") else StopLoop("AutoPetFarm") end
    end
})

EggSection:AddParagraph({
    Title = "Egg Stats",
    Desc = string.format("Hatched: %d", Stats.eggsHatched),
    Image = "egg",
    ImageSize = 32
})

--==================================================
-- REBIRTH TAB
--==================================================
local RebirthSection = RebirthTab:AddSection({Name = "Auto Rebirth", Glass = true, Outline = true})

RebirthSection:AddToggle({
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

RebirthSection:AddSlider({
    Name = "Rebirth Delay",
    Min = 0.5,
    Max = 10,
    Default = 1,
    Increment = 0.5,
    ValueName = "sec",
    Outline = true,
    Callback = function(Value)
        Toggles.RebirthDelay = Value
    end
})

RebirthSection:AddParagraph({
    Title = "Rebirth Stats",
    Desc = string.format("Total: %s", formatNumber(Stats.rebirths)),
    Image = "trending-up",
    ImageSize = 32
})

--==================================================
-- EXPLOIT TAB
--==================================================
local SpySection = ExploitTab:AddSection({Name = "Remote Spy", Glass = true, Outline = true})

SpySection:AddToggle({
    Name = "Remote Spy",
    Default = false,
    Color = Color3.fromRGB(200, 0, 200),
    Outline = true,
    Flag = "RemoteSpy",
    Save = true,
    Callback = function(Value)
        remoteSpyActive = Value
        Notify(Value and "Remote Spy ON (check F9 console)" or "Remote Spy OFF")
    end
})

SpySection:AddButton({
    Name = "Clear Spy Logs",
    Icon = "trash",
    Outline = true,
    Callback = function()
        remoteLogs = {}
        Notify("Logs cleared!")
    end
})

local ExploitSection = ExploitTab:AddSection({Name = "Exploit Actions", Glass = true, Outline = true})

ExploitSection:AddButton({
    Name = "Fire All Click Detectors",
    Icon = "mouse-pointer",
    Outline = true,
    Callback = function()
        local count = fireAllClickDetectors()
        Notify(string.format("Fired %d click detectors!", count))
    end
})

ExploitSection:AddButton({
    Name = "Activate Hidden UIs",
    Icon = "eye",
    Outline = true,
    Callback = function()
        local count = activateHiddenUIs()
        Notify(string.format("Activated %d hidden UIs!", count))
    end
})

ExploitSection:AddButton({
    Name = "Fire All Purchase Remotes",
    Icon = "shopping-cart",
    Outline = true,
    Callback = function()
        if fireAllPurchaseRemotes() then
            Notify("Purchase remotes fired!")
        else
            Notify("Purchase remote not found", 2)
        end
    end
})

ExploitSection:AddButton({
    Name = "Spam All Obfuscated Remotes",
    Icon = "zap",
    Outline = true,
    Callback = function()
        Notify("Spamming remotes... Check console", 3)
        if spamAllObfuscatedRemotes() then
            Notify("Spam complete!")
        else
            Notify("No obfuscated remotes found")
        end
    end
})

--==================================================
-- RECON TAB
--==================================================
local ScanSection = ReconTab:AddSection({Name = "Scanner", Glass = true, Outline = true})

ScanSection:AddButton({
    Name = "Full Exploit Scan",
    Icon = "search",
    Outline = true,
    Callback = function()
        scanExploitables()
        
        local reconText = string.format([[
=== EXPLOIT SCAN RESULTS ===

📡 REMOTES:
  Events: %d
  Functions: %d

👁️ HIDDEN UIs: %d

🖱️ CLICK DETECTORS: %d

⚠️ ANTI-CHEAT SCRIPTS: %d

🔘 ACCESSIBLE BUTTONS: %d

=== END OF SCAN ===
        ]],
            #exploitData.remotes.events,
            #exploitData.remotes.functions,
            #exploitData.hiddenGuis,
            #exploitData.clickDetectors,
            #exploitData.antiCheatScripts,
            #exploitData.accessibleButtons
        )
        
        print(reconText)
        Notify("Scan complete! Check F9 console")
    end
})

ScanSection:AddButton({
    Name = "Show Hidden UIs List",
    Icon = "list",
    Outline = true,
    Callback = function()
        if #exploitData.hiddenGuis == 0 then
            Notify("No hidden UIs found. Scan first!")
            return
        end
        
        print("=== HIDDEN UIs ===")
        for i, ui in ipairs(exploitData.hiddenGuis) do
            print(string.format("[%d] %s", i, ui.name))
            print("  " .. ui.path)
        end
        Notify("Check F9 console")
    end
})

ScanSection:AddButton({
    Name = "Show Click Detectors",
    Icon = "mouse-pointer",
    Outline = true,
    Callback = function()
        if #exploitData.clickDetectors == 0 then
            Notify("No click detectors found. Scan first!")
            return
        end
        
        print("=== CLICK DETECTORS ===")
        for i, click in ipairs(exploitData.clickDetectors) do
            print(string.format("[%d] %s", i, click.name))
            print("  " .. click.path)
        end
        Notify("Check F9 console")
    end
})

ScanSection:AddButton({
    Name = "Show Anti-Cheat Scripts",
    Icon = "shield",
    Outline = true,
    Callback = function()
        if #exploitData.antiCheatScripts == 0 then
            Notify("No anti-cheat scripts found")
            return
        end
        
        print("=== ANTI-CHEAT SCRIPTS ===")
        for i, script in ipairs(exploitData.antiCheatScripts) do
            print(string.format("[%d] %s", i, script.name))
            print("  " .. script.path)
        end
        Notify("Check F9 console - BE CAREFUL!")
    end
})

--==================================================
-- VISUALS TAB
--==================================================
local VisualSection = VisualsTab:AddSection({Name = "Visuals", Glass = true, Outline = true})

VisualSection:AddToggle({
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

VisualSection:AddToggle({
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
-- MISC TAB
--==================================================
local MiscSection = MiscTab:AddSection({Name = "Miscellaneous", Glass = true, Outline = true})

MiscSection:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Color = Color3.fromRGB(100, 100, 255),
    Outline = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Toggles.AntiAFK = Value
        if Value then
            player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

MiscSection:AddButton({
    Name = "Server Hop",
    Icon = "globe",
    Outline = true,
    Callback = function()
        Notify("Searching for new server...", 3)
        if serverHop() then
            Notify("Joining new server...")
        else
            Notify("No servers available!")
        end
    end
})

MiscSection:AddButton({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Outline = true,
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end
})

MiscSection:AddButton({
    Name = "Destroy UI",
    Icon = "x",
    Outline = true,
    Callback = function()
        for name, loop in pairs(Loops) do
            StopLoop(name)
        end
        OrionLib:Destroy()
        _G.TapSimUltimate = false
    end
})

MiscSection:AddParagraph({
    Title = "Server Info",
    Desc = string.format("Players: %d/%d\nPing: %dms", 
        #Players:GetPlayers(),
        game.Players.MaxPlayers,
        math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    ),
    Image = "server",
    ImageSize = 38
})

--==================================================
-- ADD CONFIG TAB
--==================================================
Window:AddConfigTab({Name = "Settings", Icon = "settings"})

--==================================================
-- INITIALIZE
--==================================================
OrionLib:Init()

Notify("✅ Tap Simulator Ultimate loaded!", 3)
print("=" .. string.rep("=", 60))
print("TAP SIMULATOR - ULTIMATE EDITION v2.0")
print("=" .. string.rep("=", 60))
print("Features:")
print("  • Auto Farm (Tap, Clicker, Rewards)")
print("  • Auto Rebirth")
print("  • Auto Eggs & Pets")
print("  • Remote Spy")
print("  • Exploit Scanner")
print("  • Hidden UI Detector")
print("  • Click Detector Firer")
print("  • Anti-Cheat Detector")
print("  • Server Hop")
print("=" .. string.rep("=", 60))
print("Press F4 or click floating button to toggle UI")