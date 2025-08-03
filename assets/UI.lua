require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.planet_cycles")
require("assets.player")
require("assets.math")

local target = Vector.Zero
local fontSize = 20
local fontSpacing = 5
local fontColor = 0xFFFFFFFF
local fontRotation = 0
local fontY = 20

UI = {
    RenderUI = function(inWorld)
        if not inWorld then
            local hour, minute = PlanetCycles.GetTime()
            DrawText(string.format("%02d:%02d", hour, minute), Window.Width / 2 - 30, fontY, fontSize, fontSpacing, fontRotation, fontColor)

            local temp = math.floor(PlanetCycles.GetTemperature())
            DrawText(temp .. " C", Window.Width - 80, fontY, fontSize, fontSpacing, fontRotation, fontColor)

            DrawText(RocketPartsFound .. " / 8", 30, fontY, fontSize, fontSpacing, fontRotation, fontColor)
        else
            local touch = GetTouch()
            if touch.IsTapped then
                target = ScreenToWorldSpace(touch.Position)
                target:Print()
            end

            if (Player.Position() - target):SquaredLength() > (2 * 2) then
                DrawCircle(target, 4, 0x00FF00FF, false)
            else
                target = Player.Position()
            end
        end
    end,
}