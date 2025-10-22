-- To be parented to a tool that is in the players backpack, initially.
local reps = game:GetService("ReplicatedStorage")
local e = reps:WaitForChild("events"):WaitForChild("classEvents"):WaitForChild("Swing")
local rayFunctions = require(reps:WaitForChild("dictionaries"):WaitForChild("rayFunctions"))
local statsDatabase = require(reps:WaitForChild("dictionaries"):WaitForChild("statsDatabase"))
local animations = require(reps.dictionaries:WaitForChild("animationIds"))

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

local humanoid = character:WaitForChild("Humanoid")

-- load the animation
local swingAnimation = Instance.new("Animation",tool)
swingAnimation.AnimationId = animations[localItem.Name].main.id
local swingWaitBeforeDamage = animations[localItem.Name].main.waitBeforeEvent
local swingTrack = humanoid:LoadAnimation(swingAnimation)
swingTrack.Looped = false
swingTrack.Priority = Enum.AnimationPriority.Action

local itemStats = statsDatabase.Swing[localItem.Name]

local busyAnimating = false
local function playAnim() -- Animates the player with the swingTrack animation
	if busyAnimating == false then
		busyAnimating = true
		swingTrack:Play()
		swingTrack.Stopped:Wait()
		busyAnimating = false
	end
end

local debounce = false
tool.Activated:Connect(function()
	task.wait(0.2) -- wind up period
	if debounce == false then
		debounce = true
		print("TOOL ACTIVATED!")
		-- animations and whatnot
		task.spawn(playAnim)
		task.wait(swingWaitBeforeDamage) -- wait before damaging so the swing is at the bottom
		local hit = rayFunctions.FindFirstResultSwungAt(character.HumanoidRootPart,itemStats.range)
		print(hit)
		if hit then
			e:FireServer(tonumber(localItem.Classifier),hit[2],hit[1].Position)
		end
		-- wait for the cooldown period, plus a 0.1 second buffer, and subtract the amount already waited
		-- for the swing to reach the bottom
		task.wait(itemStats.cooldown + 0.1 - swingWaitBeforeDamage)
		debounce = false
	end
end)

tool.Equipped:Connect(function()
	print("TOOL EQUIPPED")
end)

tool.Unequipped:Connect(function()
	print("TOOL UNEQUIPPED")
end)