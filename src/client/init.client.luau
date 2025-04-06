--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(ReplicatedStorage.Shared.Data.Types)

local modules: { [string]: types.Module } = {}

for _, mod in script:GetChildren() do 
    if not mod:IsA("ModuleScript") then continue end
    modules[mod.Name] = require(mod) :: types.Module
end

modules.Main.Init()