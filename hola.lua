-- MorphSystem (ServerScriptService)
-- 1) Espera a que Role exista y a que el player no esté en el lobby
-- 2) Quita accesorios/ropa y hace el cuerpo invisible (no destruye partes core)
-- 3) Clona el modelo (Ninja / Zombie) y lo weld/ata al HumanoidRootPart como "morph"
-- 4) Limpia scripts/humanoids del morph para evitar conflictos
-- Requisitos:
--  ReplicatedStorage.Characters.Killers.<Zombie>
--  ReplicatedStorage.Characters.Survivors.<Ninja>
--  Workspace debe tener un SpawnLocation llamado "LobbySpawn" (si existe se usa para detectar lobby)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- intentar Characters en ReplicatedStorage, si no existe fallback a ServerStorage
local characters = ReplicatedStorage:FindFirstChild("Characters") or ServerStorage:FindFirstChild("Characters")
if not characters then
	error("MorphSystem: no se encontró carpeta 'Characters' en ReplicatedStorage ni ServerStorage.")
end

local killersFolder = characters:FindFirstChild("Killers")
local survivorsFolder = characters:FindFirstChild("Survivors")

local DEFAULT_SURVIVOR = "Ninja"
local DEFAULT_KILLER = "Zombie"

-- posicion de lobby (opcional)
local lobbySpawn = Workspace:FindFirstChild("LobbySpawn")
local LOBBY_RADIUS = 15 -- si estás dentro de este radio respecto a LobbySpawn -> consideramos lobby

local function isInLobby(hrp)
	if not hrp or not hrp:IsA("BasePart") then return false end
	if not lobbySpawn or not lobbySpawn:IsA("BasePart") then return false end
	return (hrp.Position - lobbySpawn.Position).Magnitude <= LOBBY_RADIUS
end

local function findFirstBasePart(model)
	for _,v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") then return v end
	end
	return nil
end

local function clearAppearance(character)
	-- elimina accesorios y ropa (Shirt/Pants/CharacterMesh/ShirtGraphic) y hace parts invisibles sin borrar joints
	for _,child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") then
			pcall(function() child:Destroy() end)
		elseif child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("CharacterMesh") then
			pcall(function() child:Destroy() end)
		end
	end

	-- ocultar partes visuales (transparency) y desactivar colisiones visuales
	for _,desc in ipairs(character:GetDescendants()) do
		if desc:IsA("BasePart") then
			pcall(function()
				-- No tocamos joints/constraints, solo propiedades visuales y físicas superficiales
				desc.Transparency = 1
				desc.CanCollide = false
			end)
		elseif desc:IsA("Decal") then
			pcall(function() desc.Transparency = 1 end)
		end
	end
end

local function sanitizeMorphModel(model)
	-- eliminar Humanoids/Animators/Scripts/LocalScripts/ModuleScripts del morph para evitar conflictos
	for _,obj in ipairs(model:GetDescendants()) do
		if obj:IsA("Humanoid") or obj:IsA("Animator") then
			pcall(function() obj:Destroy() end)
		elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
			-- opcional: eliminamos scripts del morph para seguridad; si querés conservar algún ModuleScript pon condición
			pcall(function() obj:Destroy() end)
		end
	end
end

local function weldModelToHRP(clone, hrp)
	if not clone or not hrp then return end

	-- encontrar primary part del clone
	local prim = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart") or findFirstBasePart(clone)
	if not prim then
		warn("MorphSystem: clon no tiene BasePart para weld.")
		return
	end

	-- posicionar el morph donde está el hrp
	pcall(function() clone:SetPrimaryPartCFrame(hrp.CFrame) end)

	-- desactivar colisiones del morph (para evitar bloquear el mundo)
	for _,p in ipairs(clone:GetDescendants()) do
		if p:IsA("BasePart") then
			pcall(function() p.CanCollide = false end)
		end
	end

	-- si ya existe un weld previo con ese morph, eliminarlo
	for _,c in ipairs(prim:GetChildren()) do
		if c:IsA("WeldConstraint") and c.Name == "MorphWeld" then
			pcall(function() c:Destroy() end)
		end
	end

	-- crear WeldConstraint entre prim (morph) y hrp
	local weld = Instance.new("WeldConstraint")
	weld.Name = "MorphWeld"
	weld.Part0 = prim
	weld.Part1 = hrp
	weld.Parent = prim

	-- opcional: devolver network owner al jugador para mejor control (safe pcall)
	pcall(function()
		if prim and prim:IsA("BasePart") and hrp and hrp:IsA("BasePart") then
			prim:SetNetworkOwner(nil) -- dejar server ownership por defecto; si querés SetNetworkOwner(player) probalo en tu host
		end
	end)
