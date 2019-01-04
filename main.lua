local manager = require 'roomy'.new()

local game, pause = {}, {}

function game:keypressed(key)
	if key == 'escape' then
		manager:push(pause, 'hiya!')
	end
	if key == 'space' then
		manager:switch(pause, 'switching')
	end
end

function game:pause()
	print 'pause'
end

function game:resume()
	print 'unpause'
end

function game:draw()
	love.graphics.print 'this is the gameplay state'
end

function pause:enter(previous, message)
	print(previous, message)
end

function pause:keypressed(key)
	manager:pop()
end

function pause:draw()
	love.graphics.print 'paused'
end

function love.load()
	manager:hook {
		callbacks = {'update', 'draw'},
		applyBefore = false,
	}
	manager:switch(game)
end
