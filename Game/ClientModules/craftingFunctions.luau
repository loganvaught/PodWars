local craftingFunctions = {}

local ps = game:GetService("Players")
local plr = ps.LocalPlayer
local craftE = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("craftClient")

local craftDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("craftDatabase"))
local itemDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("itemDatabase"))
local localInventory = require(plr:WaitForChild("PlayerScripts"):WaitForChild("LocalInventory"))

local inventory = nil

local craftingMenu = plr:WaitForChild("PlayerGui"):WaitForChild("main"):WaitForChild("canvas"):WaitForChild("craft")
local buttons = craftingMenu:WaitForChild("inner"):WaitForChild("buttons")
local clones = plr:WaitForChild("PlayerGui"):WaitForChild("guiClones")

local resourceTextBoxes = { 
	--[[["Wood"] = {
		{textbox,amount}
	}]]
}

local loadedItems = {} -- list of strings of craftable items loaded already into the frame
local hiddenItems = {}
local visibleItems = {}
local previousLevel = nil

local nameToPanelTable = {}


local localCooldowns = {
	--[[
	["itemName"] = true
	
	]]
}
local function listenForCrafting(craftButton,itemName)
	craftButton.MouseButton1Up:Connect(function()
		if localCooldowns[itemName] == nil then
			local canCraft = true
			local recipe = craftDatabase.recipes[itemName]
			for i,v in pairs(recipe) do -- client side ensuring player can make it
				local classifierOfResource = inventory:GetResourceClassifier(i)
				local amount = inventory:GetAmountOfClassifier(classifierOfResource)
				if amount < v then
					canCraft = false
					break
				end
			end
			if canCraft then
				craftingFunctions.CraftItem(itemName) -- sending the request
			end
		end
	end)
end

local function instantiatePanelForItem(itemName,level)
	-- assume panel will be visible right away
	loadedItems[itemName] = true
	visibleItems[itemName] = true
	-- attach listen for crafting function
	local clonedPanel = clones:WaitForChild("craft"):WaitForChild("item"):Clone()
	local resourceLabel = clones:WaitForChild("craft"):WaitForChild("resource")
	local recipeFrame = clonedPanel:WaitForChild("recipe")
	-- get items in crafting recipe and list them for the item
	for a,b in pairs(craftDatabase.recipes[itemName]) do
		local newResource = resourceLabel:Clone()
		local amount = inventory:GetAmountOfClassifier(inventory:GetResourceClassifier(a))
		newResource.Text = string.format("%s: %d/%d",a,amount,b)
		newResource.TextColor3 = (amount < b) -- just learned how to do this text color trick. colors the txtbox red if cant craft, green if can craft
			and Color3.fromRGB(255, 80, 80)
			or Color3.fromRGB(100, 255, 100)
		newResource.Parent = recipeFrame
		if not resourceTextBoxes[a] then
			resourceTextBoxes[a] = {{newResource,b}}
		else
			table.insert(resourceTextBoxes[a], {newResource,b})
		end
	end
	local itemInfo = itemDatabase[itemName]
	local metaData = craftDatabase.metadata[itemName]
	clonedPanel:WaitForChild("image").Image = itemInfo.image
	clonedPanel:WaitForChild("description").Text = itemInfo.description
	clonedPanel:WaitForChild("title").Text = itemInfo.name
	clonedPanel:WaitForChild("timer").Text = string.format("Cooldown: %ds",metaData.cooldownByLevel[level])
	clonedPanel.Parent = buttons
	listenForCrafting(clonedPanel:WaitForChild("craft"),itemName)

	loadedItems[itemName] = true
	visibleItems[itemName] = true
	nameToPanelTable[itemName] = clonedPanel
end

local function hideItem(itemName) -- hides an item
	if nameToPanelTable[itemName] ~= nil then
		nameToPanelTable[itemName].Visible = false
		visibleItems[itemName] = nil
		hiddenItems[itemName] = true
	end
