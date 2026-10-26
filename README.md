# rbx-ddd-architecture

DDD architecture for Roblox Studio. Services, controllers, HUD bootstrap.

## Install

### Option 1: Copy-paste script

1. Open `install.lua` from this repo.
2. In Roblox Studio, create a new **Script** in ServerScriptService.
3. Paste contents and run.
4. Folder tree builds automatically.

### Option 2: HttpService fetch

1. Enable HttpService (Game Settings > Security > Allow HTTP Requests).
2. Create a Script in ServerScriptService with:

```lua
local HttpService = game:GetService("HttpService")
local url = "https://raw.githubusercontent.com/tlipe/rbx-ddd-architecture/master/install.lua"
local ok, source = pcall(HttpService.GetAsync, HttpService, url)
if not ok then error(source) end
loadstring(source)()
```

3. Run.

## Structure

```
shared/          (ReplicatedStorage)
  definitions/
  events/
  index/
  packages/
  utils/
server/          (ServerScriptService)
  bootstrapper   (Script)
  classes/
  controllers/
  services/
  utils/
client/          (StarterPlayerScripts)
  bootstrapper   (LocalScript)
  classes/
  entities/
  controllers/
  services/
  ui/
    frames/
    helpers/
    hud          (ModuleScript)
  utils/
```

## Controller contract

Each controller module must return a table with `start`:

```lua
return {
	start = function(self)
		-- init logic
	end
}
```

Bootstrapper loads all modules in `services/` and `controllers/`, calls `start()` on each controller, sets `workspace.ServerLoaded = true` when clean.

## Version

Current: 1.1.0
