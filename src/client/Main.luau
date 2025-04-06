--!strict
local main = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage.Remotes
local countdown = remotes.Countdown

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local messageText = playerGui:WaitForChild("Message"):WaitForChild("Label") :: TextLabel

function main.Init()
    countdown.OnClientEvent:Connect(function(timeLeft: number)
        for i = timeLeft, 1, -1 do
            messageText.Text = "Game starting in " .. tostring(i) .. "..."
            task.wait(1)
        end

        messageText.Text = ""
    end)
end

return main