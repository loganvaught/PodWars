-- Script description: Handles client updating inventory, and inventory initialization.

local inventoryEvent = game:GetService("ServerStorage"):WaitForChild("serverEvents"):WaitForChild("inventoryServerEvent")
local clientEvent = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("inventoryClient")
local Inventory = require(game:GetService("ServerStorage"):WaitForChild("Inventory"))

local clientRequestFunctions = { -- do not trust parameters, may be wrong type. Plr is a trustworthy parameter in first slot.
	new = function(plr)
		inventoryEvent:Fire("new",{plr})
	end,
	updatePlayer = function(plr)
		inventoryEvent:Fire("updatePlayer",{plr})
	end,
}

local functions = {
	-- UPDATE FUNCTIONS: TO ONLY UPDATE THE CLIENT WITH GIVEN PARAMETERS
	new = function(plr) -- make a new inventory. To be requested by client
		if Inventory.GetInventoryFromPlr(plr) == nil then
			local newInventory = Inventory.new(plr)
			clientEvent:FireClient(plr,"new")
			if not newInventory then
				warn("Error when instantiating inventory.")
			end
		end
	end,
	updatePlayer = function(plr) -- updates entire player inventory. To be requested by client
		local playerInventory = Inventory.GetInventoryFromPlr(plr)
		if playerInventory then
			local newInventory = {
				["Food"] = {
					--[[
					[123123] = Actual Object
					]]
				},
				["Independent"] = {},
				["Ranged"] = {},
				["Resource"] = {},
				["Swing"] = {},
			}
			for i,v in pairs(playerInventory.Objects) do
				for a,_ in ipairs(v) do
					newInventory[i][a] = playerInventory:GetObjectFromClassifier(a)
				end
			end
			clientEvent:FireClient(plr,"updatePlayer",{newInventory})
		end
	end,
	updatePlayerClassifierWithProperty = function(plr,classifier,property,value) -- To be called from Inventory object directly
		clientEvent:FireClient(plr,"updatePlayerClassifierWithProperty",{classifier,property,value})
	end,

	-- Addition and Removal Update Functions

	updatePlayerRemoveClassifier = function(plr,classifier) -- To be called from Inventory object directly
		clientEvent:FireClient(plr,"updatePlayerRemoveClassifier",{classifier})
	end,

	updatePlayerAddClassifier = function(plr,classifier,item) -- To be called from Inventory object directly
		clientEvent:FireClient(plr,"updatePlayerAddClassifier",{classifier,item})
	end,
	updatePlayerDestroyInventory = function(plr) -- To be called from Inventory object directly, while destroying
		clientEvent:FireClient(plr,"updatePlayerDestroyInventory")
	end,

	-- client function controller
	clientRequest = function(plr,request,info) -- plr parameter trusted. Request parameter was valid. Info not to be trusted, but is a table with valid length for the reason.
		clientRequestFunctions[request](plr,unpack(info))
	end,
}

inventoryEvent.Event:Connect(function(reason,info)
	-- all info[1] in all cases should be a player instance
	if info[1] and info[1]:IsA("Player") and info[1].Parent == game:GetService("Players") then -- player is in game then
		functions[reason](unpack(info))
	end
end)

game:GetService("Players").PlayerRemoving:Connect(function(plr)
	local thisInventory = Inventory.GetInventoryFromPlr(plr)
	if thisInventory then
		thisInventory:Destroy() -- starts chain reaction of inventory getting deleted
	end
end)

-- makes inventories for when they are needed
-- ensures good syncing across client and server
-- ensures inventories are destroyed at proper times

-- removal and addition of items are handled by a different script, that listens to client requests and checks for validity.
-- then, this script will update the client of its new inventory.

-- not update at one time, but update whether certain items were added, or update certain items when amounts change
-- if amounts reach 0, the client will not automatically delete the item. you must send a signal, item = nil