local Front = {}
Front.__index = Front

local Shockwave = require("agent.copilot.shockwave")
local RotVis = require("agent.glm.rotvis")

function Front.new()
    local self = setmetatable({

        effects = {},
        rotVis = nil
    }, Front)


    return self
end

function Front:collisionOnEnter(fixture_a, fixture_b, contact)
    -- Handle collisions between 'Front' and 'Ball'
    local point = { contact:getPositions() }
    for i = 1, #point, 2 do
        local x, y = point[i], point[i + 1]
        -- Cache the values inside the (volatile) Contacts (fron love docs)
        table.insert(self.effects, Shockwave.new(x, y))
    end
    -- do not use contact after this function returns
end

function Front:applyBraking(inputValue)
    self.body:setLinearDamping(25 * inputValue + 0.5)
    self.body:setAngularDamping(25 * inputValue + 0.5)
end

function Front:releaseBraking()
    self.body:setLinearDamping(0.25)
    self.body:setAngularDamping(1)
    -- self.body:setLinearDamping(1)
end

function Front:load(window, world, rear, contactHandler, playerCount)
    self.size = rear.size
    self.torque = FrontWheelTorque(rear.force) --175 * dimmer
    self.body = love.physics.newBody(world, rear.x + self.size * 6, rear.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.85)
    self.fixture:setFriction(0.0)
    self.fixture:setUserData({ name = "Front"..playerCount })
    self.body:setMass(FrontWheelMass(rear.body:getMass()))
    self.body:setGravityScale(FrontWheelGravityScale(rear.body:getGravityScale()))
    self:releaseBraking()
    -- rotation visualization
    local name = "FrontLine"
    self.rotVis = RotVis:new(self.size, self.body, name)
     
    -- contact visualization
    contactHandler:addBegin("Front"..playerCount, "Ball", function(a, b, contact)
        return self:collisionOnEnter(a, b, contact)
    end)

end

function Front:update(dt, window, world)
    self:releaseBraking()
    for i = #self.effects, 1, -1 do
        local e = self.effects[i]
        e:update(dt)
        if e.dead then
            table.remove(self.effects, i)
        end
    end
end

function Front:draw()
    love.graphics.setColor(0.4, 1, 0.4)
    love.graphics.circle("fill",
        self.body:getX(),
        self.body:getY(),
        self.size --shape:getRadius()
    )

    -- draw line showing rotation
    love.graphics.setColor(0, 0, 0)
    if self.rotVis ~= nil then self.rotVis:draw() end

    love.graphics.setColor(1, 1, 1)
    -- Draw Particle Effects
    for _, e in pairs(self.effects) do
        e:draw()
    end

end

return Front
