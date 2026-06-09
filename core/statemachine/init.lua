local StateMachine = {}
StateMachine.__index = StateMachine

--------------------------------------------------------------------------------
--- new
--------------------------------------------------------------------------------
function StateMachine.new()
    local self = setmetatable({
        state = nil,
        cursor = 1
    }, StateMachine)
    return self
end

function StateMachine:cursorNext()
    local prev = self.cursor
    self.cursor = self.cursor + 1
    if self.cursor > #self.state.nodes then self.cursor = 1 end
    print("cursor", self.cursor)
    self.state.nodes[prev].selected = false
    self.state.nodes[self.cursor].selected = true
end

function StateMachine:cursorPrev()
    local prev = self.cursor
    self.cursor = self.cursor - 1
    if self.cursor < 1 then self.cursor = #self.state.nodes end
    print("cursor", self.cursor)
    self.state.nodes[prev].selected = false
    self.state.nodes[self.cursor].selected = true
end

function StateMachine:getSelectedNode()
    print("getSelectedNode", self.cursor)
    return self.state.nodes[self.cursor]
end

function StateMachine:cursorReset()
    self.cursor = 1
    if nil == self.state or nil == self.state.nodes then return end
    for k, v in pairs(self.state.nodes) do
        v.selected = false
    end
    self.state.nodes[1].selected = true
end

function StateMachine:onTest()
    -- print("StateMachine:onTest 1", self.state.trigger.onTest)
    if not self.state or not self.state.trigger.onTest then
        return 0, nil
    end
    -- print("StateMachine:onTest 2", self.state.title)
    for _, nodeTest in pairs(self.state.trigger.onTest) do
        local res = nodeTest()
        -- print("state onTest result", res)
        -- load by returned next index if non-zero result
        if res and res > 0 then
            return res, self.state.nodes[res]
        end
    end
    return 0, self.state
end

--------------------------------------------------------------------------------
--- load (& reload)
--------------------------------------------------------------------------------
function StateMachine:load(newState)
    self.state = newState
    self:cursorReset()
end

return StateMachine
