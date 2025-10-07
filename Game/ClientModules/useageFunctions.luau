-- used when processing the useage of tools, for example equipping, unequipping, dropping, firing/reloading if applicable, eating if applicable, etc
-- Work in progress
local plr = game:GetService("Players").LocalPlayer
local backpack = plr:WaitForChild("Backpack")

local useageFunctions = {
	hotbarKeys = { -- uipHandler script will handle these.
		["1"] = Enum.KeyCode.One,
		["2"] = Enum.KeyCode.Two,
		["3"] = Enum.KeyCode.Three,
		["4"] = Enum.KeyCode.Four,
		["5"] = Enum.KeyCode.Five,
	},
	buildPreview = {
		Position = nil,
	}
}

local equippedItem = nil

useageFunctions.Equip = function(item)
	equippedItem = item
	
	-- finding it in backpack
	
	local model = backpack:FindFirstChild(item.Classifier)
	if model then
		model.Parent = plr.Character
	end
end
useageFunctions.Unequip = function()
	local model = plr.Character:FindFirstChild(equippedItem.Classifier)
	if model then
		model.Parent = backpack
	end
	equippedItem = nil
end

useageFunctions.ToggleEquip = function(item) -- should only be called on items with classes that are equippable
	print("Toggle equip.")
	if equippedItem ~= nil then
		-- an item is already equipped
		if equippedItem ~= item then -- the classifer was not the equipped item
			useageFunctions.Unequip()
			useageFunctions.Equip(item) -- swap for the new classifier
		else
			useageFunctions.Unequip() -- just uneqip it
		end
	else
		useageFunctions.Equip(item)
	end
end

useageFunctions.Consume = function(item) -- One time consuming of an item, particularly food
	print("Consume!")
end
useageFunctions.Build = function(item) -- Prompts building mode, and the request to build
	print("Build!")
end

useageFunctions.DisplayClassifier = function(classifier)
	-- used to display the classifier under the inventory
end

return useageFunctions
