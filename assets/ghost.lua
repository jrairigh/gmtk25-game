require("assets.rt.capi")
require("assets.gameobject")
require("assets.pulse")

GhostStates = {
    Chase = 1,
    Frightened = 2,
    Eaten = 3
}

local ghostScale = Vector:New(0.75, 0.75)
local chaseSpeed = 50
local eatenSpeed = 75
local maxDistToNavPoint = 0.5
local maxDistToTeleportPoint = 5
local respawnTriggerBounds = {X = -10, Y = -30, Width = 20, Height = 20}

local function Initialize(self, textureId)
    self.Id = textureId
    self.IsOnPathPoint = false
    self.State = GhostStates.Chase
    self.MoveDirection = Vector.Zero
    self.Speed = chaseSpeed
    Blinky.Transform.Position = NavPathPoints[1]
    Inky.Transform.Position = NavPathPoints[6]
    Pinky.Transform.Position = NavPathPoints[63]
    Clyde.Transform.Position = NavPathPoints[66]

    if IsDevice(SupportedDevices.MotoGPower) then
        self.Transform.Scale = Vector:New(0.6, 0.6)
        self.Speed = chaseSpeed * 0.75
    else
        self.Transform.Scale = ghostScale
    end
end

local function UpdateStateLocal(self, newState)
    if self.State ~= GhostStates.Eaten then
        self.State = newState
    end
end

local function IsPacmanTouched(self)
    local pacmanPos = Pacman.Transform.Position
    local ghostPos = self.Transform.Position
    return (ghostPos - pacmanPos):SquaredLength() < 100
end

local function UpdateFrightened(self)
    local candidateDirections = {Vector.Up, Vector.Down, Vector.Left, Vector.Right}
    local navLinkLocation = GetNavLinkLocation(self.Transform.Position, maxDistToNavPoint)
    local isOnPathPoint = navLinkLocation > 0
    if isOnPathPoint and not self.IsOnPathPoint then
        local direction
        while true do
            local randomDirection = candidateDirections[math.random(1, 4)]
            local target = randomDirection + self.Transform.Position
            direction = MoveTowardsTarget(self.Transform.Position, randomDirection, target)
            if direction ~= Vector.Zero then
                break
            end
        end
        self.MoveDirection = direction
        self.IsOnPathPoint = true
        self.Transform.Position = NavPathPoints[navLinkLocation]
    elseif not isOnPathPoint and self.IsOnPathPoint then
        self.IsOnPathPoint = false
    end

    if IsPacmanTouched(self) then
        Sounds.PlayEatGhostSfx()
        self.State = GhostStates.Eaten
        self.Speed = eatenSpeed
    end
end

local function UpdateGhostTarget(self, ghostTarget)
    local navLinkLocation = GetNavLinkLocation(self.Transform.Position, maxDistToNavPoint)
    local isOnPathPoint = navLinkLocation > 0
    if isOnPathPoint and not self.IsOnPathPoint then
        self.MoveDirection = MoveTowardsTarget(self.Transform.Position, self.MoveDirection, ghostTarget)
        self.IsOnPathPoint = true
        self.Transform.Position = NavPathPoints[navLinkLocation]
    elseif not isOnPathPoint and self.IsOnPathPoint then
        self.IsOnPathPoint = false
    end
end

local function UpdateChase(self)
    local target = self:GetChaseTarget()
    UpdateGhostTarget(self, target)
    --DrawCircle(target, 5, self.DebugTargetColor, true)
end

local function UpdateEaten(self)
    UpdateGhostTarget(self, Vector:New(0, -20))
    
    if CheckCollision(respawnTriggerBounds, self.Transform.Position) then
        self.State = GhostStates.Chase
        if IsDevice(SupportedDevices.MotoGPower) then
            self.Speed = chaseSpeed * 0.75
        else
            self.Speed = chaseSpeed
        end
    end
end

