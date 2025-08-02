require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.planet_cycles")
require("assets.player")
require("assets.inventory")

local target = Vector.Zero
local isOpeningInventory = true

local RenderInventory = function()
    local inventoryPosition = Vector:New(Window.Width / 2 - 160, 0)
    local scaledSpriteSize = SpriteSize * 2.5
    for i = 1, 4 do
        for j = 1, 4 do
            local x = inventoryPosition.X + (i - 1) * scaledSpriteSize
            local y = inventoryPosition.Y + (j - 1) * scaledSpriteSize
            DrawRectangle({X = x, Y = y, Width = scaledSpriteSize, Height = scaledSpriteSize}, 4, 0x000000FF, 0xFFFFFF20, true)
        end
    end

    if Inventory.HasItem(Items.Fins) then
        Fins:RenderInventory(inventoryPosition)
    end
end

UI = {
    RenderUI = function(inWorld)
        if not inWorld then
            local hour, minute = PlanetCycles.GetTime()
            DrawText(string.format("%02d:%02d", hour, minute), Window.Width / 2 - 30, 30, 20, 5, 0, 0xFFFFFFFF)

            local temp = math.floor(PlanetCycles.GetTemperature())
            DrawText(temp .. " C", Window.Width - 80, 30, 20, 5, 0, 0xFFFFFFFF)

            local windDir = PlanetCycles.GetWindVelocity()
            DrawLine(Vector:New(40, 40), Vector:New(40, 40) + windDir, 5, 0xFF0000FF)

            if isOpeningInventory then
                RenderInventory()
            end
        else
            local touch = GetTouch()
            if touch.IsTapped then
                target = ScreenToWorldSpace(touch.Position)
                target:Print()
            end

            if (Player.Position() - target):SquaredLength() > (2 * 2) then
                DrawCircle(target, 4, 0xFF0000FF, false)
            else
                target = Player.Position()
            end
        end
    end,
}