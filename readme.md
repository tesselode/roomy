# Roomy

**Roomy** is a screen management library for LÖVE. It facilitates organizing game code by the different "screens" in the game, such as the title screen, gameplay screen, and pause screen.

## Installation

## Usage

### Defining screens

A screen is defined as a table with self functions for each event it should respond to. For example, a gameplay screen may look like this:

```lua
local gameplay = {}

function gameplay:enter(previous, ...)
	-- set up the level
end

function gameplay:update(dt)
	-- update entities
end

function gameplay:leave(next, ...)
	-- destroy entities and cleanup resources
end

function gameplay:draw()
	-- draw the level
end
```

A screen table can contain anything, but it will likely have some combination of functions corresponding to LÖVE callbacks and Roomy events.

### Creating a screen manager

```lua
local manager = roomy.new()
```

Creates a new screen manager. You can create as many screen managers as you want, but you'll most likely want one global manager for the main screens of your game.

### Switching screens

```lua
manager:switch(screen, ...)
```

Changes the currently active screen.

### Pushing/popping screens

```lua
manager:push(screen, ...)
manager:pop()
```

Managers use a stack to hold screens. You can push a screen onto the top of the stack, making it the currently active screen, and then pop it, resuming the previous state where it left off. This is useful for implementing pause screens, for example:

```lua
local pause = {}

function pause:keypressed(key)
	if key == 'escape' then
		manager:pop()
	end
end

local game = {}

function game:keypressed(key)
	if key == 'escape' then
		manager:push(pause)
	end
end
```
