require("assets.rt.vec2")
require("assets.rt.capi")
require("assets.pacman")
require("assets.pulse")
require("assets.ghost")
require("assets.dots")

GameState = {
    Init = 0,
    Menu = 1,
    Ready = 2,
    InProgress = 3,
    Over = 4
}

SupportedDevices = {
    Laptop = "16x9",
    MotoGPower = "1080x2388"
}

local gameState = GameState.Init
local windowHeight = 800
local windowTitle = "Pacman"

WorldUnits = Vector:New(1, 1)
WorldBounds = {}

ConfigureGame(windowHeight, windowTitle, "style.rgs")

Sounds = {}
Textures = {}
FrameTime = 0
GameWallClock = 0
PowerDotPulse = Pulse:New(0.33)
ReadyTextPulse = Pulse:New(0.5)
FrightenedTimer = Pulse:New(7, 0)
ReadyTextVisible = true
PowerDotColor = 0xFFFFFFFF

local function LoadTextures()
    Textures.DrawPacman = LoadTextureEx("art/pacman.png", 0, 0, 1, 3)
    Textures.Blinky = LoadTexture("art/blinky.png", 0, 0, 1, 1)
    Textures.Clyde = LoadTexture("art/clyde.png", 0, 0, 1, 1)
    Textures.Inky = LoadTexture("art/inky.png", 0, 0, 1, 1)
    Textures.Pinky = LoadTexture("art/pinky.png", 0, 0, 1, 1)
    Textures.BlueGhost = LoadTexture("art/blue_ghost.png", 0, 0, 1, 1)
    Textures.Eyes = LoadTexture("art/eyes.png", 0, 0, 1, 1)
    Textures.DrawApple = LoadTextureEx("art/apple.png", 0, 0, 1, 1)
    Textures.DrawStrawberry = LoadTextureEx("art/strawberry.png", 0, 0, 1, 1)
    Textures.DrawDot = LoadTextureEx("art/dot.png", 0, 0, 1, 1)
    if IsDevice(SupportedDevices.MotoGPower) then
        Textures.DrawMaze = LoadTextureEx("art/maze_compact.png", 0, 0, 1, 1)
    else
        Textures.DrawMaze = LoadTextureEx("art/maze.png", 0, 0, 1, 1)
    end

    Textures.DrawCheckboard = LoadTextureEx("art/checkerboard.png", 0, 0, 1, 1)
end

local function LoadSounds()
    Sounds.Credit = LoadSound("sfx/credit.wav")
    Sounds.Death0 = LoadSound("sfx/death_0.wav")
    Sounds.Death1 = LoadSound("sfx/death_1.wav")
    Sounds.PlayEatDotSfx = LoadSoundEx("sfx/eat_dot_0.wav")
    Sounds.PlayEatPowerDotSfx = LoadSoundEx("sfx/eat_dot_1.wav")
    Sounds.EatFruit = LoadSound("sfx/eat_fruit.wav")
    Sounds.PlayEatGhostSfx = LoadSoundEx("sfx/eat_ghost.wav")
    Sounds.Extend = LoadSound("sfx/extend.wav")
    Sounds.PlayEyesSfx = LoadSoundEx("sfx/eyes.wav")
    Sounds.EyesFirstloop = LoadSound("sfx/eyes_firstloop.wav")
    Sounds.Fright = LoadSound("sfx/fright.wav")
    Sounds.FrightFirstloop = LoadSound("sfx/fright_firstloop.wav")
    Sounds.Intermission = LoadSound("sfx/intermission.wav")
    Sounds.Siren0 = LoadSound("sfx/siren0.wav")
    Sounds.Siren0Firstloop = LoadSound("sfx/siren0_firstloop.wav")
    Sounds.Siren1 = LoadSound("sfx/siren1.wav")
    Sounds.Siren1Firstloop = LoadSound("sfx/siren1_firstloop.wav")
    Sounds.Siren2 = LoadSound("sfx/siren2.wav")
    Sounds.Siren2Firstloop = LoadSound("sfx/siren2_firstloop.wav")
    Sounds.Siren3 = LoadSound("sfx/siren3.wav")
    Sounds.Siren3Firstloop = LoadSound("sfx/siren3_firstloop.wav")
    Sounds.Siren4 = LoadSound("sfx/siren4.wav")
    Sounds.Siren4Firstloop = LoadSound("sfx/siren4_firstloop.wav")
    Sounds.PlayStartSfx = LoadSoundEx("sfx/start.wav")
