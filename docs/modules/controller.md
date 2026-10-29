---
title: Controller
description: Controller module contract and a PlayerJoinController example for the RBX DDD architecture.
---

# Controller

Controllers orchestrate systems. They don't implement domain logic. They wire things together: connecting signals, driving systems, handling the flow of your game. If services are the foundation, controllers are the rooms built on top of it.

Every controller returns exactly `{ start = function(self) }`, and the bootstrapper calls `start()` in order after all services have loaded. This is the key difference from services, and it's worth understanding why.

## Why controllers have start() but services don't

Services initialize at require time. When you require a service, it runs its top-level code and returns. That's it. Services are infrastructure: they set up connections, initialize state, and make themselves available.

Controllers are different. They need to initialize in a specific order, after all services are ready. If a controller tried to use DataStoreService before that service was initialized, you'd get nil references and silent failures. The `start()` method ensures proper sequencing.

The bootstrapper loads all services first (they initialize at require time), then loads all controllers and calls `start()` on each one in order. By the time your controller's `start()` runs, every service it depends on is already there and ready.

## Contract

- Location: `server/controllers/*.luau` or `client/controllers/*.luau`.
- Return: `{ start: (self) -> () }`. Missing `start` or a wrong type is a load-time error.
- Called: after all services load, in registration order.
- Purpose: wire events, connect signals, drive systems. Not to hold domain logic.

The contract is strict for a reason. If you return the wrong shape, the bootstrapper can't call `start()` on your controller, and the whole initialization sequence breaks. The load-time error tells you immediately what went wrong, instead of letting you debug a silent failure later.

## Example: PlayerJoinController

Let's walk through a complete example. This controller handles player join and leave events, loading and saving player data:

```luau
-- server/controllers/PlayerJoinController.luau
const Players = game:GetService("Players")
const DataService = require(script.Parent.Parent.services.DataStoreService)

local function onPlayerAdded(player: Player)
	local data = DataService.Load(player)
	if not data then
		data = { coins = 0, level = 1 }
	end
	player:SetAttribute("Coins", data.coins)
	player:SetAttribute("Level", data.level)
end

local function onPlayerRemoving(player: Player)
	DataService.Save(player, {
		coins = player:GetAttribute("Coins"),
		level = player:GetAttribute("Level"),
	})
end

return {
	start = function(self)
		Players.PlayerAdded:Connect(onPlayerAdded)
		Players.PlayerRemoving:Connect(onPlayerRemoving)
	end,
}
```

The controller requires the `DataStoreService` as a `const` binding. Inside `start()`, it connects signal handlers to `PlayerAdded` and `PlayerRemoving`.

The `onPlayerAdded` function checks if the data is `nil` and provides default values. The service just loads data. The controller decides what to do when data is missing.

The `onPlayerRemoving` function reads the current values from player attributes and saves them. The controller orchestrates the flow: when a player leaves, read the current state and save it.

## Server vs client controllers

Server controllers own gameplay systems and network wiring. A `PlayerJoinController` handles player join and leave. A `CombatController` manages combat flow. A `ShopController` handles purchases. These controllers connect services, events, and signals to drive the game logic.

Client controllers cover input handlers, camera, and animations. They follow the same `start()` lifecycle. A `CameraController` manages camera behavior. An `InputController` handles user input. An `AnimationController` drives character animations. Same pattern, different domain.

The distinction matters because server controllers run on the server and have access to server-side services and data. Client controllers run on the client and have access to user input, camera control, and rendering APIs. They're separate because they operate in different contexts with different capabilities.

## What controllers don't do

Controllers don't hold domain logic. If you find yourself writing complex business logic inside a controller, that logic probably belongs in a service or a class. Controllers connect the dots. They don't implement the dots.

For example, a controller shouldn't calculate damage formulas, validate purchase transactions, or determine level-up thresholds. Those belong in services or classes. The controller just wires the signals: when a player attacks, call the CombatService. When a player makes a purchase, call the ShopService.

## Consumption pattern

Require the service as a `const` binding. Call its public methods from inside signal handlers registered in `start()`.

The pattern is consistent: controllers consume services, connect signals, and drive the flow. They don't hold domain logic. That belongs in services or classes.

See [Service](/modules/service) for what a controller consumes and [Contracts](/architecture/contracts) for the full validation rules.
