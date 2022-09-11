-- (c) 2022 imskyyc
-- This code is a part of the Genesis framework (https://github.com/imskyyc/Genesis) licensed under the MIT license (see LICENSE.lua for details)

local Types = require(game:GetService("ReplicatedStorage").Genesis.Types)
local Genesis, Service = nil

local Remote; Remote = {
    __GENESIS_DISABLED = false,
    __GENESIS_REMOTE_EVENT = nil,
    HookedEvents = {} :: Types.Array<Types.HookedFunction>,

    Load = function(Environment)
        Genesis = Environment.Genesis

        local RemoteEvent = Instance.new("RemoteEvent")
        RemoteEvent.Name = "Genesis"
        RemoteEvent.OnServerEvent:Connect(Remote.OnServerEvent)
        RemoteEvent.Parent = Genesis.Shared.Events

        Environment.Genesis.Remote = Remote
    end,

    Emit = function(Player: string | Player, Event: string, Payload: any) : nil
       local Player = Service.Players:FindFirstChild(tostring(Player))
       assert(Player, "Player cannot be nil: " .. tostring(Player))

       Remote.__GENESIS_REMOTE_EVENT:FireClient(Player, Event, Payload)
    end,

    EmitAll = function(Event: string, Payload: any) : nil
        Remote.__GENESIS_REMOTE_EVENT:FireAllClients(Event, Payload)
    end,

    Listen = function(Event: string, Callback: (Player: Player, Payload: any) -> nil, Yield: boolean?) : Types.HookedFunction
        if not Remote.HookedEvents[Event] then Remote.HookedEvents[Event] = {} end

        local Index = #Remote.HookedEvents[Event] + 1
        local HookedFunction; HookedFunction = {
            __initializer = "server",
            __connected = true,
            __yield = Yield,

            Function = Callback,
            UnHook = function()
                HookedFunction.__connected = false

                local HookedFunction = table.find(Remote.HookedEvents, HookedFunction)
                if HookedFunction then
                    table.remove(Remote.HookedEvents, HookedFunction)
                end
            end
        }

        Remote.HookedEvents[Event][Index] = HookedFunction

        return HookedFunction
    end,

    OnServerEvent = function(Player: Player, Event: string, Payload: any) : nil
        local HookedFunction = Remote.HookedEvents[Event]

        if HookedFunction then
            local Executor = if HookedFunction.__yield then pcall else task.spawn
            Executor(Player, Payload)
        else
            Genesis.Report(
                "Exploit", 
                string.format("Player %s sent an invalid remote command: %s. Payload %s", 
                    tostring(Player), 
                    tostring(Event), 
                    tostring(Payload)
                )
            )
        end
    end
}

return Remote