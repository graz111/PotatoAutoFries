
-- ==============================================
-- HighJump System with Custom Notifications
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

function NotificationSystem:CreateJumpNotification(height, type)
    local title = ""
    local message = ""
    local notifType = "info"
    local icon = "🦘"
    
    if type == "jump" then
        if height >= 200 then
            title = "🚀 SUPER JUMP!"
            message = "Jump height: " .. height .. " studs!"
            notifType = "warning"
            icon = "🚀"
        elseif height >= 100 then
            title = "🦘 HIGH JUMP"
            message = "Jump height: " .. height
            notifType = "info"
            icon = "🦘"
        else
            title = "👟 NORMAL JUMP"
            message = "Jump height: " .. height
            notifType = "info"
            icon = "👟"
        end
    elseif type == "change" then
        title = "⚙️ JUMP SETTINGS"
        message = "Jump power set to: " .. height
        notifType = "info"
        icon = "⚙️"
    elseif type == "error" then
        title = "❌ JUMP ERROR"
        message = "Jump power reset to default"
        notifType = "error"
        icon = "❌"
    end
    
    -- Create notification
    local ScreenGui = game:GetService("CoreGui"):FindFirstChild("JumpNotifications") or Instance.new("ScreenGui")
    ScreenGui.Name = "JumpNotifications"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local Notification = Instance.new("Frame")
    Notification.Name = "JumpNotification"
    Notification.Size = UDim2.new(0, 250, 0, 70)
    Notification.Position = UDim2.new(0.7, 0, 0.1, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Notification.BackgroundTransparency = 0.1
    Notification.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Notification
    
    -- Animated icon
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Position = UDim2.new(0, 10, 0.5, -25)
    Icon.BackgroundTransparency = 1
    Icon.Text = icon
    Icon.TextColor3 = Color3.fromRGB(155, 89, 182)
    Icon.TextSize = 24
    Icon.Font = Enum.Font.GothamBold
    Icon.TextYAlignment = Enum.TextYAlignment.Center
    Icon.Parent = Notification
    
    -- Bounce animation
    spawn(function()
        for i = 1, 3 do
            TweenService:Create(Icon, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 10, 0.5, -35)
            }):Play()
            wait(0.2)
            TweenService:Create(Icon, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 10, 0.5, -25)
            }):Play()
            wait(0.2)
        end
    end)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 170, 0, 25)
    TitleLabel.Position = UDim2.new(0, 70, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.white
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Notification
    
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(0, 170, 0, 30)
    MessageLabel.Position = UDim2.new(0, 70, 0, 30)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    MessageLabel.TextSize = 12
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.Parent = Notification
    
    -- Height indicator bar
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 170, 0, 3)
    Bar.Position = UDim2.new(0, 70, 1, -5)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Bar.BorderSizePixel = 0
    Bar.Parent = Notification
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(math.min(height / 300, 1), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    
    Notification.Parent = ScreenGui
    
    -- Animation
    Notification.Position = UDim2.new(0.7, 0, -0.1, 0)
    TweenService:Create(Notification, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.7, 0, 0.1, 0)
    }):Play()
    
    -- Auto-remove
    spawn(function()
        wait(3)
        TweenService:Create(Notification, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.7, 0, -0.1, 0)
        }):Play()
        wait(0.4)
        Notification:Destroy()
    end)
end

-- ===== HIGHJUMP SYSTEM =====
local DEFAULT_JUMP = 50
local currentJump = 120
local jumpEnabled = true
local jumpPresets = {50, 75, 120, 200, 300, 500}
local currentPresetIndex = 3

-- Jump Effects
local jumpEffects = {}

local function createJumpEffect(position)
    local effect = Instance.new("Part")
    effect.Name = "JumpEffect"
    effect.Size = Vector3.new(4, 0.1, 4)
    effect.Position = position
    effect.Transparency = 0.5
    effect.Color = Color3.fromRGB(155, 89, 182)
    effect.Material = Enum.Material.Neon
    effect.Anchored = true
    effect.CanCollide = false
    
    local ring = Instance.new("SelectionSphere")
    ring.Transparency = 0.7
    ring.Color3 = Color3.fromRGB(155, 89, 182)
    ring.Adornee = effect
    ring.Parent = effect
    
    table.insert(jumpEffects, effect)
    effect.Parent = workspace
    
    -- Animate ring
    spawn(function()
        for i = 1, 20 do
            if effect then
                effect.Size = Vector3.new(4 + i, 0.1, 4 + i)
                effect.Transparency = 0.5 + (i * 0.025)
                wait(0.05)
            end
        end
        effect:Destroy()
        table.remove(jumpEffects, table.find(jumpEffects, effect))
    end)
