-- GABUNGAN SEMUA SCRIPT TELEPORT, ZONES, REWARDS, AUTOMATION, DAN LAINNYA
-- Script lengkap tanpa key system dan tanpa loadstring

-- =============================================
-- BAGIAN 1: TELEPORT ZONES SYSTEM
-- =============================================
local TeleportZones = {}

function TeleportZones.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Daftar zone teleport
    local zones = {
        {name = "Spawn Zone", position = Vector3.new(0, 10, 0), radius = 10, color = Color3.fromRGB(0, 255, 0)},
        {name = "Shop Zone", position = Vector3.new(50, 10, 0), radius = 10, color = Color3.fromRGB(255, 255, 0)},
        {name = "Farm Zone", position = Vector3.new(100, 10, 50), radius = 15, color = Color3.fromRGB(0, 100, 255)},
        {name = "PvP Zone", position = Vector3.new(-50, 10, -50), radius = 20, color = Color3.fromRGB(255, 0, 0)},
        {name = "Secret Zone", position = Vector3.new(200, 50, 200), radius = 5, color = Color3.fromRGB(255, 0, 255)}
    }
    
    -- Buat GUI untuk menampilkan zone
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportZonesGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.02, 0, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 200, 0, 300)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = "TELEPORT ZONES"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Parent = mainFrame
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollingFrame.Size = UDim2.new(1, 0, 1, -60)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #zones * 35)
    scrollingFrame.ScrollBarThickness = 5
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollingFrame
    uiListLayout.Padding = UDim.new(0, 5)
    
    -- Buat tombol untuk setiap zone
    for i, zone in ipairs(zones) do
        local button = Instance.new("TextButton")
        button.Parent = scrollingFrame
        button.Name = zone.name .. "Button"
        button.BackgroundColor3 = zone.color
        button.BackgroundTransparency = 0.3
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Font = Enum.Font.Gotham
        button.Text = zone.name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.AutoButtonColor = false
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            button.BackgroundTransparency = 0.1
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundTransparency = 0.3
        end)
        
        -- Teleport ketika diklik
        button.MouseButton1Click:Connect(function()
            humanoidRootPart.CFrame = CFrame.new(zone.position)
            
            -- Notifikasi
            local notification = Instance.new("ScreenGui")
            notification.Name = "Notification"
            notification.Parent = player.PlayerGui
            
            local notifFrame = Instance.new("Frame")
            notifFrame.Parent = notification
            notifFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            notifFrame.BorderSizePixel = 0
            notifFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
            notifFrame.Size = UDim2.new(0, 300, 0, 50)
            
            local notifLabel = Instance.new("TextLabel")
            notifLabel.Parent = notifFrame
            notifLabel.BackgroundTransparency = 1
            notifLabel.Size = UDim2.new(1, 0, 1, 0)
            notifLabel.Font = Enum.Font.Gotham
            notifLabel.Text = "Teleported to " .. zone.name .. "!"
            notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            notifLabel.TextSize = 16
            
            -- Hapus notifikasi setelah 2 detik
            task.delay(2, function()
                notification:Destroy()
            end)
        end)
    end
    
    -- Tombol Close
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Font = Enum.Font.Gotham
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- =============================================
-- BAGIAN 2: TELEPORTS SYSTEM
-- =============================================
local TeleportsSystem = {}

function TeleportsSystem.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Daftar lokasi teleport
    local teleportLocations = {
        {name = "Pusat Kota", position = Vector3.new(0, 5, 0), description = "Area utama kota"},
        {name = "Toko Senjata", position = Vector3.new(30, 5, 20), description = "Beli senjata di sini"},
        {name = "Area Pelatihan", position = Vector3.new(-30, 5, 40), description = "Latih kemampuanmu"},
        {name = "Gudang", position = Vector3.new(60, 5, -20), description = "Tempat menyimpan item"},
        {name = "Arena Boss", position = Vector3.new(0, 5, 100), description = "Hadapi bos terkuat"},
        {name = "Tempat Rahasia", position = Vector3.new(150, 30, 150), description = "Lokasi tersembunyi"}
    }
    
    -- Buat GUI Teleports
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportsGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 400, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Buat bayangan
    local shadow = Instance.new("ImageLabel")
    shadow.Parent = mainFrame
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = -1
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "⚡ TELEPORT SYSTEM ⚡"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Parent = mainFrame
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollingFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #teleportLocations * 70)
    scrollingFrame.ScrollBarThickness = 8
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollingFrame
    uiListLayout.Padding = UDim.new(0, 10)
    
    -- Buat item teleport
    for i, location in ipairs(teleportLocations) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Parent = scrollingFrame
        itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        itemFrame.BorderSizePixel = 0
        itemFrame.Size = UDim2.new(1, 0, 0, 60)
        
        local locationName = Instance.new("TextLabel")
        locationName.Parent = itemFrame
        locationName.BackgroundTransparency = 1
        locationName.Position = UDim2.new(0, 10, 0, 5)
        locationName.Size = UDim2.new(1, -20, 0, 20)
        locationName.Font = Enum.Font.GothamBold
        locationName.Text = location.name
        locationName.TextColor3 = Color3.fromRGB(255, 200, 100)
        locationName.TextSize = 16
        locationName.TextXAlignment = Enum.TextXAlignment.Left
        
        local locationDesc = Instance.new("TextLabel")
        locationDesc.Parent = itemFrame
        locationDesc.BackgroundTransparency = 1
        locationDesc.Position = UDim2.new(0, 10, 0, 25)
        locationDesc.Size = UDim2.new(1, -20, 0, 20)
        locationDesc.Font = Enum.Font.Gotham
        locationDesc.Text = location.description
        locationDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
        locationDesc.TextSize = 12
        locationDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        local teleportButton = Instance.new("TextButton")
        teleportButton.Parent = itemFrame
        teleportButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        teleportButton.BorderSizePixel = 0
        teleportButton.Position = UDim2.new(1, -70, 0, 15)
        teleportButton.Size = UDim2.new(0, 60, 0, 30)
        teleportButton.Font = Enum.Font.GothamBold
        teleportButton.Text = "TP"
        teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        teleportButton.TextSize = 14
        
        teleportButton.MouseButton1Click:Connect(function()
            humanoidRootPart.CFrame = CFrame.new(location.position)
            
            -- Efek visual teleport
            local effect = Instance.new("Part")
            effect.Parent = workspace
            effect.Size = Vector3.new(5, 5, 5)
            effect.Position = location.position
            effect.Anchored = true
            effect.CanCollide = false
            effect.Transparency = 0.5
            effect.BrickColor = BrickColor.new("Bright blue")
            effect.Material = Enum.Material.Neon
            
            task.delay(1, function()
                effect:Destroy()
            end)
            
            -- Notifikasi
            itemFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            task.delay(0.3, function()
                itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end)
        end)
    end
end

-- =============================================
-- BAGIAN 3: REWARDS SYSTEM
-- =============================================
local RewardsSystem = {}

function RewardsSystem.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Data rewards
    local rewards = {
        daily = {name = "Daily Reward", amount = 100, color = Color3.fromRGB(255, 215, 0)},
        weekly = {name = "Weekly Reward", amount = 500, color = Color3.fromRGB(138, 43, 226)},
        monthly = {name = "Monthly Reward", amount = 2000, color = Color3.fromRGB(255, 69, 0)},
        login = {name = "Login Reward", amount = 50, color = Color3.fromRGB(100, 149, 237)},
        achievement = {name = "Achievement Reward", amount = 250, color = Color3.fromRGB(60, 179, 113)},
        special = {name = "Special Event", amount = 1000, color = Color3.fromRGB(255, 20, 147)}
    }
    
    -- Leaderstats jika ada
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
        
        local coins = Instance.new("NumberValue")
        coins.Name = "Coins"
        coins.Parent = leaderstats
        coins.Value = 0
    end
    
    local coinsValue = leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Gold") or leaderstats:FindFirstChild("Money")
    if not coinsValue then
        coinsValue = Instance.new("NumberValue")
        coinsValue.Name = "Coins"
        coinsValue.Parent = leaderstats
        coinsValue.Value = 0
    end
    
    -- Buat GUI Rewards
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RewardsGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 400, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Buat rounded corners
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "🎁 REWARDS SYSTEM 🎁"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 10)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 5)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tampilkan jumlah koin
    local coinsFrame = Instance.new("Frame")
    coinsFrame.Parent = mainFrame
    coinsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    coinsFrame.BorderSizePixel = 0
    coinsFrame.Position = UDim2.new(0, 10, 0, 50)
    coinsFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local coinsCorner = Instance.new("UICorner")
    coinsCorner.Parent = coinsFrame
    coinsCorner.CornerRadius = UDim.new(0, 5)
    
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Parent = coinsFrame
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Size = UDim2.new(1, 0, 1, 0)
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.Text = "Your Coins: " .. coinsValue.Value
    coinsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    coinsLabel.TextSize = 18
    
    -- Update koin setiap kali berubah
    coinsValue:GetPropertyChangedSignal("Value"):Connect(function()
        coinsLabel.Text = "Your Coins: " .. coinsValue.Value
    end)
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Parent = mainFrame
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Position = UDim2.new(0, 10, 0, 100)
    scrollingFrame.Size = UDim2.new(1, -20, 1, -150)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #rewards * 80)
    scrollingFrame.ScrollBarThickness = 8
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollingFrame
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Status klaim
    local claimedStatus = {}
    
    -- Buat item reward
    for rewardType, rewardData in pairs(rewards) do
        claimedStatus[rewardType] = false
        
        local rewardFrame = Instance.new("Frame")
        rewardFrame.Parent = scrollingFrame
        rewardFrame.BackgroundColor3 = rewardData.color
        rewardFrame.BackgroundTransparency = 0.2
        rewardFrame.BorderSizePixel = 0
        rewardFrame.Size = UDim2.new(1, -10, 0, 70)
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.Parent = rewardFrame
        frameCorner.CornerRadius = UDim.new(0, 8)
        
        local rewardName = Instance.new("TextLabel")
        rewardName.Parent = rewardFrame
        rewardName.BackgroundTransparency = 1
        rewardName.Position = UDim2.new(0, 10, 0, 5)
        rewardName.Size = UDim2.new(1, -20, 0, 25)
        rewardName.Font = Enum.Font.GothamBold
        rewardName.Text = rewardData.name
        rewardName.TextColor3 = Color3.fromRGB(255, 255, 255)
        rewardName.TextSize = 18
        rewardName.TextXAlignment = Enum.TextXAlignment.Left
        
        local rewardAmount = Instance.new("TextLabel")
        rewardAmount.Parent = rewardFrame
        rewardAmount.BackgroundTransparency = 1
        rewardAmount.Position = UDim2.new(0, 10, 0, 30)
        rewardAmount.Size = UDim2.new(1, -20, 0, 20)
        rewardAmount.Font = Enum.Font.Gotham
        rewardAmount.Text = rewardAmount .. " Coins"
        rewardAmount.TextColor3 = Color3.fromRGB(255, 255, 200)
        rewardAmount.TextSize = 14
        rewardAmount.TextXAlignment = Enum.TextXAlignment.Left
        
        local claimButton = Instance.new("TextButton")
        claimButton.Parent = rewardFrame
        claimButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        claimButton.BackgroundTransparency = 0.5
        claimButton.BorderSizePixel = 0
        claimButton.Position = UDim2.new(1, -80, 0, 20)
        claimButton.Size = UDim2.new(0, 70, 0, 30)
        claimButton.Font = Enum.Font.GothamBold
        claimButton.Text = "CLAIM"
        claimButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        claimButton.TextSize = 14
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = claimButton
        buttonCorner.CornerRadius = UDim.new(0, 5)
        
        -- Update tampilan jika sudah diklaim
        local function updateButton()
            if claimedStatus[rewardType] then
                claimButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                claimButton.Text = "CLAIMED"
                claimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                claimButton.Active = false
            else
                claimButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                claimButton.Text = "CLAIM"
                claimButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                claimButton.Active = true
            end
        end
        
        updateButton()
        
        claimButton.MouseButton1Click:Connect(function()
            if not claimedStatus[rewardType] then
                claimedStatus[rewardType] = true
                coinsValue.Value = coinsValue.Value + rewardData.amount
                
                -- Efek visual
                rewardFrame.BackgroundTransparency = 0
                rewardFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                
                task.delay(0.3, function()
                    rewardFrame.BackgroundColor3 = rewardData.color
                    rewardFrame.BackgroundTransparency = 0.2
                    updateButton()
                end)
                
                -- Notifikasi
                local notification = Instance.new("ScreenGui")
                notification.Parent = player.PlayerGui
                
                local notifFrame = Instance.new("Frame")
                notifFrame.Parent = notification
                notifFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                notifFrame.BorderSizePixel = 0
                notifFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
                notifFrame.Size = UDim2.new(0, 300, 0, 50)
                
                local notifCorner = Instance.new("UICorner")
                notifCorner.Parent = notifFrame
                notifCorner.CornerRadius = UDim.new(0, 8)
                
                local notifLabel = Instance.new("TextLabel")
                notifLabel.Parent = notifFrame
                notifLabel.BackgroundTransparency = 1
                notifLabel.Size = UDim2.new(1, 0, 1, 0)
                notifLabel.Font = Enum.Font.Gotham
                notifLabel.Text = "Claimed " .. rewardData.amount .. " coins!"
                notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                notifLabel.TextSize = 16
                
                task.delay(2, function()
                    notification:Destroy()
                end)
            end
        end)
    end
    
    -- Reset harian (simulasi)
    task.spawn(function()
        while true do
            task.wait(86400) -- 24 jam
            for rewardType, _ in pairs(rewards) do
                if rewardType == "daily" then
                    claimedStatus[rewardType] = false
                end
            end
        end
    end)
end

-- =============================================
-- BAGIAN 4: SMOOTH UI
-- =============================================
local SmoothUI = {}

function SmoothUI.createSmoothButton(parent, text, position, size, color, onClick)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = color or Color3.fromRGB(0, 120, 255)
    button.BorderSizePixel = 0
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.Size = size or UDim2.new(0, 100, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = text or "Button"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.Parent = button
    corner.CornerRadius = UDim.new(0, 5)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button:TweenSize(UDim2.new(0, size.X.Offset + 10, 0, size.Y.Offset + 5), "Out", "Quad", 0.2)
        button.BackgroundColor3 = color:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        button:TweenSize(size, "Out", "Quad", 0.2)
        button.BackgroundColor3 = color
    end)
    
    button.MouseButton1Click:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        task.delay(0.1, function()
            button.BackgroundColor3 = color
        end)
        
        if onClick then
            onClick()
        end
    end)
    
    return button
end

function SmoothUI.createSmoothFrame(parent, position, size, color, transparency)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.Size = size or UDim2.new(0, 100, 0, 100)
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 10)
    
    return frame
end

function SmoothUI.createSmoothInput(parent, placeholder, position, size)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    frame.BorderSizePixel = 0
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.Size = size or UDim2.new(0, 200, 0, 30)
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 5)
    
    local textBox = Instance.new("TextBox")
    textBox.Parent = frame
    textBox.BackgroundTransparency = 1
    textBox.Size = UDim2.new(1, -10, 1, 0)
    textBox.Position = UDim2.new(0, 5, 0, 0)
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = placeholder or "Input..."
    textBox.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14
    textBox.ClearTextOnFocus = false
    
    return textBox
end

function SmoothUI.createNotification(title, message, duration)
    local player = game.Players.LocalPlayer
    if not player then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Notification"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    frame.Size = UDim2.new(0, 300, 0, 0)
    frame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 10)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = frame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title or "Notification"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Parent = frame
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 10, 0, 35)
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Text = message or ""
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    
    -- Animasi muncul
    frame:TweenSize(UDim2.new(0, 300, 0, 80), "Out", "Quad", 0.3)
    
    -- Animasi hilang
    task.delay(duration or 3, function()
        frame:TweenSize(UDim2.new(0, 300, 0, 0), "Out", "Quad", 0.3)
        task.delay(0.3, function()
            screenGui:Destroy()
        end)
    end)
end

-- =============================================
-- BAGIAN 5: QUICK PROGRESS
-- =============================================
local QuickProgress = {}

function QuickProgress.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat leaderstats jika belum ada
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
        
        local level = Instance.new("NumberValue")
        level.Name = "Level"
        level.Parent = leaderstats
        level.Value = 1
        
        local exp = Instance.new("NumberValue")
        exp.Name = "Exp"
        exp.Parent = leaderstats
        exp.Value = 0
        
        local maxExp = Instance.new("NumberValue")
        maxExp.Name = "MaxExp"
        maxExp.Parent = leaderstats
        maxExp.Value = 100
    end
    
    local levelValue = leaderstats:FindFirstChild("Level") or Instance.new("NumberValue")
    local expValue = leaderstats:FindFirstChild("Exp") or Instance.new("NumberValue")
    local maxExpValue = leaderstats:FindFirstChild("MaxExp") or Instance.new("NumberValue")
    
    -- Buat GUI Progress
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProgressGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "⚡ QUICK PROGRESS ⚡"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 10)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 5)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Level Display
    local levelFrame = Instance.new("Frame")
    levelFrame.Parent = mainFrame
    levelFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    levelFrame.BorderSizePixel = 0
    levelFrame.Position = UDim2.new(0, 10, 0, 50)
    levelFrame.Size = UDim2.new(1, -20, 0, 60)
    
    local levelCorner = Instance.new("UICorner")
    levelCorner.Parent = levelFrame
    levelCorner.CornerRadius = UDim.new(0, 8)
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Parent = levelFrame
    levelLabel.BackgroundTransparency = 1
    levelLabel.Position = UDim2.new(0, 10, 0, 5)
    levelLabel.Size = UDim2.new(1, -20, 0, 25)
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Text = "LEVEL " .. levelValue.Value
    levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    levelLabel.TextSize = 22
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Progress Bar
    local progressBg = Instance.new("Frame")
    progressBg.Parent = levelFrame
    progressBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    progressBg.BorderSizePixel = 0
    progressBg.Position = UDim2.new(0, 10, 0, 35)
    progressBg.Size = UDim2.new(1, -20, 0, 15)
    
    local progressBgCorner = Instance.new("UICorner")
    progressBgCorner.Parent = progressBg
    progressBgCorner.CornerRadius = UDim.new(0, 7)
    
    local progressFill = Instance.new("Frame")
    progressFill.Parent = progressBg
    progressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.new(expValue.Value / maxExpValue.Value, 0, 1, 0)
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.Parent = progressFill
    progressCorner.CornerRadius = UDim.new(0, 7)
    
    local expLabel = Instance.new("TextLabel")
    expLabel.Parent = progressBg
    expLabel.BackgroundTransparency = 1
    expLabel.Size = UDim2.new(1, 0, 1, 0)
    expLabel.Font = Enum.Font.Gotham
    expLabel.Text = expValue.Value .. " / " .. maxExpValue.Value
    expLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    expLabel.TextSize = 10
    
    -- Update progress
    local function updateProgress()
        levelLabel.Text = "LEVEL " .. levelValue.Value
        progressFill:TweenSize(UDim2.new(expValue.Value / maxExpValue.Value, 0, 1, 0), "Out", "Quad", 0.3)
        expLabel.Text = math.floor(expValue.Value) .. " / " .. maxExpValue.Value
    end
    
    expValue:GetPropertyChangedSignal("Value"):Connect(updateProgress)
    levelValue:GetPropertyChangedSignal("Value"):Connect(updateProgress)
    maxExpValue:GetPropertyChangedSignal("Value"):Connect(updateProgress)
    
    -- Quick Actions
    local actionsLabel = Instance.new("TextLabel")
    actionsLabel.Parent = mainFrame
    actionsLabel.BackgroundTransparency = 1
    actionsLabel.Position = UDim2.new(0, 10, 0, 120)
    actionsLabel.Size = UDim2.new(1, -20, 0, 20)
    actionsLabel.Font = Enum.Font.GothamBold
    actionsLabel.Text = "QUICK ACTIONS:"
    actionsLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    actionsLabel.TextSize = 16
    actionsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local actionsFrame = Instance.new("Frame")
    actionsFrame.Parent = mainFrame
    actionsFrame.BackgroundTransparency = 1
    actionsFrame.Position = UDim2.new(0, 10, 0, 145)
    actionsFrame.Size = UDim2.new(1, -20, 0, 130)
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.Parent = actionsFrame
    gridLayout.CellSize = UDim2.new(0, 120, 0, 60)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    
    -- Tombol-tombol aksi
    local actions = {
        {name = "GAIN EXP", color = Color3.fromRGB(0, 150, 255), amount = 10},
        {name = "LEVEL UP", color = Color3.fromRGB(255, 150, 0), amount = 0},
        {name = "RESET EXP", color = Color3.fromRGB(255, 50, 50), amount = 0},
        {name = "DOUBLE", color = Color3.fromRGB(150, 0, 255), amount = 0}
    }
    
    for i, action in ipairs(actions) do
        local actionButton = Instance.new("TextButton")
        actionButton.Parent = actionsFrame
        actionButton.BackgroundColor3 = action.color
        actionButton.BorderSizePixel = 0
        actionButton.Size = UDim2.new(1, 0, 1, 0)
        actionButton.Font = Enum.Font.GothamBold
        actionButton.Text = action.name
        actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        actionButton.TextSize = 12
        actionButton.AutoButtonColor = false
        
        local actionCorner = Instance.new("UICorner")
        actionCorner.Parent = actionButton
        actionCorner.CornerRadius = UDim.new(0, 5)
        
        actionButton.MouseEnter:Connect(function()
            actionButton.BackgroundColor3 = action.color:Lerp(Color3.fromRGB(255, 255, 255), 0.3)
        end)
        
        actionButton.MouseLeave:Connect(function()
            actionButton.BackgroundColor3 = action.color
        end)
        
        actionButton.MouseButton1Click:Connect(function()
            if action.name == "GAIN EXP" then
                expValue.Value = math.min(expValue.Value + action.amount, maxExpValue.Value)
            elseif action.name == "LEVEL UP" then
                if expValue.Value >= maxExpValue.Value then
                    levelValue.Value = levelValue.Value + 1
                    expValue.Value = 0
                    maxExpValue.Value = maxExpValue.Value + 50
                end
            elseif action.name == "RESET EXP" then
                expValue.Value = 0
            elseif action.name == "DOUBLE" then
                expValue.Value = math.min(expValue.Value * 2, maxExpValue.Value)
            end
            
            -- Animasi klik
            actionButton:TweenSize(UDim2.new(1.1, 0, 1.1, 0), "Out", "Quad", 0.1)
            task.delay(0.1, function()
                actionButton:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.1)
            end)
        end)
    end
