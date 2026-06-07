local AudioProto = require("core.audio")
local BodyStickyCooldownProto = require("core.abilities.cooldown")
local context = require("core.context")
local ball = require("core.ball")

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
        -- currentState = {
        --     boostValue = 0
        -- },
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
            draw = function(window, value)
                -- print("made it")
                love.graphics.setColor(0.7, 0.1, 0.7)
                love.graphics.rectangle(
                    "fill",
                    window.bottom - 300,
                    window.bottom - 50,
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
    print("current sticky value: ", self.targetPlayer.currentState.sticky, self.targetPlayer.id)
    
    if not self.wamBody or not self.ballBody then
        print("nope..........", self.wamBody, self.ballBody)
        return
    end
    local x, y = self.wamBody:getX(), self.wamBody:getY()
    local dx, dy = x - self.ballBody:getX(), y - self.ballBody:getY()
    print("yep!!!!!!!!!!!!!!!!!!!!!!!!!!", dx, dy)
    local impulseStrength = 0.05
    self.ballBody:applyLinearImpulse(dx * impulseStrength, dy * impulseStrength - 2)
    if dx > 50 or dy > 50 then
        self.ballBody = nil; self.wamBody = nil
    end
    -- todo - find 'magic number', or implement such that cooldown consumed by dx, dy
    -- self.targetTable.x = 0
    -- self.targetTable.y = 0
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
        print(",,,BodySticky - ", aName, bName)

    end
    print("BodySticky - ", triggerName, triggerValue)
end

function BodySticky:applySticky(player, aball)
    -- self.targetPlayer.currentState.boostValue = 3
    self.wamBody = player
    self.ballBody = aball

    -- current behavior: single frame of impulse results in elastic bounceaway
end

function BodySticky:applyStickyBall(aball, boostValue)
    -- find vector representing wam-facing direction (front to rear ->)
    -- local x, y = self.targetPlayer.rear.body:getX(), self.targetPlayer.rear.body:getY()


    -- self.currentState.forceValue = diffVector
end

return BodySticky
