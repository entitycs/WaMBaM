local function polygonCentroid(points)
    local area = 0
    local cx = 0
    local cy = 0
    local n = #points

    local function wrap(i)
        return ((i - 1) % n) + 1
    end

    for i = 1, n, 2 do
        local x1 = points[i]
        local y1 = points[i+1]
        local x2 = points[wrap(i+2)]
        local y2 = points[wrap(i+3)]

        local cross = x1 * y2 - x2 * y1
        area = area + cross
        cx = cx + (x1 + x2) * cross
        cy = cy + (y1 + y2) * cross
    end

    area = area * 0.5
    cx = cx / (6 * area)
    cy = cy / (6 * area)

    return cx, cy
end
 

local function centerAndScale(points, scale)
    local cx, cy = polygonCentroid(points)

    local centered = {}
    for i = 1, #points, 2 do
        centered[i]   = points[i]   - cx
        centered[i+1] = points[i+1] - cy
    end

    local scaled = {}
    for i = 1, #centered, 2 do
        scaled[i]   = centered[i]   * scale + cx
        scaled[i+1] = centered[i+1] * scale + cy
    end

    return scaled
end

return centerAndScale