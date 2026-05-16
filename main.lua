require("core.ratios")
require("current.arena")
Arena = require("core.arena")
JoystickInput = require("core.joystick")
KeyboardInput = require("core.keyboard")
local Ball = require("core.ball")
local Rear = require("player.rear")
local Front = require("player.front")
local ContactHandler = require("core.contact")

function love.conf(t)
    t.console = true
end

local window = {}
local world

local function reloadBall(fixtureA, fixtureB, contact)
    Ball:drop(window.right / 2 - Ball.shape:getRadius() / 2, 30)
end

local center = {} -- connector

local limitingVel = 400
function love.load()
    love.physics.setMeter(64)
    window.left = 0
    window.top = 0
    window.right = 1200
    window.bottom = 600

    -- Set the window size
    love.window.setMode(window.right, window.bottom)

    -- Create new World
    world = love.physics.newWorld(0, 90, true)

    -- Set contact handling callback
    local contactHandler = ContactHandler.new(world)
    world:setCallbacks(contactHandler.beginContact)

    -- Add to contact handling callback list, post-set!
    contactHandler:addBegin("Ball", "Goal1", reloadBall)
    contactHandler:addBegin("Ball", "Goal2", reloadBall)

    local wheelSize = 10

    -- Ball
    local ballRadius = BallSize(wheelSize)
    Ball:load(window, world, ballRadius)

    -- Player
    -- - Rear 'Wheel'
    Rear:load(window, world, wheelSize)
    -- - Front 'Wheel'
    Front:load(window, world, Rear, contactHandler)

    -- 'Center/Body' (no collision)
    center.joint = love.physics.newDistanceJoint(
        Rear.body, Front.body,
        Rear.body:getX(), Front.body:getY(),
        Front.body:getX(), Front.body:getY(),
        false -- do not collide with each other
    )

    KeyboardInput:load(Rear, Front, limitingVel)
    JoystickInput:load(Rear, Front, limitingVel)

    -- Arena
    Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world, ballRadius)

    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end

function love.update(dt)
    -- update world
    world:update(dt)

    -- update ball
    Ball:update(dt)

    -- joystick input (up to date)
    JoystickInput:update(dt)
    Rear:update(dt)
    Front:update(dt)
    KeyboardInput:update(dt)
end

function love.draw()
    -- Wipe the screen
    love.graphics.clear(0.1, 0.1, 0.12)
    love.graphics.setColor(.5, .5, .5)

    -- Draw Arena (Backdrop => first)
    CurrentArena:draw()

    -- Draw Arena
    Arena:draw()
    local curVel_x, curVel_y = Rear.body:getLinearVelocity()
    local angVel = Rear.body:getAngularVelocity()
    love.graphics.print("LinearVelocity: " .. curVel_x + curVel_y, 200, 120)
    love.graphics.print("AngularVelocity: " .. angVel, 200, 140)

    -- Draw rear wheel
    Rear:draw()
    -- Draw Front Wheel
    Front:draw()
    -- Draw the line between them
    love.graphics.setColor(1, 1, 0.4)
    love.graphics.setLineWidth(3)
    love.graphics.line(
        Rear.body:getX(), Rear.body:getY(),
        Front.body:getX(), Front.body:getY()
    )

    -- Draw ball
    Ball:draw()

    -- Draw joystick (ie. debugging)
    JoystickInput:draw()
end
