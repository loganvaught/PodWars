local ps = game:GetService("Players")
local dss = game:GetService("DataStoreService")
local mainStore = dss:GetDataStore("main")
-- data structure
--[[
player.UserId = {
	wins = n,
	loses = n,
	cash = n,
	exp = n,
	equippedSkin = string,
	skins = {[strings] = n(quantity)},
}
]]

ps.PlayerAdded:Connect(function(plr)
	
end)

ps.PlayerRemoving:Connect(function(plr)
	if plr:FindFirstChild("dontSave") == nil then
		local data = {
			wins = 0,
			loses = 0,
			cash = 0,
			exp = 0,
			equippedSkin = nil,
			skins = {}
		}
		pcall(function()
			mainStore:SetAsync(plr.UserId,data)
		end)
	end
end)