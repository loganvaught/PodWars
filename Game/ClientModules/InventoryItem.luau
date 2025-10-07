local InventoryItem = {}
InventoryItem.__index = InventoryItem

local cs = game:GetService("CollectionService")
local itemToClone = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("guiClones"):WaitForChild("inventory"):WaitForChild("item")
local itemsFrame = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("main"):WaitForChild("canvas"):WaitForChild("inventory"):WaitForChild("items")
local hotbar =  game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("main"):WaitForChild("canvas"):WaitForChild("hotbar")
local classDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("classDatabase"))
local itemDatabase =  require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("itemDatabase"))
local independentDatabase =require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("independentDatabase")) 

local LocalInventory = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("LocalInventory"))
local useageFunctions = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("useageFunctions"))

-- local functions and variables
local categoriesByClass = { -- to sort items of classes into categories for sorting
	["Food"] = "food",
	["Resource"] = "resources",
	["Swing"] = "items",
	["Independent"] = "items",
	["Ranged"] = "items",
}
local specificCategoriesByName = { -- if an items class doesnt typically identify with it, you can sort it into a different filter category
	["Arrow"] = "items", -- arrows are seens by the game as a resource. people typically see it as an item.
}
local function getCategory(item: Object): string
	local class = item.Class
	return specificCategoriesByName[item] or categoriesByClass[class]
end

local hotbarReference = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("guiClones"):WaitForChild("inventory"):WaitForChild("hotbarReference")
local function conditionForLocation(location: string,frame) -- note: leaves frame invisible to avoid weird transitions.
	frame.Visible = false
	if location ~= "inventory" then
		-- hotbar
		frame.ImageTransparency = 1
		for _,v in pairs(frame:GetChildren()) do
			local reference = hotbarReference:FindFirstChild(v.Name)
			v.Position = reference.Position
			v.Size = reference.Size
			v.Visible = reference.Visible
		end
	else
		-- inventory
		frame.ImageTransparency = 0
		for _,v in pairs(frame:GetChildren()) do
			local reference = itemToClone:FindFirstChild(v.Name)
			v.Position = reference.Position
			v.Size = reference.Size
			v.Visible = reference.Visible
		end
	end
end

-- Object Oriented Functionality

local ClassifierToObjectRegistry = {} -- [Item] = Object
local FrameToObjectRegistry = {}
local ObjectToName = {} -- might be useful for filtering which items should be visible in the future

local pathByLocation = {
	["inventory"] = itemsFrame,
	["1"] = hotbar:WaitForChild("1"),
	["2"] = hotbar:WaitForChild("2"),
	["3"] = hotbar:WaitForChild("3"),
	["4"] = hotbar:WaitForChild("4"),
	["5"] = hotbar:WaitForChild("5"),
}
local locationRegistry = {
	["inventory"] = {
		--[InventoryItem] = true
	},
	["1"] = {},
	["2"] = {},
	["3"] = {},
	["4"] = {},
	["5"] = {},
}

local currentlyFiltering = {
	["all"] = true -- all enabled by default
} -- allowed categories

function InventoryItem.new(itemFor: Item, classifier: number)
	local newItem = {}
	setmetatable(newItem,InventoryItem)
	
	newItem.Category = getCategory(itemFor)
	newItem.Frame = nil
	newItem.DraggableItem = nil -- an indicator that its currently being dragged.
	newItem.Location = nil
	newItem.Terminated = false
	if itemFor.Class == "independent" then
		newItem.Stackable = independentDatabase[itemFor.Name].stackable
	else
		newItem.Stackable = classDatabase[itemFor.Class].stackable
	end
	newItem.Classifier = classifier
	ClassifierToObjectRegistry[classifier] = newItem
	ObjectToName[newItem] = itemFor.Name
	
	return newItem
end

function InventoryItem.GetObjectFromClassifier(classifier)
	print("Searching for calssifier")
	print(ClassifierToObjectRegistry[classifier])
	return ClassifierToObjectRegistry[classifier]
end
function InventoryItem.GetObjectFromFrame(frame)
	return FrameToObjectRegistry[frame]
end
function InventoryItem.ChangeFilter(newFiltering)
	currentlyFiltering = newFiltering
end
function InventoryItem.GetFirstItemInHotbarSlot(n: string)
	for i,_ in pairs(locationRegistry[n]) do
		return i
	end
end

function InventoryItem:Instantiate(itemFor: Item) -- adds the frame to the player inventory
	print("Instantiating.")
	if self.Terminated == false then
		local newItemFrame = itemToClone:Clone()

		newItemFrame.Name = itemFor.Name -- useful for sorting alphabetically

		if self.Stackable then
			newItemFrame:FindFirstChild("quantity").Text = tostring(itemFor.Amount)
		else
			newItemFrame:FindFirstChild("quantity"):Destroy()
		end
		newItemFrame:FindFirstChild("image").Image = itemDatabase[itemFor.Name].image
		newItemFrame:FindFirstChild("title").Text = itemDatabase[itemFor.Name].name
		self.Location = "inventory"
		locationRegistry["inventory"][self] = true
		FrameToObjectRegistry[newItemFrame] = self
		cs:AddTag(newItemFrame,"item")
		self.Frame = newItemFrame
		print("Filtering!")
		print(currentlyFiltering)
		if currentlyFiltering[self.Category] ~= nil or currentlyFiltering["all"] ~= nil then -- item can be shown
			newItemFrame.Visible = true
		else
			newItemFrame.Visible = false
		end
		newItemFrame.Parent = itemsFrame
	end
