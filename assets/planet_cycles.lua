require("assets.rt.capi")
require("assets.math")

local maxTempC = 50
local minTempC = 0
local tempC = 0
local gameClock = 0
local hoursPerDay = 7
local morningHour = 2
local eveningHour = 6
local minWindSpeed = 0
local maxWindSpeed = 50
local windSpeed = 0
local brightness = 0x333333

local function GetPlanetTint()
    brightness = Cycles(brightness, 0x333333FF, 0xFFFFFFFF, 2, 6, 30, 30, LerpColor)
    return brightness
end

function IsDay()
    return GetPlanetTint() == 0xFFFFFFFF
end

PlanetCycles = {
    Update = function()
        gameClock = GetTime() / 10
    end,

    GetTemperature = function()
        return Cycles(tempC, minTempC, maxTempC, morningHour, eveningHour, 30, 30, LerpNumber)
    end,

    GetTime = function()
        local hour, frac = math.modf((gameClock/ 3) % hoursPerDay)
        local minute = math.floor(frac * 60) % 60
        return hour, minute
    end,

    GetWindVelocity = function()
        return Vector:New(-.7071, .7071) * PlanetCycles.GetWindSpeed()
    end,

    GetWindSpeed = function()
        windSpeed = Cycles(windSpeed, minWindSpeed, maxWindSpeed, 0, 1, 30, 30, LerpNumber)
        return windSpeed
    end,

    Render = function()
        Textures.DrawPlanet(0, 0, GetPlanetTint(), {Position = Vector.Zero, Scale = Vector:New(1, 1), Rotation = 0})
    end
}

function Cycles(value, a, b, bHourStart, bHourEnd, lerpStartMinute_A, lerpEndMinute_B, lerp)
    local hour, minute = PlanetCycles.GetTime()
    if hour < bHourStart or hour > bHourEnd then
        value = a
    elseif hour == bHourStart and minute <= lerpEndMinute_B then
        value = lerp(a, b, minute / lerpEndMinute_B)
    elseif hour == bHourEnd and minute >= lerpStartMinute_A then
        value = lerp(a, b, (60 - minute) / (60 - lerpStartMinute_A))
    else
        value = b
    end

    return value
end


