require("assets.rt.vec2")
require("assets.navpath")
require("assets.gameobject")

PacmanStates = {
    Alive = 1,
    Dead = 2
}

local maxDistToTeleportPoint = 5
local pacmanSpeed = 60

local function Initialize(self)
    if IsDevice(SupportedDevices.MotoGPower) then
        self.Transform.Position = NavPathPoints[33]
        self.Transform.Scale = Vector:New(0.6, 0.6)
    else
        self.Transform.Position = Vector:New(0, 28)
        self.Transform.Scale = Vector:New(0.75, 0.75)
    end
    self.State = PacmanStates.Alive
    self.MoveDirection = Vector.Right
    self.AttemptedDirection = self.MoveDirection
    self.Transform.Rotation = 0
end

local function IsGhostTouched(self)
    local ghosts = {Blinky, Inky, Pinky, Clyde}
    local touched = false
    for i=1, #ghosts do
        local ghost = ghosts[i]
        if ghost.State == GhostStates.Chase then
            local pacmanPos = self.Transform.Position
            local ghostPos = ghost.Transform.Position
            touched = touched or (ghostPos - pacmanPos):SquaredLength() < 100
        end
    end

    return touched
end

local function Update(self, gameState)
    local touch = GetTouch()
    if IsKeyDown(Key.W) or touch.IsSwipedUp then
        self.AttemptedDirection = Vector.Up
    elseif IsKeyDown(Key.A) or touch.IsSwipedLeft then
        self.AttemptedDirection = Vector.Left
    elseif IsKeyDown(Key.S) or touch.IsSwipedDown then
        self.AttemptedDirection = Vector.Down
    elseif IsKeyDown(Key.D) or touch.IsSwipedRight then
        self.AttemptedDirection = Vector.Right
    end

    self.MoveDirection = MoveNavPath(self.Transform.Position, self.MoveDirection, self.AttemptedDirection)
    self.Transform.Position = Teleport(self.Transform.Position + pacmanSpeed * FrameTime * self.MoveDirection, self.MoveDirection, maxDistToTeleportPoint)

    if self.MoveDirection == Vector.Up then
        self.Transform.Rotation = 270
    elseif self.MoveDirection == Vector.Down then
        self.Transform.Rotation = 90
    elseif self.MoveDirection == Vector.Left then
        self.Transform.Rotation = 180
    elseif self.MoveDirection == Vector.Right then
        self.Transform.Rotation = 0
    end

    if IsGhostTouched(self) then
        Pacman.State = PacmanStates.Dead
    end
end

local function Render(self)
    local frameSpeed = 10
    local frame = math.fmod(frameSpeed * GameWallClock, 3)
    Textures.DrawPacman(0, frame, 0xFFFFFFFF, self.Transform)
end

Pacman = GameObject:New(
    -- Transform
    {
        Position = Vector.Zero,
        Rotation = 0,
        Scale = Vector:New(0.75, 0.75)
    },

    -- Hit Box
    {X = 0, Y = 0, Width = 100, Height = 100},

    Initialize,
    Update,
    Render
)
