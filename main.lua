local manager = require 'roomy'.new()

local state = {}

state.title = {}

function state.title:keypressed(key)
	if key == 'return' then
		manager:enter(state.gameplay, 'hi!')
	end
end

function state.title:leave(next, ...)
	print('leaving the title screen for', next, ...)
end

function state.title:draw()
	love.graphics.print 'title'
end

state.gameplay = {}

function state.gameplay:keypressed(key)
	if key == 'return' then
		manager:enter(state.title)
	elseif key == 'space' then
		manager:push(state.pause)
	end
end

function state.gameplay:pause(...)
	print('pause', ...)
end

function state.gameplay:resume(...)
	print('resume', ...)
end

function state.gameplay:draw()
	love.graphics.print 'gameplay'
end

state.pause = {}

function state.pause:keypressed(key)
	manager:pop(love.math.random(), love.math.random())
end

function state.pause:draw()
	love.graphics.print 'pause'
end

function love.load()
	manager:hook()
	manager:enter(state.title)
end

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end
