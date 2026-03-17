local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Characters = RS:WaitForChild("Characters")

local function applyMorph(player)
	local char = player.Character
	if not char then return end
	
	local role = player:GetAttribute("Role")
	if not role then return end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	-- borrar accesorios y ropa
	for _,v in pairs(char:GetChildren()) do
		if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then
			v:Destroy()
		end
	end
	
	-- hacer invisible el cuerpo
	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
			v.CanCollide = false
		end
	end
	
	-- elegir modelo
	local model
	if role == "Killer" then
		model = Characters.Killers:FindFirstChild("Zombie")
	else
		model = Characters.Survivors:FindFirstChild("Ninja")
	end
	
	if not model then return end
	
	local clone = model:Clone()
	clone.Parent = char
	
	-- quitar humanoid del morph
	local hum = clone:FindFirstChildOfClass("Humanoid")
	if hum then hum:Destroy() end
	
	local root = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChildWhichIsA("BasePart")
	if not root then return end
	
	clone.PrimaryPart = root
	clone:SetPrimaryPartCFrame(hrp.CFrame)
	
	-- weld
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = hrp
	weld.Parent = root
end

-- Esto ES LA CLAVE
-- se aplica cuando cambia el role (cuando empieza la ronda)

Players.PlayerAdded:Connect(function(player)
	player:GetAttributeChangedSignal("Role"):Connect(function()
		task.wait(0.5) -- pequeño delay para tp
		applyMorph(player)
	end)
end)
