-- localscript: lobby music randomized (pegalo en StarterPlayer > StarterPlayerScripts)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ====== CONFIG ======
-- pon acá 5 ids (solo el número o string con número)
local musicIds = {
    "TU_ID_1", -- ej: "18374918"
    "TU_ID_2",
    "TU_ID_3",
    "TU_ID_4",
    "TU_ID_5"
}

local volume = 1           -- 0..1
local fadeOutTime = 0.6    -- segundos para desvanecer al cortar (mejor experiencia)
local checksRequired = 3   -- cuantas checks consecutivas necesitan indicar "in game" para confirmar
local checkInterval = 0.5  -- intervalo entre checks (s)
-- ======================

-- util: shuffle tabla
local function shuffle(t)
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- crear player gui padre
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- crear sound (se recrea por cada pista para evitar bugs)
local function makeSound(id)
    local s = Instance.new("Sound")
    s.SoundId = ("rbxassetid://%s"):format(tostring(id))
    s.Looped = false
    s.Volume = volume
    s.PlayOnRemove = false
    s.Parent = playerGui
    return s
end

-- playlist inicial (copiar y shuffle)
local playlist = {}
for _, v in ipairs(musicIds) do
    if v and tostring(v) ~= "" then
        table.insert(playlist, v)
    end
end

if #playlist == 0 then
    warn("lobby music: no hay ids en la playlist. pon 5 ids en la tabla musicIds.")
    return
end

shuffle(playlist)

local currentIndex = 0
local currentSound = nil
local playing = true

-- reproducir siguiente pista
local function playNext()
    if currentSound then
        currentSound:Destroy()
        currentSound = nil
    end
    currentIndex = currentIndex + 1
    if currentIndex > #playlist then
        -- reshuffle y volver a empezar
        shuffle(playlist)
        currentIndex = 1
    end
    local id = playlist[currentIndex]
    currentSound = makeSound(id)
    currentSound:Play()
    -- cuando termina, reproducir siguiente si todavía estamos en lobby
    local conn
    conn = currentSound.Ended:Connect(function()
        conn:Disconnect()
        if playing then
            playNext()
        end
    end)
end

-- comprobar estados del juego con varias heuristicas
local function checkReplicatedStorageFlags()
    -- busca nombres comunes
    local namesBool = {"InGame", "RoundActive", "GameActive"}
    local namesValue = {"Status", "GameState", "State"}
    for _, n in ipairs(namesBool) do
        local v = ReplicatedStorage:FindFirstChild(n)
        if v and v:IsA("BoolValue") then
            if v.Value == true then return true end
        end
    end
    for _, n in ipairs(namesValue) do
        local v = ReplicatedStorage:FindFirstChild(n)
        if v and v:IsA("StringValue") then
            local val = v.Value:lower()
            if val ~= "lobby" and val ~= "waiting" and val ~= "" then
                return true
            end
        end
    end
    return false
end

local function checkWorkspaceFlags()
    -- cosas comunes en workspace
    if workspace:FindFirstChild("GameStarted") or workspace:FindFirstChild("RoundStarted") or workspace:FindFirstChild("Match") then
        return true
    end
    return false
end

local function checkActivePlayers()
    local active = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                active = active + 1
            end
        end
    end
    -- si hay más de 1 jugador con personaje activo, lo consideramos partida iniciada
    return active > 1
end

-- función compuesta y estable (requiere checksRequired confirmaciones consecutivas)
local function detectGameStart()
    local okCount = 0
    for i = 1, checksRequired do
        if checkReplicatedStorageFlags() or checkWorkspaceFlags() or checkActivePlayers() then
            okCount = okCount + 1
        else
            okCount = 0
        end
        if okCount >= checksRequired then
            return true
        end
        wait(checkInterval)
    end
    return false
end

-- fade out helper
local function fadeOutAndStop(soundObj, secs)
    if not soundObj then return end
    local startVol = soundObj.Volume
    local steps = 10
    local dt = secs / steps
    for i = 1, steps do
        if not soundObj or not soundObj.Parent then break end
        local newV = startVol * (1 - i/steps)
        soundObj.Volume = newV
        wait(dt)
    end
    if soundObj and soundObj.Parent then
        soundObj:Stop()
        soundObj:Destroy()
    end
end

-- main
spawn(function()
    -- start playlist
    playNext()

    -- loop principal: cada cierto tiempo chequea si la partida empezó
    while playing do
        local started = detectGameStart()
        if started then
            playing = false
            -- fade out la pista actual
            fadeOutAndStop(currentSound, fadeOutTime)
            -- cleanup
            currentSound = nil
            break
        end
        -- chequeo menos agresivo entre detecciones
        wait(1)
    end
end)

-- limpieza si el jugador sale del juego (safety)
LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer:IsDescendantOf(game) then
        if currentSound then
            pcall(function() currentSound:Stop() end)
            pcall(function() currentSound:Destroy() end)
            currentSound = nil
        end
        playing = false
    end
end)
