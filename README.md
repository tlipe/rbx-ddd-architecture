<div align="center">

# RBX DDD Architecture

**Domain-Driven Design for Roblox Studio.**

One-click install. Automatic server/client bootstrapper. Ready-made conventions for games of any scale.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](#)
[![Roblox](https://img.shields.io/badge/Roblox-Luau-red.svg)](https://www.roblox.com)

</div>

---

## Why use it

| Benefit | Detail |
|---|---|
| **Instant setup** | One script builds the entire folder tree, bootstrappers, and contracts. Zero manual configuration. |
| **Convention over configuration** | Services load themselves. Controllers register `start()`. No manual wiring between modules. |
| **Synchronized server-client** | Client waits for `ServerLoaded` before initializing. No race conditions at startup. |
| **Scale without refactoring** | Start with 3 services, grow to 30 without changing the structure. Add a module in the right folder, it's ready. |
| **Native observability** | LogService integrated. Every load/failure appears in the Studio Output with clear context. |
| **Explicit contract** | Typed interfaces (`Controller`, service return). Contract errors fail at load time, not silent runtime. |

---

## How it works

### Initialization flow

```
Studio Play
    │
    ▼
server/bootstrapper (Script)
    ├── loads services/*.lua ──► require + count
    ├── loads controllers/*.lua ──► require + validates start()
    ├── executes controller:start() in order
    └── workspace.ServerLoaded = true
            │
            ▼
client/bootstrapper (LocalScript)
    ├── awaits ServerLoaded (GetAttributeChangedSignal)
    ├── loads services/*.lua
    ├── loads controllers/*.lua
    ├── loads ui/hud
    └── workspace.ClientLoaded = true
```

### Generated tree

```
ReplicatedStorage/
└── shared/                    ← shared code
    ├── definitions/           ← types, enums, constants
    ├── events/                ← RemoteEvent/RemoteFunction wrappers
    ├── index/                 ← barrel exports
    ├── packages/              ← external libs
    └── utils/                 ← pure helpers

ServerScriptService/
└── server/                    ← authoritative logic
    ├── bootstrapper           ← Script (entry point)
    ├── classes/               ← domain models (DDD entities/value objects)
    ├── controllers/           ← use case orchestration
    ├── services/              ← infrastructure (DataStore, HTTP, messaging)
    └── utils/                 ← server-only helpers

StarterPlayer/StarterPlayerScripts/
└── client/                    ← presentation and prediction
    ├── bootstrapper           ← LocalScript (entry point)
    ├── classes/               ← remote entity clients
    ├── entities/              ← local player/world states
    ├── controllers/           ← input handlers, camera, animations
    ├── services/              ← AudioService, TweenService wrappers
    ├── ui/
    │   ├── frames/            ← individual ScreenGui components
    │   ├── helpers/           ← UI utilities (layout, theme)
    │   └── hud                ← ModuleScript (orchestrates frames)
    └── utils/                 ← client-only helpers
```

---

## Installation

<div align="center">

### Option A — Copy and paste

Open [`install.lua`](install.lua), paste into a new Script in ServerScriptService, run. Done.

</div>

### Option B — HttpService (remote download)

1. Game Settings → Security → **Allow HTTP Requests**: ON
2. Create a Script in ServerScriptService:

```lua
local HttpService = game:GetService("HttpService")
local url = "https://raw.githubusercontent.com/tlipe/rbx-ddd-architecture/main/install.lua"
local ok, source = pcall(HttpService.GetAsync, HttpService, url)
if not ok then error(source) end
loadstring(source)()
```

3. Run. The script downloads the latest version straight from GitHub.

---

## Writing your first module

### Service

A service is a ModuleScript that returns a table with methods. No need to call anything special — the bootstrapper does `require` automatically.

```lua
-- server/services/DataStoreService.lua
local DataStoreService = game:GetService("DataStoreService")

local store = DataStoreService:GetDataStore("PlayerData_v1")

return {
	Load = function(player: Player): {[string]: any}?
		local ok, result = pcall(store.GetAsync, store, `player_{player.UserId}`)
		if not ok then
			warn(`[DataService] Load failed for {player.Name}: {result}`)
			return nil
		end
		return result
	end,

	Save = function(player: Player, data: {[string]: any}): boolean
		local ok, err = pcall(store.SetAsync, store, `player_{player.UserId}`, data)
		if not ok then
			warn(`[DataService] Save failed for {player.Name}: {err}`)
			return false
		end
		return true
	end,
}
```

### Controller

A controller must return `{ start = function(self) }`. The bootstrapper calls `start()` after all services load.

```lua
-- server/controllers/PlayerJoinController.lua
local Players = game:GetService("Players")
local DataService = require(script.Parent.Parent.services.DataStoreService)

return {
	start = function(self)
		Players.PlayerAdded:Connect(function(player)
			local data = DataService.Load(player)
			if not data then
				data = { coins = 0, level = 1 }
			end
			player:SetAttribute("Coins", data.coins)
			player:SetAttribute("Level", data.level)
		end)

		Players.PlayerRemoving:Connect(function(player)
			DataService.Save(player, {
				coins = player:GetAttribute("Coins"),
				level = player:GetAttribute("Level"),
			})
		end)
	end,
}
```

### HUD Frame

Each frame in `client/ui/frames/` is a ModuleScript that returns a function. The `hud` runner calls them all in parallel via `task.spawn`.

```lua
-- client/ui/frames/CoinCounter.lua
local CoinsLabel = script.Parent:WaitForChild("CoinsLabel"):: TextLabel

return function()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		-- reposition logic
	end)

	game.Players.LocalPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
		local coins = game.Players.LocalPlayer:GetAttribute("Coins")
		CoinsLabel.Text = `${coins} coins`
	end)
end
```

---

## Contracts

| Path | Type | Contract |
|---|---|---|
| `*/services/*.lua` | ModuleScript | Returns `table`. Any public method. Require failure aborts that service but continues others. |
| `*/controllers/*.lua` | ModuleScript | Returns `{ start: (self) -> () }`. Bootstrapper validates type and presence of `start`. |
| `client/ui/frames/*.lua` | ModuleScript | Returns `function()`. Executed in `task.spawn` by the HUD runner. |
| `client/ui/hud` | ModuleScript | Internal orchestrator. Do not modify without understanding the frame loop. |

---

## Debugging

All logs use structured prefixes:

```
[SERVICE] Loading DataStoreService...
[SERVICE] Loaded DataStoreService.
[CONTROLLER] Registered PlayerJoinController.
[CONTROLLER] Start failed #2: attempt to index nil value
[SERVER] Server fully loaded in 0.04s.
[CLIENT] Waiting for server...
[CLIENT] Server loaded. Timestamp: 1730000000
[HUD] Bootstrap runtime error: CoinCounter -> ...
```

If `ServerLoaded` stays `false`, open the Output and look for `[SERVICE] Failed` or `[CONTROLLER]` with an error. Fix the problematic module; the bootstrapper won't advance with failures.

---

## Versioning

| Version | Changes |
|---|---|
| 1.1.0 | Server/client bootstrapper separation, HUD frame runner, contract validation |
| 1.0.0 | Initial structure, tree builder, log_stdio |

---

## License

MIT. Use freely in commercial and personal projects.
