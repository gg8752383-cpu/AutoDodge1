-- Violence District Predictive AutoDodge (client-side, best-effort)
-- PlaceId: 93978595733734
-- Role/name agnostic: predicts near-future player collisions and fast projectile paths.
-- This does NOT guarantee avoidance; server-side attacks and hidden hitboxes may differ.

local EXPECTED_PLACE_ID = 93978595733734
if game.PlaceId ~= EXPECTED_PLACE_ID then
    warn("[Predictive AutoDodge] Wrong game/place.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Enabled = true,
    Horizon = 0.85,             -- predict this far ahead
    PlayerThreatRadius = 5.0,   -- predicted closest approach
    PlayerScanRange = 26,
    MinimumApproachSpeed = 2.5,
    DodgeSeconds = 0.19,
    Cooldown = 0.34,
    ProjectileHorizon = 0.75,
    ProjectileRadius = 3.2,
    ProjectileMinSpeed = 20,
    MaxTrackedParts = 250,
    ProjectileScanInterval = 0.06,
}

local shuttingDown = false
local connections = {}
local trackedParts = {}
local activeDodge = nil
local lastDodge = -math.huge
local scanAccumulator = 0
local gui

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end

local function characterParts(character)
    if not character then return nil, nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid and root and humanoid.Health > 0 then return humanoid, root end
    return nil, nil
end

local function flat(v)
    return Vector3.new(v.X, 0, v.Z)
end

local function unitOrZero(v)
    if v.Magnitude < 0.001 then return Vector3.zero end
    return v.Unit
end

local function clearDirection(root, direction)
    direction = unitOrZero(flat(direction))
    if direction.Magnitude < 0.01 then return nil end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    params.IgnoreWater = true

    local origin = root.Position + Vector3.new(0, 1.5, 0)
    if Workspace:Raycast(origin, direction * 5.5, params) then
        return nil
    end

    -- Avoid deliberately stepping off a ledge.
    local groundOrigin = root.Position + direction * 3.0 + Vector3.new(0, 2.5, 0)
    local ground = Workspace:Raycast(groundOrigin, Vector3.new(0, -7, 0), params)
    if not ground then return nil end
    return direction
end

local function chooseDodgeDirection(myRoot, threatPosition, threatVelocity)
    local away = flat(myRoot.Position - threatPosition)
    local side = Vector3.new(-threatVelocity.Z, 0, threatVelocity.X)
    if side.Magnitude < 0.5 then
        side = Vector3.new(-away.Z, 0, away.X)
    end
    side = unitOrZero(side)

    local candidates = {
        side + unitOrZero(away) * 0.35,
        -side + unitOrZero(away) * 0.35,
        away,
        side,
        -side,
    }
    for _, candidate in ipairs(candidates) do
        local clear = clearDirection(myRoot, candidate)
        if clear then return clear end
    end
    return nil
end

local function predictPlayerThreat(myRoot, otherRoot)
    local relativePosition = flat(otherRoot.Position - myRoot.Position)
    local relativeVelocity = flat(otherRoot.AssemblyLinearVelocity - myRoot.AssemblyLinearVelocity)
    local distance = relativePosition.Magnitude
    if distance < 0.1 or distance > CONFIG.PlayerScanRange then return nil end

    local speedSquared = relativeVelocity:Dot(relativeVelocity)
    if speedSquared < CONFIG.MinimumApproachSpeed ^ 2 then return nil end

    local t = math.clamp(-relativePosition:Dot(relativeVelocity) / speedSquared, 0, CONFIG.Horizon)
    local closest = relativePosition + relativeVelocity * t
    local missDistance = closest.Magnitude
    local closingSpeed = -relativePosition:Dot(relativeVelocity) / math.max(distance, 0.1)

    if closingSpeed <= 0.5 or missDistance > CONFIG.PlayerThreatRadius then return nil end
    if t <= 0.04 and distance > CONFIG.PlayerThreatRadius then return nil end

    return {
        score = t + missDistance * 0.045,
        time = t,
        position = otherRoot.Position,
        velocity = otherRoot.AssemblyLinearVelocity,
        kind = "player trajectory",
    }
end

local function isCharacterPart(instance)
    local ancestor = instance
    while ancestor and ancestor ~= Workspace do
        if ancestor:IsA("Model") and ancestor:FindFirstChildOfClass("Humanoid") then
            return true
        end
        ancestor = ancestor.Parent
    end
    return false
end

local function registerPart(instance)
    if shuttingDown or not instance:IsA("BasePart") then return end
    if not instance:IsDescendantOf(Workspace) or instance.Anchored then return end
    if LocalPlayer.Character and instance:IsDescendantOf(LocalPlayer.Character) then return end
    if isCharacterPart(instance) then return end
    if instance.AssemblyLinearVelocity.Magnitude < CONFIG.ProjectileMinSpeed then return end

    trackedParts[instance] = os.clock()
    local count = 0
    for part in pairs(trackedParts) do
        count += 1
        if count > CONFIG.MaxTrackedParts then
            trackedParts[part] = nil
        end
    end
end

