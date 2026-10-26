---
title: Contracts
description: "Module contracts for services, controllers, events, indexes, registries, packages, and HUD frames in the RBX DDD architecture."
---

# Contracts

A contract is what a module must return and how the bootstrapper treats it. Contract violations fail at load time with a logged error, not silently at runtime.

## Contract table

| Path | Type | Contract |
|---|---|---|
| `*/services/*.luau` | ModuleScript | Long-lived infrastructure. Initializes once. Returns table with public methods OR `return 0` if side-effect only. No `start()`. Require failure aborts that service but continues others. |
| `*/controllers/*.luau` | ModuleScript | Orchestration layer. Returns `{ start: (self) -> () }`. Bootstrapper validates type and presence of `start`. Called after all services load. |
| `shared/events/*.luau` | ModuleScript | One file per server-client connection. Named after the event. Wraps the network library call. Ends with `return 0`. |
| `shared/index/*.luau` | ModuleScript | Pure data. Direct `return { ... }`. No intermediate var. No freeze. Query/filter/lookup goes in `shared/utils/*Helper`. |
| `shared/registry/*.luau` | ModuleScript | Registrar/voter environment. Single expression `return { key = value, ... }`. Never assign to local first. Never wrap in `table.freeze()`. |
| `shared/packages/*` | Folder | External libraries ONLY. User-added. Nothing project-specific belongs here. |
| `client/ui/frames/*.luau` | ModuleScript | One file per UI surface. Filename identifies the UI. Contains normal interface-building code. Ends with `return 0`. Spawned by HUD runner. |
| `client/ui/hud` | ModuleScript | Internal orchestrator. Do not modify without understanding the frame loop. |

## Services

Initialize once when required. Either side-effect only (`return 0`) or a table of public methods. Never expose `start()`; the bootstrapper does not call one. A failing require kills that service only; the rest continue loading.

See [Service](/modules/service) for a full example.

## Controllers

Return exactly `{ start = function(self) }`. The bootstrapper requires every controller, validates the shape, then calls `start()` in order after all services are loaded. Missing `start` or a wrong type is a load-time error.

See [Controller](/modules/controller).

## Events

One ModuleScript per connection, named after the event. The module wraps the network library call and ends with `return 0`. It is required for its side effect of registering the connection, not for a return value.

```luau
-- shared/events/purchaseItem.luau
const Packages = script.Parent.Parent.packages
const NetworkLib = require(Packages.NetworkLib)

NetworkLib.define("purchaseItem", {
	fireServer = function(itemId: string, quantity: number)
		-- fire/listen wiring for this connection
	end,
})

return 0
```

See [Event](/modules/event).

## Indexes and registries

Both are pure data. Return the table directly. Never attach methods to the index table; lookup logic lives in `shared/utils/*Helper`.

Wrong:

```luau
local weapons = {}
weapons.sword = { damage = 15 }
table.freeze(weapons)
return table.freeze(weapons)
```

Correct:

```luau
return {
	sword = { damage = 15 },
}
```

Registry modules follow the same single-expression rule: `return { key = value, ... }`, no local-first assignment, no `table.freeze()`.

See [Registry](/modules/registry).

## HUD frames

Filename IS the UI surface. Normal code building that interface, ending `return 0`. The HUD runner spawns each frame in parallel via `task.spawn`.

See [HUD Frame](/modules/hud-frame).

::: info
The bootstrapper enforces these contracts. If a module violates its shape, expect a `[SERVICE]` or `[CONTROLLER]` error in the Output and see [Debugging](/debugging/) for triage.
:::