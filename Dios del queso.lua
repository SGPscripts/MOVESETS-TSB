-- dios del queso – morph estilo GOJO (FIXED)
-- visual only

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

-- ==== TUS IDS ====
local SHIRT_ID = 6187928493
local PANTS_ID = 6187941992
local ACCESSORIES = "9063836052,9572366291" -- cabeza bear, cheese aura
-- =================

-- humanoid description LIMPIO
local desc = Instance.new("HumanoidDescription")

desc.Shirt = SHIRT_ID
desc.Pants = PANTS_ID

-- SOLO props compatibles (como GOJO)
desc.HatAccessory = ACCESSORIES
desc.HairAccessory = ACCESSORIES
desc.FaceAccessory = ACCESSORIES
desc.NeckAccessory = ACCESSORIES

-- forzar r6 (opcional pero ayuda)
pcall(function()
	hum.RigType = Enum.HumanoidRigType.R6
end)

-- aplicar varias veces (anti reset TSB)
for i = 1, 15 do
	pcall(function()
		hum:ApplyDescription(desc)
	end)
	task.wait(0.15)
end

-- reaplicar despues (como GOJO)
task.delay(1.2, function()
	for i = 1, 8 do
		pcall(function()
			hum:ApplyDescription(desc)
		end)
		task.wait(0.2)
	end
end)

print("dios del queso aplicado correctamente :D")
