local joystick = require("core.input.joystick")
local keyboard = require("core.input.keyboard")
local menuShader = require("agent.copilot.menushader")
local resumeImage = love.graphics.newImage("images/MenuResume-02.png", { dpiscale = 7 })
local pausedImage = love.graphics.newImage("images/MenuPlay-CP.png", { dpiscale = 5 })
local exitImage = love.graphics.newImage("images/MenuExit-CP.png", { dpiscale = 5 })
local mainMenuImage = love.graphics.newImage("images/MenuMain-CP.png", { dpiscale = 5 })

local cursor = 1

local function cursorNext(nodes)
    cursor = cursor + 1
    if cursor > #nodes then
        cursor = 1
    end
end

local function cursorPrev(nodes)
    cursor = cursor - 1
    if cursor < 1 then
        cursor = #nodes
    end
end

local function cursorReset()
    cursor = 1
end

local function checkConsumeJoy(state)
    if joystick.lastButton == state.joyMap then
        joystick.lastButton = "none"
        return true
    end
    return false
end


local function checkConsumeKey(state)
    if keyboard.lastKey == state.keyMap then
        keyboard.lastKey = "none"
        return true
    end
    return false
end


local function checkConsumeInput(state)
    return checkConsumeJoy(state) or checkConsumeKey(state)
end


local function checkConsumeInputs(state)
    return checkConsumeJoy(state), checkConsumeKey(state)
end


-- Partial Definition for States
local states = {
    landing = {
        title = "landing",
        joyMap = "b",
        keyMap = "m",
        selected = false,
        nodes = {}
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
    }
}

-- Define States 'graph'
states.landing.nodes = { states.game, states.exit } -- future home of settings?
states.game.nodes = { states.paused }
states.paused.nodes = { states.game, states.landing, states.exit }

-- Define States 'contents'
states.landing.images = { pausedImage, exitImage }
states.game.images = { pausedImage }
states.paused.images = { resumeImage, mainMenuImage, exitImage }

states.landing.text = { "Start New Game", "Exit" }
states.game.text = { "Press Start/Esc to pause" }
states.paused.text = { "Resume", "Exit to Menu", "Exit Game" }

states.landing.trigger = {
    onTest = { function()
        if checkConsumeInput(states.game) then
            return 1
        end
        if checkConsumeInput(states.exit) then
            return 2
        end
        return 0
    end },
    onEnter = function(window, world)
        print("LANDING")
    end
}

states.game.trigger = {
    onTest = { function()
        if checkConsumeInput(states.paused) then 
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
            if checkConsumeInput(states.game) then
                return 1
            end
            return 0
        end,
        -- exit to menu
        function()
            if checkConsumeInput(states.landing) then
                return 2
            end
            return 0
        end,
        -- quit game
        function()
            if checkConsumeInput(states.exit) then
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

states.exit.trigger = {
    onTest = { function() -- todo: if confirm-exit step
        if joystick.lastButton == "x" then
            return 1
        end
        if keyboard.lastKey == "escape" then
            return 1
        end
        return 0
    end },
    onEnter = function()
        love.event.quit()
    end
}

local StateMachine = {
    state = states.landing
}

local isLoaded = false

function StateMachine:load()
    print("inside load")
    cursorReset()
    print(self.state.title)
    if self.state ~= nil then
        self.state.trigger.onEnter()
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
    menuShader.load()
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

    if joystick.lastButton == "dpdown" then
        cursorNext(self.state.nodes)
        joystick.lastButton = "none"
    elseif joystick.lastButton == "dpup" then
        cursorPrev(self.state.nodes)
        joystick.lastButton = "none"
    end

    for k, node in ipairs(self.state.nodes) do
        if cursor == k then node.selected = true
        else node.selected = false
       end

        -- check for selection with cursor
        if joystick.lastButton == "a" then
            if node.selected then
                joystick.lastButton = "none"
                self.state = node
                self:load()
            end
        end

        -- check onTest for each reachable state
        for k1, nodeTest in pairs(self.state.trigger.onTest) do
            local res = nodeTest()
            if res > 0 then
                -- 'consume' the button input
                JoystickInput:setLastButton("none")
                self.state = self.state.nodes[res]
                self:load()
                return self.state.title ~= states.paused.title and
                self.state.title ~= states.landing.title                                     -- should a value here represent whether physics runs in main
            end
        end
    end
    return self.state.title == states.game.title
end

function StateMachine:draw(window)
    local image = nil
    local width = 0
    love.graphics.setColor(1, 1, 1, 1)
    if self.state.images then
        for i = 1, #self.state.images do
            image = self.state.images[i]
            local designDPI = 72
            local displayDPI = love.window.getDPIScale() * 96  -- LÖVE’s scale factor × baseline DPI
            local scale = displayDPI / designDPI

            local height = image:getHeight() / scale

            menuShader:draw(image, window.right / 2 - width / 2, 20 + 100   * i, self.state.nodes[i].selected)
        end
    end
end

return StateMachine
