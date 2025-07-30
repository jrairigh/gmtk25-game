GameObject = {
    New = function(self, transform, hitBox, initFunc, updateFunc, drawFunc)
        local obj = {Transform = transform, HitBox = hitBox, Initialize = initFunc, Update = updateFunc, Draw = drawFunc}
        setmetatable(obj, self)
        self.__index = self
        return obj
    end
}