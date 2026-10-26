---
title: Service
description: "Service module contract and a full DataStoreService example for the RBX DDD architecture."
---

# Service

If you've built Roblox games before, you already know that some things need to "just work" the moment your game starts. Data persistence, authentication, audio configuration—these aren't features you toggle on and off. They're infrastructure. That's exactly what services are in this architecture.

Think of services as the long-lived foundation that everything else builds on. They initialize once when required, and from that point forward, they're always available. No startup ceremony, no lifecycle management, no surprises.

You'll notice that services never expose a `start()` method, and that's intentional. The reason is simple: services initialize at require time, so the bootstrapper doesn't need to orchestrate their startup. This is different from controllers, which we'll cover later. Services are the foundation; controllers are the orchestration layer that sits on top. Once you internalize this distinction, the rest of the architecture clicks into place.

## Contract

- Location: `server/services/*.luau` or `client/services/*.luau`.
- Lifecycle: initialized at require time, exactly once.
- Return: table with public methods OR `return 0`.
- Forbidden: `start()`, mutable module-level state without accessor discipline.
- Failure behavior: a failing require aborts that service only; other services continue loading.

The failure behavior is worth highlighting. If one service breaks, it doesn't take down your entire game. The bootstrapper logs a `[SERVICE]` error and keeps going. This is intentional—you want to be able to fix one broken service without blocking the rest of your game from loading.

## Naming

Service references are `const` and LOUD_SNAKE_CASE when they hold config or a service singleton. Required modules are `const`. Mutable locals inside functions stay `local`. This naming convention makes it immediately clear what's immutable infrastructure versus what's temporary state.

## Example: DataStoreService

Let's walk through a complete example. This service wraps Roblox's DataStoreService to handle player data persistence:

```luau
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

Let's break down what's happening here. The two `const` bindings (`DataStoreService`, `store`) are service references and stay immutable for the module's lifetime. The inner `ok`/`result` pairs are `local` because they're mutable per-call state. Public methods are PascalCase keys in the returned table (`Load`, `Save`); internal functions are camelCase (`loadData`, `saveData`).

The reason we use `pcall` is that DataStore operations can fail—network issues, throttling, outages. By wrapping them in `pcall`, we catch errors gracefully and return meaningful values instead of crashing the caller.

## Side-effect-only variant

Sometimes a service doesn't need to expose methods. Maybe it just sets up listeners or primes caches. In that case, return `0`:

```luau
-- client/services/AudioService.luau
const SoundService = game:GetService("SoundService")
const DefaultSoundGroup = SoundService:FindFirstChild("Default"):: SoundGroup?

if DefaultSoundGroup then
	DefaultSoundGroup.Volume = 0.8
end

return 0
```

This service configures the default sound group's volume when it loads. It doesn't expose any methods because nothing else needs to call into it. The `return 0` tells the bootstrapper: "I did my thing, I'm ready, but I don't have a public API."

Controllers consume services by requiring them and calling the public methods. See [Controller](/modules/controller) for the consumption pattern.

Now that you understand services, you're ready to see how controllers orchestrate them. Head over to [Controller](/modules/controller) to see the other half of the equation.
