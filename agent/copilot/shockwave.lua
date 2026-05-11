local Shockwave = {}
Shockwave.__index = Shockwave

-- Pre-create the texture ONCE, outside physics callbacks
local shockwaveTexture

function Shockwave:load()
    shockwaveTexture = love.graphics.newCanvas(32, 32)
    love.graphics.setCanvas(shockwaveTexture)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", 16, 16, 16)
    love.graphics.setCanvas()
end
function Shockwave.new(x, y)
    local ps = love.graphics.newParticleSystem(shockwaveTexture, 1)
    -- Create particle system using the prebuilt texture

    ps:setBufferSize(1)
    ps:setEmissionRate(0)
    ps:setEmitterLifetime(1.01)
    ps:setParticleLifetime(1.35)

    ps:setSizes(0.2, 2.5)
    ps:setSizeVariation(1)

    ps:setColors(
        1, 0, 1, 1,
        1, 0, 1, 0
    )

    ps:setSpeed(0, 0)
    ps:setPosition(x, y)
    ps:emit(1)
    local obj = { ps = ps, dead = false }
    local mt = setmetatable(obj, Shockwave)

 

    return obj
    -- return setmetatable({
    --     ps = ps,
    --     dead = false
    -- }, Shockwave)
end

function Shockwave:update(dt)
    self.ps:update(dt)
    if self.ps:isStopped() then
        self.dead = true
    end
end

function Shockwave:draw()
    love.graphics.setBlendMode("alpha")
    -- love.graphics.setBlendMode("add")
    love.graphics.draw(self.ps)
 

end

return Shockwave
