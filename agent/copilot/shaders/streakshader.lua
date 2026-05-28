local StreakShader = {
    threshold = 200
}
StreakShader.__index = StreakShader

local streakTexture


local function createStreakTexture()
    streakTexture = love.graphics.newCanvas(8, 64)
    love.graphics.setCanvas(streakTexture)
    love.graphics.clear(0,0,0,0)

    for y = 0, 63 do
        local a = 1 - (y / 63)
        love.graphics.setColor(1, 1, 1, a)
        love.graphics.rectangle("fill", 0, y, 8, 1)
    end

    love.graphics.setCanvas()
end


function StreakShader.new(x, y, angle, color)
    local ps = love.graphics.newParticleSystem(streakTexture, 32)
    
    ps:setBufferSize(32)
    ps:setEmissionRate(0)
    ps:setEmitterLifetime(0.5)
    ps:setParticleLifetime(0.25)
    
    ps:setSizes(1.0, 1.0)
    ps:setSizeVariation(1)
    
    ps:setColors(
        color[1], color[2], color[3], 1,
        color[1], color[2], color[3], 0
    )
    
    ps:setSpeed(0, 0)
    ps:setDirection(angle)
    ps:setRotation(angle, angle)

    ps:setSpread(0.1)
    
    ps:setPosition(x, y)
    ps:emit(1)
    
    return setmetatable({ ps = ps, dead = false }, StreakShader)
end


function StreakShader:load()
    -- StreakShader.shader = love.graphics.newShader("agent/copilot/streak.glsl")
    createStreakTexture()
end


function StreakShader:update(dt)
    self.ps:update(dt)
    if self.ps:isStopped() then
        self.dead = true
    end
end

function StreakShader:draw()
    love.graphics.setBlendMode("add")
    love.graphics.draw(self.ps)
    love.graphics.setBlendMode("alpha")
end

return StreakShader
