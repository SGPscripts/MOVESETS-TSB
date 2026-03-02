-- dios del queso – morph copia literal de GOJO
-- visual only

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

-- ===== TUS IDS =====
local SHIRT_ID = 6187928493
local PANTS_ID = 6187941992
local ACCESSORIES = "9063836052,9572366291" -- cabeza bear, cheese aura
-- ===================

-- crear description LIMPIA (clave)
local desc = Instance.new("HumanoidDescription")

desc.Shirt = SHIRT_ID
desc.Pants = PANTS_ID

-- GOJO-style: poner accesorios en TODAS las categorias
desc.HatAccessory = ACCESSORIES
desc.HairAccessory = ACCESSORIES
desc.FaceAccessory = ACCESSORIES
desc.NeckAccessory = ACCESSORIES
desc.ShoulderAccessory = ACCESSORIES
desc.FrontAccessory = ACCESSORIES
desc.BackAccessory = ACCESSORIES
desc.WaistAccessory = ACCESSORIES

-- fuerza r6 como hacen muchos scripts
pcall(function()
	hum.RigType = Enum.HumanoidRigType.R6
end)

-- aplicar MUCHAS veces (esto es lo importante)
for i = 1, 20 do
	pcall(function()
		hum:ApplyDescription(desc)
	end)
	task.wait(0.15)
end

-- reaplicar unos segundos después (anti TSB reset)
task.delay(1.5, function()
	for i = 1, 10 do
		pcall(function()
			hum:ApplyDescription(desc)
		end)
		task.wait(0.2)
	end
end)

print("dios del queso morph aplicado")
