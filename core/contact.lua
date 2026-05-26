local ContactHandler = {}
ContactHandler.__index = ContactHandler

-- Add Begin callback
--- func desc
---@param handler table 
function ContactHandler:addBegin( handler)
    -- print("contact handler: ")
    -- print("nameFixtureA: ", nameFixtureA)
    -- print("nameFixtureB: ", nameFixtureB)

    table.insert(self.handlers.begin, { handler = handler })
    -- handler.names? - i only use names for the test...
    -- ... so just handler, if i refactor
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

function ContactHandler.new(world)
    local handlers = {
        begin = {}
    }
    local function beginContact(fixtureA, fixtureB, contact)
        if fixtureA == nil or fixtureB == nil then return end
        local ud_a = fixtureA:getUserData() or nil
        local ud_b = fixtureB:getUserData() or nil

        for i, o in pairs(handlers.begin) do
            -- copy fixture names for handler
            -- local names = { o.names[1], o.names[2] }
            local handler = o.handler
            if (ud_a ~= nil and ud_b ~= nil) then
                io.write(string.format("handler: %s\n", handler))
                if handler.test(ud_a["name"], ud_b["name"]) then
                    handler.invoke(fixtureA, fixtureB, contact)
                end
            end -- else print error?
            -- remove from local fixture names copy if matched
            -- if (ud_a ~= nil and ud_b ~= nil) then
            --     for j = #names, 1, -1 do -- todo update to use Contains?
            --         if names[j] == ud_a["name"] or names[j] == ud_b["name"] then
            --             -- should the above the adjustable?
            --             -- eg. handler.test(aName,bName), handler.invoke(a,b,contact)
            --             table.remove(names, j)
            --         end
            --     end
            --     if #names == 0 then
            --         handler(fixtureA, fixtureB, contact)
            --     end
            -- end
        end
        -- do not use contact after this function returns
    end

    return setmetatable({
        world = world,
        handlers = handlers,
        beginContact = beginContact
    }, ContactHandler)
end

return ContactHandler
