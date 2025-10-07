local LocalInventory = {}
LocalInventory.__index = LocalInventory

local currentInventory = nil

local classifierToItem = {} -- A LARGE important table, linking every [classifier] to the real item
local resourceCache = {} -- Stores [resourceName] = classifier, so that resources are easily grabbable

local cacheUpdater = Instance.new("BindableEvent")
local visibleFeedback = Instance.new("BindableEvent")

local craftDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("craftDatabase"))

function LocalInventory.new()
	if currentInventory == nil then
		local newLocalInventory = {}
		setmetatable(newLocalInventory,LocalInventory)

		newLocalInventory.Objects = {
			["Food"] = {
				-- [classifier] = true -- signifies that a classifier exists
			},
			["Independent"] = {},
			["Ranged"] = {},
			["Resource"] = {},
			["Swing"] = {},
		}
		newLocalInventory.Active = true
		currentInventory = newLocalInventory
		return currentInventory
	end
end

function LocalInventory.GetInventory()
	return currentInventory
end

function LocalInventory.GetObjectFromClassifier(classifier)
	local get = classifierToItem[classifier]
	return get
end

function LocalInventory.GetQuantityOfClassifier(classifier)
	local item = LocalInventory.GetObjectFromClassifier(classifier)
	if item then
		return item.Amount
	else
		return 0
	end
end

function LocalInventory:GetResourceChangedEvent()
	return cacheUpdater
end

function LocalInventory:GetVisualEvent()
	return visibleFeedback
end

--[[function Inventory:HasClassifier(classifier) -- Not good. Use GetOwnerOfClassififer and compare if possible
	for _,v in pairs(self.Objects) do
		for _,b in pairs(v) do
			if b == classifier then
				return true
			end
		end
	end
	return false
end]]

function LocalInventory.UpdateClassifierField(classifier,field,value)
	local get = LocalInventory.GetObjectFromClassifier(classifier)
	if get and get[field] ~= nil then 
		get[field] = value
	end
	if resourceCache[get.Name] ~= nil and field == "Amount" then -- the change was a resource amount
		cacheUpdater:Fire(get.Name,value)
		visibleFeedback:Fire("update",classifier,value)
	end
end

function LocalInventory:AddItem(classifier,item) -- function to add item 
	local class = item.Class
	self.Objects[class][classifier] = true
	classifierToItem[classifier] = item
	-- resoure cache check
	if class == "Resource" then
		resourceCache[item.Name] = classifier
		cacheUpdater:Fire(item.Name,item.Amount)
	end
	visibleFeedback:Fire("add",classifier,item)
end

function LocalInventory:RemoveClassifier(classifier) -- Removes an item from inventory and existence
	local get = LocalInventory.GetObjectFromClassifier(classifier)
	if get then
		if self.Objects[get.Class][classifier] then
			self.Objects[get.Class][classifier] = nil
		end
	end
	if get.Class == "Resource" then
		resourceCache[get.Name] = nil -- remove resource from cache
		cacheUpdater:Fire(get.Name,0)
	end
	classifierToItem[classifier] = nil
	visibleFeedback:Fire("remove",classifier)
end

function LocalInventory:Destroy()
	classifierToItem = {}
	resourceCache = {}
	self.Active = false
end

-- CRAFTING FUNCTIONS

function LocalInventory:GetResourceClassifier(resourceName)
	return resourceCache[resourceName]
end

function LocalInventory:GetAmountOfClassifier(classifier)
	local item = LocalInventory.GetObjectFromClassifier(classifier)
	if item then
		return item.Amount
	else
		return 0
	end
end

function LocalInventory:HasEnoughForCraft(itemName)
	local recipe = craftDatabase.getRecipeOfItem(itemName) -- a table with ["ResourceName" = Amount: number]
	local canCraft = true
	for i,v in pairs(recipe) do
		if self:GetAmountOfClassifier(self:GetResourceClassifier(i)) < v then
			canCraft = false
		end
	end
	return canCraft
end

function LocalInventory:Display() -- debugging thing
	print("---")
	print("--------------------- OBJECT CATEGORIZATION ---------------------")
	for i,v in pairs(self.Objects) do
		print("- "..string.upper(i).." -")
		for a,_ in pairs(v) do
			print(a)
		end
	end
	print("---------------------  CLASSIFIER REGISTRY  ---------------------")
	for i,v in pairs(classifierToItem) do
		print(i..": Name = "..tostring(v.Name)..", Amount: "..tostring(v.Amount)..", Class: "..tostring(v.Class))
	end
	print("---------------------     RESOURCE CACHE    ---------------------")
	for i,v in pairs(resourceCache) do
		print(i.." = "..v)
	end
	print("---")
end

return LocalInventory
