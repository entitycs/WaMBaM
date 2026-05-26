local RotVis = {}
RotVis.__index = RotVis
function RotVis.new(size, parentBody, name)

    return setmetatable({
        size = size,
        body = parentBody,
        name = name
    }, RotVis)
end

function RotVis:load()
    self.lineShape = love.physics.newEdgeShape(0, 0, self.size, 0)
    self.lineFixture = love.physics.newFixture(self.body, self.lineShape)
    self.lineFixture:setUserData({name = self.name})
    self.lineFixture:setSensor(true) -- Line won't collide
end

function RotVis:update(dt)

end

function RotVis:draw()
    local angle = self.body:getAngle()
    local radius = self.size
    local x = self.body:getX()
    local y = self.body:getY()
    
    love.graphics.line(
        x + math.cos(angle) * radius * 0.9,
        y + math.sin(angle) * radius * 0.9,
        x - math.cos(angle) * radius * 0.9,
        y - math.sin(angle) * radius * 0.9
    )
end

return RotVis