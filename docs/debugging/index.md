---
title: Debugging
description: Structured log prefixes and ServerLoaded troubleshooting for the RBX DDD architecture.
---

# Debugging

All bootstrapper and module logs use structured prefixes. Filter the Studio Output by prefix to isolate the failing layer.

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

## ServerLoaded stays false

The client blocks on `workspace.ServerLoaded`. If it never flips, the server did not finish loading. Triage in order:

1. Open the Output window. Filter for `[SERVICE] Failed` or `[SERVICE]` with an error.
2. Look for `[CONTROLLER]` lines with `Start failed`. A controller returning the wrong shape or throwing inside `start()` halts progression.
3. Fix the offending module. The bootstrapper will not advance past failures; there is no partial-success path.
4. Re-run. Confirm `[SERVER] Server fully loaded` appears, then `[CLIENT] Server loaded`.

Common causes:

| Symptom | Likely cause |
|---|---|
| `[SERVICE] Failed` on a module | Require error: typo in path, missing `.luau` extension, circular require |
| `[CONTROLLER] Start failed #N` | Controller missing `start`, wrong return shape, or runtime throw inside `start()` |
| No `[SERVER]` line at all | Installer did not run, or bootstrapper Script is not in `ServerScriptService` |
| `[CLIENT] Waiting for server...` forever | Server halted before setting `ServerLoaded`; check server Output first |

## HUD frame errors

A frame that throws logs under `[HUD]` and is skipped. Other frames keep running. To locate the bad frame, read the suffix after `Bootstrap runtime error:` — it names the frame module. Fix the frame, re-run, confirm the `[HUD]` error clears.

::: info
Contract violations fail at load time, not silently at runtime. If a module loads but behaves wrongly later, the bug is inside the module, not the architecture. Check naming and `const`/`local` usage against [Code Rules](/architecture/code-rules).
:::

Related pages: [Contracts](/architecture/contracts), [Controller](/modules/controller), [Service](/modules/service), [HUD Frame](/modules/hud-frame).