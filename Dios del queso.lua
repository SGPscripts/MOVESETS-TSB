local plr = game.Players.LocalPlayer

local function aplicarAura(char)
    -- =====================
    -- PARTICULAS EN MANOS
    -- =====================
    local function particulasMano(mano)
        if not mano then return end
        if mano:FindFirstChild("QuesoParticles") then return end

        local pe = Instance.new("ParticleEmitter")
        pe.Name = "QuesoParticles"
        pe.Texture = "rbxassetid://243660364"
        pe.Rate = 80
        pe.Lifetime = NumberRange.new(0.5, 1)
        pe.Speed = NumberRange.new(1, 2)
        pe.SpreadAngle = Vector2.new(360, 360)
        pe.Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1.5),
            NumberSequenceKeypoint.new(1, 0)
        }
        pe.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 150))
        }
        pe.LightEmission = 1
        pe.Parent = mano
    end

    particulasMano(char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
    particulasMano(char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"))

    -- =====================
    -- AURA POTENTE CUERPO
    -- =====================
    local root = char:WaitForChild("HumanoidRootPart")
    if root:FindFirstChild("AuraQuesoBody") then return end

    local aura = Instance.new("ParticleEmitter")
    aura.Name = "AuraQuesoBody"
    aura.Texture = "rbxassetid://243660364" -- puedes cambiar a un asset más flashy si querés
    aura.Rate = 300
    aura.Lifetime = NumberRange.new(1.2, 2)
    aura.Speed = NumberRange.new(2, 4)
    aura.SpreadAngle = Vector2.new(360, 360)
    aura.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 3),
        NumberSequenceKeypoint.new(1, 0)
    }
    aura.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 120))
    }
    aura.LightEmission = 1
    aura.RotSpeed = NumberRange.new(100, 200)
    aura.Parent = root
end

if plr.Character then
    aplicarAura(plr.Character)
end

plr.CharacterAdded:Connect(aplicarAura)
