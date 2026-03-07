-- RoundManager (ServerScriptService)
-- Versión robusta, todo-en-uno según tu spec

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
math.randomseed(tick())

-- CONFIG
local MIN_PLAYERS = 2
local PREP_TIME = 30        -- countdown antes de empezar la ronda
local ROUND_TIME = 180      -- duración de la ronda
local RETURN_DELAY = 5      -- espera antes de permitir nuevo conteo
local KILLER_COUNT = 1      -- cuantos killers por ronda (1 por defecto)

-- REMOTE
local roundEvent = ReplicatedStorage:FindFirstChild("RoundEvent")
if not roundEvent then
	roundEvent = Instance.new("RemoteEvent")
	roundEvent.Name = "RoundEvent"
	roundEvent.Parent = ReplicatedStorage
end

-- REFS (requeridos en Workspace)
local lobbySpawn = workspace:FindFirstChild("LobbySpawn")
local mapsFolder = workspace:FindFirstChild("Maps")

assert(lobbySpawn, "RoundManager: crea un SpawnLocation en Workspace llamado 'LobbySpawn'.")
assert(mapsFolder and #mapsFolder:GetChildren() > 0, "RoundManager: crea folder 'Maps' con al menos 1 mapa.")

-- HELPERS
local function broadcast(kind, payload)
	-- kind: "Waiting","Countdown","CountdownCancelled","RoundStart","Tick","EndingChosen","RoundUpdate","RoundEnd"
	roundEvent:FireAllClients(kind, payload)
end

local function getPlayers()
	return Players:GetPlayers()
end

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(1, i)
		t[i], t[j] = t[j], t[i]
	end
end

local function safeTeleportCharacterToPart(player, part)
	if not player or not player.Character then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if root and part and part:IsA("BasePart") then
		local target = part.CFrame + Vector3.new(0, 3, 0)
		pcall(function()
			if player.Character.PrimaryPart then
				player.Character:SetPrimaryPartCFrame(target)
			else
				root.CFrame = target
			end
		end)
	end
end

local function chooseRandomMap()
	local maps = mapsFolder:GetChildren()
	if #maps == 0 then return nil end
	return maps[math.random(1,#maps)]
end

local function chooseKillerPlayers(playersList, n)
	n = math.max(1, math.min(n, #playersList))
	local pool = {}
	for i,pl in ipairs(playersList) do pool[i] = pl end
	local chosen = {}
	for i = 1, n do
		local idx = math.random(1, #pool)
		table.insert(chosen, pool[idx])
		table.remove(pool, idx)
	end
	return chosen
end

local function countAliveByRole(playersList)
	local survivorsAlive = 0
	local killersAlive = 0
	for _, pl in ipairs(playersList) do
		local role = pl:GetAttribute("Role")
		if pl.Character then
			local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
			if hum and hum.Health > 0 then
				if role == "Survivor" then survivorsAlive = survivorsAlive + 1 end
				if role == "Killer" then killersAlive = killersAlive + 1 end
			end
		end
	end
	return survivorsAlive, killersAlive
end

local function returnAllToLobby()
	for _, pl in ipairs(Players:GetPlayers()) do
		pcall(function()
			if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
				pl.Character:MoveTo(lobbySpawn.Position + Vector3.new(0,3,0))
			else
				pl:LoadCharacter()
				-- intento mover despues de spawn
				task.delay(0.5, function()
					if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
						pl.Character:MoveTo(lobbySpawn.Position + Vector3.new(0,3,0))
					end
				end)
			end
		end)
	end
end

-- ROUNDMANAGER PRINCIPAL
local inRound = false

local function startRound()
	if inRound then return end
	local players = getPlayers()
	if #players < MIN_PLAYERS then return end
	inRound = true

	-- elegir mapa random
	local chosenMap = chooseRandomMap()
	if not chosenMap then
		warn("RoundManager: no hay mapas en Maps")
		inRound = false
		return
	end

	-- recolectar spawns del mapa
	local survivorFolder = chosenMap:FindFirstChild("SurvivorSpawns")
	local killerSpawn = chosenMap:FindFirstChild("KillerSpawn")
	local survivorSpawns = {}
	if survivorFolder then
		for _, v in ipairs(survivorFolder:GetChildren()) do
			if v:IsA("BasePart") or v:IsA("SpawnLocation") then
				table.insert(survivorSpawns, v)
			end
		end
	end
	if #survivorSpawns == 0 then
		warn("RoundManager: map "..chosenMap.Name.." no tiene SurvivorSpawns válidos. Se usará LobbySpawn como fallback.")
	end
	if not killerSpawn or not (killerSpawn:IsA("BasePart") or killerSpawn:IsA("SpawnLocation")) then
		warn("RoundManager: map "..chosenMap.Name.." no tiene KillerSpawn válido. Se usará LobbySpawn como fallback.")
		killerSpawn = lobbySpawn
	end

	-- elegir killers
	local chosenKillers = chooseKillerPlayers(players, KILLER_COUNT)
	local killersSet = {}
	for _, k in ipairs(chosenKillers) do killersSet[k] = true end

	-- asignar roles y reset vida si aplica
	for _, pl in ipairs(players) do
		if killersSet[pl] then
			pl:SetAttribute("Role", "Killer")
		else
			pl:SetAttribute("Role", "Survivor")
		end
		pcall(function()
			if pl.Character then
				local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
				if hum then hum.Health = hum.MaxHealth end
			end
		end)
	end

	-- teleports: shuffle survivors spawns para distribuir mejor
	shuffle(survivorSpawns)
	local spawnsCount = #survivorSpawns

	for i, pl in ipairs(players) do
		if pl:GetAttribute("Role") == "Killer" then
			safeTeleportCharacterToPart(pl, killerSpawn or lobbySpawn)
		else
			if spawnsCount > 0 then
				local pick = survivorSpawns[((i-1) % spawnsCount) + 1]
				safeTeleportCharacterToPart(pl, pick)
			else
				safeTeleportCharacterToPart(pl, lobbySpawn)
			end
		end
	end

	-- notificar inicio de ronda
	local survivorsTotal = 0
	for _,pl in ipairs(players) do if pl:GetAttribute("Role") == "Survivor" then survivorsTotal = survivorsTotal + 1 end end
	broadcast("RoundStart", {map = chosenMap.Name, killersTotal = #chosenKillers, survivorsTotal = survivorsTotal, roundTime = ROUND_TIME})

	-- monitoreo de muertes y desconexiones
	local connList = {}
	local survivorsAlive, killersAlive = countAliveByRole(players)

	local function onPlayerDeath(pl)
		survivorsAlive, killersAlive = countAliveByRole(getPlayers())
		broadcast("RoundUpdate", {survivorsAlive = survivorsAlive, killersAlive = killersAlive})
	end

	-- conectar humanoids actuales y futuros
	for _, pl in ipairs(players) do
		if pl.Character then
			local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
			if hum then
				table.insert(connList, hum.Died:Connect(function() onPlayerDeath(pl) end))
			end
		end
		table.insert(connList, pl.CharacterAdded:Connect(function(char)
			task.wait(0.4)
			local hum = char:FindFirstChildWhichIsA("Humanoid")
			if hum then
				table.insert(connList, hum.Died:Connect(function() onPlayerDeath(pl) end))
			end
		end))
		-- tambien escuchar si el player se va
		table.insert(connList, pl.AncestryChanged:Connect(function()
			-- si player sale del juego, recalculamos
			survivorsAlive, killersAlive = countAliveByRole(getPlayers())
			broadcast("RoundUpdate", {survivorsAlive = survivorsAlive, killersAlive = killersAlive})
		end))
	end

	-- timer principal
	local timeLeft = ROUND_TIME
	local endingChosen = nil
	while timeLeft > 0 and survivorsAlive > 0 and killersAlive > 0 do
		task.wait(1)
		timeLeft = timeLeft - 1

		-- si en cualquier momento caen menos de MIN_PLAYERS, terminamos la ronda y volvemos al lobby
		if #getPlayers() < MIN_PLAYERS then
			broadcast("RoundCancelled", {})
			break
		end

		-- tick
		broadcast("Tick", {time = timeLeft, survivorsAlive = survivorsAlive, killersAlive = killersAlive})

		-- cuando faltan 30s elegimos ending random
		if timeLeft == 30 then
			local endings = {"escape", "hallway", "boss", "lockdown"}
			endingChosen = endings[math.random(1,#endings)]
			broadcast("EndingChosen", {ending = endingChosen, timeLeft = timeLeft})
			-- NO implementamos teleports/acciones del ending aquí (se hace por bloques después)
		end
	end

	-- decidir ganador
	local winner = "survivors"
	if #getPlayers() < MIN_PLAYERS then
		winner = "none" -- ronda cancelada por pocos players
	else
		if survivorsAlive <= 0 then
			winner = "killer"
		elseif killersAlive <= 0 then
			winner = "survivors"
		elseif timeLeft <= 0 then
			winner = "survivors"
		end
	end

	broadcast("RoundEnd", {winner = winner, ending = endingChosen})

	-- cleanup
	for _,c in ipairs(connList) do
		if c and c.Disconnect then
			pcall(function() c:Disconnect() end)
		end
	end

	inRound = false

	-- esperar 2 segundos y reiniciar a todos los jugadores para que vuelvan al lobby
	task.wait(2)
	for _, pl in ipairs(Players:GetPlayers()) do
		pcall(function()
			pl:LoadCharacter()
		end)
	end

	-- esperar un poco antes de permitir nuevo conteo
	task.wait(RETURN_DELAY)
end

-- BUCLE PRINCIPAL: espera jugadores y hace PREP countdown (cancelable)
spawn(function()
	while true do
		task.wait(1)
		if inRound then continue end
		local players = getPlayers()
		if #players < MIN_PLAYERS then
			broadcast("Waiting", {minPlayers = MIN_PLAYERS, current = #players})
			continue
		end

		-- countdown PREP_TIME
		local cancelled = false
		for t = PREP_TIME, 1, -1 do
			-- cancelar si bajan players
			if #getPlayers() < MIN_PLAYERS then
				cancelled = true
				broadcast("CountdownCancelled", {})
				break
			end
			broadcast("Countdown", {time = t})
			task.wait(1)
		end

		if cancelled then
			task.wait(1)
			continue
		end

		-- si sigue todo ok, startRound
		pcall(function() startRound() end)
	end
end)
