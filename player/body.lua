local JoystickInputProto = require("core.input.joystick")
local KeyboardInput = require("core.input.keyboard")
local RearProto = require("player.rear")
local Rear = nil
local FrontProto = require("player.front")
local Front = nil

local Player = {}
Player.__index = Player

local limitingVel = 400

function Player.new()
    Front = FrontProto.new()
    Rear = RearProto.new()
    -- local JoyInput = JoystickInputProto.new()
    local self = setmetatable({
        joystickInput = JoystickInputProto.new(),
        front = Front,
        rear = Rear
    }, Player)

    return self
end


function Player:load(window, world, wheelSize, contactHandler)
    -- load body parts
    self.rear:load(window, world, wheelSize)
    self.front:load(window, world, self.rear, contactHandler)
    local center = {}
    center.joint = love.physics.newDistanceJoint(
        self.rear.body, self.front.body,
        self.rear.body:getX(), self.front.body:getY(),
        self.front.body:getX(), self.front.body:getY(),
        false -- do not collide with each other
    )
    -- load body inputs
    KeyboardInput:load(self.rear, self.front, limitingVel)
    self.joystickInput:load(self.rear, self.front, limitingVel)
end


function Player:update(dt)
    self.rear:update(dt)
    self.front:update(dt)
    self.joystickInput:update(dt)
    KeyboardInput:update(dt)
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
        self.rear.body:getX(),  self.rear.body:getY(),
        self.front.body:getX(), self.front.body:getY()
    )

    -- for debugging
    local curVel_x, curVel_y = self.rear.body:getLinearVelocity()
    local angVel = self.rear.body:getAngularVelocity()
    love.graphics.print("LinearVelocity: " .. curVel_x + curVel_y, 200, 120)
    love.graphics.print("AngularVelocity: " .. angVel, 200, 140)

     self.joystickInput:draw()
end

return Player