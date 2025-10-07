-- WORK IN PROGRESS
local reps = game:GetService("ReplicatedStorage")
local e = reps:WaitForChild("events"):WaitForChild("classEvents"):WaitForChild("Swing")
local Inventory = require(game:GetService("ServerStorage"):WaitForChild("Inventory"))
local rayFunctions = require(reps:WaitForChild("dictionaries"):WaitForChild("rayFunctions"))
local statsDatabase = require(reps:WaitForChild("dictionaries"):WaitForChild("statsDatabase"))
local safetyFunctions = require(game:GetService("ServerStorage"):WaitForChild("dictionaries"):WaitForChild("safetyFunctions"))

local playerCooldownRegistry = {} -- players in cooldown by weapon

function canCooldownThenAdd(plr,weaponName)
	if playerCooldownRegistry[plr] == nil then playerCooldownRegistry[plr] = {} end
	local thisRegistry = playerCooldownRegistry[plr]
	
	if thisRegistry[weaponName] == true then -- cooldown exists
		return false
	else
		thisRegistry[weaponName] = true
		task.spawn(function()
			task.wait()-- wait the weapon cooldown (subtract a little to account for server-client lag. client started counting down earlier)
			thisRegistry[weaponName] = nil
		end)
		return true -- player can swing.
	end
end

e.OnServerEvent:Connect(function(client,weaponClassifier,hitItem)
	print("server receives request.")
	if safetyFunctions.isNumberSafe(weaponClassifier) and hitItem and (hitItem:IsA("BasePart") or hitItem:IsA("MeshPart")) then
		local thisItem = Inventory.GetObjectFromClassifier(weaponClassifier)
		if thisItem and thisItem.Owner == client then -- player has weapon
			if canCooldownThenAdd(client,thisItem.Name) == true then -- player is not in cooldown for this weapon
				-- ensure theres a clear path from humanoid root part to the instance (check center, and the two front sides of the part)
				local plrCharacter = client.Character 
				if plrCharacter then
					local humanoid = plrCharacter:FindFirstChild("Humanoid")
					local hrp = plrCharacter:FindFirstChild("HumanoidRootPart")
					if humanoid and hrp and humanoid.Health > 0 then-- player can do damage, because they exist and are alive.
						print("Final verifiaction step:")
						-- ensure theres a clear path from humanoid root part to the instance (check center, and the two front sides of the part)
						local ignoreParts = {plrCharacter, hitItem, --[[workspace.Terrain]]} -- ignores descendants of the player
						local pointOnes = { -- assuming default huamnoid root part size
							(hrp.CFrame * CFrame.new(1,1,-0.5)).Position, -- top right, front
							(hrp.CFrame * CFrame.new(1,0,-0.5)).Position, -- middle right, front
							(hrp.CFrame * CFrame.new(0,0,-0.5)).Position, -- Center, front
							(hrp.CFrame * CFrame.new(0,1,-0.5)).Position, -- Top center, front
						}
						local canSee = false
						for _,v in pairs(pointOnes) do -- fires horizontal ray at four locations towards part center
							local isVisible = rayFunctions.IsPartTangibleBetweenPoints(v,Vector3.new(hitItem.Position.X, v.Y, hitItem.Position.Z),ignoreParts)
							canSee = isVisible
							if canSee == true then break end
						end
-- XV COME BACK TO LATER: Just finished trying to make so that can pass cansee. I had to disable terrain
-- dont forget to try to rework the module wiring in the Swing modulescript, so that i dont have to weridly require
-- pod and harvestable. 

-- NOTE TO SELF: CURRENTLY when firing canSee rays, fires backwards? 
-- make it so that if a ray is trying to hit a player, cansee doesnt look for the specific item
-- but looks for any part that belongs to the player. this will be in the ignoreparts  list somehow
-- the parent of the hit item? The goal is that cansee doesnt see any other part in the way
-- implement hierarchy traversal in the Swing module to ensure a player is validly detected
-- implement hierarchy traversal in the hitpart to see if it belongs to a player, to exclude the entire character module
						if canSee then
							-- ensure its close enough
							local range = statsDatabase["Swing"][thisItem.Name].range
							if (hrp.Position - hitItem.Position).Magnitude <= range then
								-- fire the object's hit event with the hitItem parameter. it will do all the checks
								print("sending damage")
								thisItem:DamagePart(hitItem)
							end
						end
					end
				end
			end
		end
	end
	-- if damage is possible, resource management will automatically deal it, and possibly grant rewards.
end)