local machine = {}

export type state = {
    Name: string,
    OnEnter: (...any) -> (),
    OnExit: (...any) -> ()
}

export type stateMachine = {
    States: { [string]: state },
    CurrentState: string?,
    AddState: (stateMachine, state) -> (),
    Transition: (stateMachine, string, ...any) -> ()
}

function machine.Create()
    local newMachine: stateMachine = {
        States = {},
        CurrentState = nil,

        AddState = function(self, newState)
            assert(self.States[newState.Name] == nil, "State already exists: " .. newState.Name)
            self.States[newState.Name] = newState
        end,

        Transition = function(self, stateName, ...)
            local state = self.States[stateName]
			assert(state ~= nil, "State " .. stateName .. " does not exist")

			if self.CurrentState then
				self.States[self.CurrentState].OnExit(self, ...)
			end

			self.CurrentState = stateName
			state.OnEnter(self, ...)
        end
    }
    
    return newMachine
end

return machine