end

-- Set Jump Function
local function setJump(newJump)
    if not Humanoid or not Humanoid.Parent then return end
    
    currentJump = newJump
    Humanoid.JumpPower = newJump
    
    -- Update notification
    NotificationSystem:CreateJumpNotification(newJump, "change")
    
    -- Visual effect for high jumps
    if newJump >= 200 then
        local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- Add glow effect
            local glow = Instance.new("PointLight")
            glow.Name = "JumpGlow"
            glow.Color = Color3.fromRGB(255, 100, 100)
            glow.Range = 15
            glow.Brightness = 2
            glow.Parent = humanoidRootPart
        end
    else
        -- Remove glow if exists
        local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart and humanoidRootPart:FindFirstChild("JumpGlow") then
            humanoidRootPart.JumpGlow:Destroy()
        end
    end
end

-- Toggle Jump Function
local function toggleJump()
    jumpEnabled = not jumpEnabled
    
    if jumpEnabled then
        Humanoid.JumpPower = currentJump
        NotificationSystem:CreateJumpNotification(currentJump, "change")
    else
        Humanoid.JumpPower = DEFAULT_JUMP
        NotificationSystem:CreateJumpNotification(DEFAULT_JUMP, "error")
    end
end

-- Detect jumps
Humanoid.StateChanged:Connect(function(oldState, newState)
    if newState == Enum.HumanoidStateType.Jumping then
        -- Create jump effect
        local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            createJumpEffect(humanoidRootPart.Position)
            
            -- Show jump notification
            NotificationSystem:CreateJumpNotification(currentJump, "jump")
            
            -- Super jump effects
            if currentJump >= 200 then
                -- Screen shake effect
                local camera = workspace.CurrentCamera
                local originalPosition = camera.CFrame
                
                spawn(function()
                    for i = 1, 10 do
                        camera.CFrame = originalPosition * CFrame.new(
                            math.random(-0.5, 0.5),
                            math.random(-0.3, 0.3),
                            math.random(-0.5, 0.5)
                        )
                        wait(0.05)
                    end
                    camera.CFrame = originalPosition
                end)
            end
        end
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle jump
    if input.KeyCode == Enum.KeyCode.J then
        toggleJump()
    end
    
    -- Increase jump
    if input.KeyCode == Enum.KeyCode.Up then
        local newJump = math.min(currentJump + 25, 1000)
        setJump(newJump)
    end
    
    -- Decrease jump
    if input.KeyCode == Enum.KeyCode.Down then
        local newJump = math.max(currentJump - 25, 10)
        setJump(newJump)
    end
    
    -- Preset cycling
    if input.KeyCode == Enum.KeyCode.O then
        currentPresetIndex = (currentPresetIndex % #jumpPresets) + 1
        setJump(jumpPresets[currentPresetIndex])
    end
    
    if input.KeyCode == Enum.KeyCode.P then
        currentPresetIndex = currentPresetIndex - 1
        if currentPresetIndex < 1 then
            currentPresetIndex = #jumpPresets
        end
        setJump(jumpPresets[currentPresetIndex])
    end
    
    -- Super jump (hold space for charged jump)
    if input.KeyCode == Enum.KeyCode.Space then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local chargedJump = currentJump * 1.5
            Humanoid.JumpPower = chargedJump
            
            spawn(function()
                wait(0.5)
                Humanoid.JumpPower = currentJump
            end)
            
            NotificationSystem:CreateJumpNotification(chargedJump, "jump")
        end
    end
end)

-- Apply on character spawn
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    
    wait(0.5)
    
    if jumpEnabled then
        Humanoid.JumpPower = currentJump
        NotificationSystem:CreateJumpNotification(currentJump, "change")
    end
end)

-- Initial setup
setJump(currentJump)

-- Success notification
NotificationSystem:CreateJumpNotification(currentJump, "change")

print("✅ HighJump system loaded successfully!")
