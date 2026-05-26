require("core.ratios")
require("current.arena")
require("core.utils.table")
local Menu = require("core.state.menu")
Arena = require("core.arena")
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
    invoke = function (fixtureA, fixtureB, contact)
        Ball:drop(window.right / 2 - Ball.shape:getRadius() / 2, 30)
        love.audio.play(love.audio.newSource("audio/score.wav", "static"))
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

    -- Create new World
    world = love.physics.newWorld(0, 90, true)
    Menu:load(window)
    -- Set contact handling callback
    local contactHandler = ContactHandler.new(world)
    world:setCallbacks(contactHandler.beginContact)

    -- Add to contact handling callback list, post-set!
    contactHandler:addBegin(reloadBall)
    contactHandler:addBegin(reloadBall)

    local wheelSize = 10

    -- Ball
    local ballRadius = BallSize(wheelSize)
    Ball:load(window, world, ballRadius)

    -- Players
    Player1 = PlayerProto.new()
    Player2 = PlayerProto.new()

    Player2:load(window, world, wheelSize, contactHandler)
    Player1:load(window, world, wheelSize, contactHandler)
    -- Arena
    Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world, ballRadius)

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

function love.draw()
    -- Wipe the screen
    love.graphics.clear(0.1, 0.1, 0.12)
    love.graphics.setColor(.5, .5, .5)

    -- Draw Arena (Backdrop => first)
    CurrentArena:draw()

    -- Draw Arena
    Arena:draw()

    -- Draw player
    Player1:draw()
    Player2:draw()
    -- Draw ball
    Ball:draw()

    -- Draw Menu
    Menu:draw(window)

end
