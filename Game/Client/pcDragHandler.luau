local plr = game:GetService("Players").LocalPlayer
local PlrScripts = plr:WaitForChild("PlayerScripts")
local PlrGui = plr:WaitForChild("PlayerGui")
local uip = game:GetService("UserInputService")
local cs = game:GetService("CollectionService")

local InventoryItem = require(PlrScripts:WaitForChild("InventoryItem"))
local screenGui = PlrGui:WaitForChild("main")
local canvas = screenGui:WaitForChild("canvas")
local rs = game:GetService("RunService")

-- InventoryItems have a tag: "interactable" attached to the main frame
-- Locations (like hotbar slots, inventory segment) have "snapPoint" attached to the main frame

local canUse = false
local isMobile = uip.TouchEnabled and not uip.KeyboardEnabled
if isMobile then
	script:Destroy()
else
	canUse = true
	print("PodWars detected that you were on a non-mobile device. Note: PC or Mobile Only!")
end

if not canUse then return end

-- dragging properties
local isClicking = false
local isDragging = false
local frameFrom = nil
local itemFrom = nil
local tracer = nil
local inputPosition = nil
local storedInput = nil
-- end dragging properties

local function getFirstElementWithTag(tag,position)
	local elements = PlrGui:GetGuiObjectsAtPosition(position.X,position.Y)
	for _,v in pairs(elements) do
		if cs:HasTag(v,tag) then
			-- frame belongs to a InventoryItem
			return v
		end
	end
	return nil
end

local function resetClick() -- gets rid of the current click, regardless of state.
	if isDragging == true and itemFrom then
		itemFrom:RemoveTracer()
		tracer = nil
		isDragging = false
	end
	frameFrom = nil
	isClicking = false
	itemFrom = nil
	inputPosition = nil
	storedInput = nil
end

local function isPositionInsideElement(position,element)
	local elementPosition = element.AbsolutePosition
	local elementSize = element.AbsoluteSize
	local xIsIn = position.X >= elementPosition.X and position.X <= elementPosition.X + elementSize.X
	local yIsIn = position.Y >= elementPosition.Y and position.Y <= elementPosition.Y + elementSize.Y
	return xIsIn and yIsIn
end

rs.RenderStepped:Connect(function()
	if isClicking and inputPosition then -- currently, the user is clicking on an important item, or dragging it
		if isDragging == true then -- currently dragging
			if tracer ~= nil then
				tracer.Position = UDim2.new(0,inputPosition.X,0,inputPosition.Y)
				-- update location of the draggable item
				-- ensure draggable item has not been destroyed. If it has, the draggable item has been removed. Halt dragging
			end
		else -- not dragging, check if needs to be
			-- check if mouse is outside the frame

			if not isPositionInsideElement(inputPosition,frameFrom) then
				print("STARTING DRAG")
				-- start dragging
				-- clone the item picture to follow the mouse
				tracer = itemFrom:MakeTracer()
				if tracer then -- tracer successfully made
					tracer.Size = UDim2.new(0.1,0,0.1,0)
					tracer.Position = UDim2.new(0,inputPosition.X,0,inputPosition.Y)
					tracer.Parent = canvas
					isDragging = true
				end
			end
		end
	end
end)

local clickDebounce = false -- the window in which a click could be registered as a potential useage
uip.InputBegan:Connect(function(input) -- mouse click starts
	if input.UserInputType == Enum.UserInputType.MouseButton1 and clickDebounce == false then -- there should only be one mouse button 1 registered at a time
		-- click
		clickDebounce = true
		if isClicking == true then
			-- was already tracking an input. just make this the new one
			resetClick()
		end
		local itemOf = getFirstElementWithTag("item",input.Position)
		if itemOf then -- this was a special item
			local thisInventoryitem = InventoryItem.GetObjectFromFrame(itemOf)
			if thisInventoryitem then
				frameFrom = itemOf
				itemFrom = thisInventoryitem
				storedInput = input
				inputPosition = input.Position
				isClicking = true
				print("Clicked")
			end
		end
		task.wait(0.1) -- wait 0.1 seconds before re-enabling the window
		clickDebounce = false
	end
end)

uip.InputChanged:Connect(function(input) -- mouse position changes
	if isClicking == true and input.UserInputType == Enum.UserInputType.MouseMovement then
		inputPosition = input.Position
	end
end)

uip.InputEnded:Connect(function(input) -- mouse click ends
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isClicking == true and itemFrom then
			if input == storedInput then
				if isDragging == true then -- this input was dragging an item
					if tracer then -- sometimes the tracer can be destroyed if a user consumes the item, signaling the item doesnt exist. so this is an extra safety step
						local frame = getFirstElementWithTag("snapPoint",input.Position) 
						if frame then
							local locationAttribute = frame:GetAttribute("location")
							if locationAttribute then
								itemFrom:Move(locationAttribute)
							end
						end
					end
					resetClick()
				else -- this input did not start to drag the item
					-- user clicked on this item
					itemFrom:Click() 
					resetClick()
				end
			else
				print("Tried to end a clicking state, but the start and end didnt match")
				resetClick() -- might have errored because there should theoretically only be one click going at a time
			end
		end
	end
end)