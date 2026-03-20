local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Characters = RS:WaitForChild("Characters")
local Killers = Characters:WaitForChild("Killers")
local Survivors = Characters:WaitForChild("Survivors")

local LOBBY_SPAWN = Workspace:FindFirstChild("LobbySpawn")
local LOBBY_RADIUS = 20
local MORPH_OFFSET = CFrame.new(0, -2.75, 0)

local function isInLobby(char)
	if not LOBBY_SPAWN or not char then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	return (hrp.Position - LOBBY_SPAWN.Position).Magnitude <= LOBBY_RADIUS
end

local function getCharacterReady(player)
	for _ = 1, 30 do
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			return char
		end
		task.wait(0.1)
	end
	return nil
end

local function removeMorph(player)
	local char = player.Character
	if not char then return end

	local oldMorph = char:FindFirstChild("Morph")
	if oldMorph then
		oldMorph:Destroy()
	end

	for _, obj in ipairs(char:GetChildren()) do
		if obj:GetAttribute("MorphItem") then
			obj:Destroy()
		end
	end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 0
			part.CanCollide = true
		end
	end
end

local function clearPlayerAppearance(char)
	for _, obj in ipairs(char:GetChildren()) do
		if obj:IsA("Accessory")
			or obj:IsA("Shirt")
			or obj:IsA("Pants")
			or obj:IsA("ShirtGraphic")
			or obj:IsA("CharacterMesh")
			or obj:IsA("BodyColors") then
			obj:Destroy()
		end
	end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 1
			part.CanCollide = false
			part.CastShadow = false
		end
	end
end

local function moveCosmeticsToCharacter(morphModel, char)
	for _, obj in ipairs(morphModel:GetChildren()) do
		if obj:IsA("Accessory")
			or obj:IsA("Shirt")
			or obj:IsA("Pants")
			or obj:IsA("ShirtGraphic")
			or obj:IsA("CharacterMesh")
			or obj:IsA("BodyColors") then

			local copy = obj:Clone()
			copy:SetAttribute("MorphItem", true)
			copy.Parent = char
			obj:Destroy()
		end
	end
end

local function weldMorphParts(morphModel, root)
	for _, part in ipairs(morphModel:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.Massless = true
		end
	end

	for _, part in ipairs(morphModel:GetDescendants()) do
		if part:IsA("BasePart") and part ~= root then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = part
			weld.Parent = root
		end
	end
end

local function applyMorph(player)
	local char = getCharacterReady(player)
	if not char then return end

	local role = player:GetAttribute("Role")
	if role ~= "Killer" and role ~= "Survivor" then
		removeMorph(player)
		return
	end

	-- espera a que ya no esté en lobby
	for _ = 1, 30 do
		if not isInLobby(char) then
			break
		end
		task.wait(0.1)
	end

	if isInLobby(char) then
		return
	end

	removeMorph(player)
	clearPlayerAppearance(char)

	local sourceModel
	if role == "Killer" then
		sourceModel = Killers:FindFirstChild("Zombie")
	else
		sourceModel = Survivors:FindFirstChild("Ninja")
	end

	if not sourceModel then
		warn("no se encontró el morph para " .. player.Name)
		return
	end

	local morph = sourceModel:Clone()
	morph.Name = "Morph"
	morph.Parent = char

	-- quitar scripts / humanoid del morph
	for _, obj in ipairs(morph:GetDescendants()) do
		if obj:IsA("Humanoid") or obj:IsA("Animator") or obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
			obj:Destroy()
		end
	end

	-- mover ropa/accesorios del morph al character para q sí se vean
	moveCosmeticsToCharacter(morph, char)

	local root = morph:FindFirstChild("HumanoidRootPart") or morph:FindFirstChildWhichIsA("BasePart")
	if not root then
		warn("el morph no tiene root")
		return
	end

	morph.PrimaryPart = root
	morph:PivotTo(char.HumanoidRootPart.CFrame * MORPH_OFFSET)

	weldMorphParts(morph, root)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = char.HumanoidRootPart
	weld.Parent = root
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		applyMorph(player)
	end)

	player:GetAttributeChangedSignal("Role"):Connect(function()
		task.wait(0.2)
		applyMorph(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		if player.Character then
			task.wait(0.2)
			applyMorph(player)
		end
	end)
end
