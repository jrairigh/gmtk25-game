require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.player")

local cameraTarget = Vector.Zero

Camera = {
    Offset = function()
        local cameraOffset = GetCameraOffset()
        return Vector:New(cameraOffset.X, cameraOffset.Y)
    end,

    Position = function()
        return GetCameraPosition()
    end,

    MoveToTarget = function(target)
        cameraTarget = target
    end,
    
    Update = function()
        local cameraPosition = Camera.Position()
        local cameraOffset = cameraTarget - cameraPosition
        local length = cameraOffset:Length()
        if length > 10 then
            local cameraMoveDirection = cameraOffset:Normalized()
            cameraPosition = cameraPosition + cameraMoveDirection * length * 0.5 * GetFrameTime()
            SetCameraPosition(cameraPosition)
        else
            local playerOffsetFromCenter = Player.Position() - Camera.Position()
            if (math.abs(playerOffsetFromCenter.X) > 10) or (math.abs(playerOffsetFromCenter.Y) > 50) then
                Camera.MoveToTarget(Player.Position())
            end
        end
    end
}