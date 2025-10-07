local e = game:GetService("ReplicatedStorage").events.loadAnimationHandler

local waitingText = script.Parent:WaitForChild("TextLabel")
e.OnClientEvent:Connect(function(info)
	print("Received text update")
	print(info.Text)
	if info.Text == "" then
		script.Parent.Visible = false
	else
		if info.Hint == "waiting" then
			script.Parent.Visible = true
			-- some form of waiting text. either waiting for 
			waitingText.Text = info.Text
		end
	end
end)