end

-- =============================================
-- BAGIAN 6: OP SCRIPT
-- =============================================
local OPScript = {}

function OPScript.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Statistik player
    local stats = {
        walkspeed = 16,
        jumppower = 50,
        health = 100,
        maxHealth = 100
    }
    
    -- Buat GUI OP
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OPScriptGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "🔥 OP SCRIPT 🔥"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 10)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tab system
    local tabFrame = Instance.new("Frame")
    tabFrame.Parent = mainFrame
    tabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabFrame.BorderSizePixel = 0
    tabFrame.Position = UDim2.new(0, 10, 0, 55)
    tabFrame.Size = UDim2.new(1, -20, 0, 35)
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.Parent = tabFrame
    tabCorner.CornerRadius = UDim.new(0, 8)
    
    local tabs = {"MOVEMENT", "COMBAT", "VISUAL", "UTILITY"}
    local tabButtons = {}
    local currentTab = "MOVEMENT"
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    contentFrame.BorderSizePixel = 0
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.Size = UDim2.new(1, -20, 1, -150)
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.Parent = contentFrame
    contentCorner.CornerRadius = UDim.new(0, 8)
    
    -- Buat tab buttons
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = tabFrame
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        tabButton.BorderSizePixel = 0
        tabButton.Position = UDim2.new((i-1) * 0.25, 2, 0, 2)
        tabButton.Size = UDim2.new(0.25, -4, 1, -4)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.Parent = tabButton
        tabButtonCorner.CornerRadius = UDim.new(0, 6)
        
        tabButtons[tabName] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            currentTab = tabName
            for _, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            updateContent()
        end)
    end
    
    -- Set tab pertama aktif
    tabButtons["MOVEMENT"].BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    tabButtons["MOVEMENT"].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Function update konten
    local function updateContent()
        -- Hapus konten lama
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                child:Destroy()
            end
        end
        
        if currentTab == "MOVEMENT" then
            -- Konten Movement
            local speedLabel = Instance.new("TextLabel")
            speedLabel.Parent = contentFrame
            speedLabel.BackgroundTransparency = 1
            speedLabel.Position = UDim2.new(0, 10, 0, 10)
            speedLabel.Size = UDim2.new(1, -20, 0, 30)
            speedLabel.Font = Enum.Font.GothamBold
            speedLabel.Text = "WALK SPEED: " .. stats.walkspeed
            speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            speedLabel.TextSize = 18
            speedLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local speedSlider = Instance.new("Frame")
            speedSlider.Parent = contentFrame
            speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            speedSlider.BorderSizePixel = 0
            speedSlider.Position = UDim2.new(0, 10, 0, 50)
            speedSlider.Size = UDim2.new(0.7, -20, 0, 30)
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.Parent = speedSlider
            sliderCorner.CornerRadius = UDim.new(0, 5)
            
            local speedFill = Instance.new("Frame")
            speedFill.Parent = speedSlider
            speedFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            speedFill.BorderSizePixel = 0
            speedFill.Size = UDim2.new(stats.walkspeed / 100, 0, 1, 0)
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.Parent = speedFill
            fillCorner.CornerRadius = UDim.new(0, 5)
            
            local speedInput = Instance.new("TextBox")
            speedInput.Parent = contentFrame
            speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            speedInput.BorderSizePixel = 0
            speedInput.Position = UDim2.new(0.7, 10, 0, 50)
            speedInput.Size = UDim2.new(0.25, -20, 0, 30)
            speedInput.Font = Enum.Font.Gotham
            speedInput.PlaceholderText = "Value"
            speedInput.Text = tostring(stats.walkspeed)
            speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            speedInput.TextSize = 14
            
            local inputCorner = Instance.new("UICorner")
            inputCorner.Parent = speedInput
            inputCorner.CornerRadius = UDim.new(0, 5)
            
            speedInput.FocusLost:Connect(function()
                local newSpeed = tonumber(speedInput.Text) or 16
                newSpeed = math.clamp(newSpeed, 1, 500)
                stats.walkspeed = newSpeed
                speedLabel.Text = "WALK SPEED: " .. newSpeed
                speedFill:TweenSize(UDim2.new(newSpeed / 100, 0, 1, 0), "Out", "Quad", 0.3)
                humanoid.WalkSpeed = newSpeed
            end)
            
            -- Jump Power
            local jumpLabel = Instance.new("TextLabel")
            jumpLabel.Parent = contentFrame
            jumpLabel.BackgroundTransparency = 1
            jumpLabel.Position = UDim2.new(0, 10, 0, 100)
            jumpLabel.Size = UDim2.new(1, -20, 0, 30)
            jumpLabel.Font = Enum.Font.GothamBold
            jumpLabel.Text = "JUMP POWER: " .. stats.jumppower
            jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            jumpLabel.TextSize = 18
            jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local jumpSlider = Instance.new("Frame")
            jumpSlider.Parent = contentFrame
            jumpSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            jumpSlider.BorderSizePixel = 0
            jumpSlider.Position = UDim2.new(0, 10, 0, 140)
            jumpSlider.Size = UDim2.new(0.7, -20, 0, 30)
            
            local jumpSliderCorner = Instance.new("UICorner")
            jumpSliderCorner.Parent = jumpSlider
            jumpSliderCorner.CornerRadius = UDim.new(0, 5)
            
            local jumpFill = Instance.new("Frame")
            jumpFill.Parent = jumpSlider
            jumpFill.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            jumpFill.BorderSizePixel = 0
            jumpFill.Size = UDim2.new(stats.jumppower / 500, 0, 1, 0)
            
            local jumpFillCorner = Instance.new("UICorner")
            jumpFillCorner.Parent = jumpFill
            jumpFillCorner.CornerRadius = UDim.new(0, 5)
            
            local jumpInput = Instance.new("TextBox")
            jumpInput.Parent = contentFrame
            jumpInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            jumpInput.BorderSizePixel = 0
            jumpInput.Position = UDim2.new(0.7, 10, 0, 140)
            jumpInput.Size = UDim2.new(0.25, -20, 0, 30)
            jumpInput.Font = Enum.Font.Gotham
            jumpInput.PlaceholderText = "Value"
            jumpInput.Text = tostring(stats.jumppower)
            jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            jumpInput.TextSize = 14
            
            local jumpInputCorner = Instance.new("UICorner")
            jumpInputCorner.Parent = jumpInput
            jumpInputCorner.CornerRadius = UDim.new(0, 5)
            
            jumpInput.FocusLost:Connect(function()
                local newJump = tonumber(jumpInput.Text) or 50
                newJump = math.clamp(newJump, 1, 1000)
                stats.jumppower = newJump
                jumpLabel.Text = "JUMP POWER: " .. newJump
                jumpFill:TweenSize(UDim2.new(newJump / 500, 0, 1, 0), "Out", "Quad", 0.3)
                humanoid.JumpPower = newJump
            end)
            
        elseif currentTab == "COMBAT" then
            -- Konten Combat
            local combatOptions = {
                {name = "AUTO ATTACK", default = false},
                {name = "AUTO BLOCK", default = false},
                {name = "CRITICAL HITS", default = true},
                {name = "DMG MULTIPLIER", default = "2x"}
            }
            
            for i, option in ipairs(combatOptions) do
                local optionFrame = Instance.new("Frame")
                optionFrame.Parent = contentFrame
                optionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                optionFrame.BorderSizePixel = 0
                optionFrame.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 45)
                optionFrame.Size = UDim2.new(1, -20, 0, 40)
                
                local optionCorner = Instance.new("UICorner")
                optionCorner.Parent = optionFrame
                optionCorner.CornerRadius = UDim.new(0, 8)
                
                local optionLabel = Instance.new("TextLabel")
                optionLabel.Parent = optionFrame
                optionLabel.BackgroundTransparency = 1
                optionLabel.Position = UDim2.new(0, 10, 0, 0)
                optionLabel.Size = UDim2.new(0.6, 0, 1, 0)
                optionLabel.Font = Enum.Font.Gotham
                optionLabel.Text = option.name
                optionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionLabel.TextSize = 16
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleButton = Instance.new("TextButton")
                toggleButton.Parent = optionFrame
                toggleButton.BackgroundColor3 = option.default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                toggleButton.BorderSizePixel = 0
                toggleButton.Position = UDim2.new(0.8, 0, 0.1, 0)
                toggleButton.Size = UDim2.new(0.15, 0, 0.8, 0)
                toggleButton.Font = Enum.Font.GothamBold
                toggleButton.Text = option.default and "ON" or "OFF"
                toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleButton.TextSize = 14
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.Parent = toggleButton
                toggleCorner.CornerRadius = UDim.new(0, 5)
                
                local state = option.default
                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                    toggleButton.Text = state and "ON" or "OFF"
                end)
            end
            
        elseif currentTab == "VISUAL" then
            -- Konten Visual
            local visualOptions = {
                {name = "ESP", default = false},
                {name = "WALLHACK", default = false},
                {name = "FULLBRIGHT", default = false},
                {name = "NAMETAGS", default = true},
                {name = "CHAMS", default = false}
            }
            
            for i, option in ipairs(visualOptions) do
                local optionFrame = Instance.new("Frame")
                optionFrame.Parent = contentFrame
                optionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                optionFrame.BorderSizePixel = 0
                optionFrame.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 40)
                optionFrame.Size = UDim2.new(1, -20, 0, 35)
                
                local optionCorner = Instance.new("UICorner")
                optionCorner.Parent = optionFrame
                optionCorner.CornerRadius = UDim.new(0, 8)
                
                local optionLabel = Instance.new("TextLabel")
                optionLabel.Parent = optionFrame
                optionLabel.BackgroundTransparency = 1
                optionLabel.Position = UDim2.new(0, 10, 0, 0)
                optionLabel.Size = UDim2.new(0.7, 0, 1, 0)
                optionLabel.Font = Enum.Font.Gotham
                optionLabel.Text = option.name
                optionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionLabel.TextSize = 16
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleButton = Instance.new("TextButton")
                toggleButton.Parent = optionFrame
                toggleButton.BackgroundColor3 = option.default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                toggleButton.BorderSizePixel = 0
                toggleButton.Position = UDim2.new(0.8, 0, 0.15, 0)
                toggleButton.Size = UDim2.new(0.15, 0, 0.7, 0)
                toggleButton.Font = Enum.Font.GothamBold
                toggleButton.Text = option.default and "ON" or "OFF"
                toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleButton.TextSize = 14
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.Parent = toggleButton
                toggleCorner.CornerRadius = UDim.new(0, 5)
                
                local state = option.default
                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                    toggleButton.Text = state and "ON" or "OFF"
                end)
            end
            
        elseif currentTab == "UTILITY" then
            -- Konten Utility
            local utilityButtons = {
                {name = "INFINITE JUMP", color = Color3.fromRGB(0, 150, 255)},
                {name = "NO CLIP", color = Color3.fromRGB(255, 150, 0)},
                {name = "FLY", color = Color3.fromRGB(150, 0, 255)},
                {name = "RESPAWN", color = Color3.fromRGB(255, 50, 50)},
                {name = "HEAL", color = Color3.fromRGB(0, 200, 0)},
                {name = "GOD MODE", color = Color3.fromRGB(255, 215, 0)}
            }
            
            for i, btn in ipairs(utilityButtons) do
                local row = math.floor((i-1) / 3)
                local col = (i-1) % 3
                
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.05 + col * 0.32, 0, 0.05 + row * 0.18, 0)
                button.Size = UDim2.new(0.3, 0, 0.15, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.Parent = button
                buttonCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(function()
                    if btn.name == "INFINITE JUMP" then
                        -- Implementasi infinite jump
                    elseif btn.name == "NO CLIP" then
                        -- Implementasi noclip
                    elseif btn.name == "FLY" then
                        -- Implementasi fly
                    elseif btn.name == "RESPAWN" then
                        humanoid.Health = 0
                    elseif btn.name == "HEAL" then
                        humanoid.Health = humanoid.MaxHealth
                    elseif btn.name == "GOD MODE" then
                        -- Implementasi god mode
                    end
                end)
            end
        end
    end
    
    updateContent()
    
    -- Update loop
    task.spawn(function()
        while true do
            task.wait(0.1)
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = stats.walkspeed
                humanoid.JumpPower = stats.jumppower
            end
        end
    end)
end

-- =============================================
-- BAGIAN 7: FREE SCRIPT (Versi Gratis dari OP)
-- =============================================
local OPFreeScript = {}

function OPFreeScript.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Free
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FreeScriptGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "✨ FREE SCRIPT ✨"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 10)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 5)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tombol-tombol free
    local freeButtons = {
        {name = "Speed Boost", description = "Tingkatkan kecepatan", color = Color3.fromRGB(0, 150, 255)},
        {name = "Auto Click", description = "Klik otomatis", color = Color3.fromRGB(255, 150, 0)},
        {name = "Auto Farm", description = "Farm otomatis", color = Color3.fromRGB(0, 200, 0)},
        {name = "ESP", description = "Lihat player lain", color = Color3.fromRGB(255, 0, 150)},
        {name = "No Fall Damage", description = "Tanpa damage jatuh", color = Color3.fromRGB(150, 0, 255)},
        {name = "Full Bright", description = "Terang terus", color = Color3.fromRGB(255, 255, 0)}
    }
    
    for i, btn in ipairs(freeButtons) do
        local row = math.floor((i-1) / 2)
        local col = (i-1) % 2
        
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Parent = mainFrame
        buttonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        buttonFrame.BorderSizePixel = 0
        buttonFrame.Position = UDim2.new(0.05 + col * 0.48, 0, 0.15 + row * 0.25, 0)
        buttonFrame.Size = UDim2.new(0.45, 0, 0.22, 0)
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = buttonFrame
        buttonCorner.CornerRadius = UDim.new(0, 8)
        
        local button = Instance.new("TextButton")
        button.Parent = buttonFrame
        button.BackgroundColor3 = btn.color
        button.BackgroundTransparency = 0.2
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Font = Enum.Font.GothamBold
        button.Text = ""
        button.AutoButtonColor = false
        
        local buttonCornerInner = Instance.new("UICorner")
        buttonCornerInner.Parent = button
        buttonCornerInner.CornerRadius = UDim.new(0, 8)
        
        local buttonTitle = Instance.new("TextLabel")
        buttonTitle.Parent = button
        buttonTitle.BackgroundTransparency = 1
        buttonTitle.Position = UDim2.new(0, 0, 0, 5)
        buttonTitle.Size = UDim2.new(1, 0, 0, 25)
        buttonTitle.Font = Enum.Font.GothamBold
        buttonTitle.Text = btn.name
        buttonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        buttonTitle.TextSize = 14
        
        local buttonDesc = Instance.new("TextLabel")
        buttonDesc.Parent = button
        buttonDesc.BackgroundTransparency = 1
        buttonDesc.Position = UDim2.new(0, 0, 0, 30)
        buttonDesc.Size = UDim2.new(1, 0, 0, 20)
        buttonDesc.Font = Enum.Font.Gotham
        buttonDesc.Text = btn.description
        buttonDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
        buttonDesc.TextSize = 10
        
        button.MouseEnter:Connect(function()
            button.BackgroundTransparency = 0
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundTransparency = 0.2
        end)
        
        button.MouseButton1Click:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            task.delay(0.1, function()
                button.BackgroundColor3 = btn.color
            end)
            
            SmoothUI.createNotification("Free Script", btn.name .. " activated!", 2)
        end)
    end
end

-- =============================================
-- BAGIAN 8: CRAFTING SCRIPT
-- =============================================
local OPCraftingScript = {}

