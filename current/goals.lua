local Goal = require("core.goal")
local Goal1 = nil
local Goal2 = nil
local Goals = {}

function Goals:load(window, world, ballSize)
    Goal1 = Goal:new(world, ballSize, window.left + ballSize * 1.16, window.bottom / 3, false) -- Load first goal
    Goal2 = Goal:new(world, ballSize, window.right - ballSize * 1.16, window.bottom / 3, true) -- Load second goal
    Goal1.fixture:setUserData({ name = "Goal1" })
    Goal2.fixture:setUserData({ name = "Goal2" })
end

function Goals:draw()
    if Goal1 ~= nil then Goal1:draw() end -- Draw goals on the screen
    if Goal2 ~= nil then Goal2:draw() end -- Draw goals on the screen

end

return Goals