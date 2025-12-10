local rayFunctions = {
	maxRays = 10,
}
local cs = game:GetService("CollectionService")

rayFunctions.VisualizeRay = function(origin, direction, distanceOut, color)
	local rayVisualizer1 = Instance.new("Part")
	rayVisualizer1.CanCollide = false
	rayVisualizer1.Anchored = true
	local target = origin + direction * distanceOut
	rayVisualizer1.Size = Vector3.new(0.1, 0.1, (origin - target).Magnitude) -- thin and long
	rayVisualizer1.CFrame = CFrame.new(origin, target) * CFrame.new(0, 0, -rayVisualizer1.Size.Z / 2)
	rayVisualizer1.Color = color
	cs:AddTag(rayVisualizer1, "rayIgnore")
	rayVisualizer1.Parent = workspace
	task.spawn(function()
		task.wait(3)
		rayVisualizer1:Destroy()
	end)
end

rayFunctions.FindFirstValidCollision = function(
	origin: Vector3,
	direction: Vector3,
	distanceOut: number,
	ignoreTags: { string },
	ignoreParts: { Instance },
	ignoreTransparent: boolean,
	ignoreUncollideable: boolean,
	debugging: boolean
): table
	local params = RaycastParams.new()
	params.IgnoreWater = true
	params.FilterDescendantsInstances = ignoreParts

	if debugging == true then
		rayFunctions.VisualizeRay(origin, direction, distanceOut, Color3.fromRGB(255, 255, 255))
	end

	local iterations = 1
	repeat
		local result = workspace:Raycast(origin, direction * distanceOut, params)
		if result and result.Instance then
			-- ensure that it doesnt have an ignore tag
			local hadIgnoreTag = false
			for _, v in pairs(ignoreTags) do
				if result.Instance:HasTag(v) then
					hadIgnoreTag = true
					break
				end
			end

			local hadBypassTag = cs:HasTag(result.Instance, "rayTouch")

			-- check if is not transparent if ignore transparent is on
			if
				(not (result.Instance.Transparency == 1 and ignoreTransparent == true) and hadIgnoreTag == false)
				or hadBypassTag == true
			then
				-- check if collideable if ignore uncollideable is on, or is a part that belongs to a character that is alive
				if
					not (result.Instance.CanCollide == false and ignoreUncollideable == true)
					or (result.Instance.Parent and result.Instance.Parent:FindFirstChild("Humanoid") and result.Instance.Parent.Humanoid.Health > 0)
					or hadBypassTag
				then
					return { result, params.FilterDescendantsInstances }
				end
			end
			local currentParams = params.FilterDescendantsInstances
			table.insert(currentParams, result.Instance)
			params.FilterDescendantsInstances = currentParams
		else
			-- there was no result
			return { nil, params.FilterDescendantsInstances }
		end
		iterations += 1
	until iterations > 10
	return { nil, params.FilterDescendantsInstances }
end

rayFunctions.FindFirstResultSwungAt = function(hrp: Instance, range: number): RaycastResult
	if
		hrp
		and hrp.Parent
		and hrp.Parent:FindFirstChild("Humanoid")
		and hrp.Parent:FindFirstChild("Humanoid").Health > 0
	then
		local elevation = 1
		for i = 1, 3 do -- the three floors
			local angle = 120 - 10 * i
			for i = 1, 4 do
				local origin = (hrp.CFrame * CFrame.new(1, elevation, -0.5)).Position -- sets the origin at the front right edge of the hrp
				local unitDirection = (hrp.CFrame * CFrame.Angles(0, math.rad(90 - angle), 0)).LookVector
				local hit = rayFunctions.FindFirstValidCollision(
					origin,
					unitDirection,
					range - i / 4,
					{ "rayIgnore" },
					{
						hrp.Parent, --[[workspace.Terrain]]
					},
					true,
					true,
					false
				)

				if hit[1] then
					return hit
				end
				angle -= 30
				task.wait()
			end
			-- fifth ray straight out
			local origin = (hrp.CFrame * CFrame.new(0, elevation, -0.5)).Position -- at the front vertical line
			local unitDirection = hrp.CFrame.LookVector
			local hit = rayFunctions.FindFirstValidCollision(
				origin,
				unitDirection,
				range,
				{ "rayIgnore" },
				{ hrp.Parent },
				true,
				true,
				false
			)
			if hit[1] then
				return hit
			end
			elevation -= 1
		end
		return nil -- no part was found
	end
end

rayFunctions.IsPathBlocked = function(pointOne: Vector3, pointTwo: Vector2, ignoreParts: { Instance }): boolean
	local unit = (pointOne - pointTwo).Unit
	local magnitude = (pointOne - pointTwo).Magnitude
	local result = rayFunctions.FindFirstValidCollision(
		pointOne,
		unit,
		magnitude,
		{ "rayIgnore" },
		ignoreParts,
		true,
		true,
		false
	)[1]

	if result == nil then
		return true -- nothing is in the way
	end

	return false
end

return rayFunctions
