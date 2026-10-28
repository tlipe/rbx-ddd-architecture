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

The reason for this separation is security and maintainability. If your client-side frame contains business logic (like "check if player has enough coins before showing purchase button"), you're trusting the client to make that decision. A malicious player could modify the client code and bypass that check. By keeping all logic on the server, you ensure that validation happens in a trusted environment.

It also keeps your code organized. When you need to change how the shop works, you know the logic is in the ShopService on the server, not scattered across client-side frames. The frame is just the display layer.

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

The frame reads the player's `Coins` attribute and displays it. When the attribute changes, it updates the label. That's it. No computation. No validation. Just display.

Notice how the frame doesn't know where the coins came from. It doesn't know if the player earned them, bought them, or received them as a gift. It just displays the current value. The server handles all that logic. The frame is purely reactive.

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

The reason we spawn frames in parallel is performance. If you have ten UI frames and they each take 100ms to initialize, spawning them sequentially means your UI is ready in 1000ms. Spawning them in parallel means your UI is ready in 100ms total.

That's the difference between a snappy UI and a sluggish one. Players notice when the UI takes a second to load. They don't notice when it takes 100ms.

The parallel spawning also provides error isolation. If one frame throws an error during initialization, the other frames keep running. One broken UI element doesn't take down your entire interface. The HUD runner logs the error under `[HUD]` and continues.

This is a deliberate design trade-off. The server-side bootstrapper is strict: it halts on any failure because server systems tend to depend on each other. But the client-side HUD bootstrapper is lenient: it skips failures because UI frames are usually independent. The architecture makes different choices for different contexts.

Do not modify the runner without understanding this loop. The parallel spawning and error isolation are deliberate design choices.

## Why frames never require each other

Frames never require each other. Shared state flows through attributes or events, not direct module coupling.

The reason for this rule is decoupling. If `shopCoin` requires `shopSwords`, you've created a dependency that makes both files harder to understand and maintain. You can't test `shopCoin` in isolation anymore. You can't load it without also loading `shopSwords`.

By keeping frames independent, you can load, unload, or modify any frame without affecting the others. Shared state flows through player attributes (which both frames can read) or through events (which both frames can listen to). This is loose coupling, and it keeps your UI modular.

If you find yourself thinking "frame A needs to know what frame B is doing", that's a sign that the state should live on the server, not in the client. Push the state up to the server, expose it as a player attribute, and let both frames react to it independently.

## Helpers

Quick reusable utilities scoped to frames live in `client/ui/helpers`. Sibling frame modules consume them. They are pure builders/formatters, not state holders.

If you find yourself copying the same formatting code across multiple frames, extract it into a helper. For example, if three frames all format currency values the same way, create a `formatCurrency` helper in `client/ui/helpers/currency.luau`. This keeps your frames DRY and makes the formatting logic easier to test and maintain.

Helpers are pure functions. They don't hold state. They don't connect to signals. They just transform data. If your helper starts doing more than that, it probably belongs in a service, not a helper.

## Rules

- One surface per file. If a frame grows past one screen, split it into sibling frames plus a shared helper.
- No domain logic in frames. Read attributes, render, forward input through [events](/modules/event). Compute on the server.
- Frames never require each other. Shared state flows through attributes or events, not direct module coupling.
- Filename carries meaning. Rename the file when the surface changes; do not keep stale names.

The one-surface-per-file rule is about cognitive load. When you open `shopCoin.luau`, you should see everything related to the coin shop. If the file is getting long, it's probably doing too much. Split it into smaller, focused frames.

See [Folder Reference](/architecture/folder-reference) for how `frames`, `helpers`, and `hud` relate, and [Contracts](/architecture/contracts) for the full table.
