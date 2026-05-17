local Goal = {}
Goal.__index = Goal

local function contains(t, val)
    for _, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function Goal:new(world, ballSize, posX, posY, flip)
    local goalSize = ballSize * 1.25
    local body = love.physics.newBody(world, posX, posY, "static")
    local points 
    if flip then -- for left/right side of map
        points = {
            0, 0,
            -goalSize, 0,
            -goalSize / 2, goalSize,
            0, goalSize
        }
    else
        points = {
            0, 0,
            goalSize, 0,
            goalSize / 2, goalSize,
            0, goalSize
        }
    end
        
    local shape = love.physics.newPolygonShape(points)
    local fixture = love.physics.newFixture(body, shape, 30)
    fixture:setSensor(true)

    local edges = {}
    local openEdges = { 1 }
    
    -- Edge padding to keep goal collision from bleeding through edges
    local edgePadding = 1.05
    for i = 1, #points, 2 do
        if not contains(openEdges, i) then 
            local x1 = points[i] * edgePadding
            local y1 = points[(i + 1)] * edgePadding
            local x2 = (points[(i + 2)] or points[1]) * edgePadding
            local y2 = (points[(i + 3)] or points[2]) * edgePadding
            local edgeShape = love.physics.newEdgeShape(x1, y1, x2, y2)
            edges[#edges + 1] = {
                shape = edgeShape,
                fixture = love.physics.newFixture(body, edgeShape, 1),
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
    local thickness = 2
    for _, edgeData in ipairs(self.edges) do
        local x1, y1, x2, y2 = edgeData.shape:getPoints()
        -- Pass the 8 points directly as individual arguments
        love.graphics.line( self.body:getWorldPoints(
            x1, y1, 
            x2, y2 
        ))
    end
    love.graphics.setColor(1, 1, 1)
end

return Goal