end

LoadTextures()
LoadSounds()

function OnUpdate()
    UpdateGame()
    RenderGame()
end

function OnUpdateUI()
    if gameState == GameState.Menu then
        RenderGameMenu()
    elseif gameState == GameState.Ready then
        RenderHUD()
    end

    if IsKeyToggled(Key.F1) then
        local fps = GetFPS()
        DrawText("FPS " .. fps, 10, 10, 16, 5, 0, 0xFFFFFFFF)
    end
end

function UpdateGame()
    FrameTime = GetFrameTime()
    GameWallClock = GetTime()
    if gameState == GameState.Init then
        UpdateGameInit()
    elseif gameState == GameState.Ready then
        UpdateReady()
    elseif gameState == GameState.InProgress then
        UpdateGameInProgress()
    elseif gameState == GameState.Over then
        UpdateGameOver()
    end
end

function RenderGame()
    if gameState == GameState.Init then
        return
    end
    -- For visual debugging nav path
    --DrawNavPath()
    
    RenderGameInProgress()
    if gameState == GameState.Over then
        RenderGameOver()
    end
end

function OnWindowResized(width, height)
    WorldBounds = {X=0, Y=0, Width=width, Height=height}
    SetCameraOffset(Vector:New(WorldBounds.Width / 2, WorldBounds.Height / 2))
    print("Width: " .. width .. ", Height: " .. height)
end

function UpdateGameInit()
    SetCameraZoom(3)
    SetCameraPosition(Vector.Zero)
    SetCameraOffset(Vector:New(WorldBounds.Width / 2, WorldBounds.Height / 2))
    if IsDevice(SupportedDevices.MotoGPower) then
        NavPathPoints = NavPathPoints_Mobile
        NavPathLinks = NavPathLinks_Mobile
        Dots = Dots_Mobile
        PowerDots = PowerDots_Mobile
    else
        NavPathPoints = NavPathPoints_Laptop
        NavPathLinks = NavPathLinks_Laptop
        Dots = Dots_Laptop
        PowerDots = PowerDots_Laptop
    end

    Pacman:Initialize()
    Blinky:Initialize(Textures.Blinky)
    Inky:Initialize(Textures.Inky)
    Pinky:Initialize(Textures.Pinky)
    Clyde:Initialize(Textures.Clyde)
    ResetDots()
    EatenDots = 0
    gameState = GameState.Menu
    PowerDotPulse:Reset()
    ReadyTextPulse:Reset()
    ReadyTextVisible = true
end

function UpdateReady()
    if IsLastSoundCompleted() then
        gameState = GameState.InProgress
    end
end

function UpdateGameInProgress()
    local state = 0
    Pacman:Update(state)
    if Pacman.State == PacmanStates.Dead then
        gameState = GameState.Over
        PlaySound(Sounds.Death0, 1.0, 1.0)
        return
    end

    UpdateDots()

    if EatenDots >= #Dots then
        gameState = GameState.Over
        PlaySound(Sounds.Credit, 1.0, 1.0)
        return
    end
    
    Blinky:Update()
    Inky:Update()
    Pinky:Update()
    Clyde:Update()

    if FrightenedTimer:CheckPulse() then
        Blinky:UpdateState(GhostStates.Chase)
        Inky:UpdateState(GhostStates.Chase)
        Pinky:UpdateState(GhostStates.Chase)
        Clyde:UpdateState(GhostStates.Chase)
    end

    if IsLastSoundCompleted() then
        if Blinky.State == GhostStates.Frightened then
            PlaySound(Sounds.Fright, 1.0, 1.0)
        else
            PlaySound(Sounds.Siren0, 1.0, 1.0)
        end
    end
