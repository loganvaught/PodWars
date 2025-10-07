local e = game:GetService("ReplicatedStorage").events.tellServerInOrOut
local Lobby = require(game:GetService("ServerStorage"):WaitForChild("Lobby"))
local collections = game:GetService("CollectionService")
local lobbyDictionary = require(game:GetService("ServerStorage").dictionaries.lobbyDictionary)

local plrQueueTracker = {}
local lobbiesFolder = workspace:WaitForChild("lobbies")
repeat 
	task.wait() 
until #lobbiesFolder:GetChildren() >= lobbyDictionary.numberOfLobbies
for _,v in pairs(lobbiesFolder:GetChildren()) do
	if plrQueueTracker[v] == nil then
		plrQueueTracker[v] = {}
	end
end

e.OnServerEvent:Connect(function(plrFrom,action,lobbyFolder)
	local lobbyInstance = Lobby.getLobbyFromInstance(lobbyFolder)
	local relativeTracker = plrQueueTracker[lobbyFolder]
	if lobbyInstance and relativeTracker and collections:HasTag(plrFrom,"teleporting") == false then
		if action == "join" then
			if not collections:HasTag(plrFrom,"isInQueue") then -- detects player not in a queue
				collections:AddTag(plrFrom,"isInQueue")
				lobbyInstance:AddPlrToQueue(plrFrom)
			else -- detects player is in queue somewhere
				for i,v in pairs(plrQueueTracker) do -- remove player from any queues they may be in
					if table.find(v,plrFrom) then
						local thisLobby = Lobby.getLobbyFromInstance(i)
						thisLobby:RemovePlrFromQueue(plrFrom)
						e:FireClient(plrFrom,"left",i, true) -- client is no longer in the rogue lobby
						table.remove(v,table.find(v,plrFrom))
						print("Continuance")
					end
				end
				lobbyInstance:AddPlrToQueue(plrFrom)
			end
			table.insert(relativeTracker,plrFrom)
			e:FireClient(plrFrom,"joined",lobbyFolder) -- client is now in the queue for which they requested
		else -- player wants to leave
			if collections:HasTag(plrFrom,"isInQueue") then
				local index = table.find(relativeTracker,plrFrom)
				if index then
					table.remove(relativeTracker,index)
					collections:RemoveTag(plrFrom,"isInQueue")
					lobbyInstance:RemovePlrFromQueue(plrFrom)
				end
			end
			e:FireClient(plrFrom,"left",lobbyFolder) -- client is not in the queue for their request anymore
		end
	end
end)

-- add a receptive event for which the server fires itself here to remove the player from any queue they are in if they leave the game

game:GetService("Players").PlayerRemoving:Connect(function(plr)
	if collections:HasTag(plr,"isInQueue") then
		for i,v in pairs(plrQueueTracker) do -- remove player from any queues they may be in
			if table.find(v,plr) then
				local lobbyInstance = Lobby.getLobbyFromInstance(i)
				lobbyInstance:RemovePlrFromQueue(plr)
				table.remove(v,table.find(v,plr))
			end
		end
	end
end)