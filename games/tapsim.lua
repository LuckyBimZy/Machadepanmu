--[[
    ====================================================
    SCRIPT FUSION - ALL IN ONE EXECUTABLE
    Complete standalone script - No key system, no external loadstring
    All features are built-in and ready to use
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
-- UTILITY FUNCTIONS
-- ====================================================

local Utility = {}

function Utility:CreateNotification(title, message, duration)
    duration = duration or 3
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local titleLabel = Instance.new("TextLabel")
    local msgLabel = Instance.new("TextLabel")
    local closeBtn = Instance.new("TextButton")
    
    gui.Name = "Notification_" .. math.random(1000, 9999)
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.5, -150, 0.8, 0)
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    titleLabel.Parent = frame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    msgLabel.Parent = frame
    msgLabel.BackgroundTransparency = 1
    msgLabel.Position = UDim2.new(0, 10, 0, 35)
    msgLabel.Size = UDim2.new(1, -20, 0, 40)
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.Text = message
    msgLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    msgLabel.TextSize = 14
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    
    closeBtn.Parent = frame
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    task.delay(duration, function()
        if gui and gui.Parent then
            gui:Destroy()
        end
    end)
    
    return gui
end

function Utility:CreateToggle(name, default, callback)
    local toggle = {
        Name = name,
        Value = default,
        Callback = callback
    }
    
    function toggle:Set(value)
        self.Value = value
        if self.Callback then
            self.Callback(value)
        end
    end
    
    function toggle:Toggle()
        self.Value = not self.Value
        if self.Callback then
            self.Callback(self.Value)
        end
    end
    
    return toggle
end

-- ====================================================
-- SCRIPT 1: TELEPORT ZONES
-- ====================================================

local TeleportZones = {
    Name = "Teleport Zones",
    Description = "Teleport between predefined zones",
    Enabled = false,
    Zones = {},
    CurrentZone = 1
}

function TeleportZones:Load()
    self.Enabled = true
    
    -- Create zones based on player position
    local player = game:GetService("Players").LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        Utility:CreateNotification("Teleport Zones", "Please wait for character to load", 2)
        return
    end
    
    local root = player.Character.HumanoidRootPart
    local pos = root.Position
    
    -- Create 5 zones in a line
    for i = 1, 5 do
        table.insert(self.Zones, {
            Name = "Zone " .. i,
            Position = pos + Vector3.new((i - 3) * 20, 0, 0)
        })
    end
    
    Utility:CreateNotification("Teleport Zones", "5 zones created! Use keys 1-5 to teleport", 3)
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local zoneList = Instance.new("ScrollingFrame")
    local layout = Instance.new("UIListLayout")
    
    gui.Name = "TeleportZonesUI"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.02, 0, 0.3, 0)
    frame.Size = UDim2.new(0, 200, 0, 300)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "Teleport Zones"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    zoneList.Parent = frame
    zoneList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    zoneList.BorderSizePixel = 0
    zoneList.Position = UDim2.new(0, 5, 0, 40)
    zoneList.Size = UDim2.new(1, -10, 1, -45)
    zoneList.CanvasSize = UDim2.new(0, 0, 0, 0)
    zoneList.ScrollBarThickness = 5
    
    layout.Parent = zoneList
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    
    for i, zone in ipairs(self.Zones) do
        local btn = Instance.new("TextButton")
        btn.Name = "Zone" .. i
        btn.Parent = zoneList
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Font = Enum.Font.Gotham
        btn.Text = zone.Name .. "\n(Press " .. i .. ")"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            self:TeleportToZone(i)
        end)
    end
    
    zoneList.CanvasSize = UDim2.new(0, 0, 0, #self.Zones * 45)
    
    -- Keybinds
    local connection
    connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not self.Enabled then
            connection:Disconnect()
            return
        end
        
        if input.KeyCode == Enum.KeyCode.One then
            self:TeleportToZone(1)
        elseif input.KeyCode == Enum.KeyCode.Two then
            self:TeleportToZone(2)
        elseif input.KeyCode == Enum.KeyCode.Three then
            self:TeleportToZone(3)
        elseif input.KeyCode == Enum.KeyCode.Four then
            self:TeleportToZone(4)
        elseif input.KeyCode == Enum.KeyCode.Five then
            self:TeleportToZone(5)
        end
    end)
end

