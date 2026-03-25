--// servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

--// config
local TOOL_NAME = "Jet Dive"
local ALERT_TEXT = "Usa a genos porfavor"

--// función para detectar si tiene la tool
local function HasGenosTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    if backpack and backpack:FindFirstChild(TOOL_NAME) then
        return true
    end

    if character and character:FindFirstChild(TOOL_NAME) then
        return true
    end

    return false
end

--// crear alerta
local function ShowAlert()
    -- GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GenosAlert"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 0, 0, 0)
    textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = ALERT_TEXT
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = screenGui

    -- sonido "clin"
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9118828565" -- podés cambiarlo si querés otro
    sound.Volume = 1
    sound.Parent = SoundService
    sound:Play()

    -- animación aparecer
    local tweenIn = TweenService:Create(
        textLabel,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0.4, 0, 0.1, 0)}
    )
    tweenIn:Play()

    -- esperar
    task.wait(2.5)

    -- animación desaparecer
    local tweenOut = TweenService:Create(
        textLabel,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    tweenOut:Play()

    tweenOut.Completed:Wait()
    screenGui:Destroy()
end

--// ejecutar
task.wait(1) -- esperar a que cargue todo

if not HasGenosTool() then
    ShowAlert()
end

--// servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Torso = Character:WaitForChild("UpperTorso") -- si tu modelo tiene otro nombre cambia

--// configuración de partículas
local function createFireParticle(parent, color, size, rate, lifetime, speed)
    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(color)
    particle.LightEmission = 0.6
    particle.Size = NumberSequence.new(size)
    particle.Rate = rate
    particle.Lifetime = NumberRange.new(lifetime)
    particle.Speed = NumberRange.new(speed)
    particle.Rotation = NumberRange.new(0, 360)
    particle.RotSpeed = NumberRange.new(50, 100)
    particle.Texture = "rbxassetid://243660364" -- textura de llama clásica
    particle.ZOffset = 0.5
    particle.Parent = parent
    return particle
end

--// capa de partículas
local baseFire = createFireParticle(Torso, Color3.fromRGB(255,140,0), 2, 20, 1.5, 2)
local sparks = createFireParticle(Torso, Color3.fromRGB(255,220,100), 1, 10, 1, 3)
local smallGlow = createFireParticle(Torso, Color3.fromRGB(255,180,50), 3, 5, 2, 1)

--// animación overheat (cuando atacas, cambia a azul)
local isOverheat = false
local function setOverheat(state)
    isOverheat = state
    if state then
        baseFire.Color = ColorSequence.new(Color3.fromRGB(0,170,255))
        sparks.Color = ColorSequence.new(Color3.fromRGB(100,220,255))
        smallGlow.Color = ColorSequence.new(Color3.fromRGB(50,180,255))
        baseFire.Size = NumberSequence.new(3)
    else
        baseFire.Color = ColorSequence.new(Color3.fromRGB(255,140,0))
        sparks.Color = ColorSequence.new(Color3.fromRGB(255,220,100))
        smallGlow.Color = ColorSequence.new(Color3.fromRGB(255,180,50))
        baseFire.Size = NumberSequence.new(2)
    end
end

--// ejemplo simple de overheat toggle (puedes reemplazar con tu check de ataque)
RunService.Heartbeat:Connect(function()
    -- por ejemplo si pulsaste M1 o skill -> setOverheat(true)
    -- sino -> setOverheat(false)
    if LocalPlayer:GetAttribute("Attacking") then
        setOverheat(true)
    else
        setOverheat(false)
    end
end)
