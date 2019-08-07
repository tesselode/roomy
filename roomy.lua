local roomy = {}

local loveCallbacks = {
	'directorydropped',
	'draw',
	'filedropped',
	'focus',
	'gamepadaxis',
	'gamepadpressed',
	'gamepadreleased',
	'joystickaxis',
	'joystickhat',
	'joystickpressed',
	'joystickreleased',
	'joystickremoved',
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
	'joystickadded',
}

-- returns a list of all the items in t1 that aren't in t2
local function exclude(t1, t2)
	local set = {}
	for _, item in ipairs(t1) do set[item] = true end
	for _, item in ipairs(t2) do set[item] = nil end
	local t = {}
	for item, _ in pairs(set) do
		table.insert(t, item)
	end
	return t
end

local Manager = {}
Manager.__index = Manager

function Manager:emit(event, ...)
	local state = self._stack[#self._stack]
	if state[event] then state[event](state, ...) end
end

function Manager:enter(next, ...)
	local previous = self._stack[#self._stack]
	self:emit('leave', next, ...)
	self._stack[#self._stack] = next
	self:emit('enter', previous, ...)
end

function Manager:push(next, ...)
	local previous = self._stack[#self._stack]
	self:emit('pause', next, ...)
	self._stack[#self._stack + 1] = next
	self:emit('enter', previous, ...)
end

function Manager:pop(...)
	local previous = self._stack[#self._stack]
	local next = self._stack[#self._stack - 1]
	self:emit('leave', next, ...)
	self._stack[#self._stack] = nil
	self:emit('resume', previous, ...)
end

function Manager:hook(options)
	options = options or {}
	local callbacks = options.include or loveCallbacks
	if options.exclude then
		callbacks = exclude(callbacks, options.exclude)
	end
	for _, callbackName in ipairs(callbacks) do
		local oldCallback = love[callbackName]
		love[callbackName] = function(...)
			if oldCallback then oldCallback(...) end
			self:emit(callbackName, ...)
		end
	end
end

function roomy.new()
	return setmetatable({
		_stack = {{}},
	}, Manager)
end

return roomy