end

function UpdateGameOver()
    if IsLastSoundCompleted() then
        gameState = GameState.Init
    end
end

function RenderGameMenu()
    DrawText("Pacman", WorldBounds.Width / 2 - 50, WorldBounds.Height / 2 - 70, 32, 5, 0, 0xFFFF00FF)
    local bounds = {X = WorldBounds.Width / 2 - 50, Y = WorldBounds.Height / 2, Width = 100, Height = 50}
    DrawButton("Play", bounds, "OnPlayButtonClick")
end

function RenderHUD()
    if ReadyTextPulse:CheckPulse() then
        ReadyTextVisible = not ReadyTextVisible
    end

    if ReadyTextVisible then
        DrawText("Ready", WorldBounds.Width / 2 - 50, WorldBounds.Height / 2 + 50, 32, 5, 0, 0xFFFF00FF)
    end
end

function RenderGameInProgress()
    DrawMap()
    DrawDots()
    Pacman:Draw()
    Blinky:Draw()
    Inky:Draw()
    Pinky:Draw()
    Clyde:Draw()
end

function RenderGameOver()
    DrawMap()
    Pacman:Draw()
end

function DrawMap()
    local transform = {
        Position = {X = 0, Y = 0},
        Rotation = 0,
        Scale = {X = 1, Y = 1}
    }

    if IsDevice(SupportedDevices.Laptop) then
        Textures.DrawCheckboard(0, 0, 0xFFFFFF11, transform)
    end

    Textures.DrawMaze(0, 0, 0xFFFFFFFF, transform)
end

function DrawDots()
    for i = 1, #Dots do
        if not Dots[i].IsEaten then
            Textures.DrawDot(0, 0, 0xFFFFFFFF, {
                Position = Dots[i].Position,
                Rotation = 0,
                Scale = {X = 1, Y = 1}
            })
        end
    end
    for i = 1, #PowerDots do
        if PowerDotPulse:CheckPulse() then
            if PowerDotColor == 0x00000000 then
                PowerDotColor = 0xFFFFFFFF
            else
                PowerDotColor = 0x00000000
            end
        end
        if not PowerDots[i].IsEaten then
            Textures.DrawDot(0, 0, PowerDotColor, {
                Position = PowerDots[i].Position,
                Rotation = 0,
                Scale = {X = 3, Y = 3}
            })
        end
    end
end

function OnPlayButtonClick()
    gameState = GameState.Ready
    Sounds.PlayStartSfx(1.0, 1.0)
end

function UpdateDots()
    local maxDist = 8
    for i = 1, #Dots do
        local dotPos = Dots[i].Position
        local pacmanPos = Pacman.Transform.Position
        local isEaten = (dotPos - pacmanPos):SquaredLength() < maxDist * maxDist
        if not Dots[i].IsEaten and isEaten then
            EatenDots = EatenDots + 1
            Dots[i].IsEaten = true
            Sounds.PlayEatDotSfx()
        end
    end
    for i = 1, #PowerDots do
        local dotPos = PowerDots[i].Position
        local pacmanPos = Pacman.Transform.Position
        local isEaten = (dotPos - pacmanPos):SquaredLength() < maxDist * maxDist
        if not PowerDots[i].IsEaten and isEaten then
            PowerDots[i].IsEaten = true
            OnPowerDotEaten()
        end
    end
end

function OnPowerDotEaten()
    Sounds.PlayEatPowerDotSfx()
    Blinky:UpdateState(GhostStates.Frightened)
    Inky:UpdateState(GhostStates.Frightened)
    Pinky:UpdateState(GhostStates.Frightened)
    Clyde:UpdateState(GhostStates.Frightened)
    FrightenedTimer:Reset(1)
end

function ResetDots()
    for i = 1, #Dots do
        Dots[i].IsEaten = false
    end

    for i = 1, #PowerDots do
        PowerDots[i].IsEaten = false
    end
end
