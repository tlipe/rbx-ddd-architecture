---
title: Introduction
description: What the RBX DDD architecture is, why use it, and how the server/client bootstrappers initialize a Roblox Luau project.
---

# Introduction

RBX DDD Architecture is a folder-and-convention foundation for Roblox Luau projects. It applies Domain-Driven Design ideas to the Roblox instance tree: every module has a fixed home, a fixed lifecycle, and a fixed contract. You add files in the right folder and they work; no manual wiring between modules.

One script generates the entire tree, the server and client bootstrappers, and the contract scaffolding. From there the structure scales from 3 services to 30 without refactoring.

## Why use it

| Benefit | Detail |
|---|---|
| Instant setup | One script builds the entire folder tree, bootstrappers, and contracts. Zero manual configuration. |
| Convention over configuration | Services load themselves. Controllers register `start()`. No manual wiring between modules. |
| Synchronized server-client | Client waits for `ServerLoaded` before initializing. No race conditions at startup. |
| Scale without refactoring | Start with 3 services, grow to 30 without changing the structure. Add a module in the right folder, it is ready. |
| Native observability | LogService integrated. Every load/failure appears in the Studio Output with clear context. |
| Explicit contract | Typed interfaces (`Controller`, service return). Contract errors fail at load time, not silent runtime. |

## Initialization flow

```
Studio Play
    │
    ▼
server/bootstrapper (Script)
    ├── loads services/*.luau ──► require + count (initialized once, no start())
    ├── loads controllers/*.luau ──► require + validates start()
    ├── executes controller:start() in order
    └── workspace.ServerLoaded = true
            │
            ▼
client/bootstrapper (LocalScript)
    ├── awaits ServerLoaded (GetAttributeChangedSignal)
    ├── loads services/*.luau
    ├── loads controllers/*.luau
    ├── loads ui/hud
    └── workspace.ClientLoaded = true
```

The server finishes first and flips `workspace.ServerLoaded`. The client listens on that attribute and only then loads its own services, controllers, and HUD. Startup ordering is enforced by the bootstrappers, not by each module.

## Where to go next

Every folder has an exact meaning. Read the [folder reference](/architecture/folder-reference) before placing your first module. To put the architecture into a place, see [installation](/guide/installation).