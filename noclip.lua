-- ==============================================
-- Noclip System with Custom Notifications
-- For Skitek Loader V3
-- ==============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ===== NOTIFICATION SYSTEM =====
local NotificationSystem = {}

function NotificationSystem:CreateNoclipNotification(enabled, mode)
    local title = enabled and "👻 NOCLIP ENABLED" or "🧱 NOCLIP DISABLED"
    local message = mode or (enabled and "You can walk through walls!" or "Collisions restored.")
    local color = enabled and Color3.fromRGB(155, 89, 182) or Color3.fromRGB(149, 165, 166)
    local icon = enabled and "👻" or "🧱"
    
    -- Create notification
    local ScreenGui = game:GetService("CoreGui"):FindFirstChild("NoclipNotifications") or Instance.new("ScreenGui")
    ScreenGui.Name = "NoclipNotifications"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local Notification = Instance.new("Frame")
    Notification.Name = "NoclipNotification"
    Notification.Size = UDim2.new(0, 280, 0, 80)
    Notification.Position = UDim2.new(0.5, -140, 0.9, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Notification.BackgroundTransparency = 0.1
    Notification.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Notification
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color
    Stroke.Thickness = 2
    Stroke.Parent = Notification
    
    -- Ghost effect for enabled
    local GhostIcon = Instance.new("TextLabel")
    GhostIcon.Size = UDim2.new(0, 50, 0, 50)
    GhostIcon.Position = UDim2.new(0, 15, 0.5, -25)
    GhostIcon.BackgroundTransparency = 1
    GhostIcon.Text = icon
    GhostIcon.TextColor3 = color
    GhostIcon.TextSize = 28
    GhostIcon.Font = Enum.Font.GothamBold
    GhostIcon.TextYAlignment = Enum.TextYAlignment.Center
    GhostIcon.Parent = Notification
    
    -- Ghost animation
    if enabled then
        spawn(function()
            while Notification.Parent do
                TweenService:Create(GhostIcon, TweenInfo.new(1), {
                    TextTransparency = 0.5
                }):Play()
                wait(1)
                TweenService:Create(GhostIcon, TweenInfo.new(1), {
                    TextTransparency = 0
                }):Play()
                wait(1)
            end
        end)
    end
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 0, 25)
    TitleLabel.Position = UDim2.new(0, 80, 0, 15)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.white
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Notification
    
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(0, 200, 0, 40)
    MessageLabel.Position = UDim2.new(0, 80, 0, 40)
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
    Notification.Position = UDim2.new(0.5, -140, 1.1, 0)
    TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -140, 0.9, 0)
    }):Play()
    
    -- Auto-remove
    spawn(function()
        wait(3)
        TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -140, 1.1, 0)
        }):Play()
        wait(0.5)
        Notification:Destroy()
    end)
end

-- ===== NOCLIP SYSTEM =====
local noclipEnabled = false
local noclipMode = "Standard" -- Standard, Ghost, Phase
local originalCollisions = {}

-- Store original collisions
local function storeCollisions()
    originalCollisions = {}
    
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCollisions[part] = part.CanCollide
            end
        end
    end
end

-- Apply noclip
local function applyNoclip()
    if not Character then return end
    
    if noclipEnabled then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                
                -- Visual effects based on mode
                if noclipMode == "Ghost" then
                    part.Transparency = 0.7
                    part.Material = Enum.Material.Glass
                elseif noclipMode == "Phase" then
                    part.Transparency = 0.9
                    part.Material = Enum.Material.ForceField
                end
            end
        end
        
        -- Add ghost trail effect
        if noclipMode == "Ghost" then
            local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local trail = Instance.new("Trail")
                trail.Color = ColorSequence.new(Color3.fromRGB(155, 89, 182))
                trail.Transparency = NumberSequence.new(0.7)
                trail.Lifetime = 0.5
                trail.Parent = humanoidRootPart
            end
        end
        
        NotificationSystem:CreateNoclipNotification(true, "Mode: " .. noclipMode)
        
    else
        -- Restore collisions
        for part, canCollide in pairs(originalCollisions) do
            if part and part.Parent then
                part.CanCollide = canCollide
                part.Transparency = 0
                part.Material = Enum.Material.Plastic
            end
        end
        
        -- Remove trail effects
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("Trail") then
                    part:Destroy()
                end
            end
        end
        
        NotificationSystem:CreateNoclipNotification(false)
    end
end

-- Toggle noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        storeCollisions()
    end
    
    applyNoclip()
end

-- Cycle modes
local function cycleMode()
    local modes = {"Standard", "Ghost", "Phase"}
    local currentIndex = table.find(modes, noclipMode) or 1
    
    noclipMode = modes[(currentIndex % #modes) + 1]
    
    if noclipEnabled then
        applyNoclip()
    end
    
    NotificationSystem:CreateNoclipNotification(noclipEnabled, "Mode changed to: " .. noclipMode)
end

-- Auto-noclip system
local noclipConnection

local function startAutoNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if noclipEnabled and Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle noclip
    if input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
        startAutoNoclip()
    end
    
    -- Cycle modes
    if input.KeyCode == Enum.KeyCode.M then
        cycleMode()
    end
    
    -- Quick toggle (hold)
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        if not noclipEnabled then
            noclipEnabled = true
            storeCollisions()
            applyNoclip()
            startAutoNoclip()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Quick toggle release
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        if noclipEnabled then
            noclipEnabled = false
            applyNoclip()
        end
    end
end)

-- Handle character changes
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    
    wait(0.5) -- Wait for character to load
    
    if noclipEnabled then
        storeCollisions()
        applyNoclip()
        startAutoNoclip()
        
        NotificationSystem:CreateNoclipNotification(true, "Re-applied after respawn")
    end
end)

-- Initial store
storeCollisions()

-- Success notification
NotificationSystem:CreateNoclipNotification(false, "Press N to toggle noclip\nM to change modes\nHold Alt for quick noclip")

print("✅ Noclip system loaded successfully!")
