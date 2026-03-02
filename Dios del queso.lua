local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

-- colores
local AURA_COLOR = Color3.fromRGB(255,220,80) -- queso
local HAND_COLOR = Color3.fromRGB(255,230,90)

-- =====================
-- LUZ + PARTICULAS EN MANOS
-- =====================
local function setupHand(hand)
    if not hand then return end

    -- luz
    local light = Instance.new("PointLight")
    light.Name = "QuesoLight"
    light.Color = HAND_COLOR
    light.Brightness = 6
    light.Range = 12
    light.Shadows = false
    light.Parent = hand

    -- partículas
    local partEmit = Instance.new("ParticleEmitter")
    partEmit.Name = "QuesoHandsParticles"
    partEmit.Texture = "rbxassetid://243660364"
    partEmit.Rate = 80
    partEmit.Lifetime = NumberRange.new(0.4, 0.8)
    partEmit.Speed = NumberRange.new(1,2)
    partEmit.SpreadAngle = Vector2.new(360,360)
    partEmit.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    }
    partEmit.Color = ColorSequence.new(HAND_COLOR)
    partEmit.LightEmission = 1
    partEmit.Parent = hand
end

setupHand(char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
setupHand(char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"))

-- =====================
-- AURA POTENTE EN TORSO
-- =====================
local root = char:FindFirstChild("HumanoidRootPart")
if root then
    local auraPart = Instance.new("Part")
    auraPart.Name = "AuraQuesoBody"
    auraPart.Anchored = true
    auraPart.CanCollide = false
    auraPart.Transparency = 1
    auraPart.Size = Vector3.new(1,1,1)
    auraPart.CFrame = root.CFrame
    auraPart.Parent = char

    -- luz gigante
    local light = Instance.new("PointLight")
    light.Name = "AuraLight"
    light.Color = AURA_COLOR
    light.Brightness = 10
    light.Range = 25
    light.Shadows = false
    light.Parent = auraPart

    -- partículas enormes
    local aura = Instance.new("ParticleEmitter")
    aura.Name = "AuraParticles"
    aura.Texture = "rbxassetid://243660364"
    aura.Rate = 120
    aura.Lifetime = NumberRange.new(0.8,1.5)
    aura.Speed = NumberRange.new(1,3)
    aura.SpreadAngle = Vector2.new(360,360)
    aura.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 2),
        NumberSequenceKeypoint.new(1, 0)
    }
    aura.Color = ColorSequence.new(AURA_COLOR)
    aura.LightEmission = 1
    aura.Parent = auraPart

    -- mover el aura con el root
    RunService.RenderStepped:Connect(function()
        if root and auraPart then
            auraPart.CFrame = root.CFrame
        end
    end)
end

local Players = game:GetService("Players")
local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local head = char:WaitForChild("Head") -- donde vamos a poner el sonido

-- crear el sonido
local cheeseSound = Instance.new("Sound")
cheeseSound.Name = "GIMME THE CHEESE"
cheeseSound.SoundId = "rbxassetid://140183508936964" -- pon tu ID
cheeseSound.Volume = 1 -- bien fuerte XD
cheeseSound.PlayOnRemove = false
cheeseSound.Looped = false
cheeseSound.Parent = head

-- reproducir apenas se ejecute
cheeseSound:Play()
