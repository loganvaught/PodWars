 -- Script description: Handles client requests to update inventory, and inventory inintialization.

local e = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("inventoryClient")
local serverE = game:GetService("ServerStorage"):WaitForChild("serverEvents"):WaitForChild("inventoryServerEvent")

local rateLimits = {
	--[[ [plr] = {
		bans = {
			[request] = true
		},
		requestCounts = {
			[request] = 0
		},
	}
	]]
}

-- IMPORTANT: ALL VALID REQUESTS MUST BE ENTERED IN THE FOLLOWING DICTIONARIES

local cooldownsByRequest = { -- how long it takes for a cooldown strike to go away
	["new"] = -1,
	["updatePlayer"] = 30, -- An expensive function. Very occasional to fix any inventory bugs.
}
local maxRequests = { -- max cooldown strikes until you are limited (until strikes goes down below max)
	["new"] = 1,
	["updatePlayer"] = 1,
}

local function rateLimitHandler(client,request)
	local folder = rateLimits[client]
	if not folder then
		rateLimits[client] = {
			bans = {},
			requestCounts = {},
			itemsCrafting = {}
		}
		folder = rateLimits[client]
	end

	if folder.requestCounts[request] ~= nil then
		folder.requestCounts[request] += 1
	else
		folder.requestCounts[request] = 1
	end
	task.spawn(function()
		if cooldownsByRequest[request] ~= -1 then -- request can be cooled down
			task.wait(cooldownsByRequest[request])
			folder.requestCounts[request] -= 1
		end
	end)

	if folder.requestCounts[request] <= maxRequests[request] then
		return true -- user can request it
	end
	return false -- cannot request it
end

local safetyFunctions = require(game:GetService("ServerStorage"):WaitForChild("dictionaries"):WaitForChild("safetyFunctions"))
e.OnServerEvent:Connect(function(client,request,info)
	-- check for parameter safety
	if not info then 
		info = {} 
	end -- avoids errors of when a request doesnt need parameters 
	if safetyFunctions.isStringSafe(request) and cooldownsByRequest[request] then -- request is safe and valid
		if safetyFunctions.isTableSafe(info,safetyFunctions.expectedParametersByProcess[request]) then
			-- Valid request, info might be innacurate
			if rateLimitHandler(client,request) == true then -- client is NOT rate limited for this request
				print("Sending successful request.")
				serverE:Fire("clientRequest",{client,request,info})
			end
		else
			warn("Suspicious request in inventoryClient sent from: "..client.Name)
		end
	else
		warn("Suspicious request in inventoryClient sent from: "..client.Name)
	end
end)