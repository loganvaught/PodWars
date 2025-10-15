local serverRayFunctions = {}

local rayFunctions = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("rayFunctions"))

serverRayFunctions.GetObstructingParts = function(character: Instance,ignoreParts: {Instance}): Instance
	--[[
	IT IS ASSUMED
	that character has all the necessary parts
	and is considered alive and valid
	
	This function will check across the characters body to their right arm, and to the
	end of the right arm, and returns the first part in the way
	]]
	
	local hrp = character.HumanoidRootPart
	local rightHand = character.RightHand
	
	local center = hrp.CFrame
	local pointOne = center * CFrame.new(1,0.5,0) -- The point at the base of the arm (Roughly)
	local pointTwo = rightHand.CFrame -- The end of the arm
	
	-- Check from center of character to base of arm
	local result = rayFunctions.FindFirstValidCollision(center.Position, (pointOne.Position - center.Position).Unit, 
		(center.Position - pointOne.Position).Magnitude, {}, ignoreParts, true, true, true)

	if result [1] then
		-- There was a part in the way. Return this as a hit
		return result[1].Instance
	end

	-- Check from base of arm to end of arm
	local result2 = rayFunctions.FindFirstValidCollision(pointOne.Position, (pointTwo.Position - pointOne.Position).Unit, 
		(pointOne.Position - pointTwo.Position).Magnitude, {}, ignoreParts, true, true, true)

	if result2[1]  then
		-- There was a part in the way. Return this as a hit
		return result2[1].Instance
	end
	
	return nil -- No obstructing parts
end

serverRayFunctions.GetHitPart = function(playerFrom: Player, ignoreParts: {Instance}, endPosition: Vector3): boolean
	--[[
	
	The client detects when they hit an object, and fires a request to the server.
	This function is used to verify whether that request actually hits an object.

	1) It fires a ray from the players arm to the end position specified, plus 1 stud for network delays.
	
	2) It fires four rays around the center ray described above, 1 distance off from the center ray,
	and also 1 stud farther than the start position. This accounts for network delays as well.
	
	3) If an object is hit, it returns the hit Instance part, which will later be checked for whether
	it is a:
	- Player
	- Damageable structure
	- Resource
	
	Note: Game has to be R15 only, or will have to manually calculate the end point of an arm,
	because this code relies on rightHand.
	
	]]
	
	-- Verify existence of character
	local character = playerFrom.Character
	if not character then
		return nil
	end
	local h = character:FindFirstChild("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local rightHand = character:FindFirstChild("RightHand")
	if not (h and h.Health > 0 and hrp and rightHand) then
		return nil
	end
	
	--[[
		Next, verify validity of given IgnoreParts.
		Assume that the server will only call this function when checking for tangible, collideable parts.
		These are parts that: are not invisible, are collideable, and do not have any special tags telling rays to ignore them
		
		The ignore parts parameter given to this function is not checked for safety
	]]
	
	-- Will return nil at any point if the table is not safe
	if typeof(ignoreParts) == "table" then
		local indexOn = 0
		local newTable = {} -- This table is safe, and will be returned. It is the filtered table.

		for i,v in pairs(ignoreParts) do 
			indexOn += 1 
			if i ~= indexOn then return nil end -- non numerical index. Will not check for hit parts
			
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				if v.Transparency == 1 or v.CanCollide == true then
					table.insert(newTable,v)
				end
			end
			if i >= 10 then -- Will not check more than 10 values. Only 10 are possible assuming regular conditions
				break
			end
		end
		ignoreParts = newTable
	else
		return nil
	end
	
	-- 1)
	
	local startPoint = rightHand.CFrame -- The end of the arm
	
	local result = rayFunctions.FindFirstValidCollision(startPoint.Position, (endPosition - startPoint.Position).Unit, 
		(startPoint.Position - endPosition).Magnitude + 1, {}, ignoreParts, true, true, true)
	if result[1] then
		-- There was a part. Return this as a hit
		return result[1].Instance
	end
	
	-- 2)
	
	local rayOn = 1
	local originalDirection = (endPosition - startPoint.Position).Unit
	local baseCFrame = CFrame.new(endPosition, endPosition + originalDirection) -- Create a cframe facing outward to calculate four surrounding points
	
	local rays = {
		- baseCFrame.RightVector , baseCFrame.RightVector, - baseCFrame.UpVector, baseCFrame.UpVector
	}
	while rayOn <= 4 do
		local newEnd = endPosition + rays[rayOn]
		
		-- 4)
		local result = rayFunctions.FindFirstValidCollision(startPoint.Position, (newEnd - startPoint.Position).Unit, 
			(startPoint.Position - newEnd).Magnitude + 1, {"rayIgnore"}, ignoreParts, true, true, true)
		
		if result[1] then
			return result[1].Instance
		end
		
		rayOn += 1
	end
	
	-- There was no hit part
	
	return nil
end

return serverRayFunctions
