--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(ReplicatedStorage.Shared.Data.Types)
local weld = require(ReplicatedStorage.Shared.Util.Weld)

local reference = ReplicatedStorage.Models.Sword
local modules: { [string]: types.Module } = {}


for _, mod in script:GetChildren() do 
    if not mod:IsA("ModuleScript") then continue end
    modules[mod.Name] = require(mod) :: types.Module
end

Players.PlayerAdded:Connect(function(player)
    weld.Weld(player, reference)
end)

modules.Main.Init()