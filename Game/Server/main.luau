--[[
Handles the loading of required player items and folders.
]]


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
	local dataFolder = Instance.new("Folder") -- to be parented after all data has loaded, or to have child "dontSave" if failed

	dataFolder.Name = "data"

	-- data folder children

	local skinsFolder = Instance.new("Folder")
	skinsFolder.Name = "skins"
	skinsFolder.Parent = dataFolder
	
	-- folders required for gameplay
	
	local armorFolder = Instance.new("Folder")
	armorFolder.Name = "armor"
	armorFolder.Parent = plr

	-- getting player data

	local data = nil
	local s,_ = pcall(function()
		data = mainStore:GetAsync(plr.UserId)
		if data then
			--adding skins
			for i,_ in pairs(data.skins) do
				local newFolder = Instance.new("Folder")
				newFolder.Name = i
				newFolder.Parent = skinsFolder
			end
		else
			local dontSave = Instance.new("Folder")
			dontSave.Name = "dontSave"
			dontSave.Parent = plr
		end
	end)
	if not s then
		local dontSave = Instance.new("Folder")
		dontSave.Name = "dontSave"
		dontSave.Parent = plr
	end

	dataFolder.Parent = plr
end)