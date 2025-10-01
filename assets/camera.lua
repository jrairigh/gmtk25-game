require("assets.rt.capi")
require("assets.rt.vec2")

local cameraTarget = Vector.Zero
local boarderCoord = 500
local toIdleRadius = 10
local distanceToTarget = 0

Camera = {

    Speed = 100,

    Position = function()
        return GetCameraPosition()
    end,

    Offset = function()
        return GetCameraOffset()
    end,

    Zoom = function()
        return GetCameraZoom()
    end,

    UpdateTarget = function(self, target, targetMoveDirection)
        cameraTarget = target
        --[[local x = 10
        local y = 50
        local factor = 0.5
        local targetOffsetFromCenter = target - self.Position()
        local invCamZoom = 1 / self.Zoom()
        if (math.abs(targetOffsetFromCenter.X) > x) or (math.abs(targetOffsetFromCenter.Y) > y) then
            cameraTarget = target + targetMoveDirection * Window.Width * factor * invCamZoom
        end]]
    end,

    MoveToTarget = function(target)
        cameraTarget = target
    end,

    DistanceToTarget = function()
        return distanceToTarget
    end,

    -- TODO this is useful outside of initializing, so a better name is needed
    Initialize = function(self, zoom, position, target)
        SetCameraZoom(zoom)
        SetCameraPosition(position)
        self:UpdateTarget(target, Vector:New(1,0))
    end,

    IsCameraIdle = function()
        return not (distanceToTarget > toIdleRadius)
    end,
    
    Update = function(self)
        local cameraPosition = self.Position()
        local cameraOffset = cameraTarget - cameraPosition
        distanceToTarget = cameraOffset:Length()
        local isCameraMoving = distanceToTarget > toIdleRadius
        if isCameraMoving then
            local invCamZoom = 1 / self.Zoom()
            local camOffsetX = Window.Width * 0.5 * invCamZoom
            local camOffsetY = Window.Height * 0.5 * invCamZoom
            
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
            
            local cameraMoveDirection = cameraOffset * (1 / distanceToTarget)
            cameraPosition = cameraPosition + cameraMoveDirection * self.Speed * GetFrameTime()
            SetCameraPosition(cameraPosition)
        end
    end
}
