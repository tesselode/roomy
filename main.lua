local manager = require 'roomy'.new()

local game, pause = {}, {}

function game:keypressed(key)
	if key == 'escape' then
		manager:push(pause, 'hiya!')
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

function pause:leave()
	print 'im getting popped now'
end

function pause:draw()
	love.graphics.print 'paused'
end

function love.load()
	manager:hook()
	manager:switch(game)
end

function love.draw()
	love.graphics.print(math.floor(collectgarbage 'count') .. 'kb', 0, 32)
end
