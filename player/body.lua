local JoystickInputProto = require("core.input.joystick")
local KeyboardInput = require("core.input.keyboard")
local RearProto = require("player.rear")
local FrontProto = require("player.front")
local AudioProto = require("core.audio")
local Abilities = require("player.abilities")
local Collisions = require("player.collisions")
local InputRouter = require("player.input_router")

local playerCount = 1

local Player = {}
Player.__index = Player

local limitingVel = 400

--------------------------------------------------------------------------------
-- new
--------------------------------------------------------------------------------
function Player.new()
    local self = setmetatable({
        id = playerCount,
        joystickInput = nil,
        front = FrontProto.new(),
        rear = RearProto.new(),
        abilities = Abilities.new(),
        audio = AudioProto.new(),
        limitingVel = limitingVel,
        currentState = {
            x = 0,
            y = 0,
            forceValue = { x = 0, y = 0 },
            boostValue = 0,
            torqueValue = { x = 0, y = 0 },
            brakeReleasedThisFrame = false,
            dtTriggers = {},
            inputAngularVelocity = 0,
        },
        collisionOnEnterRear = nil, -- built in :load (needs self.id)
        collisionOnEnterFront = nil,
        window = {}, --suspect
        motor = {}   -- testing
    }, Player)
    playerCount = playerCount + 1
    return self
end

-- Called by the contact dispatcher via the handler factories in player/collisions.
function Player:collisionOnEnter(fixture_a, fixture_b, contact)
    love.audio.play(self.audio[fixture_a])
end

-- Listener methods called by JoystickInput. All three delegate to the router.
function Player:onTrigger(triggerName, triggerValue)
    InputRouter.onInput(self, triggerName, triggerValue)
end

function Player:onAxis(axisName, axisValue)
    InputRouter.onInput(self, axisName, axisValue)
end

function Player:onTriggerRelease(triggerName)
    InputRouter.onInput(self, triggerName, 0)
    self.dtTriggers[triggerName] = 0
end

--------------------------------------------------------------------------------
-- load
--------------------------------------------------------------------------------
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

    -- contact handlers (need self.id, so built here, not in :new)
    self.collisionOnEnterRear = Collisions.buildWheelHandler("Rear", self.id, self, "wam")
    self.collisionOnEnterFront = Collisions.buildWheelHandler("Front", self.id, self, "bam")
    Collisions.load(self.audio, contactHandler, self.collisionOnEnterRear, self.collisionOnEnterFront)

    -- inc for next player ID
    playerCount = playerCount + 1
end

--------------------------------------------------------------------------------
-- update
--------------------------------------------------------------------------------
function Player:update(dt)
    self.joystickInput:update(dt)
    self.abilities:update(dt)
    self.rear:update(dt)
    self.front:update(dt)
    KeyboardInput:update(dt)
    
    self.rear.body:applyLinearImpulse(
        dt * self.currentState.forceValue.x,
        dt * self.currentState.forceValue.y
    )

    self.front.body:applyLinearImpulse(
        dt * self.currentState.torqueValue.x,
        dt * self.currentState.torqueValue.y
    )

    -- zero out 'summed' forces after applying
    -- self.currentState.boostValue = 0
    self.currentState.forceValue = { x = 0, y = 0 }
    self.currentState.torqueValue = { x = 0, y = 0 }
    self.currentState.brakeValue = 0
end

--------------------------------------------------------------------------------
-- draw
--------------------------------------------------------------------------------
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
    love.graphics.push()   -- save world transform
    love.graphics.origin() -- reset to screen space (no camera transform)
    self.joystickInput:draw()
    self.abilities:draw(self.window)
    love.graphics.pop()
end

return Player