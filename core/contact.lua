local ContactHandler = {
    handlers = {
        begin = {}
    }
}
ContactHandler.__index = ContactHandler

--------------------------------------------------------------------------------
--- new
--------------------------------------------------------------------------------
function ContactHandler.new()
    local handlers = {
        begin = {}
    }
    local function beginContact(fixtureA, fixtureB, contact)
        if fixtureA == nil or fixtureB == nil then return end
        local ud_a = fixtureA:getUserData() or nil
        local ud_b = fixtureB:getUserData() or nil

        for i, o in pairs(handlers.begin) do
            local handler = o.handler
            if (ud_a ~= nil and ud_b ~= nil) then
                if handler.test(ud_a["name"], ud_b["name"]) then
                    handler.invoke(fixtureA, fixtureB, contact)
                end
            end -- else print error?
        end
        -- do not use contact after this function returns
    end

    return setmetatable({
        handlers = handlers,
        beginContact = beginContact
    }, ContactHandler)
end

-- Add Begin callback
---@param handler table
function ContactHandler:addBegin(handler)
    table.insert(self.handlers.begin, { handler = handler })
end

-- Remove Begin callback
function ContactHandler:removeBegin(handler)
    for i = #self.handlers.begin, 1, -1 do
        if self.handlers.begin[i].handler == handler then
            table.remove(self.handlers.begin, i)
            break
        end
    end
end

return ContactHandler
