local JoystickInput = {}
local joystick = nil
local lastButton = "none"
local currentAngle = {}
function love.joystickadded(js)
    joystick = js
end
function love.gamepadpressed(joystick, button)
    lastButton = button
end


function JoystickInput:load()
--  local joysticks = love.joystick.getJoysticks()
    joystick = nil
    currentAngle.x, currentAngle.y = 0, 0
    currentAngle.changed = false
end


function JoystickInput:update(dt, rear, front)
    if joystick  ~= nil then
        local triggerval = joystick:getGamepadAxis("triggerright")
        local trigger2 = joystick:getGamepadAxis("triggerleft")

        if triggerval ~= 0 then
            currentAngle.x, currentAngle.y = rear.body:getLinearVelocity()
            currentAngle.changed = true
            front.body:setLinearDamping(50 * triggerval + 0.5)
            front.body:setAngularDamping(50 * triggerval + 0.5)
            local curx, cury = front.body:getLinearVelocity()
            -- front.body:setLinearVelocity(curx * (1 - triggerval) , cury * (1 - triggerval))
        elseif currentAngle.changed then
            local newx, newy = rear.body:getLinearVelocity()
            local newx2, newy2 = front.body:getLinearVelocity()
            rear.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
            front.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
            front.body:setLinearDamping(0.1)
            rear.body:setLinearDamping(0.1)
            currentAngle.changed = false
        end
        if joystick:getGamepadAxis("leftx") ~= 0 then
            local totalForce = 2 * rear.force * dt * joystick:getGamepadAxis("leftx")
            totalForce = totalForce * (1 + trigger2)
            rear.body:applyLinearImpulse(totalForce, 0)
        end
        if joystick:getGamepadAxis("lefty") ~= 0 then
            local totalForce = rear.force * dt * joystick:getGamepadAxis("lefty")
            totalForce = totalForce * (1 + trigger2)
            rear.body:applyLinearImpulse(0, totalForce)
        end
                    
        if joystick:getGamepadAxis("righty") ~= 0 then
            if rear.body:getX() == front.body:getX() then
                front.body = front.body
            else
                currentAngle.impulse = front.torque * dt * joystick:getGamepadAxis("righty")
                front.body:applyLinearImpulse(0, currentAngle.impulse)
                currentAngle.x, currentAngle.y = rear.body:getLinearVelocity()
            end
        end
        -- if joystick:getGamepadAxis("rightx") ~= 0 then
        --     if rear.body:getX() == front.body:getX() then
        --         front.body = front.body
        --     else
        --         currentAngle.impulse = front.torque * dt * joystick:getGamepadAxis("rightx")
        --         front.body:applyLinearImpulse(currentAngle.impulse, 0)
        --         -- currentAngle.x, currentAngle.y = rear.body:getLinearVelocity()
        --     end
        -- end
    end
end


function JoystickInput:draw()
    local joysticks = love.joystick.getJoysticks()
    if joystick  ~= nil then
        for i, joystick in ipairs(joysticks) do
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

        love.graphics.print("Last gamepad button pressed: "..lastButton, 10, 10)
        love.graphics.print("offset dx dy: " .. currentAngle.x, 600, 10)
        -- love.graphics.print("front angular velocities" .. front.body:getAngularVelocity(), 600, 30)
        -- love.graphics.print("rear angular velocities" .. rear.body:getAngularVelocity(), 600, 50)
        love.graphics.print("righttrigger val: " .. joystick:getGamepadAxis("triggerright"), 600, 70)
    end
end

return JoystickInput
