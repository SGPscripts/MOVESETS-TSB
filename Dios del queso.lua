-- dios del queso (fake bear overlay, visual only)
-- pegar como LocalScript o ejecutar con el personaje ya spawneado

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===== CAMBIAR ACA si queres otros assets =====
local HEAD_ASSET_ID = 9063836052       -- cabeza bear (accessory id)
local AURA_ASSET_ID = 9572366291       -- aura accesory id (opcional)
-- colores del overlay (ajustá si querés)
local BEAR_MAIN = Color3.fromRGB(150, 100, 50)   -- color cuerpo
local BEAR_ACCENT = Color3.fromRGB(255, 220, 60) -- color queso / detalles
-- ==============================================

local function safeGetObjects(assetId)
    local ok, res = pcall(function()
        return game:GetObjects("rbxassetid://"..tostring(assetId))
    end)
    if ok then return res end
    return nil
end

local function makeOverlayForPart(origPart, nameSuffix, color, useHeadMesh)
    local p = Instance.new("Part")
    p.Name = "Overlay_" .. origPart.Name .. nameSuffix
    p.Size = origPart.Size
    p.Transparency = 0
    p.CanCollide = false
    p.Anchored = false
    p.Massless = true
    p.Material = Enum.Material.SmoothPlastic
    p.Color = color or BEAR_MAIN
    p.Parent = workspace -- parent temporarily; we'll move into model later

    if useHeadMesh then
        local sm = Instance.new("SpecialMesh", p)
        sm.MeshType = Enum.MeshType.Head
        sm.Scale = Vector3.new(1.08, 1.08, 1.08)
    end

    -- weld to original part
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = p
    weld.Part1 = origPart
    weld.Parent = p

    return p
end

local function hideOriginalPartLocal(part)
    if not part then return end
    pcall(function()
        -- prefer local transparency modifier (client-side)
        if part.LocalTransparencyModifier ~= nil then
            part.LocalTransparencyModifier = 1
        else
            -- fallback: change transparency (usually ok for local scripts but may replicate)
            part.Transparency = 1
        end
        -- hide face decal if exists (head)
        for _,c in pairs(part:GetChildren()) do
            if c:IsA("Decal") then
                c.Transparency = 1
            end
        end
    end)
end

local function restoreOriginalPartLocal(part)
    if not part then return end
    pcall(function()
        if part.LocalTransparencyModifier ~= nil then
            part.LocalTransparencyModifier = 0
        else
            part.Transparency = 0
        end
        for _,c in pairs(part:GetChildren()) do
            if c:IsA("Decal") then
                c.Transparency = 0
            end
        end
    end)
end

local overlayModelName = "CheeseBearOverlay_local"

local function clearOldOverlay()
    local old = workspace:FindFirstChild(overlayModelName)
    if old then old:Destroy() end
end

local function createOverlay(character)
    if not character then return end
    clearOldOverlay()

    local overlayModel = Instance.new("Model")
    overlayModel.Name = overlayModelName
    overlayModel.Parent = workspace

    -- choose parts list depending on rig
    local isR15 = character:FindFirstChild("UpperTorso") and true or false

    local partNames = {}
    if isR15 then
        partNames = {
            "Head","UpperTorso","LowerTorso",
            "LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand",
            "LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"
        }
    else
        partNames = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
    end

    -- store originals for restore if needed
    local originals = {}

    for _,pname in ipairs(partNames) do
        local orig = character:FindFirstChild(pname)
        if orig and orig:IsA("BasePart") then
            originals[pname] = orig
            -- hide original local
            hideOriginalPartLocal(orig)

            local useHeadMesh = (pname == "Head")
            local color = BEAR_MAIN
            if pname == "Head" then color = BEAR_MAIN end
            if pname:lower():find("hand") or pname:lower():find("arm") then color = BEAR_MAIN end
            local overlayPart = makeOverlayForPart(orig, "", color, useHeadMesh)
            overlayPart.Parent = overlayModel

            -- make overlay slightly bigger to overlap nicely
            overlayPart.Size = orig.Size * Vector3.new(1.04, 1.04, 1.04)
        end
    end

    -- try to attach real head accessory if available (preferred)
    local gotHead = safeGetObjects(HEAD_ASSET_ID)
    if gotHead and #gotHead > 0 then
        for _,obj in pairs(gotHead) do
            if obj:IsA("Accessory") then
                -- parent temporary
                local acc = obj:Clone()
                acc.Parent = overlayModel
                -- weld accessory handle to real Head
                local head = character:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    local handle = acc:FindFirstChildWhichIsA("BasePart")
                    if handle then
                        handle.CanCollide = false
                        handle.Anchored = false
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = handle
                        weld.Part1 = head
                        weld.Parent = handle
                    end
                end
            end
        end
    end

    -- try to attach aura accessory if available; if not, do particle hands
    local gotAura = safeGetObjects(AURA_ASSET_ID)
    local auraAttached = false
    if gotAura and #gotAura > 0 then
        for _,obj in pairs(gotAura) do
            if obj:IsA("Accessory") then
                local acc = obj:Clone()
                acc.Parent = overlayModel
                local head = character:FindFirstChild("Head") or character:FindFirstChild("Torso")
                local handle = acc:FindFirstChildWhichIsA("BasePart")
                if handle and head then
                    handle.CanCollide = false
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = handle
                    weld.Part1 = head
                    weld.Parent = handle
                    auraAttached = true
                end
            end
        end
    end

    -- if aura accessory not available, add particles to hands
    if not auraAttached then
        local lh = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
        local rh = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
        local function makeAura(part)
            if not part then return end
            local e = Instance.new("ParticleEmitter")
            e.Name = "CheeseAuraEffect"
            e.Texture = "rbxassetid://243660364"
            e.Rate = 60
            e.Lifetime = NumberRange.new(0.6,1)
            e.Speed = NumberRange.new(0.5,1.2)
            e.Size = NumberSequence.new{ NumberSequenceKeypoint.new(0,0.6), NumberSequenceKeypoint.new(1,0) }
            e.Color = ColorSequence.new(BEAR_ACCENT)
            e.LightEmission = 1
            e.Parent = part
        end
        makeAura(lh)
        makeAura(rh)
    end

    return overlayModel, originals
end

local function restoreOriginals(originals)
    if not originals then return end
    for _,part in pairs(originals) do
        restoreOriginalPartLocal(part)
    end
end

-- main bind
local currentOverlay = nil
local currentOriginals = nil

local function bindCharacter(char)
    -- small delay so char parts exist
    char:WaitForChild("Humanoid", 5)
    char:WaitForChild("Head", 5)
    -- cleanup old overlay
    clearOldOverlay()
    if currentOverlay then currentOverlay:Destroy() end
    if currentOriginals then restoreOriginals(currentOriginals) end

    -- create overlay
    local overlay, originals = createOverlay(char)
    currentOverlay = overlay
    currentOriginals = originals

    -- on character removing restore
    char.AncestryChanged:Connect(function()
        if not char:IsDescendantOf(game) then
            if currentOverlay then currentOverlay:Destroy() end
            if currentOriginals then restoreOriginals(currentOriginals) end
        end
    end)
end

-- bind now & on respawn
local char = player.Character or player.CharacterAdded:Wait()
bindCharacter(char)
player.CharacterAdded:Connect(function(newChar)
    -- wait small bit then bind (avoid racing)
    task.wait(0.3)
    bindCharacter(newChar)
end)

print("dios del queso overlay activo :D")
