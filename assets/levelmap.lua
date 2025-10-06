require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.math")

LevelMap = {
    New = function(rows, columns, poopLocations)
        local map = {
            Rows = rows,
            Columns = columns,
            PoopLocations = poopLocations or {},
        }
        return map
    end
}