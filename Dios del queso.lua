-- dios del queso (morph estilo GOJO) - visual only
-- ejecutalo con el personaje ya cargado. si queres cambiar algo, editá las constantes abajo.

-- toggle (copiado estilo GOJO): si lo queres desactivar pon false
getgenv().cheeseMorph = true

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===== CAMBIAR ACA (ids que me pasaste) =====
local SHIRT_ID = 6187928493    -- camisa clásica (bear)
local PANTS_ID = 6187941992    -- pantalón clásico (bear)
-- accesorios (en una sola string, separados por comas, SIN "rbxassetid://")
local ACCESSORIES_STRING = "9063836052,9572366291" -- cabeza bear, cheese aura
-- ============================================

local function safeApplyDescription(humanoid, desc)
    -- intenta varias veces por si tsb pisa el avatar al spawnear
    for i = 1, 6 do
        local ok, err = pcall(function()
            humanoid:ApplyDescription(desc)
        end)
        if ok then
            return true
        end
        task.wait(0.25)
    end
    return false
end

local function ponerAuraEnManos(char)
    local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
    local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

    local function crear(mano)
        if not mano then return end
        if mano:FindFirstChild("CheeseAura") then return end

        local p = Instance.new("ParticleEmitter")
        p.Name = "CheeseAura"
        p.Texture = "rbxassetid://243660364"
        p.Rate = 50
        p.Lifetime = NumberRange.new(0.6, 1)
        p.Speed = NumberRange.new(0.5, 1)
        p.Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(1, 0)
        }
        p.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60))
        p.LightEmission = 1
        p.Parent = mano
    end

    crear(leftHand)
    crear(rightHand)
end

local function aplicarMorph(char)
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    -- crear o tomar description base
    local desc
    local ok, got = pcall(function() return humanoid:GetAppliedDescription() end)
    if ok and got then
        desc = got
    else
        desc = Instance.new("HumanoidDescription")
    end

    -- definir cosas básicas
    -- nota: usamos numeros para shirt/pants como en algunos scripts GOJO-style
    desc.Shirt = SHIRT_ID
    desc.Pants = PANTS_ID

    -- accesorios en una linea (string con ids separados por coma)
    if type(ACCESSORIES_STRING) == "string" and ACCESSORIES_STRING ~= "" then
        desc.HatAccessory = ACCESSORIES_STRING
        desc.HairAccessory = ACCESSORIES_STRING
        desc.FaceAccessory = ACCESSORIES_STRING
        desc.NeckAccessory = ACCESSORIES_STRING
        desc.ShoulderAccessory = ACCESSORIES_STRING
        desc.FrontAccessory = ACCESSORIES_STRING
        desc.BackAccessory = ACCESSORIES_STRING
        desc.WaistAccessory = ACCESSORIES_STRING
    end

    -- aplicamos la desc (con reintentos)
    local applied = safeApplyDescription(humanoid, desc)
    if not applied then
        warn("[dios del queso] no se pudo aplicar description (tsb pudo pisar). Intentá re-ejecutar el script o ejecutar justo despues de spawnear.")
    end

    -- esperar un poco y poner aura local en manos
    task.delay(0.6, function() ponerAuraEnManos(char) end)
end

-- aplica al char actual y se reconecta al respawn
local function bindCharacter(c)
    task.spawn(function()
        -- aguantar a que humaoid y rig carguen
        c:WaitForChild("Humanoid", 5)
        task.wait(0.45)
        if getgenv().cheeseMorph then
            aplicarMorph(c)
        else
            -- si el user desactiva morph, igual colocamos aura y devolvemos
            ponerAuraEnManos(c)
        end
    end)
end

local char = player.Character or player.CharacterAdded:Wait()
bindCharacter(char)

player.CharacterAdded:Connect(function(newChar)
    bindCharacter(newChar)
end)

print("dios del queso: script cargado :D")
