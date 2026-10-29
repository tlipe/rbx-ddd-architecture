---
title: Debugging
description: Structured log prefixes and ServerLoaded troubleshooting for the RBX DDD architecture.
---

# Debugging

All bootstrapper and module logs use structured prefixes. Filter the Studio Output by prefix to isolate the failing layer.

## Why structured prefixes

When something goes wrong in your Roblox game, the last thing you want is to spend hours hunting through code trying to figure out where the problem is. The structured prefix system exists to turn debugging from a guessing game into a systematic process.

Each prefix acts like a label on a filing cabinet. Instead of dumping everything into one log stream and sorting through it manually, the architecture automatically organizes your logs by layer. When you see `[SERVICE] Failed`, you know immediately that the problem is in a service module. When you see `[CONTROLLER] Start failed`, you know it's a controller issue. You can filter the Studio Output by prefix and see exactly what's happening in that layer.

This matters because Roblox games have complex initialization sequences. Services load, controllers start, the server signals readiness, the client connects, UI frames spawn. If something breaks, you need to know which layer failed. Without structured prefixes, you'd be reading through a wall of undifferentiated log output, trying to figure out where the problem is.

## Log prefixes

| Prefix | Source | Meaning |
|---|---|---|
| `[SERVICE]` | bootstrapper / service | Service load, loaded, or failure |
| `[CONTROLLER]` | bootstrapper / controller | Controller registration, start, or start failure |
| `[SERVER]` | server/bootstrapper | Server-side lifecycle milestones |
| `[CLIENT]` | client/bootstrapper | Client-side lifecycle milestones |
| `[HUD]` | client/ui/hud | Frame spawn/runtime errors |

Example output:

```
[SERVICE] Loading DataStoreService...
[SERVICE] Loaded DataStoreService.
[CONTROLLER] Registered PlayerJoinController.
[CONTROLLER] Start failed #2: attempt to index nil value
[SERVER] Server fully loaded in 0.04s.
[CLIENT] Waiting for server...
[CLIENT] Server loaded. Timestamp: 1730000000
[HUD] Bootstrap runtime error: shopCoin -> ...
```

When you see this output, you can immediately tell what's happening. Services loaded successfully, a controller failed to start, the server finished loading, the client connected, and there's an error in the `shopCoin` HUD frame. Each prefix tells you which layer to investigate.

## ServerLoaded stays false

The client blocks on `workspace.ServerLoaded`. If it never flips, the server did not finish loading. Triage in order:

1. Open the Output window. Filter for `[SERVICE] Failed` or `[SERVICE]` with an error.
2. Look for `[CONTROLLER]` lines with `Start failed`. A controller returning the wrong shape or throwing inside `start()` halts progression.
3. Fix the offending module. The bootstrapper will not advance past failures; there is no partial-success path.
4. Re-run. Confirm `[SERVER] Server fully loaded` appears, then `[CLIENT] Server loaded`.

## Why the bootstrapper doesn't advance past failures

The bootstrapper is strict: if a service or controller fails, it halts. There's no partial-success path.

Common causes:

| Symptom | Likely cause |
|---|---|
| `[SERVICE] Failed` on a module | Require error: typo in path, missing `.luau` extension, circular require |
| `[CONTROLLER] Start failed #N` | Controller missing `start`, wrong return shape, or runtime throw inside `start()` |
| No `[SERVER]` line at all | Installer did not run, or bootstrapper Script is not in `ServerScriptService` |
| `[CLIENT] Waiting for server...` forever | Server halted before setting `ServerLoaded`; check server Output first |

The most common cause is a typo in a require path or a circular dependency. If you see `[SERVICE] Failed`, check that the path is correct and that you're not creating a circular require (module A requires module B, which requires module A).

## HUD frame errors

A frame that throws logs under `[HUD]` and is skipped. Other frames keep running. The suffix after `Bootstrap runtime error:` names the frame module. Fix that frame, re-run, and confirm the `[HUD]` error clears.

## Why HUD frames are isolated

A frame that throws logs under `[HUD]` and is skipped. Other frames keep running. The suffix after `Bootstrap runtime error:` names the frame module. Fix that frame, re-run, and confirm the `[HUD]` error clears.

::: info
Contract violations fail at load time, not silently at runtime. If a module loads but behaves wrongly later, the bug is inside the module, not the architecture.
:::

## Why contracts fail at load time

The architecture enforces contracts at load time. If a module returns the wrong shape, you get an error immediately. This is fail-fast: catch problems early, before they become runtime headaches.

If your module loads correctly but then behaves wrongly at runtime, that's a bug in your code, not the architecture. Check your logic, your naming, your `const`/`local` usage. The architecture gave you a clean foundation. What you build on top of it is your responsibility.

Related pages: [Contracts](/architecture/contracts), [Controller](/modules/controller), [Service](/modules/service), [HUD Frame](/modules/hud-frame).
