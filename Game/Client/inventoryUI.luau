-- Important:
-- Items have tag: interactable
-- Snap points have tag: snapPoint
-- Snap points have attribute: location, with a predifined string value like "invnetory" or "1" or "2"...

local plr = game:GetService("Players").LocalPlayer
local LocalInventory = require(plr:WaitForChild("PlayerScripts"):WaitForChild("LocalInventory"))
local inventory = nil
local itemsFrame = script.Parent:WaitForChild("items")

repeat 
	task.wait(0.1) 
	inventory = LocalInventory.GetInventory() 
until inventory ~= nil

local visualEvent = inventory:GetVisualEvent()

local InventoryItem = require(plr:WaitForChild("PlayerScripts"):WaitForChild("InventoryItem"))

-- Updating system for item frames

local functions = {
	update = function(classifier,amount)
		local thisItem = InventoryItem.GetObjectFromClassifier(classifier)
		thisItem:UpdateAmount(amount)
	end,
	remove = function(classifier)
		local thisItem = InventoryItem.GetObjectFromClassifier(classifier)
		thisItem:Remove()
	end,
	add = function(classifier,item)
		local newItem = InventoryItem.new(item,classifier)
		newItem:Instantiate(item)
	end,
}

visualEvent.Event:Connect(function(action: string,classifier: number,info: Item_or_number)
	functions[action](classifier,info)
end)

-- Filtering

local foodB = script.Parent:WaitForChild("foodB")
local itemsB = script.Parent:WaitForChild("itemsB")
local resourcesB = script.Parent:WaitForChild("resourcesB")
local selections = script.Parent:WaitForChild("selections")
local oldState = nil

local batchPerWait = 5
function filter(category)
	local newFilter = {}
	if category == nil then
		newFilter["all"] = true
		for i,v in ipairs(itemsFrame:GetChildren()) do
			if i%batchPerWait == 0 then
				task.wait()
			end
			if v:IsA("ImageLabel") then
				v.Visible = true
			end
		end
	else
		newFilter[category] = true
		for i,v in ipairs(itemsFrame:GetChildren()) do
			if i%batchPerWait == 0 then
				task.wait()
			end
			if v:IsA("ImageLabel") then
				
				local thisFrame = InventoryItem.GetObjectFromFrame(v)
				if thisFrame then
					local thisCategory = thisFrame.Category
					v.Visible = thisCategory == category
				end
			end
		end
	end
	InventoryItem.ChangeFilter(newFilter)
end

function changeState(new)
	if new == oldState then 
		if new ~= nil then
			selections:FindFirstChild(new).Visible = not selections:FindFirstChild(new).Visible
			oldState = nil
			filter(nil)
			return
		else
			return
		end
	end
	if oldState ~= nil then
		selections:FindFirstChild(oldState).Visible = false
	end

	if new ~= nil then
		selections:FindFirstChild(new).Visible = true
	end
	oldState = new
	filter(new)
end
foodB.MouseButton1Up:Connect(function()
	changeState("food")
end)
itemsB.MouseButton1Up:Connect(function()
	changeState("items")
end)
resourcesB.MouseButton1Up:Connect(function()
	changeState("resources")
end)