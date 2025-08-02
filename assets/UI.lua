require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.planet_cycles")
require("assets.player")
require("assets.math")

local target = Vector.Zero

UI = {
    RenderUI = function(inWorld)
        if not inWorld then
            local hour, minute = PlanetCycles.GetTime()
            DrawText(string.format("%02d:%02d", hour, minute), Window.Width / 2 - 30, 30, 20, 5, 0, 0xFFFFFFFF)

            local temp = math.floor(PlanetCycles.GetTemperature())
            DrawText(temp .. " C", Window.Width - 80, 30, 20, 5, 0, 0xFFFFFFFF)

            local windDir = PlanetCycles.GetWindVelocity()
            DrawLine(Vector:New(40, 40), Vector:New(40, 40) + windDir, 5, 0xFF0000FF)
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