-- used to inform about object names, images, properties
local itemDatabase = {
	-- Swings
	-- Pickaxes
	["Wooden Pickaxe"] = {
		name = "Wooden Pick",
		description = "Really? Might as well use your fist.",
		image = "rbxassetid://78186472563163",
		class = "Swing",
	},
	["Stone Pickaxe"] = {
		name = "Stone Pick",
		description = "Okay! Bang two rocks together.",
		image = "rbxassetid://95634237701655",
		class = "Swing",
	},
	["Iron Pickaxe"] = {
		name = "Iron Pick",
		description = "Efficiently gathers minerals and thatch.",
		image = "rbxassetid://86980085046613",
		class = "Swing",
	},
	-- Axes
	["Wooden Axe"] = {
		name = "Wooden Axe",
		description = "Well... at least you won't hurt your hands!",
		image = "rbxassetid://114639218054355",
		class = "Swing",
	},
	["Stone Axe"] = {
		name = "Stone Axe",
		description = "Effectively gathers wood.",
		image = "rbxassetid://83536365643773",
		class = "Swing",
	},
	["Iron Axe"] = {
		name = "Iron Axe",
		description = "How ba-a-a-ad can you be?",
		image = "rbxassetid://110028165574197",
		class = "Swing",
	},
	-- Swords
	["Wooden Sword"] = {
		name = "Wooden Sword",
		description = "Give your opponent splinters, I guess.",
		image = "rbxassetid://93187972982694",
		class = "Swing",
	},
	["Stone Sword"] = {
		name = "Stone Sword",
		description = "A little dull, but it's the thought that counts.",
		image = "rbxassetid://93187972982694",
		class = "Swing",
	},
	["Iron Sword"] = {
		name = "Iron Sword",
		description = "Heavy, sharp, brutally effective. Emphasis on heavy.",
		image = "rbxassetid://93187972982694",
		class = "Swing",
	},
	-- Resources
	["Wood"] = {
		name = "Wood",
		description = "",
		image = "rbxassetid://72345067364364",
		class = "Resource",
	},
	["Fiber"] = {
		name = "Fiber",
		description = "",
		image = "rbxassetid://93187972982694",
		class = "Resource",
	},
	["Stone"] = {
		name = "Stone",
		description = "",
		image = "rbxassetid://132683524706266",
		class = "Resource",
	},
	["Thatch"] = {
		name = "Thatch",
		description = "",
		image = "rbxassetid://93187972982694",
		class = "Resource",
	},
	["Flint"] = {
		name = "Flint",
		description = "",
		image = "rbxassetid://93187972982694",
		class = "Resource",
	},
	["Coal"] = {
		name = "Coal",
		description = "",
		image = "rbxassetid://93187972982694",
		class = "Resource",
	},
	["Raw Iron"] = {
		name = "Raw Iron",
		description = "",
		image = "rbxassetid://73549451934430",
		class = "Resource",
	},
	["Iron"] = {
		name = "Raw Iron",
		description = "",
		image = "rbxassetid://115435471256943",
		class = "Resource",
	},
	-- Ammos
	["Arrow"] = {
		name = "Arrow",
		description = "",
		image = "rbxassetid://140001809989658",
		class = "Resource",
	},
	-- Food
	["Zazzleberry"] = {
		name = "Zazzleberry",
		description = "",
		image = "rbxassetid://131386686151752",
		class = "Food",
	},
	["Lamberry"] = {
		name = "Lamberry",
		description = "",
		image = "rbxassetid://131386686151752",
		class = "Food",
	},
	["Ham"] = {
		name = "Ham",
		description = "",
		image = "rbxassetid://131386686151752",
		class = "Food",
	},
	["Raw Ham"] = {
		name = "Raw Ham",
		description = "",
		image = "rbxassetid://131386686151752",
		class = "Food",
	},
	["Water Bottle"] = {
		name = "Water Bottle",
		description = "",
		image = "rbxassetid://131386686151752",
		class = "Food",
	},
	-- Ranged
	["Bow"] = {
		name = "Bow",
		description = "The power of fiber and a stick. Uses: Arrow",
		image = "rbxassetid://130123554372123",
		class = "Ranged",
	},
	-- Independent
	["Magnifying Glass"] = {
		name = "Magnifying Glass",
		description = "Reveals the health level of objects, structures, and animals.",
		image = "rbxassetid://85424941579104",
		class = "Independent",
	},
	["Leafy Pants"] = {
		name = "Leafy Pants",
		description = "Eat your vegetables",
		image = "rbxassetid://130123554372123",
		class = "Armor",
		bodyLocation = "legs",
	},
	-- Independent
	["Leafy Chestplate"] = {
		name = "Leafy Chestplate",
		description = "Eat your vegetables",
		image = "rbxassetid://85424941579104",
		class = "Armor",
		bodyLocation = "torso",
	},
}

return itemDatabase
