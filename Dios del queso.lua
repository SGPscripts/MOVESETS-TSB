-- DIOS DEL QUESO – avatar client-side (estilo GOJO)
-- ejecutalo con el personaje ya cargado

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- =========================
-- FORZAR R6 (CUADRADITO)
-- =========================
pcall(function()
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.RigType = Enum.HumanoidRigType.R6
    end
end)

-- =========================
-- LIMPIAR AVATAR
-- =========================
for _,v in pairs(char:GetChildren()) do
    if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then
        v:Destroy()
    end
end

-- =========================
-- ROPA BEAR (CLÁSICA)
-- =========================
local SHIRT_ID = 6187928493
local PANTS_ID = 6187941992

local shirt = Instance.new("Shirt")
shirt.ShirtTemplate = "rbxassetid://"..SHIRT_ID
shirt.Parent = char

local pants = Instance.new("Pants")
pants.PantsTemplate = "rbxassetid://"..PANTS_ID
pants.Parent = char

-- =========================
-- ACCESORIOS
-- =========================
local ACCESORIOS = {
    9063836052, -- cabeza bear
    9572366291  -- cheese aura
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

print("dios del queso cargado B)")
