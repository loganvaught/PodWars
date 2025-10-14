local Harvestable = {}
Harvestable.__index = Harvestable
local harvestableDatabase = require(game:GetService("ServerStorage"):WaitForChild("dictionaries"):WaitForChild("harvestableDatabase"))
local Inventory = require(game:GetService("ServerStorage"):WaitForChild("Inventory"))

local harvestableClassifierRegistry = {
	--[classifier] = Harvestable
}

function Harvestable.new(resourceName: string, sizeIndex: number, modelFolder: Folder, classifier: number)
	local newHarvestable = {} 
	setmetatable(newHarvestable,Harvestable)

	newHarvestable.Name = resourceName
	newHarvestable.SizeMultiplier = sizeIndex/harvestableDatabase.baseSizes[resourceName]
	newHarvestable.Model = modelFolder
	newHarvestable.Classifier = classifier
	newHarvestable.Health = math.floor(harvestableDatabase.baseHealth[resourceName] * newHarvestable.SizeMultiplier)
	harvestableClassifierRegistry[classifier] = newHarvestable
	print(typeof(classifier))
	print("was the type")
	newHarvestable.LastPlrDamaged = nil
	--newHarvestable.UpdaterEvent = Instance.new("BindableEvent")

	return newHarvestable
end

function Harvestable.PrintRegistry()
	print(harvestableClassifierRegistry)
end

function Harvestable.GetObjectFromFolder(folder)
	local classifier = folder:GetAttribute("classifier")
	if classifier then
		return harvestableClassifierRegistry[tonumber(classifier)]
	end
end

function Harvestable.GetObjectFromClassifier(classifier)
	return harvestableClassifierRegistry[classifier]
end

function Harvestable:Remove()
	harvestableClassifierRegistry[self.Classifier] = nil
	self.Model:Destroy() -- destroy
	--self.UpdaterEvent:Fire()
	--self.UpdaterEvent:Destroy()
end

function Harvestable:Harvest()
	print("Harvesting.")
	print(self.LastPlrDamaged)
	if self.LastPlrDamaged and self.LastPlrDamaged.Parent == game:GetService("Players") then -- player is in the game
		print("Here1")
		local plrInventory = Inventory.GetInventoryFromPlr(self.LastPlrDamaged)
		if plrInventory ~= nil then
			print("Here!")
			local resourcesToGrant = harvestableDatabase.baseResources[self.Name]
			for i,v in pairs(resourcesToGrant) do -- granting resources
				print(i,v)
				local amount = math.floor(v * self.SizeMultiplier) -- applying multiplier for this resource
				local classifier = plrInventory:GetClassifierOfStackableItem(i)
				local object = Inventory.GetObjectFromClassifier(classifier)
				if object then
					print("Had this object")
					-- player has this stackable resource. update it
					Inventory.UpdateClassifierField(classifier,"Amount",object.Amount + amount)
				else
					print("Did not have this object")
					plrInventory:AddItem(i,amount)
				end
			end
		end
	end
	self:Remove()
end

--[[function Harvestable:GetUpdaterEvent()
	return self.UpdaterEvent
end]]

function Harvestable:Damage(plrFrom,amount)
	if self.Health > 0 then
		self.LastPlrDamaged = plrFrom
		self.Health -= amount
		if self.Health <= 0 then
			self:Harvest()
		end
		print("Item damaged. New health: "..tostring(self.Health))
	end
end

return Harvestable