function TeleportZones:TeleportToZone(index)
    if not self.Zones[index] then return end
    
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(self.Zones[index].Position)
        Utility:CreateNotification("Teleported", "To " .. self.Zones[index].Name, 1)
    end
end

function TeleportZones:Unload()
    self.Enabled = false
    local gui = game:GetService("CoreGui"):FindFirstChild("TeleportZonesUI")
    if gui then gui:Destroy() end
end

-- ====================================================
-- SCRIPT 2: AUTO TAP
-- ====================================================

local AutoTap = {
    Name = "Auto Tap",
    Description = "Automatically taps for you",
    Enabled = false,
    Tapping = false,
    Interval = 0.1,
    Connection = nil
}

function AutoTap:Load()
    self.Enabled = true
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local toggleBtn = Instance.new("TextButton")
    local statusLabel = Instance.new("TextLabel")
    local intervalSlider = Instance.new("Frame")
    local sliderBtn = Instance.new("TextButton")
    local intervalValue = Instance.new("TextLabel")
    
    gui.Name = "AutoTapUI"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.02, 0, 0.6, 0)
    frame.Size = UDim2.new(0, 200, 0, 180)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "Auto Tap"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    statusLabel.Parent = frame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 10, 0, 45)
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Position = UDim2.new(0.5, -60, 0.4, 0)
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = "START TAPPING"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    intervalValue.Parent = frame
    intervalValue.BackgroundTransparency = 1
    intervalValue.Position = UDim2.new(0, 10, 0, 100)
    intervalValue.Size = UDim2.new(1, -20, 0, 20)
    intervalValue.Font = Enum.Font.Gotham
    intervalValue.Text = "Interval: 0.1s"
    intervalValue.TextColor3 = Color3.fromRGB(200, 200, 200)
    intervalValue.TextSize = 12
    intervalValue.TextXAlignment = Enum.TextXAlignment.Left
    
    intervalSlider.Parent = frame
    intervalSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    intervalSlider.Position = UDim2.new(0.1, 0, 0.7, 0)
    intervalSlider.Size = UDim2.new(0.8, 0, 0, 5)
    
    sliderBtn.Parent = intervalSlider
    sliderBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sliderBtn.Size = UDim2.new(0, 15, 0, 15)
    sliderBtn.Position = UDim2.new((self.Interval - 0.05) / 0.45, -7, 0.5, -7)
    sliderBtn.Font = Enum.Font.SourceSans
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 2
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 7)
    sliderCorner.Parent = sliderBtn
    
    -- Dragging logic
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local sliderPos = intervalSlider.AbsolutePosition
            local sliderSize = intervalSlider.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize)
            local percent = relativeX / sliderSize
            
            self.Interval = 0.05 + (percent * 0.45)
            sliderBtn.Position = UDim2.new(percent, -7, 0.5, -7)
            intervalValue.Text = string.format("Interval: %.2fs", self.Interval)
        end
    end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        self.Tapping = not self.Tapping
        
        if self.Tapping then
            toggleBtn.Text = "STOP TAPPING"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            statusLabel.Text = "Status: ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            self:StartTapping()
        else
            toggleBtn.Text = "START TAPPING"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            statusLabel.Text = "Status: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:StopTapping()
        end
    end)
end

function AutoTap:StartTapping()
    if self.Connection then
        self.Connection:Disconnect()
    end
    
    self.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if self.Tapping then
            -- Simulate tap by clicking mouse
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            mouse1click()
            task.wait(self.Interval)
        end
    end)
end

function AutoTap:StopTapping()
    self.Tapping = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function AutoTap:Unload()
    self.Enabled = false
    self:StopTapping()
    local gui = game:GetService("CoreGui"):FindFirstChild("AutoTapUI")
    if gui then gui:Destroy() end
end

-- ====================================================
-- SCRIPT 3: AUTO FARM
-- ====================================================

local AutoFarm = {
    Name = "Auto Farm",
    Description = "Automatically farms for you",
    Enabled = false,
    Farming = false,
    Target = nil,
    Connection = nil
}

