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
    ├── loads services/*.lua ──► require + count (initialized once, no start())
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
workspace/
├── Client/                    ← local rendering folder (per-player visuals)
└── Server/                    ← replication/rendering folder (all players)

ReplicatedStorage/
└── shared/                    ← shared code
    ├── definitions/           ← data contracts/schemas (types, enums, constants)
    ├── events/                ← RemoteEvent/RemoteFunction wrappers
    ├── index/                 ← pure data tables (return { ... }, no methods)
    ├── registry/              ← data modules returning tables directly
    ├── packages/              ← external libs (Warp, KoltStore, Spring, etc.)
    └── utils/                 ← pure functions (+ *Helper modules for queries)

ServerScriptService/
└── server/                    ← authoritative logic
    ├── bootstrapper           ← Script (entry point)
    ├── classes/               ← stateful domain objects
    ├── controllers/           ← orchestrate systems; function controllerName:start()
    ├── services/              ← long-lived; initialized once; return 0; no start()
    └── utils/                 ← server-only helpers

StarterPlayer/StarterPlayerScripts/
└── client/                    ← presentation and prediction
    ├── bootstrapper           ← LocalScript (entry point)
    ├── classes/               ← remote entity clients
    ├── entities/              ← client game object representations
    ├── controllers/           ← input handlers, camera, animations; start()
    ├── services/              ← AudioService, TweenService wrappers; return 0
    ├── ui/
    │   ├── frames/            ← individual ScreenGui components
    │   ├── helpers/           ← UI interaction helpers
    │   └── hud                ← ModuleScript (UI bootstrapper; return 0)
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

## Code rules

These are strict conventions baked into the architecture:

| Rule | Detail |
|---|---|
| **English only** | Identifiers, strings, logs, error messages. Zero Portuguese in code. |
| **No comments** | Unless explicitly requested. |
| **camelCase** | Local variables, member values, functions, params, table keys. |
| **PascalCase** | Types/classes and Roblox API references. |
| **LOUD_SNAKE_CASE** | `const` bindings holding config or service references. Enum members exempt. |
| **Services always `const`** | Never `local`. Module refs, configs, singletons: `const`. Mutable state, loop counters, accumulators: `local`. |

---

## Writing your first module

### Service

A service is a long-lived infrastructure module. It initializes once when required and returns `0`. No `start()` method.

```lua
-- server/services/DataStoreService.lua
const DataStoreService = game:GetService("DataStoreService")

const store = DataStoreService:GetDataStore("PlayerData_v1")

local function loadData(player: Player): {[string]: any}?
	local ok, result = pcall(store.GetAsync, store, `player_{player.UserId}`)
	if not ok then
		warn(`[DataService] Load failed for {player.Name}: {result}`)
		return nil
	end
	return result
end

local function saveData(player: Player, data: {[string]: any}): boolean
	local ok, err = pcall(store.SetAsync, store, `player_{player.UserId}`, data)
	if not ok then
		warn(`[DataService] Save failed for {player.Name}: {err}`)
		return false
	end
	return true
end

return {
	Load = loadData,
	Save = saveData,
}
```

### Controller

A controller orchestrates a system using its lifecycle hook. Must return `{ start = function(self) }`. The bootstrapper calls `start()` after all services load.

```lua
-- server/controllers/PlayerJoinController.lua
const Players = game:GetService("Players")
const DataService = require(script.Parent.Parent.services.DataStoreService)

local function onPlayerAdded(player: Player)
	local data = DataService.Load(player)
	if not data then
		data = { coins = 0, level = 1 }
	end
	player:SetAttribute("Coins", data.coins)
	player:SetAttribute("Level", data.level)
end

local function onPlayerRemoving(player: Player)
	DataService.Save(player, {
		coins = player:GetAttribute("Coins"),
		level = player.GetAttribute("Level"),
	})
end

return {
	start = function(self)
		Players.PlayerAdded:Connect(onPlayerAdded)
		Players.PlayerRemoving:Connect(onPlayerRemoving)
	end,
}
```

### Registry / Index module

Pure data contracts. Return the table directly. No intermediate variable. No `table.freeze()`.

```lua
-- shared/registry/weapons.lua
return {
	{
		id = "sword_basic",
		name = "Iron Sword",
		damage = 15,
	},
	{
		id = "bow_hunter",
		name = "Hunter Bow",
		damage = 22,
	},
}
```

Wrong (do NOT do this):

```lua
local weapons = {}
weapons.sword = { damage = 15 }
table.freeze(weapons)
return table.freeze(weapons)
```

Correct:

```lua
return {
	sword = { damage = 15 },
}
```

### HUD Frame

Each frame in `client/ui/frames/` is a ModuleScript that returns a function. The `hud` runner calls them all in parallel via `task.spawn`.

```lua
-- client/ui/frames/CoinCounter.lua
const CoinsLabel = script.Parent:WaitForChild("CoinsLabel"):: TextLabel
const LocalPlayer = game.Players.LocalPlayer

return function()
	LocalPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
		local coins = LocalPlayer:GetAttribute("Coins")
		CoinsLabel.Text = `${coins} coins`
	end)
end
```

---

## Contracts

| Path | Type | Contract |
|---|---|---|
| `*/services/*.lua` | ModuleScript | Long-lived infrastructure. Initializes once. Returns table with public methods OR `return 0` if side-effect only. No `start()`. Require failure aborts that service but continues others. |
| `*/controllers/*.lua` | ModuleScript | Orchestration layer. Returns `{ start: (self) -> () }`. Bootstrapper validates type and presence of `start`. Called after all services load. |
| `shared/index/*.lua` | ModuleScript | Pure data. Direct `return { ... }`. No intermediate var. No freeze. Query/filter/lookup goes in `shared/utils/*Helper`. |
| `shared/registry/*.lua` | ModuleScript | Single expression `return { key = value, ... }`. Never assign to local first. Never wrap in `table.freeze()`. |
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
