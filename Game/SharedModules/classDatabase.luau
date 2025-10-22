-- used to inform about class properties
local itemDatabase = {
	["Resource"] = {
		stackable = true, -- whether can stack in inventory
		droppable = false, -- whether can be dropped from inventory
		equippable = false, -- whether can be put in the hotbar for use
		consumable = false, -- whether can be eaten
		wearable = false, -- whether can be worn (eg armor)
		holdable = false, -- whether can be held, eg a tool
	},
	["Food"] = {
		stackable = true,
		droppable = false,
		equippable = true,
		consumable = true,
		wearable = false,
		holdable = false,
	},
	["Swing"] = {
		stackable = false,
		droppable = true,
		equippable = true,
		consumable = false,
		wearable = false,
		holdable = true,
	},
	["Independent"] = {
		-- independent class has independent properties. see independent database
	},
	["Ranged"] = {
		stackable = false,
		droppable = true,
		equippable = true,
		consumable = false,
		wearable = false,
		holdable = true,
	},
	["Armor"] = {
		stackable = false,
		droppable = true,
		equippable = false,
		consumable = false,
		wearable = true,
		holdable = false,
	},
}

return itemDatabase
