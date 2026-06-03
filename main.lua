require("core.ratios")
require("current.arena")
require("core.utils.table")
local Menu = require("core.menu.controller")
local Stage = require("current.stage")
-- Arena = require("core.arena")
-- local Goals = require("current.goals.container")
local Ball = require("core.ball")
local PlayerProto = require("player.body")
local Player1 = {}
local Player2 = {}

local ContactHandler = require("core.contact")

function love.conf(t)
    t.console = true
end

local window = {}
local world
local H = love.graphics.getHeight()

local influence = 0.9
local smoothFactor = 0.01
local currentCameraX = 0
local currentCameraY = 0

local reloadBall = {
    test =  function (aName, bName)
        local names = { aName, bName }
        if not Pop(names, "Ball") then
            return false
        end
        local collider = names[1]
        if not collider then return false end
        -- note: NOT regex
        return string.match(collider, "^Goal%d*$") ~= nil
    end ,
    invoke = function(fixtureA, fixtureB, contact)
        Ball:drop(window.right / 2 - Ball.shape:getRadius() / 2, 30)
        love.audio.play(love.audio.newSource("audio/score.wav", "static"))
        currentCameraX = 0--Ball.body:getX()
        currentCameraY = 0--Ball.body:getY()
    end
}

-- local function reloadBall(fixtureA, fixtureB, contact)
--     Ball:drop(window.right / 2 - Ball.shape:getRadius() / 2, 30)
--     love.audio.play(love.audio.newSource("audio/score.wav", "static"))
-- end

local center = {} -- connector

-- local limitingVel = 400
function love.load()
    love.physics.setMeter(64)
    window.left = 0
    window.top = 0
    window.right = 1200
    window.bottom = 600

    -- Set the window size
    love.window.setMode(window.right, window.bottom)
    
    -- Players
    Player1 = PlayerProto.new()
    Player2 = PlayerProto.new()

    -- Create new World
    world = love.physics.newWorld(0, 90, true)
    -- Set contact handling callback
    local contactHandler = ContactHandler.new( )
    world:setCallbacks(contactHandler.beginContact)
    
    Menu:load(window, world, {Player1, Player2}, contactHandler)
    
    -- Add to contact handling callback list, post-set (above)!
    -- contactHandler:addBegin(reloadBall)
    -- contactHandler:addBegin(reloadBall)

    local wheelSize = 10

    -- Ball
    local ballRadius = BallSize(wheelSize)
    -- new constructor removes window, adds x, y params
    Ball:load(world, ballRadius,  window.right / 2 - ballRadius / 2, window.top)


    Player2:load(window, world, wheelSize, contactHandler)
    Player1:load(window, world, wheelSize, contactHandler)

    -- initial stage load (subsequent loads through menu)
    if Stage ~= nil and type(Stage.arena) == "table" then  
        Stage.arena:load(window, world, contactHandler)
    end
    -- -- Arena
    -- Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world, ballRadius)
    -- Goals:load(window, world, ballRadius * 2)

    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end

function love.update(dt)
    
    local isResume = Menu:update(dt)
    
    if not isResume then return end
    
    -- update world
    world:update(dt)

    -- update ball
    Ball:update(dt)

    Player1:update(dt)
    Player2:update(dt)
end

local function createWorld()

end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.12)

    local W = window.right
    local H = window.bottom

    -- Player world position
    local px = Player1.rear.body:getX()
    local py = Player1.rear.body:getY()

    -- Camera target: player slightly below center (Only Up style)
    local targetCameraX = px - W * 0.5
    local targetCameraY = py - H * 0.6   -- <--- THIS is the magic ratio

    -- Smooth follow
    currentCameraX = currentCameraX + (targetCameraX - currentCameraX) * smoothFactor * 0.1
    currentCameraY = currentCameraY + (targetCameraY - currentCameraY) * smoothFactor

    -- Only-Up threshold: 10% from top of screen
    local topEdge = currentCameraY
    local threshold = topEdge + H * 0.1

    if py < threshold then
        -- Smooth upward shift instead of instant jump
        currentCameraY = currentCameraY - H * 0.5
    end

    -- Apply camera transform
    love.graphics.push()
    love.graphics.translate(-currentCameraX, -currentCameraY)

        -- EVERYTHING in world space
    CurrentArena:draw()
    if Stage ~= nil and type(Stage.arena) == "table" then
            print("stage.arena: ", Stage.arena)
            Stage.arena:draw()
        end
        -- Goals:draw()
        -- Arena:draw()
        Player1:draw()
        Player2:draw()
        Ball:draw()

    love.graphics.pop()

    -- UI only
    Menu:draw(window)
end


