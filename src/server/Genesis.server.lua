-- (c) 2022 imskyyc
-- This code is a part of the Genesis framework (https://github.com/imskyyc/Genesis) licensed under the MIT license (see LICENSE.lua for details)

-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants --
local This = script
local Container = This.Parent

local Core = Container.Core
local Modules = Container.Modules
local Dependencies = Container.Dependencies

local Shared = ReplicatedStorage.Genesis
local Types = require(Shared.Types)
local Promise = require(Shared.Promise)

local Service = require(Dependencies.Service)
local Genesis: Types.Dictionary<string, any> = {
    Debug = false,
    Shared = Shared,
    Modules = {}
}
local Environment: Types.Dictionary<string, any> = {
    Genesis = Genesis,
    Service = Service
}

-- Setup --

--// Register cores
for _, Child in pairs(Core:GetChildren()) do
    if Child:IsA("ModuleScript") then
        local Core = require(Child)
        local Enabled = not Core.__GENESIS_DISABLED

        if Enabled then
            Core.Load(Environment)
            Core.Load = nil
        end
    end
end

--// Load modules
for _, Child in pairs(Modules:GetChildren()) do
    if Child:IsA("ModuleScript") then
        local Module = require(Child)
        local Enabled = not Module.__GENESIS_DISABLED
        local Dependencies = Module.__GENESIS_DEPENDENCIES

        local LoadModule = function()
            for _, Dependency in ipairs(Dependencies) do
                if not Genesis.Modules[Dependency] then
                    repeat
                        task.wait()
                    until Genesis.Modules[Dependency] ~= nil
                end
            end

            Module.Load(Environment)
        end

        if Enabled then
            task.spawn(LoadModule)
        end
    end
end