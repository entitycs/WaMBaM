require("core.ratios")
require("current.arena")
require("core.utils.table")
-- local Menu = require("core.menu.controller")
local Arena = require("core.arena")
local Goals = require("current.goals.container")
local Ball = require("core.ball")
local PlayerProto = require("player.body")
local Player1 = {}
local Player2 = {}

local ContactHandler = require("core.contact")

local DefaultStage = {
    window = {},
    world = {}
}

 
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
        Ball:drop(nil, 30)
        love.audio.play(love.audio.newSource("audio/score.wav", "static"))
        currentCameraX = 0--Ball.body:getX()
        currentCameraY = 0--Ball.body:getY()
    end
}
 

local center = {} -- connector
 


--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function DefaultStage:load(window, world, players, contactHandler)
    self.window = window
    self.world = world
    love.physics.setMeter(64)
    self.window.left = 0
    self.window.top = 0
    self.window.right = 1200
    self.window.bottom = 600

    -- -- Set the window size
    -- love.window.setMode(self.window.right, self.window.bottom)

    -- Create new World
    -- world = love.physics.newWorld(0, 90, true)
    -- Menu:load(self.window, self.world)
    -- Set contact handling callback

    -- Add to contact handling callback list, post-set!
    contactHandler:addBegin(reloadBall)

    local wheelSize = 10

    -- -- Ball
    local ballRadius = BallSize(wheelSize)
    -- Ball:load(self.window, self.world, ballRadius)

    -- -- Players
    Player1 = players[1]--PlayerProto.new()
    Player2 = players[2]--PlayerProto.new()

    -- Player2:load(window, world, wheelSize, contactHandler)
    -- Player1:load(window, world, wheelSize, contactHandler)
    -- Arena
    Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world, ballRadius)
    Goals:load(window, world, ballRadius * 2)

    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end

function DefaultStage:unload()
    Goals:unload()
    Arena:unload()
    ContactHandler:removeBegin(reloadBall)
end
--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function DefaultStage:update(dt)
    
    -- local isResume = Menu:update(dt)
    
    -- if not isResume then return end
    
    -- update world
    self.world:update(dt)

    -- update ball
    -- Ball:update(dt)

    -- Player1:update(dt)
    -- Player2:update(dt)
end

local function createWorld()

end


--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function DefaultStage:draw()
    love.graphics.clear(0.1, 0.1, 0.12)

    local W = self.window.right
    local H = self.window.bottom

    -- -- Player world position
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
        -- Player1:draw()
        -- Player2:draw()
        -- Ball:draw()
     
    love.graphics.pop()
    Goals:draw()
    Arena:draw()

    -- UI only
    -- Menu:draw(self.window)
end

return DefaultStage
