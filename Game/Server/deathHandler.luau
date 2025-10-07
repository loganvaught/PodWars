-- WORK IN PROGRESS
local serverE = game:GetService("ServerStorage"):WaitForChild("serverEvents"):WaitForChild("deathHandler")
local Inventory = require(game:GetService("ServerStorage"):WaitForChild("Inventory"))
local Profile = require(game:GetService("ServerStorage"):WaitForChild("Profile"))
local Pod = require(game:GetService("ServerStorage"):WaitForChild("Pod"))

local inventoryHandlerEvent = game:GetService("ServerStorage"):WaitForChild("serverEvents"):WaitForChild("inventoryServerEvent")

serverE.Event:Connect(function(plr,profile,pod)
	local inventory = Inventory.GetInventoryFromPlr(plr) -- gets rid of player inventory
	if inventory then
		inventory:Destroy()
	end
end)