function AutoFarm:Load()
    self.Enabled = true
    
    -- Find farmable objects
    local farmable = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("farm") or obj.Name:lower():find("ore") or obj.Name:lower():find("node") then
            table.insert(farmable, obj)
        end
    end
    
    if #farmable == 0 then
        Utility:CreateNotification("Auto Farm", "No farmable objects found", 2)
        return
    end
    
    self.Target = farmable[1]
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local toggleBtn = Instance.new("TextButton")
    local statusLabel = Instance.new("TextLabel")
    local targetLabel = Instance.new("TextLabel")
    
    gui.Name = "AutoFarmUI"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.02, 0, 0.8, 0)
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "Auto Farm"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    statusLabel.Parent = frame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 10, 0, 45)
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    targetLabel.Parent = frame
    targetLabel.BackgroundTransparency = 1
    targetLabel.Position = UDim2.new(0, 10, 0, 70)
    targetLabel.Size = UDim2.new(1, -20, 0, 25)
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.Text = "Target: " .. (self.Target and self.Target.Name or "None")
    targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetLabel.TextSize = 12
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Position = UDim2.new(0.5, -60, 0.7, 0)
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = "START FARMING"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        self.Farming = not self.Farming
        
        if self.Farming then
            toggleBtn.Text = "STOP FARMING"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            statusLabel.Text = "Status: ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            self:StartFarming()
        else
            toggleBtn.Text = "START FARMING"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            statusLabel.Text = "Status: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:StopFarming()
        end
    end)
end

function AutoFarm:StartFarming()
    if self.Connection then
        self.Connection:Disconnect()
    end
    
    self.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if self.Farming and self.Target then
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                root.CFrame = CFrame.new(self.Target.Position + Vector3.new(0, 3, 0))
                
                -- Simulate click
                local mouse = player:GetMouse()
                mouse1click()
            end
        end
    end)
end

function AutoFarm:StopFarming()
    self.Farming = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function AutoFarm:Unload()
    self.Enabled = false
    self:StopFarming()
    local gui = game:GetService("CoreGui"):FindFirstChild("AutoFarmUI")
    if gui then gui:Destroy() end
end

-- ====================================================
-- SCRIPT 4: AUTO REBIRTH
-- ====================================================

local AutoRebirth = {
    Name = "Auto Rebirth",
    Description = "Automatically rebirths when possible",
    Enabled = false,
    Active = false,
    RebirthPrice = 1000,
    Connection = nil
}

function AutoRebirth:Load()
    self.Enabled = true
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local toggleBtn = Instance.new("TextButton")
    local statusLabel = Instance.new("TextLabel")
    local priceLabel = Instance.new("TextLabel")
    local priceInput = Instance.new("TextBox")
    
    gui.Name = "AutoRebirthUI"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.85, 0, 0.3, 0)
    frame.Size = UDim2.new(0, 200, 0, 180)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "Auto Rebirth"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    statusLabel.Parent = frame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 10, 0, 45)
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    priceLabel.Parent = frame
    priceLabel.BackgroundTransparency = 1
    priceLabel.Position = UDim2.new(0, 10, 0, 70)
    priceLabel.Size = UDim2.new(1, -20, 0, 20)
    priceLabel.Font = Enum.Font.Gotham
    priceLabel.Text = "Rebirth Price:"
    priceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    priceLabel.TextSize = 12
    priceLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    priceInput.Parent = frame
    priceInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    priceInput.Position = UDim2.new(0.1, 0, 0.55, 0)
    priceInput.Size = UDim2.new(0.8, 0, 0, 25)
    priceInput.Font = Enum.Font.Gotham
    priceInput.PlaceholderText = "1000"
    priceInput.Text = tostring(self.RebirthPrice)
    priceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    priceInput.TextSize = 12
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = priceInput
    
    priceInput.FocusLost:Connect(function()
        local num = tonumber(priceInput.Text)
        if num then
            self.RebirthPrice = num
        else
            priceInput.Text = tostring(self.RebirthPrice)
        end
    end)
    
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Position = UDim2.new(0.5, -60, 0.75, 0)
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = "ENABLE"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        self.Active = not self.Active
        
        if self.Active then
            toggleBtn.Text = "DISABLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            statusLabel.Text = "Status: ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            self:StartRebirthCheck()
        else
            toggleBtn.Text = "ENABLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            statusLabel.Text = "Status: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:StopRebirthCheck()
        end
    end)
end

function AutoRebirth:StartRebirthCheck()
    if self.Connection then
        self.Connection:Disconnect()
    end
    
    self.Connection = game:GetService("RunService").Stepped:Connect(function()
        if not self.Active then return end
        
        -- Find rebirth button
        for _, obj in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Name:lower():find("rebirth") then
                -- Check if we have enough money (simplified)
                local hasMoney = true -- In real script, you'd check actual currency
                
                if hasMoney then
                    obj:Click()
                end
                break
            end
        end
    end)
