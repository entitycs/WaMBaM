-- Player contact handlers.
--
-- Builds the two `test` / `invoke` pairs the contact dispatcher needs in
-- order to play `wam` on rear-ball contact and `bam` on front-ball contact.
-- The audio assets are loaded once, here, keyed by fixture name.

local Audio = require("core.audio")

local Collisions = {}

--------------------------------------------------------------------------------
-- Build a contact-handler record for one wheel side.
--   side       : "Rear" | "Front"
--   playerId   : numeric id used in fixture UserData names
--   player     : owning Player (provides self:collisionOnEnter and self.audio)
--   fixtureKey : "wam" | "bam" - matches the audio asset key
--------------------------------------------------------------------------------
function Collisions.buildWheelHandler(side, playerId, player, fixtureKey)
    local selfName = side .. playerId
    return {
        test = function(aName, bName)
            local names = { aName, bName }
            if not Pop(names, selfName) then
                return false
            end
            if not Pop(names, "Ball") then
                return false
            end
            return true
        end,
        invoke = function(a, b, contact)
            return player:collisionOnEnter(fixtureKey, b, contact)
        end,
    }
end

--------------------------------------------------------------------------------
-- Load the audio bundle + register both contact handlers on the dispatcher.
--------------------------------------------------------------------------------
function Collisions.load(audio, contactHandler, rearHandler, frontHandler)
    audio:load({ wam = "audio/wam.wav", bam = "audio/bam.wav", score = "audio/score.wav" })
    contactHandler:addBegin(rearHandler)
    contactHandler:addBegin(frontHandler)
end

return Collisions