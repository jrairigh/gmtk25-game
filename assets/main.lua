require("assets.rt.vec2")
require("assets.rt.capi")
require("assets.planet_cycles")
require("assets.camera")
require("assets.math")
require("assets.player")
require("assets.items")
require("assets.levelmap")
require("assets.layers")

SupportedDevices = {
    Laptop = "16x9",
    MotoGPower = "1080x2388"
}

Window = {
    Width = 0,
    Height = 800,
    Title = "Ludum Dare 58"
}

GameState = {
    StartingGame = 1,
    PlayingGame = 2,
    GameOver = 3
}

CurrentGameState = GameState.StartingGame

ConfigureGame(Window.Height, Window.Title)
Camera:Initialize(1, PlayerHomePosition, PlayerHomePosition)

Sounds = {}
Sounds.PlayPickupSfx = LoadSoundEx("sfx/pickup.wav")
Sounds.PlayNopeSfx = LoadSoundEx("sfx/nope.wav")
Sounds.PlayDeathSfx = LoadSoundEx("sfx/death.wav")

Textures = {}
Textures.DrawPlanet = LoadTextureEx("art/planet.png", 0, 0, 1, 1)
Textures.DrawTreeTops = LoadTextureEx("art/tree_tops.png", 0, 0, 1, 1)
Textures.DrawPlayer = LoadTextureEx("art/player.png", 0, 0, 4, 4)
Textures.DrawItems = LoadTextureEx("art/items.png", 0, 0, 4, 4)

SpriteSize = 32
PoopLocations = {}

local function GetCellSize(rows, columns)
    local gridXSize = Window.Width / columns
    local gridYSize = Window.Height / rows
    return gridXSize, gridYSize
end

local function RenderLevelMap()
    local level = Levels[CurrentLevel]
    local rows = level.Rows
    local columns = level.Columns
    local gridXSize, gridYSize = GetCellSize(rows, columns)
    for i = 1, columns do
        for j = 1, rows do
            local bounds = {
                X = gridXSize * (i - 1),
                Y = gridYSize * (j - 1),
                Width = gridXSize,
                Height = gridYSize
            }

            local fillColor = 0xEEEEEEFF
            if (i + j) % 2 == 0 then
                fillColor = 0xFFFFFFFF
            end

            DrawRectangle(bounds, 1, 0, fillColor, true)
        end
    end

    -- Draw poop cells
    for _, location in ipairs(PoopLocations) do
        local poopBounds = {
            X = gridXSize * location[2],
            Y = gridYSize * location[1],
            Width = gridXSize,
            Height = gridYSize
        }
        local brownColor = 0x8B4513FF
        DrawRectangle(poopBounds, 1, 0, brownColor, true)
    end

    -- Draw the player position indicator and valid cells to move player next
    local playerCellX, playerCellY = Player.Cell.X, Player.Cell.Y
    local bounds = {
        X = gridXSize * playerCellX,
        Y = gridYSize * playerCellY,
        Width = gridXSize,
        Height = gridYSize
    }
    local fillColor = 0x00FF0044
    fillColor = fillColor + math.sin(GetTime() / 10) * 0x44
    DrawRectangle(bounds, 1, 0, fillColor, true)
    local bounds = {
        X = gridXSize * playerCellX,
        Y = 0,
        Width = gridXSize,
        Height = gridYSize * playerCellY
    }
    DrawRectangle(bounds, 1, 0, 0x00FF0044, true)
    local bounds = {
        X = gridXSize * playerCellX,
        Y = gridYSize * (playerCellY + 1),
        Width = gridXSize,
        Height = gridYSize * (rows - 1)
    }
    DrawRectangle(bounds, 1, 0, 0x00FF0044, true)
    local bounds = {
        X = 0,
        Y = gridYSize * playerCellY,
        Width = gridXSize * playerCellX,
        Height = gridYSize
    }
    DrawRectangle(bounds, 1, 0, 0x00FF0044, true)
    local bounds = {
        X = gridXSize * (playerCellX + 1),
        Y = gridYSize * playerCellY,
        Width = gridXSize * (columns - 1),
        Height = gridYSize
    }
    DrawRectangle(bounds, 1, 0, 0x00FF0044, true)
end

local function GetTargetCell(rows, columns, touchPos)
    local gridXSize, gridYSize = GetCellSize(rows, columns)
    local target = ScreenToWorldSpace(touchPos)
    local cellX = math.floor(target.X / gridXSize)
    local cellY = math.floor(target.Y / gridYSize)
    return cellX, cellY
end

local function StartingGameUpdate()
    CurrentLevel = next(Levels, CurrentLevel)
    if CurrentLevel == nil then
        CurrentGameState = GameState.GameOver
        return
    end

    PoopLocations = Levels[CurrentLevel].PoopLocations
    CurrentGameState = GameState.PlayingGame
end

local function PlayingGameUpdate()
    local level = Levels[CurrentLevel]
    local touch = GetTouch()
    if touch.IsTapped then
        local cellX, cellY = GetTargetCell(level.Rows, level.Columns, touch.Position)
        --print("Cell X " .. cellX .. "   Cell Y " .. cellY)
        Player:Update(cellX, cellY)
        print("Total Moves " .. Player.TotalMoves)
        if not Player:IsValidMove(cellX, cellY) then
            Sounds.PlayNopeSfx()
        end

        for i, location in ipairs(PoopLocations) do
            if location[1] == Player.Cell.Y and location[2] == Player.Cell.X then
                table.remove(PoopLocations, i)
            end
        end

        if #PoopLocations == 0 then
            CurrentGameState = GameState.StartingGame
        end
    end
end

local function GameOverUpdate()
    DrawText("Score " .. Player.TotalMoves, 0, 0, 32, 0, 0, 0x00FF00FF)
    DrawText("Thanks for playing", 0, 50, 32, 0, 0, 0x00FF00FF)
end

function OnUpdate()
    Layers.OnUpdate(L)
end

function OnUpdateUI()
    if IsKeyToggled(Key.F1) then
        local fps = GetFPS()
        DrawText("FPS " .. fps, 10, 10, 16, 5, 0, 0xFFFFFFFF)
    end
end

function UpdateGame()
    if CurrentGameState == GameState.StartingGame then
        StartingGameUpdate()
    elseif CurrentGameState == GameState.PlayingGame then
        PlayingGameUpdate()
    else
        GameOverUpdate()
    end
end

function RenderGame()
    if CurrentGameState == GameState.PlayingGame then
        RenderLevelMap()
        Player.Render()
        FuelRod1:Render()
    end
end

function OnWindowResized(width, height)
    Window.Width = width
    Window.Height = height
end

L = {}
Layers.AddLayer(L, UpdateGame, RenderGame)
Levels = {
    LevelMap.New(8, 4, {{4, 0}, {7, 2}, {2, 3}})
}
CurrentLevel = nil
