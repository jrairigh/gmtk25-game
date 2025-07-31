require("assets.rt.capi")
require("assets.rt.vec2")

Camera = {
    Offset = function()
        local cameraOffset = GetCameraOffset()
        return Vector:New(cameraOffset.X, cameraOffset.Y)
    end,

    Position = function()
        return GetCameraPosition()
    end
}