-- To be parented to a tool that is in the players backpack, initially.
local reps = game:GetService("ReplicatedStorage")
local e = reps:WaitForChild("events"):WaitForChild("classEvents"):WaitForChild("Swing")
local rayFunctions = require(reps:WaitForChild("dictionaries"):WaitForChild("rayFunctions"))
local statsDatabase = require(reps:WaitForChild("dictionaries"):WaitForChild("statsDatabase"))

local plr = game:GetService("Players").LocalPlayer
local LocalInventory = require(plr:WaitForChild("PlayerScripts"):WaitForChild("LocalInventory"))
local localItem = nil
local tool = script.Parent
repeat 
	print("waiting for client-sided verification of item ownership. Swing 1") 
	task.wait(0.3) 
	localItem = LocalInventory.GetObjectFromClassifier(tonumber(tool.Name)) 
until localItem ~= nil

local character = nil
repeat 
	task.wait(0.3)  
	character = plr.Character 
until character ~= nil

local itemStats = statsDatabase.Swing[localItem.Name]

local debounce = false
tool.Activated:Connect(function()
	task.wait(0.2) -- wind up period
	if debounce == false then
		debounce = true
		print("TOOL ACTIVATED!")
		-- animations and whatnot
		local hit = rayFunctions.FindFirstResultSwungAt(character.HumanoidRootPart,itemStats.range)
		print(hit)
		if hit then
			e:FireServer(tonumber(localItem.Classifier),hit[2],hit[1].Position)
		end
		task.wait(itemStats.cooldown + 0.1)
		debounce = false
	end
end)

tool.Equipped:Connect(function()
	print("TOOL EQUIPPED")
end)

tool.Unequipped:Connect(function()
	print("TOOL UNEQUIPPED")
end)