local plr = game.Players.LocalPlayer

local function aplicarAura(char)
    -- =====================
    -- LUZ LOCALIZADA EN MANOS
    -- =====================
    local function luzMano(mano)
        if not mano then return end
        if mano:FindFirstChild("QuesoLight") then return end

        local light = Instance.new("SurfaceLight")
        light.Name = "QuesoLight"
        light.Face = Enum.NormalId.Top
        light.Color = Color3.fromRGB(255, 230, 90)
        light.Brightness = 2
        light.Range = 4
        light.Angle = 90
        light.Parent = mano
    end

    luzMano(char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
    luzMano(char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"))

    -- =====================
    -- AURA POTENCIADA EN CUERPO
    -- =====================
    local root = char:WaitForChild("HumanoidRootPart")
    if root:FindFirstChild("AuraQuesoBody") then return end

    local aura = Instance.new("ParticleEmitter")
    aura.Name = "AuraQuesoBody"
    aura.Texture = "rbxassetid://243660364" -- podés cambiar por otro asset de partículas más flashy
    aura.Rate = 150 -- muchas más partículas
    aura.Lifetime = NumberRange.new(1, 1.5)
    aura.Speed = NumberRange.new(1, 2)
    aura.SpreadAngle = Vector2.new(360, 360)
    aura.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 2),
        NumberSequenceKeypoint.new(1, 0)
    }
    aura.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 150))
    }
    aura.LightEmission = 1
    aura.RotSpeed = NumberRange.new(50, 100)
    aura.Parent = root
end

if plr.Character then
    aplicarAura(plr.Character)
end

plr.CharacterAdded:Connect(aplicarAura)
