local War = {}
War.__index = War

local warObject = nil

function War.new(profiles)
	print("War instantiated")
	if warObject == nil then
		local newWar = {}
		setmetatable(newWar,War)
		warObject = newWar
		newWar.Started = false
		newWar.Profiles = profiles
		newWar.Prize = #profiles - 1
		
		return newWar
	else
		return nil
	end
end

function War:HasStarted()
	return self.Started
end

function War:BeginGame()
	print("WAR: War begins")
	self.Started = true
	
	local numberAlive = 0
	repeat
		print("war: routine check")
		for _,v in pairs(self.Profiles) do
			if not(v.Player and v.Player.Parent == game:GetService("Players")) then
				-- player should not be in there
				-- a theoretical cause of this is that a player remains in the war after leaving during loading
				print("Funky stuff.")
				v:Remove("left")
				self:RemoveProfile(v,"left") -- At least gets them out of the competition. 
			end
		end
		task.wait(5)
		-- conduct a routine checkup to ensure anyone not in the game's profile is not participating
		numberAlive = #self.Profiles
	until numberAlive <= 1
	
	local playerAlive = nil
	
	-- EndGame() endgame end game Ending
	
	for _,v in pairs(self.Profiles) do
		if playerAlive == nil and v.Player and v.Player.Parent == game:GetService("Players") then
			playerAlive = v 
		else
			v:Kick("An error occured when deciding upon a winner. You have not received a victory.")
		end
	end
	
	if playerAlive then
		print(playerAlive.Player.Name.." is the winner, with a prize pool of: "..tostring(self.Prize))
		
		playerAlive:Remove("won")
		-- REWARD BONUS FOR PLAYER ALIVE
	end
	
	task.wait(10)
	
	-- teleport everyone in the game back
end

function War:BeginMetabolism()
	print("Metabolism starting.")
	for _,v in pairs(self.Profiles) do
		v:BeginMetabolizing()
	end
end

function War:AddProfile(profile)
	print("Profile added to war.")
	if not table.find(self.Profiles,profile) then
		if self.Started == true then
			profile:BeginMetabolizing()
		end
		table.insert(self.Profiles,profile)
	end
end

function War:RemoveProfile(profile,reason)
	print("Profile removed from war. Reason: "..tostring(reason))
	print(profile)
	for _,v in pairs(self.Profiles) do
		print("Participant: "..tostring(v))
	end
	local index = table.find(self.Profiles,profile)
	if index then -- player was a participant
		print("Player was a participant.")
		table.remove(self.Profiles,index)
		if reason == "left" then
			self.Prize = self.Prize - 1 -- not a valid kill, prize is lessened
			print(self.Prize)
		end
	end
end

function War.GetWar()
	return warObject
end

return War
