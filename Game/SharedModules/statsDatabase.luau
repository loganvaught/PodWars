-- used to inform about object damages, replenishes, buffs, etc
local statsDatabase = {
	["Swing"] = {
		["Wooden Pickaxe"] = {
			baseDamage = 8,
			resourcesDamage = { -- damage multipliers by resource. if missing, 0 damage is applied
				["Pine Tree"] = 0.5, 
				["Rock"] = 1, -- optimal efficiency for rocks
			},
			podDamage = {
				["door"] = 1, -- base damage
				["body"] = 1,
			},
			damageMultiplierPerArmorPoint = 0.98, -- every armor point is added to this value as a power. 75 points=0.98^75 = 0.21 damge multiplier,
			range = 4,
			cooldown = 0.6, -- careful! is this number greater than or equal to the animation period? make sure it is
		}
	}
}

return statsDatabase
