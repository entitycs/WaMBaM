
local Ball = {}
local RotVis = require("agent.glm.rotvis")
local BallRotVis = nil

function Ball:drop(x_pos, y_pos)
    self.x = x_pos
    self.y = y_pos
    self.body:setX(x_pos)
    self.body:setY(y_pos)
end

function Ball:load(window, world, size)
    self.body = love.physics.newBody(world, window.right / 2, window.top, "dynamic")
    self.shape = love.physics.newCircleShape(size)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.5)
    self.fixture:setFriction(0.1)
    self.fixture:setUserData({name = "Ball"})
    self.body:setMass(0.5)

    -- Create a line shape for rotation visualization (glm-4.7)
    local name = "BallLine"
    BallRotVis = RotVis:new(size, self.body, name)
    BallRotVis:load()
end

function Ball:update(dt, window, world)

end

function Ball:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill",
        self.body:getX(),
        self.body:getY(),
        self.shape:getRadius()
    )
    love.graphics.setColor(0, 0, 0)
    -- Draw rotation indicator line (glm-4.7)
    if BallRotVis ~= nil then BallRotVis:draw() end
    -- local angle = self.body:getAngle()
    -- local radius = self.shape:getRadius()
    -- local x = self.body:getX()
    -- local y = self.body:getY()
    
    -- love.graphics.line(
    --     x + math.cos(angle) * radius * 0.9,
    --     y + math.sin(angle) * radius * 0.9,
    --     x - math.cos(angle) * radius * 0.9,
    --     y - math.sin(angle) * radius * 0.9
    -- )
    love.graphics.setColor(1, 1, 1)
end

return Ball