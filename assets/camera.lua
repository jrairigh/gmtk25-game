require("assets.rt.capi")
require("assets.rt.vec2")

local cameraTarget = Vector.Zero
local isCameraMoving = true
local boarderCoord = 500

Camera = {

    Initialize = function()
        SetCameraZoom(3)
        SetCameraPosition(Vector:New(-300, 300))
        cameraTarget = PlayerHomePosition
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
        local scale = 0.75
        isCameraMoving = length > 10
        if isCameraMoving then
            local camZoom = GetCameraZoom()
            local camOffsetX = Window.Width / (2 * camZoom)
            local camOffsetY = Window.Height / (2 * camZoom)
            
            if cameraPosition.X < (-boarderCoord + camOffsetX) then
                cameraPosition.X = -boarderCoord + camOffsetX
            end
            
            if cameraPosition.X > (boarderCoord - camOffsetX) then
                cameraPosition.X = boarderCoord - camOffsetX
            end
            
            if cameraPosition.Y > (boarderCoord - camOffsetY) then
                cameraPosition.Y = boarderCoord - camOffsetY
            end
            
            if cameraPosition.Y < (-boarderCoord + camOffsetY) then
                cameraPosition.Y = -boarderCoord + camOffsetY
            end
            
            local speed = math.max(100, length * scale)
            
            if Player.IsDead() then
                speed = 300
            end
            
            local cameraMoveDirection = cameraOffset:Normalized()
            cameraPosition = cameraPosition + cameraMoveDirection * speed * GetFrameTime()
            SetCameraPosition(cameraPosition)
        end
    end
}
