local plr = game:GetService("Players").LocalPlayer
local PlrScripts = plr:WaitForChild("PlayerScripts")
local reps = game:GetService("ReplicatedStorage")
local uip = game:GetService("UserInputService")

local InventoryItem = require(PlrScripts:WaitForChild("InventoryItem"))

-- InventoryItems have a tag: "interactable" attached to the main frame
-- Locations (like hotbar slots, inventory segment) have "receiving" attached to the main frame

local canUse = false
local isMobile = uip.TouchEnabled and not uip.KeyboardEnabled
if isMobile then
	canUse = true
	print("PodWars detected you were on a mobile device.")
else
	script:Destroy()
end

if not canUse then return end

-- INCOMPLETE SCRIPT