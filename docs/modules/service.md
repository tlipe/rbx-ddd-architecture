---
title: Service
description: "Service module contract and a full DataStoreService example for the RBX DDD architecture."
---

# Service

Services are long-lived infrastructure. They initialize once when required. They return either `0` (side-effect only) or a table with public methods. They never expose `start()`.

## Contract

- Location: `server/services/*.luau` or `client/services/*.luau`.
- Lifecycle: initialized at require time, exactly once.
- Return: table with public methods OR `return 0`.
- Forbidden: `start()`, mutable module-level state without accessor discipline.
- Failure behavior: a failing require aborts that service only; other services continue loading.

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

## Side-effect-only variant

When a service only sets up listeners or primes caches without exposing methods, return `0`:

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
