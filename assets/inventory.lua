local inventory = {}

Items = {
    Fins = 0,
    Body = 1,
    FuelRod1 = 2,
    FuelRod2 = 3,
    FuelRod3 = 4,
    CrewCapsule = 5,
    NavigationModule = 6,
    CommunicationsModule = 7,
}

Inventory = {
    AddItem = function(item)
        table.insert(inventory, item)
    end,

    HasItem = function(item)
        for _, invItem in ipairs(inventory) do
            if invItem == item then
                return true
            end
        end
        return false
    end,
}