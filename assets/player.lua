require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.camera")
require("assets.items")

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
    local isTouched = not Inventory.HasItem(item.Id) and CheckCollision(itemBoundingBox, playerTransform.Position)

    if isTouched then
        Sounds.PlayPickupSfx()
    end

    return isTouched
end

local function IsAtLaunchPad()
    local launchPadBoundingBox = {
        X = LaunchPad.Transform.Position.X - SpriteSize * 0.5,
        Y = LaunchPad.Transform.Position.Y - SpriteSize * 0.5,
        Width = SpriteSize,
        Height = SpriteSize
    }
    return CheckCollision(launchPadBoundingBox, playerTransform.Position)
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
            Inventory.SelectItem(Items.Fins.Id) -- TODO selecting should be done in UI
        elseif IsItemTouched(Body) then
            Inventory.AddItem(Items.Body)
            Inventory.SelectItem(Items.Body.Id) -- TODO selecting should be done in UI
        elseif IsItemTouched(FuelRod1) then
            Inventory.AddItem(Items.FuelRod1)
            Inventory.SelectItem(Items.FuelRod1.Id) -- TODO selecting should be done in UI
        elseif IsItemTouched(FuelRod2) then
            Inventory.AddItem(Items.FuelRod2)
            Inventory.SelectItem(Items.FuelRod2.Id) -- TODO selecting should be done in UI
        elseif IsItemTouched(FuelRod3) then
            Inventory.AddItem(Items.FuelRod3)
            Inventory.SelectItem(Items.FuelRod3.Id) -- TODO selecting should be done in UI
        elseif IsItemTouched(CrewCapsule) then
            Inventory.AddItem(Items.CrewCapsule)
            Inventory.SelectItem(Items.CrewCapsule.Id) -- TODO selecting should be done in UI
        elseif IsItemTouched(NavigationModule) then
            Inventory.AddItem(Items.NavigationModule)
            Inventory.SelectItem(Items.NavigationModule.Id) -- TODO selecting should be done in UI
        elseif IsItemTouched(CommunicationsModule) then
            Inventory.AddItem(Items.CommunicationsModule)
            Inventory.SelectItem(Items.CommunicationsModule.Id) -- TODO selecting should be done in UI
        end
    end,

    Position = function()
        return playerTransform.Position
    end,

    Render = function()
        Textures.DrawPlayer(0, 0, 0xFFFFFFFF, playerTransform)
    end,

    HasWonGame = function()
        return IsAtLaunchPad() and Inventory.HasItems({Items.Body.Id, Items.Fins.Id, Items.FuelRod1.Id, Items.FuelRod2.Id, Items.FuelRod3.Id, Items.CrewCapsule.Id, Items.NavigationModule.Id, Items.CommunicationsModule.Id})
    end
}