end

function InventoryItem:UpdateAmount(amount)
	print("updating")
	print(self.Stackable)
	print(self.Frame)
	if self.Stackable == true and self.Frame ~= nil then
		local amountText = self.Frame:FindFirstChild("quantity")
		amountText.Text = tostring(amount)
	end
end

function InventoryItem:Trade(otherItem: InventoryItem) -- self trades spots with other item. Other item will always be in  hotbar
	if self.Frame and otherItem.Frame and self.Location and otherItem.Location then
		local thisParent = self.Frame.Parent
		local thatParent = otherItem.Frame.Parent
		
		locationRegistry[self.Location][self] = nil
		locationRegistry[otherItem.Location][otherItem] = nil
		locationRegistry[otherItem.Location][self] = true
		locationRegistry[self.Location][otherItem] = true
		local oldLocation = self.Location
		self.Location = otherItem.Location
		otherItem.Location = oldLocation
		
		conditionForLocation(self.Location,self.Frame)
		conditionForLocation(otherItem.Location,otherItem.Frame)
		self.Frame.Parent = thatParent
		otherItem.Frame.Parent = thisParent
		
		self.Frame.Visible = true
		print(currentlyFiltering)
		if otherItem.Location == "inventory" then -- visibility filters
			if currentlyFiltering[otherItem.Category] ~= nil or currentlyFiltering["all"] ~= nil then -- item can be shown
				print("OTHER ITEM COULD BE SHOWN!")
				otherItem.Frame.Visible = true
			end
		else
			otherItem.Frame.Visible = true
		end
	end
end

function InventoryItem:Move(location: string)
	if locationRegistry[location][self] == nil then
		-- its not already here
		if location == "inventory" then
			print("Moving to inventory")
			locationRegistry[self.Location][self] = nil
			locationRegistry["inventory"][self] = true
			self.Location = "inventory"
			-- no trading has to be done. but filtering may have to be
			conditionForLocation("inventory",self.Frame)
			if currentlyFiltering[self.Category] ~= nil or currentlyFiltering["all"] ~= nil then -- item can be shown
				self.Frame.Visible = true
			else
				self.Frame.Visible = false
			end
			self.Frame.Parent = pathByLocation["inventory"]
		else
			-- hotbar slot
			print("Adding to hotbar slot: "..location)
			local currentItem = InventoryItem.GetFirstItemInHotbarSlot(location)
			if currentItem then
				self:Trade(currentItem)
			else
				locationRegistry[self.Location][self] = nil
				locationRegistry[location][self] = true
				self.Location = location
				conditionForLocation(location,self.Frame)
				self.Frame.Parent = pathByLocation[location]
				self.Frame.Visible = true
			end
		end
	else
		print("Item was already here.")
	end
end

function InventoryItem:MakeTracer()
	if self.Frame and self.DraggableItem == nil then
		local image = self.Frame:FindFirstChild("image")
		print("Here")
		if image then
			print("Here2")
			local newClone = image:Clone()
			newClone.ZIndex = 10
			self.DraggableItem = newClone
			print("Made tracer.")
			return newClone
		end
	end
end

function InventoryItem:Click()
	local thisItem = LocalInventory.GetObjectFromClassifier(self.Classifier)
	if thisItem then
		if self.Location == "inventory" then
			print("Clicked item in inventory.")
			-- in the future, maybe add a visual that says a description of the item, maybe some stats about the item, and a button that says "equip" and "cancel"
			-- thisItem:LocalClick()
		else -- hotbar click
			print("Clicked item in hotbar.")
			local properties = nil
			if thisItem.Class == "independent" then
				properties = independentDatabase[thisItem.Name]
			else
				properties = classDatabase[thisItem.Class]
			end
			if properties ~= nil then
				if properties.equippable == true then
					-- equip item
					useageFunctions.ToggleEquip(thisItem)
				elseif properties.consumable == true then
					-- will consume the item
					useageFunctions.Consume(thisItem)
				elseif properties.placeable == true then
					-- will prompy to place the item
					useageFunctions.Build(thisItem)
				end
			end
		end
	else
		warn("Attempted to click invalid inventory item.")
	end
end

function InventoryItem:RemoveTracer()
	if self.DraggableItem then
		self.DraggableItem:Destroy()
		self.DraggableItem = nil
	end
end

function InventoryItem:Remove()
	if self.Terminated == true then return end
	self.Terminated = true
	
	if self.Location ~= nil then
		locationRegistry[self.Location][self] = nil
	end
	ObjectToName[self] = nil
	ClassifierToObjectRegistry[self.Classifier] = nil
	
	if self.DraggableItem then 
		self.DraggableItem:Destroy() 
	end
	
	if self.Frame then
		FrameToObjectRegistry[self.Frame] = nil
		self.Frame:Destroy()
	end
end

return InventoryItem
