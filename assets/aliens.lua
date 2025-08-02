require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.math")
require("assets.player")
require("assets.planet_cycles")

local nocturnalAlienSpeed = 100

CommonStates = {
    Idle = 0,
    Chasing = 1,
    Attacking = 2
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

local function NocturnalAlien_Update(self)
    if PlanetCycles.GetTemperature() > 10 then
        self.State = 4
        self.Transform.Position = self.HomePosition
    elseif self.State == CommonStates.Idle then
        if (Player.Position() - self.Transform.Position):SquaredLength() < (100 * 100) then
            if not Player.IsPlayerOnWater() then
                self.State = CommonStates.Chasing
            end
        end
    elseif self.State == CommonStates.Chasing then
        local moveDirection = (Player.Position() - self.Transform.Position):Normalized()
        self.Transform.Position = self.Transform.Position + moveDirection * nocturnalAlienSpeed * GetFrameTime()
        if (self.Transform.Position - self.HomePosition):SquaredLength() > (100 * 100) then
            self.State = 3
        elseif (Player.Position() - self.Transform.Position):SquaredLength() < (20 * 20) then
            self.State = CommonStates.Attacking
        end
    elseif self.State == CommonStates.Attacking then
        Player.Dies()
        self.State = 3
    elseif self.State == 3 then
        -- return to home position
        local moveDirection = (self.HomePosition - self.Transform.Position):Normalized()
        self.Transform.Position = self.Transform.Position + moveDirection * nocturnalAlienSpeed * GetFrameTime()
        if (self.Transform.Position - self.HomePosition):SquaredLength() < (10 * 10) then
            self.State = CommonStates.Idle
        end
    elseif self.State == 4 then
        if PlanetCycles.GetTemperature() <= 10 then
            self.State = CommonStates.Idle
        end
    end
end

local function NocturnalAlien_Render(self)
    if self.State == 4 then
        -- in burrow
        RenderSprites({1, 0}, self.Transform)
    else
        RenderSprites({0, 0}, self.Transform)
    end
end

local function SeaAlien_Update(self)
end

local function SeaAlien_Render(self)
    RenderSprites({0, 1, 0, 2}, self.Transform)
end

NocturnalAlien = Alien.New(
    CommonStates.Idle,
    Vector:New(396, -343), 
    NocturnalAlien_Update, NocturnalAlien_Render)

SeaAlienSubmerged = Alien.New(CommonStates.Idle, Vector:New(-212, -253), SeaAlien_Update, SeaAlien_Render)
SeaAlienBreached = Alien.New(CommonStates.Chasing, Vector.Zero, SeaAlien_Update, SeaAlien_Render)