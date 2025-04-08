local main = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ball = require(script.Parent.Ball)
local stateMachine = require(ReplicatedStorage.Shared.Util.StateMachine)

local remotes = ReplicatedStorage.Remotes
local countdown = remotes.Countdown

local gamePlane = workspace.GameArea

local INTERMISSION_TIME = 10
local SPAWN_RADIUS = 40

local timeLeft = INTERMISSION_TIME

local function getVerticesPositions(radius: number, centerPos: Vector3, sides: number)
    local vertices = {}

    for i = 0, sides - 1 do
        local angle = (2 * math.pi / sides) * i
        local x = centerPos.X + radius * math.cos(angle)
        local z = centerPos.Z + radius * math.sin(angle)
        local y = centerPos.Y

        local vertex = Vector3.new(x, y, z)
        table.insert(vertices, vertex)
    end

    return vertices
end

local function onPlayerAdded(player: Player, stateMachine: stateMachine.stateMachine)
    if stateMachine.CurrentState ~= "Intermission" then return end
    countdown:FireClient(player, timeLeft)
end

local function intermission()
    countdown:FireAllClients(INTERMISSION_TIME)

    task.spawn(function()
        task.wait(1)
        timeLeft -= 1
    end)

    timeLeft = INTERMISSION_TIME
end

local function startGame()
    local center = gamePlane.Position + Vector3.new(0, 3, 0)
    local spawnPositions = getVerticesPositions(SPAWN_RADIUS, center, #Players:GetPlayers())

    for i, pos in spawnPositions do
        local nextPlayer = Players:GetPlayers()[i]
        local character = nextPlayer.Character or nextPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character.HumanoidRootPart

        humanoidRootPart.CFrame = CFrame.new(pos, center)
    end

    ball.new()
end

function main.Init()
    local gameStateMachine = stateMachine.Create()
    gameStateMachine:AddState({
        Name = "Intermission",
        OnEnter = intermission,

        OnExit = function()
        
           
        end
    })

    gameStateMachine:AddState({
        Name = "Game",
        OnEnter = startGame,

        OnExit = function()
            --gameStateMachine:Transition("Intermission")
        end
    })

    Players.PlayerAdded:Connect(function(player)
        onPlayerAdded(player, gameStateMachine)
    end)

    while true do
        gameStateMachine:Transition("Intermission")
        task.wait(INTERMISSION_TIME)
        gameStateMachine:Transition("Game")
        task.wait(100)
    end
end

return main