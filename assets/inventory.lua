require("assets.rt.vec2")

local inventory = {}

Items = {
    Fins = {Id = 0, Position = Vector:New(16, 16)},
    Body = {Id = 1, Position = Vector.Zero},
    FuelRod1 = {Id = 2, Position = Vector.Zero},
    FuelRod2 = {Id = 3, Position = Vector.Zero},
    FuelRod3 = {Id = 4, Position = Vector.Zero},
    CrewCapsule = {Id = 5, Position = Vector.Zero},
    NavigationModule = {Id = 6, Position = Vector.Zero},
    CommunicationsModule = {Id = 7, Position = Vector.Zero},
}

function GetItemById(itemId)
    for _, item in ipairs(Items) do
        if item.Id == itemId then
            return item
        end
    end
    return nil
end

Inventory = {
    AddItem = function(item)
        table.insert(inventory, item)
    end,

    HasItem = function(item)
        for _, invItem in ipairs(inventory) do
            if invItem.Id == item.Id then
                return true
            end
        end
        return false
    end,
}