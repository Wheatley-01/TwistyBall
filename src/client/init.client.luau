--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local blink = require(ReplicatedStorage.Shared.path.to.client)
local types = require(ReplicatedStorage.Shared.Data.Types)

local modules: { [string]: types.Module } = {}
local clientBall = {}

for _, mod in script:GetChildren() do 
    if not mod:IsA("ModuleScript") then continue end
    modules[mod.Name] = require(mod) :: types.Module
end

modules.Main.Init()
modules.Buttons.Init()

blink.CreateBall.On(function(spawnPosition: Vector3)
    clientBall = modules.Ball.new(spawnPosition)
end)

blink.UpdateBall.On(function(newPosition: Vector3)
    modules.Ball.Update(clientBall, newPosition)
end)