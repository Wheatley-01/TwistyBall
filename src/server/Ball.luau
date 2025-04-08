local ball = {}
ball.__index = ball

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local blink = require(ReplicatedStorage.Shared.path.to.server)
local ballData = require(ReplicatedStorage.Shared.Data.Ball)
local physics = require(ReplicatedStorage.Shared.Util.Physics)

local deflectingPlayers = {} --i didnt want to do this here
local cooldownPlayers = {}

local UPDATE_FREQUENCY = 50 / 1000
local lastUpdate = 0

type Ball = {
	ServerBall: BasePart,
	Position: Vector3,
	Velocity: Vector3,
	Acceleration: number,
	Target: Model,
	LastDeflect: number,
	Update: (self: Ball, dt: number) -> (),
	Block: (self: Ball) -> (),
	Deflect: (self: Ball) -> (),
	DeflectConnection: () -> (),
}

local ballHitbox = ReplicatedStorage.Models.BallHitbox
local gamePlane = workspace.GameArea

local function getRandomCharacter() : Model
	local player = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
	local character = player.Character or player.CharacterAdded:Wait()

	return character
end

local function checkIfTargetHit(self: Ball) : boolean
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = {self.ServerBall}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local touchingParts = workspace:GetPartsInPart(self.ServerBall, params)

	for _, part in touchingParts do
		if part.Parent ~= self.Target then continue end
		return true
	end

	return false
end

function ball.Deflect(self: Ball)
	if not self.Target.PrimaryPart then return end
	local lookDirection = self.Target.PrimaryPart.CFrame.LookVector.Unit
	
	self.Velocity = ballData.DeflectVelocity * lookDirection * self.Acceleration
	self.Acceleration = self.Acceleration + 0.2

	self.LastDeflect = tick()
end

function ball.Block(self: Ball, player: Player)
	local currentTime = tick()
	if not cooldownPlayers[player.Name] then cooldownPlayers[player.Name] = 0 end
	if currentTime - cooldownPlayers[player.Name] < ballData.CooldownTime then return end

	cooldownPlayers[player.Name] = currentTime
	deflectingPlayers[player.Name] = true

	task.delay(ballData.DeflectTime, function()
		deflectingPlayers[player.Name] = false
	end)
end

function ball.Update(self: Ball, dt: number)
	local hrp = self.Target.PrimaryPart
	if not hrp then
		return
	end

	if checkIfTargetHit(self) then
		if deflectingPlayers[self.Target.Name] then
			deflectingPlayers[self.Target.Name] = false
			self.Deflect(self)
		else
			local humanoid = self.Target:FindFirstChild("Humanoid")
			if not humanoid then return end

			--humanoid.Health = 0
		end
	end

	local targetPosition = hrp.Position
	local acceleration = (targetPosition - self.Position).Unit * ballData.Acceleration * self.Acceleration

	self.ServerBall.Position = self.Position

	if tick() - self.LastDeflect < ballData.DeflectToNormalTime then
		--We want the ball to move in deflect direction without tracking the target hence no acceleration for some time
		self.Position = physics.CalculatePosition(self.Position, self.Velocity, Vector3.zero, dt)
	else
		--We want the ball to move in the direction of the player hence the projection vector
		self.Position = physics.CalculatePosition(self.Position, self.Velocity, acceleration, dt)
		self.Velocity = physics.CalculateVelocity(self.Velocity, acceleration, dt):Dot(acceleration.Unit) * acceleration.Unit
	end

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
	self.Acceleration = 1
	self.Target = getRandomCharacter()

	self.ServerBall.Position = self.Position
	self.ServerBall.Parent = workspace
	self.LastDeflect = 0

	blink.CreateBall.FireAll(self.Position)

	RunService.PostSimulation:Connect(function(dt: number)
		self.Update(self :: Ball, dt)
	end)

	self.DeflectConnection = blink.DeflectBall.On(function(player: Player)
		self.Block(self :: Ball, player)
	end)

	return self
end

return ball
