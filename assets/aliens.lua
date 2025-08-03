require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.math")
require("assets.player")
require("assets.planet_cycles")

NocturnalAlienHomePosition = Vector:New(396, -343)

local nocturnalAlienSpeed = 100
local daytimeAlienSpeed = 60
local seaAlienSpeed = 100
local campirePosition = Vector:New(227, 142)

CommonStates = {
    Idle = 0,
    Chasing = 1,
    Attacking = 2,
    ReturnHome = 3,
    Dead = 9
}

Alien = {
    New = function(state, position, updateFunc, renderFunc, scale)
        local alien = {
            HomePosition = position,
            Transform = {
                Position = position,
                Rotation = 0,
                Scale = scale or Vector:New(1, 1),
            },
            State = state,
            Update = updateFunc,
            Render = renderFunc
        }
        return alien
    end,
}

local function RenderSprites(spritePositions, alienTransform)
    local anchorRow, anchorCol = spritePositions[1], spritePositions[2]
    for i = 1, #spritePositions, 2 do
        local row = spritePositions[i]
        local col = spritePositions[i + 1]
        local transform = CloneTransform(alienTransform)
        local offset = Vector:New(anchorCol - col, anchorRow - row) * SpriteSize
        transform.Position = transform.Position - offset
        Textures.DrawAliens(row, col, 0xFFFFFFFF, transform)
    end
end

local function UpdateIdle(self, enabled)
    if (Player.Position() - self.Transform.Position):SquaredLength() < (100 * 100) then
        if enabled then
            self.State = CommonStates.Chasing
            Sounds.PlayGrowlSfx()
        end
    end
end

local function UpdateChasing(self, speed, homePosition)
    local moveDirection = (Player.Position() - self.Transform.Position):Normalized()
    self.Transform.Position = self.Transform.Position + moveDirection * speed * GetFrameTime()
    if (self.Transform.Position - homePosition):SquaredLength() > (100 * 100) then
        self.State = CommonStates.ReturnHome
    elseif (Player.Position() - self.Transform.Position):SquaredLength() < (20 * 20) then
        self.State = CommonStates.Attacking
    end

    if (self.Transform.Position - campirePosition):SquaredLength() < (10 * 10) then
        Sounds.PlayAlienDeathSfx()
        self.State = CommonStates.Dead
        Meat = Item.New({3, 1}, self.Transform.Position, Items.Meat.Id)
    end
end

local function UpdateReturnHome(self, speed)
    local moveDirection = (self.HomePosition - self.Transform.Position):Normalized()
    self.Transform.Position = self.Transform.Position + moveDirection * speed * GetFrameTime()
    if (self.Transform.Position - self.HomePosition):SquaredLength() < (10 * 10) then
        self.State = CommonStates.Idle
    end
end

local function NocturnalAlien_Update(self)
    if self.State == CommonStates.Dead then
        return
    end

    if self.State == CommonStates.Idle then
        self.Transform.Position = NocturnalAlienHomePosition
        if PlanetCycles.GetTemperature() <= 10 or Inventory.HasItem(Items.Meat.Id) then
            UpdateIdle(self, not Player.IsPlayerOnWater())
        end
    elseif self.State == CommonStates.Chasing then
        if PlanetCycles.GetTemperature() > 10  then
            self.State = CommonStates.ReturnHome
        else
            UpdateChasing(self, nocturnalAlienSpeed, self.HomePosition)
        end
    elseif self.State == CommonStates.Attacking then
        Player.Dies()
        self.State = CommonStates.ReturnHome
    elseif self.State == CommonStates.ReturnHome then
        UpdateReturnHome(self, nocturnalAlienSpeed)
        if PlanetCycles.GetTemperature() > 25 then
            self.State = CommonStates.Dead
            Sounds.PlayAlienDeathSfx()
        end
    end
end

local function NocturnalAlien_Render(self)
    if self.State == CommonStates.Dead then
        return
    end
    if self.State == CommonStates.Idle then
        -- in burrow
        RenderSprites({1, 0}, self.Transform)
    else
        RenderSprites({0, 0}, self.Transform)
    end
end

local function DaytimeAlien_Update(self)
    if self.State == CommonStates.Dead then
        return
    end
    if self.State == CommonStates.Idle then
        UpdateIdle(self, not Player.IsPlayerOnWater())
    elseif self.State == CommonStates.Chasing then
        if Player.IsPlayerOnWater() then
            self.State = CommonStates.ReturnHome
        else
            UpdateChasing(self, daytimeAlienSpeed, Player.Position())
        end
    elseif self.State == CommonStates.Attacking then
        Player.Dies()
        self.State = CommonStates.ReturnHome
    elseif self.State == CommonStates.ReturnHome then
        UpdateReturnHome(self, daytimeAlienSpeed)
    end
end

local function DaytimeAlien_Render(self)
    if self.State == CommonStates.Dead then
        return
    end

    RenderSprites({0, 0}, self.Transform)
end

local function SeaAlien_Update(self)
    if self.State == CommonStates.Dead then
        return
    end
    if self.State == CommonStates.Idle then
        UpdateIdle(self, Player.IsPlayerOnWater())
    elseif self.State == CommonStates.Chasing then
        if Player.IsPlayerOnWater() then
            UpdateChasing(self, seaAlienSpeed - PlanetCycles.GetWindSpeed(), self.HomePosition)
        else
            self.State = CommonStates.ReturnHome
        end
    elseif self.State == CommonStates.Attacking then
        Player.Dies()
        self.State = CommonStates.ReturnHome
    elseif self.State == CommonStates.ReturnHome then
        UpdateReturnHome(self, seaAlienSpeed)
    end
end

local function SeaAlien_Render(self)
    if self.State == CommonStates.Dead then
        return
    end

    local isCloseToPlayer = self.State == CommonStates.Chasing and (self.Transform.Position - Player.Position()):SquaredLength() < (50 * 50)
    if self.State == CommonStates.Attacking or isCloseToPlayer then
        RenderSprites({1, 1, 1, 2}, self.Transform)
    else
        RenderSprites({0, 1, 0, 2}, self.Transform)
    end
end

NocturnalAlien = Alien.New(
    CommonStates.Idle,
    NocturnalAlienHomePosition, 
    NocturnalAlien_Update, NocturnalAlien_Render)

DaytimeAlien = Alien.New(
    CommonStates.Idle,
    Vector:New(-242, 270), 
    DaytimeAlien_Update, DaytimeAlien_Render)

SeaAlien = Alien.New(
    CommonStates.Idle, 
    Vector:New(-220, -295), 
    SeaAlien_Update, SeaAlien_Render)