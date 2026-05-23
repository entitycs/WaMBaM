require("core.utils.input")
local states = require("core.state.definition")
local JoystickInputProto = require("core.input.joystick")
local menuShader = require("agent.copilot.menushader")
local getMenuItemPos = require("agent.copilot.menuitempos")
local confirmImage = love.graphics.newImage("images/MenuExit-CP.png", { dpiscale = 5 })

local cursor = 1
local joystick = {}
local drawQueueInstructions = {}


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


function StateMachine:load()
    print("inside load")
    if not StateMachine.state then
        StateMachine.state = states.landing
    end
    drawQueueInstructions = {}
    local drawInstruction = self.state.drawInstruction --function() menuShader:draw(confirmImage, 0, 200, true) end
    if not Contains(drawQueueInstructions, drawInstruction) then
        -- queue this command for draw:
        table.insert(drawQueueInstructions, drawInstruction)
    end
    if not joystick then
        joystick = JoystickInputProto.new()
    end
    cursorReset()
    print(self.state.title)
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

    local currentSelection = nil
    for k, node in ipairs(self.state.nodes) do
        if cursor == k then
            node.selected = true
            currentSelection = node
        else
            node.selected = false
        end

        -- check onTest for each reachable state
        for k1, nodeTest in pairs(self.state.trigger.onTest) do
            local res = nodeTest()
            if res > 0 then
                -- 'consume' the button input
                -- JoystickInput:setLastButton("none")
                self.state = self.state.nodes[res]
                self:load()
                return self.state.title ~= states.paused.title and
                    self.state.title ~=
                    states.landing
                    .title -- should a value here represent whether physics runs in main
            end
        end
    end
    -- check for selection trigger aligned with cursor
    if JoystickInputProto.consumeButton("a") then
        if currentSelection then
            print("a pressed")
            print(currentSelection.title)
            print(currentSelection.selected)
            self.state = currentSelection
            self:load()
        end
    end
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
            io.write(string.format("x, y: %d, %d\n", x, y))
            menuShader:draw(image, x, y, self.state.nodes[i].selected)
        end
    end
    self:onDrawQueue()
end


function StateMachine:onDrawQueue()
    for _, instruction in pairs(drawQueueInstructions) do
        instruction()
    end
    -- drawQueueInstructions = {}
end

return StateMachine
