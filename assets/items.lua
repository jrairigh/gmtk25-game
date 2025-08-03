require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.math")
require("assets.inventory")

Items = {
    Fins = {Id = 0, Position = Vector.Zero},
    Body = {Id = 1, Position = Vector.Zero},
    FuelRod1 = {Id = 2, Position = Vector.Zero},
    FuelRod2 = {Id = 3, Position = Vector.Zero},
    FuelRod3 = {Id = 4, Position = Vector.Zero},
    CrewCapsule = {Id = 5, Position = Vector.Zero},
    NavigationModule = {Id = 6, Position = Vector.Zero},
    CommunicationsModule = {Id = 7, Position = Vector.Zero},
    Meat = {Id = 8, Position = Vector.Zero},
    Boat = {Id = 9, Position = Vector.Zero},
}

Item = {
    New = function(spritePositions, position, id, scale)
        local item = {
            Transform = {
                Position = position,
                Rotation = 0,
                Scale = scale or Vector:New(1, 1),
            },
            SpritePositions = spritePositions,
            Id = id,

            Render = function(self)
                if Inventory.HasItem(self.Id) then
                    return
                end

                local anchorRow, anchorCol = self.SpritePositions[1], self.SpritePositions[2]
                for i = 1, #self.SpritePositions, 2 do
                    local row = self.SpritePositions[i]
                    local col = self.SpritePositions[i + 1]
                    local transform = CloneTransform(self.Transform)
                    local offset = Vector:New(anchorCol - col, anchorRow - row) * SpriteSize
                    transform.Position = transform.Position - offset
                    Textures.DrawItems(row, col, 0xFFFFFFFF, transform)
                end
            end
        }
        return item
    end,
}

LaunchPad = Item.New({3, 0, 1, 0, 2, 0}, Vector:New(180, 144), -1)
RocketShip = Item.New({2, 1, 1, 1, 0, 1}, Vector:New(185, 144), -1)
Campsite = Item.New({3, 3}, Vector:New(226, 148), -1)
Fins = Item.New({3, 2}, Vector:New(-96, -218), Items.Fins.Id)
Body = Item.New({2, 2}, Vector:New(255, 91), Items.Body.Id)
FuelRod1 = Item.New({2, 3}, Vector:New(376, -306), Items.FuelRod1.Id)
FuelRod2 = Item.New({2, 3}, Vector:New(-446, -286), Items.FuelRod2.Id)
FuelRod3 = Item.New({2, 3}, Vector:New(-232, 290), Items.FuelRod3.Id)
CrewCapsule = Item.New({1, 2}, Vector:New(191, 457), Items.CrewCapsule.Id)
NavigationModule = Item.New({0, 2}, Vector:New(-159, -306), Items.NavigationModule.Id)
CommunicationsModule = Item.New({0, 3}, Vector:New(3, -73), Items.CommunicationsModule.Id)
Boat = Item.New({0, 0}, Vector:New(422, -360), Items.Boat.Id, Vector:New(0.5, 0.5))
Meat = nil
