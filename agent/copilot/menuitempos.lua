local function getMenuItemPosition(i, images)
    local screenW, screenH = love.graphics.getDimensions()

    -- DPI scales
    local gfxScale = love.graphics.getDPIScale()
    io.write(string.format("gfxScale: %d\n", gfxScale))
    io.write(string.format("screenW, screenH: %d, %d\n", screenW, screenH))
    -- Layout constants (logical units)
    local spacing      = 200 * gfxScale
    local bottomMargin = 90 * gfxScale

    -- Compute cumulative width of all previous items
    local x = 0
    for n = 1, i-1 do
        local img = images[n]
        local s   =1 / img:getDPIScale()
        print("dpi scale << >>")
        print(s)
        x = x + img:getWidth() * s + spacing
    end

    -- Current image size
    local img = images[i]
    local s   =  img:getDPIScale()
    local imgW = img:getWidth()  * s
    local imgH = img:getHeight() * s

    -- Bottom‑aligned Y
    local y = 400

    return x, y
end

return getMenuItemPosition