local Rear = {}

function Rear:drop(x_pos, y_pos)
    self.x = math.abs(x_pos)
    self.y = math.abs(y_pos)
end

function Rear:load(window, world, size)
    self.x = 100
    self.y = 0
    self.size = size
    self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.size) -- copilot fix (wrong arguments prev.)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.1)
    self.fixture:setFriction(1)
    self.fixture:setUserData({name = "Rear"})
    self.body:setMass(2)
    self.body:setGravityScale(3)
    self.body:setAngularDamping(10)
    local dimmer = 1.0
    self.force = 500 * dimmer
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
end

return Rear