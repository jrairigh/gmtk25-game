require("assets.rt.vec2")

function LerpNumber(a, b, t)
    return a + (b - a) * t
end

function LerpColor(c1, c2, t)
    local c1_r = (c1 & 0xFF000000) >> 24
    local c1_g = (c1 & 0x00FF0000) >> 16
    local c1_b = (c1 & 0x0000FF00) >> 8
    local c1_a = c1 & 0x000000FF
    local c2_r = (c2 & 0xFF000000) >> 24
    local c2_g = (c2 & 0x00FF0000) >> 16
    local c2_b = (c2 & 0x0000FF00) >> 8
    local c2_a = c2 & 0x000000FF
    local r = math.floor(LerpNumber(c1_r, c2_r, t))
    local g = math.floor(LerpNumber(c1_g, c2_g, t))
    local b = math.floor(LerpNumber(c1_b, c2_b, t))
    local a = math.floor(LerpNumber(c1_a, c2_a, t))
    return (r << 24) | (g << 16) | (b << 8) | a
end

function CloneVector(v)
    return Vector:New(v.X, v.Y)
end

function CloneTransform(t)
    return {
        Position = CloneVector(t.Position),
        Rotation = t.Rotation,
        Scale = CloneVector(t.Scale)
    }
end