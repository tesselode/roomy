## What are gamestates?

A **gamestate** is an isolated section of a game. They're commonly thought of as "screens". For example, a game might have a title screen, a gameplay screen, and a pause screen. Each of these screens would make sense to represent as a different gamestate.

Gamestates are a useful organizational tool for game code. Each state has different behavior for each LÖVE callback or other event, so it makes sense to write each one in a separate section of the code. Roomy also fosters passing information to states when switching between them. For example, when switching to a gameplay state, you might want to specify the filename of a level to load. A gamestate system might call an "enter" event on the gameplay state and pass the filename of the level to the `enter` function.

You don't need Roomy or any other gamestate library to use the idea of gamestates in your code, but a library might already do everything you need. In which case, you may as well use it!

## Usage

### Defining gamestates

A gamestate is just a table with a number of callbacks defined as self functions. A typical gamestate will at least have some combination of Roomy and LÖVE callbacks. For example, a gameplay state may look like this:

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

### Creating a gamestate manager
```lua
local manager = roomy.new()
```

### Switching states
```lua
manager:switch(state, ...)
```

### Pushing states
```lua
manager:push(state, ...)
```

### Popping states
```lua
manager:pop(...)
```

### Applying state changes
```lua
manager:apply()
```

When calling `switch`, `push`, or `pop`, changes are not applied immediately. Rather, they are queued up, and all changes are performed at once when `apply` is called. This allows you to choose a specific point in the game loop to apply state changes.

Note that if you use `manager.hook`, you don't have to call `apply` manually.

**Why not just apply changes immediately?** The main reason to queue state changes for later instead of applying them immediately is so that events aren't passed to the wrong state. For example, if the state is switched in the `keypress` event, and then `mousepressed` is called right after, that event would be passed to the new state even though it occurred during the same frame as the keypress the first state received. This is unintuitive behavior that could theoretically lead to errant inputs on the first frame of a new state.

### Emitting events
```lua
manager:emit(event, ...)
```

### Hooking into LÖVE callbacks
```lua
manager:hook(options)
```