local function Update(self)
    if self.State == GhostStates.Chase then
        UpdateChase(self)
    elseif self.State == GhostStates.Frightened then
        UpdateFrightened(self)
    elseif self.State == GhostStates.Eaten then
        UpdateEaten(self)
    end

    self.Transform.Position = Teleport(self.Transform.Position + self.MoveDirection * self.Speed * FrameTime, self.MoveDirection, maxDistToTeleportPoint)
end

local function Render(self)
    local texId = self.Id
    if self.State == GhostStates.Frightened then
        texId = Textures.BlueGhost
    elseif self.State == GhostStates.Eaten then
        texId = Textures.Eyes
    end

    DrawTexture(texId, 0, 0, 0xFFFFFFFF, self.Transform)
    --DrawRectangle(respawnTriggerBounds, 1, 0x00FF00FF, 0, false)
end

Blinky = GameObject:New(
    -- Transform
    {
        Position = Vector.Zero,
        Rotation = 0,
        Scale = ghostScale
    },

    -- Hit Box
    {X = 0, Y = 0, Width = 100, Height = 100},

    Initialize,
    Update,
    Render
)

Inky = GameObject:New(
    -- Transform
    {
        Position = Vector.Zero,
        Rotation = 0,
        Scale = ghostScale
    },

    -- Hit Box
    {X = 0, Y = 0, Width = 100, Height = 100},

    Initialize,
    Update,
    Render
)

Pinky = GameObject:New(
    -- Transform
    {
        Position = Vector.Zero,
        Rotation = 0,
        Scale = ghostScale
    },

    -- Hit Box
    {X = 0, Y = 0, Width = 100, Height = 100},

    Initialize,
    Update,
    Render
)

Clyde = GameObject:New(
    -- Transform
    {
        Position = Vector.Zero,
        Rotation = 0,
        Scale = ghostScale
    },

    -- Hit Box
    {X = 0, Y = 0, Width = 100, Height = 100},

    Initialize,
    Update,
    Render
)

Blinky.DebugTargetColor = 0xFF0000FF
Pinky.DebugTargetColor = 0xFF0077FF
Inky.DebugTargetColor = 0x0077FFFF
Clyde.DebugTargetColor = 0x777700FF

Blinky.UpdateState = UpdateStateLocal
Pinky.UpdateState = UpdateStateLocal
Inky.UpdateState = UpdateStateLocal
Clyde.UpdateState = UpdateStateLocal

Blinky.GetChaseTarget = function(self)
    return Pacman.Transform.Position
end

Pinky.GetChaseTarget = function(self)
    local vUnits = 4 * WorldUnits.Y
    local hUnits = 4 * WorldUnits.X
    local pacmanPos = Pacman.Transform.Position
    local pacmanRotation = Pacman.Transform.Rotation
    local target = pacmanPos + hUnits * Vector.Right
    if pacmanRotation == 270 then
        target = pacmanPos + vUnits * Vector.Up + hUnits * Vector.Left
    elseif pacmanRotation == 90 then
        target = pacmanPos + vUnits * Vector.Down
    elseif pacmanRotation == 180 then
        target = pacmanPos + hUnits * Vector.Left
    end

    return target
end

Inky.GetChaseTarget = function(self)
    local vUnits = 2 * WorldUnits.Y
    local hUnits = 2 * WorldUnits.X
    local pacmanPos = Pacman.Transform.Position
    local pacmanRotation = Pacman.Transform.Rotation
    local target = pacmanPos + hUnits * Vector.Right
    if pacmanRotation == 270 then
        target = pacmanPos + vUnits * Vector.Up + hUnits * Vector.Left
    elseif pacmanRotation == 90 then
        target = pacmanPos + vUnits * Vector.Down
    elseif pacmanRotation == 180 then
        target = pacmanPos + hUnits * Vector.Left
    end

    local direction = -(Blinky.Transform.Position - target)
    target = target + direction

    return target
end

Clyde.GetChaseTarget = function(self)
    local pacmanPos = Pacman.Transform.Position
    local target = self.ScatterTarget
    if (pacmanPos - self.Transform.Position):SquaredLength() > 64 then
        target = pacmanPos
    end

    return target
end