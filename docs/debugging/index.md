---
title: Debugging
description: Structured log prefixes and ServerLoaded troubleshooting for the RBX DDD architecture.
---

# Debugging

Let's be honest: when something goes wrong in your Roblox game, the last thing you want is to spend hours hunting through code trying to figure out where the problem is. We've all been there — staring at a wall of log output, clicking through files, wondering why nothing works the way it should.

That's exactly why the RBX DDD architecture uses structured log prefixes. Every bootstrapper and module log uses a specific prefix, so you can filter the Studio Output and immediately isolate the failing layer. Think of it as a debugging superpower. Instead of staring at a wall of undifferentiated output, you can filter by `[SERVICE]`, `[CONTROLLER]`, `[HUD]`, or whatever prefix is relevant, and see exactly what's happening in that layer.

You'll notice that this approach transforms debugging from a frustrating guessing game into a systematic process. Once you learn to read the prefixes, you'll be able to pinpoint problems in seconds rather than minutes.

## Log prefixes

Here's what each prefix means and where it comes from. You'll want to keep this table handy — it's your map for navigating the log output:

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

The reason this works so well is that each prefix acts like a label on a filing cabinet. Instead of dumping everything into one drawer and sorting through it manually, the architecture automatically organizes your logs by layer. This means you can go from "something is broken" to "the PlayerJoinController is failing to start" in a single filter operation.

## ServerLoaded stays false

This is one of the most common issues you'll encounter — and honestly, it's the one that trips up most developers when they first work with this architecture. The client blocks on `workspace.ServerLoaded`. If it never flips, the server did not finish loading. Here's how to triage it, in order:

1. Open the Output window. Filter for `[SERVICE] Failed` or `[SERVICE]` with an error.
2. Look for `[CONTROLLER]` lines with `Start failed`. A controller returning the wrong shape or throwing inside `start()` halts progression.
3. Fix the offending module. The bootstrapper will not advance past failures; there is no partial-success path.
4. Re-run. Confirm `[SERVER] Server fully loaded` appears, then `[CLIENT] Server loaded`.

The reason the bootstrapper doesn't advance past failures is that partial success is dangerous. If a service failed to load, controllers that depend on it will get nil references. If a controller failed to start, the systems it orchestrates won't be wired up. Better to halt and tell you what's wrong than to limp along with broken systems.

Think of it like a car assembly line: if the engine installation fails, you don't want the car to keep moving down the line with no engine. You want the line to stop, a big red light to flash, and someone to come fix the problem before anything else proceeds.

Common causes:

| Symptom | Likely cause |
|---|---|
| `[SERVICE] Failed` on a module | Require error: typo in path, missing `.luau` extension, circular require |
| `[CONTROLLER] Start failed #N` | Controller missing `start`, wrong return shape, or runtime throw inside `start()` |
| No `[SERVER]` line at all | Installer did not run, or bootstrapper Script is not in `ServerScriptService` |
| `[CLIENT] Waiting for server...` forever | Server halted before setting `ServerLoaded`; check server Output first |

The most common cause is a typo in a require path or a circular dependency. If you see `[SERVICE] Failed`, check that the path is correct and that you're not creating a circular require (module A requires module B, which requires module A). We've all made this mistake at some point — it's one of those things that's easy to overlook when you're moving fast.

A good habit to build: when you add a new module, immediately run the game once to confirm it loads. That way, if something breaks later, you know the problem isn't a stale require path from days ago.

## HUD frame errors

A frame that throws logs under `[HUD]` and is skipped. Other frames keep running. To locate the bad frame, read the suffix after `Bootstrap runtime error:` — it names the frame module. Fix the frame, re-run, confirm the `[HUD]` error clears.

The reason we skip failing frames instead of halting is that UI elements are often independent. If the shop UI breaks, you probably still want the inventory UI to work. By isolating frame failures, you can fix one broken UI element without taking down your entire interface.

This is a deliberate design trade-off. The server-side bootstrapper is strict — it halts on any failure because server systems tend to depend on each other. But the client-side HUD bootstrapper is lenient — it skips failures because UI frames are usually independent. The architecture makes different choices for different contexts, and understanding why helps you make similar decisions in your own code.

::: info
Contract violations fail at load time, not silently at runtime. If a module loads but behaves wrongly later, the bug is inside the module, not the architecture. Check naming and `const`/`local` usage against [Code Rules](/architecture/code-rules).
:::

This is an important distinction. The architecture enforces contracts at load time—if you return the wrong shape, you'll get an error immediately. But if your module loads correctly and then behaves wrongly at runtime, that's a bug in your code, not the architecture. Check your logic, your naming, your `const`/`local` usage.

You can think of contracts like a bouncer at a club: they check your ID at the door (load time), but once you're inside, what you do is your own responsibility (runtime). If someone misbehaves inside, you don't blame the bouncer — you fix the behavior.

Related pages: [Contracts](/architecture/contracts), [Controller](/modules/controller), [Service](/modules/service), [HUD Frame](/modules/hud-frame).

Now that you know how to read the logs and triage the most common issues, you're in a much better position to build with confidence. The structured logs will guide you when things go wrong, and the contracts will catch problems before they become runtime headaches. The next time you see an error in the Output window, you'll know exactly where to look.
