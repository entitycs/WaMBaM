local centerAndScale = require("agent.copilot.centroid")
require("core.utils.table")

local Geometry = {}

function Geometry.build(points, openEdges, scale)
    scale = scale or 1

    -- scale polygon
    local scaled = {}

    -- build edges around goal
    local newPoints = centerAndScale(points, scale)
    local edges = {}

    for i = 1, #newPoints, 2 do
        if not Contains(openEdges, i) then
            local x1 = newPoints[i] * scale
            local y1 = newPoints[i+1] * scale
            local x2 = (newPoints[i+2] or newPoints[1]) * scale
            local y2 = (newPoints[i+3] or newPoints[2]) * scale
            table.insert(edges, {x1, y1, x2, y2})
        end
    end

    return scaled, edges
end

return Geometry
