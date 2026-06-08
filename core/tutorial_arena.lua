--- Arena 'Model'
--1780152612.8902
local TutorialArena = {
    floor = {},
    left = {},
    top = {},
    right = {},
    textbox = {}
}

local function dashedLine(x1, y1, x2, y2, dash, gap)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    local nx, ny = dx / len, dy / len

    local t = 0
    while t < len do
        local sx = x1 + nx * t
        local sy = y1 + ny * t
        local ex = x1 + nx * math.min(t + dash, len)
        local ey = y1 + ny * math.min(t + dash, len)
        love.graphics.line(sx, sy, ex, ey)
        t = t + dash + gap
    end
end

function TutorialArena:randomEdges(window, world, opt)
    local edges = {}
    local count = 6
    local midX = window.right / 2

    for i = 1, count do
        -- Random position on LEFT side only
        local x = math.random(opt.paddingX, midX - opt.paddingX)
        local y = -opt.beginY + math.random(opt.paddingY, window.bottom - opt.paddingY)

        -- Random length and angle
        local length = math.random(opt.minLength, opt.maxLength)
        local angle = math.random() * math.pi / 4


        -- Compute endpoints
        local dx = math.cos(angle) * length / 2
        local dy = math.sin(angle) * length / 2

        -- LEFT EDGE
        local leftBody = love.physics.newBody(world, x, y, "static")
        local leftShape = love.physics.newEdgeShape(-dx, -dy, dx, dy)
        love.physics.newFixture(leftBody, leftShape)

        table.insert(edges, {
            body = leftBody,
            shape = leftShape,
            side = "left",
            x = x,
            y = y,
            angle = angle,
            length = length
        })
        --  1780111767.8787
        -- MIRRORED X POSITION
        local mirroredX  = midX + (midX - x)

        -- To mirror across vertical axis:
        -- flip the X offsets (dx -> -dx), keep dy the same
        local mdx        = -dx
        local mdy        = dy

        local rightBody  = love.physics.newBody(world, mirroredX, y, "static")
        local rightShape = love.physics.newEdgeShape(-mdx, -mdy, mdx, mdy)
        local f          = love.physics.newFixture(rightBody, rightShape)
        f:setFriction(200.0)

        table.insert(edges, {
            body = rightBody,
            shape = rightShape,
            side = "right",
            x = mirroredX,
            y = y,
            -- mirrored angle if you want to store it:
            angle = math.pi - angle,
            length = length
        })
    end
    return edges
end

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function TutorialArena:load(window, world)
    self.textbox = {
        oFont = love.graphics.getFont(),
        font = love.graphics.newFont("fonts/VampiroOne-Regular.ttf", 40)
    }
    local seed = os.time() + love.timer.getTime()
    print("RANDOM SEED: ", seed)
    math.randomseed(os.time() + love.timer.getTime())

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
    self.top.fixture:setSensor(true)
    self.top.fixture:setFriction(20)
    self.edges = {}

    for i = 0, 20 do
        local y = -i * 350 -- each level 350px higher
        local edges =
            self:randomEdges(window, world,
                { beginY = -y, paddingX = 20, paddingY = 20, count = 3, minLength = 30, maxLength = 150 })
        for j = 1, #edges do
            local edge = edges[j]
            table.insert(self.edges, edge)
        end
    end
    -- self.edges = edges
end

function TutorialArena:unload()
    for i = #self.edges, 1, -1 do
        local edge = self.edges[i]
        edge.body:destroy()
        table.remove(self.edges, i)
    end
end

--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function TutorialArena:draw()
    -- Setting the font so that it is used when drawning the string.
    love.graphics.setFont(self.textbox.font)

    -- Draws "Hello world!" at position x: 100, y: 200 with the custom font applied.
    love.graphics.print("Hello world!", 100, 200)
    love.graphics.setFont(self.textbox.oFont)
    love.graphics.print(self.floor.shape:getPoints(), 50, 100) -- Print text on the screen
    -- Draw floor edge
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setLineWidth(4)
    love.graphics.line(self.floor.shape:getPoints())
    love.graphics.setColor(1, 0, 0)

    for _, e in ipairs(self.edges) do
        local x1, y1, x2, y2 = e.body:getWorldPoints(e.shape:getPoints())

        -- Glow pass
        love.graphics.setBlendMode("add")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(10)
        love.graphics.line(x1, y1, x2, y2)
        -- Shadow pass (offset + darker + thicker)
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.setColor(1, 1, 1, .1)
        love.graphics.setLineWidth(18)
        love.graphics.line(x1 + 3, y1 + 3, x2 + 3, y2 + 3)
        -- Core line
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(.1, .1, .1)
        love.graphics.setLineWidth(4)
        dashedLine(x1, y1, x2, y2, 10, 6)

        -- love.graphics.line(e.body:getWorldPoints(e.shape:getPoints()))
    end
end

return TutorialArena
