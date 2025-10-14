local Profile = {}
Profile.__index = Profile

local ownerProfileRegistry = {}
local podProfileRegsitry = {}
local profilesAlive = {}
local loadingBan = {}

local ss = game:GetService("ServerStorage")
local War = require(ss:WaitForChild("War"))

function Profile.new(plr,pod) -- officially marks the player as competing. their pod exists before this
	if ownerProfileRegistry[plr] == nil and profilesAlive[plr] == nil then
		if table.find(loadingBan,plr.UserId) == nil then
			local newProfile = {}
			setmetatable(newProfile,Profile)

			newProfile.Player = plr
			newProfile.Pod = pod
			ownerProfileRegistry[plr] = newProfile
			podProfileRegsitry[pod] = newProfile
			table.insert(profilesAlive,newProfile)

			return newProfile
		else
			if pod then 
            pod:Remove() 
            return nil 
         end
		end
	else
		return nil
	end
end

function Profile.getActiveProfiles()
	return profilesAlive
end

function Profile.addLoadingBan(id)
	table.insert(loadingBan,id)
end

function Profile:Remove(reason) -- function that removes player from competition entirely. their pod will be gone after this
	-- demolish pod and 
	if War.GetWar() then
		local war = War.GetWar()
		war:RemoveProfile(self,reason)
	end
	if self.Pod then
		self.Pod:Remove()
	end
	ownerProfileRegistry[self.Player] = nil
	podProfileRegsitry[self.Pod] = nil
	local index = table.find(profilesAlive,self)
	if index then
		table.remove(profilesAlive,index)
	end
	
	if reason ~= "left" and reason ~= "won" then -- player will spectate
		print("Spectableing player: "..self.Player)
	end
end

function Profile.getProfileFromOwner(plr)
	return ownerProfileRegistry[plr]
end

function Profile:BeginMetabolizing()
	print("Beginning player metabolism: "..self.Player.Name)
end

function Profile.StartWarWithProfiles()
	local newWar = War.new(profilesAlive)
	return newWar
end


return Profile
