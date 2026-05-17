local JoystickInput = {
    lastButton = "none"
}
local joystick = nil
local currentAngle = {}


function love.joystickadded(js)
    joystick = js
end

function love.gamepadpressed(joystick, button)
    JoystickInput.lastButton = button
end

function JoystickInput:setLastButton(button)
    self.lastButton = button
end

function JoystickInput:load(rear, front, limitingVel)
    --  local joysticks = love.joystick.getJoysticks()
    joystick = nil
    currentAngle.x, currentAngle.y = 0, 0
    currentAngle.changed = false
    self.rear = rear
    self.front = front
    self.limitingVel = limitingVel
end

function JoystickInput:update(dt)
    -- self.lastButton = lastButton
    local limitedX = false
    local limitedY = false
    if joystick ~= nil then
        local triggerval = joystick:getGamepadAxis("triggerright")
        local trigger2 = joystick:getGamepadAxis("triggerleft")

        -- Braking
        if triggerval ~= 0 then
            currentAngle.x, currentAngle.y = self.rear.body:getLinearVelocity()
            currentAngle.changed = true
            self.front.body:setLinearDamping(25 * triggerval + 0.5)
            self.front.body:setAngularDamping(25 * triggerval + 0.5)
            local curx, cury = self.front.body:getLinearVelocity()
            -- front.body:setLinearVelocity(curx * (1 - triggerval) , cury * (1 - triggerval))
        elseif currentAngle.changed then
            local newx, newy = self.rear.body:getLinearVelocity()
            local newx2, newy2 = self.front.body:getLinearVelocity()
            self.rear.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
            self.front.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
            self.front.body:setLinearDamping(0)
            self.rear.body:setLinearDamping(0.1)
            currentAngle.changed = false
        end

        -- Accelerating
        local curVel_x, curVel_y = self.rear.body:getLinearVelocity()
        if math.abs(curVel_x) + math.abs(curVel_y) > self.limitingVel then
            if math.abs(curVel_x) > math.abs(curVel_y) then
                limitedX = true
            else
                limitedY = true
            end
        end
        local xForce = 0
        local yForce = 0
        if joystick:getGamepadAxis("leftx") ~= 0 and not limitedX then
            local totalForce = 2 * self.rear.force * dt * joystick:getGamepadAxis("leftx")
            totalForce = totalForce * (1 + trigger2)
            xForce = totalForce
        end
        if joystick:getGamepadAxis("lefty") ~= 0 and not limitedY then
            local totalForce = self.rear.force * dt * joystick:getGamepadAxis("lefty")
            totalForce = totalForce * (1 + trigger2)
            yForce = totalForce
            -- self.rear.body:applyLinearImpulse(0, totalForce)
        end
        self.rear.body:applyLinearImpulse(xForce, yForce)

        curVel_x, curVel_y = self.front.body:getLinearVelocity()
        if math.abs(curVel_x) + math.abs(curVel_y) > self.limitingVel then
            if math.abs(curVel_x) > math.abs(curVel_y) then
                -- if desired impulse is in same direction as cur velocity, limit; else allow
                currentAngle.impulse = self.front.torque * dt * joystick:getGamepadAxis("rightx")
                if curVel_x * currentAngle.impulse > 0 then
                    limitedX = true
                end
            else
                currentAngle.impulse = self.front.torque * dt * joystick:getGamepadAxis("righty")
                if (curVel_y * currentAngle.impulse) > 0 then
                    limitedY = true
                end
            end
        end
        if joystick:getGamepadAxis("righty") ~= 0 and not limitedY then
            if self.rear.body:getX() == self.front.body:getX() then
                self.front.body = self.front.body
            else
                currentAngle.impulse = self.front.torque * dt * joystick:getGamepadAxis("righty")
                self.front.body:applyLinearImpulse(0, currentAngle.impulse)
                self.rear.body:applyLinearImpulse(0, -.65 * currentAngle.impulse)
                currentAngle.x, currentAngle.y = self.rear.body:getLinearVelocity()
            end
        end
        if joystick:getGamepadAxis("rightx") ~= 0 and not limitedX then
            if self.rear.body:getX() == self.front.body:getX() then
                self.front.body = self.front.body
            else
                currentAngle.impulse = self.front.torque * dt * joystick:getGamepadAxis("rightx")
                self.front.body:applyLinearImpulse(currentAngle.impulse, 0)
                currentAngle.x, currentAngle.y = self.rear.body:getLinearVelocity()
            end
        end
    end
end

function JoystickInput:draw()
    local joysticks = love.joystick.getJoysticks()
    if joystick ~= nil then
        for i, joystick in pairs(joysticks) do
            love.graphics.print(joystick:getName(), 10, i * 20)
            for j = 1, 2 do
                love.graphics.setColor(0, 1, 0) -- Green for axes
                love.graphics.print(j, 20, (i + j) * 20)
            end
        end

        if joystick:getGamepadAxis("leftx") ~= 0 then
            love.graphics.print(joystick:getGamepadAxis("leftx"), 300, 300)
        end
        if joystick:getGamepadAxis("lefty") ~= 0 then
            love.graphics.print(joystick:getGamepadAxis("lefty"), 400, 400)
        end

        love.graphics.print("Last gamepad button pressed: " .. self.lastButton, 10, 10)
        love.graphics.print("offset dx dy: " .. currentAngle.x, 600, 10)
        -- love.graphics.print("front angular velocities" .. front.body:getAngularVelocity(), 600, 30)
        -- love.graphics.print("rear angular velocities" .. rear.body:getAngularVelocity(), 600, 50)
        love.graphics.print("righttrigger val: " .. joystick:getGamepadAxis("triggerright"), 600, 70)
    end
end

return JoystickInput