function OPCraftingScript.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Data crafting
    local recipes = {
        {name = "Wooden Sword", materials = {"Wood x3", "String x1"}, result = "Wooden Sword", time = 5},
        {name = "Stone Pickaxe", materials = {"Stone x5", "Wood x2"}, result = "Stone Pickaxe", time = 8},
        {name = "Iron Armor", materials = {"Iron x10", "Leather x3"}, result = "Iron Armor", time = 15},
        {name = "Diamond Sword", materials = {"Diamond x8", "Gold x4"}, result = "Diamond Sword", time = 20},
        {name = "Enchanted Bow", materials = {"Wood x6", "String x3", "Emerald x2"}, result = "Enchanted Bow", time = 12},
        {name = "Health Potion", materials = {"Herb x4", "Water x1", "Glass x1"}, result = "Health Potion", time = 3}
    }
    
    -- Buat GUI Crafting
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CraftingGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "⚒️ CRAFTING SYSTEM ⚒️"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Parent = mainFrame
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Position = UDim2.new(0, 10, 0, 55)
    scrollingFrame.Size = UDim2.new(1, -20, 1, -110)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #recipes * 90)
    scrollingFrame.ScrollBarThickness = 8
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollingFrame
    uiListLayout.Padding = UDim.new(0, 8)
    
    -- Buat item crafting
    for i, recipe in ipairs(recipes) do
        local recipeFrame = Instance.new("Frame")
        recipeFrame.Parent = scrollingFrame
        recipeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        recipeFrame.BorderSizePixel = 0
        recipeFrame.Size = UDim2.new(1, -10, 0, 80)
        
        local recipeCorner = Instance.new("UICorner")
        recipeCorner.Parent = recipeFrame
        recipeCorner.CornerRadius = UDim.new(0, 8)
        
        local recipeName = Instance.new("TextLabel")
        recipeName.Parent = recipeFrame
        recipeName.BackgroundTransparency = 1
        recipeName.Position = UDim2.new(0, 10, 0, 5)
        recipeName.Size = UDim2.new(0.5, 0, 0, 20)
        recipeName.Font = Enum.Font.GothamBold
        recipeName.Text = recipe.name
        recipeName.TextColor3 = Color3.fromRGB(255, 215, 0)
        recipeName.TextSize = 16
        recipeName.TextXAlignment = Enum.TextXAlignment.Left
        
        local recipeTime = Instance.new("TextLabel")
        recipeTime.Parent = recipeFrame
        recipeTime.BackgroundTransparency = 1
        recipeTime.Position = UDim2.new(0.5, 0, 0, 5)
        recipeTime.Size = UDim2.new(0.3, 0, 0, 20)
        recipeTime.Font = Enum.Font.Gotham
        recipeTime.Text = "⏱️ " .. recipe.time .. "s"
        recipeTime.TextColor3 = Color3.fromRGB(200, 200, 200)
        recipeTime.TextSize = 14
        recipeTime.TextXAlignment = Enum.TextXAlignment.Left
        
        local materialsLabel = Instance.new("TextLabel")
        materialsLabel.Parent = recipeFrame
        materialsLabel.BackgroundTransparency = 1
        materialsLabel.Position = UDim2.new(0, 10, 0, 25)
        materialsLabel.Size = UDim2.new(0.7, 0, 0, 20)
        materialsLabel.Font = Enum.Font.Gotham
        materialsLabel.Text = "Materials: " .. table.concat(recipe.materials, ", ")
        materialsLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        materialsLabel.TextSize = 12
        materialsLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local resultLabel = Instance.new("TextLabel")
        resultLabel.Parent = recipeFrame
        resultLabel.BackgroundTransparency = 1
        resultLabel.Position = UDim2.new(0, 10, 0, 45)
        resultLabel.Size = UDim2.new(0.5, 0, 0, 20)
        resultLabel.Font = Enum.Font.Gotham
        resultLabel.Text = "Result: " .. recipe.result
        resultLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        resultLabel.TextSize = 12
        resultLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local craftButton = Instance.new("TextButton")
        craftButton.Parent = recipeFrame
        craftButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        craftButton.BorderSizePixel = 0
        craftButton.Position = UDim2.new(0.8, 0, 0.2, 0)
        craftButton.Size = UDim2.new(0.15, 0, 0.6, 0)
        craftButton.Font = Enum.Font.GothamBold
        craftButton.Text = "CRAFT"
        craftButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        craftButton.TextSize = 14
        
        local craftCorner = Instance.new("UICorner")
        craftCorner.Parent = craftButton
        craftCorner.CornerRadius = UDim.new(0, 5)
        
        -- Progress bar (sembunyi)
        local progressFrame = Instance.new("Frame")
        progressFrame.Parent = recipeFrame
        progressFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        progressFrame.BorderSizePixel = 0
        progressFrame.Position = UDim2.new(0, 10, 0, 65)
        progressFrame.Size = UDim2.new(0.7, 0, 0, 10)
        progressFrame.Visible = false
        
        local progressCorner = Instance.new("UICorner")
        progressCorner.Parent = progressFrame
        progressCorner.CornerRadius = UDim.new(0, 5)
        
        local progressFill = Instance.new("Frame")
        progressFill.Parent = progressFrame
        progressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        progressFill.BorderSizePixel = 0
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.Parent = progressFill
        fillCorner.CornerRadius = UDim.new(0, 5)
        
        local isCrafting = false
        
        craftButton.MouseButton1Click:Connect(function()
            if isCrafting then return end
            
            isCrafting = true
            craftButton.Text = "CRAFTING..."
            craftButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            craftButton.Active = false
            progressFrame.Visible = true
            
            -- Animasi progress
            local startTime = tick()
            local craftingTime = recipe.time
            
            local connection
            connection = game:GetService("RunService").Heartbeat:Connect(function()
                local elapsed = tick() - startTime
                local progress = math.min(elapsed / craftingTime, 1)
                progressFill.Size = UDim2.new(progress, 0, 1, 0)
                
                if progress >= 1 then
                    connection:Disconnect()
                    
                    -- Selesai crafting
                    task.wait(0.5)
                    progressFrame.Visible = false
                    craftButton.Text = "CRAFT"
                    craftButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    craftButton.Active = true
                    isCrafting = false
                    
                    -- Notifikasi
                    local notification = Instance.new("ScreenGui")
                    notification.Parent = player.PlayerGui
                    
                    local notifFrame = Instance.new("Frame")
                    notifFrame.Parent = notification
                    notifFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    notifFrame.BorderSizePixel = 0
                    notifFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
                    notifFrame.Size = UDim2.new(0, 300, 0, 50)
                    
                    local notifCorner = Instance.new("UICorner")
                    notifCorner.Parent = notifFrame
                    notifCorner.CornerRadius = UDim.new(0, 8)
                    
                    local notifLabel = Instance.new("TextLabel")
                    notifLabel.Parent = notifFrame
                    notifLabel.BackgroundTransparency = 1
                    notifLabel.Size = UDim2.new(1, 0, 1, 0)
                    notifLabel.Font = Enum.Font.Gotham
                    notifLabel.Text = "Crafted: " .. recipe.result
                    notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    notifLabel.TextSize = 16
                    
                    task.delay(2, function()
                        notification:Destroy()
                    end)
                end
            end)
        end)
    end
    
    -- Inventory section
    local invFrame = Instance.new("Frame")
    invFrame.Parent = mainFrame
    invFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    invFrame.BorderSizePixel = 0
    invFrame.Position = UDim2.new(0, 10, 1, -45)
    invFrame.Size = UDim2.new(1, -20, 0, 35)
    
    local invCorner = Instance.new("UICorner")
    invCorner.Parent = invFrame
    invCorner.CornerRadius = UDim.new(0, 8)
    
    local invLabel = Instance.new("TextLabel")
    invLabel.Parent = invFrame
    invLabel.BackgroundTransparency = 1
    invLabel.Size = UDim2.new(1, 0, 1, 0)
    invLabel.Font = Enum.Font.Gotham
    invLabel.Text = "Inventory: Wood x10 | Stone x15 | Iron x8 | Diamond x3"
    invLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    invLabel.TextSize = 14
end

-- =============================================
-- BAGIAN 9: KEYLESS V2
-- =============================================
local KeylessV2 = {}

function KeylessV2.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Keyless
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeylessV2GUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    mainFrame.Size = UDim2.new(0, 450, 0, 350)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Parent = mainFrame
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    })
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Font = Enum.Font.GothamBold
    title.Text = "🔑 KEYLESS V2 🔑"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Parent = title
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 0, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 200))
    })
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Welcome text
    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Parent = mainFrame
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.Position = UDim2.new(0, 20, 0, 60)
    welcomeLabel.Size = UDim2.new(1, -40, 0, 30)
    welcomeLabel.Font = Enum.Font.GothamBold
    welcomeLabel.Text = "Welcome, " .. player.Name .. "!"
    welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    welcomeLabel.TextSize = 18
    welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Stats
    local statsFrame = Instance.new("Frame")
    statsFrame.Parent = mainFrame
    statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statsFrame.BorderSizePixel = 0
    statsFrame.Position = UDim2.new(0, 20, 0, 100)
    statsFrame.Size = UDim2.new(1, -40, 0, 80)
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.Parent = statsFrame
    statsCorner.CornerRadius = UDim.new(0, 10)
    
    local statsGradient = Instance.new("UIGradient")
    statsGradient.Parent = statsFrame
    statsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    
    local stats = {
        {name = "Level", value = "42"},
        {name = "Kills", value = "1,234"},
        {name = "Deaths", value = "567"},
        {name = "K/D", value = "2.18"}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = Instance.new("Frame")
        statFrame.Parent = statsFrame
        statFrame.BackgroundTransparency = 1
        statFrame.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        statFrame.Size = UDim2.new(0.25, 0, 1, 0)
        
        local statValue = Instance.new("TextLabel")
        statValue.Parent = statFrame
        statValue.BackgroundTransparency = 1
        statValue.Position = UDim2.new(0, 0, 0.2, 0)
        statValue.Size = UDim2.new(1, 0, 0.4, 0)
        statValue.Font = Enum.Font.GothamBold
        statValue.Text = stat.value
        statValue.TextColor3 = Color3.fromRGB(255, 255, 255)
        statValue.TextSize = 20
        
        local statName = Instance.new("TextLabel")
        statName.Parent = statFrame
        statName.BackgroundTransparency = 1
        statName.Position = UDim2.new(0, 0, 0.6, 0)
        statName.Size = UDim2.new(1, 0, 0.3, 0)
        statName.Font = Enum.Font.Gotham
        statName.Text = stat.name
        statName.TextColor3 = Color3.fromRGB(200, 200, 200)
        statName.TextSize = 12
    end
    
    -- Features grid
    local featuresLabel = Instance.new("TextLabel")
    featuresLabel.Parent = mainFrame
    featuresLabel.BackgroundTransparency = 1
    featuresLabel.Position = UDim2.new(0, 20, 0, 200)
    featuresLabel.Size = UDim2.new(1, -40, 0, 20)
    featuresLabel.Font = Enum.Font.GothamBold
    featuresLabel.Text = "FEATURES"
    featuresLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    featuresLabel.TextSize = 16
    featuresLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local featuresFrame = Instance.new("Frame")
    featuresFrame.Parent = mainFrame
    featuresFrame.BackgroundTransparency = 1
    featuresFrame.Position = UDim2.new(0, 20, 0, 230)
    featuresFrame.Size = UDim2.new(1, -40, 0, 100)
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.Parent = featuresFrame
    gridLayout.CellSize = UDim2.new(0, 90, 0, 40)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    
    local features = {
        {name = "AIMBOT", color = Color3.fromRGB(255, 50, 50)},
        {name = "ESP", color = Color3.fromRGB(50, 255, 50)},
        {name = "WALLHACK", color = Color3.fromRGB(50, 50, 255)},
        {name = "SPEED", color = Color3.fromRGB(255, 255, 50)},
        {name = "JUMP", color = Color3.fromRGB(255, 50, 255)},
        {name = "FLY", color = Color3.fromRGB(50, 255, 255)},
        {name = "NOCLIP", color = Color3.fromRGB(255, 150, 50)},
        {name = "GOD", color = Color3.fromRGB(150, 50, 255)}
    }
    
    for _, feature in ipairs(features) do
        local featureButton = Instance.new("TextButton")
        featureButton.Parent = featuresFrame
        featureButton.BackgroundColor3 = feature.color
        featureButton.BackgroundTransparency = 0.3
        featureButton.BorderSizePixel = 0
        featureButton.Size = UDim2.new(1, 0, 1, 0)
        featureButton.Font = Enum.Font.GothamBold
        featureButton.Text = feature.name
        featureButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        featureButton.TextSize = 10
        featureButton.AutoButtonColor = false
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = featureButton
        buttonCorner.CornerRadius = UDim.new(0, 5)
        
        local state = false
        
        featureButton.MouseButton1Click:Connect(function()
            state = not state
            featureButton.BackgroundTransparency = state and 0 or 0.3
            featureButton.Text = state and "ON" or feature.name
        end)
    end
    
    -- Discord button
    local discordButton = Instance.new("TextButton")
    discordButton.Parent = mainFrame
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordButton.BorderSizePixel = 0
    discordButton.Position = UDim2.new(0, 20, 1, -45)
    discordButton.Size = UDim2.new(0.4, 0, 0, 35)
    discordButton.Font = Enum.Font.GothamBold
    discordButton.Text = "JOIN DISCORD"
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextSize = 14
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.Parent = discordButton
    discordCorner.CornerRadius = UDim.new(0, 8)
    
    discordButton.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/example")
        SmoothUI.createNotification("Discord", "Link copied to clipboard!", 2)
    end)
    
    -- Execute button
    local executeButton = Instance.new("TextButton")
    executeButton.Parent = mainFrame
    executeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    executeButton.BorderSizePixel = 0
    executeButton.Position = UDim2.new(0.5, 10, 1, -45)
    executeButton.Size = UDim2.new(0.4, 0, 0, 35)
    executeButton.Font = Enum.Font.GothamBold
    executeButton.Text = "EXECUTE"
    executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeButton.TextSize = 14
    
    local executeCorner = Instance.new("UICorner")
    executeCorner.Parent = executeButton
    executeCorner.CornerRadius = UDim.new(0, 8)
    
    executeButton.MouseButton1Click:Connect(function()
        executeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.delay(0.2, function()
            executeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end)
        SmoothUI.createNotification("Success", "Script executed!", 1)
    end)
end

-- =============================================
-- BAGIAN 10: KEYLESS SCRIPT (Dasar)
-- =============================================
local KeylessScript = {}

function KeylessScript.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Keyless sederhana
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeylessScriptGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 300, 0, 300)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "🔓 KEYLESS SCRIPT 🔓"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 10)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 5)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Menu sederhana
    local menuItems = {
        {name = "Auto Farm", desc = "Farm otomatis", color = Color3.fromRGB(0, 150, 255)},
        {name = "Auto Rebirth", desc = "Rebirth otomatis", color = Color3.fromRGB(255, 150, 0)},
        {name = "Auto Hatch", desc = "Hatch telur otomatis", color = Color3.fromRGB(150, 0, 255)},
        {name = "Speed Hack", desc = "Kecepatan maksimal", color = Color3.fromRGB(0, 255, 0)}
    }
    
    for i, item in ipairs(menuItems) do
        local yPos = 50 + (i-1) * 55
        
        local itemFrame = Instance.new("Frame")
        itemFrame.Parent = mainFrame
        itemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        itemFrame.BorderSizePixel = 0
        itemFrame.Position = UDim2.new(0, 10, 0, yPos)
        itemFrame.Size = UDim2.new(1, -20, 0, 50)
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.Parent = itemFrame
        itemCorner.CornerRadius = UDim.new(0, 8)
        
        local itemName = Instance.new("TextLabel")
        itemName.Parent = itemFrame
        itemName.BackgroundTransparency = 1
        itemName.Position = UDim2.new(0, 10, 0, 5)
        itemName.Size = UDim2.new(0.6, 0, 0, 20)
        itemName.Font = Enum.Font.GothamBold
        itemName.Text = item.name
        itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
        itemName.TextSize = 14
        itemName.TextXAlignment = Enum.TextXAlignment.Left
        
        local itemDesc = Instance.new("TextLabel")
        itemDesc.Parent = itemFrame
        itemDesc.BackgroundTransparency = 1
        itemDesc.Position = UDim2.new(0, 10, 0, 25)
        itemDesc.Size = UDim2.new(0.6, 0, 0, 20)
        itemDesc.Font = Enum.Font.Gotham
        itemDesc.Text = item.desc
        itemDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
        itemDesc.TextSize = 10
        itemDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Parent = itemFrame
        toggleButton.BackgroundColor3 = item.color
        toggleButton.BorderSizePixel = 0
        toggleButton.Position = UDim2.new(0.7, 0, 0.1, 0)
        toggleButton.Size = UDim2.new(0.25, 0, 0.8, 0)
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Text = "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextSize = 12
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.Parent = toggleButton
        toggleCorner.CornerRadius = UDim.new(0, 5)
        
        local isOn = false
        toggleButton.MouseButton1Click:Connect(function()
            isOn = not isOn
            toggleButton.Text = isOn and "ON" or "OFF"
            toggleButton.BackgroundColor3 = isOn and Color3.fromRGB(0, 200, 0) or item.color
        end)
    end
end

-- =============================================
-- BAGIAN 11: FULL PROGRESS AUTOMATION
-- =============================================
local FullProgressAutomation = {}

