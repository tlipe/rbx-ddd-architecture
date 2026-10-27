---
title: HUD Frame
description: "client/ui/frames convention for the RBX DDD architecture. Filename is the UI surface, HUD runner spawns frames via task.spawn."
---

# HUD Frame

`client/ui/frames` holds one ModuleScript per UI surface. The module name IS the UI it programs (`shopCoin.luau`, `shopSwords.luau`, `inventoryFrame.luau`). Inside: normal code building that interface. Ends with `return 0`.

## Contract

- Location: `StarterPlayer/StarterPlayerScripts/client/ui/frames/*.luau`.
- Filename = UI surface identity. camelCase matching the component or screen it builds.
- Contents: ordinary Instance construction and signal wiring for that one surface.
- Return: `0`. Always.
- Runner: `client/ui/hud` requires every frame and spawns each in parallel via `task.spawn`.

## Example: shopCoin

```luau
-- client/ui/frames/shopCoin.luau
const CoinsLabel = script.Parent:WaitForChild("CoinsLabel"):: TextLabel
const LocalPlayer = game.Players.LocalPlayer

CoinsLabel.Text = `${LocalPlayer:GetAttribute("Coins")} coins`

LocalPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
	CoinsLabel.Text = `${LocalPlayer:GetAttribute("Coins")} coins`
end)

return 0
```

## HUD runner

`client/ui/hud` is a single ModuleScript orchestrator. It iterates the frames folder, requires each module, and spawns it:

```luau
-- client/ui/hud.luau (sketch)
const FramesFolder = script.Parent.frames

for _, frame in FramesFolder:GetChildren() do
	task.spawn(function()
		require(frame)
	end)
end

return 0
```

Each frame runs concurrently. A failing frame logs under the `[HUD]` prefix and does not block siblings. Do not modify the runner without understanding this loop.

## Helpers

Quick reusable utilities scoped to frames live in `client/ui/helpers`. Sibling frame modules consume them. They are pure builders/formatters, not state holders.

## Rules

- One surface per file. If a frame grows past one screen, split it into sibling frames plus a shared helper.
- No domain logic in frames. Read attributes, render, forward input through [events](/modules/event). Compute on the server.
- Frames never require each other. Shared state flows through attributes or events, not direct module coupling.
- Filename carries meaning. Rename the file when the surface changes; do not keep stale names.

See [Folder Reference](/architecture/folder-reference) for how `frames`, `helpers`, and `hud` relate, and [Contracts](/architecture/contracts) for the full table.
