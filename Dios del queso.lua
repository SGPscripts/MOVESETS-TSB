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

-- efectos hero hunter (golpe + dash)
-- solo visual + sonido custom

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()

local root = char:WaitForChild("HumanoidRootPart")

-- =====================
-- CONFIG
-- =====================
local GOLPE_SOUND_ID = "rbxassetid://101467951382277" -- <- poné tu id
local GOLPE_VOLUME = 7

local EFFECT_COLOR = Color3.fromRGB(255,255,255)

-- =====================
-- SONIDO GOLPE
-- =====================
local function playHitSound(parent)
    local s = Instance.new("Sound")
    s.Name = "HitSound"
    s.SoundId = GOLPE_SOUND_ID
    s.Volume = GOLPE_VOLUME
    s.PlayOnRemove = false
    s.Parent = parent
    s:Play()

    s.Ended:Connect(function()
        s:Destroy()
    end)
end

-- =====================
-- FLASH EN MANO
-- =====================
local function punchFlash(hand)
    if not hand then return end

    local light = Instance.new("PointLight")
    light.Color = EFFECT_COLOR
    light.Brightness = 8
    light.Range = 6
    light.Parent = hand

    task.delay(0.05, function()
        light:Destroy()
    end)
end

-- =====================
-- SHOCKWAVE PISO
-- =====================
local function groundRing(position)
    local ring = Instance.new("Part")
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = Enum.Material.Neon
    ring.Color = EFFECT_COLOR
    ring.Transparency = 0.35
    ring.Size = Vector3.new(1,0.2,1)
    ring.CFrame = CFrame.new(position) * CFrame.new(0,-2.8,0)
    ring.Parent = workspace

    task.spawn(function()
        for i = 1,10 do
            ring.Size += Vector3.new(1.4,0,1.4)
            ring.Transparency += 0.07
            task.wait(0.02)
        end
        ring:Destroy()
    end)
end

-- =====================
-- EFECTO GOLPE (CALL)
-- =====================
function HeroHunterHit()
    local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

    punchFlash(hand)
    groundRing(root.Position)
    playHitSound(hand or root)
end

-- =====================
-- DASH TRAIL
-- =====================
local function dashTrail()
    local att0 = Instance.new("Attachment", root)
    local att1 = Instance.new("Attachment", root)
    att1.Position = Vector3.new(0,0,-2)

    local trail = Instance.new("Trail")
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Lifetime = 0.15
    trail.Color = ColorSequence.new(EFFECT_COLOR)
    trail.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,0),
        NumberSequenceKeypoint.new(1,1)
    }
    trail.Parent = root

    task.delay(0.2, function()
        trail:Destroy()
        att0:Destroy()
        att1:Destroy()
    end)
end

-- =====================
-- DASH PARTICULAS
-- =====================
local function dashParticles()
    local emit = Instance.new("ParticleEmitter")
    emit.Texture = "rbxassetid://243660364"
    emit.Rate = 180
    emit.Lifetime = NumberRange.new(0.2,0.4)
    emit.Speed = NumberRange.new(5,8)
    emit.SpreadAngle = Vector2.new(180,180)
    emit.Color = ColorSequence.new(EFFECT_COLOR)
    emit.LightEmission = 1
    emit.Parent = root

    task.delay(0.15, function()
        emit.Enabled = false
        task.wait(0.25)
        emit:Destroy()
    end)
end

-- =====================
-- EFECTO DASH (CALL)
-- =====================
function HeroHunterDash()
    dashTrail()
    dashParticles()
end
