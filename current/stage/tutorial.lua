require("core.ratios")
require("current.arena")
require("core.utils.table")
local Arena = require("core.tutorial_arena")
-- local Goals = require("current.goals.container")
-- local Ball = require("core.ball")
-- local PlayerProto = require("player.body")
local Player1 = {}
-- local Player2 = {}

local Tutorial = {
    window = {},
    world = {}
}
 --------------------------------------------------------------

local H = love.graphics.getHeight()

local influence = 0.9
local smoothFactor = 0.01
local currentCameraX = 0
local currentCameraY = 0

 
-- local limitingVel = 400
function Tutorial:load(window, world, players, contactHandler)
 
    if window ~= nil then self.window = window end
    if world ~= nil then self.world = world end
    if players ~= nil then self.players = players end

    self.right = window.right
    self.bottom = window.bottom
    window = window
    -- Create new World
    -- world = love.physics.newWorld(0, 90, true)
    -- Set contact handling callback

    local wheelSize = 10

    -- Ball
    local ballRadius = BallSize(wheelSize)
 
    -- Players
    Player1 = self.players[1]-- PlayerProto.new()
 
    -- Player1:load(window, world, wheelSize, contactHandler)
    -- Arena
    Arena:load(window, world)

    -- Per 'Round/Game' Arena
    CurrentArena:load(window, world, ballRadius)
 
    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end


function Tutorial:unload()
    Arena:unload()
end


function Tutorial:update(dt)
    
    Player1:update(dt)
 
end

 

function Tutorial:draw()
    love.graphics.clear(0.1, 0.1, 0.12)

    local W = self.right
    local H = self.bottom

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
 
        -- Arena:draw()
        -- Player1:draw()
 

    love.graphics.pop()
end

return Tutorial

