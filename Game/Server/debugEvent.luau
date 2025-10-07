-- Script description: For debugging. Will not be part of final product.

local clientEvent = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("debugEvent")
local Inventory = require(game:GetService("ServerStorage"):WaitForChild("Inventory"))

local resourceCache = {}

clientEvent.OnServerEvent:Connect(function(client,request,itemName)
	local clientInv = Inventory.GetInventoryFromPlr(client)
	if clientInv then
		if request == "serverGet" then
			if not resourceCache[client] then
				resourceCache[client] = {}
			end
			-- local classOfItem = Oh no this debugging mode isnt realistic cause in a real environment players will remove
			-- non stackable items but the classifier would be known. the only time it would need to be removed if the tool breaks after
			-- it performs a task (classifier is known) or if the player drops it (classifier is also known)
			if resourceCache[client][itemName] then
				print("PLayer had item")
				-- player already has
				local playerItem = resourceCache[client][itemName]
				resourceCache[client][itemName].Amount += 1
				clientInv.UpdateClassifierField(playerItem.Classifier,"Amount",playerItem.Amount)
			else
				print("Making new item")
				local newItem = clientInv:AddItem(itemName,1)
				resourceCache[client][itemName] = newItem
			end
		elseif request == "reqCraft" then -- requests to craft item name
			print("Request craft is not yet a thing.")
		elseif request == "printInv" then -- prints entire inventory on server output, and client should theoretically print one too
			clientInv:Display()
		elseif request == "serverRemove" then -- removes one of item
			if resourceCache[client][itemName] then
				print("removing one")
				-- player already has
				local playerItem = resourceCache[client][itemName]
				print("Previous amount detected:")
				print(playerItem.Amount)
				resourceCache[client][itemName].Amount -= 1
				clientInv.UpdateClassifierField(playerItem.Classifier,"Amount",playerItem.Amount)
				if playerItem.Amount <= 0 then
					resourceCache[client][itemName] = nil
				end
			else
				print("Silly. You dont have this item")
			end
		end
	end
end)

