require("assets.rt.capi")
require("assets.rt.vec2")

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
            cameraPosition = cameraPosition + cameraMoveDirection * length * 0.75 * GetFrameTime()
            SetCameraPosition(cameraPosition)
        end
    end
}