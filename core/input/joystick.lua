local JoystickInput = {}
JoystickInput.__index = JoystickInput

local activeInstances = {}
local listeners = {}

function love.joystickadded(js)
    for _, inst in ipairs(activeInstances) do
        if not inst.joystick then
            inst.joystick = js
            break
        end
    end
end

function love.gamepadpressed(js, button)
    print("gamepad id: "..js:getID() .. "button: "..button)
    for _, inst in ipairs(activeInstances) do
        if inst.joystick == js then
            inst.lastButton = button
            break
        end
    end
end

function JoystickInput.new(listenerList) -- should i pass in a player
    local self = setmetatable({
        lastButton = "none",
        joystick = nil,
        -- currentAngle = { x = 0, y = 0, changed = false }
    }, JoystickInput)
    for _, listener in ipairs(listenerList) do
        table.insert(listeners, listener)
    end
    table.insert(activeInstances, self)
    return self
end

function JoystickInput.consumeButton(button)
    for _, inst in ipairs(activeInstances) do
        if inst.lastButton == button then
            inst.lastButton = "none"
            return true
        end
    end
    return false
end

function JoystickInput:load(rear, front, limitingVel)
    self.rear = rear
    self.front = front
    self.limitingVel = limitingVel
    -- self.currentAngle = { x = 0, y = 0, changed = false }

    -- Try to find an unassigned joystick
    local joysticks = love.joystick.getJoysticks()
    for _, js in pairs(joysticks) do
        local alreadyAssigned = false
        for _, inst in pairs(activeInstances) do
            if inst.joystick == js then
                print("ALREADY")
                alreadyAssigned = true
                break
            end
        end
        if not alreadyAssigned then
            self.joystick = js
            break
        end
    end
end

function JoystickInput:update(dt)
    local limitedX = false
    local limitedY = false
    if self.joystick == nil then
        return
    end

    for _, l in ipairs(listeners) do
        if self.joystick:isGamepadDown("rightshoulder") then
        
            l:onTrigger("rightshoulder", 1)
        else
            l:onTrigger("rightshoulder", 0)
        end
    end

    for _, l in ipairs(listeners) do
        l:onTrigger("triggerleft", self.joystick:getGamepadAxis("triggerleft"))
    end

    for _, l in ipairs(listeners) do
        l:onTrigger("triggerright", self.joystick:getGamepadAxis("triggerright"))
    end

    for _, l in ipairs(listeners) do
        l:onAxis("leftx", self.joystick:getGamepadAxis("leftx"))
    end
    for _, l in ipairs(listeners) do
        l:onAxis("lefty", self.joystick:getGamepadAxis("lefty"))
    end

    for _, l in ipairs(listeners) do
        l:onAxis("rightx", self.joystick:getGamepadAxis("rightx"))
    end
    for _, l in ipairs(listeners) do
        l:onAxis("righty", self.joystick:getGamepadAxis("righty"))
    end

    -- Braking
    -- if triggerBrake ~= 0 then -- onTrigger(triggerright)
    --     -- self.currentAngle.x, self.currentAngle.y = self.rear.body:getLinearVelocity()
    --     -- self.currentAngle.changed = true
    --     -- self.front:applyBraking(triggerBrake)
    -- elseif self.currentAngle.changed then -- onTriggerRelease(triggerright)
    --     -- average out front and back velocities over the frame following braking
    --     local newx, newy = self.rear.body:getLinearVelocity()
    --     local newx2, newy2 = self.front.body:getLinearVelocity()
    --     self.rear.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
    --     self.front.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
    --     self.currentAngle.changed = false
    -- end

    -- -- Accelerating
    -- local curVel_x, curVel_y = self.rear.body:getLinearVelocity()
    -- if math.abs(curVel_x) + math.abs(curVel_y) > self.limitingVel then
    --     if math.abs(curVel_x) > math.abs(curVel_y) then
    --         limitedX = true
    --     else
    --         limitedY = true
    --     end
    -- end
    -- local xForce = 0
    -- local yForce = 0
    -- if self.joystick:getGamepadAxis("leftx") ~= 0 and not limitedX then
    --     local totalForce = 2 * self.rear.force * dt * self.joystick:getGamepadAxis("leftx")
    --     totalForce = totalForce * (1 + triggerLeft)
    --     xForce = totalForce
    -- end
    -- if self.joystick:getGamepadAxis("lefty") ~= 0 and not limitedY then
    --     local totalForce = self.rear.force * dt * self.joystick:getGamepadAxis("lefty")
    --     totalForce = totalForce * (1 + triggerLeft)
    --     yForce = totalForce
    -- end
    -- self.rear.body:applyLinearImpulse(xForce, yForce)

    -- curVel_x, curVel_y = self.front.body:getLinearVelocity()
    -- if math.abs(curVel_x) + math.abs(curVel_y) > self.limitingVel then
    --     if math.abs(curVel_x) > math.abs(curVel_y) then
    --         -- if desired impulse is in same direction as cur velocity, limit; else allow
    --         self.currentAngle.impulse = self.front.torque * dt * self.joystick:getGamepadAxis("rightx")
    --         if curVel_x * self.currentAngle.impulse > 0 then
    --             limitedX = true
    --         end
    --     else
    --         self.currentAngle.impulse = self.front.torque * dt * self.joystick:getGamepadAxis("righty")
    --         if (curVel_y * self.currentAngle.impulse) > 0 then
    --             limitedY = true
    --         end
    --     end
    -- end
    -- if self.joystick:getGamepadAxis("righty") ~= 0 and not limitedY then
    --     if self.rear.body:getX() ~= self.front.body:getX() then
    --         self.currentAngle.impulse = self.front.torque * dt * self.joystick:getGamepadAxis("righty")
    --         self.front.body:applyLinearImpulse(0, self.currentAngle.impulse)
    --         self.rear.body:applyLinearImpulse(0, -.65 * self.currentAngle.impulse)
    --         self.currentAngle.x, self.currentAngle.y = self.rear.body:getLinearVelocity()
    --     end
    -- end
    -- if self.joystick:getGamepadAxis("rightx") ~= 0 and not limitedX then
    --     if self.rear.body:getX() == self.front.body:getX() then
    --         self.front.body = self.front.body
    --     else
    --         self.currentAngle.impulse = self.front.torque * dt * self.joystick:getGamepadAxis("rightx")
    --         self.front.body:applyLinearImpulse(self.currentAngle.impulse, 0)
    --         self.currentAngle.x, self.currentAngle.y = self.rear.body:getLinearVelocity()
    --     end
    -- end
end

function JoystickInput:draw()
    local joysticks = love.joystick.getJoysticks()
    if self.joystick ~= nil then
        for i, js in pairs(joysticks) do
            love.graphics.print(js:getName(), 10, i * 20)
            for j = 1, 2 do
                love.graphics.setColor(0, 1, 0) -- Green for axes
                love.graphics.print(j, 20 * i, (i + j) * 20)
            end
        end

        if self.joystick:getGamepadAxis("leftx") ~= 0 then
            love.graphics.print(self.joystick:getGamepadAxis("leftx"), 300, 300)
        end
        if self.joystick:getGamepadAxis("lefty") ~= 0 then
            love.graphics.print(self.joystick:getGamepadAxis("lefty"), 400, 400)
        end

        love.graphics.print("Last gamepad button pressed: " .. self.lastButton, 10, 10)
        -- love.graphics.print("offset dx dy: " .. self.currentAngle.x, 600, 10)
        love.graphics.print("righttrigger val: " .. self.joystick:getGamepadAxis("triggerright"), 600, 70)
    end
end

return JoystickInput
