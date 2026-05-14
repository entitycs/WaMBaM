require("core.ratios")
require("current.arena")
Arena = require("core.arena")
JoystickInput = require("core.joystick")
local Ball = require("core.ball")
Moonshine = require("lib.moonshine")
Shockwave = require("agent.copilot.shockwave")
local Rear = require("player.rear")
local Front = require("player.front")
local ContactHandler = require("core.contact")

local logger = {}
function love.conf(t)
    t.console = true
end
local signifiers = {
    effects = {}
}


function signifiers.testCallback(fixtureA, fixtureB, contact)

end


function signifiers.collisionOnEnter(fixture_a, fixture_b, contact)
    local ud_a = fixture_a:getUserData()
    local ud_b = fixture_b:getUserData()

    -- Handle collisions between 'Front' and 'Ball'
    if (ud_a ~= nil and ud_b ~= nil) and ((ud_a["name"] == "Front") or (ud_b["name"] == "Front")) then
        if (ud_a["name"] == "Ball") or (ud_b["name"] == "Ball") then

            local point = {contact:getPositions()}
            for i = 1, #point, 2 do
                local x, y = point[i], point[i + 1]
                -- Cache the values inside the Contacts because they're not guaranteed
                -- to be valid later in the frame. (fron love docs)
                table.insert(signifiers.effects, Shockwave.new(x, y))
            end 
        end
    end
    -- do not use contact after this function returns
end
local window = {}
local world

local function reloadBall(fixtureA, fixtureB, contact)
    Ball:drop(window.right / 2 - Ball.shape:getRadius() / 2, 30)
end

local center = {}   -- connector

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
    contactHandler:addBegin("Front", "Ball", signifiers.collisionOnEnter)
    contactHandler:addBegin("Ball", "Goal1", reloadBall)
    contactHandler:addBegin("Ball", "Goal2", reloadBall)


    Shockwave:load()

    -- In love.load(), after creating fixtures:
    local wheelSize = 10
    local ballRadius = BallSize(wheelSize)
    -- Arena
    Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world, ballRadius)

    Ball:load(window, world, ballRadius)
    -- Player
    -- - Rear 'Wheel'
    Rear:load(window, world, wheelSize)
    -- - Front 'Wheel'
    Front:load(window, world, Rear)

    -- 'Center/Body' (no collision)
    center.joint = love.physics.newDistanceJoint(
        Rear.body, Front.body,
        Rear.body:getX(), Front.body:getY(),
        Front.body:getX(), Front.body:getY(),
        false -- do not collide with each other
    )
    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end


function love.update(dt)
    world:update(dt)
    local limitingVel = 400

    -- update ball
    Ball:update(dt)

    -- backwards iteration - safer for removals
    for i = #signifiers.effects, 1, -1 do 
        local e = signifiers.effects[i]
        e:update(dt)
        if e.dead then
            table.remove(signifiers.effects, i)
        end
    end

    -- joystick input (up to date)
    JoystickInput:update(dt, Rear, Front)
    Rear:update(dt)
    Front:update(dt)
    -- keyboard input (lagging behind)
    -- loop through directions
    local limitedX = false
    local limitedY = false
    local curVel_x, curVel_y = Rear.body:getLinearVelocity()

    -- determine player acceleration limits based on current velocity
    if math.abs(curVel_x) + math.abs(curVel_y) > limitingVel then
        if math.abs(curVel_x) > math.abs(curVel_y) then
            limitedX = true
        else
            limitedY = true
        end
    end
    -- loop through (poll) defined keyboard inputs as directions
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
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.circle("fill",
    -- ball.body:getX(),
    -- ball.body:getY(),
    --     ball.shape:getRadius()
    -- )
    
    -- Joystick debug
    JoystickInput:draw()
    for _, e in ipairs(signifiers.effects) do
        e:draw()
    end
end
