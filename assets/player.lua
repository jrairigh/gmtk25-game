require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.camera")
require("assets.items")
require("assets.inventory")

local playerTransform = {
    Position = Vector.Zero, 
    Scale = Vector:New(0.5, 0.5), 
    Rotation = 0
}

local playerTarget = Vector.Zero
local playerMoveDirection = Vector.Zero
local playerSpeed = 100

local function IsItemTouched(item)
    local itemBoundingBox = {
        X = item.Transform.Position.X - SpriteSize * 0.5,
        Y = item.Transform.Position.Y - SpriteSize * 0.5,
        Width = SpriteSize,
        Height = SpriteSize
    }
    local isTouched = not Inventory.HasItem(GetItemById(item.Id)) and CheckCollision(itemBoundingBox, playerTransform.Position)

    if isTouched then
        Sounds.PlayPickupSfx()
    end

    return isTouched
end

Player = {
    Update = function()
        local touch = GetTouch()
        local playerPosition = playerTransform.Position

        if touch.IsTapped then
            playerTarget = ScreenToWorldSpace(touch.Position)
            playerMoveDirection = (playerTarget - playerPosition):Normalized()
        end

        if (playerTarget - playerPosition):SquaredLength() > 1 then
            playerTransform.Position = playerPosition + playerMoveDirection * playerSpeed * GetFrameTime()
        end

        local playerOffsetFromCenter = playerPosition - Camera.Position()
        if (math.abs(playerOffsetFromCenter.X) > 10) or (math.abs(playerOffsetFromCenter.Y) > 50) then
            Camera.MoveToTarget(playerPosition)
        end

        if IsItemTouched(Fins) then
            Inventory.AddItem(Items.Fins)
        elseif IsItemTouched(Body) then
            Inventory.AddItem(Items.Body)
        elseif IsItemTouched(FuelRod1) then
            Inventory.AddItem(Items.FuelRod1)
        elseif IsItemTouched(FuelRod2) then
            Inventory.AddItem(Items.FuelRod2)
        elseif IsItemTouched(FuelRod3) then
            Inventory.AddItem(Items.FuelRod3)
        elseif IsItemTouched(CrewCapsule) then
            Inventory.AddItem(Items.CrewCapsule)
        elseif IsItemTouched(NavigationModule) then
            Inventory.AddItem(Items.NavigationModule)
        elseif IsItemTouched(CommunicationsModule) then
            Inventory.AddItem(Items.CommunicationsModule)
        end
    end,

    Position = function()
        return playerTransform.Position
    end,

    Render = function()
        Textures.DrawPlayer(0, 0, 0xFFFFFFFF, playerTransform)
    end
}