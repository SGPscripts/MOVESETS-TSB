-- RoundUIConnector (LocalScript)
-- Ubicación recomendada: StarterPlayerScripts
-- Conecta con ReplicatedStorage.RoundEvent y actualiza las TextLabels (robusto ante nombres distintos)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- esperar RemoteEvent
local roundEvent = ReplicatedStorage:WaitForChild("RoundEvent", 10)
if not roundEvent then
	warn("RoundUIConnector: no se encontró RoundEvent en ReplicatedStorage")
	return
end

-- intentamos localizar la GUI del jugador. Primero el nombre que usabas, si no buscamos alternativas
local function findPlayerGui()
	-- espera PlayerGui
	local pg = player:WaitForChild("PlayerGui", 10)
	if not pg then return nil end

	-- si hay un GameUI concreto
	if pg:FindFirstChild("GameUI") then
		return pg.GameUI
	end

	-- buscar cualquier ScreenGui que tenga alguno de los labels esperados
	for _, g in ipairs(pg:GetChildren()) do
		if g:IsA("ScreenGui") then
			if g:FindFirstChild("Contador") or g:FindFirstChild("Timer") or g:FindFirstChild("TimerLabel") then
				return g
			end
			if g:FindFirstChild("SurvivorLeft") or g:FindFirstChild("Survivors") or g:FindFirstChild("SurvivorsLabel") then
				return g
			end
			if g:FindFirstChild("KillerContador") or g:FindFirstChild("Killers") or g:FindFirstChild("KillersLabel") then
				return g
			end
		end
	end

	-- fallback: devolver el primer ScreenGui
	for _, g in ipairs(pg:GetChildren()) do
		if g:IsA("ScreenGui") then return g end
	end

	return nil
end

local gui = findPlayerGui()
if not gui then
	warn("RoundUIConnector: no se encontró ScreenGui en PlayerGui (busca 'GameUI' o labels esperados).")
	-- no abortamos; seguiremos recibiendo eventos pero no actualizaremos labels
end

-- helper para buscar label por varias opciones
local function findLabel(parent, names)
	if not parent then return nil end
	for _, name in ipairs(names) do
		local obj = parent:FindFirstChild(name)
		if obj and obj:IsA("TextLabel") then
			return obj
		end
	end
	return nil
end

-- intentar encontrar los labels (con alternativas)
local contadorLabel = findLabel(gui, {"Contador", "Timer", "TimerLabel", "ContadorLabel"})
local killersLabel  = findLabel(gui, {"KillerContador", "Killers", "KillersLabel", "KillerLabel"})
local survivorsLabel = findLabel(gui, {"SurvivorLeft", "Survivors", "SurvivorsLabel", "SurvivorLabel"})
local centerLabel = findLabel(gui, {"CenterLabel", "Center", "MainCenter", "YouVsLabel"}) -- opcional

local function safeSetText(lbl, txt)
	if lbl and lbl:IsA("TextLabel") then
		pcall(function() lbl.Text = tostring(txt) end)
	end
end

-- formatea segundos a MM:SS
local function formatTime(s)
	s = math.max(0, math.floor(s or 0))
	local m = math.floor(s / 60)
	local sec = s % 60
	return string.format("%02d:%02d", m, sec)
end

-- estado local para mostrar totales
local lastSurvivorsTotal = 12
local lastKillersTotal = 0

-- manejador de eventos
roundEvent.OnClientEvent:Connect(function(kind, payload)
	payload = payload or {}

	if kind == "Waiting" then
		safeSetText(contadorLabel, "waiting")
		local cur = payload.current or #Players:GetPlayers()
		safeSetText(survivorsLabel, tostring(cur).."/"..tostring(lastSurvivorsTotal))
		safeSetText(killersLabel, "killers: "..tostring(lastKillersTotal))

	elseif kind == "Countdown" then
		local t = payload.time or 0
		safeSetText(contadorLabel, formatTime(t))
		safeSetText(survivorsLabel, tostring(#Players:GetPlayers()).."/"..tostring(lastSurvivorsTotal))

	elseif kind == "CountdownCancelled" then
		safeSetText(contadorLabel, "waiting")
		safeSetText(survivorsLabel, tostring(#Players:GetPlayers()).."/"..tostring(lastSurvivorsTotal))

	elseif kind == "RoundStart" then
		lastSurvivorsTotal = payload.survivorsTotal or lastSurvivorsTotal
		lastKillersTotal = payload.killersTotal or lastKillersTotal
		safeSetText(contadorLabel, formatTime(payload.roundTime or 0))
		safeSetText(survivorsLabel, tostring(lastSurvivorsTotal).."/"..tostring(lastSurvivorsTotal))
		safeSetText(killersLabel, tostring(lastKillersTotal))
		if centerLabel and payload.killerName then
			safeSetText(centerLabel, "You vs "..tostring(payload.killerName))
			centerLabel.Visible = true
			task.delay(2, function() if centerLabel then centerLabel.Visible = false end end)
		end

	elseif kind == "Tick" then
		safeSetText(contadorLabel, formatTime(payload.time or 0))
		if payload.survivorsAlive ~= nil then
			safeSetText(survivorsLabel, tostring(payload.survivorsAlive).."/"..tostring(lastSurvivorsTotal))
		end
		if payload.killersAlive ~= nil then
			safeSetText(killersLabel, tostring(payload.killersAlive))
		end

	elseif kind == "EndingChosen" then
		local e = payload.ending or "ending"
		safeSetText(contadorLabel, "ENDING: "..tostring(e))
		if centerLabel then
			safeSetText(centerLabel, "ENDING: "..tostring(e))
			centerLabel.Visible = true
			task.delay(2, function() if centerLabel then centerLabel.Visible = false end end)
		end

	elseif kind == "RoundUpdate" then
		if payload.survivorsAlive ~= nil then
			safeSetText(survivorsLabel, tostring(payload.survivorsAlive).."/"..tostring(lastSurvivorsTotal))
		end
		if payload.killersAlive ~= nil then
			safeSetText(killersLabel, tostring(payload.killersAlive))
		end

	elseif kind == "RoundEnd" then
		local w = payload.winner or "result"
		safeSetText(contadorLabel, "winner: "..tostring(w))
		if centerLabel then
			safeSetText(centerLabel, "RESULT: "..tostring(w))
			centerLabel.Visible = true
			task.delay(3, function() if centerLabel then centerLabel.Visible = false end end)
		end
		-- después de mostrar resultado, restablecer a waiting (lo hace el servidor al reiniciar)
		task.delay(3.5, function()
			safeSetText(contadorLabel, "waiting")
			safeSetText(survivorsLabel, tostring(#Players:GetPlayers()).."/"..tostring(lastSurvivorsTotal))
			safeSetText(killersLabel, tostring(0))
		end)
	end
end)
