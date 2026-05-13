local Goal = {}
Goal.__index = Goal

local function contains(t, val)
    for _, v in ipairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function Goal:new(world, ballSize, posX, posY, flip)
    local goalSize = ballSize * 1.15
    local body = love.physics.newBody(world, posX, posY, "static")
    local points 
    if flip then
        -- shape = love.physics.newPolygonShape(
            points = {
                0, 0,
                -goalSize, 0,
                -goalSize / 2, goalSize,
                0, goalSize
            }
        else
            -- shape = love.physics.newPolygonShape(
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
    local openEdges = {1}
    for i = 1, #points, 2 do
        if not contains(openEdges, i) then 
                    
            local x1 =     points[i]
            local y1 =     points[(i + 1)]
            local x2 = points[(i + 2)] or points[1]
            local y2 =  points[(i + 3)] or points[2]
            
            local edgeShape = love.physics.newEdgeShape(x1, y1, x2, y2)
            edges[#edges + 1] = {
                shape = edgeShape,
                fixture = love.physics.newFixture(body, edgeShape, 1)
            }
        end
    end

    return setmetatable({
        body = body,
        shape = shape,
        fixture = fixture
    }, Goal)
end

function Goal:load(scoreGroup)
    self.scoreGroup = scoreGroup
end

function Goal:update(dt)
    -- todo: collision detection ... or give name and use callbacks GL_ARB_provoking_vertex
    -- what else here...?
    -- how does the ball reset after a goal if it needs to?
    -- should all goals be reset when scoreGroup is updated?

end

function Goal:draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    love.graphics.setColor(1, 1, 1)
end

return Goal