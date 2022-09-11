return setmetatable({}, {
    __index = function(Self, Index)
        local CachedService = rawget(Self, Index)
        if CachedService then
            return CachedService
        else
            local Service = pcall(game.GetService, game, Index)

            if Service then
                rawset(Self, Index, Service)
                return Service
            else
                warn("Invalid service indexed: " .. tostring(Index))
            end
        end
    end
})