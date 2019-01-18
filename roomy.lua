local roomy = {}

local unpack = unpack or table.unpack -- luacheck: ignore

local loveCallbacks = {
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

function Manager:switch(screen, ...)
	local args = {...}
	table.insert(self.queue, function()
		local previous = self.stack[#self.stack]
		if previous then self:emit('leave', screen, unpack(args)) end
		-- if there is no screen on the stack yet, make sure the index is still 1
		local currentStackPosition = math.max(#self.stack, 1)
		self.stack[currentStackPosition] = screen
		self:emit('enter', previous or false, unpack(args))
	end)
end

function Manager:push(screen, ...)
	local args = {...}
	table.insert(self.queue, function()
		local previous = self.stack[#self.stack]
		if previous then self:emit('pause', screen, unpack(args)) end
		self.stack[#self.stack + 1] = screen
		self:emit('enter', previous or false, unpack(args))
	end)
end

function Manager:pop(...)
	local args = {...}
	table.insert(self.queue, function()
		if #self.stack == 0 then
			error('No screen to pop', 3)
		end
		if #self.stack == 1 then
			error('Cannot pop a screen when there is no screen below it on the stack', 3)
		end
		local previous = self.stack[#self.stack]
		self.stack[#self.stack] = nil
		self:emit('resume', previous, unpack(args))
	end)
end

function Manager:apply()
	while #self.queue > 0 do
		self.queue[1]()
		table.remove(self.queue, 1)
	end
end

function Manager:emit(event, ...)
	local screen = self.stack[#self.stack]
	if not screen then return end
	if screen[event] then screen[event](screen, ...) end
end

function Manager:hook(options)
	if options and options.callbacks and options.skip then
		error('Cannot define both callbacks and skip lists', 2)
	end
	local applyBefore = 'update'
	if options and options.applyBefore ~= nil then
		applyBefore = options.applyBefore
	end
	local callbacks = loveCallbacks
	if options then
		if options.callbacks then
			callbacks = options.callbacks
		elseif options.skip then
			callbacks = exclude(loveCallbacks, options.skip)
		end
	end
	for _, callbackName in ipairs(callbacks) do
		local oldCallback = love[callbackName]
		love[callbackName] = function(...)
			if oldCallback then oldCallback(...) end
			if callbackName == applyBefore then
				self:apply()
			end
			self:emit(callbackName, ...)
		end
	end
end

function roomy.new()
	local manager = setmetatable({
		stack = {},
		queue = {},
	}, Manager)
	return manager
end

return roomy
