local plr = game.Players.LocalPlayer

local function aplicarAura(char)
    -- =====================
    -- MANOS CON PARTICULAS
    -- =====================
    local function manosQueso(mano)
        if not mano then return end
        if mano:FindFirstChild("QuesoParticles") then return end

        local pe = Instance.new("ParticleEmitter")
        pe.Name = "QuesoParticles"
        pe.Texture = "rbxassetid://243660364"
        pe.Rate = 120
        pe.Lifetime = NumberRange.new(0.5, 1)
        pe.Speed = NumberRange.new(1.5, 3)
        pe.SpreadAngle = Vector2.new(360, 360)
        pe.Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1.5),
            NumberSequenceKeypoint.new(1, 0)
        }
        pe.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 120))
        }
        pe.LightEmission = 1
        pe.Parent = mano
    end

    manosQueso(char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
    manosQueso(char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"))

    -- =====================
    -- AURA GIGANTE CON LUZ
    -- =====================
    local root = char:WaitForChild("HumanoidRootPart")
    if root:FindFirstChild("AuraQueso") then return end

    local attachment = Instance.new("Attachment")
    attachment.Name = "AuraAttachment"
    attachment.Parent = root

    local pe = Instance.new("ParticleEmitter")
    pe.Name = "AuraQueso"
    pe.Texture = "rbxassetid://243660364"
    pe.Rate = 400
    pe.Lifetime = NumberRange.new(1.5, 2.5)
    pe.Speed = NumberRange.new(3, 5)
    pe.SpreadAngle = Vector2.new(360, 360)
    pe.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 5),
        NumberSequenceKeypoint.new(1, 0)
    }
    pe.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 150))
    }
    pe.LightEmission = 1
    pe.Parent = attachment

    -- LUZ POTENTE
    local light = Instance.new("PointLight")
    light.Name = "AuraLight"
    light.Color = Color3.fromRGB(255, 220, 90)
    light.Brightness = 10
    light.Range = 25
    light.Parent = root
end

if plr.Character then
    aplicarAura(plr.Character)
end

plr.CharacterAdded:Connect(aplicarAura)
