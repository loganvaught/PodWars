-- WORK IN PROGRESS
local Food = {}
Food.__index = Food

local ss = game:GetService("ServerStorage")
local itemModels = ss:WaitForChild("itemModels"):WaitForChild("Food")

function Food.new(owner: Player,foodName: string,foodClassifier: number,startingQuantity: number)
	local newFood = {}
	setmetatable(newFood,Food)
	
	newFood.Class = "Food"
	newFood.Classifier = foodClassifier
	newFood.Amount = startingQuantity
	newFood.Name = foodName
	--[[newFood.Model = itemModels:FindFirstChild(foodClassifier):Clone()
	newFood.Model.Name = foodClassifier
	newFood.Model.Parent = activeModels]]
	newFood.Owner = owner
	
	return newFood
end

function Food:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
end

return Food