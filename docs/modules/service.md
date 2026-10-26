---
title: Service
description: "Service module contract and a full DataStoreService example for the RBX DDD architecture."
---

# Service

A service is long-lived infrastructure. It initializes once when required. It returns either `0` (side-effect only) or a table of public methods. It never exposes `start()`; the bootstrapper does not call one on services.

## Contract

- Location: `server/services/*.luau` or `client/services/*.luau`.
- Lifecycle: initialized at require time, exactly once.
- Return: table with public methods OR `return 0`.
- Forbidden: `start()`, mutable module-level state without accessor discipline.
- Failure behavior: a failing require aborts that service only; other services continue loading.

## Naming

Service references are `const` and LOUD_SNAKE_CASE when they hold config or a service singleton. Required modules are `const`. Mutable locals inside functions stay `local`.

## Example: DataStoreService

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

The two `const` bindings (`DataStoreService`, `store`) are service references and stay immutable for the module's lifetime. The inner `ok`/`result` pairs are `local` because they are mutable per-call state. Public methods are PascalCase keys in the returned table; internal functions are camelCase.

## Side-effect-only variant

When a service only registers listeners or primes caches, return `0`:

```luau
-- client/services/AudioService.luau
const SoundService = game:GetService("SoundService")
const DefaultSoundGroup = SoundService:FindFirstChild("Default"):: SoundGroup?

if DefaultSoundGroup then
	DefaultSoundGroup.Volume = 0.8
end

return 0
```

Controllers consume services by requiring them and calling the public methods. See [Controller](/modules/controller) for the consumption pattern.