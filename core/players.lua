local PlayerProto = require("player.body")

local PlayerManager = {
    players = {

    }
}

function PlayerManager.addPlayer(controller_id)
    local body = PlayerProto.new()
    table.insert(PlayerManager.players, {
        id = #PlayerManager.players + 1,
        controller_id = controller_id,
        body = body
    })
end

function PlayerManager.getPlayer(id)
    return PlayerManager.players[id].body
end

function PlayerManager.getPlayerBody(id)
    local player = PlayerManager.getPlayer(id)
    if not player then return false end
    return player.body
end

function PlayerManager.load(config)
    for i = 1, #PlayerManager.players do
        local player = PlayerManager.players[i].body
        player:load(config)
    end
end

function PlayerManager.update(dt)
    for i = 1, #PlayerManager.players do
        local player = PlayerManager.players[i].body
        player:update(dt)
    end
end

function PlayerManager.draw()
    for i = 1, #PlayerManager.players do
        local player = PlayerManager.players[i].body
        player:draw()
    end
end

return PlayerManager
