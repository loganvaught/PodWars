-- Script description: Handles client requests to craft

local e = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("craftClient")
local craftDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("craftDatabase"))
local itemDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("itemDatabase"))
local Pod = require(game:GetService("ServerStorage"):WaitForChild("Pod"))
local Inventory = require(game:GetService("ServerStorage"):WaitForChild("Inventory"))

local classDatabase = require(game:GetService("ReplicatedStorage").dictionaries:WaitForChild("classDatabase"))

local limitByPlayer = {
	--[[
		[plr] = {["Iron Pickaxe"] = 0...}
	]]
}

local generalLimitPoints = {}
local generalLimitCooldown = 5
local maxGeneralStrikes = 10
local function addGeneralLimitPoint(plr)
	if not generalLimitPoints[plr] then 
		generalLimitPoints[plr] = 0 
	end
	generalLimitPoints[plr] += 1
	task.wait(generalLimitCooldown)
	generalLimitPoints[plr] -= 1
end
local function addLimitPoint(plr,item,level)
	local cooldown = craftDatabase.metadata[item].cooldownByLevel[level]
	if limitByPlayer[plr] == nil then 
		limitByPlayer[plr] = {} 
	end
	if limitByPlayer[plr][item] then 
		limitByPlayer[plr][item] += 1 
	else 
		limitByPlayer[plr][item] = 1 
	end
	task.wait(cooldown)
	limitByPlayer[plr][item] -= 1
end

local function rateLimitHandler(client,itemName,level)
	if generalLimitPoints[client] ~= nil and generalLimitPoints[client] >= maxGeneralStrikes then return false end -- skip this request, user is rate limmited (general)
	if limitByPlayer[client] and limitByPlayer[client][itemName] and limitByPlayer[client][itemName] >= 2 then return false end -- user is already crafting an item. number is 2 because of possible delay between server and client
	task.spawn(addGeneralLimitPoint,client)
	task.spawn(addLimitPoint,client,itemName,level)
	return true
end

local safetyFunctions = require(game:GetService("ServerStorage"):WaitForChild("dictionaries"):WaitForChild("safetyFunctions"))
local function sendRequest(client,itemName,resourcesHad,levelRequested,playerInventory)
	if rateLimitHandler(client,itemName,levelRequested) == true then -- client is NOT rate limited for this request
		-- inventoryServerEvent:Fire()
		-- resourcesHad has already been checked for proper length, and has verified that all elements are attributed to a resource, and
		-- all resources are present. And has verified all have enough. So, just update the amount.
		local recipe = craftDatabase.recipes[itemName]
		for i,v in pairs(recipe) do
			local object = resourcesHad[i]
			Inventory.UpdateClassifierField(object.Classifier,"Amount",object.Amount - v) -- the resource is updated
		end
		-- the new item is given
		local cooldown = craftDatabase.metadata[itemName].cooldownByLevel[levelRequested]
		task.wait(cooldown) -- begin crafting
		local amountToCraft = craftDatabase.amountPerCraft[itemName]
		if amountToCraft == nil then 
			amountToCraft = 1 
		end
		if classDatabase[itemDatabase[itemName].class].stackable == true then -- is a stackable item
			-- player has item?
			local classifier = playerInventory:GetClassifierOfStackableItem(itemName)
			local itemOf = Inventory.GetObjectFromClassifier(classifier)
			if playerInventory:GetClassifierOfStackableItem(itemName) and itemOf then
				-- player has item, update it
				Inventory.UpdateClassifierField(classifier,"Amount",itemOf.Amount + amountToCraft)
			else
				-- give player item
				playerInventory:AddItem(itemName,amountToCraft)
			end
		else
			playerInventory:AddItem(itemName,amountToCraft)
		end
	end
end
e.OnServerEvent:Connect(function(client,itemName,levelRequested)
	local playerInventory = Inventory.GetInventoryFromPlr(client)
	local playerPod = Pod.GetPodFromUserId(client.UserId)
	-- check for parameter safety
	if itemName and playerPod and playerInventory then -- ensures itemname was entered, and the user was fully ready
		if safetyFunctions.isStringSafe(itemName) 
			and itemDatabase[itemName] 
			and safetyFunctions.isNumberSafe(levelRequested) 
			and craftDatabase.levelItems[levelRequested] then -- most of the request is valid and safe
			-- verifying table safety

			local recipe = craftDatabase.recipes[itemName]
			local passes = true
			local resourcesHad = {}
			for i,v in pairs(recipe) do
				local item = Inventory.GetObjectFromClassifier(playerInventory:GetClassifierOfStackableItem(i))
				if item and item.Amount >= v then
					-- is fine
					resourcesHad[i] = item
				else
					passes = false
					break
				end
			end
			if passes == true then -- player has enough resources
				-- ensure the player has the level requested
				if levelRequested == 0 then -- everyone has level 0
					sendRequest(client,itemName,resourcesHad,levelRequested,playerInventory)
				else
					if playerPod:IsPlayerInside() == true and playerPod:GetUtilityLevel("Bench") >= levelRequested then
						sendRequest(client,itemName,resourcesHad,levelRequested,playerInventory) -- player is accessing a worthy crafting table
					end
				end
			else
				warn("Suspicious request in inventoryClient sent from: "..client.Name..". Player didn't have enough resources.")
			end
		else
			warn("Suspicious request in inventoryClient sent from: "..client.Name..". Blatant malformation of request.")
		end
	end
end)