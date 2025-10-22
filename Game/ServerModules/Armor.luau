-- WORK IN PROGRESS
local Armor = {}
Armor.__index = Armor

local ss = game:GetService("ServerStorage")
local itemModels = ss:WaitForChild("itemModels"):WaitForChild("Armor")
local itemDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("itemDatabase"))

function Armor.new(owner: Player,armorName: string,armorClassifier: number,startingQuantity: number)
	local newArmor = {}
	setmetatable(newArmor,Armor)

	newArmor.Class = "Armor"
	newArmor.Amount = startingQuantity
	newArmor.Classifier = armorClassifier
	newArmor.Name = armorName
	--[[newResource.Model = itemModels:FindFirstChild(resourceName):Clone()
	newResource.Model.Name = resourceClassifier
	newResource.Model.Parent = activeModels]]
	newArmor.Owner = owner
	newArmor.BodyLocation = itemDatabase[armorName].bodyLocation

	return newArmor
end

function Armor:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
end

return Armor