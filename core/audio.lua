local Audio = {}
Audio.__index = Audio

--------------------------------------------------------------------------------
--- new
--------------------------------------------------------------------------------
function Audio.new()
    local self = setmetatable({
        -- file, type pairs
        wam = {},
        bam = {},
        score = {}
    }, Audio)    
    return self
end    

function Audio:play(sound) 
    love.audio.play(sound)
end

--------------------------------------------------------------------------------
--- load
--------------------------------------------------------------------------------
function Audio:load(sounds)
    self.wam = love.audio.newSource(sounds.wam, "static")
    self.bam = love.audio.newSource(sounds.bam, "static")
    self.score = love.audio.newSource(sounds.score, "static")
end    


return Audio