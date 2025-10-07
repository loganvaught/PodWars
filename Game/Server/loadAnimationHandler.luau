local remoteE = game:GetService("ReplicatedStorage").events.loadAnimationHandler
local bindE = game:GetService("ServerStorage"):WaitForChild("serverEvents"):WaitForChild("loadAnimationHandler")

bindE.Event:Connect(function(plrTo,info,text)
	remoteE:FireClient(plrTo,info,text)
end)