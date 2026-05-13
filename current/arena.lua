--- Arena 'Model'
local Goals = require("current.goals")

CurrentArena = {
     backdrop = love.graphics.newImage('backdrops/maxresdefault.jpg')
}


function CurrentArena:load(window, world, ballRadius)
    self.backdrop = love.graphics.newImage('backdrops/maxresdefault.jpg')
    Goals:load(window, world, ballRadius * 2)
end


function CurrentArena:draw()
    -- Draw Arena (TODO: FILTERS)
    love.graphics.draw(self.backdrop, 0, 0)
    -- Draw goals
    Goals:draw()

end
