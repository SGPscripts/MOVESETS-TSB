--// servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

--// config
local TOOL_NAME = "Jet Dive"
local ULT_TOOL = "Incinerate"

--// función detectar tools
local function HasTool(toolName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    if backpack and backpack:FindFirstChild(toolName) then
        return true
    end
    if character and character:FindFirstChild(toolName) then
        return true
    end
    return false
end

--// alerta genérica
local function ShowAlert(text)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GenosAlert"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 0, 0, 0)
    textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = screenGui

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9118828565"
    sound.Volume = 1
    sound.Parent = SoundService
    sound:Play()

    local tweenIn = TweenService:Create(
        textLabel,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0.4, 0, 0.1, 0)}
    )
    tweenIn:Play()

    task.wait(2.5)

    local tweenOut = TweenService:Create(
        textLabel,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    tweenOut:Play()

    tweenOut.Completed:Wait()
    screenGui:Destroy()
end

--// ejecutar checks
task.wait(1)

if HasTool(ULT_TOOL) then
    ShowAlert("Espera a q se acabe la ulti para cargar el script")
    return
end

if not HasTool(TOOL_NAME) then
    ShowAlert("Usa a genos porfavor")
    return
end

--// ===== AURA DE FUEGO IMPONENTE (R6) =====
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("HumanoidRootPart")

if not Torso then
    warn("No se encontró torso para el aura de fuego")
    return
end

-- función para crear fuego gigante
local function createBigFire(parent, heat, size, color, secondaryColor)
    local fire = Instance.new("Fire")
    fire.Heat = heat
    fire.Size = size
    fire.Color = color
    fire.SecondaryColor = secondaryColor
    fire.Parent = parent
    return fire
end

-- stacking de Fire para más épico
createBigFire(Torso, 20, 7, Color3.fromRGB(255,140,0), Color3.fromRGB(255,50,0))
createBigFire(Torso, 25, 9, Color3.fromRGB(255,160,0), Color3.fromRGB(255,60,0))
createBigFire(Torso, 30, 11, Color3.fromRGB(255,180,50), Color3.fromRGB(255,80,0))

-- agregar luz para que la llama resalte
local light = Instance.new("PointLight")
light.Color = Color3.fromRGB(255,140,0)
light.Range = 15
light.Brightness = 3
light.Parent = Torso
