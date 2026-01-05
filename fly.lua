-- ==============================================
-- Fly System with Custom Notifications
-- For Skitek Loader V3
-- ==============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ===== CUSTOM NOTIFICATION SYSTEM =====
local NotificationSystem = {}

function NotificationSystem:CreateNotification(title, message, type, duration)
    local notificationTypes = {
        success = {color = Color3.fromRGB(46, 204, 113), icon = "✅"},
        error = {color = Color3.fromRGB(231, 76, 60), icon = "❌"},
        warning = {color = Color3.fromRGB(241, 196, 15), icon = "⚠️"},
        info = {color = Color3.fromRGB(52, 152, 219), icon = "ℹ️"}
    }
    
    local config = notificationTypes[type] or notificationTypes.info
    
    -- Create ScreenGui if not exists
    local ScreenGui = game:GetService("CoreGui"):FindFirstChild("FlyNotifications") or Instance.new("ScreenGui")
    ScreenGui.Name = "FlyNotifications"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Notification Frame
    local Notification = Instance.new("Frame")
    Notification.Name = "FlyNotification"
    Notification.Size = UDim2.new(0, 300, 0, 80)
    Notification.Position = UDim2.new(0.5, -150, 0.1, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Notification.BackgroundTransparency = 0.1
    Notification.BorderSizePixel = 0
    Notification.ZIndex = 999
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Notification
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = config.color
    Stroke.Thickness = 2
    Stroke.Parent = Notification
    
    -- Icon
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 15, 0.5, -20)
    Icon.BackgroundTransparency = 1
    Icon.Text = config.icon
    Icon.TextColor3 = config.color
    Icon.TextSize = 24
    Icon.Font = Enum.Font.GothamBold
    Icon.TextYAlignment = Enum.TextYAlignment.Center
    Icon.Parent = Notification
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 0, 25)
    TitleLabel.Position = UDim2.new(0, 65, 0, 15)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.white
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Notification
    
    -- Message
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(0, 200, 0, 40)
    MessageLabel.Position = UDim2.new(0, 65, 0, 35)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    MessageLabel.TextSize = 12
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextWrapped = true
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.Parent = Notification
    
    Notification.Parent = ScreenGui
    
    -- Animation
    Notification.Position = UDim2.new(0.5, -150, 0, -100)
    TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.1, 0)
    }):Play()
    
    -- Auto-remove
    if duration then
        spawn(function()
            wait(duration)
            TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -150, 0, -100)
            }):Play()
            wait(0.5)
            Notification:Destroy()
        end)
    end
    
    return Notification
end

-- ===== FLY SYSTEM =====
local FLY_SPEED = 50
local FLY_TOGGLE_KEY = Enum.KeyCode.F
local FLY_MODE = "Normal" -- Normal, Hover, Jetpack
local flying = false
local bodyVelocity

-- Speed Control Variables
local currentSpeed = FLY_SPEED
local speedMultiplier = 1.0

-- Create Velocity Object
local function createFlyVelocity()
    if bodyVelocity then 
        bodyVelocity:Destroy() 
        bodyVelocity = nil
    end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyVelocity"
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.P = 1250
    
    -- Smooth start
    local startForce = Vector3.new(1000, 1000, 1000)
    bodyVelocity.MaxForce = startForce
    
    spawn(function()
        for i = 1, 10 do
            if bodyVelocity then
                bodyVelocity.MaxForce = startForce:Lerp(Vector3.new(9e9, 9e9, 9e9), i/10)
                wait(0.05)
            end
        end
    end)
    
    bodyVelocity.Parent = HumanoidRootPart
end

-- Toggle Fly Function
local function toggleFly()
    flying = not flying
    
    if flying then
        -- Enable fly
        createFlyVelocity()
        
        NotificationSystem:CreateNotification(
            "🚀 Flight System",
            "Flight enabled! Mode: " .. FLY_MODE .. "\nSpeed: " .. currentSpeed .. "\nControls: WASD + Space/Shift",
            "success",
            4
        )
        
        -- Add flight effects
        local particles = Instance.new("ParticleEmitter")
        particles.Name = "FlightParticles"
        particles.Color = ColorSequence.new(Color3.fromRGB(100, 150, 255))
        particles.Size = NumberSequence.new(0.2)
        particles.Lifetime = NumberRange.new(0.5)
        particles.Rate = 20
        particles.Speed = NumberRange.new(2)
        particles.Parent = HumanoidRootPart
        
    else
        -- Disable fly
        if bodyVelocity then 
            bodyVelocity:Destroy() 
            bodyVelocity = nil
        end
        
        -- Remove effects
        if HumanoidRootPart:FindFirstChild("FlightParticles") then
            HumanoidRootPart.FlightParticles:Destroy()
        end
        
        NotificationSystem:CreateNotification(
            "🛬 Flight System",
            "Flight disabled. Back to ground mode.",
            "info",
            3
        )
    end
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle flight
    if input.KeyCode == FLY_TOGGLE_KEY then
        toggleFly()
    end
    
    -- Speed control
    if input.KeyCode == Enum.KeyCode.Equals then
        currentSpeed = math.min(currentSpeed + 10, 200)
        NotificationSystem:CreateNotification(
            "⚡ Speed Increased",
            "Current speed: " .. currentSpeed,
            "info",
            1.5
        )
    end
    
    if input.KeyCode == Enum.KeyCode.Minus then
        currentSpeed = math.max(currentSpeed - 10, 10)
        NotificationSystem:CreateNotification(
            "🐢 Speed Decreased",
            "Current speed: " .. currentSpeed,
            "info",
            1.5
        )
    end
    
    -- Mode switching
    if input.KeyCode == Enum.KeyCode.M then
        if FLY_MODE == "Normal" then
            FLY_MODE = "Hover"
        elseif FLY_MODE == "Hover" then
            FLY_MODE = "Jetpack"
        else
            FLY_MODE = "Normal"
        end
        
        NotificationSystem:CreateNotification(
            "🔄 Flight Mode",
            "Switched to: " .. FLY_MODE .. " mode",
            "info",
            2
        )
    end
