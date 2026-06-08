require("core.ratios")
require("current.arena")
require("core.utils.table")
local Arena = require("core.tutorial_arena")
local Ball = require("core.ball")
local Player1 = {}

local ContactHandler = require("core.contact")

local TutorialStage = {
    window = {},
    world = {},
    textbox = {},
}

local influence = 0.9
local smoothFactor = 0.01
local currentCameraX = 0
local currentCameraY = 0

local reloadBall = {
    test = function(aName, bName)
        local names = { aName, bName }
        if not Pop(names, "Ball") then
            return false
        end
        local collider = names[1]
        if not collider then return false end
        -- note: NOT regex
        return string.match(collider, "^Goal%d*$") ~= nil
    end,
    invoke = function(fixtureA, fixtureB, contact)
        Ball:drop(nil, 30)
        love.audio.play(love.audio.newSource("audio/score.wav", "static"))
        currentCameraX = 0 --Ball.body:getX()
        currentCameraY = 0 --Ball.body:getY()
    end
}

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function TutorialStage:load(window, world, players, contactHandler)
    self.window = window
    self.world = world
    love.physics.setMeter(64)
    self.window.left = 0
    self.window.top = 0
    self.window.right = 1200
    self.window.bottom = 600

    self.textbox = {
        positions = { { x = 0, y = 0 } },
        oFont = love.graphics.getFont(),
        font = love.graphics.newFont("fonts/VampiroOne-Regular.ttf", 40)
    }

    -- Add to contact handling callback list, post-set!
    contactHandler:addBegin(reloadBall)

    -- -- Players
    Player1 = players[1] --PlayerProto.new()

    -- Arena
    Arena:load(window, world)

    Directions = { "up", "down", "left", "right" }
    DirectionTargets = { "y", "y", "x", "x" }
end

function TutorialStage:unload()
    Arena:unload()
    ContactHandler:removeBegin(reloadBall)
end

--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function TutorialStage:update(dt)
    -- update world
    self.world:update(dt)
    -- print(Ball.body:getY())
    if Ball.body:getY() > self.window.bottom then Ball:drop(nil, 30) end
end

--------------------------------------------------------------------------------
--- draw - *w/ help from copilot
--------------------------------------------------------------------------------
function TutorialStage:draw()
    love.graphics.clear(0.1, 0.1, 0.12)

    local W = self.window.right
    local H = self.window.bottom

    -- -- Player world position
    local px = Player1.rear.body:getX()
    local py = Player1.rear.body:getY()

    -- Camera target: player slightly below center (Only Up style)
    local targetCameraX = px - W * 0.5
    local targetCameraY = py - H * 0.6 -- <--- THIS is the magic ratio

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
    Player1:draw()
    Ball:draw()
    Arena:draw()
    love.graphics.pop()
    love.graphics.setFont(self.textbox.font)

    -- Draws "Hello world!" at position x: 100, y: 200 with the custom font applied.
    love.graphics.setColor(1,1,1,.5)
    love.graphics.print("Hello world!", 100, 200)
    love.graphics.setFont(self.textbox.oFont)
end

return TutorialStage
