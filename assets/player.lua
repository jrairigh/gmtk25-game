require("assets.rt.capi")
require("assets.rt.vec2")

local playerTransform = {
    Position = Vector.Zero, 
    Scale = Vector:New(0.5, 0.5), 
    Rotation = 0
}

local oldPlayerPosition = Vector.Zero
local moveTime = 0
local touchPosition = Vector.Zero
local delay = 1

Player = {
    Update = function()
        local touch = GetTouch()
        local time = GetTime()

        if touch.IsTapped then
            touchPosition = ScreenToWorldSpace(touch.Position)
            moveTime = time + delay
            oldPlayerPosition = playerTransform.Position
        end

        if (moveTime - time) > 0 then
            local t = (delay - (moveTime - time)) / delay
            playerTransform.Position = Vector.Lerp(oldPlayerPosition, touchPosition, t)
        end
    end,

    Position = function()
        return playerTransform.Position
    end,

    Render = function()
        Textures.DrawPlayer(0, 0, 0xFFFFFFFF, playerTransform)
    end
}