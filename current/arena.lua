--- Arena 'Model'
CurrentArena = {
 
     backdrop = love.graphics.newImage('backdrops/maxresdefault.jpg')
}

function CurrentArena:draw()
    -- Draw Arena (TODO: FILTERS)
    love.graphics.draw(self.backdrop, 0, 0)
end


function CurrentArena:load(window, world)
    self.backdrop = love.graphics.newImage('backdrops/maxresdefault.jpg')
end

