local LocalInventory = require(script.Parent:WaitForChild("LocalInventory"))
local reps = game:GetService("ReplicatedStorage")
local event = reps:WaitForChild("events"):WaitForChild("inventoryClient")
local plr = game:GetService("Players").LocalPlayer

local inventory = nil -- client local inventory
repeat 
	task.wait() 
until plr and plr.Character

-- repeat until player is ready to ask to make an inventory

local functions = {
	new = function() -- server signaled okay for inventory creation
		inventory = LocalInventory.new()
	end,
	updatePlayer = function(newInventory)
		--[[
			["Food"] = {
				[123123] = Actual Object
			},
			["Independent"] = {},
			["Ranged"] = {},
			["Resource"] = {},
			["Swing"] = {},
		]]
		inventory:Clear()
		for _,v in pairs(newInventory) do
			for a,b in pairs(v) do
				inventory:AddItem(a,b)
			end
		end
	end,
	updatePlayerClassifierWithProperty = function(classifier,property,value)
		inventory.UpdateClassifierField(classifier,property,value)
	end,
	updatePlayerRemoveClassifier = function(classifier)
		inventory:RemoveClassifier(classifier)
	end,
	updatePlayerAddClassifier = function(classifier,item)
		inventory:AddItem(classifier,item)
	end,
	updatePlayerDestroyInventory = function()
		inventory:Destroy()
		inventory = nil
	end,
}

event.OnClientEvent:Connect(function(reason,info)
	if not info then
		info = {} 
	end -- prevents errors in functions with no parameters
	if inventory == nil and reason ~= "new" then
		plr:Kick("Request from server but client inventory was not prepared.")
	else -- inventory was there, or request is a new inventory
		if functions[reason] then
			print("INFO RECEIVED: ")
			print(unpack(info))
			print("Doing: "..tostring(reason))
			functions[reason](unpack(info))
		else
			plr:Kick("Unexpected function reason from server.")
		end
	end
end)

event:FireServer("new") -- Generating inventory for first time