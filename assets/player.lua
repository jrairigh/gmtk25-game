require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.camera")
require("assets.items")
require("assets.math")

PlayerHomePosition = Vector:New(217, 153)
local playerTransform = {
    Position = PlayerHomePosition, 
    Scale = Vector:New(0.5, 0.5), 
    Rotation = 0
}

local playerTarget = Vector.Zero
local playerMoveDirection = Vector.Zero
local playerSpeed = 100
local playerIsOnWater = false

Inventory.AddItem(Items.Boat)

local PlayerStates = {
    Alive = 1,
    Dead = 2
}

local playerState = PlayerStates.Alive

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

local function CheckCollisions()
    -- Check player colliding with water or cliffs
    local nextFramePlayerPosition = playerTransform.Position + playerMoveDirection
    if playerMoveDirection ~= Vector.Zero and IsTouchingWater(nextFramePlayerPosition, 4, 4)  then
        -- checking if player is on launch pad because it uses the same mask as the water, so acquiring the boat would allow saling through
        -- the launch pad
        if Inventory.HasItem(Items.Boat.Id) and not IsAtLaunchPad() then
            playerIsOnWater = true
        else
            Sounds.PlayNopeSfx()
            playerMoveDirection = Vector.Zero
            playerIsOnWater = false
        end
    elseif playerIsOnWater then
        if CheckCollision({X = -280, Y = -378, Width = 166, Height = 13}, nextFramePlayerPosition) or
           CheckCollision({X = -512, Y = -234, Width = 218, Height = 12}, nextFramePlayerPosition) or
           CheckCollision({X = -127, Y = -512, Width = 12, Height = 147}, nextFramePlayerPosition) then
            Sounds.PlayNopeSfx()
            playerMoveDirection = Vector.Zero
        else
            playerIsOnWater = false
        end
    end
end

local function UpdateCameraTarget()
    local playerPosition = playerTransform.Position
    local playerOffsetFromCenter = playerPosition - Camera.Position()
    if (math.abs(playerOffsetFromCenter.X) > 10) or (math.abs(playerOffsetFromCenter.Y) > 50) then
        Camera.MoveToTarget(playerPosition + playerMoveDirection * ((Window.Width * 0.5) / GetCameraZoom()))
    end
end

local function CheckItemsTouched()
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
    elseif IsItemTouched(Meat) then
        Inventory.AddItem(Items.Meat)
        Inventory.SelectItem(Items.Meat.Id) -- TODO selecting should be done in UI
    elseif IsItemTouched(Boat) then
        Inventory.AddItem(Items.Boat)
        Inventory.SelectItem(Items.Boat.Id) -- TODO selecting should be done in UI
    end
end

local function MovePlayerToTarget()
    local playerPosition = playerTransform.Position
    if (playerTarget - playerPosition):SquaredLength() > 1 then
        playerTransform.Position = playerPosition + playerMoveDirection * playerSpeed * GetFrameTime()
    end
end

local function GetTouchTarget()
    local touch = GetTouch()
    local playerPosition = playerTransform.Position
    if touch.IsTapped then
        playerTarget = ScreenToWorldSpace(touch.Position)
        playerMoveDirection = (playerTarget - playerPosition):Normalized()
    end
end

local function RenderPlayerShadow()
    local bounds = {}
    if playerIsOnWater then
        bounds = {
            X = playerTransform.Position.X - 10,
            Y = playerTransform.Position.Y + 5,
            Width = 20,
            Height = 5,
        }
    else
        bounds = {
            X = playerTransform.Position.X - 3,
            Y = playerTransform.Position.Y + 5,
            Width = 6,
            Height = 3,
        }
    end

    DrawRectangle(bounds, 1, 0, 0x000000c0, true)
end

local function UpdateAlive()
    GetTouchTarget()
    CheckCollisions()
    MovePlayerToTarget()
    UpdateCameraTarget()
    CheckItemsTouched()
end

local function UpdateDead()
    if Camera.IsCameraIdle() then
        playerState = PlayerStates.Alive
    end
end

Player = {
    Update = function()
        if playerState == PlayerStates.Alive then
            UpdateAlive()
        elseif playerState == PlayerStates.Dead then
            UpdateDead()
        end
    end,

    Position = function()
        return playerTransform.Position
    end,

    Render = function()
        --RenderPlayerShadow()
        if playerIsOnWater then
            Textures.DrawItems(1, 3, 0xFFFFFFFF, playerTransform)
        else
            Textures.DrawPlayer(0, 0, 0xFFFFFFFF, playerTransform)
        end
    end,

    HasWonGame = function()
        return IsAtLaunchPad() and Inventory.HasItems({Items.Body.Id, Items.Fins.Id, Items.FuelRod1.Id, Items.FuelRod2.Id, Items.FuelRod3.Id, Items.CrewCapsule.Id, Items.NavigationModule.Id, Items.CommunicationsModule.Id})
    end,

    IsPlayerOnWater = function()
        return playerIsOnWater
    end,

    Dies = function()
        Sounds.PlayDeathSfx()
        playerTransform.Position = PlayerHomePosition
        playerMoveDirection = Vector.Zero
        playerState = PlayerStates.Dead
        playerIsOnWater = false
        Camera.MoveToTarget(PlayerHomePosition)
    end
}