end)

-- Movement tracking
local keysPressed = {
    [Enum.KeyCode.W] = false,
    [Enum.KeyCode.S] = false,
    [Enum.KeyCode.A] = false,
    [Enum.KeyCode.D] = false,
    [Enum.KeyCode.Space] = false,
    [Enum.KeyCode.LeftShift] = false,
    [Enum.KeyCode.RightShift] = false
}

UserInputService.InputBegan:Connect(function(input)
    if keysPressed[input.KeyCode] ~= nil then
        keysPressed[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if keysPressed[input.KeyCode] ~= nil then
        keysPressed[input.KeyCode] = false
    end
end)

-- Main flight loop
RunService.Heartbeat:Connect(function(deltaTime)
    if not flying or not bodyVelocity or not HumanoidRootPart then return end
    
    local moveDirection = Vector3.new(0, 0, 0)
    
    -- Collect input
    if keysPressed[Enum.KeyCode.W] then 
        moveDirection = moveDirection + HumanoidRootPart.CFrame.LookVector 
    end
    if keysPressed[Enum.KeyCode.S] then 
        moveDirection = moveDirection - HumanoidRootPart.CFrame.LookVector 
    end
    if keysPressed[Enum.KeyCode.D] then 
        moveDirection = moveDirection + HumanoidRootPart.CFrame.RightVector 
    end
    if keysPressed[Enum.KeyCode.A] then 
        moveDirection = moveDirection - HumanoidRootPart.CFrame.RightVector 
    end
    if keysPressed[Enum.KeyCode.Space] then 
        moveDirection = moveDirection + Vector3.new(0, 1, 0) 
    end
    if keysPressed[Enum.KeyCode.LeftShift] or keysPressed[Enum.KeyCode.RightShift] then 
        moveDirection = moveDirection - Vector3.new(0, 1, 0) 
    end
    
    -- Apply mode-specific behavior
    if FLY_MODE == "Hover" then
        -- Auto-hover when no input
        if moveDirection.Magnitude == 0 then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            return
        end
    elseif FLY_MODE == "Jetpack" then
        -- Add upward force
        moveDirection = moveDirection + Vector3.new(0, 0.3, 0)
    end
    
    -- Calculate velocity
    if moveDirection.Magnitude > 0 then
        local velocity = moveDirection.Unit * currentSpeed
        
        -- Smooth acceleration
        local currentVel = bodyVelocity.Velocity
        local newVelocity = currentVel:Lerp(velocity, 8 * deltaTime)
        bodyVelocity.Velocity = newVelocity
    else
        -- Smooth deceleration
        bodyVelocity.Velocity = bodyVelocity.Velocity * 0.9
        if bodyVelocity.Velocity.Magnitude < 0.5 then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
    
    -- Particle effects based on speed
    if HumanoidRootPart:FindFirstChild("FlightParticles") then
        local particles = HumanoidRootPart.FlightParticles
        particles.Rate = math.clamp(currentSpeed * 0.5, 10, 50)
        particles.Speed = NumberRange.new(math.clamp(currentSpeed * 0.1, 1, 10))
    end
end)

-- Auto-disable on death
Character:GetPropertyChangedSignal("Parent"):Connect(function()
    if Character.Parent == nil then
        flying = false
        if bodyVelocity then bodyVelocity:Destroy() end
        NotificationSystem:CreateNotification(
            "💀 Flight System",
            "Flight disabled due to character reset",
            "warning",
            3
        )
    end
end)

-- Success notification
NotificationSystem:CreateNotification(
    "✈️ Fly System Loaded",
    "Press F to toggle flight\n+/- to adjust speed\nM to change modes",
    "success",
    5
)

print("✅ Fly system loaded successfully!")
