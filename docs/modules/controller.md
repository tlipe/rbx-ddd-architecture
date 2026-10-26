---
title: Controller
description: Controller module contract and a PlayerJoinController example for the RBX DDD architecture.
---

# Controller

A controller orchestrates a system. It returns exactly `{ start = function(self) }`. The bootstrapper requires every controller, validates the shape, then calls `start()` in order after all services have loaded.

## Contract

- Location: `server/controllers/*.luau` or `client/controllers/*.luau`.
- Return: `{ start: (self) -> () }`. Missing `start` or a wrong type is a load-time error.
- Called: after all services load, in registration order.
- Purpose: wire events, connect signals, drive systems. Not to hold domain logic.

## Example: PlayerJoinController

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

::: warning
Attribute reads use colon syntax: `player:GetAttribute("Level")`, not `player.GetAttribute("Level")`. Dot syntax drops the implicit `self` and fails at runtime. Every Roblox instance method in this architecture is called with `:`.
:::

## Consumption pattern

Require the service as a `const` binding. Call its public methods from inside signal handlers registered in `start()`. Keep handlers as named `local` functions so the `start` body stays readable and stack traces point at real names.

Client controllers cover input handlers, camera, and animations. They follow the same `start()` lifecycle. Server controllers own gameplay systems and network wiring through [events](/modules/event).

See [Service](/modules/service) for what a controller consumes and [Contracts](/architecture/contracts) for the full validation rules.