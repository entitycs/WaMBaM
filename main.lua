require("core.ratios")
require("current.arena")
require("core.utils.table")
local context = require("core.context")
local Menu = require("core.menu.controller")
local Stage = require("current.stage")
local Ball = require("core.ball")
local PlayerManager = require("core.players")
local ContactHandler = require("core.contact")

function love.conf(t)
    t.console = true
end

local window = {}
local world = {}
local H = window.height --love.graphics.getHeight()

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function love.load()
    -- Get Window, World from Context
    context.init()
    window = context.window
    world = context.world

    -- Early return(s)
    if window == nil or world == nil then
        print("Error in main.lua: world or window not found")
        return
    end

    -- Main Config
    love.physics.setMeter(64)

    -- Window
    window.left = 0
    window.top = 0
    window.right = 1200
    window.bottom = 600
    love.window.setMode(window.right, window.bottom)

    -- World
    local contactHandler = ContactHandler.new()
    world:setCallbacks(contactHandler.beginContact)

    -- Players
    local wheelSize = 10
    PlayerManager.addPlayer(1) -- todo , run when new joystick added
    print("calling load on player manager")
    PlayerManager.load({ wheelSize = wheelSize, contactHandler = contactHandler })
    local player1 = PlayerManager.getPlayer(1) --PlayerProto.new()

    -- Menu
    Menu:load(window, world, { player1, }, contactHandler)

    -- Ball

    local ballRadius = BallSize(wheelSize)
    Ball:load(world, ballRadius, window.right / 2 - ballRadius / 2, window.top)

    -- Stage - initial stage load (subsequent loads through menu)
    if Stage ~= nil and type(Stage.arena) == "table" then
        Stage.arena:load(window, world, contactHandler)
    end
    -- -- Arena
    -- CurrentArena:load(window, world, ballRadius)

    -- Inputs
    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end

--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function love.update(dt)
    if not context.world then return end

    local isResume = Menu:update(dt)

    if not isResume then return end

    -- update world
    world:update(dt)

    Stage.arena:update(dt)
    
    -- update ball
    Ball:update(dt)
    PlayerManager.update(dt)
end

--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function love.draw()
    love.graphics.clear(0.1, 0.1, 0.12)

    PlayerManager.draw()

    -- CurrentArena:draw()
    if Stage ~= nil and type(Stage.arena) == "table" then
        Stage.arena:draw()
    end

    Menu:draw(window)
end
