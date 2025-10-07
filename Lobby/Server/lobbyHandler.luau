local lobbyDictionary = require(game:GetService("ServerStorage"):WaitForChild("dictionaries"):WaitForChild("lobbyDictionary"))
local ws = game:GetService("Workspace")
local Lobby = require(game:GetService("ServerStorage").Lobby)
local lobbyFolder = ws:WaitForChild("lobbies")

repeat 
	task.wait() 
until #lobbyFolder:GetChildren() >= lobbyDictionary.numberOfLobbies

local registeredLobbies = {} -- table of lobbies to check player proximity
-- format {		lobbyInstance = {lobby = lobbyInstance, center = center, decal = decal}	}



for _,v in pairs(lobbyFolder:GetChildren()) do -- registers all the lobby circles to start making lobbies
	local thisLobby = Lobby.new(v) -- makes the new lobby object
	task.spawn(function()
		thisLobby:StopCountdown() -- will signify that it is waiting for players, starting the cycle at phase 0
	end)

	registeredLobbies[v] = thisLobby
end