---
title: Service
description: "Service module contract and a full DataStoreService example for the RBX DDD architecture."
---

# Service

Services are the foundation of your architecture. They're long-lived infrastructure that initializes once when required and stays available for the lifetime of the game. Think of them as the plumbing: data persistence, authentication, resource management. They're always there, always working, and you don't need to turn them on every morning.

Services never expose `start()`. The bootstrapper doesn't call one. Services initialize at require time, and that's it. This is different from controllers, which we'll cover later. Services are the foundation; controllers are the orchestration layer that sits on top. Once you internalize this distinction, the rest of the architecture clicks into place.

## Contract

- Location: `server/services/*.luau` or `client/services/*.luau`.
- Lifecycle: initialized at require time, exactly once.
- Return: table with public methods OR `return 0`.
- Forbidden: `start()`, mutable module-level state without accessor discipline.
- Failure behavior: a failing require aborts that service only; other services continue loading.

The failure behavior is worth highlighting. If one service breaks, it doesn't take down your entire game. The bootstrapper logs a `[SERVICE]` error and keeps going. This is intentional. You want to be able to fix one broken service without blocking the rest of your game from loading.

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

The two `const` bindings at the top (`DataStoreService`, `store`) are service references. They stay immutable for the module's lifetime. The inner `ok`/`result` pairs are `local` because they're mutable per-call state. Public methods are PascalCase keys in the returned table (`Load`, `Save`); internal functions are camelCase (`loadData`, `saveData`).

The reason we use `pcall` is that DataStore operations can fail. Network issues, throttling, outages. By wrapping them in `pcall`, we catch errors gracefully and return meaningful values instead of crashing the caller. The service absorbs the failure and returns `nil` or `false`, letting the caller decide what to do.

Notice how the service doesn't know anything about players, coins, or game logic. It just loads and saves data. The controller that uses this service knows about players and game state. The service knows about data persistence. This separation of concerns is what makes the architecture scalable.

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

The distinction between "table of methods" and "return 0" is simple: if other modules need to call into the service, return a table. If the service just needs to exist and do its thing, return `0`. Most services return tables. Side-effect-only services are the exception, not the rule.

## Consumption pattern

Controllers consume services by requiring them and calling the public methods. Here's how a controller would use the DataStoreService:

```luau
-- server/controllers/PlayerJoinController.luau
const DataService = require(script.Parent.Parent.services.DataStoreService)

local function onPlayerAdded(player: Player)
	local data = DataService.Load(player)
	if not data then
		data = { coins = 0, level = 1 }
	end
	player:SetAttribute("Coins", data.coins)
	player:SetAttribute("Level", data.level)
end
```

The controller requires the service as a `const` binding. It calls `DataService.Load(player)` and gets back the data (or `nil` if the load failed). The controller doesn't know how the service loads data. It doesn't care about `pcall`, DataStore keys, or error handling. It just calls the public method and uses the result.

This is the contract: services expose public methods, controllers call them. Services handle the how, controllers handle the when and why. This separation keeps your code modular and testable.

See [Controller](/modules/controller) for the full orchestration pattern.
