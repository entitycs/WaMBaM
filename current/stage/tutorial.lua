require("core.ratios")
require("current.arena")
require("core.utils.table")
local context = require("core.context")
local Arena = require("core.tutorial_arena")
local Ball = require("core.ball")
local Player1 = {}
-- 1780976264.8167
local ContactHandler = require("core.contact")

local TutorialStage = {
    window = {},
    world = {},
    textbox = {
        currentProgress = false,
    },
    currentTask = 1,
    currentTaskCountdown = 0,
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
        Ball:drop(nil, Player1.rear.body:getY())
        love.audio.play(love.audio.newSource("audio/score.wav", "static"))
        currentCameraX = 0 --Ball.body:getX()
        currentCameraY = 0 --Ball.body:getY()
    end
}

function TutorialStage:nextTask()

end

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
    self.currentTask = 1
    self.textbox = {
        positions = { { x = 0, y = 0 } },
        oFont = love.graphics.getFont(),
        font = love.graphics.newFont("fonts/VampiroOne-Regular.ttf", 20),
        tasks = {
            {
                draw = function()
                    local text = love.graphics.newText(self.textbox.font)
                    text:add({
                        { 1,   1, 1 }, "Welcome \n\
                Your body is made of two parts. \n\
                Use the RIGHT STICK to move your",
                        { 0.1, 1, 0.1 }, " 'BaM'",
                        { 1, 1, 1 }, " side to 12o'clock"
                    }, 0, 0)
                    if self.textbox.currentProgress == true then
                        love.graphics.setColor(0.1, 1, 0.1)
                    else
                        love.graphics.setColor(1, 1, 0.1)
                    end

                    love.graphics.rectangle("fill", 0, Player1.front.body:getY(), context.window.right, 10)
                    love.graphics.setColor(1, 1, 1)
                    self.currentTaskCountdown = self.currentTaskCountdown - 1

                    love.graphics.draw(text, 100, 200)
                end,
                update = function(dt)
                    self.textbox.currentProgress = false
                    if math.abs(Player1.rear.body:getX() - Player1.front.body:getX()) < 10 then
                        if Player1.rear.body:getY() > Player1.front.body:getY() then
                            self.textbox.currentProgress = true
                        end
                    end
                end,
                -- message = "Welcome \n\
                --     Your body is made of two parts. \n\
                --     Use the right stick to move your 'bam' side\n\
                --     straight up (12 o'clock position).",
                test = function()
                    if self.currentTaskCountdown < 0 then
                        self.currentTaskCountdown = 100
                        return true
                    end
                    return false
                    -- love.graphics.draw(text, 100, 200)
                end
            },
            {
                draw = function()
                    -- love.graphics.setFont(self.textbox.font)
                    local font = love.graphics.getFont()
                    local text = love.graphics.newText(self.textbox.font)
                    text:add({
                        { 1,   1, 1 }, "Hello World!",
                        { 0.1, 1, 0.1 }, " How are you?",
                    }
                    , 0, 0)
                    if self.textbox.currentProgress == true then
                        love.graphics.setColor(0.1, 1, 0.1)
                    else
                        love.graphics.setColor(1, 1, 0.1)
                    end

                    love.graphics.rectangle("fill", 0, Player1.front.body:getY(), context.window.right, 10)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(text, 100, 200)
                end,
                update = function(dt)
                    self.textbox.currentProgress = false
                    if math.abs(Player1.rear.body:getX() - Player1.front.body:getX()) < 10 then
                        if Player1.rear.body:getY() < Player1.front.body:getY() then
                            self.textbox.currentProgress = true
                        end
                    end
                end,
                test = function()
                end
            },
            {
                message = "Message 3",
                test = function()
                end
            },
            {
                message = "Message 4",
                test = function()
                end
            },
            {
                message = "Message 5",
                test = function()
                end
            },
            {
                message = "Message 6",
                test = function()
                end
            },
            {
                message = "Message 7",
                test = function()
                end
            },
            {
                message = "Message 8",
                test = function()
                end
            },
            {
                message = "Message 9",
                test = function()
                end
            },
            {
                message = "Message 10",
                test = function()
                end

            }
        }
        -- "Message 3",
        -- "Message 4",
        -- "Message 5",
        -- "Message 6",
        -- "Message 7",
        -- "Message 8",
        -- "Message 9",
        -- "Message 10"
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
    -- run the current test
    -- self.textbox.tasks[self.currentTask].test(dt)
    -- print(Player1.rear.body:getY())
    if Ball.body:getY() > self.window.bottom then
        Ball.body:setLinearVelocity(0, 0)
        Ball:drop(nil, Player1.rear.body:getY() - 30)
    end

    local msgIndex = -(Player1.rear.body:getY() - context.window.bottom) / 300
    msgIndex = msgIndex > 0 and msgIndex < 10 and msgIndex or 1
    self.currentTask = math.ceil(msgIndex)
    self.textbox.tasks[self.currentTask].update(dt)
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
    -- love.graphics.setFont(self.textbox.font)

    -- Draws "Hello world!" at position x: 100, y: 200 with the custom font applied.
    local msgIndex = -(Player1.rear.body:getY() - context.window.bottom) / 300
    msgIndex = msgIndex > 0 and msgIndex < 10 and msgIndex or 1


    love.graphics.setColor(1, 1, 1, .5)
    print(self.textbox.tasks[math.ceil(msgIndex)].draw())
    -- love.graphics.print(self.textbox.messages[math.ceil(msgIndex)], 100, 200)
    -- love.graphics.setFont(self.textbox.oFont)
end

return TutorialStage
