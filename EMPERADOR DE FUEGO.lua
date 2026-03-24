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
