# Roomy

**Roomy** is a screen management library for LÖVE. It facilitates organizing game code by the different "screens" in the game, such as the title screen, gameplay screen, and pause screen.

## Installation

To use Roomy, place roomy.lua in your project, and then `require` it in each file where you need to use it:

```lua
local roomy = require 'roomy' -- if your roomy.lua is in the root directory
local roomy = require 'path.to.roomy' -- if it's in subfolders
```

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

### Applying screen changes

```lua
manager:apply()
```

Calling `switch`, `push`, and `pop` does not apply screen changes immediately. Rather, they are queued up and applied all at once when `apply` is called. Placing `manager.apply` at a specific point in the game loop (right before updating, for instance) alleviates some potential issues with inputs meant for one screen being sent to another screen.

Note that if you use `manager.hook`, you don't need to call this manually.

### Emitting events

```lua
manager:emit(event, ...)
```

Calls `screen:[event]` on the active screen if that function exists.

### Hooking into LÖVE callbacks

```lua
manager:hook(options)
```

Adds code to the LÖVE callbacks to emit events for each callback (previously defined behavior will be preserved). `options` is an optional table with the following keys:
- `applyBefore` - the name of the callback to run `manager:apply()` at the start of. Set this to `false` to disable this behavior. Defaults to `update`.
- `callbacks` - a list of callbacks to hook into. Defaults to all LÖVE callbacks (except for `errhand`).
- `skip` - a list of callbacks not to hook into. If defined, all LÖVE callbacks will be hooked except for the ones in this list. Note that you will get an error if you define both `callbacks` and `skip`.

As an example, the following code will cause the screen manager to hook into every callback except for `keypressed` and `mousepressed`, and screen changes will be applied at the beginning of `love.draw`.

```lua
manager:hook {
	skip = {'keypressed', 'mousepressed'},
	applyBefore = 'draw',
}
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

## License

MIT License

Copyright (c) 2019 Andrew Minnich

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
