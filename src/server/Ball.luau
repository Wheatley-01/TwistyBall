local ball = {}
ball.__index = ball

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local blink = require(ReplicatedStorage.Shared.path.to.server)
local ballData = require(ReplicatedStorage.Shared.Data.Ball)
local physics = require(ReplicatedStorage.Shared.Util.Physics)

local blockingPlayers = {} --i didnt want to do this here
local cooldownPlayers = {}

local UPDATE_FREQUENCY = 50 / 1000
local lastUpdate = 0

type Ball = {
	ServerBall: BasePart,
	Position: Vector3,
	Velocity: Vector3,
	Target: Model,
	Update: (self: Ball, dt: number) -> (),
}

local ballHitbox = ReplicatedStorage.Models.BallHitbox
local gamePlane = workspace.GameArea

local function getRandomCharacter(): Model
	local player = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
	local character = player.Character or player.CharacterAdded:Wait()

	return character
end

function ball.Update(self: Ball, dt: number)
	local hrp = self.Target.PrimaryPart
	if not hrp then
		return
	end

	local targetPosition = hrp.Position
	local acceleration = (targetPosition - self.Position).Unit * ballData.Acceleration

	self.Position = physics.CalculatePosition(self.Position, self.Velocity, acceleration, dt)
	self.Velocity = physics.CalculateVelocity(self.Velocity, acceleration, dt):Dot(acceleration.Unit)
		* acceleration.Unit --spent 30 minutes staring at the screen to arrive at this

	self.ServerBall.Position = self.Position

	if tick() - lastUpdate < UPDATE_FREQUENCY then
		return
	end
	blink.UpdateBall.FireAll(self.Position)
	lastUpdate = tick()
end

function ball.new()
	local self = setmetatable({} :: any, ball) :: Ball
	self.ServerBall = ballHitbox:Clone()
	self.Position = gamePlane.Position + Vector3.new(0, ballData.HeightOffset, 0)
	self.Velocity = Vector3.zero
	self.Target = getRandomCharacter()

	self.ServerBall.Position = self.Position
	self.ServerBall.Parent = workspace

	blink.CreateBall.FireAll(self.Position)

	RunService.PostSimulation:Connect(function(dt: number)
		self.Update(self :: Ball, dt)
	end)

	return self
end

return ball
