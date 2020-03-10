local roomy = {
	_VERSION = 'Roomy',
	_DESCRIPTION = 'Scene management for LÖVE.',
	_URL = 'https://github.com/tesselode/roomy',
	_LICENSE = [[
		MIT License

		Copyright (c) 2019 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

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
	local scene = self._scenes[#self._scenes]
	if scene[event] then scene[event](scene, ...) end
end

function Manager:enter(next, ...)
	local previous = self._scenes[#self._scenes]
	self:emit('leave', next, ...)
	self._scenes[#self._scenes] = next
	self:emit('enter', previous, ...)
end

function Manager:push(next, ...)
	local previous = self._scenes[#self._scenes]
	self:emit('pause', next, ...)
	self._scenes[#self._scenes + 1] = next
	self:emit('enter', previous, ...)
end

function Manager:pop(...)
	local previous = self._scenes[#self._scenes]
	local next = self._scenes[#self._scenes - 1]
	self:emit('leave', next, ...)
	self._scenes[#self._scenes] = nil
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
		_scenes = {{}},
	}, Manager)
end

return roomy
