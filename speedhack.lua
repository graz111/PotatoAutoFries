
-- ==============================================
-- SpeedHack System with Custom Notifications
-- For Skitek Loader V3
-- ==============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ===== NOTIFICATION SYSTEM =====
local NotificationSystem = {}

function NotificationSystem:CreateNotification(title, message, type)
    local colors = {
        success = Color3.fromRGB(46, 204, 113),
        error = Color3.fromRGB(231, 76, 60),
        warning = Color3.fromRGB(241, 196, 15),
        info = Color3.fromRGB(52, 152, 219)
    }
    
    local icons = {
        success = "✅",
        error = "❌",
        warning = "⚠️",
        info = "ℹ️"
    }
    
    local config = {
        color = colors[type] or colors.info,
        icon = icons[type] or icons.info
    }
    
    -- Create GUI
    local ScreenGui = game:GetService("CoreGui"):FindFirstChild("SpeedNotifications") or Instance.new("ScreenGui")
    ScreenGui.Name = "SpeedNotifications"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local Notification = Instance.new("Frame")
    Notification.Name = "SpeedNotification"
    Notification.Size = UDim2.new(0, 280, 0, 60)
    Notification.Position = UDim2.new(0.05, 0, 0.85, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Notification.BackgroundTransparency = 0.1
    Notification.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Notification
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 10, 0.5, -20)
    Icon.BackgroundTransparency = 1
    Icon.Text = config.icon
    Icon.TextColor3 = config.color
    Icon.TextSize = 20
    Icon.Font = Enum.Font.GothamBold
    Icon.TextYAlignment = Enum.TextYAlignment.Center
    Icon.Parent = Notification
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 0, 25)
    TitleLabel.Position = UDim2.new(0, 60, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.white
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Notification
    
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(0, 200, 0, 25)
    MessageLabel.Position = UDim2.new(0, 60, 0, 30)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    MessageLabel.TextSize = 12
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.Parent = Notification
    
    Notification.Parent = ScreenGui
    
    -- Animation
    Notification.Position = UDim2.new(-0.3, 0, 0.85, 0)
    TweenService:Create(Notification, TweenInfo.new(0.3), {
        Position = UDim2.new(0.05, 0, 0.85, 0)
    }):Play()
    
    -- Auto-remove
    spawn(function()
        wait(3)
        TweenService:Create(Notification, TweenInfo.new(0.3), {
            Position = UDim2.new(-0.3, 0, 0.85, 0)
        }):Play()
        wait(0.3)
        Notification:Destroy()
    end)
end

-- ===== SPEEDHACK SYSTEM =====
local DEFAULT_SPEED = 16
local currentSpeed = 50
local speedEnabled = true
local speedPresets = {16, 30, 50, 100, 150, 200}
local currentPresetIndex = 3

-- Speed Trails Effect
local trailEffect

local function createTrailEffect()
    if trailEffect then trailEffect:Destroy() end
    
    trailEffect = Instance.new("Part")
    trailEffect.Name = "SpeedTrail"
    trailEffect.Size = Vector3.new(0.5, 0.5, 2)
    trailEffect.Transparency = 0.7
    trailEffect.Color = Color3.fromRGB(100, 150, 255)
    trailEffect.Material = Enum.Material.Neon
    trailEffect.Anchored = true
    trailEffect.CanCollide = false
    
    local trail = Instance.new("Trail")
    trail.Color = ColorSequence.new(Color3.fromRGB(100, 150, 255))
    trail.Transparency = NumberSequence.new(0.7)
    trail.Lifetime = 0.3
    trail.Parent = trailEffect
    
    spawn(function()
        while trailEffect and speedEnabled and currentSpeed > 50 do
            if Character and Character.Parent then
                local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local newTrail = trailEffect:Clone()
                    newTrail.Position = humanoidRootPart.Position
                    newTrail.Parent = workspace
                    
                    game:GetService("Debris"):AddItem(newTrail, 1)
                end
            end
            wait(0.1)
        end
    end)
end

-- Set Speed Function
local function setSpeed(newSpeed)
    if not Humanoid or not Humanoid.Parent then return end
    
    currentSpeed = newSpeed
    Humanoid.WalkSpeed = newSpeed
    
    -- Visual feedback based on speed
    if newSpeed >= 100 then
        if not trailEffect then
            createTrailEffect()
        end
        NotificationSystem:CreateNotification(
            "⚡ HYPER SPEED",
            "Speed: " .. newSpeed .. " | Trail effect enabled!",
            "warning"
        )
    elseif newSpeed >= 50 then
        if trailEffect then
            trailEffect:Destroy()
            trailEffect = nil
        end
        NotificationSystem:CreateNotification(
            "🏃 FAST MOVEMENT",
            "Speed set to: " .. newSpeed,
            "info"
        )
    else
        if trailEffect then
            trailEffect:Destroy()
            trailEffect = nil
        end
        NotificationSystem:CreateNotification(
            "🚶 NORMAL SPEED",
            "Speed: " .. newSpeed,
            "info"
        )
    end
end

-- Toggle Speed Function
local function toggleSpeed()
    speedEnabled = not speedEnabled
    
    if speedEnabled then
        Humanoid.WalkSpeed = currentSpeed
        NotificationSystem:CreateNotification(
            "✅ SPEED ENABLED",
            "Speed hack activated: " .. currentSpeed,
            "success"
        )
    else
        Humanoid.WalkSpeed = DEFAULT_SPEED
        if trailEffect then
            trailEffect:Destroy()
            trailEffect = nil
        end
        NotificationSystem:CreateNotification(
            "⛔ SPEED DISABLED",
            "Speed reset to default: " .. DEFAULT_SPEED,
            "error"
        )
    end
end

-- Cycle Presets
local function cyclePreset(forward)
    if forward then
        currentPresetIndex = (currentPresetIndex % #speedPresets) + 1
    else
        currentPresetIndex = currentPresetIndex - 1
        if currentPresetIndex < 1 then
            currentPresetIndex = #speedPresets
        end
    end
    
    setSpeed(speedPresets[currentPresetIndex])
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle speed
    if input.KeyCode == Enum.KeyCode.V then
        toggleSpeed()
    end
    
    -- Increase speed
    if input.KeyCode == Enum.KeyCode.PageUp then
        local newSpeed = math.min(currentSpeed + 10, 300)
        setSpeed(newSpeed)
    end
    
    -- Decrease speed
    if input.KeyCode == Enum.KeyCode.PageDown then
        local newSpeed = math.max(currentSpeed - 10, 1)
        setSpeed(newSpeed)
    end
    
    -- Cycle presets forward
    if input.KeyCode == Enum.KeyCode.RightBracket then
        cyclePreset(true)
    end
    
    -- Cycle presets backward
    if input.KeyCode == Enum.KeyCode.LeftBracket then
        cyclePreset(false)
    end
    
    -- Turbo boost (temporary speed)
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        local originalSpeed = currentSpeed
        setSpeed(originalSpeed * 2)
        
        spawn(function()
            wait(2)
            if currentSpeed == originalSpeed * 2 then
                setSpeed(originalSpeed)
            end
        end)
    end
end)

-- Apply speed on character spawn
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    
    wait(0.5) -- Wait for character to stabilize
    
    if speedEnabled then
        Humanoid.WalkSpeed = currentSpeed
        NotificationSystem:CreateNotification(
            "🔄 CHARACTER SPAWNED",
            "Speed re-applied: " .. currentSpeed,
            "info"
        )
    end
end)

-- Initial setup
setSpeed(currentSpeed)

-- Success notification
NotificationSystem:CreateNotification(
    "⚡ SPEEDHACK LOADED",
    "Controls:\nV: Toggle\nPageUp/Down: Adjust\n[/]: Presets\nAlt: Turbo Boost",
    "success"
)

print("✅ SpeedHack system loaded successfully!")
