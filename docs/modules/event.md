---
title: Event
description: "shared/events pattern for the RBX DDD architecture. One ModuleScript per server-client connection, wrapping the network library."
---

# Event

Every server-client connection lives in `shared/events`. One ModuleScript per connection, named after the event (e.g. `purchaseItem.luau`). The module wraps the network library call and ends with `return 0`. It is required for its side effect of registering the connection, not for a return value.

## Why one file per event

Most Roblox projects start with a single network handler script that manages all RemoteEvents. It works fine until you have 20+ events. Then you're scrolling through a 500-line file trying to find where `purchaseItem` is defined. You're hunting through nested `if` statements, trying to understand which events depend on which services.

The one-file-per-event pattern exists to prevent that entropy. When you need to understand how `purchaseItem` works, you open `purchaseItem.luau` and see the entire connection definition in five lines. No hunting. No scrolling. No context switching.

This also makes debugging easier. When a network error occurs, the stack trace points directly to the event file. You know immediately which connection failed. You don't have to trace through a monolithic handler to find the culprit.

## Why no domain logic in events

Event modules only move data across the boundary. They don't validate, transform, or act on the data. That responsibility belongs to controllers and services.

When you need to change how purchases work, you know the logic is in the ShopService, not scattered across event handlers. The event is just the transport layer.

## Why both sides require the same module

Both server and client require the same event module path. This ensures the channel definition stays identical on both sides. If you defined the channel separately on server and client, you could accidentally drift out of sync: different parameter names, different types, silent failures.

By requiring the same module, you get compile-time guarantees that both sides agree on the channel structure. If you change the parameter types in `purchaseItem.luau`, both server and client see the change immediately. There's no way for them to disagree.

## Contract

- Location: `ReplicatedStorage/shared/events/*.luau`.
- Filename = event name. camelCase, matching the network channel identifier.
- Contents: code that fires/listens on this single connection.
- Return: `0`. Always.
- Network library: whatever lives in `shared/packages` (RemoteEvents wrapper, Promise-based lib, etc.). The event module is the only place that touches it for this channel.

## Example

```luau
-- shared/events/purchaseItem.luau
const Packages = script.Parent.Parent.packages
const NetworkLib = require(Packages.NetworkLib)

NetworkLib.define("purchaseItem", {
	fireServer = function(itemId: string, quantity: number)
	end,
})

return 0
```

The `Packages` and `NetworkLib` bindings are `const`: module references, immutable for the file's lifetime. `define` registers the channel. The trailing `return 0` marks the module as side-effect-only.

## Payload shapes belong in definitions

If your event passes complex data structures (like a purchase request with item ID, quantity, and player inventory snapshot), those shapes belong in `shared/definitions`, not inline in the event module.

The reason is reuse and consistency. If multiple events pass the same data structure (like `PlayerInventory`), you want to define it once in `definitions/inventory.luau` and reference it everywhere. If you redefine it inline in each event, you risk drift: one event expects `coins: number`, another expects `currency: number`. They're the same thing with different names.

By centralizing payload shapes in definitions, you get type safety and consistency across your entire network layer.

## Rules

- One file, one connection. Do not bundle two events into one module.
- No domain logic inside the event module. Validate and act in the controller or service that listens; the event module only moves data across the boundary.
- Both sides require the same module path so the channel definition stays identical on server and client.
- Payload shapes belong in `shared/definitions`. Reference the type, do not redefine it inline.

See [Folder Reference](/architecture/folder-reference) for where `shared/events` sits relative to `shared/packages` and `shared/definitions`, and [Contracts](/architecture/contracts) for the full contract table.
