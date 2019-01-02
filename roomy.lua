local roomy = {}

local Manager = {}
Manager.__index = Manager

function Manager:_switch(state, ...)
	local previous = self.stack[#self.stack]
	if previous then self:emit('leave', state, ...) end
	self.stack[math.max(#self.stack, 1)] = state
	self:emit('enter', previous or false, ...)
end

function Manager:_push(state, ...)
	local previous = self.stack[#self.stack]
	if previous then self:emit('pause', state, ...) end
	self.stack[#self.stack + 1] = state
	self:emit('enter', previous or false, ...)
end

function Manager:_pop(...)
	if #self.stack == 0 then
		error('No state to pop', 3)
	end
	if #self.stack == 1 then
		error('Cannot pop a state when there is no state below it on the stack', 3)
	end
	local previous = self.stack[#self.stack]
	self.stack[#self.stack] = nil
	self:emit('resume', previous, ...)
end

function Manager:apply()
	if not self.action then return end
	if self.action.type == 'switch' then
		self:_switch(self.action.state, unpack(self.action.args))
	elseif self.action.type == 'push' then
		self:_push(self.action.state, unpack(self.action.args))
	elseif self.action.type == 'pop' then
		self:_pop(unpack(self.action.args))
	end
	self.action = nil
end

function Manager:switch(state, ...)
	self.action = {type = 'switch', state = state, args = {...}}
end

function Manager:push(state, ...)
	self.action = {type = 'push', state = state, args = {...}}
end

function Manager:pop(...)
	self.action = {type = 'pop', args = {...}}
end

function Manager:emit(event, ...)
	local state = self.stack[#self.stack]
	if not state then return end
	if state[event] then state[event](state, ...) end
end

local defaultHookOptions = {
	callbacks = {
		'directorydropped',
		'draw',
		'filedropped',
		'focus',
		'keypressed',
		'keyreleased',
		'load',
		'lowmemory',
		'mousefocus',
		'mousemoved',
		'mousepressed',
		'mousereleased',
		'quit',
		'resize',
		'run',
		'textedited',
		'textinput',
		'threaderror',
		'touchmoved',
		'touchpressed',
		'touchreleased',
		'update',
		'visible',
		'wheelmoved',
	},
	applyBefore = 'update',
}

function Manager:hook(options)
	options = options or defaultHookOptions
	for _, callbackName in ipairs(options.callbacks) do
		local oldCallback = love[callbackName]
		love[callbackName] = function(...)
			if oldCallback then oldCallback(...) end
			if callbackName == options.applyBefore then
				self:apply()
			end
			self:emit(callbackName, ...)
		end
	end
end

function roomy.new()
	local manager = setmetatable({
		stack = {},
		action = nil,
	}, Manager)
	return manager
end

return roomy
