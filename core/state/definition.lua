require("core.utils.input")
require("agent.copilot.menuitempos")
local menuShader = require("agent.copilot.shaders.menushader")
local menuWamBam = love.graphics.newImage("images/MenuWamBam.png", { dpiscale = 3 })
local pausedImage = love.graphics.newImage("images/MenuPaused.png", { dpiscale = 3 })
local resumeImage = love.graphics.newImage("images/MenuResume-02.png", { dpiscale = 6 })
local pauseImage = love.graphics.newImage("images/MenuPlay-CP.png", { dpiscale = 5 })
local exitImage = love.graphics.newImage("images/MenuExit-CP.png", { dpiscale = 6 })
local mainMenuImage = love.graphics.newImage("images/MenuMain-CP.png", { dpiscale = 5 })
local confirmImage = love.graphics.newImage("images/MenuExit-CP.png", { dpiscale = 5 })
local yesImage = love.graphics.newImage("images/MenuYes.png", { dpiscale = 4 })
local noImage = love.graphics.newImage("images/MenuNo.png", { dpiscale = 4 })


-- Partial Definition for States
local states = {
    previous = {
        title = "previous"
    },
    landing = {
        title = "landing",
        joyMap = "b",
        keyMap = "m",
        selected = false,
        nodes = {}
    },
    arena = {
        title = "arena",
        joyMap = "rightshoulder",
        keyMap = "a",
        selected = false,
        nodes = {},
        controller = nil
    },
    game = {
        title = "playing",
        joyMap = "start",
        keyMap = "escape",
        selected = true,
        nodes = {}
    },
    paused = {
        title = "paused",
        joyMap = "start",
        keyMap = "escape",
        selected = false,
        nodes = {}
    },
    exit = {
        title = "exit",
        joyMap = "x",
        keyMap = "q",
        selected = false,
        nodes = {}
    },
    confirmExit = {
        title = "confirm exit",
        joyMap = "x",
        keyMap = "q",
        selected = false,
        nodes = {}
    }
}

-- Define States 'graph'
states.previous = states.landing
states.landing.nodes = { states.game, states.arena, states.confirmExit } -- future home of settings?
states.arena.nodes = { states.landing }
states.game.nodes = { states.paused }
states.paused.nodes = { states.game, states.landing, states.confirmExit }
states.confirmExit.nodes = { states.exit }

-- Define States 'contents'
states.landing.images = { pauseImage, exitImage }
states.arena.images = { yesImage }
states.game.images = {  }
states.paused.images = { resumeImage, mainMenuImage, exitImage }
states.confirmExit.images = { yesImage, noImage }

states.landing.drawInstruction = function() menuShader:draw(menuWamBam, 0, 200, true) end
states.game.drawInstruction = function() end
states.paused.drawInstruction = function() menuShader:draw(pausedImage, 0, 200, true) end
states.confirmExit.drawInstruction = function() menuShader:draw(confirmImage, 0, 200, true) end

states.landing.text = { "Start New Game", "Exit" }
states.game.text = { "Press Start/Esc to pause" }
states.paused.text = { "Resume", "Exit to Menu", "Exit Game" }
states.confirmExit.text = {"Yes", "No"}

states.landing.trigger = {
    onTest = { function()
        if CheckConsumeInput(states.game) then
            return 1
        end
        if CheckConsumeInput(states.confirmExit) then
            return 2
        end
        return 0
    end },
    onEnter = function(window, world)
        print("LANDING")
    end
}

states.arena.trigger = {
    onTest = { function()
        if CheckConsumeInput(states.landing) then
            return 1
        end
        return 0
    end },
        onEnter = function(window, world)
        print("ARENA!!!")
    end
}

states.game.trigger = {
    onTest = { function()
        if CheckConsumeInput(states.paused) then
            return 1
        end
        return 0
    end },
    onEnter = function()
        print("GAME STARTED!!!")
    end
}

states.paused.trigger = {
    onTest = {
        -- resume
        function()
            if CheckConsumeInput(states.game) then
                return 1
            end
            return 0
        end,
        -- exit to menu
        function()
            if CheckConsumeInput(states.landing) then
                return 2
            end
            return 0
        end,
        -- quit game
        function()
            if CheckConsumeInput(states.confirmExit) then
                return 3
            end
            return 0
        end
    },
    onEnter = function()
        --
        print("GAME PAUSED!!!")
    end
}

states.confirmExit.trigger = {
    onTest = { function()
        if CheckConsumeInput(states.exit) then
            return 1
        end
        return 0
    end },
    onEnter = function()
        print("CONFIRM EXIT") -- todo: show RUSure? graphic
        states.confirmExit.nodes[2] = states.previous
    end
}

states.exit.trigger = {
    onTest = { function() -- todo: if confirm-exit step
        if CheckConsumeInput(states.exit) then
            return 1
        end
        return 0
    end },
    onEnter = function()
        love.event.quit()
    end
}

return states