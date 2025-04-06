--!strict
local charCon: RBXScriptConnection
local weldLib = {}

--local functions

local function weld(partA: BasePart, partB: BasePart, offsetCFrame: CFrame)
	partA.CFrame = partB.CFrame * offsetCFrame

	local weldConstraint = Instance.new('WeldConstraint')
	weldConstraint.Part0 = partA
	weldConstraint.Part1 = partB
	weldConstraint.Parent = partA
end

local function charAdded(char: Model, refDummy: Model)
	local weldPart = refDummy:FindFirstChild(refDummy.Name) :: BasePart
	if not weldPart then return end
	weldPart = weldPart:Clone()
    
	local weldTo = char:WaitForChild(weldPart:GetAttribute("WeldTo") :: string) :: BasePart
	if not weldTo then return end
	
	local refPart = refDummy:FindFirstChild(weldTo.Name) :: BasePart
	if not refPart  then return end
	
	local offset = refPart.CFrame:Inverse() * weldPart.CFrame
	weld(weldPart, weldTo, offset)
	
	weldPart.Parent = char
end

--functions

function weldLib.Weld(player: Player, refDummy: Model)
	if charCon then charCon:Disconnect() end
	
	charCon = player.CharacterAdded:Connect(function(char)
		charAdded(char, refDummy)
	end)
	
	if not player.Character then return end
	charAdded(player.Character, refDummy)
end

return weldLib