---
title: Event
description: "shared/events pattern for the RBX DDD architecture. One ModuleScript per server-client connection, wrapping the network library."
---

# Event

Every server-client connection lives in `shared/events`. One ModuleScript per connection, named after the event (e.g. `purchaseItem.luau`). The module wraps the network library call and ends with `return 0`. It is required for its side effect of registering the connection, not for a return value.

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
		-- fire/listen wiring for this connection
	end,
})

return 0
```

The `Packages` and `NetworkLib` bindings are `const`: module references, immutable for the file's lifetime. `define` registers the channel. The trailing `return 0` marks the module as side-effect-only.

## Rules

- One file, one connection. Do not bundle two events into one module.
- No domain logic inside the event module. Validate and act in the controller or service that listens; the event module only moves data across the boundary.
- Both sides require the same module path so the channel definition stays identical on server and client.
- Payload shapes belong in `shared/definitions`. Reference the type, do not redefine it inline.

See [Folder Reference](/architecture/folder-reference) for where `shared/events` sits relative to `shared/packages` and `shared/definitions`, and [Contracts](/architecture/contracts) for the full contract table.