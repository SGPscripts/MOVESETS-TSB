-- dios del queso (visual only, no server) -- arreglo por santi

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")

local player = Players.LocalPlayer

-- >>> CAMBIAR ACA: poné tus IDs (solo numeros)
local SHIRT_ID = 10250370539    -- ejemplo: 10250370539
local PANTS_ID = 6187941992     -- ejemplo: 6187941992

local ACCESORIOS = {
    9063836052,   -- orejas bear (ej)
    957236629158, -- cabeza bear (ej)
    -- agregá mas separando con coma
}

-- funcion que aplica todo al personaje pasado
local function aplicarDiosDelQueso(char)
    if not char then return end

    -- manos (r6 o r15)
    local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
    local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

    -- ---- AURA: primero removemos si ya existe (para no duplicar)
    local function removerAura(mano)
        if not mano then return end
        local existing = mano:FindFirstChild("CheeseAura")
        if existing and existing:IsA("ParticleEmitter") then
            existing:Destroy()
        end
    end
    removerAura(leftHand)
    removerAura(rightHand)

    local function ponerAura(mano)
        if not mano then return end
        local p = Instance.new("ParticleEmitter")
        p.Name = "CheeseAura"
        p.Texture = "rbxassetid://243660364"
        p.Rate = 50
        p.Lifetime = NumberRange.new(0.6, 1)
        p.Speed = NumberRange.new(0.5, 1)
        p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
        p.Color = ColorSequence.new(Color3.fromRGB(255, 220, 60))
        p.LightEmission = 1
        p.Parent = mano
    end

    ponerAura(leftHand)
    ponerAura(rightHand)

    -- ---- ROPA: borramos la ropa vieja y ponemos la nueva
    for _,v in pairs(char:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") then
            v:Destroy()
        end
    end

    -- convertir a string rbxassetid://
    local shirt = Instance.new("Shirt")
    shirt.ShirtTemplate = "rbxassetid://" .. tostring(SHIRT_ID)
    shirt.Parent = char

    local pants = Instance.new("Pants")
    pants.PantsTemplate = "rbxassetid://" .. tostring(PANTS_ID)
    pants.Parent = char

    -- ---- ACCESORIOS: cargamos cada asset y lo parentamos (pcall por si falla)
    for _,id in pairs(ACCESORIOS) do
        -- seguridad: si un id no es numero, lo salteamos
        if typeof(id) ~= "number" then
            warn("[dios del queso] accesorio con id invalido:", tostring(id))
        else
            local ok, asset = pcall(function()
                return InsertService:LoadAsset(id)
            end)
            if ok and asset then
                -- buscá accesorios dentro del paquete y ponelos en el character
                for _,obj in pairs(asset:GetChildren()) do
                    if obj:IsA("Accessory") then
                        -- evitar duplicados: si ya existe un accesorio con el mismo nombre lo destruimos primero
                        local existing = char:FindFirstChild(obj.Name)
                        if existing and existing:IsA("Accessory") then
                            existing:Destroy()
                        end
                        obj.Parent = char
                    else
                        -- algunos paquetes traen modelos o parts; los ignoramos para no spawnear basura
                    end
                end
            else
                warn("[dios del queso] fallo al cargar accesorio id:", id)
            end
            -- pequeña pausa para evitar rate-limit raro
            task.wait(0.15)
        end
    end
end

-- aplicar al personaje actual (si ya esta cargado)
local char = player.Character or player.CharacterAdded:Wait()
aplicarDiosDelQueso(char)

-- reaplicar cada vez que respawneas
player.CharacterAdded:Connect(function(newChar)
    -- esperamos que se inicialice un poco
    newChar:WaitForChild("Humanoid", 5)
    aplicarDiosDelQueso(newChar)
end)
