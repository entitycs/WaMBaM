local Slider = {}
Slider.__index = Slider

function Slider.new(x, y, w, h, min, max, value)
    return setmetatable({
        x = x, y = y, w = w, h = h,
        min = min, max = max,
        value = value or min,
        dragging = false,
    }, Slider)
end

function Slider:getValue()
    return self.value
end

function Slider:setValue(v)
    self.value = math.min(self.max, math.max(self.min, v))
end

function Slider:update(dt)
    if self.dragging then
        local mx = love.mouse.getX()
        local t = (mx - self.x) / self.w
        self:setValue(self.min + t * (self.max - self.min))
    end
end

function Slider:mousepressed(mx, my, button)
    if button == 1 and
       mx >= self.x and mx <= self.x + self.w and
       my >= self.y and my <= self.y + self.h then
        self.dragging = true
    end
end

function Slider:mousereleased(mx, my, button)
    if button == 1 then
        self.dragging = false
    end
end

function Slider:draw()
    -- background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- knob position
    local t = (self.value - self.min) / (self.max - self.min)
    local knobX = self.x + t * self.w

    -- knob
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", knobX - 5, self.y, 10, self.h)

    love.graphics.setColor(1,1,1)
end

return Slider
