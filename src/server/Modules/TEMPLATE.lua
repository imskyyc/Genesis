local Types = require(game:GetService("ReplicatedStorage").Genesis.Types)
local Genesis, Service = nil

local Module; Module = {
    __GENESIS_DISABLED = true,
    __GENESIS_DEPENDENCIES = {},

    Load = function(Environment)
        Genesis = Environment.Genesis
    end,

    -- Include whatever functions you may need
}

return Module