require("assets.rt.vec2")
require("assets.rt.capi")
require("assets.planet_cycles")
require("assets.camera")
require("assets.math")

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

Brightness = 0x333333
MoveTime = 0
TouchPosition = Vector.Zero
CameraTarget = Vector.Zero
Delay = 1
OldCamPosition = Vector.Zero
local cameraOffset = Camera.Offset()

function UpdateGame()
    local touch = GetTouch()
    local time = GetTime()

    if touch.IsTapped then
        TouchPosition = touch.Position
        CameraTarget = TouchPosition - cameraOffset
        CameraTarget:Print()
        MoveTime = time + Delay
        OldCamPosition = Camera.Position()
    end

    if MoveTime - time > 0 then
        local offset = Vector.Lerp(Vector.Zero, CameraTarget, (Delay - (MoveTime - time)) / Delay)
        local cameraPosition = OldCamPosition + offset
        SetCameraPosition(cameraPosition)
    end

    PlanetCycles.Update()
end

function RenderGame()
    Textures.DrawPlanet(1, 1, GetPlanetTint(), {Position = Vector:New(0, 0), Scale = Vector:New(1, 1), Rotation = 0})
    local time = GetTime()
    if MoveTime - time > 0 then
        DrawCircle(ScreenToWorldSpace(TouchPosition), 6, 0xFF0000FF, true)
    end

    if IsKeyToggled(Key.F1) then
        DrawCircle(Vector.Zero, 6, 0x0000FFFF, true)
        DrawCircle(Camera.Position(), 3, 0xFF0000FF, true)
    end
end

function OnWindowResized(width, height)
    Window.Width = width
    Window.Height = height
    SetCameraOffset(Vector:New(Window.Width / 2, Window.Height / 2))
end

function GetPlanetTint()
    Brightness = Cycles(Brightness, 0x333333FF, 0xFFFFFFFF, 3, 6, 30, 30, LerpColor)
    return Brightness
end