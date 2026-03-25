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
local function createBigFire(parent, heat, size, color, secondaryColor, transparency)
    local fire = Instance.new("Fire")
    fire.Heat = heat
    fire.Size = size
    fire.Color = color
    fire.SecondaryColor = secondaryColor
    fire.Transparency = transparency
    fire.Parent = parent
    return fire
end

-- stacking de Fire para más épico
createBigFire(Torso, 20, 7, Color3.fromRGB(255,140,0), Color3.fromRGB(255,50,0), 0.5)
createBigFire(Torso, 25, 9, Color3.fromRGB(255,160,0), Color3.fromRGB(255,60,0), 0.5)
createBigFire(Torso, 30, 11, Color3.fromRGB(255,180,50), Color3.fromRGB(255,80,0), 0.5)

-- agregar luz para que la llama resalte
local light = Instance.new("PointLight")
light.Color = Color3.fromRGB(255,140,0)
light.Range = 15
light.Brightness = 3
light.Parent = Torso

--// servicios
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// config
local TOOL_NAME = "Blitz Shot"
local MAX_FOV = 150

--// buscar target (jugadores + dummies)
local function getClosestTarget()
    local closest = nil
    local shortestDistance = MAX_FOV

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            
            -- evitar agarrarte a vos mismo
            if v ~= LocalPlayer.Character then
                
                local pos, onScreen = Camera:WorldToViewportPoint(v.HumanoidRootPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closest = v
                    end
                end
            end
        end
    end

    return closest
end

--// dirección asistida
local function getAimDirection()
    local target = getClosestTarget()

    if target then
        local targetPos = target.HumanoidRootPart.Position
        local camPos = Camera.CFrame.Position

        local normalDir = Camera.CFrame.LookVector
        local targetDir = (targetPos - camPos).Unit

        -- suavidad (no aimlock)
        return normalDir:Lerp(targetDir, 0.25)
    end

    return Camera.CFrame.LookVector
end

--// hookear tool
local function setupTool(tool)
    if tool.Name ~= TOOL_NAME then return end

    tool.Activated:Connect(function()
        local dir = getAimDirection()

        print("Aim Assist Direction:", dir)

        -- acá conectás con tu disparo real
    end)
end

-- detectar tools
local function checkTools()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            setupTool(tool)
        end
    end

    char.ChildAdded:Connect(function(v)
        if v:IsA("Tool") then
            setupTool(v)
        end
    end)
end

checkTools()