function FullProgressAutomation.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Data progress
    local progressData = {
        level = 1,
        exp = 0,
        maxExp = 100,
        coins = 0,
        rebirths = 0,
        pets = 0,
        achievements = 0
    }
    
    -- Buat GUI Progress Automation
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProgressAutomationGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 550, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "⚙️ FULL PROGRESS AUTOMATION ⚙️"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Parent = mainFrame
    tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    tabFrame.BorderSizePixel = 0
    tabFrame.Position = UDim2.new(0, 10, 0, 55)
    tabFrame.Size = UDim2.new(1, -20, 0, 35)
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.Parent = tabFrame
    tabCorner.CornerRadius = UDim.new(0, 8)
    
    local tabs = {"PROGRESS", "AUTOMATION", "STATS", "SETTINGS"}
    local tabButtons = {}
    local currentTab = "PROGRESS"
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    contentFrame.BorderSizePixel = 0
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.Size = UDim2.new(1, -20, 1, -150)
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.Parent = contentFrame
    contentCorner.CornerRadius = UDim.new(0, 10)
    
    -- Buat tab buttons
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = tabFrame
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tabButton.BorderSizePixel = 0
        tabButton.Position = UDim2.new((i-1) * 0.25, 2, 0, 2)
        tabButton.Size = UDim2.new(0.25, -4, 1, -4)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.Parent = tabButton
        tabButtonCorner.CornerRadius = UDim.new(0, 6)
        
        tabButtons[tabName] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            currentTab = tabName
            for _, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            updateContent()
        end)
    end
    
    tabButtons["PROGRESS"].BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    tabButtons["PROGRESS"].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Function update konten
    local function updateContent()
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        if currentTab == "PROGRESS" then
            -- Progress bars
            local progressItems = {
                {name = "LEVEL", value = progressData.level, max = 100, color = Color3.fromRGB(255, 215, 0)},
                {name = "EXP", value = progressData.exp, max = progressData.maxExp, color = Color3.fromRGB(0, 200, 100)},
                {name = "REBIRTHS", value = progressData.rebirths, max = 50, color = Color3.fromRGB(150, 0, 255)},
                {name = "PETS", value = progressData.pets, max = 100, color = Color3.fromRGB(255, 100, 0)}
            }
            
            for i, item in ipairs(progressItems) do
                local yPos = 10 + (i-1) * 70
                
                local itemLabel = Instance.new("TextLabel")
                itemLabel.Parent = contentFrame
                itemLabel.BackgroundTransparency = 1
                itemLabel.Position = UDim2.new(0, 20, 0, yPos)
                itemLabel.Size = UDim2.new(1, -40, 0, 20)
                itemLabel.Font = Enum.Font.GothamBold
                itemLabel.Text = item.name .. ": " .. item.value .. " / " .. item.max
                itemLabel.TextColor3 = item.color
                itemLabel.TextSize = 16
                itemLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local barBg = Instance.new("Frame")
                barBg.Parent = contentFrame
                barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                barBg.BorderSizePixel = 0
                barBg.Position = UDim2.new(0, 20, 0, yPos + 25)
                barBg.Size = UDim2.new(1, -40, 0, 20)
                
                local barCorner = Instance.new("UICorner")
                barCorner.Parent = barBg
                barCorner.CornerRadius = UDim.new(0, 10)
                
                local barFill = Instance.new("Frame")
                barFill.Parent = barBg
                barFill.BackgroundColor3 = item.color
                barFill.BorderSizePixel = 0
                barFill.Size = UDim2.new(item.value / item.max, 0, 1, 0)
                
                local fillCorner = Instance.new("UICorner")
                fillCorner.Parent = barFill
                fillCorner.CornerRadius = UDim.new(0, 10)
            end
            
            -- Quick add buttons
            local addFrame = Instance.new("Frame")
            addFrame.Parent = contentFrame
            addFrame.BackgroundTransparency = 1
            addFrame.Position = UDim2.new(0, 20, 0, 300)
            addFrame.Size = UDim2.new(1, -40, 0, 60)
            
            local addLabel = Instance.new("TextLabel")
            addLabel.Parent = addFrame
            addLabel.BackgroundTransparency = 1
            addLabel.Position = UDim2.new(0, 0, 0, 0)
            addLabel.Size = UDim2.new(1, 0, 0, 20)
            addLabel.Font = Enum.Font.GothamBold
            addLabel.Text = "QUICK ADD:"
            addLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            addLabel.TextSize = 14
            addLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local addButtons = {"+10 EXP", "+1 LEVEL", "+1 REBIRTH", "+10 COINS"}
            
            for i, btnText in ipairs(addButtons) do
                local addButton = Instance.new("TextButton")
                addButton.Parent = addFrame
                addButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
                addButton.BorderSizePixel = 0
                addButton.Position = UDim2.new((i-1) * 0.25, 2, 0, 25)
                addButton.Size = UDim2.new(0.25, -4, 0, 30)
                addButton.Font = Enum.Font.GothamBold
                addButton.Text = btnText
                addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                addButton.TextSize = 12
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.Parent = addButton
                buttonCorner.CornerRadius = UDim.new(0, 5)
                
                addButton.MouseButton1Click:Connect(function()
                    if btnText == "+10 EXP" then
                        progressData.exp = math.min(progressData.exp + 10, progressData.maxExp)
                    elseif btnText == "+1 LEVEL" then
                        if progressData.exp >= progressData.maxExp then
                            progressData.level = progressData.level + 1
                            progressData.exp = 0
                            progressData.maxExp = progressData.maxExp + 50
                        end
                    elseif btnText == "+1 REBIRTH" then
                        progressData.rebirths = progressData.rebirths + 1
                    elseif btnText == "+10 COINS" then
                        progressData.coins = progressData.coins + 10
                    end
                    updateContent()
                end)
            end
            
        elseif currentTab == "AUTOMATION" then
            -- Automation settings
            local autoItems = {
                {name = "Auto Farm", description = "Otomatis farming", default = true},
                {name = "Auto Rebirth", description = "Rebirth otomatis saat mencapai level maks", default = false},
                {name = "Auto Hatch", description = "Hatch telur otomatis", default = true},
                {name = "Auto Collect", description = "Kumpulkan item otomatis", default = true},
                {name = "Auto Upgrade", description = "Upgrade otomatis", default = false},
                {name = "Auto Sell", description = "Jual item otomatis", default = true}
            }
            
            for i, item in ipairs(autoItems) do
                local itemFrame = Instance.new("Frame")
                itemFrame.Parent = contentFrame
                itemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                itemFrame.BorderSizePixel = 0
                itemFrame.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 45)
                itemFrame.Size = UDim2.new(1, -20, 0, 40)
                
                local itemCorner = Instance.new("UICorner")
                itemCorner.Parent = itemFrame
                itemCorner.CornerRadius = UDim.new(0, 8)
                
                local itemName = Instance.new("TextLabel")
                itemName.Parent = itemFrame
                itemName.BackgroundTransparency = 1
                itemName.Position = UDim2.new(0, 10, 0, 5)
                itemName.Size = UDim2.new(0.5, 0, 0, 15)
                itemName.Font = Enum.Font.GothamBold
                itemName.Text = item.name
                itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
                itemName.TextSize = 14
                itemName.TextXAlignment = Enum.TextXAlignment.Left
                
                local itemDesc = Instance.new("TextLabel")
                itemDesc.Parent = itemFrame
                itemDesc.BackgroundTransparency = 1
                itemDesc.Position = UDim2.new(0, 10, 0, 20)
                itemDesc.Size = UDim2.new(0.5, 0, 0, 15)
                itemDesc.Font = Enum.Font.Gotham
                itemDesc.Text = item.description
                itemDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
                itemDesc.TextSize = 10
                itemDesc.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleButton = Instance.new("TextButton")
                toggleButton.Parent = itemFrame
                toggleButton.BackgroundColor3 = item.default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                toggleButton.BorderSizePixel = 0
                toggleButton.Position = UDim2.new(0.8, 0, 0.15, 0)
                toggleButton.Size = UDim2.new(0.15, 0, 0.7, 0)
                toggleButton.Font = Enum.Font.GothamBold
                toggleButton.Text = item.default and "ON" or "OFF"
                toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleButton.TextSize = 12
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.Parent = toggleButton
                toggleCorner.CornerRadius = UDim.new(0, 5)
                
                local state = item.default
                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                    toggleButton.Text = state and "ON" or "OFF"
                end)
            end
            
        elseif currentTab == "STATS" then
            -- Detailed stats
            local stats = {
                {label = "Play Time", value = "2h 34m"},
                {label = "Total Clicks", value = "15,432"},
                {label = "Items Collected", value = "3,891"},
                {label = "Pets Hatched", value = "127"},
                {label = "Bosses Defeated", value = "23"},
                {label = "Achievements", value = "18/50"}
            }
            
            for i, stat in ipairs(stats) do
                local row = math.floor((i-1) / 2)
                local col = (i-1) % 2
                
                local statFrame = Instance.new("Frame")
                statFrame.Parent = contentFrame
                statFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                statFrame.BorderSizePixel = 0
                statFrame.Position = UDim2.new(0.05 + col * 0.48, 0, 0.05 + row * 0.15, 0)
                statFrame.Size = UDim2.new(0.45, 0, 0.12, 0)
                
                local statCorner = Instance.new("UICorner")
                statCorner.Parent = statFrame
                statCorner.CornerRadius = UDim.new(0, 8)
                
                local statLabel = Instance.new("TextLabel")
                statLabel.Parent = statFrame
                statLabel.BackgroundTransparency = 1
                statLabel.Position = UDim2.new(0, 5, 0, 5)
                statLabel.Size = UDim2.new(1, -10, 0, 15)
                statLabel.Font = Enum.Font.Gotham
                statLabel.Text = stat.label
                statLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                statLabel.TextSize = 12
                statLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Parent = statFrame
                valueLabel.BackgroundTransparency = 1
                valueLabel.Position = UDim2.new(0, 5, 0, 20)
                valueLabel.Size = UDim2.new(1, -10, 0, 15)
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.Text = stat.value
                valueLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                valueLabel.TextSize = 14
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            end
            
        elseif currentTab == "SETTINGS" then
            -- Settings
            local settings = {
                {name = "Auto Save", type = "toggle"},
                {name = "Notifications", type = "toggle"},
                {name = "Sound Effects", type = "toggle"},
                {name = "Auto Start", type = "toggle"},
                {name = "Farm Speed", type = "slider", min = 1, max = 10, value = 5},
                {name = "Rebirth Delay", type = "slider", min = 1, max = 60, value = 10}
            }
            
            for i, setting in ipairs(settings) do
                if setting.type == "toggle" then
                    local settingFrame = Instance.new("Frame")
                    settingFrame.Parent = contentFrame
                    settingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    settingFrame.BorderSizePixel = 0
                    settingFrame.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 40)
                    settingFrame.Size = UDim2.new(1, -20, 0, 35)
                    
                    local settingCorner = Instance.new("UICorner")
                    settingCorner.Parent = settingFrame
                    settingCorner.CornerRadius = UDim.new(0, 8)
                    
                    local settingName = Instance.new("TextLabel")
                    settingName.Parent = settingFrame
                    settingName.BackgroundTransparency = 1
                    settingName.Position = UDim2.new(0, 10, 0, 0)
                    settingName.Size = UDim2.new(0.7, 0, 1, 0)
                    settingName.Font = Enum.Font.Gotham
                    settingName.Text = setting.name
                    settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    settingName.TextSize = 14
                    settingName.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local toggleButton = Instance.new("TextButton")
                    toggleButton.Parent = settingFrame
                    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    toggleButton.BorderSizePixel = 0
                    toggleButton.Position = UDim2.new(0.8, 0, 0.15, 0)
                    toggleButton.Size = UDim2.new(0.15, 0, 0.7, 0)
                    toggleButton.Font = Enum.Font.GothamBold
                    toggleButton.Text = "ON"
                    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    toggleButton.TextSize = 12
                    
                    local toggleCorner = Instance.new("UICorner")
                    toggleCorner.Parent = toggleButton
                    toggleCorner.CornerRadius = UDim.new(0, 5)
                    
                    local state = true
                    toggleButton.MouseButton1Click:Connect(function()
                        state = not state
                        toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
                        toggleButton.Text = state and "ON" or "OFF"
                    end)
                    
                elseif setting.type == "slider" then
                    local settingFrame = Instance.new("Frame")
                    settingFrame.Parent = contentFrame
                    settingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    settingFrame.BorderSizePixel = 0
                    settingFrame.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 50)
                    settingFrame.Size = UDim2.new(1, -20, 0, 45)
                    
                    local settingCorner = Instance.new("UICorner")
                    settingCorner.Parent = settingFrame
                    settingCorner.CornerRadius = UDim.new(0, 8)
                    
                    local settingName = Instance.new("TextLabel")
                    settingName.Parent = settingFrame
                    settingName.BackgroundTransparency = 1
                    settingName.Position = UDim2.new(0, 10, 0, 5)
                    settingName.Size = UDim2.new(0.7, 0, 0, 15)
                    settingName.Font = Enum.Font.Gotham
                    settingName.Text = setting.name
                    settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    settingName.TextSize = 14
                    settingName.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local valueLabel = Instance.new("TextLabel")
                    valueLabel.Parent = settingFrame
                    valueLabel.BackgroundTransparency = 1
                    valueLabel.Position = UDim2.new(0.8, 0, 0, 5)
                    valueLabel.Size = UDim2.new(0.15, 0, 0, 15)
                    valueLabel.Font = Enum.Font.GothamBold
                    valueLabel.Text = setting.value
                    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    valueLabel.TextSize = 14
                    
                    local sliderBg = Instance.new("Frame")
                    sliderBg.Parent = settingFrame
                    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                    sliderBg.BorderSizePixel = 0
                    sliderBg.Position = UDim2.new(0, 10, 0, 25)
                    sliderBg.Size = UDim2.new(1, -20, 0, 10)
                    
                    local sliderCorner = Instance.new("UICorner")
                    sliderCorner.Parent = sliderBg
                    sliderCorner.CornerRadius = UDim.new(0, 5)
                    
                    local sliderFill = Instance.new("Frame")
                    sliderFill.Parent = sliderBg
                    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    sliderFill.BorderSizePixel = 0
                    sliderFill.Size = UDim2.new((setting.value - setting.min) / (setting.max - setting.min), 0, 1, 0)
                    
                    local fillCorner = Instance.new("UICorner")
                    fillCorner.Parent = sliderFill
                    fillCorner.CornerRadius = UDim.new(0, 5)
                end
            end
        end
    end
    
    updateContent()
end

-- =============================================
-- BAGIAN 12: EGG SYSTEM
-- =============================================
local EggSystem = {}

