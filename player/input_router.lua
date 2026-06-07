-- Player input dispatch.
--
-- Replaces the three near-identical onTrigger / onAxis / onTriggerRelease
-- methods with a single :onInput(name, value) that routes to the right place.
-- `value == nil` is treated as a "release" frame for triggers.
--
-- All threshold/routing decisions match the original body.lua 1:1.

local Forces = require("player.forces")

local InputRouter = {}

local TRIGGER_BRAKE = "triggerright"

--------------------------------------------------------------------------------
-- Generic input entry point used by JoystickInput listeners.
---@param value number
---@param name string
--------------------------------------------------------------------------------
function InputRouter.onInput(player, name, value)
    -- Triggers: forward to abilities, then maybe braking.
    if name == TRIGGER_BRAKE then
        player.abilities:onInput(name, value)
        if value and value ~= 0 then
            Forces.applyBraking(player, value)
        elseif player.currentState.brakeReleasedThisFrame then
            -- onTriggerRelease(triggerright): re-applied next frame with value=0
            Forces.applyBraking(player, 0)
        end
        return
    end
    
    -- Axes: cache joystick state for any future use, then apply.
    if name == "rightx" then player.joystickX = value end
    if name == "righty" then player.joystickY = value end
    if name == "leftx" or name == "lefty" or name == "rightx" or name == "righty" then
        Forces.applyAcceleration(player, name, value, player.limitingVel)
        return
    end

    -- Other triggers (boost, wamBoost) go straight to abilities.
    -- if name == "triggerleft" or name == "rightshoulder" then
        player.abilities:onInput(name, value)
        -- return
    -- end
end
    
return InputRouter