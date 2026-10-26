---
title: Controller
description: Controller module contract and a PlayerJoinController example for the RBX DDD architecture.
---

# Controller

If services are the foundation, controllers are the conductor. They don't play instruments—they make sure everyone plays together, at the right time, in the right order. Controllers are responsible for wiring things together: connecting signals, driving systems, handling the flow of your game.

Every controller returns exactly `{ start = function(self) }`, and the bootstrapper calls `start()` in order after all services have loaded. This is the key difference from services, and it's worth understanding why.

The reason controllers have a `start()` method but services don't is sequencing. Controllers need to initialize after all services are ready. Imagine if a controller tried to use DataStoreService before that service was initialized—you'd get nil references and silent failures that are nightmare fuel to debug. The `start()` method ensures proper ordering, so by the time your controller runs, everything it depends on is already there.

## Contract

- Location: `server/controllers/*.luau` or `client/controllers/*.luau`.
- Return: `{ start: (self) -> () }`. Missing `start` or a wrong type is a load-time error.
- Called: after all services load, in registration order.
- Purpose: wire events, connect signals, drive systems. Not to hold domain logic.

The key thing to understand is that controllers orchestrate—they don't implement. Domain logic belongs in services or classes. Controllers just connect the dots.

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

Let's break down what's happening here. The controller requires the `DataStoreService` as a `const` binding. Inside `start()`, it connects signal handlers to `PlayerAdded` and `PlayerRemoving`. The handlers are named `local` functions (`onPlayerAdded`, `onPlayerRemoving`) rather than anonymous functions—this keeps the `start` body readable and makes stack traces point at real names when something goes wrong.

::: warning
Attribute reads use colon syntax: `player:GetAttribute("Level")`, not `player.GetAttribute("Level")`. Dot syntax drops the implicit `self` and fails at runtime. Every Roblox instance method in this architecture is called with `:`.
:::

This is a common gotcha, especially if you're coming from other languages. Roblox instance methods need the colon syntax because they expect `self` as the first parameter. Using dot syntax will compile fine but fail at runtime with a confusing error.

## Consumption pattern

Require the service as a `const` binding. Call its public methods from inside signal handlers registered in `start()`. Keep handlers as named `local` functions so the `start` body stays readable and stack traces point at real names.

Client controllers cover input handlers, camera, and animations. They follow the same `start()` lifecycle. Server controllers own gameplay systems and network wiring through [events](/modules/event).

The pattern is consistent: controllers consume services, connect signals, and drive the flow. They don't hold domain logic—that belongs in services or classes. This separation makes your code easier to test and reason about.

See [Service](/modules/service) for what a controller consumes and [Contracts](/architecture/contracts) for the full validation rules.

Now that you understand how controllers orchestrate systems, you're ready to see how server and client communicate. Head over to [Event](/modules/event) to understand the network layer.
