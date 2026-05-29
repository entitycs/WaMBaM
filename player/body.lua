local JoystickInputProto = require("core.input.joystick")
local KeyboardInput = require("core.input.keyboard")
local RearProto = require("player.rear")
local FrontProto = require("player.front")
local AudioProto = require("core.audio")
local Abilities = require("player.abilities")

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
    torqueX = "rightx",
    wamBoost = "rightshoulder",
}


function Player.new()
    -- local JoyInput = JoystickInputProto.new()
    local self = setmetatable({
        id = playerCount,
        joystickInput = nil,
        front = FrontProto.new(),
        rear = RearProto.new(),
        abilities = Abilities.new(),
        audio = AudioProto.new(),
        currentState = {
            x = 0,
            y = 0,
            forceValue = { x = 0, y = 0 },
            boostValue = 0,
            torqueValue = { x = 0, y = 0 },
            brakeReleasedThisFrame = false,
            previousStickAngle = 0,
            inputAngularVelocity = 0,
        },
        collisionOnEnterRear = function() end,
        collisionOnEnterFront = function() end,
        window = {}, --suspect
        motor = {}   -- testing
    }, Player)
    -- self.boost = BodyBoost.new(self.rear.body, self.currentState.forceValue)
    self.collisionOnEnterRear = { -- separate from above, for access to self.id
        test = function(aName, bName)
            local names = { aName, bName }
            if not Pop(names, "Rear" .. self.id) then
                return false
            end
            if not Pop(names, "Ball") then
                return false
            end
            return true
        end,
        invoke = function(a, b, contact)
            return self:collisionOnEnter("wam", b, contact)
        end
    }

    self.collisionOnEnterFront = { -- separate from above, for access to self.id
        test = function(aName, bName)
            local names = { aName, bName }
            if not Pop(names, "Front" .. self.id) then
                return false
            end
            if not Pop(names, "Ball") then
                return false
            end
            return true
        end,
        invoke = function(a, b, contact)
            return self:collisionOnEnter("bam", b, contact)
        end
    }
    playerCount = playerCount + 1
    return self
end

function Player:load(window, world, wheelSize, contactHandler)
    -- load body parts
    self.window = window
    self.rear:load(window, world, self.front, wheelSize, self.id)
    self.front:load(window, world, self.rear, contactHandler, self.id)
    local center = {}
    center.joint = love.physics.newDistanceJoint(
        self.rear.body, self.front.body,
        self.rear.body:getX(), self.front.body:getY(),
        self.front.body:getX(), self.front.body:getY(),
        false -- do not collide with each other
    )
    -- experimental
    self.motor = love.physics.newMotorJoint(self.rear.body, self.front.body, 1)

    -- load body inputs
    KeyboardInput:load(self.rear, self.front, limitingVel)
    self.joystickInput = JoystickInputProto.new({ self }) -- todo make a bodyForceHandler?
    self.joystickInput:load(self.rear, self.front, limitingVel)
    -- todo, pass playercount, then attempt fallback controller if > available controllers/inputs
    -- abilities
    self.abilities:load(window, self)


    -- load audio for collisions
    self.audio:load({ wam = "audio/wam.wav", bam = "audio/bam.wav", score = "audio/score.wav" })
    -- add audio collision handlers
    contactHandler:addBegin(self.collisionOnEnterRear)
    contactHandler:addBegin(self.collisionOnEnterFront)
    -- inc for next player ID
    playerCount = playerCount + 1
end

function Player:update(dt)
    self.joystickInput:update(dt)
    self.abilities:update(dt)
    self.rear:update(dt)
    self.front:update(dt)
    KeyboardInput:update(dt)


    local rx, ry = self.rear.body:getPosition()
    local fx, fy = self.front.body:getPosition()
    local sx, sy = math.abs(rx - fx), math.abs(ry - fy)
    local rquad = 1

    -- -- check quadrant
    -- if self.joystickInput.joystick ~= nil then 
    --     self.motor:setLinearOffset(
    --         50 * self.joystickInput.joystick:getGamepadAxis("rightx"),
    --         50 * self.joystickInput.joystick:getGamepadAxis("righty")
    --     )
    -- end
    -- -- if true then return end
    -- if fx > rx then
    --     if fy < ry then
    --         rquad = 2
    --     end
    -- elseif fy < ry then
    --     rquad = 4
    -- else
    --     rquad = 3
    -- end


    -- local rotDir = 0
    -- if sx > 0.1 then
    --     rotDir = 1 -- right = clockwise
    -- elseif sx < -0.1 then
    --     rotDir = 1 -- left = counter-clockwise
    -- end



    self.rear.body:applyLinearImpulse(
        dt * self.currentState.forceValue.x,
        dt * self.currentState.forceValue.y
    )

    self.front.body:applyLinearImpulse(
        dt * self.currentState.torqueValue.x ,
        dt * self.currentState.torqueValue.y  
    )

    -- zero out 'summed' forces after applying
    self.currentState.boostValue = 0
    self.currentState.forceValue = { x = 0, y = 0 }
    self.currentState.torqueValue = { x = 0, y = 0 }
    self.currentState.brakeValue = 0
    -- self.currentState.inputAngularVelocity = 0
    -- self.currentState.previousStickAngle =
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
    self.abilities:draw(self.window)
end

local collisionOnEnter = {
}

function Player:collisionOnEnter(fixture_a, fixture_b, contact)
    love.audio.play(self.audio[fixture_a])
end

