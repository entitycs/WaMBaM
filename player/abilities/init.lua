local BodyBoostProto = require("player.abilities.boost")
local Abilities = {}
Abilities.__index = Abilities

--------------------------------------------------------------------------------
--- new
--------------------------------------------------------------------------------
function Abilities.new()
    local self = setmetatable({
        player = nil,
        boost = nil,
        -- future abilities:
        
    }, Abilities)
    
    return self
end

function Abilities:onInput(name, inputValue)
    return self.boost:onInput(name, inputValue)
    -- todo qualifiers for any future ability
end

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function Abilities:load(window, player)
    self.window = window
    self.player = player 
    self.boost = BodyBoostProto.new()
    print("current boost value 2: ", player.currentState.boostValue)

    self.boost:load(self.player, self.player.currentState)
end

--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function Abilities:update(dt)
    if self.boost then
        self.boost:update(dt)
    end
    
end

--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function Abilities:draw(window)
    self.boost:draw(window)
end

return Abilities
