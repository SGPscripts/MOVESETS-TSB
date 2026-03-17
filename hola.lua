-- MorphSystem (ServerScriptService)
-- Aplica "skin encima" tipo morph: quita accesorios y ropa, hace el cuerpo invisible
-- y coloca el modelo (Ninja o Zombie) atado al HumanoidRootPart.
-- Requisitos mínimos:
--  ReplicatedStorage.Characters.Killers.<Zombie>
--  ReplicatedStorage.Characters.Survivors.<Ninja>

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- buscar carpeta Characters en ReplicatedStorage, si no está buscar en ServerStorage como fallback
local characters = ReplicatedStorage:FindFirstChild("Characters")
if not characters then
	local ServerStorage = game:GetService("ServerStorage")
	characters = ServerStorage:FindFirstChild("Characters")
	if characters then
		warn("MorphSystem: Characters encontrado en ServerStorage. se recomienda moverlo a ReplicatedStorage para mejor performance.")
	else
		error("MorphSystem: no se encontró carpeta 'Characters' en ReplicatedStorage ni ServerStorage.")
	end
end

local killersFolder = characters:FindFirstChild("Killers")
local survivorsFolder = characters:FindFirstChild("Survivors")

local DEFAULT_SURVIVOR = "Ninja"
local DEFAULT_KILLER = "Zombie"

local function clearAppearance(char)
	-- elimina accesorios y ropa, hace las partes transparentes y no colisionables
	for _, obj in ipairs(char:GetChildren()) do
		-- destruir accesorios para evitar superposiciones
		if obj:IsA("Accessory") then
			pcall(function() obj:Destroy() end)
		-- destruir Shirt / Pants para que no se vean
		elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("CharacterMesh") then
			pcall(function() obj:Destroy() end)
		-- BodyColors / BodyGyro etc podemos dejar, pero mejor ocultar partes
		end
	end

	-- hacer invisibles todas las BaseParts (mantener HumanoidRootPart si querés, pero suele ser invisible)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			-- no tocar joints ni constraints (solo propiedades visuales/físicas)
			pcall(function()
				part.Transparency = 1
				part.CanCollide = false
			end)
		elseif part:IsA("Decal") then
			-- ocultar decals (caras, etc)
			pcall(function() part.Transparency = 1 end)
		end
	end
end

local function sanitizeMorphModel(model)
	-- eliminar humanoids, animators y scripts del modelo para evitar conflictos
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("Humanoid") or obj:IsA("Animator") then
			pcall(function() obj:Destroy() end)
		elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
			-- opcional: eliminar scripts para seguridad
			pcall(function() obj:Destroy() end)
		end
	end
end

local function weldModelToHRP(clone, hrp)
	if not clone or not hrp then return end

	-- asegurar primary part
	local prim = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChildWhichIsA("BasePart")
	if not prim then
		-- si no hay basepart, intentar asignar la primera basepart
		for _,v in ipairs(clone:GetDescendants()) do
			if v:IsA("BasePart") then
				prim = v
				break
			end
		end
	end
	if not prim then
		warn("MorphSystem: el modelo clon no tiene BasePart para weld.")
		return
	end

	-- posicionar el morph exactamente donde está el hrp
	pcall(function()
		clone:SetPrimaryPartCFrame(hrp.CFrame)
	end)

	-- desactivar colisiones del morph
	for _, part in ipairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				part.CanCollide = false
			end)
		end
	end

	-- crear WeldConstraint entre primary parts
	local weld = Instance.new("WeldConstraint")
	weld.Name = "MorphWeld"
	weld.Part0 = prim
	weld.Part1 = hrp
	weld.Parent = prim

	-- opcional: también crear AlignPosition/AlignOrientation para servers con física problemática
	-- (no obligatorio; si notas jitter, podemos añadir Aligns después)
end

local function applyMorph(player, role)
	if not player then return end
	local char = player.Character
	if not char then return end

	-- asegurar humanoidrootpart
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChildWhichIsA("BasePart")
	if not hrp then
		warn("MorphSystem: "..player.Name.." no tiene HumanoidRootPart en su character.")
		return
	end

	-- limpiar apariencia del jugador
	clearAppearance(char)

	-- elegir modelo
	local model
	if role == "Killer" then
		local name = player:GetAttribute("EquippedCharacter") or DEFAULT_KILLER
		if killersFolder then model = killersFolder:FindFirstChild(name) or killersFolder:FindFirstChild(DEFAULT_KILLER) end
	else
		local name = player:GetAttribute("EquippedCharacter") or DEFAULT_SURVIVOR
		if survivorsFolder then model = survivorsFolder:FindFirstChild(name) or survivorsFolder:FindFirstChild(DEFAULT_SURVIVOR) end
	end
	if not model then
		warn("MorphSystem: no se encontró modelo para "..tostring(role).." ("..tostring(player.Name)..")")
		return
	end

	-- clonar y sanitizar
	local clone = model:Clone()
	clone.Name = "Morph_"..player.Name

	-- quitar humanoid/animator/scripts para evitar conflictos
	sanitizeMorphModel(clone)

	-- parentear el morph dentro del character para orden (también podría ir en workspace)
	clone.Parent = char

	-- asegurar primarypart
	local prim = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChildWhichIsA("BasePart")
	if prim and not clone.PrimaryPart then
		clone.PrimaryPart = prim
	end

	-- weld al humanoidrootpart
	weldModelToHRP(clone, hrp)
end

-- evento principal: cuando aparece el character aplicamos morph
local function onCharacterAdded(player, char)
	-- esperar un poco para que RoundManager teleporte y asigne Role
	task.wait(0.25)

	-- esperar a que role exista (timeout corto)
	local role = player:GetAttribute("Role")
	if not role then
		for i = 1, 10 do
			task.wait(0.15)
			role = player:GetAttribute("Role")
			if role then break end
		end
	end
	if not role then
		-- no hay role asignado -> no morph
		return
	end

	-- aplicar morph
	pcall(function()
		applyMorph(player, role)
	end)
end

-- conectar jugadores
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(char)
		onCharacterAdded(player, char)
	end)

	-- si ya tiene char (rejoin), aplicarlo
	if player.Character then
		spawn(function() onCharacterAdded(player, player.Character) end)
	end
end

for _, pl in ipairs(Players:GetPlayers()) do
	spawn(function() onPlayerAdded(pl) end)
end
Players.PlayerAdded:Connect(onPlayerAdded)

-- cleanup: si sale el player, eliminar morph leftovers por nombre
Players.PlayerRemoving:Connect(function(player)
	local char = workspace:FindFirstChild(player.Name)
	if char and char:IsA("Model") then
		-- el morph está parented al character, así que al destruir el character se limpia
		-- pero por si acaso, eliminar cualquier objeto llamado Morph_<player>
		for _, obj in ipairs(char:GetChildren()) do
			if obj.Name == "Morph_"..player.Name then
				pcall(function() obj:Destroy() end)
			end
		end
	end
end)
