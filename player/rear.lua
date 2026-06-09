local context = require("core.context")

local streakShader = require("agent.copilot.shaders.streakshader")
local Rear = {}
Rear.__index = Rear

local RotVis = require("agent.glm.rotvis")

--------------------------------------------------------------------------------
--- new
--------------------------------------------------------------------------------
function Rear.new()
    local self = setmetatable({
        rotVis = nil,
        streaks = {},
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
    self.body:setAngularDamping(1000)
    self.body:setLinearDamping(0.25)
end

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function Rear:load(window, worlda, front, size, playerCount)
    self.x = 100
    self.y = 0
    self.size = size
    self.body = love.physics.newBody(context.world, self.x, self.y, "dynamic")
    print("rear body created")
    self.shape = love.physics.newCircleShape(self.size) -- copilot fix (wrong arguments prev.)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.01)
    self.fixture:setFriction(100)
    self.fixture:setUserData({name = "Rear"..playerCount})
    self.body:setMass(10)
    self.body:setGravityScale(1)
    self:releaseBraking()
    local dimmer = 1.0
    self.force = self.body:getMass() * 100 * dimmer
    self.rotVis = RotVis.new(self.size, self.body, "RearRotation")
    self.front = front
    streakShader:load()
end

--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function Rear:update(dt)

    local vel  = self.body:getLinearVelocity()
    local angle = math.atan(
        self.body:getY() - self.front.body:getY(),
        self.body:getX() - self.front.body:getX()
    )
    local rx, ry = self.body:getPosition()

    -- streak
    if math.abs(vel) > 400 then -- magic number reused
        table.insert(self.streaks,
            streakShader.new(rx, ry, angle, { 1, 0.4, 0.4 })
        )
    end
    
 -- update & remove  streaks
    for i = #self.streaks, 1, -1 do
        local s = self.streaks[i]
        s:update(dt)
        if s.dead then
            table.remove(self.streaks, i)
        end
    end

end

--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function Rear:draw()
    love.graphics.setColor(1, 0.4, 0.4)
    -- draw streaks first (behind)
    for _, s in ipairs(self.streaks) do
        s:draw()
    end
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