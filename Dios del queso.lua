-- dios del queso (visual only, no server)

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- =========================
-- AURA AMARILLA EN MANOS
-- =========================

local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

local function ponerAura(mano)
    if not mano then return end

    local p = Instance.new("ParticleEmitter")
    p.Name = "CheeseAura"
    p.Texture = "rbxassetid://243660364"
    p.Rate = 50
    p.Lifetime = NumberRange.new(0.6, 1)
    p.Speed = NumberRange.new(0.5, 1)
    p.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 0)
    })
    p.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60))
    p.LightEmission = 1
    p.Parent = mano
end

ponerAura(leftHand)
ponerAura(rightHand)

-- =========================
-- CAMBIO DE ROPA (BEAR)
-- =========================

-- borra la ropa q ya tenés
for _,v in pairs(char:GetChildren()) do
    if v:IsA("Shirt") or v:IsA("Pants") then
        v:Destroy()
    end
end

-- >>> CAMBIAR ACA <<<
local SHIRT_ID = 10250370539   -- poné el ID NUMERO de tu shirt
local PANTS_ID = 6187941992  -- poné el ID NUMERO de tus pants

local shirt = Instance.new("Shirt")
shirt.ShirtTemplate = "rbxassetid://" .. SHIRT_ID
shirt.Parent = char

local pants = Instance.new("Pants")
pants.PantsTemplate = "rbxassetid://" .. PANTS_ID
pants.Parent = char

-- =========================
-- ACCESORIOS BEAR
-- =========================

-- >>> CAMBIAR ACA <<<
-- aca van LOS IDS DE LOS ACCESORIOS (solo numeros)
local ACCESORIOS = {
    9063836052
    957236629158 -- accesorio 2 (ej: cabeza bear)
}

for _,id in pairs(ACCESORIOS) do
    local ok,asset = pcall(function()
        return InsertService:LoadAsset(id)
    end)
    if ok and asset then
        for _,obj in pairs(asset:GetChildren()) do
            if obj:IsA("Accessory") then
                obj.Parent = char
            end
        end
    end
end