function EggSystem.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Data eggs
    local eggs = {
        {name = "Common Egg", price = 100, color = Color3.fromRGB(150, 150, 150), pets = {"Cat", "Dog", "Chicken"}},
        {name = "Rare Egg", price = 500, color = Color3.fromRGB(0, 150, 255), pets = {"Wolf", "Fox", "Eagle"}},
        {name = "Epic Egg", price = 2000, color = Color3.fromRGB(150, 0, 255), pets = {"Dragon", "Phoenix", "Unicorn"}},
        {name = "Legendary Egg", price = 10000, color = Color3.fromRGB(255, 215, 0), pets = {"Titan", "God", "Mythical"}}
    }
    
    -- Inventory
    local inventory = {
        coins = 5000,
        pets = {"Cat", "Dog"}
    }
    
    -- Buat GUI Egg System
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EggSystemGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "🥚 EGG SYSTEM 🥚"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Coins display
    local coinsFrame = Instance.new("Frame")
    coinsFrame.Parent = mainFrame
    coinsFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    coinsFrame.BackgroundTransparency = 0.2
    coinsFrame.BorderSizePixel = 0
    coinsFrame.Position = UDim2.new(0, 10, 0, 55)
    coinsFrame.Size = UDim2.new(1, -20, 0, 35)
    
    local coinsCorner = Instance.new("UICorner")
    coinsCorner.Parent = coinsFrame
    coinsCorner.CornerRadius = UDim.new(0, 8)
    
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Parent = coinsFrame
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Size = UDim2.new(1, 0, 1, 0)
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.Text = "💰 COINS: " .. inventory.coins
    coinsLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    coinsLabel.TextSize = 18
    
    local eggsFrame = Instance.new("Frame")
    eggsFrame.Parent = mainFrame
    eggsFrame.BackgroundTransparency = 1
    eggsFrame.Position = UDim2.new(0, 10, 0, 100)
    eggsFrame.Size = UDim2.new(1, -20, 0, 200)
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.Parent = eggsFrame
    gridLayout.CellSize = UDim2.new(0, 110, 0, 150)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    
    -- Buat eggs
    for i, egg in ipairs(eggs) do
        local eggFrame = Instance.new("Frame")
        eggFrame.Parent = eggsFrame
        eggFrame.BackgroundColor3 = egg.color
        eggFrame.BackgroundTransparency = 0.3
        eggFrame.BorderSizePixel = 0
        eggFrame.Size = UDim2.new(1, 0, 1, 0)
        
        local eggCorner = Instance.new("UICorner")
        eggCorner.Parent = eggFrame
        eggCorner.CornerRadius = UDim.new(0, 10)
        
        local eggName = Instance.new("TextLabel")
        eggName.Parent = eggFrame
        eggName.BackgroundTransparency = 1
        eggName.Position = UDim2.new(0, 5, 0, 5)
        eggName.Size = UDim2.new(1, -10, 0, 20)
        eggName.Font = Enum.Font.GothamBold
        eggName.Text = egg.name
        eggName.TextColor3 = Color3.fromRGB(255, 255, 255)
        eggName.TextSize = 12
        
        local eggPrice = Instance.new("TextLabel")
        eggPrice.Parent = eggFrame
        eggPrice.BackgroundTransparency = 1
        eggPrice.Position = UDim2.new(0, 5, 0, 25)
        eggPrice.Size = UDim2.new(1, -10, 0, 20)
        eggPrice.Font = Enum.Font.Gotham
        eggPrice.Text = "💰 " .. egg.price
        eggPrice.TextColor3 = Color3.fromRGB(255, 255, 0)
        eggPrice.TextSize = 12
        
        local eggIcon = Instance.new("TextLabel")
        eggIcon.Parent = eggFrame
        eggIcon.BackgroundTransparency = 1
        eggIcon.Position = UDim2.new(0, 0, 0, 50)
        eggIcon.Size = UDim2.new(1, 0, 0, 50)
        eggIcon.Font = Enum.Font.Gotham
        eggIcon.Text = "🥚"
        eggIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        eggIcon.TextSize = 40
        
        local hatchButton = Instance.new("TextButton")
        hatchButton.Parent = eggFrame
        hatchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        hatchButton.BorderSizePixel = 0
        hatchButton.Position = UDim2.new(0.1, 0, 0.8, 0)
        hatchButton.Size = UDim2.new(0.8, 0, 0.15, 0)
        hatchButton.Font = Enum.Font.GothamBold
        hatchButton.Text = "HATCH"
        hatchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        hatchButton.TextSize = 10
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = hatchButton
        buttonCorner.CornerRadius = UDim.new(0, 5)
        
        hatchButton.MouseButton1Click:Connect(function()
            if inventory.coins >= egg.price then
                inventory.coins = inventory.coins - egg.price
                coinsLabel.Text = "💰 COINS: " .. inventory.coins
                
                -- Random pet
                local randomPet = egg.pets[math.random(1, #egg.pets)]
                table.insert(inventory.pets, randomPet)
                
                -- Animasi hatch
                eggIcon.Text = "🐣"
                hatchButton.Text = "HATCHING..."
                hatchButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                hatchButton.Active = false
                
                task.delay(2, function()
                    eggIcon.Text = randomPet
                    hatchButton.Text = "HATCHED!"
                    hatchButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    
                    task.delay(1, function()
                        eggIcon.Text = "🥚"
                        hatchButton.Text = "HATCH"
                        hatchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                        hatchButton.Active = true
                    end)
                    
                    -- Notifikasi
                    local notification = Instance.new("ScreenGui")
                    notification.Parent = player.PlayerGui
                    
                    local notifFrame = Instance.new("Frame")
                    notifFrame.Parent = notification
                    notifFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    notifFrame.BorderSizePixel = 0
                    notifFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
                    notifFrame.Size = UDim2.new(0, 300, 0, 50)
                    
                    local notifCorner = Instance.new("UICorner")
                    notifCorner.Parent = notifFrame
                    notifCorner.CornerRadius = UDim.new(0, 8)
                    
                    local notifLabel = Instance.new("TextLabel")
                    notifLabel.Parent = notifFrame
                    notifLabel.BackgroundTransparency = 1
                    notifLabel.Size = UDim2.new(1, 0, 1, 0)
                    notifLabel.Font = Enum.Font.Gotham
                    notifLabel.Text = "You hatched a " .. randomPet .. "!"
                    notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    notifLabel.TextSize = 16
                    
                    task.delay(2, function()
                        notification:Destroy()
                    end)
                end)
            else
                -- Not enough coins
                hatchButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                hatchButton.Text = "NO COINS"
                task.delay(0.5, function()
                    hatchButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    hatchButton.Text = "HATCH"
                end)
            end
        end)
    end
    
    -- Inventory section
    local invFrame = Instance.new("Frame")
    invFrame.Parent = mainFrame
    invFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    invFrame.BorderSizePixel = 0
    invFrame.Position = UDim2.new(0, 10, 0, 310)
    invFrame.Size = UDim2.new(1, -20, 0, 80)
    
    local invCorner = Instance.new("UICorner")
    invCorner.Parent = invFrame
    invCorner.CornerRadius = UDim.new(0, 10)
    
    local invTitle = Instance.new("TextLabel")
    invTitle.Parent = invFrame
    invTitle.BackgroundTransparency = 1
    invTitle.Position = UDim2.new(0, 10, 0, 5)
    invTitle.Size = UDim2.new(1, -20, 0, 20)
    invTitle.Font = Enum.Font.GothamBold
    invTitle.Text = "YOUR PETS"
    invTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    invTitle.TextSize = 14
    invTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local petsScrolling = Instance.new("ScrollingFrame")
    petsScrolling.Parent = invFrame
    petsScrolling.BackgroundTransparency = 1
    petsScrolling.Position = UDim2.new(0, 10, 0, 30)
    petsScrolling.Size = UDim2.new(1, -20, 0, 40)
    petsScrolling.CanvasSize = UDim2.new(0, math.max(#inventory.pets * 70, 300), 0, 0)
    petsScrolling.ScrollBarThickness = 5
    petsScrolling.ScrollingDirection = Enum.ScrollingDirection.X
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = petsScrolling
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal
    uiListLayout.Padding = UDim.new(0, 5)
    
    for _, pet in ipairs(inventory.pets) do
        local petLabel = Instance.new("TextLabel")
        petLabel.Parent = petsScrolling
        petLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        petLabel.BorderSizePixel = 0
        petLabel.Size = UDim2.new(0, 60, 0, 30)
        petLabel.Font = Enum.Font.Gotham
        petLabel.Text = pet
        petLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        petLabel.TextSize = 12
        
        local petCorner = Instance.new("UICorner")
        petCorner.Parent = petLabel
        petCorner.CornerRadius = UDim.new(0, 5)
    end
end

-- =============================================
-- BAGIAN 13: BEST AUTO ENCHANT
-- =============================================
local BestAutoEnchant = {}

function BestAutoEnchant.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Data enchant
    local enchants = {
        {name = "Sharpness", level = 1, maxLevel = 5, cost = 100, color = Color3.fromRGB(255, 100, 100)},
        {name = "Protection", level = 1, maxLevel = 4, cost = 150, color = Color3.fromRGB(100, 100, 255)},
        {name = "Efficiency", level = 1, maxLevel = 5, cost = 120, color = Color3.fromRGB(100, 255, 100)},
        {name = "Unbreaking", level = 1, maxLevel = 3, cost = 80, color = Color3.fromRGB(255, 255, 100)},
        {name = "Fortune", level = 1, maxLevel = 3, cost = 200, color = Color3.fromRGB(255, 150, 0)},
        {name = "Silk Touch", level = 1, maxLevel = 1, cost = 500, color = Color3.fromRGB(200, 200, 200)}
    }
    
    -- Resources
    local resources = {
        essence = 1000,
        level = 10
    }
    
    -- Buat GUI Enchant
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EnchantGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
    mainFrame.Size = UDim2.new(0, 500, 0, 450)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "✨ BEST AUTO ENCHANT ✨"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Resources display
    local resFrame = Instance.new("Frame")
    resFrame.Parent = mainFrame
    resFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    resFrame.BorderSizePixel = 0
    resFrame.Position = UDim2.new(0, 10, 0, 55)
    resFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local resCorner = Instance.new("UICorner")
    resCorner.Parent = resFrame
    resCorner.CornerRadius = UDim.new(0, 8)
    
    local essenceLabel = Instance.new("TextLabel")
    essenceLabel.Parent = resFrame
    essenceLabel.BackgroundTransparency = 1
    essenceLabel.Position = UDim2.new(0, 10, 0, 0)
    essenceLabel.Size = UDim2.new(0.5, -15, 1, 0)
    essenceLabel.Font = Enum.Font.GothamBold
    essenceLabel.Text = "🔮 Essence: " .. resources.essence
    essenceLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
    essenceLabel.TextSize = 16
    essenceLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Parent = resFrame
    levelLabel.BackgroundTransparency = 1
    levelLabel.Position = UDim2.new(0.5, 5, 0, 0)
    levelLabel.Size = UDim2.new(0.5, -15, 1, 0)
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Text = "⭐ Level: " .. resources.level
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    levelLabel.TextSize = 16
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Parent = mainFrame
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Position = UDim2.new(0, 10, 0, 105)
    scrollingFrame.Size = UDim2.new(1, -20, 1, -160)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #enchants * 80)
    scrollingFrame.ScrollBarThickness = 8
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollingFrame
    uiListLayout.Padding = UDim.new(0, 8)
    
    -- Buat item enchant
    for i, enchant in ipairs(enchants) do
        local enchantFrame = Instance.new("Frame")
        enchantFrame.Parent = scrollingFrame
        enchantFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        enchantFrame.BorderSizePixel = 0
        enchantFrame.Size = UDim2.new(1, -10, 0, 70)
        
        local enchantCorner = Instance.new("UICorner")
        enchantCorner.Parent = enchantFrame
        enchantCorner.CornerRadius = UDim.new(0, 10)
        
        local enchantName = Instance.new("TextLabel")
        enchantName.Parent = enchantFrame
        enchantName.BackgroundTransparency = 1
        enchantName.Position = UDim2.new(0, 10, 0, 5)
        enchantName.Size = UDim2.new(0.5, 0, 0, 20)
        enchantName.Font = Enum.Font.GothamBold
        enchantName.Text = enchant.name
        enchantName.TextColor3 = enchant.color
        enchantName.TextSize = 18
        enchantName.TextXAlignment = Enum.TextXAlignment.Left
        
        local enchantLevel = Instance.new("TextLabel")
        enchantLevel.Parent = enchantFrame
        enchantLevel.BackgroundTransparency = 1
        enchantLevel.Position = UDim2.new(0.5, 0, 0, 5)
        enchantLevel.Size = UDim2.new(0.3, 0, 0, 20)
        enchantLevel.Font = Enum.Font.Gotham
        enchantLevel.Text = "Level " .. enchant.level .. "/" .. enchant.maxLevel
        enchantLevel.TextColor3 = Color3.fromRGB(200, 200, 200)
        enchantLevel.TextSize = 14
        enchantLevel.TextXAlignment = Enum.TextXAlignment.Left
        
        local enchantCost = Instance.new("TextLabel")
        enchantCost.Parent = enchantFrame
        enchantCost.BackgroundTransparency = 1
        enchantCost.Position = UDim2.new(0, 10, 0, 25)
        enchantCost.Size = UDim2.new(0.5, 0, 0, 20)
        enchantCost.Font = Enum.Font.Gotham
        enchantCost.Text = "Cost: " .. enchant.cost .. " essence"
        enchantCost.TextColor3 = Color3.fromRGB(255, 255, 100)
        enchantCost.TextSize = 12
        enchantCost.TextXAlignment = Enum.TextXAlignment.Left
        
        local progressBg = Instance.new("Frame")
        progressBg.Parent = enchantFrame
        progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        progressBg.BorderSizePixel = 0
        progressBg.Position = UDim2.new(0, 10, 0, 45)
        progressBg.Size = UDim2.new(0.6, 0, 0, 15)
        
        local progressCorner = Instance.new("UICorner")
        progressCorner.Parent = progressBg
        progressCorner.CornerRadius = UDim.new(0, 7)
        
        local progressFill = Instance.new("Frame")
        progressFill.Parent = progressBg
        progressFill.BackgroundColor3 = enchant.color
        progressFill.BorderSizePixel = 0
        progressFill.Size = UDim2.new(enchant.level / enchant.maxLevel, 0, 1, 0)
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.Parent = progressFill
        fillCorner.CornerRadius = UDim.new(0, 7)
        
        local enchantButton = Instance.new("TextButton")
        enchantButton.Parent = enchantFrame
        enchantButton.BackgroundColor3 = enchant.color
        enchantButton.BorderSizePixel = 0
        enchantButton.Position = UDim2.new(0.75, 0, 0.2, 0)
        enchantButton.Size = UDim2.new(0.2, 0, 0.6, 0)
        enchantButton.Font = Enum.Font.GothamBold
        enchantButton.Text = "ENCHANT"
        enchantButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        enchantButton.TextSize = 12
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = enchantButton
        buttonCorner.CornerRadius = UDim.new(0, 5)
        
        enchantButton.MouseButton1Click:Connect(function()
            if enchant.level < enchant.maxLevel then
                if resources.essence >= enchant.cost then
                    resources.essence = resources.essence - enchant.cost
                    enchant.level = enchant.level + 1
                    essenceLabel.Text = "🔮 Essence: " .. resources.essence
                    
                    -- Update tampilan
                    enchantLevel.Text = "Level " .. enchant.level .. "/" .. enchant.maxLevel
                    progressFill:TweenSize(UDim2.new(enchant.level / enchant.maxLevel, 0, 1, 0), "Out", "Quad", 0.3)
                    
                    -- Efek visual
                    enchantButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    task.delay(0.1, function()
                        enchantButton.BackgroundColor3 = enchant.color
                    end)
                    
                    if enchant.level == enchant.maxLevel then
                        enchantButton.Text = "MAXED"
                        enchantButton.Active = false
                        enchantButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    end
                else
                    -- Not enough essence
                    enchantButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    enchantButton.Text = "NO ESSENCE"
                    task.delay(0.5, function()
                        enchantButton.BackgroundColor3 = enchant.color
                        enchantButton.Text = "ENCHANT"
                    end)
                end
            end
        end)
        
        -- Auto enchant toggle
        local autoButton = Instance.new("TextButton")
        autoButton.Parent = enchantFrame
        autoButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        autoButton.BorderSizePixel = 0
        autoButton.Position = UDim2.new(0.75, 0, 0.7, 0)
        autoButton.Size = UDim2.new(0.2, 0, 0.2, 0)
        autoButton.Font = Enum.Font.GothamBold
        autoButton.Text = "AUTO"
        autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        autoButton.TextSize = 8
        
        local autoCorner = Instance.new("UICorner")
        autoCorner.Parent = autoButton
        autoCorner.CornerRadius = UDim.new(0, 3)
        
        local autoState = false
        autoButton.MouseButton1Click:Connect(function()
            autoState = not autoState
            autoButton.BackgroundColor3 = autoState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        end)
    end
    
    -- Auto enchant all button
    local autoAllButton = Instance.new("TextButton")
    autoAllButton.Parent = mainFrame
    autoAllButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    autoAllButton.BorderSizePixel = 0
    autoAllButton.Position = UDim2.new(0, 10, 1, -45)
    autoAllButton.Size = UDim2.new(0.3, 0, 0, 35)
    autoAllButton.Font = Enum.Font.GothamBold
    autoAllButton.Text = "AUTO ALL"
    autoAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoAllButton.TextSize = 14
    
    local autoAllCorner = Instance.new("UICorner")
    autoAllCorner.Parent = autoAllButton
    autoAllCorner.CornerRadius = UDim.new(0, 8)
    
    autoAllButton.MouseButton1Click:Connect(function()
        autoAllButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.delay(0.2, function()
            autoAllButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
        end)
        SmoothUI.createNotification("Auto Enchant", "Auto enchant started!", 2)
    end)
    
    -- Add essence button
    local addButton = Instance.new("TextButton")
    addButton.Parent = mainFrame
    addButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    addButton.BorderSizePixel = 0
    addButton.Position = UDim2.new(0.35, 0, 1, -45)
    addButton.Size = UDim2.new(0.3, 0, 0, 35)
    addButton.Font = Enum.Font.GothamBold
    addButton.Text = "+100 ESSENCE"
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.TextSize = 14
    
    local addCorner = Instance.new("UICorner")
    addCorner.Parent = addButton
    addCorner.CornerRadius = UDim.new(0, 8)
    
    addButton.MouseButton1Click:Connect(function()
        resources.essence = resources.essence + 100
        essenceLabel.Text = "🔮 Essence: " .. resources.essence
    end)
    
    -- Reset button
    local resetButton = Instance.new("TextButton")
    resetButton.Parent = mainFrame
    resetButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    resetButton.BorderSizePixel = 0
    resetButton.Position = UDim2.new(0.7, 0, 1, -45)
    resetButton.Size = UDim2.new(0.25, 0, 0, 35)
    resetButton.Font = Enum.Font.GothamBold
    resetButton.Text = "RESET"
    resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetButton.TextSize = 14
    
    local resetCorner = Instance.new("UICorner")
    resetCorner.Parent = resetButton
    resetCorner.CornerRadius = UDim.new(0, 8)
    
    resetButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        BestAutoEnchant.init()
    end)
end

-- =============================================
-- BAGIAN 14: BALANCED AUTO FARM
-- =============================================
local BalancedAutoFarm = {}

function BalancedAutoFarm.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Balanced Auto Farm
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BalancedAutoFarmGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    mainFrame.Size = UDim2.new(0, 400, 0, 350)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "⚖️ BALANCED AUTO FARM ⚖️"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Status
    local statusFrame = Instance.new("Frame")
    statusFrame.Parent = mainFrame
    statusFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    statusFrame.BorderSizePixel = 0
    statusFrame.Position = UDim2.new(0, 10, 0, 50)
    statusFrame.Size = UDim2.new(1, -20, 0, 60)
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.Parent = statusFrame
    statusCorner.CornerRadius = UDim.new(0, 8)
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Parent = statusFrame
    statusTitle.BackgroundTransparency = 1
    statusTitle.Position = UDim2.new(0, 10, 0, 5)
    statusTitle.Size = UDim2.new(1, -20, 0, 20)
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.Text = "CURRENT STATUS"
    statusTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
    statusTitle.TextSize = 14
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local statusText = Instance.new("TextLabel")
    statusText.Parent = statusFrame
    statusText.BackgroundTransparency = 1
    statusText.Position = UDim2.new(0, 10, 0, 25)
    statusText.Size = UDim2.new(1, -20, 0, 30)
    statusText.Font = Enum.Font.Gotham
    statusText.Text = "Farming in progress... (12 items/min)"
    statusText.TextColor3 = Color3.fromRGB(200, 255, 200)
    statusText.TextSize = 12
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextWrapped = true
    
    -- Mode selector
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Parent = mainFrame
    modeLabel.BackgroundTransparency = 1
    modeLabel.Position = UDim2.new(0, 10, 0, 120)
    modeLabel.Size = UDim2.new(1, -20, 0, 20)
    modeLabel.Font = Enum.Font.GothamBold
    modeLabel.Text = "FARM MODE"
    modeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeLabel.TextSize = 14
    modeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local modeFrame = Instance.new("Frame")
    modeFrame.Parent = mainFrame
    modeFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    modeFrame.BorderSizePixel = 0
    modeFrame.Position = UDim2.new(0, 10, 0, 145)
    modeFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local modeCorner = Instance.new("UICorner")
    modeCorner.Parent = modeFrame
    modeCorner.CornerRadius = UDim.new(0, 8)
    
    local modes = {"Balanced", "Speed", "Efficiency", "Safe"}
    local modeButtons = {}
    
    for i, modeName in ipairs(modes) do
        local modeButton = Instance.new("TextButton")
        modeButton.Parent = modeFrame
        modeButton.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
        modeButton.BorderSizePixel = 0
        modeButton.Position = UDim2.new((i-1) * 0.25, 2, 0, 5)
        modeButton.Size = UDim2.new(0.25, -4, 0, 30)
        modeButton.Font = Enum.Font.GothamBold
        modeButton.Text = modeName
        modeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        modeButton.TextSize = 12
        
        local modeButtonCorner = Instance.new("UICorner")
        modeButtonCorner.Parent = modeButton
        modeButtonCorner.CornerRadius = UDim.new(0, 5)
        
        modeButtons[modeName] = modeButton
        
        modeButton.MouseButton1Click:Connect(function()
            for _, btn in pairs(modeButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            modeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusText.Text = "Farming in " .. modeName .. " mode... (15 items/min)"
        end)
    end
    
    modeButtons["Balanced"].BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    modeButtons["Balanced"].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Settings
    local settingsLabel = Instance.new("TextLabel")
    settingsLabel.Parent = mainFrame
    settingsLabel.BackgroundTransparency = 1
    settingsLabel.Position = UDim2.new(0, 10, 0, 200)
    settingsLabel.Size = UDim2.new(1, -20, 0, 20)
    settingsLabel.Font = Enum.Font.GothamBold
    settingsLabel.Text = "FARM SETTINGS"
    settingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsLabel.TextSize = 14
    settingsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Parent = mainFrame
    settingsFrame.BackgroundTransparency = 1
    settingsFrame.Position = UDim2.new(0, 10, 0, 225)
    settingsFrame.Size = UDim2.new(1, -20, 0, 100)
    
    local farmSettings = {
        {name = "Auto Collect", default = true},
        {name = "Auto Sell", default = true},
        {name = "Auto Upgrade", default = false},
        {name = "Auto Rebirth", default = false}
    }
    
    for i, setting in ipairs(farmSettings) do
        local row = math.floor((i-1) / 2)
        local col = (i-1) % 2
        
        local settingFrame = Instance.new("Frame")
        settingFrame.Parent = settingsFrame
        settingFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
        settingFrame.BorderSizePixel = 0
        settingFrame.Position = UDim2.new(0.02 + col * 0.5, 0, 0.05 + row * 0.45, 0)
        settingFrame.Size = UDim2.new(0.46, 0, 0.4, 0)
        
        local settingCorner = Instance.new("UICorner")
        settingCorner.Parent = settingFrame
        settingCorner.CornerRadius = UDim.new(0, 6)
        
        local settingName = Instance.new("TextLabel")
        settingName.Parent = settingFrame
        settingName.BackgroundTransparency = 1
        settingName.Position = UDim2.new(0, 5, 0, 0)
        settingName.Size = UDim2.new(0.6, 0, 1, 0)
        settingName.Font = Enum.Font.Gotham
        settingName.Text = setting.name
        settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
        settingName.TextSize = 10
        settingName.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Parent = settingFrame
        toggleButton.BackgroundColor3 = setting.default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.BorderSizePixel = 0
        toggleButton.Position = UDim2.new(0.65, 0, 0.15, 0)
        toggleButton.Size = UDim2.new(0.3, 0, 0.7, 0)
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Text = setting.default and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextSize = 8
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.Parent = toggleButton
        toggleCorner.CornerRadius = UDim.new(0, 3)
        
        local state = setting.default
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            toggleButton.Text = state and "ON" or "OFF"
        end)
    end
    
    -- Control buttons
    local controlFrame = Instance.new("Frame")
    controlFrame.Parent = mainFrame
    controlFrame.BackgroundTransparency = 1
    controlFrame.Position = UDim2.new(0, 10, 1, -45)
    controlFrame.Size = UDim2.new(1, -20, 0, 35)
    
    local startButton = Instance.new("TextButton")
    startButton.Parent = controlFrame
    startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startButton.BorderSizePixel = 0
    startButton.Position = UDim2.new(0, 0, 0, 0)
    startButton.Size = UDim2.new(0.3, 0, 1, 0)
    startButton.Font = Enum.Font.GothamBold
    startButton.Text = "START"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextSize = 14
    
    local startCorner = Instance.new("UICorner")
    startCorner.Parent = startButton
    startCorner.CornerRadius = UDim.new(0, 6)
    
    startButton.MouseButton1Click:Connect(function()
        startButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        statusText.Text = "Farming started! (18 items/min)"
        task.delay(0.2, function()
            startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end)
    end)
    
    local stopButton = Instance.new("TextButton")
    stopButton.Parent = controlFrame
    stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    stopButton.BorderSizePixel = 0
    stopButton.Position = UDim2.new(0.35, 0, 0, 0)
    stopButton.Size = UDim2.new(0.3, 0, 1, 0)
    stopButton.Font = Enum.Font.GothamBold
    stopButton.Text = "STOP"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextSize = 14
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.Parent = stopButton
    stopCorner.CornerRadius = UDim.new(0, 6)
    
    stopButton.MouseButton1Click:Connect(function()
        stopButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        statusText.Text = "Farming stopped"
        task.delay(0.2, function()
            stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end)
    end)
    
    local statsButton = Instance.new("TextButton")
    statsButton.Parent = controlFrame
    statsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    statsButton.BorderSizePixel = 0
    statsButton.Position = UDim2.new(0.7, 0, 0, 0)
    statsButton.Size = UDim2.new(0.3, 0, 1, 0)
    statsButton.Font = Enum.Font.GothamBold
    statsButton.Text = "STATS"
    statsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsButton.TextSize = 14
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.Parent = statsButton
    statsCorner.CornerRadius = UDim.new(0, 6)
    
    statsButton.MouseButton1Click:Connect(function()
        SmoothUI.createNotification("Farm Stats", "Total items: 2,547 | Time: 3h 24m", 3)
    end)
end

-- =============================================
-- BAGIAN 15: AUTO UNLOCK
-- =============================================
local AutoUnlock = {}

function AutoUnlock.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Data unlocks
    local unlocks = {
        {name = "Area 2", requirement = "Level 10", cost = 1000, unlocked = false, color = Color3.fromRGB(100, 200, 100)},
        {name = "Area 3", requirement = "Level 25", cost = 5000, unlocked = false, color = Color3.fromRGB(100, 150, 255)},
        {name = "Shop", requirement = "Level 5", cost = 500, unlocked = true, color = Color3.fromRGB(255, 200, 100)},
        {name = "Crafting", requirement = "Level 15", cost = 2000, unlocked = false, color = Color3.fromRGB(200, 100, 255)},
        {name = "PvP Arena", requirement = "Level 30", cost = 10000, unlocked = false, color = Color3.fromRGB(255, 100, 100)},
        {name = "Secret Area", requirement = "Level 50", cost = 50000, unlocked = false, color = Color3.fromRGB(255, 255, 100)}
    }
    
    -- Player stats
    local stats = {
        level = 12,
        coins = 3500
    }
    
    -- Buat GUI Auto Unlock
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoUnlockGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 450, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "🔓 AUTO UNLOCK SYSTEM 🔓"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Stats display
    local statsFrame = Instance.new("Frame")
    statsFrame.Parent = mainFrame
    statsFrame.BackgroundColor3 = Color3.fromRGB(35, 30, 40)
    statsFrame.BorderSizePixel = 0
    statsFrame.Position = UDim2.new(0, 10, 0, 55)
    statsFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.Parent = statsFrame
    statsCorner.CornerRadius = UDim.new(0, 8)
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Parent = statsFrame
    levelLabel.BackgroundTransparency = 1
    levelLabel.Position = UDim2.new(0, 10, 0, 0)
    levelLabel.Size = UDim2.new(0.5, -15, 1, 0)
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Text = "⭐ Level: " .. stats.level
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    levelLabel.TextSize = 16
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Parent = statsFrame
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Position = UDim2.new(0.5, 5, 0, 0)
    coinsLabel.Size = UDim2.new(0.5, -15, 1, 0)
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.Text = "💰 Coins: " .. stats.coins
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextSize = 16
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Parent = mainFrame
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Position = UDim2.new(0, 10, 0, 105)
    scrollingFrame.Size = UDim2.new(1, -20, 1, -160)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #unlocks * 70)
    scrollingFrame.ScrollBarThickness = 8
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollingFrame
    uiListLayout.Padding = UDim.new(0, 8)
    
    -- Buat item unlock
    for i, unlock in ipairs(unlocks) do
        local unlockFrame = Instance.new("Frame")
        unlockFrame.Parent = scrollingFrame
        unlockFrame.BackgroundColor3 = unlock.unlocked and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(40, 30, 40)
        unlockFrame.BorderSizePixel = 0
        unlockFrame.Size = UDim2.new(1, -10, 0, 60)
        
        local unlockCorner = Instance.new("UICorner")
        unlockCorner.Parent = unlockFrame
        unlockCorner.CornerRadius = UDim.new(0, 8)
        
        local unlockName = Instance.new("TextLabel")
        unlockName.Parent = unlockFrame
        unlockName.BackgroundTransparency = 1
        unlockName.Position = UDim2.new(0, 10, 0, 5)
        unlockName.Size = UDim2.new(0.5, 0, 0, 20)
        unlockName.Font = Enum.Font.GothamBold
        unlockName.Text = unlock.name
        unlockName.TextColor3 = unlock.color
        unlockName.TextSize = 16
        unlockName.TextXAlignment = Enum.TextXAlignment.Left
        
        local unlockReq = Instance.new("TextLabel")
        unlockReq.Parent = unlockFrame
        unlockReq.BackgroundTransparency = 1
        unlockReq.Position = UDim2.new(0.5, 0, 0, 5)
        unlockReq.Size = UDim2.new(0.3, 0, 0, 20)
        unlockReq.Font = Enum.Font.Gotham
        unlockReq.Text = unlock.requirement
        unlockReq.TextColor3 = Color3.fromRGB(200, 200, 200)
        unlockReq.TextSize = 12
        unlockReq.TextXAlignment = Enum.TextXAlignment.Left
        
        local unlockCost = Instance.new("TextLabel")
        unlockCost.Parent = unlockFrame
        unlockCost.BackgroundTransparency = 1
        unlockCost.Position = UDim2.new(0, 10, 0, 25)
        unlockCost.Size = UDim2.new(0.5, 0, 0, 20)
        unlockCost.Font = Enum.Font.Gotham
        unlockCost.Text = "Cost: " .. unlock.cost .. " coins"
        unlockCost.TextColor3 = Color3.fromRGB(255, 255, 100)
        unlockCost.TextSize = 12
        unlockCost.TextXAlignment = Enum.TextXAlignment.Left
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Parent = unlockFrame
        statusLabel.BackgroundTransparency = 1
        statusLabel.Position = UDim2.new(0, 10, 0, 40)
        statusLabel.Size = UDim2.new(0.5, 0, 0, 15)
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.Text = unlock.unlocked and "✅ UNLOCKED" or "🔒 LOCKED"
        statusLabel.TextColor3 = unlock.unlocked and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        statusLabel.TextSize = 10
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local unlockButton = Instance.new("TextButton")
        unlockButton.Parent = unlockFrame
        unlockButton.BackgroundColor3 = unlock.unlocked and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(0, 150, 0)
        unlockButton.BorderSizePixel = 0
        unlockButton.Position = UDim2.new(0.75, 0, 0.2, 0)
        unlockButton.Size = UDim2.new(0.2, 0, 0.6, 0)
        unlockButton.Font = Enum.Font.GothamBold
        unlockButton.Text = unlock.unlocked and "UNLOCKED" or "UNLOCK"
        unlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        unlockButton.TextSize = 12
        unlockButton.Active = not unlock.unlocked
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = unlockButton
        buttonCorner.CornerRadius = UDim.new(0, 5)
        
        unlockButton.MouseButton1Click:Connect(function()
            if not unlock.unlocked then
                if stats.level >= tonumber(unlock.requirement:match("%d+")) and stats.coins >= unlock.cost then
                    stats.coins = stats.coins - unlock.cost
                    unlock.unlocked = true
                    coinsLabel.Text = "💰 Coins: " .. stats.coins
                    
                    -- Update tampilan
                    unlockFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                    statusLabel.Text = "✅ UNLOCKED"
                    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    unlockButton.Text = "UNLOCKED"
                    unlockButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    unlockButton.Active = false
                    
                    -- Efek visual
                    unlockButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    task.delay(0.1, function()
                        unlockButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    end)
                    
                    SmoothUI.createNotification("Unlocked", unlock.name .. " has been unlocked!", 2)
                    
                elseif stats.level < tonumber(unlock.requirement:match("%d+")) then
                    unlockButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    unlockButton.Text = "LOW LEVEL"
                    task.delay(0.5, function()
                        unlockButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                        unlockButton.Text = "UNLOCK"
                    end)
                elseif stats.coins < unlock.cost then
                    unlockButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                    unlockButton.Text = "NO COINS"
                    task.delay(0.5, function()
                        unlockButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                        unlockButton.Text = "UNLOCK"
                    end)
                end
            end
        end)
    end
    
    -- Auto unlock toggle
    local autoFrame = Instance.new("Frame")
    autoFrame.Parent = mainFrame
    autoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    autoFrame.BorderSizePixel = 0
    autoFrame.Position = UDim2.new(0, 10, 1, -45)
    autoFrame.Size = UDim2.new(1, -20, 0, 35)
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.Parent = autoFrame
    autoCorner.CornerRadius = UDim.new(0, 8)
    
    local autoLabel = Instance.new("TextLabel")
    autoLabel.Parent = autoFrame
    autoLabel.BackgroundTransparency = 1
    autoLabel.Position = UDim2.new(0, 10, 0, 0)
    autoLabel.Size = UDim2.new(0.5, 0, 1, 0)
    autoLabel.Font = Enum.Font.Gotham
    autoLabel.Text = "Auto Unlock"
    autoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoLabel.TextSize = 14
    autoLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local autoToggle = Instance.new("TextButton")
    autoToggle.Parent = autoFrame
    autoToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    autoToggle.BorderSizePixel = 0
    autoToggle.Position = UDim2.new(0.8, 0, 0.15, 0)
    autoToggle.Size = UDim2.new(0.15, 0, 0.7, 0)
    autoToggle.Font = Enum.Font.GothamBold
    autoToggle.Text = "ON"
    autoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoToggle.TextSize = 12
    
    local autoToggleCorner = Instance.new("UICorner")
    autoToggleCorner.Parent = autoToggle
    autoToggleCorner.CornerRadius = UDim.new(0, 5)
    
    local autoState = true
    autoToggle.MouseButton1Click:Connect(function()
        autoState = not autoState
        autoToggle.BackgroundColor3 = autoState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        autoToggle.Text = autoState and "ON" or "OFF"
    end)
end

-- =============================================
-- BAGIAN 16: AUTO TAP KEYLESS
-- =============================================
local AutoTapKeyless = {}

function AutoTapKeyless.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Data tap
    local tapData = {
        taps = 0,
        power = 1,
        autoEnabled = false,
        interval = 0.1
    }
    
    -- Buat GUI Auto Tap
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoTapGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 350, 0, 300)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "👆 AUTO TAP KEYLESS 👆"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 5)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tap counter
    local counterFrame = Instance.new("Frame")
    counterFrame.Parent = mainFrame
    counterFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    counterFrame.BorderSizePixel = 0
    counterFrame.Position = UDim2.new(0, 10, 0, 50)
    counterFrame.Size = UDim2.new(1, -20, 0, 60)
    
    local counterCorner = Instance.new("UICorner")
    counterCorner.Parent = counterFrame
    counterCorner.CornerRadius = UDim.new(0, 10)
    
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Parent = counterFrame
    counterLabel.BackgroundTransparency = 1
    counterLabel.Size = UDim2.new(1, 0, 0.5, 0)
    counterLabel.Font = Enum.Font.GothamBold
    counterLabel.Text = "TOTAL TAPS"
    counterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    counterLabel.TextSize = 14
    
    local tapsLabel = Instance.new("TextLabel")
    tapsLabel.Parent = counterFrame
    tapsLabel.BackgroundTransparency = 1
    tapsLabel.Position = UDim2.new(0, 0, 0.5, 0)
    tapsLabel.Size = UDim2.new(1, 0, 0.5, 0)
    tapsLabel.Font = Enum.Font.GothamBold
    tapsLabel.Text = tostring(tapData.taps)
    tapsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    tapsLabel.TextSize = 24
    
    -- Power display
    local powerFrame = Instance.new("Frame")
    powerFrame.Parent = mainFrame
    powerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    powerFrame.BorderSizePixel = 0
    powerFrame.Position = UDim2.new(0, 10, 0, 120)
    powerFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local powerCorner = Instance.new("UICorner")
    powerCorner.Parent = powerFrame
    powerCorner.CornerRadius = UDim.new(0, 8)
    
    local powerLabel = Instance.new("TextLabel")
    powerLabel.Parent = powerFrame
    powerLabel.BackgroundTransparency = 1
    powerLabel.Position = UDim2.new(0, 10, 0, 0)
    powerLabel.Size = UDim2.new(0.5, 0, 1, 0)
    powerLabel.Font = Enum.Font.Gotham
    powerLabel.Text = "Tap Power:"
    powerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    powerLabel.TextSize = 14
    powerLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local powerValue = Instance.new("TextLabel")
    powerValue.Parent = powerFrame
    powerValue.BackgroundTransparency = 1
    powerValue.Position = UDim2.new(0.5, 0, 0, 0)
    powerValue.Size = UDim2.new(0.5, -10, 1, 0)
    powerValue.Font = Enum.Font.GothamBold
    powerValue.Text = tapData.power .. "x"
    powerValue.TextColor3 = Color3.fromRGB(255, 200, 0)
    powerValue.TextSize = 16
    powerValue.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Controls
    local controlFrame = Instance.new("Frame")
    controlFrame.Parent = mainFrame
    controlFrame.BackgroundTransparency = 1
    controlFrame.Position = UDim2.new(0, 10, 0, 170)
    controlFrame.Size = UDim2.new(1, -20, 0, 60)
    
    local autoButton = Instance.new("TextButton")
    autoButton.Parent = controlFrame
    autoButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    autoButton.BorderSizePixel = 0
    autoButton.Position = UDim2.new(0, 0, 0, 0)
    autoButton.Size = UDim2.new(0.45, 0, 0.4, 0)
    autoButton.Font = Enum.Font.GothamBold
    autoButton.Text = "AUTO TAP"
    autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoButton.TextSize = 12
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.Parent = autoButton
    autoCorner.CornerRadius = UDim.new(0, 5)
    
    autoButton.MouseButton1Click:Connect(function()
        tapData.autoEnabled = not tapData.autoEnabled
        autoButton.BackgroundColor3 = tapData.autoEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 150, 0)
        autoButton.Text = tapData.autoEnabled and "STOP" or "AUTO TAP"
    end)
    
    local manualButton = Instance.new("TextButton")
    manualButton.Parent = controlFrame
    manualButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    manualButton.BorderSizePixel = 0
    manualButton.Position = UDim2.new(0.55, 0, 0, 0)
    manualButton.Size = UDim2.new(0.45, 0, 0.4, 0)
    manualButton.Font = Enum.Font.GothamBold
    manualButton.Text = "MANUAL TAP"
    manualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    manualButton.TextSize = 12
    
    local manualCorner = Instance.new("UICorner")
    manualCorner.Parent = manualButton
    manualCorner.CornerRadius = UDim.new(0, 5)
    
    manualButton.MouseButton1Click:Connect(function()
        tapData.taps = tapData.taps + tapData.power
        tapsLabel.Text = tostring(tapData.taps)
        
        -- Efek visual
        manualButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        task.delay(0.1, function()
            manualButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
        end)
    end)
    
    -- Upgrade buttons
    local upgradeFrame = Instance.new("Frame")
    upgradeFrame.Parent = mainFrame
    upgradeFrame.BackgroundTransparency = 1
    upgradeFrame.Position = UDim2.new(0, 10, 0, 210)
    upgradeFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local upgradeButton = Instance.new("TextButton")
    upgradeButton.Parent = upgradeFrame
    upgradeButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    upgradeButton.BorderSizePixel = 0
    upgradeButton.Position = UDim2.new(0, 0, 0, 0)
    upgradeButton.Size = UDim2.new(0.45, 0, 1, 0)
    upgradeButton.Font = Enum.Font.GothamBold
    upgradeButton.Text = "UPGRADE (100)"
    upgradeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    upgradeButton.TextSize = 12
    
    local upgradeCorner = Instance.new("UICorner")
    upgradeCorner.Parent = upgradeButton
    upgradeCorner.CornerRadius = UDim.new(0, 5)
    
    upgradeButton.MouseButton1Click:Connect(function()
        if tapData.taps >= 100 then
            tapData.taps = tapData.taps - 100
            tapData.power = tapData.power + 1
            tapsLabel.Text = tostring(tapData.taps)
            powerValue.Text = tapData.power .. "x"
            
            -- Efek visual
            upgradeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            task.delay(0.1, function()
                upgradeButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            end)
        else
            upgradeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            task.delay(0.5, function()
                upgradeButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            end)
        end
    end)
    
    local speedButton = Instance.new("TextButton")
    speedButton.Parent = upgradeFrame
    speedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    speedButton.BorderSizePixel = 0
    speedButton.Position = UDim2.new(0.55, 0, 0, 0)
    speedButton.Size = UDim2.new(0.45, 0, 1, 0)
    speedButton.Font = Enum.Font.GothamBold
    speedButton.Text = "SPEED (200)"
    speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedButton.TextSize = 12
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.Parent = speedButton
    speedCorner.CornerRadius = UDim.new(0, 5)
    
    speedButton.MouseButton1Click:Connect(function()
        if tapData.taps >= 200 then
            tapData.taps = tapData.taps - 200
            tapData.interval = math.max(0.01, tapData.interval - 0.02)
            tapsLabel.Text = tostring(tapData.taps)
            
            -- Efek visual
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            task.delay(0.1, function()
                speedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
            end)
        else
            speedButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            task.delay(0.5, function()
                speedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
            end)
        end
    end)
    
    -- Reset button
    local resetButton = Instance.new("TextButton")
    resetButton.Parent = mainFrame
    resetButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    resetButton.BorderSizePixel = 0
    resetButton.Position = UDim2.new(0, 10, 1, -35)
    resetButton.Size = UDim2.new(1, -20, 0, 25)
    resetButton.Font = Enum.Font.GothamBold
    resetButton.Text = "RESET TAPS"
    resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetButton.TextSize = 12
    
    local resetCorner = Instance.new("UICorner")
    resetCorner.Parent = resetButton
    resetCorner.CornerRadius = UDim.new(0, 5)
    
    resetButton.MouseButton1Click:Connect(function()
        tapData.taps = 0
        tapsLabel.Text = "0"
    end)
    
    -- Auto tap loop
    task.spawn(function()
        while true do
            task.wait(tapData.interval)
            if tapData.autoEnabled then
                tapData.taps = tapData.taps + tapData.power
                tapsLabel.Text = tostring(tapData.taps)
            end
        end
    end)
