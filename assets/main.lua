require("assets.rt.vec2")
require("assets.rt.capi")
require("assets.planet_cycles")
require("assets.camera")
require("assets.math")
require("assets.player")

SupportedDevices = {
    Laptop = "16x9",
    MotoGPower = "1080x2388"
}

Window = {
    Width = 0,
    Height = 800,
    Title = "GMTK25 Game"
}

ConfigureGame(Window.Height, Window.Title)

SetCameraZoom(3)
SetCameraPosition(Vector.Zero)

Sounds = {}

Textures = {}
Textures.DrawPlanet = LoadTextureEx("art/planet.png", 0, 0, 1, 1)
Textures.DrawPlayer = LoadTextureEx("art/player.png", 0, 0, 4, 4)

function OnUpdate()
    UpdateGame()
    RenderGame()
end

function OnUpdateUI()
    if IsKeyToggled(Key.F1) then
        local fps = GetFPS()
        DrawText("FPS " .. fps, 10, 10, 16, 5, 0, 0xFFFFFFFF)
    end

    local hour, minute = PlanetCycles.GetTime()
    DrawText(string.format("%02d:%02d", hour, minute), Window.Width / 2 - 30, 30, 20, 5, 0, 0xFFFFFFFF)

    local temp = math.floor(PlanetCycles.GetTemperature())
    DrawText(temp .. " C", Window.Width - 80, 30, 20, 5, 0, 0xFFFFFFFF)

    local windDir = PlanetCycles.GetWindVelocity()
    DrawLine(Vector:New(40, 40), Vector:New(40, 40) + windDir, 5, 0xFF0000FF)
end

function UpdateGame()
    PlanetCycles.Update()
    Camera.Update()
    Player.Update()
end

function RenderGame()
    PlanetCycles.Render()
    Player.Render()
end

function OnWindowResized(width, height)
    Window.Width = width
    Window.Height = height
    SetCameraOffset(Vector:New(Window.Width / 2, Window.Height / 2))
end

