local safetyFunctions = {
	expectedParametersByProcess = { -- must be indexed in proper array form. 1 -> 2 -> 3...
		--[[
		["example"] = {
			"", 1, true, {"", 1, {""}} ,""
		},
		
		]]
		["new"] = {},
		["updatePlayer"] = {},
	},
	limits = {
		minNumber = 0,
		maxNumber = 9999999999,
		maxStringLength = 50,
	}
}

safetyFunctions.isStringSafe = function(s: string):boolean
	if 
		typeof(s) == "string" and
		#s <= safetyFunctions.limits.maxStringLength and -- string is proper size
		not s:find("[^%w ]")-- string only contains letters and spaces.
	then
		return true
	end
	return false
end

safetyFunctions.isNumberSafe = function(n: number):boolean
	if typeof(n) == "number" and not( n > safetyFunctions.limits.maxNumber or n < safetyFunctions.limits.minNumber ) then -- is a number, and no weird number size
		return true
	end
	return false
end

safetyFunctions.isTableSafe = function(info: table, parameterTable: table): boolean -- requires a parameter table, structured like above in safetyFunctions.expectedParametersByProcess 
	if parameterTable == nil or info == nil or typeof(info) ~= "table" or typeof(parameterTable) ~= "table" then return false end
	local indexOn = 0

	for i,v in pairs(info) do 
		indexOn += 1
		if i ~= indexOn then return false end -- non numerical index
		local expectedType = parameterTable[indexOn]
		if expectedType == nil or v == nil or typeof(v) ~= typeof(expectedType) then -- table is not indexed with proper array form, has extra index, or type doesnt match, or the current item is nil
			return false
		end
		if typeof(v) == "table" then -- need to do another check
			-- note to self: dont worry, should be able to address large embedded tables, because the previous if statement will catch if a table is there and isnt supposed to be
			if safetyFunctions.isTableSafe(v, expectedType) == false then
				return false
			end
			-- table, and all embedded tables past this are safe
		elseif typeof(v) == "number" then
			if safetyFunctions.isNumberSafe(v) == false then
				return false
			end
		elseif typeof(v) == "string" then
			if safetyFunctions.isStringSafe(v) == false then
				return false
			end
		else
			-- safety, just in case it got past here. not a valid type
			return false
		end
	end

	if indexOn ~= #parameterTable then -- catches if there wre less parameters in info than expected
		return false
	end

	return true -- safe
end

safetyFunctions.getDistanceToVerticalBeam = function(instanceOne,instanceBeam)
	-- Assume instanceBeam has a square base
	local x1 = instanceOne.Position.X
	local z1 = instanceOne.Position.Z
	local x2 = instanceBeam.Position.X
	local z2 = instanceBeam.Position.Z
	
	return math.sqrt((x1 - x2)^2 + (z1 - z2)^2) - instanceBeam.Size.X * 0.5
end

safetyFunctions.getVerticalDisplacementWithBeamLength = function(instanceOne,instanceBeam)
	-- This function returns a number that shows how far away a part
	-- (instanceOne, assumed to be a point mass) is vertically from instanceBeam's
	-- lowest or highest points
	-- Assume Y axis is the axis the beam is aligned with
	
	local y1 = instanceOne.Position.Y
	local yLow = instanceBeam.Position.Y - instanceBeam.Size.Y * 0.5
	local yHigh = instanceBeam.Position.Y + instanceBeam.Size.Y * 0.5
	
	if y1 <= yHigh then
		if y1 >= yLow then
			return 0
		else
			return math.abs(y1 - yLow)
		end
	else
		return math.abs(yHigh - y1)
	end
end

return safetyFunctions
