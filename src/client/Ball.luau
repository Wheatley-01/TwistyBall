local ball = {}
ball.__index = ball

type Ball = {
    Ball: MeshPart,
    TargetPosition: Vector3,
    Heartbeat: RBXScriptConnection,
    LeftClick: RBXScriptConnection,
    UIClick: RBXScriptConnection,
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ballData = require(ReplicatedStorage.Shared.Data.Ball)
local blinkClient = require(ReplicatedStorage.Shared.path.to.client)

local LERP_SPEED = 30

local ballVisual = ReplicatedStorage.Models.Ball
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local deflectButton = playerGui:WaitForChild("Buttons"):WaitForChild("Holder"):WaitForChild("Deflect")
local cooldownEffect = deflectButton:WaitForChild("Cooldown") :: Frame

local lastDeflect = 0

local function deflectBall()
    if tick() - lastDeflect < ballData.CooldownTime then return end
    blinkClient.DeflectBall.Fire()

   -- cooldownEffect:TweenSize(UDim2.new())
end

function ball.Heartbeat(self: Ball, dt: number)
    local alpha = math.min(LERP_SPEED * dt, 1)
    self.Ball.Position = self.Ball.Position:Lerp(self.TargetPosition, alpha)
end

function ball.Update(self: Ball, newPosition: Vector3)
    self.TargetPosition = newPosition
end

function ball.new(spawnPosition: Vector3)
    local self = setmetatable({} :: any, ball) :: Ball
    self.Ball = ballVisual:Clone()
    self.Ball.Position = spawnPosition
    self.Ball.Parent = workspace

    self.Heartbeat = RunService.Heartbeat:Connect(function(dt)
        ball.Heartbeat(self, dt)
    end)

    self.LeftClick = UserInputService.InputBegan:Connect(function(input, gpe)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 or gpe then
            return
        end

        deflectBall()
    end)

    self.UIClick = deflectButton.Activated:Connect(deflectBall)
    return self
end

return ball