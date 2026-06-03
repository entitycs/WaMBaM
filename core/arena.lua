--- Arena 'Model'
--1780152612.8902
local Arena = {
    floor = {},
    left = {},
    top = {},
    right = {}
}

function Arena:load(window, world)
    self.floor.body = love.physics.newBody(world, 0, 0, "static")
    self.floor.shape = love.physics.newEdgeShape(0, window.bottom - 100, window.right, window.bottom - 100)
    self.floor.fixture = love.physics.newFixture(self.floor.body, self.floor.shape)
    self.floor.fixture:setFriction(2)
    -- left wall

    self.left.body = love.physics.newBody(world, 0, 0, "static")
    self.left.shape = love.physics.newEdgeShape(0, 0, 0, window.bottom)
    self.left.fixture = love.physics.newFixture(self.left.body, self.left.shape)
    self.left.fixture:setRestitution(0)
    self.left.fixture:setFriction(2)
    -- right wall

    self.right.body = love.physics.newBody(world, 0, 0, "static")
    self.right.shape = love.physics.newEdgeShape(window.right, 0, window.right, window.bottom)
    self.right.fixture = love.physics.newFixture(self.right.body, self.right.shape)
    -- ceiling

    self.top.body = love.physics.newBody(world, 0, 0, "static")
    self.top.shape = love.physics.newEdgeShape(0, 0, window.right, 0)
    self.top.fixture = love.physics.newFixture(self.top.body, self.top.shape)
    -- self.top.fixture:setSensor(true)
    self.top.fixture:setFriction(20)
    self.edges = {}
end

function Arena:unload()
    self.top.body:destroy()
    self.right.body:destroy()
    self.left.body:destroy()
    self.floor.body:destroy()
end

function Arena:draw()
    love.graphics.print(self.floor.shape:getPoints(), 50, 100) -- Print text on the screen
    -- Draw floor edge
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setLineWidth(4)
    love.graphics.line(self.floor.shape:getPoints())
    love.graphics.setColor(1, 0, 0)
end

return Arena
