local ContactHandler = {}
ContactHandler.__index = ContactHandler
local function contains(t, val)
    for _, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end
-- Add Begin callback
--- func desc
---@param nameFixtureA string
---@param nameFixtureB string
---@param handler function
function ContactHandler:addBegin(nameFixtureA, nameFixtureB, handler)
    print("contact handler: ")
    print("nameFixtureA: ", nameFixtureA)
    print("nameFixtureB: ", nameFixtureB)

    table.insert(self.handlers.begin, { names = { nameFixtureA, nameFixtureB }, handler = handler })
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
        -- local i = 0
        -- if ud_a ~= nil then
        --     for k, v in pairs(ud_a) do
        --         io.write(string.format("key: %s, value: %s\n", k, v))
        --         i = i + 1
        --         if i % 2 == 0 then
        --             io.write(string.format("\n"))
        --         end
        --     end
        -- end
        -- i = 0
        -- if ud_b ~= nil then
        --     for k, v in pairs(ud_b) do
        --         io.write(string.format("key: %s, value: %s\n", k, v))
        --         i = i + 1
        --         if i % 2 == 0 then
        --             io.write(string.format("\n"))
        --         end
        --     end
        -- end
        -- Handle collisions between eg. 'Front' and 'Ball'
        for i, o in pairs(handlers.begin) do
            -- copy fixture names for handler
            local names = { o.names[1], o.names[2] }
            local handler = o.handler
            -- remove from local fixture names copy if matched
            if (ud_a ~= nil and ud_b ~= nil) then
                for j = #names, 1, -1 do
                    if names[j] == ud_a["name"] or names[j] == ud_b["name"] then
                        table.remove(names, j)
                    end
                end
                if #names == 0 then
                    handler(fixtureA, fixtureB, contact)
                end
            end
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
