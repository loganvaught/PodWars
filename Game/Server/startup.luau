local MemoryStoreService = game:GetService("MemoryStoreService")
local reservedServers = MemoryStoreService:GetHashMap("ReservedServers")
local warConfigs = require(game:GetService("ServerStorage"):WaitForChild("dictionaries"):WaitForChild("warConfigs"))
local ps = game:GetService("Players")
local loadAnimationRemote = game:GetService("ServerStorage"):WaitForChild("serverEvents"):WaitForChild("loadAnimationHandler")
local Pod = require(game:GetService("ServerStorage"):WaitForChild("Pod"))
local Profile = require(game:GetService("ServerStorage"):WaitForChild("Profile"))
local deathEvent = game:GetService("ServerStorage"):WaitForChild("serverEvents"):WaitForChild("deathHandler")
local debugMode = warConfigs.debugMode

local dss = game:GetService("DataStoreService")
local mainStore = dss:GetDataStore("main")
print("Startup")
--[[
	[userid] = {
		coins = n,
		wins = n,
		xp = n,
		skinsOwned = {string,string,string},
		equipped = {skin = "string",}
	}
]]

-- Gotta make sure the PrivateServerId isn't blank, meaning it's either a reserved
-- or private server, and if the PrivateServerOwnerId is 0 that means it's a reserved server.

local verifiedPlayers = {} -- players who are verified, and have started preparing for the game
local playersReady = {} -- players who are verified, and ready to react to a game start
local thisWar = nil
local waitingOver = false

local gameStartedValue = game:GetService("ServerStorage"):WaitForChild("gameStarted")
local gameEndedValue = game:GetService("ServerStorage"):WaitForChild("gameEnded")
local data = nil
local assignedSlots = {}

function beginPod(profile,pod) -- XV THIS IS NEXT
	print(profile)
	print("Beginning this users pod")
	-- should we wait for anything to ensure pod is ready to be opened?
	-- this function is only called once the game has begun
	
	-- make their pods open and toggle all their items 
	pod:ToggleDoor()
	

	-- unlock proximity prompts with pod:Unlock(prompt)
	pod:Unlock("door")
end

function attachPlayerToStarting(plr,pod,profile)
	repeat 
		task.wait(0.5) 
	until waitingOver == true and plr.Character
	loadAnimationRemote:Fire(plr,{Hint = "waiting",Text = ""}) -- removing their countdown
	beginPod(profile,pod)
end

local function newPlayer(plr,loadedLate) -- put them in their pod and whatnot while countdown waits
	print("----".." BEGINNING NEW PLAYER SEQUENCE: "..plr.Name.." ----")
	-- getting player data
	local playerData = nil
	local s,_ = pcall(function()
		playerData = mainStore:GetAsync(plr.UserId)
	end)
	if s and playerData then
		local playerSkin = playerData.equippedSkin
		local podAssigned = Pod.GetPodFromUserId(plr.UserId)
		if podAssigned then
			print("- The user ID is associated with a pod. +")
			podAssigned:OfficializePod(plr,playerSkin) -- load player skin and attach their name to the pod
		end
		-- make new profile for the player
		print("Beginning profile creation.")
		
		local newProfile = Profile.new(plr,podAssigned)
		
		
		plr.CharacterAdded:Connect(function(c) -- handles respawning
			local h = c:WaitForChild("Humanoid")
			local hrp = c:WaitForChild("HumanoidRootPart")
			if podAssigned and podAssigned.Active == true then
				hrp.CFrame = podAssigned:GetSpawn().CFrame
			else
				print("Player spawned but had no pod.")
			end
			
			h.Died:Connect(function() -- PLAYER HAS DIED
				deathEvent:Fire(plr,newProfile,podAssigned)
			end)
		end)
		plr:LoadCharacter()


		-- after doing everything
		if loadedLate == false then -- player is not late
			table.insert(playersReady,plr) -- queue to show themn the countdown
			attachPlayerToStarting(plr,podAssigned,newProfile)
		else
			-- they loaded late
			table.insert(playersReady,plr) -- queue to show themn the countdown
			beginPod(newProfile,podAssigned)
			thisWar.AddProfile(newProfile,true)
		end
	else
		plr:Kick("Failed to load data.") -- MAKE SURE this data is set to not be saved before kicking
		-- remove the pod from existence
		-- make sure player is removed properly
	end
end
local function registerPod(userId,slot)
	local newPod = Pod.new(userId)
	newPod:AssignSlot(slot)
	newPod:LoadPod("empty",false)
