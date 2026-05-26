local MenuShader = {}
MenuShader.__index = MenuShader

function MenuShader.load()
    MenuShader.shader = love.graphics.newShader("agent/copilot/shaders/desatmini.glsl")
end

function MenuShader:apply(selected)
    if not selected then
        -- self.shader:send("scaleFactor", 0.9)
        self.shader:send("desatAmount", 0.8)
        love.graphics.setShader(self.shader)
        love.graphics.scale(0.9, 0.9)
    else
        love.graphics.setShader()
        love.graphics.scale(1, 1)
    end
end

function MenuShader:draw(image, x, y, selected)
    love.graphics.push()
    love.graphics.translate(x, y)
    self:apply(selected)
    love.graphics.draw(image, 0, 0)
    love.graphics.pop()
    love.graphics.setShader()
end

return MenuShader
