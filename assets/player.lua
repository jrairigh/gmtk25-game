require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.camera")

local playerTransform = {
    Position = Vector.Zero, 
    Scale = Vector:New(0.5, 0.5), 
    Rotation = 0
}

local playerTarget = Vector.Zero
local playerMoveDirection = Vector.Zero
local playerSpeed = 100

Player = {
    Update = function()
        local touch = GetTouch()
        local playerPosition = playerTransform.Position

        if touch.IsTapped then
            playerTarget = ScreenToWorldSpace(touch.Position)
            playerMoveDirection = (playerTarget - playerPosition):Normalized()
        end

        if (playerTarget - playerPosition):SquaredLength() > 1 then
            playerTransform.Position = playerPosition + playerMoveDirection * playerSpeed * GetFrameTime()
        end

        local playerOffsetFromCenter = playerPosition - Camera.Position()
        if (math.abs(playerOffsetFromCenter.X) > 10) or (math.abs(playerOffsetFromCenter.Y) > 50) then
            Camera.MoveToTarget(playerPosition)
        end
    end,

    Position = function()
        return playerTransform.Position
    end,

    Render = function()
        Textures.DrawPlayer(0, 0, 0xFFFFFFFF, playerTransform)
    end
}