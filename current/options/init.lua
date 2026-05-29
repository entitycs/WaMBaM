local Options = {
    listeners = {},
    gameplay = require("options.gameplay"),
}

-- todo
function Options.save()
    local encoded = love.data.encode("string", "json", Options)
    love.filesystem.write("options.json", encoded)
end

-- todo
function Options.load()
    local raw = love.filesystem.read("options.json")
    local decoded = love.data.decode("string", "json", raw)
end


function Options.onChange(key, fn)
    Options.listeners[key] = Options.listeners[key] or {}
    table.insert(Options.listeners[key], fn)
end
 

return Options
