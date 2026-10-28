---
title: Contracts
description: "Module contracts for services, controllers, events, indexes, registries, packages, and HUD frames in the RBX DDD architecture."
---

# Contracts

A contract defines what a module must return and how the bootstrapper treats it. The bootstrapper enforces these contracts at load time: if a module violates its shape, you get a logged error immediately, not a silent failure that shows up hours later during gameplay.

This fail-fast approach exists because Roblox games have complex initialization sequences. If a service fails to load but the game continues anyway, controllers that depend on it will get nil references and crash later. By catching contract violations at load time, you know exactly what broke and where, instead of debugging a cascade of runtime errors.

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

Services initialize once when required. They return either a table of public methods (if other modules need to call into the service) or `return 0` (if the service only needs to set up listeners or prime caches).

Services never expose `start()`. The bootstrapper doesn't call one. Services initialize at require time, and that's it. This is different from controllers, which we'll cover next.

The reason services don't have a `start()` method is that they're infrastructure, not orchestration. A `DataStoreService` that handles persistence is always available once it's required. It doesn't need to wait for other services or coordinate with controllers. It just does its job. Controllers, on the other hand, need to initialize in a specific order after all services are ready, which is why they have `start()`.

A failing require kills that service only; the rest continue loading. This is intentional. One broken service shouldn't take down your entire game. You'll see a `[SERVICE]` error in the Output, and you can fix it without affecting other systems.

See [Service](/modules/service) for a full example.

## Controllers

Controllers return exactly `{ start = function(self) }`. The bootstrapper requires every controller, validates the shape, then calls `start()` in order after all services are loaded. Missing `start` or a wrong type is a load-time error.

The reason controllers have a `start()` method but services don't is sequencing. Controllers need to initialize after all services are ready. If a controller tried to use DataStoreService before that service was initialized, you'd get nil references and silent failures that are nightmare fuel to debug. The `start()` method ensures proper ordering, so by the time your controller runs, everything it depends on is already there.

Controllers orchestrate systems. They don't implement domain logic. A `PlayerJoinController` connects to `Players.PlayerAdded` and `Players.PlayerRemoving`, loads player data from the service, and sets attributes. It doesn't know how DataStoreService works internally. It just calls the public methods. This separation keeps controllers focused on wiring and flow, while services handle the actual work.

See [Controller](/modules/controller).

## Events

Events handle server-client communication. One ModuleScript per connection, named after the event. The module wraps the network library call and ends with `return 0`. It's required for its side effect of registering the connection, not for a return value.

The reason we use one file per event is maintainability. When you're debugging a network issue, you can immediately find the exact file that handles that connection. No hunting through monolithic network modules. It's the difference between having one giant phone book and having a contact card for each person.

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

Notice how the file is named after the event it handles. This isn't just a convention. It's a discoverability feature. When you're looking for where `purchaseItem` is defined, you don't search through code. You just open `shared/events/purchaseItem.luau`.

See [Event](/modules/event).

## Indexes and registries

Both indexes and registries are pure data. You return the table directly. Never attach methods to the index table; lookup logic lives in `shared/utils/*Helper`.

The reason for this strict separation is that it keeps data pure and behavior isolated. When data tables are immutable and method-free, you can reason about them without worrying about hidden side effects. And when lookup logic is in utilities, it's reusable and testable.

Wrong:

```luau
local weapons = {}
weapons.sword = { damage = 15 }
table.freeze(weapons)
return table.freeze(weapons)
```

The problem with this pattern isn't that `table.freeze()` is bad. The problem is that you're assigning to a local first, which means the table is mutable during construction. There's a window where the table could be modified before it's frozen. Direct return removes that window entirely.

Correct:

```luau
return {
	sword = { damage = 15 },
}
```

Registry modules follow the same single-expression rule: `return { key = value, ... }`, no local-first assignment, no `table.freeze()`.

See [Registry](/modules/registry).

## HUD frames

HUD frames handle your UI surfaces. The filename IS the UI surface. You write normal code building that interface, ending with `return 0`. The HUD runner spawns each frame in parallel via `task.spawn`.

The reason we spawn frames in parallel is performance. If you have ten UI frames and they each take 100ms to initialize, spawning them in parallel means your UI is ready in 100ms total, not 1000ms. That's the difference between a snappy UI and a sluggish one.

See [HUD Frame](/modules/hud-frame).

::: info
The bootstrapper enforces these contracts. If a module violates its shape, expect a `[SERVICE]` or `[CONTROLLER]` error in the Output and see [Debugging](/debugging/) for triage.
:::
