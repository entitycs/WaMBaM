-- arena_state.lua -- copilot
local registry = require("current.goals.registry")

local ArenaMenu = {}
ArenaMenu.__index = ArenaMenu


local function drawGoalPreview(module, x, y, w, h)
    -- Get normalized points (ballSize=1 gives normalized shape)
    local base = module.getPoints(1, false)

    -- Compute bounds of normalized shape
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge

    for i = 1, #base, 2 do
        local px = base[i]
        local py = base[i+1]
        if px < minX then minX = px end
        if px > maxX then maxX = px end
        if py < minY then minY = py end
        if py > maxY then maxY = py end
    end

    local shapeW = maxX - minX
    local shapeH = maxY - minY

    -- Scale to fit inside preview box
    local scale = 10
    

    -- Center inside the box
    local cx = (minX + maxX) / 2
    local cy = (minY + maxY) / 2

    local centerX = x + w / 2
    local centerY = y + h / 2

    -- Draw background box
    love.graphics.setColor(0.1, 0.1, 0.1, 0.4)
    love.graphics.rectangle("fill", x, y, w, h, 8, 8)

    -- Draw polygon
    love.graphics.push()
    love.graphics.translate(centerX, centerY)
    love.graphics.scale(scale)
    love.graphics.setColor(1, 0, 0)

    local shifted = {}
    for i = 1, #base, 2 do
        shifted[i]   = base[i]   - cx
        shifted[i+1] = base[i+1] - cy
    end

    love.graphics.polygon("line", shifted)
    love.graphics.pop()

    love.graphics.setColor(1, 1, 1)
end


function ArenaMenu.new(window)
    local keys = {}
    for key, _ in pairs(registry) do
        keys[#keys + 1] = key
    end
    print("YES")
    return setmetatable({
        window = window,
        keys = keys,
        index = 1, -- currently selected goal type
    }, ArenaMenu)
end


function ArenaMenu:update(dt)
    if love.keyboard.isDown("left") then
        self.index = math.max(1, self.index - 1)
    elseif love.keyboard.isDown("right") then
        self.index = math.min(#self.keys, self.index + 1)
    elseif love.keyboard.isDown("up") then
        self.index = math.max(1, self.index - 4)
    elseif love.keyboard.isDown("down") then
        self.index = math.min(#self.keys, self.index + 4)
    end
end


function ArenaMenu:draw()
    if not self.window then return end
    local keys = self.keys
    local count = #keys

    local previewsPerRow = 4
    local margin = 20

    local w = self.window.right
    local h = self.window.bottom

    local boxWidth  = (w - margin * (previewsPerRow + 1)) / previewsPerRow
    local boxHeight = boxWidth * 1.2

    for i = 1, count do
        local col = (i - 1) % previewsPerRow
        local row = math.floor((i - 1) / previewsPerRow)

        local x = margin + col * (boxWidth + margin)
        local y = margin + row * (boxHeight + margin)

        local key = keys[i]
        local module = require(registry[key].module)

        drawGoalPreview(module, x, y, boxWidth, boxHeight)

        -- highlight selected
        if i == self.index then
            love.graphics.setColor(1, 1, 0)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", x, y, boxWidth, boxHeight, 8, 8)
            love.graphics.setLineWidth(1)
            love.graphics.setColor(1, 1, 1)
        end
    end
end

return ArenaMenu