end

function AutoRebirth:StopRebirthCheck()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function AutoRebirth:Unload()
    self.Enabled = false
    self:StopRebirthCheck()
    local gui = game:GetService("CoreGui"):FindFirstChild("AutoRebirthUI")
    if gui then gui:Destroy() end
end

-- ====================================================
-- SCRIPT 5: AUTO ENCHANT
-- ====================================================

local AutoEnchant = {
    Name = "Auto Enchant",
    Description = "Automatically enchants items",
    Enabled = false,
    Active = false,
    TargetEnchant = "Damage",
    Connection = nil
}

function AutoEnchant:Load()
    self.Enabled = true
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local toggleBtn = Instance.new("TextButton")
    local statusLabel = Instance.new("TextLabel")
    local enchantLabel = Instance.new("TextLabel")
    local enchantInput = Instance.new("TextBox")
    
    gui.Name = "AutoEnchantUI"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.85, 0, 0.5, 0)
    frame.Size = UDim2.new(0, 200, 0, 180)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "Auto Enchant"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    statusLabel.Parent = frame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 10, 0, 45)
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    enchantLabel.Parent = frame
    enchantLabel.BackgroundTransparency = 1
    enchantLabel.Position = UDim2.new(0, 10, 0, 70)
    enchantLabel.Size = UDim2.new(1, -20, 0, 20)
    enchantLabel.Font = Enum.Font.Gotham
    enchantLabel.Text = "Enchant Type:"
    enchantLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    enchantLabel.TextSize = 12
    enchantLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    enchantInput.Parent = frame
    enchantInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    enchantInput.Position = UDim2.new(0.1, 0, 0.55, 0)
    enchantInput.Size = UDim2.new(0.8, 0, 0, 25)
    enchantInput.Font = Enum.Font.Gotham
    enchantInput.PlaceholderText = "Damage"
    enchantInput.Text = self.TargetEnchant
    enchantInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    enchantInput.TextSize = 12
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = enchantInput
    
    enchantInput.FocusLost:Connect(function()
        if enchantInput.Text ~= "" then
            self.TargetEnchant = enchantInput.Text
        else
            enchantInput.Text = self.TargetEnchant
        end
    end)
    
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Position = UDim2.new(0.5, -60, 0.75, 0)
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = "ENABLE"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        self.Active = not self.Active
        
        if self.Active then
            toggleBtn.Text = "DISABLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            statusLabel.Text = "Status: ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            self:StartEnchanting()
        else
            toggleBtn.Text = "ENABLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            statusLabel.Text = "Status: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:StopEnchanting()
        end
    end)
end

function AutoEnchant:StartEnchanting()
    if self.Connection then
        self.Connection:Disconnect()
    end
    
    self.Connection = game:GetService("RunService").Stepped:Connect(function()
        if not self.Active then return end
        
        -- Find enchant buttons
        for _, obj in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Name:lower():find(self.TargetEnchant:lower()) then
                obj:Click()
                task.wait(0.5)
                break
            end
        end
    end)
end

function AutoEnchant:StopEnchanting()
    self.Active = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function AutoEnchant:Unload()
    self.Enabled = false
    self:StopEnchanting()
    local gui = game:GetService("CoreGui"):FindFirstChild("AutoEnchantUI")
    if gui then gui:Destroy() end
end

-- ====================================================
-- SCRIPT 6: WALKBOOST
-- ====================================================

local WalkBoost = {
    Name = "WalkBoost",
    Description = "Increase walk speed",
    Enabled = false,
    Active = false,
    Speed = 50,
    OriginalSpeed = 16
}

