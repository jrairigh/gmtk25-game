require("assets.rt.vec2")
require("assets.rt.capi")

SupportedDevices = {
    Laptop = "16x9",
    MotoGPower = "1080x2388"
}

local windowHeight = 800
local windowTitle = "GMTK25 Game"

ConfigureGame(windowHeight, windowTitle)

SetCameraZoom(3)
SetCameraOffset(Vector:New(362 / 2, windowHeight / 2))

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
end

MoveTime = 0
TouchPosition = Vector.Zero
CameraTarget = Vector.Zero
Delay = 1
OldCamPosition = Vector.Zero
local cameraOffset = GetCameraOffset()
local camOffset = Vector:New(cameraOffset.X, cameraOffset.Y)

function UpdateGame()
    local touch = GetTouch()
    local time = GetTime()

    if touch.IsTapped then
        TouchPosition = touch.Position
        CameraTarget = TouchPosition - camOffset
        CameraTarget:Print()
        MoveTime = time + Delay
        OldCamPosition = GetCameraPosition()
    end

    if MoveTime - time > 0 then
        local offset = Vector.Lerp(Vector.Zero, CameraTarget, (Delay - (MoveTime - time)) / Delay)
        local cameraPosition = OldCamPosition + offset
        SetCameraPosition(cameraPosition)
    end
end

function RenderGame()
    Textures.DrawPlanet(1, 1, 0xFFFFFFFF, {Position = Vector:New(0, 0), Scale = Vector:New(1, 1), Rotation = 0})
    local time = GetTime()
    if MoveTime - time > 0 then
        DrawCircle(ScreenToWorldSpace(TouchPosition), 6, 0xFF0000FF, true)
    end
end

function OnWindowResized(width, height)
    WorldBounds = {X=0, Y=0, Width=width, Height=height}
    SetCameraOffset(Vector:New(WorldBounds.Width / 2, WorldBounds.Height / 2))
    print("Width: " .. width .. ", Height: " .. height)
end
