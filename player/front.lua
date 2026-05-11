local Front = {}


function Front:load(window, world, rear)
    self.size = rear.size
    self.torque = FrontWheelTorque(rear.force) --175 * dimmer
    self.body = love.physics.newBody(world, rear.x + self.size * 6, rear.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.85)
    self.fixture:setFriction(0.0)
    self.fixture:setUserData({name = "Front"})
    self.body:setLinearDamping(1)
    self.body:setMass(FrontWheelMass(rear.body:getMass()))
    self.body:setGravityScale(FrontWheelGravityScale(rear.body:getGravityScale()))
end

function Front:update(dt, window, world)

end

function Front:draw()
    love.graphics.setColor(0.4, 1, 0.4)
    love.graphics.circle("fill",
    self.body:getX(),
    self.body:getY(),
        self.size --shape:getRadius()
    )
end
return Front