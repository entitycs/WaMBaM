local BodyBoostProto = require("player.abilities.boost")
local BodyStickyProto = require("player.abilities.sticky")

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
        sticky = nil,
        
    }, Abilities)
    
    return self
end

function Abilities:onInput(name, inputValue)
    self.boost:onInput(name, inputValue)
    -- todo qualifiers for any future ability
    self.sticky:onInput(name, inputValue)
end

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function Abilities:load(window, player)
    self.window = window
    self.player = player 
    self.boost = BodyBoostProto.new()
    self.boost:load(self.player, self.player.currentState)
    self.sticky = BodyStickyProto.new()
    self.sticky:load(self.player, self.player.currentState)
end

--------------------------------------------------------------------------------
--- update
--------------------------------------------------------------------------------
function Abilities:update(dt)
    if self.boost then
        self.boost:update(dt)
    end
    if self.sticky then
        self.sticky:update(dt)
    end
    
end

--------------------------------------------------------------------------------
--- draw
--------------------------------------------------------------------------------
function Abilities:draw(window)
    self.boost:draw()
    self.sticky:draw()
end

return Abilities
