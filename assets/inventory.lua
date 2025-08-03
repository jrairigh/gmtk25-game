local inventory = {}
local selectedItemId = -1

Inventory = {
    AddItem = function(item)
        table.insert(inventory, item)
    end,

    HasItem = function(itemId)
        for _, invItem in ipairs(inventory) do
            if invItem.Id == itemId then
                return true
            end
        end
        return false
    end,

    HasItems = function(itemIds)
        for _, itemId in ipairs(itemIds) do
            if not Inventory.HasItem(itemId) then
                return false
            end
        end
        return true
    end,

    SelectItem = function(itemId)
        selectedItemId = itemId
    end,

    DropItem = function(itemId)
        for i, invItem in ipairs(inventory) do
            if invItem.Id == itemId then
                table.remove(inventory, i)
                return
            end
        end
    end,
}