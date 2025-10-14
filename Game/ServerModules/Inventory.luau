local Inventory = {}
local ss = game:GetService("ServerStorage")
local itemClasses = ss:WaitForChild("itemClasses")
local serverInventoryHandlerEvent = ss:WaitForChild("serverEvents"):WaitForChild("inventoryServerEvent")

local classes = {
	["Food"] = require(itemClasses:WaitForChild("Food")),
	["Resource"] = require(itemClasses:WaitForChild("Resource")),
	["Ranged"] = require(itemClasses:WaitForChild("Ranged")),
	["Swing"] = require(itemClasses:WaitForChild("Swing")),
	["Independent"] = require(itemClasses:WaitForChild("Independent")),
}
local classDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("classDatabase"))

local itemDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("itemDatabase"))
local independentDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("independentDatabase"))


Inventory.__index = Inventory

local inventoryRegistry = {
	--[[
	
	[plr] = Inventory object
	
	]]
}

local classifierToItem = {} -- A LARGE important table, linking every [classifier] to the real item

--[[
inventory object diagram
Inventory = {
	Player = plr
	["Resource"] = { -- Crafting ingredients
		[12312312] = true, [12312312] = true...
	}
	["Swing"] = { -- Class of items that swing and use rays with properties definable by dictionary
		[123123] = true, [34151] = true,...
	}
	["Independent"] = { -- Class of items with their independent scripts
	
	}
	["Food"] = { -- Class of items used to fuel player metabolism points
	
	}
	["Ranged"] = { -- Class of items that cast long ranged rays with projectiles
	
	}
}
]]

local function isItemStackable(item)
	if item.Class == "independent" then
		return independentDatabase[item.Name].stackable
	else
		return classDatabase[item.Class].stackable
	end
end

function Inventory.new(plr)
	if inventoryRegistry[plr] == nil then
		local newInventory = {}
		setmetatable(newInventory,Inventory)

		newInventory.Player = plr
		newInventory.Objects = {
			["Food"] = {
				-- [classifier] = true -- signifies that a classifier exists
			},
			["Independent"] = {},
			["Ranged"] = {},
			["Resource"] = {},
			["Swing"] = {},
		}
		newInventory.StackableCache = {}
		newInventory.Active = true

		inventoryRegistry[plr] = newInventory

		return newInventory
	end
end

function Inventory.GetInventoryFromPlr(plr)
	return inventoryRegistry[plr]
end

function Inventory.GetObjectFromClassifier(classifier)
	local get = classifierToItem[classifier]
	return get
end

function Inventory.GetQuantityOfClassifier(classifier)
	local item = Inventory.GetObjectFromClassifier(classifier)
	if item then
		return item.Amount
	else
		return 0
	end
end

function Inventory:GetClassifierOfStackableItem(itemName)
	return self.StackableCache[itemName]
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

function Inventory.GetOwnerOfClassififer(classifier)
	local get = Inventory.GetObjectFromClassifier(classifier) 
	if get then
		return get.Owner
	end
	return nil
end

local idOn = 1

local function generateClassifier()
	local newClassifier = idOn
	idOn += 1
	return newClassifier
end

function Inventory.UpdateClassifierField(classifier,field,value)
	local get = Inventory.GetObjectFromClassifier(classifier)
	if get then 
		if classDatabase[get.Class].stackable == false then
			-- special case. Can't update this amount. Its either adding or removal
			warn("Can't update the value on a non-stackable item! Use add and remove instead.")
			return
		end
		if field == "Amount" and value == 0 then
			-- special case. remove it instead of updating it. amount to go to 0
			local playerInventory = Inventory.GetInventoryFromPlr(get.Owner)
			playerInventory:RemoveClassifier(classifier)
		elseif get[field] ~= nil then
			get[field] = value
			serverInventoryHandlerEvent:Fire("updatePlayerClassifierWithProperty",{get.Owner,classifier,field,value})
		end
	end
end

function Inventory:AddItem(itemName,amount) -- function to add item name from item database, and amount. assigns classifiers
	local itemInfo = itemDatabase[itemName] 
	local Class = classes[itemInfo.class]

	-- order = name, classifier, amount, 
	local newClassifier = generateClassifier()
	local newItem = Class.new(self.Player,itemName,newClassifier,amount)

	classifierToItem[newClassifier] = newItem
	self.Objects[itemInfo.class][newClassifier] = true
	serverInventoryHandlerEvent:Fire("updatePlayerAddClassifier",{self.Player,newClassifier,newItem})
	if isItemStackable(newItem) == true then
		-- add to stackable cache
		self.StackableCache[itemName] = newClassifier
	end
	return newItem -- useful little thing
end

function Inventory:RemoveClassifier(classifier) -- Removes an item from its inventory, and existence. XV Can this be improved?
	local get = Inventory.GetObjectFromClassifier(classifier)
	if get then
		if self.Objects[get.Class][classifier] then
			self.Objects[get.Class][classifier] = nil
		end
	end
	get:Destroy()
	classifierToItem[classifier] = nil
	serverInventoryHandlerEvent:Fire("updatePlayerRemoveClassifier",{self.Player,classifier})
	if isItemStackable(get) == true then
		-- remove from stackable cache
		self.StackableCache[classifier] = nil
	end
end

function Inventory:Clear()
	self.Objects = {
		["Food"] = {
			-- [classifier] = true -- signifies that a classifier exists
		},
		["Independent"] = {},
		["Ranged"] = {},
		["Resource"] = {},
		["Swing"] = {},
	}
	classifierToItem = {}
end

function Inventory:Destroy() -- removes inventory
	for _,v in pairs(self.Objects) do
		for a,_ in pairs(v) do
			local thisItem = Inventory.GetObjectFromClassifier(a)
			if thisItem then
				thisItem:Destroy() -- Object oriented function for the items
			end
			classifierToItem[a] = nil -- removing all classifiers that are stored
			inventoryRegistry[self.Player] = nil
		end
	end
	self.Active = false
	serverInventoryHandlerEvent:Fire("updatePlayerDestroyInventory",{self.Player})
end

function Inventory:Display() -- debugging thing
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
	print("---")
end

return Inventory
