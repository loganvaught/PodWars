-- While following tutorial by CoodSlayer on Youtube
-- NOT USED IN PODWARS YET

local FSM = {}
FSM.__index = FSM

function FSM.new(states: {string})
	local newFSM = {}
	setmetatable(newFSM,FSM)
	
	newFSM.validStates = states
	newFSM.currentState = nil
	
	-- function lists
	
	newFSM.beforeLeave = {}
	newFSM.beforeEnter = {}
	newFSM.afterLeave = {}
	newFSM.afterEnter = {}
	
	-- structure: (Old state means state coming from, newstates mean states cannot transition to)
	-- {
	--		[oldState] = newstate1, newstate2, newstate3
	-- }
	newFSM.invalidTransitions = {}
	
	newFSM.specificTransitions = {} -- useful for additional functions for specific transitions? idk
	
	for _,v in ipairs(states) do -- adding the functions. structure: newFSM.before____[state] = {}: {function}
		newFSM.beforeLeave[v] = {}
		newFSM.beforeEnter[v] = {}
		newFSM.afterLeave[v] = {}
		newFSM.afterEnter[v] = {}
		newFSM.invalidTransitions[v] = {} -- contains invalid transitions, 
		
		for _,b in ipairs(states) do
			if v == b then continue end -- to not add a specific transition table for a state going to the same state	
			 newFSM.specificTransitions[v][b] = {} -- for every state, assigns a table indexed with other states, and valued with specific functions
		end
	end
	
	return newFSM
end

function FSM:changeState(newState: string)
	if not table.find(self.validStates,newState) then return end -- this isnt a valid state
	local oldState = self.currentState
	if oldState == newState then return end -- the state is the same
	
	-- Now, begin procedure for doing: before leave, before enter, after leave, after enter
	
	-- Before callbacks
	
	if oldState then -- there was a state before this. Ensure its a valid transition, then call before callbacks
		-- is valid transition?
		if self.invalidTransitions[oldState][newState] then
			return
		end
		
		-- doing before leave callbacks
		for _,v in pairs(self.beforeLeave[oldState]) do
			v() -- perform the function for the old state
		end
	end
	
	for _,v in pairs(self.beforeEnter[oldState]) do -- Before entering the new state, do the functions
		v() -- perform the function for the old state
	end
	
	if oldState then -- executing any necessary specific functions for this transition
		for _,v in pairs(self.specificTransitions[oldState][newState]) do
			v()
		end
	end
	
	self.currentState = newState -- ASSIGNING NEW STATE
	
	-- After callbacks
	
	for _,v in pairs(self.afterLeave[oldState]) do -- After leaving the new state, do the functions
		v()
	end

	for _,v in pairs(self.afterEnter[oldState]) do -- After entering the new state, do the functions
		v() 
	end
end

return FSM