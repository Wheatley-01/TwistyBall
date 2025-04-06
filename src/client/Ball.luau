local ball = {}
ball.__index = ball

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LERP_SPEED = 10

type Ball = {
    Ball: MeshPart,
    TargetPosition: Vector3,
    Heartbeat: RBXScriptConnection,
    LeftClick: RBXScriptConnection,
}

local ballVisual = ReplicatedStorage.Models.Ball

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
    end)

    return self
end

return ball