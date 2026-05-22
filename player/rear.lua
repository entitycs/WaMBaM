local Rear = {}
Rear.__index = Rear

local RotVis = require("agent.glm.rotvis")


function Rear.new()
    local self = setmetatable({
        rotVis = nil
    }, Rear)

    return self
end


function Rear:drop(x_pos, y_pos)
    self.x = math.abs(x_pos)
    self.y = math.abs(y_pos)
end


function Rear:applyBraking(inputValue)

end


function Rear:releaseBraking()
    self.body:setAngularDamping(100)
    self.body:setLinearDamping(1)
end

function Rear:load(window, world, size, playerCount)
    self.x = 100
    self.y = 0
    self.size = size
    self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.size) -- copilot fix (wrong arguments prev.)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.01)
    self.fixture:setFriction(1)
    self.fixture:setUserData({name = "Rear"..playerCount})
    self.body:setMass(6)
    self.body:setGravityScale(2)
    self:releaseBraking()
    local dimmer = 1.0
    self.force = self.body:getMass() * 175 * dimmer
    self.rotVis = RotVis:new(self.size, self.body, "RearRotation")
end

function Rear:update(dt)

end

function Rear:draw()
    love.graphics.setColor(1, 0.4, 0.4)
    love.graphics.circle("fill",
        self.body:getX(),
        self.body:getY(),
        self.shape:getRadius()
    )
    love.graphics.setColor(0, 0, 0)
    if self.rotVis ~= nil then self.rotVis:draw() end
    love.graphics.setColor(1, 1, 1)
end

return Rear