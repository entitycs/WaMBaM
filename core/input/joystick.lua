local JoystickInput = {}
JoystickInput.__index = JoystickInput

local activeInstances = {}
-- local listeners = {}

function love.joystickadded(js)
    for i, inst in ipairs(activeInstances) do
        if not inst.joystick then
            inst.joystick = js
            break
        end
    end
end

function love.gamepadpressed(js, button)
    print("gamepad id: " .. js:getID() .. "button: " .. button)
    for _, inst in ipairs(activeInstances) do
        if inst.joystick == js then
            inst.lastButton = button
            break
        end
    end
end

function JoystickInput.consumeButtonAny(button)
    for _, inst in ipairs(activeInstances) do
        if inst.lastButton == button then
            inst.lastButton = "none"
            return true
        end
    end
    return false
end

function JoystickInput:consumeButton(button)
    if self.lastButton == button then
        self.lastButton = "none"
        return true
    end

    return false
end

--------------------------------------------------------------------------------
--- new
--------------------------------------------------------------------------------
function JoystickInput.new(listenerList) -- should i pass in a player
    local self = setmetatable({
        lastButton = "none",
        joystick = nil,
        listeners = {},
        -- currentAngle = { x = 0, y = 0, changed = false }
    }, JoystickInput)
    for _, listener in ipairs(listenerList) do
        table.insert(self.listeners, listener)
    end
    table.insert(activeInstances, self)
    return self
end

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function JoystickInput:load(rear, front, limitingVel)
    self.rear = rear
    self.front = front
    self.limitingVel = limitingVel

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

--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function JoystickInput:update(dt)
    -- print("joy")
    local limitedX = false
    local limitedY = false
    local listeners = self.listeners
    if self.joystick == nil then
        return
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
end

--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
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
        love.graphics.print("righttrigger val: " .. self.joystick:getGamepadAxis("triggerright"), 600, 70)
    end
end

return JoystickInput