end

local approved


if debugMode==true then
	-- instantiating fake data
	data = {
		ids = {2880083964}
	}
	approved = true
else
	-- getting real data
	data = reservedServers:GetAsync(game.PrivateServerId)
	approved = (game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0)
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
	repeat 
		task.wait() 
	until data and approved
	if gameStartedValue.Value == true then -- player arrived late
		if gameEndedValue.Value == false then
			print("Player arrived late")
			if table.find(data.ids,plr.UserId) then -- player is allowed
				print("Late player verified.")
				repeat 
					task.wait() 
				until gameStartedValue.Value == true
				-- they will probably be suspended in air while their player is not loaded for up to the three seconds in the first section between waiting over and war being declared

				-- player can spawn now
				table.insert(verifiedPlayers,plr) -- verifying them
				newPlayer(plr,true)
			end
		else
			plr:Kick("The game already ended. Sorry!")
		end
	end
end)

game:GetService("Players").PlayerRemoving:Connect(function(plr) -- processes the withdrawal of the player. SAVE DATA OR NO?
	repeat 
		task.wait() 
	until data and approved
	print("Player left")
	if gameStartedValue.Value == false then
		-- remove their id from expected ids
		if table.find(playersReady,plr) then
			print("Player was ready")
			table.remove(playersReady,table.find(playersReady,plr))
		end
		if table.find(data.ids,plr.UserId) then
			print("Player was valuable")
			table.remove(data.ids,table.find(data.ids,plr.UserId))
		end
	end
	local plrProfile = Profile.getProfileFromOwner(plr)
	if plrProfile then -- if the player has a profile, it will be removed, and if theres a pod, it will be removed as well. if the player doesn't have a profile, a loading ban will be added
		print("Profile existed.")
		plrProfile:Remove("left") -- this will stop them from competing and remove a pod if it exists
	else
		print("Profile did not exist.")
		Profile.addLoadingBan(plr.UserId) -- stops profile and pod from being made, so they dont enter competition
		local theoreticalPod = Pod.GetPodFromUserId(plr.UserId) -- gets rid of a pod of it exists
		if theoreticalPod then
			print("Theoretical pod existed.")
			theoreticalPod:Remove()
		end
	end
end)

repeat 
	task.wait() 
until data and approved


print("LETS GO")

-- randomly make assignedSlots where i (pot slot number) = playerId
local numIds = #data.ids
for i = numIds, 1,-1 do
	local j = math.random(1,i)
	local temp = data.ids[j]
	data.ids[j] = data.ids[i]
	data.ids[i] = temp
end

for i,v in pairs(data.ids) do
	print(i,v)
	assignedSlots[i] = v
	registerPod(v,i)
end
print("XX")

repeat
	for _,v in pairs(ps:GetPlayers()) do
		if table.find(playersReady,v) then
			loadAnimationRemote:Fire(v,{Hint = "waiting",Text = "Needs "..tostring(warConfigs.minimumPlayers).." to start!"})
		end
	end	
	local countDown = warConfigs.timeToWaitForPlayers
	repeat -- checking until all players have loaded, or until the max time has surpassed
		print("Coutndown tick")
		task.wait(1)
		numIds = #data.ids
		for _,v in pairs(ps:GetPlayers()) do
			if table.find(verifiedPlayers,v) == nil then
				if table.find(data.ids,v.UserId) then
					table.insert(verifiedPlayers,v)
					task.spawn(newPlayer,v,false)
				else
					v:Kick("Error: Failure during UserId processing. Code: XV-2")
				end
			end
			if table.find(playersReady,v) then -- show them the countdown
				print("PLayer was ready.")
				loadAnimationRemote:Fire(v,{Hint = "waiting",Text = "Waiting for players: "..tostring(#playersReady).."/"..tostring(numIds).."\nAuto start in "..tostring(countDown).."."})
			end
		end
		countDown = countDown - 1
	until countDown <= 0 or #playersReady >= numIds -- until max time passed or all players expected have loaded
until #playersReady >= warConfigs.minimumPlayers

waitingOver = true -- player countdowns are changed to Starting..., and players that join after this will go through the late procedure

-- new war?

gameStartedValue.Value = true
thisWar = Profile.StartWarWithProfiles()
thisWar:BeginGame()

-- XV THIS IS NEXT: NEW WAR OBJECT
-- other scripts:
-- begin basic survival functions like hunger and thirst for all players in game