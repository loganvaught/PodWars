-- responsible for detectitng when players alive is only one

-- use profilesAlive in server storage

local ss = game:GetService("ServerStorage")
local markBeginning = ss:WaitForChild("serverEvents"):WaitForChild("markBeginning")

markBeginning.Event:Connect(function() -- game has begun
	print("Detected game start")
end)