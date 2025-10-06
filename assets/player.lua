require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.camera")
require("assets.items")
require("assets.math")

PlayerHomePosition = Vector.Zero
RocketPartsFound = 0

local playerTransform = {
    Position = PlayerHomePosition, 
    Scale = Vector:New(1, 1), 
    Rotation = 0
}

local playerTarget = Vector.Zero
local playerMoveDirection = Vector.Zero
local playerSpeed = 100
local playerIsOnWater = false

local PlayerStates = {
    Alive = 1,
    Dead = 2
}

local playerState = PlayerStates.Dead

local function IsItemTouched(item)
    local itemBoundingBox = {
        X = item.Transform.Position.X - SpriteSize * 0.5,
        Y = item.Transform.Position.Y - SpriteSize * 0.5,
        Width = SpriteSize,
        Height = SpriteSize
    }
    local isTouched = not Inventory.HasItem(item.Id) and CheckCollision(itemBoundingBox, playerTransform.Position)

    if isTouched then
        Sounds.PlayPickupSfx()
    end

    return isTouched
end

local function IsAtLaunchPad(nextFramePlayerPosition)
    local launchPadBoundingBox = {
        X = 0,
        Y = 0,
        Width = SpriteSize,
        Height = SpriteSize
    }
    return CheckCollision(launchPadBoundingBox, nextFramePlayerPosition)
end

local function CheckCliffCollision(nextFramePlayerPosition)
    return CheckCollision({X = -280, Y = -378, Width = 166, Height = 13}, nextFramePlayerPosition) or
           CheckCollision({X = -512, Y = -234, Width = 278, Height = 12}, nextFramePlayerPosition) or
           CheckCollision({X = -125, Y = -512, Width = 19, Height = 147}, nextFramePlayerPosition) or
           CheckCollision({X = -245, Y = -263, Width = 19, Height = 41}, nextFramePlayerPosition)
end

local function CheckCollisionWithNocturalAlienBurrow(nextFramePlayerPosition)
    return CheckCollision({X = 379, Y = -355, Width = 36, Height = 22}, nextFramePlayerPosition)
end

local function CheckCollisions()
    if playerMoveDirection == Vector.Zero then
        return
    end
    -- Check player colliding with water or cliffs
    local nextFramePlayerPosition = playerTransform.Position + playerMoveDirection
    if playerIsOnWater then
        if CheckCliffCollision(nextFramePlayerPosition) then
            Sounds.PlayNopeSfx()
            playerMoveDirection = Vector.Zero
        end
    elseif CheckCollisionWithNocturalAlienBurrow(nextFramePlayerPosition) then
        Sounds.PlayNopeSfx()
        playerMoveDirection = Vector.Zero
    end
end

local function UpdateCameraTarget()
    Camera.Speed = math.max(100, Camera:DistanceToTarget() * 0.75)
    Camera:UpdateTarget(playerTransform.Position, playerMoveDirection)
    --local playerPosition = playerTransform.Position
    --local playerOffsetFromCenter = playerPosition - Camera.Position()

    --if not IsDevice(SupportedDevices.MotoGPower) then
    --    x = 100
	--factor = 0.2
    --end
    --if (math.abs(playerOffsetFromCenter.X) > x) or (math.abs(playerOffsetFromCenter.Y) > y) then
    --    Camera.MoveToTarget(playerPosition + playerMoveDirection * ((Window.Width * factor) / Camera.Zoom()))
    --end
end

local function CheckItemsTouched()
    if IsItemTouched(FuelRod1) then
        Inventory.AddItem(Items.FuelRod1)
    end
end

local function MovePlayerToTarget()
    local playerPosition = playerTransform.Position
    if (playerTarget - playerPosition):SquaredLength() > 1 then
        playerTransform.Position = playerPosition + playerMoveDirection * playerSpeed * GetFrameTime()
    end
end

Player = {
    TotalMoves = 0,
    Cell = {
        X = 0,
        Y = 0
    },

    Update = function(self, cellX, cellY)
        if not self:IsValidMove(cellX, cellY) then
            return
        end

        self.TotalMoves = self.TotalMoves + math.abs(self.Cell.X - cellX) + math.abs(self.Cell.Y - cellY)
        self.Cell.X = cellX
        self.Cell.Y = cellY
        --print("Player cell X " .. self.Cell.X .. "   cell Y " .. self.Cell.Y)
    end,

    Position = function()
        return playerTransform.Position
    end,
    Render = function()
        if playerIsOnWater then
            Textures.DrawItems(1, 3, 0xFFFFFFFF, playerTransform)
        else
            Textures.DrawPlayer(0, 0, 0xFFFFFFFF, playerTransform)
        end
    end,

    HasWonGame = function()
        return IsAtLaunchPad(playerTransform.Position + playerMoveDirection) and RocketPartsFound == 8
    end,

    IsPlayerOnWater = function()
        return playerIsOnWater
    end,

    Dies = function()
        Sounds.PlayDeathSfx()
        playerTransform.Position = PlayerHomePosition
        playerMoveDirection = Vector.Zero
        playerState = PlayerStates.Dead
        playerIsOnWater = false
        Camera.MoveToTarget(PlayerHomePosition)
    end,

    IsDead = function()
        return playerState == PlayerStates.Dead
    end,

    IsValidMove = function(self, cellX, cellY)
        -- single mode for now
        return not (self.Cell.X ~= cellX and self.Cell.Y ~= cellY)
    end
}