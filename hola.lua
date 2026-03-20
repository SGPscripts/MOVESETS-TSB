local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Characters = RS:WaitForChild("Characters")

local function getCharacter(player)
	for i = 1, 20 do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			return player.Character
		end
		task.wait(0.2)
	end
	return nil
end

local function removeMorph(player)
	local char = player.Character
	if not char then return end
	
	for _,v in pairs(char:GetChildren()) do
		if v.Name == "Morph" then
			v:Destroy()
		end
	end
	
	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 0
		end
	end
end

local function applyMorph(player)
	local char = getCharacter(player)
	if not char then return end
	
	local role = player:GetAttribute("Role")
	if not role then return end
	
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	removeMorph(player)
	
	for _,v in pairs(char:GetChildren()) do
		if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then
			v:Destroy()
		end
	end
	
	for _,v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = 1
		end
	end
	
	local model
	if role == "Killer" then
		model = Characters.Killers:FindFirstChild("Zombie")
	else
		model = Characters.Survivors:FindFirstChild("Ninja")
	end
	
	if not model then return end
	
	local clone = model:Clone()
	clone.Name = "Morph"
	clone.Parent = char
	
	local hum = clone:FindFirstChildOfClass("Humanoid")
	if hum then hum:Destroy() end
	
	local root = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChildWhichIsA("BasePart")
	if not root then return end
	
	clone.PrimaryPart = root
	clone:SetPrimaryPartCFrame(hrp.CFrame)
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = hrp
	weld.Parent = root
end

--  CUANDO CAMBIA EL ROLE
Players.PlayerAdded:Connect(function(player)
	player:GetAttributeChangedSignal("Role"):Connect(function()
		task.wait(1) --  clave: esperar a que el tp termine
		
		if player:GetAttribute("Role") then
			applyMorph(player)
		else
			removeMorph(player)
		end
	end)
end)
