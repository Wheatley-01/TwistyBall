--!strict
local buttons = {}

local players = game:GetService("Players")
local TweenService = game:GetService("TweenService")


local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local info = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

--functions

local function getTween(scale : UIScale, size : number) : Tween
	return TweenService:Create(scale, info, {Scale = size})
end

local function handleScaling(btn : GuiButton)
	local scale = Instance.new("UIScale")
	scale.Parent = btn

	btn.MouseEnter:Connect(function()
		getTween(scale, 1.08):Play()
	end)

	btn.MouseLeave:Connect(function()
		getTween(scale, 1):Play()
	end)

	btn.MouseButton1Down:Connect(function()
		getTween(scale, 0.92):Play()
	end)

	btn.MouseButton1Up:Connect(function()
		getTween(scale, 1):Play()
	end)
end

function buttons.Init()
    for _, btn in playerGui:GetDescendants() do
        if not btn:IsA("GuiButton") then continue end
        handleScaling(btn)
    end
    
    playerGui.DescendantAdded:Connect(function(btn)
        if not btn:IsA("GuiButton") then return end
        handleScaling(btn)
    end)
end

return buttons