-- WORK IN PROGRESS
local Ranged = {}
Ranged.__index = Ranged

local ss = game:GetService("ServerStorage")
local itemModels = ss:WaitForChild("itemModels"):WaitForChild("Ranged")


function Ranged.new(owner: Player,rangedName: string,rangedClassifier: number)
	local newRanged = {}
	setmetatable(newRanged,Ranged)
	
	newRanged.Class = "Ranged"
	newRanged.Name = rangedName
	newRanged.Classifier = rangedClassifier
	--[[newRanged.Model = itemModels:FindFirstChild(rangedName):Clone()
	newRanged.Model.Name = rangedClassifier
	newRanged.Model.Parent = activeModels]]
	newRanged.Owner = owner
	newRanged.Amount = 1
	
	
	return newRanged
end

function Ranged:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
end

return Ranged