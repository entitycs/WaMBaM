--- Arena 'Model'
-- local Goals = require("current.goals.container")

CurrentArena = {
     backdrop = love.graphics.newImage('backdrops/maxresdefault.jpg')
}


function CurrentArena:load(window, world, ballRadius)
    self.backdrop = love.graphics.newImage('backdrops/maxresdefault.jpg')
    self.window = window
    self.width, self.height = self.backdrop:getDimensions()
    self.offset = {x = self.width - self.window.right, y = self.height - self.window.bottom}
    -- Goals:load(window, world, ballRadius * 2)
end


function CurrentArena:draw()
    -- Draw Arena (TODO: FILTERS)
    love.graphics.draw(self.backdrop, -self.offset.x/ 2, -self.offset.y / 2)


end