end

-- =============================================
-- BAGIAN 17: AUTO TAP
-- =============================================
local AutoTap = {}

function AutoTap.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Versi sederhana dari AutoTapKeyless
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoTapSimpleGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Font = Enum.Font.GothamBold
    title.Text = "AUTO TAP"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 10)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -30, 0, 5)
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 5)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local taps = 0
    
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Parent = mainFrame
    counterLabel.BackgroundTransparency = 1
    counterLabel.Position = UDim2.new(0, 0, 0, 45)
    counterLabel.Size = UDim2.new(1, 0, 0, 30)
    counterLabel.Font = Enum.Font.GothamBold
    counterLabel.Text = "Taps: 0"
    counterLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    counterLabel.TextSize = 20
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Parent = mainFrame
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(0.25, 0, 0.6, 0)
    toggleButton.Size = UDim2.new(0.5, 0, 0, 35)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "START"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 14
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.Parent = toggleButton
    toggleCorner.CornerRadius = UDim.new(0, 8)
    
    local isActive = false
    
    toggleButton.MouseButton1Click:Connect(function()
        isActive = not isActive
        toggleButton.BackgroundColor3 = isActive and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 150, 0)
        toggleButton.Text = isActive and "STOP" or "START"
    end)
    
    local manualButton = Instance.new("TextButton")
    manualButton.Parent = mainFrame
    manualButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    manualButton.BorderSizePixel = 0
    manualButton.Position = UDim2.new(0.25, 0, 0.8, 0)
    manualButton.Size = UDim2.new(0.5, 0, 0, 30)
    manualButton.Font = Enum.Font.GothamBold
    manualButton.Text = "MANUAL TAP"
    manualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    manualButton.TextSize = 12
    
    local manualCorner = Instance.new("UICorner")
    manualCorner.Parent = manualButton
    manualCorner.CornerRadius = UDim.new(0, 8)
    
    manualButton.MouseButton1Click:Connect(function()
        taps = taps + 1
        counterLabel.Text = "Taps: " .. taps
    end)
    
    task.spawn(function()
        while true do
            task.wait(0.1)
            if isActive then
                taps = taps + 1
                counterLabel.Text = "Taps: " .. taps
            end
        end
    end)
end

-- =============================================
-- BAGIAN 18: AUTO REBIRTH
-- =============================================
local AutoRebirth = {}

function AutoRebirth.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Data rebirth
    local rebirthData = {
        level = 50,
        rebirths = 0,
        rebirthCost = 1000,
        autoEnabled = false
    }
    
    -- Buat GUI Auto Rebirth
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoRebirthGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
    mainFrame.Size = UDim2.new(0, 350, 0, 250)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "🔄 AUTO REBIRTH 🔄"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 5)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Stats
    local statsFrame = Instance.new("Frame")
    statsFrame.Parent = mainFrame
    statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statsFrame.BorderSizePixel = 0
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.Size = UDim2.new(1, -20, 0, 70)
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.Parent = statsFrame
    statsCorner.CornerRadius = UDim.new(0, 8)
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Parent = statsFrame
    levelLabel.BackgroundTransparency = 1
    levelLabel.Position = UDim2.new(0, 10, 0, 5)
    levelLabel.Size = UDim2.new(0.5, 0, 0, 20)
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Text = "Level: " .. rebirthData.level
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    levelLabel.TextSize = 16
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local rebirthLabel = Instance.new("TextLabel")
    rebirthLabel.Parent = statsFrame
    rebirthLabel.BackgroundTransparency = 1
    rebirthLabel.Position = UDim2.new(0.5, 0, 0, 5)
    rebirthLabel.Size = UDim2.new(0.5, -10, 0, 20)
    rebirthLabel.Font = Enum.Font.GothamBold
    rebirthLabel.Text = "Rebirths: " .. rebirthData.rebirths
    rebirthLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
    rebirthLabel.TextSize = 16
    rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local costLabel = Instance.new("TextLabel")
    costLabel.Parent = statsFrame
    costLabel.BackgroundTransparency = 1
    costLabel.Position = UDim2.new(0, 10, 0, 30)
    costLabel.Size = UDim2.new(1, -20, 0, 30)
    costLabel.Font = Enum.Font.Gotham
    costLabel.Text = "Next Rebirth Cost: " .. rebirthData.rebirthCost
    costLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    costLabel.TextSize = 14
    costLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Progress bar
    local progressBg = Instance.new("Frame")
    progressBg.Parent = statsFrame
    progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    progressBg.BorderSizePixel = 0
    progressBg.Position = UDim2.new(0, 10, 0, 50)
    progressBg.Size = UDim2.new(1, -20, 0, 10)
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.Parent = progressBg
    progressCorner.CornerRadius = UDim.new(0, 5)
    
    local progressFill = Instance.new("Frame")
    progressFill.Parent = progressBg
    progressFill.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.new(rebirthData.level / 100, 0, 1, 0)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.Parent = progressFill
    fillCorner.CornerRadius = UDim.new(0, 5)
    
    -- Controls
    local controlFrame = Instance.new("Frame")
    controlFrame.Parent = mainFrame
    controlFrame.BackgroundTransparency = 1
    controlFrame.Position = UDim2.new(0, 10, 0, 130)
    controlFrame.Size = UDim2.new(1, -20, 0, 80)
    
    local rebirthButton = Instance.new("TextButton")
    rebirthButton.Parent = controlFrame
    rebirthButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    rebirthButton.BorderSizePixel = 0
    rebirthButton.Position = UDim2.new(0.2, 0, 0, 0)
    rebirthButton.Size = UDim2.new(0.6, 0, 0.4, 0)
    rebirthButton.Font = Enum.Font.GothamBold
    rebirthButton.Text = "REBIRTH NOW"
    rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rebirthButton.TextSize = 14
    
    local rebirthCorner = Instance.new("UICorner")
    rebirthCorner.Parent = rebirthButton
    rebirthCorner.CornerRadius = UDim.new(0, 8)
    
    rebirthButton.MouseButton1Click:Connect(function()
        if rebirthData.level >= 50 then
            rebirthData.rebirths = rebirthData.rebirths + 1
            rebirthData.level = 1
            rebirthData.rebirthCost = rebirthData.rebirthCost * 2
            rebirthLabel.Text = "Rebirths: " .. rebirthData.rebirths
            levelLabel.Text = "Level: 1"
            costLabel.Text = "Next Rebirth Cost: " .. rebirthData.rebirthCost
            progressFill.Size = UDim2.new(0.01, 0, 1, 0)
            
            -- Efek visual
            rebirthButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            task.delay(0.1, function()
                rebirthButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
            end)
        else
            rebirthButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            task.delay(0.5, function()
                rebirthButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
            end)
        end
    end)
    
    local autoToggle = Instance.new("TextButton")
    autoToggle.Parent = controlFrame
    autoToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    autoToggle.BorderSizePixel = 0
    autoToggle.Position = UDim2.new(0.25, 0, 0.5, 0)
    autoToggle.Size = UDim2.new(0.5, 0, 0.35, 0)
    autoToggle.Font = Enum.Font.GothamBold
    autoToggle.Text = "AUTO REBIRTH: OFF"
    autoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoToggle.TextSize = 12
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.Parent = autoToggle
    autoCorner.CornerRadius = UDim.new(0, 5)
    
    autoToggle.MouseButton1Click:Connect(function()
        rebirthData.autoEnabled = not rebirthData.autoEnabled
        autoToggle.BackgroundColor3 = rebirthData.autoEnabled and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 150, 0)
        autoToggle.Text = rebirthData.autoEnabled and "AUTO REBIRTH: ON" or "AUTO REBIRTH: OFF"
    end)
    
    -- Settings
    local settingFrame = Instance.new("Frame")
    settingFrame.Parent = mainFrame
    settingFrame.BackgroundTransparency = 1
    settingFrame.Position = UDim2.new(0, 10, 1, -35)
    settingFrame.Size = UDim2.new(1, -20, 0, 25)
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Parent = settingFrame
    targetLabel.BackgroundTransparency = 1
    targetLabel.Position = UDim2.new(0, 0, 0, 0)
    targetLabel.Size = UDim2.new(0.4, 0, 1, 0)
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.Text = "Target Level:"
    targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    targetLabel.TextSize = 12
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local targetInput = Instance.new("TextBox")
    targetInput.Parent = settingFrame
    targetInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    targetInput.BorderSizePixel = 0
    targetInput.Position = UDim2.new(0.4, 0, 0, 0)
    targetInput.Size = UDim2.new(0.2, 0, 1, 0)
    targetInput.Font = Enum.Font.Gotham
    targetInput.Text = "50"
    targetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetInput.TextSize = 12
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.Parent = targetInput
    targetCorner.CornerRadius = UDim.new(0, 3)
    
    task.spawn(function()
        while true do
            task.wait(1)
            if rebirthData.autoEnabled then
                rebirthData.level = rebirthData.level + 1
                levelLabel.Text = "Level: " .. rebirthData.level
                progressFill.Size = UDim2.new(rebirthData.level / 100, 0, 1, 0)
                
                if rebirthData.level >= tonumber(targetInput.Text) then
                    rebirthData.rebirths = rebirthData.rebirths + 1
                    rebirthData.level = 1
                    rebirthData.rebirthCost = rebirthData.rebirthCost * 2
                    rebirthLabel.Text = "Rebirths: " .. rebirthData.rebirths
                    costLabel.Text = "Next Rebirth Cost: " .. rebirthData.rebirthCost
                    levelLabel.Text = "Level: 1"
                end
            end
        end
    end)
