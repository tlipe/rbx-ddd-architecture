---
title: HUD Frame
description: "client/ui/frames convention for the RBX DDD architecture. Filename is the UI surface, HUD runner spawns frames via task.spawn."
---

# HUD Frame

If you've built UI in Roblox before, you know how quickly it can spiral. A single `UIHandler` LocalScript with 600 lines of GUI construction, signal wiring, and state management. Sound familiar? The `client/ui/frames` pattern exists specifically to prevent that kind of entropy.

The idea is straightforward: each UI surface gets its own file. The module name IS the UI it programs (`shopCoin.luau`, `shopSwords.luau`, `inventoryFrame.luau`). Inside, you write normal code building that interface. It always ends with `return 0`.

You might wonder why we don't have one big UI module that handles everything. We've all been there, and it works... until your UI grows. The shop doesn't need to know about the inventory, and the inventory doesn't need to know about the shop. By giving each surface its own file, you keep them isolated, easier to understand, and—crucially—easier to debug when something breaks at 2 AM.

## Contract

- Location: `StarterPlayer/StarterPlayerScripts/client/ui/frames/*.luau`.
- Filename = UI surface identity. camelCase matching the component or screen it builds.
- Contents: ordinary Instance construction and signal wiring for that one surface.
- Return: `0`. Always.
- Runner: `client/ui/hud` requires every frame and spawns each in parallel via `task.spawn`.

The `return 0` tells the HUD runner that this frame is side-effect-only. It built its UI, wired its signals, and it's done. No exported methods; the HUD doesn't call into the frame after spawn.

## Example: shopCoin

Let's look at a complete example. This frame displays the player's coin count and updates it when the value changes:

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

`CoinsLabel` and `LocalPlayer` are `const`: instance/player references immutable for the file's lifetime. The frame reads attributes, wires its own change signal, and returns `0`. Simple, clean, self-contained.

Notice how the frame doesn't compute anything—it just reads attributes and renders them. This is intentional. Frames are presentation layers. They read state, display it, and forward user input through events. All computation happens on the server.

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

The reason we spawn frames in parallel is performance. If you have ten UI frames and they each take 100ms to initialize, spawning them in parallel means your UI is ready in 100ms total, not 1000ms. And if one frame fails, the others keep running—one broken UI element doesn't take down your entire interface.

## Helpers

Quick reusable utilities scoped to frames live in `client/ui/helpers`. Sibling frame modules consume them. They are pure builders/formatters, not state holders.

If you find yourself copying the same formatting code across multiple frames, extract it into a helper. This keeps your frames DRY and makes the formatting logic easier to test and maintain.

## Rules

- One surface per file. If a frame grows past one screen, split it into sibling frames plus a shared helper.
- No domain logic in frames. Read attributes, render, forward input through [events](/modules/event). Compute on the server.
- Frames never require each other. Shared state flows through attributes or events, not direct module coupling.
- Filename carries meaning. Rename the file when the surface changes; do not keep stale names.

The reason frames never require each other is decoupling. If `shopCoin` requires `shopSwords`, you've created a dependency that makes both files harder to understand and maintain. Instead, shared state flows through attributes or events—loose coupling that keeps each frame independent.

The one-surface-per-file rule is about cognitive load. When you open `shopCoin.luau`, you should see everything related to the coin shop. If the file is getting long, it's probably doing too much. Split it into smaller, focused frames.

See [Folder Reference](/architecture/folder-reference) for how `frames`, `helpers`, and `hud` relate, and [Contracts](/architecture/contracts) for the full table.

Now that you understand how UI frames work, you're ready to debug issues when they arise. Head over to [Debugging](/debugging/) to learn how to read the structured logs and troubleshoot common problems.