local function predictProjectileThreat(myRoot)
    local now = os.clock()
    local best = nil
    for part, born in pairs(trackedParts) do
        if not part.Parent or now - born > 3.5 then
            trackedParts[part] = nil
        else
            local velocity = part.AssemblyLinearVelocity
            if velocity.Magnitude >= CONFIG.ProjectileMinSpeed then
                local relative = part.Position - myRoot.Position
                local relativeVelocity = velocity - myRoot.AssemblyLinearVelocity
                local speedSquared = relativeVelocity:Dot(relativeVelocity)
                if speedSquared > 1 then
                    local t = math.clamp(-relative:Dot(relativeVelocity) / speedSquared, 0, CONFIG.ProjectileHorizon)
                    local miss = (relative + relativeVelocity * t).Magnitude
                    if miss <= CONFIG.ProjectileRadius and (not best or t < best.time) then
                        best = {
                            score = t,
                            time = t,
                            position = part.Position,
                            velocity = velocity,
                            kind = "projectile trajectory",
                        }
                    end
                end
            end
        end
    end
    return best
end

local function dodgeFrom(threat, myRoot, humanoid)
    if not threat or os.clock() - lastDodge < CONFIG.Cooldown then return false end
    local direction = chooseDodgeDirection(myRoot, threat.position, threat.velocity)
    if not direction then return false end

    lastDodge = os.clock()
    activeDodge = { direction = direction, ends = lastDodge + CONFIG.DodgeSeconds }
    if gui and gui:FindFirstChild("Status") then
        gui.Status.Text = "PREDICTED: " .. threat.kind
    end
    return true
end

local function tick()
    if shuttingDown or not CONFIG.Enabled then return end
    local humanoid, myRoot = characterParts(LocalPlayer.Character)
    if not humanoid or not myRoot then
        activeDodge = nil
        return
    end

    if activeDodge then
        if os.clock() >= activeDodge.ends then
            activeDodge = nil
        else
            humanoid:Move(activeDodge.direction, false)
            return
        end
    end

    local bestThreat = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local _, otherRoot = characterParts(player.Character)
            if otherRoot then
                local threat = predictPlayerThreat(myRoot, otherRoot)
                if threat and (not bestThreat or threat.score < bestThreat.score) then
                    bestThreat = threat
                end
            end
        end
    end

    local projectile = predictProjectileThreat(myRoot)
    if projectile and (not bestThreat or projectile.score < bestThreat.score) then
        bestThreat = projectile
    end
    if bestThreat then dodgeFrom(bestThreat, myRoot, humanoid) end
end

local function makeUI()
    local parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not parent then return end
    local old = parent:FindFirstChild("PredictiveAutoDodgeUI")
    if old then old:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = "PredictiveAutoDodgeUI"
    gui.ResetOnSpawn = false
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(1, 0.5)
    frame.Position = UDim2.new(1, -10, 0.55, 0)
    frame.Size = UDim2.fromOffset(205, 92)
    frame.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 0, 25)
    title.Position = UDim2.fromOffset(6, 4)
    title.BackgroundTransparency = 1
    title.Text = "PREDICTIVE AUTO DODGE"
    title.TextColor3 = Color3.fromRGB(230, 240, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Position = UDim2.fromOffset(7, 33)
    toggle.Size = UDim2.new(1, -14, 0, 25)
    toggle.Text = "AUTO DODGE: ON"
    toggle.Font = Enum.Font.GothamSemibold
    toggle.TextSize = 11
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.BackgroundColor3 = Color3.fromRGB(54, 73, 98)
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 5)
    toggle.Activated:Connect(function()
        CONFIG.Enabled = not CONFIG.Enabled
        activeDodge = nil
        toggle.Text = "AUTO DODGE: " .. (CONFIG.Enabled and "ON" or "OFF")
        if gui and gui:FindFirstChild("Status") then
            gui.Status.Text = CONFIG.Enabled and "Predicting trajectories" or "Paused"
        end
    end)

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Position = UDim2.fromOffset(7, 62)
    status.Size = UDim2.new(1, -14, 0, 20)
    status.BackgroundTransparency = 1
    status.Text = "Predicting trajectories"
    status.TextColor3 = Color3.fromRGB(165, 220, 180)
    status.Font = Enum.Font.Gotham
    status.TextSize = 9
    status.Parent = frame
end

connect(Workspace.DescendantAdded, registerPart)
connect(RunService.Heartbeat, tick)
connect(RunService.Heartbeat, function(dt)
    scanAccumulator += dt
    if scanAccumulator >= CONFIG.ProjectileScanInterval then
        scanAccumulator = 0
        for part in pairs(trackedParts) do
            if not part.Parent or part.Anchored then trackedParts[part] = nil end
        end
    end
end)

task.spawn(function()
    local descendants = Workspace:GetDescendants()
    for i, object in ipairs(descendants) do
        if shuttingDown then break end
        if object:IsA("BasePart") then registerPart(object) end
        if i % 250 == 0 then task.wait() end
    end
end)

makeUI()

local env = (getgenv and getgenv()) or _G
env.PredictiveAutoDodge_Stop = function()
    if shuttingDown then return end
    shuttingDown = true
    activeDodge = nil
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    table.clear(connections)
    table.clear(trackedParts)
    if gui then pcall(function() gui:Destroy() end) end
end

print("[Predictive AutoDodge] Loaded. Role/name-independent trajectory prediction enabled; runtime success is not guaranteed.")
