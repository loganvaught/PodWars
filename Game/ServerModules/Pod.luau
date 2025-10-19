local Pod = {}
Pod.__index = Pod
local Profile = require(game:GetService("ServerStorage"):WaitForChild("Profile"))

local plrToPodRegistry = {
	--[[
	[userId] = Pod
	]]
}
local slotToPodRegistry = {
	--[[
		[slot] = Pod
	]]
}

local activePods = workspace:WaitForChild("podFunctionality"):WaitForChild("activePods")

function Pod.new(userId)
	print("Registering pod for userId: "..tostring(userId))
	local newPod = {}
	setmetatable(newPod,Pod)
	newPod.Active = true
	newPod.Owner = nil
	newPod.UserId = userId
	newPod.Slot = nil
	newPod.Loaded = false
	newPod.Open = false
	newPod.CurrentlyLoading = false
	newPod.PhysicalPod = nil
	newPod.ProxPrompts = {
		--[[example
			[proxPromptName] = proxPrompt
		]]
	}
	newPod.ItemHealths = { -- when implementing this feature in the future, use tags to make sure what parts are part of what groups, so that yu can go through all parts an dmake them go bye bye
		["body"] = 10000,
		["door"] = 5000,	
	}
	newPod.ItemsBySection = {
		["body"] = {},
		["door"] = {},
	}
	newPod.UtilityLevels = {
		["door"] = 0,
		["furnace"] = 0,
		["crafting"] = 0,
	}
	plrToPodRegistry[userId] = newPod

	return newPod
end

function Pod.GetPodFromUserId(userId)
	print("Player UID: "..tostring(userId))
	print("User id of supposed pod: "..tostring(plrToPodRegistry[userId].UserId))
	return plrToPodRegistry[userId]
end
function Pod.GetPodFromSlotNumber(slotNumber) -- will return nil if slot isnt assigned
	return slotToPodRegistry[slotNumber]
end

function Pod:AssignSlot(slot)
	-- ensure the slot isnt taken. if it is taken, return nil? maybe. or just be super secure on the main script
	if self.Slot == nil then
		self.Slot = slot
		slotToPodRegistry[slot] = self
		-- add the unloaded pod skin to hold the place
	end
end

function Pod:OfficializePod(plr,skin)
	print("Officializing pod for: "..plr.Name.." with user id stored as "..tostring(self.UserId))
	if plr.UserId == self.UserId then
		self.Owner = plr
		self:LoadPod(skin,true)
		self.Active = true
	else
		print("What! these are different? weird")
	end
end

function Pod:LoadPod(skin,official)
	repeat task.wait() until self.CurrentlyLoading == false
	self.CurrentlyLoading = true
	local s,e = pcall(function()
		if not self.Owner or skin == "empty" then
			-- loading empty skin
			local skinFolder = workspace:WaitForChild("podSkins"):FindFirstChild("empty")
			if skinFolder then
				-- code to make the code load in the slot
				local slotRoot = workspace:WaitForChild("podFunctionality"):WaitForChild("starterFrames"):FindFirstChild(self.Slot)
				local clonedSkin = skinFolder:Clone()
				clonedSkin:SetPrimaryPartCFrame(slotRoot.CFrame)
				clonedSkin.Name = self.Slot
				-- remove the empty skin if there is one
				local currentSkin = activePods:FindFirstChild(self.Slot)
				if currentSkin then currentSkin:Destroy() end
				clonedSkin.Parent = activePods

				-- XV add other essenial pod startup stuff. What is visible what is not?
				-- What is enabled what is disabled? (prox prompts)
				-- keep in mind that proximity prompts will not work if the game has not begun

				self.PhysicalPod = nil

			else
				self.Owner:Kick("Empty skin doesnt exist.")
			end

		else
			-- loading player skin
			local playerLoadedCorrectly = not self.Owner:FindFirstChild("dontSave")
			if playerLoadedCorrectly then
				if not skin then
					skin = "default"
				end
				local plrSkin = self.Owner:WaitForChild("data"):WaitForChild("skins"):FindFirstChild(skin)
				if plrSkin or skin == "default" and official == true then -- they own the skin they have equipped, or had no skin equipped
					local skinFolder = workspace.podSkins:FindFirstChild(skin)
					if skinFolder then
						-- code to make the code load in the slot
						local slotRoot = workspace.podFunctionality.starterFrames:FindFirstChild(self.Slot)
						local clonedSkin = skinFolder:Clone()
						clonedSkin:SetPrimaryPartCFrame(slotRoot.CFrame)
						clonedSkin.Name = self.Slot
						-- remove the empty skin if there is one
						local currentSkin = activePods:FindFirstChild(self.Slot)
						if currentSkin then currentSkin:Destroy() end

						-- set default transparency and collide values, and also categorizing damage parts
						for _,v in pairs(clonedSkin:GetDescendants()) do
							if v:IsA("BasePart")   then
								if v:GetAttribute("XVTransparency") then
									v.Transparency = v:GetAttribute("XVTransparency")
								end
								if v:GetAttribute("XVCollide") then
									v.CanCollide = v:GetAttribute("XVCollide")
								end
								local section = v:GetAttribute("damageComponent")
								if section then
									table.insert(self.ItemsBySection[section],v)
								end
								if v:GetAttribute("slotNumberBelongs") == "none" then
									v:SetAttribute("slotNumberBelongs",self.Slot)
								end
							elseif v:IsA("ProximityPrompt") then
								self.ProxPrompts[v.Name] = v
							end
						end

						self.PhysicalPod = clonedSkin

						local starterScripts = workspace:WaitForChild("podFunctionality"):WaitForChild("starterScripts")
						clonedSkin.Parent = activePods
						for _,v in pairs(starterScripts:GetChildren()) do
							print(v)
							local clone = v:Clone()
							clone.Parent = clonedSkin
							clone.Enabled = true
						end

						-- XV add other essenial pod startup stuff. What is visible what is not?
						-- What is enabled what is disabled? (prox prompts)
						-- keep in mind that proximity prompts will not work if the game has not begun


					else
						self.Owner:Kick("Skin doesnt exist.")
					end
				else
					-- plr doesnt oown the skin
					self.Owner:Kick("Error when getting skin. You do not own it")
				end
				-- load the entered skin in the slot
				-- ensure the player owns the skin, or else use the default skin
			else
				Pod:Remove()
				Profile.getProfileFromOwner(self.Owner):Remove()
				self.Owner:Kick("Failed to load data for this game. Please rejoin.")
			end
		end
	end)
	self.CurrentlyLoading = false
	if not s then --[[self.Owner:Kick(tostring(e)) ]] print(tostring(e)) end
