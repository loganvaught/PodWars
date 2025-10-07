-- WORK IN PROGRESS
local Resource = {}
Resource.__index = Resource

local ss = game:GetService("ServerStorage")
local itemModels = ss:WaitForChild("itemModels"):WaitForChild("Resource")

function Resource.new(owner: Player,resourceName: string,resourceClassifier: number,startingQuantity: number)
	local newResource = {}
	setmetatable(newResource,Resource)
	
	newResource.Class = "Resource"
	newResource.Amount = startingQuantity
	newResource.Classifier = resourceClassifier
	newResource.Name = resourceName
	--[[newResource.Model = itemModels:FindFirstChild(resourceName):Clone()
	newResource.Model.Name = resourceClassifier
	newResource.Model.Parent = activeModels]]
	newResource.Owner = owner
	
	return newResource
end

function Resource:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
end

return Resource