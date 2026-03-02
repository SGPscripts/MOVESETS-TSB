-- dios del queso (visual only, estilo GOJO)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function aplicarDiosDelQueso(char)
    local humanoid = char:WaitForChild("Humanoid")

    -- =========================
    -- SKIN (HumanoidDescription)
    -- =========================

    local desc = humanoid:GetAppliedDescription()

    -- >>> CAMBIAR ACA <<<
    desc.Shirt = 10250370539
    desc.Pants = 6187941992

    -- accesorios (IDS separados por coma)
    -- si tenes mas, seguilos poniendo asi
    desc.HatAccessory = "9063836052,957236629158"

    -- aplicar skin
    humanoid:ApplyDescription(desc)

    -- =========================
    -- AURA AMARILLA EN MANOS
    -- =========================

    task.wait(1) -- esperar q cargue el rig

    local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
    local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

    local function ponerAura(mano)
        if not mano then return end
        if mano:FindFirstChild("CheeseAura") then return end

        local p = Instance.new("ParticleEmitter")
        p.Name = "CheeseAura"
        p.Texture = "rbxassetid://243660364"
        p.Rate = 50
        p.Lifetime = NumberRange.new(0.6,1)
        p.Speed = NumberRange.new(0.5,1)
        p.Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0.6),
            NumberSequenceKeypoint.new(1,0)
        }
        p.Color = ColorSequence.new(Color3.fromRGB(255,220,60))
        p.LightEmission = 1
        p.Parent = mano
    end

    ponerAura(leftHand)
    ponerAura(rightHand)
end

-- aplicar al character actual
local char = player.Character or player.CharacterAdded:Wait()
aplicarDiosDelQueso(char)

-- reaplicar al respawnear
player.CharacterAdded:Connect(function(newChar)
    aplicarDiosDelQueso(newChar)
end)
