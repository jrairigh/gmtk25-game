require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.math")
require("assets.inventory")

Items = {
    FuelRod1 = {Id = 2, Position = Vector.Zero},
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

FuelRod1 = Item.New({2, 3}, Vector:New(200, 300), Items.FuelRod1.Id)
