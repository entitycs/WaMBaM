local KeyboardInput = {}

local lastKey = "none"


function love.keypressed(key, scancode, isrepeat)
    if not isrepeat then
        lastKey = key
    end
end


function KeyboardInput:load(rear, front, limitingVel)
    self.rear = rear
    self.front = front
    self.limitingVel = limitingVel
end

function KeyboardInput:update(dt)
    -- keyboard input (lagging behind)
    -- loop through directions
    local limitedX = false
    local limitedY = false
    local curVel_x, curVel_y = self.rear.body:getLinearVelocity()

    -- determine player acceleration limits/constraints based on current velocity
    if math.abs(curVel_x) + math.abs(curVel_y) > self.limitingVel then
        if math.abs(curVel_x) > math.abs(curVel_y) then
            limitedX = true
        else
            limitedY = true
        end
    end
    -- loop through (poll) defined keyboard inputs as directions
    for i, dir in pairs(Directions) do -- todo, sep. loop for joystick
        local dirdt = dt * self.rear.force
        if love.keyboard.isDown(dir) then
            if i % 2 == 1 then
                dirdt = -dirdt -- Reverse direction if odd
            end
            -- Only apply implulse if not limited by velocity constraint
            if DirectionTargets[i] == "x" and not limitedX then
                self.rear.body:applyLinearImpulse(dirdt, 0)
            elseif not limitedY then
                self.rear.body:applyLinearImpulse(0, dirdt)
            end
        end
    end
end

return KeyboardInput