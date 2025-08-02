require("assets.rt.vec2")
require("assets.rt.capi")
require("assets.planet_cycles")
require("assets.camera")
require("assets.math")
require("assets.player")
require("assets.UI")
require("assets.items")

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
Sounds.PlayPickupSfx = LoadSoundEx("sfx/pickup.wav")
Sounds.PlayNopeSfx = LoadSoundEx("sfx/nope.wav")

Textures = {}
Textures.DrawPlanet = LoadTextureEx("art/planet.png", 0, 0, 1, 1)
Textures.DrawPlayer = LoadTextureEx("art/player.png", 0, 0, 4, 4)
Textures.DrawItems = LoadTextureEx("art/items.png", 0, 0, 4, 4)
Textures.WaterMaskId = LoadImage("art/water_mask.png")

function OnUpdate()
    UpdateGame()
    RenderGame()
end

function OnUpdateUI()
    UI.RenderUI(false)

    if IsKeyToggled(Key.F1) then
        local fps = GetFPS()
        DrawText("FPS " .. fps, 10, 10, 16, 5, 0, 0xFFFFFFFF)
    end
end

function UpdateGame()
    if Player.HasWonGame() then
        return
    end
    
    PlanetCycles.Update()
    Player.Update()
    Camera.Update()
end

function RenderGame()
    PlanetCycles.Render()
    Player.Render()
    LaunchPad:Render()
    Fins:Render()
    Body:Render()
    FuelRod1:Render()
    FuelRod2:Render()
    FuelRod3:Render()
    CrewCapsule:Render()
    NavigationModule:Render()
    CommunicationsModule:Render()

    if Player.HasWonGame() then
        RocketShip:Render()
    end

    UI.RenderUI(true)
end

function RenderRocketShip()
end

function OnWindowResized(width, height)
    Window.Width = width
    Window.Height = height
    SetCameraOffset(Vector:New(Window.Width / 2, Window.Height / 2))
end

