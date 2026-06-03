local states = require("core.menu.states")
local contents = require("core.menu.contents")
local triggersFactory = require("core.menu.triggers")
-- local graph = require("core.state.graph")

-- Build graph
states.previous = states.landing --[graph.previous]

states.landing.nodes = { states.game, states.arena, states.tutorial, states.confirmExit }
states.arena.nodes = { states.landing }
states.game.nodes = { states.paused }
states.tutorial.nodes = { states.paused }
states.paused.nodes = { states.game, states.landing, states.confirmExit }
states.confirmExit.nodes = { states.exit }

-- Contents
if contents.images then
    for stateName, stateImages in pairs(contents.images) do
        if states[stateName] then
            states[stateName].images = stateImages
        end
    end
end

-- Text (unused)
if contents.text then
    for stateName, stateText in pairs(contents.text) do
        if states[stateName] then
            states[stateName].text = stateText
        end
    end
end

-- Draw Instructions
if contents.drawInstruction then
    for stateName, drawFunc in pairs(contents.drawInstruction) do
        if states[stateName] then
            states[stateName].drawInstruction = drawFunc
        end
    end
end

-- Triggers
local triggers = triggersFactory(states)
for stateName, stateTriggers in pairs(triggers) do
    if states[stateName] then
        states[stateName].trigger = stateTriggers
    end
end

return states