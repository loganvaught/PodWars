-- purpose: To instantiate resource objects assigned to each model in the harvestable folder in workspace.
-- Handles the damaging and the rewarding of resources after harvesting

local harvestables = workspace:WaitForChild("harvestable")
local Harvestable = require(game:GetService("ServerStorage"):WaitForChild("Harvestable"))
local harvestableDatabase = require(game:GetService("ServerStorage"):WaitForChild("dictionaries"):WaitForChild("harvestableDatabase"))
local War = require(game:GetService("ServerStorage"):WaitForChild("War"))
local war = nil

repeat 
	task.wait(0.05) 
	war = War.GetWar() 
until war
repeat 
	task.wait(0.05) 
until war:HasStarted() == true -- wait until war started to register the items

local resourceOn = 1
for _,v in pairs(harvestables:GetChildren()) do
	if harvestableDatabase.baseSizes[v.Name] then
		-- registering with a tag
		v:SetAttribute("classifier",tostring(resourceOn))
		print("Registering.")
		local specialPart = v:FindFirstChild("item")
		local sizeIndex = specialPart.Size.X * specialPart.Size.Y * specialPart.Size.Z
		if specialPart then
			Harvestable.new(v.Name,sizeIndex,v,resourceOn)
		end
		resourceOn += 1
	end
end