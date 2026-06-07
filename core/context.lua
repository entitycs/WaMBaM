local Context = {
    window = {},
    world = nil,

}

function Context.init()
    Context.window.width  = love.graphics.getWidth()
    Context.window.height = love.graphics.getHeight()
    Context.window.left   = 0
    Context.window.top    = 0
    Context.window.right  = Context.window.width
    Context.window.bottom = Context.window.height

    Context.world         = love.physics.newWorld(0, 90, true)

end

return Context
