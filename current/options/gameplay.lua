local Options = {
    listeners = {},
    gravityMult = 1,
    forceMult = 1,
    cooldown1 = 1,
    cooldown2 = 1,
}


function Options.get(key)
    return Options[key]
end


function Options.set(key, value)
    Options[key] = value
    if Options.listeners[key] then
        for _, fn in ipairs(Options.listeners[key]) do
            fn(value)
        end
    end
end


function Options.onChange(key, fn)
    Options.listeners[key] = Options.listeners[key] or {}
    table.insert(Options.listeners[key], fn)
end


return Options