end

local function visifyItem(itemName) -- makes an item visible
	if nameToPanelTable[itemName] ~= nil then
		nameToPanelTable[itemName].Visible = true
		hiddenItems[itemName] = false
		visibleItems[itemName] = true
	end
end

local function updateItem(itemName,level) -- updates cooldown, resource increases if needed, etc
	local thisPanel = nameToPanelTable[itemName]
	if thisPanel then
		local cooldownText = thisPanel.timer
		local metaData = craftDatabase.metadata[itemName]
		cooldownText.Text = string.format("Cooldown: %ds",metaData.cooldownByLevel[level])
	end
end

craftingFunctions.OpenMenuOfLevel = function(level: number)
	if craftDatabase.levelItems[level] == nil then return end -- Don't do anything: level isnt valid
	if previousLevel == level then
		-- just open the table, level was the same
		craftingMenu.Visible = true
	end
	local itemsCanCraft = craftDatabase.levelItems[level]
	local unsafeItems = {} -- method to ensure visible items not supposed to be there are rid of
	for i,_ in pairs(visibleItems) do
		unsafeItems[i] = true
	end
	-- go through currently loaded items, update them with any updates that arrise from a level change. eg: cooldown. and ensure its visible
	for _,v in pairs(itemsCanCraft) do
		unsafeItems[v] = nil -- item is now safe
		if loadedItems[v] then
			updateItem(v,level)
			if hiddenItems[v] then
				visifyItem(v)
			end
		else
			instantiatePanelForItem(v,level)
		end
	end
	for i,v in pairs(unsafeItems) do
		if v ~= nil then
			hideItem(i)
		end
	end
	previousLevel = level
	craftingMenu.Visible = true
end

local cooldownEvent = Instance.new("BindableEvent")
local function addCooldown(itemName,level) -- XV: What happens when a cooldown is in progress and a person changes their crafting menu?
	local metaData = craftDatabase.metadata[itemName]
	cooldownEvent:Fire(itemName,true,level)
	localCooldowns[itemName] = true
	task.wait(metaData.cooldownByLevel[level])
	cooldownEvent:Fire(itemName,false,level)
	localCooldowns[itemName] = nil
end

cooldownEvent.Event:Connect(function(itemName,isCooldown)
	local panelOf = nameToPanelTable[itemName]
	if panelOf then
		local craftButton = panelOf.craft
		if isCooldown then
			craftButton.Visible = false
		else
			craftButton.Visible = true
		end
	end
end)

craftingFunctions.CraftItem = function(itemName)
	-- ask server to craft
	craftE:FireServer(itemName, previousLevel)
	-- wait cooldown (client side.) since we already check if it can be crafted, assume there will be very few errors where
	-- an improper cooldown is placed for a non-exploiter. real cooldowns are added on serverside anyway.
	addCooldown(itemName, previousLevel)
end

-- Grabbing the players inventory
repeat 
	inventory = localInventory.GetInventory() 
	task.wait(0.1) 
until inventory ~= nil

local throttleEveryXFrames = 5 -- every 5 frames, wait till the next frame to continue
local resourceUpdater = inventory:GetResourceChangedEvent()
resourceUpdater.Event:Connect(function(name,amount)
	if resourceTextBoxes[name] == nil then return end -- resource hasn't been registered by any items ye
	for i,v in ipairs(resourceTextBoxes[name]) do
		if i%throttleEveryXFrames == 0 then
			task.wait()
		end
		-- v[1] is the textbox, v[2] is the amount it needs
		v[1].Text = string.format("%s: %d/%d",name,amount,v[2])
		v[1].TextColor3 = (amount < v[2]) -- just learned how to do this text color trick. colors the txtbox red if cant craft, green if can craft
			and Color3.fromRGB(255, 80, 80)
			or Color3.fromRGB(100, 255, 100)
	end
end)

return craftingFunctions