end

local function destroyOldMorph(character, player)
	-- limpiar morph leftovers si existieran (nombre Morph_<player>)
	for _,child in ipairs(character:GetChildren()) do
		if child.Name == ("Morph_" .. (player and player.Name or "")) then
			pcall(function() child:Destroy() end)
		end
	end
end

local function getModelForRole(player, role)
	if role == "Killer" then
		local name = player:GetAttribute("EquippedCharacter") or DEFAULT_KILLER
		if killersFolder then
			return killersFolder:FindFirstChild(name) or killersFolder:FindFirstChild(DEFAULT_KILLER)
		end
	elseif role == "Survivor" then
		local name = player:GetAttribute("EquippedCharacter") or DEFAULT_SURVIVOR
		if survivorsFolder then
			return survivorsFolder:FindFirstChild(name) or survivorsFolder:FindFirstChild(DEFAULT_SURVIVOR)
		end
	end
	return nil
end

local function applyMorph(player, role)
	if not player then return end
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
	if not hrp then
		warn("MorphSystem: "..player.Name.." no tiene HumanoidRootPart / BasePart")
		return
	end

	-- destruir morph anterior si existe
	destroyOldMorph(char, player)

	-- limpiar apariencias del player (accesorios, ropa, partes visibles)
	clearAppearance(char)

	-- buscar el modelo
	local model = getModelForRole(player, role)
	if not model then
		warn("MorphSystem: no se encontró modelo para role="..tostring(role).." player="..tostring(player.Name))
		return
	end

	-- clonar y sanitizar el morph
	local clone = model:Clone()
	clone.Name = "Morph_" .. player.Name

	-- limpiar scripts/humanoids del clone
	sanitizeMorphModel(clone)

	-- parentear el morph dentro del character para que se destruya con él al respawnear/irse
	clone.Parent = char

	-- asegurarse primarypart
	local prim = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart") or findFirstBasePart(clone)
	if prim and not clone.PrimaryPart then
		clone.PrimaryPart = prim
	end

	-- weld al hrp
	weldModelToHRP(clone, hrp)
end

-- CORE: handler al aparecer character
local function onCharacterAdded(player, character)
	-- Esperar un poco para que RoundManager teleporte y asigne Role.
	-- Pero en vez de asumir _G o RoundEvent, esperamos Role AND que el HRP no esté en lobby.
	-- Esperamos hasta X tiempos; si no aparece Role cancelamos.
	local role = nil
	for i = 1, 30 do -- hasta 3s
		role = player:GetAttribute("Role")
		if role then break end
		task.wait(0.1)
	end
	if not role then
		-- no hay Role -> no morph
		return
	end

	-- esperar a que character tenga HRP y esté fuera del lobby (timeout)
	local hrp = nil
	for i = 1, 40 do -- 4s max
		hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
		if hrp then
			-- si está en lobby, esperar un poco más (esperamos a que sea teleported al mapa)
			if isInLobby(hrp) then
				task.wait(0.15)
				continue
			else
				break
			end
		end
		task.wait(0.1)
	end

	-- si sigue en lobby -> no morph (evita morph en lobby)
	hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
	if hrp and isInLobby(hrp) then
		-- no aplicamos morph en lobby
		return
	end

	-- aplicar morph seguro
	pcall(function()
		applyMorph(player, role)
	end)
end

local function onPlayerAdded(player)
	-- conectar
	player.CharacterAdded:Connect(function(char)
		-- run in a spawn to avoid blocking
		spawn(function()
			onCharacterAdded(player, char)
		end)
	end)

	-- si ya tiene character (rejoin), aplicarlo (spawn so it doesn't block)
	if player.Character then
		spawn(function() onCharacterAdded(player, player.Character) end)
	end
end

-- conectar players existentes
for _,pl in ipairs(Players:GetPlayers()) do
	spawn(function() onPlayerAdded(pl) end)
end
Players.PlayerAdded:Connect(onPlayerAdded)

-- cleanup: si sale player, intentar borrar morph leftovers
Players.PlayerRemoving:Connect(function(player)
	-- si el character está en workspace con su nombre, limpiar morph
	local char = Workspace:FindFirstChild(player.Name)
	if char and char:IsA("Model") then
		for _,c in ipairs(char:GetChildren()) do
			if c.Name == "Morph_"..player.Name then
				pcall(function() c:Destroy() end)
			end
		end
	end
end)
