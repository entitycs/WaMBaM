local AudioProto = require("core.audio")
local BodyBoostCooldown = require("core.abilities.cooldown")
local context = require("core.context")
local BodyBoost = {}
BodyBoost.__index = BodyBoost

local limitingVel = 400
local inputMap = {
    boost = "triggerleft",
    wamBoost = "rightshoulder",
}

--------------------------------------------------------------------------------
--- new
--------------------------------------------------------------------------------
function BodyBoost.new(targetBody, forceTable)
    -- local JoyInput = JoystickInputProto.new()
    local self = setmetatable({
        targetPlayer = targetBody,
        targetTable = forceTable,
        cooldown = BodyBoostCooldown.new(),
        audio = AudioProto.new(),
        -- currentState = {
        --     boostValue = 0
        -- },
    }, BodyBoost)

    return self
end

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function BodyBoost:load(targetPlayer, forceTable)
    self.targetPlayer = targetPlayer
    self.targetTable = forceTable
    self.cooldown:load()
    self.cooldown:setCooldown(
        "wam",
        {
            value = 1.0,      -- 1 = full, 0 = empty
            drainRate = 0.5, -- per second
            regenRate = 0.25,  -- per second
            cooldownDelay = 5,
            draw = function(window, value)
                -- print("made it")
                love.graphics.setColor(0.2, 0.8, 0.3)
                love.graphics.rectangle(
                    "fill",
                    window.bottom - 200,
                    window.bottom - 50,
                    100 * value,
                    30
                )
                love.graphics.setColor(1, 1, 1)
            end
        }
    )
    self.cooldown:setCooldown(
        "lance",
        {
            value = 1.0,
            drainRate = 5.0,
            regenRate = 0.3,
            cooldownDelay = 1.0,
            draw = function(awindow, value)
                love.graphics.setColor(0.8, 0.3, 0.3)
                love.graphics.rectangle(
                    "fill",
                    awindow.bottom - 100,
                    awindow.bottom - 50,
                    100 * value,
                    30
                )
                love.graphics.setColor(1, 1, 1)
            end
        }
    )
    self.targetTable = forceTable
end

--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function BodyBoost:update(dt)
    -- zero out 'summed' forces after applying
    self.cooldown:update(dt)
    print("current boost value: ", self.targetPlayer.currentState.boostValue, self.targetPlayer.id)
    

    -- self.targetTable.x = 0
    -- self.targetTable.y = 0
end

--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function BodyBoost:draw( )
 
    self.cooldown:draw(context.window)
end

-- something like a boost-empty audio would be nice
-- function Player:collisionOnEnter(fixture_a, fixture_b, contact)
--     love.audio.play(self.audio[fixture_a])
-- end

-- callbacks from InputHandler (ie. Joystick)
function BodyBoost:onInput(triggerName, triggerValue)
    if triggerName == inputMap.wamBoost then
        if self.cooldown:onInput("lance", triggerValue) then
            self:applyVectorBoost(2 * triggerValue)
        end
    elseif triggerName == inputMap.boost then
        if self.cooldown:onInput("wam", triggerValue) then
            print("(applyBoost) boosting 1")
            self:applyBoost(triggerName, 4 * triggerValue)
        end
    end
end

function BodyBoost:applyBoost(axisName, boostValue)
    self.targetPlayer.currentState.boostValue = boostValue
end

function BodyBoost:clampTeleport(x, y)
    local minX, minY = 10, 10
    local maxX, maxY =  context.window.right - 10,  context.window.bottom - 110

    x = math.max(minX, math.min(x, maxX))
    y = math.max(minY, math.min(y, maxY))

    return x, y
end

function BodyBoost:applyVectorBoost(boostValue)
    -- find vector representing wam-facing direction (front to rear ->)
    local x, y = self.targetPlayer.rear.body:getX() - self.targetPlayer.front.body:getX(),
        self.targetPlayer.rear.body:getY() - self.targetPlayer.front.body:getY()
    local diffVector = { x = x, y = y }
    -- normalize 'vector'
    local length = math.sqrt(diffVector.x * diffVector.x + diffVector.y * diffVector.y)
    if length ~= 0 then
        diffVector.x = diffVector.x / length
        diffVector.y = diffVector.y / length
    end
    self.targetPlayer.rear.body:setPosition(
        self:clampTeleport(
            self.targetPlayer.rear.body:getX() + diffVector.x * 2,
            self.targetPlayer.rear.body:getY() + diffVector.y * 2
        )
    )
    local impulseStrength = 1
    self.targetPlayer.rear.body:applyLinearImpulse(x * impulseStrength, y * impulseStrength)

    -- self.currentState.forceValue = diffVector
end

return BodyBoost
