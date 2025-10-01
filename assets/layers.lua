Layers = {
    AddLayer = function(layers, updateFunc, renderFunc)
        table.insert(layers, {Update = updateFunc, Render = renderFunc})
    end,

    OnUpdate = function(layers)
        for _, layer in ipairs(layers) do
            if layer.Update ~= nil and type(layer.Update) == "function" then
                layer.Update()
            end
            if layer.Render ~= nil and type(layer.Render) == "function" then
                layer.Render()
            end
        end
    end
}
