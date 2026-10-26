---
title: Event
description: "shared/events pattern for the RBX DDD architecture. One ModuleScript per server-client connection, wrapping the network library."
---

# Event

Networking is where most Roblox projects start to fall apart. You know the pattern: a single `RemoteHandler` script with 400 lines of `if eventName == "purchaseItem" then ... elseif ...` chains. It works until it doesn't. The `shared/events` pattern exists specifically to prevent that.

The idea is simple: one ModuleScript per server-client connection, named after the event itself (e.g., `purchaseItem.luau`). Each module wraps the network library call and ends with `return 0`. You require it for its side effect—registering the connection—not for a return value.

You might wonder why we don't just put all network code in one big module. We've all been there, and it works... until it doesn't. When you're debugging a network issue at 2 AM, you want to open `purchaseItem.luau` and see exactly how that connection works in five lines—not hunt through a 500-line monolithic network module. One file, one connection, zero ambiguity.

## Contract

Here's the short version of what makes an event module an event module. Keep this checklist handy:

- Location: `ReplicatedStorage/shared/events/*.luau`.
- Filename = event name. camelCase, matching the network channel identifier.
- Contents: code that fires/listens on this single connection.
- Return: `0`. Always.
- Network library: whatever lives in `shared/packages` (RemoteEvents wrapper, Promise-based lib, etc.). The event module is the only place that touches it for this channel.

That `return 0` might look strange at first, but it serves a real purpose. It tells the bootstrapper: "I did my thing—I registered the connection—but I don't expose a public API." It's the same pattern you saw with side-effect-only services, and it keeps the bootstrapper's job consistent across module types.

## Example

Here's what a typical event module looks like:

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

Notice how clean this is. The entire connection definition fits in a few lines. When you need to understand how `purchaseItem` works, you open this file and you're done.

## Rules

- One file, one connection. Do not bundle two events into one module.
- No domain logic inside the event module. Validate and act in the controller or service that listens; the event module only moves data across the boundary.
- Both sides require the same module path so the channel definition stays identical on server and client.
- Payload shapes belong in `shared/definitions`. Reference the type, do not redefine it inline.

The reason we keep domain logic out of event modules is separation of concerns. The event module's job is to move data across the network boundary. Validation, business rules, and side effects belong in controllers or services. This makes each layer easier to understand and test.

When both sides require the same module path, you guarantee that the channel definition is identical on server and client. If you defined the channel separately on each side, you could accidentally drift out of sync—different parameter names, different types, silent failures.

See [Folder Reference](/architecture/folder-reference) for where `shared/events` sits relative to `shared/packages` and `shared/definitions`, and [Contracts](/architecture/contracts) for the full contract table.

Now that you understand how server and client communicate, you're ready to see how pure data modules work. Head over to [Registry](/modules/registry) to understand indexes and registries.
