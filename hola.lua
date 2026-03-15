-- CharacterSystem (ServerScriptService)
-- reemplaza el character por el modelo equipado cuando el player spawnea
-- requisitos:
--  ServerStorage.Characters.Killers.<model>
--  ServerStorage.Characters.Survivors.<model>
--  player:SetAttribute("Role","Killer"/"Survivor") <-- tu RoundManager ya lo hace
--  opcional: player:SetAttribute("EquippedCharacter","Ninja")  (si no existe usa defaults)

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local charactersFolder = ServerStorage:WaitForChild("Characters")
local killersFolder = charactersFolder:WaitForChild("Killers")
local survivorsFolder = charactersFolder:WaitForChild("Survivors")

-- configuración / nombres por defecto si no hay atributo EquippedCharacter
local DEFAULT_SURVIVOR = "Ninja"
local DEFAULT_KILLER = "Zombie"

local function findPrimaryPart(model)
	-- intenta devolver HumanoidRootPart u otra BasePart como PrimaryPart
	local root = model:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then return root end
	-- fallback: primera BasePart que encuentre
	for _, v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") then return v end
	end
	return nil
end

local function safeReplaceCharacter(player, oldChar, newModel)
	if not player or not newModel then return end
	-- guardar cframe de la posición actual (teleport bug)
	local posCFrame
	if oldChar and oldChar:FindFirstChild("HumanoidRootPart") then
		posCFrame = oldChar.HumanoidRootPart.CFrame
	end

	-- preparar clon
	local clone = newModel:Clone()
	clone.Name = player.Name

	-- asegurar primary part
	local prim = findPrimaryPart(clone)
	if prim then
		clone.PrimaryPart = prim
	else
		warn("CharacterSystem: modelo "..clone.Name.." no tiene BasePart. Abortando replace.")
		return
	end

	-- poner en workspace sin soltar la posición
	clone.Parent = Workspace

	-- setear cframe a la posicion previa si existe
	if posCFrame then
		-- pequeño pcall por si algo falla
		pcall(function()
			clone:SetPrimaryPartCFrame(posCFrame)
		end)
	end

	-- asegurar humanoid y salud
	local newHum = clone:FindFirstChildOfClass("Humanoid")
	if newHum then
		newHum.Health = newHum.MaxHealth
	else
		warn("CharacterSystem: clon no tiene Humanoid: "..clone:GetFullName())
	end

	-- esperar 1 frame para que todo se asiente
	RunService.Heartbeat:Wait()

	-- IMPORTANT: poner el nuevo modelo como character del player ANTES de destruir el antiguo
	-- esto evita que el engine pierda el control y te mande al spawn
	pcall(function()
		player.Character = clone
	end)

	-- intentar devolver ownership de red (mejora la respuesta de movimiento en cliente)
	-- no es obligatorio pero ayuda en servidores con física; ignoramos errores en caso de sandbox.
	pcall(function()
		if prim and prim:IsA("BasePart") then
			prim:SetNetworkOwner(player)
		end
	end)

	-- eliminar el character viejo (si existe)
	if oldChar and oldChar.Parent then
		pcall(function() oldChar:Destroy() end)
	end

	-- final: ya está el nuevo personaje activo y en la misma posición que el viejo
end

local function getModelForPlayer(player)
	local role = player:GetAttribute("Role")
	-- obtener nombre del personaje equipado (si existe)
	local equipped = player:GetAttribute("EquippedCharacter")

	if role == "Killer" then
		local name = equipped and tostring(equipped) or DEFAULT_KILLER
		return killersFolder:FindFirstChild(name) or killersFolder:FindFirstChild(DEFAULT_KILLER)
	elseif role == "Survivor" then
		local name = equipped and tostring(equipped) or DEFAULT_SURVIVOR
		return survivorsFolder:FindFirstChild(name) or survivorsFolder:FindFirstChild(DEFAULT_SURVIVOR)
	end
	return nil
end

local function onCharacterAdded(player, char)
	-- pequeña espera para dejar que el RoundManager teleporte primero
	task.wait(0.1)

	-- si el jugador no tiene Role todavía, no hacemos nada (esperamos a que lo ponga RoundManager)
	local role = player:GetAttribute("Role")
	if not role then
		-- opcional: esperar un poco más a que se asigne role
		for i = 1, 10 do
			task.wait(0.2)
			role = player:GetAttribute("Role")
			if role then break end
		end
	end
	if not role then return end

	-- buscar modelo adecuado
	local model = getModelForPlayer(player)
	if not model then
		warn("CharacterSystem: no se encontró modelo para "..player.Name.." role="..tostring(role))
		return
	end

	-- reemplazar de forma segura
	pcall(function()
		safeReplaceCharacter(player, char, model)
	end)
end

local function onPlayerAdded(player)
	-- si el player se une durante la ronda, asumimos spectator (para evitar bugs)
	-- esto es opcional; si no querés este comportamiento sacalo.
	-- usamos _G.RoundInProgress si tu RoundManager lo marca; si no, podés quitar esta línea.
	if _G and _G.RoundInProgress then
		player:SetAttribute("Role", "Spectator")
	end

	-- conectar CharacterAdded
	player.CharacterAdded:Connect(function(char)
		onCharacterAdded(player, char)
	end)

	-- si ya tenía character (rejoins), aplicarlo ahora
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end

-- conectar jugadores ya presentes
for _,pl in ipairs(Players:GetPlayers()) do
	spawn(function() onPlayerAdded(pl) end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	-- cleanup opcional: si hay leftovers en workspace con el mismo nombre, eliminarlos
	local w = Workspace:FindFirstChild(player.Name)
	if w and w:IsA("Model") then
		pcall(function() w:Destroy() end)
	end
end)
