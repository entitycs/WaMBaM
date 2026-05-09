require("core.ratios")
require("current.arena")
Arena = require("core.arena")
JoystickInput = require("core.joystick")

local logger = {}

local window = {}

local world

-- local floor = {}    -- floor/ground
local rear = {}     -- main wheel
local front = {}    -- second wheel
local center = {}   -- connector

local ball = {}     -- game ball

function love.load()
    JoystickInput:load()
    window.left = 0
    window.top = 0
    window.right = 1200
    window.bottom = 600
      
    -- Set the window size
    love.window.setMode(window.right, window.bottom)
    world = love.physics.newWorld(0, 90, true)
    
    -- In love.load(), after creating fixtures:
    local wheelSize = 10
    rear.x = 100
    rear.y = 0

    ball.body = love.physics.newBody(world, 400, 400, "dynamic")
    ball.shape = love.physics.newCircleShape(BallSize(wheelSize))
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setRestitution(0.5)
    ball.fixture:setFriction(0.1)
    ball.body:setMass(0.5)

    -- Arena
    Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world)

    -- Player
    -- Rear 'Wheel'
    rear.body = love.physics.newBody(world, rear.x, rear.y, "dynamic")
    rear.shape = love.physics.newCircleShape(wheelSize) -- copilot fix (wrong arguments prev.)
    rear.fixture = love.physics.newFixture(rear.body, rear.shape, 1)
    rear.fixture:setRestitution(0.1)
    rear.fixture:setFriction(0.9)
    rear.body:setMass(2)
    rear.body:setGravityScale(3)
    -- Front 'Wheel'
    front.body = love.physics.newBody(world, rear.x + wheelSize * 6, rear.y, "dynamic")
    front.shape = love.physics.newCircleShape(wheelSize)
    front.fixture = love.physics.newFixture(front.body, front.shape, 1)
    front.fixture:setRestitution(0.85)
    front.fixture:setFriction(0.4)
    front.body:setMass(FrontWheelMass(rear.body:getMass()))
    front.body:setGravityScale(FrontWheelGravityScale(rear.body:getGravityScale()))
    -- 'Center/Body' (no collision)
    center.joint = love.physics.newDistanceJoint(
        rear.body, front.body,
        rear.body:getX(), front.body:getY(),
        front.body:getX(), front.body:getY(),
        false -- do not collide with each other
    )

    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end


function love.update(dt)
    world:update(dt)
    local dimmer = 1.0
    -- Update game state here (e.g., handle input, update characters, etc.)
    rear.force = 300 * dimmer
    front.torque = FrontWheelTorque(rear.force) --175 * dimmer

    -- joystick input (up to date)
    JoystickInput:update(dt, rear, front)

    -- keyboard input (lagging behind)
    -- loop through directions
    for i, dir in ipairs(Directions) do -- todo, sep. loop for joystick
        local dirdt = dt * rear.force
        if love.keyboard.isDown(dir) then
            if i % 2 == 1 then
                dirdt = -dirdt -- Reverse direction if odd
            end
            if DirectionTargets[i] == "x" then
                rear.body:applyLinearImpulse(dirdt, 0)
            else
                rear.body:applyLinearImpulse(0, dirdt)
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

    -- Draw rear wheel
    love.graphics.setColor(1, 0.4, 0.4)
    love.graphics.circle("fill",
        rear.body:getX(),
        rear.body:getY(),
        rear.shape:getRadius()
    )

    -- Draw Front Wheel
    love.graphics.setColor(0.4, 1, 0.4)
    love.graphics.circle("fill",
        front.body:getX(),
        front.body:getY(),
        front.shape:getRadius()
    )

    -- Draw the line between them
    love.graphics.setColor(1, 1, 0.4)
    love.graphics.setLineWidth(3)
    love.graphics.line(
        rear.body:getX(), rear.body:getY(),
        front.body:getX(), front.body:getY()
    )

    -- Draw ball
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill",
        ball.body:getX(),
        ball.body:getY(),
        ball.shape:getRadius()
    )

    -- Joystick debug
    JoystickInput:draw()
end
