<div align="center">

# RBX DDD Architecture

**Domain-Driven Design for Roblox Studio.**

One-click install. Automatic server/client bootstrapper. Ready-made conventions for games of any scale.

[![License: MPL-2.0](https://img.shields.io/badge/License-MPL--2.0-blue.svg)](LICENSE)
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
    ├── loads services/*.luau ──► require + count (initialized once, no start())
    ├── loads controllers/*.luau ──► require + validates start()
    ├── executes controller:start() in order
    └── workspace.ServerLoaded = true
            │
            ▼
client/bootstrapper (LocalScript)
    ├── awaits ServerLoaded (GetAttributeChangedSignal)
    ├── loads services/*.luau
    ├── loads controllers/*.luau
    ├── loads ui/hud
    └── workspace.ClientLoaded = true
```

### Generated tree

```
workspace/
├── Client/
└── Server/

ReplicatedStorage/
└── shared/
    ├── definitions/
    ├── events/
    ├── index/
    ├── registry/
    ├── packages/
    └── utils/

ServerScriptService/
└── server/
    ├── bootstrapper          (Script)
    ├── classes/
    ├── controllers/
    ├── services/
    └── utils/

StarterPlayer/StarterPlayerScripts/
└── client/
    ├── bootstrapper          (LocalScript)
    ├── classes/
    ├── entities/
    ├── controllers/
    ├── services/
    ├── ui/
    │   ├── frames/
    │   ├── helpers/
    │   └── hud               (ModuleScript)
    └── utils/
```

### Folder reference

#### workspace/Client

Folder holding all client-side rendered instances. Physical objects, visual effects, anything visible only to the local player.

#### workspace/Server

Folder holding all server-authoritative instances. Visible to every player. Replicated physical objects, world effects, shared visuals.

#### shared/definitions

Schemas, contracts, types, enums, constants. Dedicated to data shape agreements used across server and client.

#### shared/events

All server-client connections live here. RemoteEvents, RemoteFunctions, network library wrappers. Each connection gets its own ModuleScript named after the event (e.g. `purchaseItem.luauu`). Inside: code that fires/listens on that connection. Pattern:

```lua
-- code working with this event
return 0
```

#### shared/index

Pure data tables. Direct `return { ... }`. No methods attached. Query/filter/lookup helpers belong in `shared/utils/*Helper`.

#### shared/registry

Registrar / voter environment. Modules that record or annotate state, votes, registrations. Single expression `return { key = value, ... }`. Never assign to local first. Never `table.freeze()`.

#### shared/packages

ALL external libraries and ModuleScripts described as libraries. Usually added by the user (Warp, KoltStore, Spring, etc.). Nothing else lives here.

#### shared/utils

Helper/utility ModuleScripts shared by BOTH sides. Pure functions reusable from server and client.

#### server/bootstrapper

Script entry point. Loads services, then controllers, calls `start()` on each, sets `workspace.ServerLoaded`.

#### server/classes

Stateful domain objects. Classes/enums dedicated to specific game objects.

#### server/controllers

Orchestrate systems. Lifecycle hook: `function controllerName:start()`.

#### server/services

Long-lived infrastructure. Initialized once. `return 0`. No `start()` method.

#### server/utils

Helpers dedicated to the SERVER side and its neighbor folders (classes, controllers, services).

#### client/bootstrapper

LocalScript entry point. Waits for `ServerLoaded`, loads services, controllers, HUD, sets `workspace.ClientLoaded`.

#### client/classes

ModuleScripts dedicated to classes or enums of specific objects. Same purpose as `server/classes` but scoped to the client.

#### client/entities

ModuleScripts acting 100% on in-game entities renderable on the client. Requires a server-client connection strategy. Dedicated to optimization and rendering of entities (including players).

#### client/controllers

Input handlers, camera, animations. Uses `start()`.

#### client/services

AudioService/TweenService wrappers. `return 0`.

#### client/ui/frames

One ModuleScript per UI surface. The module name IS the UI it programs (e.g. `shopCoin.luauu`, `shopSwords.luau`, `inventoryFrame.luau`). Inside: normal code building that interface. Pattern:

```lua
-- code programming the determined interface
return 0
```

#### client/ui/helpers

Quick reusable helpers scoped to the frames folder. Shared utilities consumed by sibling frame modules.

#### client/ui/hud

ModuleScript orchestrating frames. Runs each frame via `task.spawn`. Returns `0`.

#### client/utils

Helpers dedicated to the CLIENT side and its neighbor folders (classes, entities, controllers, services).

---

## Installation

<div align="center">

### Option A — Copy and paste

Open [`install.luau`](install.luau), paste into a new Script in ServerScriptService, run. Done.

</div>

### Option B — HttpService (remote download)

1. Game Settings → Security → **Allow HTTP Requests**: ON
2. Create a Script in ServerScriptService:

```lua
local HttpService = game:GetService("HttpService")
local url = "https://raw.githubusercontent.com/tlipe/rbx-ddd-architecture/main/install.luau"
local ok, source = pcall(HttpService.GetAsync, HttpService, url)
if not ok then error(source) end
loadstring(source)()
```

3. Run. The script downloads the latest version straight from GitHub.

---

## Code rules

Strict conventions baked into the architecture:

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

Long-lived infrastructure. Initializes once when required. Returns `0` if side-effect only, OR a table with public methods. No `start()`.

```lua
-- server/services/DataStoreService.luau
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

Orchestrates a system using its lifecycle hook. Must return `{ start = function(self) }`. Bootstrapper calls `start()` after all services load.

```lua
-- server/controllers/PlayerJoinController.luau
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
		level = player:GetAttribute("Level"),
	})
end

return {
	start = function(self)
		Players.PlayerAdded:Connect(onPlayerAdded)
		Players.PlayerRemoving:Connect(onPlayerRemoving)
	end,
}
```

### Event (shared/events)

Each server↔client connection is one ModuleScript named after the event. Works alongside whatever network library lives in `shared/packages`.

```lua
-- shared/events/purchaseItem.luau
const Packages = script.Parent.Parent.packages
const NetworkLib = require(Packages.NetworkLib)

NetworkLib.define("purchaseItem", {
	fireServer = function(itemId: string, quantity: number)
		-- code working with this event
	end,
})

return 0
```

### Registry / Index module

Pure data contracts. Return the table directly. No intermediate variable. No `table.freeze()`.

```lua
-- shared/registry/weapons.luau
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

### HUD Frame (client/ui/frames)

One ModuleScript per UI surface. The module name IS the UI it programs. Inside: normal code building that interface. Runner spawns it in parallel.

```lua
-- client/ui/frames/shopCoin.luau
const CoinsLabel = script.Parent:WaitForChild("CoinsLabel"):: TextLabel
const LocalPlayer = game.Players.LocalPlayer

CoinsLabel.Text = `${LocalPlayer:GetAttribute("Coins")} coins`

LocalPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
	CoinsLabel.Text = `${LocalPlayer:GetAttribute("Coins")} coins`
end)

return 0
```

---

## Contracts

| Path | Type | Contract |
|---|---|---|
| `*/services/*.luau` | ModuleScript | Long-lived infrastructure. Initializes once. Returns table with public methods OR `return 0` if side-effect only. No `start()`. Require failure aborts that service but continues others. |
| `*/controllers/*.luau` | ModuleScript | Orchestration layer. Returns `{ start: (self) -> () }`. Bootstrapper validates type and presence of `start`. Called after all services load. |
| `shared/events/*.luau` | ModuleScript | One file per server↔client connection. Named after the event. Wraps the network library call. Ends with `return 0`. |
| `shared/index/*.luau` | ModuleScript | Pure data. Direct `return { ... }`. No intermediate var. No freeze. Query/filter/lookup goes in `shared/utils/*Helper`. |
| `shared/registry/*.luau` | ModuleScript | Registrar/voter environment. Single expression `return { key = value, ... }`. Never assign to local first. Never wrap in `table.freeze()`. |
| `shared/packages/*` | Folder | External libraries ONLY. User-added. Nothing project-specific belongs here. |
| `client/ui/frames/*.luau` | ModuleScript | One file per UI surface. Filename identifies the UI. Contains normal interface-building code. Ends with `return 0`. Spawned by HUD runner. |
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
[HUD] Bootstrap runtime error: shopCoin -> ...
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

Mozilla Public License 2.0. Free for commercial and personal use. Modifications to covered files must be shared under the same license.
