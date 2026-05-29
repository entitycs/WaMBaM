BodyBoost = require("player.abilities.boost")
local Abilities = {}
Abilities.__index = Abilities


function Abilities.new()
    local self = setmetatable({
        player = nil,
        boost = nil,
        -- future abilities:
        
    }, Abilities)

    return self
end


function Abilities:load(window, player)
    self.window = window
    self.player = player
    self.boost = BodyBoost.new()
    self.boost:load(player, player.currentState)
end


function Abilities:update(dt)
    if self.boost then
        self.boost:update(dt)
    end
    
end


function Abilities:draw(window)
    self.boost:draw(window)
end


function Abilities:onInput(name, inputValue)
    return self.boost:onInput(name, inputValue)
   -- todo qualifiers for any future ability
end


return Abilities
