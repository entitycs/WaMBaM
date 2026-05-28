local BodyBoost = {}
BodyBoost.__index = BodyBoost

function BodyBoost.new()
    local self = setmetatable({
        wam = {
            value = 1.0,      -- 1 = full, 0 = empty
            drainRate = 0.5,  -- per second
            regenRate = 0.5, -- per second
            cooldownDelay = 2.0,
            cooldownTimer = 0.0,
            inputDown = false,
            draw = function(window, value)
                print("made it")
                love.graphics.setColor(0.2, 0.8, 0.3)
                love.graphics.rectangle(
                    "fill",
                    window.bottom - 200,
                    window.bottom - 50,
                    100 * value,
                    30
                )
                love.graphics.setColor(1, 1, 1)
            end
        },
        lance = {
            value = 1.0,
            drainRate = 10.0,
            regenRate = 0.1,
            cooldownDelay = 2.0,
            cooldownTimer = 0.0,
            inputDown = false,
            draw = function(window, value)
                love.graphics.setColor(0.8, 0.3, 0.3)
                love.graphics.rectangle(
                    "fill",
                    window.bottom - 100,
                    window.bottom - 50,
                    100 * value,
                    30
                )
                love.graphics.setColor(1, 1, 1)
            end
        }
    }, BodyBoost)
    return self
end

function BodyBoost:onWam(inputValue)
    local bar = self.wam
    local deadzone = 0.0001

    bar.inputDown = inputValue > deadzone
    if bar.inputDown and bar.value > 0 then --and bar.cooldownTimer <= 0 then
        return true
    end
    return false
end


function BodyBoost:onLance(inputValue)
    local bar = self.lance
    local deadzone = 0.0001

    bar.inputDown = inputValue > deadzone
    if bar.inputDown and bar.value > 0 then --and bar.cooldownTimer <= 0 then
        return true
    end
    return false
end

function BodyBoost:load(e)

end

function BodyBoost:update(dt) -- help from copilot
    for k, bar in pairs(self) do
        if type(bar) == "table" then

            if bar.inputDown and bar.value > 0 then
                -- actively boosting
                bar.value = bar.value - bar.drainRate * dt
                if bar.value < 0 then bar.value = 0 end
                bar.cooldownTimer = bar.cooldownDelay

            else
                -- not boosting: cooldown first
                if bar.cooldownTimer > 0 then
                    bar.cooldownTimer = bar.cooldownTimer - dt
                else
                    -- cooldown finished: regen
                    bar.value = bar.value + bar.regenRate * dt
                    if bar.value > 1 then bar.value = 1 end
                end
            end
        end
    end
end


function BodyBoost:draw(window)
    for k, v in pairs(self) do
        if type(v) == "table" then
            print(k)
            print(v.value)
            v.draw(window, v.value)
        end
    end
end

return BodyBoost