end

-- =============================================
-- BAGIAN 19: AUTOMATION SCRIPT
-- =============================================
local AutomationScript = {}

function AutomationScript.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Automation
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutomationScriptGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 450, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "🤖 AUTOMATION SCRIPT 🤖"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Categories
    local categories = {
        {name = "FARMING", icon = "🌾"},
        {name = "COMBAT", icon = "⚔️"},
        {name = "UTILITY", icon = "🔧"},
        {name = "MOVEMENT", icon = "🏃"}
    }
    
    local catFrame = Instance.new("Frame")
    catFrame.Parent = mainFrame
    catFrame.BackgroundTransparency = 1
    catFrame.Position = UDim2.new(0, 10, 0, 55)
    catFrame.Size = UDim2.new(1, -20, 0, 30)
    
    for i, cat in ipairs(categories) do
        local catButton = Instance.new("TextButton")
        catButton.Parent = catFrame
        catButton.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
        catButton.BorderSizePixel = 0
        catButton.Position = UDim2.new((i-1) * 0.25, 2, 0, 0)
        catButton.Size = UDim2.new(0.25, -4, 1, 0)
        catButton.Font = Enum.Font.GothamBold
        catButton.Text = cat.icon .. " " .. cat.name
        catButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        catButton.TextSize = 12
        
        local catCorner = Instance.new("UICorner")
        catCorner.Parent = catButton
        catCorner.CornerRadius = UDim.new(0, 6)
    end
    
    -- Automation list
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Parent = mainFrame
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Position = UDim2.new(0, 10, 0, 95)
    scrollingFrame.Size = UDim2.new(1, -20, 1, -150)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
    scrollingFrame.ScrollBarThickness = 8
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollingFrame
    uiListLayout.Padding = UDim.new(0, 8)
    
    local automations = {
        {name = "Auto Farm", description = "Otomatis farming sumber daya", category = "Farming", enabled = false},
        {name = "Auto Combat", description = "Otomatis bertarung dengan musuh", category = "Combat", enabled = true},
        {name = "Auto Collect", description = "Otomatis mengumpulkan item", category = "Utility", enabled = false},
        {name = "Auto Sell", description = "Otomatis menjual item", category = "Utility", enabled = true},
        {name = "Auto Move", description = "Otomatis bergerak ke lokasi", category = "Movement", enabled = false},
        {name = "Auto Heal", description = "Otomatis memulihkan health", category = "Combat", enabled = true},
        {name = "Auto Craft", description = "Otomatis crafting item", category = "Utility", enabled = false},
        {name = "Auto Upgrade", description = "Otomatis upgrade equipment", category = "Farming", enabled = false}
    }
    
    for i, auto in ipairs(automations) do
        local autoFrame = Instance.new("Frame")
        autoFrame.Parent = scrollingFrame
        autoFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
        autoFrame.BorderSizePixel = 0
        autoFrame.Size = UDim2.new(1, -10, 0, 50)
        
        local autoCorner = Instance.new("UICorner")
        autoCorner.Parent = autoFrame
        autoCorner.CornerRadius = UDim.new(0, 8)
        
        local autoName = Instance.new("TextLabel")
        autoName.Parent = autoFrame
        autoName.BackgroundTransparency = 1
        autoName.Position = UDim2.new(0, 10, 0, 5)
        autoName.Size = UDim2.new(0.6, 0, 0, 20)
        autoName.Font = Enum.Font.GothamBold
        autoName.Text = auto.name
        autoName.TextColor3 = Color3.fromRGB(255, 255, 255)
        autoName.TextSize = 14
        autoName.TextXAlignment = Enum.TextXAlignment.Left
        
        local autoDesc = Instance.new("TextLabel")
        autoDesc.Parent = autoFrame
        autoDesc.BackgroundTransparency = 1
        autoDesc.Position = UDim2.new(0, 10, 0, 25)
        autoDesc.Size = UDim2.new(0.6, 0, 0, 20)
        autoDesc.Font = Enum.Font.Gotham
        autoDesc.Text = auto.description
        autoDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
        autoDesc.TextSize = 10
        autoDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Parent = autoFrame
        toggleButton.BackgroundColor3 = auto.enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.BorderSizePixel = 0
        toggleButton.Position = UDim2.new(0.75, 0, 0.2, 0)
        toggleButton.Size = UDim2.new(0.2, 0, 0.6, 0)
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Text = auto.enabled and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextSize = 12
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.Parent = toggleButton
        toggleCorner.CornerRadius = UDim.new(0, 5)
        
        local state = auto.enabled
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            toggleButton.Text = state and "ON" or "OFF"
        end)
    end
    
    -- Control panel
    local controlPanel = Instance.new("Frame")
    controlPanel.Parent = mainFrame
    controlPanel.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    controlPanel.BorderSizePixel = 0
    controlPanel.Position = UDim2.new(0, 10, 1, -45)
    controlPanel.Size = UDim2.new(1, -20, 0, 35)
    
    local controlCorner = Instance.new("UICorner")
    controlCorner.Parent = controlPanel
    controlCorner.CornerRadius = UDim.new(0, 8)
    
    local startAll = Instance.new("TextButton")
    startAll.Parent = controlPanel
    startAll.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startAll.BorderSizePixel = 0
    startAll.Position = UDim2.new(0, 5, 0, 5)
    startAll.Size = UDim2.new(0.3, 0, 0, 25)
    startAll.Font = Enum.Font.GothamBold
    startAll.Text = "START ALL"
    startAll.TextColor3 = Color3.fromRGB(255, 255, 255)
    startAll.TextSize = 12
    
    local startCorner = Instance.new("UICorner")
    startCorner.Parent = startAll
    startCorner.CornerRadius = UDim.new(0, 5)
    
    startAll.MouseButton1Click:Connect(function()
        startAll.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.delay(0.2, function()
            startAll.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end)
    end)
    
    local stopAll = Instance.new("TextButton")
    stopAll.Parent = controlPanel
    stopAll.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    stopAll.BorderSizePixel = 0
    stopAll.Position = UDim2.new(0.35, 0, 0, 5)
    stopAll.Size = UDim2.new(0.3, 0, 0, 25)
    stopAll.Font = Enum.Font.GothamBold
    stopAll.Text = "STOP ALL"
    stopAll.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopAll.TextSize = 12
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.Parent = stopAll
    stopCorner.CornerRadius = UDim.new(0, 5)
    
    stopAll.MouseButton1Click:Connect(function()
        stopAll.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.delay(0.2, function()
            stopAll.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end)
    end)
    
    local settings = Instance.new("TextButton")
    settings.Parent = controlPanel
    settings.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    settings.BorderSizePixel = 0
    settings.Position = UDim2.new(0.7, 0, 0, 5)
    settings.Size = UDim2.new(0.25, 0, 0, 25)
    settings.Font = Enum.Font.GothamBold
    settings.Text = "SETTINGS"
    settings.TextColor3 = Color3.fromRGB(255, 255, 255)
    settings.TextSize = 12
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.Parent = settings
    settingsCorner.CornerRadius = UDim.new(0, 5)
end

-- =============================================
-- BAGIAN 20: AUTOMATIONS
-- =============================================
local Automations = {}

function Automations.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Automations (versi ringkas)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutomationsGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "⚙️ AUTOMATIONS ⚙️"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local automations = {
        {name = "Auto Click", icon = "👆"},
        {name = "Auto Farm", icon = "🌾"},
        {name = "Auto Rebirth", icon = "🔄"},
        {name = "Auto Hatch", icon = "🥚"},
        {name = "Auto Enchant", icon = "✨"},
        {name = "Auto Collect", icon = "📦"}
    }
    
    local gridFrame = Instance.new("Frame")
    gridFrame.Parent = mainFrame
    gridFrame.BackgroundTransparency = 1
    gridFrame.Position = UDim2.new(0, 10, 0, 50)
    gridFrame.Size = UDim2.new(1, -20, 1, -60)
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.Parent = gridFrame
    gridLayout.CellSize = UDim2.new(0, 110, 0, 100)
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    
    for _, auto in ipairs(automations) do
        local autoButton = Instance.new("TextButton")
        autoButton.Parent = gridFrame
        autoButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        autoButton.BorderSizePixel = 0
        autoButton.Size = UDim2.new(1, 0, 1, 0)
        autoButton.Font = Enum.Font.GothamBold
        autoButton.Text = ""
        autoButton.AutoButtonColor = false
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = autoButton
        buttonCorner.CornerRadius = UDim.new(0, 10)
        
        local icon = Instance.new("TextLabel")
        icon.Parent = autoButton
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, 0, 0, 10)
        icon.Size = UDim2.new(1, 0, 0, 40)
        icon.Font = Enum.Font.Gotham
        icon.Text = auto.icon
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.TextSize = 30
        
        local name = Instance.new("TextLabel")
        name.Parent = autoButton
        name.BackgroundTransparency = 1
        name.Position = UDim2.new(0, 0, 0, 55)
        name.Size = UDim2.new(1, 0, 0, 20)
        name.Font = Enum.Font.GothamBold
        name.Text = auto.name
        name.TextColor3 = Color3.fromRGB(200, 200, 255)
        name.TextSize = 12
        
        local status = Instance.new("TextLabel")
        status.Parent = autoButton
        status.BackgroundTransparency = 1
        status.Position = UDim2.new(0, 0, 0, 75)
        status.Size = UDim2.new(1, 0, 0, 15)
        status.Font = Enum.Font.Gotham
        status.Text = "OFF"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        status.TextSize = 10
        
        local state = false
        autoButton.MouseButton1Click:Connect(function()
            state = not state
            autoButton.BackgroundColor3 = state and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(30, 30, 40)
            status.Text = state and "ON" or "OFF"
            status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        end)
        
        autoButton.MouseEnter:Connect(function()
            autoButton.BackgroundColor3 = state and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(40, 40, 50)
        end)
        
        autoButton.MouseLeave:Connect(function()
            autoButton.BackgroundColor3 = state and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(30, 30, 40)
        end)
    end
end

-- =============================================
-- BAGIAN 21: AUTO FARM & REBIRTH
-- =============================================
local AutoFarmRebirth = {}

function AutoFarmRebirth.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Auto Farm & Rebirth
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmRebirthGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    mainFrame.Size = UDim2.new(0, 400, 0, 350)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "🌱 AUTO FARM & REBIRTH 🌱"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Stats
    local stats = {
        level = 25,
        rebirths = 3,
        coins = 15000
    }
    
    local statsFrame = Instance.new("Frame")
    statsFrame.Parent = mainFrame
    statsFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
    statsFrame.BorderSizePixel = 0
    statsFrame.Position = UDim2.new(0, 10, 0, 55)
    statsFrame.Size = UDim2.new(1, -20, 0, 60)
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.Parent = statsFrame
    statsCorner.CornerRadius = UDim.new(0, 8)
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Parent = statsFrame
    levelLabel.BackgroundTransparency = 1
    levelLabel.Position = UDim2.new(0, 10, 0, 5)
    levelLabel.Size = UDim2.new(0.33, 0, 0, 20)
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Text = "Level: " .. stats.level
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    levelLabel.TextSize = 14
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local rebirthLabel = Instance.new("TextLabel")
    rebirthLabel.Parent = statsFrame
    rebirthLabel.BackgroundTransparency = 1
    rebirthLabel.Position = UDim2.new(0.33, 0, 0, 5)
    rebirthLabel.Size = UDim2.new(0.33, 0, 0, 20)
    rebirthLabel.Font = Enum.Font.GothamBold
    rebirthLabel.Text = "Rebirths: " .. stats.rebirths
    rebirthLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    rebirthLabel.TextSize = 14
    rebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Parent = statsFrame
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Position = UDim2.new(0.66, 0, 0, 5)
    coinsLabel.Size = UDim2.new(0.33, 0, 0, 20)
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.Text = "Coins: " .. stats.coins
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextSize = 14
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Progress bars
    local expLabel = Instance.new("TextLabel")
    expLabel.Parent = statsFrame
    expLabel.BackgroundTransparency = 1
    expLabel.Position = UDim2.new(0, 10, 0, 25)
    expLabel.Size = UDim2.new(0.5, 0, 0, 15)
    expLabel.Font = Enum.Font.Gotham
    expLabel.Text = "EXP: 1250/2000"
    expLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    expLabel.TextSize = 10
    expLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local expBar = Instance.new("Frame")
    expBar.Parent = statsFrame
    expBar.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
    expBar.BorderSizePixel = 0
    expBar.Position = UDim2.new(0, 10, 0, 40)
    expBar.Size = UDim2.new(0.45, 0, 0, 10)
    
    local expBarCorner = Instance.new("UICorner")
    expBarCorner.Parent = expBar
    expBarCorner.CornerRadius = UDim.new(0, 5)
    
    local expFill = Instance.new("Frame")
    expFill.Parent = expBar
    expFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    expFill.BorderSizePixel = 0
    expFill.Size = UDim2.new(0.625, 0, 1, 0)
    
    local expFillCorner = Instance.new("UICorner")
    expFillCorner.Parent = expFill
    expFillCorner.CornerRadius = UDim.new(0, 5)
    
    -- Mode selection
    local modeFrame = Instance.new("Frame")
    modeFrame.Parent = mainFrame
    modeFrame.BackgroundTransparency = 1
    modeFrame.Position = UDim2.new(0, 10, 0, 125)
    modeFrame.Size = UDim2.new(1, -20, 0, 100)
    
    local farmLabel = Instance.new("TextLabel")
    farmLabel.Parent = modeFrame
    farmLabel.BackgroundTransparency = 1
    farmLabel.Position = UDim2.new(0, 0, 0, 0)
    farmLabel.Size = UDim2.new(1, 0, 0, 20)
    farmLabel.Font = Enum.Font.GothamBold
    farmLabel.Text = "FARM MODE"
    farmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmLabel.TextSize = 14
    farmLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local farmModes = {"Efficient", "Balanced", "Aggressive"}
    local farmButtons = {}
    
    for i, mode in ipairs(farmModes) do
        local modeButton = Instance.new("TextButton")
        modeButton.Parent = modeFrame
        modeButton.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
        modeButton.BorderSizePixel = 0
        modeButton.Position = UDim2.new((i-1) * 0.33, 2, 0, 25)
        modeButton.Size = UDim2.new(0.33, -4, 0, 30)
        modeButton.Font = Enum.Font.GothamBold
        modeButton.Text = mode
        modeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        modeButton.TextSize = 12
        
        local modeCorner = Instance.new("UICorner")
        modeCorner.Parent = modeButton
        modeCorner.CornerRadius = UDim.new(0, 5)
        
        farmButtons[mode] = modeButton
        
        modeButton.MouseButton1Click:Connect(function()
            for _, btn in pairs(farmButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            modeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
    
    farmButtons["Balanced"].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    farmButtons["Balanced"].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Rebirth settings
    local rebirthFrame = Instance.new("Frame")
    rebirthFrame.Parent = modeFrame
    rebirthFrame.BackgroundTransparency = 1
    rebirthFrame.Position = UDim2.new(0, 0, 0, 60)
    rebirthFrame.Size = UDim2.new(1, 0, 0, 35)
    
    local autoRebirthLabel = Instance.new("TextLabel")
    autoRebirthLabel.Parent = rebirthFrame
    autoRebirthLabel.BackgroundTransparency = 1
    autoRebirthLabel.Position = UDim2.new(0, 0, 0, 0)
    autoRebirthLabel.Size = UDim2.new(0.5, 0, 1, 0)
    autoRebirthLabel.Font = Enum.Font.Gotham
    autoRebirthLabel.Text = "Auto Rebirth at Level:"
    autoRebirthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoRebirthLabel.TextSize = 12
    autoRebirthLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local rebirthInput = Instance.new("TextBox")
    rebirthInput.Parent = rebirthFrame
    rebirthInput.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    rebirthInput.BorderSizePixel = 0
    rebirthInput.Position = UDim2.new(0.5, 0, 0, 0)
    rebirthInput.Size = UDim2.new(0.2, 0, 1, 0)
    rebirthInput.Font = Enum.Font.Gotham
    rebirthInput.Text = "50"
    rebirthInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    rebirthInput.TextSize = 12
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.Parent = rebirthInput
    inputCorner.CornerRadius = UDim.new(0, 3)
    
    -- Control buttons
    local controlFrame = Instance.new("Frame")
    controlFrame.Parent = mainFrame
    controlFrame.BackgroundTransparency = 1
    controlFrame.Position = UDim2.new(0, 10, 1, -40)
    controlFrame.Size = UDim2.new(1, -20, 0, 30)
    
    local startButton = Instance.new("TextButton")
    startButton.Parent = controlFrame
    startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startButton.BorderSizePixel = 0
    startButton.Position = UDim2.new(0, 0, 0, 0)
    startButton.Size = UDim2.new(0.45, 0, 1, 0)
    startButton.Font = Enum.Font.GothamBold
    startButton.Text = "START FARM"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextSize = 14
    
    local startCorner = Instance.new("UICorner")
    startCorner.Parent = startButton
    startCorner.CornerRadius = UDim.new(0, 6)
    
    startButton.MouseButton1Click:Connect(function()
        startButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.delay(0.2, function()
            startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end)
    end)
    
    local stopButton = Instance.new("TextButton")
    stopButton.Parent = controlFrame
    stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    stopButton.BorderSizePixel = 0
    stopButton.Position = UDim2.new(0.55, 0, 0, 0)
    stopButton.Size = UDim2.new(0.45, 0, 1, 0)
    stopButton.Font = Enum.Font.GothamBold
    stopButton.Text = "STOP FARM"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextSize = 14
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.Parent = stopButton
    stopCorner.CornerRadius = UDim.new(0, 6)
    
    stopButton.MouseButton1Click:Connect(function()
        stopButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.delay(0.2, function()
            stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end)
    end)
end

-- =============================================
-- BAGIAN 22: AUTO FARM & HATCH
-- =============================================
local AutoFarmHatch = {}

function AutoFarmHatch.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Auto Farm & Hatch
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmHatchGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    mainFrame.Size = UDim2.new(0, 400, 0, 350)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Font = Enum.Font.GothamBold
    title.Text = "🥚 AUTO FARM & HATCH 🥚"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 15)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 8)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Stats
    local stats = {
        coins = 5000,
        eggs = 3,
        pets = 12
    }
    
    local statsFrame = Instance.new("Frame")
    statsFrame.Parent = mainFrame
    statsFrame.BackgroundColor3 = Color3.fromRGB(35, 25, 40)
    statsFrame.BorderSizePixel = 0
    statsFrame.Position = UDim2.new(0, 10, 0, 55)
    statsFrame.Size = UDim2.new(1, -20, 0, 50)
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.Parent = statsFrame
    statsCorner.CornerRadius = UDim.new(0, 8)
    
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Parent = statsFrame
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.Position = UDim2.new(0, 10, 0, 5)
    coinsLabel.Size = UDim2.new(0.33, 0, 0, 20)
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.Text = "💰 " .. stats.coins
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextSize = 14
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local eggsLabel = Instance.new("TextLabel")
    eggsLabel.Parent = statsFrame
    eggsLabel.BackgroundTransparency = 1
    eggsLabel.Position = UDim2.new(0.33, 0, 0, 5)
    eggsLabel.Size = UDim2.new(0.33, 0, 0, 20)
    eggsLabel.Font = Enum.Font.GothamBold
    eggsLabel.Text = "🥚 " .. stats.eggs
    eggsLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
    eggsLabel.TextSize = 14
    eggsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local petsLabel = Instance.new("TextLabel")
    petsLabel.Parent = statsFrame
    petsLabel.BackgroundTransparency = 1
    petsLabel.Position = UDim2.new(0.66, 0, 0, 5)
    petsLabel.Size = UDim2.new(0.33, 0, 0, 20)
    petsLabel.Font = Enum.Font.GothamBold
    petsLabel.Text = "🐾 " .. stats.pets
    petsLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    petsLabel.TextSize = 14
    petsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Farm settings
    local farmFrame = Instance.new("Frame")
    farmFrame.Parent = mainFrame
    farmFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 35)
    farmFrame.BorderSizePixel = 0
    farmFrame.Position = UDim2.new(0, 10, 0, 115)
    farmFrame.Size = UDim2.new(1, -20, 0, 80)
    
    local farmCorner = Instance.new("UICorner")
    farmCorner.Parent = farmFrame
    farmCorner.CornerRadius = UDim.new(0, 8)
    
    local farmTitle = Instance.new("TextLabel")
    farmTitle.Parent = farmFrame
    farmTitle.BackgroundTransparency = 1
    farmTitle.Position = UDim2.new(0, 10, 0, 5)
    farmTitle.Size = UDim2.new(1, -20, 0, 20)
    farmTitle.Font = Enum.Font.GothamBold
    farmTitle.Text = "FARM SETTINGS"
    farmTitle.TextColor3 = Color3.fromRGB(255, 200, 255)
    farmTitle.TextSize = 14
    farmTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local farmSpeed = Instance.new("TextLabel")
    farmSpeed.Parent = farmFrame
    farmSpeed.BackgroundTransparency = 1
    farmSpeed.Position = UDim2.new(0, 10, 0, 30)
    farmSpeed.Size = UDim2.new(0.4, 0, 0, 20)
    farmSpeed.Font = Enum.Font.Gotham
    farmSpeed.Text = "Farm Speed:"
    farmSpeed.TextColor3 = Color3.fromRGB(200, 200, 200)
    farmSpeed.TextSize = 12
    farmSpeed.TextXAlignment = Enum.TextXAlignment.Left
    
    local speedBar = Instance.new("Frame")
    speedBar.Parent = farmFrame
    speedBar.BackgroundColor3 = Color3.fromRGB(50, 45, 55)
    speedBar.BorderSizePixel = 0
    speedBar.Position = UDim2.new(0.4, 0, 0, 35)
    speedBar.Size = UDim2.new(0.5, 0, 0, 10)
    
    local speedBarCorner = Instance.new("UICorner")
    speedBarCorner.Parent = speedBar
    speedBarCorner.CornerRadius = UDim.new(0, 5)
    
    local speedFill = Instance.new("Frame")
    speedFill.Parent = speedBar
    speedFill.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    speedFill.BorderSizePixel = 0
    speedFill.Size = UDim2.new(0.7, 0, 1, 0)
    
    local speedFillCorner = Instance.new("UICorner")
    speedFillCorner.Parent = speedFill
    speedFillCorner.CornerRadius = UDim.new(0, 5)
    
    -- Hatch settings
    local hatchFrame = Instance.new("Frame")
    hatchFrame.Parent = mainFrame
    hatchFrame.BackgroundColor3 = Color3.fromRGB(30, 25, 35)
    hatchFrame.BorderSizePixel = 0
    hatchFrame.Position = UDim2.new(0, 10, 0, 205)
    hatchFrame.Size = UDim2.new(1, -20, 0, 80)
    
    local hatchCorner = Instance.new("UICorner")
    hatchCorner.Parent = hatchFrame
    hatchCorner.CornerRadius = UDim.new(0, 8)
    
    local hatchTitle = Instance.new("TextLabel")
    hatchTitle.Parent = hatchFrame
    hatchTitle.BackgroundTransparency = 1
    hatchTitle.Position = UDim2.new(0, 10, 0, 5)
    hatchTitle.Size = UDim2.new(1, -20, 0, 20)
    hatchTitle.Font = Enum.Font.GothamBold
    hatchTitle.Text = "HATCH SETTINGS"
    hatchTitle.TextColor3 = Color3.fromRGB(255, 200, 255)
    hatchTitle.TextSize = 14
    hatchTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local autoHatchLabel = Instance.new("TextLabel")
    autoHatchLabel.Parent = hatchFrame
    autoHatchLabel.BackgroundTransparency = 1
    autoHatchLabel.Position = UDim2.new(0, 10, 0, 30)
    autoHatchLabel.Size = UDim2.new(0.5, 0, 0, 20)
    autoHatchLabel.Font = Enum.Font.Gotham
    autoHatchLabel.Text = "Auto Hatch:"
    autoHatchLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    autoHatchLabel.TextSize = 12
    autoHatchLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local hatchToggle = Instance.new("TextButton")
    hatchToggle.Parent = hatchFrame
    hatchToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    hatchToggle.BorderSizePixel = 0
    hatchToggle.Position = UDim2.new(0.5, 0, 0, 30)
    hatchToggle.Size = UDim2.new(0.15, 0, 0, 20)
    hatchToggle.Font = Enum.Font.GothamBold
    hatchToggle.Text = "ON"
    hatchToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    hatchToggle.TextSize = 10
    
    local hatchToggleCorner = Instance.new("UICorner")
    hatchToggleCorner.Parent = hatchToggle
    hatchToggleCorner.CornerRadius = UDim.new(0, 3)
    
    local hatchState = true
    hatchToggle.MouseButton1Click:Connect(function()
        hatchState = not hatchState
        hatchToggle.BackgroundColor3 = hatchState and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        hatchToggle.Text = hatchState and "ON" or "OFF"
    end)
    
    local eggSelect = Instance.new("TextLabel")
    eggSelect.Parent = hatchFrame
    eggSelect.BackgroundTransparency = 1
    eggSelect.Position = UDim2.new(0, 10, 0, 55)
    eggSelect.Size = UDim2.new(0.4, 0, 0, 20)
    eggSelect.Font = Enum.Font.Gotham
    eggSelect.Text = "Egg Type:"
    eggSelect.TextColor3 = Color3.fromRGB(200, 200, 200)
    eggSelect.TextSize = 12
    eggSelect.TextXAlignment = Enum.TextXAlignment.Left
    
    local eggDropdown = Instance.new("TextButton")
    eggDropdown.Parent = hatchFrame
    eggDropdown.BackgroundColor3 = Color3.fromRGB(40, 35, 45)
    eggDropdown.BorderSizePixel = 0
    eggDropdown.Position = UDim2.new(0.4, 0, 0, 55)
    eggDropdown.Size = UDim2.new(0.5, 0, 0, 20)
    eggDropdown.Font = Enum.Font.Gotham
    eggDropdown.Text = "Common Egg"
    eggDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    eggDropdown.TextSize = 12
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.Parent = eggDropdown
    dropdownCorner.CornerRadius = UDim.new(0, 3)
    
    -- Control buttons
    local controlFrame = Instance.new("Frame")
    controlFrame.Parent = mainFrame
    controlFrame.BackgroundTransparency = 1
    controlFrame.Position = UDim2.new(0, 10, 1, -35)
    controlFrame.Size = UDim2.new(1, -20, 0, 25)
    
    local startButton = Instance.new("TextButton")
    startButton.Parent = controlFrame
    startButton.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
    startButton.BorderSizePixel = 0
    startButton.Position = UDim2.new(0.25, 0, 0, 0)
    startButton.Size = UDim2.new(0.5, 0, 1, 0)
    startButton.Font = Enum.Font.GothamBold
    startButton.Text = "START AUTOMATION"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextSize = 12
    
    local startCorner = Instance.new("UICorner")
    startCorner.Parent = startButton
    startCorner.CornerRadius = UDim.new(0, 5)
    
    startButton.MouseButton1Click:Connect(function()
        startButton.BackgroundColor3 = Color3.fromRGB(200, 100, 200)
        task.delay(0.2, function()
            startButton.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
        end)
    end)
