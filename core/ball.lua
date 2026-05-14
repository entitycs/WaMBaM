
local Ball = {}
local RotVis = require("agent.glm.rotvis")
local BallRotVis = nil

function Ball:drop(x_pos, y_pos)
    self.x = x_pos
    self.y = y_pos
    self.needsUpdate = true
end

function Ball:load(window, world, radius)
    self.body = love.physics.newBody(world, window.right / 2 - radius / 2, window.top, "dynamic")
    self.shape = love.physics.newCircleShape(radius)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.5)
    self.fixture:setFriction(0.1)
    self.fixture:setUserData({name = "Ball"})
    self.body:setMass(0.5)

    -- Create a line shape for rotation visualization (glm-4.7)
    local name = "BallLine"
    BallRotVis = RotVis:new(radius, self.body, name)
    BallRotVis:load()
end

function Ball:update(dt)
    if self.needsUpdate then
        self.body:setX(self.x)
        self.body:setY(self.y)
        self.needsUpdate = false
    end
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
    love.graphics.setColor(1, 1, 1)
end

return Ball