end

function Pod:GetSpawn()
	if self.PhysicalPod then
		return self.PhysicalPod:FindFirstChild("spawnPoint")
	end
	-- gets the spawn of the pod, used for teleporting players
end

function Pod:Unlock(proxPrompt)
	-- enables proximity prompt. useful when turning ont he door for the first time
	-- toggle the prox prompt to work
	-- prox prompts are all disabled to start with
	if self.ProxPrompts[proxPrompt] then
		self.ProxPrompts[proxPrompt].Enabled = true
	end
end
function Pod:Lock(proxPrompt)
	-- toggle the prox promopt to not work
	if self.ProxPrompts[proxPrompt] then
		self.ProxPrompts[proxPrompt].Enabled = false
	end
end


function Pod:ToggleDoor()
	local doorFolder = self.PhysicalPod:FindFirstChild("door")
	-- makes the door open or close
	if self.Open then
		-- close the door
		for _,v in pairs(doorFolder:FindFirstChild("closed"):GetDescendants()) do
			if v:IsA("BasePart") then
				if  v:GetAttribute("ActiveTransparency") then
					v.Transparency = v:GetAttribute("ActiveTransparency")
				end
				if v:GetAttribute("ActiveCollide") then
					v.CanCollide = v:GetAttribute("ActiveCollide")
				end
			end
		end
		for _,v in pairs(doorFolder:FindFirstChild("open"):GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
				v.CanCollide = false
			end
		end
		self.Open = false
	else-- open the door
		for _,v in pairs(doorFolder.open:GetDescendants()) do
			if v:IsA("BasePart") then
				if  v:GetAttribute("ActiveTransparency") then
					v.Transparency = v:GetAttribute("ActiveTransparency")
				end
				if v:GetAttribute("ActiveCollide") then
					v.CanCollide = v:GetAttribute("ActiveCollide")
				end
			end
		end
		for _,v in pairs(doorFolder.closed:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
				v.CanCollide = false
			end
		end
		self.Open = true
	end
end

function Pod:Destroy()
	-- this will happen when a player has lost.Regularly destroyed parts are just semi transparent?
	-- makes it so that the destroy skin goes, and the pod no longer works
	-- switch to destroyed skin. This will happen when a player has lost
end

function Pod:Remove()
	print("Removing a pod")
	-- erases the pod from existence. 
	if activePods:FindFirstChild(self.Slot) then
		activePods[self.Slot]:Destroy()
	else
		print("Physical pod didnt exist")
	end
	if self.Owner and plrToPodRegistry[self.Owner] then
		plrToPodRegistry[self.Owner] = nil
	end
	if slotToPodRegistry[self.Slot] then
		slotToPodRegistry[self.Slot] = nil
	end
	self.Active = false
end

function Pod:BreakSection(sectionName)
	print("Destroying Section: "..sectionName)
	for _,v in pairs(self.ItemsBySection[sectionName]) do
		print(v)
		v.Transparency = 1
		v.CanCollide = false
	end
end

function Pod:DamageSection(sectionName,amount)
	-- valid section names: body, door
	-- to find a parts damage component, search with tag: damageComponent. if it does not have this tag, it is not damageable
	-- it also must have attribute "damageable" = "pod"

	-- ensure the unit exists
	print("-- Damage Sent --")
	if sectionName == "door" or sectionName == "body" then
		local thisHealth = self.ItemHealths[sectionName]
		if thisHealth > 0 then-- ensure the unit can take damage
			self.ItemHealths[sectionName] -= amount
			if self.ItemHealths[sectionName] <= 0 then
				-- destroy this items groups
				self:BreakSection(sectionName)
			end
		end
	end
end

function Pod:GetUtilityLevel(utility: string) -- "Furnace", "Bench"
	return 10 -- debugging. will change later
	-- used to easily check that the player can craft a certain thing
end
function Pod:GetHealthTable()
	-- returns a list of al the items of the pod and their healths
end

function Pod:IsPlayerInside(): boolean
	if self.Owner then
		local c = self.Owner.Character
		local h = c:FindFirstChild("Humanoid")
		local hrp = c:FindFirstChild("HumanoidRootPart")
		if c and hrp and h and h.Health > 0 then
			-- cast a ray down, check if there is a result and the instance has a tag of the player userid.
			return true
		end
	end
	return false
end


return Pod

-- XV find where kicking player and make sure they are resonsibly removed 