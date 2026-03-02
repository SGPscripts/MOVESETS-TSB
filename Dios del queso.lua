-- dios del queso (morph reforzado estilo GOJO) - visual only
-- ejecutalo con el personaje ya spawneado

getgenv().cheeseMorph = true -- poner false si no querés morph automatico

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ====== CAMBIAR ACA (ids que me pasaste) ======
local SHIRT_ID = 6187928493    -- camisa clásica (bear)
local PANTS_ID = 6187941992    -- pantalón clásico (bear)
-- accesorios en una sola string, separados por comas, SIN "rbxassetid://"
local ACCESSORIES_STRING = "9063836052,9572366291" -- cabeza bear, cheese aura
-- ==============================================

-- helpers
local function split(s, sep)
    local out = {}
    for token in string.gmatch(s, "([^" .. sep .. "]+)") do
        token = token:gsub("^%s*(.-)%s*$", "%1")
        if token ~= "" then table.insert(out, token) end
    end
    return out
end

local function countExpectedAccessories()
    if not ACCESSORIES_STRING or ACCESSORIES_STRING == "" then return 0 end
    return #split(ACCESSORIES_STRING, ",")
end

local function has_shirt_pants_applied(char)
    local shirt = char:FindFirstChildOfClass("Shirt")
    local pants = char:FindFirstChildOfClass("Pants")
    local okShirt = false
    local okPants = false
    if shirt and shirt.ShirtTemplate then
        okShirt = tostring(SHIRT_ID) == tostring((shirt.ShirtTemplate:gsub("rbxassetid://", "")))
    end
    if pants and pants.PantsTemplate then
        okPants = tostring(PANTS_ID) == tostring((pants.PantsTemplate:gsub("rbxassetid://", "")))
    end
    return okShirt and okPants
end

local function count_current_accessories(char)
    local c = 0
    for _,v in pairs(char:GetChildren()) do
        if v:IsA("Accessory") then c = c + 1 end
    end
    return c
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

-- aplica humanoiddescription con reintentos y checks
local function applyDescriptionWithChecks(char)
    if not char then return false end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return false end

    local expectedAcc = countExpectedAccessories()

    local desc
    local ok, got = pcall(function() return humanoid:GetAppliedDescription() end)
    if ok and got then
        desc = got
    else
        desc = Instance.new("HumanoidDescription")
    end

    -- setear ropa (usar numeros)
    desc.Shirt = SHIRT_ID
    desc.Pants = PANTS_ID

    -- setear accesorios: lo ponemos en todas las propiedades de accessory para que salga seguro
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

    -- intentar aplicar varias veces y comprobar resultado
    local success = false
    for i = 1, 12 do -- reintentar ~12 veces (3s)
        local applied = false
        local okApply, err = pcall(function()
            humanoid:ApplyDescription(desc)
            applied = true
        end)
        task.wait(0.18)

        -- checks: shirt+pants + accesorios (si esperamos accesorios)
        local clothesOk = has_shirt_pants_applied(char)
        local accOk = true
        if expectedAcc > 0 then
            local curAcc = count_current_accessories(char)
            accOk = (curAcc >= expectedAcc)
        end

        if applied and clothesOk and accOk then
            success = true
            break
        end
        -- si no salió, reintentamos
    end

    return success
end

-- aplica y monitorea por un tiempo corto para reaplicar si tsb pisa
local function robustApplyAndMonitor(char)
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    local ok = applyDescriptionWithChecks(char)
    ponerAuraEnManos(char)

    -- monitoreo por ~6 segundos: si el shirt/pants desaparecen o accesorios bajan, re-aplicamos una vez
    local monitorTime = 6
    local checkInterval = 0.4
    local elapsed = 0
    local reattempted = false
    while elapsed < monitorTime do
        task.wait(checkInterval)
        elapsed = elapsed + checkInterval

        local clothesOk = has_shirt_pants_applied(char)
        local expectedAcc = countExpectedAccessories()
        local accOk = true
        if expectedAcc > 0 then
            accOk = (count_current_accessories(char) >= expectedAcc)
        end

        if not clothesOk or not accOk then
            if not reattempted then
                -- intentar reaplicar rápido
                applyDescriptionWithChecks(char)
                ponerAuraEnManos(char)
                reattempted = true
            end
        end
    end

    return ok
end

-- bind al character y respawn
local function bindCharacter(c)
    task.spawn(function()
        c:WaitForChild("Humanoid", 5)
        task.wait(0.35)
        if getgenv().cheeseMorph then
            local ok = robustApplyAndMonitor(c)
            if not ok then
                warn("[dios del queso] no se pudo asegurar morph 100%. Probá re-ejecutar justo despues de spawnear.")
            end
        else
            ponerAuraEnManos(c)
        end
    end)
end

local char = player.Character or player.CharacterAdded:Wait()
bindCharacter(char)
player.CharacterAdded:Connect(function(newChar)
    bindCharacter(newChar)
end)

print("dios del queso (reforzado) cargado :D")
