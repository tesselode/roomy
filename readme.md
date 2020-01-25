# Roomy

**Roomy** is a screen management library for LÖVE. It helps organize game code by the different "screens" in the game, such as the title screen, gameplay screen, and pause screen.

## Installation

To use Roomy, place roomy.lua in your project, and then `require` it in each file where you need to use it:

```lua
local roomy = require 'roomy' -- if your roomy.lua is in the root directory
local roomy = require 'path.to.roomy' -- if it's in subfolders
```

## Usage

### Defining screens

A screen is defined as a table with functions for each event it should respond to. For example, a gameplay screen may look like this:

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
manager:enter(screen, ...)
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

### Emitting events

```lua
manager:emit(event, ...)
```

Calls `screen:[event]` on the active screen if that function exists. Additional arguments are passed to `screen.event`.

### Hooking into LÖVE callbacks

```lua
manager:hook(options)
```

Adds code to the LÖVE callbacks to emit events for each callback (previously defined behavior will be preserved). `options` is an optional table with the following keys:
- `include` - a list of callbacks to hook into. If this is defined, *only* these callbacks will be overridden.
- `exclude` - a list of callbacks *not* to hook into. If this is defined, all of the callbacks except for these ones will be overridden.

As an example, the following code will cause the screen manager to hook into every callback except for `keypressed` and `mousepressed`.

```lua
manager:hook {
	exclude = {'keypressed', 'mousepressed'},
}
```

**Note:** because this function overrides the LOVE callbacks, you'll want to call this *after* you've defined them. I recommend using this function in the body of `love.load`, like this:

```lua
function love.load()
	manager:hook()
	manager:enter(gameplay)
end
```

### Screen callbacks

Screens have a few special callbacks that are called when a screen is switched, pushed, or popped.

```lua
function screen:enter(previous, ...) end
```

Called when a manager switches *to* this screen or if this screen is pushed on top of another screen.
- `previous` - the previously active screen, or `false` if there was no previously active screen
- `...` - additional arguments passed to `manager.switch` or `manager.push`

```lua
function screen:leave(next, ...) end
```

Called when a manager switches *away from* this screen or if this screen is popped from the stack.
- `next` - the screen that will be active next
- `...` - additional arguments passed to `manager.switch` or `manager.pop`

```lua
function screen:pause(next, ...) end
```

Called when a screen is pushed on top of this screen.
- `next` - the screen that was pushed on top of this screen
- `...` - additional arguments passed to `manager.push`

```lua
function screen:resume(previous, ...) end
```

Called when a screen is popped and this screen becomes active again.
- `previous` - the screen that was popped
- `...` - additional arguments passed to `manager.pop`
