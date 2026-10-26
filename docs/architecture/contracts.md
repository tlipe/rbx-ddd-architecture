---
title: Contracts
description: "Module contracts for services, controllers, events, indexes, registries, packages, and HUD frames in the RBX DDD architecture."
---

# Contracts

If you've ever debugged a Roblox project where modules silently failed to load or behaved unpredictably, you know how frustrating it is when the system doesn't tell you what went wrong. Contracts solve that problem.

A contract is what a module must return and how the bootstrapper treats it. The beauty of this system is that contract violations fail at load time with a logged error, not silently at runtime. You'll know immediately when something's wrong, and the error message will point you to the exact issue.

Think of contracts as a handshake between your module and the bootstrapper. You agree to return a specific shape, and the bootstrapper agrees to handle it correctly. When both sides follow the contract, everything just works. And when someone breaks the contract? You get a clear error message instead of a mysterious bug that only shows up in production.

## Contract table

Here's the complete overview of what each module type must return:

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

You'll notice that the contracts are intentionally strict. The reason is that strictness at the module level buys you flexibility at the system level. When every module follows the same pattern, you can add, remove, or replace modules without worrying about breaking the whole system. It's like having a standardized plug shape—you can swap out any appliance as long as it uses the right plug.

## Services

Services are the foundation of your architecture. They initialize once when required. You can return either a table of public methods (if other modules need to call into the service) or `return 0` (if the service only needs to set up listeners or prime caches).

The key thing to understand is that services never expose `start()`. The bootstrapper doesn't call one. Services initialize at require time, and that's it. This is different from controllers, which we'll cover next.

Think of services as your application's infrastructure layer. A `DataStoreService` that handles persistence, an `AuthService` that manages authentication, a `ResourceService` that manages game assets—these are always-on systems that other modules depend on. They're like the plumbing in your house: always there, always working, and you don't need to turn them on every morning.

A failing require kills that service only; the rest continue loading. This is intentional—one broken service shouldn't take down your entire game. You'll see a `[SERVICE]` error in the Output, and you can fix it without affecting other systems.

See [Service](/modules/service) for a full example.

## Controllers

Controllers are the orchestration layer. They return exactly `{ start = function(self) }`. The bootstrapper requires every controller, validates the shape, then calls `start()` in order after all services are loaded.

The reason controllers have a `start()` method is that they need to initialize in a specific order, after all services are ready. If a controller tried to use a service before that service was initialized, you'd get nil references. The `start()` method ensures proper sequencing.

Think of controllers as the conductors of your game's systems. A `GameController` that orchestrates the game loop, a `CombatController` that manages combat flow, a `UIController` that coordinates UI updates—these are the systems that tie everything together. They wait for the foundation (services) to be ready, then they start orchestrating.

Missing `start` or a wrong type is a load-time error. The bootstrapper won't silently skip a broken controller—it'll tell you exactly what's wrong.

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

Notice how the file is named after the event it handles. This isn't just a convention—it's a discoverability feature. When you're looking for where `purchaseItem` is defined, you don't search through code; you just open `shared/events/purchaseItem.luau`.

See [Event](/modules/event).

## Indexes and registries

Both indexes and registries are pure data. You return the table directly. Never attach methods to the index table; lookup logic lives in `shared/utils/*Helper`.

The reason for this strict separation is that it keeps data pure and behavior isolated. When data tables are immutable and method-free, you can reason about them without worrying about hidden side effects. And when lookup logic is in utilities, it's reusable and testable.

Think of indexes as your game's database tables and utilities as your query functions. The data just sits there, pure and immutable. The utilities know how to query, filter, and transform that data. This separation makes both easier to understand and test.

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

You might wonder why we don't use `table.freeze()`. The answer is that direct return removes the window where the table could be mutated. If you're assigning to a local first, there's a moment where the table is mutable. Direct return eliminates that window entirely. It's like the difference between building a house and then locking it versus building it already locked.

Registry modules follow the same single-expression rule: `return { key = value, ... }`, no local-first assignment, no `table.freeze()`.

See [Registry](/modules/registry).

## HUD frames

HUD frames handle your UI surfaces. The filename IS the UI surface. You write normal code building that interface, ending with `return 0`. The HUD runner spawns each frame in parallel via `task.spawn`.

The reason we spawn frames in parallel is performance. If you have ten UI frames and they each take 100ms to initialize, spawning them in parallel means your UI is ready in 100ms total, not 1000ms. That's the difference between a snappy UI and a sluggish one.

Think of the HUD runner as a stage crew that sets up all your sets at the same time instead of one after another. Each frame is independent, so there's no reason to wait for one to finish before starting the next.

See [HUD Frame](/modules/hud-frame).

::: info
The bootstrapper enforces these contracts. If a module violates its shape, expect a `[SERVICE]` or `[CONTROLLER]` error in the Output and see [Debugging](/debugging/) for triage.
:::

Now that you understand the contracts, you're ready to dive into the specifics of each module type. Head over to [Service](/modules/service) to see a complete example, or check [Code Rules](/architecture/code-rules) to understand the naming conventions that keep the codebase consistent.
