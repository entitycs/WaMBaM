require("core.utils.input")
require("core.utils.table")
local states = require("core.state.definition")
local ArenaState = require("core.state.arena")
local JoystickInputProto = require("core.input.joystick")
local menuShader = require("agent.copilot.shaders.menushader")
local getMenuItemPos = require("agent.copilot.menuitempos")

local cursor = 1
local joystick = {}

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


local StateMachine = {
    state = states.landing
}


function StateMachine:load(window)
    if not states.arena.controller then 
        states.arena.controller = ArenaState.new(window)
    end
    if not StateMachine.state then
        StateMachine.state = states.landing
    end
    self.drawQueueInstructions = {}
    local drawInstruction = self.state.drawInstruction
    if not Contains(self.drawQueueInstructions, drawInstruction) then
        table.insert(self.drawQueueInstructions, drawInstruction)
    end
    if not joystick then
        joystick = JoystickInputProto.new()
    end
    cursorReset()
    if self.state ~= nil then
        self.state.trigger.onEnter(self.state.previous, drawInstruction)
        states.previous = self.state
    end
    menuShader.load()
end


function StateMachine:update(dt)
    -- selection up/down (joystick only -- keyboard todo)
    for _, btn in pairs({ "dpdown", "dpright" }) do
        if JoystickInputProto.consumeButton(btn) then
            cursorNext(self.state.nodes)
        end
    end
    for _, btn in pairs({ "dpup", "dpleft" }) do -- ? can both be present in 1 update
        if JoystickInputProto.consumeButton(btn) then
            cursorPrev(self.state.nodes)
        end
    end

    -- Two options for selecting + loading next state:
    -- 1) trigger test (eg. start button pressed during playing/game state)
    -- 2) directional cursor selects, and designated key/joystick button applies selection
    local currentSelection = nil

    -- for each reachable state, test for trigger to load
    for _, nodeTest in pairs(self.state.trigger.onTest) do
        local res = nodeTest()
        -- load by returned next index if non-zero result
        if res > 0 then
            self.state = self.state.nodes[res]
            self:load()
            return self.state.title == states.game.title
        end
    end

    -- for each reachable next state, set selected from cursor
    for k, node in ipairs(self.state.nodes) do
         if cursor == k then
            node.selected = true
            currentSelection = node
        else
            node.selected = false
        end
    end

    -- check for selection trigger aligned with cursor
    if self.state ~= states.game and JoystickInputProto.consumeButton("a") then
        if currentSelection then
            self.state = currentSelection
            self:load()
        end
    end
    -- arenas
    if self.state == states.arena and states.arena.controller then
        states.arena.controller:update(dt)
    end

    -- return false if game should be paused, true otherwise
    return self.state.title == states.game.title
end


function StateMachine:draw(window)
    local image = nil
    love.graphics.setColor(1, 1, 1, 1)
    if self.state.images then
        local dpi
        for i = 1, #self.state.images do
            image = self.state.images[i]
            local x, y = getMenuItemPos(i, self.state.images)
            menuShader:draw(image, x, y, self.state.nodes[i].selected)
        end
    end
    -- arena
    if self.state == states.arena then
        states.arena.controller:draw()
    end

    self:onDrawQueue()
end


function StateMachine:onDrawQueue()
    for _, instruction in pairs(self.drawQueueInstructions) do
        instruction()
    end
end

return StateMachine
