-- Player force / torque / braking math.
--
-- Pure-physics helpers operating on a `player` shaped like:
--   player.rear.body, player.front.body
--   player.currentState.forceValue, .torqueValue, .boostValue, .brakeReleasedThisFrame
--
-- Tuned values are preserved from the original body.lua 1:1.

local Forces = {}

local DEFAULT_LIMITING_VEL = 400
local FRONT_VEL_MULTIPLIER = 2.15  -- magic number preserved

--------------------------------------------------------------------------------
-- Velocity limit check. Returns (limitedX, limitedY) for the given body part.
--------------------------------------------------------------------------------
function Forces.checkLimits(player, bodyPart, limitingVel)
    local curVelX, curVelY = player[bodyPart].body:getLinearVelocity()
    local limitedX = false
    local limitedY = false
    if math.abs(curVelX) + math.abs(curVelY) > limitingVel then
        if math.abs(curVelX) > math.abs(curVelY) then
            limitedX = true
        else
            limitedY = true
        end
    end
    return limitedX, limitedY
end

--------------------------------------------------------------------------------
-- Apply axis input (left/right stick) to either force or torque on the body.
-- Preserves the cross-coupling: torqueY subtracts from forceValue.y (and
-- torqueX from forceValue.x) with the same 0.95 magic number.
--------------------------------------------------------------------------------
function Forces.applyAcceleration(player, axisName, accelerationValue, limitingVel)
    limitingVel = limitingVel or DEFAULT_LIMITING_VEL
    local limitedX, limitedY = Forces.checkLimits(player, "rear", limitingVel)
    local xForce = player.currentState.forceValue.x
    local yForce = player.currentState.forceValue.y

    -- only apply these forces if not already over the normal velocity limits
    if axisName == "leftx" and not limitedX then
        local totalForce = player.rear.force * accelerationValue -- suspect (l/r was doubled)
        totalForce = totalForce * (1 + player.currentState.boostValue)
        xForce = totalForce
    elseif axisName == "lefty" and not limitedY then
        local totalForce = player.rear.force * accelerationValue
        totalForce = totalForce * (1 + player.currentState.boostValue)
        yForce = totalForce
    end
    player.currentState.forceValue.x = xForce
    player.currentState.forceValue.y = yForce

    limitedX, limitedY = Forces.checkLimits(player, "front", limitingVel * FRONT_VEL_MULTIPLIER)
    if axisName == "righty" and not limitedY then
        player.currentState.torqueValue.y = 1 + player.front.torque * accelerationValue
        player.currentState.forceValue.y = player.currentState.forceValue.y - 0.95 * player.currentState.torqueValue.y
    elseif axisName == "rightx" and not limitedX then
        player.currentState.torqueValue.x = 1 + player.front.torque * accelerationValue
        player.currentState.forceValue.x = player.currentState.forceValue.x - 0.95 * player.currentState.torqueValue.x
    end
end

--------------------------------------------------------------------------------
-- Apply brake (or release it on the frame following release).
-- On release, average the front/rear linear velocities (frame-coalesce).
--------------------------------------------------------------------------------
function Forces.applyBraking(player, brakeValue)
    if brakeValue ~= 0 then
        player.currentState.x, player.currentState.y = player.rear.body:getLinearVelocity()
        player.currentState.brakeReleasedThisFrame = true
        player.front:applyBraking(brakeValue)
        player.rear:applyBraking(brakeValue)               -- note, may still be a no-op
    elseif player.currentState.brakeReleasedThisFrame then -- onTriggerRelease(triggerright)
        -- average out front and back velocities over the frame following braking
        player.front:releaseBraking()
        player.rear:releaseBraking()
        local newx, newy = player.rear.body:getLinearVelocity()
        local newx2, newy2 = player.front.body:getLinearVelocity()
        player.rear.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
        player.front.body:setLinearVelocity((newx + newx2) / 2, (newy + newy2) / 2)
        player.currentState.brakeReleasedThisFrame = false
    end
end

return Forces