require("core.utils.input")
local Stages = require("current.stage.registry")
local Stage = require("current.stage")

-- Return a factory function that accepts the states table
return function(states)
    -- Helper function to check input for a state
    local function checkConsumeInput(state)
        return CheckConsumeInput(state)
    end

    return {
        landing = {
            -- called on EVERY state load / entry, not just THIS one's
            onLoad = function(window) end,
            onTest = { function() -- should i automate from nodes? yes
                for k, v in pairs(states.landing.nodes) do
                    -- print("num nodes: ", #states.landing.nodes)
                    if checkConsumeInput(v) then
                        return k
                    end
                end
                return 0
                -- if checkConsumeInput(states.game) then
                --     return 1
                -- end
                -- if checkConsumeInput(states.confirmExit) then
                --     return 2
                -- end
                -- return 0
            end },
            -- called when THIS state is entered (loaded)
            onEnter = function(window, world)
                print("LANDING")
            end
        },

        arena = {
            onTest = { function()
                if checkConsumeInput(states.landing) then
                    return 1
                end
                return 0
            end },
            onEnter = function(window, world)
                print("ARENA!!!")
            end
        },

        game = {
            onTest = { function()
                if checkConsumeInput(states.paused) then
                    return 1
                end
                return 0
            end },
            onEnter = function(window, world, players, contactHandler)
                print("GAME STARTED!!!")
                if Stage and Stage.arena then Stage.arena:unload() end
                local s = Stages.default
                Stage.arena = require(s.module)
                Stage.arena:load(window, world, players, contactHandler)
            end
        },

        tutorial = {
            onTest = { function()
                for k, v in pairs(states.tutorial.nodes) do
                    if checkConsumeInput(v) then
                        return k
                    end
                end
                return 0
            end },
            onEnter = function(window, world, players, contactHandler)
                print("TUTORIAL STARTED!!!")
                if Stage and Stage.arena then Stage.arena:unload() end
                local s = Stages.vertical
                Stage.arena = require(s.module)
                Stage.arena:load(window, world, players, contactHandler)
            end
        },

        paused = {
            onTest = {
                -- resume
                function()
                    for k, v in pairs(states.paused.nodes) do
                        if checkConsumeInput(v) then
                            return k
                        end
                    end
                    return 0
                end
            },
            onEnter = function()
                print("GAME PAUSED!!!")
            end
        },

        confirmExit = {
            onTest = { function()
                for k, v in pairs(states.confirmExit.nodes) do
                    print("node: ", v.title)
                    if checkConsumeInput(v) then
                        return k
                    end
                end
                return 0
            end },
            onEnter = function()
                print("CONFIRM EXIT")
                states.confirmExit.nodes[2] = states.previous
            end
        },

        exit = {
            onTest = { function()
                for k, v in pairs(states.exit.nodes) do
                    print("num nodes: ", #states.exit.nodes)
                    if checkConsumeInput(v) then
                        return k
                    end
                end
                return 0
            end },
            onEnter = function()
                love.event.quit()
            end
        }
    }
end