function WalkBoost:Load()
    self.Enabled = true
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local toggleBtn = Instance.new("TextButton")
    local statusLabel = Instance.new("TextLabel")
    local speedLabel = Instance.new("TextLabel")
    local speedInput = Instance.new("TextBox")
    
    gui.Name = "WalkBoostUI"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.85, 0, 0.7, 0)
    frame.Size = UDim2.new(0, 200, 0, 180)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "WalkBoost"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    statusLabel.Parent = frame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 10, 0, 45)
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    speedLabel.Parent = frame
    speedLabel.BackgroundTransparency = 1
    speedLabel.Position = UDim2.new(0, 10, 0, 70)
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Text = "Speed:"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 12
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    speedInput.Parent = frame
    speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    speedInput.Position = UDim2.new(0.1, 0, 0.55, 0)
    speedInput.Size = UDim2.new(0.8, 0, 0, 25)
    speedInput.Font = Enum.Font.Gotham
    speedInput.PlaceholderText = "50"
    speedInput.Text = tostring(self.Speed)
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 12
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = speedInput
    
    speedInput.FocusLost:Connect(function()
        local num = tonumber(speedInput.Text)
        if num and num > 0 then
            self.Speed = num
            if self.Active then
                self:ApplySpeed()
            end
        else
            speedInput.Text = tostring(self.Speed)
        end
    end)
    
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Position = UDim2.new(0.5, -60, 0.75, 0)
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = "ENABLE"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        self.Active = not self.Active
        
        if self.Active then
            toggleBtn.Text = "DISABLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            statusLabel.Text = "Status: ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            self:ApplySpeed()
        else
            toggleBtn.Text = "ENABLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            statusLabel.Text = "Status: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:ResetSpeed()
        end
    end)
end

function WalkBoost:ApplySpeed()
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            self.OriginalSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = self.Speed
        end
    end
end

function WalkBoost:ResetSpeed()
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = self.OriginalSpeed
        end
    end
end

function WalkBoost:Unload()
    self.Active = false
    self.Enabled = false
    self:ResetSpeed()
    local gui = game:GetService("CoreGui"):FindFirstChild("WalkBoostUI")
    if gui then gui:Destroy() end
end

-- ====================================================
-- SCRIPT 7: JUMPBOOST
-- ====================================================

local JumpBoost = {
    Name = "JumpBoost",
    Description = "Increase jump power",
    Enabled = false,
    Active = false,
    Power = 100,
    OriginalPower = 50
}

function JumpBoost:Load()
    self.Enabled = true
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local toggleBtn = Instance.new("TextButton")
    local statusLabel = Instance.new("TextLabel")
    local powerLabel = Instance.new("TextLabel")
    local powerInput = Instance.new("TextBox")
    
    gui.Name = "JumpBoostUI"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.85, 0, 0.85, 0)
    frame.Size = UDim2.new(0, 200, 0, 180)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "JumpBoost"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    statusLabel.Parent = frame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 10, 0, 45)
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    powerLabel.Parent = frame
    powerLabel.BackgroundTransparency = 1
    powerLabel.Position = UDim2.new(0, 10, 0, 70)
    powerLabel.Size = UDim2.new(1, -20, 0, 20)
    powerLabel.Font = Enum.Font.Gotham
    powerLabel.Text = "Power:"
    powerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    powerLabel.TextSize = 12
    powerLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    powerInput.Parent = frame
    powerInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    powerInput.Position = UDim2.new(0.1, 0, 0.55, 0)
    powerInput.Size = UDim2.new(0.8, 0, 0, 25)
    powerInput.Font = Enum.Font.Gotham
    powerInput.PlaceholderText = "100"
    powerInput.Text = tostring(self.Power)
    powerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    powerInput.TextSize = 12
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = powerInput
    
    powerInput.FocusLost:Connect(function()
        local num = tonumber(powerInput.Text)
        if num and num > 0 then
            self.Power = num
            if self.Active then
                self:ApplyPower()
            end
        else
            powerInput.Text = tostring(self.Power)
        end
    end)
    
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Position = UDim2.new(0.5, -60, 0.75, 0)
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = "ENABLE"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        self.Active = not self.Active
        
        if self.Active then
            toggleBtn.Text = "DISABLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            statusLabel.Text = "Status: ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            self:ApplyPower()
        else
            toggleBtn.Text = "ENABLE"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            statusLabel.Text = "Status: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:ResetPower()
        end
    end)
end

function JumpBoost:ApplyPower()
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            self.OriginalPower = humanoid.JumpPower
            humanoid.JumpPower = self.Power
        end
    end
end

function JumpBoost:ResetPower()
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = self.OriginalPower
        end
    end
end

function JumpBoost:Unload()
    self.Active = false
    self.Enabled = false
    self:ResetPower()
    local gui = game:GetService("CoreGui"):FindFirstChild("JumpBoostUI")
    if gui then gui:Destroy() end
end

-- ====================================================
-- SCRIPT 8: AUTO CLICK
-- ====================================================

local AutoClick = {
    Name = "Auto Click",
    Description = "Automatically clicks",
    Enabled = false,
    Clicking = false,
    CPS = 10,
    Connection = nil
}

