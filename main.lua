local window = {}

local world
local floor = {}    -- floor/ground
local rear = {}     -- main wheel
local front = {}    -- second wheel
local center = {}   -- connector

local ball = {}     -- game ball

local joystick = nil

function love.load()
    local joysticks = love.joystick.getJoysticks()
    joystick = nil
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
    ball.shape = love.physics.newCircleShape(wheelSize * 2)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setRestitution(0.5)
    ball.fixture:setFriction(0.1)
    ball.body:setMass(0.1)

    -- Floor in category 1
    floor.body = love.physics.newBody(world, 0, 0, "static")
    floor.shape = love.physics.newEdgeShape(0, window.bottom - 100, window.right, window.bottom - 100)
    floor.fixture = love.physics.newFixture(floor.body, floor.shape)
    floor.fixture:setFriction(0.8)

    -- Player in category 2
    rear.body = love.physics.newBody(world, rear.x, rear.y, "dynamic")
    rear.shape = love.physics.newCircleShape(wheelSize) -- copilot fix (wrong arguments prev.)
    rear.fixture = love.physics.newFixture(rear.body, rear.shape, 1)
    rear.fixture:setRestitution(0.3)
    rear.fixture:setFriction(0.9)
    rear.body:setMass(2)
    rear.body:setGravityScale(3)
    -- A Wheel Fixed to a joint
    front.body = love.physics.newBody(world, rear.x + wheelSize * 6, rear.y, "dynamic")
    front.shape = love.physics.newCircleShape(wheelSize)
    front.fixture = love.physics.newFixture(front.body, front.shape, 1)
    front.fixture:setRestitution(0.3)
    front.fixture:setFriction(0.4)
    front.body:setMass(0.7)
    center.joint = love.physics.newDistanceJoint(
        rear.body, front.body,
        rear.body:getX(), front.body:getY(),
        front.body:getX(), front.body:getY(),
        false -- do not collide with each other
    )

    Directions = { "up", "down", "left", "right" }

    DirectionTargets = { "y", "y", "x", "x" }
    -- World boundaries (static edges)
    walls = {}

    -- Left wall
    walls.left = {}
    walls.left.body = love.physics.newBody(world, 0, 0, "static")
    walls.left.shape = love.physics.newEdgeShape(0, 0, 0, window.bottom)
    walls.left.fixture = love.physics.newFixture(walls.left.body, walls.left.shape)

    -- Right wall
    walls.right = {}
    walls.right.body = love.physics.newBody(world, 0, 0, "static")
    walls.right.shape = love.physics.newEdgeShape(window.right, 0, window.right, window.bottom)
    walls.right.fixture = love.physics.newFixture(walls.right.body, walls.right.shape)

    -- Ceiling
    walls.top = {}
    walls.top.body = love.physics.newBody(world, 0, 0, "static")
    walls.top.shape = love.physics.newEdgeShape(0, 0, window.right, 0)
    walls.top.fixture = love.physics.newFixture(walls.top.body, walls.top.shape)


    
end
function love.joystickadded(js)
    joystick = js
end

function love.update(dt)
    world:update(dt)

    -- Update game state here (e.g., handle input, update characters, etc.)
    local rearForce = 175
    local frontTorque = 200
    -- loop through directions
    for i, dir in ipairs(Directions) do
        local dirdt = dt * rearForce
        if love.keyboard.isDown(dir) then
            if i % 2 == 1 then
                dirdt = -dirdt -- Reverse direction if odd
            end
            if DirectionTargets[i] == "x" then
                rear.body:applyLinearImpulse(dirdt, 0)
            else
                rear.body:applyLinearImpulse(0, dirdt)
            end
        elseif joystick  ~= nil then
            if joystick:getGamepadAxis("leftx") ~= 0 then
                rear.body:applyLinearImpulse(dirdt * joystick:getGamepadAxis("leftx"), 0)
                -- rear.body:applyAngularImpulse(dirdt * joystick:getGamepadAxis("leftx"))
            end
            if joystick:getGamepadAxis("lefty") ~= 0 then
                rear.body:applyLinearImpulse(0, dirdt * joystick:getGamepadAxis("lefty"))
            end
             
            if joystick:getGamepadAxis("rightx") ~= 0 then
                if dy == 0 then 
                    front.body = front.body
                else
                    front.body:applyLinearImpulse(0, frontTorque * dt *  joystick:getGamepadAxis("righty"))
                end
            end
            -- rear.body:applyLinearImpulse(joystick:getGamepadAxis("lefty"))
        end
    end
end


function love.draw()
    -- Draw everything on the screen
    love.graphics.clear(0.1, 0.1, 0.12)

    love.graphics.print(floor.shape:getPoints(), 50, 100) -- Print text on the screen
    -- Draw floor edge
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setLineWidth(4)
    love.graphics.line(floor.shape:getPoints())

    -- Draw rear wheel
    love.graphics.setColor(0.2, 0.7, 1.0)
    love.graphics.circle("fill",
        rear.body:getX(),
        rear.body:getY(),
        rear.shape:getRadius()
    )

    -- Draw Front Wheel
 
    love.graphics.setColor(1, 0.4, 0.4)
    love.graphics.circle("fill",
        front.body:getX(),
        front.body:getY(),
        front.shape:getRadius()
    )

    -- Draw the line between them
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.line(
        rear.body:getX(), rear.body:getY(),
        front.body:getX(), front.body:getY()
    )

    -- Draw ball
        love.graphics.circle("fill",
        ball.body:getX(),
        ball.body:getY(),
        ball.shape:getRadius()
    )
    -- Joystick:
    local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        love.graphics.print(joystick:getName(), 10, i * 20)
        for j = 1, 2 do
            love.graphics.setColor(0, 1, 0) -- Green for axes
            love.graphics.print(j, 20, (i + j) * 20)
        end
    end
    
    if joystick  ~= nil then
        if joystick:getGamepadAxis("leftx") ~= 0 then
            love.graphics.print(joystick:getGamepadAxis("leftx"), 300, 300)
        end
        if joystick:getGamepadAxis("lefty") ~= 0 then
            love.graphics.print(joystick:getGamepadAxis("lefty"), 400, 400)
        end
    end
end
