require("core.ratios")
require("current.arena")
Arena = require("core.arena")
JoystickInput = require("core.joystick")
local Ball = require("core.ball")
-- Moonshine = require("lib.moonshine")
-- Shockwave = require("agent.copilot.shockwave")
local Rear = require("player.rear")
local Front = require("player.front")
local ContactHandler = require("core.contact")

local logger = {}


function love.conf(t)
    t.console = true
end

-- local signifiers = {
--     effects = {}
-- }


-- function signifiers.testCallback(fixtureA, fixtureB, contact)

-- end

-- function signifiers.collisionOnEnter(fixture_a, fixture_b, contact)
--     -- Handle collisions between 'Front' and 'Ball'
--     local point = { contact:getPositions() }
--     for i = 1, #point, 2 do
--         local x, y = point[i], point[i + 1]
--         -- Cache the values inside the (volatile) Contacts (fron love docs)
--         table.insert(signifiers.effects, Shockwave.new(x, y))
--     end
--     -- do not use contact after this function returns
-- end

local window = {}
local world

local function reloadBall(fixtureA, fixtureB, contact)
    Ball:drop(window.right / 2 - Ball.shape:getRadius() / 2, 30)
end

local center = {} -- connector

function love.load()
    love.physics.setMeter(64)
    -- effect = Moonshine(Moonshine.effects.glow)
    JoystickInput:load()
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

    -- Arena
    Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world, ballRadius)

    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end

function love.update(dt)
    local limitingVel = 400

    -- update world
    world:update(dt)

    -- update ball
    Ball:update(dt)

    -- joystick input (up to date)
    JoystickInput:update(dt, Rear, Front)
    Rear:update(dt)
    Front:update(dt)

    -- keyboard input (lagging behind)
    -- loop through directions
    local limitedX = false
    local limitedY = false
    local curVel_x, curVel_y = Rear.body:getLinearVelocity()

    -- determine player acceleration limits/constraints based on current velocity
    if math.abs(curVel_x) + math.abs(curVel_y) > limitingVel then
        if math.abs(curVel_x) > math.abs(curVel_y) then
            limitedX = true
        else
            limitedY = true
        end
    end
    -- loop through (poll) defined keyboard inputs as directions
    for i, dir in pairs(Directions) do -- todo, sep. loop for joystick
        local dirdt = dt * Rear.force
        if love.keyboard.isDown(dir) then
            if i % 2 == 1 then
                dirdt = -dirdt -- Reverse direction if odd
            end
            -- Only apply implulse if not limited by velocity constraint
            if DirectionTargets[i] == "x" and not limitedX then
                Rear.body:applyLinearImpulse(dirdt, 0)
            elseif not limitedY then
                Rear.body:applyLinearImpulse(0, dirdt)
            end
        end
    end
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
