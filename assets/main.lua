require("assets.rt.vec2")
require("assets.rt.capi")

SupportedDevices = {
    Laptop = "16x9",
    MotoGPower = "1080x2388"
}

local windowHeight = 800
local windowTitle = "GMTK25 Game"

ConfigureGame(windowHeight, windowTitle)

Sounds = {}
Textures = {}

local function LoadTextures()
end

local function LoadSounds()
end

LoadTextures()
LoadSounds()

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

function UpdateGame()
end

function RenderGame()
end

function OnWindowResized(width, height)
    WorldBounds = {X=0, Y=0, Width=width, Height=height}
    SetCameraOffset(Vector:New(WorldBounds.Width / 2, WorldBounds.Height / 2))
    print("Width: " .. width .. ", Height: " .. height)
end
