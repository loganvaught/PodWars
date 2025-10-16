-- WORK IN PROGRESS
local Swing = {}
Swing.__index = Swing

local ss = game:GetService("ServerStorage")
local itemModels = ss:WaitForChild("itemModels")
local classModels = itemModels:WaitForChild("Swing")
local classScript = itemModels:WaitForChild("classScripts"):WaitForChild("Swing")
local Pod
local Harvestable

local statsDatabase = require(game:GetService("ReplicatedStorage"):WaitForChild("dictionaries"):WaitForChild("statsDatabase"))


function Swing.new(owner: Player,swingName: string,swingClassifier: number)
	local newSwing = {}
	setmetatable(newSwing,Swing)

	newSwing.Class = "Swing"
	newSwing.Classifier = swingClassifier
	newSwing.Name = swingName
	newSwing.Model = classModels:FindFirstChild(swingName):Clone()
	local scriptFor = classScript:Clone()
	scriptFor.Parent = newSwing.Model
	newSwing.Model.Name = swingClassifier
	newSwing.Owner = owner
	newSwing.Amount = 1
	newSwing.Model.Parent = owner.Backpack

	return newSwing
end

function Swing:DamagePart(hit: Instance)
	print("DAMAGE PART RECEIVED: "..hit.Name)

	-- WORK AROUND FOR AVOIDING RECURSIVE REQUIRE ON MODULES. CHANGE LATER XV
	if not Pod then
		Pod = require(game:GetService("ServerStorage"):WaitForChild("Pod"))
	end
	if not Harvestable then
		Harvestable = require(game:GetService("ServerStorage"):WaitForChild("Harvestable"))
	end
	
	-- Is it a player
	if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
		print("Damage player")
		-- armor info is stored in the plr object. in a folder called "armor", 
		-- and each piece is an int value with armor points.
		-- 1 total armor point = an exact reduction in damage dealt,
		-- by the armor constant: armorMult
		
		-- IN THE FUTURE: Armor will be another class: wearables.
		local plr = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
		if plr and plr ~= self.Owner then
			local armorFolder = plr:FindFirstChild("armor")
			-- local damageReduction
			local armorMult = statsDatabase["Swing"][self.Name].damageMultiplierPerArmorPoint
			local armorPoints = 0
			if armorFolder then
				for _,v in pairs(armorFolder:GetChildren()) do
					armorPoints += v.Value
				end
			end
			local damageProtectionMultiplier = math.pow(armorMult,armorPoints)
			local thisDamage = statsDatabase["Swing"][self.Name].baseDamage

			-- local amountToDeal = thisDamage * damageProtectionMultiplier
			local h = hit.Parent.Humanoid
			h.Health -= thisDamage
		end
	elseif hit:GetAttribute("damageable") == "resource" then -- is it a resource
		-- do damage to resource
		print("Damage resource")
		local thisResource = Harvestable.GetObjectFromFolder(hit.Parent) -- assumes the damageable part is directly a descendant
		local thisInfo = statsDatabase["Swing"][self.Name]
		local thisDamage = thisInfo.baseDamage
		local resourceMultiplier = thisInfo.resourcesDamage[thisResource.Name]

		if thisResource then
			local amountToDeal = thisDamage * resourceMultiplier
			thisResource:Damage(self.Owner,amountToDeal)
		end
	elseif hit:GetAttribute("damageable") == "pod" then -- is it a pod
		print("Damage pod")
		-- do damage to pod
		-- Pod parts marked as damageable should have the following tags, which specify which slot
		-- it is from, and which segment of the pod is damaged
		local component = hit:GetAttribute("damageComponent")
		local slotNumber = hit:GetAttribute("slotNumberBelongs")
		if slotNumber and component then
			local thisPod = Pod.GetPodFromSlotNumber(slotNumber)
			if thisPod and thisPod.Owner ~= self.Owner then
				local thisInfo = statsDatabase["Swing"][self.Name]
				local thisDamage = thisInfo.baseDamage
				local sectionMultiplier = thisInfo.podDamage[component]
				local amountToDamage = thisDamage * sectionMultiplier
				thisPod:DamageSection(component,amountToDamage)
			end
		end
	end
end

function Swing:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
end

return Swing