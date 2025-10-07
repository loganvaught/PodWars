local plr = game:GetService("Players").LocalPlayer
local waitingForServer = false
local e = game:GetService("ReplicatedStorage").events.tellServerInOrOut
local c = nil
repeat task.wait() until game:IsLoaded()

local existingLobbies = {}
for _,v in pairs(workspace.lobbies:GetChildren()) do
	existingLobbies[v] = false
end

function isPlrInArea(hrp,center,radius)
	local cX = center.X
	local cZ = center.Z
	local pX = hrp.X
	local pZ = hrp.Z
	local dX = math.abs(cX - pX)
	local dZ = math.abs(cZ - pZ)
	--print(tostring(dZ).."Z")
	local h = math.sqrt(dX^2 + dZ^2)
	--print(tostring(h).."H")
	if h <= radius then
		return true
	else
		return false
	end
end

local inQueueDisplay = plr.PlayerGui:WaitForChild("main"):WaitForChild("displays"):WaitForChild("inQueueDisplay")
local function senseLocation(character)
	print("Connected")
	while character.Parent == workspace do -- cycle to detect when player is in or out of the circle
		task.wait(0.2)
		pcall(function()
			if waitingForServer == false then
				local hrp = character.HumanoidRootPart.Position
				local inQueue = false
				for i,v in pairs(existingLobbies) do
					if v == true then 
                  inQueue = true 
               end
					
					local center = i.center.Position
					local radius = i.lobbyElements.decal.Size.X/2
					if isPlrInArea(hrp,center,radius) then -- plr should be in this queue
						if v == false then -- server does not think is insid
							print("join "..i.Name)
							waitingForServer = true
							e:FireServer("join", i)
						end
					else -- plr should not be in this queue
						if v == true then -- server thinks is inside
							print("leave "..i.Name)
							waitingForServer = true
							e:FireServer("leave", i)
						end
					end
				end
				if inQueue then
					inQueueDisplay.Visible = true
				else
					inQueueDisplay.Visible = false
				end
			end
		end)
	end
	print("Detected player left workspace.")
	repeat 
      task.wait() 
   until plr.Character
	senseLocation(plr.Character)
end

e.OnClientEvent:Connect(function(action, lobbyFolder, extraneous)
	if action == "joined" then
		existingLobbies[lobbyFolder] = true
	else -- left
		existingLobbies[lobbyFolder] = false
	end
	if extraneous ~= true then
		waitingForServer = false
	end
end)

repeat 
   c = plr.Character 
   task.wait() 
until c ~= nil

senseLocation(c)