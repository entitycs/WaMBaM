local AudioProto = require("core.audio")
local BodyStickyCooldownProto = require("core.abilities.cooldown")
local context = require("core.context")

local BodySticky = {
    wamBody = nil,
    ball = nil
}
BodySticky.__index = BodySticky

local limitingVel = 400
local inputMap = {
    boost = "triggerleft",
    wamBoost = "rightshoulder",
}

--------------------------------------------------------------------------------
--- new
--------------------------------------------------------------------------------
function BodySticky.new(targetBody, forceTable)
    -- local JoyInput = JoystickInputProto.new()
    local self = setmetatable({
        targetPlayer = targetBody,
        targetTable = forceTable,
        cooldown = BodyStickyCooldownProto.new(),
        audio = AudioProto.new(),
        wamBody = nil,
        ballBody = nil,
    }, BodySticky)

    return self
end

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function BodySticky:load(targetPlayer, stateTable)
    self.targetPlayer = targetPlayer
    self.targetTable = stateTable
    self.cooldown:load()
    self.cooldown:setCooldown(
        "sticky",
        {
            value = 1.0,      -- 1 = full, 0 = empty
            drainRate = 0.5,  -- per second
            regenRate = 0.25, -- per second
            cooldownDelay = 5,
            draw = function(awindow, value)
                -- print("made it")
                love.graphics.setColor(0.7, 0.1, 0.7)
                love.graphics.rectangle(
                    "fill",
                    awindow.bottom - 300,
                    awindow.bottom - 50,
                    100 * value,
                    30
                )
                love.graphics.setColor(1, 1, 1)
            end
        }
    )
    self.targetTable = stateTable
end

--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function BodySticky:update(dt)
    -- zero out 'summed' forces after applying
    self.cooldown:update(dt)

    if not self.wamBody or not self.ballBody then
        return
    end
    local x, y = self.wamBody:getX(), self.wamBody:getY()
    local dx, dy = x - self.ballBody:getX(), y - self.ballBody:getY()
    local impulseStrength = 0.05
    self.ballBody:applyLinearImpulse(dx * impulseStrength, dy * impulseStrength - 2)
    if math.abs(dx) > 50 or math.abs(dy) > 50 then
        self.cooldown:onInput("sticky", 0)
        self.ballBody = nil; self.wamBody = nil
    else
        self.cooldown:onInput("sticky", 1) -- if...
    end
end

--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function BodySticky:draw()
    self.cooldown:draw(context.window)
end

-- input: collision with wam
function BodySticky:onInput(triggerName, triggerValue)
    if triggerName == "wam" then
        local contact = triggerValue
        local a, b = contact:getFixtures()
        local aData, bData = a:getUserData(), b:getUserData()
        local aName, bName = nil, nil
        if aData and aData["name"] then aName = aData["name"] end
        if bData and bData["name"] then bName = bData["name"] end
        if aName == "Ball" then
            self:applySticky(b:getBody(), a:getBody())
        elseif bName == "Ball" then
            self:applySticky(a:getBody(), b:getBody())
        end
    end
end

function BodySticky:applySticky(player, aball)
    self.wamBody = player
    self.ballBody = aball
end

function BodySticky:applyStickyBall(aball, boostValue)
end

return BodySticky
