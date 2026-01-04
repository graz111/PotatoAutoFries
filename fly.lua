

-- This would be in your GitHub repository as Fly.lua
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local FLY_SPEED = 50
local FLY_KEY = Enum.KeyCode.F
local flying = false
local bodyVelocity

local function createFlyVelocity()
    if bodyVelocity then bodyVelocity:Destroy() end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = HumanoidRootPart
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == FLY_KEY then
        flying = not flying
        
        if flying then
            createFlyVelocity()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Fly System",
                Text = "Flight enabled! Use WASD + Space/Shift",
                Duration = 3
            })
        else
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if flying and bodyVelocity then
        local direction = Vector3.new(0, 0, 0)
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + HumanoidRootPart.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - HumanoidRootPart.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + HumanoidRootPart.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction - HumanoidRootPart.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
        
        if direction.Magnitude > 0 then
            bodyVelocity.Velocity = direction.Unit * FLY_SPEED
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

print("✅ Fly system loaded from GitHub!")
]]