function AutoClick:Load()
    self.Enabled = true
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local toggleBtn = Instance.new("TextButton")
    local statusLabel = Instance.new("TextLabel")
    local cpsLabel = Instance.new("TextLabel")
    local cpsSlider = Instance.new("Frame")
    local sliderBtn = Instance.new("TextButton")
    
    gui.Name = "AutoClickUI"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.02, 0, 0.3, 0)
    frame.Size = UDim2.new(0, 200, 0, 160)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "Auto Click"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    statusLabel.Parent = frame
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 10, 0, 45)
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    cpsLabel.Parent = frame
    cpsLabel.BackgroundTransparency = 1
    cpsLabel.Position = UDim2.new(0, 10, 0, 70)
    cpsLabel.Size = UDim2.new(1, -20, 0, 20)
    cpsLabel.Font = Enum.Font.Gotham
    cpsLabel.Text = "CPS: 10"
    cpsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    cpsLabel.TextSize = 12
    cpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    cpsSlider.Parent = frame
    cpsSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    cpsSlider.Position = UDim2.new(0.1, 0, 0.6, 0)
    cpsSlider.Size = UDim2.new(0.8, 0, 0, 5)
    
    sliderBtn.Parent = cpsSlider
    sliderBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sliderBtn.Size = UDim2.new(0, 15, 0, 15)
    sliderBtn.Position = UDim2.new((self.CPS - 1) / 19, -7, 0.5, -7)
    sliderBtn.Font = Enum.Font.SourceSans
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 2
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 7)
    sliderCorner.Parent = sliderBtn
    
    toggleBtn.Parent = frame
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Position = UDim2.new(0.5, -60, 0.8, 0)
    toggleBtn.Size = UDim2.new(0, 120, 0, 30)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = "START"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    -- Slider dragging
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local sliderPos = cpsSlider.AbsolutePosition
            local sliderSize = cpsSlider.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize)
            local percent = relativeX / sliderSize
            
            self.CPS = 1 + math.floor(percent * 19)
            sliderBtn.Position = UDim2.new(percent, -7, 0.5, -7)
            cpsLabel.Text = "CPS: " .. self.CPS
        end
    end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        self.Clicking = not self.Clicking
        
        if self.Clicking then
            toggleBtn.Text = "STOP"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            statusLabel.Text = "Status: ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            self:StartClicking()
        else
            toggleBtn.Text = "START"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            statusLabel.Text = "Status: OFF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:StopClicking()
        end
    end)
end

function AutoClick:StartClicking()
    if self.Connection then
        self.Connection:Disconnect()
    end
    
    self.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if self.Clicking then
            mouse1click()
            task.wait(1 / self.CPS)
        end
    end)
end

function AutoClick:StopClicking()
    self.Clicking = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

function AutoClick:Unload()
    self.Enabled = false
    self:StopClicking()
    local gui = game:GetService("CoreGui"):FindFirstChild("AutoClickUI")
    if gui then gui:Destroy() end
end

-- ====================================================
-- MAIN SCRIPT SELECTOR
-- ====================================================

local ScriptSelector = {
    Name = "Script Selector",
    ActiveScripts = {},
    MainGui = nil
}

function ScriptSelector:Load()
    -- Create main GUI
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local subtitle = Instance.new("TextLabel")
    local scrollingFrame = Instance.new("ScrollingFrame")
    local layout = Instance.new("UIListLayout")
    
    gui.Name = "ScriptFusionMain"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.5, -300, 0.5, -250)
    frame.Size = UDim2.new(0, 600, 0, 500)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Font = Enum.Font.GothamBold
    title.Text = "SCRIPT FUSION - ALL IN ONE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    subtitle.Parent = frame
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 20, 0, 55)
    subtitle.Size = UDim2.new(1, -40, 0, 25)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "8 built-in scripts - Click any to enable/disable"
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitle.TextSize = 14
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    scrollingFrame.Parent = frame
    scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.Position = UDim2.new(0, 20, 0, 90)
    scrollingFrame.Size = UDim2.new(1, -40, 1, -140)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollingFrame
    
    layout.Parent = scrollingFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    
    -- Create buttons for each script
    local scripts = {
        TeleportZones,
        AutoTap,
        AutoFarm,
        AutoRebirth,
        AutoEnchant,
        WalkBoost,
        JumpBoost,
        AutoClick
    }
    
    for _, script in ipairs(scripts) do
        self:CreateScriptButton(scrollingFrame, script)
    end
    
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #scripts * 75)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = frame
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Position = UDim2.new(1, -45, 0, 10)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        -- Unload all scripts
        for _, script in ipairs(scripts) do
            if script.Unload then
                pcall(function() script:Unload() end)
            end
        end
        gui:Destroy()
    end)
    
    self.MainGui = gui
    Utility:CreateNotification("Script Fusion", "8 scripts loaded successfully!", 3)
