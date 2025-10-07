-- WORK IN PROGRESS
local Independent = {}
Independent.__index = Independent

local ss = game:GetService("ServerStorage")
local itemModels = ss:WaitForChild("itemModels"):WaitForChild("Independent")


function Independent.new(owner: Player,independentName: string,independentClassifier: number)
	local newIndependent = {}
	setmetatable(newIndependent,Independent)
	
	newIndependent.Class = "Independent"
	newIndependent.Classifier = independentClassifier
	newIndependent.Name = independentName
	--[[newIndependent.Model = itemModels:FindFirstChild(independentName):Clone()
	newIndependent.Model.Name = independentClassifier
	newIndependent.Model.Parent = activeModels]]
	newIndependent.Owner = owner
	newIndependent.Amount = 1
	
	return newIndependent
end

function Independent:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
end


return Independent