require("core.utils.input")
require("core.utils.table")
-- local states = require("core.state")
local states = require("core.menu")
local arenaStateProto = require("agent.copilot.ui.arena")
local joystickInputProto = require("core.input.joystick")
local menuShader = require("agent.copilot.shaders.menushader")
local getMenuItemPos = require("agent.copilot.menuitempos")
local machineProto = require("core.statemachine")

local MenuView = {
    state = states.landing
}
-- local cursor = 1
local joystick = {}
local machine = machineProto.new()
--------------------------------------------------------------------------------
-- Load
--------------------------------------------------------------------------------
function MenuView:load(window, world, players, contactHandler)
    print("loading menu", window, world)
    if self.window == nil then 
        self.window = window
    end
    if self.world == nil then
        self.world = world
    end
    if players ~= nil then
        self.players = players
    end
    if contactHandler ~= nil then
        self.contactHandler = contactHandler
    end
    if not states.arena.controller then
        states.arena.controller = arenaStateProto.new(self.window)
    end
    if not MenuView.state then
        MenuView.state = states.landing
    end
    self.drawQueueInstructions = {} -- todo?
    local drawInstruction = self.state.drawInstruction
    if not Contains(self.drawQueueInstructions, drawInstruction) then
        table.insert(self.drawQueueInstructions, drawInstruction)
    end
    if not joystick then
        joystick = joystickInputProto.new()
    end
    machine:load(states.landing)
    machine:cursorReset()

    -- load
    for _, astate in pairs(states) do
        if astate.onLoad then
            astate.onLoad(self.window)
        end
    end

    -- enter
    if self.state ~= nil then
        print("entering state", self.window, self.world)
        self.state.trigger.onEnter(self.window, self.world, self.players, self.contactHandler)
        states.previous = self.state
    end
    menuShader.load()
end

--------------------------------------------------------------------------------
-- Update
--------------------------------------------------------------------------------
function MenuView:update(dt)

    if not machine then return end
    -- selection up/down (joystick only -- keyboard todo)
    for _, btn in pairs({ "dpdown", "dpright" }) do
        if joystickInputProto.consumeButton(btn) then
            machine:cursorNext()
        end
    end
    for _, btn in pairs({ "dpup", "dpleft" }) do -- ? can both be present in 1 update
        if joystickInputProto.consumeButton(btn) then
            machine:cursorPrev()
        end
    end

    -- Two options for selecting + loading next state:
    -- 1) trigger test (eg. start button pressed during playing/game state)
    -- 2) directional cursor selects, and designated key/joystick button applies selection
    -- local currentSelection = machine:getSelectedNode() -- moved below

    -- for each reachable state, test for trigger to load
    local targetIndex, targetState = machine:onTest()
    if targetIndex > 0 then
        -- transition
        self.state = targetState
        self:load()
        machine:load(targetState)
        return self.state.title == states.game.title or self.state.title == states.tutorial.title
    end
    -- for _, nodeTest in pairs(self.state.trigger.onTest) do
    --     local res = nodeTest()
    --     -- load by returned next index if non-zero result
    --     if res > 0 then
    --         self.state = self.state.nodes[res]
    --         self:load()
    --         return self.state.title == states.game.title
    --     end
    -- end

    -- -- for each reachable next state, set selected from cursor
    -- for k, node in ipairs(self.state.nodes) do
    --     if cursor == k then
    --         node.selected = true
    --         currentSelection = node
    --     else
    --         node.selected = false
    --     end
    -- end

    -- check for selection trigger aligned with cursor
    if self.state ~= states.game and
        self.state ~= states.tutorial and
        joystickInputProto.consumeButton("a") then
        local currentSelection = machine:getSelectedNode()
        if currentSelection then
            self.state = currentSelection
            self:load(self.window, self.world)
            machine:load(currentSelection)
        end
    end
    -- arenas
    if self.state == states.arena and states.arena.controller then
        states.arena.controller:update(dt)
    end

    -- return false if game should be paused, true otherwise
    return self.state.title == states.game.title or self.state.title == states.tutorial.title
end

--------------------------------------------------------------------------------
-- Draw
--------------------------------------------------------------------------------
function MenuView:draw(window)
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

------------------------------------------------------
-- onDrawQueue
--
-- Used to draw data queued outside of draw lifecycle
------------------------------------------------------
function MenuView:onDrawQueue()
    for _, instruction in pairs(self.drawQueueInstructions) do
        instruction()
    end
end

return MenuView
