local menuShader = require("agent.copilot.shaders.menushader")

local menuWamBam = love.graphics.newImage("images/MenuWamBam.png", { dpiscale = 3 })
local pausedImage = love.graphics.newImage("images/MenuPaused.png", { dpiscale = 3 })
local resumeImage = love.graphics.newImage("images/MenuResume.png", { dpiscale = 6 })
local pauseImage = love.graphics.newImage("images/MenuPlay.png", { dpiscale = 5 })
local exitImage = love.graphics.newImage("images/MenuExit.png", { dpiscale = 6 })
local mainMenuImage = love.graphics.newImage("images/MenuMain.png", { dpiscale = 5 })
local confirmImage = love.graphics.newImage("images/MenuExit.png", { dpiscale = 5 })
local yesImage = love.graphics.newImage("images/MenuYes.png", { dpiscale = 4 })
local noImage = love.graphics.newImage("images/MenuNo.png", { dpiscale = 4 })
local menuOptions = love.graphics.newImage("images/MenuOptions.png", {dpiscale = 6})
local tutorialImage = love.graphics.newImage("images/MenuTutorial.png", {dpiscale = 6})

return {
    images = {
        landing = { pauseImage, menuOptions, tutorialImage, exitImage },
        arena = { menuOptions },
        game = {},
        tutorial = {},
        paused = { resumeImage, mainMenuImage, exitImage },
        confirmExit = { yesImage, noImage }
    },
    
    text = {
        landing = { "Start New Game", "Exit" },
        game = { "Press Start/Esc to pause" },
        paused = { "Resume", "Exit to Menu", "Exit Game" },
        confirmExit = {"Yes", "No"}
    },
    
    drawInstruction = {
        landing = function() menuShader:draw(menuWamBam, 0, 200, true) end,
        game = function() end,
        paused = function() menuShader:draw(pausedImage, 0, 200, true) end,
        confirmExit = function() menuShader:draw(confirmImage, 0, 200, true) end
    }
}