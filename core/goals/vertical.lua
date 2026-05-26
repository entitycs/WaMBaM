local centerAndScale = require("agent.copilot.centroid")
require("core.utils.table")

local Goal = {}
Goal.__index = Goal

local edgeData = {
    points = {
        1, 0,
        3 * 1 / 4, 5,
        1 / 4, 5,
        0, 0
    },
    flipped = {
        -1, 0,
        -3 * 1 / 4, 5,
        -1 / 4, 5,
        0, 0
    }
}


function Goal.getNormalizedPoints(flip)
    return flip and edgeData.flipped or edgeData.points
end


function Goal.getPoints(ballSize, flip)
    local points = {}

    local goalWidth = ballSize * 1
    local goalHeight = ballSize * 1
    -- Create vertical elongated shape with a gap in the center
    if flip then
        -- Right side of field: goal entirely on the negative side of 0
        for i = 1, #edgeData.flipped do
            if i % 2 == 1 then
                points[i] = edgeData.flipped[i] * goalWidth
            else
                points[i] = edgeData.flipped[i] * goalHeight
            end
        end
    else
        for i = 1, #edgeData.points do
            if i % 2 == 1 then
                points[i] = edgeData.points[i] * goalWidth
            else
                points[i] = edgeData.points[i] * goalHeight
            end
        end
    end
    return points
end


function Goal.new(world, ballSize, posX, posY, flip)
    -- New dimensions for vertical goal


    -- treat posX and posY as recommendations
    local body = love.physics.newBody(world, posX, posY, "static")
    -- local points

    -- -- Create vertical elongated shape with a gap in the center
    -- if flip then
    --     -- Right side of field: goal entirely on the negative side of 0
    --     for i = 1, #edgeData.flipped do
    --         if i % 2 == 1 then
    --             points[i] = -edgeData.flipped[i] * goalWidth
    --         else
    --             points[i] = edgeData.flipped[i] * goalHeight
    --         end
    --     end
    --     -- points = {
    --     --     -goalWidth, 0,
    --     --     -3 * goalWidth / 4, goalHeight,
    --     --     -goalWidth / 4, goalHeight,
    --     --     0, 0
    --     -- }
    -- else
    --     for i = 1, #edgeData.flipped do
    --         if i % 2 == 1 then
    --             points[i] = edgeData.points[i] * goalWidth
    --         else
    --             points[i] = edgeData.points[i] * goalHeight
    --         end
    --     end
    --     -- points = {
    --     --     goalWidth, 0,
    --     --     3 * goalWidth / 4, goalHeight,
    --     --     goalWidth / 4, goalHeight,
    --     --     0, 0
    --     -- }
    -- end
    local points = Goal.getPoints(ballSize, flip)
    local shape = love.physics.newPolygonShape(points)
    local fixture = love.physics.newFixture(body, shape, 30)
    fixture:setSensor(true)

    local edges     = {}
    local openEdges = { 1, 2 } -- Remove center-facing vertical edges

    -- from copilot, get center of goal polygon
    local newPoints = centerAndScale(points, 1.25)
    for i = 1, #newPoints, 2 do
        if not Contains(openEdges, i) then
            local x1 = newPoints[i]
            local y1 = newPoints[(i + 1)]
            local x2 = (newPoints[(i + 2)] or newPoints[1])
            local y2 = (newPoints[(i + 3)] or newPoints[2])
            local edgeShape = love.physics.newEdgeShape(x1, y1, x2, y2)
            edgeShape:setPreviousVertex(x1, y1)
            edges[#edges + 1] = {
                shape = edgeShape,
                fixture = love.physics.newFixture(body, edgeShape, 100),
                -- todo group for collisions
            }
        end
    end

    return setmetatable({
        body = body,
        shape = shape,
        fixture = fixture,
        edges = edges
    }, Goal)
end

function Goal:load(scoreGroup)
    self.scoreGroup = scoreGroup
end

function Goal:update(dt)
    -- todo: collision detection ... (see ContactHandler)
end

function Goal:draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(3)
    for _, edgeData in ipairs(self.edges) do
        local x1, y1, x2, y2 = edgeData.shape:getPoints()
        -- Draw in world space, around body at x, y, centered on shape
        love.graphics.line(self.body:getWorldPoints(
            x1, y1,
            x2, y2
        ))
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
end

return Goal