-- callbacks from InputHandler (ie. Joystick)
function Player:onTrigger(triggerName, triggerValue)
    self.abilities:onInput(triggerName, triggerValue)
    -- if triggerName == inputMap.wamBoost then
    --     if self.boost:onLance(triggerValue) then
    --         self:applyVectorBoost(2 * triggerValue)
    --     end
    if triggerName == inputMap.braking then
    --elseif triggerName == inputMap.braking then
        self:applyBraking(triggerValue)
    -- elseif triggerName == inputMap.boost then
    --     if self.boost:onWam(triggerValue) then
    --         self:applyBoost(4 * triggerValue)
    --     end
    end
end

function Player:onTriggerRelease(triggerName)

end

function Player:onAxis(axisName, axisValue)
    if axisName == inputMap.torqueX then self.joystickX = axisValue end
    if axisName == inputMap.torqueY then self.joystickY = axisValue end
    self:applyAcceleration(axisName, axisValue)
end

function Player:applyBraking(brakeValue)
    if brakeValue ~= 0 then
        self.currentState.x, self.currentState.y = self.rear.body:getLinearVelocity()
        self.currentState.brakeReleasedThisFrame = true
        self.front:applyBraking(brakeValue)
        self.rear:applyBraking(brakeValue)               -- note, may still be a no-op
    elseif self.currentState.brakeReleasedThisFrame then -- onTriggerRelease(triggerright)
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

function Player:checkLimits(bodyPart, limitingVel)
    local curVelX, curVelY = self[bodyPart].body:getLinearVelocity()
    local limitedX = false
    local limitedY = false
    local absVelX = math.abs(curVelX)
    local absVelY = math.abs(curVelY)
    if absVelX + absVelY > limitingVel then
        if absVelX > absVelY then
            limitedX = true
        else
            limitedY = true
        end
    end
    return limitedX, limitedY
end

function Player:applyAcceleration(axisName, accelerationValue)
    local limitedX, limitedY = self:checkLimits("rear", limitingVel)
    local xForce = self.currentState.forceValue.x
    local yForce = self.currentState.forceValue.y

    -- only apply these forces if not already over the normal velocity limits
    if axisName == inputMap.forceX and not limitedX then
        local totalForce = self.rear.force * accelerationValue -- suspect (l/r was doubled)
        totalForce = totalForce * (1 + self.currentState.boostValue)
        xForce = totalForce
    elseif axisName == inputMap.forceY and not limitedY then
        local totalForce = self.rear.force * accelerationValue
        totalForce = totalForce * (1 + self.currentState.boostValue)
        yForce = totalForce
    end
    self.currentState.forceValue.x = xForce
    self.currentState.forceValue.y = yForce


    -- new idea: for increased ease of usability in 'swiping'
    -- measure dx, dy for front vs rear.  if dy > dx, ignore y 'torque'
    -- and vice versa.
    local rx, ry = self.rear.body:getX(), self.rear.body:getY()
    local fx, fy = self.front.body:getX(), self.front.body:getY()
    local dx, dy = math.abs(rx - fx), math.abs(ry - fy)

    -- if ry <= fy then return end


    -- lets try w/ and w/out limits for torque
    limitedX, limitedY = self:checkLimits("front", limitingVel * 2.15) -- magic number
    if axisName == inputMap.torqueY and not limitedY then
        -- if dx >= dy
        -- or (accelerationValue > 0 and fy > ry)
        -- or (accelerationValue < 0 and fy < ry) then
        self.currentState.torqueValue.y = 1 + self.front.torque * accelerationValue
        self.currentState.forceValue.y = self.currentState.forceValue.y - 0.95 * self.currentState.torqueValue.y
        -- end
    elseif axisName == inputMap.torqueX and not limitedX then
        -- if dy >= dx
        --     or (accelerationValue > 0 and fx > rx)
        --     or (accelerationValue < 0 and fx < rx)
        -- then+-++

        self.currentState.torqueValue.x = 1 + self.front.torque * accelerationValue
        self.currentState.forceValue.x = self.currentState.forceValue.x - 0.95 * self.currentState.torqueValue.x
        -- self.front.body:applyLinearImpulse(self.currentAngle.impulse, 0)
        -- end
    end
end

-- function Player:applyBoost(boostValue)
--     self.currentState.boostValue = boostValue
-- end

function Player:clampTeleport(x, y)
    local minX, minY = 10, 10
    local maxX, maxY = self.window.right - 10, self.window.bottom - 110

    x = math.max(minX, math.min(x, maxX))
    y = math.max(minY, math.min(y, maxY))

    return x, y
end

-- function Player:applyVectorBoost(boostValue)
--     -- find vector representing wam-facing direction (front to rear ->)
--     local x, y = self.rear.body:getX() - self.front.body:getX(),
--         self.rear.body:getY() - self.front.body:getY()
--     local diffVector = { x = x, y = y }
--     -- normalize 'vector'
--     local length = math.sqrt(diffVector.x * diffVector.x + diffVector.y * diffVector.y)
--     if length ~= 0 then
--         diffVector.x = diffVector.x / length
--         diffVector.y = diffVector.y / length
--     end
--     self.rear.body:setPosition(
--         self:clampTeleport(
--             self.rear.body:getX() + diffVector.x * 2,
--             self.rear.body:getY() + diffVector.y * 2
--         )
--     )
--     local impulseStrength = 1
--     self.rear.body:applyLinearImpulse(x * impulseStrength, y * impulseStrength)

--     -- print(diffVector.x .. ", " .. diffVector.y)

--     self.currentState.forceValue = diffVector
-- end

return Player
