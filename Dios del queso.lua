-- aura queso GOD (manos con luz + cuerpo con aura)

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

-- =====================
-- LUZ AMARILLA EN MANOS
-- =====================
local function luzMano(mano)
    if not mano then return end

    local light = Instance.new("PointLight")
    light.Name = "QuesoLight"
    light.Color = Color3.fromRGB(255, 230, 90)
    light.Brightness = 4
    light.Range = 10
    light.Shadows = false
    light.Parent = mano
end

task.wait(1)

luzMano(char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
luzMano(char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"))

-- =====================
-- AURA EN TODO EL CUERPO
-- =====================
local root = char:WaitForChild("HumanoidRootPart")

local aura = Instance.new("ParticleEmitter")
aura.Name = "AuraQuesoBody"
aura.Texture = "rbxassetid://243660364"
aura.Rate = 60
aura.Lifetime = NumberRange.new(0.6, 1)
aura.Speed = NumberRange.new(0.5, 1)
aura.SpreadAngle = Vector2.new(360, 360)
aura.Size = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(1, 0)
}
aura.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80))
aura.LightEmission = 1
aura.Parent = root
