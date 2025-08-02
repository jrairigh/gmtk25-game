require("assets.rt.capi")
require("assets.rt.vec2")

local cameraTarget = Vector.Zero
local isCameraMoving = false

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

    IsCameraIdle = function()
        return not isCameraMoving
    end,
    
    Update = function()
        local cameraPosition = Camera.Position()
        local cameraOffset = cameraTarget - cameraPosition
        local length = cameraOffset:Length()
        isCameraMoving = length > 10
        if isCameraMoving then
            local cameraMoveDirection = cameraOffset:Normalized()
            cameraPosition = cameraPosition + cameraMoveDirection * length * 0.75 * GetFrameTime()
            SetCameraPosition(cameraPosition)
        end
    end
}