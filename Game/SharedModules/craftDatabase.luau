-- used to inform about object crafting recipes
local craftDatabase = {
	levelItems = {
		[0] = { -- Hand
			"Wooden Pickaxe",
			"Stone Pickaxe",
			"Wooden Axe",
			"Stone Axe",
			"Wooden Sword",
			"Stone Sword",
			"Bow",
			"Arrow",
			"Leafy Pants",
			"Leafy Chestplate",
		},
		[1] = { -- Hand
			"Wooden Pickaxe",
			"Stone Pickaxe",
			"Wooden Axe",
			"Stone Axe",
			"Wooden Sword",
			"Stone Sword",
			"Bow",
			"Arrow",
			"Leafy Pants",
			"Leafy Chestplate",
		},
		[2] = { -- Hand
			"Wooden Pickaxe",
			"Stone Pickaxe",
			"Wooden Axe",
			"Stone Axe",
			"Wooden Sword",
			"Stone Sword",
			"Bow",
			"Arrow",
			"Leafy Pants",
			"Leafy Chestplate",
		},
		[3] = { -- Hand
			"Wooden Pickaxe",
			"Stone Pickaxe",
			"Wooden Axe",
			"Stone Axe",
			"Wooden Sword",
			"Stone Sword",
			"Bow",
			"Arrow",
			"Leafy Pants",
			"Leafy Chestplate",
		},
		[4] = { -- Hand
			"Wooden Pickaxe",
			"Stone Pickaxe",
			"Wooden Axe",
			"Stone Axe",
			"Wooden Sword",
			"Stone Sword",
			"Bow",
			"Arrow",
			"Leafy Pants",
			"Leafy Chestplate",
		},
	},
	recipes = {
		["Wooden Pickaxe"] = {
			["Wood"] = 3,
			["Fiber"] = 5,
		},
		["Wooden Axe"] = {
			["Wood"] = 4,
			["Fiber"] = 5,
		},
		["Wooden Sword"] = {
			["Wood"] = 5,
			["Fiber"] = 5,
		},
		["Stone Pickaxe"] = {
			["Wood"] = 2,
			["Fiber"] = 5,
			["Stone"] = 1,
		},
		["Stone Axe"] = {
			["Wood"] = 2,
			["Fiber"] = 5,
			["Stone"] = 2,
		},
		["Stone Sword"] = {
			["Wood"] = 2,
			["Fiber"] = 5,
			["Stone"] = 3,
		},
		["Iron Pickaxe"] = {
			["Wood"] = 3,
			["Fiber"] = 5,
			["Iron"] = 1,
		},
		["Iron Axe"] = {
			["Wood"] = 3,
			["Fiber"] = 5,
			["Iron"] = 2,
		},
		["Iron Sword"] = {
			["Wood"] = 3,
			["Fiber"] = 5,
			["Iron"] = 3,
		},
		["Bow"] = {
			["Wood"] = 15,
			["Fiber"] = 7,
		},
		["Arrow"] = {
			["Wood"] = 3,
			["Stone"] = 1,
		},
		["Leafy Chestplate"] = {
			["Fiber"] = 20,
		},
		["Leafy Pants"] = {
			["Fiber"] = 15,
		}
		
	},
	metadata = {
		["Wooden Pickaxe"] = {
			cooldownByLevel = {
				[0] = 5, -- hand, 5 seconds
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Wooden Axe"] = {
			cooldownByLevel = {
				[0] = 5, -- hand, 5 seconds
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Wooden Sword"] = {
			cooldownByLevel = {
				[0] = 5, -- hand, 5 seconds
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Stone Pickaxe"] = {
			cooldownByLevel = {
				[0] = 5,
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Stone Axe"] = {
			cooldownByLevel = {
				[0] = 5,
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Stone Sword"] = {
			cooldownByLevel = {
				[0] = 5,
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Iron Pickaxe"] = {
			cooldownByLevel = {
				[0] = 5,
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Iron Axe"] = {
			cooldownByLevel = {
				[0] = 5,
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Iron Sword"] = {
			cooldownByLevel = {
				[0] = 5,
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Bow"] = {
			cooldownByLevel = {
				[0] = 5,
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Arrow"] = {
			cooldownByLevel = {
				[0] = 3,
				[1] = 3,
				[2] = 2,
				[3] = 1,
				[4] = 1,
			}
		},
		["Leafy Chestplate"] = {
			cooldownByLevel = {
				[0] = 5,
				[1] = 5,
				[2] = 5,
				[3] = 5,
				[4] = 5,
			}
		},
		["Leafy Pants"] = {
			cooldownByLevel = {
				[0] = 3,
				[1] = 3,
				[2] = 2,
				[3] = 1,
				[4] = 1,
			}
		},
	},
	--[[craftFormat = {
		["Wooden Pickaxe"] = 1, -- Wooden pickaxe will be first in the ui
		["Stone Pickaxe"] = 2,
		["Iron Pickaxe"] = 3,
		["Wooden Axe"] = 4,
		["Stone Axe"] = 5,
	},]]
	amountPerCraft = {-- only specify items if they do not add one per craft
		["Arrow"] = 3
	}
}

craftDatabase.getCraftablesOfLevel = function(level: number): table
	return craftDatabase.levelItems[level]
end
craftDatabase.getRecipeOfItem = function(itemName: string): table
	return craftDatabase.recipes[itemName]
end
craftDatabase.getMetadataOfItem = function(itemName: string): table
	return craftDatabase.metadata[itemName]
end

return craftDatabase