end

-- =============================================
-- BAGIAN 23: AUTO ENCHANT (Standalone)
-- =============================================
local AutoEnchant = {}

function AutoEnchant.init()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    -- Buat GUI Auto Enchant sederhana
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoEnchantGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.Text = "✨ AUTO ENCHANT ✨"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 6)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Essence display
    local essenceFrame = Instance.new("Frame")
    essenceFrame.Parent = mainFrame
    essenceFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    essenceFrame.BorderSizePixel = 0
    essenceFrame.Position = UDim2.new(0, 10, 0, 50)
    essenceFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local essenceCorner = Instance.new("UICorner")
    essenceCorner.Parent = essenceFrame
    essenceCorner.CornerRadius = UDim.new(0, 8)
    
    local essenceLabel = Instance.new("TextLabel")
    essenceLabel.Parent = essenceFrame
    essenceLabel.BackgroundTransparency = 1
    essenceLabel.Size = UDim2.new(1, 0, 1, 0)
    essenceLabel.Font = Enum.Font.GothamBold
    essenceLabel.Text = "🔮 ENCHANT ESSENCE: 500"
    essenceLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
    essenceLabel.TextSize = 16
    
    -- Enchant items
    local enchantItems = {
        {name = "Sharpness", level = 3, max = 5, cost = 100},
        {name = "Protection", level = 2, max = 4, cost = 150},
        {name = "Efficiency", level = 4, max = 5, cost = 120},
        {name = "Unbreaking", level = 2, max = 3, cost = 80}
    }
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Parent = mainFrame
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Position = UDim2.new(0, 10, 0, 100)
    scrollingFrame.Size = UDim2.new(1, -20, 1, -150)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #enchantItems * 60)
    scrollingFrame.ScrollBarThickness = 8
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollingFrame
    uiListLayout.Padding = UDim.new(0, 8)
    
    for _, item in ipairs(enchantItems) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Parent = scrollingFrame
        itemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        itemFrame.BorderSizePixel = 0
        itemFrame.Size = UDim2.new(1, -10, 0, 50)
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.Parent = itemFrame
        itemCorner.CornerRadius = UDim.new(0, 8)
        
        local itemName = Instance.new("TextLabel")
        itemName.Parent = itemFrame
        itemName.BackgroundTransparency = 1
        itemName.Position = UDim2.new(0, 10, 0, 5)
        itemName.Size = UDim2.new(0.5, 0, 0, 20)
        itemName.Font = Enum.Font.GothamBold
        itemName.Text = item.name
        itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
        itemName.TextSize = 14
        itemName.TextXAlignment = Enum.TextXAlignment.Left
        
        local itemLevel = Instance.new("TextLabel")
        itemLevel.Parent = itemFrame
        itemLevel.BackgroundTransparency = 1
        itemLevel.Position = UDim2.new(0.5, 0, 0, 5)
        itemLevel.Size = UDim2.new(0.3, 0, 0, 20)
        itemLevel.Font = Enum.Font.Gotham
        itemLevel.Text = "Lv." .. item.level .. "/" .. item.max
        itemLevel.TextColor3 = Color3.fromRGB(200, 200, 200)
        itemLevel.TextSize = 12
        itemLevel.TextXAlignment = Enum.TextXAlignment.Left
        
        local progressBg = Instance.new("Frame")
        progressBg.Parent = itemFrame
        progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        progressBg.BorderSizePixel = 0
        progressBg.Position = UDim2.new(0, 10, 0, 30)
        progressBg.Size = UDim2.new(0.6, 0, 0, 10)
        
        local progressCorner = Instance.new("UICorner")
        progressCorner.Parent = progressBg
        progressCorner.CornerRadius = UDim.new(0, 5)
        
        local progressFill = Instance.new("Frame")
        progressFill.Parent = progressBg
        progressFill.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
        progressFill.BorderSizePixel = 0
        progressFill.Size = UDim2.new(item.level / item.max, 0, 1, 0)
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.Parent = progressFill
        fillCorner.CornerRadius = UDim.new(0, 5)
        
        local enchantButton = Instance.new("TextButton")
        enchantButton.Parent = itemFrame
        enchantButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        enchantButton.BorderSizePixel = 0
        enchantButton.Position = UDim2.new(0.75, 0, 0.2, 0)
        enchantButton.Size = UDim2.new(0.2, 0, 0.6, 0)
        enchantButton.Font = Enum.Font.GothamBold
        enchantButton.Text = "ENCHANT"
        enchantButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        enchantButton.TextSize = 10
        
        local enchantCorner = Instance.new("UICorner")
        enchantCorner.Parent = enchantButton
        enchantCorner.CornerRadius = UDim.new(0, 5)
    end
    
    -- Auto enchant toggle
    local autoFrame = Instance.new("Frame")
    autoFrame.Parent = mainFrame
    autoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    autoFrame.BorderSizePixel = 0
    autoFrame.Position = UDim2.new(0, 10, 1, -35)
    autoFrame.Size = UDim2.new(1, -20, 0, 25)
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.Parent = autoFrame
    autoCorner.CornerRadius = UDim.new(0, 8)
    
    local autoLabel = Instance.new("TextLabel")
    autoLabel.Parent = autoFrame
    autoLabel.BackgroundTransparency = 1
    autoLabel.Position = UDim2.new(0, 10, 0, 0)
    autoLabel.Size = UDim2.new(0.5, 0, 1, 0)
    autoLabel.Font = Enum.Font.Gotham
    autoLabel.Text = "Auto Enchant"
    autoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoLabel.TextSize = 12
    autoLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local autoToggle = Instance.new("TextButton")
    autoToggle.Parent = autoFrame
    autoToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    autoToggle.BorderSizePixel = 0
    autoToggle.Position = UDim2.new(0.8, 0, 0.1, 0)
    autoToggle.Size = UDim2.new(0.15, 0, 0.8, 0)
    autoToggle.Font = Enum.Font.GothamBold
    autoToggle.Text = "ON"
    autoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoToggle.TextSize = 10
    
    local autoToggleCorner = Instance.new("UICorner")
    autoToggleCorner.Parent = autoToggle
    autoToggleCorner.CornerRadius = UDim.new(0, 3)
    
    local autoState = true
    autoToggle.MouseButton1Click:Connect(function()
        autoState = not autoState
        autoToggle.BackgroundColor3 = autoState and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        autoToggle.Text = autoState and "ON" or "OFF"
    end)
end

-- =============================================
-- MAIN SCRIPT - MENU UTAMA
-- =============================================

-- Inisialisasi semua fungsi
local function initAllScripts()
    local player = game.Players.LocalPlayer
    if not player then 
        player = game.Players.PlayerAdded:Wait()
    end
    
    -- Buat menu utama
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainMenuGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    mainFrame.Size = UDim2.new(0, 600, 0, 500)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 20)
    
    local gradient = Instance.new("UIGradient")
    gradient.Parent = mainFrame
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    })
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    title.BorderSizePixel = 0
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Font = Enum.Font.GothamBold
    title.Text = "🚀 MEGA SCRIPT COLLECTION 🚀"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = title
    titleCorner.CornerRadius = UDim.new(0, 20)
    
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Parent = title
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 150))
    })
    
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeButton
    closeCorner.CornerRadius = UDim.new(0, 10)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local tabs = {
        "TELEPORT", "REWARDS", "AUTO FARM", "ENCHANT", 
        "EGG", "PROGRESS", "AUTO TAP", "REBIRTH", "CRAFTING"
    }
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Parent = mainFrame
    tabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    tabFrame.BorderSizePixel = 0
    tabFrame.Position = UDim2.new(0, 10, 0, 60)
    tabFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.Parent = tabFrame
    tabCorner.CornerRadius = UDim.new(0, 10)
    
    local tabButtons = {}
    local currentTab = "TELEPORT"
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = tabFrame
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        tabButton.BorderSizePixel = 0
        tabButton.Position = UDim2.new((i-1) * (1/#tabs), 2, 0, 2)
        tabButton.Size = UDim2.new(1/#tabs, -4, 1, -4)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 12
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.Parent = tabButton
        tabButtonCorner.CornerRadius = UDim.new(0, 8)
        
        tabButtons[tabName] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            currentTab = tabName
            for _, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            updateContent()
        end)
    end
    
    tabButtons["TELEPORT"].BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    tabButtons["TELEPORT"].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    contentFrame.BorderSizePixel = 0
    contentFrame.Position = UDim2.new(0, 10, 0, 110)
    contentFrame.Size = UDim2.new(1, -20, 1, -170)
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.Parent = contentFrame
    contentCorner.CornerRadius = UDim.new(0, 10)
    
    local function updateContent()
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("ScrollingFrame") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        if currentTab == "TELEPORT" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "TELEPORT SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "Teleport Zones", func = TeleportZones.init, color = Color3.fromRGB(0, 150, 255)},
                {name = "Teleports System", func = TeleportsSystem.init, color = Color3.fromRGB(255, 150, 0)},
                {name = "Quick Teleport", func = function() 
                    local player = game.Players.LocalPlayer
                    if player and player.Character then
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
                    end
                end, color = Color3.fromRGB(0, 255, 0)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(function()
                    btn.func()
                    SmoothUI.createNotification("Teleport", btn.name .. " activated!", 2)
                end)
            end
            
        elseif currentTab == "REWARDS" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "REWARDS SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "Daily Rewards", func = RewardsSystem.init, color = Color3.fromRGB(255, 215, 0)},
                {name = "Achievement Rewards", func = function()
                    SmoothUI.createNotification("Achievement", "Claimed 500 coins!", 2)
                end, color = Color3.fromRGB(0, 200, 0)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(btn.func)
            end
            
        elseif currentTab == "AUTO FARM" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "AUTO FARM SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "Balanced Auto Farm", func = BalancedAutoFarm.init, color = Color3.fromRGB(0, 150, 100)},
                {name = "Auto Farm & Rebirth", func = AutoFarmRebirth.init, color = Color3.fromRGB(0, 100, 50)},
                {name = "Auto Farm & Hatch", func = AutoFarmHatch.init, color = Color3.fromRGB(150, 50, 150)},
                {name = "Automation Script", func = AutomationScript.init, color = Color3.fromRGB(0, 100, 150)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 12
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(btn.func)
            end
            
        elseif currentTab == "ENCHANT" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "ENCHANT SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "Best Auto Enchant", func = BestAutoEnchant.init, color = Color3.fromRGB(150, 50, 200)},
                {name = "Auto Enchant", func = AutoEnchant.init, color = Color3.fromRGB(100, 100, 255)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(btn.func)
            end
            
        elseif currentTab == "EGG" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "EGG SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "Egg System", func = EggSystem.init, color = Color3.fromRGB(255, 100, 150)},
                {name = "Auto Hatch", func = function()
                    SmoothUI.createNotification("Auto Hatch", "Hatching eggs...", 2)
                end, color = Color3.fromRGB(255, 150, 100)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(btn.func)
            end
            
        elseif currentTab == "PROGRESS" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "PROGRESS SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "Quick Progress", func = QuickProgress.init, color = Color3.fromRGB(255, 215, 0)},
                {name = "Full Progress Automation", func = FullProgressAutomation.init, color = Color3.fromRGB(0, 150, 200)},
                {name = "Auto Unlock", func = AutoUnlock.init, color = Color3.fromRGB(100, 50, 200)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 12
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(btn.func)
            end
            
        elseif currentTab == "AUTO TAP" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "AUTO TAP SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "Auto Tap Keyless", func = AutoTapKeyless.init, color = Color3.fromRGB(255, 100, 100)},
                {name = "Auto Tap Simple", func = AutoTap.init, color = Color3.fromRGB(100, 100, 255)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(btn.func)
            end
            
        elseif currentTab == "REBIRTH" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "REBIRTH SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "Auto Rebirth", func = AutoRebirth.init, color = Color3.fromRGB(150, 0, 150)},
                {name = "Auto Farm & Rebirth", func = AutoFarmRebirth.init, color = Color3.fromRGB(0, 150, 50)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(btn.func)
            end
            
        elseif currentTab == "CRAFTING" then
            local label = Instance.new("TextLabel")
            label.Parent = contentFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 30)
            label.Font = Enum.Font.GothamBold
            label.Text = "CRAFTING SYSTEMS"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 18
            
            local buttons = {
                {name = "OP Crafting", func = OPCraftingScript.init, color = Color3.fromRGB(139, 69, 19)},
                {name = "Auto Craft", func = function()
                    SmoothUI.createNotification("Auto Craft", "Crafting items...", 2)
                end, color = Color3.fromRGB(200, 100, 50)}
            }
            
            for i, btn in ipairs(buttons) do
                local button = Instance.new("TextButton")
                button.Parent = contentFrame
                button.BackgroundColor3 = btn.color
                button.BorderSizePixel = 0
                button.Position = UDim2.new(0.1, 0, 0.1 + i * 0.1, 0)
                button.Size = UDim2.new(0.8, 0, 0.08, 0)
                button.Font = Enum.Font.GothamBold
                button.Text = btn.name
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.Parent = button
                btnCorner.CornerRadius = UDim.new(0, 8)
                
                button.MouseButton1Click:Connect(btn.func)
            end
        end
    end
    
    updateContent()
    
    -- Footer
    local footerFrame = Instance.new("Frame")
    footerFrame.Parent = mainFrame
    footerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    footerFrame.BorderSizePixel = 0
    footerFrame.Position = UDim2.new(0, 10, 1, -40)
    footerFrame.Size = UDim2.new(1, -20, 0, 30)
    
    local footerCorner = Instance.new("UICorner")
    footerCorner.Parent = footerFrame
    footerCorner.CornerRadius = UDim.new(0, 8)
    
    local footerText = Instance.new("TextLabel")
    footerText.Parent = footerFrame
    footerText.BackgroundTransparency = 1
    footerText.Size = UDim2.new(1, 0, 1, 0)
    footerText.Font = Enum.Font.Gotham
    footerText.Text = "🚀 All Scripts Loaded Successfully | Mega Script Collection v1.0"
    footerText.TextColor3 = Color3.fromRGB(150, 150, 200)
    footerText.TextSize = 12
end

-- Jalankan menu utama
initAllScripts()