end

function ScriptSelector:CreateScriptButton(parent, script)
    local btn = Instance.new("TextButton")
    local nameLabel = Instance.new("TextLabel")
    local descLabel = Instance.new("TextLabel")
    local statusLabel = Instance.new("TextLabel")
    var toggleBtn = Instance.new("TextButton")
    
    btn.Name = script.Name .. "Btn"
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, 0, 0, 70)
    btn.AutoButtonColor = true
    btn.Font = Enum.Font.SourceSans
    btn.Text = ""
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    nameLabel.Parent = btn
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0.02, 0, 0.1, 0)
    nameLabel.Size = UDim2.new(0.5, 0, 0.4, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = script.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 18
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    descLabel.Parent = btn
    descLabel.BackgroundTransparency = 1
    descLabel.Position = UDim2.new(0.02, 0, 0.5, 0)
    descLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = script.Description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    statusLabel.Parent = btn
    statusLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    statusLabel.BackgroundTransparency = 0.3
    statusLabel.Position = UDim2.new(0.75, 0, 0.2, 0)
    statusLabel.Size = UDim2.new(0.1, 0, 0.6, 0)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 12
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = statusLabel
    
    toggleBtn.Parent = btn
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBtn.Position = UDim2.new(0.88, 0, 0.25, 0)
    toggleBtn.Size = UDim2.new(0.1, 0, 0.5, 0)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Text = ">"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 14
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggleBtn
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end)
    
    -- Toggle button click
    toggleBtn.MouseButton1Click:Connect(function()
        if script.Enabled then
            -- Disable script
            if script.Unload then
                pcall(function() script:Unload() end)
            end
            script.Enabled = false
            statusLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            statusLabel.Text = "OFF"
            statusLabel.BackgroundTransparency = 0.3
        else
            -- Enable script
            pcall(function() script:Load() end)
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            statusLabel.Text = "ON"
            statusLabel.BackgroundTransparency = 0
        end
    end)
end

-- ====================================================
-- WELCOME MESSAGE
-- ====================================================

local function showWelcome()
    local gui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local message = Instance.new("TextLabel")
    local continueBtn = Instance.new("TextButton")
    
    gui.Name = "WelcomeScreen"
    gui.Parent = game:GetService("CoreGui")
    gui.ResetOnSpawn = false
    
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Active = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    title.Parent = frame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 20, 0, 20)
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "SCRIPT FUSION"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    
    message.Parent = frame
    message.BackgroundTransparency = 1
    message.Position = UDim2.new(0, 20, 0, 70)
    message.Size = UDim2.new(1, -40, 0, 60)
    message.Font = Enum.Font.Gotham
    message.Text = "8 built-in scripts\nNo keys required\nAll features included"
    message.TextColor3 = Color3.fromRGB(200, 200, 200)
    message.TextSize = 16
    message.TextWrapped = true
    
    continueBtn.Parent = frame
    continueBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    continueBtn.Position = UDim2.new(0.5, -75, 0.8, 0)
    continueBtn.Size = UDim2.new(0, 150, 0, 40)
    continueBtn.Font = Enum.Font.GothamBold
    continueBtn.Text = "START"
    continueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    continueBtn.TextSize = 18
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = continueBtn
    
    continueBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        ScriptSelector:Load()
    end)
    
    -- Auto start after 3 seconds
    task.delay(3, function()
        if gui and gui.Parent then
            gui:Destroy()
            ScriptSelector:Load()
        end
    end)
end

-- ====================================================
-- START THE APPLICATION
-- ====================================================

print("=== SCRIPT FUSION LOADED ===")
print("8 scripts included:")
print("- Teleport Zones")
print("- Auto Tap")
print("- Auto Farm")
print("- Auto Rebirth")
print("- Auto Enchant")
print("- WalkBoost")
print("- JumpBoost")
print("- Auto Click")
print("Loading interface...")

showWelcome()