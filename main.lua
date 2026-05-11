require("core.ratios")
require("current.arena")
Arena = require("core.arena")
JoystickInput = require("core.joystick")
Moonshine = require("lib.moonshine")
Shockwave = require("agent.copilot.shockwave")
local Rear = require("player.rear")

local logger = {}

local signifiers = {
    effects = {},
    normals = {}
}
function signifiers.collisionOnEnter(fixture_a, fixture_b, contact)
    ud_a = fixture_a:getUserData()
    ud_b = fixture_b:getUserData()
    print(ud_b)
    if (ud_a ~= nil and ud_b ~= nil) and ((ud_a["name"] == "Front") or (ud_b["name"] == "Front")) then
        if (ud_a["name"] == "Ball") or (ud_b["name"] == "Ball") then
            print("made it")

            local point = {contact:getPositions()}
            for i = 1, #point, 2 do
                local x, y = point[i], point[i + 1]
                -- Cache the values inside the contacts because they're not guaranteed
                -- to be valid later in the frame. (fron love docs)
                -- table.insert(signifiers.normals, { x, y, x + dx, y + dy })
                table.insert(signifiers.effects, Shockwave.new(x, y))
            end 
        end
    end
    

    -- do not use contact after this function returns
end
local window = {}

local world

-- local floor = {}    -- floor/ground
-- local rear = {}     -- main wheel
local front = {}    -- second wheel
local center = {}   -- connector

local ball = {}     -- game ball

function love.load()
    love.physics.setMeter(64)
    effect = Moonshine(Moonshine.effects.glow)
    JoystickInput:load()
    window.left = 0
    window.top = 0
    window.right = 1200
    window.bottom = 600
    
    -- Set the window size
    love.window.setMode(window.right, window.bottom)
    world = love.physics.newWorld(0, 90, true)
    world:setCallbacks(signifiers.collisionOnEnter)
    
    Shockwave:load()

    -- In love.load(), after creating fixtures:
    local wheelSize = 10

    ball.body = love.physics.newBody(world, 400, 400, "dynamic")
    ball.shape = love.physics.newCircleShape(BallSize(wheelSize))
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setRestitution(0.5)
    ball.fixture:setFriction(0.1)
    ball.fixture:setUserData({name = "Ball"})
    ball.body:setMass(0.5)

    -- Arena
    Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world)

    -- Player
    -- Rear 'Wheel'
    Rear:load(window, world, wheelSize)

    -- Front 'Wheel'
    front.body = love.physics.newBody(world, Rear.x + wheelSize * 6, Rear.y, "dynamic")
    front.shape = love.physics.newCircleShape(wheelSize)
    front.fixture = love.physics.newFixture(front.body, front.shape, 1)
    front.fixture:setRestitution(0.85)
    front.fixture:setFriction(0.0)
    front.fixture:setUserData({name = "Front"})
    front.body:setLinearDamping(1)
    front.body:setMass(FrontWheelMass(Rear.body:getMass()))
    front.body:setGravityScale(FrontWheelGravityScale(Rear.body:getGravityScale()))
    -- 'Center/Body' (no collision)
    center.joint = love.physics.newDistanceJoint(
        Rear.body, front.body,
        Rear.body:getX(), front.body:getY(),
        front.body:getX(), front.body:getY(),
        false -- do not collide with each other
    )
        
    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
    -- local dimmer = 1.0
    -- Rear.force = 500 * dimmer
    front.torque = FrontWheelTorque(Rear.force) --175 * dimmer
end


function love.update(dt)
    world:update(dt)
    local limitingVel = 400

    for i = #signifiers.effects, 1, -1 do
        local e = signifiers.effects[i]
        e:update(dt)
        if e.dead then
            table.remove(signifiers.effects, i)
        end
    end

    -- Update game state here (e.g., handle input, update characters, etc.)

    -- joystick input (up to date)
    JoystickInput:update(dt, Rear, front)
    Rear:update(dt)
    -- keyboard input (lagging behind)
    -- loop through directions
    local limitedX = false
    local limitedY = false
    local curVel_x, curVel_y = Rear.body:getLinearVelocity()

    if math.abs(curVel_x) + math.abs(curVel_y) > limitingVel then 
        if math.abs(curVel_x) > math.abs(curVel_y) then
            limitedX = true
        else
            limitedY = true
        end
    end
    for i, dir in ipairs(Directions) do -- todo, sep. loop for joystick
        local dirdt = dt * Rear.force
        if love.keyboard.isDown(dir) then
            if i % 2 == 1 then
                dirdt = -dirdt -- Reverse direction if odd
            end
            if DirectionTargets[i] == "x" and not limitedX then
                Rear.body:applyLinearImpulse(dirdt, 0)
            elseif not limitedY then
                Rear.body:applyLinearImpulse(0, dirdt)
            end
        end
    end
    local curVel_x, curVel_y = Rear.body:getLinearVelocity()
    
    
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
    
    -- effect(function()
    -- )
    -- end)
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
        Rear.body:getX(), Rear.body:getY(),
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
    for _, e in ipairs(signifiers.effects) do
        e:draw()
    end
end
