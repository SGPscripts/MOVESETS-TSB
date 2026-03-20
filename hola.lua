local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local roundEvent = ReplicatedStorage:WaitForChild("RoundEvent")
local characters = ReplicatedStorage:WaitForChild("Characters")

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
			v.CanCollide = true
		end
	end
end

local function applyMorph(player)
	local char = player.Character
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
		model = characters.Killers:FindFirstChild("Zombie")
	else
		model = characters.Survivors:FindFirstChild("Ninja")
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

--  ESCUCHAR RONDA
roundEvent.OnClientEvent:Connect(function(type)
	if type == "RoundStart" then
		for _,player in pairs(Players:GetPlayers()) do
			task.wait(0.2)
			applyMorph(player)
		end
	elseif type == "RoundEnd" then
		for _,player in pairs(Players:GetPlayers()) do
			removeMorph(player)
		end
	end
end)
