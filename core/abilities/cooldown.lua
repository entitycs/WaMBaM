local CooldownHandler = {}
CooldownHandler.__index = CooldownHandler

local defaults = {
    value = 1.0,
    drainRate = 0.25,
    regenRate = 0.5,
    cooldownDelay = 2.0,
    draw = function(window, value)
        love.graphics.setColor(0.2, 0.8, 0.3)
        love.graphics.rectangle("fill",
            window.bottom - 200,
            window.bottom - 50,
            100 * value,
            30
        )
        love.graphics.setColor(1, 1, 1)
    end
}


--------------------------------------------------------------------------------
-- New
--------------------------------------------------------------------------------
function CooldownHandler.new()
    local self = setmetatable({
        items = {}
    }, CooldownHandler)
    return self
end

                
--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function CooldownHandler:load(e)
    -- self.items = {}
end


--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function CooldownHandler:update(dt)                 -- help from copilot
    for k, item in pairs(self.items) do
        if type(item) == "table" then
            if item.inputDown and item.value > 0 then
                -- actively boosting
                item.value = item.value - item.drainRate * dt
                if item.value < 0 then item.value = 0 end
                item.cooldownTimer = item.cooldownDelay
            else
                -- not boosting: cooldown first
                if item.cooldownTimer > 0 then
                    item.cooldownTimer = item.cooldownTimer - dt
                else
                    -- cooldown finished: regen
                    item.value = item.value + item.regenRate * dt
                    if item.value > 1 then item.value = 1 end
                end
            end
        end
    end
end


--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function CooldownHandler:draw(window)
    for k, v in pairs(self.items) do
        if type(v) == "table" then
            -- print(k)
            -- print(v.value)
            v.draw(window, v.value)
        end
    end
end


------------------------------------------------
-- setCooldown
------------------------------------------------
function CooldownHandler:setCooldown(name, def)
    -- shallow copy defaults
    local item = {}
    for k, v in pairs(def) do
        item[k] = v
    end
    
    -- applied generally
    item.cooldownTimer = 0
    item.inputDown = false
    -- table.insert(self.items, item)
    self.items[name] = item
    io.write(string.format("setting %s cooldown timer \n", name))
    io.write(string.format("item count: %d \n", #self.items))
    -- io.write(string.format("check: %s \n", self.items["wam"].regenRate))
end


---------------------------------------------------
-- onInput
---------------------------------------------------
function CooldownHandler:onInput(itemName, inputValue)
    local item = self.items[itemName]
    if not item then return false end

    local deadzone = 0.0001
    item.inputDown = inputValue > deadzone

    if item.inputDown and item.value > 0 then
        return true
    end
    return false
end


return CooldownHandler
