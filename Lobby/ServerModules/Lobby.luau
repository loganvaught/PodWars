local Lobby = {}
Lobby.__index = Lobby

local lobbyDictionary = require(game:GetService("ServerStorage"):WaitForChild("dictionaries"):WaitForChild("lobbyDictionary"))
local tps = game:GetService("TeleportService")
local collections = game:GetService("CollectionService")
local memoryStore = game:GetService("MemoryStoreService")
local reservedServerStore = memoryStore:GetHashMap("ReservedServers")

--[[
phases:
- 0: waiting for players
- 1: initiated, running, pooling players
- 2: currently in the process of teleporting

]]

local instanceRegistry = {
	--[[
	
	instance = object
	]]
}

function Lobby.new(physicalLobby)
	local newLobby = {}
	setmetatable(newLobby,Lobby)

	newLobby.countdown = lobbyDictionary.timeToWait
	newLobby.queue = {}
	newLobby.phase = "0"
	newLobby.physicalLobby = physicalLobby
	instanceRegistry[physicalLobby] = newLobby

	return newLobby
end

function Lobby.getLobbyFromInstance(instance)
	return instanceRegistry[instance]
end

function Lobby:ChangeText(text) -- chang the text of the circle
	local textLabel = self.physicalLobby:WaitForChild("center"):WaitForChild("mainText"):WaitForChild("TextLabel")
	textLabel.Text = text
end
function Lobby:ChangePlayerDisplay(number)
	local textLabel = self.physicalLobby:WaitForChild("center"):WaitForChild("plrText"):WaitForChild("TextLabel")
	textLabel.Text = tostring(number).."/"..tostring(lobbyDictionary.maximumPlayers)
end

function Lobby:AddPlrToQueue(plr) -- adds a player to the queue
	if self:PlayerCanJoin(plr)  then
		table.insert(self.queue,plr)
	end
end

function Lobby:RemovePlrFromQueue(plr) -- removes player if is in the current lobby cycle
	local index = table.find(self.queue,plr)
	table.remove(self.queue,index)
end
function Lobby:BeginCountdown()-- begins counting down
	self.phase = "1"
	local continues = true
	local listOfPlayers = self:GetTopMaxPlrs()
	while self.countdown > 0 do
		listOfPlayers = self:GetTopMaxPlrs()
		self:ChangePlayerDisplay(#listOfPlayers)
		self:ChangeText("Beginning in "..tostring(self.countdown))
		task.wait(1)
		self.countdown = self.countdown - 1
		if #listOfPlayers < lobbyDictionary.minimumPlayers then
			continues = false
			break
		elseif #listOfPlayers >= lobbyDictionary.maximumPlayers then
			break
		end
	end
	if continues == true then
		self:StartRound(listOfPlayers)
	else
		self:StopCountdown() -- lobby enters 0 again, waiting for more players to join befor beginning countdown
	end
end

function Lobby:StopCountdown() -- used to revert a lobby back to default info, after a previous one has gone or fallen below minimum player threshold
	print("Reset")
	self.phase = "0"
	self.countdown = lobbyDictionary.timeToWait -- resets countdown to max
	local cycleOn = 1
	
	-- repeatedly changes the text to . .. .. until enough players are inside
	local playersInside = self:GetTopMaxPlrs()
	repeat 
      task.wait(0.5)
      self:ChangeText("Waiting for players ("..tostring(math.abs(#playersInside - lobbyDictionary.minimumPlayers)).." more)."..string.rep(".",cycleOn%3))
      cycleOn+= 1 
      playersInside = self:GetTopMaxPlrs() 
      self:ChangePlayerDisplay(#playersInside) 
   until #playersInside >= lobbyDictionary.minimumPlayers
	self:BeginCountdown()
end
--[[
quick break mark

how do i seperate number of players txt and starting in ... text?
]]

function Lobby:GetTopMaxPlrs()
	local list = {}
	local indexOn = 1
	while #list < lobbyDictionary.maximumPlayers and indexOn <= #self.queue do
		local plr = self.queue[indexOn]
		if self:PlayerIsValid(plr) == true then
			table.insert(list,plr)
		end
		indexOn = indexOn + 1
	end
	return list
end

function Lobby:TeleportPlayers()
	
end

function Lobby:PlayerIsValid(plr) -- player exists to the fullest extent detectable
	if plr and plr.Parent == game:GetService("Players") and collections:HasTag(plr,"teleporting") == false then
		return true
	end
	return false
end

function Lobby:PlayerCanJoin(plr) -- player can join
	if self:PlayerIsValid(plr) and not table.find(self.queue,plr) then
		return true
	end
	return false
end

function Lobby:StartRound(playersToTeleport) -- begins teleporting procedure.
	self.phase = "2"
	self:ChangeText("Starting Round")
	-- teleporting players and stuff
	for _,v in pairs(playersToTeleport) do
		task.wait()
		table.remove(self.queue, table.find(self.queue,v))
		collections:AddTag(v, "teleporting")
	end

	pcall(function()
		local reservedServer,privateId = tps:ReserveServer(81123897434469)
		local teleportOptions = Instance.new("TeleportOptions")
		teleportOptions.ReservedServerAccessCode = reservedServer

		local playerIds = {}
		for _,v in pairs(playersToTeleport) do
			table.insert(playerIds,v.UserId)
		end
		local data = {
			ids = playerIds
		}
		
		local s,_ = pcall(function()
			print(privateId)
			reservedServerStore:SetAsync(tostring(privateId),data,120) -- 120 is 120s before it expires
		end)
		
		if s then
			local newServer = tps:TeleportAsync(81123897434469,playersToTeleport,teleportOptions)
			--[[
         CURRENTLY BEING USED TO DO TESTS. Final code here is not added.
         task.wait(10)-- lag simulation for 2 player test
			local newServer2 = tps:TeleportAsync(81123897434469,{game.Players.SuperSuperCoolDude8},teleportOptions)
			task.wait(10)-- lag simulation for 2 player test
			local newServer2 = tps:TeleportAsync(81123897434469,{game.Players.Xrvoa},teleportOptions)]]
		else
			print("XV: Error when sending data over memory store for reserved server.")
			for _,v in pairs(playersToTeleport) do
				pcall(function()
					v:Kick("There was a teleportation error. Code: XV-1.")
				end)
			end
		end
	end) 
	
	-- may want to aniamte teleporation here so players know they are being teleported


	self:StopCountdown() -- enter phase 0
end

function Lobby:GetPhase()
	return self.phase
end



return Lobby
