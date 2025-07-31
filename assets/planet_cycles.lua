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
local maxWindSpeed = 20
local windSpeed = 10

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
        local windX = math.cos(gameClock * 10)
        local windY = math.sin(gameClock * 10)
        return Vector:New(windX, windY) * PlanetCycles.GetWindSpeed()
    end,

    GetWindSpeed = function()
        windSpeed = Cycles(windSpeed, minWindSpeed, maxWindSpeed, 4, 6, 50, 10, LerpNumber)
        return windSpeed
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
