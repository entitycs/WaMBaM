local JoystickInputProto = require("core.input.joystick")
local KeyboardInput = require("core.input.keyboard")
local RearProto = require("player.rear")
local FrontProto = require("player.front")
local AudioProto = require("core.audio")

local playerCount = 1

local Player = {}
Player.__index = Player

local limitingVel = 400
local inputMap = {
    braking = "triggerright",
    boost = "triggerleft",
    forceY = "lefty",
    forceX = "leftx",
    torqueY = "righty",
    torqueX = "rightx"
}


function Player.new()
    -- local JoyInput = JoystickInputProto.new()
    local self = setmetatable({
        id = playerCount,
        joystickInput = nil,
        front = FrontProto.new(),
        rear = RearProto.new(), 
        audio = AudioProto.new(),
        currentState = {
            x = 0,
            y = 0,
            forceValue = { x = 0, y = 0 },
            boostValue = 0,
            torqueValue = { x = 0, y = 0 },
            brakeReleasedThisFrame = false,
        }
    }, Player)

    playerCount = playerCount + 1
    return self
end

function Player:load(window, world, wheelSize, contactHandler)
    -- load body parts
    self.rear:load(window, world, wheelSize, self.id)
    self.front:load(window, world, self.rear, contactHandler, self.id)
    local center = {}
    center.joint = love.physics.newDistanceJoint(
        self.rear.body, self.front.body,
        self.rear.body:getX(), self.front.body:getY(),
        self.front.body:getX(), self.front.body:getY(),
        false -- do not collide with each other
    )
    -- load body inputs
    KeyboardInput:load(self.rear, self.front, limitingVel)
    self.joystickInput = JoystickInputProto.new({ self })   -- todo make a bodyForceHandler?
    self.joystickInput:load(self.rear, self.front, limitingVel)
    -- todo, pass playercount, then attempt fallback controller if > available controllers/inputs
    self.audio:load({ wam = "audio/wam.wav", bam = "audio/bam.wav", score = "audio/score.wav" })
    contactHandler:addBegin("Front" .. self.id, "Ball", function(a, b, contact)
        return self:collisionOnEnter("bam", b, contact)
    end)
    contactHandler:addBegin("Rear" .. self.id, "Ball", function(a, b, contact)
        return self:collisionOnEnter("wam", b, contact)
    end)
    playerCount = playerCount + 1
end

function Player:update(dt)
    -- if self.currentState.forceValue == nil then return end
    self.rear:update(dt)
    self.front:update(dt)
    self.joystickInput:update(dt)
    KeyboardInput:update(dt)

    self.rear.body:applyLinearImpulse(
        dt * self.currentState.forceValue.x,
        dt * self.currentState.forceValue.y
    )

    self.front.body:applyLinearImpulse(
        dt * self.currentState.torqueValue.x,
        dt * self.currentState.torqueValue.y
    )



    -- for k, v in pairs(self.currentState) do
    --     print(k .. ": ", "")
    --     if type(v) == "table" then print( v.x ); print(v.y)
    --     else print(v)
    --     end
    -- end
    self.currentState.boostValue = 0
    self.currentState.forceValue = { x = 0, y = 0 }
    self.currentState.torqueValue = { x = 0, y = 0 }
    self.currentState.brakeValue = 0
end

function Player:draw()
    -- Draw rear wheel
    self.rear:draw()
    -- Draw Front Wheel
    self.front:draw()
    -- Draw the line between them
    love.graphics.setColor(1, 1, 0.4)
    love.graphics.setLineWidth(3)
    love.graphics.line(
        self.rear.body:getX(), self.rear.body:getY(),
        self.front.body:getX(), self.front.body:getY()
    )

    -- for debugging
    local curVel_x, curVel_y = self.rear.body:getLinearVelocity()
    local angVel = self.rear.body:getAngularVelocity()
    love.graphics.print("LinearVelocity: " .. curVel_x + curVel_y, 200 * self.id, 120)
    love.graphics.print("AngularVelocity: " .. angVel, 200 * self.id, 140)

    self.joystickInput:draw()
end


function Player:collisionOnEnter(fixture_a, fixture_b, contact)
   love.audio.play(self.audio[fixture_a])
end


function Player:onTrigger(triggerName, triggerValue)
    if triggerName == inputMap.braking then
        self:applyBraking(triggerValue)
    elseif triggerName == inputMap.boost then
        self:applyBoost(triggerValue)
    end
end

function Player:onTriggerRelease(triggerName)

end

function Player:onAxis(axisName, axisValue)
    -- if axisName == inputMap.forceX or axisName == inputMap.forceY then
    self:applyAcceleration(axisName, axisValue)
    -- end
end

function Player:applyBraking(brakeValue)
    if brakeValue ~= 0 then     -- onTrigger(triggerright)
        self.currentState.x, self.currentState.y = self.rear.body:getLinearVelocity()
        self.currentState.brakeReleasedThisFrame = true
        self.front:applyBraking(brakeValue)
    elseif self.currentState.brakeReleasedThisFrame then     -- onTriggerRelease(triggerright)
        -- average out front and back velocities over the frame following braking
        self.front:releaseBraking()
        self.rear:releaseBraking()
        local newx, newy = self.rear.body:getLinearVelocity()
        local newx2, newy2 = self.front.body:getLinearVelocity()
        self.rear.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
        self.front.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
        self.currentState.brakeReleasedThisFrame = false
    end
end

function Player:applyAcceleration(axisName, accelerationValue)
    -- Accelerating (Rear) -- todo use accelerationValue
    local limitedX = false
    local limitedY = false
    local curVel_x, curVel_y = self.rear.body:getLinearVelocity()
    if math.abs(curVel_x) + math.abs(curVel_y) > limitingVel then
        if math.abs(curVel_x) > math.abs(curVel_y) then
            limitedX = true
        else
            limitedY = true
        end
    end
    local xForce = self.currentState.forceValue.x
    local yForce = self.currentState.forceValue.y
    if axisName == inputMap.forceX and not limitedX then
        local totalForce = 2 * self.rear.force * accelerationValue
        totalForce = totalForce * (1 + self.currentState.boostValue)
        xForce = totalForce
    elseif axisName == inputMap.forceY and not limitedY then
        local totalForce = self.rear.force * accelerationValue
        totalForce = totalForce * (1 + self.currentState.boostValue)
        yForce = totalForce
    end
    self.currentState.forceValue.x = xForce
    self.currentState.forceValue.y = yForce
    --self.rear.body:applyLinearImpulse(xForce, yForce)
    if axisName == inputMap.torqueY and not limitedY then
        if self.rear.body:getX() ~= self.front.body:getX() then
            self.currentState.torqueValue.y = 1 + self.front.torque * accelerationValue
            self.currentState.forceValue.y = self.currentState.forceValue.y - 0.65 * self.currentState.torqueValue.y
        end
    elseif axisName == inputMap.torqueX and not limitedX then
        if self.rear.body:getX() ~= self.front.body:getX() then
            self.currentState.torqueValue.x = 1 + self.front.torque * accelerationValue
            -- self.front.body:applyLinearImpulse(self.currentAngle.impulse, 0)
        end
    end
end

function Player:applyBoost(boostValue)
    self.currentState.boostValue = boostValue
end

return Player
