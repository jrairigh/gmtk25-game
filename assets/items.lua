require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.math")
require("assets.inventory")

SpriteSize = 32

Item = {
    New = function(spritePositions, position, id)
        local item = {
            Transform = {
                Position = position,
                Rotation = 0,
                Scale = Vector:New(1, 1),
            },
            SpritePositions = spritePositions,
            Id = id,

            RenderWorld = function(self)
                if Inventory.HasItem(GetItemById(self.Id)) then
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
            end,
            
            RenderInventory = function(self, origin)
                local anchorRow, anchorCol = self.SpritePositions[1], self.SpritePositions[2]
                local transform = {
                    Position = origin + GetItemById(self.Id).Position,
                    Rotation = 0,
                    Scale = Vector:New(1, 1),
                }
                Textures.DrawItems(anchorRow, anchorCol, 0xFFFFFFFF, transform)
            end
        }
        return item
    end,
}

LaunchPad = Item.New({3, 0, 3, 1, 1, 0, 2, 0}, Vector:New(180, 144), -1)
Fins = Item.New({3, 2}, Vector:New(70, 25), Items.Fins.Id)
Body = Item.New({2, 2}, Vector:New(255, 91), Items.Body.Id)
FuelRod1 = Item.New({2, 3}, Vector:New(220, 11), Items.FuelRod1.Id)
FuelRod2 = Item.New({2, 3}, Vector:New(230, 11), Items.FuelRod2.Id)
FuelRod3 = Item.New({2, 3}, Vector:New(240, 11), Items.FuelRod3.Id)
CrewCapsule = Item.New({1, 2}, Vector:New(38, 158), Items.CrewCapsule.Id)
NavigationModule = Item.New({0, 2}, Vector:New(-115, 74), Items.NavigationModule.Id)
CommunicationsModule = Item.New({0, 3}, Vector:New(3, -73), Items.CommunicationsModule.Id)
