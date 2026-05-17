local Joystick = require("core.input.joystick")
local Keyboard = require("core.input.keyboard")

-- Partial Definition for States
local states = {
    landing = {
        nodes = {},
        triggerResult = 0
    },
    game = {
        nodes = {},
        triggerResult = 0
    },
    paused = {
        nodes = {},
        triggerResult = 0
    },
    exit = {
        nodes = {},
        triggerResult = 0
    }
}

-- Define States 'graph'
states.landing.nodes = { states.game, states.exit }
states.game.nodes = { states.paused }
states.paused.nodes = { states.game, states.landing, states.exit }

-- Define States 'contents'
states.landing.title = "Landing"
states.landing.text = { "Start New Game", "Exit" }
states.landing.trigger = {
    onTest = { function()
        if Joystick.lastButton == "start" then
            return 1
        elseif Joystick.lastButton == "x" then
            return 2
        end
        if Keyboard.lastKey == "enter" then
            return 1
        elseif Keyboard.lastKey == "escape" then
            return 2
        end
        return 0
    end },
    onEnter = {
        function(window, world)

        end,
        function(window, world)
            love.event.quit()
        end
    }
}

states.game.title = "Playing"
states.game.text = { "Press Start/Esc to pause" }
states.game.trigger = {
    onTest = { function()
        if Joystick.lastButton == "start" then
            return 1
        end
        if Keyboard.lastKey == "escape" then
            return 1
        end
        return 0
    end },
    onEnter = {
        function()
            print("GAME STARTED!!!")
        end
    }
}

states.paused.title = "Paused"
states.paused.text = { "Resume", "Exit to Menu", "Exit Game" }
states.paused.trigger = {
    onTest = {
        -- resume
        function()
            if Joystick.lastButton == "start" then
                Joystick.lastButton = "none"
                return 1
            end
            if Keyboard.lastKey == "escape" then
                Keyboard.lastKey = "none"
                return 1
            end
            return 0
        end,
        -- exit to menu
        function()
            if Joystick.lastButton == "b" then
                Joystick.lastButton = "none"
                return 2
            end
            return 0
        end,
        -- quit game
        function()
            if Joystick.lastButton == "x" then
                Joystick.lastButton = "none"
                return 3
            end
            if Keyboard.lastKey == "q" then
                Keyboard.lastKey = "none"
                return 3
            end
            return 0
        end
    },
    onEnter = {
        function()
            print("GAME PAUSED!!!")
        end,
        function()
            print("MAIN MENU!!!")
        end,
        function()
            love.event.quit()
        end
    }
}

states.exit.title = "Goodbye"
states.exit.trigger = {
    onTest = { function()
        if Joystick.lastButton == "x" then
            return 1
        end
        if Keyboard.lastKey == "escape" then
            return 1
        end
        return 0
    end },
    onEnter = {
        function()
            love.event.quit()
        end
    }
}

local StateMachine = {
    state = states.landing
}

local isLoaded = false

function StateMachine:load( )
    print("inside load")
    print(self.state.title)
    if self.state ~= nil then
        print("new states available:")
        for k in ipairs(self.state.nodes) do
            print(k .. "...")
            for k1, v in pairs(self.state.nodes[k]) do
                print(k1)
                print(v)
            end
        end
        print("\n")
        -- self.state = state
    end
end

function StateMachine:next()
    -- -- reset available options
    -- self.options = {}
    -- -- set options for display
    -- for k, v in pairs(self.states) do
    --     table.insert(self.options, v.text)
    -- end
end

function StateMachine:update(dt)
    local last = JoystickInput.lastButton
    -- if last ~= "none" then
    --     print(JoystickInput.lastButton)
    -- end
    for k, node in ipairs(self.state.nodes) do
        -- check onTest for each reachable state
        -- print("checking tests for node: ")
        -- print(node.title)
        for k1, nodeTest in pairs(self.state.trigger.onTest) do
            local res = nodeTest()
            if res > 0 then
                print("made it " .. res)
                JoystickInput:setLastButton("none")
                self.state.trigger.onEnter[res]()
                self.state = self.state.nodes[res]
                self:load()
                return self.state.title ~= "Paused" and self.state.title ~= "Landing" -- should a value here represent whether physics runs in main
            end
        end
    end
    return self.state.title == "Playing"
end

function StateMachine:draw(window)
    -- print("current state: ")
    -- print(self.state.title)
    local font = love.graphics.getFont()
    local text = love.graphics.newText(font, nil)
    local width = 0
    local height = font:getHeight()
    love.graphics.setColor(1, 1, 1, 1)
    width = text:add({ { 1, 1, 1 }, self.state.title }, 0, 0) + width
    width = text:add({ { 0.8, 0.8, 0 }, "\nSecond Option" }, 0, 0) + width
    love.graphics.draw(text, window.right / 2 - width / 2, 99)
end

return StateMachine
