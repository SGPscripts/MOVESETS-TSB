-- aura amarilla simple (solo visual)

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

local function aura(mano)
    if not mano then return end

    local p = Instance.new("ParticleEmitter")
    p.Name = "AuraQueso"
    p.Texture = "rbxassetid://243660364"
    p.Rate = 35
    p.Lifetime = NumberRange.new(0.5, 0.9)
    p.Speed = NumberRange.new(0.3, 0.8)
    p.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 0)
    }
    p.Color = ColorSequence.new(Color3.fromRGB(255, 230, 80))
    p.LightEmission = 1
    p.Parent = mano
end

task.wait(1)

aura(char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
aura(char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"))
