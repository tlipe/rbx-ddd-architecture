---
title: HUD Frame
description: "client/ui/frames convention for the RBX DDD architecture. Filename is the UI surface, HUD runner spawns frames via task.spawn."
---

# HUD Frame

`client/ui/frames` holds one ModuleScript per UI surface. The module name IS the UI it programs (`shopCoin.luau`, `shopSwords.luau`, `inventoryFrame.luau`). Inside: normal code building that interface. Ends with `return 0`.

## Why one file per UI surface

Most Roblox projects start with a single UI handler script that manages all screens. It works fine until you have 10+ screens. Then you're scrolling through a 2000-line file trying to find where the shop UI is defined. You're hunting through nested functions, trying to understand which signals belong to which screen.

The one-file-per-surface pattern exists to prevent that entropy. When you need to fix a bug in the shop UI, you open `shopCoin.luau` and see the entire screen definition in 30 lines. No hunting. No scrolling. No context switching.

This also makes the Explorer readable. When you look at `client/ui/frames`, you see exactly what UI surfaces exist: `shopCoin.luau`, `shopSwords.luau`, `inventoryFrame.luau`. The filename is the screen. There's no ambiguity.

## Why frames are presentation-only

Frames read state, display it, and forward user input through events. They don't compute. They don't validate. They don't make decisions. All computation happens on the server.

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

The frame reads the player's `Coins` attribute and displays it. When the attribute changes, it updates the label.

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

Each frame runs concurrently. A failing frame logs under the `[HUD]` prefix and does not block siblings.

## Why parallel spawning

Each frame runs concurrently. A failing frame logs under the `[HUD]` prefix and does not block siblings.

Do not modify the runner without understanding this loop.

## Why frames never require each other

Frames never require each other. Shared state flows through attributes or events, not direct module coupling.

## Helpers

Quick reusable utilities scoped to frames live in `client/ui/helpers`. Sibling frame modules consume them. They are pure builders/formatters, not state holders.

## Rules

- One surface per file. If a frame grows past one screen, split it into sibling frames plus a shared helper.
- No domain logic in frames. Read attributes, render, forward input through [events](/modules/event). Compute on the server.
- Frames never require each other. Shared state flows through attributes or events, not direct module coupling.
- Filename carries meaning. Rename the file when the surface changes; do not keep stale names.

The one-surface-per-file rule is about cognitive load. When you open `shopCoin.luau`, you should see everything related to the coin shop. If the file is getting long, it's probably doing too much. Split it into smaller, focused frames.

See [Folder Reference](/architecture/folder-reference) for how `frames`, `helpers`, and `hud` relate, and [Contracts](/architecture/contracts) for the full table.
