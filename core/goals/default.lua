local centerAndScale = require("agent.copilot.centroid")
require("core.utils.table")

local Goal = {}
Goal.__index = Goal

local edgeData = {
    points = {
        0, 0,
        1, 0,
        1 / 2, 1,
        0, 1
    },
    flipped = {
        0, 0,
        -1, 0,
        -1 / 2, 1,
        0, 1
    }
}
local openEdges   = { 1, 3 }


function Goal.getNormalizedPoints(flip)
    return flip and edgeData.flipped or edgeData.points
end


function Goal.getPoints(ballSize, flip)
    local goalSize = ballSize * 1.5
    -- exp ? a : b ternary translates to exp and a or b
    local src = flip and edgeData.flipped or edgeData.points

    local points = {}
    for i = 1, #src do
        points[i] = src[i] * goalSize
    end

    return points, openEdges
end


function Goal.new(world, ballSize, posX, posY, flip)
    local body = love.physics.newBody(world, posX, posY, "static")
    local points, _ = Goal.getPoints(ballSize, flip)
    local shape = love.physics.newPolygonShape(points)
    local fixture = love.physics.newFixture(body, shape, 30)
    fixture:setSensor(true)

    local edges       = {}

    -- from copilot, get center of goal polygon
    local newPoints   = centerAndScale(points, 1.15)
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

function Goal:unload()
    self.body:destroy()
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
        -- Pass the 8 points directly as individual arguments
        love.graphics.line(self.body:getWorldPoints(
            x1, y1,
            x2, y2
        ))
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
end

return Goal
