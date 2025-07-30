require("assets.rt.capi")
require("assets.rt.vec2")
require("assets.outnavpath")

local function DrawNavPathLinks()
    for i = 1, #NavPathLinks do
        local startPoint = NavPathPoints[i]
        for j = 1, #NavPathLinks[i] do
            local endPoint = NavPathPoints[NavPathLinks[i][j]]
            DrawLine(startPoint, endPoint, 1, 0xFFFF0066)
        end
    end
end

local function DrawNavPathPoints()
    for i = 1, #NavPathPoints do
        DrawCircle(NavPathPoints[i], 2, 0xFFFFFF66, true)
    end
end

--- Tries to update the direction with the desired if possible, otherwise returns the last valid direction.
--- @class Vector
--- @param location Vector The current position of the object.
--- @param lastDirection Vector The last valid direction.
--- @param attemptedDirection Vector The normalized direction the object is trying to move.
--- @return Vector a The new direction
function MoveNavPath(location, lastDirection, attemptedDirection)
    local maxDistanceToPoint = 0.5
    local navPathId = GetNavLinkLocation(location, maxDistanceToPoint)
    local newDirection = lastDirection
    if navPathId > 0 then
        -- The object is on a path point, few cases to consider:
        -- Case 1 => If the attempted new direction is possible, then use it
        -- Case 2 => If the attempted new direction is impossible, then continue in the last direction
        -- Case 3 => If continuing in the current direction is impossible, then stop the object
        local tolerance = 0.99
        local candidates = NavPathLinks[navPathId]
        local candidateDirections = {}
        for i = 1, #candidates do
            local candidatePoint = NavPathPoints[candidates[i]]
            local targetDirection = (candidatePoint - location):Normalized()
            table.insert(candidateDirections, targetDirection)
        end
    
        for i=1, #candidates do
            local dotP = attemptedDirection * candidateDirections[i]
            if dotP > tolerance then
                -- Case 1, the attempted direction is allowed
                newDirection = attemptedDirection
                goto ret
            end
        end

        -- Case 2, try continuing in the last direction if possible
        for i=1, #candidates do
            local dotP = lastDirection * candidateDirections[i]
            if dotP > tolerance then
                -- Case 2, the last direction is allowed
                newDirection = lastDirection
                goto ret
            end
        end

        -- Case 3, no valid direction found, so stop the object
        newDirection = Vector.Zero
    else
        -- the object is between path points, so can only move in current direction or the opposite direction
        local dotP = attemptedDirection * lastDirection
        if dotP == -1 or dotP == 1 then
            newDirection = attemptedDirection
        end
    end
    ::ret::
    return newDirection
end

--- Moves a game object towards a target position along the navigation path.
--- @class Vector
--- @param position Vector The position of the object.
--- @param moveDirection Vector The current direction the object is moving in.
--- @param target Vector The target position to move towards.
--- @return Vector a new direction to move the object in.
function MoveTowardsTarget(position, moveDirection, target)
    local candidateDirections = {Vector.Up, Vector.Left, Vector.Down, Vector.Right}

    local direction = Vector.Zero
    local minDist = math.huge
    for i = 1, #candidateDirections do
        local newMoveDirection = MoveNavPath(position, moveDirection, candidateDirections[i])
        if newMoveDirection == Vector.Zero or newMoveDirection == -moveDirection then
            goto continue
        end
        local candidatePos = position + newMoveDirection
        local sqrDist = (target - candidatePos):SquaredLength()
        if sqrDist < minDist then
            direction = newMoveDirection
            minDist = sqrDist
        end
        ::continue::
    end

    return direction
end

--- Get the navigation path point index closest to a given point, or return -1 if no points are within the specified distance.
--- @class Vector
--- @param point Vector The point to check against the navigation path points.
--- @param maxDistanceToPoint number The maximum distance to consider a point as valid.
--- @return integer The index of the closest navigation path point, or -1 if no points are close enough.
function GetNavLinkLocation(point, maxDistanceToPoint)
    for i = 1, #NavPathPoints do
        local navPoint = NavPathPoints[i]
        local dist = (navPoint - point):SquaredLength()
        if dist <= maxDistanceToPoint * maxDistanceToPoint then
            return i
        end
    end
    return -1
end

--- Teleports object across the maze
--- @param position Vector The current position of the object.
--- @param moveDirection Vector The current direction the object is moving in.
--- @param maxDistToPoint number The maximum distance to consider a point as valid for teleportation.
--- @return Vector The new position after teleportation, or the original position if no teleportation is needed.
function Teleport(position, moveDirection, maxDistToPoint)
    local navPoint = GetNavLinkLocation(position, maxDistToPoint)
    if navPoint == 32 then
        local teleportPoint = NavPathPoints[32]
        local teleportPointDirection = (teleportPoint - position):Normalized()
        if (moveDirection * teleportPointDirection) > 0.95 then
            return NavPathPoints[27]
        end
    elseif navPoint == 27 then
        local teleportPoint = NavPathPoints[27]
        local teleportPointDirection = (teleportPoint - position):Normalized()
        if (moveDirection * teleportPointDirection) > 0.95 then
            return NavPathPoints[32]
        end
    end

    return position
end

--- Draws the navpath for visual debuggging
function DrawNavPath()
    DrawNavPathPoints()
    DrawNavPathLinks()
    local id = GetNavLinkLocation(Pacman.Transform.Position, 5)
    local fontSize = 4
    local fontSpacing = 1
    local fontRotation = 0
    local color = 0xFFFFFFFF
    local offsetX = 10
    local offsetY = 10
    if id > 0 then
        color = 0x00FF00FF
        DrawCircle(NavPathPoints[id], 2, color, true)
    end
    
    local ms = GetMouseState()
    if ms.Position.X > WorldBounds.Width - 100 then
        offsetX = -50
    end

    DrawText(string.format("ID %d\nMouse: %.2f, %.2f", id, 
        ms.WorldPosition.X, ms.WorldPosition.Y),
        ms.WorldPosition.X + offsetX, ms.WorldPosition.Y + offsetY, 
        fontSize, fontSpacing, fontRotation, color)
end
