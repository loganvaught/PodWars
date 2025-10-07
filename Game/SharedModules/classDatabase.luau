-- used to inform about class properties
local itemDatabase = {
	["Resource"] = {
		stackable = true,
		droppable = false,
		equippable = false,
		consumable = false,
	},
	["Food"] = {
		stackable = true,
		droppable = false,
		equippable = false,
		consumable = true,
	},
	["Swing"] = {
		stackable = false,
		droppable = true,
		equippable = true,
		consumable = false,
	},
	["Independent"] = {
		-- independent class has independent properties. see independent database
	},
	["Ranged"] = {
		stackable = false,
		droppable = true,
		equippable = true,
		consumable = false,
	},
}

return itemDatabase
