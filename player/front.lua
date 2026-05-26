local Front = {}
Front.__index = Front

local Shockwave = require("agent.copilot.shaders.shockwave")
local RotVis = require("agent.glm.rotvis")
local streakShader = require("core.shaders.streakshader")


function Front.new()
    local self = setmetatable({
        effects = {},
        rotVis = nil,
        streaks = {},
        rear = {}
    }, Front)
    return self
end

function Front:collisionOnEnter(fixture_a, fixture_b, contact)
    -- Handle collisions between 'Front' and 'Ball'
    local point = { contact:getPositions() }
    for i = 1, #point, 2 do
        local x, y = point[i], point[i + 1]
        table.insert(self.effects, Shockwave.new(x, y))
    end
end

function Front:applyBraking(inputValue)
    self.body:setLinearDamping(25 * inputValue + 0.5)
    self.body:setAngularDamping(25 * inputValue + 0.5)
end

function Front:releaseBraking()
    self.body:setLinearDamping(3)
    self.body:setAngularDamping(1)
end

function Front:load(window, world, rear, contactHandler, playerCount)
    self.size = rear.size
    local wheelbase = self.size * 6
    self.torque = FrontWheelTorque(rear.force) --175 * dimmer
    self.body = love.physics.newBody(world, rear.x + wheelbase, rear.y, "dynamic")
    self.shape = love.physics.newCircleShape(self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.85)
    self.fixture:setFriction(0.0)
    self.fixture:setUserData({ name = "Front" .. playerCount })
    self.body:setMass(FrontWheelMass(rear.body:getMass()))
    self.body:setGravityScale(FrontWheelGravityScale(rear.body:getGravityScale()))
    self:releaseBraking()
    -- rotation visualization
    local name = "FrontLine"
    self.rotVis = RotVis.new(self.size, self.body, name)

    -- contact visualization
    contactHandler:addBegin( {
        test = function(nameA, nameB)
            local names = {nameA, nameB}
            if not Pop(names, "Ball") then
                return false
            end
            if not Pop(names, "Front" .. playerCount) then
                return false
            end
            return true
        end,
        invoke = function(a, b, contact)
            return self:collisionOnEnter(a, b, contact)
        end,
    })
    streakShader:load()
    self.rear = rear
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
    local vel = self.body:getLinearVelocity()
    -- local frontAngVel = self.front.body:getAngularVelocity()

    local angle = math.atan(
        self.body:getY() - self.rear.body:getY(),
        self.body:getX() - self.rear.body:getX()
    )
    local rx, ry     = self.body:getPosition()
    -- local fx, fy = self.front.body:getPosition()

    -- rear streak
    if math.abs(vel) > 400 then
        print("streak")
        table.insert(self.streaks,
            streakShader.new(rx, ry, angle, { 1, 0.4, 0.4 })
        )
    end
    -- update streaks
    for i = #self.streaks, 1, -1 do
        local s = self.streaks[i]
        s:update(dt)
        if s.dead then
            table.remove(self.streaks, i)
        end
    end
end

function Front:draw()
    love.graphics.setColor(0.4, 1, 0.4)
    for _, s in ipairs(self.streaks) do
        s:draw()
    end
    love.graphics.circle("fill",
        self.body:getX(),
        self.body:getY(),
        self.size --shape:getRadius()
    )

    -- draw line showing rotation
    love.graphics.setColor(0, 0, 0)
    if self.rotVis ~= nil then self.rotVis:draw() end

    -- Draw Particle Effects
    love.graphics.setColor(1, 1, 1)
    for _, e in pairs(self.effects) do
        e:draw()
    end
end

return Front
