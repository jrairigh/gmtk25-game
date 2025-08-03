require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.camera")
require("assets.items")
require("assets.math")

PlayerHomePosition = Vector:New(217, 153)
RocketPartsFound = 0

local playerTransform = {
    Position = PlayerHomePosition, 
    Scale = Vector:New(0.5, 0.5), 
    Rotation = 0
}

local playerTarget = Vector.Zero
local playerMoveDirection = Vector.Zero
local playerSpeed = 100
local playerIsOnWater = false
--Inventory.AddItem(Items.Boat)

local PlayerStates = {
    Alive = 1,
    Dead = 2
}

local playerState = PlayerStates.Dead

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

local function IsAtLaunchPad(nextFramePlayerPosition)
    local launchPadBoundingBox = {
        X = LaunchPad.Transform.Position.X - SpriteSize * 0.5,
        Y = LaunchPad.Transform.Position.Y - SpriteSize * 0.5,
        Width = SpriteSize,
        Height = SpriteSize
    }
    return CheckCollision(launchPadBoundingBox, nextFramePlayerPosition)
end

local function CheckCliffCollision(nextFramePlayerPosition)
    return CheckCollision({X = -280, Y = -378, Width = 166, Height = 13}, nextFramePlayerPosition) or
           CheckCollision({X = -512, Y = -234, Width = 278, Height = 12}, nextFramePlayerPosition) or
           CheckCollision({X = -125, Y = -512, Width = 19, Height = 147}, nextFramePlayerPosition) or
           CheckCollision({X = -245, Y = -263, Width = 19, Height = 41}, nextFramePlayerPosition)
end

local function CheckCollisionWithNocturalAlienBurrow(nextFramePlayerPosition)
    return CheckCollision({X = 379, Y = -355, Width = 36, Height = 22}, nextFramePlayerPosition) and NocturnalAlien.State ~= CommonStates.Dead
end

local function CheckCollisions()
    if playerMoveDirection == Vector.Zero then
        return
    end
    -- Check player colliding with water or cliffs
    local nextFramePlayerPosition = playerTransform.Position + playerMoveDirection
    if playerIsOnWater then
        if CheckCliffCollision(nextFramePlayerPosition) then
            Sounds.PlayNopeSfx()
            playerMoveDirection = Vector.Zero
        elseif not IsTouchingWater(nextFramePlayerPosition, 4, 4) then
            playerIsOnWater = false
        end
    elseif IsTouchingWater(nextFramePlayerPosition, 4, 4) then
        -- checking if player is on launch pad because it uses the same mask as the water, so acquiring the boat would allow saling through
        -- the launch pad
        if Inventory.HasItem(Items.Boat.Id) and not CheckCliffCollision(nextFramePlayerPosition) then
            playerIsOnWater = true
        else
            Sounds.PlayNopeSfx()
            playerMoveDirection = Vector.Zero
            playerIsOnWater = false
        end
    elseif CheckCollisionWithNocturalAlienBurrow(nextFramePlayerPosition) or IsAtLaunchPad(nextFramePlayerPosition) then
        Sounds.PlayNopeSfx()
        playerMoveDirection = Vector.Zero
    end
end

local function UpdateCameraTarget()
    local playerPosition = playerTransform.Position
    local playerOffsetFromCenter = playerPosition - Camera.Position()
    local x = 10
    local y = 50
    local factor = 0.5
    if not IsDevice(SupportedDevices.MotoGPower) then
        x = 100
	factor = 0.2
    end
    if (math.abs(playerOffsetFromCenter.X) > x) or (math.abs(playerOffsetFromCenter.Y) > y) then
        Camera.MoveToTarget(playerPosition + playerMoveDirection * ((Window.Width * factor) / GetCameraZoom()))
    end
end

local function CheckItemsTouched()
    if IsItemTouched(Fins) then
        Inventory.AddItem(Items.Fins)
        RocketPartsFound = RocketPartsFound + 1
    elseif IsItemTouched(Body) then
        Inventory.AddItem(Items.Body)
        RocketPartsFound = RocketPartsFound + 1
    elseif IsItemTouched(FuelRod1) then
        Inventory.AddItem(Items.FuelRod1)
        RocketPartsFound = RocketPartsFound + 1
    elseif IsItemTouched(FuelRod2) then
        Inventory.AddItem(Items.FuelRod2)
        RocketPartsFound = RocketPartsFound + 1
    elseif IsItemTouched(FuelRod3) then
        Inventory.AddItem(Items.FuelRod3)
        RocketPartsFound = RocketPartsFound + 1
    elseif IsItemTouched(CrewCapsule) then
        Inventory.AddItem(Items.CrewCapsule)
        RocketPartsFound = RocketPartsFound + 1
    elseif IsItemTouched(NavigationModule) then
        Inventory.AddItem(Items.NavigationModule)
        RocketPartsFound = RocketPartsFound + 1
    elseif IsItemTouched(CommunicationsModule) then
        Inventory.AddItem(Items.CommunicationsModule)
        RocketPartsFound = RocketPartsFound + 1
    elseif IsItemTouched(Boat) then
        Inventory.AddItem(Items.Boat)
    elseif Meat ~= nil then
        if IsItemTouched(Meat) then
            Inventory.AddItem(Items.Meat)
        end
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
        if playerIsOnWater then
            Textures.DrawItems(1, 3, 0xFFFFFFFF, playerTransform)
        else
            Textures.DrawPlayer(0, 0, 0xFFFFFFFF, playerTransform)
        end
    end,

    HasWonGame = function()
        return IsAtLaunchPad(playerTransform.Position + playerMoveDirection) and RocketPartsFound == 8
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
    end,

    IsDead = function()
        return playerState == PlayerStates.Dead
    end
}